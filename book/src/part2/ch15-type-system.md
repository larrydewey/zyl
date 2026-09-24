# Chapter 15: Type System and Inference

This chapter is the reference for Zyl's types: primitives, composite
types, capability types, function types and inference. The normative text
is `zyl_specification.txt` §4, with the value model in §3 and the numeric
model in §20. The implementation is `stdlib/compiler/type_system.zyl` (the
`Type` ADT and unifier) and `stdlib/compiler/type_inference.zyl`.

One fact shapes the rest of this chapter. §4.6 specifies Hindley–Milner
inference with region and capability constraints. The self-hosted
inferer computes types, but **it does not reject ill-typed programs**: a
failed unification falls back to a fresh type variable, and compilation
continues. Section 15.7 lists what is actually checked.

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
  `(int 3.7)` fail at link time as undefined functions.
- **String comparison.** `=` and `==` on strings compare contents.
- **Unit** has no literal (`unit` is an unbound identifier). It is the
  value of a one-armed `if` whose condition is false and of a `let` with
  no body.

> **Implementation gaps (§20).**
>
> - **Overflow.** §20.1 makes overflow checked by default. Generated code
>   wraps silently: `(+ 9223372036854775807 1)` is
>   `-9223372036854775808`.
> - **Division by zero.** §20.3 requires `E_DIVISION_BY_ZERO` for
>   `Int`. Generated code executes `idiv` and the process dies with
>   `SIGFPE`.
> - **Mixed arithmetic.** Mixing `Int` and `Float` in one operation is
>   neither rejected nor converted. `(+ 1.5 2)` evaluates to `1.5`.

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

The region is part of the type: unification requires two `ByteBuf`s to
have the same region. Because inference never fails a program (15.6), a
mismatch is not reported, and the runtime allocates every buffer with
`malloc` whatever region it names.

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
| `Vec<T>` | `(Vec T)`, a generic ADT in `collections/vec`: `(deftype Vec (VecC Int Int Int Int T))` (buffer, length, capacity, arena, and a phantom `T` that is never read). Elements are 8-byte words. Use `vec-create`, `vec-push`, `vec-get`, `vec-len`; `vec-get` returns `T`. |
| `Map<K,V>` | `(Map String V)`, a generic ADT in `core/map` (an association list; keys compared with `str-eq`), with `map-new`, `map-insert`, `map-get` (an `Option`), `map-has`, `map-remove`. `collections/map` is a separate Int-to-Int hash map. |
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

These are not types you can write. In the implementation they are
`CapKind` values inside one type constructor, `TCap CapKind Type`, and the
compiler introduces them itself: `ffi-pin` produces a `TPin`, and a `for`
loop variable is a `TMut`. `CapKind` also has `TCByte`, `TCAtomicByte` and
`TCSecret`, which are defined but not yet produced by inference.

Two capability types unify only if their kinds are equal, with one
exception: `Secret` and `Cap` unify with each other. The rules, the
aliasing invariant and the Secret capability are covered in Chapter 17.

## 15.4 Function Types

§4.4 writes a function type as `TFun([T*], TReturn)`. The implementation
represents it as `TFun (List Type)`, the parameter types followed by the
return type. Function types cannot be written in source either. A
parameter that holds a function is left unannotated.

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
  struct name, so `(Point 1 2)` also constructs one. Each struct gets a
  tag unique across the program, which is what the runtime fallback of
  trait dispatch relies on (Chapter 20).
- §4.7 makes structs nominal. `==` compares a struct's tag as well as its
  fields, so values of two struct types with the same fields are never
  equal. No type error is raised for mixing them, though (15.6).
- Generic structs are not supported (§6.5).

### ADTs

`(deftype Name (Variant Type*) ...)`: see Chapter 18. ADTs are nominal
(§4.7), may be recursive, and may be generic (Chapter 19).

### Aliases

§4.7 and §10 specify aliases as transparent and zero-cost. The
post-processor does not recognize `alias`: `(alias UserId Int)` is
accepted, has no effect, and does not introduce `UserId` as a name.
Because parameter annotations are not checked against known types (15.6),
writing `(id UserId)` in a parameter list is also accepted.

