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

#endif
