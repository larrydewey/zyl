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
| `E_INVALID_ESCAPE` | Invalid escape sequence in a string literal | §1 |
| `E_MALFORMED_FORM` | A special form's arguments do not have its required shape | §2 |
| `E_NESTED_PATTERN` | Nested pattern in a constructor arm | §4.9, §8 |
| `E_MATCH_NONEXHAUSTIVE` | Missing match case | §8.3 |
| `E_MUT_CONFLICT` | Aliasing violation (TMut/TCap) | §10 |
| `E_TRAIT_NOT_FOUND` | Missing impl for trait bound | §5.4 |
| `E_DUPLICATE_IMPL` | Conflicting impls | §5.3 |
| `E_TRAIT_NOT_DERIVABLE` | Cannot derive trait | §5.6 |
| `E_MACRO_NON_TERMINATION` | Macro expansion loop | §19 |
| `E_MACRO_ILLEGAL_ACCESS` | Macro accessed runtime value | §19.4 |
| `E_CANNOT_INFER` | A type the program does not determine | §4.10, §6.7 |
| `E_INFINITE_TYPE` | A type would contain itself (occurs check) | §4.10 |
| `E_FFI_TIMEOUT_REQUIRED` | `ffi-call` does not end with a positive integer literal timeout | §16 |
| `E_FFI_SYMBOL_REQUIRED` | `ffi-call` symbol is not a string literal | §16 |
| `E_FFI_RESTRICTED` | `ffi-call` names a raw runtime entry outside the standard library, or an `extern` declares a runtime entry | §16 |
| `E_REGION_ESCAPE` | Region rule violation | §9 |
| `E_REGION_SPEC` | Malformed `with-region` specification | §9.2 |
| `E_CAPABILITY_LEAK` | TMut leaked | §10 |

§4.10 defines two further type errors that §28 does not repeat:
`E_TYPE_MISMATCH` (two types that must be equal are not) and
`E_UNBOUND_VARIABLE` (a name defined nowhere). §6.7 defines
`E_TRAIT_BOUND_NOT_SATISFIED` (concrete type violates a bound) and
`E_UNKNOWN_GENERIC_PARAM` (reference to an undeclared type parameter).
§6.7 still words `E_CANNOT_INFER` as "generic param with no call-site
evidence", a special case of §4.10's meaning.

Compile-time errors abort compilation. The type errors of §4.10 are all
reported before the compile fails (§4.8).

---

## Runtime Errors

| Error Code | Condition | Specification Reference |
|------------|-----------|----------------------|
| `E_USER_ERROR` | `(error msg)` | §12.10 |
| `E_ASSERT_FAIL` | Assertion condition is false | §12.4 |
| `E_FFI_TIMEOUT` | FFI call exceeded timeout | §16 |
| `E_INDEX_OUT_OF_BOUNDS` | Index outside a word array | §13 |
| `E_UNINITIALIZED_USE` | Variable used before initialization | — |
| `E_CONTRACT_VIOLATION` | Contract condition failed | §23 |
| `E_OVERFLOW` | Integer overflow | §20.1 |
| `E_DIVISION_BY_ZERO` | Division by zero (Int) | §20.3 |
| `E_REGION_EXHAUSTED` | A `with-region` region ran out of its fixed size or limit (catchable) | §9.2 |
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

Raised by the compiler: `E_RESERVED_KEYWORD` (only for the reserved byte
widths; see `spec/01-lexing-and-tokens.md`), `E_INVALID_ESCAPE`
(`parser.zyl`), `E_MALFORMED_FORM` and `E_FFI_RESTRICTED` (the arity
pass, below), `E_FFI_SYMBOL_REQUIRED` and `E_FFI_TIMEOUT_REQUIRED`
(`ffi-check-call`), `E_NESTED_PATTERN` (`expr_inner.zyl`),
`E_MACRO_NON_TERMINATION` and `E_MACRO_ILLEGAL_ACCESS`
(`macro_expand.zyl`), `E_MUT_CONFLICT` and `E_CAPABILITY_LEAK`
(`mutability_check.zyl`), `E_MATCH_NONEXHAUSTIVE`, `E_DUPLICATE_IMPL`
and `E_TRAIT_NOT_DERIVABLE` (`derive.zyl`), `E_TRAIT_NOT_FOUND`,
`E_CANNOT_INFER` and `E_INFINITE_TYPE` (`type_annotate.zyl`),
`E_REGION_ESCAPE` (a `(bytebuf Stack N)` that escapes its frame, or a
value that outlives its `with-region`), `E_REGION_SPEC`, and every
package-system code. Raised at run time: `E_FFI_TIMEOUT`,
`E_INDEX_OUT_OF_BOUNDS` (vectors and word arrays), `E_REGION_EXHAUSTED`
and `E_CONTRACT_VIOLATION` (the prefix of a failed contract check's
message).

