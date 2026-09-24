# Zyl Compiler Error Index

Every diagnostic code the self-hosted compiler, the REPL interpreter and the
runtime know about. The catalog lives in `stdlib/compiler/error_codes.zyl`
(`error-codes`, one `(EC name phase severity message)` per code); spec §28
lists the normative subset. The catalog was originally transcribed from the
Rust bootstrap's `ZylError` enum (`archive/rust-bootstrap-2026/`) and has
since gained the self-hosted-only and package-system (§31) codes.

The catalog is data, not a dispatcher: each checker writes its own code
name into the message it raises, and nothing looks the code up at raise
time. As a result the catalog contains codes that no current module emits,
and a few modules emit codes the catalog does not contain. Both are listed
below; the "Raised by" column was produced by searching the active sources
(`stdlib/`, `selfhost/driver.zyl`, `runtime/actor_runtime.c`), not by
running every path.

## How a diagnostic looks

Two shapes are in use.

**Located diagnostics** go through `err-at` in
`stdlib/compiler/error_report.zyl`, which renders a header, the
`path:line:col` of the node's recorded span, the source line, a caret and a
help line:

```
PANIC: error[E_UNBOUND_VARIABLE]: unbound identifier `y`
  --> unbound.zyl:1:25
   |
 1 | (defn main () (print (+ y 1)))
   |                         ^
   = help: check the spelling, or bind it with `let` before this point
```

A node with no recorded span (offset < 0, i.e. one a later phase
synthesized) degrades to the header plus the `= help:` line. Names in the
message are shortened from their canonical symbol key
(`local/main@0::mod::f`) to the part after the last `::` (`err-name`).
The checks that currently produce located diagnostics are the balance check
(`E_UNBALANCED_*`, `E_UNTERMINATED_STRING`), `duplicate_check.zyl`
(`E_DUPLICATE_DEFINITION`), `arity_check.zyl` (`E_ARITY_MISMATCH`),
`exhaustiveness_check.zyl` (`E_NON_EXHAUSTIVE_MATCH`,
`E_UNREACHABLE_MATCH_ARM`), `expr_inner.zyl` (`E_MALFORMED_PARAMETER`) and
`codegen.zyl` (`E_UNBOUND_VARIABLE`).

**Plain diagnostics** are every other check: `zyl_panic` with a string of
the form `CODE: message`, printed as `PANIC: CODE: message` with no
location.

Every error is fatal: the first one aborts the compile with exit status 1.
There is no error recovery and no multi-error report. Warnings are printed
to stderr as `CODE: message` and do not change the exit status.

## Catalog

Phase numbers are the ones `error_codes.zyl` assigns: 1 lexer, 2 parser,
3 macro, 4 type, 5 mono, 6 region, 7 ICNF, 8 codegen, 9 module/package
resolution, 10 runtime, 11 test, 12 trait, 13 capability, 14 contract,
15 numeric, 16 FFI, 17 match, 19 package. Severity is 1 (error) unless noted.
"Catalog only" means no active module raises the code today. §28 marks the
codes spec §28 lists by name.

### Lexer (phase 1)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_BYTE_VALUE_OOB` | lexer: byte literal out of range 0-255 | `expr_inner.zyl` (`(byte N)` forms) |
| `E_FLOAT_OVERFLOW` | lexer: float overflow in literal L at S | catalog only |
| `E_INTEGER_OVERFLOW` | lexer: integer overflow in literal L at S | catalog only |
| `E_INVALID_CHAR` | lexer: invalid character C at S | catalog only |
| `E_UNEXPECTED_EOF` | lexer: unexpected EOF while expecting C at S | catalog only |
| `E_UNTERMINATED_STRING` | lexer: unterminated string at S | `parser.zyl` (balance check, located) |

