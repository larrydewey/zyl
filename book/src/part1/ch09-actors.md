# Chapter 9: Concurrency with Actors

Zyl's concurrency model is based on **actors** that communicate over **channels**, with no shared mutable state (Spec §15). The channels form a Kahn process network: each channel has exactly one writer and one reader, and a read blocks until a value arrives. As a result, a program's output does not depend on how its threads are scheduled. This chapter covers the model and what the current compiler and runtime implement. Every runnable example was compiled with `zyl` and run.

## 9.1 Actors and Channels

An actor is a sequential process with private state and its own thread of control. Actors communicate only through channels:

```
  actor A                  channel (FIFO, 1..n values)            actor B
┌─────────┐  chan-send   ┌─────────────────────────────┐  chan-recv  ┌─────────┐
│         │ ───────────▶ │ [v1] [v2] [v3] ...          │ ──────────▶ │         │
│  owns   │     (Tx)     └─────────────────────────────┘    (Rx)     │  owns   │
│  the Tx │                                                          │  the Rx │
└─────────┘                                                          └─────────┘
```

**Rules from Spec §15:**

- No shared mutable state between actors.
- Values sent on a channel must be **Send-capable**.
- Each channel has one writer and one reader: every endpoint has exactly one owner.
- A reader cannot test whether a channel is empty. It can only wait for the next value.

Under these rules, the sequence of values each actor sees is fixed by the program and its inputs, so its output is fixed too.

The language forms are `spawn`, `chan`, `chan-tx`, `chan-rx`, `chan-send` and `chan-recv`. Joining and querying actors (`actor-wait`, `actor-is-alive`) come from the standard library module `actor/actor`.

## 9.2 Spawning Actors

```lisp
(spawn (fn () body))
(spawn entry-fn)          ; a named zero-argument function also works
```

`spawn` starts a new actor running `body` on its own thread and returns immediately with a value of type `Actor`. An `Actor` can be joined with `actor-wait` and queried with `actor-is-alive`, and nothing else: it is not an `Int`, and it is not a destination for messages.

```lisp
(use actor/actor)

(defn crunch (n)
  (if (<= n 1) 1 (* n (crunch (- n 1)))))

(defn main ()
  (let a (spawn (fn () (print (crunch 5))))
    (let b (spawn (fn () (print (crunch 6))))
      (begin
        (print "main first")
        (actor-wait b)
        (actor-wait a)
        (print "both done")
        0))))
```

Output, on every run:

```
main first
720
120
both done
```

The two actors run at the same time, but neither writes to stdout directly. An actor's `print`s go into a buffer of its own, which is emitted when the actor is joined. `main` joins `b` first, so `720` comes before `120`, whichever actor finished first. §9.7 covers output in full.

Two rules for the function passed to `spawn`:

1. **Capture only immutable values.** A spawned closure may read variables from the enclosing scope; like any closure it gets copies of them. A closure that captures a `let-mut` variable is rejected at compile time with `E_CAPABILITY_LEAK` (Chapter 8, §8.6).
2. **Take no parameters.** The entry has type `() -> a`. Data reaches an actor through the values it captures and the channels it reads. Spawning a function that takes a parameter is `E_TYPE_MISMATCH`.

## 9.3 Channels

```lisp
(chan n)            ; a new channel buffering up to n values: (Chan a)
(chan-tx c)         ; its sending end: (Tx a)
(chan-rx c)         ; its receiving end: (Rx a)
(chan-send tx v)    ; append v; blocks while the buffer is full; Unit
(chan-recv rx)      ; remove the oldest value; blocks while the buffer is empty
```

- `n` must be between 1 and 16777216. Anything else is `E_CHANNEL_CAPACITY` at run time.
- Values come out in the order they went in.
- There is no `select`, no non-blocking receive and no emptiness test. These are left out on purpose: each would let the result depend on timing.
- Channels are typed. A channel carries values of one type, and the type checker infers it from how the endpoints are used. Receiving an `Int` where a `String` is needed is a compile-time error:

```lisp
(use actor/actor)

(defn main ()
  (let c (chan 1)
    (let tx (chan-tx c)
      (let rx (chan-rx c)
        (begin
          (chan-send tx 1)
          (print (str-concat "got " (chan-recv rx)))
          0)))))
```

```
error[E_TYPE_MISMATCH]: cannot unify String with Int
  --> main.zyl:9:18
   |
 9 |           (print (str-concat "got " (chan-recv rx)))
   |                  ^
PANIC: error[E_TYPE_MISMATCH]: the program does not type-check (1 error above)
```

