# Chapter 2: Syntax and Basic Types

Zyl's syntax is built on **S-expressions** (symbolic expressions) — parenthesized lists where the first element is an operator and the rest are operands. If you know Lisp, Scheme, or Clojure, this will feel familiar. If not, don't worry — we'll start from the ground up.

Every code block in this chapter that has a `main` is a complete program: save it as a `.zyl` file, compile it with `zyl file.zyl -o file`, and run it. Fragments without a `main` can be pasted into the REPL.

## 2.1 The Two Kinds of Expressions

Every Zyl expression is either an **atom** (a single value) or a **list** (a parenthesized sequence of expressions).

```lisp
42              ; atom (integer)
"hello"         ; atom (string)
true            ; atom (boolean)
(+ 1 2)         ; list: operator +, operands 1 and 2
(defn f (x) x)  ; list: defn, name f, params (x), body x
```

**Key rule**: *Code is data, data is code.* This is called **homoiconicity** — it is what makes macros (Chapter 10) possible.

## 2.2 Atoms — The Basic Values

### Integers (`Int`)

64-bit signed integers (range: -9,223,372,036,854,775,808 to +9,223,372,036,854,775,807).

```lisp
42
-17
0
0xff                   ; hexadecimal literal: 255
9223372036854775807    ; maximum Int
-9223372036854775808   ; minimum Int
```

Integer literals are decimal or hexadecimal (`0x` prefix). There are no
suffixes and no octal literals. The bitwise operators (`bit-and`,
`shl` and the rest) are built in; see §2.6 and Chapter 32.

### Floats (`Float`)

IEEE-754 binary64 (double precision). ~15-17 decimal digits of precision.

```lisp
3.14
-2.5
1.0e10      ; scientific notation: 1.0 × 10¹⁰
-0.0        ; negative zero (distinct from +0.0 in IEEE-754)
```

`print` writes a Float with six decimal places: `(print 3.14)` prints
`3.140000`.

**Int and Float do not mix.** There is no implicit conversion between
them: `(+ 1 2.5)` is a compile error (`E_TYPE_MISMATCH`, "cannot unify
Float with Int"). Write `1.0` when you mean a Float. There are no
conversion built-ins yet; the runtime's `(ffi-call "zyl_f_of_int" n 1000)`
turns an Int into a Float.

The compiler infers every value's type (Chapter 15), and `print`,
arithmetic and comparison follow it: a Float that arrives through an
unannotated parameter, a struct field or a pattern match is still a
Float. A function whose parameter type is left open is compiled once
per type it is called with, so it works for each:

```lisp
(defn half (x) (/ x 2.0))

(defn main ()
  (print (half 5.0))     ; 2.500000
  0)
```

### Booleans (`Bool`)

```lisp
true
false
```

At runtime a Bool is the integer 1 or 0, and `print` shows it that way:
`(print true)` prints `1`. To the type checker, though, `Bool` and `Int`
are different types. A condition — of `if`, `cond`, `when`, `while`, a
guard or a contract — must be a `Bool`; there are no "truthy" numbers,
so `(if 1 ...)` and `(if count ...)` are type errors. Compare
explicitly: `(if (!= count 0) ...)`.

### Strings (`String`)

A string is an immutable sequence of UTF-8 bytes. String literals live
in the program's read-only data; strings built at runtime (by
`str-concat`, for example) are allocated by the runtime.

```lisp
"hello"
"line 1\nline 2"          ; escape sequences: \n \t \\ \"
"quoted \"string\""       ; escaped quote
"Unicode: 你好 🌍"        ; any UTF-8 text
```

The string built-ins:

| Form | Result |
|------|--------|
| `(str-concat a b)` | A new string, `a` followed by `b` |
| `(str-length s)` | Length in **bytes** (`(str-length "你好")` is 6) |
| `(str-substring s start len)` | `len` bytes starting at byte `start` |
| `(str-eq a b)` | `true` if the two strings have the same contents, else `false` |

There is no `+` for strings. `==` and `!=` on two Strings compare their
contents, wherever the strings came from — a parameter, a struct field,
a `Vec` element. `str-eq` does the same explicitly. Its result is a
`Bool`, so use it directly as a condition — `(if (str-eq a b) ...)`,
not `(if (> (str-eq a b) 0) ...)`, which no longer type-checks.

```lisp
(defn shout (s)
  (print (str-concat s "!")))

(defn main ()
  (shout "hello")                         ; hello!
  (print (str-length "hello"))            ; 5
  (print (str-substring "hello" 1 3))     ; ell
  (print (str-eq "abc" "abc"))            ; 1 (true)
  0)
```

### Symbols and Keywords

Identifiers such as `x`, `factorial` or `list-length` name variables
and functions. Names may contain `-`, `?`, `!` and similar punctuation:
`even?` and `set!` are ordinary identifiers.

