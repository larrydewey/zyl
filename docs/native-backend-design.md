# Native Backend: Design

Status: in progress (started 2026-09-25). Decided with the user after the
benchmark matrix below: Zyl gets a real optimizing native backend of its
own (no C or LLVM backend), and Vec updates in place when the compiler
proves the old value unique. Stages 1 and 2 and in-place reuse have
landed, with parts of stages 3–5; "Where it stands" below records exactly
what (as of 2026-09-25, commit f4213bc).

## Starting point

Before this work, `codegen.zyl` was a stack machine (it remains the
emitter for functions the new path does not take). Every local and parameter lives in a
frame slot, every intermediate value goes through `rax` and the machine
stack, and every function saves `rbx` and `r12`. Measured on 2026-09-25
(best of 3, seconds; C and C++ at -O2, Rust at opt-level=3, Go default):

| benchmark | Zyl | C | C++ | Rust | Go |
|---|---|---|---|---|---|
| fib(40) | 0.60 | 0.08 | 0.08 | 0.18 | 0.34 |
| loop, 200M mul/mod | 0.59 | 0.41 | 0.40 | 0.48 | 0.50 |
| list, 30 × 1M cons | 0.27 | 0.34 | 0.37 | 0.38 | 0.69 |
| binary trees | 1.97 | 2.72 | 3.85 | 6.40 | 3.52 |
| 5M int→string concat | 0.22 | 0.13 | 0.04 | 0.08 | 0.09 |
| sieve, 50M bytes | 0.73 | 0.14 | 0.14 | 0.14 | 0.15 |
| vec, 10M push + sum | 0.50 | 0.01 | 0.02 | 0.01 | 0.03 |

Allocation-heavy code is already competitive (per-call regions free in
bulk); scalar code and anything through a runtime call is not. The
benchmark sources are kept in `bench/` (see "Measuring").

## Goals

- Scalar code within 1.5× of C at -O2; every benchmark at least as fast
  as Go.
- Determinism unchanged: the same source gives the same assembly, and the
  self-hosting fixed point holds. Every choice (block order, register
  assignment, spill slots) is a function of instruction order only.
- Evaluation order unchanged: no optimization moves a side effect.
- Constant-time sequences stay constant-time: the bit-operation lowering
  (`cg-bit-mnem`) and Secret frame wiping are kept exactly.
- Same ABI as the current backend, so the two can coexist during the
  transition: SysV argument registers, the result in `rax`, the region
  frame layout (`docs/regions-design.md`), callee-saved `rbx` and
  `r12`–`r15` preserved.

## Pipeline

```
ICNF (tree)  --lower-->  MIR (per function: basic blocks, virtual registers)
  --optimize (safe only)-->  MIR
  --liveness + linear-scan allocation-->  MIR with physical registers and spill slots
  --emit-->  x86-64 text (same buffer and label counter as codegen.zyl)
```

- **MIR** is a linear, three-address IR: `mov`, integer ops, `cmp` +
  conditional branch, loads and stores (frame slot, `[reg+off]`), calls
  (user, runtime, indirect) with an explicit argument list, `ret`, and
  labels. Values are virtual registers; ICNF `ILet`/`ISet` locals become
  virtual registers too (a `set!` is a new definition of the same vreg,
  which is fine for linear scan without SSA; SSA construction comes when
  the optimizations need it).
- **Register allocation** is linear scan (Poletto–Sarkar) over live
  intervals computed from the block order. Values live across a call get
  callee-saved registers (`rbx`, `r12`–`r15`); others get caller-saved
  ones. What does not fit is spilled to a frame slot. Each function saves
  only the callee-saved registers it uses.
- **Tail calls**: a self tail call becomes a jump to the loop header
  with the arguments moved into the parameters' registers (parallel
  move); other tail calls keep the current frame-reuse scheme.
- **Inline runtime operations**: byte loads and stores, `Array` get/set,
  string length where the length is known, and the Vec operations, with
  the same checks the runtime performs.

## Where it stands

The native path lives in `codegen.zyl` (lowering `ml-expr`/`ml-tail`,
eligibility `mb-eligible`/`ml-ok`, emission `mb-emit-one`) and
`mir.zyl` (`deftype MI`, liveness, intervals, `mir-allocate`, the
parallel-move sequencer `pm-sequence`). `ZYL_MIR=0` at compile time
sends every function through the stack machine.

- **Stage 1: landed** (7161725). Integers and control, direct and
  runtime calls of up to six arguments, self tail calls as jumps to the
  loop head, other tail calls as jumps, inline byte access, linear scan
  with move and parameter hints, only the used callee-saved registers
  saved.
