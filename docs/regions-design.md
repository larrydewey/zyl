# Real Regions: Design

Status: implemented 2026-09-24 (commits 8d5c17d, 12b7f4c, a06157d,
ac3042e, and b840013 for size-class blocks). This document describes how spec §9's region system is made true
in the implementation, replacing the single never-reclaimed heap arena for
values the compiler can prove short-lived. The sections below describe what
was built; where the implementation departed from the original plan, the
text has been corrected. Later changes that touch regions: inlining now
runs before this analysis (cdda64b), in-place reuse runs after it and
relies on it (55c9355), and the native backend (`docs/native-backend-design.md`)
emits the same region frames, with inline bump allocation (0929426) and
frame-region recycling in self tail calls (93ab380).

## Starting point (before this work)

- Every heap value (variants, structs, closures, strings built at run time)
  is allocated from one process-wide arena, `g_heap_arena`, and reclaimed
  only when the process exits.
- `region_inference.zyl` performs one rewrite: a variant bound by `let` and
  only matched or printed becomes an `IStackVariant` in the frame.
- `E_REGION_ESCAPE` is catalogued but never raised.

## Model

Three levels, ordered `L < R < H`:

- **L (local):** the value does not outlive the current call. It is
  allocated in the call's own region, which is released when the call
  returns (or tail-calls, or is unwound by a panic).
- **R (result):** the value may be part of the call's result, but goes no
  further than that. It is allocated in the region the *caller* chose for
  the result. This is region polymorphism in the Tofte–Talpin sense, with
  one implicit region parameter per call.
- **H (heap):** the value escapes in a way the compiler does not track:
  stored in a global, sent to an actor, handed to foreign code, written into
  raw memory, captured by a closure called through an unknown function
  value, or passed to a runtime function not known to be region-safe. It is
  allocated in the process heap, as everything is today.

The level is a property of an **abstract object class**: a union-find class
of values that may point to each other. Classes are field-insensitive: a
variant, its fields and anything read out of it share one class. That
over-approximates (a local list of heap strings makes the strings local too
only if nothing else constrains them) and it is sound.

## Analysis (compile time, over ICNF)

A pass in `region_inference.zyl` (the `rg-*` functions, entry
`rg-regions`), run in `pipeline.zyl` after inlining and optimization and
after the stack-variant rewrite `ri-transform-fns`, over the whole
program; the in-place reuse pass (`reuse.zyl`) runs after it. The
allocation sites are `IVariant` nodes and calls to region-aware runtime
functions; every call site is classified too. Classes are kept in a
union-find structure in the runtime (`zyl_uf_*`). A node the type pass
proves to be `Int`, `Bool` or `Float` (the `icnf-scalars` side table in
`node_tables.zyl`, set by `ta-scalar`)
never joins a class, so scalars do not tie unrelated objects together.

Per function, walk the body with an environment from names to classes:

| ICNF | constraint |
|---|---|
| `ILet n v b` | `n` gets `v`'s class |
| `ISet n v` | unify `n` with `v` |
| `IIf c t e`, `IMatch` arms | unify the branch results |
| `IMatch s arms` | every binder unifies with `s` |
| `IVariant`/`IStackVariant` | fields unify with the new object; the node is an allocation site |
| `ICall f args`, `f` top level | per the callee summary: an `R` parameter unifies its argument with the call's result, an `H` parameter marks the argument `H` |
| `ICall f args`, `f` local (closure or function value) | arguments `H`; the result unifies with `f` |
| call in tail position | each argument is at least `R` (the frame is gone when the callee runs) |
| `IFfi` to a runtime function in `rg-ffi-kind` | per its table entry (fresh result / result aliases an argument / no allocation) |
| `IFfi` to any other runtime function | arguments and result `H` |
| foreign `ffi-call` | arguments `H` |
| `ITryCatch` | the catch variable is `H`; branch results unify |
| function body | unifies with the function's result class, which is at least `R` |

