# Appendix A: Error Codes Reference

Every code the compiler, runtime and REPL can report. The catalog of
record is `stdlib/compiler/error_codes.zyl`: one entry per code, giving
its name, the phase that owns it, a severity (1 error, 2 warning) and a
default message. This appendix mirrors that catalog, grouped by phase,
and cross-checks it against spec §28 and against the code that
actually raises each error.

Not every catalogued code is raised by today's compiler, and a few codes
are raised without being catalogued. Both cases are marked in the
tables below and collected in §A.17, so you can tell a code you will see
from one that exists only on paper.

A diagnostic's code also reaches your editor: the language server puts
it in the LSP `code` field, so you can filter or group on it without
matching message text (Chapter 35).

## A.1 How a Diagnostic Looks

A check that knows where the problem is prints a located diagnostic:

```text
error[E_MALFORMED_PARAMETER]: `(struct-get ...)` is not a parameter
  --> tests/regression/structs.zyl:16:20
   |
16 | (defn _s-get-x (p (struct-get p "x"))
   |                   ^
   = help: a missing `)` earlier on the line puts the body in the list
```

A diagnostic can point at a second place with a labelled span. The
mutability and capability checks use one for the binding or definition
involved:

```text
error[E_MUT_CONFLICT]: set! target `x` is not a let-mut binding in scope
  --> prog.zyl:3:5
   |
 3 |     (set! x 2)
   |     ^
 1 | (let x 1
   | - bound here by `let`, which is immutable (TCap)
   = help: only a let-mut binding is TMut and may be assigned; declare it with `let-mut`
```

A label in another file is introduced by a `::: file:line:col` line, and
one without a recorded position prints as `= note:`. A name that is not
defined gets up to three close names in scope (`= help: did you mean
`count`?`), Zyl's spelling of a name another Lisp uses (`string-append`
is `str-concat`), or the `(use ...)` line for the standard-library
module that defines it. A very
long source line is shown as a window of about 120 bytes around the
column, with `...` where it is cut.

Warnings use the same shape with `warning[CODE]`, and never stop a
build.

A check without a source position panics with the code at the front of
the message, for example `PANIC: E_INVALID_CAPABILITY: ...`. Every check
but one aborts on its first problem, so those report one error at a
time. The exception is the type pass: it reports every type error in
the program (`E_TYPE_MISMATCH`, `E_INFINITE_TYPE`, `E_CANNOT_INFER`,
`E_UNBOUND_VARIABLE`, `E_UNKNOWN_TYPE`, `E_TRAIT_NOT_FOUND`,
`E_FFI_TYPE_NOT_PINNABLE`, and `E_FFI_RESTRICTED` for an `extern` of a
runtime entry), then stops.
After more than one error the last line is a count, with no code:

```text
3 errors; fix the first one first
```

After a single error nothing follows it. Each name that is not defined is
reported once, at its first use, and nothing that depends on it is
reported as a type error.

Setting `ZYL_STRICT_TYPES=report` turns those errors into
`W_TYPE_STRICT` warnings (§A.16) so you can count what is left while
porting old code. The compile then goes on, but it is a counting tool:
no setting makes the compiler accept an ill-typed program for real.

### Machine-readable output

`zyl <file.zyl> --error-format=json` prints each diagnostic, warnings
included, as one JSON object per line on stderr instead:

```json
{"severity":"error","code":"E_UNBOUND_VARIABLE","message":"`cont` is not defined","file":"prog.zyl","line":1,"column":45,"labels":[],"help":"did you mean `count`, `const` or `Cons`?"}
```

`labels` holds `{"message", "file", "line", "column"}` for each
secondary span. An unknown position is `"file":""`, `"line":0`,
`"column":0`; a panic that carries no location is wrapped the same way,
with its code split off the front of the message.

## A.2 Lexing (phase 1)

