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

1. **No shared mutable state between actors** (spec §7.4), checked by
   type after inference (`stdlib/compiler/share_check.zyl`). A spawned
   closure's captures (inline, `let`-bound, or through a parameter a
   callee spawns or captures), a value sent on a channel, and every
   top-level def an actor's code reaches through calls must not be, or
   hold in a struct, variant, tuple, Option, list or closure, a
   `let-mut`, a `ByteBuf`/`ByteSlice`, a `Ref`, or another handle written
   in place (`WVec`, `SMap`, `Attr`, `Array`, `Words`, `StrBuf`, `UF`,
   `Arena`, `Pin`): `E_CAPABILITY_LEAK`. A `Secret` is `E_SECRET_ESCAPE`.
   Persistent `Vec`, `IntMap` and `Slice` are checked by their elements.
   A crossing closure whose captures cannot be seen (a call result, a
   field) fails closed. Within one actor all of these stay usable.
2. **AtomicBuf** (`atomic/atomic`) is the one buffer that crosses, as a
   direct capture of the spawned closure only. While held it takes only
   `atomicbuf-add`, `-max`, `-min`, `-and`, `-or`, `-xor` on a slot,
   which commute and return nothing; there is no read, store, CAS or
   fetch-add. An actor holds it from its spawn until the actor that
   spawned it joins it. `atomicbuf-freeze!` (a move) copies the slots
   into a readable `AtomicView` when no holder remains, else
   `E_ATOMIC_SHARED` (`atomicbuf-freeze?`: `None`); `atomicbuf-held` asks.
   A slot is a 128-bit sum or a 64-bit value plus the set of update kinds
   seen, so the frozen contents are a function of the multiset of
   updates, and a read reports two kinds as `E_MUT_CONFLICT` and a sum
   outside Int as `E_OVERFLOW`. The full argument is spec §7.4.
3. **One owner per endpoint.** The creator owns both ends. Ownership
   moves only at two points:
   - a spawned closure that captures the endpoint directly (as a free
     variable), which moves it to the new actor;
   - an endpoint sent on a channel, which belongs to its receiver.

   Any other use is `E_CHANNEL_NOT_OWNER`. An endpoint nested inside
   another captured value does not move.
4. **Closing.** When the owner of a `Tx` finishes, the channel closes.
   Main finishes when its program ends. A `chan-recv` on a closed,
   drained channel is `E_CHANNEL_CLOSED`.
5. **Deadlock.** When every live actor is blocked on a channel or a join,
   the program prints what the actors wrote so far (spawn order), then
   `PANIC: E_DEADLOCK`, and exits with status 1.
6. **Output.** An actor's stdout is buffered and emitted when the actor
   is joined, or at exit, in spawn order, for actors that were never
   joined. Program exit joins every actor.
7. **Panics.** An actor's uncaught panic ends only that actor.
   `actor-wait` re-raises it, and it can be caught. At exit, the first
   unjoined actor panic in spawn order is reported and the status is 1.
   After an uncaught panic on main, actors are abandoned and their output
   is dropped.
8. **Exit and stack overflow.** `(exit c)` in an actor ends only that
   actor; when it is joined (by `actor-wait`, or at exit in spawn order)
   its output is emitted and the joiner exits with status `c`. An actor's
   stack overflow likewise stops the program with `E_STACK_OVERFLOW`
   (status 1, not catchable) when the actor is joined, after its output,
   so both land at the same point under every schedule.
9. At most 1024 actors per program (`E_ACTOR_LIMIT`).

### Region rules

- **R2:** a value sent on a channel escapes, so it goes to the Heap.
- **R3:** spawn and chan-send take only values that hold no in-place
  mutable handle (rule 1); an AtomicBuf crosses spawn as a direct capture.

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
- AtomicBuf holders: at spawn the runtime scans the closure's
  environment words (and the interpreter's moved block) for AtomicBuf
  headers, as it does for endpoints, adds the new actor to each one's
  holder count and records the spawner; `actor-wait` by that spawner
  releases them (`runtime/rt/actor.zyl`, `abuf.zyl`). A slot's add is a
  `lock xadd` on its low word with the carry and sign added to its high
  word, so the 128-bit total is exact once every add has finished.
- The toolchain's own modules (`compiler/`, `lsp/`, `repl/`) are not
  share-checked: the REPL's actor shares interpreter environment cells
  that only `set!` writes, and the interpreted program was checked.
