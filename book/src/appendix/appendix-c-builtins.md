# Appendix C: Built-in Operations

Every head symbol the compiler recognises specially, plus the operators
it lowers to single instructions. The authority is `dispatch-special`
and its helpers in `stdlib/compiler/expr_inner.zyl`, the operator table
`ic-op-of` in `stdlib/compiler/icnf.zyl`, and the four string builtins
that `icnf.zyl` inlines to runtime calls.

The language server's hover and completion come from a table kept in
step with these (`stdlib/lsp/builtins.zyl`), so anything listed here
can be hovered in an editor for its signature and a one-line
description. That table also lists a few names that are ordinary
library functions rather than compiler forms — `when`, `str-eq`,
`str-intern`, `buf-append`, `error`, `declassify` — and they are marked
as such below.

Recognising a form is not the same as implementing it. A handful of
forms are parsed and checked but have no lowering to ICNF yet, and so
evaluate to 0 in a compiled program. They are flagged **not lowered**
in the tables. The examples in this appendix were checked against
`build/boot/zyl-self`.

## C.1 Arithmetic

| Operator | Form | Notes |
|---|---|---|
| `+` | `(+ a b ...)` | n-ary, folds left |
| `-` | `(- a b ...)` | n-ary, folds left; `(- x)` negates |
| `*` | `(* a b ...)` | n-ary, folds left |
| `/` | `(/ a b)` | integer division truncates toward zero; rejected on a `Secret` operand |
| `%` | `(% a b)` | sign follows the dividend; rejected on a `Secret` operand |

```lisp
(+ 1 2 3)   ; 6
(- 5)       ; -5
(/ -7 2)    ; -3
(% -7 2)    ; -1
```

Any other single-argument use, such as `(+ 7)` or `(* 7)`, yields 0, not
the argument. Integers are 64-bit signed. Floats are IEEE-754 binary64,
and float division by zero yields an infinity or a NaN. Integer division
by zero is **not checked** in compiled code; only the REPL interpreter
reports `E_DIVISION_BY_ZERO`.

## C.2 Comparison

| Operator | Form | Notes |
|---|---|---|
| `=`, `==` | `(= a b)` | the same operation; `=` is the spelling used throughout the stdlib |
| `!=` | `(!= a b)` | |
| `<`, `>`, `<=`, `>=` | `(< a b)` | |

**`=` compares string contents only when the compiler knows both
operands are strings** — literals, results of the string builtins, or
parameters annotated `String`. Two unannotated parameters that hold
strings are compared by address:

```lisp
(defn same? (a b) (= a b))                    ; compares addresses
(defn same-str? ((a String) (b String)) (= a b)) ; compares contents
```

When in doubt use `str-eq`, which always compares contents and returns
1 or 0. For secret data use `ct-eq` or `ct-eq-words` (Chapter 33) — a
comparison that stops at the first difference leaks the length of the
matching prefix.

Structs and ADTs compare by identity, not structure: two separately
constructed equal structs are not `=`. Compare their fields.

## C.3 Bitwise and Shifts

| Operator | Form | Notes |
|---|---|---|
| `bit-and` | `(bit-and a b ...)` | n-ary, folds left |
| `bit-or` | `(bit-or a b ...)` | n-ary |
| `bit-xor` | `(bit-xor a b ...)` | n-ary |
| `bit-not` | `(bit-not a)` | exactly one argument, else `E_ARITY_MISMATCH` |
| `shl` | `(shl a n)` | logical left shift |
| `shr` | `(shr a n)` | **logical** right shift, zero fill |
| `ashr` | `(ashr a n)` | **arithmetic** right shift, sign fill |

Each lowers to a single machine instruction and is constant-time, which
is what makes them the vocabulary of `math/secret/secret`.

**Out-of-range shift counts are defined**, not left to x86's mod-64
masking: a logical shift by 64 or more gives 0, and `ashr` saturates to
the sign bit.