| Code | Cause |
|---|---|
| `E_UNTERMINATED_STRING` | A string literal reached end of input with no closing quote; located at the quote |
| `E_BYTE_VALUE_OOB` | A `byte` literal outside 0..255, or a non-integer argument to `byte` |
| `E_INVALID_ESCAPE` | A backslash escape in a string literal that the lexer does not know |
| `E_INVALID_CHAR` | A character that cannot begin any token, such as `#`, `$` or a lone `@` outside a string or comment, located at that byte. (`'`, `` ` ``, `,` and `,@` are the quote, quasiquote, unquote and splice tokens.) |
| `E_INTEGER_OVERFLOW` | An integer literal too large for `Int`. |

## A.3 Parsing and S-Expression Balance (phase 2)

| Code | Cause |
|---|---|
| `E_UNBALANCED_UNCLOSED` | An opener never reached its matching closer, or an opener in column 1 inside a still-open form (spec §1.6) |
| `E_UNBALANCED_UNEXPECTED_CLOSE` | A closing delimiter with no opener open |
| `E_UNBALANCED_MISMATCHED_BRACKET` | A closer that does not match its opener |
| `E_MALFORMED_PARAMETER` | A parameter that is neither a name nor `(name Type)` — usually a missing `)` |
| `E_MALFORMED_FORM` | A special form whose arguments do not have the shape it requires, such as `(if c)` with no branches, or `(quote a b)`; also a name inside quoted data, `'(1 x)`, since there is no symbol type, and the same in quasiquoted data outside an unquote, `` `(1 x) ``; a quasiquote inside a quasiquote; a `,` or `,@` outside a quasiquote and a macro template; and in a template, a `,@` where a form takes a fixed number of expressions, or of anything but the `&rest` parameter. Such a form used to compile to the constant 0, which let some tests pass without testing anything. Raised by `arity_check.zyl`. |
| `E_UNEXPECTED_TOKEN_IN_EXPR` | A token that cannot appear in expression position |
| `E_RESERVED_KEYWORD` | A reserved keyword (spec §1.3) as the name a definition introduces, or `make-S` for a struct `S`; located at the name |

The balance check (`sexp_balance.zyl`) runs before parsing and is what
an editor shows while you are still typing. Its diagnostics carry a
fix-it hint, which the language server turns into a quick-fix code
action. The same check runs on its own as `zyl balance [file | dir ...]`,
and it also enforces the layout rule of spec §1.6: an opener in column 1
while a form is still open is `E_UNBALANCED_UNCLOSED` at that form, which
catches a missing closer that an extra one elsewhere balances.

Spec §1.3.1 makes every keyword in §1.3 reserved as an identifier, and `compiler/reserved_check.zyl` enforces it outside the standard library and the runtime.

## A.4 Macro Expansion (phase 3)

| Code | Cause |
|---|---|
| `E_MACRO_NON_TERMINATION` | A macro was called while its own expansion was in progress (directly or through other macros), or expansion nested more than 256 deep. |
| `E_MACRO_ILLEGAL_ACCESS` | A `defmacro` inside a function body or other form, where its template could name run-time values. |

Macro expansion also reports `E_ARITY_MISMATCH` (wrong argument count, or too few before `&rest`), `E_DUPLICATE_DEFINITION` (a macro name defined twice, or shared with a function in the same file), `E_MALFORMED_PARAMETER` (a non-identifier parameter, a `&rest` not followed by exactly one name at the end of the list, or a non-identifier argument where the template needs a name) and `E_UNBOUND_VARIABLE` (a template naming a call-site local, which hygiene forbids it to capture).

## A.5 Types, Names and Arity (phases 4 and 5)