The **summary** of a function is the level of each parameter's class after
the analysis, encoded as 0 (does not escape the call), 1 (may reach the
result) or 2 (escapes), plus bit 62, set when the function may allocate
into its result region. Summaries start at 0 and are recomputed over all
functions, in program order, until none changes. The constraints are not
monotone in the summary (a lower summary for one parameter can raise
another), and recomputing summaries by plain replacement once made the
fixpoint cycle forever (found on `math-blake3`); each new summary is
therefore joined with the previous one, per parameter maximum. With the
join, summaries only rise in a finite lattice, so the fixpoint terminates
and is deterministic.

Each allocation site and each call site is annotated with the level of its
result class. The annotations live in the `icnf-regions` side table
(`node_tables.zyl`), keyed by the ICNF node: for a site, the level plus one (1 frame, 2 result, 3 heap, `4 + k`
the enclosing `with-region` scope `k`); for a function node, flags plus 4
(bit 0: the function has a frame region, bit 1: it keeps the result
region). `icnf_print` shows a site's annotation as ` @r`, so the ICNF hash
of a package build covers region decisions.

## Runtime

- A region is a four-word header inside the frame: `prev`, `bump`, `end`,
  `blocks`. Blocks come from per-thread pools carved from `mmap`ed
  chunks (addresses above 4 GiB, so the closure-versus-code
  address checks keep working); an allocation larger than a block gets its
  own mapping. Blocks come in four size classes, 1, 4, 16 and 64 KiB
  (commit b840013): a region's first block is the smallest and each
  further block is the next class up, so a deep recursion that keeps a
  little local data in every frame costs about 1 KiB a frame. Every block allocation is charged to the
  `ZYL_MAX_MEMORY` budget, and `zyl_region_live_bytes` reports the bytes
  currently held by live regions.
- `zyl_cur_region` (thread-local) is the region the next result goes into;
  0 means the heap. Compiled code sets it immediately before every
  annotated call site (a call whose callee may allocate into its result
  region); an unannotated call leaves it untouched. A
  compiled function that keeps its result region reads it once, at entry,
  and saves it in its frame.
- `zyl_region_top` (thread-local) chains the live frame regions. Entry
  pushes, exit pops and releases. Try frames and the test runner record
  the chain top; `zyl_panic` releases every region above it before its
  `longjmp`, so unwinding leaks nothing and `zyl_cur_region` never points
  at a dead frame.
- A region-aware allocation keeps the hidden size header `zyl_heap_alloc`
  writes, so structural equality and the interpreter's value helpers behave
  the same, and in-place reuse can check that an old block is large
  enough for the new record.
- `zyl_region_recycle` empties a frame region but keeps its first block;
  a self tail call in a function with a frame region calls it (when the
  region took a block) instead of releasing the region and re-opening
  it. Region inference already keeps every tail-call argument out of the
  frame region.
- Only runtime functions listed as region-aware allocate in a region: the
  fresh-result producers `zyl_cstr_concat`, `zyl_cstr_substr`,
  `zyl_cstr_from_byte`, `zyl_int_text`, `zyl_f_text`, `zyl_view_copy` and
  `zyl_file_read_c` have `_r` entry points (and `zyl_bytebuf_new_r` takes
  the region of a Stack bytebuf) that compiled code calls from annotated sites.
  Every other runtime allocation stays in the heap. The
  compiler's table of region-aware functions and the runtime's list must
  agree in one direction only: a function the compiler treats as
  region-aware must not retain or alias its arguments beyond what its table
  entry says. A function missing from the table is always safe.

## Codegen

- Both emitters (the native MIR path and the stack machine) use one
  layout. A flagged function has six words at the top of its frame:
  `[rbp-8]` the saved `rax`, `[rbp-16]` the result region, `[rbp-48]`
  the four-word region header (`prev`, `bump`, `end`, `blocks`). On the
  stack machine parameters start at `[rbp-56]`; on the native path the
  saved callee-saved registers follow the header. Entry pushes the header on the `zyl_region_top` chain
  inline; exit, and every tail jump, pops it inline and calls
  `zyl_region_free` only if a block was taken.
- Before each annotated call: `zyl_cur_region` (addressed `fs`-relative) := the frame
  region (`L`), the saved result region (`R`), or 0 (`H`), after the
  arguments are evaluated and immediately before the `call`.
