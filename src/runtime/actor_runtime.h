#ifndef ZYL_ACTOR_RUNTIME_H
#define ZYL_ACTOR_RUNTIME_H

#include <stddef.h>
#include <stdint.h>
#include <pthread.h>

#define ZYL_MAX_ACTORS 1024
#define ZYL_MAX_MAILBOX 256

typedef enum {
    ZYL_MSG_DATA = 0,
    ZYL_MSG_CLOSURE = 1
} ZylMessageKind;

typedef struct ZylClosureMsg {
    void (*fn)(void*);
    void* state;
} ZylClosureMsg;

typedef struct ZylMessage {
    ZylMessageKind kind;
    void* data;
    struct ZylMessage* next;
} ZylMessage;

typedef struct ZylActor {
    void (*entry)(void*);
    void* state;
    ZylMessage* mailbox_head;
    ZylMessage* mailbox_tail;
    uint32_t mailbox_count;
    pthread_t thread;
    int alive;
    int running;
} ZylActor;

typedef struct {
    ZylActor actors[ZYL_MAX_ACTORS];
    uint32_t next_id;
    int initialized;
} ZylActorSystem;

void zyl_actor_init(void);
uint32_t zyl_actor_spawn(void (*entry)(void*), void* state);
void zyl_actor_send(uint32_t actor_id, void* msg);
void zyl_actor_send_data(uint32_t actor_id, void* data);
void zyl_actor_send_closure(uint32_t actor_id, void (*fn)(void*), void* state);
void zyl_actor_wait_all(void);
void* zyl_actor_thread_entry(void* arg);
long long zyl_actor_is_alive(long long actor_id);
void zyl_actor_terminate(long long actor_id);
void zyl_actor_wait(long long actor_id);

/* FFI pinning. */
void* ffi_pin(long long value);
void ffi_unpin(void* ptr);

/* Raw memory arena. */
long long zyl_mem_alloc(long long size);
void zyl_mem_free(long long ptr);
long long zyl_mem_read(long long ptr);
void zyl_mem_write(long long ptr, long long value);

/* Atomic operations. */
long long zyl_atomic_load(long long addr);
void zyl_atomic_store(long long addr, long long value);
long long zyl_atomic_add(long long addr, long long value);
long long zyl_atomic_sub(long long addr, long long value);
long long zyl_atomic_max(long long addr, long long value);
long long zyl_atomic_min(long long addr, long long value);
long long zyl_atomic_cas(long long addr, long long expected, long long new_value);
long long zyl_atomic_fetch_add(long long addr, long long value);

#endif
