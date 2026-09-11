# Chapter 21: Actor Concurrency Model

Complete reference for Zyl's actor system: spawn, send, mailboxes, scheduling, and determinism guarantees.

## 21.1 Actor Model Overview

An actor is an isolated, single-threaded entity with:
- **Private state** (only accessible by that actor)
- **Mailbox** (FIFO queue of messages)
- **Behavior** (function processing messages)

```
Actor = (State, Mailbox, Behavior)
```

## 21.2 Spawning Actors

```
spawn ::= "spawn" Expression
```

```lisp
(spawn behavior-fn)
```

- `behavior-fn` : `(fn (message) body)` — takes one message argument
- Returns `ActorRef` — opaque handle for sending messages
- Actor runs on dedicated thread (pthread)

### Behavior Function

```lisp
(fn (msg)
  (match msg
    (MsgType1 arg1 arg2 (handle-msg1 arg1 arg2))
    (MsgType2 arg (handle-msg2 arg))
    (Shutdown unit)))
```

- Processes messages sequentially (one at a time)
- Can maintain state via closure capture (`let-mut`)
- Returns `unit` (or loops forever)

### State Patterns

```lisp
;; Pattern 1: Closure with let-mut
(spawn
  (let-mut (count 0)
    (fn (msg)
      (match msg
        (Inc (set! count (+ count 1)))
        (Get (print count))))))

;; Pattern 2: Actor with multiple behaviors (state machine)
(spawn
  (let-mut (state Disconnected)
    (fn (msg)
      (match msg
        (Connect (set! state Connected))
        (Data d (if (== state Connected) (process d)))
        (Disconnect (set! state Disconnected))))))
```

## 21.3 Sending Messages

```
send ::= "send" Expression Expression
```

```lisp
(send actor-ref message)
```

- **Asynchronous** — returns `unit` immediately
- **FIFO ordering** — messages processed in send order
- **Type-checked** — message must be Send-capable

### Send-Capable Types

| Type | Send? | Notes |
|------|-------|-------|
| Primitives (Int, Float, Bool, String) | ✅ | Immutable |
| `TCap<T>` | ✅ | Shared immutable |
| `TAtomic<T>` | ✅ | Thread-safe |
| ADTs/Structs with all Send fields | ✅ | Recursive check |
| `TMut<T>` | ❌ | Exclusive ownership |
| `TBox<T>` | ❌ | Unique ownership |
| `TPin<T>` | ❌ | FFI-pinned |
| Closures with TMut captures | ❌ | Leaks mutable state |

```lisp
;; ✅ OK
(send actor 42)
(send actor (Some "hello"))
(send actor (atomic-new 0))

;; ❌ COMPILE ERROR: E_CAPABILITY_LEAK
(let-mut x 10)
(send actor x)
```

## 21.4 Message Protocol Design

### Request-Response

```lisp
(deftype Request
  (Get (reply ActorRef))
  (Set String (reply ActorRef)))

;; Server
(spawn (fn (req)
  (match req
    (Get key reply (send reply (Ok (lookup key))))
    (Set key val reply (send reply (Ok (insert key val)))))))

;; Client
(let reply-actor (spawn (fn (resp) ...)))
(send server (Get "key" reply-actor))
```

### Streaming

```lisp
;; Sender streams data
(spawn (fn (sink)
  (for (item items)
    (send sink (Chunk item))
  (send sink Done))))

;; Receiver processes
(spawn (fn (msg)
  (match msg
    (Chunk item (process item))
    (Done (finish)))))
```

## 21.5 wait_all — Synchronization

```
wait_all ::= "wait_all" Expression+
```

```lisp
(wait_all actor1 actor2 actor3)
```

- Blocks current thread until all actors have **processed their current mailbox**
- Returns `unit`
- Use for: test synchronization, batch processing barriers
- **Use sparingly** — prefer async message passing

## 21.6 Determinism Guarantees

Zyl's actor system is **fully deterministic**:

