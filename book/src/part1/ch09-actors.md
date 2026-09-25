# Chapter 9: Concurrency with Actors

Zyl's concurrency model is based on **actors**: isolated entities that communicate by message passing, with no shared mutable state (Spec §15). This chapter describes the model, then what the current compiler and runtime implement. The runtime is still a subset of the design, and the gaps (most importantly, scheduling is left to the operating system) are called out where they matter. Every runnable example was compiled with `zyl` and run.

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

The language forms are `spawn`, `send`, `receive` and `actor-self`. Everything else in this chapter (waiting for, stopping, and querying actors) comes from the standard library module `actor/actor`.

## 9.2 Spawning Actors

```lisp
(spawn (fn () body))
(spawn entry-fn)          ; a named zero-argument function also works
```

`spawn` starts a new actor running `body` on its own thread and returns immediately with an **actor reference**, a value of type `Actor` used by `send` and the `actor/actor` functions. An `Actor` is not an `Int`: it cannot be added to, and an `Int` cannot be sent to.

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
          (print "both done")))))
  0)
```

Output:

```
120
720
both done
```

Two rules for the closure passed to `spawn` in the current compiler:

1. **Capture only immutable values.** A spawned closure may read variables from the enclosing scope; like any closure it gets copies of them. A closure that captures a `let-mut` variable is rejected at compile time with `E_CAPABILITY_LEAK` (Chapter 8, §8.6).
2. **Take no parameters.** Messages are read with `(receive)` (§9.3), not passed as an argument. Spawning a function that takes a parameter is `E_TYPE_MISMATCH`.

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
      (print "sent three messages")))
  0)
```

The messages above are never read, so they are dropped when the actor stops. To read them, the actor calls `receive`.

### Receiving Messages

```lisp
(receive)       ; the next message in this actor's mailbox; blocks until one arrives
(actor-self)    ; this actor's own reference
```

`receive` returns the message. It is the one form the type checker does not see through yet: its result takes whatever type the code that uses it needs, so matching it against `CounterMsg` arms, or printing it as an `Int`, is accepted without any check that the sender sent that type. Mailboxes are to be replaced by typed channels, which will close this hole; until then, keep one message type per actor and match on it right away. Messages are usually ADT values, so the actor matches on what it received and loops with a tail call to wait for the next one. A message that expects an answer carries the sender's reference, obtained with `actor-self`; `main` has a mailbox too, so an actor can reply to it:

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
        (print (receive))
        (send c (Add 30))
        (send c (Stop me))
        (print (receive))
        0))))
```

Output:

```
12
42
```

`Get` and `Stop` carry the reference of whoever asked, so their fields are typed `Actor`: `actor-self` returns one, and `send` takes one as its first argument. Declaring them `Int`, as older versions of this program did, is now `E_TYPE_MISMATCH` at the `send`.

`counter-loop` calls itself in tail position, so it runs in constant stack however many messages it handles. An actor still blocked in `receive` when `main` returns does not hold up the exit: it is idle, and the runtime stops it. A `receive` that no message ever answers blocks forever. Sending to a reference that does not name a live actor does nothing. `book/examples/actor-counter/counter.zyl` is a complete version of this program.

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

## 9.4 Structuring Actor Code

A stateful actor is a recursive loop over `receive`, with its state passed as the loop's parameters, as `counter-loop` above does. The practical pattern is:

1. Write the real logic as ordinary, pure functions (easy to test; see Chapter 11).
2. Define the actor's protocol as an ADT, one variant per kind of message.
3. Give each actor a loop that receives a message, matches on it, and calls itself with the new state; the variant that stops the actor simply does not loop.

The runtime also has **closure messages**, queued by its C entry `zyl_actor_send_closure`, which run a C function on the actor's thread. A Zyl program cannot send one: the entry has no signature in the compiler's table, and an `extern` for a runtime entry is `E_FFI_RESTRICTED` (Chapter 21, §21.4). Every message a Zyl program sends goes through `send` and `receive`.

## 9.5 Request-Response

A request carries the requester's reference, and the actor answers with `send` to it; the requester waits for the answer with its own `receive`. The `Get` message of §9.3 is exactly this. A small helper keeps call sites short:

```lisp
(defn ask (c me)
  (begin
    (send c (Get me))
    (receive)))