A colon-prefixed word such as `:le` is a **keyword**. Keywords are not
general values in the current compiler — a bare `:foo` in an expression
is an `E_UNBOUND_VARIABLE` error. They appear inside particular forms,
such as the endianness selector of the byte loads in Chapter 32.

Quoted data (`'foo`, `'(+ 1 2)`) is part of the specification but is
not supported as a runtime value in compiled programs yet. Don't use it
in ordinary code.

### `Unit`: "No Value"

Forms evaluated only for their effect have type `Unit`: `print`,
`set!`, `while`, an `if` without an else branch, and a `cond` with no
`true` or `else` clause. The literal `unit` is the one value of that
type. Because `Unit` is a type like any other, the checker holds it to
the same rules: `(+ 1 (print x))` is a type error, and so is an `if`
whose one branch prints and whose other returns a number — both
branches of an `if` (and all arms of a `match`) must have the same
type.

## 2.3 Lists — The Universal Structure

A list is zero or more expressions enclosed in parentheses:

```lisp
(+ 1 2 3)                   ; function call
(defn square (x) (* x x))   ; function definition
(let x 10 x)                ; local binding
```

**Everything is a list.** This uniformity is what makes macros possible.

### Evaluation Rule (Critical!)

> **Strict left-to-right evaluation, always.**
>
> In `(f a b c)`:
> 1. Evaluate `f` (the operator)
> 2. Evaluate `a` (first argument)
> 3. Evaluate `b` (second argument)
> 4. Evaluate `c` (third argument)
> 5. Apply the function to the arguments

```lisp
(defn noisy ((label String) v)
  (begin
    (print label)
    v))

(defn main ()
  (print (+ (noisy "first" 1) (noisy "second" 2)))
  0)
;; Output:
;; first
;; second
;; 3
```

**No operator precedence.** Parentheses are never optional — they *are* the grouping.

## 2.4 Comments

```lisp
; This is a line comment
(defn foo () ; inline comment
  42)
```

Only line comments (`;`) exist. There are no block comments — `#| ... |#`
is not a comment, and the compiler will misread everything after it.

## 2.5 Variables and Bindings

### Top-Level Constants

A top-level `(def name expr)` defines an immutable global (spec R7).
Every `def` is evaluated once, in source order, before `main` (or the
tests) runs, and its name can be used anywhere, like a function's:

```lisp
(def max-size 1000)
(def app-name "MyApp")

(defn main ()
  (begin
    (print max-size)        ; 1000
    (print app-name)        ; MyApp
    0))
```

A `def` cannot be changed: `(set! max-size 5)` is `E_MUT_CONFLICT`.
Mark it `(pub def ...)` to export it from a module. At the REPL prompt,
`(def x 21)` binds `x` for every later entry.

### Local Immutable Bindings (`let`)

```lisp
(let x 10          ; binds x = 10 for the body
  (print x))       ; x is immutable within this scope
```

- Scope: the body of the `let`
- Value evaluated once, bound to the name
- **Immutable** — a `set!` on a `let` binding is a compile error
  (`E_MUT_CONFLICT`)

Two spellings are accepted:

```lisp
(let x 10 (+ x 1))          ; bare name and value
(let (x 10) (+ x 1))        ; binding list
```

The bare form is what the standard library and the compiler's own
source use throughout, and it is what the rest of this book uses. Both
take any number of body forms, run in order as an implicit `begin`. A
`let` with no body at all, such as `(let x 1)`, is `E_MALFORMED_FORM`.

### Shadowing

A nested `let` may reuse a name; inside it, the new binding hides the
outer one:

```lisp
(defn main ()
  (let x 10
    (begin
      (let x 20
        (print x))         ; prints 20
      (print x)))         ; prints 10 (outer x unchanged)
  0)
```

Note the `begin`. In the current compiler, a `let` that appears as one
of several forms in a function body (or in a `let` body) without an
enclosing `begin` stays in scope for the forms after it — here, the
second `print` would see 20. Grouping the forms with `begin`, as above,
gives the scoping the language defines. It is good practice anyway:
Chapter 3 recommends `begin` for every multi-form body.

### Local Mutable Bindings (`let-mut`)

```lisp
(defn main ()
  (let-mut counter 0
    (begin
      (set! counter (+ counter 1))   ; rebinding, not in-place mutation
      (print counter)))             ; prints 1
  0)
```

- `set!` **rebinds** the name to a new value — it does *not* mutate the old value in place
- Only a `let-mut` binding can be the target of `set!`; anything else is `E_MUT_CONFLICT`
- Use sparingly — prefer immutable `let` and recursion

### Multiple Bindings

`let` binds exactly one name. Several bindings means several `let`s,
nested — and each one can refer to the ones outside it:

```lisp
(let x 10
  (let y (+ x 5)
    (+ x y)))               ; 25
```