To carry several kinds of message on one channel, make them variants of one ADT (§9.5).

## 9.4 Endpoint Ownership

Each endpoint, `Tx` or `Rx`, belongs to exactly one actor at a time. The actor that creates a channel owns both of its ends. Ownership moves only at two points:

- **Spawn capture.** A spawned closure that captures an endpoint directly, as a free variable, takes it over when the actor starts. An endpoint nested inside another captured value does not move.
- **Sending an endpoint.** An endpoint sent on a channel belongs to whoever receives it.

Using an endpoint the running actor does not own is `E_CHANNEL_NOT_OWNER`. Here `main` gives `rx` to the actor, then tries to read from it itself:

```lisp
(use actor/actor)

(defn main ()
  (let c (chan 1)
    (let rx (chan-rx c)
      (let tx (chan-tx c)
        (let a (spawn (fn () (print (chan-recv rx))))
          (begin
            (chan-send tx 1)
            (actor-wait a)
            (print (chan-recv rx))
            0))))))
```

```
1
PANIC: E_CHANNEL_NOT_OWNER: this actor does not own the channel endpoint
```

Because ownership changes only at those two program points, this error is raised the same way on every run.

An endpoint sent on a channel lets an actor be wired up after it starts. The reader below owns only `h-rx` at first. `main` then hands it the receiving end of `data`:

```lisp
(use actor/actor)

(defn main ()
  (let data (chan 1)
    (let handoff (chan 1)
      (let data-rx (chan-rx data)
        (let data-tx (chan-tx data)
          (let h-tx (chan-tx handoff)
            (let h-rx (chan-rx handoff)
              (let reader (spawn (fn () (let rx (chan-recv h-rx) (print (chan-recv rx)))))
                (begin
                  (chan-send h-tx data-rx)
                  (chan-send data-tx 42)
                  (actor-wait reader)
                  0)))))))))
```

Output:

```
42
```

## 9.5 A Counter Actor

A stateful actor is a recursive loop over `chan-recv`, with its state passed as the loop's parameters. Requests are ADT values on one channel, and answers come back on a second channel. The program below is `book/examples/actor-counter/counter.zyl`:

```lisp
(use actor/actor)

(deftype CounterMsg (Add Int) (Get) (Stop))

(defn counter-loop (rx tx total)
  (match (chan-recv rx)
    (Add n (counter-loop rx tx (+ total n)))
    (Get (begin (chan-send tx total) (counter-loop rx tx total)))
    (Stop (chan-send tx total))))

(defn main ()
  (let req (chan 8)
    (let rep (chan 1)
      (let rx (chan-rx req)
        (let tx (chan-tx rep)
          (let c (spawn (fn () (counter-loop rx tx 0)))
            (let ask (chan-tx req)
              (let answer (chan-rx rep)
                (begin
                  (chan-send ask (Add 5))
                  (chan-send ask (Add 7))
                  (chan-send ask (Get))
                  (print (str-concat "after two adds: " (ffi-call "zyl_int_text" (chan-recv answer) 1000)))
                  (chan-send ask (Add 30))
                  (chan-send ask (Stop))
                  (print (str-concat "final: " (ffi-call "zyl_int_text" (chan-recv answer) 1000)))
                  (actor-wait c)
                  0)))))))))
```

Output:

```
after two adds: 12
final: 42
```

The spawned closure captures `rx` (the reading end of `req`) and `tx` (the writing end of `rep`), so the actor owns them. `main` keeps `ask` and `answer`. `counter-loop` calls itself in tail position, so it runs in constant stack however many messages it handles. The `Stop` variant does not loop, so the actor's body returns, and `actor-wait` joins it.

The request-reply pattern needs no reply address in the message: each request channel is paired with its own reply channel. An actor that serves several clients needs one request channel and one reply channel per client.

## 9.6 Send-Capable Values

The specification's Send rules:

| Type | Send? | Notes |
|------|-------|-------|
| `Int`, `Float`, `Bool`, `String` | Yes | Immutable primitives |
| `TCap<T>` | Yes | Shared immutable |
| `TAtomic<T>` | Yes | Thread-safe mutation |
| ADTs and structs with Send fields | Yes | Checked recursively |
| Channel endpoints | Yes | Ownership moves to the receiver (§9.4) |
| `TMut<T>` | No | Exclusive; cannot be shared |
| `TBox<T>` | No | Owned; would violate exclusivity |
| `TPin<T>` | No | FFI-pinned; not for actors |
| Closures capturing `TMut` | No | Would leak mutable state |

