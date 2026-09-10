# Chapter 17: Capability Types and Aliasing

Complete reference for Zyl's capability type system: TCap, TMut, TAtomic, TBox, TPin, and the aliasing invariant.

## 17.1 The Aliasing Invariant (Core Guarantee)

> **For any memory location: either exactly one TMut reference OR any number of TCap references. Never both.**

This is enforced **at compile time** — violation = `E_MUT_CONFLICT`.

## 17.2 Capability Types

### TCap<T> — Shared Immutable

```
TCap<T> ::= "TCap" "<" Type ">"
```

- **Access**: Read-only
- **Aliasing**: Unlimited references
- **Region**: Stack or Heap
- **Subtyping**: `TCap<T>` is supertype of `TMut<T>`, `TAtomic<T>`, `TBox<T>`, `TPin<T>`
- **Created by**: Default for `let`, function params, read-only captures

```lisp
(let x 42)              ; x : TCap<Int> @ Stack
(defn foo (y) y)        ; y : TCap<T> (param)
```

### TMut<T> — Exclusive Mutable

```
TMut<T> ::= "TMut" "<" Type ">"
```

- **Access**: Read-write (via `set!` rebinding)
- **Aliasing**: Exactly one reference
- **Region**: Stack or Heap
- **Created by**: `let-mut`, mutated captures

```lisp
(let-mut x 42)          ; x : TMut<Int> @ Stack
(set! x 10)             ; Rebinding allowed
```

**Restrictions:**
- Cannot be shared (no `TCap<TMut<T>>`)
- Cannot be sent to actors
- Cannot be captured by escaping closure (unless promoted to Heap with unique ownership)

### TAtomic<T> — Thread-Safe Mutation

```
TAtomic<T> ::= "TAtomic" "<" Type ">"
```

- **Access**: Atomic read-modify-write
- **Aliasing**: Unlimited references
- **Region**: Heap
- **Operations**: `atomic-load`, `atomic-store`, `atomic-add`, `atomic-sub`, `atomic-cas`
- **Actor-safe**: Can be sent between actors

```lisp
(let counter (atomic-new 0))
(atomic-add counter 1)
(spawn (fn () (atomic-add counter 1)))  ; OK — Send capable
```

### TBox<T> — Heap-Owned

```
TBox<T> ::= "TBox" "<" Type ">"
```

- **Access**: Unique owner (like `Box<T>` in Rust)
- **Aliasing**: Single owner, but can create `TCap` borrows
- **Region**: Heap
- **Created by**: Explicit `TBox` allocation, recursive structures

```lisp
(deftype List (Cons T (TBox (List T))) Nil)
```

### TPin<T> — FFI-Pinned

```
TPin<T> ::= "TPin" "<" Type ">"
```

- **Access**: Read-only from Zyl, read-write from C
- **Aliasing**: Single pin per value
- **Region**: Pin (non-moving arena)
- **Created by**: `ffi-pin`

```lisp
(let pinned (ffi-pin my-int))
(ffi-call "c_func" pinned 1000)
(ffi-unpin pinned)
```

## 17.3 Capability Operations

| Operation | TCap | TMut | TAtomic | TBox | TPin |
|-----------|------|------|---------|------|------|
| Read field | ✅ | ✅ | ✅ | ✅ | ✅ |
| `set!` rebind | ❌ | ✅ | ❌ | ❌ | ❌ |
| Atomic ops | ❌ | ❌ | ✅ | ❌ | ❌ |
| Send to actor | ✅ | ❌ | ✅ | ❌ | ❌ |
| FFI pass | ❌ | ❌ | ❌ | ❌ | ✅ |
| Coerce to TCap | — | ✅ | ✅ | ✅ | ✅ |

## 17.4 Coercion Rules

### Implicit (Safe)

```
TMut<T> → TCap<T>           (mutable → immutable view)
TAtomic<T> → TCap<T>        (atomic → immutable view)
TBox<T> → TCap<T>           (owned → shared view)
TPin<T> → TCap<T>           (pinned → shared view)
```

### Explicit (Unsafe, Not Provided)

