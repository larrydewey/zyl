# Zyl Specification — Optimization Rules

**Canonical authority:** `zyl_specification.txt` §26 (Implementation Contract — compiler MUST MAY)
**Related:** `docs/architecture-decisions.md` §D9
**Implementation:** `src/optimization.rs`

---

## Optimization Policy

**Rule:** Only safe optimizations. No reordering, no spec-breaking transforms.

### Safe Optimizations

1. **Constant Folding (CF):** Fold BinOp/UnOp with compile-time constants.
   - Fixed-point iteration: run until no more folds possible.
   
2. **Dead Code Elimination (DCE):** Remove nodes not reachable from function returns.
   - BFS-based transitive dependency collection.
   - Control flow structures (If, While, For) are preserved.
   - Struct nodes are preserved.

### Compiler MUST NOT

From `zyl_specification.txt` §26:

- Reorder side effects
- Violate determinism
- Bypass region system
- Relax trait coherence
- Mutate struct fields without rebinding

### Compiler MAY

- Optimize code (within semantics)
- Inline functions (if it does not alter semantics)
- Remove dead code
- Refine escape analysis

---

## Implementation Constraints

1. **Evaluation order preservation:** No optimization may change the left-to-right evaluation order of side effects.
2. **Determinism:** Optimized output must be bit-for-bit reproducible for the same input.
3. **Region preservation:** Region annotations must not be lost during optimization.
4. **Type preservation:** Optimized IR must be well-typed.

---

## Optimization Phase Position

Phase 7 in the compilation pipeline, between ICNF generation and code generation.

**Input:** ICNFProgram from Phase 6
**Output:** Optimized ICNFProgram → Phase 8 (Code Generation)