### Parser (phase 2)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_ATOM_AS_OPERATOR` | parser: atom cannot be used as operator in prefix position at S | catalog only |
| `E_EMPTY_LIST` | parser: empty list is not a valid expression at S | catalog only |
| `E_EXPECTED_EXPRESSION` | parser: expected an expression but found T at S | catalog only |
| `E_EXPECTED_RBRACKET` | parser: expected ] but found T at S | catalog only |
| `E_EXPECTED_RCURLY` | parser: expected } but found T at S | catalog only |
| `E_EXPECTED_RPAREN` | parser: expected ) at S but found T | catalog only |
| `E_MALFORMED_PARAMETER` | parser: P is not a parameter at S - write a name, or (name Type) | `expr_inner.zyl` (located) |
| `E_RESERVED_KEYWORD` (§28) | parser: reserved keyword K cannot be used as identifier at S | `expr_inner.zyl` (reserved-but-unimplemented forms) |
| `E_UNBALANCED_PARENS` | parser: unbalanced parens - open and close counts differ | catalog only (the old depth-counter check; superseded by the three below) |
| `E_UNBALANCED_UNCLOSED` | parser: unclosed opener - opened at S, never reached its matching closer | `parser.zyl` via `sexp_balance.zyl` (located at the opener) |
| `E_UNBALANCED_UNEXPECTED_CLOSE` | parser: unexpected closing delimiter at S - no opener is open here | `parser.zyl` via `sexp_balance.zyl` (located) |
| `E_UNBALANCED_MISMATCHED_BRACKET` | parser: closing delimiter at S does not match its opener | `parser.zyl` via `sexp_balance.zyl` (located), e.g. `(...]` |
| `E_UNEXPECTED_TOKEN_IN_EXPR` | parser: unexpected token T in expression context at S | `expr_inner.zyl` (endian keyword, `bytebuf` capacity) |

The balance check runs on the whole source before parsing
(`compile-check-balance` in `pipeline.zyl`, `check-balanced` in
`parser.zyl`). `sexp_balance.zyl` is a string- and comment-aware stack scan
over bracket type, and its `sb-hint` supplies the `= help:` text.

### Macro (phase 3)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_MACRO_ILLEGAL_ACCESS` (§28) | macro: illegal runtime access in macro expansion | catalog only |
| `E_MACRO_NON_TERMINATION` (§28) | macro: expansion loop detected (max depth exceeded) | catalog only |

### Type (phases 4 and 5)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_ARITY_MISMATCH` | type: function arity mismatch for F at S: expected E arguments, found G | `arity_check.zyl` (located), `icnf.zyl`, `expr_inner.zyl` (special forms), REPL interpreter |
| `E_ATOMIC_ABA` | region: atomic CAS on non-Pin memory is forbidden | catalog only |
| `E_BYTEBUF_NOT_PIN` | type: bytebuf-ptr requires Pin region | catalog only |
| `E_STACK_BYTEBUF_RETURN` | type: Stack ByteBuf cannot be returned | catalog only |
| `E_GLOBAL_BYTEBUF_MUT` | type: Global ByteBuf must be immutable | catalog only |
| `E_DUPLICATE_DEFINITION` | type: duplicate definition of N at S. previously defined at P | `duplicate_check.zyl` (located at the second definition) |
| `E_DUPLICATE_VARIANT` | type: duplicate variant V in deftype at S | `icnf.zyl` (a variant name defined twice in one `deftype`) |
| `E_RETURN_TYPE_MISMATCH` | type: return type mismatch in F - expected T, got U at S | catalog only |
| `E_TYPE_MISMATCH` | type: type mismatch at S - expected E, found F | catalog only |
| `E_UNBOUND_VARIABLE` | type: unbound variable V at S | `codegen.zyl` (located), REPL interpreter |
| `E_UNKNOWN_GENERIC_PARAM` | type: unknown generic parameter G at S | catalog only |
| `E_UNKNOWN_TYPE` | type: unknown type T at S | catalog only |
| `E_CANNOT_INFER` (§28, phase 5) | type: cannot infer concrete type for generic parameter G at S - no call-site evidence | catalog only (listed twice in the catalog) |

Type inference does not currently reject ill-typed programs:
`(+ 1 "a")` compiles without a diagnostic, and `E_TYPE_MISMATCH` /
`E_RETURN_TYPE_MISMATCH` are never raised.

### Region and ICNF (phases 6 and 7)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_REGION_ESCAPE` (§28) | region: value escapes region constraint at S | catalog only (`region_inference.zyl` mentions it only in comments) |
| `E_UNINITIALIZED_USE` (§28) | variable: use of uninitialized variable V at S | catalog only |
| `E_MATCH_ARM_COMPLEX` | match: arm combines a constant with multiple calls - bind to lets first | `icnf.zyl` |
| `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN` | icnf: top-level statements combined with explicit main | `icnf.zyl` (top-level `test`/`run-tests` forms next to an explicit `(defn main ...)`) |

`E_MATCH_ARM_COMPLEX` rejects a match arm that combines a constant with two
or more calls in one binary operation, or that nests binop chains; bind the
parts with `let` or move the sum into a helper function.

