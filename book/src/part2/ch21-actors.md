# Chapter 21: Actor Concurrency Model

Complete reference for Zyl's actor system: the model the specification defines, the forms the compiler accepts, the runtime that executes them, and the compile-time checks on what may cross between actors.

The normative text is spec v5.0 §15 (concurrency model), §7.4 (closures and concurrency), §9.1 rules R2 and R3, §27 (determinism) and §31.9 (the `actor` capability). The implementation is split across `stdlib/compiler/expr_inner.zyl` and `icnf.zyl` (parsing and lowering of `spawn` and `send`), `stdlib/compiler/mutability_check.zyl` (the send checks), `runtime/actor_runtime.c` (threads and mailboxes) and `stdlib/actor/actor.zyl` (library wrappers).

**Implementation status.** `spawn` starts a thread; `send` queues a message; `(receive)` takes the next one from the running actor's mailbox, and `(actor-self)` is the running actor's id, so actors exchange structured messages (ADT values) and reply to each other or to `main`. The runtime's other message kind, closure messages (§21.4), cannot be sent from a Zyl program. Output from several actors printing at once is not deterministic. This chapter documents what works, and marks what the specification promises but the implementation does not yet provide.

## 21.1 Actor Model Overview

Spec §15: an actor is private state plus a FIFO mailbox.

- **No shared mutable state**
- **Messages must be Send-capable**
- **Deterministic FIFO per actor**
- **Isolation**: no direct memory sharing between actors

```
Actor = (State, Mailbox, Behaviour)
```

In the implementation, an actor is an operating-system thread with a mailbox. The thread handles one message at a time, in the order the messages were queued.

## 21.2 Spawning Actors

```
spawn ::= "(" "spawn" Expression ")"
```

```lisp
(spawn entry)
```

- `entry` is a named function or a `fn`, which may capture immutable variables (by value, like any closure). It must take no parameters.
- The runtime creates one pthread for the actor and calls `entry` once on it. When `entry` returns, the thread stays alive, idling on its mailbox until the actor is stopped (§21.7).
- `spawn` returns the actor's id, a value of type `Actor`. Ids are numbered 0, 1, 2, … and never reused, but an `Actor` is not an `Int`: arithmetic on it, or passing an `Int` where an actor is expected, is `E_TYPE_MISMATCH`.
- At most 1024 actors can exist in one process. Beyond that, `spawn` prints `zyl: actor limit reached` and returns an invalid id.

```lisp
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

An entry function that takes a parameter is `E_TYPE_MISMATCH` at the `spawn`. An entry is not a message handler; loop on `(receive)` instead (§21.3).

### State

An actor's state lives in its own entry function. A `let-mut` local inside that function is private to the actor:

```lisp
(defn counter-actor ()
  (let-mut count 0
    (begin
      (while (< count 5)
        (begin
          (set! count (+ count 1))
          (print count)))
      (print "counter done"))))

(defn main ()
  (let _ (spawn counter-actor)
    (begin
      (ffi-call "zyl_actor_wait_all" 1000)
      (print "main done")
      0)))
```

Output: `1` through `5`, then `counter done`, then `main done`, one per line.

`zyl_actor_wait_all` is a runtime entry, so `ffi-call` needs no declaration for it: the compiler's signature table gives it the type `-> Unit` (Chapter 22, §22.2). §21.5 lists it with the other ways to wait.

A `let-mut` from the *spawning* scope cannot be captured. The compiler rejects that with `E_CAPABILITY_LEAK` (§21.3).

## 21.3 Sending Messages

```
send ::= "(" "send" Expression Expression ")"
```

```lisp
(send actor message)
```

Specified: asynchronous, FIFO per actor, and the message must be Send-capable.

Implemented:

- `send` takes an `Actor` and a message, and returns Unit.
- `send` is asynchronous and returns immediately.
- The message is passed as a single 64-bit word, either an `Int` or a pointer to an (immutable) heap value such as an ADT. It is not copied.
- Messages are delivered in the order each sender sent them.
- Sending to an id that does not name a live actor does nothing.

### Receiving: `receive` and `actor-self`

```lisp
(receive)       ; the next data message in this actor's mailbox; blocks until one arrives
(actor-self)    ; this actor's id
```

`actor-self` has type `Actor`. `receive` returns the message word. Match on it to handle structured
messages. On the main thread, the first `actor-self` or
`receive` opens a mailbox for `main`, so an actor can reply to it:

```lisp
(deftype CounterMsg (Add Int) (Get Actor) (Stop Actor))

(defn counter-loop (total)
  (match (receive)
    (Add n (counter-loop (+ total n)))
    (Get reply-to (begin (send reply-to total) (counter-loop total)))
    (Stop reply-to (send reply-to total))))

