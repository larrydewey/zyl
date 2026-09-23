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

## Package System Errors (§31)

Specified in v5.0, unimplemented. Phase 19 (`package`) is new and must be
added to the phase legend in `stdlib/compiler/error_codes.zyl`.

| Error Code | Phase | Condition |
|------------|-------|-----------|
| `E_MANIFEST_INVALID` | 19 | `zyl.pkg` malformed or missing a required field |
| `E_MANIFEST_NOT_FOUND` | 19 | No `zyl.pkg` in the package root |
| `E_PKG_BAD_NAME` | 19 | Name is not a valid scoped path |
| `E_PKG_BAD_VERSION` | 19 | Version is not strict SemVer |
| `E_PKG_BAD_REQUIREMENT` | 19 | Range operator in a requirement; MVS takes minimums |
| `E_PKG_DUPLICATE_DEP` | 19 | Two `dep` entries for one name |
| `E_PKG_NOT_FOUND` | 19 | Name not present in the index |
| `E_PKG_VERSION_NOT_FOUND` | 19 | Version not present in the index |
| `E_PKG_NOT_IN_STORE` | 19 | Build needs a package the store lacks |
| `E_PKG_HASH_MISMATCH` | 19 | Archive hash differs from the lock |
| `E_PKG_SIGNATURE_INVALID` | 19 | Ed25519 signature does not verify |
| `E_PKG_KEY_CHANGED` | 19 | Publisher key differs from the pinned key |
| `E_PKG_UNSIGNED` | 19 | Index entry carries no signature |
| `E_PKG_YANKED` | 19 | New resolution selected a yanked version |
| `E_PKG_LOCK_STALE` | 19 | `--locked`, but manifests imply a different graph |
| `E_PKG_LOCK_INVALID` | 19 | Lock malformed or of an unknown version |
| `E_PKG_COMPILER_TOO_OLD` | 19 | Package requires a newer compiler |
| `E_PKG_UNKNOWN_EDITION` | 19 | Edition not known to this compiler |
| `E_PKG_FETCH_FAILED` | 19 | `git`/`curl` exited non-zero |
| `E_PKG_ARCHIVE_INVALID` | 19 | Archive violates the canonical format |
| `E_PKG_NATIVE_PATH_ESCAPE` | 19 | Native source path escapes the package root |
| `E_PKG_NATIVE_FLAG_DENIED` | 19 | cflag outside the allowlist |
| `E_PKG_NATIVE_BUILD_FAILED` | 19 | `cc` failed on a native source |
| `E_PKG_FEATURE_UNKNOWN` | 19 | Requested feature not declared |
| `E_PKG_FEATURE_COLLISION` | 19 | Gated definition collides with a base definition |
| `E_PKG_CYCLE` | 9 | Dependency graph is not a DAG |
| `E_MODULE_CYCLE` | 9 | Module graph within a package is not a DAG |
| `E_PKG_VERSION_CONFLICT` | 9 | Requirement unsatisfiable within a major |
| `E_PKG_PRIVATE_SYMBOL` | 9 | Imported symbol is not `pub` |
| `E_PKG_UNKNOWN_SYMBOL` | 9 | Imported symbol does not exist |
| `E_PKG_UNKNOWN_MODULE` | 9 | Module path does not exist in that package |
| `E_PKG_UNDECLARED_DEP` | 9 | `use` names a package absent from the manifest |
| `E_PKG_RESERVED_MODULE` | 9 | Module named `unsafe` |
| `E_PKG_ORPHAN_IMPL` | 12 | Impl where neither trait nor type is local |
| `E_PKG_CAPABILITY_VIOLATION` | 13 | Construct used without the declared capability |
| `E_PKG_CAPABILITY_GROWTH` | 13 | Capability closure grew under `--locked` |

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
