# Zyl Specification — Optimization Rules

**Canonical authority:** `zyl_specification.txt` §22 (step 7, "Optimization (Safe only)"), §26 (Implementation Contract)
**Related:** `docs/design-rationale.md` §D9, `spec/11-icnf-ir.md`
**Implementation:** `stdlib/compiler/optimization.zyl`

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

One bottom-up walk over each function's ICNF tree (`opt-expr`). Children
are optimized first, so nested constant arithmetic collapses in a single
pass; there is no fixed-point iteration.

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

### Other rewriting passes

These run on the program before ICNF lowering (see the pipeline in
`spec/00-language-overview.md`):

- **`closure_inline.zyl`:** for `(let f (fn params body) rest)` where `f`
  is only ever called directly (it does not escape and is not recursive),
  each call is beta-reduced in place. This is inlining, permitted by §26.
- **`assert_lowering.zyl`:** rewrites `assert-equal` on ADT or struct
  values to a comparison through the runtime's `zyl_variant_eq`.
- **Region inference** (`ri-transform-fns`) runs after optimization; see
  `spec/07-region-memory-model.md`.

### Relation to §26

Several MUST items are not met by the current compiler; each is described
in the file for its area: region rules and escape violations
(`spec/07`), FFI Pin-only safety (`spec/09`), macro hygiene (`spec/03`),
trait coherence and derive (`spec/05`), `with-resource` cleanup
(`spec/04`) and alias transparency (`spec/10`). Match exhaustiveness and
struct immutability are enforced.
