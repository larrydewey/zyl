# Zyl Specification — Actors and Concurrency

**Canonical authority:** `zyl_specification.txt` §15
**Related:** `spec/06-capability-types.md`, `spec/07-region-memory-model.md`
**Implementation:** Type checking in `src/type_inference.rs`; runtime deferred

---

## Actor Model

An actor consists of:
- Private state
- FIFO mailbox

### Operations

| Operation | Description |
|-----------|-------------|
| `spawn` | Create a new actor running the given closure |
| `send` | Send a message to an actor's mailbox |

### Rules

1. No shared mutable state between actors.
2. Messages must be Send-capable (TCap or TAtomic).
3. Deterministic FIFO per actor.
4. Actors are isolated; no direct memory sharing.

### Region Rules for Actors

- **R3:** Actor transfer → Heap region
- Spawned closures must only capture Send-capable variables (TCap/TAtomic)

---

## 15. Formal Model

### Actor State

```
Actor = { state: Region, mailbox: FIFO<Message> }
```

### Spawn Semantics

```
spawn Expr → ActorRef(ID)
```

1. Evaluate Expr to closure.
2. Create new actor with isolated state.
3. Capture Send-capable variables from enclosing environment.
4. Return ActorRef pointing to new actor.

### Send Semantics

```
send ActorRef Expr
```

1. Evaluate Expr to message value.
2. Enqueue message in actor's FIFO mailbox.
3. Message must be Send-capable.

---

## Implementation Status

Type checking for `spawn`/`send` is implemented.
Runtime actor execution is deferred.
