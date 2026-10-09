# Proving a value dead: the roadmap past regions

Status: **plan**. Generational arena handles (the first item of the
original list) are done; this document records the other four so the work
can be picked up without redoing the survey. Written 2026-10-09.

## Where Zyl is

Memory is reclaimed three ways today:

- **Frame and result regions** (`docs/regions-design.md`). Escape analysis
  over union-find object classes places each allocation in the call's own
  region, the caller's result region, or the process heap. Regions are
  released on return. This is Tofte–Talpin region inference specialised to
  one implicit region parameter per call.
- **Explicit arenas** (`with-region`, `StringBuffer`, the compiler's and
  the language server's own arenas). Released by `with-resource` or by
  hand; `linearity.zyl` checks release is affine (`E_MOVE_VALUE`), and the
  runtime floor is the generational handle (a stale `Arena` is detected,
  never dereferenced).
- **The process heap**, for everything the analysis sends to level H. It
  is never freed. `(memory reported)` lists these allocations
  (`W_HEAP_ESCAPE`) and `(memory bounded)` refuses them; across the
  regression and smoke programs 27 of 132 have at least one.

Two facts about the language make the stronger techniques below unusually
applicable:

1. **No in-place mutation.** A `let` binding is immutable and `set!` only
   rebinds a `let-mut` name, so a value never comes to point at a value
   created after it. Immutable data cannot form a cycle — with one
   exception, below.
2. **Release is already affine and checked** (`linearity.zyl`), and
   **in-place reuse already exists** (`reuse.zyl`), so the ownership
   facts these techniques need are partly computed.

**The exception to (1):** a closure that captures itself, or two local
functions that capture each other, is a cycle. Any reference-counting
scheme below needs either a rule that such closures live in a region (they
are known at compile time: a `defn` or `fn` whose free variables include
its own binding) or a cycle-breaking step for them. Check this first.

## Why the heap escapes, in order of frequency

From the 27 programs `(memory bounded)` rejects:

1. **A value passed to a function value** (`escapes here: passed to a
   function value that may keep it`). The analysis has no summary for an
   unknown callee, so every argument becomes H. Higher-order code — `map`
   with a lambda, `twice`, callbacks — is the common case.
2. **A value passed to a runtime entry not in `rg-ffi-kind`** (a ref cell,
   `zyl_ref_set`; the table is incomplete rather than wrong).
3. **A value joined with a caught error** (`ITryCatch`: the catch
   variable is H).
4. **A value kept by a function whose summary says so** (correct, but
   field-insensitive classes over-approximate it).

Items 1 and 4 are where better algorithms pay; 2 and 3 are table and
special-case work.

## 1. Defunctionalise known function values (do first)

**What.** Where the set of functions a function value can be is known —
a lambda passed straight to a `defn` parameter, a top-level function
named as a value — specialise the callee for that function, so the call
becomes a direct call with an ordinary summary. Zyl already specialises
per type (`type_annotate.zyl`'s specialisation of calls and function
values); this is the same mechanism keyed by function identity.

**Gets.** Most of cause 1, with the analysis Zyl already has. `(twice (fn
(ys) (Cons 1 ys)) xs)` becomes `twice_lambda17`, whose summary says the
argument reaches the result (R), not the heap.

**Costs.** Code size (one specialisation per distinct lambda at a
higher-order call), bounded by a limit after which the call falls back to
H. One reseed.

**Where.** A pass between type checking and ICNF lowering, beside the
existing specialisation; `region_inference.zyl` needs nothing new.

## 2. FP²: fully in-place functional programming

Lorenzen, Leijen, Swierstra, *FP²: Fully in-Place Functional
Programming*, ICFP 2023.

**What.** A type system that certifies a function as *fip* — it runs in
constant extra space, every allocation reusing a cell its owned input
gives up — or *fbip* (constant extra space plus a bounded stack). The
check is syntactic over owned and borrowed parameters.

**Gets.** It is what `(memory bounded)` should mean per function: not "no
heap escapes" but "this function allocates nothing beyond what it is
given". A `(memory bounded)` program could require every function on a
loop to be fip, and report the first allocation that is not a reuse.

**Costs.** Needs ownership/borrow facts per parameter (see 4) and reuse
pairing, which `reuse.zyl` partly does. No runtime change.

**Where.** A checker after `reuse.zyl`; diagnostics in the mentor voice
pointing at the allocation that is not a reuse.

## 3. Perceus: precise reference counting

Reinking, Xie, de Moura, Leijen, *Perceus: Garbage Free Reference Counting
with Reuse*, PLDI 2021 (Koka). Companion: Lorenzen and Leijen, *Reference
Counting with Frame Limited Reuse*, ICFP 2022.

**What.** Insert `dup` and `drop` so every heap value is freed at the
moment its last reference dies, with a proof that no unreachable value is
retained ("garbage free"). Reuse analysis turns a `drop` followed by an
allocation of the same size into an in-place update.

**Gets.** The strongest answer to "prove the scope has dropped": release
at last use rather than at a region's end. It removes the process heap as
a never-freed sink, and it fixes the case regions cannot — state threaded
through a long tail-recursive loop, which today accumulates in the
outermost caller's result region.

**Costs.** A count word per heap object, count traffic at every
`dup`/`drop` (borrowing, 4, removes most of it), a different code
generation for allocation, and the cycle question above. It changes the
memory model from regions-plus-heap to regions-plus-precise-release, so it
needs a spec section (§9) and its own design document before code.

**Where.** A pass over ICNF after region inference — region-placed values
keep their regions; only H values become counted — and runtime support in
`runtime/rt/alloc.zyl`.

## 4. Borrowed-parameter inference

Ullrich and de Moura, *Counting Immutable Beans: Reference Counting
Optimized for Purely Functional Programming*, IFL 2019 (Lean 4).

**What.** Infer which parameters a function only reads (borrowed) and
which it may consume (owned), by a fixpoint over the call graph — the same
shape as `region_inference.zyl`'s parameter summaries.

**Gets.** Makes 3 cheap enough (no count updates for borrowed arguments)
and supplies 2 its ownership facts.

**Costs.** Small: a summary lattice and a fixpoint, alongside the one
region inference already runs.

## 5. Reachability types (longer term)

Bao, Wei, Bračevac, Jiang, Lhoták, Rompf, *Reachability Types: Tracking
Aliasing and Separation in Higher-Order Functional Programs*, OOPSLA 2021;
Wei et al., *Polymorphic Reachability Types*, POPL 2024.

**What.** Types carry the set of values a value can reach, including
through closures, with polymorphism over those sets.

**Gets.** Cause 1 in full, including function values that defunctionalising
cannot resolve (stored callbacks, values from data structures): a
function's type says what it keeps.

**Costs.** A type-system extension threaded through inference and the
unifier — the kind of change `docs/architecture-decisions.md` A7 declined
for capabilities. Only worth it if 1 leaves a large residue.

## Suggested order

1. Defunctionalise known function values (cause 1, existing analysis).
2. Borrowed-parameter inference (small; prerequisite for 3 and FP²).
3. FP² checking under `(memory bounded)` (per-function memory proof).
4. Perceus for level-H values (the memory-model change; design document
   and spec first; settle self-capturing closures first).
5. Reachability types, if 1 leaves enough unresolved.

Measure each step the way the memory profile was measured: compile the
regression and smoke programs under `(memory bounded)` and count the
`E_REGION_ESCAPE` that remain, and keep `tests/lsp/lsp_memory_test.py`
green.
