# Zyl Specification — Region Memory Model

**Canonical authority:** `zyl_specification.txt` §9, §10, §13, §14
**Related:** `spec/06-capability-types.md`, `spec/09-ffi-contracts.md` (Pin region)
**Implementation:** `stdlib/compiler/region_inference.zyl`, `runtime/rt/alloc.zyl` (arenas, regions), `runtime/rt/actor.zyl` (big stack)

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
spawn and chan-send require a Send-capable type.

### R4. FFI Rule
ffi-call requires Pin region AND FFI_Pinnable type, and a timeout,
at the call or as its extern's `:timeout` default (§16).

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

## 9.3 Memory Profile

Once per program — a top-level form of a lone file, or a line of `zyl.pkg`:

```lisp
(memory unbounded)   ; the default
(memory reported)
(memory bounded)
```

A value the region analysis cannot place in a frame, result or `with-region`
region goes to the process heap and lives until exit; in a loop that is
unbounded growth. `unbounded` allows it silently; `reported` warns
(`W_HEAP_ESCAPE`) at each such allocation in the program's own source,
labelled with where it escaped; `bounded` refuses it (`E_REGION_ESCAPE`). A
top-level `def`'s value is global (R7) and is not an escape; allocations
inside the standard library are not reported. A module file may not state a
profile, and a manifested package states it only in `zyl.pkg`
(`E_MALFORMED_FORM`).

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
- Either exactly one assigning owner (a `let-mut` binding)
- OR any number of immutable readers (a `let` binding)

Zyl has no in-place field mutation, so a location cannot be shared between
an owner and a reader in the first place.

Violations: `E_MUT_CONFLICT`, `E_MOVE_VALUE`, `E_CAPABILITY_LEAK`
(compile-time). The compiler's own messages still use the older `TCap`/`TMut`
wording, because those strings are part of the tool's output history; the
rule they enforce is the binding form above.

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

- Region inference runs after optimization, so the code that inlining
  (`opt-inline-fns`, `optimization.zyl`) copied into a caller is placed
  like any other code of that caller.
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
  `Float` (the `icnf-scalars` side table, set from `ta-scalar`) never
  joins a class.
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
- Annotations live in the side table `icnf-regions` (`node_tables.zyl`;
  sites: 1 frame, 2 result, 3 heap,
  `4 + k` the enclosing `with-region` scope `k`; function nodes: bit 0 has
  a frame region, bit 1 keeps the result region, stored plus 4). The ICNF
  printer shows them as ` @r`, so the ICNF hash of a package build covers
  region decisions.
- `E_REGION_ESCAPE` is raised, with a location, for a `(bytebuf Stack N)`
  that escapes and for a value that outlives its `with-region`.
- `ZYL_REGIONS=0` at compile time turns the pass off: every site is H.
- A self tail call in a function with a frame region empties the region
  and keeps its first block (`zyl_region_recycle`) instead of releasing
  and re-opening it; the analysis already keeps every tail-call argument
  out of the frame region.
- In-place reuse (`reuse.zyl`, `ru-reuse`) runs after region inference.
  A variant construction may take the block of a value that is provably
  unique and dead, only when the new record holds a pointer read out of
  the old one, so the two are one class and one region; the native
  backend takes the block when its size header is large enough. The
  decision is the `icnf-reuse` side table, which the ICNF printer does
  not show. `ZYL_REUSE=0` turns it off.
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
  class up) carved from per-thread 1 MiB `mmap`ed chunks; a larger
  request gets its own mapping. Region allocations
  (`zyl_ralloc`) keep the hidden size header, so structural equality works
  the same, and `zyl_region_live_bytes` reports the bytes held by live
  regions.
- Releasing a region returns its blocks to the pool. It does **not**
  wipe them: there is no wipe-on-release. With `ZYL_REGION_POISON=1` a
  released *pooled* block is instead filled with `0xDE`, purely so that a
  stale read produces recognizable garbage instead of the next
  allocation's leftovers — a detector, not a security measure, and off by
  default. Page protection (`mprotect`) was tried and withdrawn;
  `docs/memory-poisoning-design.md` is the write-up.
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

### What a program may allocate

A program cannot create an arena or take a raw allocation: `alloc-malloc`,
`alloc-free`, the `arena-*` wrappers and `buf-new` all reach a raw runtime
entry and are `E_FFI_RESTRICTED` outside the standard library
(`ffi_sigs.zyl`, `arity_check.zyl`). `str-intern` is not restricted
itself, but its first parameter is an `Arena` and no program can produce a
value of that type, so it is unreachable in practice.

What a program does instead is allocate in a region it names:
`(bytebuf R N)` for the buffer, `bytebuf-ptr` for its address. `Ptr` in a
signature is a spelling for `Int` — there is no pointer type — and what is
enforced is where an address may come from: `bytebuf-ptr`, `ffi-pin`, or a
foreign call. The collections (`vec-new`, `intmap-*`, `set-create`,
`slice-*`) and the `math/*` entry points take no arena and place their
results through region inference.

### Stack safety (§14)

A call in tail position is compiled as a jump where its stack arguments
allow it (`PROGRESS.md` lists the exceptions). Beyond that, the guarantee is
approximated: the generated `main` runs on a thread whose stack is
a `MAP_NORESERVE` reservation of 64 GB (falling back to 16, 4, then 1 GB)
with a guard page (`zyl_call_on_big_stack`). Deep recursion is therefore
bounded by that reservation rather than unbounded.

### Mutability (§10)

The aliasing checks that exist are described in
`spec/06-capability-types.md`. Zyl has no in-place mutation: every `let`
binding is immutable, `set!` on a `let-mut` binding rebinds it, and
`set!` on anything else is `E_MUT_CONFLICT`. Direct field mutation,
`(set! (struct-get p "x") 5)`, is rejected by the parser with
`E_MUT_CONFLICT`.
