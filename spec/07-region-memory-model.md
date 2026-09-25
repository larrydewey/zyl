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

## 9.2 Explicit Regions (`with-region`)

```
(with-region (arena :block B :align A :limit L) body)
(with-region (fixed :size S :align A) body)
```

- `arena` grows in blocks of `B` bytes (a multiple of 4096, at most
  64 MiB), up to `L` bytes in total (0: no limit). `fixed` holds exactly
  `S` bytes. `A` is a power of two from 8 to 4096, default 8.
- Allocations in `body` go to the region, which is released when `body`
  ends. Exhaustion depends only on the request sequence.
- Malformed spec → `E_REGION_SPEC`. Exhausted → `E_REGION_EXHAUSTED`
  (catchable). A value of the region reaching `body`'s result or a
  longer-lived location → `E_REGION_ESCAPE`. A `(bytebuf Stack N)` that is
  returned, stored, sent or passed where it may be retained →
  `E_REGION_ESCAPE`.

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

Not normative. The design and its rationale are in
`docs/regions-design.md`; this section summarises what is implemented.

### Region inference

- `ri-transform-fns`, an ICNF-to-ICNF rewrite run after optimization,
  turns `(let x (Variant ...) body)` into `IStackVariant` (allocated in the
  frame) when every use of `x` is a `match` subject or a `print` argument.
- The main pass, `rg-regions` (the `rg-*` functions), runs next, over the
  whole program. It classifies every allocation site (`IVariant`, calls to
  region-aware runtime functions) and every call site as one of three
  levels, `L < R < H`:
  - **L** — the frame's own region, released when the call returns,
    before a tail jump, or when a caught panic or failed test unwinds it
    (rule R1, generalised from the stack to a per-call region);
  - **R** — the region the caller chose for the result: region
    polymorphism with one implicit region parameter, passed in the
    thread-local `zyl_cur_region`;
  - **H** — the process heap (rule R2).
- Levels belong to union-find object classes (runtime `zyl_uf_*`), which
  are field-insensitive. A node the type pass proves `Int`, `Bool` or
  `Float` (attribute table 5, `ta-scalar`) never joins a class.
- Each function has a parameter summary (0 does not escape, 1 may reach
  the result, 2 escapes; bit 62: may allocate into its result region).
  Summaries are joined (per-parameter maximum) to a fixpoint over the
  program; the join is needed because the constraints are not monotone in
  the summary.
- Tail-call arguments are at least R. Calls through a function value pass
  their arguments as H and join the result with the closure's class
  (rule R5). Runtime functions are trusted only from the explicit table
  `rg-ffi-kind`; any other runtime function keeps its arguments and result
  in the heap. Arguments of a foreign `ffi-call` are H.
- Annotations live in attribute table 4 (sites: 1 frame, 2 result, 3 heap,
  `4 + k` the enclosing `with-region` scope `k`; function nodes: bit 0 has
  a frame region, bit 1 keeps the result region, stored plus 4). The ICNF
  printer shows them as ` @r`, so the ICNF hash of a package build covers
  region decisions.
- `E_REGION_ESCAPE` is raised, with a location, for a `(bytebuf Stack N)`
  that escapes and for a value that outlives its `with-region`.
- `ZYL_REGIONS=0` at compile time turns the pass off: every site is H.
- Not implemented: Circular detection (R6) and a distinct Global region
  (R7); top-level `def` values live in the heap. Classes over-approximate:
  a local list of strings shares one level with its strings.
- The `Region` ADT (`RStack`, `RHeap`, `RGlobal`, `RCircular`, `RPin`) in
  `type_system.zyl` is recorded on the `(bytebuf R N)` node itself, a
  construction-time constant that lowering and region inference read; it
  is not part of the type. To the type checker `ByteBuf` and `ByteSlice`
  are plain nullary types. Each byte operation requires the handle its
  runtime entry accepts (a load or store either, `bytebuf-len` a ByteBuf,
  `byteslice-sub` a ByteSlice; `spec/05-types-and-inference.md` §4.9). A Stack
  bytebuf is allocated in the frame region.

### Memory in the runtime

- A region is a four-word header (`prev`, `bump`, `end`, `blocks`) in the
  frame, chained through the thread-local `zyl_region_top`. Its blocks
  come from per-thread pools of size-class blocks (1, 4, 16 and 64 KiB; a
  region's first block is the smallest and each further block the next
  class up) carved from `mmap`ed chunks above 4 GiB; a larger request gets its own mapping. Region allocations
  (`zyl_ralloc`) keep the hidden size header, so structural equality works
  the same, and `zyl_region_live_bytes` reports the bytes held by live
  regions.
- Try frames and the test runner record the chain top; `zyl_panic`
  releases every region above it before its `longjmp`.
- Heap values (H sites) still come from `zyl_heap_alloc`, a bump allocator
  over a process-wide arena with a hidden word-count header, which is
  never reset or freed: a value that escapes to the heap lives until the
  process exits.
- Region blocks and heap allocations are both charged to the memory
  budget (`ZYL_MAX_MEMORY` when set, otherwise 80% of available memory);
  exceeding it, or an allocation failure, is `E_OUT_OF_MEMORY`.
- `with-region` scopes use the same header layout, marked by the low bit
  of `blocks`. Their blocks are page-aligned, so exhaustion
  (`E_REGION_EXHAUSTED`) is the same on every run. The REPL interpreter
  ignores regions and does not enforce `with-region` limits.
- `ffi-pin` copies an 8-byte value into a separate pin arena
  (`zyl_pin_alloc`, which also `mlock`s it on a best-effort basis);
  `ffi-unpin` checks that its argument points into that arena.

### Stack safety (§14)

A call in tail position is compiled as a jump where its stack arguments
allow it (`docs/implementation-status.md`). Beyond that, the guarantee is
approximated: the generated `main` runs on a thread whose stack is
a `MAP_NORESERVE` reservation of 64 GB (falling back to 16, 4, then 1 GB)
with a guard page (`zyl_call_on_big_stack`). Deep recursion is therefore
bounded by that reservation rather than unbounded.

### Mutability (§10)

The aliasing checks that exist are described in
`spec/06-capability-types.md`. Direct field mutation,
`(set! (struct-get p "x") 5)`, is rejected by the parser with
`E_MUT_CONFLICT`.