```lisp
(shl 1 64)     ; 0, not 1
(shr -1 64)    ; 0
(ashr -1 64)   ; -1
(ashr 1024 64) ; 0
```

Constant folding deliberately does not cover these operators. Folding a
`bit-and` inside the compiler would require the compiler's own source
to use `bit-and`, which the previous-generation seed cannot compile.

## C.4 Logical

| Operator | Form | Notes |
|---|---|---|
| `and` | `(and a b ...)` | short-circuits |
| `or` | `(or a b ...)` | short-circuits |
| `not` | `(not a)` | |

## C.5 Strings

| Name | Form | Notes |
|---|---|---|
| `str-concat` | `(str-concat a b)` | returns a fresh string; inlined by the compiler |
| `str-length` | `(str-length s)` | length in bytes; inlined |
| `str-substring` | `(str-substring s start len)` | byte-indexed; inlined |
| `str-equal` | `(str-equal a b)` | compares contents, returns 1 or 0; inlined |
| `str-eq` | `(str-eq a b)` | library function (`allocator/allocator`); same result as `str-equal` |
| `str-len` | `(str-len s)` | library function; same result as `str-length` |
| `str-intern` | `(str-intern arena s)` | library function; copies `s` into `arena` |
| `buf-append` | `(buf-append buf s)` | library function; appends at the end of the string in `buf` |

The four inlined names are reserved by the module resolver: they are
never qualified, so they always mean the builtin.

## C.6 Binding and Mutation

| Form | Syntax |
|---|---|
| `defn` | `(defn name (param ...) body)` |
| `def` | `(def name value)` |
| `let` | `(let name value body)` |
| `let-mut` | `(let-mut name value body)` |
| `set!` | `(set! name value)` |
| `fn` | `(fn (param ...) body)` |
| `lambda` | `(lambda (param ...) body)` |

`let` and `let-mut` take the name and value directly, as written
throughout the stdlib; the specification's spelling with the pair in
parentheses, `(let (name value) body)`, is accepted too. A list of
several bindings, `(let ((x 1) (y 2)) ...)`, is not supported and is
not rejected either — it compiles to the wrong program — so nest `let`s
instead. `set!` rebinds a `let-mut` name and nothing else: field mutation,
`(set! (struct-get p "x") 5)`, is rejected with `E_MUT_CONFLICT`.

`fn` and `lambda` are the same form under two names: both take a
parameter list and a body, and neither takes a name.

A top-level `def` does **not** become a readable global: referring to
one is `E_UNBOUND_VARIABLE`. Use a nullary `defn` for a constant. Spec
§2 also lists `defun` as a synonym for `defn`; the compiler does not
recognise it.

A parameter is a name or `(name Type)`: `(defn f ((n Int) (k Secret)) ...)`.
Anything else is `E_MALFORMED_PARAMETER`. Name a parameter `_`, or give
it a `_` prefix, to mark it unused; `_` may repeat.

## C.7 Control Flow

| Form | Syntax | Notes |
|---|---|---|
| `if` | `(if cond then else)` | both arms required |
| `cond` | `(cond (test body) ... (else body))` | tested top to bottom; `else` always matches |
| `while` | `(while cond body)` | |
| `for` | `(for (i start) cond body)` | `cond` is re-tested each pass; the body must `set!` the loop variable itself |
| `match` | `(match subject (Variant binding ... body) ... (_ body))` | exhaustive or it is a compile error |
| `begin` | `(begin expr ...)` | value is the last expression |
| `try` | `(try body (catch e handler))` | catches a runtime panic, binding its message to `e` |
| `with-resource` | `(with-resource (name init) body)` | binds `name` for `body`; no release step is run yet |
| `assert` | `(assert expr)` or `(assert expr "message")` | a false `expr` panics with `assert failed`; the message is not printed |
| `unwrap` | `(unwrap expr)` | the value of `Some`/`Ok`; `None` or `Err` panics with `unwrap on None` |
| `error` | `(error "message")` | library function (`allocator/allocator`); panics with the message |
| `when` | `(when cond body)` | library function (`core/core`); `body` is evaluated even when `cond` is false |

