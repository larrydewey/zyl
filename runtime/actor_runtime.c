#include "actor_runtime.h"
long long zyl_ralloc(long long size, long long rp);
/* The region a region-aware runtime function allocates its result in:
   0 (the heap) except while one of the `_r` entry points below runs,
   which compiled code calls only from a site region inference
   annotated, with zyl_cur_region set just before the call. Every other
   caller (the interpreter, C code inside this runtime) gets the heap. */
static __thread long long g_result_region = 0;
long long zyl_regions_enabled(void);
#define ZYL_RESULT_ALLOC(n) zyl_ralloc((long long)(n), g_result_region)
#include <stdint.h>
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

/* Lowest address the kernel will ever map on Linux by default
 * (/proc/sys/vm/mmap_min_addr, 0x10000 on most distros; 0x1000 is the
 * conservative floor even on the most permissive configs). Used to reject
 * small bogus integers misused as pointers before dereferencing them. */
#define ZYL_MIN_CALL_ADDR 0x1000LL

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
    /* Idempotent (bodies behind g_system.initialized); registers the
       item-26 actor drain as an atexit handler exactly once, whether or
       not the program ever spawns. The compiler emits zyl_ensure_arenas
       in every generated main prologue, so every compiled program
       drains its actors before exit. */
    zyl_actor_init();
    if (!g_heap_arena) {
        g_heap_arena = (void*)(size_t)zyl_arena_create(ZYL_HEAP_ARENA_DEFAULT_BLOCK);
    }
    if (!g_pin_arena) {
        g_pin_arena = (void*)(size_t)zyl_arena_create(ZYL_PIN_ARENA_DEFAULT_BLOCK);
    }
}

__attribute__((destructor))
static void zyl_runtime_cleanup(void) {
    /* An abandoned FFI call may still be using arena memory. */
    if (zyl_ffi_abandoned()) return;
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
    atexit(zyl_actor_wait_all);
}

uint32_t zyl_actor_spawn(void (*entry)(void*), void* state) {
    if (!g_system.initialized) zyl_actor_init();

    /* The compiler lowers a capture-free lambda's value to a plain code
       pointer (entry with state=0), but a CAPTURING lambda is a heap
       [tag, code, env] triple (ic-closure-magic, 2051230803 -- see
       icnf.zyl ic-closure-magic), and codegen currently passes that whole
       triplet value in the `entry` slot with state=0. Calling it as code
       segfaults (the triplet is data, not text). Decompose the triplet
       here instead: code = [1], env = [2], the env being exactly the
       `_clos_env` trailing argument a lifted zero-arg closure fn expects.
       For a capture-free lambda the code pointer's first qword is not the
       magic tag, so nothing changes. Each spawned body is a zero-arg
       lambda, so the one-arg (env) ABI is exactly right. */
    if ((unsigned long long)(size_t)entry >= ZYL_MIN_CALL_ADDR) {
        const long long* p = (const long long*)(size_t)entry;
        if (p[0] == 2051230803LL) {
            entry = (void (*)(void*))(size_t)p[1];
            state = (void*)(size_t)p[2];
        }
    }

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
        /* msg is a caller-owned opaque value (an int, an arena block, a
           caller's string) -- NEVER freed here. Dropping the send must not
           free() an arbitrary value: `(send 5 7)` used to crash with
           "free(): invalid pointer". */
        return;
    }

    ZylActor* actor = &g_system.actors[actor_id];

    ZylMessage* m = (ZylMessage*)malloc(sizeof(ZylMessage));
    if (!m) {
        return;
    }
    m->kind = ZYL_MSG_DATA;
    m->data = msg;
    m->next = NULL;

    pthread_mutex_lock(&actor->lock);
    if (!actor->alive) {
        pthread_mutex_unlock(&actor->lock);
        free(m);
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

/* The running actor's id; -1 on a thread that is not an actor yet. */
static _Thread_local long long g_self_id = -1;

/* (actor-self): this actor's id. On the main thread the first call opens a
   mailbox (a slot with no thread of its own), so actors can reply to main;
   wait_all skips it because it has no thread. */
long long zyl_actor_self(void) {
    if (g_self_id >= 0) return g_self_id;
    if (!g_system.initialized) zyl_actor_init();
    uint32_t id = g_system.next_id;
    if (id >= ZYL_MAX_ACTORS) return -1;
    ZylActor* actor = &g_system.actors[id];
    memset(actor, 0, sizeof *actor);
    actor->alive = 1;
    pthread_mutex_init(&actor->lock, NULL);
    pthread_cond_init(&actor->cond, NULL);
    g_system.next_id++;
    g_self_id = id;
    return id;
}

/* (receive): the next data message in this actor's mailbox, blocking until
   one arrives. Closure messages queued ahead of it run first, so the
   mailbox stays FIFO. Waiting counts as parked for wait_all; when the
   process stops the actor, its thread ends here. */
long long zyl_actor_receive(void) {
    long long id = zyl_actor_self();
    if (id < 0) return 0;
    ZylActor* actor = &g_system.actors[id];
    for (;;) {
        pthread_mutex_lock(&actor->lock);
        while (actor->alive && !actor->mailbox_head) {
            actor->parked = 1;
            pthread_cond_wait(&actor->cond, &actor->lock);
        }
        actor->parked = 0;
        if (!actor->alive) {
            int threaded = actor->thread != 0;
            if (threaded) actor->running = 0;
            pthread_mutex_unlock(&actor->lock);
            if (threaded) pthread_exit(NULL);
            return 0;
        }
        ZylMessage* m = actor->mailbox_head;
        actor->mailbox_head = m->next;
        if (!actor->mailbox_head) actor->mailbox_tail = NULL;
        actor->mailbox_count--;
        pthread_mutex_unlock(&actor->lock);
        if (m->kind == ZYL_MSG_DATA) {
            long long v = (long long)(size_t)m->data;
            free(m);
            return v;
        }
        ZylClosureMsg* closure = (ZylClosureMsg*)m->data;
        if (closure && closure->fn) closure->fn(closure->state);
        free(closure);
        free(m);
    }
}

void* zyl_actor_thread_entry(void* arg) {
    uint32_t id = (uint32_t)(size_t)arg;
    if (id >= ZYL_MAX_ACTORS) return NULL;
    g_self_id = id;

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
            /* parked: blocked here with an empty mailbox, so this thread
               cannot be mid-message and cannot enqueue anywhere. wait_all
               keys its quiescence check on this. */
            actor->parked = 1;
            pthread_cond_wait(&actor->cond, &actor->lock);
        }
        actor->parked = 0;
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
        /* Phase 1: drain. Wait until no active, running actor has pending
           mail. (An actor whose consumer already stopped -- running==0 --
           can no longer process mail; it can't send more either.) */
        int pending;
        do {
            pending = 0;
            for (uint32_t i = 0; i < ZYL_MAX_ACTORS; i++) {
                ZylActor* actor = &g_system.actors[i];
                pthread_mutex_lock(&actor->lock);
                int active = !actor->joined && actor->thread && actor->running && actor->mailbox_count > 0;
                pthread_mutex_unlock(&actor->lock);
                if (active) {
                    pending = 1;
                    break;
                }
            }
            if (pending) usleep(1000);
        } while (pending);

        /* Phase 2: quiescence check, re-checking under each actor's lock.
           Every active running actor must be parked (consumer blocked in
           cond_wait on an empty mailbox). A parked consumer holds no
           message, so it cannot be executing a body that sends to another
           actor; with every sender parked and the main thread (the only
           other sender) inside wait_all, no further message can land. If
           any active running actor is still mid-message, loop again. The
           old code instead stopped and joined actors in id order, so a
           still-running higher-id actor could reply to an already-stopped
           lower-id one and the reply was silently dropped. */
        int quiesced = 1;
        for (uint32_t i = 0; i < ZYL_MAX_ACTORS; i++) {
            ZylActor* actor = &g_system.actors[i];
            pthread_mutex_lock(&actor->lock);
            int active = !actor->joined && actor->thread;
            if (active && actor->running && (actor->mailbox_count > 0 || !actor->parked)) {
                quiesced = 0;
            }
            pthread_mutex_unlock(&actor->lock);
            if (!quiesced) break;
        }
        if (!quiesced) continue;

        /* Phase 3: stop every active actor in one pass, then join. All
           consumers are parked and can only wake on a broadcast issued
           right after their OWN alive=0 write, so nothing is dropped. */
        for (uint32_t i = 0; i < ZYL_MAX_ACTORS; i++) {
            ZylActor* actor = &g_system.actors[i];
            pthread_mutex_lock(&actor->lock);
            int active = !actor->joined && actor->thread;
            if (active) {
                actor->alive = 0;
                actor->parked = 0;
            }
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
        break;
    }
}

/* Waits for all spawned actors to finish their pending messages before the
   process exits (registered as an atexit handler from zyl_actor_init). This
   is what makes a program whose main returns before its actors finish still
   run every sent message to completion: without it, "42 was printed only if
   the scheduler happened to run the actor before main returned". */

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
    void* region_mark;   /* zyl_region_top when the handler was installed */
};
void* zyl_region_mark(void);
void zyl_region_unwind(void* mark);

/* Thread-local: each actor runs its own thread with independent try/catch
 * nesting. A process-global here would let one actor's zyl_try_pop/
 * zyl_panic unlink or longjmp into another actor's frame/stack. */
static _Thread_local struct ZylTryFrame* g_try_top = 0;

