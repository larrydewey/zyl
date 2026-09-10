# Chapter 16: Region-Based Memory Model

Complete reference for Zyl's region system: regions, inference rules, escape analysis, and reclamation.

## 16.1 Regions

| Region | Purpose | Lifetime | Allocation |
|--------|---------|----------|------------|
| **Stack** | Local variables, params | Function scope | Stack pointer bump |
| **Heap** | Escaped values, closures | Until owning scope ends | Bump allocator |
| **Global** | `def` constants | Program lifetime | Static data section |
| **Circular** | Cyclic data structures | Cycle detector | Heap sub-region |
| **Pin** | FFI-pinned memory | Manual `ffi-unpin` | Separate mmap arena |

## 16.2 Region Rules (Normative, Spec §9.1)

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

## 16.3 Escape Analysis

A value **escapes** its defining scope if:

1. **Returned** from function
2. **Captured** by a closure that escapes
3. **Sent** to actor via `send`
4. **Passed to FFI** via `ffi-pin`
5. **Stored** in global/heap data structure that escapes

### Escape Examples

```lisp
;; Stack (no escape)
(defn add (a b) (+ a b))

;; Heap (returned)
(defn make-point (x y) (make-Point x y))

;; Heap (captured by escaping closure)
(defn make-adder (n)
  (fn (x) (+ x n)))   ; n escapes → Heap

;; Heap (sent to actor)
(spawn (fn (msg) ...) (Some data))  ; data escapes → Heap

;; Pin (FFI)
(ffi-call "c_func" (ffi-pin my-int) 1000)  ; my-int → Pin
```

## 16.4 Region Inference Algorithm (Two-Pass)

### Pass 1: Bottom-Up (Collect Constraints)

- Traverse AST from leaves to root
- Each binding gets region variable `ρ`
- Generate constraints:
  - `ρ₁ ≤ ρ₂` (region subsumption: Stack ≤ Heap ≤ Circular)
  - `ρ = Pin` for `ffi-pin` args
  - `ρ = Global` for `def` bindings

### Pass 2: Top-Down (Solve + Promote)

- Solve constraint system
- Assign minimal region satisfying constraints
- Promote Stack → Heap where escape detected
- Detect cycles → assign Circular region

### Subsumption Lattice

```
Stack ≤ Heap ≤ Circular
  │
  └── Pin (incomparable, only for FFI)
  │
  └── Global (incomparable, only for constants)
```

## 16.5 Region Annotations on Types

Types carry region info (erased at runtime):

```
T @ ρ    ; Type T in region ρ
```

Examples:
- `Int @ Stack`
- `TCap<Point> @ Heap`
- `TFun([Int @ Stack], Int @ Stack) @ Stack`

## 16.6 Reclamation

| Region | Reclamation |
|--------|-------------|
| Stack | Automatic on function return (stack pointer restore) |
| Heap | Scope-based: freed when owning scope exits |
| Global | Never (program lifetime) |
| Circular | Cycle detector (periodic, deterministic) |
| Pin | Manual `ffi-unpin` or scope exit |

### Heap Reclamation Details

- Each function has a **heap scope**
- Allocations recorded in scope
- On scope exit: iterate allocations, free
- Deterministic: same allocation order → same free order

### Cycle Detection

- Runs at safe points (function returns, GC points)
- Marks reachable from roots (stack, globals)
- Unmarked heap objects in cycles → Circular region
- Circular region freed when cycle broken

## 16.7 Region Errors

| Error | Cause |
|-------|-------|
| `E_REGION_ESCAPE` | Value escapes assigned region |
| `E_PIN_MISMATCH` | Non-pinnable type passed to `ffi-pin` |
| `E_GLOBAL_MUTATION` | Attempt to mutate Global region value |
| `E_CIRCULAR_REQUIRED` | Cycle detected but not in Circular region |

## 16.8 Interaction with Capabilities

| Capability | Typical Region | Escape Behavior |
|------------|----------------|-----------------|
| `TCap<T>` | Stack/Heap | Promoted to Heap if escapes |
| `TMut<T>` | Stack/Heap | Must not escape as shared |
| `TAtomic<T>` | Heap | Actor-safe |
| `TBox<T>` | Heap | Unique ownership |
| `TPin<T>` | Pin | FFI only |

## 16.9 Determinism

Region inference is **fully deterministic**:
- Ordered constraint solving (FNV-1a hashed maps)
- No heuristics, no randomness
- Same source → identical region assignment
- Verified by boot fixed point

## 16.10 Best Practices

1. **Prefer Stack**: Let compiler infer Stack — fastest
2. **Avoid unnecessary escapes**: Return values instead of capturing
3. **Use `TBox` explicitly** for recursive heap structures
4. **Minimize Pin**: Only for FFI, unpin promptly
5. **Trust the compiler**: Region inference is complete for valid programs