Catalogued but never raised: `E_USER_ERROR`, `E_ASSERT_FAIL`,
`E_UNINITIALIZED_USE`, `E_OVERFLOW`, `E_TEST_FAILURE`,
`E_TEST_RUNNER_ERROR`, and from §6.7 `E_TRAIT_BOUND_NOT_SATISFIED` and
`E_UNKNOWN_GENERIC_PARAM`. `E_DIVISION_BY_ZERO` is raised only by the
REPL's ICNF interpreter; a compiled program traps with SIGFPE.

Raised but not in the catalog: `E_NON_EXHAUSTIVE_MATCH` and
`E_UNREACHABLE_MATCH_ARM` (from `exhaustiveness_check.zyl`),
`E_DUPLICATE_PARAMETER` (from `unused_check.zyl`), `W_TYPE_STRICT` (the
type pass in report mode) and the interpreter's `E_INTERP_TAG`.
`E_NON_EXHAUSTIVE_MATCH` is a second spelling of §28's
`E_MATCH_NONEXHAUSTIVE`; the two are raised by different passes.

### Type errors

The type pass (`type_annotate.zyl`, see
`spec/05-types-and-inference.md`) reports every unification failure as a
located `E_TYPE_MISMATCH` (`cannot unify A with B`, or `mismatched types:
expected T, found U` with a label at the parameter or field declaration
it clashes with), every failed occurs check as `E_INFINITE_TYPE`, every
type it cannot determine as `E_CANNOT_INFER` (a foreign `ffi-call` with no
`extern`, a runtime symbol with no signature, a trait call whose receiver
type stays unknown, a `struct-get` whose record type stays unknown when
several structs have the field, a function needing more than 256
specialized instances), and every unknown name as `E_UNBOUND_VARIABLE`. It does not
stop at the first: it types the whole program, printing each error, and
then fails with

```
PANIC: error[E_TYPE_MISMATCH]: the program does not type-check (3 errors above)
```

where the code is the first error's. A `struct-get` of a field a known
struct lacks (`E_TYPE_MISMATCH`), the trait-method errors
(`E_TRAIT_NOT_FOUND`), `ffi-pin` of a function (`E_FFI_TYPE_NOT_PINNABLE`)
and an `ffi-call` to a runtime entry the program also declares with
`extern` (`E_FFI_RESTRICTED`) are collected the same way. Setting
`ZYL_STRICT_TYPES=report` (or `1`) prints each of the collected errors as
a `W_TYPE_STRICT` warning instead and lets the compile continue; it is
for counting errors, not for running an ill-typed program. The catalog's
message for `E_CANNOT_INFER` still reads "cannot infer concrete type for
generic parameter G", the narrower old meaning.

### Form and FFI errors from the arity pass

`arity_check.zyl` runs with the other checks after macro expansion.
Besides `E_ARITY_MISMATCH` it raises:

- `E_MALFORMED_FORM` for any special form whose shape its parser in
  `expr_inner.zyl` rejected (the parser builds an `EUnknown` node for it,
  which used to lower silently to the constant 0): for example a `let`
  with no body, a `test` or `defmacro` with more than one body, an
  `assert-equal` with one argument, a malformed `extern`, or a trait
  method whose parameters are not a list.
- `E_FFI_RESTRICTED` for an `ffi-call` naming one of the raw runtime
  entries of `ffi-raw-p` (`ffi_sigs.zyl`) from a definition outside the
  standard library. (The type pass raises the same code for an `extern`
  of a runtime entry.)

### Duplicate and pattern errors

- `E_DUPLICATE_VARIANT` is raised by `duplicate_check.zyl` when a program
  type outside the standard library declares a prelude constructor name
  (`Some`, `None`, `Ok`, `Err`, `Cons`, `Nil`): the standard library's
  unqualified uses of those names would resolve to it. ICNF lowering
  also raises it for a variant name repeated within one `deftype`.
- `E_NESTED_PATTERN` is raised by the parse for a constructor arm whose
  field position holds anything but a plain name, including a prelude
  constructor name or a qualified name used as a binder (`(Some Nil
  ...)` would bind a variable called `Nil`).

### Runtime errors

A compiled program reports runtime failures through `zyl_panic`, which
unwinds to the innermost `try`, or to the test runner, or else prints
`PANIC: message` and exits with status 1. Most messages are plain text:
`(error "boom")` prints `PANIC: boom`, a failed assertion prints
`PANIC: assert-equal failed`. Those that start with a code are the
runtime's own (`E_INDEX_OUT_OF_BOUNDS`, `E_REGION_EXHAUSTED`,
`E_FFI_TIMEOUT`, `error[E_OUT_OF_MEMORY]`) and contract failures
(`E_CONTRACT_VIOLATION: ...`); `recover` matches arms on that prefix.
`(checkpoint e)` restores the outer `let-mut` variables `e` assigned
before an error propagates (see `spec/09-ffi-contracts.md`).
