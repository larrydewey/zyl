#include "actor_runtime.h"
long long zyl_ralloc(long long size, long long rp);
static volatile int g_threads_started; /* see ZYL_ARENA_LOCK */
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

/* Lowest address the kernel will ever map on Linux by default
 * (/proc/sys/vm/mmap_min_addr, 0x10000 on most distros; 0x1000 is the
 * conservative floor even on the most permissive configs). Used to reject
 * small bogus integers misused as pointers before dereferencing them. */
#define ZYL_MIN_CALL_ADDR 0x1000LL

static ZylActorSystem g_system;

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
    zyl_arenas_init();
}

__attribute__((destructor))
static void zyl_runtime_cleanup(void) {
    /* An abandoned FFI call may still be using arena memory. */
    if (zyl_ffi_abandoned()) return;
    zyl_arenas_destroy();
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

    g_threads_started = 1;
    zyl_threads_started_mark();
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

void* ffi_pin(long long value) {
    return (void*)(size_t)zyl_pin_word(value);
}

/* Unpinning returns the pinned value; the Pin arena reclaims storage in
 * bulk, so individual slots are never freed here. */
long long ffi_unpin(long long ptr) {
    if (!ptr) return 0;
    if (!zyl_pin_owns(ptr)) {
        fprintf(stderr, "zyl: ffi-unpin: pointer not from ffi-pin/Pin arena\n");
        return 0;
    }
    return *(long long*)(size_t)ptr;
}

/* ==========================================================================
   Raw memory arena — foundation for stdlib/allocator.
   Pointers are passed to/from Zyl as Int (64-bit).
   ========================================================================== */

/* ==========================================================================
   Character-level string access — substrate for the self-hosting lexer.
   ========================================================================== */

/* String views (stdlib text/view): a view is {base, off, len} with
   off + len <= strlen(base), checked once by zyl_view_ok when the view is
   made. The accessors below trust that invariant and never call strlen,
   so they are restricted to the standard library (ffi-raw-p). */

/* Decode a Zyl string literal body (src[start..end], `start` points past the
   opening quote): handle \n \t \" \\ escapes. Returns a NUL-terminated buffer
   in `arena`, or 0 if an escape is unterminated (caller reports a lex error).
   Deterministic: decodes left-to-right in source order. */

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

/* Node attribute tables, string maps and word vectors for compiler passes.
   Keyed by address or content, probed only (never iterated); a miss reads 0. */

typedef struct { uintptr_t key; long long val; } ZylAttrSlot;

/* Process-wide instances, created on first use. */

#include <sys/stat.h>
long long zyl_heap_alloc(long long size);

/* ==========================================================================
   FFI pinning — copy an 8-byte value to a stable Pin arena location and back.
   ========================================================================== */

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
 * through; a bare "E_CODE: text" or "error[E_CODE]: text" is wrapped
 * with its code split off. */
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
    } else if (strncmp(msg, "error[", 6) == 0) {
        /* "error[E_CODE]: text", as the type pass's summary is written. */
        const char* e = strchr(msg + 6, ']');
        if (e && e[1] == ':' && (size_t)(e - msg - 6) < sizeof(code)) {
            memcpy(code, msg + 6, (size_t)(e - msg - 6));
            code[e - msg - 6] = 0;
            text = e + 2;
            while (*text == ' ') text++;
        }
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

/* (exit code): flush buffered output, then end the process. */
long long zyl_exit(long long code) {
    fflush(stdout);
    fflush(stderr);
    exit((int)code);
}

/* (read-line): one line from stdin without its newline; "" at end of input. */
long long zyl_read_line(void) {
    fflush(stdout);
    size_t cap = 128, n = 0;
    char* buf = (char*)malloc(cap);
    if (!buf) return (long long)(size_t)"";
    char c;
    while (read(0, &c, 1) == 1 && c != '\n') {
        if (n + 1 >= cap) { char* nb = (char*)realloc(buf, cap * 2); if (!nb) break; buf = nb; cap *= 2; }
        buf[n++] = c;
    }
    if (n > 0 && buf[n - 1] == '\r') n--;
    char* out = (char*)(size_t)zyl_heap_alloc((long long)n + 1);
    if (out) { memcpy(out, buf, n); out[n] = 0; }
    free(buf);
    return out ? (long long)(size_t)out : (long long)(size_t)"";
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

/* ── CLI helpers (used by the self-hosted driver) ─────────────────────── */
#include <unistd.h>

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
/* The runtime to link: the object boot.sh/install.sh build next to the
   source (actor_runtime.o, -O2) when it is newer than the source, else
   the source itself, compiled with the same flags. */
static int zyl_rt_obj_fresh(void) {
    struct stat so, sc;
    if (stat("actor_runtime.o", &so) != 0 || stat("actor_runtime.c", &sc) != 0) return 0;
    if (so.st_mtim.tv_sec != sc.st_mtim.tv_sec) return so.st_mtim.tv_sec > sc.st_mtim.tv_sec;
    return so.st_mtim.tv_nsec > sc.st_mtim.tv_nsec;
}

static void zyl_cc_argv(char** argv, const char* asm_path, char* out_path) {
    int k = 0;
    argv[k++] = (char*)"cc"; argv[k++] = (char*)"-no-pie"; argv[k++] = (char*)asm_path;
    if (zyl_rt_obj_fresh()) argv[k++] = (char*)"actor_runtime.o";
    else { argv[k++] = (char*)"-O2"; argv[k++] = (char*)"actor_runtime.c"; }
    argv[k++] = (char*)"-o"; argv[k++] = out_path; argv[k++] = (char*)"-lpthread"; argv[k] = NULL;
}

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
    char* argv[8];
    zyl_cc_argv(argv, asm_path, out_path);
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
    char* argv[8];
    zyl_cc_argv(argv, asm_path, out_path);
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

/* Terminal entries live in runtime/rt/os.zyl; stdio's flush and atexit stay here. */
long long zyl_term_flush(void) {
    fflush(stdout);
    return 0;
}

/* Registers the Zyl restore handler once (no code-address primitive yet). */
long long zyl_term_atexit(void) {
    atexit(zyl_term_restore_atexit);
    return 0;
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

/* The interpreter's test registry. A `(test "name" ...)` form lowers to
   a zyl_register_test call whose second argument is the address of the
   generated test function -- which, under the interpreter, is not an
   address at all but an interpreter value. So the interpreter keeps its
   own registry of those values and runs the tests itself, printing what
   zyl_run_tests prints, character for character, because the regression
   suite compares the two outputs. */

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

/* Milliseconds on a monotonic clock. The REPL's `:time` uses it; it is
   deliberately not available to a compiled program's determinism-
   sensitive paths through any other name, and nothing in the compiler
   calls it. */
#include <time.h>

/* The other direction, for a word the interpreter knows points at
   NUL-terminated bytes. Also the identity; also there for the type
   system rather than the machine. */

/* The IEEE-754 bit pattern of a Float, as an Int (a Float travels in a
   general register as its bits, so this is the identity too). Typed
   Float -> Int, it is how Hash hashes a Float without a cast. */

/* The Float whose IEEE-754 bit pattern is `w`. Every 64-bit pattern is
   some double (a NaN at worst), so this is total and safe to expose. */

/* Raw word access for the interpreter, which runs word-level ICNF: the
   word at address `a`, and a store to it. Typed Int -> Int and
   Int Int -> Unit; they are raw memory access, so the checker only lets
   the standard library call them (arity_check.zyl, E_FFI_RESTRICTED). */

/* `p` advanced by `n` bytes. */

/* The NUL-terminated bytes at `p`, as a String (the identity). */

/* zyl_ffi_lookup as an address word, for the interpreter's ISymAddr and
   its calls through zyl_call_argv (FnPtr is opaque to Zyl code). */
long long zyl_ffi_lookup(long long name);
long long zyl_ffi_addr(long long name) { return zyl_ffi_lookup(name); }

/* Decimal text of an integer, heap-allocated. zyl_cstr_from_int needs
   an arena; the interpreter has heap values and no arena of its own. */

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
    X(zyl_cstr_key_matches) X(zyl_div_magic) X(zyl_div_shift) X(zyl_array_copy) X(zyl_view_ok) X(zyl_view_byte) X(zyl_view_cmp) X(zyl_view_find) X(zyl_view_copy) \
    X(zyl_cstr_last_newline) X(zyl_cstr_len) X(zyl_cstr_of_word) X(zyl_float_bits) X(zyl_float_of_bits) X(zyl_word_load) X(zyl_word_store) X(zyl_ptr_add) X(zyl_ptr_cstr) X(zyl_ffi_addr) \
    X(zyl_cstr_sanitize) X(zyl_cstr_sub) X(zyl_cstr_substr) \
    X(zyl_cstr_to_int) X(zyl_cstr_to_int_base) X(zyl_diag_json) \
    X(zyl_diag_json_set) X(zyl_dirname_cstr) \
    X(zyl_attr_clear) X(zyl_attr_copy) X(zyl_attr_get) X(zyl_attr_set) \
    X(zyl_ensure_arenas) X(zyl_exec_cmd) X(zyl_f_add) \
    X(zyl_f_cmp) X(zyl_f_div) X(zyl_f_error) \
    X(zyl_f_mul) X(zyl_f_of_int) X(zyl_f_parse) \
    X(zyl_f_rem) X(zyl_f_sub) X(zyl_f_text) \
    X(zyl_f_to_int) X(zyl_ffi_lookup) X(zyl_ffi_timed) X(zyl_ffi_timed_argv) X(zyl_file_close_c) X(zyl_exit) X(zyl_read_line) \
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
    g_threads_started = 1;
    zyl_threads_started_mark();
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

/* print, in each of the three shapes codegen emits, so that interpreted
   output is byte-identical to compiled output. */
long long zyl_print_int(long long n) { printf("%lld\n", n); return 0; }
long long zyl_print_str(long long s) { printf("%s\n", (const char*)(size_t)s); return 0; }
long long zyl_print_float(long long bits) { printf("%f\n", zyl_d_of(bits)); return 0; }

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

