# Zyl Specification — Structs and Data Types

**Canonical authority:** `zyl_specification.txt` §2 (struct forms), §3 (StructValue), §4.2, §8, §10 (mutability), §12.3, §21.11, §21.12
**Related:** `spec/04-evaluation-semantics.md`, `spec/05-types-and-inference.md`
**Implementation:** `stdlib/compiler/expr_inner.zyl` (`parse-defstruct`, `parse-match-arm`, literal-pattern desugaring), `stdlib/compiler/icnf.zyl`, `stdlib/compiler/exhaustiveness_check.zyl`, `stdlib/compiler/codegen.zyl`

---

## 8. Algebraic Data Types (ADTs)

### 8.1 ADT Declaration

```lisp
(deftype Name (Variant1 TypeExpr*) (Variant2 TypeExpr*) ...)
```

### 8.2 Variant Construction

```lisp
(Some 42)    ; constructs Some variant with value 42
None         ; constructs None variant
(Red)        ; constructs Red variant (no fields)
```

In the implementation, a name is a constructor when it is registered as a
variant of a declared `deftype`; a zero-field variant may be written bare
(`None`) or applied (`(Red)`).

### 8.3 Pattern Matching

```lisp
(match Expr (VariantName pattern* body) ...)
```

Exhaustiveness required. Missing cases = Compile Error (`E_MATCH_NONEXHAUSTIVE`).

### 8.4 ADTs and Generics

```lisp
(deftype Option (Some T) None)
```

Monomorphized per concrete type.

---

## Struct System

### Syntax (§2)

```lisp
(defstruct Name (Field*) (:derive [Trait*])?)
(defstruct+ Name (Field*) (:derive [Trait*])?)
Field := (Name TypeExpr)
```

`defstruct+` has the same grammar as `defstruct`; the canonical text does
not distinguish their semantics further.

### Constructor

```lisp
(make-StructName val1 val2 ...)
```

Auto-generated for every `defstruct` (§2, `make-Name`).

### Field Access (§21.11)

```lisp
(struct-get struct field-name)
```

Retrieves a field value. `(defstruct Point (x) (y))` also defines one accessor per field,
`Point.x` and `Point.y`: each is `(defn Point.x ((p Point)) (struct-get p "x"))`,
an ordinary typed function generated before type checking, so it is a
value like any other function and has the field's type. `defstruct+`
generates them too. A program definition of the same name is
`E_DUPLICATE_DEFINITION`, reported at the program's definition and naming
the `defstruct`. In a package an accessor is visible as its struct is.
`struct-get` and dot syntax are unchanged.

### Struct Immutability (§10)

Fields defined in `defstruct` are **immutable by default**.

**Mutation requires rebinding the entire struct:**
```lisp
(let-mut p (make-Point 10 20)
  (set! p (make-Point 30 20)))  ; OK: rebinding
```

**Direct field mutation is FORBIDDEN:**
```lisp
(set! (struct-get p "x") 5)     ; rejected
```

### Struct Region

Per R1/R2, a struct instance that does not escape may live on the Stack;
one that escapes is promoted to the Heap.

---

## 10. Mutability and Aliasing (Struct Context)

- Struct instances are immutable: no in-place field mutation
- Rebinding requires a `let-mut` binding
- Alias transparency: aliases are zero-cost; no runtime unwrap is needed
  unless explicitly called

---

## Aliases (§4.2, §4.7, §21.12)

```lisp
(alias Name TypeExpr)
(unwrap alias-val)      ; explicit extraction (usually implicit)
```

An alias is a transparent, zero-cost wrapper. Type equality for aliases is
nominal, but an alias is coerced to its target (and back) without runtime
cost.

---

## Value Model: StructValue

```
StructValue(Name, Map<Name, V>)
```

Immutable aggregate. Fields cannot be mutated in place.
Mutation requires rebinding the entire struct instance.

---

## Implementation Notes

Not normative.

### Structs

- `defstruct` is sugar for a single-variant `deftype`. A field is a bare
  name or `(name Type)`. A declared field type is checked: a value of
  another type is `E_TYPE_MISMATCH` (`ta-check-fields`); a bare field is
  an implicit type parameter of the struct
  (`spec/05-types-and-inference.md`). `defstruct+` is parsed by the same
  function as `defstruct`.
