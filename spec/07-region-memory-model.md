# Zyl Specification — Region Memory Model

**Canonical authority:** `zyl_specification.txt` §9, §10, §13, §14
**Related:** `spec/06-capability-types.md`, `spec/09-ffi-contracts.md` (Pin region)
**Implementation:** `stdlib/compiler/region_inference.zyl`, `runtime/actor_runtime.c` (arenas, big stack)

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

---

## Implementation Notes

Not normative. The self-hosted compiler implements much less of the region
system than §9 describes; the gaps are recorded here.

### Region inference

- There is no general region inference. An earlier two-pass design that
  computed Stack/Heap/Global/Circular/Pin for every value was deleted
  because nothing read its result, and `E_REGION_ESCAPE` was never raised
  by it (or by the Rust bootstrap before it).
- What remains is `ri-transform-fns`, an ICNF-to-ICNF rewrite that runs
  after optimization, just before code generation. For
  `(let x (Variant ...) body)`, when every use of `x` in `body` is a
  `match` subject or a `print` argument, the construction becomes
  `IStackVariant` and is allocated in the current stack frame. Every other
  value is heap-allocated. This is rule R1 for one proven shape.
- Rules R2–R8 have no dedicated implementation. There is no Circular
  detection and no Global region; `E_REGION_ESCAPE` is catalogued but
  never raised. ICNF nodes carry no region annotation.
- The `Region` ADT (`RStack`, `RHeap`, `RGlobal`, `RCircular`, `RPin`) in
  `type_system.zyl` survives only as a type parameter of `ByteBuf` and
  `ByteSlice`, where unification requires equal regions. The runtime's
  `zyl_bytebuf_new` ignores the region argument.

### Memory in the runtime

- Heap values (variants and structs) come from `zyl_heap_alloc`, a bump
  allocator over a process-wide arena with a hidden word-count header.
  Generated code never resets or frees that arena, so heap values live
  until the process exits. Allocation
  failure, or exceeding the memory budget (`ZYL_MAX_MEMORY` when set,
  otherwise 80% of available memory), is `E_OUT_OF_MEMORY`.
- `ffi-pin` copies an 8-byte value into a separate pin arena
  (`zyl_pin_alloc`, which also `mlock`s it on a best-effort basis);
  `ffi-unpin` checks that its argument points into that arena.

### Stack safety (§14)

There is no tail-call optimization in code generation. The guarantee is
approximated instead: the generated `main` runs on a thread whose stack is
a `MAP_NORESERVE` reservation of 64 GB (falling back to 16, 4, then 1 GB)
with a guard page (`zyl_call_on_big_stack`). Deep recursion is therefore
bounded by that reservation rather than unbounded.

### Mutability (§10)

The aliasing checks that exist are described in
`spec/06-capability-types.md`. Direct field mutation,
`(set! (struct-get p "x") 5)`, is rejected by the parser with
`E_MUT_CONFLICT`.