| Code | Cause |
|---|---|
| `E_UNBOUND_VARIABLE` | A name with no binding. The type pass reports each such name once, at its first use, with a "did you mean" suggestion or the `(use ...)` line that imports it |
| `E_ARITY_MISMATCH` | A call with the wrong number of arguments, a malformed byte, load, store or atomic form, or `/`, `%` or a bitwise operator given one operand (`operator 3 needs two operands`) |
| `E_DUPLICATE_DEFINITION` | A name defined more than once at top level |
| `E_DUPLICATE_VARIANT` | A variant name repeated within one `deftype`, or a program type that reuses a prelude constructor name (`Some`, `None`, `Ok`, `Err`, `Cons`, `Nil`) — the standard library's unqualified uses of those names would otherwise resolve to it |
| `E_DUPLICATE_PARAMETER` | A parameter name repeated in one signature (`_` and `_`-prefixed names may repeat). *Raised by `unused_check.zyl`; not in the catalog.* |
| `E_TYPE_MISMATCH` | Two types that must be equal are not: an `Int` condition where `Bool` is required, `Int` and `Float` mixed in arithmetic, a `String` passed where a field or parameter wants an `Int`, an `Int` given to `actor-wait` where an `Actor` is required, a value received from a channel used at a different type than was sent, a `Float` in an `extern` signature, a `file-open` mode that is not a literal, a list literal with elements of two types, a non-`Int` byte offset, a slice where a `ByteBuf` is required, an `Int` given to `file-write` as its data. Raised by `type_annotate.zyl` for every unification failure, with both types in the message |
| `E_INFINITE_TYPE` | A type that would have to contain itself, found by the occurs check, such as a function applied to itself, `(x x)` |
| `E_UNKNOWN_TYPE` | A lowercase name as a field type in `deftype`: it is neither a type nor a type parameter (those are uppercase) |
| `E_CANNOT_INFER` | The type pass has no type for an expression: an `ffi-call` to a foreign symbol with no `(extern ...)` declaration, a runtime entry with no signature, a trait call whose receiver type never resolves, or a byte load or store whose handle may be a `ByteBuf` or a `ByteSlice` and nothing decides which (annotate it: `((b ByteBuf))`) |

## A.6 Regions (phase 6) and Byte Buffers

| Code | Cause |
|---|---|
| `E_REGION_ESCAPE` | A value outlives the region it was allocated in: a `(bytebuf Stack N)` that is returned, stored, sent or passed to code that may keep it, or a value allocated inside `with-region` that reaches the body's result or anything longer-lived. Located at the allocation where one is known. |
| `E_REGION_SPEC` | A malformed `with-region` spec: an unknown kind (only `arena` and `fixed` exist), an arena block size that is not a multiple of 4096 or exceeds 64 MiB, or an alignment that is not a power of two from 8 to 4096. Located. |

Region inference classifies every allocation as belonging to the
current call's frame region, the caller's result region, or the heap,
and reclaims the regions on return. `E_REGION_ESCAPE` is reported only
for explicit region choices — a Stack bytebuf and `with-region` — since
an inferred placement is always one the value cannot escape (Chapter
16).

## A.7 ICNF Lowering and Code Generation (phases 7 and 8)

| Code | Cause |
|---|---|
| `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN` | Top-level statements, or top-level `test`/`run-tests` forms, alongside an explicit `(defn main ...)` |
| `E_MATCH_ARM_COMPLEX` | An arm body combining a constant with several calls — bind the calls to `let`s first |
| `E_CODEGEN_BUFFER_FULL` | The generated assembly exceeded the code-generation buffer |
| `E_CODEGEN_BUFFER_LIMIT` | A bounded buffer append went past its limit. |

## A.8 Modules and Packages (phase 9)

| Code | Cause |
|---|---|
| `E_MODULE_NOT_FOUND` | A `use` path that does not resolve |
| `E_MODULE_CYCLE` | The module graph within one package is not a DAG |
| `E_PKG_CYCLE` | The package dependency graph is not a DAG |
| `E_PKG_VERSION_CONFLICT` | A requirement cannot be satisfied within one major version |
| `E_PKG_PRIVATE_SYMBOL` | An imported symbol that is not `pub` |
| `E_PKG_UNKNOWN_SYMBOL` | An imported symbol that does not exist in that module |
| `E_PKG_UNKNOWN_MODULE` | A module path that does not exist in that package |
| `E_PKG_UNDECLARED_DEP` | A `use` naming a package absent from the manifest |
| `E_PKG_RESERVED_MODULE` | A module named `unsafe` |

## A.9 Runtime (phase 10)

