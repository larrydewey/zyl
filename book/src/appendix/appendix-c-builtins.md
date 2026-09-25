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

Every form here is typed by the type pass (`type_annotate.zyl`), and a
program that does not type-check does not compile (Chapter 15). The
rules that most often surprise are collected in each section: conditions
are `Bool`, arithmetic never mixes `Int` and `Float`, and statement forms
have type `Unit`.

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
(+ 1.5 2.0) ; 3.500000
(+ 1 2.0)   ; error[E_TYPE_MISMATCH]: cannot unify Float with Int
```

Every operand of one arithmetic form has the same type, `Int` or
`Float`, and the result has that type too. Nothing converts between
them implicitly; write the literal in the type you want, or convert an
`Int` with the runtime's `(ffi-call "zyl_f_of_int" n 1000)`.

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
| `<`, `>`, `<=`, `>=` | `(< a b)` | `Int`, `Float` or `String`; not a struct or ADT |

Every comparison returns `Bool`, and both operands have one type. The
type pass knows that type everywhere, so `=` on strings compares
contents even through unannotated parameters: a generic function is
specialized per type at each call.

```lisp
(defn same? (a b) (= a b))
(same? "ab" (str-concat "a" "b"))   ; true
```

`str-eq` compares string contents too and also returns `Bool`. For
secret data use `ct-eq` or `ct-eq-words` (Chapter 33) — a comparison
that stops at the first difference leaks the length of the matching
prefix.

Structs and ADTs compare structurally: `=` is true when two values have
the same constructor and equal fields. They have no ordering operators:
`(< Red Blue)` is `E_TYPE_MISMATCH`. Derive `Ord` and use `Ord.compare`,
which returns -1, 0 or 1 (variants in declaration order, then fields).

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

The operands and results are `Bool`. An `Int` is not a truth value:
`(not 0)` is `E_TYPE_MISMATCH`; write `(= n 0)`.

## C.5 Strings

| Name | Form | Notes |
|---|---|---|
| `str-concat` | `(str-concat a b)` | returns a fresh string; inlined by the compiler |
| `str-length` | `(str-length s)` | length in bytes; inlined |
| `str-substring` | `(str-substring s start len)` | byte-indexed; inlined |
| `str-equal` | `(str-equal a b)` | compares contents, returns a `Bool`; inlined |
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
`E_MALFORMED_FORM`; nest `let`s instead. `set!` has type `Unit`. `set!` rebinds a `let-mut` name and nothing else: field mutation,
`(set! (struct-get p "x") 5)`, is rejected with `E_MUT_CONFLICT`.

`fn` and `lambda` are the same form under two names: both take a
parameter list and a body, and neither takes a name. A `defn`, `fn` or
`lambda` body may be several forms, evaluated in order as if wrapped in
`begin`; the value is the last one's.

A top-level `(def name expr)` is an immutable global, evaluated once, in source order, before `main` or the tests run. Spec
§2 also lists `defun` as a synonym for `defn`; the compiler does not
recognise it.

A parameter is a name or `(name Type)`: `(defn f ((n Int) (k Secret)) ...)`.
Anything else is `E_MALFORMED_PARAMETER`. Name a parameter `_`, or give
it a `_` prefix, to mark it unused; `_` may repeat.

## C.7 Control Flow

| Form | Syntax | Notes |
|---|---|---|
| `if` | `(if cond then else)` | `cond` is `Bool`; both arms have one type. Without `else` the form is `Unit`, and so must `then` be |
| `cond` | `(cond (test body ...) ... (else body ...))` | tested top to bottom; a clause headed `else` or `true` always matches and ends the `cond`. Without one, the `cond` is `Unit`. A clause may hold several forms |
| `while` | `(while cond body ...)` | `Unit` |
| `for` | `(for (i start) cond body)` | `cond` is re-tested each pass; the body must `set!` the loop variable itself |
| `match` | `(match subject (Variant binding ... body) ... (_ body))` | exhaustive or it is a compile error |
| `begin` | `(begin expr ...)` | value is the last expression |
| `try` | `(try body (catch e handler ...))` | catches a runtime panic, binding its message to `e`; the handler may be several forms and has the body's type |
| `with-resource` | `(with-resource (name init) body)` | binds `name` for `body`; no release step is run yet |
| `assert` | `(assert expr)` or `(assert expr "message")` | `expr` is `Bool`; a false `expr` panics with the message (a string literal), else `assert failed`. `Unit` |
| `unwrap` | `(unwrap expr)` | the value of `Some`/`Ok`; `None` or `Err` panics with `unwrap on None` |
| `error` | `(error "message")` | library function (`allocator/allocator`); panics with the message |
| `when` | `(when cond body)` | library function (`core/core`); `body` is a `Unit` statement, evaluated even when `cond` is false — to skip it, use `(if cond stmt)` |

`for` does not step for you:

```lisp
(for (i 0) (< i 3)
  (print i)
  (set! i (+ i 1)))   ; prints 0, 1, 2
