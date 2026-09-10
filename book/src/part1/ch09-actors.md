# Chapter 9: Concurrency with Actors

Zyl's concurrency model is based on **actors** — isolated, single-threaded entities that communicate via message passing. No shared mutable state, no locks, no data races.

## 9.1 Actor Model Basics

An actor has:
- **Private state** (only it can access)
- **Mailbox** (FIFO queue of messages)
- **Behavior** (function processing messages)

```
┌─────────────────────────────────────┐
│           Actor                     │
│  ┌─────────────────────────────┐   │
│  │      Mailbox (FIFO)         │   │
│  │  [Msg1] [Msg2] [Msg3] ...   │   │
│  └──────────────┬──────────────┘   │
│                 ▼                  │
│  ┌─────────────────────────────┐   │
│  │   Behavior Function         │   │
│  │   (msg, state) → new_state  │   │
│  └──────────────┬──────────────┘   │
│                 ▼                  │
│  ┌─────────────────────────────┐   │
│  │   Private State             │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Key guarantees:**
- Messages processed **sequentially** (one at a time)
- **FIFO ordering** per actor (deterministic)
- **No shared memory** between actors
- **Type-safe** message passing

## 9.2 Spawning Actors

```lisp
(spawn behavior-fn)
```

Returns an `ActorRef` — opaque handle to send messages to.

```lisp
;; Simple actor: prints messages
(def printer-actor
  (spawn (fn (msg)
    (print "Got: " msg))))

;; Actor with state (using closure capture)
(def counter-actor
  (spawn
    (let-mut (count 0)
      (fn (msg)
        (match msg
          (Inc (set! count (+ count 1)))
          (Get (print "Count: " count)))))))
```

**Behavior function signature:** `(fn (message) body)` — takes one argument (the message).

## 9.3 Sending Messages

```lisp
(send actor-ref message)
```

- **Asynchronous** — returns immediately (`unit`)
- **FIFO** — messages processed in send order
- **Type-checked** — message must be Send-capable

```lisp
(send printer-actor "hello")
(send counter-actor (Inc))
(send counter-actor (Get))
```

### Send-Capable Types

| Type | Send? | Notes |
|------|-------|-------|
| `Int`, `Float`, `Bool`, `String` | ✅ | Immutable primitives |
| `TCap<T>` | ✅ | Shared immutable |
| `TAtomic<T>` | ✅ | Thread-safe mutation |
| `Vec<T>`, `Map<K,V>` (T, K, V Send) | ✅ | Deeply immutable |
| ADTs with Send fields | ✅ | Recursive check |
| `TMut<T>` | ❌ | Exclusive — can't share |
| `TBox<T>` | ❌ | Owned — would violate exclusivity |
| `TPin<T>` | ❌ | FFI-pinned — not for actors |
| Closures capturing TMut | ❌ | Leaks mutable state |

```lisp
;; ✅ OK
(send actor 42)
(send actor (Some "hi"))
(send actor (vec-create 0 10))

;; ❌ COMPILE ERROR: E_CAPABILITY_LEAK
(let-mut (x 10)
  (send actor x))  ; x is TMut
```

## 9.4 Actor State Patterns

### Pattern 1: Closure with `let-mut`

```lisp
(defn make-counter ()
  (spawn
    (let-mut (count 0)
      (fn (msg)
        (match msg
          (Inc (set! count (+ count 1)))
          (Dec (set! count (- count 1)))
          (Get (print count)))))))
```

### Pattern 2: State in Message (Stateless Actors)

```lisp
(defn stateless-processor ()
  (spawn (fn (msg)
    (match msg
      (Process data (print "Processing: " data))))))
```

### Pattern 3: Actor with Multiple Behaviors (State Machine)

```lisp
(deftype ConnectionMsg
  (Connect)
  (Data String)
  (Disconnect))

(defn connection-actor ()
  (spawn
    (let-mut (state Disconnected)
      (fn (msg)
        (match msg
          (Connect
            (if (== state Disconnected)
              (set! state Connected)
              (print "Already connected")))
          (Data d
            (if (== state Connected)
              (print "Received: " d)
              (print "Not connected")))
          (Disconnect (set! state Disconnected)))))))
```

## 9.5 Request-Response Pattern

Actors often need to reply. Pass a reply-to actor:

```lisp
(deftype Request
  (Get (reply ActorRef))
  (Set Int (reply ActorRef)))

