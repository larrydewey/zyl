# Appendix C: Built-in Operations

Every head symbol the compiler recognises specially, plus the operators
it lowers to single instructions. The authority is
`dispatch-special` in `stdlib/compiler/expr_inner.zyl` and the operator
table in `stdlib/compiler/icnf.zyl`; this appendix mirrors both.

The same table backs the language server's hover and completion
(`stdlib/lsp/builtins.zyl`), so anything listed here can be hovered in
an editor for its signature and a one-line description.

## C.1 Arithmetic

| Operator | Form | Notes |
|---|---|---|
| `+` | `(+ a b ...)` | n-ary, left-associative |
| `-` | `(- a b ...)` | unary form negates |
| `*` | `(* a b ...)` | n-ary, left-associative |
| `/` | `(/ a b)` | truncates toward zero; rejected on a `Secret` operand |
| `%` | `(% a b)` | sign follows the dividend; rejected on a `Secret` operand |

Integers are 64-bit signed. Floats are IEEE-754 binary64; integer
division by zero is `E_DIVISION_BY_ZERO`, while float division follows
IEEE-754 and yields an infinity or a NaN.

## C.2 Comparison

| Operator | Form | Notes |
|---|---|---|
| `=`, `==` | `(= a b)` | the same operation; `=` is the spelling used throughout the stdlib |
| `!=` | `(!= a b)` | |
| `<`, `>`, `<=`, `>=` | `(< a b)` | |

**`=` on two dynamically built strings compares addresses, not
contents.** Use `str-eq`, which returns 1 or 0. For secret data use
`ct-eq` or `ct-eq-words` (Chapter 33) — a comparison that stops at the
first difference leaks the length of the matching prefix.

Structs and ADTs compare by identity, not structure: two separately
constructed equal structs are not `=`. Compare their fields.

## C.3 Bitwise and Shifts

| Operator | Form | Notes |
|---|---|---|
| `bit-and` | `(bit-and a b ...)` | n-ary, left-associative |
| `bit-or` | `(bit-or a b ...)` | n-ary |
| `bit-xor` | `(bit-xor a b ...)` | n-ary |
| `bit-not` | `(bit-not a)` | |
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

| Operator | Form |
|---|---|
| `and` | `(and a b)` |
| `or` | `(or a b)` |
| `not` | `(not a)` |

## C.5 Strings

| Operator | Form | Notes |
|---|---|---|
| `str-concat` | `(str-concat a b)` | returns a fresh string |
| `str-length`, `str-len` | `(str-length s)` | length in bytes |
| `str-substring` | `(str-substring s start len)` | byte-indexed |
| `str-eq` | `(str-eq a b)` | compares **contents**, returns 1 or 0 |
| `str-intern` | `(str-intern arena s)` | interns in an arena so `=` becomes meaningful |

## C.6 Binding and Mutation

| Form | Syntax |
|---|---|
| `def` | `(def name value)` |
| `defn` | `(defn name (param ...) body)` |
| `let` | `(let name value body)` |
| `let-mut` | `(let-mut name value body)` |
| `set!` | `(set! name value)` |
| `fn` | `(fn (param ...) body)` |
| `lambda` | `(lambda (param ...) body)` |

`let` and `let-mut` take the name and value directly — not a binding
list. `set!` rebinds a `let-mut` name and nothing else: field mutation,
`(set! (struct-get p "x") 5)`, is rejected.

`fn` and `lambda` are the same form under two names: both take a
parameter list and a body, and neither takes a name.

A top-level `def` does **not** currently become a readable global;
every reference to one compiles to 0. Use a nullary `defn` for a
constant.

A parameter may carry a type annotation: `(defn f ((n Int) (k Secret)) ...)`.

## C.7 Control Flow

| Form | Syntax | Notes |
|---|---|---|
| `if` | `(if cond then else)` | both arms required |
| `cond` | `(cond (test body) ... (else body))` | tested top to bottom; `else` is recognised and always matches |
| `when` | `(when cond body)` | absent arm yields unit |
| `while` | `(while cond body)` | |
| `for` | `(for (i start) limit body)` | `(for (i 16) ...)` starts at 16 |
| `match` | `(match subject (Variant binding ... body) ...)` | exhaustive or it is an error |
| `begin` | `(begin expr ...)` | value is the last expression |
| `try` | `(try body (catch e handler))` | catches a runtime panic |
| `unwrap` | `(unwrap expr)` | panics on `Err`/`None` |
| `error` | `(error "message")` | |
| `assert` | `(assert expr)` | lowered by the assert pass |
| `range` | `(range start end)` | |
| `with-resource` | `(with-resource name acquire body)` | releases on every exit path |

A `match` arm named `dN` (`d1`, `d2`, …) is the wildcard convention
used throughout this codebase; those names are also exempt from the
unused-binding warning.

## C.8 Data Definition

| Form | Syntax |
|---|---|
| `deftype` | `(deftype Name (Variant Field ...) ...)` |
| `defstruct` | `(defstruct Name (field Type) ...)` |
| `defstruct+` | `(defstruct+ Name (field Type) ...)` |
| `struct-get` | `(struct-get value "field")` |
| `make-struct` | `(make-struct Name field ...)` |
| `make-variant` | `(make-variant Type Variant field ...)` |
| `trait` | `(trait Name (method (param ...) ReturnType) ...)` |
| `impl` | `(impl Trait Type (defn method (self ...) body) ...)` |
| `derive` | `(derive Type Trait ...)` |
| `alias` | `(alias Name Type)` |
| `macro`, `defmacro` | `(macro name (param ...) template)` |