No implicit `TCap<T> → TMut<T>` — would violate invariant.

### Borrow-Like Patterns

```lisp
;; Function takes TCap (read-only)
(defn print-point (p TCap<Point>) ...)

;; Caller with TMut can pass
(let-mut p (make-Point 1 2))
(print-point p)   ; TMut<Point> → TCap<Point> ✅
```

## 17.5 Struct Fields and Capabilities

**Struct fields are always immutable** — capability applies to the whole struct:

```lisp
(defstruct Point (x) (y))

(let-mut p (make-Point 1 2))  ; p : TMut<Point>
(set! p (make-Point 3 4))     ; Rebinding whole struct ✅
(set! (struct-get p "x") 5)   ; Direct field mutation ❌ COMPILE ERROR
```

**Why?** Field-level capabilities would require:
- Per-field capability tracking
- Complex aliasing rules for partial mutability
- Runtime overhead for capability checks

Zyl chooses **whole-value rebinding** for simplicity.

## 17.6 Closure Capture and Capabilities

```lisp
;; Read-only capture → TCap
(defn make-adder (n)
  (fn (x) (+ x n)))   ; n : TCap<Int>

;; Mutated capture → TMut (must escape to Heap)
(defn make-counter ()
  (let-mut (count 0)
    (fn () (set! count (+ count 1)) count)))  ; count : TMut<Int> @ Heap

;; Atomic capture → TAtomic
(defn make-atomic-counter ()
  (let counter (atomic-new 0)
    (fn () (atomic-add counter 1))))  ; counter : TAtomic<Int>
```

## 17.7 Actor Communication and Capabilities

### Send-Capable Types

A type is **Send** if it can be safely transferred between actors:

| Type | Send? |
|------|-------|
| Primitives (Int, Float, Bool, String) | ✅ |
| `TCap<T>` where T: Send | ✅ |
| `TAtomic<T>` where T: Send | ✅ |
| ADTs/Structs with all Send fields | ✅ |
| `TMut<T>` | ❌ |
| `TBox<T>` | ❌ |
| `TPin<T>` | ❌ |
| Closures with TMut captures | ❌ |

```lisp
;; ✅ OK
(send actor (Some "hello"))
(send actor (atomic-new 0))

;; ❌ COMPILE ERROR: E_CAPABILITY_LEAK
(let-mut x 10)
(send actor x)
```

## 17.8 FFI and Capabilities

- **FFI args must be `TPin<T>`** — created by `ffi-pin`
- **Only FFI_Pinnable types** can be pinned:
  - Primitives: Int, Float, Bool, String
  - `Vec<T>` where T pinnable
  - Structs/ADTs with all pinnable fields
- **No `TMut` or `TBox` in FFI** — would violate memory safety

## 17.9 Capability Inference

Compiler infers capabilities automatically:

1. **Read usage** → `TCap`
2. **Write usage (`set!`)** → `TMut`
3. **Atomic usage** → `TAtomic`
4. **Escape + capture** → Promote to Heap, adjust capability
5. **Actor send** → Require Send capability
6. **FFI** → Require `TPin`

## 17.10 Capability Errors

| Error | Cause |
|-------|-------|
| `E_MUT_CONFLICT` | TMut and TCap alias same memory |
| `E_CAPABILITY_LEAK` | TMut/TBox sent to actor or stored in shared struct |
| `E_REGION_ESCAPE` | Value escapes region due to capability |
| `E_FFI_PIN_TYPE` | Non-pinnable type passed to `ffi-pin` |

## 17.11 Comparison with Rust

| Rust | Zyl |
|------|-----|
| `&T` | `TCap<T>` (inferred) |
| `&mut T` | `TMut<T>` (inferred) |
| `Box<T>` | `TBox<T>` (explicit) |
| `Pin<&mut T>` | `TPin<T>` (via `ffi-pin`) |
| `Arc<Mutex<T>>` | `TAtomic<T>` |
| Borrow checker | Region + capability inference |
| Lifetime parameters | Region variables (inferred) |

**Key difference**: Zyl infers capabilities and regions — no annotations needed in most code.