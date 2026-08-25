<!-- Generated from the ZylError enum in src/error.rs. Regenerate after
     editing error variants (extraction script in git history of this file). -->
# Zyl Compiler Error Index

All compiler diagnostics from `src/error.rs` (`ZylError`), following spec
§28 `E_*` naming. `<value>` marks a formatted diagnostic payload.

| Code | Meaning |
|------|---------|
| `E_ARITY_MISMATCH` | type: function arity mismatch for '<value>' at <value>: expected <value> arguments, found <value> |
| `E_ASSERT_FAIL` | assertion: condition failed - <value> at <value> |
| `E_ATOM_AS_OPERATOR` | parser: atom cannot be used as operator in prefix position at <value> |
| `E_CANNOT_INFER` | type: cannot infer concrete type for generic parameter '<value>' at <value> — no call-site evidence |
| `E_CAPABILITY_LEAK` | capability: TMut leaked across boundary at <value> |
| `E_CIRCULAR_MODULE` | module: circular dependency: <value> |
| `E_CODEGEN` | codegen: <value> |
| `E_CONTRACT_VIOLATION` | contract: contract violation - <value> at <value> |
| `E_DIVISION_BY_ZERO` | numeric: division by zero at <value> |
| `E_DUPLICATE_DEFINITION` | type: duplicate definition of '<value>' at <value>. previously defined at <value> |
| `E_DUPLICATE_IMPL` | trait: duplicate impl of '<value>' for '<value>' at <value> |
| `E_EMPTY_LIST` | parser: empty list is not a valid expression at <value> |
| `E_EXPECTED_EXPRESSION` | parser: expected an expression but found <value> at <value> |
| `E_EXPECTED_RBRACKET` | parser: expected ']' but found <value> at <value> |
| `E_EXPECTED_RCURLY` | parser: expected '}}' but found <value> at <value> |
| `E_EXPECTED_RPAREN` | parser: expected ')' at <value> but found <value> |
| `E_FFI_TIMEOUT` | ffi: call exceeded timeout of <value>ms at <value> |
| `E_FLOAT_OVERFLOW` | lexer: float overflow in literal '<value>' |
| `E_INTEGER_OVERFLOW` | lexer: integer overflow in literal '<value>' |
| `E_INVALID_CAPABILITY` | type: invalid capability usage for '<value>' — <value> at <value> |
| `E_INVALID_CHAR` | lexer: invalid character '<value>' at <value> |
| `E_MACRO_ILLEGAL_ACCESS` | macro: illegal runtime access in macro expansion |
| `E_MACRO_NON_TERMINATION` | macro: expansion loop detected (max depth exceeded) |
| `E_MATCH_NONEXHAUSTIVE` | match: non-exhaustive pattern match at <value> — missing cases: <value> |
| `E_MODULE_NOT_FOUND` | module: module '<value>' not found at '<value>' |
| `E_MUT_CONFLICT` | aliasing: mutable reference conflict at <value> |
| `E_OVERFLOW` | numeric: integer overflow at <value> |
| `E_REGION_ESCAPE` | region: value escapes region constraint at <value> |
| `E_RESERVED_KEYWORD` | parser: reserved keyword '<value>' cannot be used as identifier at <value> |
| `E_RETURN_TYPE_MISMATCH` | type: return type mismatch in '<value>': expected <value>, got <value> at <value> |
| `E_SYMBOL_NOT_EXPORTED` | module: symbol '<value>' not exported by '<value>' |
| `E_TEST_FAILURE` | test: assertion failed - <value> |
| `E_TEST_RUNNER_ERROR` | test: runner error - <value> |
| `E_TRAIT_BOUND_NOT_SATISFIED` | type: unsatisfied trait bound '<value>' : <value> at <value> |
| `E_TRAIT_NOT_DERIVABLE` | trait: cannot derive '<value>' for type '<value>' at <value> |
| `E_TRAIT_NOT_FOUND` | trait: no implementation found for '<value>' |
| `E_TYPE_MISMATCH` | type: type mismatch at <value> — expected <value>, found <value> |
| `E_UNBOUND_VARIABLE` | type: unbound variable '<value>' at <value> |
| `E_UNEXPECTED_EOF` | lexer: unexpected EOF while expecting '<value>' at <value> |
| `E_UNEXPECTED_TOKEN_IN_EXPR` | parser: unexpected token '<value>' in expression context at <value> |
| `E_UNINITIALIZED_USE` | variable: use of uninitialized variable '<value>' at <value> |
| `E_UNKNOWN_GENERIC_PARAM` | type: unknown generic parameter '<value>' at <value> |
| `E_UNKNOWN_TYPE` | type: unknown type '<value>' at <value> |
| `E_UNTERMINATED_STRING` | lexer: unterminated string at <value> |
| `E_USER_ERROR` | runtime: user error - <value> at <value> |

## Guard diagnostics (via E_USER_ERROR)

- `E_MATCH_ARM_COMPLEX` — a match arm combines a constant with 2+ calls in
  one binop, or nests binop chains. Arm bodies must hold a single call or
  a single simple binop; nest sums through helper functions. Raised by the
  Rust bootstrap (ICNF level) and the self-hosted lowering (AST level).
- `E_DUPLICATE_VARIANT` — a variant name is defined by more than one
  deftype; constructor identities would silently break `match`.
- `E_UNBALANCED_PARENS` — paren counts differ across the token stream.
- `E_CODEGEN_BUFFER_FULL` — generated assembly exceeded the 64MB codegen
  text buffer.
