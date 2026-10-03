# Chapter 21: Actor Concurrency Model

Complete reference for Zyl's actor system: the model the specification defines, the forms the compiler accepts, the runtime that executes them, and the compile-time checks on what may cross between actors.

The normative text is spec v5.0 §15 (concurrency model), §7.4 (closures and concurrency), §9.1 rules R2 and R3, §27 (determinism) and §31.9 (the `actor` capability). The implementation is split across `stdlib/compiler/expr_inner.zyl` and `icnf.zyl` (parsing and lowering of `spawn` and the channel forms), `stdlib/compiler/type_annotate.zyl` (the channel types), `stdlib/compiler/mutability_check.zyl` and `secret_check.zyl` (the capture and send checks), `runtime/rt/actor.zyl`, `chan.zyl`, `out.zyl` and `thread.zyl` (threads, channels and actor output) and `stdlib/actor/actor.zyl` (joining). The design rationale is `docs/concurrency-determinism-design.md`.

**Implementation status.** Actors, typed channels, endpoint ownership, closing, deadlock detection, per-actor output buffering and actor panic isolation are implemented. The deterministic and chaos schedulers of the design are not. The type-based Send check is not either: Send-capability is still the syntactic `let-mut` rule (§21.4).

## 21.1 The Model

Spec §15 defines concurrency as a Kahn process network:

- An **actor** is a sequential process with private state and its own thread of control.
- Actors communicate only through **channels**. A channel is a FIFO buffer with exactly one writer and one reader.
- A read blocks until a value arrives. No actor can test whether a channel is empty.
- There is no shared mutable state, and values that cross a channel must be Send-capable.

Under these rules, each actor's output sequence is a function of its input sequences. The program's observable output therefore does not depend on scheduling (§27), even though the implementation runs every actor on its own operating-system thread.

## 21.2 Spawning Actors

```
spawn ::= "(" "spawn" Expression ")"
```

```lisp
(spawn entry)
```

- `entry` is a named function or a `fn`, which may capture immutable variables (by value, like any closure). Its type must be `() -> a`. An entry that takes a parameter is `E_TYPE_MISMATCH` at the `spawn`.
- The runtime creates one thread for the actor and calls `entry` once on it. When `entry` returns (or panics), the actor is finished.
- `spawn` returns the actor's id, a value of type `Actor`. Ids are numbered 0, 1, 2, … and never reused. An `Actor` is not an `Int`: arithmetic on it, or passing an `Int` where an actor is expected, is `E_TYPE_MISMATCH`.
- Endpoints that the closure captures directly move to the new actor before its thread starts (§21.3).

```lisp
(capabilities actor)

(use actor/actor)

(defn spin (n) (if (= n 0) 0 (spin (- n 1))))

(defn main ()
  (let a (spawn (fn () (begin (spin 20000) (print "actor finished"))))
    (begin
      (print "main waiting")
      (actor-wait a)
      (print "main done")
      0)))
```

Output:

```
main waiting
actor finished
main done
```

The order is fixed: `main` prints straight to stdout, and the actor's line is emitted when `main` joins it (§21.6).

### State

An actor's state lives in its own entry function. A `let-mut` local inside that function is private to the actor:

```lisp
(capabilities actor)

(use actor/actor)

(defn counter-actor ()
  (let-mut count 0
    (begin
      (while (< count 5)
        (begin
          (set! count (+ count 1))
          (print count)))
      (print "counter done"))))

(defn main ()
  (let a (spawn counter-actor)
    (begin
      (print "main first")
      (actor-wait a)
      (print "main done")
      0)))
```

Output: `main first`, then `1` through `5`, then `counter done`, then `main done`, one per line.

A `let-mut` from the *spawning* scope cannot be captured. The compiler rejects that with `E_CAPABILITY_LEAK` (§21.4).

## 21.3 Channels

```
chan      ::= "(" "chan" Expression ")"
chan-tx   ::= "(" "chan-tx" Expression ")"
chan-rx   ::= "(" "chan-rx" Expression ")"
chan-send ::= "(" "chan-send" Expression Expression ")"
chan-recv ::= "(" "chan-recv" Expression ")"
```

