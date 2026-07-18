# Zyl Specification — Determinism and Hashing

**Canonical authority:** `zyl_specification.txt` §20.4, §27
**Related:** `docs/architecture-decisions.md` §A3, §D10
**Implementation:** All phases; `sha2` crate for finalization

---

## 20.4 Determinism

Bit-level reproducibility guaranteed.

## 27. Determinism Contract

### Observable Behavior Includes ONLY

- Return values
- Explicit IO
- Actor outputs
- FFI results
- Runtime errors

### NOT Observable

- Timing
- Memory layout
- Scheduling
- Register allocation

### Guarantee

Same program + same inputs → identical observable outputs and binaries.

---

## 20. Numeric Model (Determinism)

### 20.1 Integers

Int64 signed. Overflow behavior: checked (default), wrapping, saturating.

### 20.2 Floats

IEEE-754 binary64.

### 20.3 Division by Zero

- Int: `E_DIVISION_BY_ZERO`
- Float: ±Infinity/NaN

---

## Implementation Requirements

1. **Ordered data structures:** All maps use indexmap (ordered) or hashbrown with sorted keys.
2. **Deterministic iteration:** All iteration order is deterministic (sorted or insertion-order).
3. **No randomness:** No use of random number generators in compilation.
4. **No timestamp dependence:** Compilation does not embed timestamps.
5. **SHA-256 finalization:** Binary fingerprinting via sha2 crate for reproducibility verification.

---

## Determinism Across Phases

Every phase must produce deterministic output from the same input:

| Phase | Determinism Requirement |
|-------|----------------------|
| Parsing | Same tokens, same AST |
| Macro Expansion | Same expansion order (innermost-first) |
| Type Inference | Same type assignments |
| Region Inference | Same region lattice solution |
| Monomorphization | Same canonical names (alphabetical sort) |
| ICNF Generation | Same SSA IDs, same node order |
| Optimization | Same fold/DCE results |
| Code Generation | Same register assignment, same instruction order |