```

Replies arrive in the order they were sent, but when several actors reply to the same mailbox, their replies interleave in whatever order the threads ran. Give each reply a variant that says what it answers when more than one actor can reply.

## 9.6 Waiting for Actors

The `actor/actor` module provides:

| Function | Meaning |
|----------|---------|
| `(actor-wait a)` | Block until actor `a` has finished its body, then stop it and join its thread |
| `(actor-terminate a)` | Stop actor `a`'s mailbox loop and join its thread |
| `(actor-is-alive a)` | `true` until the actor has been waited on or terminated |
| `(actor-spawn f)`, `(actor-send a m)` | Function wrappers around `spawn` and `send` |
| `(actor-send-with-timeout a m t)` | `send` wrapped in a `Result`: `(Ok ...)`, or `(Err e)` if the send raised. The timeout `t` is ignored, because `send` never blocks on a mailbox |

`actor-wait` does not drain the mailbox: messages still queued when the actor is stopped are dropped. To let every actor finish its queued messages first, call the runtime directly with `(ffi-call "zyl_actor_wait_all" 1000)`. It needs no declaration, because the compiler's signature table types it `-> Unit` (Chapter 12); it waits until every mailbox is empty and then stops and joins every actor (Chapter 21, §21.5).

There is no `wait_all` language form, but every compiled program runs `zyl_actor_wait_all` when it exits, so returning from `main` lets every actor finish its queued messages; an actor waiting in `receive` for a message that will never come is stopped. This program:

```lisp
(defn main ()
  (let a (spawn (fn () (print "hi from actor")))
    (print "main exits"))
  0)
```

printed `hi from actor` in 200 of 200 runs. (Before 2026-09-24 the process did not wait, and the line appeared in only 186 of 200.) Wait explicitly where the order of output matters, as in §9.8.

## 9.7 Actor Lifecycle

```
spawn
  │  actor slot allocated, thread started
  ▼
body runs
  │  (receive) takes the next message, in FIFO order;
  │  closure messages queued ahead of it run first
  ▼
body returns: mailbox loop runs any remaining closure messages
  │  (unread data messages are dropped)
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
      (print "all workers finished")))))
  0)
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

Pipelines and worker pools are loops over `receive` that forward work with `send`: each stage receives a message, transforms it, and sends the result to the next stage's reference, which it was given when spawned. Supervision also needs failure notifications, which the runtime does not provide.

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
- **Thread body**: run the entry function once, then loop, dequeuing messages until the actor is marked dead. A message is either a *data* message (what `send` produces; `receive` returns it, and one left unread when the body returns is dropped) or a *closure* message (`zyl_actor_send_closure`, a C entry a Zyl program cannot call, which runs a C function in the actor's thread). `zyl_actor_receive` runs closure messages it finds ahead of the next data message. `main` gets a mailbox, without a thread, the first time it calls `actor-self` or `receive`.

### Message Representation

```c
typedef struct ZylMessage {
    ZylMessageKind kind;       /* ZYL_MSG_DATA or ZYL_MSG_CLOSURE */
    void* data;                /* the sent word, or a ZylClosureMsg* */
    struct ZylMessage* next;   /* FIFO link */
} ZylMessage;
```

`(send a m)` lowers to `zyl_actor_send(a, m)`, `(receive)` to `zyl_actor_receive()` and `(actor-self)` to `zyl_actor_self()`; the value `m` is passed through as an opaque 64-bit word, never copied or boxed. That is also why `receive` is untyped: the word carries no record of the type it was sent at.

### Send Capability Check (Compile Time)

The check lives in `stdlib/compiler/mutability_check.zyl`. It reports `E_CAPABILITY_LEAK` when a `send` message, or the body of a spawned closure, refers to a `let-mut` variable of the enclosing scope. The rest of the Send table in §9.3 (rejecting `TBox`, `TPin`, and non-Send ADT fields) is specified but not yet checked.

### Scheduling

There is no scheduler of Zyl's own. Actor threads are scheduled by the kernel, which is why cross-actor ordering is not deterministic (§9.8). A deterministic scheduler is part of the design but not implemented.

---

**Next:** [Chapter 10: Macros and Metaprogramming](ch10-macros.md) covers `defmacro`, expansion order, and what the current macro expander does and does not do.