`for` does not step for you:

```lisp
(for (i 0) (< i 3)
  (begin (print i) (set! i (+ i 1))))   ; prints 0, 1, 2
```

`try` works with `error`: `(try (error "x") (catch e 7))` is 7. Spec
§12.10 describes `error` as returning `(Err msg)`; the implementation
panics instead, and the panic unwinds to the nearest `try`.

Where the failure message matters, use the test assertions (C.14) or an
explicit `if` with `error` instead of `assert`, and `result-expect`, or
`result-unwrap`/`option-unwrap` with a default (Appendix B.1), instead
of `unwrap`.

### Patterns

A `match` arm names a constructor and binds its fields:
`(Some x body)`, `(None body)`. `_` is the catch-all; it must be the
last arm, and a catch-all before other arms is
`E_UNREACHABLE_MATCH_ARM`. A match can instead dispatch on literal
values, in which case it must end with a `_` arm:

| Pattern | Example | Meaning |
|---|---|---|
| literal | `(0 body)` | equal to 0 |
| alternatives | `(1 2 3 body)` | equal to any of them |
| range | `((range 1 9) body)` | between 1 and 9, inclusive |
| guard | `(0 (when debug) body)` | the pattern matches and `debug` is true |

A guard can refer only to names bound outside the `match`. Literal and
constructor patterns cannot be mixed in one `match`.

## C.8 Data Definition

| Form | Syntax | Notes |
|---|---|---|
| `deftype` | `(deftype Name (Variant Field ...) ...)` | |
| `defstruct` | `(defstruct Name (field Type) ...)` | also defines the constructor `make-Name` |
| `defstruct+` | `(defstruct+ Name (field Type) ...)` | parsed the same way as `defstruct` |
| `struct-get` | `(struct-get value "field")` | |
| `make-struct` | `(make-struct Name field ...)` | **not lowered**; use `(make-Name field ...)` |
| `make-variant` | `(make-variant (Type) Variant field ...)` | **not lowered**; call the constructor, `(Variant field ...)` |
| `trait` | `(trait Name (method (param ...) ReturnType) ...)` | |
| `impl` | `(impl Trait Type (defn method (self ...) body) ...)` | call a method as `(Trait.method receiver ...)` |
| `derive` | `(derive Type Trait ...)` | |
| `alias` | `(alias Name Type)` | transparent |
| `macro`, `defmacro` | `(defmacro name (param ...) template)` | |

`defstruct` is sugar: it lowers to a single-variant `deftype` whose
variant is named after the type, so the ADT machinery builds and reads
struct values with no separate field-offset system. Field type
annotations become the variant's field types: they constrain inference,
and a `make-Name` argument that definitely clashes with one is
`E_TYPE_MISMATCH` (Chapter 15, §15.6).

A macro's template is the body with the parameters substituted:
`(defmacro twice (x) (begin x x))`. There is no quasiquote or unquote
syntax.

## C.9 Modules and Packages

| Form | Syntax | Notes |
|---|---|---|
| `use` | `(use path/to/module)` | stdlib modules by path; see Chapter 25 for package paths |
| `pub` | `(pub defn name (param ...) body)` | exports the wrapped definition from its package (§24.4) |
| `feature-gate` | `(feature-gate feature definition)` | includes the definition only when `feature` is enabled (§31.10) |
| `module` | `(module name)` | |
| `export` | `(export name)` | deprecated by §24.3 in favour of `pub`; still reserved |

## C.10 I/O