## 15.6 Type Inference

### What the inferer does

The pass is `compiler/type_annotate.zyl`, run on the fully lowered
program just before ICNF lowering.

- **Hindley–Milner with let-polymorphism.** Unification over union-find
  with an occurs check. Top-level functions are inferred in dependency
  order, one strongly connected component of the call graph at a time,
  and generalized, so each call instantiates a function's type afresh.
  Local `let`s are not generalized.
- **Declared types count.** Parameter annotations, the field types of
  `deftype` and `defstruct`, and `trait` method signatures all constrain
  inference; a type name in a field that is not a known type (an
  uppercase name like `T`) is a type parameter.
- **The results are used**, not only computed. Every expression's type
  reaches code generation, which picks `print`'s format (`%lld`, `%f`,
  `%s`), String comparison and Float arithmetic from it — for a `Vec`
  element, a struct field, a pattern-bound name, a closure capture or the
  result of a generic call alike. Trait calls are resolved from it
  (Chapter 20), and a function whose body depends on a type parameter is
  instantiated per concrete type (15.8).
- `ZYL_DEBUG_TYPES=1` prints every function's inferred type while
  compiling; the REPL's `:type` shows an expression's type.

### What it does not do

- **It does not reject type errors.** A unification failure marks the
  type variables involved as unknown, and code generation falls back to
  what the literals and annotations say. All three of these compile
  without a diagnostic:

  ```lisp
  (defn add ((a Int) (b Int)) (+ a b))

  (defn main ()
    (begin
      (print (+ 1 "a"))       ; adds a string's address to 1
      (print (add 1 "x"))     ; annotation not enforced
      (print (+ 1.5 2))       ; wrong: Int and Float mixed
      0))
  ```

- **It does not check annotations against known types.** An unknown name
  such as `(v Bogus)` is accepted.
- **Heterogeneous data loses its type.** A list holding a `Circle` and a
  `Rect` has no single element type; values read from it are treated as
  plain words (and trait calls on them use the runtime fallback).

### Annotations

A parameter may be annotated as `(name Type)`, where `Type` is a name
such as `Int`, `Float`, `Bool`, `String`, `Unit`, `Byte`, a struct or ADT
name, or `Secret`/`(Secret Int)` (Chapter 17):

```lisp
(defn half ((x Float)) (/ x 2.0))

(defn main ()
  (begin
    (print (half 5.0))   ; 2.500000
    0))
```

Annotations are optional (§0 P7): inference usually finds the same
type without them. They are not enforced. There is no return-type
annotation and no annotation on `let`.

## 15.7 Type Errors

| Code | Status |
|------|--------|
| `E_INVALID_CAPABILITY` | **Raised** by `mutability_check` (before inference) when a lambda is passed to `ffi-call`; a named top-level function may be passed, as a C callback. Type inference itself raises no errors. |
| `E_BYTE_VALUE_OOB` | **Raised** by the parser for `(byte N)` outside 0–255. |
| `E_TYPE_MISMATCH` | Catalogued in `error_codes.zyl`; never raised. |
| `E_RETURN_TYPE_MISMATCH` | Catalogued; never raised. |
| `E_UNKNOWN_TYPE` | Catalogued; never raised. |
| `E_CANNOT_INFER` | In §28 and §6.7; never raised (Chapter 19). |
| `E_TRAIT_BOUND_NOT_SATISFIED` | In §6.7; never raised (Chapter 19). |

Other checks run before type inference and do report errors, for example
`E_UNBOUND_VARIABLE`, `E_ARITY_MISMATCH`, `E_MUT_CONFLICT` and the match
checks of Chapter 18. They are covered in the chapters for those
features.

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

The hidden size word is what lets `==`, `<` and `assert-equal` compare two
separately allocated aggregates structurally (`zyl_variant_eq` and
`zyl_variant_cmp` in `runtime/actor_runtime.c`). The comparison is
shallow: fields that are pointers, including strings, are compared by
address.
