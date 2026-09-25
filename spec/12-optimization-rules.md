# Zyl Specification — Optimization Rules

**Canonical authority:** `zyl_specification.txt` §22 (step 7, "Optimization (Safe only)"), §26 (Implementation Contract)
**Related:** `docs/design-rationale.md` §D9, `spec/11-icnf-ir.md`
**Implementation:** `stdlib/compiler/optimization.zyl` (inlining, copy propagation, folding), `stdlib/compiler/reuse.zyl` (in-place reuse)

---

## Optimization Policy

**Rule:** Only safe optimizations. No reordering, no spec-breaking transforms.

## 26. Implementation Contract

### Compiler MUST

- preserve evaluation order (strict left-to-right)
- enforce aliasing invariants (TMut vs TCap)
- enforce region rules (no escape violations)
- enforce FFI safety (Pin region only)
- enforce deterministic ICNF and monomorphization
- enforce macro hygiene
- enforce trait coherence (one impl per Trait-Type)
- enforce match exhaustiveness (Compile Error if missing)
- enforce defstruct immutability (no in-place mutation)
- enforce alias transparency (zero-cost)
- generate correct derive impls or raise `E_TRAIT_NOT_DERIVABLE`
- ensure with-resource closes before error propagation

### Compiler MAY

- Optimize code (within semantics)
- Inline functions
- Remove dead code
- Refine escape analysis

### Compiler MUST NOT

- Reorder side effects
- Violate determinism
- Bypass region system
- Relax trait coherence
- Mutate struct fields without rebinding

---

## Implementation Constraints

These follow from §26 and §27; they are not separately stated in the
canonical text.

1. **Evaluation order preservation:** No optimization may change the left-to-right evaluation order of side effects.
2. **Determinism:** Optimized output must be bit-for-bit reproducible for the same input.
3. **Region preservation:** Region annotations must not be lost during optimization.
4. **Type preservation:** Optimized IR must be well-typed.

---

## Optimization Phase Position

Phase 7 in the compilation pipeline (§22), between ICNF generation and
code generation.

---

## Implementation Notes

Not normative.

### `optimization.zyl`

The pipeline applies `opt-inline-fns` and then `opt-optimize-fns` to the
lowered ICNF, before region inference.

**Inlining** (`opt-inline-fns`). A call of a small function is replaced
by its body. The arguments are bound first, in call order, by nested
`let`s, and every binder in the copied body is renamed, so nothing can
capture or be captured. A candidate has at most `ZYL_INLINE_LIMIT` ICNF
nodes (default 6), does not call itself, takes only Int-kind parameters,
and contains no `try`, region scope, lambda, closure call or `print`; a
leaf (a body that calls only runtime functions) of up to three times
that limit is inlined only into a self-recursive function (a loop). A call is left alone inside a `try` body, when its
name is a local at the site, or when the body names a function or global
that a local at the site would shadow. Two rounds flatten a wrapper of a
wrapper. Copy propagation then replaces `(let n x body)`, where `x` is a
local read, by `body` with `n` renamed to `x` when neither is `set!` in
`body` and `body` binds no `x`; reading a local has no effect, so no side
effect moves. `ZYL_INLINE=0` turns both off.

**Folding** (`opt-optimize-fns`) is one bottom-up walk over each
function's ICNF tree (`opt-expr`). Children are optimized first, so
nested constant arithmetic collapses in a single pass; there is no
fixed-point iteration.

1. **Constant folding.** An `IBinop` whose operands are both `IConst`
   folds, for opcodes 0–10 (arithmetic and comparison) only. Floats are
   not folded (a float literal is carried as text). Division or remainder
   by a constant zero is left in place so that it still fails at run time.
   Bitwise opcodes (11–16) are not folded; the `op > 10` guard in
   `opt-fold-binop` is load-bearing, because the folding chain's final
   case is `!=`.
2. **Dead-branch elimination.** An `IIf` with a constant condition keeps
   only the taken branch; an `IWhile` whose condition is the constant 0
   becomes `(IConst 0)`.

There is no dead-code elimination of unused bindings or functions.

### `reuse.zyl`

`ru-reuse` runs after region inference. When a variant construction's
old value is provably unique (bound to a fresh value, never stored,
aliased, `set!`, captured or passed where its region summary lets it
escape) and dead (no later use in evaluation order, and not inside a loop
it was bound outside of), and the new record holds a pointer read out of
the old one (so both are one region class), the construction is marked
to reuse the old block (`icnf-reuse`). A function whose parameters could
be reused gets an owning clone `f~own`, called where those arguments are
owned and dead; ownership and freshness are a whole-program fixpoint in
program order. The native backend takes the block at run time only when
its size header covers the new record; every other consumer ignores the
mark, so the program's meaning is unchanged. `ZYL_REUSE=0` turns it off.

### Other rewriting passes

These run on the program before ICNF lowering (see the pipeline in
`spec/00-language-overview.md`):

- **`closure_inline.zyl`:** retired; it is now an identity pass
  (beta-reducing a lambda into its callers was not hygienic, and closures
  are real values).
- **Type annotation** (`type_annotate.zyl`) renames calls rather than
  rewriting code: a trait call to its impl, a call or value use of a
  trait-generic function to its per-type instance, and `==`/`=`/`!=` or
  `assert-equal` on an ADT to the type's generated structural equality
  function. `assert-equal` unifies its two sides, and the inferred type
  alone picks the Float epsilon comparison; the old syntactic
  `assert_lowering.zyl` rewrite is deleted.
- **Region inference** (`ri-transform-fns`, `rg-regions`) runs after
  optimization and before reuse; see `spec/07-region-memory-model.md`.

### Relation to §26

Evaluation order, determinism of ICNF and of instance naming, macro
hygiene (`spec/03`), trait coherence (`E_DUPLICATE_IMPL` and the
package orphan rule) and derive (`E_TRAIT_NOT_DERIVABLE`, `spec/05`),
match exhaustiveness and struct immutability are enforced. Some MUST
items are met only in part or not at all; each is described in the file
for its area: aliasing (`TMut`/`TCap` are syntactic checks, `spec/06`),
region rules (escape analysis places every value where it cannot
escape, and `E_REGION_ESCAPE` covers Stack bytebufs and `with-region`
values, but there is no Circular or distinct Global region, `spec/07`),
FFI Pin-only safety (only a `Secret` argument must be pinned,
`spec/09`), `with-resource` cleanup (`spec/04`) and alias transparency
(`spec/10`).
