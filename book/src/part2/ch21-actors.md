# Chapter 21: Actor Concurrency Model

Complete reference for Zyl's actor system: the model the specification defines, the forms the compiler accepts, the runtime that executes them, and the compile-time checks on what may cross between actors.

The normative text is spec v5.0 §15 (concurrency model), §7.4 (closures and concurrency), §9.1 rules R2 and R3, §27 (determinism) and §31.9 (the `actor` capability). The implementation is split across `stdlib/compiler/expr_inner.zyl` and `icnf.zyl` (parsing and lowering of `spawn` and `send`), `stdlib/compiler/mutability_check.zyl` (the send checks), `runtime/actor_runtime.c` (threads and mailboxes) and `stdlib/actor/actor.zyl` (library wrappers).

**Implementation status.** Actors are the least complete part of the language. `spawn` starts a thread. A message sent with `send` is queued and then **discarded**, and there is no `receive`. The one working way to deliver a message is the runtime's closure-message primitive, `zyl_actor_send_closure`, called through `ffi-call` (§21.4). Actor output is not deterministic. This chapter documents what works, and marks what the specification promises but the implementation does not yet provide.

## 21.1 Actor Model Overview

Spec §15: an actor is private state plus a FIFO mailbox.

- **No shared mutable state**
- **Messages must be Send-capable**
- **Deterministic FIFO per actor**
- **Isolation**: no direct memory sharing between actors

```
Actor = (State, Mailbox, Behaviour)
```

In the implementation, an actor is an operating-system thread with a mailbox. Each queued closure message is run on that thread, one at a time, in the order it was queued.

## 21.2 Spawning Actors

```
spawn ::= "(" "spawn" Expression ")"
```

```lisp
(spawn entry)
```

- `entry` is a named function, or a `fn` that captures nothing. It must take no parameters.
- The runtime creates one pthread for the actor and calls `entry` once on it. When `entry` returns, the thread stays alive, waiting on its mailbox for closure messages (§21.4).
- `spawn` returns the actor's id, an `Int` (0, 1, 2, …, never reused). There is no separate `ActorRef` type.
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

### What does not work yet

- **A `fn` that captures variables crashes.** `(let x 41 (spawn (fn () (print (+ x 1)))))` compiles, but the closure's environment block is passed as the code pointer and the actor segfaults. Pass state through closure messages instead.
- **An entry function with a parameter** receives 0. It is not a message handler.
- **`(receive)`** is not implemented. A `spawn` body that uses it compiles to an actor that does nothing.

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
  (let a (spawn counter-actor)
    (begin
      (ffi-call "zyl_actor_wait_all" 1000)
      (print "main done")
      0)))
```

Output: `1` through `5`, then `counter done`, then `main done`, one per line.

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

- `send` is asynchronous and returns immediately.
- The message is passed as a single 64-bit word, either an `Int` or a pointer to a heap value. It is not copied.
- **The runtime discards data messages** when it dequeues them. Nothing in Zyl can observe a message sent with `send`.
- Sending to an id that does not name a live actor currently aborts the process (`free(): invalid pointer`).

Until `send` and `receive` are implemented, use closure messages (§21.4).

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
PANIC: E_CAPABILITY_LEAK: message sent to an actor references a let-mut (TMut) variable from the enclosing scope -- messages must be Send-capable
```

```lisp
(let-mut count 0
  (spawn (fn () (set! count (+ count 1)))))
```

```
PANIC: E_CAPABILITY_LEAK: spawned closure captures a let-mut (TMut) variable from the enclosing scope -- only Send-capable (non-mut) captures may cross into another actor
```

Limits of the check:

- It is name-based. Copying the value into an immutable binding first (`(let y x (send a y))`) passes, which is sound for an `Int`.
- There is no type-based Send check. The type system defines one (`tc-is-send`) but never calls it, so `TBox`, `TPin` and other non-Send types are not rejected.
- The error carries no source location.
- A `Secret` value in a message or spawn capture is rejected separately, with `E_SECRET_ESCAPE`.

## 21.4 Closure Messages: the Working Protocol

`zyl_actor_send_closure` queues a call `handler(word)` on an actor. The actor's thread runs queued calls one at a time, in the order they were queued:

```lisp
(ffi-call "zyl_actor_send_closure" actor handler word 1000)
```

- `handler` is a named one-parameter function.
- `word` is its argument: an `Int`, or a heap value passed by pointer.

```lisp
(defn idle () 0)
(defn handler (msg) (print (* msg 10)))

(defn main ()
  (let a (spawn idle)
    (begin
      (ffi-call "zyl_actor_send_closure" a handler 1 1000)
      (ffi-call "zyl_actor_send_closure" a handler 2 1000)
      (ffi-call "zyl_actor_send_closure" a handler 3 1000)
      (ffi-call "zyl_actor_wait_all" 1000)
      (print "main done")
      0)))
```

Output:

```
10
20
30
main done
```

### Request and response

An ADT message can carry the id of the actor to reply to:

```lisp
(deftype Msg (Request Int Int) (Reply Int))

(defn idle () 0)

(defn on-client (m)
  (match m
    ((Reply v) (print v))
    ((Request _ _) 0)))

(defn on-server (m)
  (match m
    ((Request from n)
      (ffi-call "zyl_actor_send_closure" from on-client (Reply (* n n)) 1000))
    ((Reply _) 0)))

(defn main ()
  (let server (spawn idle)
    (let client (spawn idle)
      (begin
        (ffi-call "zyl_actor_send_closure" server on-server (Request client 7) 1000)
        (ffi-call "zyl_actor_send_closure" server on-server (Request client 12) 1000)
        (ffi-call "zyl_actor_wait_all" 1000)
        (print "main done")
        0))))
```