1. **FIFO per actor** — messages processed in send order
2. **Deterministic scheduling** — round-robin quantum (no randomness)
3. **No shared state** — no data races possible
4. **Same inputs → same message order → same outputs**

### Scheduling Algorithm

```c
// Simplified (actor_runtime.c)
while (running) {
    for (actor in actors) {        // Fixed order
        Message* msg = mailbox_pop(actor);
        if (msg) {
            execute_behavior(actor, msg);
            if (--quantum == 0) yield();  // Fixed quantum
        }
    }
}
```

### Implications

- **Reproducible concurrency bugs** — run twice, get same interleaving
- **Testable** — `wait_all` + deterministic scheduling = reliable tests
- **No heisenbugs** — timing doesn't affect correctness

## 21.7 Actor Lifecycle

```
spawn → ActorRef created, thread started
    ↓
Message received → behavior runs, state updated
    ↓
... more messages ...
    ↓
Actor stops when:
  - Behavior function returns (finishes)
  - Program exits
  - (No explicit "stop" — design your own Shutdown message)
```

### Graceful Shutdown Pattern

```lisp
(deftype Control (Shutdown))

;; Actor
(spawn (let-mut (running true)
  (fn (msg)
    (match msg
      (Shutdown (set! running false))
      (Work ... (if running (process ...)))))))

;; Shutdown
(send actor (Shutdown))
(wait_all actor)  ; Wait for processing to finish
```

## 21.8 Mailbox Implementation

- **Unbounded** (heap-allocated queue)
- **Lock-free MPSC** (multi-producer, single-consumer)
- **No backpressure** — implement in protocol if needed

```lisp
;; Backpressure example
(deftype Work (Task Data) (Reply ActorRef))

;; Sender
(let credit (atomic-new MAX_IN_FLIGHT))
(send worker (Work task reply))
(atomic-sub credit 1)
;; When reply received: (atomic-add credit 1)
```

## 21.9 Error Handling in Actors

### Uncaught Errors

- Actor behavior errors → actor stops
- Other actors unaffected
- No supervision built-in (implement your own)

### Supervision Pattern

```lisp
(deftype SupervisorMsg
  (Start (child ActorRef))
  (ChildFailed (child ActorRef) (err String)))

(defn supervisor ()
  (spawn
    (let-mut (children Nil)
      (fn (msg)
        (match msg
          (Start child (set! children (Cons child children)))
          (ChildFailed child err
            (print "Restarting: " err)
            (let new (spawn ...)
              (set! children (Cons new (remove child children)))))))))
```

## 21.10 Performance Characteristics

| Operation | Cost |
|-----------|------|
| `spawn` | pthread_create (~10-50μs) |
| `send` | Lock-free queue push (~50ns) |
| Message process | Function call + match |
| `wait_all` | Barrier wait |
| Context switch | pthread yield (~1-2μs) |

### Tuning

- Quantum: fixed (configurable at runtime)
- Thread count: one per actor (M:N planned)
- Stack size: default pthread (configurable)

## 21.11 Errors

| Error | Cause |
|-------|-------|
| `E_CAPABILITY_LEAK` | Non-Send type sent to actor |
| `E_ACTOR_DEAD` | Send to terminated actor (implementation-defined) |
| `E_MAILBOX_FULL` | Not applicable (unbounded) |

## 21.12 Comparison with Other Models

| Feature | Erlang/Elixir | Go | Rust (Actix) | Zyl |
|---------|---------------|-----|--------------|-----|
| Isolation | Process | Goroutine + channels | Actor + mutex | Actor (no shared state) |
| Scheduling | Preemptive | Cooperative | Cooperative | Deterministic round-robin |
| FIFO per actor | ✅ | Channel | ✅ | ✅ |
| Shared memory | ❌ | Yes (`Arc<Mutex>`) | ❌ |
| Supervision | Built-in | Manual | Built-in | Manual pattern |
| Determinism | ❌ | ❌ | ❌ | ✅ |
| Hot code reload | ✅ | ❌ | ❌ | ❌ |