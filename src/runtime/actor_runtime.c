#include "actor_runtime.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

static ZylActorSystem g_system;

__attribute__((constructor))
static void zyl_actor_system_init(void) {
    zyl_actor_init();
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
    if (!actor->alive) {
        free(msg);
        return;
    }

    ZylMessage* m = (ZylMessage*)malloc(sizeof(ZylMessage));
    if (!m) {
        free(msg);
        return;
    }
    m->data = msg;
    m->next = NULL;

    if (actor->mailbox_tail) {
        actor->mailbox_tail->next = m;
    } else {
        actor->mailbox_head = m;
    }
    actor->mailbox_tail = m;
    actor->mailbox_count++;
}

void* zyl_actor_thread_entry(void* arg) {
    uint32_t id = (uint32_t)(size_t)arg;
    if (id >= ZYL_MAX_ACTORS) return NULL;

    ZylActor* actor = &g_system.actors[id];
    actor->running = 1;

    /* Run the entry function. */
    if (actor->entry) {
        actor->entry(actor->state);
    }

    /* Actor entry done — loop processing mailbox until actor dies. */
    while (actor->alive) {
        ZylMessage* msg = NULL;

        /* Spin-lock free: poll mailbox (deterministic, no mutex). */
        if (actor->mailbox_head) {
            msg = actor->mailbox_head;
            actor->mailbox_head = msg->next;
            if (!actor->mailbox_head) {
                actor->mailbox_tail = NULL;
            }
            actor->mailbox_count--;
        }

        if (msg) {
            free(msg->data);
            free(msg);
        }
    }

    actor->running = 0;
    return NULL;
}