- `IVariant` at a region site allocates through `zyl_ralloc(size, region)`
  with the region passed directly; a heap site still calls
  `zyl_heap_alloc`. On the native path a frame- or result-region
  allocation bumps the region's pointer inline, writing `zyl_ralloc`'s
  size header itself, when the current block has room and the region is
  not a `with-region` scope; otherwise it calls `zyl_ralloc`. Functions
  with a `with-region` scope stay on the stack machine.

## Explicit regions and E_REGION_ESCAPE

The same analysis checks explicit region choices:

- A `(bytebuf Stack N)` is allocated in the frame region. One whose class
  reaches `R` or `H` (returned, stored, sent, or passed to code that may
  keep it) is `E_REGION_ESCAPE`, reported at the allocation. Byte loads,
  stores, appends and atomics are classified, so using the buffer locally
  is fine.
- The region extension registry adds `with-region`:

  ```lisp
  (with-region (arena :block B :align A :limit L) body)
  (with-region (fixed :size S :align A) body)
  ```

  An `arena` grows in blocks of `B` bytes (a multiple of 4096, at most
  64 MiB) up to `L` bytes (0: no limit); a `fixed` region has exactly `S`
  bytes. `A` is a power of two from 8 to 4096 (default 8). A malformed
  spec is `E_REGION_SPEC`; running out is `E_REGION_EXHAUSTED`, which is
  catchable and deterministic (it depends only on the request sequence;
  blocks are page-aligned, so alignment padding is the same every run).
  Allocations in `body` go to the new region, which is released when
  `body` ends; a value of that region reaching `body`'s result, or
  anything longer-lived, is `E_REGION_ESCAPE`.
- `with-region` is recognised at the Expr level (`parse-with-region` in
  `expr_inner.zyl`, an `EApply "with-region"`) and lowered to the ICNF
  node `IRegion kind block align limit body`. A scope header uses the
  frame-region layout and is marked by the low bit of `blocks`, which
  keeps the frames of the committed seed valid.

## Not changed

- The interpreter ignores region annotations and `with-region` scopes; it
  allocates in its own arenas, so `with-region` byte limits are enforced
  only in compiled code (`tests/regression/with-region-limits.zyl` is
  excluded from the interpreter differential run).
- User arenas (`allocator/allocator`, `vec-create` with an arena) are
  explicit and unaffected.
- Foreign calls: arguments are `H`, so an abandoned timed-out call can
  never be left holding a released region.

## Verification

- `./boot.sh`: the compiler compiles itself with regions on and must still
  reach the byte-identical fixed point.
- The full regression suite, plus region tests: loops that allocate
  temporaries run in bounded memory (checked through a runtime counter of
  live region bytes), results built in callees survive, closures returned
  from functions keep their captures, panics inside regions unwind cleanly.
- A `ZYL_REGIONS=0` escape hatch, read at compile time (every site `H`,
  the old behaviour), for bisecting a suspected region bug.

## Results

Measured when regions landed (2026-09-24):

- The regression suite passes (200/200) and `./boot.sh` reaches the
  fixed point. New tests: `tests/regression/{region-reclaim,stack-bytebuf,
  with-region,with-region-limits}.zyl` and the compile-fail tests
  `stack-bytebuf-return`, `stack-bytebuf-escape`, `with-region-escape`,
  `with-region-spec` and `with-region-block`.
- A test program that builds and drops 20000 lists went from a 630 MB to a
  12 MB peak and runs 2.4 times faster.
- The compiler's own build time is unchanged (about 6.1 s) and its peak
  memory barely moves: its data mostly escapes into its results or into
  global tables.

## Known limitations

- Classes are field-insensitive and over-approximate: a local list of
  strings shares one level with its strings.
- The `try`/`catch` frames `zyl_try_push` allocates are still `malloc`ed
  per `try` and never freed (this predates regions).
- The interpreter does not enforce `with-region` limits.
- The Global and Circular regions remain names only. Global is the set of
  top-level `def` values, which live in the heap.
