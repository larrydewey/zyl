# Zyl Specification — Actors and Concurrency

**Canonical authority:** `zyl_specification.txt` §15 (also §7.4, §9.1 R2/R3, §31.9 `actor`)
**Related:** `spec/06-capability-types.md`, `spec/07-region-memory-model.md`
**Implementation:** `stdlib/compiler/expr_inner.zyl` (`parse-spawn`, `parse-send`), `stdlib/compiler/icnf.zyl` (lowering), `stdlib/compiler/mutability_check.zyl` (capture checks), `runtime/actor_runtime.c` (runtime), `stdlib/actor/actor.zyl` (library)

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

- **R2:** A value sent to an actor escapes → Heap.
- **R3:** spawn/send requires a Send-capable type.
- Spawned closures must only capture Send-capable variables (TCap/TAtomic) (§7.4).

---

## Elaborated Model

The canonical §15 states only the rules above. The model below is this
document's elaboration of them.

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

## Implementation Notes

Not normative.

### What works

- `(spawn (fn () body))` starts an actor and returns its id; `(send a msg)`
  enqueues a message. They lower to the runtime calls `zyl_actor_spawn` and
  `zyl_actor_send`.
- Each actor is an OS thread (`pthread_create`) with its own mutex,
  condition variable and linked-list mailbox; messages are delivered in
  FIFO order per actor.
- `stdlib/actor/actor.zyl` adds `actor-spawn`, `actor-send`,
  `actor-send-with-timeout`, `actor-is-alive`, `actor-wait` and
  `actor-terminate`.
- `mutability_check.zyl` rejects a spawned closure or a sent message that
  refers to an in-scope `let-mut` binding (`E_CAPABILITY_LEAK`), and
  `secret_check.zyl` rejects a Secret reaching `spawn` or `send`
  (`E_SECRET_ESCAPE`). In a package, `spawn`, `send` and `receive` need the
  `actor` capability (§31.9).

### Differences from §15

- **`(receive)` takes the next data message** from the running actor's
  mailbox (`zyl_actor_receive`), blocking until one arrives, and
  `(actor-self)` is the running actor's id; `main` has a mailbox too, so
  actors can exchange structured messages and replies
  (`tests/regression/actor-receive.zyl`).
- **Typing.** `spawn` and `actor-self` are `Actor`, `send` requires an
  `Actor` as its target and is `Unit`, and the entry passed to `spawn`
  is `() -> a`. `receive` is `a`: a mailbox holds whatever any sender put
  there, so its result takes whatever type the receiver uses it at. This
  is the one exception spec §4.8 names to the soundness guarantee; typed
  single-sender channels are to replace mailboxes and remove it.
- **Scheduling is not deterministic.** Actors are scheduled by the
  operating system; nothing orders the interleaving of output from two
  actors. This is at odds with P1 and §27 for programs whose observable
  output depends on that interleaving.
- **Send-capability is checked syntactically** (the `let-mut` rule above),
  not by type; no type carries Send-capability.
