# Real Regions: Design

Status: in progress (2026-09-24). This document is the plan for making spec
§9's region system true in the implementation, replacing the single
never-reclaimed heap arena for values the compiler can prove short-lived.

## Starting point

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

A new pass in `region_inference.zyl`, run after optimization (where the
existing stack-variant rewrite runs), over the whole program.

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
| `IFfi` to a region-aware runtime function | per its table entry (fresh result / result aliases an argument / no allocation) |
| `IFfi` to anything else | arguments and result `H` |
| `ITryCatch` | the catch variable is `H`; branch results unify |
| function body | unifies with the function's result class, which is at least `R` |

The **summary** of a function is the level of each parameter's class after
the analysis: `L` (does not escape the call), `R` (may reach the result),
`H` (escapes). Summaries start at `L` and are recomputed over all functions,
in program order, until none changes; the lattice is finite and every
constraint only raises levels, so this terminates and is deterministic.

Each allocation site and each call site is annotated with the level of its
result class. The annotation is stored in a codegen side table keyed by the
ICNF node (as codegen kinds are), and `icnf_print` shows it, so the ICNF
hash covers region decisions.

## Runtime

- A region is a four-word header inside the frame: `prev`, `bump`, `end`,
  `blocks`. Blocks come from a per-thread pool of fixed-size blocks carved
  from `mmap`ed chunks (addresses above 4 GiB, so the closure-versus-code
  address checks keep working); an allocation larger than a block gets its
  own mapping. Every block allocation is charged to the `ZYL_MAX_MEMORY`
  budget.
- `zyl_cur_region` (thread-local) is the region the next result goes into;
  0 means the heap. Compiled code sets it immediately before every call to a
  compiled function and every region-aware runtime function. A compiled
  function that has `R` sites reads it once, at entry.
- `zyl_region_top` (thread-local) chains the live frame regions. Entry
  pushes, exit pops and releases. A panic caught by `try`, or a failing
  test, releases every region above the frame it unwinds to, so unwinding
  leaks nothing and `zyl_cur_region` never points at a dead frame.
- A region-aware allocation keeps the hidden size header `zyl_heap_alloc`
  writes, so structural equality and the interpreter's value helpers behave
  the same.
- Only runtime functions listed as region-aware allocate in
  `zyl_cur_region`; every other runtime allocation stays in the heap. The
  compiler's table of region-aware functions and the runtime's list must
  agree in one direction only: a function the compiler treats as
  region-aware must not retain or alias its arguments beyond what its table
  entry says. A function missing from the table is always safe.

## Codegen

- A function with an `L` site reserves the header, pushes it at entry, and
  pops and releases it at exit and before every tail jump.
- Before each call: `zyl_cur_region` := the frame region (`L`), the saved
  result region (`R`), or 0 (`H`), after the arguments are evaluated and
  immediately before the `call`.
- `IVariant` allocates through `zyl_ralloc(size, region)` with the region
  passed directly.

## Explicit regions and E_REGION_ESCAPE

The same analysis checks explicit region choices:

- A `(bytebuf Stack N)` whose class reaches `R` or `H` is
  `E_REGION_ESCAPE` (it lives in the frame).
- The region extension registry adds `(with-region KIND body)`: allocations
  in `body` go to a region of a closed, audited kind (fixed block size,
  alignment and limit, deterministic for a given request sequence); a value
  of that region reaching `body`'s result, or anything longer-lived, is
  `E_REGION_ESCAPE`.

## Not changed

- The interpreter ignores region annotations; it allocates as before.
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
- A `ZYL_REGIONS=0` escape hatch (all sites `H`) for bisecting a suspected
  region bug.