### Codegen (phase 8)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_CODEGEN` | codegen: M | catalog only |
| `E_CODEGEN_BUFFER_FULL` | codegen: output buffer full at S | `pipeline.zyl` (generated assembly exceeded the codegen text buffer) |
| `E_CODEGEN_BUFFER_LIMIT` | codegen: buffer limit reached: M | catalog only (the runtime's bounded append panics with `codegen buffer limit exceeded` and no code) |

### Modules and package resolution (phase 9)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_CIRCULAR_MODULE` | module: circular dependency: M | catalog only (superseded by `E_MODULE_CYCLE`) |
| `E_MODULE_NOT_FOUND` | module: module M not found at P | `module_resolver.zyl` |
| `E_SYMBOL_NOT_EXPORTED` | module: symbol N not exported by M | catalog only (superseded by `E_PKG_PRIVATE_SYMBOL`) |
| `E_PKG_CYCLE` (§28) | package: dependency graph is not a DAG: M | `mvs.zyl`, `module_resolver.zyl` |
| `E_MODULE_CYCLE` (§28) | module: module graph within package N is not a DAG: M | `module_resolver.zyl` |
| `E_PKG_VERSION_CONFLICT` (§28) | package: requirement on N cannot be satisfied within major V | `mvs.zyl`, `workspace.zyl` |
| `E_PKG_PRIVATE_SYMBOL` (§28) | module: symbol N imported from M is not pub | `module_resolver.zyl` |
| `E_PKG_UNKNOWN_SYMBOL` (§28) | module: symbol N does not exist in M | `module_resolver.zyl` |
| `E_PKG_UNKNOWN_MODULE` (§28) | module: module path M does not exist in package N | `module_resolver.zyl` |
| `E_PKG_UNDECLARED_DEP` (§28) | module: use names package N, absent from the manifest | `module_resolver.zyl` |
| `E_PKG_RESERVED_MODULE` (§28) | module: unsafe is a reserved module name | `module_resolver.zyl` |

### Runtime (phase 10)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_ALIGNMENT_FAILED` | runtime: alignment check failed | catalog only |
| `E_ALIGN_CHECK_FAILED` | runtime: alignment check failed | catalog only (same message as the previous entry) |
| `E_ASSERT_FAIL` (§28) | assertion: condition failed - M at S | catalog only |
| `E_BYTE_OOB` | runtime: byte offset out of bounds | catalog only |
| `E_BYTEBUF_CAP_EXCEEDED` | runtime: bytebuf append exceeds capacity | catalog only (the runtime fails closed past capacity but prints no code) |
| `E_BYTEBUF_INVALID` | runtime: bytebuf magic tag mismatch | catalog only |
| `E_BYTEBUF_OVERLAP` | runtime: bytebuf append overlapping slice | catalog only |
| `E_LIST_NTH_OOB` | runtime: list-nth index out of bounds at S | `monomorphization.zyl` (compiler-internal) |
| `E_NULL_POINTER` | runtime: null pointer dereference | catalog only |
| `E_OUT_OF_MEMORY` | runtime: memory budget exhausted - raise or remove it with ZYL_MAX_MEMORY | `actor_runtime.c` (`PANIC: error[E_OUT_OF_MEMORY]: ...`); a second catalog entry reads "runtime: out of memory" |
| `E_USER_ERROR` (§28) | runtime: user error - M at S | catalog only |

What a compiled program prints at runtime today: `(error "boom")` prints
`PANIC: boom` and exits 1; a failed `assert-true` or `assert-equal` prints
`PANIC: assert-true failed` or `PANIC: assert-equal failed` and exits 1.
Neither carries the catalog code. The one-argument form `(assert c)` is
parsed (`EAssert`) and checked, but `icnf.zyl` does not lower it, so a
false `(assert ...)` in a compiled program currently does nothing.

### Test (phase 11)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_TEST_FAILURE` (§28) | test: assertion failed - M | catalog only |
| `E_TEST_RUNNER_ERROR` (§28) | test: runner error - M | catalog only |

### Traits (phase 12)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_DUPLICATE_IMPL` (§28) | trait: duplicate impl of T for U at S | catalog only |
| `E_TRAIT_BOUND_NOT_SATISFIED` | type: unsatisfied trait bound T : U at S | catalog only |
| `E_TRAIT_NOT_DERIVABLE` (§28) | trait: cannot derive T for type U at S | catalog only |
| `E_TRAIT_NOT_FOUND` (§28) | trait: no implementation found for T at S | catalog only |
| `E_PKG_ORPHAN_IMPL` (§28) | trait: impl of T for U where neither the trait nor the type is local to N | `module_resolver.zyl` |

### Capabilities and secrets (phase 13)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_CAPABILITY_LEAK` (§28) | capability: TMut leaked across boundary at S | `mutability_check.zyl` |
| `E_INVALID_CAPABILITY` | type: invalid capability usage for F - M at S | `mutability_check.zyl` (closure passed to `ffi-call`), `type_inference.zyl` (FFI value of a non-pinnable type) |
| `E_MUT_CONFLICT` (§28) | aliasing: mutable reference conflict at S | `mutability_check.zyl` (`set!` on a non-`let-mut` binding, or, located, on a `let-mut` captured by a closure), `expr_inner.zyl` |
| `E_CT_VIOLATION` | constant-time: secret-dependent M at S - branches, memory indices and divisions must not depend on a Secret value | `secret_check.zyl` |
| `E_SECRET_ESCAPE` | secret: Secret value escapes through M at S | `secret_check.zyl` |
| `E_SECRET_DEBUG` | secret: Secret value reaches a debug/print sink at S | `secret_check.zyl` |
| `E_ZEROIZE_MISSING` (severity 2, warning) | secret: function F takes a Secret parameter but never zeroizes it | `secret_check.zyl` |
| `E_PKG_CAPABILITY_VIOLATION` (§28) | capability: package N uses M without declaring the C capability | `capability_check.zyl`, `cli.zyl` |
| `E_PKG_CAPABILITY_GROWTH` (§28) | capability: capability closure grew under --locked: C | `capability_check.zyl`, `mvs.zyl` |

`E_ZEROIZE_MISSING` fires when a function consumes a `Secret` parameter into
a public result and never calls `zeroize`/`zeroize-bytes` on it. It is a
warning because erasure can legitimately live one frame up;
`secret_check.zyl` exempts secret-returning functions and the declassifiers
themselves.

### Contracts, numeric, FFI, match (phases 14 to 17)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_CONTRACT_VIOLATION` (§28) | contract: contract violation - M at S | catalog only |
| `E_DIVISION_BY_ZERO` (§28) | numeric: division by zero at S | REPL interpreter only; a compiled `(/ 1 0)` dies with SIGFPE |
| `E_OVERFLOW` (§28) | numeric: integer overflow at S | catalog only |
| `E_FFI_PIN_REQUIRED` | ffi: Secret argument to F must be handed over through ffi-pin (Pin region) at S | `secret_check.zyl` |
| `E_FFI_TYPE_NOT_PINNABLE` | ffi: value has type T which is not FFI_Pinnable | catalog only (`type_inference.zyl` and `mutability_check.zyl` report a non-pinnable FFI argument as `E_INVALID_CAPABILITY`) |
| `E_FFI_TIMEOUT` (§28) | ffi: call exceeded timeout of M ms at S | catalog only |
| `E_MATCH_NONEXHAUSTIVE` (§28) | match: non-exhaustive pattern match at S - missing cases: M | `icnf.zyl` (unknown variant in an arm; residual non-exhaustive match), `expr_inner.zyl` (literal-pattern match without a final `_`), REPL interpreter |

The main compile-time exhaustiveness check (`exhaustiveness_check.zyl`)
reports a missing variant as `E_NON_EXHAUSTIVE_MATCH`, not the spec's
`E_MATCH_NONEXHAUSTIVE`; see the next section.

### Package manifest, lock and registry (phase 19)

All raised by the package modules named; all are §28 codes.

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_MANIFEST_INVALID` | package: zyl.pkg is malformed or missing required field F at P | `package.zyl`, `workspace.zyl`, `mvs.zyl` |
| `E_MANIFEST_NOT_FOUND` | package: no zyl.pkg in package root P | `package.zyl`, `selfhost/driver.zyl` |
| `E_PKG_BAD_NAME` | package: N is not a valid scoped package path | `package.zyl` |
| `E_PKG_BAD_VERSION` | package: V is not a strict SemVer version | `package.zyl` |
| `E_PKG_BAD_REQUIREMENT` | package: requirement R uses a range operator - MVS takes bare minimum versions | `package.zyl` |
| `E_PKG_DUPLICATE_DEP` | package: duplicate dep entry for N | `package.zyl`, `cli.zyl` |
| `E_PKG_NOT_FOUND` | package: N is not present in the index | `index.zyl` |
| `E_PKG_VERSION_NOT_FOUND` | package: version V of N is not present in the index | `index.zyl`, `cli.zyl` |
| `E_PKG_NOT_IN_STORE` | package: N V is not in the store - run zyl fetch | `store.zyl`, `mvs.zyl`, `module_resolver.zyl` |
| `E_PKG_HASH_MISMATCH` | package: archive hash for N V differs from the lock | `store.zyl` |
| `E_PKG_SIGNATURE_INVALID` | package: Ed25519 signature for N V does not verify | `index.zyl` |
| `E_PKG_KEY_CHANGED` | package: publisher key for N differs from the pinned key | `index.zyl` |
| `E_PKG_UNSIGNED` | package: index entry for N V carries no signature | `index.zyl`, `cli.zyl` |
| `E_PKG_YANKED` | package: resolution selected yanked version V of N | `index.zyl` |
| `E_PKG_LOCK_STALE` | package: --locked, but the manifests imply a different graph | `selfhost/driver.zyl` |
| `E_PKG_LOCK_INVALID` | package: zyl.lock is malformed or of an unknown version | `lock.zyl` |
| `E_PKG_COMPILER_TOO_OLD` | package: N requires compiler version V, this is C | `package.zyl` |
| `E_PKG_UNKNOWN_EDITION` | package: edition E is not known to this compiler | `package.zyl` |
| `E_PKG_FETCH_FAILED` | package: fetch of N V failed - M | `store.zyl`, `index.zyl` |
| `E_PKG_ARCHIVE_INVALID` | package: archive for N V violates the canonical format - M | `store.zyl` |
| `E_PKG_NATIVE_PATH_ESCAPE` | package: native source path P escapes the package root | `cli.zyl` |
| `E_PKG_NATIVE_FLAG_DENIED` | package: cflag F is outside the allowlist | `cli.zyl` |
| `E_PKG_NATIVE_BUILD_FAILED` | package: cc failed on native source P | `cli.zyl` |
| `E_PKG_FEATURE_UNKNOWN` | package: feature F is not declared by N | `module_resolver.zyl`, `mvs.zyl` |
| `E_PKG_FEATURE_COLLISION` | package: gated definition D collides with a base definition | `module_resolver.zyl` |

## Codes raised but not in the catalog

| Code | Severity | Raised by | Meaning |
|------|----------|-----------|---------|
| `E_NON_EXHAUSTIVE_MATCH` | error | `exhaustiveness_check.zyl` (located) | a `match` over a `deftype` does not cover some variant and has no `_` arm |
| `E_UNREACHABLE_MATCH_ARM` | error | `exhaustiveness_check.zyl` (located) | an arm after a catch-all, or a repeated constructor arm |
| `E_DUPLICATE_PARAMETER` | error | `unused_check.zyl` | two parameters of one `defn`/`fn`/`lambda` share a name |
| `W_UNUSED_FUNCTION` | warning | `unused_check.zyl` | a top-level `defn` is never referenced by name |
| `W_UNUSED_PARAMETER` | warning | `unused_check.zyl` | a parameter is never used (`_` and `_`-prefixed names are exempt) |
| `W_UNUSED_VARIABLE` | warning | `unused_check.zyl` | a `let`/`let-mut`/`for` binding is never used |
| `W_SHADOWED_BINDING` | warning | `unused_check.zyl` | a binding shadows an outer binding of the same name |
| `E_UNDEFINED_FUNCTION` | error | `stdlib/repl/interp.zyl` | a call names no function (the compiled path reports `E_UNBOUND_VARIABLE` from codegen's `cg-call-user`) |
| `E_NOT_CALLABLE` | error | `stdlib/repl/interp.zyl` | a call's head is not a function or closure |
| `E_UNSUPPORTED_INTERPRETED` | error | `stdlib/repl/interp.zyl` | spawning an actor, which needs a native entry point; compile the program instead |
| `E_FFI_SYMBOL_NOT_FOUND` | error | `stdlib/repl/interp.zyl`, `actor_runtime.c` | an `ffi-call` names a symbol the REPL process does not export |
| `E_NO_MAIN` | error | `stdlib/repl/interp.zyl` | the interpreted program defines no `main` (`zyl eval`) |
| `E_INTERNAL` | error | `stdlib/repl/eval.zyl` | a REPL entry's wrapper function did not survive lowering (an internal fault) |

The REPL's interpreter errors are reported to the prompt and do not end the
session; see `docs/repl.md`.