| Code | Cause |
|---|---|
| `E_OUT_OF_MEMORY` | The memory budget is exhausted. Raise or remove it with `ZYL_MAX_MEMORY` (a byte count; `0` disables it). *Listed twice in the catalog, with two messages.* |
| `E_REGION_EXHAUSTED` | A `with-region` scope ran out: a `fixed` region's `:size` or an `arena`'s `:limit` was exceeded. Catchable with `try`, and deterministic: it depends only on the sequence of allocation requests. Enforced in compiled code only; the REPL interpreter ignores region limits. |
| `E_INDEX_OUT_OF_BOUNDS` | An index outside a vector or word array |
| `E_CHANNEL_NOT_OWNER` | `chan-send` or `chan-recv` on an endpoint the running actor does not own (Chapter 9, §9.4) |
| `E_CHANNEL_CLOSED` | `chan-recv` on a channel whose sender has finished and whose buffer is empty. Catchable with `try` |
| `E_CHANNEL_CAPACITY` | `(chan n)` with `n` outside 1..16777216 |
| `E_DEADLOCK` | Every live actor, `main` included, is blocked on a channel or a join. Ends the process after emitting the actors' buffered output |
| `E_ACTOR_LIMIT` | A 1025th `spawn`: at most 1024 actors per program |
| `E_INTERP_TAG` | The REPL interpreter's checking mode (`ZYL_INTERP_CHECK=1`) found an operand of the wrong tag, or a condition that is not 0 or 1. Such a program type-checked, so this is a type-checker bug; the interpreter regression tests run in this mode |

## A.10 Testing (phase 11)

| Code | Cause |
|---|---|

## A.11 Traits (phase 12)

| Code | Cause |
|---|---|
| `E_PKG_ORPHAN_IMPL` | An `impl` where neither the trait nor the type is local to the package |
| `E_TRAIT_NOT_FOUND` | A trait call, or a dot method call, whose receiver type is known and has no impl of the trait, located at the call |
| `E_IMPL_FORBIDDEN` | An `impl` or `derive` that an `(impl-not Trait Target)` declaration forbids, or an impl of that trait whose result is derived from a protected value (Chapter 20). |
| `E_TRAIT_NOT_DERIVABLE` | `derive` of a trait that is not derivable, or whose field requirement fails: a field type without the trait, or a `Secret` field under `Eq`/`Ord`/`Hash`. |
| `E_DUPLICATE_IMPL` | Two implementations of one trait for one type, counting impls and derives |

## A.12 Capabilities, Aliasing and Secrets (phase 13)

| Code | Cause |
|---|---|
| `E_MUT_CONFLICT` | `set!` on a name that is not a `let-mut` binding in scope, on a `let-mut` of an enclosing scope from inside a closure (captures are by value), or on anything other than a plain name — direct field mutation included |
| `E_CAPABILITY_LEAK` | A spawned closure or a value sent with `chan-send` refers to a `let-mut` (`TMut`) variable of the enclosing scope |
| `E_INVALID_CAPABILITY` | A closure written inline as an `ffi-call` argument |
| `E_CT_VIOLATION` | A `Secret` steered a branch, indexed memory, or went through a divider |
| `E_SECRET_ESCAPE` | A `Secret` reached `spawn`, `chan-send` or `file-write` |
| `E_SECRET_DEBUG` | A `Secret` reached `print` |
| `E_ZEROIZE_MISSING` | *(warning, severity 2)* A function takes a `Secret` parameter and never zeroizes it |
| `E_PKG_CAPABILITY_VIOLATION` | A package uses a construct, or a stdlib module, without declaring the capability it needs (§31.9) |
| `E_PKG_CAPABILITY_GROWTH` | The capability closure grew under `--locked` |

Chapter 17 covers the aliasing rules, Chapter 33 the `Secret` checks and
Chapter 25 package capabilities.

## A.13 Contracts, Numerics and Matching (phases 14, 15 and 17)

