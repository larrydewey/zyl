#include "actor_runtime.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <limits.h>
#include <spawn.h>
#include <sys/wait.h>
extern char** environ;

#define ZYL_HEAP_ARENA_DEFAULT_BLOCK (1024 * 1024)
#define ZYL_PIN_ARENA_DEFAULT_BLOCK (256 * 1024)

static ZylActorSystem g_system;
static void* g_heap_arena = NULL;
static void* g_pin_arena = NULL;

#include <sys/resource.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <pthread.h>

/* Run `fn` on a worker thread with a very large stack and return its
   integer result. Used by generated main so deep recursion in
   self-hosted compiler runs cannot exhaust the 8MB main-thread stack
   (which is frequently capped by adjacent mmaps). */
struct ZylBigStackCtx {
    long long (*fn)(void);
    long long result;
};

static void* zyl_bigstack_tramp(void* arg) {
    struct ZylBigStackCtx* ctx = (struct ZylBigStackCtx*)arg;
    ctx->result = ctx->fn();
    return 0;
}

/* Historically this used pthread_attr_setstacksize (pthread does its own
 * internal mmap for the stack) at a fixed 64GB, and the whole process had
 * to run under `setarch -R` (ASLR fully off) because that allocation
 * intermittently crashed/hung under ASLR (~20% of runs; see commit
 * fc0ad72). Disabling ASLR for the entire process to work around one
 * allocation is a much bigger exploit-mitigation downgrade than the
 * problem calls for -- it also weakens every other mapping in the
 * process (heap, shared libs, every other thread's stack), including
 * whatever untrusted zyl program this process may go on to run.
 *
 * Fix: allocate the stack ourselves via explicit mmap (MAP_NORESERVE, so
 * it's a virtual reservation, not a real memory commitment) and hand it
 * to pthread via pthread_attr_setstack instead of letting pthread pick
 * the placement. This gives explicit, checkable error handling instead
 * of a fire-and-forget internal allocation, and a graceful size ladder
 * (64GB down to 1GB) instead of one all-or-nothing size -- so a
 * constrained environment degrades instead of crashing. A single mmap
 * call is also unaffected by ASLR in the way that mattered here: the
 * kernel never returns overlapping memory for it, so this needs no
 * personality/ASLR change to be reliable. */
static const size_t ZYL_BIGSTACK_SIZES[] = {
    (size_t)64 * 1024 * 1024 * 1024ULL,
    (size_t)16 * 1024 * 1024 * 1024ULL,
    (size_t)4  * 1024 * 1024 * 1024ULL,
    (size_t)1  * 1024 * 1024 * 1024ULL,
};
#define ZYL_BIGSTACK_GUARD 4096

long long zyl_call_on_big_stack(long long (*fn)(void)) {
    for (size_t i = 0; i < sizeof(ZYL_BIGSTACK_SIZES) / sizeof(ZYL_BIGSTACK_SIZES[0]); i++) {
        size_t sz = ZYL_BIGSTACK_SIZES[i];
        void* stack = mmap(NULL, sz, PROT_READ | PROT_WRITE,
                            MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE, -1, 0);
        if (stack == MAP_FAILED) continue;
        /* Guard page at the low end (stack grows down toward it): an
         * overflow past the reserved size faults immediately instead of
         * silently running into whatever happens to sit below. */
        mprotect(stack, ZYL_BIGSTACK_GUARD, PROT_NONE);

        pthread_attr_t attr;
        pthread_attr_init(&attr);
        if (pthread_attr_setstack(&attr, stack, sz) != 0) {
            pthread_attr_destroy(&attr);
            munmap(stack, sz);
            continue;
        }
        pthread_t t;
        struct ZylBigStackCtx ctx;
        ctx.fn = fn;
        ctx.result = 0;
        if (pthread_create(&t, &attr, zyl_bigstack_tramp, &ctx) != 0) {
            pthread_attr_destroy(&attr);
            munmap(stack, sz);
            continue;
        }
        pthread_join(t, 0);
        pthread_attr_destroy(&attr);
        munmap(stack, sz);
        return ctx.result;
    }
    /* Every reservation size failed: fall back to running inline on the
     * current (small) stack rather than crashing outright. */
    return fn();
}



/* Raise the main-thread stack soft limit to the hard limit so deep
   recursion in self-hosted compiler runs can grow beyond 8MB. Must run
   before deep recursion starts; called from zyl_ensure_arenas (invoked
   in every generated main prologue). Idempotent and harmless when the
   hard limit is already reached. */
static void zyl_raise_stack_limit(void) {
    struct rlimit rl;
    if (getrlimit(RLIMIT_STACK, &rl) == 0 && rl.rlim_cur < rl.rlim_max) {
        rl.rlim_cur = rl.rlim_max;
        setrlimit(RLIMIT_STACK, &rl);
    }
}

void zyl_ensure_arenas(void) {
    static int stack_raised = 0;
    if (!stack_raised) { stack_raised = 1; zyl_raise_stack_limit(); }
    if (!g_heap_arena) {
        g_heap_arena = (void*)(size_t)zyl_arena_create(ZYL_HEAP_ARENA_DEFAULT_BLOCK);
    }
    if (!g_pin_arena) {
        g_pin_arena = (void*)(size_t)zyl_arena_create(ZYL_PIN_ARENA_DEFAULT_BLOCK);
    }
}

__attribute__((destructor))
static void zyl_runtime_cleanup(void) {
    if (g_pin_arena) {
        zyl_arena_destroy((long long)(size_t)g_pin_arena);
        g_pin_arena = NULL;
    }
    if (g_heap_arena) {
        zyl_arena_destroy((long long)(size_t)g_heap_arena);
        g_heap_arena = NULL;
    }
}

void zyl_actor_init(void) {
    if (g_system.initialized) return;
    memset(&g_system, 0, sizeof(g_system));
    g_system.next_id = 0;
    g_system.initialized = 1;
}

uint32_t zyl_actor_spawn(void (*entry)(void*), void* state) {
    if (!g_system.initialized) zyl_actor_init();

    uint32_t id = g_system.next_id;
    if (id >= ZYL_MAX_ACTORS) {
        fprintf(stderr, "zyl: actor limit reached (%d)\n", ZYL_MAX_ACTORS);
        return (uint32_t)-1;
    }

    ZylActor* actor = &g_system.actors[id];
    actor->entry = entry;
    actor->state = state;
    actor->mailbox_head = NULL;
    actor->mailbox_tail = NULL;
    actor->mailbox_count = 0;
    actor->alive = 1;
    actor->running = 0;
    actor->joined = 0;
    pthread_mutex_init(&actor->lock, NULL);
    pthread_cond_init(&actor->cond, NULL);

    pthread_create(&actor->thread, NULL, zyl_actor_thread_entry, (void*)(size_t)id);
    g_system.next_id++;

    return id;
}

void zyl_actor_send(uint32_t actor_id, void* msg) {
    /* IDs are monotonic (never recycled -- next_id only increments, spawn
       just refuses once it hits ZYL_MAX_ACTORS), so no generation counter
       is needed to distinguish "reused" IDs. What IS unguarded without the
       next_id check: an ID that was never spawned still indexes a live
       slot in the fixed actors[] array, so sending to it would lock/touch
       an actor whose mutex/cond were never pthread_*_init'd. */
    if (!g_system.initialized || actor_id >= ZYL_MAX_ACTORS || actor_id >= g_system.next_id) {
        free(msg);
        return;
    }

    ZylActor* actor = &g_system.actors[actor_id];

    ZylMessage* m = (ZylMessage*)malloc(sizeof(ZylMessage));
    if (!m) {
        free(msg);
        return;
    }
    m->kind = ZYL_MSG_DATA;
    m->data = msg;
    m->next = NULL;

    pthread_mutex_lock(&actor->lock);
    if (!actor->alive) {
        pthread_mutex_unlock(&actor->lock);
        free(m);
        free(msg);
        return;
    }
    if (actor->mailbox_tail) {
        actor->mailbox_tail->next = m;
    } else {
        actor->mailbox_head = m;
    }
    actor->mailbox_tail = m;
    actor->mailbox_count++;
    pthread_cond_signal(&actor->cond);
    pthread_mutex_unlock(&actor->lock);
}

void zyl_actor_send_data(uint32_t actor_id, void* data) {
    zyl_actor_send(actor_id, data);
}

void zyl_actor_send_closure(uint32_t actor_id, void (*fn)(void*), void* state) {
    if (!g_system.initialized || actor_id >= ZYL_MAX_ACTORS || actor_id >= g_system.next_id) {
        return;
    }

    ZylActor* actor = &g_system.actors[actor_id];

    ZylClosureMsg* closure = (ZylClosureMsg*)malloc(sizeof(ZylClosureMsg));
    if (!closure) {
        return;
    }
    closure->fn = fn;
    closure->state = state;

    ZylMessage* m = (ZylMessage*)malloc(sizeof(ZylMessage));
    if (!m) {
        free(closure);
        return;
    }
    m->kind = ZYL_MSG_CLOSURE;
    m->data = closure;
    m->next = NULL;

    pthread_mutex_lock(&actor->lock);
    if (!actor->alive) {
        pthread_mutex_unlock(&actor->lock);
        free(m);
        free(closure);
        return;
    }
    if (actor->mailbox_tail) {
        actor->mailbox_tail->next = m;
    } else {
        actor->mailbox_head = m;
    }
    actor->mailbox_tail = m;
    actor->mailbox_count++;
    pthread_cond_signal(&actor->cond);
    pthread_mutex_unlock(&actor->lock);
}

void* zyl_actor_thread_entry(void* arg) {
    uint32_t id = (uint32_t)(size_t)arg;
    if (id >= ZYL_MAX_ACTORS) return NULL;

    ZylActor* actor = &g_system.actors[id];

    pthread_mutex_lock(&actor->lock);
    actor->running = 1;
    pthread_mutex_unlock(&actor->lock);

    /* Run the entry function. */
    if (actor->entry) {
        actor->entry(actor->state);
    }

    /* Process mailbox FIFO until the actor is stopped by wait_all. */
    for (;;) {
        pthread_mutex_lock(&actor->lock);
        while (actor->alive && !actor->mailbox_head) {
            pthread_cond_wait(&actor->cond, &actor->lock);
        }
        if (!actor->alive) {
            pthread_mutex_unlock(&actor->lock);
            break;
        }
        ZylMessage* m = actor->mailbox_head;
        actor->mailbox_head = m->next;
        if (!actor->mailbox_head) actor->mailbox_tail = NULL;
        actor->mailbox_count--;
        pthread_mutex_unlock(&actor->lock);

        if (m->kind == ZYL_MSG_DATA) {
            /* Data message: data pointer is opaque, nothing to execute. */
        } else if (m->kind == ZYL_MSG_CLOSURE) {
            /* Closure message: extract and execute. */
            ZylClosureMsg* closure = (ZylClosureMsg*)m->data;
            if (closure && closure->fn) {
                closure->fn(closure->state);
            }
            free(closure);
        }

        free(m);
    }

    pthread_mutex_lock(&actor->lock);
    actor->running = 0;
    pthread_mutex_unlock(&actor->lock);
    return NULL;
}

void zyl_actor_wait_all(void) {
    /* Wait until all pending messages have been consumed, so messages sent
       before wait_all are guaranteed to be processed (avoids the race where
       a send lands after the consumer already drained an empty mailbox).

       The drain poll and the alive=0 pass below are two separate lock
       acquisitions per actor, so a message can still land in the gap
       between "this actor's mailbox read empty" and "we marked it dead"
       (send only checks `alive`, which is still 1 in that gap). Such a
       message would sit on the mailbox forever: the consumer thread's loop
       exits on `!alive` without re-checking mailbox_head, leaking it.
       Closed by re-checking mailbox_count at the point we're about to set
       alive=0, atomically with that write (same lock acquisition); if it's
       non-empty, skip stopping that actor this round and re-run the whole
       drain+stop pass instead. */
    for (;;) {
        int pending;
        do {
            pending = 0;
            for (uint32_t i = 0; i < ZYL_MAX_ACTORS; i++) {
                ZylActor* actor = &g_system.actors[i];
                pthread_mutex_lock(&actor->lock);
                int active = !actor->joined && (actor->running || actor->thread) && actor->mailbox_count > 0;
                pthread_mutex_unlock(&actor->lock);
                if (active) {
                    pending = 1;
                    break;
                }
            }
            if (pending) usleep(1000);
        } while (pending);

        int retry = 0;
        for (uint32_t i = 0; i < ZYL_MAX_ACTORS; i++) {
            ZylActor* actor = &g_system.actors[i];
            pthread_mutex_lock(&actor->lock);
            int active = !actor->joined && (actor->running || actor->thread);
            if (active && actor->mailbox_count > 0) {
                /* Message landed since the drain poll above; don't stop
                   this actor yet, let the outer loop drain it and retry. */
                pthread_mutex_unlock(&actor->lock);
                retry = 1;
                continue;
            }
            if (active) actor->alive = 0;
            pthread_t t = actor->thread;
            pthread_mutex_unlock(&actor->lock);
            if (active) {
                pthread_cond_broadcast(&actor->cond);
                pthread_join(t, NULL);
                pthread_mutex_lock(&actor->lock);
                actor->joined = 1;
                pthread_mutex_unlock(&actor->lock);
            }
        }
        if (!retry) break;
    }
}

/* ==========================================================================
   Dynamic closure invocation. A closure value is either a raw code pointer
   (static binary text, low addresses) or an env-block pointer (heap, high
   addresses) whose first qword is the code pointer and which takes the env
   as an extra leading argument. These helpers dispatch dynamically so call
   sites whose callee shape is unknown at compile time work for both.
   ========================================================================== */

