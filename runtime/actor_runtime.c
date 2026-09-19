#include "actor_runtime.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <limits.h>

#define ZYL_HEAP_ARENA_DEFAULT_BLOCK (1024 * 1024)
#define ZYL_PIN_ARENA_DEFAULT_BLOCK (256 * 1024)

static ZylActorSystem g_system;
static void* g_heap_arena = NULL;
static void* g_pin_arena = NULL;

#include <sys/resource.h>
#include <sys/mman.h>
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
    return zyl_arena_alloc((long long)(size_t)g_pin_arena, size);
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
long long zyl_file_read_c(long long fd, long long count) {
    static _Thread_local char buf[1 << 20];
    long long n = read((int)fd, buf, (size_t)count);
    if (n < 0) n = 0;
    if (n >= (long long)sizeof(buf) - 1) n = (long long)sizeof(buf) - 1;
    buf[n] = 0;
    return (long long)(size_t)buf;
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

long long zyl_system_cmd(long long cmd) {
    return (long long)system((const char*)(size_t)cmd);
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

#include <spawn.h>
#include <sys/wait.h>
extern char** environ;

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