| Form | Type | Meaning |
|------|------|---------|
| `(chan n)` | `Int -> (Chan a)` | a channel buffering 1..n values; `n` outside 1..16777216 is `E_CHANNEL_CAPACITY` |
| `(chan-tx c)` | `(Chan a) -> (Tx a)` | the sending end |
| `(chan-rx c)` | `(Chan a) -> (Rx a)` | the receiving end |
| `(chan-send tx v)` | `(Tx a) a -> Unit` | append `v`, blocking while the buffer is full |
| `(chan-recv rx)` | `(Rx a) -> a` | remove the oldest value, blocking while the buffer is empty |

There is no select, no non-blocking receive and no emptiness test.

A channel carries one type, inferred like any other type variable, so what a reader receives is checked against what the writer sends. To carry several kinds of message, make them variants of one ADT and `match` on the received value. `book/examples/actor-counter/counter.zyl` is the standard example: requests `(Add Int)`, `(Get)` and `(Stop)` on one channel, answers on another (Chapter 9, §9.5).

### Ownership

Each endpoint belongs to exactly one actor at a time (spec §15 rule "one writer and one reader per channel"):

- The actor that calls `chan` owns both ends.
- A spawned closure that captures an endpoint **directly** (as a free variable) takes it over. An endpoint nested inside another captured value does not move.
- An endpoint sent on a channel is in transit until it is received, and then belongs to the receiver.

`chan-send` or `chan-recv` on an endpoint the running actor does not own is `E_CHANNEL_NOT_OWNER` (`this actor does not own the channel endpoint`). Ownership changes only at those program points, so the error does not depend on timing. `chan-tx` and `chan-rx` are not ownership-checked: they return the channel's endpoint objects, and the check happens when one is used.

### Closing

When the actor that owns a channel's `Tx` finishes, normally or by a panic, the channel closes. `main` finishes when its program ends. Values still buffered can be received. A `chan-recv` on a closed channel with nothing left in it is `E_CHANNEL_CLOSED` (`the channel's sender finished and every value was received`), which can be caught with `try`.

A consequence: an actor that loops on `chan-recv` from a channel `main` writes fails with `E_CHANNEL_CLOSED` once `main` returns, and exit reports that panic with status 1. Give such a loop a stop message, or catch the close and treat it as the end of input.

### Deadlock

When every live actor, `main` included, is blocked on a channel or a join, the runtime prints what the actors have buffered so far (in spawn order), then `PANIC: E_DEADLOCK: every live actor is blocked on a channel or a join`, and exits with status 1. In a Kahn network the set of blocked actors does not depend on scheduling, so a program that deadlocks does so on every run.

## 21.4 Send-Capability Checks

Spec §9.1 R3 and §7.4 require every value that crosses into another actor to be Send-capable. The implemented check is syntactic (`mutability_check.zyl`). It rejects a value sent on a channel, or a spawned expression, that names a `let-mut` variable of the enclosing scope. The next two programs do not compile:

```lisp
(capabilities actor)

(use actor/actor)

(defn main ()
  (let-mut x 10
    (let c (chan 1)
      (let tx (chan-tx c)
        (begin
          (chan-send tx x)
          0)))))