(defn main ()
  (let me (actor-self)
    (let c (spawn (fn () (counter-loop 0)))
      (begin
        (send c (Add 5))
        (send c (Add 7))
        (send c (Get me))
        (print (receive))          ; 12
        (send c (Stop me))
        (print (receive))          ; 12
        0))))
```

The loop is a tail call, so it runs in constant stack. An actor still
blocked in `receive` when the program ends does not hold up the exit:
it counts as idle, and the runtime stops it. `receive` on `main` with no
message coming blocks forever, like any receive nobody answers.
`book/examples/actor-counter/counter.zyl` is this program in full.

A field that carries an actor id is typed `Actor`, as `Get` and `Stop`
are here. With `(Get Int)` the program is rejected: `send reply-to`
needs an `Actor`, and `(Get me)` passes one.

**`receive` is not type-checked.** It is the one known hole in the
checker. The mailbox holds untyped words, so `(receive)` has whatever
type its use needs: above, the `match` treats it as a `CounterMsg`, and
`main` prints it as an `Int`. Nothing checks that the sender sent that
type; a mismatch is a wrong value at run time, not a compile error.
Mailboxes are to be replaced by typed channels, which close this hole.
Until then, give each actor one message type and keep its senders to it.
`receive`, `send` and `actor-self` need the `actor` capability in a
package.

### Send-capability checks

Spec §9.1 R3 and §7.4 require every value that crosses into another actor to be Send-capable. The implemented check is syntactic (`mutability_check.zyl`). It rejects a message, or a spawned expression, that names a `let-mut` variable of the enclosing scope:

```lisp
(use actor/actor)

(defn main ()
  (let a (spawn (fn () 0))
    (let-mut x 10
      (begin (send a x) (actor-wait a) 0))))
