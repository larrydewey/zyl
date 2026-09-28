# Zyl Specification — Actors and Concurrency

**Canonical authority:** `zyl_specification.txt` §15 (also §7.4, §9.1 R2/R3, §27, §31.9 `actor`)
**Related:** `spec/06-capability-types.md`, `spec/07-region-memory-model.md`, `docs/concurrency-determinism-design.md`
**Implementation:** `stdlib/compiler/expr_inner.zyl` (`parse-spawn`, `parse-send` for `chan-send`), `stdlib/compiler/type_annotate.zyl` (channel types), `stdlib/compiler/icnf.zyl` (lowering), `stdlib/compiler/mutability_check.zyl` and `secret_check.zyl` (capture and send checks), `runtime/rt/chan.zyl`, `actor.zyl`, `out.zyl` and `thread.zyl` (runtime), `stdlib/actor/actor.zyl` (library)

---

## Model: Kahn process networks

An actor is a sequential process with private state. Actors communicate
only through channels. Each channel is a FIFO with exactly one writer and
one reader, and a read blocks until a value arrives. No process can test
whether a channel is empty. So each process's output sequence is a
function of its input sequences, and the program's observable output
does not depend on scheduling (§27).

### Operations

| Form | Type | Meaning |
|------|------|---------|
| `(spawn f)` | `(() -> a) -> Actor` | start an actor running `f` |
| `(chan n)` | `Int -> (Chan a)` | a channel buffering 1..n values; otherwise `E_CHANNEL_CAPACITY` |
| `(chan-tx c)` | `(Chan a) -> (Tx a)` | the sending end |
| `(chan-rx c)` | `(Chan a) -> (Rx a)` | the receiving end |
| `(chan-send tx v)` | `(Tx a) a -> Unit` | append, blocking while full |
| `(chan-recv rx)` | `(Rx a) -> a` | remove the oldest, blocking while empty |
| `(actor-wait a)` | `Actor -> Unit` | join (from `actor/actor`) |
| `(actor-is-alive a)` | `Actor -> Bool` | true until joined |

There is no select, no non-blocking receive and no emptiness test.

### Rules

1. No shared mutable state between actors. Channel values and spawned
   captures must be Send-capable (TCap or TAtomic, §7.4). A `let-mut`
   binding is rejected (`E_CAPABILITY_LEAK`), and so is a `Secret`
   (`E_SECRET_ESCAPE`).
2. **One owner per endpoint.** The creator owns both ends. Ownership
   moves only at two points:
   - a spawned closure that captures the endpoint directly (as a free
     variable), which moves it to the new actor;
   - an endpoint sent on a channel, which belongs to its receiver.

   Any other use is `E_CHANNEL_NOT_OWNER`. An endpoint nested inside
   another captured value does not move.
3. **Closing.** When the owner of a `Tx` finishes, the channel closes.
   Main finishes when its program ends. A `chan-recv` on a closed,
   drained channel is `E_CHANNEL_CLOSED`.
4. **Deadlock.** When every live actor is blocked on a channel or a join,
   the program prints what the actors wrote so far (spawn order), then
   `PANIC: E_DEADLOCK`, and exits with status 1.
5. **Output.** An actor's stdout is buffered and emitted when the actor
   is joined, or at exit, in spawn order, for actors that were never
   joined. Program exit joins every actor.
6. **Panics.** An actor's uncaught panic ends only that actor.
   `actor-wait` re-raises it, and it can be caught. At exit, the first
   unjoined actor panic in spawn order is reported and the status is 1.
   After an uncaught panic on main, actors are abandoned and their output
   is dropped.
7. At most 1024 actors per program (`E_ACTOR_LIMIT`).

### Region rules

- **R2:** a value sent on a channel escapes, so it goes to the Heap.
- **R3:** spawn and chan-send require a Send-capable type.

---

## Implementation Notes

Not normative.

- Each actor is a thread. The thread comes from `clone` when the program
  links freestanding, and from `pthread_create` when it links hosted.
- One scheduler lock and condition word serves every channel. Each owner
  id has a record of what it waits on: room in a channel, a value or a
  close, or another owner finishing. Before blocking, the runtime checks
  whether any live owner can proceed. If none can, that is the deadlock.
- An endpoint is recognized in a closure environment only as a heap
  block with its magic word, whose channel points back at it, so an
  integer can never be taken for one.
- Schedules: the default gives each actor a thread. `ZYL_SCHED=deterministic`
  passes one baton, so only one actor runs at a time, and
  `ZYL_SCHED_CHAOS=<seed>` adds seeded yields and sleeps at channel
  operations. The test suite requires identical output under all three.
- The interpreter (`zyl repl`, `zyl eval`) spawns a compiled closure
  that interprets the body; the interpreted closure's captured endpoints
  move with it (`zyl_chan_spawn_moves`). The REPL joins an entry's
  actors before the prompt returns.
- Not yet enforced by type: Send-capability is still the syntactic
  `let-mut` rule, so a mutable collection reached through an immutable
  binding can still be shared.
