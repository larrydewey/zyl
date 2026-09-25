# Zyl Compiler Error Index

Every diagnostic code the self-hosted compiler, the REPL interpreter and the
runtime know about. The catalog lives in `stdlib/compiler/error_codes.zyl`
(`error-codes`, one `(EC name phase severity message)` per code: 127
entries, 126 distinct codes, `E_OUT_OF_MEMORY` appearing twice); spec §28
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
PANIC: error[E_ARITY_MISMATCH]: `f` called with 1 argument(s), but it takes 2
  --> arity.zyl:2:15
   |
 2 | (defn main () (f 1) 0)
   |               ^
   = help: supply the missing argument(s)
```

The type pass prints each error in the same shape without the `PANIC:`
prefix, then panics once with a summary:

```
error[E_UNBOUND_VARIABLE]: unbound identifier `y`
  --> unbound.zyl:1:25
   |
 1 | (defn main () (print (+ y 1)) 0)
   |                         ^
   = help: define it, or bind it with `let`; ...
PANIC: error[E_UNBOUND_VARIABLE]: the program does not type-check (1 error above)
```

A node with no recorded span (offset < 0, i.e. one a later phase
synthesized) degrades to the header plus the `= help:` line. Names in the
message are shortened from their canonical symbol key
(`local/main@0::mod::f`) to the part after the last `::` (`err-name`).
The checks that currently produce located diagnostics are the balance check
(`E_UNBALANCED_*`, `E_UNTERMINATED_STRING`), the reader in `parser.zyl`
(`E_INVALID_CHAR`, `E_INVALID_ESCAPE`), `duplicate_check.zyl`
(`E_DUPLICATE_DEFINITION`, `E_DUPLICATE_VARIANT`), `arity_check.zyl`
(`E_ARITY_MISMATCH`, `E_MALFORMED_FORM`, `E_FFI_RESTRICTED`,
`E_FFI_TIMEOUT_REQUIRED`, `E_FFI_SYMBOL_REQUIRED`),
`exhaustiveness_check.zyl` (`E_NON_EXHAUSTIVE_MATCH`,
`E_UNREACHABLE_MATCH_ARM`), `expr_inner.zyl` (`E_MALFORMED_PARAMETER`,
`E_NESTED_PATTERN`, `E_REGION_SPEC`, and `E_MALFORMED_FORM` for quoted
data and quasiquote), `macro_expand.zyl`, `derive.zyl`,
`mutability_check.zyl` (`E_MUT_CONFLICT`, `E_CAPABILITY_LEAK`),
`capability_check.zyl` (`E_PKG_CAPABILITY_VIOLATION`), `secret_check.zyl`
(every code, when the offending node has a span), `module_resolver.zyl`
(`E_IMPL_FORBIDDEN`, `E_PKG_FEATURE_NESTED`), `region_inference.zyl`
(`E_REGION_ESCAPE`), the type pass `type_annotate.zyl` (every type error)
and `codegen.zyl` (`E_UNBOUND_VARIABLE`, now only a backstop behind the
type pass).

**Plain diagnostics** are every other check: `zyl_panic` with a string of
the form `CODE: message`, printed as `PANIC: CODE: message` with no
location.

Every error is fatal. Most checks abort the compile with exit status 1 at
the first error. The type pass is the exception: it reports every type
error in the program (`E_TYPE_MISMATCH`, `E_INFINITE_TYPE`,
`E_CANNOT_INFER`, `E_UNBOUND_VARIABLE`, `E_TRAIT_NOT_FOUND`,
`E_FFI_TYPE_NOT_PINNABLE`, `E_MALFORMED_PARAMETER` for a trait written
as a type, and `E_FFI_RESTRICTED` for an `extern` of a runtime entry),
then fails with `error[CODE]: the program does not
type-check (N errors above)`, CODE being the first error's code.
`ZYL_STRICT_TYPES=report` (or `1`) prints the type errors as
`W_TYPE_STRICT` warnings and lets the compile continue; it exists for
counting, not for running an ill-typed program. Warnings are printed
to stderr, located like errors (`warning[CODE]: message`, the
`-->` line, the source line, a caret and a help line) when the node has
a span, and do not change the exit status.

## Catalog

Phase numbers are the ones `error_codes.zyl` assigns: 1 lexer, 2 parser,
3 macro, 4 type, 5 mono, 6 region, 7 ICNF, 8 codegen, 9 module/package
resolution, 10 runtime, 11 test, 12 trait, 13 capability, 14 contract,
15 numeric, 16 FFI, 17 match, 19 package (the catalog header also
reserves 18 for miscellaneous and user codes; no entry uses it). Severity is 1 (error) unless noted.
"Catalog only" means no active module raises the code today. §28 marks the
codes spec §28 lists by name.

### Lexer (phase 1)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_BYTE_VALUE_OOB` | lexer: byte literal out of range 0-255 | `expr_inner.zyl` (`(byte N)` forms) |
| `E_FLOAT_OVERFLOW` | lexer: float overflow in literal L at S | catalog only |
| `E_INTEGER_OVERFLOW` | lexer: integer overflow in literal L at S | catalog only |
| `E_INVALID_ESCAPE` (§28) | lexer: invalid escape sequence in a string literal at S | `parser.zyl` (located): a backslash escape other than `\n`, `\t`, `\r`, `\0`, `\"`, `\\`, `\e` and `\xNN`, checked before the string is decoded |
| `E_INVALID_CHAR` | lexer: invalid character C at S | `parser.zyl` (located): a character that begins no token, such as `#`, `$` or a lone `@` outside a string or comment (`'`, `` ` ``, `,` and `,@` are the quote, quasiquote, unquote and splice tokens) |
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
| `E_MALFORMED_PARAMETER` | parser: P is not a parameter at S - write a name, or (name Type) | `expr_inner.zyl` (located): a parameter that is not a name or `(name Type)`, a colon annotation `(a : Int)`, or `&rest` in a function's parameter list; `type_annotate.zyl` (located, `ta-trait-as-type`): a trait name written in type position, such as `(a Ord)` or the §6.1 bound spelling `((T : Ord) x)` (`Secret`, also the secret-value annotation, is exempt); `macro_expand.zyl` (located, `me-check-rest`): a macro's `&rest` not followed by exactly one name at the end of its parameter list |
| `E_MALFORMED_FORM` (§28) | parser: special form F has arguments of the wrong shape at S | `arity_check.zyl` (located): a special form whose parser rejected its shape (`expr_inner.zyl` builds an `EUnknown` node for it), such as `(let x 1)` with no body, a trait method whose parameters are not a list, `test` or `defmacro` with more than one body, a malformed `extern`, or `(quote)`/`(quote a b)`. Such a form used to compile to the constant 0. `expr_inner.zyl` (located, `quote-name-fail`): a name inside quoted data, `'(1 x)`, which has no value since there is no symbol type; `expr_inner.zyl` (located, `parse-quasiquote`): a malformed quasiquote (a name outside an unquote, a nested quasiquote, a `,@e` that is not a list element, an unquote or splice without one operand); `arity_check.zyl` (located): a `,` or `,@` outside a quasiquote and a macro template; `macro_expand.zyl` (located): in a template, a `,@` into a form that takes a fixed number of expressions (`me-kids`), or of anything but the `&rest` parameter (`me-splice-of`); `parser.zyl` (located, `prefix-alone-fail`): a quote or unquote with no form after it, as in `{ a, }`; `module_resolver.zyl` (located, `mr-sym-ident`): a non-name in an import list, as in `{ a, b }`; `expr_inner.zyl` (located, `if-extra-fail`): a form after an `if`'s else branch |
| `E_RESERVED_KEYWORD` (§28) | parser: reserved keyword K cannot be used as identifier at S | catalog only |
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
| `E_MACRO_ILLEGAL_ACCESS` (§28) | macro: illegal runtime access in macro expansion | `macro_expand.zyl` (located: a `defmacro` that is not at top level) |
| `E_MACRO_NON_TERMINATION` (§28) | macro: expansion loop detected (max depth exceeded) | `macro_expand.zyl` (located: a macro called during its own expansion, or a chain of 256 expansions) |

### Type (phases 4 and 5)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_ARITY_MISMATCH` | type: function arity mismatch for F at S: expected E arguments, found G | `arity_check.zyl` (located; also an `ffi-call` with more than 16 arguments), `icnf.zyl` (also arithmetic with no operand, or one operand other than `(- x)`, `(+ x)`, `(* x)`), `expr_inner.zyl` (special forms), `macro_expand.zyl` (a macro call's argument count, or too few before `&rest`), REPL interpreter |
| `E_ATOMIC_ABA` | region: atomic CAS on non-Pin memory is forbidden | catalog only |
| `E_BYTEBUF_NOT_PIN` | type: bytebuf-ptr requires Pin region | catalog only |
| `E_STACK_BYTEBUF_RETURN` | type: Stack ByteBuf cannot be returned | catalog only (a returned Stack bytebuf is `E_REGION_ESCAPE`) |
| `E_GLOBAL_BYTEBUF_MUT` | type: Global ByteBuf must be immutable | catalog only |
| `E_DUPLICATE_DEFINITION` | type: duplicate definition of N at S. previously defined at P | `duplicate_check.zyl` (located at the second definition) |
| `E_DUPLICATE_VARIANT` | type: duplicate variant V in deftype at S | `duplicate_check.zyl` (located: a program type declaring a prelude constructor name, `Some`, `None`, `Ok`, `Err`, `Cons` or `Nil`, which the standard library's unqualified uses would resolve to; only the standard library may declare them), `icnf.zyl` (a variant name defined twice in one `deftype`) |
| `E_RETURN_TYPE_MISMATCH` | type: return type mismatch in F - expected T, got U at S | catalog only |
| `E_TYPE_MISMATCH` | type: type mismatch at S - expected E, found F | `type_annotate.zyl` (located): every unification failure, labelled with a declared parameter or field type where there is one; also a non-literal `file-open` mode, a field a known struct lacks, list-literal elements of different types, a non-Int byte offset, length or stored value, the wrong kind of byte handle (`bytebuf-len` of a slice), and a non-String `file-write` operand |
| `E_UNBOUND_VARIABLE` | type: unbound variable V at S | `type_annotate.zyl` (located: an identifier or called function defined nowhere), `macro_expand.zyl`, `codegen.zyl` (backstop), REPL interpreter |
| `E_UNKNOWN_GENERIC_PARAM` | type: unknown generic parameter G at S | catalog only |
| `E_UNKNOWN_TYPE` | type: unknown type T at S | `type_annotate.zyl` (a lowercase field type in `deftype`), located |
| `E_CANNOT_INFER` (§28, phase 5) | type: the program does not determine a type at S (an unresolved trait receiver, an ambiguous field, an undeclared foreign symbol) | `type_annotate.zyl` (located): a type the program does not determine, such as an `ffi-call` to a foreign symbol with no `extern` or to a runtime symbol missing from `ffi_sigs.zyl`, a trait call whose receiver type stays unknown, a `struct-get` whose record type is still unknown when several structs have the field, a byte load or store whose handle is still unknown after its function group (`ta-bytes-ambiguous`), or a function that would need more than 256 specialized instances; `icnf.zyl` (backstop for an unresolved trait call) |
| `W_TYPE_STRICT` (phase 5, severity 1 in the catalog, printed as a warning) | type: a type error reported as a warning under ZYL_STRICT_TYPES=report at S | `type_annotate.zyl`: each type error, under `ZYL_STRICT_TYPES=report` |
| `E_INFINITE_TYPE` (§28) | type: a type would have to contain itself at S (occurs check) | `type_annotate.zyl` (located) |

The type pass is strict (spec §4.8-§4.10): `(+ 1 "a")` and `(+ 1 1.5)`
are `E_TYPE_MISMATCH`. Its messages are its own, not the catalog text:
``cannot unify T with U``, or ``mismatched types: expected `T`, found `U` ``
for an argument that clashes with a declared parameter or field type.
`E_RETURN_TYPE_MISMATCH` is never raised; a wrong return type is an
ordinary unification failure.

### Region and ICNF (phases 6 and 7)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_REGION_ESCAPE` (§28) | region: value escapes region constraint at S | `region_inference.zyl` (located): a `(bytebuf Stack N)` that is returned, stored, sent or passed to code that may keep it, or a value allocated inside `with-region` that outlives it |
| `E_REGION_SPEC` (§28) | region: malformed with-region specification at S | `expr_inner.zyl` (`parse-with-region`, located): unknown kind or option, block not a multiple of 4096 or above 64 MiB, alignment not a power of two from 8 to 4096 |
| `E_UNINITIALIZED_USE` (§28) | variable: use of uninitialized variable V at S | catalog only |
| `E_MATCH_ARM_COMPLEX` | match: arm combines a constant with multiple calls - bind to lets first | `icnf.zyl`, located |
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
| `E_ASSERT_FAIL` (§28) | assertion: condition failed - M at S | catalog only (a failed assertion panics with its own message, see below) |
| `E_BYTE_OOB` | runtime: byte offset out of bounds | catalog only |
| `E_BYTEBUF_CAP_EXCEEDED` | runtime: bytebuf append exceeds capacity | catalog only (the runtime fails closed past capacity but prints no code) |
| `E_BYTEBUF_INVALID` | runtime: bytebuf magic tag mismatch | catalog only |
| `E_BYTEBUF_OVERLAP` | runtime: bytebuf append overlapping slice | catalog only |
| `E_LIST_NTH_OOB` | runtime: list-nth index out of bounds at S | catalog only |
| `E_NULL_POINTER` | runtime: null pointer dereference | catalog only |
| `E_REGION_EXHAUSTED` (§28) | runtime: a with-region region ran out of its fixed size or limit | `actor_runtime.c` (`E_REGION_EXHAUSTED: <kind> region of N bytes is full`; catchable with `try`; deterministic for a given request sequence) |
| `E_INDEX_OUT_OF_BOUNDS` (§28) | runtime: index outside a word array | `actor_runtime.c` (a vector index or pop, a word array or Array index, a full string buffer), `collections/vec.zyl`, `collections/slice.zyl`, `text/view.zyl` (an index or range outside the value) |
| `E_INTERP_TAG` | runtime: the checking interpreter found an operand of the wrong tag at S (a type-checker bug) | `stdlib/repl/interp.zyl`: under `ZYL_INTERP_CHECK=1`, an operator whose operand tags break its rule, or a condition that is not 0 or 1 |
| `E_OUT_OF_MEMORY` | runtime: memory budget exhausted - raise or remove it with ZYL_MAX_MEMORY | `actor_runtime.c` (`PANIC: error[E_OUT_OF_MEMORY]: ...`); a second catalog entry reads "runtime: out of memory" |
| `E_USER_ERROR` (§28) | runtime: user error - M at S | catalog only |

What a compiled program prints at runtime today: `(error "boom")` prints
`PANIC: boom` and exits 1; outside a `test`, a failed `assert-true` or
`assert-equal` prints `PANIC: assert-true failed` or `PANIC: assert-equal
failed` and exits 1 (inside a `test`, the harness reports the test as
`FAIL` and goes on).
Neither carries the catalog code. A false `(assert c msg)` panics with
`msg`, or `assert failed` without one. The condition of `assert`,
`assert-true` and `assert-false` must be a Bool, and the two sides of
`assert-equal` must have one type (spec §4.9).

### Test (phase 11)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_TEST_FAILURE` (§28) | test: assertion failed - M | catalog only |
| `E_TEST_RUNNER_ERROR` (§28) | test: runner error - M | catalog only |

### Traits (phase 12)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_DUPLICATE_IMPL` (§28) | trait: duplicate impl of T for U at S | `derive.zyl` (located: two written impls of one trait for one type) |
| `E_TRAIT_BOUND_NOT_SATISFIED` | type: unsatisfied trait bound T : U at S | catalog only |
| `E_IMPL_FORBIDDEN` | trait: impl of T for U is forbidden by an impl-not declaration | `module_resolver.zyl` (located): an impl of a trait for a type that an `(impl-not Trait Target)` declaration forbids, directly or because the type implements `Target`; `secret_check.zyl` (located): an impl of a protected trait whose result is derived from a value the declaration protects |
| `E_TRAIT_NOT_DERIVABLE` (§28) | trait: cannot derive T for type U at S | `derive.zyl` (located: a trait outside Show, Debug, Eq, Ord, Hash, Clone, a field whose type lacks the trait, or Eq/Ord/Hash/Clone on a type with a Secret field) |
| `E_TRAIT_NOT_FOUND` (§28) | trait: no implementation found for T at S | `type_annotate.zyl` (located): a trait call on a concrete receiver type with no impl, a dot method no trait declares or none implements for the receiver, or one declared by several traits |
| `E_PKG_ORPHAN_IMPL` (§28) | trait: impl of T for U where neither the trait nor the type is local to N | `module_resolver.zyl` |

### Capabilities and secrets (phase 13)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_CAPABILITY_LEAK` (§28) | capability: TMut leaked across boundary at S | `mutability_check.zyl` (located: a spawned closure that captures a `let-mut` variable, or a message that references one) |
| `E_INVALID_CAPABILITY` | type: invalid capability usage for F - M at S | `mutability_check.zyl` (a closure passed to `ffi-call`) |
| `E_MUT_CONFLICT` (§28) | aliasing: mutable reference conflict at S | `mutability_check.zyl` (located: `set!` on a non-`let-mut` binding, or on a `let-mut` captured by a closure), `expr_inner.zyl` (a `set!` target that is not a plain name, such as a field) |
| `E_CT_VIOLATION` | constant-time: secret-dependent M at S - branches, memory indices and divisions must not depend on a Secret value | `secret_check.zyl` (located) |
| `E_SECRET_ESCAPE` | secret: Secret value escapes through M at S | `secret_check.zyl` (located) |
| `E_SECRET_DEBUG` | secret: Secret value reaches a debug/print sink at S | `secret_check.zyl` (located; also a `Show` impl whose text is derived from a Secret) |
| `E_ZEROIZE_MISSING` (severity 2, warning) | secret: function F takes a Secret parameter but never zeroizes it | `secret_check.zyl` |
| `E_PKG_CAPABILITY_VIOLATION` (§28) | capability: package N uses M without declaring the C capability | `capability_check.zyl` (located), `cli.zyl` |
| `E_PKG_CAPABILITY_GROWTH` (§28) | capability: capability closure grew under --locked: C | `capability_check.zyl`, `mvs.zyl` |

`E_ZEROIZE_MISSING` fires when a function consumes a `Secret` parameter into
a public result and never calls `zeroize`/`zeroize-bytes` on it. It is a
warning because erasure can legitimately live one frame up;
`secret_check.zyl` exempts secret-returning functions and the declassifiers
themselves.

### Contracts, numeric, FFI, match (phases 14 to 17)

| Code | Catalog message | Raised by |
|------|-----------------|-----------|
| `E_CONTRACT_VIOLATION` (§28) | contract: contract violation - M at S | `expr_inner.zyl` (a failed `requires`/`ensures`/`invariant` check panics with `E_CONTRACT_VIOLATION: <what> failed: <condition>`, at run time) |
| `E_DIVISION_BY_ZERO` (§28) | numeric: division by zero at S | REPL interpreter only; a compiled `(/ 1 0)` dies with SIGFPE |
| `E_OVERFLOW` (§28) | numeric: integer overflow at S | catalog only |
| `E_FFI_PIN_REQUIRED` | ffi: Secret argument to F must be handed over through ffi-pin (Pin region) at S | `secret_check.zyl` (located) |
| `E_FFI_TYPE_NOT_PINNABLE` | ffi: value has type T which is not FFI_Pinnable | `type_annotate.zyl` (located: `ffi-pin` of a function) |
| `E_FFI_RESTRICTED` (§28) | ffi: raw runtime entry F may only be called by the standard library at S | `arity_check.zyl` (located, `ffi-check-raw`): an `ffi-call` outside the standard library naming an entry in `ffi-raw-p` (`ffi_sigs.zyl`), one that reads raw memory or reinterprets a machine word, or trusts bounds its caller checked (the string-view accessors `zyl_view_byte`, `zyl_view_cmp`, `zyl_view_find`, `zyl_view_copy`); `type_annotate.zyl` (located): an `ffi-call` to a symbol the runtime exports (`zyl_runtime_export_p`) that the program also declares with `extern`, since runtime entries are typed only by `ffi_sigs.zyl` |
| `E_FFI_TIMEOUT` (§28) | ffi: call exceeded timeout of M ms at S | `actor_runtime.c` (`zyl_ffi_timed`), at run time: ``E_FFI_TIMEOUT: ffi call `sym` exceeded its timeout of M ms`` |
| `E_FFI_TIMEOUT_REQUIRED` (§28) | ffi: ffi-call must end with a positive integer literal timeout in milliseconds at S | `arity_check.zyl` (`ffi-check-call`, located, with a help line) |
| `E_FFI_SYMBOL_REQUIRED` (§28) | ffi: ffi-call must name its C symbol with a string literal at S | `arity_check.zyl` (`ffi-check-call`, located) |
| `E_NESTED_PATTERN` (§28) | match: nested pattern in a constructor arm at S | `expr_inner.zyl` (located): a constructor arm whose field position holds anything but a plain name, including a constructor used as a binder, `(Some Nil ...)` or `(Node v Leaf v)` for the program's own `Leaf` (`qualify.zyl` qualifies a capitalized binder that names a known symbol) |
| `E_MATCH_NONEXHAUSTIVE` (§28) | match: non-exhaustive pattern match at S - missing cases: M | `icnf.zyl` (unknown variant in an arm; residual non-exhaustive match), `expr_inner.zyl` (literal-pattern match without a final `_`), REPL interpreter |

The main compile-time exhaustiveness check (`exhaustiveness_check.zyl`)
reports a missing variant as `E_NON_EXHAUSTIVE_MATCH`, not the spec's
`E_MATCH_NONEXHAUSTIVE`; see the next section.

### Package manifest, lock and registry (phase 19)

All raised by the package modules named; all are §28 codes except
`E_PKG_VERSION_EXISTS` and `E_PKG_FEATURE_NESTED`.

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
| `E_PKG_VERSION_EXISTS` | package: version V of N is already in the index | `index.zyl` (`zyl publish` of a version already published; a published version is immutable) |
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
| `E_PKG_FEATURE_NESTED` | package: feature-gate is valid at top level only | `module_resolver.zyl` (located: a `feature-gate` inside another form) |

## Codes raised but not in the catalog

| Code | Severity | Raised by | Meaning |
|------|----------|-----------|---------|
| `E_NON_EXHAUSTIVE_MATCH` | error | `exhaustiveness_check.zyl` (located) | a `match` over a `deftype` does not cover some variant and has no `_` arm |
| `E_UNREACHABLE_MATCH_ARM` | error | `exhaustiveness_check.zyl` (located) | an arm after a catch-all, or a repeated constructor arm |
| `E_DUPLICATE_PARAMETER` | error | `unused_check.zyl` | two parameters of one `defn`/`fn`/`lambda` share a name |
| `W_UNUSED_FUNCTION` | warning | `unused_check.zyl` | catalogued, not raised: the check cannot yet tell the program's functions from the standard library's |
| `W_UNUSED_PARAMETER` | warning | `unused_check.zyl` | a parameter is never used (`_` and `_`-prefixed names are exempt) |
| `W_UNUSED_VARIABLE` | warning | `unused_check.zyl` | a `let`/`let-mut`/`for` binding is never used |
| `W_SHADOWED_BINDING` | warning | `unused_check.zyl` | a binding shadows an outer binding of the same name |
| `E_UNDEFINED_FUNCTION` | error | `stdlib/repl/interp.zyl` | a call names no function (the compiled path reports `E_UNBOUND_VARIABLE` from the type pass) |
| `E_NOT_CALLABLE` | error | `stdlib/repl/interp.zyl` | a call's head is not a function or closure |
| `E_UNSUPPORTED_INTERPRETED` | error | `stdlib/repl/interp.zyl` | spawning an actor, which needs a native entry point; compile the program instead |
| `E_FFI_SYMBOL_NOT_FOUND` | error | `stdlib/repl/interp.zyl`, `actor_runtime.c` | an `ffi-call` names a symbol the REPL process does not export |
| `E_NO_MAIN` | error | `stdlib/repl/interp.zyl` | the interpreted program defines no `main` (`zyl eval`) |
| `E_INTERNAL` | error | `stdlib/repl/eval.zyl` | a REPL entry's wrapper function did not survive lowering (an internal fault) |

The REPL's interpreter errors are reported to the prompt and do not end the
session; see `docs/repl.md`.