| Code | Cause |
|---|---|
| `E_MATCH_NONEXHAUSTIVE` | A `match` missing a variant, an unknown variant in an arm, or a literal-pattern match with no trailing `_` arm. Raised during parsing and lowering. |
| `E_NON_EXHAUSTIVE_MATCH` | A `match` that does not cover every variant of its ADT. *Raised by `exhaustiveness_check.zyl`; not in the catalog.* |
| `E_UNREACHABLE_MATCH_ARM` | An arm that no value can reach: a catch-all that is not last, or a repeated constructor. *Not in the catalog.* |
| `E_NESTED_PATTERN` | A constructor arm whose field is itself a pattern, such as `(Some (Pair a b) ...)`. Bind the field to a name and match it inside the arm body. |
| `E_DIVISION_BY_ZERO` | Integer division or remainder by zero. *Raised only by the REPL's ICNF interpreter. Compiled code does not check: the process dies with SIGFPE (exit status 136), which `try` cannot catch.* |
| `E_OVERFLOW` | Checked integer overflow. *Catalogued only.* |
| `E_CONTRACT_VIOLATION` | A `requires`, `ensures` or `invariant` clause failed at run time; the message names the clause and its function. Catchable with `try`. |

Exhaustiveness is a compile-time error, not a warning. `_` is the
catch-all pattern; it may repeat, and it must be the last arm.

## A.14 FFI (phase 16)

| Code | Cause |
|---|---|
| `E_FFI_PIN_REQUIRED` | A `Secret` argument crossed the FFI boundary without `ffi-pin` |
| `E_FFI_TYPE_NOT_PINNABLE` | `ffi-pin` of a function, located at the operand |
| `E_FFI_TIMEOUT` | A foreign call did not return within its timeout. Raised at run time; catchable with `try` and matchable with `recover` |
| `E_FFI_TIMEOUT_REQUIRED` | An `ffi-call` does not end with a positive integer literal timeout in milliseconds |
| `E_FFI_SYMBOL_REQUIRED` | An `ffi-call` does not name its C symbol with a string literal |
| `E_FFI_RESTRICTED` | A raw runtime entry that only the standard library may call, called from user code (for example `zyl_word_load`, or `zyl_view_byte`, which trusts bounds `text/view` checked); or an `extern` for a runtime (`zyl_*`) entry, whose type comes from the compiler's signature table |

An `ffi-call` to a foreign C function needs an `(extern "sym" (T ...) R)`
declaration first; without one the type pass reports `E_CANNOT_INFER`,
and an `extern` that names `Float` or a type variable is
`E_TYPE_MISMATCH` (Chapter 22).

## A.15 Package Manifest, Lock and Registry (phase 19)

Every code here is raised by the package modules
(`package.zyl`, `lock.zyl`, `index.zyl`, `store.zyl`, `mvs.zyl`,
`workspace.zyl`, `cli.zyl`, `module_resolver.zyl`). All but the last two
are spec §28's; `E_PKG_FEATURE_NESTED` and `E_PKG_VERSION_EXISTS` are
catalog additions.

| Code | Cause |
|---|---|
| `E_MANIFEST_INVALID` | `zyl.pkg` is malformed or missing a required field |
| `E_MANIFEST_NOT_FOUND` | No `zyl.pkg` in the package root |
| `E_PKG_BAD_NAME` | The name is not a valid scoped path |
| `E_PKG_BAD_VERSION` | The version is not strict SemVer |
| `E_PKG_BAD_REQUIREMENT` | A range operator in a requirement — MVS takes bare minimum versions |
| `E_PKG_DUPLICATE_DEP` | Two `dep` entries for one name |
| `E_PKG_NOT_FOUND` | The name is not present in the index |
| `E_PKG_VERSION_NOT_FOUND` | That version is not present in the index |
| `E_PKG_NOT_IN_STORE` | The build needs a package the store lacks — run `zyl fetch` |
| `E_PKG_HASH_MISMATCH` | The archive hash differs from the lock |
| `E_PKG_SIGNATURE_INVALID` | The Ed25519 signature does not verify |
| `E_PKG_KEY_CHANGED` | The publisher key differs from the pinned key |
| `E_PKG_UNSIGNED` | The index entry carries no signature |
| `E_PKG_YANKED` | A new resolution selected a yanked version |
| `E_PKG_LOCK_STALE` | `--locked`, but the manifests imply a different graph |
| `E_PKG_LOCK_INVALID` | `zyl.lock` is malformed or of an unknown version |
| `E_PKG_COMPILER_TOO_OLD` | The package requires a newer compiler |
| `E_PKG_UNKNOWN_EDITION` | The edition is not known to this compiler (v5.0 knows only `2026`) |
| `E_PKG_FETCH_FAILED` | `git` or `curl` exited non-zero |
| `E_PKG_ARCHIVE_INVALID` | The archive violates the canonical format |
| `E_PKG_NATIVE_PATH_ESCAPE` | A native source path escapes the package root |
| `E_PKG_NATIVE_FLAG_DENIED` | A `cflag` outside the allowlist |
| `E_PKG_NATIVE_BUILD_FAILED` | `cc` failed on a native source |
| `E_PKG_FEATURE_UNKNOWN` | A requested feature the package does not declare |
| `E_PKG_FEATURE_COLLISION` | A gated definition collides with a base definition |
| `E_PKG_FEATURE_NESTED` | A `feature-gate` below top level |
| `E_PKG_VERSION_EXISTS` | `zyl publish` of a version already in the index |