There is no parallel or multi-binding form: `(let (x 10 y 20) ...)`
binds `x` and stops, and the reference to `y` is then an
`E_UNBOUND_VARIABLE` error at compile time rather than a silent
surprise.

## 2.6 Function Calls and Core Operations

### Arithmetic (n-ary, left-associative)

```lisp
(+ 1 2 3 4)        ; 10     (1 + 2 + 3 + 4)
(- 10 3 2)         ; 5      (10 - 3 - 2)
(* 2 3 4)          ; 24     (2 * 3 * 4)
(/ 20 2 2)         ; 5      (20 / 2 / 2)
(/ 7 2)            ; 3      (Int division truncates)
(% 17 5)           ; 2      (remainder, sign follows dividend: (% -17 5) is -2)
```

The same operators work on Floats: `(/ 7.0 2.0)` is `3.500000`. Each
operator takes Ints or Floats, never one of each: `(* 2 1.5)` is a type
error.

**One-argument forms**: only `-` has one, and it negates: `(- 5)` is
-5. Don't write `(+ x)`, `(* x)` or `(/ x)` — the current compiler
evaluates each of them to 0 instead of rejecting it.

### Comparison

```lisp
(== 1 1)           ; true   (= is the same operator)
(!= 1 2)           ; true
(< 1 2)            ; true
(> 2 1)            ; true
(<= 1 1)           ; true
(>= 1 2)           ; false
```

The ordering operators work on `Int`, `Float` and `String` (by bytes),
and both sides must have the same type. A struct or ADT value is not
ordered by `<`: `(< Red Blue)` is `E_TYPE_MISMATCH`. Order such values
with `Ord.compare`, which returns -1, 0 or 1 and can be derived
(`(derive Color Ord)`, Chapter 7, §7.7). `==` and `!=`
compare structs and ADT values **structurally, by content**:
`(== (Some 1) (Some 1))` is true, and two structs with equal field
values are equal. Nested struct and ADT fields, and String fields, are
compared by content too, so two separately built lists
`(Cons 1 (Cons 2 Nil))` are `==`. Two exceptions compare only one level
deep, with pointer fields by address: a value whose type inference
cannot determine, and a type with a `Secret` field. For strings, see
§2.2.

### Boolean Logic (short-circuiting)

```lisp
(and true false true)     ; false  (stops at first false)
(or false true false)     ; true   (stops at first true)
(not true)                ; false
```

`and` and `or` are desugared to `if` by the parser, so they evaluate
only as many arguments as they need.

### Bitwise Operations

```lisp
(bit-and 12 10)    ; 8
(bit-or 12 10)     ; 14
(bit-xor 12 10)    ; 6
(bit-not 0)        ; -1
(shl 1 4)          ; 16
(shr -1 60)        ; 15   (logical shift)
(ashr -16 2)       ; -4   (arithmetic shift)
```

### Predicates

There are no runtime type predicates such as `int?` — types are known
at compile time. The core library does provide a few numeric
predicates: `is-zero`, `is-even` and `is-odd`.

## 2.7 Core Data Structures

This is a preview; Chapter 4 covers each in detail.

### Option, Result and List

Three ADTs are defined in the core library, which every program gets
without a `use`:

```lisp
(Some 42)               ; Option: a value is present
None                    ; Option: no value
(Ok 42)                 ; Result: success
(Err "file not found")  ; Result: failure
(Cons 1 (Cons 2 Nil))   ; List: 1, 2
```

Because they are already defined, don't declare your own `Option`,
`Result` or `List` — a second `deftype` with the same name is an
`E_DUPLICATE_DEFINITION` error.

### Vectors and Maps

`Vec` and `Map` are library types, imported with `use`. A `Vec` holds
elements of any one type; a `Map` has `Int` keys and `Int` values in
the current library.

```lisp
(use collections/vec)
(use collections/map)

(defn main ()
  (let v (vec-push (vec-push (vec-create-default 10) 42) 7)
    (begin
      (print (vec-len v))           ; 2
      (print (vec-get v 0))))       ; 42
  (let m (map-put (map-create-default 10) 1 100)
    (print (map-get m 1 0)))        ; 100
  0)
```

There is no literal syntax for either. Tuples are in the specification
but are not implemented; use a struct.

## 2.8 The `begin` Form — Sequencing

```lisp
(begin
  (print "Step 1")
  (print "Step 2")
  42)                    ; Returns value of LAST expression
```

Use `begin` whenever you need several expressions where one is
expected — an `if` branch, a `match` arm — and around any multi-form
body (see the note on shadowing in §2.5). A `fn` or `lambda` body, a
`try` handler and a `cond` clause already take several forms as an
implicit `begin`.

## 2.9 Special-Form Names

