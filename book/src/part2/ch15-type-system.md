# Chapter 15: Type System and Inference

This chapter is the reference for Zyl's types: primitives, composite
types, capability types, function types and inference. The normative text
is `zyl_specification.txt` §4, with the value model in §3 and the numeric
model in §20. The checker is one pass, `stdlib/compiler/type_annotate.zyl`;
`stdlib/compiler/type_system.zyl` holds the `Type` ADT. The design is
`docs/sound-types-design.md`.

One fact shapes the rest of this chapter. §4.6 specifies Hindley–Milner
inference, and the checker enforces it: **a program the compiler accepts
never uses a value at the wrong representation.** Every unification
failure is an error. The pass reports all of a program's type errors,
then the compile fails. There is no cast form and no mode that runs an
ill-typed program. Section 15.7 lists the errors.

## 15.1 Primitive Types

§4.1 defines five primitive types.

| Type | Literal | Runtime value | Notes |
|------|---------|---------------|-------|
| `Int` | `42`, `-7`, `0xFF` | 64-bit two's-complement word | §20.1 |
| `Float` | `3.14`, `1e3` | IEEE-754 binary64 bit pattern in a word | §20.2 |
| `Bool` | `true`, `false` | the word 0 or 1 | |
| `String` | `"hi"` | pointer to NUL-terminated bytes | |
| `Unit` | none | no meaningful value | |

- **No subtyping and no implicit conversion** between primitives. The
  standard library has no conversion functions either: `(float 42)` and
  `(int 3.7)` are `E_UNBOUND_VARIABLE`.
- **Arithmetic.** `+ - * / %` take two `Int`s or two `Float`s and return
  the same type. Mixing them is `E_TYPE_MISMATCH`: `(+ 1.5 2)` does not
  compile; write `(+ 1.5 2.0)`.
- **Ordering.** `< > <= >=` take two `Int`s, two `Float`s or two
  `String`s (by contents) and return `Bool`. A struct or ADT operand is
  `E_TYPE_MISMATCH` ("ordering on T"); such values are ordered with
  `Ord.compare`, which `derive` generates (Chapter 20, §20.6).
- **String comparison.** `=` and `==` on strings compare contents.
- **Bool** is the only condition type. `if`, `cond`, `when`, `unless`,
  `while`, match guards and contract clauses reject an `Int` condition:
  `(if 1 ...)` is `E_TYPE_MISMATCH`. Predicates such as `str-eq` return
  `Bool`, so they are used directly: `(if (str-eq a b) ...)`.
- **Unit** is a real type, and its one value is written `unit`. The
  statement forms are `Unit`: `print`, `set!`, `while`, `assert`,
  `file-write`, `send`, an `if` without an else, and a `cond` with no
  `true` or `else` clause. A form whose two branches are a `Unit` and an
  `Int` does not type-check, so a statement-only `match` arm next to an
  arm that returns a number needs a value of its own. `main` must have
  type `() -> Int`, its result being the process exit status, which is
  why the book's programs end with `0`; a `main` that ends in `print` is
  `E_TYPE_MISMATCH`. An actor entry passed to `spawn` must take no
  arguments.

> **Implementation gaps (§20).**
>
> - **Overflow.** §20.1 makes overflow checked by default. Generated code
>   wraps silently: `(+ 9223372036854775807 1)` is
>   `-9223372036854775808`.
> - **Division by zero.** §20.3 requires `E_DIVISION_BY_ZERO` for
>   `Int`. Generated code executes `idiv` and the process dies with
>   `SIGFPE`.

### Byte-level types (implementation extension)

The specification's type list has no byte types. The compiler adds four
(`BYTE_PRIMITIVES_IMPLEMENTATION_PLAN.md`; the full treatment is
Chapter 32):

| Type | Created by | Notes |
|------|------------|-------|
| `Byte` | `(byte N)`, where `N` is an integer literal 0–255; anything else is `E_BYTE_VALUE_OOB` | Unifies with `Int` in both directions. |
| `ByteBuf` *region* | `(bytebuf Heap 64)`, with region `Stack`, `Heap`, `Global`, `Circular` or `Pin` and a literal capacity | Fixed capacity, zero-initialized. |
| `ByteSlice` *region* | `(byteslice buf off len)`, `(byteslice-sub s off len)` | A view of the same bytes, not a copy. |
| endian selector | `:le` or `:be`, as the first argument of `load-u8`/`load-i8`/`store-u8`/`store-i8` | Only the byte width is implemented. |

