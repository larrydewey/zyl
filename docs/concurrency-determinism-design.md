# Deterministic Concurrency: Design

Status: stage 1 done (2026-09-28): channels, ownership, closing, deadlock
detection, per-actor output, actor panic isolation, and the mailbox API removed.
Next: the deterministic and chaos schedulers. This implements the decision
recorded in PROGRESS.md ("Deferred design work"): Kahn process networks
replace multi-sender mailboxes, so a program's observable output never
depends on scheduling (spec §27).

## Why the current model is not deterministic

Today an actor has one mailbox that any actor may send to, and `receive`
takes whatever arrived first. With two senders, the arrival order depends
on the scheduler, and so does everything the receiver computes from it.
`receive` is also untyped (spec §4.8's one known hole).

## Model

A Kahn process network is deterministic by construction. Each process is a
sequential program. It communicates only through FIFO channels that have
exactly one writer and one reader. A read blocks until a value arrives,
and a process cannot test whether a channel is empty. A process's output
sequence is then a function of its input sequences alone, whatever the
scheduling.

- `(chan n)` creates a channel with a buffer of n >= 1 values of one type
  T, and returns a `(Chan T)`. Its two endpoints are `(chan-tx c) : (Tx T)`
  and `(chan-rx c) : (Rx T)`.
- `(chan-send tx v)` appends v, blocking while the buffer is full.
  `(chan-recv rx)` removes the oldest value, blocking while the buffer is
  empty. There is no select, no try-receive and no emptiness test.
- **Single writer, single reader.** Each endpoint belongs to one actor at a
  time. The creator owns both. Ownership moves only at two defined
  program points:
  - `spawn` of a closure that captures the endpoint, since the capture list
    is known at compile time;
  - sending the endpoint over another channel.

  Using an endpoint the current actor does not own is
  `E_CHANNEL_NOT_OWNER`. The error is deterministic, because ownership
  only changes at those program points.
- **Closing.** When the actor that owns a `Tx` finishes, the channel
  closes. A `chan-recv` on a closed, empty channel is `E_CHANNEL_CLOSED`,
  a fixed error at a fixed point in the reader's sequence.
- **Deadlock.** When every live actor is blocked, the runtime raises
  `E_DEADLOCK`. In a Kahn network the set of blocked processes does not
  depend on scheduling, so the error is deterministic too.
- **Values.** Only TCap (immutable, shareable) values cross a channel (the
  spec's Send-capable rule). A TAtomic may be passed only for commutative
  writes (add/or/and), and may be read only after joining every writer.
- **Panics.** An actor's uncaught panic ends only that actor.
  `actor-wait` re-raises it, and at exit the first unjoined one in spawn
  order is reported with status 1. After an uncaught panic on main, the
  actors are abandoned.
- **Output.** An actor's `print`s go to its own output buffer, not to
  stdout. The buffer is emitted:
  - when the actor is joined (`actor-wait`);
  - at program exit for unjoined actors, in spawn order.

  Main's own output goes straight to stdout. So a program's stdout is the
  same sequence on every run.

## Scheduling

- The default is one thread per actor (runtime/rt/thread.zyl). Kahn
  determinism makes the output independent of the interleaving.
- `--sched=deterministic` runs the same program with exactly one actor
  running at a time. Control passes in a fixed order at each blocking
  point, which makes the run reproducible even when debugging.
- A seeded chaos mode, `ZYL_SCHED_CHAOS=<seed>` (tests only), inserts
  yields at channel operations. The test suite runs every actor test
  under the default, deterministic and several chaos schedules, and
  requires byte-identical output.

## Migration

- `send`/`receive`/`actor-self` mailboxes are removed. This breaking change
  was accepted on 2026-09-24. `spawn` returns an `Actor` that can only be
  joined (`actor-wait`) or queried (`actor-is-alive`, true until joined).
  `actor-terminate` is removed: stopping an actor partway through is a
  race.
- The stdlib (`stdlib/actor`), tests, examples, book, spec §15 and §27, and
  the LSP builtin list are updated together.

## Implementation plan

1. Runtime: channel objects are a futex-guarded ring buffer with
   `{owner-tx, owner-rx, closed}`. There is a per-actor output buffer,
   blocked-actor accounting for deadlock detection, and the deterministic
   and chaos schedulers.
2. Compiler:
   - builtins `chan`, `chan-tx`, `chan-rx`, `chan-send` and `chan-recv`,
     typed `(Chan T)`, `(Tx T)` and `(Rx T)` (type_annotate.zyl);
   - spawn lowering transfers the ownership of captured endpoints;
   - E_CHANNEL_NOT_OWNER, E_CHANNEL_CLOSED and E_DEADLOCK join the spec
     §28 error catalog.
3. The old mailbox API is removed and the tests are ported. New tests cover
   pipelines, fan-in through one channel per producer, closing, deadlock,
   ownership errors and output ordering, under all three schedules.