#define ZYL_HEAP_THRESHOLD 0x100000000LL

/* Lowest address the kernel will ever map on Linux by default
 * (/proc/sys/vm/mmap_min_addr, 0x10000 on most distros; 0x1000 is the
 * conservative floor even on the most permissive configs). Neither branch
 * below does executable-page validation -- that needs parsing
 * /proc/self/maps or similar on every call, too costly for a hot path --
 * but a callee address under this floor can only be a null/uninitialized
 * slot or a small bogus integer misused as code, never a real function or
 * env-block pointer. Reject those before the indirect call/deref instead
 * of segfaulting (or worse, "succeeding") on attacker-influenced data. */
#define ZYL_MIN_CALL_ADDR 0x1000LL

static long long zyl_call_guard(long long v) {
    if (v < ZYL_MIN_CALL_ADDR) {
        fprintf(stderr, "zyl: invalid callee address 0x%llx\n", (unsigned long long)v);
        exit(1);
    }
    return v;
}

long long zyl_call0(long long v) {
    v = zyl_call_guard(v);
    if (v < ZYL_HEAP_THRESHOLD) return ((long long (*)(void))v)();
    return ((long long (*)(void*))*(long long*)(size_t)v)((void*)v);
}
long long zyl_call1(long long v, long long a) {
    v = zyl_call_guard(v);
    if (v < ZYL_HEAP_THRESHOLD) return ((long long (*)(long long))v)(a);
    return ((long long (*)(void*, long long))*(long long*)(size_t)v)((void*)v, a);
}
long long zyl_call2(long long v, long long a, long long b) {
    v = zyl_call_guard(v);
    if (v < ZYL_HEAP_THRESHOLD) return ((long long (*)(long long, long long))v)(a, b);
    return ((long long (*)(void*, long long, long long))*(long long*)(size_t)v)((void*)v, a, b);
}
long long zyl_call3(long long v, long long a, long long b, long long c) {
    v = zyl_call_guard(v);
    if (v < ZYL_HEAP_THRESHOLD) return ((long long (*)(long long, long long, long long))v)(a, b, c);
    return ((long long (*)(void*, long long, long long, long long))*(long long*)(size_t)v)((void*)v, a, b, c);
}
long long zyl_call4(long long v, long long a, long long b, long long c, long long d) {
    v = zyl_call_guard(v);
    if (v < ZYL_HEAP_THRESHOLD) return ((long long (*)(long long, long long, long long, long long))v)(a, b, c, d);
    return ((long long (*)(void*, long long, long long, long long, long long))*(long long*)(size_t)v)((void*)v, a, b, c, d);
}
long long zyl_call5(long long v, long long a, long long b, long long c, long long d, long long e) {
    v = zyl_call_guard(v);
    if (v < ZYL_HEAP_THRESHOLD) return ((long long (*)(long long, long long, long long, long long, long long))v)(a, b, c, d, e);
    return ((long long (*)(void*, long long, long long, long long, long long, long long))*(long long*)(size_t)v)((void*)v, a, b, c, d, e);
}
long long zyl_call6(long long v, long long a, long long b, long long c, long long d, long long e, long long f) {
    v = zyl_call_guard(v);
    if (v < ZYL_HEAP_THRESHOLD) return ((long long (*)(long long, long long, long long, long long, long long, long long))v)(a, b, c, d, e, f);
    return ((long long (*)(void*, long long, long long, long long, long long, long long, long long))*(long long*)(size_t)v)((void*)v, a, b, c, d, e, f);
}

/* ==========================================================================
   try/catch — panic handler stack. Generated code allocates a frame, links
   it, calls setjmp on its buffer, and branches to its catch path when
   siglongjmp returns nonzero. zyl_panic unwinds to the innermost frame.
   ========================================================================== */

#include <setjmp.h>
#include <stdlib.h>

struct ZylTryFrame {
    jmp_buf buf;
    struct ZylTryFrame* prev;
    const char* msg;
};

/* Thread-local: each actor runs its own thread with independent try/catch
 * nesting. A process-global here would let one actor's zyl_try_pop/
 * zyl_panic unlink or longjmp into another actor's frame/stack. */
static _Thread_local struct ZylTryFrame* g_try_top = 0;

void* zyl_try_push(void) {
    struct ZylTryFrame* f = (struct ZylTryFrame*)malloc(sizeof *f);
    f->prev = g_try_top;
    f->msg = 0;
    g_try_top = f;
    return (void*)f;
}

void zyl_try_pop(void) {
    if (g_try_top) g_try_top = g_try_top->prev;
}

const char* zyl_try_last_msg(void) {
    return g_try_top ? g_try_top->msg : 0;
}

/* The `msg` field of a specific frame (the pointer zyl_try_push returned
 * for it) -- unlike zyl_try_last_msg, valid to call AFTER a longjmp has
 * already unlinked that frame from g_try_top (zyl_panic pops before it
 * jumps), which is exactly when generated try/catch code needs it: the
 * frame pointer it saved across the longjmp is the only remaining
 * reference to it. */
long long zyl_try_frame_msg(long long frame) {
    if (!frame) return 0;
    return (long long)(size_t)((struct ZylTryFrame*)(size_t)frame)->msg;
}

/* ==========================================================================
   FFI pinning — copy an 8-byte value to a stable heap location and back.
   ========================================================================== */

/* Defined below, once the ZylArena block layout is in scope: validates that
 * `ptr` actually lies within a live block of g_pin_arena before ffi_unpin
 * is allowed to dereference it. Without this, ffi_unpin was an unchecked
 * arbitrary-address 8-byte read: any Int a zyl program computed (leaked
 * address, brute-forced offset) could be handed to ffi-unpin regardless of
 * whether ffi-pin ever produced it. */
static int zyl_ptr_in_pin_arena(long long ptr);

void* ffi_pin(long long value) {
    if (!g_pin_arena) return NULL;
    long long* slot = (long long*)zyl_arena_alloc((long long)(size_t)g_pin_arena, sizeof(long long));
    if (slot) *slot = value;
    return (void*)slot;
}

/* Unpinning returns the pinned value; the Pin arena reclaims storage in
 * bulk, so individual slots are never freed here. */
long long ffi_unpin(long long ptr) {
    if (!ptr) return 0;
    if (!zyl_ptr_in_pin_arena(ptr)) {
        fprintf(stderr, "zyl: ffi-unpin: pointer not from ffi-pin/Pin arena\n");
        return 0;
    }
    return *(long long*)(size_t)ptr;
}

/* ==========================================================================
   Raw memory arena — foundation for stdlib/allocator.
   Pointers are passed to/from Zyl as Int (64-bit).
   ========================================================================== */

/* Same rationale as zyl_call_guard (zyl_callN, above): every one of these
 * "string pointer" arguments is a Zyl Int that can be corrupted, brute-
 * forced, or simply a wrong value the program computed -- 0 is already a
 * valid "empty string" sentinel these helpers special-case, but a non-zero
 * value under ZYL_MIN_CALL_ADDR is never a real mapping and would run
 * strlen/strcmp/indexing off into unmapped memory (CWE-125 over-read).
 * Rejects that range cheaply before any of it runs. */
static int zyl_cstr_valid(long long ptr, const char* who) {
    if (ptr && ptr < ZYL_MIN_CALL_ADDR) {
        fprintf(stderr, "zyl: %s: invalid string pointer 0x%llx\n", who, (unsigned long long)ptr);
        return 0;
    }
    return 1;
}

long long zyl_cstr_len(long long ptr) {
    if (!ptr) return 0;
    if (!zyl_cstr_valid(ptr, "cstr-len")) return 0;
    return (long long)strlen((const char*)(size_t)ptr);
}

/* Concatenate two NUL-terminated strings into freshly heap-allocated
   storage (zyl_heap_alloc). Either argument may be NULL (treated as ""). */
long long zyl_cstr_concat(long long a, long long b) {
    if (!zyl_cstr_valid(a, "cstr-concat") || !zyl_cstr_valid(b, "cstr-concat")) return 0;
    const char* sa = a ? (const char*)(size_t)a : "";
    const char* sb = b ? (const char*)(size_t)b : "";
    size_t la = strlen(sa);
    size_t lb = strlen(sb);
    /* Checked arithmetic: la + lb + 1 must not overflow */
    if (la > SIZE_MAX - lb - 1) {
        zyl_panic("string concatenation length overflow");
    }
    char* buf = (char*)(size_t)zyl_heap_alloc((long long)(la + lb + 1));
    memcpy(buf, sa, la);
    memcpy(buf + la, sb, lb);
    buf[la + lb] = '\0';
    return (long long)(size_t)buf;
}

/* Copy a substring [start, start+len) of a NUL-terminated string into
   freshly heap-allocated storage (zyl_heap_alloc). Clamps len to the
   remaining bytes. NULL src is treated as "". */
long long zyl_cstr_substr(long long src, long long start, long long len) {
    if (!zyl_cstr_valid(src, "cstr-substr")) return 0;
    const char* s = src ? (const char*)(size_t)src : "";
    size_t slen = strlen(s);
    if (start < 0) start = 0;
    if ((size_t)start > slen) start = (long long)slen;
    size_t avail = slen - (size_t)start;
    if (len < 0) len = 0;
    if ((size_t)len > avail) len = (long long)avail;
    char* buf = (char*)(size_t)zyl_heap_alloc(len + 1);
    memcpy(buf, s + start, (size_t)len);
    buf[len] = '\0';
    return (long long)(size_t)buf;
}

/* Non-zero if the two NUL-terminated strings are byte-identical. */
long long zyl_cstr_eq(long long p1, long long p2) {
    if (p1 == p2) return 1;
    if (!p1 || !p2) return 0;
    if (!zyl_cstr_valid(p1, "cstr-eq") || !zyl_cstr_valid(p2, "cstr-eq")) return 0;
    const char* s1 = (const char*)(size_t)p1;
    const char* s2 = (const char*)(size_t)p2;
    return (long long)(strcmp(s1, s2) == 0);
}

long long zyl_mem_alloc(long long size) {
    return (long long)(size_t)malloc((size_t)size);
}

void zyl_mem_free(long long ptr) {
    free((void*)(size_t)ptr);
}

long long zyl_mem_read(long long ptr) {
    if (!ptr) { fprintf(stderr, "zyl: mem-read: null pointer\n"); return 0; }
    return *(volatile long long*)(size_t)ptr;
}

long long zyl_mem_write(long long ptr, long long value) {
    if (!ptr) { fprintf(stderr, "zyl: mem-write: null pointer\n"); return value; }
    *(volatile long long*)(size_t)ptr = value;
    return value;
}

/* ==========================================================================
   Character-level string access — substrate for the self-hosting lexer.
   ========================================================================== */

/* Byte at index `i` of a NUL-terminated string, or -1 if past the terminator. */
long long zyl_cstr_byte_at(long long ptr, long long i) {
    if (!ptr || i < 0) return -1;
    if (!zyl_cstr_valid(ptr, "cstr-byte-at")) return -1;
    const char* s = (const char*)(size_t)ptr;
    if (i >= (long long)strlen(s)) return -1;
    return (long long)(unsigned char)s[i];
}

/* Write byte `b` at index `i` of a buffer (does not manage the terminator). */
void zyl_cstr_byte_set(long long ptr, long long i, long long b) {
    if (!ptr || i < 0) return;
    if (!zyl_cstr_valid(ptr, "cstr-byte-set")) return;
    ((unsigned char*)(size_t)ptr)[i] = (unsigned char)b;
}

/* Copy bytes [start, start+len) of `src` into a fresh NUL-terminated buffer
   in `arena`, returning the new buffer pointer. Deterministic (copy order). */
long long zyl_cstr_sub(long long arena, long long src, long long start, long long len) {
    if (!src || start < 0 || len < 0) return 0;
    if (!zyl_cstr_valid(src, "cstr-sub")) return 0;
    const char* s = (const char*)(size_t)src;
    long long n = (long long)strlen(s);
    if (start + len > n) len = n - start < 0 ? 0 : n - start;
    long long buf = zyl_arena_alloc_zeroed(arena, len + 1);
    memcpy((void*)(size_t)buf, s + start, (size_t)len);
    ((char*)(size_t)buf)[len] = 0;
    return buf;
}

/* Parse a decimal integer string (optional leading '-') to a value.
   Returns 0 on overflow and sets errno to ERANGE. */
long long zyl_cstr_to_int(long long ptr) {
    if (!ptr) return 0;
    if (!zyl_cstr_valid(ptr, "cstr-to-int")) return 0;
    const char* s = (const char*)(size_t)ptr;
    long long neg = 0, v = 0;
    if (*s == '-') { neg = 1; s++; }
    while (*s >= '0' && *s <= '9') {
        int digit = *s - '0';
        /* Check for overflow before multiplying/adding */
        if (neg) {
            if (v < (LLONG_MIN + digit) / 10) {
                errno = ERANGE;
                return 0;
            }
        } else {
            if (v > (LLONG_MAX - digit) / 10) {
                errno = ERANGE;
                return 0;
            }
        }
        v = v * 10 + digit;
        s++;
    }
    return neg ? -v : v;
}

/* Convert a radix-prefixed integer literal ("0xFF", "-0xFF", "0b1010",
   "0o777", plain decimal) to its value. The single leading radix prefix
   (0x/0o/0b, any case) is consumed; everything after it is parsed in that
   base. No prefix means decimal. Used by the byte-primitive lexer (the
   `(byte 0xFF)` radix forms from BYTE_PRIMITIVES_IMPLEMENTATION_PLAN.md). */