- An inline `(:derive [Trait ...])` after the fields is accepted by both
  `defstruct` and `defstruct+` and means the same as the standalone
  `(derive Name Trait...)` form (see `spec/05-types-and-inference.md`).
- `make-Name` lowers to a variant construction. `(make-struct Name args...)`
  is parsed, but the type checker has no rule for it
  (`E_CANNOT_INFER`, "no type for form"), so only `make-Name` compiles.
- `struct-get` accepts the field name as a string, `(struct-get p "x")`,
  which is what the tests use, or as a bare symbol.
- A struct or variant is a block `[tag][field0]...`, allocated in the
  frame region, the caller's result region or the heap as region
  inference places the construction; a let-bound value used solely as a
  `match` subject or a `print` argument is moved into the stack frame
  (`spec/07-region-memory-model.md`). An update of a unique, dead value
  may write the new record into the old one's block (`reuse.zyl`).
- `set!` on anything but a plain `let-mut` name is rejected by the parser
  with `E_MUT_CONFLICT`.

### Aliases

`(alias Name T)` is transparent: the type checker reads `Name` as `T`
wherever a type is written (parameter annotations, field types, `extern`
signatures), so `((m Meters))` after `(alias Meters Int)` takes exactly
an `Int` and a value of either spelling fits the other. It emits no code.
The target must name existing types (`E_UNKNOWN_TYPE` otherwise, located
at the alias), an alias may name another, and one that reaches itself is
`E_UNKNOWN_TYPE`. An alias takes no type parameters. `alias` names are
definitions (qualified, `pub`-able, importable). `(unwrap x)` takes an `Option`: `(Some v)` gives `v` and `None`
panics with `unwrap on None`; the library functions `result-unwrap` and
`option-unwrap` (which take a default) cover `Result` and defaults.

### Pattern matching

- **Constructor patterns:** `(Variant field... body)` or
  `((Variant field...) body)`. Each field is bound to a name or `_`; a
  nested pattern such as `(Wrap (Some x) x)` is `E_NESTED_PATTERN`
  (match on the field in the arm body instead).
- **Catch-all:** `_`. A lowercase identifier that is not a known variant
  also acts as a catch-all, binding the subject; the convention is to
  write `_` or a `_`-prefixed name. An arm head whose first letter is A-Z
  that no type in the program declares is `E_UNKNOWN_CONSTRUCTOR`, so a
  misspelled constructor cannot silently become a catch-all; the message
  suggests the nearest declared constructor within edit distance 2
  (smallest distance, then alphabetical).
- **Literal patterns:** integer and string literals, `(0 body)`,
  `("x" body)`. A match with any literal arm is desugared into an `if`
  chain over the subject, evaluated once. It must end with a `_` arm,
  otherwise `E_MATCH_NONEXHAUSTIVE`. Literal and constructor arms cannot be
  mixed in one match.
- **OR-patterns:** several literals before the body, `(10 11 body)`.
- **Range patterns:** `((range lo hi) body)`, inclusive at both ends.
- **Guards:** `(pattern (when cond) body)`, on literal matches only. The
  guard cannot refer to anything bound by the pattern (literal patterns
  bind nothing), and a guard on the final `_` arm is ignored.
- **Exhaustiveness (§8.3):** `exhaustiveness_check.zyl` rejects a
  constructor match that misses a variant with `E_NON_EXHAUSTIVE_MATCH`,
  a catch-all that is not last, or a duplicated arm, with
  `E_UNREACHABLE_MATCH_ARM`, and a capitalized arm head that is not a
  declared constructor with `E_UNKNOWN_CONSTRUCTOR`. Other paths use the canonical spelling
  `E_MATCH_NONEXHAUSTIVE`, which is the one in `error_codes.zyl`. The
  canonical grammar does not describe literal, OR or range patterns or
  guards.
- A match arm whose body combines a constant with two or more calls in
  one arithmetic expression is rejected with `E_MATCH_ARM_COMPLEX`; nest
  such sums through helper functions.
