# Appendix A: Error Codes Reference

Complete list of all Zyl error codes from the specification (v4.2, §28).

## Compile-Time Errors

| Code | Message | Phase |
|------|---------|-------|
| `E_RESERVED_KEYWORD` | Reserved keyword used as identifier | Parsing |
| `E_MATCH_NONEXHAUSTIVE` | Missing match case | Type Inference |
| `E_TYPE_MISMATCH` | Expected type τ₁, found τ₂ | Type Inference |
| `E_UNIFICATION_FAILED` | Cannot unify types (occurs-check) | Type Inference |
| `E_TRAIT_BOUND_NOT_SATISFIED` | Concrete type lacks required trait | Type Inference |
| `E_CANNOT_INFER` | Generic param unconstrained | Type Inference |
| `E_UNKNOWN_GENERIC_PARAM` | Reference to undeclared type param | Type Inference |
| `E_TRAIT_NOT_DERIVABLE` | Field lacks required trait for derive | Type Inference |
| `E_DUPLICATE_IMPL` | Two impls for same (Trait, Type) | Type Inference |
| `E_TRAIT_NOT_FOUND` | No impl for required (Trait, Type) | Type Inference |
| `E_ORPHAN_IMPL` | Impl violates orphan rule | Type Inference |
| `E_REGION_ESCAPE` | Value escapes assigned region | Region Inference |
| `E_PIN_MISMATCH` | Non-pinnable type passed to `ffi-pin` | Region Inference |
| `E_GLOBAL_MUTATION` | Attempt to mutate Global region value | Region Inference |
| `E_CIRCULAR_REQUIRED` | Cycle detected but not Circular region | Region Inference |
| `E_MUT_CONFLICT` | TMut and TCap alias same memory | Capability Check |
| `E_CAPABILITY_LEAK` | TMut/TBox sent to actor or shared | Capability Check |
| `E_FFI_PIN_TYPE` | Non-pinnable type passed to `ffi-pin` | Capability Check |
| `E_MACRO_NON_TERMINATION` | Macro expansion depth exceeded | Macro Expansion |
| `E_MACRO_ILLEGAL_ACCESS` | Macro accessed runtime value | Macro Expansion |
| `E_MACRO_PATTERN_MISMATCH` | Arguments don't match patterns | Macro Expansion |
| `E_UNINITIALIZED_USE` | Variable used before init | Type Inference |
| `E_OVERFLOW` | Integer overflow (checked) | Codegen/Runtime |
| `E_DIVISION_BY_ZERO` | Integer division by zero | Runtime |

## Runtime Errors

| Code | Message | Cause |
|------|---------|-------|
| `E_ASSERT_FAIL` | Assertion failed | `assert` or `unwrap` on `Err` |
| `E_FFI_TIMEOUT` | FFI call exceeded timeout | C function hung |
| `E_FFI_SYMBOL_NOT_FOUND` | C symbol not linked | Missing `.o` file |
| `E_FFI_ARITY_MISMATCH` | Wrong number of FFI args | FFI call signature mismatch |
| `E_TEST_FAILURE` | Test assertion failed | `assert-equal` etc. |
| `E_TEST_RUNNER_ERROR` | Test harness error | Internal test framework bug |

## Error Format

```
(code, location, message)
```

- `code`: Error code (e.g., `E_TYPE_MISMATCH`)
- `location`: Source location (file:line:col)
- `message`: Human-readable description

## Lowering-Guard Diagnostics (Phase 5+)

| Code | Cause |
|------|-------|
| `E_UNBALANCED_PARENS` | S-expression balance check failed |
| `E_TOO_MANY_PARAMS` | Function >6 params (pre-lift) |
| `E_DUPLICATE_VARIANT` | Variant name shared across deftypes |
| `E_MATCH_ARM_COMPLEX` | Arm body combines 2+ calls + constant |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Compile error |
| 2 | Runtime error (assert, FFI timeout, etc.) |
| 139 | Segfault (SIGSEGV) — compiler bug |
| 134 | Abort (SIGABRT) — internal error |

## Finding Error Definitions

- **Specification**: `zyl_specification.txt` §28
- **Implementation**: `src/error.rs` (Rust), `stdlib/compiler/*.zyl` (Zyl)
- **Tests**: `tests/regression/` — search for error codes