(defn key-value-store ()
  (spawn
    (let-mut (store (map-create 0 10))
      (fn (msg)
        (match msg
          (Get key reply
            (send reply (map-get store key "NOT_FOUND")))
          (Set key value reply
            (set! store (map-put store key value))
            (send reply (Ok unit))))))))

;; Client usage:
(let reply-actor (spawn (fn (response) (print "Reply: " response))))
(send store (Get "key" reply-actor))
```

## 9.6 `wait_all` — Synchronization

```lisp
(wait_all actor-ref1 actor-ref2 ...)
```

Blocks until all actors have processed their current mailbox. Returns `unit`.

```lisp
(let a1 (spawn ...))
(let a2 (spawn ...))
(send a1 (Work))
(send a2 (Work))
(wait_all a1 a2)  ; Wait for both to finish
(print "Both done")
```

**Use sparingly** — prefer async message passing. `wait_all` is for test/benchmark synchronization.

## 9.7 Actor Lifecycle

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
  - (No explicit "stop" — just stop sending messages)
```

No graceful shutdown protocol built-in — design your own with a `Shutdown` message if needed.

## 9.8 Determinism Guarantees

Zyl's actor system is **fully deterministic**:

1. **FIFO per actor** — messages processed in send order
2. **Deterministic scheduling** — round-robin or similar (no randomness)
3. **No shared state** — no race conditions possible
4. **Same inputs → same message order → same outputs**

This means: **actor programs are reproducible**. Run twice, get identical results.

## 9.9 Common Patterns

### Worker Pool

```lisp
(defn make-workers (n task-handler)
  (let workers (vec-create 0 n))
  (for (i 0) (< i n)
    (set! workers (vec-push workers (spawn task-handler))))
  workers)

(defn dispatch (workers task)
  (let idx (% (hash task) (vec-len workers)))
  (send (vec-get workers idx) task))
```

### Pipeline

```lisp
;; Stage 1: read → Stage 2: process → Stage 3: write
(let reader (spawn (fn (msg) ...)))
(let processor (spawn (fn (msg) ...)))
(let writer (spawn (fn (msg) ...)))

(send reader (ReadFile "input.txt"))
;; Reader sends to processor, processor sends to writer
```

### Supervision (Error Handling)

```lisp
(deftype SupervisorMsg
  (Start (child ActorRef))
  (ChildFailed (child ActorRef) (err String)))

(defn supervisor ()
  (spawn
    (let-mut (children Nil)
      (fn (msg)
        (match msg
          (Start child
            (set! children (Cons child children)))
          (ChildFailed child err
            (print "Child failed: " err)
            (let new-child (spawn ...)
              (set! children (Cons new-child (remove child children)))))))))
```

## 9.10 Mailbox Overflow

Mailboxes are **unbounded** (heap-allocated queue). If producer outruns consumer, memory grows. For bounded mailboxes, implement backpressure in your protocol:

```lisp
;; Sender checks credit
(send worker (Work data (reply-to credit-actor)))

;; Worker returns credit when done
(send credit-actor (Credit))
```

## 9.11 Testing Actors

Use `wait_all` in tests:

```lisp
(test "actor-counter"
  (let counter (make-counter)
    (send counter (Inc))
    (send counter (Inc))
    (send counter (Get))
    (wait_all counter)
    (assert-equal (get-output) "Count: 2")))
```

---

## For Experts: Under the Hood

### Runtime Implementation (`src/runtime/actor_runtime.c`)

- **pthread per actor** (configurable: M:N threading planned)
- **Lock-free mailbox** (MPSC queue)
- **Work-stealing scheduler** (planned)
- **Deterministic scheduling**: fixed round-robin quantum

### Message Representation

```c
struct Message {
    void* payload;      // TCap<T> or TAtomic<T> (Send-capable)
    size_t size;
    ActorRef* sender;   // For reply
};
```

### Send Capability Check (Compile-Time)

During type inference (Phase 3):
1. Infer type of message expression
2. Check `Send` trait implementation
3. `Send` auto-derived for:
   - Primitives
   - `TCap<T>` where T: Send
   - ADTs/Structs where all fields: Send
   - `TAtomic<T>`
4. Reject `TMut`, `TBox`, `TPin`, closures with TMut captures

### Deterministic Scheduling

```c
// Simplified scheduler loop
while (1) {
    for (actor in actors) {
        Message* msg = mailbox_pop(actor);
        if (msg) behavior(actor, msg);
    }
}
```

No randomness, no priority inversion — pure round-robin.

---

**Next:** [Chapter 10: Macros and Metaprogramming](ch10-macros.md) — hygienic macros, pattern matching, and compile-time code generation.