| Form | Syntax | Notes |
|---|---|---|
| `print` | `(print expr ...)` | one line per argument; rejected on a `Secret` operand |
| `file-open` | `(file-open path mode)` | mode `"r"`, `"a"`, anything else writes |
| `file-read` | `(file-read fd nbytes)` | |
| `file-write` | `(file-write fd text)` | rejected on a `Secret` operand |
| `file-close` | `(file-close fd)` | |
| `read-line` | `(read-line)` | **not lowered**: evaluates to 0 |
| `exit` | `(exit code)` | **not lowered**: does not end the process |
| `close` | `(close handle)` | **not lowered**; use `file-close` |

`print` chooses its format from the type of its argument, including
when that argument is a parameter: `(defn greet ((s String)) (print s))`
prints the string, not its address. `core/core`'s `print-int`,
`print-float`, `print-string` and `print-bool` are thin wrappers over it
and behave the same. Floats print with six decimals: `(print 3.5)`
shows `3.500000`.

## C.11 Actors and FFI

| Form | Syntax | Notes |
|---|---|---|
| `spawn` | `(spawn (fn () body))` | returns an `Int` handle; rejected on a `Secret` operand |
| `send` | `(send actor message)` | queued, then discarded unread — there is no `receive`; rejected on a `Secret` operand |
| `ffi-call` | `(ffi-call "symbol" arg ... timeout)` | the trailing timeout, in milliseconds, is required but not yet enforced |
| `ffi-pin` | `(ffi-pin value)` | moves into the Pin region for the call |
| `ffi-unpin` | `(ffi-unpin value)` | |

## C.12 Bytes, Buffers and Atomics

| Form | Syntax | Notes |
|---|---|---|
| `byte` | `(byte n)` | literal, 0..255 |
| `bytebuf` | `(bytebuf Region capacity)` | region and capacity are compile-time literals |
| `bytebuf-len` / `bytebuf-cap` | `(bytebuf-len buf)` | |
| `bytebuf-ptr` | `(bytebuf-ptr buf)` | raw address of the first byte |
| `bytebuf-append` | `(bytebuf-append buf slice)` | takes a **slice**, not a single byte; returns 0 and changes nothing when the slice does not fit |
| `byteslice` | `(byteslice buf offset length)` | |
| `byteslice-sub` | `(byteslice-sub slice offset length)` | |
| `align-check` | `(align-check ptr alignment)` | returns a Bool |
| `load-u8`, `load-i8` | `(load-u8 :le buf offset)` | `:le` or `:be` |
| `store-u8`, `store-i8` | `(store-u8 :le buf offset value)` | |
| `bytebuf-atomic-load` | `(bytebuf-atomic-load buf offset)` | |
| `bytebuf-atomic-store` / `-add` / `-sub` / `-fetch-add` / `-max` / `-min` | `(bytebuf-atomic-add buf offset value)` | |
| `bytebuf-atomic-cas` | `(bytebuf-atomic-cas buf offset expected desired)` | |

The wider load and store widths — `load-u16`/`u32`/`u64`, their signed
forms and their store counterparts — are **reserved names that are not
implemented**. Using one is rejected with `E_RESERVED_KEYWORD` rather
than silently lowered. Chapter 32 covers this family in full.

## C.13 Contracts

| Form | Syntax | Today |
|---|---|---|
| `requires` | `(requires condition)` | evaluates `condition` and discards it |
| `ensures` | `(ensures condition)` | evaluates `condition` and discards it |
| `contracts` | `(contracts off form)` | yields `form` |
| `checkpoint` | `(checkpoint expr)` | yields `expr` |
| `recover` | `(recover body fallback)` | yields `body`; `fallback` is ignored |

Contracts are an optional overlay and never alter type inference,
ownership, regions or scheduling. None of these forms is enforced yet:
a failing `requires` does not stop the program, and
`E_CONTRACT_VIOLATION` is never raised. Spec §23 also lists
`invariant`, which the compiler does not recognise.

## C.14 Testing