The region is written as part of the type, but the type pass does not
tell buffers of two regions apart: `(if c (bytebuf Stack 4) (bytebuf
Heap 4))` type-checks. Where a buffer may live is region inference's
business (Chapter 16), which rejects a `Stack` buffer that escapes with
`E_REGION_ESCAPE`.

```lisp
(defn main ()
  (let b (bytebuf Heap 16)
    (let _ (store-u8 :le b 0 255)
      (begin
        (print (load-u8 :le b 0))    ; 255 (zero-extended)
        (print (load-i8 :le b 0))    ; -1  (sign-extended)
        0))))
```

## 15.2 Composite Types

§4.2 lists `Vec<T>`, `Map<K,V>`, `Result<T,E>`, structs and aliases, and
§3 and §21.5 add tuples. The table shows how each one exists today.

| Spec type | In the implementation |
|-----------|-----------------------|
| `Vec<T>` | `(Vec T)`, a generic ADT in `collections/vec`: `(deftype Vec (VecC (Array T) Int Arena))` (a typed, bounds-checked runtime array, the length, the arena). Use `vec-create` (which takes an `Arena`) or `vec-create-default`, then `vec-push`, `vec-get`, `vec-len`; `vec-get` returns `T`. |
| `Map<K,V>` | `(Map String V)`, a generic ADT in `core/map` (an association list; keys compared with `str-eq`), with `map-new`, `map-insert`, `map-get` (an `Option`), `map-has`, `map-remove`. `collections/map` is a separate Int-to-Int hash map (`map-create-default`). |
| `Set<T>` | `collections/set` (not in §4.2). |
| `Result<T,E>` | `(deftype Result (Ok T) (Err E))` in `core/result`. |
| `Option<T>` | `(deftype Option (Some T) None)` in `core/option` (named in §25). |
| `List<T>` | `(deftype List (Cons T (List T)) Nil)` in `core/list`. |
| Tuple | Not implemented. `(tuple 1 2)` is an undefined function. |
| Struct | `defstruct`; see 15.5. |
| Alias | `(alias Name Type)` is accepted and ignored; see 15.5. |

The angle-bracket spelling `Vec<T>` is notation in this book and in the
specification, not source syntax: `<` and `>` are identifier characters,
so `Vec<Int>` would lex as one identifier.

`core/option`, `core/result` and `core/list` are part of the prelude:
`core/core` is injected into every program unless it is already imported,
so `Some`, `Ok` and `Cons` need no `use`.

```lisp
(use collections/vec)

(defn main ()
  (let v (vec-push (vec-push (vec-create-default 4) 10) 20)
    (begin
      (print (vec-len v))      ; 2
      (print (vec-get v 1))    ; 20
      (print v)                ; [10, 20]
      0)))
```

## 15.3 Capability Types

§4.3 defines five capability wrappers:

| Capability | Meaning (spec) |
|------------|----------------|
| `TCap<T>` | immutable shared access |
| `TMut<T>` | exclusive mutable ownership |
| `TAtomic<T>` | atomic shared mutation |
| `TBox<T>` | heap-managed allocation |
| `TPin<T>` | FFI-pinned memory (non-moving arena) |

These are not types you can write, and the checker has no capability
types either: it types a `let-mut` variable or a `for` loop variable as
the plain type of its value. An `ffi-pin` result is the one exception:
it has the handle type `(Pin a)`, which `ffi-unpin` turns back into
the `a`. The capability rules
are enforced by separate passes that run before type inference:
`mutability_check.zyl` (the `TMut`/`TCap` aliasing invariant and actor
transfer) and `secret_check.zyl` (the `Secret` annotation, the one
capability you do write). Chapter 17 covers them.

## 15.4 Function Types

§4.4 writes a function type as `TFun([T*], TReturn)`. The implementation
represents it as `TFun (List Type)`, the parameter types followed by the
return type. In an annotation a function type is written
`(Fn (A ...) R)`:

```lisp
(defn app ((f (Fn (Int) Int)) (x Int)) (f x))

(defn main ()
  (begin
    (print (app (fn (y) (+ y 1)) 2))   ; 3
    0))
```

Passing `(fn (y) "s")` to `app` is `E_TYPE_MISMATCH`: expected
`(Int -> Int)`, found `(a -> String)`. The same spelling types a C
callback in an `extern` declaration (Chapter 22). A parameter that holds
a function may also be left unannotated; inference finds its type from
the calls.

### Calling convention

