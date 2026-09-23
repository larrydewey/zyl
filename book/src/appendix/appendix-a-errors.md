# Appendix A: Error Codes Reference

Every code the compiler and runtime can report. The single source of
truth is `stdlib/compiler/error_codes.zyl`; this appendix mirrors it,
grouped by the phase that raises each one.

A diagnostic's code also travels to your editor: the language server
puts it in the LSP `code` field, so you can filter or group on it
without matching message text (Chapter 35).

## A.1 Lexing

| Code | Cause |
|---|---|
| `E_INVALID_CHAR` | A character that cannot begin any token |
| `E_UNEXPECTED_EOF` | End of input while a token was still open |
| `E_UNTERMINATED_STRING` | A string literal with no closing quote |
| `E_INTEGER_OVERFLOW` | An integer literal too large for `Int` |
| `E_FLOAT_OVERFLOW` | A float literal too large for `Float` |
| `E_BYTE_VALUE_OOB` | A `byte` literal outside 0..255 |

## A.2 Parsing and S-Expression Balance

| Code | Cause |
|---|---|
| `E_UNBALANCED_UNCLOSED` | An opener never reached its matching closer |
| `E_UNBALANCED_UNEXPECTED_CLOSE` | A closing delimiter with no opener open |
| `E_UNBALANCED_MISMATCHED_BRACKET` | A closer that does not match its opener |
| `E_UNBALANCED_PARENS` | Open and close counts differ |
| `E_EXPECTED_RPAREN` / `E_EXPECTED_RBRACKET` / `E_EXPECTED_RCURLY` | A specific closer was required |
| `E_EXPECTED_EXPRESSION` | An expression was required here |
| `E_UNEXPECTED_TOKEN_IN_EXPR` | A token that cannot appear in expression position |
| `E_EMPTY_LIST` | `()` is not an expression |
| `E_ATOM_AS_OPERATOR` | An atom used in operator position |
| `E_RESERVED_KEYWORD` | A reserved word used as an identifier, or a reserved form that is not yet implemented |

The balance check runs before parsing and is what an editor shows while
you are still typing. Its diagnostics carry a fix-it hint, which the
language server turns into a quick-fix code action.

## A.3 Macro Expansion

| Code | Cause |
|---|---|
| `E_MACRO_NON_TERMINATION` | Expansion exceeded the maximum depth |
| `E_MACRO_ILLEGAL_ACCESS` | A macro reached a runtime value |

## A.4 Types, Names and Arity

| Code | Cause |
|---|---|
| `E_TYPE_MISMATCH` | Expected one type, found another |
| `E_RETURN_TYPE_MISMATCH` | A function's body does not match its declared return type |
| `E_UNBOUND_VARIABLE` | A name with no binding |
| `E_UNKNOWN_TYPE` | A type name that does not resolve |
| `E_UNKNOWN_GENERIC_PARAM` | A reference to an undeclared type parameter |
| `E_CANNOT_INFER` | A generic parameter with no call-site evidence |
| `E_ARITY_MISMATCH` | A call with the wrong number of arguments |
| `E_DUPLICATE_DEFINITION` | A name defined more than once |
| `E_DUPLICATE_PARAMETER` | A parameter name repeated in one signature |
| `E_DUPLICATE_VARIANT` | A variant name shared across `deftype`s |
| `E_UNINITIALIZED_USE` | A variable read before initialisation |

## A.5 Pattern Matching

| Code | Cause |
|---|---|
| `E_NON_EXHAUSTIVE_MATCH` | A `match` that does not cover every variant |
| `E_MATCH_NONEXHAUSTIVE` | The same condition, reported from the type layer |
| `E_UNREACHABLE_MATCH_ARM` | An arm no value can reach |
| `E_MATCH_ARM_COMPLEX` | An arm body combining a constant with several calls — bind to `let`s first |

Exhaustiveness is a compile-time error, not a warning. A `dN` arm is
the wildcard convention used throughout this codebase.

## A.6 Regions and Memory

| Code | Cause |
|---|---|
| `E_REGION_ESCAPE` | A value escapes its assigned region |
| `E_STACK_BYTEBUF_RETURN` | A Stack `ByteBuf` returned from its scope |
| `E_GLOBAL_BYTEBUF_MUT` | A Global `ByteBuf` mutated |
| `E_BYTEBUF_NOT_PIN` | `bytebuf-ptr` on a buffer outside the Pin region |
| `E_ATOMIC_ABA` | An atomic compare-and-swap on non-Pin memory |

## A.7 Capabilities and Secrets

