# Chapter 5: Ownership, Regions, and Capability Types

This chapter explains Zyl's unique memory model — the heart of what makes Zyl both safe and fast. If you understand this chapter, you understand Zyl.

## 5.1 The Problem Zyl Solves

Every systems language must answer: **who owns this memory, and when is it freed?**

| Language | Approach |
|----------|----------|
| C/C++ | Manual `malloc`/`free` — programmer responsible, errors common |
| Rust | Ownership + borrow checker — compile-time, but complex annotations |
| Go/Java/Python | Garbage collector — runtime overhead, non-deterministic pauses |
| Zyl | **Region inference + capability types** — compile-time, inferred, deterministic |

Zyl's approach: **the compiler proves where every value lives and who can access it**. You rarely write annotations — the compiler infers them.

## 5.2 Regions — Where Values Live

Every value in Zyl is assigned to exactly one **region** at compile time:

| Region | Purpose | Lifetime |
|--------|---------|----------|
| **Stack** | Local variables, function parameters | Freed when function returns |
| **Heap** | Escaped values, captured closures, collections | Freed when owning scope ends |
| **Global** | Top-level `def` constants | Program lifetime (eager init) |
| **Circular** | Cyclic data structures | Freed by cycle detector |
| **Pin** | FFI-pinned memory (non-moving) | Manual via `ffi-unpin` |

### Region Rules (from Spec §9.1)

```
R1. Local stack allocation: If variable does not escape → Stack.
R2. Escape allocation: If returned, captured by escaping closure, or sent to actor → Heap.
R3. Actor transfer: spawn/send requires Send-capable type (TCap/TAtomic).
R4. FFI rule: ffi-call requires Pin region AND FFI_Pinnable type.
R5. Closure capture promotion: Escaping closure captures promoted to Heap.
R6. Cyclic structures: Cyclic references detected among heap values → Circular region.
R7. Global Region: Immutable constants only. Eager initialization. No mutation allowed.
R8. Pin Region: Non-moving arena. Values physically copied here for FFI. Never compacted.
```

### Visual: Region Assignment Flow

```
┌─────────────────────────────────────────────────────────────┐
│  let x = 42                                                 │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────┐    Does x escape?    ┌─────────┐              │
│  │ Stack   │ ────── No ──────────► │ Stack   │  (freed on return)
│  └─────────┘                      └─────────┘              │
│       │ Yes                                                       
│       ▼                                                     │
│  ┌─────────┐    Captured by       ┌─────────┐              │
│  │ Heap    │ ──── escaping closure? ─► │ Heap   │             
│  └─────────┘                      └─────────┘             
│       │ Yes                                                       
│       ▼                                                     │
│  ┌─────────┐    Sent to actor?    ┌─────────┐             
│  │ Heap    │ ────── Yes ────────► │ Heap    │ (Send check)
│  └─────────┘                      └─────────┘             
│       │ No                                                        
│       ▼                                                    
│  ┌─────────┐    FFI arg?         ┌─────────┐             
│  │ Pin     │ ────── Yes ────────► │ Pin     │ (via ffi-pin)
│  └─────────┘                      └─────────┘             
└─────────────────────────────────────────────────────────────┘
```

## 5.3 Capability Types — Who Can Access

Regions say *where*; capabilities say *how*. Two fundamental capabilities:

| Capability | Notation | Meaning | Aliasing |
|------------|----------|---------|----------|
| **Shared Immutable** | `TCap<T>` | Read-only, any number of references | ✅ Unlimited |
| **Exclusive Mutable** | `TMut<T>` | Read-write, exactly one reference | ❌ None |

**The Invariant (Spec §10):**
> For any memory location: either exactly one `TMut` reference OR any number of `TCap` references. Never both.

Violation → **compile error `E_MUT_CONFLICT`**.

### Additional Capabilities

| Capability | Notation | Use Case |
|------------|----------|----------|
| Atomic | `TAtomic<T>` | Thread-safe mutation (actors) |
| Boxed | `TBox<T>` | Heap allocation with ownership |
| Pinned | `TPin<T>` | FFI — non-moving memory |

### Capability Inference (You Don't Write These)

```lisp
;; You write:
(let (x 42) x)

;; Compiler infers:
;; x : TCap<Int>  (read-only, stack-allocated)

;; You write:
(let-mut (y 10) (set! y 20) y)

;; Compiler infers:
;; y : TMut<Int>  (mutable, stack-allocated)

;; You write:
(defn make-adder (n) (fn (x) (+ x n)))

;; Compiler infers for closure:
;; n : TCap<Int>  (read-only capture)
;; closure : TCap<TFun([Int], Int)>  (if non-escaping)
;; closure : TBox<TFun([Int], Int)>  (if escaping → Heap)
```