```

```
error[E_CAPABILITY_LEAK]: value sent on a channel references let-mut (TMut) variable `x` from the enclosing scope
  --> main.zyl:10:11
    |
 10 |           (chan-send tx x)
    |           ^
  6 |   (let-mut x 10
    |   - declared `let-mut` here
    = help: channel values must be Send-capable; send a copy bound with plain `let`
```

```lisp
(capabilities actor)

(defn main ()
  (let-mut count 0
    (spawn (fn () (set! count (+ count 1))))))
```

```
error[E_CAPABILITY_LEAK]: spawned closure captures let-mut (TMut) variable `count` from the enclosing scope
  --> main.zyl:5:5
   |
 5 |     (spawn (fn () (set! count (+ count 1))))))
   |     ^
 4 |   (let-mut count 0
   |   - declared `let-mut` here
   = help: only Send-capable (non-mut) captures may cross into another actor
```

Limits of the check:

- It is name-based. Copying the value into an immutable binding first (`(let y x (chan-send tx y))`) passes, which is sound for an `Int`.
- There is no type-based Send check. The type checker has no Send trait or predicate, so a mutable collection reached through an immutable binding, a `(Pin a)`, or any other value the specification counts as non-Send is not rejected by its type.
- A `Secret` value sent on a channel or captured by a spawn is rejected separately, with `E_SECRET_ESCAPE` (Chapter 33).

Region rule R2 applies to every sent value: it escapes its frame, so region inference places it on the heap.

## 21.5 Joining Actors

`stdlib/actor/actor.zyl` provides:

| Function | Type | Effect |
|----------|------|--------|
| `(actor-wait a)` | `Actor -> Unit` | blocks until `a` has finished, emits its buffered output, and re-raises its panic; a second wait does nothing |
| `(actor-is-alive a)` | `Actor -> Bool` | `true` until the program joins `a` |
| `(actor-spawn f)` | `(() -> a) -> Actor` | a function wrapper around `spawn` |

`actor-is-alive` answers whether the actor has been joined, not whether its thread is still running, so its result does not depend on timing.

At exit, the runtime closes `main`'s channels and joins every actor not yet joined, in spawn order. Returning from `main` therefore waits for every actor. An explicit `actor-wait` is needed only to place an actor's output, or to catch its panic, at a particular point.

## 21.6 Output and Determinism

Spec §27 counts actor output as observable and scheduling as not observable. The implementation meets this for stdout:

- `main`'s own output goes straight to stdout.
- An actor's `print`s go to a buffer of its own. The buffer is emitted when the actor is joined, or at exit, in spawn order, for actors that were never joined. A nested join writes the joined actor's output into the joiner's buffer.
- The values each actor receives, and their order, are fixed by the single-writer, single-reader rule.

So what a program `print`s is the same byte sequence on every run. What is not deterministic is timing itself: how long a program takes, and which thread the kernel runs first. `print` and `file-write` to fd 1 go through the actor's stdout buffer, and `file-write` to fd 2 goes through its stderr buffer. The stderr buffer is emitted right after the stdout one. Only foreign calls that write through libc bypass the buffers.

`ZYL_SCHED=deterministic` runs one actor at a time. A baton passes to the next ready actor in id order at each blocking point and when an actor finishes. `ZYL_SCHED_CHAOS=<seed>` gives each channel operation a seeded yield or short sleep. Both are environment variables read once at startup, so the binary is the same in every mode. The test suite's `sched` category requires byte-identical stdout, stderr and exit status across the default, deterministic and chaos schedules.

## 21.7 Actor Lifecycle

```
spawn           → id allocated; captured endpoints move; thread started
entry runs      → blocks only in chan-send, chan-recv or actor-wait
entry returns   → the actor is finished: the channels whose Tx it owns close
  (or panics)     and its panic message is kept for the joiner
actor-wait      → output emitted, panic re-raised; actor-is-alive becomes false
program exit    → main's channels close; unjoined actors joined in spawn order
```

There is no way to stop an actor from outside. Stopping an actor partway through would make what it had done depend on timing, so an actor ends only when its entry returns or panics. Tell an actor to stop with a message, or by closing its input.

## 21.8 Errors in Actors

- An uncaught panic in an actor ends only that actor. `actor-wait` re-raises it in the joiner, where `try` can catch it. If the actor is never joined, exit reports the first such panic in spawn order, after every actor's output, and the exit status is 1.
- After an uncaught panic on `main`, actors are abandoned and their buffered output is dropped.
- `E_DEADLOCK` is a whole-program error: it ends the process.
- Actor threads get an 8 MiB stack. `main` runs on a very large reserved stack, so deep recursion that works in `main` can overflow in an actor.
- There is no supervision or restart mechanism.

## 21.9 Limits

- At most 1024 actors per program, counted over its whole lifetime, since ids are never reused. The 1025th `spawn` raises `E_ACTOR_LIMIT: at most 1024 actors per program`.
- A channel holds 1 to 16777216 values.
- The interpreter (`zyl repl`, `zyl eval`) runs actors too: a spawn runs a compiled closure that interprets the body, and the endpoints the closure captures move with it. The REPL joins an entry's actors before the prompt returns.

## 21.10 Capabilities

`spawn`, `chan`, `chan-send` and `chan-recv`, and any call into `stdlib/actor`, require the `actor` capability (§31.9). A package declares it in `zyl.pkg`; a lone file declares it with a top-level `(capabilities actor)`, and without one has no capabilities at all:

```
error[E_PKG_CAPABILITY_VIOLATION]: `spawn` needs the actor capability, and this file declares none
  --> go.zyl:4:10
   |
 4 |   (let a (spawn (fn () (print "hi")))
   |          ^
   = note: a program names what it may do, so a reader sees it at the top
   = help: add `(capabilities actor)` at the top of the file
```

The root package's `main` and its top-level `test` forms are checked like any definition.

## 21.11 Runtime Implementation

- **Threads.** `zyl_actor_spawn` creates each actor's thread with `clone` in a freestanding program and with `pthread_create` in a hosted one. A capturing closure is unpacked into its code and environment, and the environment becomes the thread's state.
- **Owner ids.** `main` is owner 1 and actor *i* is owner *i* + 2. Before the thread starts, `zyl_chan_actor_spawn` scans the closure environment and moves each endpoint the spawner owns to the new actor. A word counts as an endpoint only if it is a heap block with an endpoint's magic word whose channel points back at it, so an integer is never taken for one.
- **Channels** are ring buffers. `zyl_chan_send` and `zyl_chan_recv` check the caller's owner id, then append or remove under the lock. A sent endpoint has owner 0 while in transit.
- **Scheduling.** One lock and one condition word serve every channel. Each owner records what it waits for: room in a channel, a value or a close, or another owner finishing. Before blocking, the runtime checks whether any live owner can proceed; if none can, it reports the deadlock.
- **Output.** Each owner has its own output buffer, and `zyl_out_actor_emit` writes it through the joiner's output.
- **Panics.** The actor's entry runs under a try frame. `zyl_chan_actor_done` closes the channels whose `Tx` the actor owns, records the panic message, and wakes joiners.

## 21.12 Errors

| Error | Cause |
|-------|-------|
| `E_TYPE_MISMATCH` | a spawn entry that takes a parameter; a received value used at a different type than was sent; an `Int` where an `Actor` is needed |
| `E_CAPABILITY_LEAK` | a sent value or spawned expression names a `let-mut` of the enclosing scope (§28: "TMut leaked") |
| `E_SECRET_ESCAPE` | a `Secret` value crosses into another actor |
| `E_CHANNEL_NOT_OWNER` | an endpoint used by an actor that does not own it |
| `E_CHANNEL_CLOSED` | `chan-recv` on a closed, drained channel |
| `E_CHANNEL_CAPACITY` | `(chan n)` with `n` outside 1..16777216 |
| `E_DEADLOCK` | every live actor blocked on a channel or a join |
| `E_ACTOR_LIMIT` | more than 1024 actors spawned |
| `E_PKG_CAPABILITY_VIOLATION` | an actor or channel operation in a file or package that does not declare the `actor` capability |

## 21.13 Comparison with Other Models

| Feature | Erlang/Elixir | Go | Rust (std) | Zyl |
|---------|---------------|-----|------------|-----|
| Unit | process | goroutine | thread | actor (one thread each) |
| Communication | mailbox, any sender | channel, many senders and readers | `mpsc` channel, many senders | channel, one writer and one reader |
| Receive | `receive`, selective | `<-ch`, `select` | `recv`, `try_recv` | `chan-recv` only |
| Channel typed | no | yes | yes | yes |
| Scheduling | preemptive | runtime M:N | OS threads | OS threads |
| Shared memory | no | yes | yes (`Arc`, `Mutex`) | no |
| Supervision | built in | manual | manual | none |
| Deterministic output | no | no | no | yes |