This is an implementation detail, not specified behavior. Every value is
one 64-bit word. Parameters arrive in the System V registers `rdi`,
`rsi`, `rdx`, `rcx`, `r8` and `r9`, and further arguments on the stack.
Results come back in `rax`, floats included (as bit patterns; SSE
registers are used only inside float arithmetic). Arguments are evaluated
left to right before the call.

## 15.5 User-Defined Types

### Structs

```lisp
(defstruct Point x y)              ; bare field names
(defstruct Size (w) (h))           ; parenthesized field names
(defstruct User (id Int) (name String))   ; with field types
```

- `defstruct` generates the constructor `make-Point`. Fields are read
  with `(struct-get p "x")`, where the field name is a string.
- Fields are immutable (§10). See Chapter 17.
- A struct is represented as a one-variant ADT whose variant name is the
  struct name, so `(Point 1 2)` also constructs one.
- §4.7 makes structs nominal. Values of two struct types with the same
  fields are different types, and comparing them is `E_TYPE_MISMATCH`.
- **An untyped field is a type parameter of the struct.** `(defstruct
  Pt (x) (y))` is generic in both fields, so `(make-Pt "a" 2)` is a
  `(Pt String Int)` and `(make-Pt 1.5 2)` a `(Pt Float Int)`. Each value
  keeps its field types: `(+ (struct-get p "x") 1)` on the first is
  `E_TYPE_MISMATCH`. Give a field a type, `(x Int)`, to fix it.

### ADTs

`(deftype Name (Variant Type*) ...)`: see Chapter 18. ADTs are nominal
(§4.7), may be recursive, and may be generic (Chapter 19).

### Aliases

§4.7 and §10 specify aliases as transparent and zero-cost. The
post-processor does not recognize `alias`: `(alias UserId Int)` is
accepted, has no effect, and does not introduce `UserId` as a name.
An unknown capitalized name in an annotation is a type variable (15.6),
so writing `(id UserId)` in a parameter list is also accepted: the
parameter is generic, not an `Int`.

## 15.6 Type Inference

### What the checker does

The pass is `compiler/type_annotate.zyl`, run on the fully lowered
program just before ICNF lowering.

- **Hindley–Milner with let-polymorphism.** Unification over union-find
  with an occurs check. Top-level functions are inferred in dependency
  order, one strongly connected component of the call graph at a time,
  and generalized, so each call instantiates a function's type afresh.
  Local `let`s are not generalized: a lambda bound by `let` has one type,
  so using it at `Int` and then at `String` is `E_TYPE_MISMATCH`.
- **Declared types count.** Parameter annotations, the field types of
  `deftype` and `defstruct`, `trait` method signatures and `extern`
  declarations all constrain inference; a type name in a field that is
  not a known type (an uppercase name like `T`) is a type parameter.
- **Every failure is an error.** A unification failure is
  `E_TYPE_MISMATCH` with both types, at the innermost expression being
  checked. A failed occurs check is also `E_TYPE_MISMATCH` ("infinite
  type"). A name defined nowhere is `E_UNBOUND_VARIABLE`. An expression
  the checker has no rule for, such as an `ffi-call` to a symbol with no
  signature, is `E_CANNOT_INFER`. The pass keeps going after an error, so
  one compile lists them all (a clash often shows up twice, once for the
  argument and once for the whole call), and then fails with "the
  program does not type-check (N errors above)".
- **The results are used**, not only computed. Every expression's type
  reaches code generation, which picks `print`'s format (`%lld`, `%f`,
  `%s`), String comparison and Float arithmetic from it. Trait calls are
  resolved from it statically (Chapter 20), and a function whose body
  depends on a type parameter is instantiated per concrete type (15.8).
- `ZYL_DEBUG_TYPES=1` prints every function's inferred type while
  compiling; the REPL's `:type` shows an expression's type.
- `ZYL_STRICT_TYPES=report` turns the type errors into `W_TYPE_STRICT`
  warnings and lets the compile finish. It exists for counting what is
  left while porting code, not for running the result.

```lisp
(defn main ()
  (begin
    (print (+ 1 "a"))       ; error[E_TYPE_MISMATCH]: cannot unify String with Int
    (print (+ 1.5 2))       ; error[E_TYPE_MISMATCH]: cannot unify Int with Float
    0))
```

A list holding a `Circle` and a `Rect` has no single element type, so it
is rejected too: build a sum type (`(deftype Shape (C Circle) (R Rect))`)
instead.

### The one hole

`receive` is not typed yet: its result takes whatever type its use
needs, so a message of the wrong type is not caught at compile time.
Mailboxes are to be replaced by typed channels; until then, the message
ADT you `match` on is your contract (Chapter 21). `send` and `spawn` are
typed: an actor id has type `Actor`, and `send` needs one.