## 5.4 Struct Mutability: Rebind, Don't Mutate

This is a **key difference from Rust/C++**:

```lisp
(defstruct Point (x) (y))

;; ❌ FORBIDDEN — direct field mutation
(set! (struct-get p "x") 10)

;; ✅ ALLOWED — rebind entire struct
(let-mut (p (make-Point 0 0))
  (set! p (make-Point 10 20)))
```

**Why?** If `p` is `TCap<Point>` (shared), you can't mutate any field. If `p` is `TMut<Point>` (exclusive), you *could* mutate a field — but then you'd need field-level capabilities. Zyl chooses simplicity: **whole-value rebinding only**.

This means:
- `let-mut` + `set!` replaces the entire struct
- Old struct becomes unreachable → region system reclaims it
- No partial mutation, no field-level aliasing complexity

## 5.5 Escape Analysis — When Stack Becomes Heap

A value **escapes** if:
1. **Returned** from function
2. **Captured** by a closure that escapes
3. **Sent** to an actor via `send`
4. **Passed to FFI** via `ffi-pin`

```lisp
;; Stack-allocated (doesn't escape)
(defn add (a b) (+ a b))

;; Heap-allocated (returned)
(defn make-point (x y)
  (make-Point x y))   ; Point escapes → Heap

;; Heap-allocated (captured by escaping closure)
(defn make-counter ()
  (let-mut (count 0)
    (fn () (set! count (+ count 1)) count)))  ; count escapes → Heap

;; Heap-allocated (sent to actor)
(spawn (fn (msg) (send other-actor msg)))  ; msg escapes → Heap
```

**Stack → Heap promotion** is automatic and safe. The compiler inserts the allocation.

## 5.6 Send Capability — Actor Safety

Actors communicate by message passing. To send a value, it must be **Send-capable**:

| Type | Send? | Why |
|------|-------|-----|
| `TCap<T>` | ✅ | Immutable, safe to share |
| `TAtomic<T>` | ✅ | Thread-safe by design |
| `TMut<T>` | ❌ | Exclusive — can't share across actors |
| `TBox<T>` | ❌ | Owned — would violate exclusivity |
| `TPin<T>` | ❌ | FFI-pinned — not for actor transfer |

```lisp
;; ✅ OK — immutable data
(spawn (fn (data) ...) (Some "hello"))

;; ❌ COMPILE ERROR — TMut not Send
(let-mut (x 10)
  (spawn (fn () x)))  ; Error: E_CAPABILITY_LEAK
```

## 5.7 FFI Safety — Pin Region

Foreign function calls require **Pin region** + **timeout**:

```lisp
(ffi-call "c_function" (ffi-pin my-int) 1000)  ; timeout in ms
```

**FFI_Pinnable types** (Spec §16):
- `Int`, `Float`, `Bool`, `String`
- `Vec<T>` where T is FFI_Pinnable
- Structs/ADTs composed solely of FFI_Pinnable types

```lisp
;; Pin copies value to non-moving arena
;; Returns stable pointer for C call
;; Lifetime tied to FFI call scope unless manually managed
(ffi-pin 42)           ; Pin<Int>
(ffi-unpin pinned-val) ; Explicit free
```

## 5.8 Circular Region — Cyclic Data

```lisp
;; Creating a cycle requires heap allocation + mutation
(let-mut (a (make-Node 1))
  (let-mut (b (make-Node 2))
    (set! a (make-Node 1 b))  ; a.next = b
    (set! b (make-Node 2 a)))) ; b.next = a
```

The compiler detects cycles during region inference and assigns **Circular region**. Reclamation uses a cycle detector (not reference counting).

## 5.9 Global Region — Constants Only

```lisp
(def PI 3.14159)           ; Global region
(def CONFIG (make-Config ...))  ; Global region (immutable)

;; ❌ FORBIDDEN: mutation of global
(set! PI 3.0)   ; Error: Global region immutable
```

## 5.10 Practical Examples

### Example 1: Function Parameters

```lisp
(defn process (data)      ; data : TCap<Vec<Int>> (read-only)
  (vec-len data))

(defn modify (data)       ; data : TMut<Vec<Int>> (exclusive)
  (vec-push data 42))
```

