# Chapter 9: Concurrency with Actors

Zyl's concurrency model is based on **actors**: isolated entities that communicate by message passing, with no shared mutable state (Spec §15). This chapter describes the model, then what the current compiler and runtime implement. The runtime is still a subset of the design, and the gaps (most importantly, there is no way for an actor to receive a message yet) are called out where they matter. Every runnable example was compiled with `zyl` and run.

## 9.1 Actor Model Basics

In the specification, an actor has:

- **Private state** (only it can access)
- **Mailbox** (FIFO queue of messages)
- **Behavior** (code that runs on its own, isolated from other actors)

```
┌─────────────────────────────────────┐
│           Actor                     │
│  ┌─────────────────────────────┐    │
│  │      Mailbox (FIFO)         │    │
│  │  [Msg1] [Msg2] [Msg3] ...   │    │
│  └──────────────┬──────────────┘    │
│                 ▼                   │
│  ┌─────────────────────────────┐    │
│  │   Behavior                  │    │
│  └──────────────┬──────────────┘    │
│                 ▼                   │
│  ┌─────────────────────────────┐    │
│  │   Private State             │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Rules from Spec §15:**

- No shared mutable state between actors
- Messages must be **Send-capable**
- **FIFO ordering** per actor
- Actors are isolated; no direct memory sharing

The specification defines two operations, `spawn` and `send`. Everything else in this chapter (waiting for, stopping, and querying actors) comes from the standard library module `actor/actor`.

## 9.2 Spawning Actors

```lisp
(spawn (fn () body))
(spawn entry-fn)          ; a named zero-argument function also works
```

`spawn` starts a new actor running `body` on its own thread and returns immediately with an **actor reference**, an `Int` handle used by `send` and the `actor/actor` functions.

```lisp
(use actor/actor)

(defn crunch (n)
  (if (<= n 1) 1 (* n (crunch (- n 1)))))

(defn report-a () (print (crunch 5)))
(defn report-b () (print (crunch 6)))

(defn main ()
  (let a (spawn (fn () (report-a)))
    (begin
      (actor-wait a)
      (let b (spawn (fn () (report-b)))
        (begin
          (actor-wait b)
          (print "both done"))))))
```

Output:

```
120
720
both done
```

Two rules for the closure passed to `spawn` in the current compiler:

1. **Capture only immutable values.** A spawned closure may read variables from the enclosing scope; like any closure it gets copies of them. A closure that captures a `let-mut` variable is rejected at compile time with `E_CAPABILITY_LEAK` (Chapter 8, §8.6).
2. **Take no parameters.** There is no message argument: an actor's body cannot read its mailbox (§9.3). A parameter, if declared, receives 0.

## 9.3 Sending Messages

```lisp
(send actor-ref message)
```

- **Asynchronous**: returns immediately
- **FIFO**: messages are queued in send order
- **Checked**: a message that references a `let-mut` variable is rejected

```lisp
(use actor/actor)

(defn main ()
  (let a (spawn (fn () 0))
    (begin
      (send a 1)
      (send a 2)
      (send a 3)
      (actor-wait a)
      (print "sent three messages"))))
```

**Current limitation: messages cannot be received.** There is no `receive` form yet, and a spawned body has no parameter through which a message could arrive. The runtime queues each message in the actor's mailbox and discards it when it is dequeued. `send` is therefore useful today only for exercising the send path and its compile-time checks. The one way to deliver work to a running actor is a **closure message**: the runtime routine `zyl_actor_send_closure`, called through `ffi-call`, queues a call to a named one-parameter function on the actor's thread (Chapter 21, §21.4). Also avoid sending to an actor that has already been waited on or terminated: the runtime then tries to free the message as if it were a heap pointer, which aborts the program when the message is a plain `Int`.

### Send-Capable Types

The specification's Send rules:

| Type | Send? | Notes |
|------|-------|-------|
| `Int`, `Float`, `Bool`, `String` | Yes | Immutable primitives |
| `TCap<T>` | Yes | Shared immutable |
| `TAtomic<T>` | Yes | Thread-safe mutation |
| ADTs and structs with Send fields | Yes | Checked recursively |
| `TMut<T>` | No | Exclusive; cannot be shared |
| `TBox<T>` | No | Owned; would violate exclusivity |
| `TPin<T>` | No | FFI-pinned; not for actors |
| Closures capturing `TMut` | No | Would leak mutable state |

The compiler currently enforces the `TMut` rows, for both a sent message and a spawned closure's captures:

```lisp
(use actor/actor)