| Form | Syntax | Notes |
|---|---|---|
| `test` | `(test "name" body)` | top level only |
| `run-tests` | `(run-tests)` | runs every top-level `test` and prints a summary |
| `assert-equal` | `(assert-equal actual expected)` | `=` comparison; approximate when either side contains a float literal |
| `assert-true` / `assert-false` | `(assert-true expr)` | |
| `assert-fail` | `(assert-fail expr)` | evaluates `expr`; does not yet check that it fails |
| `test-suite` | `(test-suite "name" test ...)` | parsed, but the tests inside it are not registered |
| `setup` / `teardown` | `(setup expr ...)` | parsed; not run |
| `test-property` | `(test-property "name" generator body)` | parsed as a stub; not run |
| `test-compile` | `(test-compile expr)` | parsed as a stub; not run |

```lisp
(test "adds" (assert-equal (+ 2 3) 5))
(test "fails" (assert-equal 1 2))
(run-tests)
```

prints `test: adds ... ok`, `test: fails ... FAIL` and
`test result: 1 passed, 1 failed, 2 total`. Top-level `test` or
`run-tests` forms cannot share a file with an explicit
`(defn main ...)` (`E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN`). The binary
exits with status 0 even when a test fails, so read the summary line.

## C.15 Types, Regions and Capabilities

Written in parameter annotations and region arguments, not as
expressions:

| Category | Names |
|---|---|
| Primitive types | `Int`, `Float`, `Bool`, `String`, `Unit` |
| Constructed types | `List`, `Option`, `Result`, `Vec`, `Map` |
| Regions | `Stack`, `Heap`, `Global`, `Circular`, `Pin` |
| Capabilities | `Secret`, `TCap`, `TMut` |

`declassify` (`math/secret/secret`) is the library function that drops
the `Secret` capability; `ct-eq-bool` and `ct-eq-words-bool` do the same
for a comparison result.

## C.16 The Command Line

```bash
zyl hello.zyl -o hello              # compile and link
zyl hello.zyl --emit-asm -o hello.s # write x86-64 assembly instead
```

| Command | Description |
|---|---|
| `zyl <file.zyl> [-o out] [--emit-asm]` | Compile one file |
| `zyl new <name>` | Create a package |
| `zyl add <name> [version]` | Add a dependency |
| `zyl fetch` | Resolve, verify and populate the store — the only command that uses the network |
| `zyl build [--locked]` | Compile this package |
| `zyl test` | Compile and run this package |
| `zyl update` | Re-resolve and rewrite `zyl.lock` |
| `zyl vendor` | Copy the graph into `./vendor` |
| `zyl audit` | Report capabilities per package |
| `zyl publish` | Archive, hash and sign this package |
| `zyl key` | Show or create the publisher key |
| `zyl repl` | Start an interactive session |
| `zyl eval <file.zyl>` | Run a program without building one |

An unknown subcommand prints this list. Phase dumps beyond `--emit-asm`
are not implemented.

## C.17 The REPL

`zyl repl` starts an interactive session, and the installed `zyl` (from
`install.sh`) starts one when given no arguments. The in-tree
`build/boot/zyl-self` with no arguments instead runs the legacy
bootstrap protocol, which compiles `/tmp/zyl_boot_in.zyl`.

Each entry is compiled through the normal front end and evaluated by an
ICNF interpreter, so values print as values. Commands:

| Command | Action |
|---|---|
| `:help` | List commands and editing keys |
| `:quit` | Leave the session (Ctrl-D also works) |
| `:history` | Entries from this and earlier sessions |
| `:defs` | Definitions in scope |
| `:doc NAME` | Documentation for a built-in or special form |
| `:type EXPR` | The type of an expression, without running it |
| `:time EXPR` | Evaluate it and report how long it took |
| `:load PATH` | Read a file's definitions into the session |
| `:save PATH` | Write the session's definitions to a file |
| `:reset` | Forget every definition |
| `:clear` | Clear the screen |

Definitions persist per directory in `.zyl-session`, and
`~/.zyl/replrc` (or `$ZYL_REPLRC`) is loaded at start-up. See
`docs/repl.md` and Chapter 35.
