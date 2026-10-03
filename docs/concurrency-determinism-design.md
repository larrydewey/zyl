# Deterministic Concurrency: Design

Status: done (2026-09-28). Stage 1 covers channels, ownership, closing,
deadlock detection, per-actor output, actor panic isolation, and removing
the mailbox API. Stage 2 adds the deterministic and chaos schedules and a
test category that compares them. This implements the decision
recorded in PROGRESS.md ("Deferred design work"): Kahn process networks
replace multi-sender mailboxes, so a program's observable output never
depends on scheduling (spec §27).

## Why mailboxes were not deterministic

Before 2026-09-28 an actor had one mailbox that any actor could send to,
and `receive` took whatever arrived first. With two senders, the arrival
order depended on the scheduler, and so did everything the receiver
computed from it. `receive` was also untyped (spec §4.8's one known
hole).

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
- **Values.** Only immutable (`let`) or atomic bindings cross a channel
  (the spec's Send-capable rule). `mutability_check.zyl` enforces it
  syntactically: a closure passed to `spawn`, or a value passed to
  `chan-send`, that references a `let-mut` binding of the enclosing scope
  is `E_CAPABILITY_LEAK`. There is no atomic type in the language, so a
  copy bound with plain `let` is what crosses.
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
- `ZYL_SCHED=deterministic` runs the same binary with exactly one actor
  running at a time. It is a run-time setting, not a compiler flag, so
  the binary is the same in every mode. A baton passes, at each blocking
  point and when an actor finishes, to the next ready owner in id order.
  That makes the interleaving itself reproducible, which helps when
  debugging.
- `ZYL_SCHED_CHAOS=<seed>` (for tests) gives each channel operation a
  seeded choice: nothing, a yield, or a 20 or 200 µs sleep. The test
  suite's `sched` category runs the actor tests under the default, the
  deterministic and three chaos schedules, and requires byte-identical
  stdout, stderr and exit status. `tests/scripts/actor-schedules.sh`
  does the same for deadlock, exit order and panics.
- Deadlock is checked when an actor blocks, and again when one finishes,
  since a finishing reader can leave its writers stuck.

## Migration

- `send`/`receive`/`actor-self` mailboxes are removed. This breaking change
  was accepted on 2026-09-24. `spawn` returns an `Actor` that can only be
  joined (`actor-wait`) or queried (`actor-is-alive`, true until joined).
  `actor-terminate` is removed: stopping an actor partway through is a
  race.
- The stdlib (`stdlib/actor`), tests, examples, book, spec §15 and §27, and
  the LSP builtin list are updated together.

## Implementation

- Runtime (`runtime/rt/chan.zyl`): a channel is a ring buffer under the
  scheduler's one lock and condition variable, with its owners and a
  closed flag; per-owner blocked state for deadlock detection; the
  deterministic baton and the chaos seed. Per-actor output buffers are
  in `out.zyl`, spawn and join in `actor.zyl`.
- Compiler: the builtins are typed in `type_annotate.zyl`; `chan-send`
  reuses the `ESend` node, so the let-mut and Secret checks apply; spawn
  moves the endpoints a closure captures directly. An endpoint nested
  inside a captured value does not move (open).
- The REPL interpreter spawns a compiled closure that interprets the
  body; `zyl_chan_spawn_moves` names the interpreted closure's env block,
  whose endpoints move at the same spawn.
- Tests: `tests/regression/channels.zyl`, `concurrency.zyl`,
  `actors.zyl`, `runtime-actors.zyl`, the `sched` category and
  `tests/scripts/actor-schedules.sh`.