(defn main ()
  (let-mut x 10
    (let a (spawn (fn () 0))
      (begin
        (send a x)
        (actor-wait a)))))
```

```
PANIC: error[E_CAPABILITY_LEAK]: message sent to an actor references let-mut (TMut) variable `x` from the enclosing scope
  --> main.zyl:7:9
   |
 7 |         (send a x)
   |         ^
 4 |   (let-mut x 10
   |   - declared `let-mut` here
   = help: messages must be Send-capable; send a copy bound with plain `let`
```

## 9.4 Structuring Actor Code Today

Because `send` messages are never observed, everything an actor does has to be set up when it is spawned or delivered as a closure message. The practical pattern is:

1. Write the real logic as ordinary, pure functions (easy to test; see Chapter 11).
2. Give each actor a small entry function that calls that logic and reports its result (for example, by printing it or writing a file).
3. Spawn one closure per entry function, and wait for each actor before relying on its effects.

To hand an already running actor more work, use closure messages through `ffi-call` (Chapter 21, §21.4); each one runs a named handler with a single argument, in FIFO order. Stateful behaviors written in the model's own terms (a counter that handles `Inc`/`Get` messages with `receive`, a connection state machine) need `receive` and are not expressible yet.

## 9.5 Request-Response

In the design, an actor replies by sending to a reference it was given in the request. With `send` and `receive` that is not possible yet. It can be built from closure messages instead: the request carries the requester's actor reference, and the handler replies with a closure message to it. Chapter 21 (§21.4) has a complete, working example, including the ordering caveat it depends on.

## 9.6 Waiting for Actors

The `actor/actor` module provides:

| Function | Meaning |
|----------|---------|
| `(actor-wait a)` | Block until actor `a` has finished its body, then stop it and join its thread |
| `(actor-terminate a)` | Stop actor `a`'s mailbox loop and join its thread |
| `(actor-is-alive a)` | `true` until the actor has been waited on or terminated |
| `(actor-spawn f)`, `(actor-send a m)` | Function wrappers around `spawn` and `send` |

`actor-wait` does not drain the mailbox: messages still queued when the actor is stopped are dropped. To let every actor finish its queued closure messages first, call the runtime directly with `(ffi-call "zyl_actor_wait_all" 1000)`, which waits until every mailbox is empty and then stops and joins every actor (Chapter 21, §21.5).

There is no `wait_all` language form, but every compiled program runs `zyl_actor_wait_all` when it exits, so returning from `main` lets every actor finish its queued closure messages. This program:

```lisp
(defn main ()
  (let a (spawn (fn () (print "hi from actor")))
    (print "main exits")))
```

printed `hi from actor` in 200 of 200 runs. (Before 2026-09-24 the process did not wait, and the line appeared in only 186 of 200.) Wait explicitly where the order of output matters, as in §9.8.

## 9.7 Actor Lifecycle

```
spawn
  │  actor slot allocated, thread started
  ▼
body runs
  │
  ▼
mailbox loop: dequeue messages in FIFO order
  │  (data messages are discarded; closure messages run their handler)
  │
  ▼
actor-wait or actor-terminate
  │  actor marked dead, thread joined
  ▼
actor-is-alive returns false
```

At exit the process drains and stops every remaining actor. There is no other shutdown protocol beyond `actor-wait` and `actor-terminate`.

## 9.8 Determinism

The specification requires deterministic FIFO delivery per actor, and the runtime keeps each mailbox in send order. Scheduling, however, is done by the operating system: each actor is a POSIX thread, and output from actors that run at the same time can interleave differently from run to run (see §9.9). To keep a program's observable output deterministic today:

- wait for an actor before starting work whose output must come after it, or
- let only one actor (usually `main`) produce the output that must be ordered.

## 9.9 Common Patterns

### Fan-Out and Join

Spawn several independent workers, then wait for all of them:

```lisp
(use actor/actor)

(defn sum-to (n acc)
  (if (= n 0) acc (sum-to (- n 1) (+ acc n))))

(defn job-a () (print (sum-to 100 0)))
(defn job-b () (print (sum-to 1000 0)))
(defn job-c () (print (sum-to 10000 0)))

(defn main ()
  (let a (spawn (fn () (job-a)))
  (let b (spawn (fn () (job-b)))
  (let c (spawn (fn () (job-c)))
    (begin
      (actor-wait a)
      (actor-wait b)
      (actor-wait c)
      (print "all workers finished"))))))
```

Typical output:

```
5050
500500
50005000
all workers finished
```

The final line always comes last, because `main` prints it after joining every worker. The three worker lines can appear in any order; in 100 runs, one printed `500500` before `5050`. If the order matters, wait for each worker before spawning the next, as in §9.2.

### Pipelines, Worker Pools, and Supervision

These patterns pass messages between actors. Pipelines and pools can be approximated with closure messages (Chapter 21); supervision also needs failure notifications, which the runtime does not provide.

## 9.10 Mailboxes and Limits

Mailboxes are **unbounded** linked lists on the heap: if a producer outruns its consumer, memory grows. A program can have at most 1024 actors over its lifetime (`ZYL_MAX_ACTORS` in `runtime/actor_runtime.h`). Actor ids are never reused, and once the limit is reached `spawn` prints `zyl: actor limit reached (1024)` and returns an invalid reference.

## 9.11 Testing Actors

Test what the runtime guarantees (lifecycle and the send path) and keep the logic itself in plain functions tested directly. This is the style of `tests/regression/actors.zyl`:

```lisp
(use actor/actor)

(test "spawned-actor-is-alive"
  (let a (spawn (fn () 42))
    (assert-true (actor-is-alive a))))

(test "waited-actor-is-not-alive"
  (let a (spawn (fn () 0))
    (begin
      (send a 1)
      (actor-wait a)
      (assert-false (actor-is-alive a)))))

(run-tests)
```

```
test: spawned-actor-is-alive ... ok
test: waited-actor-is-not-alive ... ok

test result: 2 passed, 0 failed, 2 total
```

### Actors in Packages

Inside a package (a directory with a `zyl.pkg`, Spec §31.9), `spawn`, `send`, and any use of the `actor/` modules require the `actor` capability. Declare it in the manifest with `(capabilities actor)`; without it, compilation stops with `E_PKG_CAPABILITY_VIOLATION`:

```
PANIC: error[E_PKG_CAPABILITY_VIOLATION]: package book/actdemo uses actor in go without declaring it in zyl.pkg
```

A single file compiled directly is not capability-checked. (The current checker also skips the body of the root package's `main`, so a `spawn` written directly in `main` goes unreported; declare the capability anyway.)

---

## For Experts: Under the Hood

### Runtime Implementation (`runtime/actor_runtime.c`)

- **One POSIX thread per actor**, created by `zyl_actor_spawn`, which receives the spawned closure's code pointer and a state pointer. For a capturing closure it unpacks the closure block into its code and environment, so the environment arrives as that state pointer.
- **Mailbox**: a singly linked FIFO list protected by a per-actor mutex, with a condition variable to wake the actor thread.
- **Thread body**: run the entry function once, then loop, dequeuing messages until the actor is marked dead. A message is either a *data* message (what `send` produces; discarded) or a *closure* message (`zyl_actor_send_closure`, which runs a function in the actor's thread). No language form produces a closure message yet; the runtime routine is reachable only through a raw `ffi-call`, which is the one way code can currently be delivered to an actor after it starts.

### Message Representation

```c
typedef struct ZylMessage {
    int kind;                  /* ZYL_MSG_DATA or ZYL_MSG_CLOSURE */
    void* data;                /* the sent word, or a ZylClosureMsg* */
    struct ZylMessage* next;   /* FIFO link */
} ZylMessage;
```

`(send a m)` lowers to `zyl_actor_send(a, m)`: the value `m` is passed through as an opaque 64-bit word, never copied or boxed.

### Send Capability Check (Compile Time)

The check lives in `stdlib/compiler/mutability_check.zyl`. It reports `E_CAPABILITY_LEAK` when a `send` message, or the body of a spawned closure, refers to a `let-mut` variable of the enclosing scope. The rest of the Send table in §9.3 (rejecting `TBox`, `TPin`, and non-Send ADT fields) is specified but not yet checked.

### Scheduling

There is no scheduler of Zyl's own. Actor threads are scheduled by the kernel, which is why cross-actor ordering is not deterministic (§9.8). A deterministic scheduler is part of the design but not implemented.

---

**Next:** [Chapter 10: Macros and Metaprogramming](ch10-macros.md) covers `defmacro`, expansion order, and what the current macro expander does and does not do.