long long zyl_cstr_to_int_base(long long ptr) {
    if (!ptr) return 0;
    if (!zyl_cstr_valid(ptr, "cstr-to-int-base")) return 0;
    const char* s = (const char*)(size_t)ptr;
    long long neg = 0, v = 0;
    if (*s == '-') { neg = 1; s++; }
    int base = 10;
    if (s[0] == '0') {
        char p = s[1];
        if (p == 'x' || p == 'X') { base = 16; s += 2; }
        else if (p == 'o' || p == 'O') { base = 8; s += 2; }
        else if (p == 'b' || p == 'B') { base = 2; s += 2; }
    }
    for (; *s; s++) {
        int digit;
        if (*s >= '0' && *s <= '9') digit = *s - '0';
        else if (*s >= 'a' && *s <= 'f') digit = *s - 'a' + 10;
        else if (*s >= 'A' && *s <= 'F') digit = *s - 'A' + 10;
        else break;
        if (digit >= base) break;
        if (neg) {
            if (v < (LLONG_MIN + digit) / base) { errno = ERANGE; return 0; }
        } else {
            if (v > (LLONG_MAX - digit) / base) { errno = ERANGE; return 0; }
        }
        v = v * base + digit;
    }
    return neg ? -v : v;
}

/* ==========================================================================
   Byte-level primitives for the byte/atomic/Endian feature.
   These implement the FFI calls lowered from the byte ICNF nodes
   (BYTE_PRIMITIVES_IMPLEMENTATION_PLAN.md).

   A ByteBuf handle and a ByteSlice handle are both plain heap pointers to
   a small tagged header, never a bare data pointer -- the magic tag lets
   every entry point reject a garbage/foreign int passed in through an
   unsafe FFI escape hatch instead of dereferencing it blind (same spirit
   as zyl_variant_eq's discriminant check above). A ByteBuf owns malloc'd,
   zero-initialized storage sized to its fixed capacity (no growth: append
   fails closed past cap, same as the E_BYTEBUF_CAP_EXCEEDED contract).
   A ByteSlice never owns memory -- it is only {data, len} borrowed from a
   ByteBuf (or another slice), so byteslice/byteslice-sub are zero-copy. */

#define ZYL_BYTEBUF_MAGIC   0x5A594C4255460001ULL /* "ZYLBUF" + kind 1 */
#define ZYL_BYTESLICE_MAGIC 0x5A594C4255460002ULL /* "ZYLBUF" + kind 2 */
#define ZYL_BYTEBUF_MAX_CAP (1LL << 40)

typedef struct {
    unsigned long long magic;
    unsigned char* data; /* separate malloc, sized to cap -- see zyl_bytebuf_new */
    long long len; /* bytes appended so far; <= cap */
    long long cap; /* fixed at creation, never grows */
} ZylByteBufHeader;

typedef struct {
    unsigned long long magic;
    unsigned char* data; /* borrowed -- never freed through this handle */
    long long len;
} ZylByteSliceHeader;

static ZylByteBufHeader* zyl_bytebuf_of(long long buf) {
    if (!buf) return NULL;
    ZylByteBufHeader* h = (ZylByteBufHeader*)(size_t)buf;
    return h->magic == ZYL_BYTEBUF_MAGIC ? h : NULL;
}

static ZylByteSliceHeader* zyl_byteslice_of(long long slice) {
    if (!slice) return NULL;
    ZylByteSliceHeader* h = (ZylByteSliceHeader*)(size_t)slice;
    return h->magic == ZYL_BYTESLICE_MAGIC ? h : NULL;
}

static unsigned char* zyl_bytebuf_data(ZylByteBufHeader* h) {
    return h->data;
}

/* off/size/bound all >= 0 and off+size <= bound, without signed overflow
   (mirrors zyl_arena_align_up's overflow-checked-first discipline above). */
static int zyl_bb_bounds_ok(long long off, long long size, long long bound) {
    if (off < 0 || size < 0 || bound < 0 || size > bound) return 0;
    return off <= bound - size;
}

/* A load/store target is either a ByteBuf (bounded by its fixed cap -- the
   whole cap is zero-initialized up front, so reading past len but within
   cap is well-defined, just zero) or a ByteSlice (bounded by its own len,
   which was already checked against its parent's extent when it was
   created). Resolves either handle kind to a flat {data, bound} view. */
typedef struct { unsigned char* data; long long bound; int valid; } ZylBytesView;

static ZylBytesView zyl_bytes_view(long long handle) {
    ZylBytesView v; v.data = NULL; v.bound = 0; v.valid = 0;
    ZylByteBufHeader* buf = zyl_bytebuf_of(handle);
    if (buf) { v.data = zyl_bytebuf_data(buf); v.bound = buf->cap; v.valid = 1; return v; }
    ZylByteSliceHeader* sl = zyl_byteslice_of(handle);
    if (sl) { v.data = sl->data; v.bound = sl->len; v.valid = 1; return v; }
    return v;
}

/* Load a byte from a ByteBuf/ByteSlice at offset (zero-extended). */
long long zyl_load_byte(long long endian, long long offset, long long buf) {
    (void)endian; /* single-byte load: endianness is a no-op until wider loads exist */
    ZylBytesView v = zyl_bytes_view(buf);
    if (!v.valid || !zyl_bb_bounds_ok(offset, 1, v.bound)) return 0;
    return (long long)v.data[offset];
}

/* Load a signed byte from a ByteBuf/ByteSlice at offset (sign-extended). */
long long zyl_load_byte_signed(long long endian, long long offset, long long buf) {
    (void)endian;
    ZylBytesView v = zyl_bytes_view(buf);
    if (!v.valid || !zyl_bb_bounds_ok(offset, 1, v.bound)) return 0;
    return (long long)(signed char)v.data[offset];
}

/* Store a byte into a ByteBuf/ByteSlice at offset. Returns 1 on success,
   0 if out of bounds (silent no-op, consistent with this file's other
   bad-input-returns-0 primitives -- never corrupts memory). */
long long zyl_store_byte(long long endian, long long offset, long long buf, long long val) {
    (void)endian;
    ZylBytesView v = zyl_bytes_view(buf);
    if (!v.valid || !zyl_bb_bounds_ok(offset, 1, v.bound)) return 0;
    v.data[offset] = (unsigned char)val;
    return 1;
}

long long zyl_store_byte_signed(long long endian, long long offset, long long buf, long long val) {
    (void)endian;
    ZylBytesView v = zyl_bytes_view(buf);
    if (!v.valid || !zyl_bb_bounds_ok(offset, 1, v.bound)) return 0;
    v.data[offset] = (unsigned char)(signed char)val;
    return 1;
}

/* Zero-copy view: `start..start+len` of a ByteBuf's data. Bounds-checked
   against the buf's fixed capacity. Returns a new ByteSlice handle (or 0
   on OOB / allocation failure) -- never copies the underlying bytes. */
long long zyl_byte_slice(long long buf, long long start, long long len) {
    ZylByteBufHeader* h = zyl_bytebuf_of(buf);
    if (!h || !zyl_bb_bounds_ok(start, len, h->cap)) return 0;
    ZylByteSliceHeader* s = (ZylByteSliceHeader*)malloc(sizeof(ZylByteSliceHeader));
    if (!s) return 0;
    s->magic = ZYL_BYTESLICE_MAGIC;
    s->data = zyl_bytebuf_data(h) + start;
    s->len = len;
    return (long long)(size_t)s;
}

/* Zero-copy sub-view of an existing ByteSlice, bounds-checked against the
   parent slice's own len (never its backing buf's cap). */
long long zyl_byte_slice_sub(long long slice, long long start, long long len) {
    ZylByteSliceHeader* parent = zyl_byteslice_of(slice);
    if (!parent || !zyl_bb_bounds_ok(start, len, parent->len)) return 0;
    ZylByteSliceHeader* s = (ZylByteSliceHeader*)malloc(sizeof(ZylByteSliceHeader));
    if (!s) return 0;
    s->magic = ZYL_BYTESLICE_MAGIC;
    s->data = parent->data + start;
    s->len = len;
    return (long long)(size_t)s;
}

/* Create a new, fixed-capacity, zero-initialized ByteBuf. `region` is
   accepted (matches the ExprInner/EByteBuf shape, which threads the
   parsed region literal through type inference already -- see
   type_inference.zyl) but doesn't change allocation strategy: the general
   Stack/Heap/Global/Circular region-promotion machinery was deleted as
   dead code (region_inference.zyl's header comment) and was never
   resurrected by this feature, so every region gets the same plain,
   stable-address heap allocation. That's actually what Pin needs anyway
   (never moves once allocated), so nothing is unsound -- Stack/Global's
   extra compile-time constraints from the plan just aren't enforced yet. */
long long zyl_bytebuf_new(long long region, long long cap) {
    (void)region;
    if (cap < 0 || cap > ZYL_BYTEBUF_MAX_CAP) return 0;
    ZylByteBufHeader* h = (ZylByteBufHeader*)malloc(sizeof(ZylByteBufHeader));
    if (!h) return 0;
    size_t alloc_len = (size_t)cap > 0 ? (size_t)cap : 1;
    unsigned char* data = (unsigned char*)malloc(alloc_len);
    if (!data) { free(h); return 0; }
    memset(data, 0, alloc_len);
    h->magic = ZYL_BYTEBUF_MAGIC;
    h->data = data;
    h->len = 0;
    h->cap = cap;
    return (long long)(size_t)h;
}

/* Append a whole ByteSlice's bytes to a ByteBuf (bytebuf-append takes a
   slice, not a single byte -- see parse-bytebuf-append's own arity error
   message "requires buf slice"). memmove (not memcpy) because the slice
   may alias the buf's own storage (e.g. appending a buf's own tail back
   onto itself). Fails closed (returns 0, no partial write) if it would
   exceed the buf's fixed capacity. */
long long zyl_bytebuf_append(long long buf, long long slice) {
    ZylByteBufHeader* h = zyl_bytebuf_of(buf);
    ZylByteSliceHeader* s = zyl_byteslice_of(slice);
    if (!h || !s) return 0;
    if (!zyl_bb_bounds_ok(h->len, s->len, h->cap)) return 0;
    memmove(h->data + h->len, s->data, (size_t)s->len);
    h->len += s->len;
    return 1;
}

long long zyl_bytebuf_len(long long buf) {
    ZylByteBufHeader* h = zyl_bytebuf_of(buf);
    return h ? h->len : 0;
}

long long zyl_bytebuf_cap(long long buf) {
    ZylByteBufHeader* h = zyl_bytebuf_of(buf);
    return h ? h->cap : 0;
}

/* Raw data pointer, for Pin-region FFI use. Not bounds-checked itself --
   callers get a stable address good for exactly `bytebuf-cap` bytes. */
long long zyl_bytebuf_ptr(long long buf) {
    ZylByteBufHeader* h = zyl_bytebuf_of(buf);
    return h ? (long long)(size_t)h->data : 0;
}

/* Alignment check - returns true if expr is aligned to align boundary */
long long zyl_align_check(long long expr, long long align) {
    if (align <= 0) return 0;
    return ((expr % align) == 0) ? 1 : 0;
}

/* ==========================================================================
   Atomic operations on a ByteBuf slot, layered on the existing raw-address
   atomics defined further below (zyl_atomic_load/store/add/sub/max/min/
   cas/fetch_add -- forward-declared here since this section comes first
   in the file): resolve+bounds+align-check the (buf, offset) pair down to
   a checked 8-byte-aligned address, then delegate. offset+8 must fit
   within the buf's fixed capacity, and offset must be 8-byte aligned
   (unaligned atomics are not lock-free on x86_64 and are rejected rather
   than silently taking a slow/tearing path). */
long long zyl_atomic_load(long long addr);
long long zyl_atomic_store(long long addr, long long value);
long long zyl_atomic_add(long long addr, long long value);
long long zyl_atomic_sub(long long addr, long long value);
long long zyl_atomic_max(long long addr, long long value);
long long zyl_atomic_min(long long addr, long long value);
long long zyl_atomic_cas(long long addr, long long expected, long long new_value);
long long zyl_atomic_fetch_add(long long addr, long long value);

static long long* zyl_bytebuf_atomic_slot(long long buf, long long offset) {
    ZylByteBufHeader* h = zyl_bytebuf_of(buf);
    if (!h) return NULL;
    if (offset < 0 || (offset & 7) != 0) return NULL;
    if (!zyl_bb_bounds_ok(offset, 8, h->cap)) return NULL;
    return (long long*)(void*)(h->data + offset);
}

long long zyl_bytebuf_atomic_load(long long buf, long long offset) {
    long long* p = zyl_bytebuf_atomic_slot(buf, offset);
    return p ? zyl_atomic_load((long long)(size_t)p) : 0;
}

long long zyl_bytebuf_atomic_store(long long buf, long long offset, long long val) {
    long long* p = zyl_bytebuf_atomic_slot(buf, offset);
    if (!p) return 0;
    zyl_atomic_store((long long)(size_t)p, val);
    return 1;
}

long long zyl_bytebuf_atomic_add(long long buf, long long offset, long long val) {
    long long* p = zyl_bytebuf_atomic_slot(buf, offset);
    return p ? zyl_atomic_add((long long)(size_t)p, val) : 0;
}

long long zyl_bytebuf_atomic_sub(long long buf, long long offset, long long val) {
    long long* p = zyl_bytebuf_atomic_slot(buf, offset);
    return p ? zyl_atomic_sub((long long)(size_t)p, val) : 0;
}

long long zyl_bytebuf_atomic_fetch_add(long long buf, long long offset, long long val) {
    long long* p = zyl_bytebuf_atomic_slot(buf, offset);
    return p ? zyl_atomic_fetch_add((long long)(size_t)p, val) : 0;
}