```

```
PANIC: error[E_CAPABILITY_LEAK]: message sent to an actor references let-mut (TMut) variable `x` from the enclosing scope
  --> main.zyl:6:14
   |
 6 |       (begin (send a x) (actor-wait a) 0))))
   |              ^
 5 |     (let-mut x 10
   |     - declared `let-mut` here
   = help: messages must be Send-capable; send a copy bound with plain `let`
```

```lisp
(defn main ()
  (let-mut count 0
    (spawn (fn () (set! count (+ count 1))))))
```

```
PANIC: error[E_CAPABILITY_LEAK]: spawned closure captures let-mut (TMut) variable `count` from the enclosing scope
  --> main.zyl:3:5
   |
 3 |     (spawn (fn () (set! count (+ count 1))))))
   |     ^
 2 |   (let-mut count 0
   |   - declared `let-mut` here
   = help: only Send-capable (non-mut) captures may cross into another actor
```

Limits of the check:

- It is name-based. Copying the value into an immutable binding first (`(let y x (send a y))`) passes, which is sound for an `Int`.
- There is no type-based Send check. The type checker has no Send trait or predicate, so a closure, a `(Pin a)` or any other value the specification counts as non-Send is not rejected by its type.
- A `Secret` value in a message or spawn capture is rejected separately, with `E_SECRET_ESCAPE`.

## 21.4 Closure Messages

The runtime has a second message kind besides the data messages of `send`. Its C entry is

```c
void zyl_actor_send_closure(uint32_t actor_id, void (*fn)(void*), void* state);
```

It queues the pair `fn`, `state` on the actor, and the actor's thread calls `fn(state)` when it reaches the message: `zyl_actor_receive` runs closure messages it finds ahead of the next data message, and an actor whose entry function has returned runs them from its idle loop. Nothing in the compiler or the standard library sends one.

A Zyl program cannot call it. The entry is a runtime export with no signature in `stdlib/compiler/ffi_sigs.zyl`, so `(ffi-call "zyl_actor_send_closure" ...)` is `E_CANNOT_INFER` ("no type for untyped ffi result"). Declaring it with `extern` does not help: an `extern` for a runtime entry is `E_FFI_RESTRICTED`. Use `send` and `receive` (§21.3) for every message.

## 21.5 Waiting for Actors

There is no `wait_all` form; `(wait_all a)` is rejected with `E_UNBOUND_VARIABLE: call to undefined function`. The available operations are:

| Operation | Effect |
|-----------|--------|
| `(ffi-call "zyl_actor_wait_all" 1000)` | polls until every mailbox is empty and every actor is idle, then stops and joins **every** actor; also runs automatically at exit |
| `(actor-wait a)` (`actor/actor`) | marks `a` stopped and joins its thread; messages still queued are **discarded** |
| `(actor-terminate a)` | marks `a` stopped |
| `(actor-is-alive a)` | whether `a` is still running |

Every compiled program registers `zyl_actor_wait_all` to run at exit, so when `main` returns, remaining actors drain their mailboxes before the process ends. Call it (or `actor-wait`) explicitly only where output order matters.

`stdlib/actor/actor.zyl` also provides `actor-spawn` and `actor-send`, wrappers around `spawn` and `send`, and `actor-send-with-timeout`, which ignores its timeout.

## 21.6 Determinism

Spec: §15 promises deterministic FIFO per actor, and §27 counts actor outputs as observable while scheduling is not. Together, the same program with the same inputs should produce the same actor output.

**The implementation does not meet this.** Every actor is its own pthread, and interleaving is up to the operating system scheduler. There is no scheduler loop, quantum or fixed order. Two actors that each print 200 lines produced 16 different outputs in 20 runs.

What does hold:

- **FIFO from one sender to one actor.** The mailbox is protected by a mutex, and messages are taken in queue order.
- **Sequential handling.** One actor runs one message at a time.

To get deterministic output from an actor program today, have exactly one actor produce output, or collect results and print them from `main` after `zyl_actor_wait_all`.

## 21.7 Actor Lifecycle

```
spawn             → thread created; entry function runs once
entry returns     → thread idles on its mailbox until stopped
stopped by        → zyl_actor_wait_all, actor-wait, actor-terminate,
                    or the drain at process exit (main returning)
```

An actor does not stop when its entry function returns. There is no `Shutdown` message convention in the runtime: stopping is an operation on the actor, not a message to it.

## 21.8 Mailbox Implementation

- **Unbounded**: a linked list, one allocation per message.
- **Mutex and condition variable**: many producers, one consumer. The mailbox is not lock-free.
- **No backpressure**: build it into your protocol if you need it (for example, reply messages that grant credit).

Two message kinds exist in the runtime: data messages from `send`, which `receive` returns (one still queued after the entry function returns is dropped), and closure messages from `zyl_actor_send_closure`, which run a C function on the actor's thread and which a Zyl program cannot send (§21.4).

## 21.9 Errors in Actors

- A panic in an actor (for example a failed `assert-true`) **exits the whole process** with status 1. It does not stop just the one actor.
- Actor threads get the default pthread stack, about 8 MB. `main` runs on a very large reserved stack, so deep recursion that works in `main` can overflow in an actor.
- There is no supervision, failure notification or restart mechanism.

## 21.10 Capabilities

In a package with a `zyl.pkg`, `spawn`, `send`, `receive` and `actor-self`, and any call into `stdlib/actor`, require the `actor` capability (§31.9):

```
PANIC: error[E_PKG_CAPABILITY_VIOLATION]: package demo/nocap uses actor in helper without declaring it in zyl.pkg
```

A lone file compiled without a manifest is not checked. The current pass also does not check the body of `main` (see Chapter 25, §25.11).

## 21.11 Performance Characteristics

Measured on the current runtime (x86_64 Linux). These are orders of magnitude, not guarantees.

| Operation | Cost |
|-----------|------|
| `spawn` | one `pthread_create`, about 10 µs |
| `send` | mutex-protected enqueue plus allocation, about 250 ns |
| `zyl_actor_wait_all` | polls every 1 ms until the mailboxes drain |
| context switch | operating-system thread switch |

There are no tuning knobs: no quantum, no thread pool and no stack-size setting.

## 21.12 Errors

| Error | Cause |
|-------|-------|
| `E_TYPE_MISMATCH` | an `Int` (or anything else) where `send`, `actor-wait` or another actor operation needs an `Actor` |
| `E_CAPABILITY_LEAK` | a message or spawned expression names a `let-mut` of the enclosing scope (§28: "TMut leaked") |
| `E_SECRET_ESCAPE` | a `Secret` value crosses into an actor |
| `E_PKG_CAPABILITY_VIOLATION` | actor operation in a package without the `actor` capability |

The runtime defines no error for sending to a stopped actor: a `send` to a stopped actor, or to an id that was never spawned, is dropped silently.

## 21.13 Comparison with Other Models

| Feature | Erlang/Elixir | Go | Rust (Actix) | Zyl (spec) | Zyl (implemented) |
|---------|---------------|-----|--------------|------------|-------------------|
| Unit | process | goroutine | actor | actor | pthread per actor |
| Receive | `receive` | channel read | handler | `receive` | `(receive)` |
| Scheduling | preemptive | runtime M:N | async executor | not observable (§27) | OS threads |
| FIFO per actor | ✅ | per channel | ✅ | ✅ | ✅ (per sender) |
| Shared memory | ❌ | yes | ❌ | ❌ | messages shared by pointer |
| Supervision | built in | manual | built in | not specified | none |
| Deterministic output | ❌ | ❌ | ❌ | ✅ | ❌ |