Output:

```
49
144
main done
```

The message value is shared by pointer between threads, not copied. Nothing prevents two actors from reaching the same heap value, so keep messages immutable.

This example depends on actor ids: it works because the server has the lower id. `zyl_actor_wait_all` stops actors in id order (§21.5), so if the client is spawned first, a reply can arrive after the client has been stopped and is then lost.

`zyl_actor_send_closure` is reached through `ffi-call`, so in a package it needs the `ffi` capability as well as `actor`.

## 21.5 Waiting for Actors

There is no `wait_all` form; `(wait_all a)` fails at link time with `undefined reference to _ZYL_wait_all`. The available operations are:

| Operation | Effect |
|-----------|--------|
| `(ffi-call "zyl_actor_wait_all" 1000)` | polls until every mailbox is empty, then stops and joins **every** actor, in id order |
| `(actor-wait a)` (`actor/actor`) | marks `a` stopped and joins its thread; closure messages still queued are **discarded** |
| `(actor-terminate a)` | marks `a` stopped |
| `(actor-is-alive a)` | whether `a` is still running |

The generated `main` does **not** wait for actors. When `main` returns, the process exits and any actor still working is killed. End `main` with `zyl_actor_wait_all` when actor work must finish.

`stdlib/actor/actor.zyl` also provides `actor-spawn` and `actor-send`, wrappers around `spawn` and `send`, and `actor-send-with-timeout`, which ignores its timeout.

## 21.6 Determinism

Spec: §15 promises deterministic FIFO per actor, and §27 counts actor outputs as observable while scheduling is not. Together, the same program with the same inputs should produce the same actor output.

**The implementation does not meet this.** Every actor is its own pthread, and interleaving is up to the operating system scheduler. There is no scheduler loop, quantum or fixed order. Two actors that each print 200 lines produced 16 different outputs in 20 runs.

What does hold:

- **FIFO from one sender to one actor.** The mailbox is protected by a mutex, and closure messages run in queue order.
- **Sequential handling.** One actor runs one message at a time.

To get deterministic output from an actor program today, have exactly one actor produce output, or collect results and print them from `main` after `zyl_actor_wait_all`.

## 21.7 Actor Lifecycle

```
spawn             → thread created; entry function runs once
entry returns     → thread idles on its mailbox, running closure messages
stopped by        → zyl_actor_wait_all, actor-wait, actor-terminate,
                    or process exit (main returning)
```

An actor does not stop when its entry function returns. There is no `Shutdown` message convention in the runtime: stopping is an operation on the actor, not a message to it.

## 21.8 Mailbox Implementation

- **Unbounded**: a linked list, one allocation per message.
- **Mutex and condition variable**: many producers, one consumer. The mailbox is not lock-free.
- **No backpressure**: build it into your protocol if you need it (for example, reply messages that grant credit).

Two message kinds exist in the runtime: data messages from `send`, which are dropped, and closure messages from `zyl_actor_send_closure`, which run.

## 21.9 Errors in Actors

- A panic in an actor (for example a failed `assert-true`) **exits the whole process** with status 1. It does not stop just the one actor.
- Actor threads get the default pthread stack, about 8 MB. `main` runs on a very large reserved stack, so deep recursion that works in `main` can overflow in an actor.
- There is no supervision, failure notification or restart mechanism.

## 21.10 Capabilities

In a package with a `zyl.pkg`, `spawn`, `send` and `receive`, and any call into `stdlib/actor`, require the `actor` capability (§31.9):

```
PANIC: E_PKG_CAPABILITY_VIOLATION: capability: package demo/nocap uses actor in demo/nocap@0::nocap::helper without declaring it in zyl.pkg
```

Closure messages also use `ffi-call`, so they need `ffi` too. A lone file compiled without a manifest is not checked. The current pass also does not check the body of `main` (see Chapter 25, §25.11).

## 21.11 Performance Characteristics

Measured on the current runtime (x86_64 Linux). These are orders of magnitude, not guarantees.

| Operation | Cost |
|-----------|------|
| `spawn` | one `pthread_create`, about 10 µs |
| closure message send | mutex-protected enqueue plus allocation, about 250 ns |
| `zyl_actor_wait_all` | polls every 1 ms until the mailboxes drain |
| context switch | operating-system thread switch |

There are no tuning knobs: no quantum, no thread pool and no stack-size setting.

## 21.12 Errors

| Error | Cause |
|-------|-------|
| `E_CAPABILITY_LEAK` | a message or spawned expression names a `let-mut` of the enclosing scope (§28: "TMut leaked") |
| `E_SECRET_ESCAPE` | a `Secret` value crosses into an actor |
| `E_PKG_CAPABILITY_VIOLATION` | actor operation in a package without the `actor` capability |

The runtime defines no error for sending to a stopped actor. A closure message to a stopped actor is dropped silently, and a data `send` to an invalid id aborts the process.

## 21.13 Comparison with Other Models

| Feature | Erlang/Elixir | Go | Rust (Actix) | Zyl (spec) | Zyl (implemented) |
|---------|---------------|-----|--------------|------------|-------------------|
| Unit | process | goroutine | actor | actor | pthread per actor |
| Receive | `receive` | channel read | handler | `receive` | closure messages via `zyl_actor_send_closure` |
| Scheduling | preemptive | runtime M:N | async executor | not observable (§27) | OS threads |
| FIFO per actor | ✅ | per channel | ✅ | ✅ | ✅ (per sender) |
| Shared memory | ❌ | yes | ❌ | ❌ | messages shared by pointer |
| Supervision | built in | manual | built in | not specified | none |
| Deterministic output | ❌ | ❌ | ❌ | ✅ | ❌ |
