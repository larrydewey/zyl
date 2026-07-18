# Zyl Specification — Error Model

**Canonical authority:** `zyl_specification.txt` §28
**Related:** `spec/00-language-overview.md` (Formal Guarantees)
**Implementation:** `src/error.rs`

---

## Error Format

```
(code, location, message)
```

Location includes file, line, and column.

---

## Compile-Time Errors

| Error Code | Condition | Specification Reference |
|------------|-----------|----------------------|
| `E_RESERVED_KEYWORD` | Reserved keyword used as identifier | §1.3.1 |
| `E_MATCH_NONEXHAUSTIVE` | Missing match case | §8.3 |
| `E_MUT_CONFLICT` | Aliasing violation (TMut/TCap) | §10 |
| `E_TRAIT_NOT_FOUND` | Missing impl for trait bound | §5.4 |
| `E_DUPLICATE_IMPL` | Conflicting impls | §5.3 |
| `E_TRAIT_NOT_DERIVABLE` | Cannot derive trait | §5.6 |
| `E_MACRO_NON_TERMINATION` | Macro expansion loop | §19 |
| `E_MACRO_ILLEGAL_ACCESS` | Macro accessed runtime value | §19.4 |

Compile-time errors abort compilation.

---

## Runtime Errors

| Error Code | Condition | Specification Reference |
|------------|-----------|----------------------|
| `E_USER_ERROR` | `(error msg)` | §12.10 |
| `E_ASSERT_FAIL` | Assertion condition is false | §12.4 |
| `E_FFI_TIMEOUT` | FFI call exceeded timeout | §16 |
| `E_REGION_ESCAPE` | Region rule violation | §9 |
| `E_UNINITIALIZED_USE` | Variable used before initialization | — |
| `E_CAPABILITY_LEAK` | TMut leaked (never dropped) | §10 |
| `E_CONTRACT_VIOLATION` | Contract condition failed | §23 |
| `E_OVERFLOW` | Integer overflow | §20.1 |
| `E_DIVISION_BY_ZERO` | Division by zero (Int) | §20.3 |
| `E_TEST_FAILURE` | Test assertion failed | §20.5 |
| `E_TEST_RUNNER_ERROR` | Test harness error | §20.5 |

Runtime errors abort execution or revert state (if checkpoint active).

---

## Behavior

### Compile-Time Errors

Abort compilation immediately. Report error code, location, and message.

### Runtime Errors

Abort execution or revert state if checkpoint is active.

---

## Error Model Implementation

The error model is defined in `src/error.rs` with the following structure:

```rust
enum ZylError {
    // Compile-time
    ReservedKeyword { location: Location, keyword: String },
    MatchNonexhaustive { location: Location, missing: Vec<String> },
    MutConflict { location: Location },
    TraitNotFound { location: Location, trait_name: String },
    DuplicateImpl { location: Location, trait_name: String, type_name: String },
    TraitNotDerivable { location: Location, type_name: String, trait_name: String },
    MacroNonTermination { location: Location },
    MacroIllegalAccess { location: Location },
    
    // Runtime
    UserError { location: Location, message: String },
    AssertFail { location: Location, message: String },
    FfiTimeout { location: Location, timeout: u64 },
    RegionEscape { location: Location, expected: Region, actual: Region },
    UninitializedUse { location: Location, variable: String },
    CapabilityLeak { location: Location, variable: String },
    ContractViolation { location: Location, contract_type: String },
    Overflow { location: Location, operation: String },
    DivisionByZero { location: Location },
    TestFailure { location: Location, message: String },
    TestRunnerError { location: Location, message: String },
}
```