long long zyl_bytebuf_atomic_max(long long buf, long long offset, long long val) {
    long long* p = zyl_bytebuf_atomic_slot(buf, offset);
    return p ? zyl_atomic_max((long long)(size_t)p, val) : 0;
}

long long zyl_bytebuf_atomic_min(long long buf, long long offset, long long val) {
    long long* p = zyl_bytebuf_atomic_slot(buf, offset);
    return p ? zyl_atomic_min((long long)(size_t)p, val) : 0;
}

/* Returns 1/0 (success), matching EAtomicCAS's TBool result type. */
long long zyl_bytebuf_atomic_cas(long long buf, long long offset, long long expected, long long new_value) {
    long long* p = zyl_bytebuf_atomic_slot(buf, offset);
    return p ? zyl_atomic_cas((long long)(size_t)p, expected, new_value) : 0;
}

/* Convert a non-negative integer to its decimal string form in `arena`.
   Used for spans/error messages in the lexer/parser. */
long long zyl_cstr_from_int(long long arena, long long value) {
    char tmp[32];
    snprintf(tmp, sizeof tmp, "%lld", value);
    long long n = (long long)strlen(tmp);
    long long buf = zyl_arena_alloc_zeroed(arena, n + 1);
    memcpy((void*)(size_t)buf, tmp, (size_t)n + 1);
    return buf;
}

/* Sanitize an identifier for use as an assembler/C symbol: every byte
   outside [A-Za-z0-9_] becomes '_'. Returns a NUL-terminated buffer in
   `arena`. Deterministic: copied left-to-right. */