- **Stage 2: landed** (70922f7). Variants at the region level the
  analysis chose, stack variants, `match`, string, Float and symbol
  constants, and functions with frame and result regions (the shared
  48-byte region layout, region prologue and release, tail-call
  arguments staged across the release). About 95% of the compiler's own
  functions take the path.
- **Stage 3: partial.** String, Float and symbol *constants* and runtime
  calls on Strings are on the native path; Float arithmetic, String and
  variant comparison, and `print` are not (no `xmm` allocation yet).
- **Stage 4: partial.** Frame and result regions landed with stage 2.
  Closures and calls through a local, `with-region` scopes, `try`,
  Secret frame wiping, and more than six parameters or arguments still
  keep a function on the stack machine, so `codegen.zyl`'s expression
  code has not been removed.
- **Stage 5: partial, and not on MIR.** Inlining of small functions was
  done on ICNF instead, before region inference, so inlined allocations
  are placed like any other (`opt-inline-fns`, cdda64b), followed by
  copy propagation; constant folding stays on ICNF. Strength reduction
  landed as division and remainder by a constant without `idiv`
  (`mb-divmod-const`, `zyl_div_magic`/`zyl_div_shift`, 4577304). Not
  done: MIR-level constant propagation, general loop-invariant code
  motion, and bounds-check elimination; the nearest thing is loading a
  byte-buffer parameter's data pointer and bound once per function
  (`MByteData`, `MByteBound`, 763b67c).
- **Other native-path work that landed:** inline `Array` get/set/cap
  and inline region bump allocation, with the five allocatable
  caller-saved registers saved around the runtime fallback (0929426);
  frames realigned only when the function itself calls C, and no copy
  of a tail argument that is its own unchanged parameter (c154e7e);
  recycling a loop's frame region on a self tail call with
  `zyl_region_recycle` instead of releasing and re-opening it (93ab380).

There is no separate MIR optimization pass: the "optimize" step of the
pipeline above is, so far, the ICNF passes before lowering and the
instruction selection done during emission.

Latest measurements, from each commit's run of the matrix (seconds;
the table above is the starting point): fib 0.30, loop 0.52, list
0.19, trees about 1.27, str 0.11, sieve 0.16, vec 0.07.

## Staging

The new backend compiles a function only when every ICNF node in it is
in its supported set; any other function is compiled by `codegen.zyl`
as today. Both use one ABI, so they call each other freely. Each stage
widens the set and ends with the suite, the fixed point and the matrix.

1. Integers and control: constants, locals, integer binops, `if`,
   `while`, `let`, `set!`, sequencing, direct and runtime calls, self
   tail calls, inline byte access. (fib, loop, sieve.)
2. Variants and `match`: allocation through `zyl_ralloc`/`zyl_heap_alloc`
   at the region the analysis chose, tag dispatch, field loads. (list,
   trees.)
3. Strings and Floats (runtime calls, `xmm` registers for Float
   arithmetic), `print`.
4. Closures and indirect calls, `with-region`, frame regions, `try`
   (values live across `setjmp` are kept in memory), Secret wiping.
   After this stage `codegen.zyl`'s expression code is removed.
5. Optimizations on MIR, each safe and local to a function: inlining
   small non-recursive functions, constant folding and propagation,
   loop-invariant code motion of pure expressions, strength reduction,
   and bounds-check elimination for loop indices proven in range.

## Vec reuse

Status: landed (55c9355) as a general pass, `reuse.zyl`, covering every
variant construction rather than Vec alone (a struct with one field
changed, a list rebuilt cell by cell). It marks the construction; the
native path takes the old block when its size header covers the new
record, and the stack machine and the interpreter ignore the mark. Only
functions of up to 150 ICNF nodes get an owning clone `f~own`.
`vec-push` also grows its storage with one `memcpy` (`zyl_array_copy`,
23976f3). The design as first written:

`vec-push` returns a new Vec that shares its storage. When the compiler
proves the old Vec value has no other use (its last use is this call and
no copy of it escapes), the new value is written into the old one's
memory instead of allocating (the "functional but in place" technique of
Koka's Perceus). This needs a last-use analysis over ICNF; it is done
after stage 2, and then applied to the other persistent collections.

## Measuring

`bench/` holds each benchmark in Zyl, C, C++, Rust and Go, and
`bench/matrix.py` runs them (best of 3, peak RSS, output compared across
languages). The table above is its output on 2026-09-25.