### Annotations

A parameter may be annotated as `(name Type)`, where `Type` is a name
such as `Int`, `Float`, `Bool`, `String`, `Unit`, `Byte`, `Actor`, a
struct or ADT name (applied to arguments for a generic one:
`(List String)`), a function type `(Fn (A ...) R)`, or
`Secret`/`(Secret Int)` (Chapter 17):

```lisp
(defn half ((x Float)) (/ x 2.0))

(defn main ()
  (begin
    (print (half 5.0))   ; 2.500000
    0))
```

Annotations are optional (§0 P7): inference usually finds the same
type without them. An argument that clashes with a parameter's
annotation, or a constructor argument (`(Circle 1.5)`, `make-Point`)
that clashes with the declared field type, gets a diagnostic whose label
points at the declaration:

```lisp
(defn add ((a Int) (b Int)) (+ a b))

(defn main ()
  (begin
    (print (add 1.5 2.0))   ; error[E_TYPE_MISMATCH]: mismatched types:
    0))                     ;   expected `Int`, found `Float`
```

A help line gives the declared type. There is no return-type annotation
and no annotation on `let`.

## 15.7 Type Errors

| Code | Status |
|------|--------|
| `E_TYPE_MISMATCH` | **Raised** by `type_annotate` for every unification failure, including an occurs-check failure, a non-`Bool` condition, mixed `Int`/`Float` arithmetic, and an argument that clashes with an annotation (15.6). Also for a `file-open` mode that is not a literal `"r"`, `"w"` or `"a"` (optionally with `+` or `b`). |
| `E_CANNOT_INFER` | **Raised** when the checker has no type for an expression: an `ffi-call` to a foreign symbol with no `extern` declaration, or to a runtime symbol with no signature. |
| `E_UNBOUND_VARIABLE` | **Raised** for a name defined nowhere, with suggestions. |
| `E_TRAIT_NOT_FOUND` | **Raised** when a trait call's receiver type has no impl (Chapter 20). |
| `E_INVALID_CAPABILITY` | **Raised** by `mutability_check` (before inference) when a lambda is passed to `ffi-call`; a named top-level function may be passed, as a C callback. |
| `E_BYTE_VALUE_OOB` | **Raised** by the parser for `(byte N)` outside 0–255. |
| `E_MALFORMED_FORM` | **Raised** for a special form whose shape its parser rejects (it used to compile to the constant 0). |
| `E_RETURN_TYPE_MISMATCH` | Catalogued; never raised (there are no return annotations). |
| `E_UNKNOWN_TYPE` | Catalogued; never raised: an unknown type name is a type variable. |
| `E_TRAIT_BOUND_NOT_SATISFIED` | In §6.7; never raised (Chapter 19). |

Other checks run before type inference, for example `E_ARITY_MISMATCH`,
`E_MUT_CONFLICT` and the match checks of Chapter 18. They are covered in
the chapters for those features.

## 15.8 Monomorphization

§4.6 places monomorphization in Phase 5, after inference. The specified
algorithm (§6.4, §17) and how much of it the compiler implements are
covered in Chapter 19.

## 15.9 Runtime Representation

Every value is one 64-bit word. Capability and region information exists
only at compile time and is erased (§27: memory layout is not
observable).

| Type | Representation |
|------|----------------|
| `Int` | the integer itself (untagged) |
| `Float` | the binary64 bit pattern (unboxed) |
| `Bool` | 0 or 1 |
| `Byte` | an integer 0–255 |
| `String` | pointer to NUL-terminated bytes (literals are in read-only data; no reference count) |
| struct, ADT variant | pointer to a heap block `[tag][field0][field1]...`, one word per slot, preceded by a hidden word holding the block's size in words |
| closure | a code pointer, or a pointer to a heap `[tag, code, env]` block when it captures variables |
| `ByteBuf`, `ByteSlice` | pointer to a runtime header holding the data pointer, length and capacity |
| `Vec`, `Map` | ordinary ADT values (15.2) |

`==`, `!=` and `assert-equal` on aggregates of a known type call a
structural equality function that `type_annotate` generates per type
(`T.==`), which compares fields by content and recurses into nested ADTs
and Strings. The hidden size word is what lets the runtime compare two
separately allocated aggregates of a type with a `Secret` field
(`zyl_variant_eq`, in `runtime/actor_runtime.c`). That runtime
comparison is shallow: fields that are pointers, including strings, are
compared by address.
