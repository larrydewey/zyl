# Zyl Specification — Region Memory Model

**Canonical authority:** `zyl_specification.txt` §9, §13, §14
**Related:** `spec/07-region-memory-model.md`, `spec/06-capability-types.md`
**Implementation:** `src/region_inference.rs`

---

## Region Types

```
Stack | Heap | Global | Circular | Pin
```

## 9.1 Region Rules (Deterministic)

### R1. Local Stack Allocation
If variable does not escape → Stack.

### R2. Escape Allocation
If returned, captured by escaping closure, or sent to actor → Heap.

### R3. Actor Transfer
spawn/send requires Send-capable type.

### R4. FFI Rule
ffi-call requires Pin region AND FFI_Pinnable type.

### R5. Closure Capture Promotion
Escaping closure captures promoted to Heap.

### R6. Cyclic Structures
Cyclic references detected among heap values → Circular region.

### R7. Global Region
Immutable constants only. Eager initialization. No mutation allowed.

### R8. Pin Region
Non-moving arena. Values physically copied here for FFI. Never compacted.

## Region Assignment Algorithm

Two-pass algorithm with region lattice:

1. **Pass 1:** Collect region constraints from expression structure
2. **Pass 2:** Solve constraints via region lattice (least fixed point)

Region lattice ordering: `Stack < Heap < Circular`, `Pin` is orthogonal.

---

## 13. Memory Operations

| Operation | Description |
|-----------|-------------|
| 13.1 Stack | Automatic scope-based allocation. |
| 13.2 Heap | Used for escaped values and captured closure variables. |
| 13.3 Circular | Used for detected cyclic structures. |
| 13.4 Pin | Used exclusively for FFI-safe memory exposure (non-moving arena). |
| 13.5 Global | Immutable constants only. |

---

## 14. Stack Safety Guarantee

The compiler guarantees that deep recursion never causes stack overflow
(via tail-call optimization or heap-allocated stack frames).

---

## 10. Mutability and Aliasing (Region Context)

### Invariant

For any memory location:
- Either exactly one `TMut` reference
- OR any number of `TCap` references

Violation: `E_MUT_CONFLICT` (compile-time error)

### Struct Mutability

Fields defined in `defstruct` are immutable by default.
To "mutate" a struct, the binding must be `let-mut`, and the entire struct
must be rebound to a new instance: `(set! p (make-Point new-x old-y))`.
Direct field mutation (`set! (struct-get p x) 5`) is FORBIDDEN.

### Alias Transparency

Aliases are zero-cost. No runtime unwrap needed unless explicitly called.