Caller must have appropriate capability:
```lisp
(let-mut (v (vec-create 0 10))
  (modify v))    ; OK — v is TMut

(let (v (vec-create 0 10))
  (process v))   ; OK — v is TCap (implicit coercion TMut → TCap for read)
```

### Example 2: Closure Capture

```lisp
;; Non-escaping closure: captures by reference (Stack)
(defn apply-twice (f x)
  (f (f x)))    ; f doesn't escape

;; Escaping closure: captures promoted to Heap
(defn make-adder (n)
  (fn (x) (+ x n)))   ; n captured, closure returned → n : Heap, closure : TBox
```

### Example 3: Actor Communication

```lisp
;; Actor state must be TCap or TAtomic
(spawn
  (fn (mailbox)
    (let-mut (state 0)
      (loop
        (match (receive mailbox)
          (Inc (set! state (+ state 1)))
          (Get (send reply-to state)))))))

;; Message must be Send-capable
(send actor (Inc))      ; OK — Inc is TCap (no payload)
(send actor (Set 42))   ; OK — Int is TCap
```

## 5.11 Common Patterns

### Pattern: Thread-Local Mutable State

```lisp
;; Use let-mut at top level of function
(defn process-items (items)
  (let-mut (count 0)
    (for (item items) ...)
    count))
```

### Pattern: Builder with Mutation

```lisp
(defn build-config ()
  (let-mut (cfg (make-Config defaults))
    (set! cfg (make-Config ... cfg ...))  ; Rebind with changes
    cfg))
```

### Pattern: Shared Read-Only Data

```lisp
(def CONFIG (load-config))  ; Global, immutable, TCap

(defn worker (id)
  (print "Worker " id " using " CONFIG))
```

## 5.12 Error Messages You'll See

| Error | Cause | Fix |
|-------|-------|-----|
| `E_MUT_CONFLICT` | `TMut` and `TCap` alias same memory | Restructure: don't share mutable data |
| `E_REGION_ESCAPE` | Value escapes its region | Let compiler promote (usually automatic) |
| `E_CAPABILITY_LEAK` | `TMut` sent to actor / stored in shared struct | Use `TCap`/`TAtomic` for shared data |
| `E_FFI_PIN_TYPE` | Non-pinnable type passed to `ffi-call` | Wrap in pinnable struct or use primitives |

## 5.13 Mental Model: Regions + Capabilities = Safety

Think of it as two independent dimensions:

```
                    CAPABILITY
              ┌─────────────┬─────────────┐
              │   TCap      │   TMut      │
              │ (shared)    │ (exclusive) │
REGION  ┌─────┼─────────────┼─────────────┤
Stack   │     │  ✅ Safe    │  ✅ Safe    │
        │     │  (read-only)│  (owner)    │
        ├─────┼─────────────┼─────────────┤
Heap    │     │  ✅ Safe    │  ⚠️ Single  │
        │     │  (shared)   │  owner only │
        ├─────┼─────────────┼─────────────┤
Pin     │     │  ✅ FFI     │  ❌ No      │
        │     │  (read-only)│             │
        └─────┴─────────────┴─────────────┘
```

**The compiler ensures every (region, capability) combination is valid.**

---

## For Experts: Under the Hood

### Region Inference Algorithm (Two-Pass)

**Pass 1: Bottom-up (collect constraints)**
- Traverse AST from leaves to root
- Each variable gets a region variable `ρ`
- Constraints: `ρ₁ ≤ ρ₂` (region subsumption)

**Pass 2: Top-down (solve + promote)**
- Solve constraints with Stack ≤ Heap ≤ Circular
- Promote Stack → Heap where escape detected
- Assign final regions

### Capability Inference

- Every binding gets capability variable `κ`
- Constraints from usage:
  - Read → `κ = TCap`
  - Write (`set!`) → `κ = TMut`
  - Capture by escaping closure → `κ = TCap` + promote to Heap
  - Send to actor → `κ = TCap` or `TAtomic`

### Aliasing Check (Compile-Time)

At each program point, for each memory location:
- Count `TMut` references: must be ≤ 1
- Count `TCap` references: any number
- If both > 0 → `E_MUT_CONFLICT`

This is a **flow-sensitive** analysis — capabilities can change along control flow paths.

### Determinism

Region and capability assignment is **fully deterministic**:
- Ordered constraint solving (FNV-1a hashed maps)
- No heuristics, no randomness
- Same source → identical region/capability assignment

---

**Next:** [Chapter 6: Pattern Matching and Error Handling](ch06-pattern-matching-error-handling.md) — exhaustive `match`, `try/catch` as syntactic sugar, and the `Result`/`Option` patterns.