The compiler currently enforces the `TMut` rows, for both a value sent on a channel and a spawned closure's captures:

```lisp
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
PANIC: error[E_CAPABILITY_LEAK]: value sent on a channel references let-mut (TMut) variable `x` from the enclosing scope
  --> main.zyl:8:11
   |
 8 |           (chan-send tx x)
   |           ^
 4 |   (let-mut x 10
   |   - declared `let-mut` here
   = help: channel values must be Send-capable; send a copy bound with plain `let`
```

A `Secret` value sent on a channel or captured by a spawn is rejected separately, with `E_SECRET_ESCAPE` (Chapter 33).

## 9.7 Joining, Output and Panics

The `actor/actor` module provides:

| Function | Meaning |
|----------|---------|
| `(actor-wait a)` | Block until actor `a` has finished, emit its buffered output, and re-raise its panic if it had one. A second wait does nothing |
| `(actor-is-alive a)` | `true` until the program joins `a` with `actor-wait` (or at exit) |
| `(actor-spawn f)` | A function wrapper around `spawn` |

`actor-is-alive` does not report whether the actor's thread is still running, which would depend on timing. It reports whether the program has joined the actor yet, which does not.

**Output.** Everything an actor prints goes into its own buffer. The buffer is emitted:

- when the actor is joined with `actor-wait`, or
- when the program exits, for actors that were never joined, in spawn order.

`main`'s own output goes straight to stdout. `print` and `file-write` to fd 1 and 2 are all buffered this way. Only a foreign C call that writes through libc bypasses the buffer. A program need not join its actors, since exit joins every one of them:

```lisp
(defn main ()
  (let a (spawn (fn () (print "hi from actor")))
    (print "main exits"))
  0)
```

Output, on every run:

```
main exits
hi from actor
```

(The compiler also warns that `a` is never used; name it `_` to silence that.)

**Panics.** An uncaught panic in an actor ends only that actor. `actor-wait` re-raises it in the joiner, where `try` can catch it:

```lisp
(use actor/actor)

(defn main ()
  (let a (spawn (fn () (begin (print "working") (error "boom"))))
    (begin
      (print (try (begin (actor-wait a) "no error") (catch e (str-concat "caught: " e))))
      (print (if (actor-is-alive a) "still alive" "joined"))
      0)))
```

Output:

```
working
caught: boom
joined
```

If an actor that panicked is never joined, the program reports the first such panic at exit (in spawn order) and exits with status 1. After an uncaught panic on `main` itself, the actors are abandoned and their buffered output is dropped.

## 9.8 Closing and Deadlock

**Closing.** When the actor that owns a channel's `Tx` finishes, the channel closes. For `main`, that is when the program ends. Values already in the buffer can still be received. A `chan-recv` on a closed channel with nothing left in it is `E_CHANNEL_CLOSED`:

```lisp
(use actor/actor)

(defn main ()
  (let c (chan 4)
    (let tx (chan-tx c)
      (let rx (chan-rx c)
        (let _ (spawn (fn () (begin (chan-send tx 1) (chan-send tx 2))))
          (begin
            (print (chan-recv rx))
            (print (chan-recv rx))
            (print (chan-recv rx))
            0))))))
```

```
1
2
PANIC: E_CHANNEL_CLOSED: the channel's sender finished and every value was received
```

The third `chan-recv` fails at the same point in the reader's sequence on every run. The error can be caught, so a reader can treat a closed channel as the end of its input:

```lisp
(use actor/actor)

(defn produce (tx i n)
  (if (> i n) 0
    (begin (chan-send tx i) (produce tx (+ i 1) n))))

(defn sum-until-closed (rx acc)
  (match (try (Some (chan-recv rx)) (catch _ None))
    (Some v (sum-until-closed rx (+ acc v)))
    (None acc)))

(defn main ()
  (let c (chan 4)
    (let tx (chan-tx c)
      (let rx (chan-rx c)
        (let p (spawn (fn () (produce tx 1 100)))
          (begin
            (print (sum-until-closed rx 0))
            (actor-wait p)
            0))))))
```

Output:

```
5050
```

`catch _` catches every error, not only `E_CHANNEL_CLOSED`. The same rule applies to a server loop that `main` feeds: when `main` returns, its `Tx` closes, and an actor still waiting in `chan-recv` fails with `E_CHANNEL_CLOSED`, which exit reports with status 1. End such a loop with an explicit stop message, as `counter-loop` does, or treat the close as the end of input.

**Deadlock.** When every live actor, `main` included, is blocked on a channel or a join, no actor can make progress. The runtime detects this, prints the output the actors have buffered so far (in spawn order), then reports `E_DEADLOCK` and exits with status 1:

```lisp
(use actor/actor)

(defn main ()
  (let c (chan 1)
    (let rx (chan-rx c)
      (let a (spawn (fn () (begin (print "waiting") (chan-recv rx))))
        (begin
          (actor-wait a)
          0)))))
```

```
waiting
PANIC: E_DEADLOCK: every live actor is blocked on a channel or a join
```

The actor waits for a value only `main` can send, and `main` waits for the actor. In a Kahn network the set of blocked actors does not depend on scheduling, so a program that deadlocks does so on every run.

## 9.9 Determinism

The runtime runs every actor on its own operating-system thread, and the kernel decides when each one runs. The observable output is the same on every run anyway:

- each channel has one writer and one reader, and a reader cannot test for emptiness, so the values each actor receives, and the order it receives them in, are fixed;
- actor `print` output is buffered and emitted at fixed points (joins and exit), not when the thread happens to print;
- ownership errors, closing and deadlock happen at fixed points of the program.

The fan-out program in §9.10, run 100 times, gave byte-identical output every time.

Two run-time schedules make this checkable. `ZYL_SCHED=deterministic` runs one actor at a time, handing control on in a fixed order at each blocking point. `ZYL_SCHED_CHAOS=<seed>` adds seeded yields and sleeps at channel operations. The same binary must print the same bytes under both and under the default schedule, and the test suite checks that.

## 9.10 Common Patterns

### Fan-Out and Join

Spawn several independent workers, then join them in the order their output should appear:

```lisp
(use actor/actor)

(defn sum-to (n acc)
  (if (= n 0) acc (sum-to (- n 1) (+ acc n))))

(defn main ()
  (let a (spawn (fn () (print (sum-to 100 0))))
    (let b (spawn (fn () (print (sum-to 1000 0))))
      (let c (spawn (fn () (print (sum-to 10000 0))))
        (begin
          (actor-wait a)
          (actor-wait b)
          (actor-wait c)
          (print "all workers finished")
          0)))))
```

Output:

```
5050
500500
50005000
all workers finished
```

### Pipelines

Each stage reads from one channel and writes to the next. Here a producer sends 1 to 10, a middle stage squares each value, and `main` adds up the results:

```lisp
(use actor/actor)

(defn produce (tx i n)
  (if (> i n) 0
    (begin (chan-send tx i) (produce tx (+ i 1) n))))

(defn square-all (rx tx k)
  (if (= k 0) 0
    (let v (chan-recv rx)
      (begin (chan-send tx (* v v)) (square-all rx tx (- k 1))))))

(defn sum (rx k acc)
  (if (= k 0) acc (sum rx (- k 1) (+ acc (chan-recv rx)))))

(defn main ()
  (let nums (chan 4)
    (let squares (chan 4)
      (let nums-tx (chan-tx nums)
        (let nums-rx (chan-rx nums)
          (let sq-tx (chan-tx squares)
            (let sq-rx (chan-rx squares)
              (let p (spawn (fn () (produce nums-tx 1 10)))
                (let s (spawn (fn () (square-all nums-rx sq-tx 10)))
                  (begin
                    (print (sum sq-rx 10 0))
                    (actor-wait p)
                    (actor-wait s)
                    0))))))))))
```

Output:

```
385
```

The buffer size bounds how far a stage can run ahead of the next: a full channel blocks its writer.

### Fan-In

A channel has only one writer, so several producers cannot share one. Give each producer its own channel and have the consumer read them in a fixed order (`tests/regression/channels.zyl`, `fan-in-one-channel-per-producer`). The consumer's input order is then part of the program, not a race.

### Supervision

There is no supervision or restart mechanism. A joiner learns of an actor's failure through the panic `actor-wait` re-raises (§9.7).

## 9.11 Limits

- A program can spawn at most 1024 actors over its lifetime. Actor ids are never reused, so this counts every actor spawned, not the ones alive at once. The 1025th `spawn` raises `E_ACTOR_LIMIT: at most 1024 actors per program`.
- A channel's buffer holds 1 to 16777216 values (`E_CHANNEL_CAPACITY`).
- Each actor thread gets an 8 MiB stack. `main` runs on a much larger reserved stack, so deep non-tail recursion that works in `main` can overflow in an actor.

## 9.12 Testing Actors

Keep the logic in plain functions and test it directly. For the actors themselves, test what the runtime guarantees. This is the style of `tests/regression/actors.zyl` and `tests/regression/channels.zyl`:

```lisp
(use actor/actor)

(test "spawned-actor-is-alive"
  (let a (spawn (fn () 42))
    (assert-true (actor-is-alive a))))

(test "joined-actor-is-not-alive"
  (let a (spawn (fn () 0))
    (begin
      (actor-wait a)
      (assert-false (actor-is-alive a)))))

(test "actor-panic-reaches-the-joiner"
  (let a (spawn (fn () (error "boom")))
    (assert-equal (try (begin (actor-wait a) "no error") (catch e e)) "boom")))

(run-tests)
```

```
test: spawned-actor-is-alive ... ok
test: joined-actor-is-not-alive ... ok
test: actor-panic-reaches-the-joiner ... ok

test result: 3 passed, 0 failed, 3 total
```

The first test passes on every run: `actor-is-alive` is `true` until the join, however quickly the actor finishes.

### Actors in Packages

Inside a package (a directory with a `zyl.pkg`, Spec §31.9), `spawn`, `chan`, `chan-send`, `chan-recv` and any use of the `actor/` modules require the `actor` capability. Declare it in the manifest with `(capabilities actor)`; without it, compilation stops with `E_PKG_CAPABILITY_VIOLATION`:

```
PANIC: error[E_PKG_CAPABILITY_VIOLATION]: package book/actdemo uses actor in go without declaring it in zyl.pkg
```

A single file compiled directly is not capability-checked.

---

## For Experts: Under the Hood

### Runtime Implementation (`runtime/rt/actor.zyl`, `chan.zyl`, `out.zyl`)

- **One thread per actor**, created by `zyl_actor_spawn` with `clone` when the program links freestanding, or with `pthread_create` when it links hosted. For a capturing closure, the runtime unpacks the closure block into its code and environment, and the environment becomes the thread's state.
- **Owners.** Every thread has an owner id: 1 for `main`, and actor *i* is *i* + 2. Before the actor's thread starts, `zyl_chan_actor_spawn` scans the closure environment and moves every endpoint the spawner owns to the new actor. A word counts as an endpoint only if it is a heap block with an endpoint's magic word whose channel points back at it, so an integer is never mistaken for one.
- **Channels** are ring buffers `{magic, cap, head, count, closed, tx, rx, buf}`. Each endpoint is `{magic, chan, owner}`. `zyl_chan_send` and `zyl_chan_recv` check the caller's owner id first. A sent endpoint is in transit (owner 0) until it is received.
- **One scheduler lock** and condition word serves every channel. Each owner records what it waits for: room in a channel, a value or a close, or another owner finishing. Before blocking, the runtime checks whether any live owner can proceed; if none can, that is the deadlock.
- **Output.** An actor's writes go to a per-owner buffer. `zyl_out_actor_emit` writes it through the joiner's own output, so a nested join lands in the joiner's buffer.
- **Panics.** The actor body runs under a try frame. A panic is recorded as the actor's result, the channels whose `Tx` it owns close, and `zyl_actor_wait` re-raises the message.
- **Exit.** `zyl_actor_wait_all` runs at exit: `main`'s channels close, then every unjoined actor is joined in spawn order and its output emitted.

### Lowering

`(spawn f)` lowers to `zyl_actor_spawn(f, 0)`, `(chan n)` to `zyl_chan_new(n)`, `chan-tx`/`chan-rx` to `zyl_chan_tx`/`zyl_chan_rx`, `(chan-send tx v)` to `zyl_chan_send(tx, v)` and `(chan-recv rx)` to `zyl_chan_recv(rx)`. A value is passed as its 64-bit word, not copied. The type checker gives `chan` the type `Int -> (Chan a)`, `chan-tx` `(Chan a) -> (Tx a)`, `chan-rx` `(Chan a) -> (Rx a)`, `chan-send` `(Tx a) a -> Unit` and `chan-recv` `(Rx a) -> a`.

### Send Capability Check (Compile Time)

The check lives in `stdlib/compiler/mutability_check.zyl`. It reports `E_CAPABILITY_LEAK` when a `chan-send` value, or the body of a spawned closure, refers to a `let-mut` variable of the enclosing scope. The rest of the Send table in §9.6 (rejecting `TBox`, `TPin`, and non-Send ADT fields) is specified but not yet checked, so a mutable collection reached through an immutable binding can still be shared.

### The Interpreter

`zyl repl` and `zyl eval` cannot spawn, because an interpreted function has no native entry. Channels work there on `main` alone.

---

**Next:** [Chapter 10: Macros and Metaprogramming](ch10-macros.md) covers `defmacro`, expansion order, and what the current macro expander does and does not do.