void* zyl_try_push(void) {
    struct ZylTryFrame* f = (struct ZylTryFrame*)malloc(sizeof *f);
    f->prev = g_try_top;
    f->msg = 0;
    f->region_mark = zyl_region_mark();
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
    char* buf = (char*)(size_t)ZYL_RESULT_ALLOC(la + lb + 1);
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
    char* buf = (char*)(size_t)ZYL_RESULT_ALLOC(len + 1);
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

/* 1 when `key` equals `name` or is a qualified key ending in "::name".
 * Allocation-free: type inference calls it inside every linear lookup. */
long long zyl_cstr_key_matches(long long key, long long name) {
    if (key == name) return 1;
    if (!key || !name) return 0;
    const char* k = (const char*)(size_t)key;
    const char* n = (const char*)(size_t)name;
    size_t kl = strlen(k), nl = strlen(n);
    if (kl == nl) return (long long)(memcmp(k, n, kl) == 0);
    if (kl < nl + 2) return 0;
    const char* tail = k + (kl - nl);
    return (long long)(tail[-1] == ':' && tail[-2] == ':' && memcmp(tail, n, nl) == 0);
}

/* Byte-wise ordering of two strings: -1, 0 or 1 (NULL sorts first). */
long long zyl_cstr_cmp(long long p1, long long p2) {
    if (p1 == p2) return 0;
    if (!p1 || !p2) return p1 ? 1 : -1;
    int c = strcmp((const char*)(size_t)p1, (const char*)(size_t)p2);
    return c < 0 ? -1 : (c > 0 ? 1 : 0);
}

long long zyl_mem_alloc(long long size) {
    return (long long)(size_t)malloc((size_t)size);
}

long long zyl_mem_free(long long ptr) {
    free((void*)(size_t)ptr);
    return 0;
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
    /* Handle is an opaque value; a small integer (or null) must be
       rejected before the magic deref below, or `(store-u8 1 7 1000)`
       segfaults on h->magic. Any real malloc'd header is >= mmap_min_addr
       and 8-aligned (malloc returns suitably aligned blocks; both headers
       start with a long long so the handle is always 8-aligned). */
    if ((unsigned long long)buf < ZYL_MIN_CALL_ADDR || ((unsigned long long)buf & 7) != 0) return NULL;
    ZylByteBufHeader* h = (ZylByteBufHeader*)(size_t)buf;
    return h->magic == ZYL_BYTEBUF_MAGIC ? h : NULL;
}

static ZylByteSliceHeader* zyl_byteslice_of(long long slice) {
    if (!slice) return NULL;
    if ((unsigned long long)slice < ZYL_MIN_CALL_ADDR || ((unsigned long long)slice & 7) != 0) return NULL;
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

/* 2-, 4- and 8-byte accesses (load-u16 .. store-i64). The whole width must
   fit, or a load returns 0 and a store does nothing and returns 0.
   endian 0 is little-endian, 1 big-endian. */
static int zyl_width_ok(long long w) { return w == 2 || w == 4 || w == 8; }

long long zyl_load_n(long long width, long long endian, long long offset, long long buf) {
    ZylBytesView v = zyl_bytes_view(buf);
    if (!zyl_width_ok(width) || !v.valid || !zyl_bb_bounds_ok(offset, width, v.bound)) return 0;
    unsigned long long r = 0;
    for (long long i = 0; i < width; i++) {
        unsigned long long b = v.data[offset + (endian ? i : width - 1 - i)];
        r = (r << 8) | b;
    }
    return (long long)r;
}

long long zyl_load_n_signed(long long width, long long endian, long long offset, long long buf) {
    unsigned long long r = (unsigned long long)zyl_load_n(width, endian, offset, buf);
    if (width >= 8) return (long long)r;
    unsigned long long sign = 1ULL << (width * 8 - 1);
    return (long long)((r ^ sign) - sign);
}

long long zyl_store_n(long long width, long long endian, long long offset, long long buf, long long val) {
    ZylBytesView v = zyl_bytes_view(buf);
    if (!zyl_width_ok(width) || !v.valid || !zyl_bb_bounds_ok(offset, width, v.bound)) return 0;
    unsigned long long u = (unsigned long long)val;
    for (long long i = 0; i < width; i++) {
        v.data[offset + (endian ? width - 1 - i : i)] = (unsigned char)(u >> (8 * i));
    }
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
/* Hex digit value, or -1. Used by zyl_cstr_decode's \xNN escape. */
static int zyl_hexval(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return 10 + (c - 'a');
    if (c >= 'A' && c <= 'F') return 10 + (c - 'A');
    return -1;
}

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
            /* \e is ESC (0x1b). Every ANSI control sequence a terminal
               program emits starts with it, and without this escape the
               REPL's line editor could not write one as a string literal
               at all -- it would have to build each sequence byte by byte
               at runtime. \xNN covers the rest of the non-printables. */
            else if (n == 'e') { out[o++] = (char)27; i += 2; }
            else if (n == 'x' && i + 3 < end
                     && zyl_hexval(s[i + 2]) >= 0 && zyl_hexval(s[i + 3]) >= 0) {
                out[o++] = (char)((zyl_hexval(s[i + 2]) << 4) | zyl_hexval(s[i + 3]));
                i += 4;
            }
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

/* --------------------------------------------------------------------------
   Arena memory budget.

   A failed malloc here used to return 0, and every caller dereferenced it:
   a segfault with no diagnosis. Worse, Linux overcommits, so malloc rarely
   fails at all -- the process simply grows until the kernel OOM killer takes
   it, which is not a diagnosis either. A compiler bug that allocates without
   bound (type inference used to be exponential in a function body's
   statement count) therefore took the machine's memory with it instead of
   reporting anything.

   The budget is deliberately not a fixed constant, which would be wrong for
   both small machines and large programs. It is:
     ZYL_MAX_MEMORY (bytes) when set -- 0 disables the budget entirely;
     otherwise 80% of this machine's MemAvailable at first allocation;
     otherwise 80% of total RAM; otherwise unlimited.
   It binds only where the kernel would have killed the process anyway, and
   it cannot change the output of a compile that succeeds -- only how one
   that was already doomed reports itself.
   -------------------------------------------------------------------------- */

static size_t g_arena_budget = 0;      /* 0 = unlimited */
static size_t g_arena_bytes = 0;       /* live bytes across every arena */
static pthread_once_t g_arena_budget_once = PTHREAD_ONCE_INIT;

static size_t zyl_meminfo_available(void) {
    FILE* f = fopen("/proc/meminfo", "r");
    if (!f) return 0;
    char line[256];
    size_t avail = 0, total = 0;
    while (fgets(line, sizeof line, f)) {
        unsigned long long kb;
        if (sscanf(line, "MemAvailable: %llu kB", &kb) == 1) { avail = (size_t)kb * 1024; break; }
        if (sscanf(line, "MemTotal: %llu kB", &kb) == 1) total = (size_t)kb * 1024;
    }
    fclose(f);
    return avail ? avail : total;
}

static void zyl_arena_budget_init(void) {
    const char* env = getenv("ZYL_MAX_MEMORY");
    if (env && *env) {
        char* end = NULL;
        unsigned long long v = strtoull(env, &end, 10);
        g_arena_budget = (size_t)v;   /* 0 means "no budget" */
        return;
    }
    size_t avail = zyl_meminfo_available();
    if (!avail) {
        long pages = sysconf(_SC_PHYS_PAGES), psz = sysconf(_SC_PAGESIZE);
        if (pages > 0 && psz > 0) avail = (size_t)pages * (size_t)psz;
    }
    g_arena_budget = avail ? avail / 5 * 4 : 0;
}

/* Out of memory is not recoverable here: unwinding through zyl_panic runs
 * handlers that allocate. Report and stop. */
static void zyl_arena_oom(size_t requested, const char* why) {
    fprintf(stderr,
            "PANIC: error[E_OUT_OF_MEMORY]: %s\n"
            "  = requested %zu bytes; %zu bytes already allocated; budget %zu bytes\n"
            "  = help: set ZYL_MAX_MEMORY to a byte count to raise the budget, "
            "or ZYL_MAX_MEMORY=0 to remove it\n",
            why, requested, g_arena_bytes, g_arena_budget);
    fflush(stderr);
    _exit(1);
}

/* Charge `n` bytes against the budget before they are handed to malloc. */
static int zyl_arena_charge(size_t n) {
    pthread_once(&g_arena_budget_once, zyl_arena_budget_init);
    size_t now = __atomic_add_fetch(&g_arena_bytes, n, __ATOMIC_RELAXED);
    if (g_arena_budget && now > g_arena_budget) {
        __atomic_sub_fetch(&g_arena_bytes, n, __ATOMIC_RELAXED);
        return 0;
    }
    return 1;
}

static void zyl_arena_refund(size_t n) {
    __atomic_sub_fetch(&g_arena_bytes, n, __ATOMIC_RELAXED);
}

static ZylArenaBlock* zyl_arena_new_block_of(ZylArena* a, size_t cap) {
    if (cap < a->block_size) cap = a->block_size;
    if (!zyl_arena_charge(cap))
        zyl_arena_oom(cap, "memory budget exhausted");
    ZylArenaBlock* b = (ZylArenaBlock*)malloc(sizeof(ZylArenaBlock));
    if (!b) {
        zyl_arena_refund(cap);
        zyl_arena_oom(sizeof(ZylArenaBlock), "out of memory allocating an arena block header");
    }
    b->mem = (char*)malloc(cap);
    if (!b->mem) {
        free(b);
        zyl_arena_refund(cap);
        zyl_arena_oom(cap, "out of memory allocating an arena block");
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

long long zyl_arena_reset(long long arena) {
    if (!arena) return 0;
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
        zyl_arena_refund(b->cap);
        free(b->mem);
        free(b);
        b = next;
    }
    a->head = NULL;
    a->total_capacity = 0;
    a->total_used = 0;
    pthread_mutex_unlock(&a->lock);
    return 0;
}

long long zyl_arena_destroy(long long arena) {
    if (!arena) return 0;
    ZylArena* a = (ZylArena*)(size_t)arena;
    pthread_mutex_lock(&a->lock);
    ZylArenaBlock* b = a->head;
    while (b) {
        ZylArenaBlock* next = b->next;
        memset(b->mem, 0xDE, b->used);
        zyl_arena_refund(b->cap);
        free(b->mem);
        free(b);
        b = next;
    }
    pthread_mutex_unlock(&a->lock);
    pthread_mutex_destroy(&a->lock);
    free(a);
    return 0;
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

/* ==========================================================================
   Source spans.

   Ast nodes (compiler/ast.zyl) carry no position field. Giving them one
   would mean editing every one of the ~470 sites that name an Ast
   constructor -- as a pattern in one place and as a construction in the
   next -- inside a compiler that then has to go on compiling itself, and
   a single miscounted pattern arity there is a silent miscompile rather
   than a build error. So the position lives beside the node instead of
   inside it: the reader records, for each node it builds, the byte offset
   it was read from, keyed by the node's own address.

   That is sound here because a variant value in this implementation IS
   its heap pointer, and arena memory is never freed, moved or reset
   during a compile -- a node's address stays valid for as long as any
   diagnostic can ask about it.

   The table is only ever probed by key, never iterated, so its layout
   cannot reach the output of a compile: determinism is unaffected. A
   miss returns -1 and the diagnostic simply prints without a location.
   ========================================================================== */

typedef struct { uintptr_t key; int off; int fid; } ZylSpanSlot;

static ZylSpanSlot* g_spans = NULL;
static size_t g_span_cap = 0;      /* power of two */
static size_t g_span_len = 0;

typedef struct { char* path; char* text; size_t len; } ZylSrcFile;

#define ZYL_MAX_SRC_FILES 256
static ZylSrcFile g_src_files[ZYL_MAX_SRC_FILES];
static int g_src_file_count = 0;

static size_t zyl_span_hash(uintptr_t k) {
    /* splitmix64 finalizer: addresses are 16-byte aligned, so the low bits
     * are always zero and the identity hash would cluster every key into
     * one sixteenth of the table. */
    uint64_t x = (uint64_t)k;
    x ^= x >> 30; x *= 0xbf58476d1ce4e5b9ULL;
    x ^= x >> 27; x *= 0x94d049bb133111ebULL;
    x ^= x >> 31;
    return (size_t)x;
}

static void zyl_span_grow(void) {
    /* Grow by eight, not two. A real compile records a span for every node
     * of every rewriting pass -- millions of them -- and doubling from 4096
     * spends its first seconds rehashing; measured, that alone was most of
     * the cost of carrying spans at all. Eight keeps a small compile's table
     * small and reaches millions in four steps. */
    size_t ncap = g_span_cap ? g_span_cap * 8 : 4096;
    ZylSpanSlot* ns = (ZylSpanSlot*)calloc(ncap, sizeof(ZylSpanSlot));
    if (!ns) return;                       /* spans are optional: drop them */
    for (size_t i = 0; i < g_span_cap; i++) {
        if (!g_spans[i].key) continue;
        size_t j = zyl_span_hash(g_spans[i].key) & (ncap - 1);
        while (ns[j].key) j = (j + 1) & (ncap - 1);
        ns[j] = g_spans[i];
    }
    free(g_spans);
    g_spans = ns;
    g_span_cap = ncap;
}

/* Record that `node` was read at byte `off` of source file `fid`. */
long long zyl_span_set(long long node, long long off, long long fid) {
    if (!node) return 0;
    if (g_span_len * 10 >= g_span_cap * 7) zyl_span_grow();
    if (!g_span_cap) return 0;
    uintptr_t k = (uintptr_t)(size_t)node;
    size_t i = zyl_span_hash(k) & (g_span_cap - 1);
    while (g_spans[i].key && g_spans[i].key != k) i = (i + 1) & (g_span_cap - 1);
    if (!g_spans[i].key) { g_spans[i].key = k; g_span_len++; }
    g_spans[i].off = (int)off;
    g_spans[i].fid = (int)fid;
    return 0;
}

static ZylSpanSlot* zyl_span_find(long long node) {
    if (!node || !g_span_cap) return NULL;
    uintptr_t k = (uintptr_t)(size_t)node;
    size_t i = zyl_span_hash(k) & (g_span_cap - 1);
    while (g_spans[i].key) {
        if (g_spans[i].key == k) return &g_spans[i];
        i = (i + 1) & (g_span_cap - 1);
    }
    return NULL;
}

/* Byte offset a node was read from, or -1 when it was never recorded
 * (every node a later phase synthesises rather than reads). */
long long zyl_span_off(long long node) {
    ZylSpanSlot* s = zyl_span_find(node);
    return s ? (long long)s->off : -1;
}

long long zyl_span_file(long long node) {
    ZylSpanSlot* s = zyl_span_find(node);
    return s ? (long long)s->fid : -1;
}

/* Give `dst` the same position as `src`. Used where one representation is
 * built straight from another (convert-ast turning an Ast into an Expr) so
 * a later phase's diagnostic can still point at the user's own text. The
 * fields are read out first: zyl_span_set may grow and rehash the table,
 * which would invalidate the slot pointer. */
long long zyl_span_copy(long long dst, long long src) {
    ZylSpanSlot* s = zyl_span_find(src);
    if (!s) return 0;
    int off = s->off, fid = s->fid;
    return zyl_span_set(dst, off, fid);
}

/* Node attribute tables, string maps and word vectors for compiler passes.
   Keyed by address or content, probed only (never iterated); a miss reads 0. */

#define ZYL_ATTR_TABLES 6
typedef struct { uintptr_t key; long long val; } ZylAttrSlot;
static ZylAttrSlot* g_attrs[ZYL_ATTR_TABLES];
static size_t g_attr_cap[ZYL_ATTR_TABLES];
static size_t g_attr_len[ZYL_ATTR_TABLES];

static void zyl_attr_grow(int t) {
    size_t ncap = g_attr_cap[t] ? g_attr_cap[t] * 8 : 4096;
    ZylAttrSlot* ns = (ZylAttrSlot*)calloc(ncap, sizeof(ZylAttrSlot));
    if (!ns) return;
    for (size_t i = 0; i < g_attr_cap[t]; i++) {
        if (!g_attrs[t][i].key) continue;
        size_t j = zyl_span_hash(g_attrs[t][i].key) & (ncap - 1);
        while (ns[j].key) j = (j + 1) & (ncap - 1);
        ns[j] = g_attrs[t][i];
    }
    free(g_attrs[t]);
    g_attrs[t] = ns;
    g_attr_cap[t] = ncap;
}

long long zyl_attr_set(long long t, long long node, long long val) {
    if (!node || t < 0 || t >= ZYL_ATTR_TABLES) return 0;
    if (g_attr_len[t] * 10 >= g_attr_cap[t] * 7) zyl_attr_grow((int)t);
    if (!g_attr_cap[t]) return 0;
    uintptr_t k = (uintptr_t)(size_t)node;
    size_t m = g_attr_cap[t] - 1;
    size_t i = zyl_span_hash(k) & m;
    while (g_attrs[t][i].key && g_attrs[t][i].key != k) i = (i + 1) & m;
    if (!g_attrs[t][i].key) { g_attrs[t][i].key = k; g_attr_len[t]++; }
    g_attrs[t][i].val = val;
    return 0;
}

long long zyl_attr_get(long long t, long long node) {
    if (!node || t < 0 || t >= ZYL_ATTR_TABLES || !g_attr_cap[t]) return 0;
    uintptr_t k = (uintptr_t)(size_t)node;
    size_t m = g_attr_cap[t] - 1;
    size_t i = zyl_span_hash(k) & m;
    while (g_attrs[t][i].key) {
        if (g_attrs[t][i].key == k) return g_attrs[t][i].val;
        i = (i + 1) & m;
    }
    return 0;
}

long long zyl_attr_clear(long long t) {
    if (t < 0 || t >= ZYL_ATTR_TABLES || !g_attr_cap[t]) return 0;
    memset(g_attrs[t], 0, g_attr_cap[t] * sizeof(ZylAttrSlot));
    g_attr_len[t] = 0;
    return 0;
}

/* Union-find over abstract object classes, for region inference
   (compiler/region_inference). Each class carries a level: 0 local,
   1 result, 2 heap. A union keeps the higher level; raising never lowers.
   One table, reset per function; compiler-internal, single-threaded. */
static long long* g_uf_parent = 0;
static long long* g_uf_level = 0;
static long long g_uf_len = 0, g_uf_cap = 0;

long long zyl_uf_reset(void) { g_uf_len = 0; return 0; }

long long zyl_uf_new(long long level) {
    if (g_uf_len == g_uf_cap) {
        long long nc = g_uf_cap ? g_uf_cap * 2 : 4096;
        long long* np = (long long*)realloc(g_uf_parent, (size_t)nc * sizeof(long long));
        long long* nl = (long long*)realloc(g_uf_level, (size_t)nc * sizeof(long long));
        if (!np || !nl) zyl_arena_oom((size_t)nc * 16, "union-find table");
        g_uf_parent = np;
        g_uf_level = nl;
        g_uf_cap = nc;
    }
    g_uf_parent[g_uf_len] = g_uf_len;
    g_uf_level[g_uf_len] = level;
    return g_uf_len++;
}

long long zyl_uf_find(long long a) {
    if (a < 0 || a >= g_uf_len) return a;
    long long root = a;
    while (g_uf_parent[root] != root) root = g_uf_parent[root];
    while (g_uf_parent[a] != root) {
        long long next = g_uf_parent[a];
        g_uf_parent[a] = root;
        a = next;
    }
    return root;
}

/* The lower id becomes the root, so the result does not depend on
   anything but the order of calls. */
long long zyl_uf_union(long long a, long long b) {
    long long ra = zyl_uf_find(a), rb = zyl_uf_find(b);
    if (ra < 0 || rb < 0 || ra >= g_uf_len || rb >= g_uf_len) return ra;
    if (ra == rb) return ra;
    long long lo = ra < rb ? ra : rb, hi = ra < rb ? rb : ra;
    if (g_uf_level[hi] > g_uf_level[lo]) g_uf_level[lo] = g_uf_level[hi];
    g_uf_parent[hi] = lo;
    return lo;
}

long long zyl_uf_raise(long long a, long long level) {
    long long r = zyl_uf_find(a);
    if (r < 0 || r >= g_uf_len) return 0;
    if (level > g_uf_level[r]) g_uf_level[r] = level;
    return 0;
}

long long zyl_uf_level(long long a) {
    long long r = zyl_uf_find(a);
    if (r < 0 || r >= g_uf_len) return 2;
    return g_uf_level[r];
}

/* Give `dst` whatever `src` has in table `t`. */
long long zyl_attr_copy(long long t, long long dst, long long src) {
    long long v = zyl_attr_get(t, src);
    if (v) zyl_attr_set(t, dst, v);
    return 0;
}

typedef struct { const char* key; long long val; } ZylSmapSlot;
typedef struct { ZylSmapSlot* slots; size_t cap; size_t len; } ZylSmap;

static size_t zyl_smap_hash(const char* s) {
    uint64_t h = 1469598103934665603ULL;
    for (; *s; s++) { h ^= (unsigned char)*s; h *= 1099511628211ULL; }
    return (size_t)h;
}

long long zyl_smap_new(void) {
    ZylSmap* m = (ZylSmap*)calloc(1, sizeof(ZylSmap));
    return (long long)(size_t)m;
}

static void zyl_smap_grow(ZylSmap* m) {
    size_t ncap = m->cap ? m->cap * 4 : 1024;
    ZylSmapSlot* ns = (ZylSmapSlot*)calloc(ncap, sizeof(ZylSmapSlot));
    if (!ns) return;
    for (size_t i = 0; i < m->cap; i++) {
        if (!m->slots[i].key) continue;
        size_t j = zyl_smap_hash(m->slots[i].key) & (ncap - 1);
        while (ns[j].key) j = (j + 1) & (ncap - 1);
        ns[j] = m->slots[i];
    }
    free(m->slots);
    m->slots = ns;
    m->cap = ncap;
}

/* Keys are copied: a REPL entry's arena (and its strings) is released. */
long long zyl_smap_put(long long mh, long long key, long long val) {
    ZylSmap* m = (ZylSmap*)(size_t)mh;
    const char* k = (const char*)(size_t)key;
    if (!m || !k) return 0;
    if (m->len * 10 >= m->cap * 7) zyl_smap_grow(m);
    if (!m->cap) return 0;
    size_t i = zyl_smap_hash(k) & (m->cap - 1);
    while (m->slots[i].key && strcmp(m->slots[i].key, k) != 0) i = (i + 1) & (m->cap - 1);
    if (!m->slots[i].key) {
        char* copy = strdup(k);
        if (!copy) return 0;
        m->slots[i].key = copy;
        m->len++;
    }
    m->slots[i].val = val;
    return 0;
}

long long zyl_smap_get(long long mh, long long key) {
    ZylSmap* m = (ZylSmap*)(size_t)mh;
    const char* k = (const char*)(size_t)key;
    if (!m || !k || !m->cap) return 0;
    size_t i = zyl_smap_hash(k) & (m->cap - 1);
    while (m->slots[i].key) {
        if (strcmp(m->slots[i].key, k) == 0) return m->slots[i].val;
        i = (i + 1) & (m->cap - 1);
    }
    return 0;
}

/* Whether `key` is present, and the value or a default: the typed API
   (compiler/ffi_sigs) for maps whose values are not Ints, where 0 is not
   a value of the type and so cannot mean "absent". */
long long zyl_smap_has(long long mh, long long key) {
    ZylSmap* m = (ZylSmap*)(size_t)mh;
    const char* k = (const char*)(size_t)key;
    if (!m || !k || !m->cap) return 0;
    size_t i = zyl_smap_hash(k) & (m->cap - 1);
    while (m->slots[i].key) {
        if (strcmp(m->slots[i].key, k) == 0) return 1;
        i = (i + 1) & (m->cap - 1);
    }
    return 0;
}

long long zyl_smap_get_or(long long mh, long long key, long long dflt) {
    ZylSmap* m = (ZylSmap*)(size_t)mh;
    const char* k = (const char*)(size_t)key;
    if (!m || !k || !m->cap) return dflt;
    size_t i = zyl_smap_hash(k) & (m->cap - 1);
    while (m->slots[i].key) {
        if (strcmp(m->slots[i].key, k) == 0) return m->slots[i].val;
        i = (i + 1) & (m->cap - 1);
    }
    return dflt;
}

long long zyl_smap_clear(long long mh) {
    ZylSmap* m = (ZylSmap*)(size_t)mh;
    if (!m) return 0;
    for (size_t i = 0; i < m->cap; i++) free((void*)m->slots[i].key);
    if (m->cap) memset(m->slots, 0, m->cap * sizeof(ZylSmapSlot));
    m->len = 0;
    return 0;
}

typedef struct { long long* data; long long len; long long cap; } ZylWvec;

long long zyl_wvec_new(void) {
    ZylWvec* v = (ZylWvec*)calloc(1, sizeof(ZylWvec));
    return (long long)(size_t)v;
}

/* Appends `x` and returns its index; -1 when memory runs out. */
long long zyl_wvec_push(long long vh, long long x) {
    ZylWvec* v = (ZylWvec*)(size_t)vh;
    if (!v) return -1;
    if (v->len >= v->cap) {
        long long ncap = v->cap ? v->cap * 2 : 4096;
        long long* nd = (long long*)realloc(v->data, (size_t)ncap * sizeof(long long));
        if (!nd) return -1;
        v->data = nd;
        v->cap = ncap;
    }
    v->data[v->len] = x;
    return v->len++;
}

/* Out of range is an error, not 0: a typed vector of ADT values has no
   0 among its values. */
long long zyl_wvec_get(long long vh, long long i) {
    ZylWvec* v = (ZylWvec*)(size_t)vh;
    if (!v || i < 0 || i >= v->len) {
        char* m = (char*)malloc(128);
        snprintf(m, 128, "E_INDEX_OUT_OF_BOUNDS: vector index %lld outside length %lld", i, v ? v->len : 0);
        zyl_panic(m);
    }
    return v->data[i];
}

long long zyl_wvec_set(long long vh, long long i, long long x) {
    ZylWvec* v = (ZylWvec*)(size_t)vh;
    if (!v || i < 0 || i >= v->len) return 0;
    v->data[i] = x;
    return 0;
}

long long zyl_wvec_len(long long vh) {
    ZylWvec* v = (ZylWvec*)(size_t)vh;
    return v ? v->len : 0;
}

long long zyl_wvec_pop(long long vh) {
    ZylWvec* v = (ZylWvec*)(size_t)vh;
    if (!v || v->len <= 0) zyl_panic("E_INDEX_OUT_OF_BOUNDS: pop from an empty vector");
    return v->data[--v->len];
}

long long zyl_wvec_truncate(long long vh, long long n) {
    ZylWvec* v = (ZylWvec*)(size_t)vh;
    if (v && n >= 0 && n < v->len) v->len = n;
    return 0;
}

/* Process-wide instances, created on first use. */
#define ZYL_GLOBAL_HANDLES 8
static long long g_global_wvecs[ZYL_GLOBAL_HANDLES];
static long long g_global_smaps[ZYL_GLOBAL_HANDLES];

long long zyl_wvec_global(long long i) {
    if (i < 0 || i >= ZYL_GLOBAL_HANDLES) return 0;
    if (!g_global_wvecs[i]) g_global_wvecs[i] = zyl_wvec_new();
    return g_global_wvecs[i];
}

long long zyl_smap_global(long long i) {
    if (i < 0 || i >= ZYL_GLOBAL_HANDLES) return 0;
    if (!g_global_smaps[i]) g_global_smaps[i] = zyl_smap_new();
    return g_global_smaps[i];
}

/* Every `.zyl` file under `dir`, recursively, as newline-separated paths
   relative to `dir`, sorted bytewise (so the listing is deterministic).
   Hidden entries are skipped. Returns "" for a missing directory. */
#include <dirent.h>
#include <sys/stat.h>
long long zyl_heap_alloc(long long size);
typedef struct { char** v; size_t n, cap; } ZylPathList;

static void zyl_pl_push(ZylPathList* l, const char* s) {
    if (l->n == l->cap) {
        size_t nc = l->cap ? l->cap * 2 : 64;
        char** nv = (char**)realloc(l->v, nc * sizeof(char*));
        if (!nv) return;
        l->v = nv; l->cap = nc;
    }
    l->v[l->n++] = strdup(s);
}

static int zyl_has_suffix(const char* s, const char* suffixes) {
    /* `suffixes` is a space-separated list, e.g. ".c .h". */
    size_t n = strlen(s);
    const char* p = suffixes;
    while (*p) {
        while (*p == ' ') p++;
        const char* q = p;
        while (*q && *q != ' ') q++;
        size_t k = (size_t)(q - p);
        if (k > 0 && n > k && strncmp(s + n - k, p, k) == 0) return 1;
        p = q;
    }
    return 0;
}

static void zyl_walk_suffix(const char* root, const char* rel, const char* suffixes, ZylPathList* out) {
    char path[4096];
    snprintf(path, sizeof path, "%s%s%s", root, rel[0] ? "/" : "", rel);
    DIR* d = opendir(path);
    if (!d) return;
    struct dirent* e;
    while ((e = readdir(d)) != NULL) {
        if (e->d_name[0] == '.') continue;
        char sub[4096];
        snprintf(sub, sizeof sub, "%s%s%s", rel, rel[0] ? "/" : "", e->d_name);
        char full[8200];
        snprintf(full, sizeof full, "%s/%s", root, sub);
        struct stat st;
        if (stat(full, &st) != 0) continue;
        if (S_ISDIR(st.st_mode)) zyl_walk_suffix(root, sub, suffixes, out);
        else if (zyl_has_suffix(sub, suffixes)) zyl_pl_push(out, sub);
    }
    closedir(d);
}

static void zyl_walk_zyl(const char* root, const char* rel, ZylPathList* out) {
    char path[4096];
    snprintf(path, sizeof path, "%s%s%s", root, rel[0] ? "/" : "", rel);
    DIR* d = opendir(path);
    if (!d) return;
    struct dirent* e;
    while ((e = readdir(d)) != NULL) {
        if (e->d_name[0] == '.') continue;
        char sub[4096];
        snprintf(sub, sizeof sub, "%s%s%s", rel, rel[0] ? "/" : "", e->d_name);
        char full[8200];
        snprintf(full, sizeof full, "%s/%s", root, sub);
        struct stat st;
        if (stat(full, &st) != 0) continue;
        if (S_ISDIR(st.st_mode)) zyl_walk_zyl(root, sub, out);
        else {
            size_t n = strlen(sub);
            if (n > 4 && strcmp(sub + n - 4, ".zyl") == 0) zyl_pl_push(out, sub);
        }
    }
    closedir(d);
}

static int zyl_pl_cmp(const void* a, const void* b) {
    return strcmp(*(char* const*)a, *(char* const*)b);
}

static long long zyl_pl_join(ZylPathList l);

long long zyl_list_zyl_files(long long dir) {
    ZylPathList l = {0};
    if (dir) zyl_walk_zyl((const char*)(size_t)dir, "", &l);
    return zyl_pl_join(l);
}

/* Like zyl_list_zyl_files, for any of the space-separated `suffixes`. */
long long zyl_list_files(long long dir, long long suffixes) {
    ZylPathList l = {0};
    if (dir && suffixes) zyl_walk_suffix((const char*)(size_t)dir, "", (const char*)(size_t)suffixes, &l);
    return zyl_pl_join(l);
}

static long long zyl_pl_join(ZylPathList l) {
    qsort(l.v, l.n, sizeof(char*), zyl_pl_cmp);
    size_t total = 1;
    for (size_t i = 0; i < l.n; i++) total += strlen(l.v[i]) + 1;
    char* buf = (char*)(size_t)zyl_heap_alloc((long long)total);
    if (!buf) return 0;
    buf[0] = 0;
    size_t at = 0;
    for (size_t i = 0; i < l.n; i++) {
        size_t n = strlen(l.v[i]);
        memcpy(buf + at, l.v[i], n);
        at += n;
        buf[at++] = '\n';
        free(l.v[i]);
    }
    buf[at] = 0;
    free(l.v);
    return (long long)(size_t)buf;
}

/* Contracts under the `warn` profile report and continue. */
long long zyl_contract_warn(long long msg) {
    fprintf(stderr, "warning: %s\n", msg ? (const char*)(size_t)msg : "contract violated");
    return 0;
}

/* A recover arm naming an error code matches a message that starts with it. */
long long zyl_err_is(long long msg, long long code) {
    const char* m = (const char*)(size_t)msg;
    const char* c = (const char*)(size_t)code;
    if (!m || !c) return 0;
    size_t n = strlen(c);
    return strncmp(m, c, n) == 0 && (m[n] == ':' || m[n] == 0) ? 1 : 0;
}

/* Top-level `def` values, keyed by canonical key. A cell is set once, by
   the def's getter on first use (the init function runs them in order). */
static long long g_def_cells = 0;

/* Every cached `def` value dropped, so the next use recomputes it (the
   REPL runs this before each entry: a `:reset` must not leave old values). */
long long zyl_global_clear(void) {
    if (g_def_cells) zyl_smap_clear(g_def_cells);
    return 0;
}

/* The same for programs the interpreter runs, in a table of their own:
   an interpreted program must neither see nor clear the `def`s of the
   compiled program running it (the REPL's own compiler tables are defs). */
static long long g_idef_cells = 0;

long long zyl_iglobal_clear(void) {
    if (g_idef_cells) zyl_smap_clear(g_idef_cells);
    return 0;
}

long long zyl_iglobal_ready(long long key) {
    return g_idef_cells && zyl_smap_get(g_idef_cells, key) ? 1 : 0;
}

long long zyl_iglobal_get(long long key) {
    long long* cell = (long long*)(size_t)(g_idef_cells ? zyl_smap_get(g_idef_cells, key) : 0);
    return cell ? *cell : 0;
}

long long zyl_iglobal_put(long long key, long long val) {
    if (!g_idef_cells) g_idef_cells = zyl_smap_new();
    long long* cell = (long long*)malloc(sizeof(long long));
    if (!cell) return val;
    *cell = val;
    zyl_smap_put(g_idef_cells, key, (long long)(size_t)cell);
    return val;
}

/* The REPL's prompt `def`s, by name: the value each one was bound to. */
static long long g_repl_globals = 0;

long long zyl_repl_global_set(long long name, long long word) {
    if (!g_repl_globals) g_repl_globals = zyl_smap_new();
    zyl_smap_put(g_repl_globals, name, word);
    return 0;
}

long long zyl_repl_global_get(long long name) {
    return g_repl_globals ? zyl_smap_get(g_repl_globals, name) : 0;
}

long long zyl_global_ready(long long key) {
    return g_def_cells && zyl_smap_get(g_def_cells, key) ? 1 : 0;
}

long long zyl_global_get(long long key) {
    long long* cell = (long long*)(size_t)(g_def_cells ? zyl_smap_get(g_def_cells, key) : 0);
    return cell ? *cell : 0;
}

long long zyl_global_put(long long key, long long val) {
    if (!g_def_cells) g_def_cells = zyl_smap_new();
    long long* cell = (long long*)malloc(sizeof(long long));
    if (!cell) return val;
    *cell = val;
    zyl_smap_put(g_def_cells, key, (long long)(size_t)cell);
    return val;
}

/* Registers a source file and returns its id; re-registering the same path
 * returns the existing id so a module parsed twice keeps one entry. */
long long zyl_source_register(long long path, long long text) {
    const char* p = (const char*)(size_t)path;
    const char* t = (const char*)(size_t)text;
    if (!p) p = "<input>";
    if (!t) t = "";
    /* A path seen before keeps its id; its text is replaced when it
       changed, since the REPL (every entry is "<repl>") and the language
       server (an edited document) register new text under an old path,
       and a diagnostic must quote the text it was computed from. */
    for (int i = 0; i < g_src_file_count; i++)
        if (strcmp(g_src_files[i].path, p) == 0) {
            if (strcmp(g_src_files[i].text ? g_src_files[i].text : "", t) != 0) {
                free(g_src_files[i].text);
                g_src_files[i].text = strdup(t);
                g_src_files[i].len = g_src_files[i].text ? strlen(g_src_files[i].text) : 0;
            }
            return i;
        }
    if (g_src_file_count >= ZYL_MAX_SRC_FILES) return -1;
    int id = g_src_file_count++;
    g_src_files[id].path = strdup(p);
    g_src_files[id].text = strdup(t);
    g_src_files[id].len = g_src_files[id].text ? strlen(g_src_files[id].text) : 0;
    return id;
}

long long zyl_source_path(long long fid) {
    if (fid < 0 || fid >= g_src_file_count) return (long long)(size_t)"<input>";
    return (long long)(size_t)g_src_files[fid].path;
}

/* 1-based line containing `off`; 0 when the offset or file is unknown. */
long long zyl_span_line(long long fid, long long off) {
    if (fid < 0 || fid >= g_src_file_count || off < 0) return 0;
    ZylSrcFile* f = &g_src_files[fid];
    if (!f->text || (size_t)off > f->len) return 0;
    long long line = 1;
    for (long long i = 0; i < off; i++) if (f->text[i] == '\n') line++;
    return line;
}

/* 1-based column of `off` within its line; 0 when unknown. */
long long zyl_span_col(long long fid, long long off) {
    if (fid < 0 || fid >= g_src_file_count || off < 0) return 0;
    ZylSrcFile* f = &g_src_files[fid];
    if (!f->text || (size_t)off > f->len) return 0;
    long long start = off;
    while (start > 0 && f->text[start - 1] != '\n') start--;
    return off - start + 1;
}

/* The whole source line containing `off`, newline stripped. malloc'd and
 * never freed on purpose: the only caller is a diagnostic, and the process
 * exits moments later. Empty string when the location is unknown. */
long long zyl_span_line_text(long long fid, long long off) {
    static const char empty[] = "";
    if (fid < 0 || fid >= g_src_file_count || off < 0) return (long long)(size_t)empty;
    ZylSrcFile* f = &g_src_files[fid];
    if (!f->text || (size_t)off > f->len) return (long long)(size_t)empty;
    long long start = off;
    while (start > 0 && f->text[start - 1] != '\n') start--;
    long long end = off;
    while ((size_t)end < f->len && f->text[end] != '\n') end++;
    size_t n = (size_t)(end - start);
    char* buf = (char*)malloc(n + 1);
    if (!buf) return (long long)(size_t)empty;
    memcpy(buf, f->text + start, n);
    buf[n] = 0;
    return (long long)(size_t)buf;
}

/* Diagnostic snippet: at most ZYL_SNIP_WIDTH bytes of the line around
 * `off`, "..."-marked where cut, so a huge line cannot balloon a report. */
#define ZYL_SNIP_WIDTH 120

static int zyl_snip_window(long long fid, long long off, long long* ws, long long* we, int* pre, int* post) {
    if (fid < 0 || fid >= g_src_file_count || off < 0) return 0;
    ZylSrcFile* f = &g_src_files[fid];
    if (!f->text || (size_t)off > f->len) return 0;
    long long start = off, end = off;
    while (start > 0 && f->text[start - 1] != '\n') start--;
    while ((size_t)end < f->len && f->text[end] != '\n') end++;
    long long s = start, e = end;
    if (end - start > ZYL_SNIP_WIDTH) {
        s = off - ZYL_SNIP_WIDTH / 2;
        if (s < start) s = start;
        e = s + ZYL_SNIP_WIDTH;
        if (e > end) { e = end; s = end - ZYL_SNIP_WIDTH; }
    }
    *ws = s; *we = e; *pre = s > start; *post = e < end;
    return 1;
}

long long zyl_span_snippet(long long fid, long long off) {
    static const char empty[] = "";
    long long s, e; int pre, post;
    if (!zyl_snip_window(fid, off, &s, &e, &pre, &post)) return (long long)(size_t)empty;
    size_t n = (size_t)(e - s);
    char* buf = (char*)malloc(n + 7);
    if (!buf) return (long long)(size_t)empty;
    size_t j = 0;
    if (pre) { memcpy(buf, "...", 3); j = 3; }
    memcpy(buf + j, g_src_files[fid].text + s, n);
    j += n;
    if (post) { memcpy(buf + j, "...", 3); j += 3; }
    buf[j] = 0;
    return (long long)(size_t)buf;
}

/* 1-based caret column of `off` within zyl_span_snippet's text. */
long long zyl_span_snippet_col(long long fid, long long off) {
    long long s, e; int pre, post;
    if (!zyl_snip_window(fid, off, &s, &e, &pre, &post)) return 0;
    return off - s + 1 + (pre ? 3 : 0);
}

/* Inverse of zyl_span_line/zyl_span_col: sexp_balance tracks 1-based
 * line/col directly, so its results come back here to be rendered. */
long long zyl_span_offset_at(long long fid, long long line, long long col) {
    if (fid < 0 || fid >= g_src_file_count || line < 1 || col < 1) return -1;
    ZylSrcFile* f = &g_src_files[fid];
    if (!f->text) return -1;
    size_t i = 0;
    for (long long l = 1; l < line; l++) {
        const char* nl = strchr(f->text + i, '\n');
        if (!nl) return -1;
        i = (size_t)(nl - f->text) + 1;
    }
    size_t off = i + (size_t)(col - 1);
    return off <= f->len ? (long long)off : (long long)f->len;
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

/* ==========================================================================
   Frame regions (docs/regions-design.md).

   A region is a four-word header the compiler reserves in a function's
   frame. Values the compiler proves do not outlive the call (level L) are
   allocated in it; values that may reach the call's result (level R) go
   into the region the caller chose for that result, which the caller
   passes in zyl_cur_region; everything else (level H) goes to the heap.

   Blocks come from a per-thread pool carved out of mmap'd chunks. The
   chunks sit far above 4 GiB, which matters: zyl_callN and generated code
   tell a closure object from a code address partly by where it lies.
   ========================================================================== */
/* Block size classes: a region's first block is small, and each further
   block is the next class up, so a deep recursion whose every frame keeps
   a little local data costs about 1 KiB a frame, not a whole block. */
#define ZYL_RCLASSES 4
static const size_t g_rclass_size[ZYL_RCLASSES] = { 1024, 4096, 16384, 65536 };
#define ZYL_RCHUNK_BYTES (1024 * 1024)

typedef struct ZylRBlock {
    struct ZylRBlock* next;
    size_t size;          /* bytes, header included */
    int big;              /* its own mapping, unmapped on release */
    int cls;              /* size class, when not big */
} ZylRBlock;

typedef struct ZylRegion {
    struct ZylRegion* prev;
    char* bump;
    char* end;
    ZylRBlock* blocks;   /* low bit set: a with-region scope, whose kind,
                            block, align, limit and bytes used follow in
                            the next five words of its header */
} ZylRegion;

/* The four-word layout is shared with generated code (codegen.zyl's
   cg-region-prologue), including code from the committed seed, so a
   scope is marked in `blocks` rather than by a fifth word. */
#define ZYL_RBLOCKS(r) ((ZylRBlock*)((uintptr_t)(r)->blocks & ~(uintptr_t)1))
#define ZYL_RSCOPED(r) (((uintptr_t)(r)->blocks & 1) != 0)
#define ZYL_RSET_BLOCKS(r, b) ((r)->blocks = (ZylRBlock*)((uintptr_t)(b) | ((uintptr_t)(r)->blocks & 1)))
#define ZYL_RPOLICY(r) ((long long*)(r) + 4)


__thread ZylRegion* zyl_cur_region = 0;
__thread ZylRegion* zyl_region_top = 0;
static __thread ZylRBlock* g_rpool[ZYL_RCLASSES];
static long long g_region_live = 0;   /* bytes in blocks handed to regions */

static void* zyl_rmap(size_t n) {
    if (!zyl_arena_charge(n)) zyl_arena_oom(n, "memory budget exhausted");
    void* p = mmap(NULL, n, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (p == MAP_FAILED) {
        zyl_arena_refund(n);
        zyl_arena_oom(n, "mmap failed for a region block");
    }
    return p;
}

/* A block for a region that already holds `nblocks` blocks. */
static ZylRBlock* zyl_rblock_get(size_t need, int nblocks) {
    size_t hdr = sizeof(ZylRBlock);
    int cls = nblocks < ZYL_RCLASSES ? nblocks : ZYL_RCLASSES - 1;
    while (cls < ZYL_RCLASSES && need + hdr > g_rclass_size[cls]) cls++;
    if (cls >= ZYL_RCLASSES) {
        size_t n = (need + hdr + 4095) & ~(size_t)4095;
        ZylRBlock* b = (ZylRBlock*)zyl_rmap(n);
        b->size = n;
        b->big = 1;
        b->cls = -1;
        b->next = 0;
        return b;
    }
    if (!g_rpool[cls]) {
        size_t sz = g_rclass_size[cls];
        char* c = (char*)zyl_rmap(ZYL_RCHUNK_BYTES);
        for (size_t off = 0; off + sz <= ZYL_RCHUNK_BYTES; off += sz) {
            ZylRBlock* b = (ZylRBlock*)(c + off);
            b->size = sz;
            b->big = 0;
            b->cls = cls;
            b->next = g_rpool[cls];
            g_rpool[cls] = b;
        }
    }
    ZylRBlock* b = g_rpool[cls];
    g_rpool[cls] = b->next;
    b->next = 0;
    return b;
}

enum { ZYL_RP_KIND, ZYL_RP_BLOCK, ZYL_RP_ALIGN, ZYL_RP_LIMIT, ZYL_RP_USED };

/* A with-region scope (compiler/region_inference, the region extension
   registry): kind 1 arena (blocks of `block` bytes, at most `limit` in
   all, 0 meaning no limit), kind 2 fixed (one block of `block` bytes).
   Every decision depends only on the sequence of requests: blocks are
   page-aligned, so alignment padding is the same on every run, and the
   limit counts requested bytes plus that padding. */
static long long zyl_policy_alloc(ZylRegion* r, long long size) {
    long long* p = ZYL_RPOLICY(r);
    size_t align = (size_t)p[ZYL_RP_ALIGN];
    size_t payload = (size_t)((size + 7) / 8) * 8;
    for (int attempt = 0; attempt < 2; attempt++) {
        if (r->bump) {
            uintptr_t at = ((uintptr_t)r->bump + 8 + align - 1) & ~(uintptr_t)(align - 1);
            char* end = (char*)at + payload;
            if (end <= r->end) {
                long long used = p[ZYL_RP_USED] + (long long)(end - r->bump);
                /* fixed: the limit is its :size, so a block rounded up to
                   whole pages still holds exactly that many bytes */
                if (p[ZYL_RP_LIMIT] > 0 && used > p[ZYL_RP_LIMIT]) break;
                p[ZYL_RP_USED] = used;
                r->bump = end;
                *(long long*)(at - 8) = (long long)(payload / 8);
                return (long long)at;
            }
        }
        if (p[ZYL_RP_KIND] == 2 && ZYL_RBLOCKS(r)) break;
        size_t want = (size_t)p[ZYL_RP_BLOCK];
        size_t need = payload + 8 + align + sizeof(ZylRBlock);
        if (want < need) want = need;
        if (p[ZYL_RP_KIND] == 2) want = (size_t)p[ZYL_RP_BLOCK] + 8 + align + sizeof(ZylRBlock);
        want = (want + 4095) & ~(size_t)4095;
        ZylRBlock* b = (ZylRBlock*)zyl_rmap(want);
        b->size = want;
        b->big = 1;
        b->next = ZYL_RBLOCKS(r);
        ZYL_RSET_BLOCKS(r, b);
        __atomic_add_fetch(&g_region_live, (long long)want, __ATOMIC_RELAXED);
        r->bump = (char*)b + sizeof(ZylRBlock);
        r->end = (char*)b + want;
    }
    char* m = (char*)malloc(160);
    snprintf(m, 160, "E_REGION_EXHAUSTED: %s region of %lld bytes is full",
             p[ZYL_RP_KIND] == 2 ? "fixed" : "arena",
             p[ZYL_RP_KIND] == 2 ? p[ZYL_RP_BLOCK] : p[ZYL_RP_LIMIT]);
    zyl_panic(m);
    return 0;
}

/* Allocate `size` bytes in region `rp` (0: the heap), with the hidden
   qword-count header zyl_heap_alloc writes, so zyl_variant_eq and the
   value helpers read region blocks the same way. */
long long zyl_ralloc(long long size, long long rp) {
    ZylRegion* r = (ZylRegion*)(size_t)rp;
    if (!r) return zyl_heap_alloc(size);
    if (size <= 0) return 0;
    if (ZYL_RSCOPED(r)) return zyl_policy_alloc(r, size);
    if (size > (1LL << 48)) {
        fprintf(stderr, "zyl_ralloc: size too large size=%lld\n", size);
        return 0;
    }
    size_t need = (size_t)((size + 7) / 8) * 8 + 8;
    if (!r->bump || (size_t)(r->end - r->bump) < need) {
        int nb = 0;
        for (ZylRBlock* q = ZYL_RBLOCKS(r); q && nb < ZYL_RCLASSES; q = q->next) nb++;
        ZylRBlock* b = zyl_rblock_get(need, nb);
        b->next = ZYL_RBLOCKS(r);
        ZYL_RSET_BLOCKS(r, b);
        __atomic_add_fetch(&g_region_live, (long long)b->size, __ATOMIC_RELAXED);
        r->bump = (char*)b + sizeof(ZylRBlock);
        r->end = (char*)b + b->size;
    }
    char* base = r->bump;
    r->bump += need;
    *(long long*)base = (long long)((size + 7) / 8);
    return (long long)(size_t)(base + 8);
}

static void zyl_region_free_blocks(ZylRegion* r) {
    ZylRBlock* b = ZYL_RBLOCKS(r);
    while (b) {
        ZylRBlock* next = b->next;
        __atomic_sub_fetch(&g_region_live, (long long)b->size, __ATOMIC_RELAXED);
        if (b->big) {
            size_t n = b->size;
            munmap(b, n);
            zyl_arena_refund(n);
        } else {
            /* Pool blocks are reused, never unmapped: a chunk is one
               mapping, so its blocks cannot be returned one by one. */
            b->next = g_rpool[b->cls];
            g_rpool[b->cls] = b;
        }
        b = next;
    }
    ZYL_RSET_BLOCKS(r, 0);
    r->bump = 0;
    r->end = 0;
}

/* Function entry: push the frame's region on this thread's chain. */
void zyl_region_enter(long long rp) {
    ZylRegion* r = (ZylRegion*)(size_t)rp;
    r->prev = zyl_region_top;
    r->bump = 0;
    r->end = 0;
    r->blocks = 0;
    zyl_region_top = r;
}

/* Enter a with-region scope; `hp` is a ten-word header in the frame. */
void zyl_region_scope_enter(long long hp, long long kind, long long block,
                            long long align, long long limit) {
    ZylRegion* r = (ZylRegion*)(size_t)hp;
    long long* p = ZYL_RPOLICY(r);
    r->prev = zyl_region_top;
    r->bump = 0;
    r->end = 0;
    r->blocks = (ZylRBlock*)(uintptr_t)1;
    p[ZYL_RP_KIND] = kind;
    p[ZYL_RP_BLOCK] = block;
    p[ZYL_RP_ALIGN] = align < 8 ? 8 : align;
    p[ZYL_RP_LIMIT] = limit;
    p[ZYL_RP_USED] = 0;
    zyl_region_top = r;
}

/* Release a frame region's blocks; generated code pops the chain and
   clears zyl_cur_region inline, calling this only when blocks were
   taken. */
void zyl_region_free(long long rp) {
    ZylRegion* r = (ZylRegion*)(size_t)rp;
    if (ZYL_RBLOCKS(r)) zyl_region_free_blocks(r);
}

/* Function exit (and before a tail jump): pop and release. The result
   region pointer must never name a dead frame, so it is cleared if it
   names this one. */
void zyl_region_exit(long long rp) {
    ZylRegion* r = (ZylRegion*)(size_t)rp;
    if (ZYL_RBLOCKS(r)) zyl_region_free_blocks(r);
    zyl_region_top = r->prev;
    if (zyl_cur_region == r) zyl_cur_region = 0;
}

/* Unwinding (a caught panic, a failed test): release every region pushed
   after `mark`, the chain top when the handler was installed. */
void zyl_region_unwind(void* mark) {
    ZylRegion* stop = (ZylRegion*)mark;
    while (zyl_region_top && zyl_region_top != stop) {
        ZylRegion* r = zyl_region_top;
        if (ZYL_RBLOCKS(r)) zyl_region_free_blocks(r);
        zyl_region_top = r->prev;
    }
    zyl_cur_region = 0;
}

void* zyl_region_mark(void) { return (void*)zyl_region_top; }

/* Bytes currently held by live regions, across all threads. */
long long zyl_region_live_bytes(void) {
    return __atomic_load_n(&g_region_live, __ATOMIC_RELAXED);
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

static long long* zyl_words_data(long long h);
long long zyl_words_len(long long h);
static void zyl_words_oob(const char* who, long long i, long long len);
/* Pack 16 one-byte-per-word Ints into a 16-byte block. */
static void zyl_words_to_block(long long base, unsigned char* out) {
    if (zyl_words_len(base) < 16) zyl_words_oob("aes block", 15, zyl_words_len(base));
    const long long* w = zyl_words_data(base);
    for (int i = 0; i < 16; i++) out[i] = (unsigned char)(w[i] & 0xff);
}

static void zyl_block_to_words(const unsigned char* in, long long base) {
    if (zyl_words_len(base) < 16) zyl_words_oob("aes block", 15, zyl_words_len(base));
    long long* w = zyl_words_data(base);
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
    if (keybytes < 0 || zyl_words_len(keybase) < keybytes) zyl_words_oob("aes key", keybytes - 1, zyl_words_len(keybase));
    long long* kw = zyl_words_data(keybase);
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
    long long* out = zyl_words_data(base);
    if (n > zyl_words_len(base)) zyl_words_oob("random-words", n - 1, zyl_words_len(base));
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

long long zyl_actor_terminate(long long actor_id) {
    if (!g_system.initialized || actor_id < 0 || actor_id >= ZYL_MAX_ACTORS || actor_id >= g_system.next_id) {
        return 0;
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
    return 0;
}

long long zyl_actor_wait(long long actor_id) {
    if (!g_system.initialized || actor_id < 0 || actor_id >= ZYL_MAX_ACTORS || actor_id >= g_system.next_id) {
        return 0;
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
    return 0;
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
static void* g_test_region_mark = 0;

void zyl_register_test(const char* name, int (*fn)(void)) {
    if (g_test_count < ZYL_MAX_TESTS) {
        strncpy(g_tests[g_test_count].name, name, ZYL_TEST_NAME_LEN - 1);
        g_tests[g_test_count].name[ZYL_TEST_NAME_LEN - 1] = '\0';
        g_tests[g_test_count].fn = fn;
        g_test_count++;
    }
}

long long zyl_diag_json(void);
long long zyl_json_quote(long long s);

/* JSON-mode panic: a message err-diag already rendered as JSON passes
 * through; a bare "E_CODE: text" is wrapped with its code split off. */
static void zyl_panic_json(const char* msg) {
    if (msg[0] == '{') { fprintf(stderr, "%s\n", msg); return; }
    size_t k = 0;
    if ((msg[0] == 'E' || msg[0] == 'W') && msg[1] == '_') {
        k = 2;
        while ((msg[k] >= 'A' && msg[k] <= 'Z') || (msg[k] >= '0' && msg[k] <= '9') || msg[k] == '_') k++;
        if (msg[k] != ':') k = 0;
    }
    char code[128] = "";
    const char* text = msg;
    if (k && k < sizeof(code)) {
        memcpy(code, msg, k);
        code[k] = 0;
        text = msg + k + 1;
        while (*text == ' ') text++;
    }
    fprintf(stderr,
        "{\"severity\":\"error\",\"code\":%s,\"message\":%s,\"file\":\"\",\"line\":0,\"column\":0,\"labels\":[],\"help\":\"\"}\n",
        (const char*)(size_t)zyl_json_quote((long long)(size_t)code),
        (const char*)(size_t)zyl_json_quote((long long)(size_t)text));
}

void zyl_panic(const char* msg) {
    if (g_try_top) {
        struct ZylTryFrame* f = g_try_top;
        g_try_top = f->prev;
        f->msg = msg ? msg : "error";
        zyl_region_unwind(f->region_mark);
        longjmp(f->buf, 1);
    }
    if (g_in_test && !zyl_ffi_on_worker()) {
        /* Panic inside a test: unwind to the runner and mark it failed
         * instead of killing the whole process. */
        g_in_test = 0;
        zyl_region_unwind(g_test_region_mark);
        longjmp(g_test_jmp, 1);
    }
    if (zyl_diag_json()) {
        zyl_panic_json(msg ? msg : "assertion failed");
        exit(1);
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

        g_test_region_mark = zyl_region_mark();
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
    long long buf = ZYL_RESULT_ALLOC(count + 1);
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
    /* A fresh heap string: a reused buffer made the next call overwrite
     * the last result, and passing a result back in (workspace.zyl walks
     * upward this way) copied the buffer onto itself. */
    char* out = (char*)(size_t)zyl_heap_alloc((long long)len + 1);
    if (!out) return 0;
    memcpy(out, p, len);
    out[len] = 0;
    return (long long)(size_t)out;
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

/* Diagnostic format: 1 = JSON (one object per diagnostic), 0 = text.
 * Set only by the compiler (--error-format=json); programs keep text. */
static int g_diag_json = 0;

long long zyl_diag_json(void) {
    return g_diag_json;
}

long long zyl_diag_json_set(long long on) {
    g_diag_json = on ? 1 : 0;
    return 0;
}

/* Warning sink: stderr by default; a capturing caller (the LSP) collects
 * them instead and drains the buffer with zyl_warn_take. */
static char* g_warn_buf = NULL;
static size_t g_warn_len = 0, g_warn_cap = 0;
static int g_warn_capture = 0;

long long zyl_warn_capture(long long on) {
    g_warn_capture = on ? 1 : 0;
    g_warn_len = 0;
    return 0;
}

long long zyl_warn_emit(long long msg) {
    const char* m = msg ? (const char*)(size_t)msg : "";
    size_t n = strlen(m);
    if (!g_warn_capture) {
        ssize_t w = write(2, m, n);
        w = write(2, "\n", 1);
        (void)w;
        return 0;
    }
    if (g_warn_len + n + 2 > g_warn_cap) {
        size_t nc = g_warn_cap ? g_warn_cap : 1024;
        while (g_warn_len + n + 2 > nc) nc *= 2;
        char* nb = (char*)realloc(g_warn_buf, nc);
        if (!nb) return 0;
        g_warn_buf = nb;
        g_warn_cap = nc;
    }
    memcpy(g_warn_buf + g_warn_len, m, n);
    g_warn_len += n;
    g_warn_buf[g_warn_len++] = '\n';
    g_warn_buf[g_warn_len] = 0;
    return 0;
}

/* Captured warnings, newline-separated; the buffer is reset. */
long long zyl_warn_take(void) {
    char* out = (char*)malloc(g_warn_len + 1);
    if (!out) return (long long)(size_t)"";
    if (g_warn_len) memcpy(out, g_warn_buf, g_warn_len);
    out[g_warn_len] = 0;
    g_warn_len = 0;
    return (long long)(size_t)out;
}

/* `s` as a quoted JSON string literal (malloc'd). */
long long zyl_json_quote(long long s) {
    const unsigned char* p = s ? (const unsigned char*)(size_t)s : (const unsigned char*)"";
    size_t n = strlen((const char*)p);
    char* out = (char*)malloc(n * 6 + 3);
    if (!out) return (long long)(size_t)"\"\"";
    size_t j = 0;
    out[j++] = '"';
    for (size_t i = 0; i < n; i++) {
        unsigned char c = p[i];
        if (c == '"' || c == '\\') { out[j++] = '\\'; out[j++] = (char)c; }
        else if (c == '\n') { out[j++] = '\\'; out[j++] = 'n'; }
        else if (c == '\t') { out[j++] = '\\'; out[j++] = 't'; }
        else if (c == '\r') { out[j++] = '\\'; out[j++] = 'r'; }
        else if (c < 0x20) { j += (size_t)sprintf(out + j, "\\u%04x", c); }
        else out[j++] = (char)c;
    }
    out[j++] = '"';
    out[j] = 0;
    return (long long)(size_t)out;
}

long long zyl_chdir(long long path) {
    return (long long)chdir((const char*)(size_t)path);
}

long long zyl_getcwd(void) {
    char buf[4096];
    if (getcwd(buf, sizeof(buf)) == NULL) {
        return 0;
    }
    size_t n = strlen(buf);
    char* out = (char*)(size_t)zyl_heap_alloc((long long)n + 1);
    if (!out) return 0;
    memcpy(out, buf, n + 1);
    return (long long)(size_t)out;
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
    const char* tmpdir = getenv("TMPDIR");
    const char* tmpl = tmpdir ? tmpdir : "/tmp";
    char script_path[512];
    snprintf(script_path, sizeof(script_path), "%s/zyl_link_XXXXXX", tmpl);
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

/* Same as zyl_cc_compile, but with the toolchain's own stdout and
   stderr redirected into `logpath`. The REPL needs this: a linker
   message belongs in a diagnostic the REPL formats and prints, not
   interleaved raw into the session transcript at whatever moment the
   child happens to write it. Returns the child's exit status, or -1. */
long long zyl_cc_compile_log(long long path, long long logpath) {
    const char* asm_path = (const char*)(size_t)path;
    const char* log_path = (const char*)(size_t)logpath;
    if (!asm_path || !log_path) return -1;
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
    posix_spawn_file_actions_t fa;
    if (posix_spawn_file_actions_init(&fa) != 0) return -1;
    posix_spawn_file_actions_addopen(&fa, STDOUT_FILENO, log_path,
                                     O_WRONLY | O_CREAT | O_TRUNC, 0644);
    posix_spawn_file_actions_adddup2(&fa, STDOUT_FILENO, STDERR_FILENO);
    char* argv[] = {
        (char*)"cc", (char*)"-no-pie", (char*)asm_path, (char*)"actor_runtime.c",
        (char*)"-o", out_path, (char*)"-lpthread", NULL
    };
    pid_t pid;
    int rc = posix_spawnp(&pid, "cc", &fa, NULL, argv, environ);
    posix_spawn_file_actions_destroy(&fa);
    if (rc != 0) return -1;
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

/* ── Interactive terminal primitives (REPL line editor) ─────────────────
   The REPL's line editor is written in Zyl (stdlib/repl/line_editor.zyl)
   and needs exactly four things the language cannot express on its own:
   putting the terminal into raw mode, reading one byte at a time with an
   optional timeout (an escape sequence has to be distinguished from a
   lone ESC by whether more bytes follow immediately), asking the kernel
   how wide the window is, and guaranteeing the terminal is restored even
   if the process dies somewhere the editor's own cleanup never runs.

   No readline/libedit dependency: those pull an external library (GPL,
   in readline's case) into every binary that links this runtime, and the
   editor needs key handling this runtime can hand it directly. */
#include <termios.h>
#include <sys/ioctl.h>
#include <poll.h>

static struct termios g_term_saved;
static int g_term_saved_valid = 0;
static int g_term_raw_active = 0;

/* Restores the terminal from whatever exit path the process takes --
   a normal return, exit(), or zyl_f_error/zyl_panic's own exit(1).
   Without this, a REPL that dies mid-edit leaves the user's shell in
   raw mode with no echo, which looks exactly like a hung terminal. */
static void zyl_term_restore_atexit(void) {
    if (g_term_raw_active && g_term_saved_valid) {
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &g_term_saved);
        g_term_raw_active = 0;
        /* Leave bracketed paste and any pending SGR behind us. */
        (void)!write(STDOUT_FILENO, "\033[?2004l\033[0m", 12);
    }
}

/* 1 if fd is a terminal. A REPL reading from a pipe must not try to
   raw-mode it: there is nothing to put in raw mode, and the editor's
   redraw escapes would end up in the captured output. */
long long zyl_term_is_tty(long long fd) {
    return isatty((int)fd) ? 1 : 0;
}

/* Raw mode: no canonical line buffering, no echo, no signal generation
   (so Ctrl-C arrives as byte 3 for the editor to interpret rather than
   killing the REPL), no XON/XOFF (so Ctrl-S is a key, not a terminal
   freeze). Output post-processing (OPOST) stays ON: the editor emits
   "\r\n" itself, and turning OPOST off gains nothing while making every
   other library's printf output in the same process misalign.
   VMIN=1/VTIME=0 makes a read block until exactly one byte is there.
   Returns 0 on success, -1 if stdin is not a terminal or tcsetattr
   fails. Idempotent: calling it twice does not overwrite the saved
   original with the raw settings. */
long long zyl_term_raw_on(void) {
    struct termios raw;
    if (!isatty(STDIN_FILENO)) return -1;
    if (g_term_raw_active) return 0;
    if (!g_term_saved_valid) {
        if (tcgetattr(STDIN_FILENO, &g_term_saved) != 0) return -1;
        g_term_saved_valid = 1;
        atexit(zyl_term_restore_atexit);
    }
    raw = g_term_saved;
    raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
    raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
    raw.c_cc[VMIN] = 1;
    raw.c_cc[VTIME] = 0;
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) != 0) return -1;
    g_term_raw_active = 1;
    return 0;
}

long long zyl_term_raw_off(void) {
    if (!g_term_raw_active || !g_term_saved_valid) return 0;
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &g_term_saved) != 0) return -1;
    g_term_raw_active = 0;
    return 0;
}

/* One byte from stdin. -1 means real EOF (Ctrl-D on an empty line at the
   tty, or the end of a piped script); -2 means the read was interrupted
   and the caller should simply ask again. Both are outside 0..255, so
   neither can collide with a real byte. */
long long zyl_term_read_byte(void) {
    unsigned char c;
    for (;;) {
        ssize_t n = read(STDIN_FILENO, &c, 1);
        if (n == 1) return (long long)c;
        if (n == 0) return -1;
        if (errno == EINTR) return -2;
        return -1;
    }
}

/* Same, but gives up after `ms` milliseconds and returns -3. This is
   what makes a bare ESC keypress distinguishable from the start of an
   arrow key's "\033[A": a real escape sequence's remaining bytes are
   already in the buffer, while a lone ESC is followed by nothing. */
long long zyl_term_read_byte_timeout(long long ms) {
    struct pollfd p;
    p.fd = STDIN_FILENO;
    p.events = POLLIN;
    p.revents = 0;
    int r = poll(&p, 1, (int)ms);
    if (r == 0) return -3;
    if (r < 0) return (errno == EINTR) ? -2 : -1;
    return zyl_term_read_byte();
}

/* Window size, for wrapping a long line across rows and for placing the
   cursor after a redraw. 80x24 when the kernel will not say (not a tty,
   or a terminal that does not implement TIOCGWINSZ). */
long long zyl_term_width(void) {
    struct winsize ws;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0 && ws.ws_col > 0)
        return (long long)ws.ws_col;
    return 80;
}

long long zyl_term_height(void) {
    struct winsize ws;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0 && ws.ws_row > 0)
        return (long long)ws.ws_row;
    return 24;
}

/* Write with no trailing newline and no stdio buffering in between.
   The editor redraws by emitting escape sequences that must reach the
   terminal in the same order as any printf output around them, so it
   flushes stdout first and then writes directly. */
long long zyl_term_write(long long s) {
    if (!s) return 0;
    const char* p = (const char*)(size_t)s;
    size_t len = strlen(p);
    size_t off = 0;
    fflush(stdout);
    while (off < len) {
        ssize_t n = write(STDOUT_FILENO, p + off, len - off);
        if (n <= 0) {
            if (n < 0 && errno == EINTR) continue;
            break;
        }
        off += (size_t)n;
    }
    return (long long)off;
}

long long zyl_term_flush(void) {
    fflush(stdout);
    return 0;
}

/* mkdir -p, for the REPL's own state directory (~/.zyl). Returns 0 if
   the directory exists afterwards, -1 otherwise. */
long long zyl_mkdir_p(long long path) {
    const char* p = (const char*)(size_t)path;
    if (!p || !*p) return -1;
    size_t len = strlen(p);
    if (len >= PATH_MAX) return -1;
    char buf[PATH_MAX];
    memcpy(buf, p, len + 1);
    for (size_t i = 1; i < len; i++) {
        if (buf[i] == '/') {
            buf[i] = 0;
            if (mkdir(buf, 0755) != 0 && errno != EEXIST) return -1;
            buf[i] = '/';
        }
    }
    if (mkdir(buf, 0755) != 0 && errno != EEXIST) return -1;
    return 0;
}

/* One-byte string, heap-allocated and NUL-terminated. The line editor
   builds output a byte at a time (an escape sequence's parameters, a
   typed character) and Zyl has no character type -- every such byte has
   to become a one-character string before str-concat can join it. */
long long zyl_cstr_from_byte(long long b) {
    long long p = ZYL_RESULT_ALLOC(2);
    if (!p) return 0;
    char* s = (char*)(size_t)p;
    s[0] = (char)(b & 0xFF);
    s[1] = 0;
    return p;
}

/* ── Interpreter support (stdlib/repl/interp.zyl) ───────────────────────
   The REPL evaluates a lowered ICNF program in this process instead of
   generating machine code for it. Three things only C can provide:
   calling an arbitrary FFI symbol by name, doing real double arithmetic
   on values the interpreter carries as bit patterns, and turning a
   String into the machine word every other layer already knows it is. */
#include <dlfcn.h>

/* A String and its address are the same thing at runtime; the type
   system is what distinguishes them. The interpreter stores every value
   as a machine word, so it needs to cross that line explicitly rather
   than by accident. */
long long zyl_word_of_cstr(long long s) { return s; }

/* A fresh id, unique for the life of the process and monotonically
   increasing. icnf.zyl names its lifted match-arm and lambda helpers
   with it, so it has to be deterministic: a fresh process compiling the
   same source asks for ids in the same order and gets the same ones,
   which is what keeps stageN and stage(N+1) byte-identical.

   It used to be the compile arena's byte offset, which is also
   deterministic but restarts whenever the arena does. The REPL compiles
   many programs in one process and reclaims each entry's arena, so two
   entries would name two unrelated lambdas `_lambda_1234` and a closure
   stored from the first would call the second. A counter that never
   resets cannot do that. */
/* The heap arena the runtime allocates from, swapped for the duration
   of one REPL entry. Compiling a program allocates a great deal of
   string garbage through zyl_cstr_concat and friends -- the qualifier
   alone builds a canonical key per identifier -- and a bump allocator
   never gives it back. The REPL compiles a program per entry, so it
   runs each one against an arena it can throw away, and keeps the
   session's own arena for the entries that bind something.

   Returns the arena that was in place, for the caller to restore. */
long long zyl_heap_swap(long long arena) {
    long long old = (long long)(size_t)g_heap_arena;
    if (arena) g_heap_arena = (void*)(size_t)arena;
    return old;
}

/* The arena that holds everything a session keeps: the values bound by
   `def`, and whatever they point at. Created once, never destroyed. */
long long zyl_session_arena(void) {
    static void* session = NULL;
    if (!session) {
        session = (void*)(size_t)zyl_arena_create(ZYL_HEAP_ARENA_DEFAULT_BLOCK);
    }
    return (long long)(size_t)session;
}

/* Whether `w` addresses a live block in one of the arenas the
   interpreter allocates values from. It has to ask: a variant's field
   is just a machine word, and the interpreter cannot tell an Int from a
   pointer by looking at it -- `(Cons 1 Nil)` holds the integer 1 where
   another value would hold an address. Dereferencing that 1 to read a
   tag is what this prevents.

   Conservative in the safe direction: an integer that happens to land
   inside a live block is treated as a pointer (and then read as a
   block, which is harmless -- it yields a wrong tag, not a crash),
   while a pointer into an arena that has been destroyed reads as not a
   pointer, which is exactly right. */
static int zyl_addr_in_arena(void* arenap, long long ptr) {
    if (!arenap) return 0;
    ZylArena* a = (ZylArena*)arenap;
    char* p = (char*)(size_t)ptr;
    int found = 0;
    pthread_mutex_lock(&a->lock);
    for (ZylArenaBlock* b = a->head; b; b = b->next) {
        if (p >= b->mem && p + sizeof(long long) <= b->mem + b->used) { found = 1; break; }
    }
    pthread_mutex_unlock(&a->lock);
    return found;
}

long long zyl_heap_block_p(long long w) {
    if (w < 4096) return 0;
    if (w & 7) return 0;
    if (zyl_addr_in_arena(g_heap_arena, w)) return 1;
    return zyl_addr_in_arena((void*)(size_t)zyl_session_arena(), w) ? 1 : 0;
}

/* The interpreter's test registry. A `(test "name" ...)` form lowers to
   a zyl_register_test call whose second argument is the address of the
   generated test function -- which, under the interpreter, is not an
   address at all but an interpreter value. So the interpreter keeps its
   own registry of those values and runs the tests itself, printing what
   zyl_run_tests prints, character for character, because the regression
   suite compares the two outputs. */
#define ZYL_ITEST_MAX 4096
static struct { long long name; long long fn; } g_itests[ZYL_ITEST_MAX];
static long long g_itest_count = 0;

long long zyl_itest_add(long long name, long long fn) {
    if (g_itest_count >= ZYL_ITEST_MAX) return -1;
    g_itests[g_itest_count].name = name;
    g_itests[g_itest_count].fn = fn;
    return g_itest_count++;
}

long long zyl_itest_count(void) { return g_itest_count; }
long long zyl_itest_name(long long i) {
    if (i < 0 || i >= g_itest_count) return 0;
    return g_itests[i].name;
}
long long zyl_itest_fn(long long i) {
    if (i < 0 || i >= g_itest_count) return 0;
    return g_itests[i].fn;
}
long long zyl_itest_reset(void) { g_itest_count = 0; return 0; }

/* The two lines zyl_run_tests writes, so that an interpreted run and a
   compiled run produce the same transcript. */
long long zyl_itest_start(long long name) {
    printf("test: %s ... ", (const char*)(size_t)name);
    fflush(stdout);
    return 0;
}

long long zyl_itest_outcome(long long ok) {
    printf(ok ? "ok\n" : "FAIL\n");
    return 0;
}

long long zyl_itest_summary(long long passed, long long failed) {
    printf("\ntest result: %lld passed, %lld failed, %lld total\n",
           passed, failed, passed + failed);
    return (failed > 0) ? 1 : 0;
}

/* Name-to-value map for the interpreter's function table. Finding the
   callee by walking a list is fine for one expression at a prompt and
   hopeless for a program that makes millions of calls: a lowered
   program has thousands of functions in it, and the walk is per call.
   One map, rebuilt when the table changes, makes the lookup a hash.

   Open addressing, no deletion, contents replaced wholesale -- the
   interpreter rebuilds it for each program it runs. Lookup order never
   affects a result, so nothing here can make a run non-deterministic. */
#define ZYL_FNMAP_CAP 16384
static struct { long long name; long long value; } g_fnmap[ZYL_FNMAP_CAP];
static long long g_fnmap_used = 0;

static size_t zyl_str_hash(const char* s) {
    size_t h = 1469598103934665603ULL;           /* FNV-1a */
    while (*s) { h ^= (unsigned char)*s++; h *= 1099511628211ULL; }
    return h;
}

long long zyl_fnmap_reset(void) {
    memset(g_fnmap, 0, sizeof(g_fnmap));
    g_fnmap_used = 0;
    return 0;
}

/* First writer wins: the interpreter inserts newest-definition-first, so
   a redefinition entered at the prompt shadows the earlier one. */
long long zyl_fnmap_put(long long name, long long value) {
    const char* n = (const char*)(size_t)name;
    if (!n || g_fnmap_used >= ZYL_FNMAP_CAP / 2) return 0;
    size_t i = zyl_str_hash(n) & (ZYL_FNMAP_CAP - 1);
    for (size_t probe = 0; probe < ZYL_FNMAP_CAP; probe++) {
        size_t j = (i + probe) & (ZYL_FNMAP_CAP - 1);
        if (!g_fnmap[j].name) {
            g_fnmap[j].name = name;
            g_fnmap[j].value = value;
            g_fnmap_used++;
            return 1;
        }
        if (strcmp((const char*)(size_t)g_fnmap[j].name, n) == 0) return 0;
    }
    return 0;
}

long long zyl_fnmap_get(long long name) {
    const char* n = (const char*)(size_t)name;
    if (!n || g_fnmap_used == 0) return 0;
    size_t i = zyl_str_hash(n) & (ZYL_FNMAP_CAP - 1);
    for (size_t probe = 0; probe < ZYL_FNMAP_CAP; probe++) {
        size_t j = (i + probe) & (ZYL_FNMAP_CAP - 1);
        if (!g_fnmap[j].name) return 0;
        if (strcmp((const char*)(size_t)g_fnmap[j].name, n) == 0) return g_fnmap[j].value;
    }
    return 0;
}

/* A heap block for the interpreter: the same payload compiled code
   builds -- [tag][field]... with zyl_heap_alloc's qword-count header
   right in front of it, which is what zyl_variant_eq and
   zyl_variant_field read -- plus one more hidden word ahead of that,
   recording what kind each field is (two bits apiece, lowest field
   first: 0 Int, 1 String, 2 Float, 3 pointer).

   Compiled code has no such word: codegen binds every destructured
   field as an Int, so a String pulled out of a variant prints as its
   address. The interpreter can do better for free, and this is where it
   keeps what it needs to. The magic tag is what makes the word safe to
   read: a block that came from anywhere else answers "no kinds", and
   its fields read back as Int exactly as before. */
#define ZYL_KINDS_MAGIC 0x5A4B4E44LL   /* 'ZKND' */

long long zyl_val_alloc(long long nwords, long long kinds, long long name) {
    if (nwords < 0) nwords = 0;
    if (nwords > (1LL << 20)) return 0;
    /* Three extra words in front of the payload: the constructor's name,
       the kinds record, and a second copy of the qword count where
       zyl_variant_eq expects to find it (immediately before the pointer
       that is handed out). */
    long long raw = zyl_heap_alloc((nwords + 3) * 8);
    if (!raw) return 0;
    long long* w = (long long*)(size_t)raw;
    w[0] = name;
    w[1] = (ZYL_KINDS_MAGIC << 32) | (kinds & 0xFFFFFFFFLL);
    w[2] = nwords;
    return raw + 24;
}

/* The kind of field `i` of `p`, or 0 (Int) when `p` was not built here. */
long long zyl_val_kind(long long p, long long i) {
    if (!p || i < 0 || i >= 31) return 0;
    if (!zyl_heap_block_p(p - 16)) return 0;
    long long w = *(long long*)(size_t)(p - 16);
    if ((w >> 32) != ZYL_KINDS_MAGIC) return 0;
    return (w >> (2 * i)) & 3;
}

/* The constructor's name, or 0 when `p` was not built by the
   interpreter. This is what lets a value print as `(Cons 1 Nil)`
   instead of as an address: the tag alone cannot say, since every ADT
   numbers its own variants from zero. */
long long zyl_val_name(long long p) {
    if (!p) return 0;
    if (!zyl_heap_block_p(p - 16)) return 0;
    long long w = *(long long*)(size_t)(p - 16);
    if ((w >> 32) != ZYL_KINDS_MAGIC) return 0;
    return *(long long*)(size_t)(p - 24);
}

/* Number of fields in a block built here (or handed out by
   zyl_heap_alloc, whose header this reads). */
long long zyl_val_arity(long long p) {
    if (!p || !zyl_heap_block_p(p - 8)) return 0;
    return *(long long*)(size_t)(p - 8);
}

/* A stable copy of a constructor's name, deduplicated by content.

   The name the interpreter gets comes from an ICNF node, which lives in
   the arena that entry compiled into -- and that arena is released when
   the entry finishes, while the value it built may outlive it in a
   session binding. Copying the name per construction would put a
   `strlen` and an allocation on the hot path of every `Cons`; interning
   it puts them on the first one only.

   The table never shrinks, which is what "stable" requires: something
   is still pointing at every entry. Names are few -- one per
   constructor in the program. */
#define ZYL_NAMES_CAP 4096
static struct { char* text; } g_names[ZYL_NAMES_CAP];
static long long g_names_used = 0;

long long zyl_intern_name(long long s) {
    const char* n = (const char*)(size_t)s;
    if (!n) return 0;
    size_t i = zyl_str_hash(n) & (ZYL_NAMES_CAP - 1);
    for (size_t probe = 0; probe < ZYL_NAMES_CAP; probe++) {
        size_t j = (i + probe) & (ZYL_NAMES_CAP - 1);
        if (!g_names[j].text) {
            if (g_names_used >= ZYL_NAMES_CAP / 2) return 0;
            size_t len = strlen(n);
            char* copy = (char*)malloc(len + 1);
            if (!copy) return 0;
            memcpy(copy, n, len + 1);
            g_names[j].text = copy;
            g_names_used++;
            return (long long)(size_t)copy;
        }
        if (strcmp(g_names[j].text, n) == 0) return (long long)(size_t)g_names[j].text;
    }
    return 0;
}

/* Milliseconds on a monotonic clock. The REPL's `:time` uses it; it is
   deliberately not available to a compiled program's determinism-
   sensitive paths through any other name, and nothing in the compiler
   calls it. */
#include <time.h>
long long zyl_now_ms(void) {
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) return 0;
    return (long long)ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
}

long long zyl_fresh_id(void) {
    static long long counter = 0;
    return ++counter;
}

/* The other direction, for a word the interpreter knows points at
   NUL-terminated bytes. Also the identity; also there for the type
   system rather than the machine. */
long long zyl_cstr_of_word(long long w) { return w; }

/* The IEEE-754 bit pattern of a Float, as an Int (a Float travels in a
   general register as its bits, so this is the identity too). Typed
   Float -> Int, it is how Hash hashes a Float without a cast. */
long long zyl_float_bits(long long w) { return w; }

/* The Float whose IEEE-754 bit pattern is `w`. Every 64-bit pattern is
   some double (a NaN at worst), so this is total and safe to expose. */
long long zyl_float_of_bits(long long w) { return w; }

/* Raw word access for the interpreter, which runs word-level ICNF: the
   word at address `a`, and a store to it. Typed Int -> Int and
   Int Int -> Unit; they are raw memory access, so the checker only lets
   the standard library call them (arity_check.zyl, E_FFI_RESTRICTED). */
long long zyl_word_load(long long a) { return *(long long*)(size_t)a; }
long long zyl_word_store(long long a, long long w) { *(long long*)(size_t)a = w; return 0; }

/* `p` advanced by `n` bytes. */
long long zyl_ptr_add(long long p, long long n) { return p + n; }

/* The NUL-terminated bytes at `p`, as a String (the identity). */
long long zyl_ptr_cstr(long long p) { return p; }

/* zyl_ffi_lookup as an address word, for the interpreter's ISymAddr and
   its calls through zyl_call_argv (FnPtr is opaque to Zyl code). */
long long zyl_ffi_lookup(long long name);
long long zyl_ffi_addr(long long name) { return zyl_ffi_lookup(name); }

/* Decimal text of an integer, heap-allocated. zyl_cstr_from_int needs
   an arena; the interpreter has heap values and no arena of its own. */
long long zyl_int_text(long long n) {
    long long p = ZYL_RESULT_ALLOC(24);
    if (!p) return 0;
    snprintf((char*)(size_t)p, 24, "%lld", n);
    return p;
}

/* Every runtime symbol the compiler can emit an `ffi-call` to, by name.
   dlsym alone would need the whole program linked with -rdynamic, which
   is not something a language should require of every binary it
   produces, so the symbols this runtime owns are listed explicitly and
   dlsym is the fallback for everything else (libc, a shared library the
   program links). Adding a function here is only necessary for the
   interpreter -- compiled code calls it directly by symbol. */
/* Every runtime symbol the compiler can emit an `ffi-call` to, by name.
   dlsym alone would need the whole program linked with -rdynamic, which
   is not something a language should require of every binary it
   produces, so the symbols this runtime owns are listed here and dlsym
   is the fallback for everything else (libc, a shared library the
   program links).

   The list is generated from what this runtime declares and what
   icnf.zyl/codegen.zyl emit; regenerate it when the runtime gains a
   function the compiler lowers to. Compiled code needs no entry -- it
   calls the symbol directly -- so a missing name costs only the
   interpreter, and shows up as E_FFI_SYMBOL_NOT_FOUND rather than as
   anything silent. */
#define ZYL_FFI_SYMBOLS(X) \
    X(ffi_pin) X(ffi_unpin) X(zyl_actor_init) \
    X(zyl_actor_is_alive) X(zyl_actor_send) X(zyl_actor_send_closure) \
    X(zyl_actor_send_data) X(zyl_actor_spawn) X(zyl_actor_terminate) \
    X(zyl_actor_wait) X(zyl_actor_wait_all) X(zyl_aes_encrypt_block) \
    X(zyl_aesni_available) X(zyl_align_check) X(zyl_arena_alloc) \
    X(zyl_arena_alloc_zeroed) X(zyl_arena_capacity) X(zyl_arena_create) \
    X(zyl_arena_destroy) X(zyl_arena_reset) X(zyl_arena_used) \
    X(zyl_arg_str) X(zyl_argc) X(zyl_atomic_add) \
    X(zyl_atomic_cas) X(zyl_atomic_fetch_add) X(zyl_atomic_load) \
    X(zyl_atomic_max) X(zyl_atomic_min) X(zyl_atomic_store) \
    X(zyl_atomic_sub) X(zyl_blake3_file_hex) X(zyl_blake3_hex) \
    X(zyl_byte_slice) X(zyl_byte_slice_sub) X(zyl_bytebuf_append) \
    X(zyl_bytebuf_atomic_add) X(zyl_bytebuf_atomic_cas) X(zyl_bytebuf_atomic_fetch_add) \
    X(zyl_bytebuf_atomic_load) X(zyl_bytebuf_atomic_max) X(zyl_bytebuf_atomic_min) \
    X(zyl_bytebuf_atomic_store) X(zyl_bytebuf_atomic_sub) X(zyl_bytebuf_cap) \
    X(zyl_bytebuf_len) X(zyl_bytebuf_new) X(zyl_bytebuf_ptr) \
    X(zyl_call0) X(zyl_call1) X(zyl_call2) \
    X(zyl_call3) X(zyl_call4) X(zyl_call5) \
    X(zyl_call6) X(zyl_call_argv) X(zyl_call_on_big_stack) \
    X(zyl_cc_compile) X(zyl_cc_compile_log) X(zyl_chdir) \
    X(zyl_cpuid_features) X(zyl_cstr_byte_at) X(zyl_cstr_byte_set) \
    X(zyl_cstr_concat) X(zyl_cstr_count_newlines) X(zyl_cstr_decode) \
    X(zyl_cstr_cmp) X(zyl_cstr_eq) X(zyl_cstr_from_byte) X(zyl_cstr_from_int) \
    X(zyl_cstr_key_matches) \
    X(zyl_cstr_last_newline) X(zyl_cstr_len) X(zyl_cstr_of_word) X(zyl_float_bits) X(zyl_float_of_bits) X(zyl_word_load) X(zyl_word_store) X(zyl_ptr_add) X(zyl_ptr_cstr) X(zyl_ffi_addr) \
    X(zyl_cstr_sanitize) X(zyl_cstr_sub) X(zyl_cstr_substr) \
    X(zyl_cstr_to_int) X(zyl_cstr_to_int_base) X(zyl_diag_json) \
    X(zyl_diag_json_set) X(zyl_dirname_cstr) \
    X(zyl_attr_clear) X(zyl_attr_copy) X(zyl_attr_get) X(zyl_attr_set) \
    X(zyl_ensure_arenas) X(zyl_exec_cmd) X(zyl_f_add) \
    X(zyl_f_cmp) X(zyl_f_div) X(zyl_f_error) \
    X(zyl_f_mul) X(zyl_f_of_int) X(zyl_f_parse) \
    X(zyl_f_rem) X(zyl_f_sub) X(zyl_f_text) \
    X(zyl_f_to_int) X(zyl_ffi_lookup) X(zyl_ffi_timed) X(zyl_ffi_timed_argv) X(zyl_file_close_c) \
    X(zyl_file_open_c) X(zyl_file_read_c) X(zyl_file_write_c) \
    X(zyl_fnmap_get) X(zyl_fnmap_put) X(zyl_fnmap_reset) \
    X(zyl_fresh_id) X(zyl_getcwd) X(zyl_getenv) \
    X(zyl_contract_warn) X(zyl_err_is) X(zyl_list_zyl_files) X(zyl_list_files) \
    X(zyl_load_n) X(zyl_load_n_signed) X(zyl_store_n) \
    X(zyl_global_get) X(zyl_global_put) X(zyl_global_ready) X(zyl_global_clear) X(zyl_iglobal_get) X(zyl_iglobal_put) X(zyl_iglobal_ready) X(zyl_iglobal_clear) \
    X(zyl_repl_global_get) X(zyl_repl_global_set) \
    X(zyl_uf_id) X(zyl_uf_reset) X(zyl_uf_new) X(zyl_uf_find) X(zyl_uf_union) X(zyl_uf_raise) X(zyl_uf_level) X(zyl_regions_enabled) X(zyl_words_new) X(zyl_words_len) X(zyl_words_get) X(zyl_words_set) X(zyl_words_view) X(zyl_smap_has) X(zyl_smap_get_or) X(zyl_array_new) X(zyl_array_cap) X(zyl_array_filled) X(zyl_array_get) X(zyl_array_set) X(zyl_attrh_new) X(zyl_attrh_set) X(zyl_attrh_get_or) X(zyl_attrh_has) X(zyl_attrh_copy) X(zyl_attrh_clear) X(zyl_ref_new) X(zyl_ref_get) X(zyl_ref_set) X(zyl_getenv_str) X(zyl_strbuf_new) X(zyl_strbuf_str) X(zyl_cstr_escapes_ok) X(zyl_heap_alloc) X(zyl_ralloc) X(zyl_region_enter) X(zyl_region_exit) X(zyl_region_free) X(zyl_region_scope_enter) X(zyl_region_live_bytes) X(zyl_heap_block_p) X(zyl_heap_swap) \
    X(zyl_int_text) X(zyl_itest_add) X(zyl_itest_count) \
    X(zyl_itest_fn) X(zyl_itest_name) X(zyl_itest_outcome) \
    X(zyl_itest_reset) X(zyl_itest_start) X(zyl_itest_summary) \
    X(zyl_json_quote) \
    X(zyl_load_byte) X(zyl_load_byte_signed) X(zyl_mangle_key) \
    X(zyl_mem_alloc) X(zyl_mem_free) X(zyl_mem_read) \
    X(zyl_mem_write) X(zyl_mkdir_p) X(zyl_mlock) \
    X(zyl_panic) X(zyl_path_exists) X(zyl_pin_alloc) \
    X(zyl_print_float) X(zyl_print_int) X(zyl_print_str) \
    X(zyl_random_fill) X(zyl_random_words) X(zyl_run_bin) \
    X(zyl_session_arena) X(zyl_smap_clear) X(zyl_smap_get) X(zyl_smap_global) X(zyl_smap_new) X(zyl_smap_put) \
    X(zyl_source_path) X(zyl_source_register) \
    X(zyl_span_col) X(zyl_span_copy) X(zyl_span_file) \
    X(zyl_span_line) X(zyl_span_line_text) X(zyl_span_off) \
    X(zyl_span_snippet) X(zyl_span_snippet_col) \
    X(zyl_span_offset_at) X(zyl_span_set) X(zyl_store_byte) \
    X(zyl_store_byte_signed) X(zyl_str_append) X(zyl_str_append_capped) \
    X(zyl_sym_escape) X(zyl_system_cmd) X(zyl_term_flush) \
    X(zyl_term_height) X(zyl_term_is_tty) X(zyl_term_raw_off) \
    X(zyl_term_raw_on) X(zyl_term_read_byte) X(zyl_term_read_byte_timeout) \
    X(zyl_term_width) X(zyl_term_write) X(zyl_try_frame_msg) \
    X(zyl_try_last_msg) X(zyl_try_pop) X(zyl_try_push) \
    X(zyl_variant_cmp) X(zyl_variant_eq) X(zyl_variant_field) \
    X(zyl_warn_capture) X(zyl_warn_emit) X(zyl_warn_take) \
    X(zyl_word_of_cstr) X(zyl_wvec_get) X(zyl_wvec_global) X(zyl_wvec_len) X(zyl_wvec_new) \
    X(zyl_wvec_pop) X(zyl_wvec_push) X(zyl_wvec_set) X(zyl_wvec_truncate) X(zyl_zeroize)

/* Forward declarations for the interpreter helpers named above. */
long long zyl_f_parse(long long text);
long long zyl_f_add(long long a, long long b);
long long zyl_f_sub(long long a, long long b);
long long zyl_f_mul(long long a, long long b);
long long zyl_f_div(long long a, long long b);
long long zyl_f_rem(long long a, long long b);
long long zyl_f_cmp(long long a, long long b);
long long zyl_f_of_int(long long n);
long long zyl_f_to_int(long long bits);
long long zyl_f_text(long long bits);
long long zyl_print_int(long long n);
long long zyl_print_str(long long s);
long long zyl_print_float(long long bits);

struct ZylFfiEntry { const char* name; void* fn; };

#define ZYL_FFI_ENTRY(sym) { #sym, (void*)(size_t)&sym },
static const struct ZylFfiEntry g_ffi_table[] = {
    ZYL_FFI_SYMBOLS(ZYL_FFI_ENTRY)
    { NULL, NULL }
};
#undef ZYL_FFI_ENTRY

/* Whether `name` is one of this runtime's own entries. The compiler is
   linked with the same runtime it compiles against, so it asks here: a
   runtime entry is typed only by the compiler's signature table, never
   by a program's (extern ...) (which could otherwise give an untyped raw
   entry any type). */
long long zyl_runtime_export_p(long long name) {
    const char* n = (const char*)(size_t)name;
    if (!n) return 0;
    for (const struct ZylFfiEntry* e = g_ffi_table; e->name; e++)
        if (strcmp(e->name, n) == 0) return 1;
    return 0;
}

/* Address of an FFI target by name: this runtime's own symbols first
   (always present, no link flags needed), then whatever the dynamic
   loader can see. 0 means "no such symbol", which the interpreter
   reports as a located error rather than calling into nothing. */
long long zyl_ffi_lookup(long long name) {
    const char* n = (const char*)(size_t)name;
    if (!n) return 0;
    for (const struct ZylFfiEntry* e = g_ffi_table; e->name; e++) {
        if (strcmp(e->name, n) == 0) return (long long)(size_t)e->fn;
    }
    void* sym = dlsym(RTLD_DEFAULT, n);
    return (long long)(size_t)sym;
}

/* Call `fn` with `argc` machine words read from the array at `argv`.
   Arguments arrive as an array rather than as parameters because a
   variadic bridge would need more than six of its own.

   Deliberately NOT routed through zyl_call0..6: those treat any address
   at or above 4 GiB as a closure object and dereference its first word
   for the code pointer, which is right for a Zyl closure value and
   wrong for every symbol the dynamic loader hands back -- libc lives
   well above that line. The interpreter resolves Zyl closures itself
   and only ever passes a real function address here. */
typedef long long (*ZylFn0)(void);
typedef long long (*ZylFn1)(long long);
typedef long long (*ZylFn2)(long long, long long);
typedef long long (*ZylFn3)(long long, long long, long long);
typedef long long (*ZylFn4)(long long, long long, long long, long long);
typedef long long (*ZylFn5)(long long, long long, long long, long long, long long);
typedef long long (*ZylFn6)(long long, long long, long long, long long, long long, long long);

long long zyl_call_argv(long long fn, long long argc, long long argv) {
    const long long* a = (const long long*)(size_t)argv;
    if (fn < ZYL_MIN_CALL_ADDR) {
        fprintf(stderr, "zyl: ffi call to invalid address 0x%llx\n",
                (unsigned long long)fn);
        return 0;
    }
    switch (argc) {
        case 0: return ((ZylFn0)(size_t)fn)();
        case 1: return ((ZylFn1)(size_t)fn)(a[0]);
        case 2: return ((ZylFn2)(size_t)fn)(a[0], a[1]);
        case 3: return ((ZylFn3)(size_t)fn)(a[0], a[1], a[2]);
        case 4: return ((ZylFn4)(size_t)fn)(a[0], a[1], a[2], a[3]);
        case 5: return ((ZylFn5)(size_t)fn)(a[0], a[1], a[2], a[3], a[4]);
        case 6: return ((ZylFn6)(size_t)fn)(a[0], a[1], a[2], a[3], a[4], a[5]);
        default:
            fprintf(stderr, "zyl: ffi call with %lld arguments (max 6)\n",
                    (long long)argc);
            return 0;
    }
}

/* ==========================================================================
   Timed FFI calls — `(ffi-call "sym" args... timeout-ms)` on foreign code.

   The compiler lowers every ffi-call to a symbol outside this runtime to
   zyl_ffi_timed(address, name, timeout-ms, argc, args...). The call runs
   on a worker thread that belongs to the calling thread (one per actor,
   created on first use and kept, so thread-local state such as errno
   stays consistent from one call to the next). The caller waits on a
   monotonic clock; if the foreign function has not returned when the
   timeout expires, the caller raises E_FFI_TIMEOUT.

   A running C function cannot be stopped safely (it may hold a lock, be
   halfway through a write, or own memory), so an overrunning call is
   abandoned, not killed: its worker finishes on its own and then frees
   itself, and the calling thread gets a fresh worker for its next call.
   Because the abandoned call may still read or write anything it was
   handed, nothing it could reach is reclaimed afterwards: Pin slots are
   never freed individually anyway, and once any call has been abandoned
   the exit-time arena teardown is skipped.

   Determinism: whether a timeout fires depends on how long foreign code
   runs, which the language cannot control. Spec §27 counts FFI results
   as observable external input; a timeout is one such result, exactly
   like a value the C function returns.
   ========================================================================== */
#include <stdarg.h>

#define ZYL_FFI_MAX_ARGS 16

typedef long long (*ZylFfiFn)(long long, long long, long long, long long,
                              long long, long long, long long, long long,
                              long long, long long, long long, long long,
                              long long, long long, long long, long long);

/* Call `fn` with exactly `argc` words. Each arm passes only the words the
   callee takes: calling through a 16-parameter pointer with trailing
   padding would work on SysV x86_64 but is not something to rely on. */
static long long zyl_ffi_invoke(long long fn, long long argc, const long long* a) {
    void* f = (void*)(size_t)fn;
    typedef long long W;
    switch (argc) {
        case 0: return ((W(*)(void))f)();
        case 1: return ((W(*)(W))f)(a[0]);
        case 2: return ((W(*)(W,W))f)(a[0],a[1]);
        case 3: return ((W(*)(W,W,W))f)(a[0],a[1],a[2]);
        case 4: return ((W(*)(W,W,W,W))f)(a[0],a[1],a[2],a[3]);
        case 5: return ((W(*)(W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4]);
        case 6: return ((W(*)(W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5]);
        case 7: return ((W(*)(W,W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6]);
        case 8: return ((W(*)(W,W,W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7]);
        case 9: return ((W(*)(W,W,W,W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8]);
        case 10: return ((W(*)(W,W,W,W,W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9]);
        case 11: return ((W(*)(W,W,W,W,W,W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10]);
        case 12: return ((W(*)(W,W,W,W,W,W,W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11]);
        case 13: return ((W(*)(W,W,W,W,W,W,W,W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12]);
        case 14: return ((W(*)(W,W,W,W,W,W,W,W,W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13]);
        case 15: return ((W(*)(W,W,W,W,W,W,W,W,W,W,W,W,W,W,W))f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13],a[14]);
        default: return ((ZylFfiFn)f)(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13],a[14],a[15]);
    }
}

typedef struct ZylFfiWorker {
    pthread_mutex_t lock;
    pthread_cond_t cond;   /* new request, and request done */
    int state;             /* 0 idle, 1 request pending, 2 result ready */
    int abandoned;         /* the caller gave up; the worker frees itself */
    long long self_id;     /* the caller's actor id, for callbacks */
    long long fn;
    long long argc;
    long long argv[ZYL_FFI_MAX_ARGS];
    long long result;
} ZylFfiWorker;

static _Thread_local ZylFfiWorker* g_ffi_worker = 0;
/* Set on a worker thread: a panic there cannot unwind into the caller's
   test runner, which lives on another thread's stack. */
static _Thread_local int g_ffi_on_worker = 0;
static int g_ffi_any_abandoned = 0;

int zyl_ffi_abandoned(void) {
    return __atomic_load_n(&g_ffi_any_abandoned, __ATOMIC_ACQUIRE);
}

int zyl_ffi_on_worker(void) { return g_ffi_on_worker; }

static void* zyl_ffi_worker_main(void* p) {
    ZylFfiWorker* w = (ZylFfiWorker*)p;
    g_self_id = w->self_id;
    g_ffi_on_worker = 1;
    pthread_mutex_lock(&w->lock);
    for (;;) {
        while (w->state != 1) pthread_cond_wait(&w->cond, &w->lock);
        long long fn = w->fn;
        long long argc = w->argc;
        long long a[ZYL_FFI_MAX_ARGS];
        memcpy(a, w->argv, sizeof a);
        pthread_mutex_unlock(&w->lock);
        long long r = zyl_ffi_invoke(fn, argc, a);
        pthread_mutex_lock(&w->lock);
        w->result = r;
        w->state = 2;
        if (w->abandoned) break;
        pthread_cond_broadcast(&w->cond);
    }
    pthread_mutex_unlock(&w->lock);
    pthread_cond_destroy(&w->cond);
    pthread_mutex_destroy(&w->lock);
    free(w);
    return 0;
}

static ZylFfiWorker* zyl_ffi_worker_get(void) {
    if (g_ffi_worker) return g_ffi_worker;
    ZylFfiWorker* w = (ZylFfiWorker*)calloc(1, sizeof *w);
    if (!w) zyl_panic("E_OUT_OF_MEMORY: no memory for an FFI worker");
    pthread_mutex_init(&w->lock, NULL);
    pthread_condattr_t ca;
    pthread_condattr_init(&ca);
    pthread_condattr_setclock(&ca, CLOCK_MONOTONIC);
    pthread_cond_init(&w->cond, &ca);
    pthread_condattr_destroy(&ca);
    w->self_id = g_self_id;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    pthread_t t;
    int rc = pthread_create(&t, &attr, zyl_ffi_worker_main, w);
    pthread_attr_destroy(&attr);
    if (rc != 0) zyl_panic("E_FFI_TIMEOUT: could not start the FFI worker thread");
    g_ffi_worker = w;
    return w;
}

static long long zyl_ffi_timed_core(long long fn, long long name, long long ms,
                                    long long argc, const long long* a) {
    const char* sym = name ? (const char*)(size_t)name : "?";
    if (fn < ZYL_MIN_CALL_ADDR) {
        char* m = (char*)malloc(strlen(sym) + 64);
        sprintf(m, "E_FFI_SYMBOL_NOT_FOUND: no such FFI symbol: %s", sym);
        zyl_panic(m);
    }
    if (argc < 0 || argc > ZYL_FFI_MAX_ARGS) {
        zyl_panic("E_ARITY_MISMATCH: ffi-call passes more than 16 arguments");
    }
    if (ms < 1) ms = 1;
    ZylFfiWorker* w = zyl_ffi_worker_get();
    struct timespec deadline;
    clock_gettime(CLOCK_MONOTONIC, &deadline);
    deadline.tv_sec += ms / 1000;
    deadline.tv_nsec += (ms % 1000) * 1000000L;
    if (deadline.tv_nsec >= 1000000000L) {
        deadline.tv_sec += 1;
        deadline.tv_nsec -= 1000000000L;
    }
    pthread_mutex_lock(&w->lock);
    w->fn = fn;
    w->argc = argc;
    memset(w->argv, 0, sizeof w->argv);
    for (long long i = 0; i < argc; i++) w->argv[i] = a[i];
    w->state = 1;
    pthread_cond_broadcast(&w->cond);
    while (w->state != 2) {
        int rc = pthread_cond_timedwait(&w->cond, &w->lock, &deadline);
        if (rc == ETIMEDOUT && w->state != 2) {
            w->abandoned = 1;
            pthread_mutex_unlock(&w->lock);
            g_ffi_worker = 0;
            __atomic_store_n(&g_ffi_any_abandoned, 1, __ATOMIC_RELEASE);
            char* m = (char*)malloc(strlen(sym) + 96);
            sprintf(m, "E_FFI_TIMEOUT: ffi call `%s` exceeded its timeout of %lld ms", sym, ms);
            zyl_panic(m);
        }
    }
    long long r = w->result;
    w->state = 0;
    pthread_mutex_unlock(&w->lock);
    return r;
}

long long zyl_ffi_timed(long long fn, long long name, long long ms, long long argc, ...) {
    long long a[ZYL_FFI_MAX_ARGS] = {0};
    va_list ap;
    va_start(ap, argc);
    for (long long i = 0; i < argc && i < ZYL_FFI_MAX_ARGS; i++) a[i] = va_arg(ap, long long);
    va_end(ap);
    return zyl_ffi_timed_core(fn, name, ms, argc, a);
}

/* The interpreter's entry: the same call with the arguments in an array. */
long long zyl_ffi_timed_argv(long long fn, long long name, long long ms,
                             long long argc, long long argv) {
    const long long* a = (const long long*)(size_t)argv;
    long long buf[ZYL_FFI_MAX_ARGS] = {0};
    for (long long i = 0; i < argc && i < ZYL_FFI_MAX_ARGS; i++) buf[i] = a[i];
    return zyl_ffi_timed_core(fn, name, ms, argc, buf);
}

/* Doubles, carried as their bit patterns. The interpreter stores every
   value in one machine word, so a Float is its IEEE-754 bits and every
   operation on it crosses through here. Compiled code uses the SSE unit
   on the same bit patterns, so the results agree bit for bit. */
static double zyl_d_of(long long bits) {
    double d;
    memcpy(&d, &bits, sizeof(d));
    return d;
}

static long long zyl_bits_of(double d) {
    long long bits;
    memcpy(&bits, &d, sizeof(bits));
    return bits;
}

long long zyl_f_parse(long long text) {
    const char* s = (const char*)(size_t)text;
    if (!s) return 0;
    return zyl_bits_of(strtod(s, NULL));
}

long long zyl_f_add(long long a, long long b) { return zyl_bits_of(zyl_d_of(a) + zyl_d_of(b)); }
long long zyl_f_sub(long long a, long long b) { return zyl_bits_of(zyl_d_of(a) - zyl_d_of(b)); }
long long zyl_f_mul(long long a, long long b) { return zyl_bits_of(zyl_d_of(a) * zyl_d_of(b)); }
long long zyl_f_div(long long a, long long b) { return zyl_bits_of(zyl_d_of(a) / zyl_d_of(b)); }
/* Truncated remainder without libm: x - trunc(x/y)*y. Written this way
   so that nothing linking this runtime has to link -lm for a case the
   language barely exercises (float `%`). */
long long zyl_f_rem(long long a, long long b) {
    double x = zyl_d_of(a), y = zyl_d_of(b);
    if (y == 0.0) return zyl_bits_of(0.0);
    double q = x / y;
    if (q > -9.22e18 && q < 9.22e18) q = (double)(long long)q;
    return zyl_bits_of(x - q * y);
}

/* -1, 0 or 1. NaN compares as 2, so that every ordering built on this
   answers false for it rather than accidentally answering true. */
long long zyl_f_cmp(long long a, long long b) {
    double x = zyl_d_of(a), y = zyl_d_of(b);
    if (x < y) return -1;
    if (x > y) return 1;
    if (x == y) return 0;
    return 2;
}

long long zyl_f_of_int(long long n) { return zyl_bits_of((double)n); }
long long zyl_f_to_int(long long bits) { return (long long)zyl_d_of(bits); }

/* The same text printf's "%f" would produce, for a REPL result line. */
long long zyl_f_text(long long bits) {
    long long p = ZYL_RESULT_ALLOC(48);
    if (!p) return 0;
    snprintf((char*)(size_t)p, 48, "%f", zyl_d_of(bits));
    return p;
}

/* print, in each of the three shapes codegen emits, so that interpreted
   output is byte-identical to compiled output. */
long long zyl_print_int(long long n) { printf("%lld\n", n); return 0; }
long long zyl_print_str(long long s) { printf("%s\n", (const char*)(size_t)s); return 0; }
long long zyl_print_float(long long bits) { printf("%f\n", zyl_d_of(bits)); return 0; }

/* Region-aware entry points (see g_result_region). Compiled code calls
   these, instead of the plain names, from sites region inference
   annotated (compiler/region_inference, rg-ffi-kind 1). */
#define ZYL_R_BEGIN long long saved_ = g_result_region; g_result_region = (long long)(size_t)zyl_cur_region;
#define ZYL_R_END g_result_region = saved_;
long long zyl_cstr_concat_r(long long a, long long b) { ZYL_R_BEGIN long long v = zyl_cstr_concat(a, b); ZYL_R_END return v; }
long long zyl_cstr_substr_r(long long s, long long st, long long n) { ZYL_R_BEGIN long long v = zyl_cstr_substr(s, st, n); ZYL_R_END return v; }
long long zyl_cstr_from_byte_r(long long b) { ZYL_R_BEGIN long long v = zyl_cstr_from_byte(b); ZYL_R_END return v; }
long long zyl_int_text_r(long long n) { ZYL_R_BEGIN long long v = zyl_int_text(n); ZYL_R_END return v; }
long long zyl_f_text_r(long long bits) { ZYL_R_BEGIN long long v = zyl_f_text(bits); ZYL_R_END return v; }
long long zyl_file_read_c_r(long long fd, long long n) { ZYL_R_BEGIN long long v = zyl_file_read_c(fd, n); ZYL_R_END return v; }

/* Regions are on unless ZYL_REGIONS=0 was set for the compile. */
long long zyl_regions_enabled(void) {
    const char* e = getenv("ZYL_REGIONS");
    return (e && e[0] == '0' && e[1] == 0) ? 0 : 1;
}

/* `(bytebuf Stack N)`: header and bytes in the frame region region
   inference chose (it is an error for such a buffer to leave it). */
long long zyl_bytebuf_new_r(long long region, long long cap) {
    (void)region;
    if (cap < 0 || cap > ZYL_BYTEBUF_MAX_CAP) return 0;
    long long rp = (long long)(size_t)zyl_cur_region;
    ZylByteBufHeader* h = (ZylByteBufHeader*)(size_t)zyl_ralloc((long long)sizeof(ZylByteBufHeader), rp);
    if (!h) return 0;
    size_t alloc_len = (size_t)cap > 0 ? (size_t)cap : 1;
    unsigned char* data = (unsigned char*)(size_t)zyl_ralloc((long long)alloc_len, rp);
    if (!data) return 0;
    memset(data, 0, alloc_len);
    h->magic = ZYL_BYTEBUF_MAGIC;
    h->data = data;
    h->len = 0;
    h->cap = cap;
    return (long long)(size_t)h;
}

/* Sixteen process-wide word cells for compiler passes (the type pass's
   strict-mode flag and current node). */
static long long g_cells[16];
long long zyl_cell_get(long long i) { return (i >= 0 && i < 16) ? g_cells[i] : 0; }
long long zyl_cell_set(long long i, long long v) { if (i >= 0 && i < 16) g_cells[i] = v; return 0; }

/* ==========================================================================
   Word arrays (math/words): a bounds-checked handle instead of a raw base
   address, so no Zyl code does address arithmetic (docs/sound-types-
   design.md). A handle is {magic, length, data}; a view shares its
   parent's data. Out-of-range access is E_INDEX_OUT_OF_BOUNDS.
   ========================================================================== */
#define ZYL_WORDS_MAGIC 0x5A594C574F524453LL  /* "ZYLWORDS" */
typedef struct { long long magic; long long len; long long* data; } ZylWords;

static ZylWords* zyl_words_of(long long h, const char* who) {
    ZylWords* w = (ZylWords*)(size_t)h;
    if (h < ZYL_MIN_CALL_ADDR || (h & 7) || w->magic != ZYL_WORDS_MAGIC) {
        char m[128];
        snprintf(m, sizeof m, "E_INDEX_OUT_OF_BOUNDS: %s: not a word array", who);
        zyl_panic(strdup(m));
    }
    return w;
}

static void zyl_words_oob(const char* who, long long i, long long len) {
    char* m = (char*)malloc(160);
    snprintf(m, 160, "E_INDEX_OUT_OF_BOUNDS: %s: index %lld outside a word array of length %lld", who, i, len);
    zyl_panic(m);
}

/* `n` zeroed words from `arena`. */
long long zyl_words_new(long long arena, long long n) {
    if (n < 0) n = 0;
    ZylWords* w = (ZylWords*)(size_t)zyl_arena_alloc_zeroed(arena, (long long)sizeof(ZylWords));
    long long* d = (long long*)(size_t)zyl_arena_alloc_zeroed(arena, (n > 0 ? n : 1) * 8);
    if (!w || !d) zyl_panic("E_OUT_OF_MEMORY: word array");
    w->magic = ZYL_WORDS_MAGIC;
    w->len = n;
    w->data = d;
    return (long long)(size_t)w;
}

static long long* zyl_words_data(long long h) { return zyl_words_of(h, "words")->data; }
long long zyl_words_len(long long h) { return zyl_words_of(h, "w-len")->len; }

long long zyl_words_get(long long h, long long i) {
    ZylWords* w = zyl_words_of(h, "w-get");
    if (i < 0 || i >= w->len) zyl_words_oob("w-get", i, w->len);
    return w->data[i];
}

long long zyl_words_set(long long h, long long i, long long v) {
    ZylWords* w = zyl_words_of(h, "w-set");
    if (i < 0 || i >= w->len) zyl_words_oob("w-set", i, w->len);
    w->data[i] = v;
    return v;
}

/* Words [off, off+len) of `h`, sharing its storage; the view's header is
   allocated in `arena`. */
long long zyl_words_view(long long arena, long long h, long long off, long long len) {
    ZylWords* w = zyl_words_of(h, "w-view");
    if (off < 0 || len < 0 || off > w->len || len > w->len - off) zyl_words_oob("w-view", off + len, w->len);
    ZylWords* v = (ZylWords*)(size_t)zyl_arena_alloc_zeroed(arena, (long long)sizeof(ZylWords));
    if (!v) zyl_panic("E_OUT_OF_MEMORY: word array view");
    v->magic = ZYL_WORDS_MAGIC;
    v->len = len;
    v->data = w->data + off;
    return (long long)(size_t)v;
}

/* ==========================================================================
   Typed arrays (collections/vec): `(Array a)` in compiler/ffi_sigs. Slots
   are filled contiguously from 0 -- a set may overwrite a filled slot or
   append at `filled` -- and only filled slots can be read, so a slot that
   was never written is never read as a value of the element type. Out of
   range is E_INDEX_OUT_OF_BOUNDS. Storage comes from an arena.
   ========================================================================== */
#define ZYL_ARRAY_MAGIC 0x5A594C4152524159LL  /* "ZYLARRAY" */
typedef struct { long long magic; long long cap; long long filled; long long* data; } ZylArray;

static ZylArray* zyl_array_of(long long h, const char* who) {
    ZylArray* a = (ZylArray*)(size_t)h;
    if (h < ZYL_MIN_CALL_ADDR || (h & 7) || a->magic != ZYL_ARRAY_MAGIC) {
        char* m = (char*)malloc(96);
        snprintf(m, 96, "E_INDEX_OUT_OF_BOUNDS: %s: not an array", who);
        zyl_panic(m);
    }
    return a;
}

long long zyl_array_new(long long arena, long long cap) {
    if (cap < 0) cap = 0;
    ZylArray* a = (ZylArray*)(size_t)zyl_arena_alloc_zeroed(arena, (long long)sizeof(ZylArray));
    long long* d = (long long*)(size_t)zyl_arena_alloc_zeroed(arena, (cap > 0 ? cap : 1) * 8);
    if (!a || !d) zyl_panic("E_OUT_OF_MEMORY: array");
    a->magic = ZYL_ARRAY_MAGIC;
    a->cap = cap;
    a->filled = 0;
    a->data = d;
    return (long long)(size_t)a;
}

long long zyl_array_cap(long long h) { return zyl_array_of(h, "array-cap")->cap; }
long long zyl_array_filled(long long h) { return zyl_array_of(h, "array-filled")->filled; }

long long zyl_array_get(long long h, long long i) {
    ZylArray* a = zyl_array_of(h, "array-get");
    if (i < 0 || i >= a->filled) zyl_words_oob("array-get", i, a->filled);
    return a->data[i];
}

long long zyl_array_set(long long h, long long i, long long v) {
    ZylArray* a = zyl_array_of(h, "array-set");
    if (i < 0 || i > a->filled || i >= a->cap) zyl_words_oob("array-set", i, a->filled);
    a->data[i] = v;
    if (i == a->filled) a->filled++;
    return 0;
}

/* ==========================================================================
   Typed side tables and cells (docs/sound-types-design.md). A handle-based
   node-keyed attribute table, `(Attr k v)`: the index-based zyl_attr_* stay
   for code the committed seed emitted. A `(Ref a)` is a one-word mutable
   cell. zyl_getenv_str gives "" for an unset variable, never 0.
   ========================================================================== */
typedef struct { ZylAttrSlot* slots; size_t cap; size_t len; } ZylAttrTab;

long long zyl_attrh_new(void) {
    return (long long)(size_t)calloc(1, sizeof(ZylAttrTab));
}

static void zyl_attrh_grow(ZylAttrTab* t) {
    size_t ncap = t->cap ? t->cap * 8 : 4096;
    ZylAttrSlot* ns = (ZylAttrSlot*)calloc(ncap, sizeof(ZylAttrSlot));
    if (!ns) zyl_arena_oom(ncap * sizeof(ZylAttrSlot), "attribute table");
    for (size_t i = 0; i < t->cap; i++) {
        if (!t->slots[i].key) continue;
        size_t j = zyl_span_hash(t->slots[i].key) & (ncap - 1);
        while (ns[j].key) j = (j + 1) & (ncap - 1);
        ns[j] = t->slots[i];
    }
    free(t->slots);
    t->slots = ns;
    t->cap = ncap;
}

long long zyl_attrh_set(long long th, long long node, long long val) {
    ZylAttrTab* t = (ZylAttrTab*)(size_t)th;
    if (!t || !node) return 0;
    if (t->len * 10 >= t->cap * 7) zyl_attrh_grow(t);
    uintptr_t k = (uintptr_t)(size_t)node;
    size_t m = t->cap - 1;
    size_t i = zyl_span_hash(k) & m;
    while (t->slots[i].key && t->slots[i].key != k) i = (i + 1) & m;
    if (!t->slots[i].key) { t->slots[i].key = k; t->len++; }
    t->slots[i].val = val;
    return 0;
}

static ZylAttrSlot* zyl_attrh_find(ZylAttrTab* t, long long node) {
    if (!t || !node || !t->cap) return NULL;
    uintptr_t k = (uintptr_t)(size_t)node;
    size_t m = t->cap - 1;
    size_t i = zyl_span_hash(k) & m;
    while (t->slots[i].key) {
        if (t->slots[i].key == k) return &t->slots[i];
        i = (i + 1) & m;
    }
    return NULL;
}

long long zyl_attrh_get_or(long long th, long long node, long long dflt) {
    ZylAttrSlot* s = zyl_attrh_find((ZylAttrTab*)(size_t)th, node);
    return s ? s->val : dflt;
}

long long zyl_attrh_has(long long th, long long node) {
    return zyl_attrh_find((ZylAttrTab*)(size_t)th, node) ? 1 : 0;
}

long long zyl_attrh_copy(long long th, long long dst, long long src) {
    ZylAttrSlot* s = zyl_attrh_find((ZylAttrTab*)(size_t)th, src);
    if (s) zyl_attrh_set(th, dst, s->val);
    return 0;
}

long long zyl_attrh_clear(long long th) {
    ZylAttrTab* t = (ZylAttrTab*)(size_t)th;
    if (!t || !t->cap) return 0;
    memset(t->slots, 0, t->cap * sizeof(ZylAttrSlot));
    t->len = 0;
    return 0;
}

long long zyl_ref_new(long long v) {
    long long* r = (long long*)malloc(sizeof(long long));
    if (!r) zyl_arena_oom(8, "ref cell");
    *r = v;
    return (long long)(size_t)r;
}
long long zyl_ref_get(long long r) { return *(long long*)(size_t)r; }
long long zyl_ref_set(long long r, long long v) { *(long long*)(size_t)r = v; return 0; }

long long zyl_getenv_str(long long name) {
    const char* v = name ? getenv((const char*)(size_t)name) : NULL;
    return (long long)(size_t)(v ? v : "");
}

/* A zeroed text buffer of `n` bytes from `arena` (`StrBuf`), and the same
   buffer read as a String: a StrBuf is a NUL-terminated char buffer that
   zyl_str_append extends in place, so both views are the same pointer. */
long long zyl_strbuf_new(long long arena, long long n) {
    return zyl_arena_alloc_zeroed(arena, n > 0 ? n : 1);
}
long long zyl_strbuf_str(long long b) { return b; }

/* A union-find class's id, for ordering classes by creation. */
long long zyl_uf_id(long long a) { return a; }

/* Whether src[start, end) holds only escapes zyl_cstr_decode accepts
   (the lexer asks before decoding, so decode's 0 is never a String). */
long long zyl_cstr_escapes_ok(long long src, long long start, long long end) {
    if (!src) return 0;
    const char* s = (const char*)(size_t)src;
    long long i = start;
    while (i < end) {
        if (s[i] == '\\') {
            if (i + 1 >= end) return 0;
            char n = s[i + 1];
            if (n == 'n' || n == 't' || n == 'r' || n == '0' || n == '"' || n == '\\' || n == 'e') i += 2;
            else if (n == 'x' && i + 3 < end && zyl_hexval(s[i + 2]) >= 0 && zyl_hexval(s[i + 3]) >= 0) i += 4;
            else return 0;
        } else i += 1;
    }
    return 1;
}