Words such as `defn`, `let`, `if`, `match`, `begin`, `while`, `for`,
`cond`, `try`, `fn`, `lambda`, `deftype`, `defstruct`, `trait`, `impl`,
`use`, `spawn`, `send` and `ffi-call` are recognized when they appear at
the head of a list. The complete set is what `:doc` answers for in the
REPL.

A special form written in a shape its parser does not accept — a
`let` with no value, an `if` with no branches — is a compile error,
`E_MALFORMED_FORM`.

The compiler does not stop you from using one as a variable name —
`(let begin 5 begin)` compiles — but code that does is hard to read,
and some names (such as `when`) are also core library functions. Treat
them as reserved.

The error code `E_RESERVED_KEYWORD` is catalogued for reserved names but
is not raised today.

## 2.10 Style Conventions

| Category | Convention | Example |
|----------|------------|---------|
| Functions | `kebab-case` | `factorial`, `read-file` |
| Types (structs, ADTs) | `PascalCase` | `Point`, `Result`, `MyType` |
| ADT Variants | `PascalCase` | `Some`, `None`, `Ok`, `Err` |
| Constants | nullary function, `kebab-case` | `(defn max-size () 1000)` |
| Variables/params | `kebab-case` | `user-count`, `file-handle` |
| Predicates | `?` suffix | `even?`, `origin?` |
| Unused names | `_` or a `_` prefix | `_`, `_rest` |

**Indentation**: 2 spaces.

## 2.11 Quick Reference Card

```lisp
;; Literals
42  0xff        ; Int
3.14            ; Float
true / false    ; Bool
"hello"         ; String

;; Bindings
(def name expr)                 ; Constant (immutable global)
(let name expr body...)         ; Local immutable
(let (name expr) body)          ; The same, one body form only
(let-mut name expr body...)     ; Local mutable (use set!)

;; Control (details in Chapter 3)
(if cond then else)             ; cond is a Bool
(cond (cond1 body1) (cond2 body2) (else body))
(while cond body...)
(for ((var init) ...) cond body)

;; Functions (details in Chapter 3)
(defn name (params) body)
(fn (params) body)              ; Anonymous function
(lambda (params) body)          ; The same form, other name

;; Data structures
(vec-create-default cap)        ; Vec (use collections/vec)
(map-create-default cap)        ; Map (use collections/map)
(Ok val) / (Err err)            ; Result
(Some val) / None               ; Option
(Cons head tail) / Nil          ; List

;; Operations
(+ - * / %)                     ; Arithmetic: all Int or all Float
(== != < > <= >=)               ; Comparison, result Bool
(and or not)                    ; Boolean
(set! var value)                ; Rebinding (let-mut only)
(print expr)                    ; One value and a newline to stdout
(print-string s) (print-float f); Typed printers (print already follows types)
(struct-get struct "field")     ; Struct field access
(bit-and bit-or bit-xor bit-not); Bitwise (Chapter 32)
(shl shr ashr)                  ; Shifts -- shr logical, ashr arithmetic
(str-concat str-length str-substring str-eq)  ; Strings
```

---

## For Experts: Under the Hood

### Representation

Every value is one 64-bit machine word.

| Type | Representation |
|------|----------------|
| `Int` | 64-bit two's-complement integer, untagged |
| `Float` | The IEEE-754 bit pattern, held in the same 64-bit word (not boxed) |
| `Bool` | 1 or 0 |
| `String` | Pointer to NUL-terminated UTF-8 bytes |
| Struct / ADT value | Pointer to a block: a hidden header, the variant tag, then one 8-byte word per field |
| `Vec` | A struct: buffer pointer, length, capacity, arena |
| `Map` | A struct: parallel key and value arrays, length, capacity, arena |

Because a field is always one word, a struct or variant block's layout
is fully determined by its field count. A struct is a single-variant
ADT whose variant name is the struct's name.

### Determinism Guarantees

- The compiler's own tables are ordered structures; nothing depends on hash-seed or allocation order
- `Map` keeps its entries in insertion order and searches them linearly, so iteration order is deterministic by construction
- Same source → identical binary, which `./boot.sh` checks for the compiler itself on every build

### Where Values Live (Preview)

| Value | Where |
|-------|-------|
| `let`-bound Int, Float, Bool | The function's stack frame |
| String literal | Read-only data in the binary |
| Struct or ADT value that provably never escapes | The function's stack frame, or the call's own region, released when it returns |
| Struct or ADT value returned to a caller | The region the caller chose for the result |
| Any other struct or ADT value | The runtime's heap arena |
| `Vec` / `Map` buffers | An arena, passed to `vec-create` / `map-create`; the `-default` constructors create a private one |

Details in [Chapter 5](ch05-ownership-regions-capabilities.md).

---

**Next:** [Chapter 3: Functions and Control Flow](ch03-functions-and-control-flow.md) — defining functions, recursion, conditionals, loops, and error handling.