long long zyl_cstr_sanitize(long long arena, long long src) {
    if (!src) return 0;
    if (!zyl_cstr_valid(src, "cstr-sanitize")) return 0;
    const char* s = (const char*)(size_t)src;
    long long n = (long long)strlen(s);
    long long buf = zyl_arena_alloc_zeroed(arena, n + 1);
    char* d = (char*)(size_t)buf;
    for (long long i = 0; i < n; i++) {
        char c = s[i];
        int ok = (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
                 (c >= '0' && c <= '9') || c == '_';
        d[i] = ok ? c : '_';
    }
    return buf;
}

/* Decode a Zyl string literal body (src[start..end], `start` points past the
   opening quote): handle \n \t \" \\ escapes. Returns a NUL-terminated buffer
   in `arena`, or 0 if an escape is unterminated (caller reports a lex error).
   Deterministic: decodes left-to-right in source order. */
long long zyl_cstr_decode(long long arena, long long src, long long start, long long end) {
    if (!src) return 0;
    if (!zyl_cstr_valid(src, "cstr-decode")) return 0;
    const char* s = (const char*)(size_t)src;
    long long cap = (end - start) + 1;
    long long buf = zyl_arena_alloc_zeroed(arena, cap + 1);
    char* out = (char*)(size_t)buf;
    long long o = 0;
    long long i = start;
    while (i < end) {
        unsigned char c = (unsigned char)s[i];
        if (c == '\\' && i + 1 < end) {
            char n = s[i + 1];
            if (n == 'n') { out[o++] = '\n'; i += 2; }
            else if (n == 't') { out[o++] = '\t'; i += 2; }
            else if (n == 'r') { out[o++] = '\r'; i += 2; }
            else if (n == '0') { out[o++] = '\0'; i += 2; }
            else if (n == '"') { out[o++] = '"'; i += 2; }
            else if (n == '\\') { out[o++] = '\\'; i += 2; }
            else return 0;
        } else if (c == '\\') {
            return 0; /* backslash at very end — unterminated escape */
        } else {
            out[o++] = (char)c;
            i += 1;
        }
    }
    out[o] = 0;
    return buf;
}

/* Count the number of '\n' characters in src[0..end). Used for line/col. */
long long zyl_cstr_count_newlines(long long src, long long end) {
    if (!src) return 0;
    if (!zyl_cstr_valid(src, "cstr-count-newlines")) return 0;
    const char* s = (const char*)(size_t)src;
    long long n = 0;
    for (long long i = 0; i < end && s[i]; i++) {
        if (s[i] == '\n') n++;
    }
    return n;
}

/* Index of the last '\n' in src[0..end), or -1 if none. Used for column. */
long long zyl_cstr_last_newline(long long src, long long end) {
    if (!src) return -1;
    if (!zyl_cstr_valid(src, "cstr-last-newline")) return -1;
    const char* s = (const char*)(size_t)src;
    for (long long i = end - 1; i >= 0; i--) {
        if (s[i] == '\n') return i;
        if (i == 0) break;
    }
    return -1;
}

/* ==========================================================================
   Region-based arena allocator.

   Deterministic reclamation: arena-reset frees every block at once and the
   handle stays valid for reuse; arena-destroy frees everything including the
   handle. Allocations are 16-byte aligned bump allocations from a growable
   block list — no per-object free, no fragmentation bookkeeping, no
   scheduling-dependent behavior. Arenas are single-threaded by design
   (consistent with actor isolation: one arena per actor/scope).
   ========================================================================== */

#define ZYL_ARENA_DEFAULT_BLOCK 65536
#define ZYL_ARENA_ALIGN 16
/* Reject sizes that could overflow zyl_arena_align_up's `n + 15` or any
 * caller's own size arithmetic (e.g. zyl_heap_alloc's qwords*8+8 header
 * calc) before they ever reach this layer. Centralized here instead of
 * only in zyl_heap_alloc so every direct zyl_arena_alloc(_zeroed) caller
 * gets the same bound, not just the one wrapper that happened to add it. */
#define ZYL_ARENA_MAX_ALLOC (1LL << 48)

typedef struct ZylArenaBlock {
    char* mem;
    size_t cap;
    size_t used;
    struct ZylArenaBlock* next;
} ZylArenaBlock;

typedef struct ZylArena {
    ZylArenaBlock* head;
    size_t block_size;
    size_t total_capacity;
    size_t total_used;
    /* g_heap_arena/g_pin_arena are process-global, shared by every actor
     * thread (despite the "one arena per actor/scope" isolation this type
     * was originally meant to provide -- that per-actor split was never
     * actually implemented). Without this lock, two actors allocating
     * concurrently race on `head`/`used`/`total_used`: both can read the
     * same `used` before either writes it back, so both get a pointer into
     * the SAME bytes -- two logically distinct heap objects silently
     * aliasing, in ordinary concurrent-actor usage, not an edge case. */
    pthread_mutex_t lock;
} ZylArena;

static size_t zyl_arena_align_up(size_t n) {
    return (n + (ZYL_ARENA_ALIGN - 1)) & ~(size_t)(ZYL_ARENA_ALIGN - 1);
}

static ZylArenaBlock* zyl_arena_new_block_of(ZylArena* a, size_t cap) {
    if (cap < a->block_size) cap = a->block_size;
    ZylArenaBlock* b = (ZylArenaBlock*)malloc(sizeof(ZylArenaBlock));
    if (!b) return NULL;
    b->mem = (char*)malloc(cap);
    if (!b->mem) {
        free(b);
        return NULL;
    }
    b->cap = cap;
    b->used = 0;
    b->next = a->head;
    a->head = b;
    a->total_capacity += cap;
    return b;
}

long long zyl_arena_create(long long block_size) {
    size_t bs = (size_t)block_size;
    if (bs < 16) bs = ZYL_ARENA_DEFAULT_BLOCK;
    ZylArena* a = (ZylArena*)malloc(sizeof(ZylArena));
    if (!a) return 0;
    a->head = NULL;
    a->block_size = bs;
    a->total_capacity = 0;
    a->total_used = 0;
    pthread_mutex_init(&a->lock, NULL);
    ZylArenaBlock* b = zyl_arena_new_block_of(a, bs);
    if (!b) {
        pthread_mutex_destroy(&a->lock);
        free(a);
        return 0;
    }
    return (long long)(size_t)a;
}

long long zyl_arena_alloc(long long arena, long long size) {
    if (!arena || size < 0 || size > ZYL_ARENA_MAX_ALLOC) return 0;
    ZylArena* a = (ZylArena*)(size_t)arena;
    size_t need = zyl_arena_align_up((size_t)size);
    pthread_mutex_lock(&a->lock);
    ZylArenaBlock* b = a->head;
    if (!b || need > b->cap - b->used) {
        b = zyl_arena_new_block_of(a, need);
        if (!b) { pthread_mutex_unlock(&a->lock); return 0; }
    }
    char* p = b->mem + b->used;
    b->used += need;
    a->total_used += need;
    pthread_mutex_unlock(&a->lock);
    return (long long)(size_t)p;
}

long long zyl_arena_alloc_zeroed(long long arena, long long size) {
    if (!arena || size < 0 || size > ZYL_ARENA_MAX_ALLOC) return 0;
    ZylArena* a = (ZylArena*)(size_t)arena;
    size_t need = zyl_arena_align_up((size_t)size);
    pthread_mutex_lock(&a->lock);
    ZylArenaBlock* b = a->head;
    if (!b || need > b->cap - b->used) {
        b = zyl_arena_new_block_of(a, need);
        if (!b) { pthread_mutex_unlock(&a->lock); return 0; }
    }
    char* p = b->mem + b->used;
    b->used += need;
    a->total_used += need;
    pthread_mutex_unlock(&a->lock);
    /* p is exclusively ours from here: `used` was already advanced past it
     * under the lock, so no concurrent allocator can hand out an
     * overlapping range -- safe to zero without holding the lock. */
    memset(p, 0, (size_t)size);
    return (long long)(size_t)p;
}

void zyl_arena_reset(long long arena) {
    if (!arena) return;
    ZylArena* a = (ZylArena*)(size_t)arena;
    pthread_mutex_lock(&a->lock);
    ZylArenaBlock* b = a->head;
    while (b) {
        ZylArenaBlock* next = b->next;
        /* Poison before free: any zyl-level pointer into this block that
         * outlived the reset (nothing in the current compiler tracks or
         * invalidates such pointers -- see region-inference gap) reads
         * obvious garbage and is far more likely to crash fast than to
         * silently read/corrupt whatever libc reuses this memory for. */
        memset(b->mem, 0xDE, b->used);
        free(b->mem);
        free(b);
        b = next;
    }
    a->head = NULL;
    a->total_capacity = 0;
    a->total_used = 0;
    pthread_mutex_unlock(&a->lock);
}

void zyl_arena_destroy(long long arena) {
    if (!arena) return;
    ZylArena* a = (ZylArena*)(size_t)arena;
    pthread_mutex_lock(&a->lock);
    ZylArenaBlock* b = a->head;
    while (b) {
        ZylArenaBlock* next = b->next;
        memset(b->mem, 0xDE, b->used);
        free(b->mem);
        free(b);
        b = next;
    }
    pthread_mutex_unlock(&a->lock);
    pthread_mutex_destroy(&a->lock);
    free(a);
}

long long zyl_arena_used(long long arena) {
    if (!arena) return 0;
    ZylArena* a = (ZylArena*)(size_t)arena;
    pthread_mutex_lock(&a->lock);
    long long v = (long long)a->total_used;
    pthread_mutex_unlock(&a->lock);
    return v;
}

long long zyl_arena_capacity(long long arena) {
    if (!arena) return 0;
    ZylArena* a = (ZylArena*)(size_t)arena;
    pthread_mutex_lock(&a->lock);
    long long v = (long long)a->total_capacity;
    pthread_mutex_unlock(&a->lock);
    return v;
}

/* True if `ptr` falls within an in-use byte range of some block of
 * g_pin_arena. Used by ffi_unpin to reject pointers that were never
 * handed out by ffi_pin. */
static int zyl_ptr_in_pin_arena(long long ptr) {
    if (!ptr || !g_pin_arena) return 0;
    ZylArena* a = (ZylArena*)(size_t)g_pin_arena;
    pthread_mutex_lock(&a->lock);
    int found = 0;
    for (ZylArenaBlock* b = a->head; b; b = b->next) {
        char* p = (char*)(size_t)ptr;
        if (p >= b->mem && p + sizeof(long long) <= b->mem + b->used) { found = 1; break; }
    }
    pthread_mutex_unlock(&a->lock);
    return found;
}

/* ==========================================================================
   Region-specific arena allocation wrappers for codegen.
   Heap arena: for escaped values, structs, variants, closures, actor data.
   Pin arena: for FFI-safe stable memory (non-moving).
   ========================================================================== */

long long zyl_heap_alloc(long long size) {
    if (!g_heap_arena || size <= 0) return 0;
    /* Reject sizes that could overflow the (qwords*8+8) header-size
     * calculation below (signed overflow is UB in C; relying on wraparound
     * to be caught downstream is not a validated bound). No legitimate
     * allocation needs anywhere near this much. */
    if (size > (1LL << 48)) {
        fprintf(stderr, "zyl_heap_alloc: size too large size=%lld\n", size);
        return 0;
    }
    /* Reserve a hidden 8-byte header before the returned pointer holding the
     * payload size (in qwords). This enables structural equality checks
     * (zyl_variant_eq) without changing any field offsets — all consumers
     * see the same address as before. */
    long long qwords = (size + 7) / 8;
    /* Checked arithmetic: qwords * 8 + 8 must not overflow */
    if (qwords > (SIZE_MAX - 8) / 8) {
        fprintf(stderr, "zyl_heap_alloc: header size overflow\n");
        return 0;
    }
    long long alloc_size = qwords * 8 + 8;
    long long base = zyl_arena_alloc((long long)(size_t)g_heap_arena, alloc_size);
    if (!base) {
        fprintf(stderr, "zyl_heap_alloc: FAILED size=%lld\n", size);
        return 0;
    }
    *(long long*)(size_t)base = qwords;
    return base + 8;
}

/* Structural equality for heap-allocated aggregates (ADT variants and
 * structs): equal hidden sizes AND identical payload qwords (discriminant +
 * fields). Pointer/string fields compare by identity — flat Int/Bool
 * payloads compare by value. */
long long zyl_variant_eq(long long a, long long b) {
    if (a == b) return 1;
    if (!a || !b) return 0;
    long long ha = *(long long*)(size_t)(a - 8);
    long long hb = *(long long*)(size_t)(b - 8);
    if (ha != hb) return 0;
    long long* pa = (long long*)(size_t)a;
    long long* pb = (long long*)(size_t)b;
    for (long long i = 0; i < ha; i++) {
        if (pa[i] != pb[i]) return 0;
    }
    return 1;
}

/* Lexicographic ordering for heap-allocated aggregates (derived Ord):
 * compares payload qwords field by field, skipping index 0 (the shared
 * discriminant, identical for every value of the same variant/struct
 * and meaningless to order on). Returns -1/0/1. Pointer/string fields
 * compare by raw address, same identity-not-content caveat as
 * zyl_variant_eq's docs above. */
long long zyl_variant_cmp(long long a, long long b) {
    if (a == b) return 0;
    if (!a || !b) return a ? 1 : -1;
    long long ha = *(long long*)(size_t)(a - 8);
    long long hb = *(long long*)(size_t)(b - 8);
    long long* pa = (long long*)(size_t)a;
    long long* pb = (long long*)(size_t)b;
    long long n = ha < hb ? ha : hb;
    for (long long i = 1; i < n; i++) {
        if (pa[i] < pb[i]) return -1;
        if (pa[i] > pb[i]) return 1;
    }
    if (ha < hb) return -1;
    if (ha > hb) return 1;
    return 0;
}

/* Field `idx` (0-based, skipping the discriminant at index 0 — same
 * layout zyl_variant_eq/zyl_variant_cmp document above) of a heap-
 * allocated aggregate. Used by closure conversion (icnf.zyl's
 * ic-lambda-closure/ic-wrap-env-binds) to read a captured value back
 * out of a closure's env block; not something the tag is ever checked
 * for here, since a closure's env is never `match`ed by user code. */
long long zyl_variant_field(long long ptr, long long idx) {
    if (!ptr) return 0;
    return *(long long*)(size_t)(ptr + 8 * (idx + 1));
}

long long zyl_pin_alloc(long long size) {
    if (!g_pin_arena || size <= 0) return 0;
    long long p = zyl_arena_alloc((long long)(size_t)g_pin_arena, size);
    /* Pin means "this memory must not reach a swap file or a core
       dump": an FFI callee holds a raw pointer to it for the duration
       of the call, and anything pinned here is by construction the
       kind of value (key material, a scalar, a buffer handed to C)
       whose appearance in swap would outlive the process that owned
       it. mlock is best-effort on purpose -- RLIMIT_MEMLOCK is 64 KiB
       by default on many systems, so a hard failure here would turn a
       hardening measure into a crash for ordinary FFI use. The pin
       itself (a stable address for the callee) is correct either
       way. */
    if (p) zyl_mlock(p, size);
    return p;
}

/* Best-effort page-locking of an address range. Page-granular, so it
   rounds down to the containing page; overlapping calls are harmless
   (mlock is idempotent per page). Returns 1 on success, 0 otherwise --
   callers that genuinely require locked memory must check. */
long long zyl_mlock(long long addr, long long len) {
    if (!addr || len <= 0) return 0;
    size_t page = (size_t)sysconf(_SC_PAGESIZE);
    if (page == 0 || page == (size_t)-1) page = 4096;
    size_t a = (size_t)addr;
    size_t start = a & ~(page - 1);
    size_t span = (a - start) + (size_t)len;
    return mlock((void*)start, span) == 0 ? 1 : 0;
}

/* ==========================================================================
   AES-NI (math/crypto/symmetric/aesgcm.zyl).

   Hardware AES only. There is deliberately NO software fallback: a
   portable AES implementation is a table lookup indexed by key-dependent
   bytes, and those lookups leak the key through the data cache -- the
   attack is old, practical, and the reason this library would rather
   refuse to encrypt than encrypt insecurely. Callers ask
   zyl_aesni_available() first and get an explicit failure if the CPU
   cannot do it.

   The AES-NI instructions themselves are constant-time by construction:
   aesenc/aesenclast are fixed-latency, operate entirely in registers,
   and touch no memory that depends on the key.

   Byte buffers arrive in the math/words one-byte-per-8-byte-word form
   the Zyl crypto library uses, and are packed/unpacked here so no Zyl
   caller has to reason about two representations.
   ========================================================================== */

#if defined(__x86_64__)
#include <immintrin.h>
#include <cpuid.h>

long long zyl_cpuid_features(void) {
    unsigned int eax, ebx, ecx, edx;
    if (!__get_cpuid(1, &eax, &ebx, &ecx, &edx)) return 0;
    long long f = 0;
    if (ecx & (1u << 25)) f |= 1;  /* AES-NI   */
    if (ecx & (1u << 1))  f |= 2;  /* PCLMULQDQ */
    if (ecx & (1u << 19)) f |= 4;  /* SSE4.1   */
    if (ecx & (1u << 28)) f |= 8;  /* AVX      */
    return f;
}

long long zyl_aesni_available(void) { return (zyl_cpuid_features() & 1) ? 1 : 0; }

/* Pack 16 one-byte-per-word Ints into a 16-byte block. */
static void zyl_words_to_block(long long base, unsigned char* out) {
    const long long* w = (const long long*)(size_t)base;
    for (int i = 0; i < 16; i++) out[i] = (unsigned char)(w[i] & 0xff);
}

static void zyl_block_to_words(const unsigned char* in, long long base) {
    long long* w = (long long*)(size_t)base;
    for (int i = 0; i < 16; i++) w[i] = (long long)in[i];
}

/* AES-256 expands two words per round constant: the even step mixes in
   aeskeygenassist's rotated word (0xff lane), the odd step its
   un-rotated SubWord (0xaa lane). The round constant must be a
   compile-time immediate, which is why both steps are macros unrolled
   at each index rather than a loop. */
#define ZYL_AES_EXPAND_256_EVEN(rk, i, rcon) \
    do { \
        __m128i t = _mm_aeskeygenassist_si128(rk[i - 1], rcon); \
        t = _mm_shuffle_epi32(t, 0xff); \
        __m128i k = rk[i - 2]; \
        k = _mm_xor_si128(k, _mm_slli_si128(k, 4)); \
        k = _mm_xor_si128(k, _mm_slli_si128(k, 4)); \
        k = _mm_xor_si128(k, _mm_slli_si128(k, 4)); \
        rk[i] = _mm_xor_si128(k, t); \
    } while (0)

#define ZYL_AES_EXPAND_256_ODD(rk, i) \
    do { \
        __m128i t = _mm_aeskeygenassist_si128(rk[i - 1], 0x00); \
        t = _mm_shuffle_epi32(t, 0xaa); \
        __m128i k = rk[i - 2]; \
        k = _mm_xor_si128(k, _mm_slli_si128(k, 4)); \
        k = _mm_xor_si128(k, _mm_slli_si128(k, 4)); \
        k = _mm_xor_si128(k, _mm_slli_si128(k, 4)); \
        rk[i] = _mm_xor_si128(k, t); \
    } while (0)

#define ZYL_AES_EXPAND_128(rk, i, rcon) \
    do { \
        __m128i t = _mm_aeskeygenassist_si128(rk[i - 1], rcon); \
        t = _mm_shuffle_epi32(t, 0xff); \
        __m128i k = rk[i - 1]; \
        k = _mm_xor_si128(k, _mm_slli_si128(k, 4)); \
        k = _mm_xor_si128(k, _mm_slli_si128(k, 4)); \
        k = _mm_xor_si128(k, _mm_slli_si128(k, 4)); \
        rk[i] = _mm_xor_si128(k, t); \
    } while (0)

__attribute__((target("aes,sse4.1")))
static int zyl_aes_expand(const unsigned char* key, int keybytes, __m128i* rk) {
    if (keybytes == 16) {
        rk[0] = _mm_loadu_si128((const __m128i*)key);
        ZYL_AES_EXPAND_128(rk, 1, 0x01); ZYL_AES_EXPAND_128(rk, 2, 0x02);
        ZYL_AES_EXPAND_128(rk, 3, 0x04); ZYL_AES_EXPAND_128(rk, 4, 0x08);
        ZYL_AES_EXPAND_128(rk, 5, 0x10); ZYL_AES_EXPAND_128(rk, 6, 0x20);
        ZYL_AES_EXPAND_128(rk, 7, 0x40); ZYL_AES_EXPAND_128(rk, 8, 0x80);
        ZYL_AES_EXPAND_128(rk, 9, 0x1b); ZYL_AES_EXPAND_128(rk, 10, 0x36);
        return 10;
    }
    if (keybytes == 32) {
        rk[0] = _mm_loadu_si128((const __m128i*)key);
        rk[1] = _mm_loadu_si128((const __m128i*)(key + 16));
        ZYL_AES_EXPAND_256_EVEN(rk, 2, 0x01);  ZYL_AES_EXPAND_256_ODD(rk, 3);
        ZYL_AES_EXPAND_256_EVEN(rk, 4, 0x02);  ZYL_AES_EXPAND_256_ODD(rk, 5);
        ZYL_AES_EXPAND_256_EVEN(rk, 6, 0x04);  ZYL_AES_EXPAND_256_ODD(rk, 7);
        ZYL_AES_EXPAND_256_EVEN(rk, 8, 0x08);  ZYL_AES_EXPAND_256_ODD(rk, 9);
        ZYL_AES_EXPAND_256_EVEN(rk, 10, 0x10); ZYL_AES_EXPAND_256_ODD(rk, 11);
        ZYL_AES_EXPAND_256_EVEN(rk, 12, 0x20); ZYL_AES_EXPAND_256_ODD(rk, 13);
        ZYL_AES_EXPAND_256_EVEN(rk, 14, 0x40);
        return 14;
    }
    return -1;
}

__attribute__((target("aes,sse4.1")))
static void zyl_aes_encrypt_raw(const __m128i* rk, int rounds,
                                const unsigned char* in, unsigned char* out) {
    __m128i b = _mm_loadu_si128((const __m128i*)in);
    b = _mm_xor_si128(b, rk[0]);
    for (int i = 1; i < rounds; i++) b = _mm_aesenc_si128(b, rk[i]);
    b = _mm_aesenclast_si128(b, rk[rounds]);
    _mm_storeu_si128((__m128i*)out, b);
}

/* Encrypt ONE 16-byte block. `keybase`/`inbase`/`outbase` are
   math/words byte arrays; `keybytes` is 16 or 32. Returns 1 on success,
   0 when the CPU lacks AES-NI or the key size is unsupported.

   The round keys live in a stack array that is wiped before returning:
   they are as sensitive as the key itself, and leaving them in a stack
   frame that later calls reuse is how key material ends up in a core
   dump. */
/* force_align_arg_pointer: the generated Zyl code does not guarantee the
   16-byte stack alignment the SysV ABI requires at a call boundary, and
   this function keeps __m128i values on its stack -- which the compiler
   spills with aligned moves. Without the realignment in the prologue,
   reaching this function through one call depth rather than another was
   the difference between working and a SIGSEGV inside the key
   expansion. The attribute makes the function independent of its
   caller's alignment; it belongs here, at the FFI boundary, rather than
   as an assumption about codegen. */
__attribute__((target("aes,sse4.1")))
__attribute__((force_align_arg_pointer))
long long zyl_aes_encrypt_block(long long keybase, long long keybytes,
                                long long inbase, long long outbase) {
    if (!zyl_aesni_available()) return 0;
    if (keybytes != 16 && keybytes != 32) return 0;
    unsigned char key[32], in[16], out[16];
    __m128i rk[15];
    long long* kw = (long long*)(size_t)keybase;
    for (long long i = 0; i < keybytes; i++) key[i] = (unsigned char)(kw[i] & 0xff);
    zyl_words_to_block(inbase, in);
    int rounds = zyl_aes_expand(key, (int)keybytes, rk);
    if (rounds < 0) return 0;
    zyl_aes_encrypt_raw(rk, rounds, in, out);
    zyl_block_to_words(out, outbase);
    zyl_zeroize((long long)(size_t)rk, (long long)sizeof rk);
    zyl_zeroize((long long)(size_t)key, (long long)sizeof key);
    return 1;
}

#else /* not x86_64 */

long long zyl_cpuid_features(void) { return 0; }
long long zyl_aesni_available(void) { return 0; }
long long zyl_aes_encrypt_block(long long keybase, long long keybytes,
                                long long inbase, long long outbase) {
    (void)keybase; (void)keybytes; (void)inbase; (void)outbase;
    return 0;
}

#endif

/* ==========================================================================
   System entropy (math/rand/crypto.zyl).

   Writes `n` random BYTES as one-per-word Ints at `base`, matching the
   math/words representation the Zyl crypto library uses everywhere, so
   no separate packing step is needed on the Zyl side.

   getrandom(2) is the right primitive: unlike reading /dev/urandom it
   cannot fail because of a missing device node, an exhausted file
   descriptor table or a chroot, and it blocks only until the pool is
   initialized at boot. It is also inherently fork-safe -- every call
   goes to the kernel, so a forked child cannot inherit and replay a
   userspace buffer, which is the classic way a fork duplicates key
   material. The /dev/urandom fallback exists for kernels older than
   3.17 and returns the same bytes, with the same per-call freshness.

   Returns the number of bytes written, or -1 if entropy could not be
   obtained -- callers MUST check: silently returning zeros here would
   be a catastrophic failure mode for key generation.
   ========================================================================== */

long long zyl_random_words(long long base, long long n) {
    if (!base || n <= 0) return -1;
    unsigned char buf[256];
    long long* out = (long long*)(size_t)base;
    long long done = 0;
    while (done < n) {
        size_t want = (size_t)(n - done);
        if (want > sizeof(buf)) want = sizeof(buf);
        long long got = zyl_random_fill((long long)(size_t)buf, (long long)want);
        if (got != (long long)want) return -1;
        for (size_t i = 0; i < want; i++) out[done + (long long)i] = (long long)buf[i];
        done += (long long)want;
    }
    return done;
}

/* Fill `len` raw bytes at `addr`. Kept separate from zyl_random_words so
   FFI callers that already hold a packed byte buffer (a ByteBuf, a C
   struct being pinned) can use it directly. */
long long zyl_random_fill(long long addr, long long len) {
    if (!addr || len <= 0) return -1;
    unsigned char* p = (unsigned char*)(size_t)addr;
    long long done = 0;
#if defined(__linux__) && defined(SYS_getrandom)
    while (done < len) {
        long r = syscall(SYS_getrandom, p + done, (size_t)(len - done), 0);
        if (r < 0) {
            if (errno == EINTR) continue;
            break; /* fall through to the /dev/urandom path */
        }
        done += (long long)r;
    }
    if (done == len) return done;
#endif
    {
        FILE* f = fopen("/dev/urandom", "rb");
        if (!f) return -1;
        size_t got = fread(p + done, 1, (size_t)(len - done), f);
        fclose(f);
        done += (long long)got;
    }
    return done == len ? done : -1;
}

/* Overwrite a range with zeros in a way the C compiler is not allowed
   to delete. A plain memset before a free is dead-store-eliminated at
   -O2 in every mainstream compiler, which is exactly how key material
   survives in freed memory; writing through a volatile pointer keeps
   the stores. Byte-at-a-time is deliberate -- it needs no assumptions
   about alignment or length, and erasure is never on a hot path. */
long long zyl_zeroize(long long addr, long long len) {
    if (!addr || len <= 0) return 0;
    volatile unsigned char* p = (volatile unsigned char*)(size_t)addr;
    for (long long i = 0; i < len; i++) p[i] = 0;
    return len;
}

/* ==========================================================================
   FFI pinning — copy an 8-byte value to a stable Pin arena location and back.
   ========================================================================== */

/* ==========================================================================
   Atomic operations on 64-bit memory locations (address passed as Int).
   ========================================================================== */

long long zyl_atomic_load(long long addr) {
    return __atomic_load_n((long long*)(size_t)addr, __ATOMIC_SEQ_CST);
}

long long zyl_atomic_store(long long addr, long long value) {
    __atomic_store_n((long long*)(size_t)addr, value, __ATOMIC_SEQ_CST);
    return value;
}

long long zyl_atomic_add(long long addr, long long value) {
    return __atomic_add_fetch((long long*)(size_t)addr, value, __ATOMIC_SEQ_CST);
}

long long zyl_atomic_sub(long long addr, long long value) {
    return __atomic_sub_fetch((long long*)(size_t)addr, value, __ATOMIC_SEQ_CST);
}

long long zyl_atomic_max(long long addr, long long value) {
    long long* p = (long long*)(size_t)addr;
    long long old = __atomic_load_n(p, __ATOMIC_SEQ_CST);
    for (;;) {
        long long candidate = old > value ? old : value;
        if (__atomic_compare_exchange_n(
                p, &old, candidate, 0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)) {
            return candidate;
        }
    }
}

long long zyl_atomic_min(long long addr, long long value) {
    long long* p = (long long*)(size_t)addr;
    long long old = __atomic_load_n(p, __ATOMIC_SEQ_CST);
    for (;;) {
        long long candidate = old < value ? old : value;
        if (__atomic_compare_exchange_n(
                p, &old, candidate, 0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)) {
            return candidate;
        }
    }
}

long long zyl_atomic_cas(long long addr, long long expected, long long new_value) {
    long long expected_copy = expected;
    return __atomic_compare_exchange_n(
        (long long*)(size_t)addr, &expected_copy, new_value,
        0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
}

long long zyl_atomic_fetch_add(long long addr, long long value) {
    return __atomic_fetch_add((long long*)(size_t)addr, value, __ATOMIC_SEQ_CST);
}

/* ==========================================================================
   Actor lifecycle queries (actor_id passed as Int).
   ========================================================================== */

long long zyl_actor_is_alive(long long actor_id) {
    if (!g_system.initialized || actor_id < 0 || actor_id >= ZYL_MAX_ACTORS || actor_id >= g_system.next_id) {
        return 0;
    }
    ZylActor* actor = &g_system.actors[(uint32_t)actor_id];
    pthread_mutex_lock(&actor->lock);
    int alive = actor->alive ? 1 : 0;
    pthread_mutex_unlock(&actor->lock);
    return alive;
}

void zyl_actor_terminate(long long actor_id) {
    if (!g_system.initialized || actor_id < 0 || actor_id >= ZYL_MAX_ACTORS || actor_id >= g_system.next_id) {
        return;
    }
    ZylActor* actor = &g_system.actors[(uint32_t)actor_id];
    pthread_mutex_lock(&actor->lock);
    int active = !actor->joined && actor->thread ? 1 : 0;
    if (active) actor->alive = 0;
    pthread_t t = actor->thread;
    pthread_mutex_unlock(&actor->lock);
    if (active) {
        pthread_cond_broadcast(&actor->cond);
        pthread_join(t, NULL);
        pthread_mutex_lock(&actor->lock);
        actor->joined = 1;
        pthread_mutex_unlock(&actor->lock);
    }
}

void zyl_actor_wait(long long actor_id) {
    if (!g_system.initialized || actor_id < 0 || actor_id >= ZYL_MAX_ACTORS || actor_id >= g_system.next_id) {
        return;
    }
    ZylActor* actor = &g_system.actors[(uint32_t)actor_id];
    pthread_mutex_lock(&actor->lock);
    int need_join = !actor->joined && actor->thread ? 1 : 0;
    pthread_t t = actor->thread;
    if (need_join && actor->alive) {
        /* Ask this actor's thread to exit its mailbox loop. */
        actor->alive = 0;
        pthread_cond_signal(&actor->cond);
    }
    pthread_mutex_unlock(&actor->lock);
    if (need_join) {
        pthread_join(t, NULL);
        pthread_mutex_lock(&actor->lock);
        actor->joined = 1;
        pthread_mutex_unlock(&actor->lock);
    }
}

/* === Test Harness === */

#include <setjmp.h>

#define ZYL_MAX_TESTS 256
#define ZYL_TEST_NAME_LEN 128

typedef struct {
    char name[ZYL_TEST_NAME_LEN];
    int (*fn)(void);
} ZylTestEntry;

static ZylTestEntry g_tests[ZYL_MAX_TESTS];
static int g_test_count = 0;

/* Recovery point for panics raised inside a running test. */
static jmp_buf g_test_jmp;
static int g_in_test = 0;

void zyl_register_test(const char* name, int (*fn)(void)) {
    if (g_test_count < ZYL_MAX_TESTS) {
        strncpy(g_tests[g_test_count].name, name, ZYL_TEST_NAME_LEN - 1);
        g_tests[g_test_count].name[ZYL_TEST_NAME_LEN - 1] = '\0';
        g_tests[g_test_count].fn = fn;
        g_test_count++;
    }
}

void zyl_panic(const char* msg) {
    if (g_try_top) {
        struct ZylTryFrame* f = g_try_top;
        g_try_top = f->prev;
        f->msg = msg ? msg : "error";
        longjmp(f->buf, 1);
    }
    if (g_in_test) {
        /* Panic inside a test: unwind to the runner and mark it failed
         * instead of killing the whole process. */
        g_in_test = 0;
        longjmp(g_test_jmp, 1);
    }
    fprintf(stderr, "PANIC: %s\n", msg ? msg : "assertion failed");
    exit(1);
}

int zyl_run_tests(void) {
    int passed = 0;
    int failed = 0;

    for (int i = 0; i < g_test_count; i++) {
        const char* name = g_tests[i].name;
        int (*fn)(void) = g_tests[i].fn;

        /* Print test name (as C string via print-int trick — use file-write) */
        printf("test: %s ... ", name);
        fflush(stdout);

        if (setjmp(g_test_jmp) == 0) {
            g_in_test = 1;
            int result = fn();
            g_in_test = 0;
            if (result == 0) {
                printf("ok\n");
                passed++;
            } else {
                printf("FAIL\n");
                failed++;
            }
        } else {
            /* Landed here via zyl_panic longjmp. */
            printf("FAIL\n");
            failed++;
        }
    }

    printf("\ntest result: %d passed, %d failed, %d total\n", passed, failed, passed + failed);

    return (failed > 0) ? 1 : 0;
}

/* ── Boot-build file helpers (used by the self-hosted driver) ───────── */
#include <fcntl.h>
#include <sys/stat.h>
long long zyl_file_open_c(long long path, long long mode) {
    const char* m = (const char*)(size_t)mode;
    if (m && m[0] == 'r') return (long long)open((const char*)(size_t)path, O_RDONLY);
    if (m && m[0] == 'a')
        return (long long)open((const char*)(size_t)path,
                               O_WRONLY | O_CREAT | O_APPEND, 0644);
    return (long long)open((const char*)(size_t)path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
}
/* Each read gets its OWN buffer, allocated from the heap arena.
   It used to return a single static thread-local buffer, so every read
   clobbered the one before it: reading a manifest after reading the
   source being compiled replaced the source text in place, and the
   compiler then compiled the manifest instead — silently, since both are
   valid S-expressions. Any two live reads alias under that scheme, so
   the fix is ownership, not ordering. It also lifts the old silent 1 MiB
   truncation: a read now returns what was asked for. */
long long zyl_file_read_c(long long fd, long long count) {
    if (count < 0) count = 0;
    if (count > (1LL << 26)) count = 1LL << 26;   /* 64 MiB ceiling */
    long long buf = zyl_heap_alloc(count + 1);
    if (!buf) return 0;
    char* p = (char*)(size_t)buf;
    long long n = read((int)fd, p, (size_t)count);
    if (n < 0) n = 0;
    p[n] = 0;
    return buf;
}
long long zyl_file_write_c(long long fd, long long buf) {
    if (!buf) return -1;
    return (long long)write((int)fd, (const void*)(size_t)buf,
                            strlen((const char*)(size_t)buf));
}
long long zyl_file_close_c(long long fd) {
    return (long long)close((int)fd);
}

/* Stub: Zyl-level (error msg) — print and exit(1).
   Named zyl_f_error (not f_error) so the codegen label `f_error` for a
   user Zyl function named `error` cannot shadow/self-recursively bind it. */
long long zyl_f_error(long long msg) {
    if (msg) fprintf(stderr, "error: %s\n", (const char*)(size_t)msg);
    else fprintf(stderr, "error\n");
    exit(1);
}

/* Append src at the end of the NUL-terminated string in dst.
   Used by the Zyl-level buf-append wrapper so repeated appends
   accumulate (matching the Rust bootstrap's StringBuffer backend).

   Codegen re-appends into the same handful of long-lived buffers
   (chiefly the single ~MB-scale asm output buffer) tens of thousands
   of times per compile. Re-scanning from byte 0 on every call makes
   the whole pass O(n^2) in final buffer size -- for a self-hosted
   compile of its own ~3MB output this never finished in practice
   (confirmed via gdb: stuck inside this scan). Small direct-mapped
   cache of (address -> known end pointer) turns the common repeated-
   same-buffer case O(1) amortized; a miss (new/rare address, or hash
   collision) just falls back to the original full scan once. */
/* Thread-local: keyed by hashed address only, so two actors appending to
 * different buffers that hash to the same slot would otherwise race on a
 * shared cache entry and could write through a stale cached end-pointer
 * into memory they don't own. Use SipHash-like mixing for better distribution. */
#define ZSA_CACHE_SLOTS 64
static _Thread_local long long zsa_cache_dst[ZSA_CACHE_SLOTS];
static _Thread_local char* zsa_cache_end[ZSA_CACHE_SLOTS];

static inline size_t zsa_cache_index(long long dst) {
    /* SipHash-like mixing for better distribution across cache slots */
    uintptr_t x = (uintptr_t)dst;
    x ^= x >> 33;
    x *= 0xff51afd7ed558ccdULL;
    x ^= x >> 33;
    x *= 0xc4ceb9fe1a85ec53ULL;
    x ^= x >> 33;
    return (size_t)(x % ZSA_CACHE_SLOTS);
}

/* Shared implementation: `cap` is the total usable size of the `dst`
 * buffer (including its NUL), or 0 for "no known bound" (preserves the
 * original unchecked behavior for every existing caller that has no
 * capacity to hand it). When a real cap is given and the append would
 * write past it, panics instead of writing out of bounds. */
static long long zyl_str_append_impl(long long dst, long long src, long long cap) {
    if (!dst) return dst;
    if (!src) return dst;
    if (!zyl_cstr_valid(dst, "str-append") || !zyl_cstr_valid(src, "str-append")) return dst;
    size_t idx = zsa_cache_index(dst);
    char* base = (char*)(size_t)dst;
    char* d;
    if (zsa_cache_dst[idx] == dst) {
        d = zsa_cache_end[idx];
    } else {
        d = base;
        while (*d) d++;
    }
    const char* s = (const char*)(size_t)src;
    size_t slen = strlen(s);
    if (cap > 0 && (size_t)(d - base) + slen + 1 > (size_t)cap) {
        zyl_panic("codegen buffer limit exceeded");
    }
    while (*s) { *d++ = *s++; }
    *d = 0;
    zsa_cache_dst[idx] = dst;
    zsa_cache_end[idx] = d;
    return dst;
}

long long zyl_str_append(long long dst, long long src) {
    return zyl_str_append_impl(dst, src, 0);
}

/* Bounds-checked variant for fixed-capacity buffers (e.g. the codegen
 * output buffer): same cache-accelerated append as zyl_str_append, but
 * panics before writing past `cap` instead of silently overrunning the
 * underlying malloc'd block (CWE-787). */
long long zyl_str_append_capped(long long dst, long long src, long long cap) {
    return zyl_str_append_impl(dst, src, cap);
}

/* ── CLI helpers (used by the self-hosted driver) ─────────────────────── */
#include <unistd.h>
int zyl_saved_argc = 0;
char** zyl_saved_argv = NULL;

void zyl_save_args(int argc, char** argv) {
    zyl_saved_argc = argc;
    zyl_saved_argv = argv;
}

long long zyl_argc(void) {
    return (long long)zyl_saved_argc;
}

long long zyl_arg_str(long long i) {
    if (i < 0 || i >= (long long)zyl_saved_argc) return 0;
    return (long long)(size_t)zyl_saved_argv[(int)i];
}

long long zyl_dirname_cstr(long long path) {
    const char* p = (const char*)(size_t)path;
    if (!p) return 0;
    /* Find last '/'; dirname is everything up to and including it. */
    const char* slash = NULL;
    for (const char* s = p; *s; s++) {
        if (*s == '/') slash = s;
    }
    size_t len;
    if (!slash) {
        len = (p[0] == 0) ? 0 : 1;
    } else {
        len = (size_t)(slash - p) + 1;
    }
    /* Thread-local buffer sized generously; contents valid until next call
     * on the same thread. A plain static here would let concurrent actor
     * threads clobber each other's returned string. */
    static _Thread_local char buf[4096];
    memcpy(buf, p, len);
    buf[len] = 0;
    return (long long)(size_t)buf;
}

/* Returns 1 if `path` exists (any type), 0 otherwise. Used to probe for
   an installed ~/.zyl before falling back to the argv0-relative bundle
   dir -- see cli-resolve-bundledir (driver.zyl) and repl-resolve-
   bundledir (tools/repl.zyl). */
long long zyl_path_exists(long long path) {
    return (access((const char*)(size_t)path, F_OK) == 0) ? 1 : 0;
}

/* Returns the value of environment variable `name`, or 0 (null) if
   unset. Contents valid until the next call (matches zyl_getcwd/
   zyl_dirname_cstr's own static-buffer convention) -- getenv's own
   returned pointer is not copied since its storage is already stable
   for the process's lifetime, but callers must still copy out (e.g.
   via str-concat) before any other env-touching call if they need the
   value to survive one. */
long long zyl_getenv(long long name) {
    const char* v = getenv((const char*)(size_t)name);
    return v ? (long long)(size_t)v : 0;
}

long long zyl_chdir(long long path) {
    return (long long)chdir((const char*)(size_t)path);
}

long long zyl_getcwd(void) {
    static _Thread_local char buf[4096];
    if (getcwd(buf, sizeof(buf)) == NULL) {
        return 0;
    }
    return (long long)(size_t)buf;
}

/* Was `system((const char*)(size_t)cmd)` -- confirmed by gdb to
   segfault on EVERY call in this runtime, including the simplest
   possible ("echo hello", no prior state): `main` here always runs on a
   pthread-spawned worker (zyl_bigstack_tramp, used to get a large
   custom stack), never the process's original main thread, and
   system()'s internal vfork() sharing an address space with a
   non-main thread that has a custom/oversized stack is a known-fragile
   combination in glibc. Same posix_spawn fix as zyl_cc_compile/
   zyl_run_bin below: posix_spawn doesn't duplicate the caller's address
   space the way vfork/fork do, so it doesn't hit that. Runs the command
   through `/bin/sh -c` so callers keep shell features (pipes, `>`
   redirection, `&&`) exactly like system() gave them -- lsp/
   repl_integration.zyl's callers rely on this. */
long long zyl_system_cmd(long long cmd) {
    const char* cmd_str = (const char*)(size_t)cmd;
    if (!cmd_str) return -1;
    char* argv[] = { (char*)"sh", (char*)"-c", (char*)cmd_str, NULL };
    pid_t pid;
    if (posix_spawn(&pid, "/bin/sh", NULL, NULL, argv, environ) != 0) return -1;
    int status;
    if (waitpid(pid, &status, 0) < 0) return -1;
    return WIFEXITED(status) ? (long long)WEXITSTATUS(status) : -1;
}

long long zyl_exec_cmd(long long cmd) {
    const char* cmd_str = (const char*)(size_t)cmd;
    /* mkstemp atomically creates+opens with O_EXCL: unlike the old
     * predictable "/tmp/zyl_link_<pid>.sh" + fopen(), this can't be raced
     * by a pre-planted symlink at that path (classic /tmp TOCTOU). */
    char script_path[] = "/tmp/zyl_link_XXXXXX";
    int fd = mkstemp(script_path);
    if (fd < 0) return -1;
    FILE* f = fdopen(fd, "w");
    if (!f) {
        close(fd);
        unlink(script_path);
        return -1;
    }
    fprintf(f, "#!/bin/sh\n%s\n", cmd_str);
    fclose(f);
    chmod(script_path, 0755);
    execl("/bin/sh", "sh", script_path, (char*)NULL);
    unlink(script_path);
    return -1;
}

/* Compile an assembly file into a binary next to it (same path minus
   ".s") via `cc`, using posix_spawn rather than fork()/system(): fork()
   from this process's 64GB-stack worker thread is documented to crash
   (see the system()-replacement note on zyl_exec_cmd above); posix_spawn
   doesn't duplicate the caller's address space the way fork does, so it
   doesn't hit that. Unlike zyl_exec_cmd (execl, replaces this process
   image, never returns), this waits for the child and returns control
   to the caller -- needed by the REPL, which must keep looping after
   each compile. Returns the child's exit status (0 on a successful
   compile), or -1 if the path is malformed or spawning/waiting fails. */
long long zyl_cc_compile(long long path) {
    const char* asm_path = (const char*)(size_t)path;
    if (!asm_path) return -1;
    size_t len = strlen(asm_path);
    char out_path[512];
    if (len >= 2 && asm_path[len - 2] == '.' && asm_path[len - 1] == 's') {
        size_t base_len = len - 2;
        if (base_len >= sizeof(out_path)) return -1;
        memcpy(out_path, asm_path, base_len);
        out_path[base_len] = 0;
    } else {
        if (len + 4 >= sizeof(out_path)) return -1;
        snprintf(out_path, sizeof(out_path), "%s.bin", asm_path);
    }
    char* argv[] = {
        (char*)"cc", (char*)"-no-pie", (char*)asm_path, (char*)"actor_runtime.c",
        (char*)"-o", out_path, (char*)"-lpthread", NULL
    };
    pid_t pid;
    if (posix_spawnp(&pid, "cc", NULL, NULL, argv, environ) != 0) return -1;
    int status;
    if (waitpid(pid, &status, 0) < 0) return -1;
    return WIFEXITED(status) ? (long long)WEXITSTATUS(status) : -1;
}

/* Run a compiled binary to completion and return its exit status. Same
   posix_spawn rationale as zyl_cc_compile: must return control to the
   caller (the REPL loop) rather than replace this process. */
long long zyl_run_bin(long long path) {
    const char* bin_path = (const char*)(size_t)path;
    if (!bin_path) return -1;
    char* argv[] = { (char*)bin_path, NULL };
    pid_t pid;
    if (posix_spawn(&pid, bin_path, NULL, NULL, argv, environ) != 0) return -1;
    int status;
    if (waitpid(pid, &status, 0) < 0) return -1;
    return WIFEXITED(status) ? (long long)WEXITSTATUS(status) : -1;
}

/* ===========================================================================
   PACKAGE SYSTEM SUPPORT (spec v5.0 §31)
   ===========================================================================
   Two primitives the compiler needs on the label path and the toolchain
   needs on the content-hash path:

     zyl_blake3_hex   BLAKE3 of a byte range, as lowercase hex
     zyl_mangle_key   canonical symbol key -> assembler label (§31.2)

   BLAKE3 lives here rather than being reached for in stdlib/math/hash so
   that exactly one implementation sits on the build path: the mangler
   needs it for the >200-byte truncation case, and `zyl` needs it for
   archive, lock and graph hashes. stdlib/math/hash/blake3.zyl remains the
   library implementation for user code; the two agree on test vectors.
   =========================================================================== */

#include <stdint.h>

#define B3_BLOCK_LEN 64
#define B3_CHUNK_LEN 1024
#define B3_CHUNK_START 1
#define B3_CHUNK_END 2
#define B3_PARENT 4
#define B3_ROOT 8

static const uint32_t B3_IV[8] = {
    0x6A09E667u, 0xBB67AE85u, 0x3C6EF372u, 0xA54FF53Au,
    0x510E527Fu, 0x9B05688Cu, 0x1F83D9ABu, 0x5BE0CD19u
};

static const uint8_t B3_PERM[16] = {2, 6, 3, 10, 7, 0, 4, 13, 1, 11, 12, 5, 9, 14, 15, 8};

static uint32_t b3_rotr(uint32_t x, int n) { return (x >> n) | (x << (32 - n)); }

static void b3_g(uint32_t s[16], int a, int b, int c, int d, uint32_t mx, uint32_t my) {
    s[a] = s[a] + s[b] + mx;
    s[d] = b3_rotr(s[d] ^ s[a], 16);
    s[c] = s[c] + s[d];
    s[b] = b3_rotr(s[b] ^ s[c], 12);
    s[a] = s[a] + s[b] + my;
    s[d] = b3_rotr(s[d] ^ s[a], 8);
    s[c] = s[c] + s[d];
    s[b] = b3_rotr(s[b] ^ s[c], 7);
}

static void b3_round(uint32_t s[16], const uint32_t m[16]) {
    b3_g(s, 0, 4, 8, 12, m[0], m[1]);
    b3_g(s, 1, 5, 9, 13, m[2], m[3]);
    b3_g(s, 2, 6, 10, 14, m[4], m[5]);
    b3_g(s, 3, 7, 11, 15, m[6], m[7]);
    b3_g(s, 0, 5, 10, 15, m[8], m[9]);
    b3_g(s, 1, 6, 11, 12, m[10], m[11]);
    b3_g(s, 2, 7, 8, 13, m[12], m[13]);
    b3_g(s, 3, 4, 9, 14, m[14], m[15]);
}

/* Full 16-word compression output; the first 8 words are the chaining
   value, all 16 are used for extended (root) output. */
static void b3_compress(const uint32_t cv[8], const uint8_t block[B3_BLOCK_LEN],
                        uint64_t counter, uint32_t block_len, uint32_t flags,
                        uint32_t out[16]) {
    uint32_t m[16];
    for (int i = 0; i < 16; i++) {
        m[i] = (uint32_t)block[i * 4] | ((uint32_t)block[i * 4 + 1] << 8) |
               ((uint32_t)block[i * 4 + 2] << 16) | ((uint32_t)block[i * 4 + 3] << 24);
    }
    uint32_t s[16] = {
        cv[0], cv[1], cv[2], cv[3], cv[4], cv[5], cv[6], cv[7],
        B3_IV[0], B3_IV[1], B3_IV[2], B3_IV[3],
        (uint32_t)counter, (uint32_t)(counter >> 32), block_len, flags
    };
    for (int r = 0; r < 7; r++) {
        b3_round(s, m);
        if (r < 6) {
            uint32_t p[16];
            for (int i = 0; i < 16; i++) p[i] = m[B3_PERM[i]];
            for (int i = 0; i < 16; i++) m[i] = p[i];
        }
    }
    for (int i = 0; i < 8; i++) {
        out[i] = s[i] ^ s[i + 8];
        out[i + 8] = s[i + 8] ^ cv[i];
    }
}

typedef struct {
    uint32_t cv[8];
    uint8_t block[B3_BLOCK_LEN];
    uint32_t block_len;
    uint64_t counter;
    uint32_t flags;
} B3Output;

typedef struct {
    uint32_t cv_stack[54][8];
    int cv_stack_len;
    uint32_t chunk_cv[8];
    uint64_t chunk_counter;
    uint8_t buf[B3_BLOCK_LEN];
    uint32_t buf_len;
    uint32_t blocks_compressed;
    uint32_t chunk_flags;
} B3Hasher;

static void b3_hasher_init(B3Hasher* h) {
    memset(h, 0, sizeof(*h));
    for (int i = 0; i < 8; i++) h->chunk_cv[i] = B3_IV[i];
    h->chunk_flags = B3_CHUNK_START;
}

static uint32_t b3_chunk_start_flag(const B3Hasher* h) {
    return h->blocks_compressed == 0 ? B3_CHUNK_START : 0;
}

static void b3_chunk_flush_block(B3Hasher* h) {
    uint32_t out[16];
    b3_compress(h->chunk_cv, h->buf, h->chunk_counter, B3_BLOCK_LEN,
                b3_chunk_start_flag(h), out);
    for (int i = 0; i < 8; i++) h->chunk_cv[i] = out[i];
    h->blocks_compressed++;
    h->buf_len = 0;
    memset(h->buf, 0, B3_BLOCK_LEN);
}

/* Chaining value of the chunk that has just been completed. */
static void b3_chunk_cv(B3Hasher* h, uint32_t out_cv[8]) {
    uint32_t out[16];
    b3_compress(h->chunk_cv, h->buf, h->chunk_counter, h->buf_len,
                b3_chunk_start_flag(h) | B3_CHUNK_END, out);
    for (int i = 0; i < 8; i++) out_cv[i] = out[i];
}

static void b3_push_cv(B3Hasher* h, const uint32_t cv[8], uint64_t total_chunks) {
    uint32_t merged[8];
    for (int i = 0; i < 8; i++) merged[i] = cv[i];
    /* Merge while the number of completed chunks is even at this level. */
    while ((total_chunks & 1) == 0 && h->cv_stack_len > 0) {
        uint8_t block[B3_BLOCK_LEN];
        uint32_t out[16];
        h->cv_stack_len--;
        for (int i = 0; i < 8; i++) {
            uint32_t w = h->cv_stack[h->cv_stack_len][i];
            block[i * 4] = (uint8_t)w;
            block[i * 4 + 1] = (uint8_t)(w >> 8);
            block[i * 4 + 2] = (uint8_t)(w >> 16);
            block[i * 4 + 3] = (uint8_t)(w >> 24);
        }
        for (int i = 0; i < 8; i++) {
            uint32_t w = merged[i];
            block[32 + i * 4] = (uint8_t)w;
            block[32 + i * 4 + 1] = (uint8_t)(w >> 8);
            block[32 + i * 4 + 2] = (uint8_t)(w >> 16);
            block[32 + i * 4 + 3] = (uint8_t)(w >> 24);
        }
        b3_compress(B3_IV, block, 0, B3_BLOCK_LEN, B3_PARENT, out);
        for (int i = 0; i < 8; i++) merged[i] = out[i];
        total_chunks >>= 1;
    }
    for (int i = 0; i < 8; i++) h->cv_stack[h->cv_stack_len][i] = merged[i];
    h->cv_stack_len++;
}

static void b3_hasher_update(B3Hasher* h, const uint8_t* input, size_t len) {
    while (len > 0) {
        if (h->buf_len == B3_BLOCK_LEN) {
            if (h->blocks_compressed == B3_CHUNK_LEN / B3_BLOCK_LEN - 1) {
                /* Last block of this chunk: finish the chunk here. */
                uint32_t cv[8];
                b3_chunk_cv(h, cv);
                b3_push_cv(h, cv, h->chunk_counter + 1);
                h->chunk_counter++;
                for (int i = 0; i < 8; i++) h->chunk_cv[i] = B3_IV[i];
                h->blocks_compressed = 0;
                h->buf_len = 0;
                memset(h->buf, 0, B3_BLOCK_LEN);
            } else {
                b3_chunk_flush_block(h);
            }
        }
        size_t take = B3_BLOCK_LEN - h->buf_len;
        if (take > len) take = len;
        memcpy(h->buf + h->buf_len, input, take);
        h->buf_len += (uint32_t)take;
        input += take;
        len -= take;
    }
}

static void b3_hasher_finalize(const B3Hasher* h_in, uint8_t* out, size_t out_len) {
    B3Hasher h = *h_in;
    uint32_t cv[8];
    uint8_t block[B3_BLOCK_LEN];
    uint32_t flags;
    uint64_t counter;
    uint32_t block_len;
    int stack = h.cv_stack_len;

    /* Output node of the final chunk. */
    for (int i = 0; i < 8; i++) cv[i] = h.chunk_cv[i];
    memcpy(block, h.buf, B3_BLOCK_LEN);
    block_len = h.buf_len;
    counter = h.chunk_counter;
    flags = b3_chunk_start_flag(&h) | B3_CHUNK_END;

    /* Fold the stack, innermost first; each fold becomes the new output node. */
    while (stack > 0) {
        uint32_t node[16];
        uint8_t parent[B3_BLOCK_LEN];
        b3_compress(cv, block, counter, block_len, flags, node);
        stack--;
        for (int i = 0; i < 8; i++) {
            uint32_t w = h.cv_stack[stack][i];
            parent[i * 4] = (uint8_t)w;
            parent[i * 4 + 1] = (uint8_t)(w >> 8);
            parent[i * 4 + 2] = (uint8_t)(w >> 16);
            parent[i * 4 + 3] = (uint8_t)(w >> 24);
        }
        for (int i = 0; i < 8; i++) {
            uint32_t w = node[i];
            parent[32 + i * 4] = (uint8_t)w;
            parent[32 + i * 4 + 1] = (uint8_t)(w >> 8);
            parent[32 + i * 4 + 2] = (uint8_t)(w >> 16);
            parent[32 + i * 4 + 3] = (uint8_t)(w >> 24);
        }
        for (int i = 0; i < 8; i++) cv[i] = B3_IV[i];
        memcpy(block, parent, B3_BLOCK_LEN);
        block_len = B3_BLOCK_LEN;
        counter = 0;
        flags = B3_PARENT;
    }

    /* Root output, extended by incrementing the output-block counter. */
    uint64_t obc = 0;
    size_t off = 0;
    while (off < out_len) {
        uint32_t words[16];
        uint8_t bytes[64];
        b3_compress(cv, block, obc, block_len, flags | B3_ROOT, words);
        for (int i = 0; i < 16; i++) {
            bytes[i * 4] = (uint8_t)words[i];
            bytes[i * 4 + 1] = (uint8_t)(words[i] >> 8);
            bytes[i * 4 + 2] = (uint8_t)(words[i] >> 16);
            bytes[i * 4 + 3] = (uint8_t)(words[i] >> 24);
        }
        size_t take = out_len - off;
        if (take > 64) take = 64;
        memcpy(out + off, bytes, take);
        off += take;
        obc++;
    }
}

static void zyl_blake3_raw(const uint8_t* input, size_t len, uint8_t* out, size_t out_len) {
    B3Hasher h;
    b3_hasher_init(&h);
    b3_hasher_update(&h, input, len);
    b3_hasher_finalize(&h, out, out_len);
}

static const char* B3_HEXDIGITS = "0123456789abcdef";

/* BLAKE3 over src[0..len) as `outbytes` bytes of lowercase hex (so the
   returned string is 2*outbytes characters). len < 0 means strlen(src). */
long long zyl_blake3_hex(long long arena, long long src, long long len, long long outbytes) {
    if (!src) return 0;
    const uint8_t* s = (const uint8_t*)(size_t)src;
    size_t n = len < 0 ? strlen((const char*)s) : (size_t)len;
    if (outbytes <= 0) outbytes = 32;
    if (outbytes > 64) outbytes = 64;
    uint8_t digest[64];
    zyl_blake3_raw(s, n, digest, (size_t)outbytes);
    long long buf = zyl_arena_alloc_zeroed(arena, outbytes * 2 + 1);
    char* d = (char*)(size_t)buf;
    for (long long i = 0; i < outbytes; i++) {
        d[i * 2] = B3_HEXDIGITS[digest[i] >> 4];
        d[i * 2 + 1] = B3_HEXDIGITS[digest[i] & 15];
    }
    d[outbytes * 2] = 0;
    return buf;
}

/* BLAKE3 of a file's contents, as lowercase hex. Returns 0 if the file
   cannot be read. Streamed, so archive-sized inputs need no buffer. */
long long zyl_blake3_file_hex(long long arena, long long path, long long outbytes) {
    const char* p = (const char*)(size_t)path;
    if (!p) return 0;
    FILE* f = fopen(p, "rb");
    if (!f) return 0;
    B3Hasher h;
    b3_hasher_init(&h);
    unsigned char chunk[65536];
    size_t got;
    while ((got = fread(chunk, 1, sizeof(chunk), f)) > 0) {
        b3_hasher_update(&h, chunk, got);
    }
    fclose(f);
    if (outbytes <= 0) outbytes = 32;
    if (outbytes > 64) outbytes = 64;
    uint8_t digest[64];
    b3_hasher_finalize(&h, digest, (size_t)outbytes);
    long long buf = zyl_arena_alloc_zeroed(arena, outbytes * 2 + 1);
    char* d = (char*)(size_t)buf;
    for (long long i = 0; i < outbytes; i++) {
        d[i * 2] = B3_HEXDIGITS[digest[i] >> 4];
        d[i * 2 + 1] = B3_HEXDIGITS[digest[i] & 15];
    }
    d[outbytes * 2] = 0;
    return buf;
}

/* §31.2 escape(): [A-Za-z0-9] verbatim, '_' -> "_5F", anything else ->
   "_x" + two uppercase hex digits. Injective by construction, which is
   the whole point: zyl_cstr_sanitize collapses '/', '.' and '-' onto '_'
   and would merge distinct canonical keys into one label. */
static size_t zyl_sym_escape_into(const char* s, size_t n, char* out) {
    static const char* HEX = "0123456789ABCDEF";
    size_t w = 0;
    for (size_t i = 0; i < n; i++) {
        unsigned char c = (unsigned char)s[i];
        int plain = (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
                    (c >= '0' && c <= '9');
        if (plain) {
            if (out) out[w] = (char)c;
            w += 1;
        } else if (c == '_') {
            if (out) { out[w] = '_'; out[w + 1] = '5'; out[w + 2] = 'F'; }
            w += 3;
        } else {
            if (out) {
                out[w] = '_';
                out[w + 1] = 'x';
                out[w + 2] = HEX[c >> 4];
                out[w + 3] = HEX[c & 15];
            }
            w += 4;
        }
    }
    return w;
}

long long zyl_sym_escape(long long arena, long long src) {
    if (!src) return 0;
    const char* s = (const char*)(size_t)src;
    size_t n = strlen(s);
    size_t need = zyl_sym_escape_into(s, n, NULL);
    long long buf = zyl_arena_alloc_zeroed(arena, (long long)need + 1);
    char* d = (char*)(size_t)buf;
    zyl_sym_escape_into(s, n, d);
    d[need] = 0;
    return buf;
}

/* §31.2 mangle(): canonical key `<package>@<major>::<module>::<symbol>`
   becomes `zy_<esc pkg>_<major>__<esc module>__<esc symbol>`. A label
   over 200 bytes keeps its first 184 bytes and gains 16 hex digits of
   BLAKE3 over the FULL canonical key, so truncation stays injective in
   practice and deterministic everywhere.

   A string with no '@' is not a canonical key (a bare local or builtin
   name); it is escaped as a symbol with no package part so that the
   label path is injective for those too. */
long long zyl_mangle_key(long long arena, long long key) {
    if (!key) return 0;
    const char* k = (const char*)(size_t)key;
    size_t klen = strlen(k);

    const char* pkg = k;
    size_t pkg_len = 0;
    const char* major = "0";
    size_t major_len = 1;
    const char* mod = "";
    size_t mod_len = 0;
    const char* sym = k;
    size_t sym_len = klen;

    const char* at = memchr(k, '@', klen);
    if (at) {
        pkg_len = (size_t)(at - k);
        const char* rest = at + 1;
        size_t rest_len = klen - pkg_len - 1;
        const char* sep = NULL;
        for (size_t i = 0; i + 1 < rest_len; i++) {
            if (rest[i] == ':' && rest[i + 1] == ':') { sep = rest + i; break; }
        }
        if (sep) {
            major = rest;
            major_len = (size_t)(sep - rest);
            const char* after = sep + 2;
            size_t after_len = rest_len - major_len - 2;
            const char* sep2 = NULL;
            for (size_t i = 0; i + 1 < after_len; i++) {
                if (after[i] == ':' && after[i + 1] == ':') { sep2 = after + i; break; }
            }
            if (sep2) {
                mod = after;
                mod_len = (size_t)(sep2 - after);
                sym = sep2 + 2;
                sym_len = after_len - mod_len - 2;
            } else {
                sym = after;
                sym_len = after_len;
            }
        } else {
            sym = rest;
            sym_len = rest_len;
        }
    }

    size_t need = 3 /* "zy_" */
                + zyl_sym_escape_into(pkg, pkg_len, NULL)
                + 1 + major_len + 2
                + zyl_sym_escape_into(mod, mod_len, NULL)
                + 2
                + zyl_sym_escape_into(sym, sym_len, NULL);

    char* full = (char*)malloc(need + 1);
    if (!full) return 0;
    size_t w = 0;
    memcpy(full + w, "zy_", 3); w += 3;
    w += zyl_sym_escape_into(pkg, pkg_len, full + w);
    full[w++] = '_';
    memcpy(full + w, major, major_len); w += major_len;
    full[w++] = '_'; full[w++] = '_';
    w += zyl_sym_escape_into(mod, mod_len, full + w);
    full[w++] = '_'; full[w++] = '_';
    w += zyl_sym_escape_into(sym, sym_len, full + w);
    full[w] = 0;

    long long out;
    if (w <= 200) {
        out = zyl_arena_alloc_zeroed(arena, (long long)w + 1);
        memcpy((void*)(size_t)out, full, w + 1);
    } else {
        uint8_t digest[8];
        zyl_blake3_raw((const uint8_t*)k, klen, digest, sizeof(digest));
        out = zyl_arena_alloc_zeroed(arena, 201);
        char* d = (char*)(size_t)out;
        memcpy(d, full, 184);
        for (int i = 0; i < 8; i++) {
            d[184 + i * 2] = B3_HEXDIGITS[digest[i] >> 4];
            d[184 + i * 2 + 1] = B3_HEXDIGITS[digest[i] & 15];
        }
        d[200] = 0;
    }
    free(full);
    return out;
}
