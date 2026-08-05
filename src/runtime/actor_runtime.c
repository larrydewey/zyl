#include "actor_runtime.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

#define ZYL_HEAP_ARENA_DEFAULT_BLOCK (1024 * 1024)
#define ZYL_PIN_ARENA_DEFAULT_BLOCK (256 * 1024)

static ZylActorSystem g_system;
static void* g_heap_arena = NULL;
static void* g_pin_arena = NULL;

void zyl_ensure_arenas(void) {
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
    if (!g_system.initialized || actor_id >= ZYL_MAX_ACTORS) {
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
    if (!g_system.initialized || actor_id >= ZYL_MAX_ACTORS) {
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
       a send lands after the consumer already drained an empty mailbox). */
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

    for (uint32_t i = 0; i < ZYL_MAX_ACTORS; i++) {
        ZylActor* actor = &g_system.actors[i];
        pthread_mutex_lock(&actor->lock);
        int active = !actor->joined && (actor->running || actor->thread);
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
}

/* ==========================================================================
   FFI pinning — copy an 8-byte value to a stable heap location and back.
   ========================================================================== */

void* ffi_pin(long long value) {
    if (!g_pin_arena) return NULL;
    long long* slot = (long long*)zyl_arena_alloc((long long)(size_t)g_pin_arena, sizeof(long long));
    if (slot) *slot = value;
    return (void*)slot;
}

void ffi_unpin(void* ptr) {
    free(ptr);
}

/* ==========================================================================
   Raw memory arena — foundation for stdlib/allocator.
   Pointers are passed to/from Zyl as Int (64-bit).
   ========================================================================== */

long long zyl_mem_alloc(long long size) {
    return (long long)(size_t)malloc((size_t)size);
}

void zyl_mem_free(long long ptr) {
    free((void*)(size_t)ptr);
}

long long zyl_mem_read(long long ptr) {
    return *(volatile long long*)(size_t)ptr;
}

void zyl_mem_write(long long ptr, long long value) {
    *(volatile long long*)(size_t)ptr = value;
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
    ZylArenaBlock* b = zyl_arena_new_block_of(a, bs);
    if (!b) {
        free(a);
        return 0;
    }
    return (long long)(size_t)a;
}

long long zyl_arena_alloc(long long arena, long long size) {
    if (!arena || size < 0) return 0;
    ZylArena* a = (ZylArena*)(size_t)arena;
    size_t need = zyl_arena_align_up((size_t)size);
    ZylArenaBlock* b = a->head;
    if (!b || b->used + need > b->cap) {
        b = zyl_arena_new_block_of(a, need);
        if (!b) return 0;
    }
    char* p = b->mem + b->used;
    b->used += need;
    a->total_used += need;
    fprintf(stderr, "DBG zyl_arena_alloc: arena=%p, need=%zu, mem=%p, used=%zu, p=%p\n", (void*)arena, need, (void*)b->mem, (size_t)b->used, (void*)p);
    return (long long)(size_t)p;
}

long long zyl_arena_alloc_zeroed(long long arena, long long size) {
    if (!arena || size < 0) return 0;
    ZylArena* a = (ZylArena*)(size_t)arena;
    size_t need = zyl_arena_align_up((size_t)size);
    ZylArenaBlock* b = a->head;
    if (!b || b->used + need > b->cap) {
        b = zyl_arena_new_block_of(a, need);
        if (!b) return 0;
    }
    char* p = b->mem + b->used;
    b->used += need;
    a->total_used += need;
    memset(p, 0, (size_t)size);
    return (long long)(size_t)p;
}

void zyl_arena_reset(long long arena) {
    if (!arena) return;
    ZylArena* a = (ZylArena*)(size_t)arena;
    ZylArenaBlock* b = a->head;
    while (b) {
        ZylArenaBlock* next = b->next;
        free(b->mem);
        free(b);
        b = next;
    }
    a->head = NULL;
    a->total_capacity = 0;
    a->total_used = 0;
}

void zyl_arena_destroy(long long arena) {
    if (!arena) return;
    ZylArena* a = (ZylArena*)(size_t)arena;
    ZylArenaBlock* b = a->head;
    while (b) {
        ZylArenaBlock* next = b->next;
        free(b->mem);
        free(b);
        b = next;
    }
    free(a);
}

long long zyl_arena_used(long long arena) {
    if (!arena) return 0;
    return (long long)((ZylArena*)(size_t)arena)->total_used;
}

long long zyl_arena_capacity(long long arena) {
    if (!arena) return 0;
    return (long long)((ZylArena*)(size_t)arena)->total_capacity;
}

/* ==========================================================================
   Region-specific arena allocation wrappers for codegen.
   Heap arena: for escaped values, structs, variants, closures, actor data.
   Pin arena: for FFI-safe stable memory (non-moving).
   ========================================================================== */

long long zyl_heap_alloc(long long size) {
    if (!g_heap_arena || size <= 0) return 0;
    return zyl_arena_alloc((long long)(size_t)g_heap_arena, size);
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

void zyl_atomic_store(long long addr, long long value) {
    __atomic_store_n((long long*)(size_t)addr, value, __ATOMIC_SEQ_CST);
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
    if (!g_system.initialized || actor_id < 0 || actor_id >= ZYL_MAX_ACTORS) {
        return 0;
    }
    ZylActor* actor = &g_system.actors[(uint32_t)actor_id];
    pthread_mutex_lock(&actor->lock);
    int alive = actor->alive ? 1 : 0;
    pthread_mutex_unlock(&actor->lock);
    return alive;
}

void zyl_actor_terminate(long long actor_id) {
    if (!g_system.initialized || actor_id < 0 || actor_id >= ZYL_MAX_ACTORS) {
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
    if (!g_system.initialized || actor_id < 0 || actor_id >= ZYL_MAX_ACTORS) {
        return;
    }
    ZylActor* actor = &g_system.actors[(uint32_t)actor_id];
    pthread_mutex_lock(&actor->lock);
    int active = !actor->joined && actor->thread ? 1 : 0;
    pthread_t t = actor->thread;
    pthread_mutex_unlock(&actor->lock);
    if (active) {
        pthread_join(t, NULL);
        pthread_mutex_lock(&actor->lock);
        actor->joined = 1;
        pthread_mutex_unlock(&actor->lock);
    }
}