`defstruct` is sugar: it lowers to a single-variant `deftype` whose
variant is named after the type, so the existing ADT machinery builds
and reads struct values with no separate field-offset system. **Field
type annotations are dropped** in that lowering — they document intent
and are not currently checked.

## C.9 Modules

| Form | Syntax |
|---|---|
| `use` | `(use path/to/module)` |
| `module` | `(module name)` |
| `export` | `(export name)` |

## C.10 I/O

| Form | Syntax | Notes |
|---|---|---|
| `print` | `(print expr ...)` | rejected on a `Secret` operand |
| `read-line` | `(read-line)` | |
| `exit` | `(exit code)` | |
| `close` | `(close handle)` | |
| `file-open` | `(file-open path mode)` | mode is `"r"`, `"w"` or `"a"` |
| `file-read` | `(file-read fd nbytes)` | |
| `file-write` | `(file-write fd text)` | rejected on a `Secret` operand |
| `file-close` | `(file-close fd)` | |
| `buf-append` | `(buf-append buf s)` | |

`print` chooses its format from the type of its argument, including
when that argument is a parameter: `(defn greet ((s String)) (print s))`
prints the string, not its address. `core/core`'s `print-int`,
`print-float`, `print-string` and `print-bool` are thin wrappers over it
and behave the same.

## C.11 Actors and FFI

| Form | Syntax | Notes |
|---|---|---|
| `spawn` | `(spawn expr)` | rejected on a `Secret` operand |
| `send` | `(send actor message)` | rejected on a `Secret` operand |
| `ffi-call` | `(ffi-call "symbol" arg ... timeout)` | the trailing timeout, in milliseconds, is mandatory |
| `ffi-pin` | `(ffi-pin value)` | moves into the Pin region for the call |
| `ffi-unpin` | `(ffi-unpin value)` | |

## C.12 Bytes, Buffers and Atomics

| Form | Syntax | Notes |
|---|---|---|
| `byte` | `(byte n)` | literal, 0..255 |
| `bytebuf` | `(bytebuf region capacity)` | region and capacity are compile-time literals |
| `bytebuf-len` / `bytebuf-cap` | `(bytebuf-len buf)` | |
| `bytebuf-ptr` | `(bytebuf-ptr buf)` | Pin region only |
| `bytebuf-append` | `(bytebuf-append buf slice)` | takes a **slice**, not a single byte |
| `byteslice` | `(byteslice buf offset length)` | |
| `byteslice-sub` | `(byteslice-sub slice offset length)` | |
| `align-check` | `(align-check ptr alignment)` | |
| `load-u8`, `load-i8` | `(load-u8 :le buf offset)` | |
| `store-u8`, `store-i8` | `(store-u8 :le buf offset value)` | |
| `bytebuf-atomic-load` / `-store` / `-add` / `-sub` / `-cas` / `-fetch-add` / `-max` / `-min` | `(bytebuf-atomic-add buf offset value)` | |

The wider load and store widths — `load-u16`/`u32`/`u64` and their
signed and store counterparts — are **reserved names that are not
implemented**. Using one is rejected with `E_RESERVED_KEYWORD` rather
than silently lowered. Chapter 32 covers this family in full.

## C.13 Contracts

| Form | Syntax |
|---|---|
| `requires` | `(requires condition)` |
| `ensures` | `(ensures condition)` |
| `contracts` | `(contracts (requires ...) (ensures ...))` |
| `recover` | `(recover body handler)` |
| `checkpoint` | `(checkpoint name)` |

Contracts are an optional overlay and never alter type inference,
ownership, regions or scheduling.

## C.14 Testing

| Form | Syntax |
|---|---|
| `test` | `(test "name" body)` |
| `test-suite` | `(test-suite "name" test ...)` |
| `assert-equal` | `(assert-equal actual expected)` |
| `assert-true` / `assert-false` | `(assert-true expr)` |
| `assert-fail` | `(assert-fail expr)` |
| `test-property` | `(test-property "name" generator body)` |
| `test-compile` | `(test-compile expr)` |
| `setup` / `teardown` | `(setup expr ...)` |
| `run-tests` | `(run-tests)` |

## C.15 Types, Regions and Capabilities

Written in parameter annotations, not as expressions:

| Category | Names |
|---|---|
| Primitive types | `Int`, `Float`, `Bool`, `String`, `Unit` |
| Constructed types | `List`, `Option`, `Result`, `Vec`, `Map` |
| Regions | `Stack`, `Heap`, `Global`, `Circular`, `Pin` |
| Capabilities | `Secret`, `TCap`, `TMut` |

## C.16 Compiler Flags

The compiler takes a source file and, optionally:

| Flag | Description |
|---|---|
| `-o <file>` | Output binary path |
| `--emit-asm` | Write x86-64 assembly instead of linking |

```bash
zyl hello.zyl -o hello
zyl hello.zyl --emit-asm -o hello.s
```

That is the whole command line. Phase dumps beyond `--emit-asm` are not
implemented in the self-hosted driver.

## C.17 The REPL

`zyl` with no arguments starts `zyl-repl`. It accepts `:q` or `:quit`
to exit. It is an unfinished skeleton — `tools/repl.zyl` is honest
about this — and is not the way to explore the language today. Compile
a file instead, or use **Zyl: Run Current File** in the editor
(Chapter 35).