```

A form evaluated only for its effect — `print`, `set!`, `while`, `for`,
`assert`, `send`, `file-write`, an `if` with no `else` — has type
`Unit`, written `unit` as a value. A function whose last form is one of
these returns `Unit`. `main` must return an `Int`, the exit status, so
it usually ends with `0`; `(defn main () (print 1))` is
`E_TYPE_MISMATCH`.

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

A guard can refer only to names bound outside the `match`, and is a
`Bool`. Two limits today: a guard on a `range` arm is rejected with a
spurious `E_ARITY_MISMATCH` (`when` called with 1 argument), and a
guard that names a top-level `def` reports it as `E_UNBOUND_VARIABLE`;
a guard over a function parameter or a `let` binding works. Literal and constructor patterns cannot be mixed in one
`match`, and a constructor's field is bound to a name, not matched
further: `(Some (Pair a b) body)` is `E_NESTED_PATTERN`. Every arm has
the same type.

## C.8 Data Definition

| Form | Syntax | Notes |
|---|---|---|
| `deftype` | `(deftype Name (Variant Field ...) ...)` | |
| `defstruct` | `(defstruct Name (field Type) ...)` | also defines the constructor `make-Name`; a field written without a type is a type parameter of the struct |
| `defstruct+` | `(defstruct+ Name (field Type) ...)` | parsed the same way as `defstruct` |
| `struct-get` | `(struct-get value "field")`, or `value.field` | dot form chains: `v.a.b` |
| `make-struct` | `(make-struct Name field ...)` | **not lowered**; use `(make-Name field ...)` |
| `make-variant` | `(make-variant (Type) Variant field ...)` | **not lowered**; call the constructor, `(Variant field ...)` |
| `trait` | `(trait Name (method (self (p Type) ...) ReturnType) ...)` | `Self` in a signature is the implementing type |
| `extern` | `(extern "symbol" (Type ...) ReturnType)` | declares a C function's signature; required before an `ffi-call` to it |
| `impl` | `(impl Trait Type (defn method (self ...) body) ...)` | call a method as `(Trait.method receiver ...)` |
| `derive` | `(derive Type Trait ...)` | Show, Debug, Eq, Ord, Hash, Clone; fields must implement the trait |
| `alias` | `(alias Name Type)` | transparent |
| `macro`, `defmacro` | `(defmacro name (param ...) template)` | |

`defstruct` is sugar: it lowers to a single-variant `deftype` whose
variant is named after the type, so the ADT machinery builds and reads
struct values with no separate field-offset system. Field type
annotations become the variant's field types, and a `make-Name`
argument of another type is `E_TYPE_MISMATCH` (Chapter 15, §15.6). An
unannotated field is an implicit type parameter: `(defstruct Box (v))`
is a `Box` of any one type, fixed at each construction.

A `deftype` may not reuse a prelude constructor name — `Some`, `None`,
`Ok`, `Err`, `Cons`, `Nil` — which is `E_DUPLICATE_VARIANT`.

A trait method's first parameter is `self`; further parameters and the
return type may name `Self`:

```lisp
(trait Ord (compare (self (other Self)) Int))
```

An impl for `Int` then takes two `Int`s. The old spelling `(area self)`,
with `self` bare instead of in a list, is `E_MALFORMED_FORM`; write
`(area (self) Int)`.

A macro's template is the body with the parameters substituted:
`(defmacro twice (x) (begin x x))`. The template is exactly one form.
There is no quasiquote or unquote syntax.

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
| `print` | `(print expr ...)` | one line per argument; `Unit`; rejected on a `Secret` operand |
| `file-open` | `(file-open path mode)` | `mode` is a string literal: `"r"`, `"w"` or `"a"`, optionally followed by `+` or `b`. Anything else, a variable included, is `E_TYPE_MISMATCH` |
| `file-read` | `(file-read fd nbytes)` | |
| `file-write` | `(file-write fd text)` | `Unit`; rejected on a `Secret` operand |
| `file-close` | `(file-close fd)` | |
| `read-line` | `(read-line)` | **not lowered**: evaluates to 0 |
| `exit` | `(exit code)` | **not lowered**: does not end the process |
| `close` | `(close handle)` | **not lowered**; use `file-close` |

`print` chooses its format from the type of its argument, including
when that argument is a parameter: `(defn greet ((s String)) (print s))`
prints the string, not its address. `core/core`'s `print-int`,
`print-float`, `print-string` and `print-bool` are thin wrappers over it
and behave the same. Floats print with six decimals: `(print 3.5)`
shows `3.500000`. A `Bool` prints as `1` or `0`.

## C.11 Actors and FFI

| Form | Syntax | Notes |
|---|---|---|
| `spawn` | `(spawn (fn () body))` | returns an `Actor`; rejected on a `Secret` operand |
| `send` | `(send actor message)` | `actor` is an `Actor`; queued FIFO per sender; `Unit`; rejected on a `Secret` operand |
| `receive` | `(receive)` | next data message of the running actor, blocking. Not type-checked: its result takes whatever type its use needs |
| `actor-self` | `(actor-self)` | the running actor's `Actor`; on `main`, opens its mailbox |
| `ffi-call` | `(ffi-call "symbol" arg ... timeout)` | the symbol is a string literal and the trailing timeout a positive integer literal in milliseconds (`E_FFI_SYMBOL_REQUIRED`, `E_FFI_TIMEOUT_REQUIRED`); a foreign call that overruns it raises `E_FFI_TIMEOUT`. A foreign symbol needs an `extern` declaration; a `zyl_*` runtime symbol is typed by the compiler's signature table |
| `ffi-pin` | `(ffi-pin value)` | copies `value`, an `a`, into a Pin-region slot and returns the slot, a `(Pin a)`; C receives its address. A function is `E_FFI_TYPE_NOT_PINNABLE` |
| `ffi-unpin` | `(ffi-unpin pinned)` | takes a `(Pin a)` and returns the `a` in the slot, which C may have written; frees nothing |

`receive` is the one place a value's type is not checked: a message
of the wrong type is read as whatever the receiver expects. Typed
channels will replace mailboxes and close that hole.

```lisp
(extern "abs" (Int) Int)
(defn main () (print (ffi-call "abs" -5 1000)) 0)   ; 5
```

An `extern`'s types are concrete and fit a machine word: `Int`, `Bool`,
`String`, `Ptr` and the byte handle types. `Float` and type variables
are rejected (`E_TYPE_MISMATCH`). `(Fn (A ...) R)` types a C callback
argument. There is no cast form: a value's type cannot be changed by
assertion.
## C.12 Bytes, Buffers and Atomics

| Form | Syntax | Notes |
|---|---|---|
| `byte` | `(byte n)` | literal, 0..255 |
| `bytebuf` | `(bytebuf Region capacity)` | region and capacity are compile-time literals; a `Stack` buffer lives in the frame region, and letting it escape is `E_REGION_ESCAPE` |
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

The wider widths — `load-u16`/`u32`/`u64`, `load-i16`/`i32`/`i64` and
the matching `store-*` forms — take the same arguments as the 8-bit ones
and honour the `:le`/`:be` selector. Buffers are typed `ByteBuf`, slices
`ByteSlice`. Chapter 32 covers this family in full.

## C.13 Contracts

| Form | Syntax | Today |
|---|---|---|
| `requires` | `(requires condition)` | raises `E_CONTRACT_VIOLATION` when `condition` is false |
| `ensures` | `(ensures condition)` | checked after the body; `result` is the return value |
| `invariant` | `(invariant condition)` | checked where written, like `requires` |
| `contracts` | `(contracts P form)`, `(contracts P)` | compiles `form` (or the next top-level form) under profile P: strict, debug, warn, off, production |
| `checkpoint` | `(checkpoint expr)` | `expr`; if it raises, outer `let-mut` variables it assigned are restored |
| `recover` | `(recover body ((E_CODE) fallback) ((String) fallback) ...)` | `body`, or the first matching arm's `fallback` |

Contracts are an optional overlay and never alter type inference,
ownership, regions or scheduling. `--contracts=P` sets the build's profile.

## C.14 Testing

| Form | Syntax | Notes |
|---|---|---|
| `test` | `(test "name" body)` | top level only; exactly one body form (use `begin` for several) |
| `run-tests` | `(run-tests)` | runs every top-level `test` and prints a summary |
| `assert-equal` | `(assert-equal actual expected)` | `=` comparison; approximate when either side contains a float literal. Compare a `Bool` result with `true`, or use `assert-true` |
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
| Primitive types | `Int`, `Float`, `Bool`, `String`, `Unit` (whose one value is `unit`) |
| Handle types | `Actor`, `ByteBuf`, `ByteSlice`, `Arena`, `Ptr` |
| Constructed types | `List`, `Option`, `Result`, `Vec`, `Map` |
| Regions | `Stack`, `Heap`, `Global`, `Circular`, `Pin` |
| Capabilities | `Secret`, `TCap`, `TMut` |

`with-region` is the one form that chooses a region for a computation:

| Form | Syntax | Notes |
|---|---|---|
| `with-region` | `(with-region (arena :block B :align A :limit L) body)` | allocations in `body` go to an arena grown in `B`-byte blocks (a multiple of 4096, at most 64 MiB) up to `L` bytes (0: no limit); released when `body` ends |
| | `(with-region (fixed :size S :align A) body)` | a region of exactly `S` bytes |

`A` is a power of two from 8 to 4096 (default 8). A malformed spec is
`E_REGION_SPEC`; running out is `E_REGION_EXHAUSTED` (catchable); a value
allocated inside that outlives the body is `E_REGION_ESCAPE`. Chapter 16
has the details.

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