| Code | Cause |
|---|---|
| `E_MUT_CONFLICT` | A `TMut` and a `TCap` alias the same memory |
| `E_CAPABILITY_LEAK` | A `TMut` crossed a boundary it may not cross |
| `E_INVALID_CAPABILITY` | A capability used where it does not apply |
| `E_CT_VIOLATION` | A `Secret` steered a branch, indexed memory, or went through a divider |
| `E_SECRET_ESCAPE` | A `Secret` reached `spawn`, `send` or `file-write` |
| `E_SECRET_DEBUG` | A `Secret` reached `print` |
| `E_ZEROIZE_MISSING` | *(warning)* A function takes a `Secret` and never zeroizes it |
| `E_FFI_PIN_REQUIRED` | A `Secret` crossed the FFI boundary without `ffi-pin` |

Chapter 33 covers all of these in context.

## A.8 Traits

| Code | Cause |
|---|---|
| `E_TRAIT_NOT_FOUND` | No implementation for a required trait |
| `E_TRAIT_BOUND_NOT_SATISFIED` | A concrete type lacks a required trait |
| `E_TRAIT_NOT_DERIVABLE` | `derive` asked for a trait that cannot be derived for this type |
| `E_DUPLICATE_IMPL` | Two implementations of the same trait for the same type |

## A.9 Modules

| Code | Cause |
|---|---|
| `E_MODULE_NOT_FOUND` | A `use` path that does not resolve |
| `E_CIRCULAR_MODULE` | A cycle in the module graph |
| `E_SYMBOL_NOT_EXPORTED` | A name the module does not export |

## A.10 FFI

| Code | Cause |
|---|---|
| `E_FFI_TYPE_NOT_PINNABLE` | A value whose type is not `FFI_Pinnable` |
| `E_FFI_TIMEOUT` | An FFI call exceeded its timeout |
| `E_FFI_PIN_REQUIRED` | See §A.7 |

## A.11 Lowering and Code Generation

| Code | Cause |
|---|---|
| `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN` | Top-level statements alongside an explicit `main` |
| `E_CODEGEN` | A code-generation failure |
| `E_CODEGEN_BUFFER_FULL` / `E_CODEGEN_BUFFER_LIMIT` | The output buffer filled |

## A.12 Runtime

| Code | Cause |
|---|---|
| `E_ASSERT_FAIL` | `assert` failed, or `unwrap` was applied to an `Err` |
| `E_USER_ERROR` | `(error "...")` |
| `E_DIVISION_BY_ZERO` | Integer division by zero |
| `E_OVERFLOW` | Checked integer overflow |
| `E_NULL_POINTER` | A null dereference |
| `E_OUT_OF_MEMORY` | An allocation failed |
| `E_LIST_NTH_OOB` | `list-nth` past the end |
| `E_BYTE_OOB` | A byte offset outside its buffer |
| `E_BYTEBUF_CAP_EXCEEDED` | An append past a buffer's fixed capacity |
| `E_BYTEBUF_OVERLAP` | An append from a slice overlapping its own buffer |
| `E_BYTEBUF_INVALID` | A buffer handle whose magic tag does not match |
| `E_ALIGNMENT_FAILED` / `E_ALIGN_CHECK_FAILED` | An `align-check` that did not hold |
| `E_CONTRACT_VIOLATION` | A `requires` or `ensures` clause failed |

## A.13 Testing

| Code | Cause |
|---|---|
| `E_TEST_FAILURE` | A test assertion failed |
| `E_TEST_RUNNER_ERROR` | An error inside the test harness itself |

## A.14 Warnings

Warnings are printed, not raised, and never stop a build:

| Code | Cause |
|---|---|
| `W_UNUSED_PARAMETER` | A parameter never read. Name it `d1`, `d2`, … to exempt it |
| `W_UNUSED_VARIABLE` | A binding never read |
| `W_SHADOWED_BINDING` | A binding that hides an outer one of the same name |
| `E_ZEROIZE_MISSING` | See §A.7 — a warning despite the `E_` prefix |

These do not reach your editor. The language server does not run
`unused_check`, because that check reports by printing to stdout, which
is the server's JSON-RPC channel; see Chapter 35.

## A.15 Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Compile error, or a runtime panic (`zyl_panic` calls `exit(1)`) |
| 139 | Segfault (SIGSEGV) — a compiler bug; please report it |
| 134 | Abort (SIGABRT) — an internal error |

## A.16 Where the Definitions Live

- **Catalog**: `stdlib/compiler/error_codes.zyl` — name, phase, severity
  and default message for every code.
- **Raised by**: the checker that owns the rule —
  `duplicate_check.zyl`, `arity_check.zyl`, `mutability_check.zyl`,
  `exhaustiveness_check.zyl`, `secret_check.zyl`, plus the lexer,
  parser and ICNF lowering.
- **Tested by**: `tests/compile-fail/`, one file per code that must be
  rejected.
- **Specification**: `zyl_specification.txt` §28.