## A.16 Warnings

Warnings are written to stderr and never stop a build:

| Code | Cause |
|---|---|
| `W_UNUSED_PARAMETER` | A parameter never read |
| `W_UNUSED_VARIABLE` | A binding never read |
| `W_SHADOWED_BINDING` | A binding that hides an outer one of the same name |
| `E_ZEROIZE_MISSING` | See §A.12 — a warning despite the `E_` prefix |
| `W_TYPE_STRICT` | A type error reported as a warning because `ZYL_STRICT_TYPES=report` is set (§A.1) |

Name a binding `_`, or give it a `_` prefix (`_count`), to exempt it
from the unused, shadowing and duplicate-parameter checks. The three
unused and shadowing codes come from `unused_check.zyl`, and
`W_TYPE_STRICT` from `type_annotate.zyl`. A warning about a standard
library file is not shown while you compile a program;
`ZYL_WARN_ALL=1` shows it. The
language server publishes them as Warning diagnostics (Chapter 35).

## A.17 Catalog Versus Implementation

The catalog (`stdlib/compiler/error_codes.zyl`) holds exactly the codes
something raises. `verify/error-codes.sh`, run with the repository's
script tests, fails when a catalogued code is raised nowhere or a raised
code is missing from the catalog. One exception is allowed while it is
being implemented: `E_OVERFLOW` is catalogued and not yet raised.
`E_DIVISION_BY_ZERO` is raised only by the REPL interpreter; a compiled
program traps instead.

A failed `assert` and a `(panic msg)` carry no code: they print `PANIC:`
and the message, `assertion failed` for an `assert` without one.

**Synonyms.** `E_MATCH_NONEXHAUSTIVE` (a literal match with no `_` arm)
and `E_NON_EXHAUSTIVE_MATCH` (a constructor match missing a variant) are
two spellings of one idea, raised by different checks.

## A.18 Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Compile error, or a runtime panic (`zyl_panic` calls `exit(1)`) |
| 136 | Floating-point exception (SIGFPE) — integer division or remainder by zero in compiled code |
| 139 | Segfault (SIGSEGV) — a compiler bug; please report it |
| 134 | Abort (SIGABRT) — an internal error |

## A.19 Where the Definitions Live

- **Catalog**: `stdlib/compiler/error_codes.zyl` — name, phase, severity
  and default message for every code.
- **Formatting**: `stdlib/compiler/error_report.zyl` — the
  `error[CODE]`, `-->`, source-line, caret, label and `= help:` shape,
  the JSON form, and the "did you mean" suggestions.
- **Raised by**: the check that owns the rule —
  `sexp_balance.zyl`, `duplicate_check.zyl`, `arity_check.zyl`,
  `mutability_check.zyl`, `exhaustiveness_check.zyl`,
  `secret_check.zyl`, `unused_check.zyl`, `capability_check.zyl`,
  `module_resolver.zyl` and the package modules, plus the parser,
  the type pass (`type_annotate.zyl`) and ICNF lowering.
- **Tested by**: `tests/compile-fail/` (one file per rejected program)
  and `tests/packages-fail/` (one package per rejected manifest or
  graph).
- **Specification**: `zyl_specification.txt` §28.
