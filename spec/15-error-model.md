# Zyl Specification — Error Model

**Canonical authority:** `zyl_specification.txt` §28
**Related:** `spec/00-language-overview.md` (Formal Guarantees)
**Implementation:** `stdlib/compiler/error_codes.zyl` (catalog), `stdlib/compiler/error_report.zyl` (rendering), `runtime/actor_runtime.c` (`zyl_panic`)

---

## Error Format

```
(code, location, message)
```

The canonical text does not define the location further; in the
implementation it is `file:line:col` where a source position is known.

§28 lists the codes without dividing them into compile-time and runtime
errors, except where it marks one as a Compile Error. The split below is
this document's reading of each code's meaning.

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
| `E_CANNOT_INFER` | Generic param has no call-site evidence | §6.4, §6.7 |
| `E_REGION_ESCAPE` | Region rule violation | §9 |
| `E_CAPABILITY_LEAK` | TMut leaked | §10 |

Two further codes are defined in §6.7 but not repeated in §28:
`E_TRAIT_BOUND_NOT_SATISFIED` (concrete type violates a bound) and
`E_UNKNOWN_GENERIC_PARAM` (reference to an undeclared type parameter).

Compile-time errors abort compilation.

---

## Runtime Errors

| Error Code | Condition | Specification Reference |
|------------|-----------|----------------------|
| `E_USER_ERROR` | `(error msg)` | §12.10 |
| `E_ASSERT_FAIL` | Assertion condition is false | §12.4 |
| `E_FFI_TIMEOUT` | FFI call exceeded timeout | §16 |
| `E_FFI_TIMEOUT_REQUIRED` | `ffi-call` does not end with a positive integer literal timeout | §16 |
| `E_FFI_SYMBOL_REQUIRED` | `ffi-call` symbol is not a string literal | §16 |
| `E_UNINITIALIZED_USE` | Variable used before initialization | — |
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

All are compile errors. The phase numbers are those §28 gives, which are
the phase categories of the error catalog in
`stdlib/compiler/error_codes.zyl` (19 package, 9 module, 12 trait,
13 capability), not the pipeline steps of §22. Every code below is
catalogued and raised by the package modules.

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

## Implementation Notes

Not normative.

### Catalog and rendering

`error_codes.zyl` is the catalog: each entry is a name, a phase category
(1 lexer, 2 parser, 3 macro, 4 type, 5 mono, 6 region, 7 icnf, 8 codegen,
9 module, 10 runtime, 11 test, 12 trait, 13 capability, 14 contract,
15 numeric, 16 ffi, 17 match, 18 misc/user, 19 package), a severity
(1 error, 2 warning, 3 note) and a message template. It contains every §28
code plus implementation codes such as `E_ARITY_MISMATCH`,
`E_UNBOUND_VARIABLE`, `E_DUPLICATE_DEFINITION`, `E_MALFORMED_PARAMETER`,
`E_OUT_OF_MEMORY`, the `E_UNBALANCED_*` balance errors, the byte-buffer
codes and the Secret codes (`E_CT_VIOLATION`, `E_SECRET_ESCAPE`,
`E_SECRET_DEBUG`, `E_ZEROIZE_MISSING`, `E_FFI_PIN_REQUIRED`). A few
entries are duplicated (`E_CANNOT_INFER`, `E_OUT_OF_MEMORY`) or near
duplicates (`E_ALIGNMENT_FAILED`, `E_ALIGN_CHECK_FAILED`).

A compile error aborts through the runtime's `zyl_panic`, which prints
`PANIC: ` and the message to stderr and exits with status 1. Where the
failing node has a source position, `error_report.zyl` renders the message
as:

```
error[E_UNBOUND_VARIABLE]: unbound identifier `nosuchvar`
  --> hello.zyl:3:16
   |
 3 |     (print-int nosuchvar)
   |                ^
   = help: check the spelling, or bind it with `let` before this point
```

Several checks (mutability, capability, the unused-binding checks, the
Secret checker and most of the post-processor's errors) still print a bare
`CODE: message` line without a location.

Warnings are `W_UNUSED_FUNCTION`, `W_UNUSED_PARAMETER`, `W_UNUSED_VARIABLE`
and `W_SHADOWED_BINDING` (from `unused_check.zyl`), printed to stderr
without a location, plus `E_ZEROIZE_MISSING` at severity 2. Names that are
`_` or start with `_` are exempt.

### Which §28 codes are raised

Raised by the compiler: `E_MUT_CONFLICT`, `E_CAPABILITY_LEAK`,
`E_MATCH_NONEXHAUSTIVE`, every package-system code, and
`E_RESERVED_KEYWORD` (only for the reserved byte widths; see
`spec/01-lexing-and-tokens.md`).

Catalogued but never raised: `E_USER_ERROR`, `E_ASSERT_FAIL`,
`E_REGION_ESCAPE`, `E_MACRO_NON_TERMINATION`,
`E_UNINITIALIZED_USE`, `E_TRAIT_NOT_FOUND`, `E_DUPLICATE_IMPL`,
`E_MACRO_ILLEGAL_ACCESS`, `E_CONTRACT_VIOLATION`, `E_OVERFLOW`,
`E_TEST_FAILURE`, `E_TEST_RUNNER_ERROR`, `E_TRAIT_NOT_DERIVABLE`,
`E_CANNOT_INFER`, and from §6.7 `E_TRAIT_BOUND_NOT_SATISFIED` and
`E_UNKNOWN_GENERIC_PARAM`. `E_DIVISION_BY_ZERO` is raised only by the
REPL's ICNF interpreter; a compiled program traps with SIGFPE.

Raised but not in the catalog: `E_NON_EXHAUSTIVE_MATCH` and
`E_UNREACHABLE_MATCH_ARM` (from `exhaustiveness_check.zyl`) and
`E_DUPLICATE_PARAMETER` (from `unused_check.zyl`).
`E_NON_EXHAUSTIVE_MATCH` is a second spelling of §28's
`E_MATCH_NONEXHAUSTIVE`; the two are raised by different passes.

### Runtime errors

A compiled program reports runtime failures through `zyl_panic`, which
unwinds to the innermost `try`, or to the test runner, or else prints
`PANIC: message` and exits with status 1. Messages are plain text:
`(error "boom")` prints `PANIC: boom`, a failed assertion prints
`PANIC: assert-equal failed`. The only runtime path that prints an error
code is memory exhaustion (`error[E_OUT_OF_MEMORY]`). Checkpoint-based
state reversion is not implemented (see `spec/09-ffi-contracts.md`).
