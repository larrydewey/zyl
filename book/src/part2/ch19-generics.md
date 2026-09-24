# Chapter 19: Generic Programming and Monomorphization

This chapter is the reference for generics: generic functions, generic
ADTs, type-parameter constraints and monomorphization. The normative text
is `zyl_specification.txt` §6 (generics) and §17 (monomorphization),
formalized in v4.2 (§30). The implementation is
`stdlib/compiler/type_inference.zyl` (per-call-site inference) and
`stdlib/compiler/monomorphization.zyl`.

The specification and the compiler diverge further here than anywhere
else in Part II:

- **Generic ADTs** work and are tested.
- **Explicit generic-function syntax** (§6.1) does not work.
- **Polymorphic functions** exist all the same, because an unannotated
  parameter accepts a value of any type.

## 19.1 Generic Functions

### Specified syntax (§6.1)

```
(defn name ((TypeParam : TraitBound*) ... (param Type) ...) body)
```

```lisp
(defn identity ((T) x) x)                      ; one type parameter
(defn min ((T : Ord) a b) (if (< a b) a b))    ; bounded
(defn pair ((T) (U) x y) ...)                  ; two type parameters
(defn show-sorted ((T : Ord Show) xs) ...)     ; two bounds
```

Rules from §6.1 and §6.2:

1. Type parameters are uppercase identifiers, by convention.
2. A type parameter is scoped to its own `defn`, and shadowing it in a
   nested `defn` is an error.
3. Parameters are positional, but specialization names do not depend on
   their order (§6.4).
4. Every occurrence of one parameter must be the same concrete type.
5. Type parameters appear only in type positions, never as runtime
   values.

### What the compiler does with it

None of these declarations compile as intended:

| Written | Read as | Result |
|---------|---------|--------|
| `((T) x)` | a one-element list in parameter position | `E_MALFORMED_PARAMETER` |
| `((T : Ord) a b)` | the lexer merges `: Ord` into the keyword `:Ord`, so this is `(T :Ord)` | an ordinary *value* parameter named `T`. The function takes one more argument than intended, and `(min 3 5)` is `E_ARITY_MISMATCH`. |

**Do not write type-parameter groups.**

### What works: unannotated parameters

Every Zyl value is one 64-bit word (Chapter 15), so a function whose
parameters are unannotated already accepts arguments of any type. Type
inference re-infers such a function at each call site (19.4).

```lisp
(defn first-of (a _) a)

(defn smaller (a b)
  (if (< a b) a b))

(defn main ()
  (begin
    (print-int (first-of 5 "s"))       ; 5
    (print-string (first-of "a" 2))    ; a
    (print-int (smaller 3 5))          ; 3
    0))
```

Two caveats:

- **Printing polymorphic results.** Types do not flow back out of a
  polymorphic call into `print`. `(print (first-of "a" 2))` formats the
  string as an integer (Chapter 15, 15.6). The typed `print-int`,
  `print-string` and `print-float` avoid this.
- **Operators are not overloaded.** `<` compares machine words, and
  structural comparison applies only to values the code generator knows
  are ADTs (Chapter 18). Calling `smaller` on two strings compares their
  addresses.

## 19.2 Generic ADTs

Generic ADTs (§6.5) are the supported, tested case
(`tests/regression/generics.zyl`, `generics-multi-type.zyl`).

```lisp
(deftype Maybe (Just T) (Nothing))             ; T from Just
(deftype Outcome (Success T) (Failure E))      ; T and E
(deftype Seq (Item T (Seq T)) (End))           ; recursive
(deftype Tree (Node T (Tree T) (Tree T)) (Leaf))
```

The prelude's `Option`, `Result` and `List` are declared the same way
(Chapter 15).

- **Parameters** are the uppercase field names. A name that repeats is
  one parameter, which §6.2 constrains to one type.
- **Separate instances.** `Maybe<Int>` and `Maybe<String>` are distinct
  instances (§6.5). One ADT may be used at several types in one program
  without the instances interfering; this is the regression
  `generics-multi-type.zyl` guards.
- **Same-type constraint.** Not enforced: `(Make 1 "hi")` for
  `(deftype Pair (Make T T))` compiles.
- **Generic structs** are not supported (§6.5).

## 19.3 Monomorphization

### Specified algorithm (§6.4, §17)

For each call site of a generic function:

1. Infer concrete types for all type parameters from the arguments. A
   parameter with no evidence at any call site is `E_CANNOT_INFER`,
   unless a trait bound selects a finite set.
2. Verify the trait bounds (`E_TRAIT_BOUND_NOT_SATISFIED`).
3. Generate a specialization named `functionName_Type1_Type2_...`, with
   the types sorted alphabetically, so `f<Int, String>` and
   `f<String, Int>` share one name, and distinct type maps get distinct
   names.
4. Cache the specialization for other sites with the same types.

```
(min 3 5)       → min_Int
(min "a" "b")   → min_String
(pair 1 "hi")   → pair_Int_String
(pair 1.0 2.0)  → pair_Float
```

### Implementation

`monomorphization.zyl` runs after type inference (§22 Phase 5).

- **Which functions it specializes.** It treats a parameter whose name
  starts with an uppercase letter as a type parameter. Since
  type-parameter groups do not parse (19.1), ordinary user functions are
  compiled once, and every call site shares that one body. That is
  correct because of the uniform one-word representation.
- **Impl methods.** An impl method body is lifted to a top-level function
  named `Trait.method_Type` (Chapter 20).
- **Generic ADTs** have their concrete instantiations recorded for
  constructors and matches.
- **Naming.** `canonical-name-from-type-map` builds the base name, `_`,
  then the concrete type names deduplicated, sorted and joined with `_`.
  This meets "order-independent" but not "distinct maps give distinct
  names":
  - `f<Int, Int>` and `f<Int>` get the same name;
  - a compound type is named only by its outer constructor (`List`,
    `Fn`), so `f<List<Int>>` and `f<List<String>>` collide.
- **Bounded parameters.** A bounded type parameter gets one instantiation:
  the first type that satisfies the bound.

The name the linker sees is then mangled from the canonical symbol key
(§31.2), for example
`zy_local_x2Fmain_0__prog__Area_x2Earea_5F...Point` for `Area.area_Point`
in a program `prog.zyl`. The exact spelling is an implementation detail.

## 19.4 Per-Call-Site Inference

For a function with unannotated parameters, inference does not generalize
a type scheme. It infers the body again at each call site with that
site's argument types, and caches the result under the key
`name::ArgType1,ArgType2,...`. That is how one ADT can be used at `Int`
and `String` in the same program.

A recursive generic function works the same way. The recursive call has
the same argument types, so it reuses the cached result:

```lisp
(defn count-items (xs)
  (match xs
    (Nil 0)
    (Cons _ rest (+ 1 (count-items rest)))))

(defn main ()
  (begin
    (print (count-items (Cons 1 (Cons 2 Nil))))    ; 2
    (print (count-items (Cons "a" Nil)))           ; 1
    0))
```

## 19.5 Trait Bounds

§6.4 requires each call site's concrete types to satisfy the declared
bounds. With no way to declare a bound (19.1), nothing is checked.

The monomorphizer's own bound check (`check-trait-bound`) accepts every
primitive type for every trait. For other types it looks for a matching
`impl`, but no source construct reaches it.

`derive` on generic ADTs (§6.6) is covered in Chapter 20, and is
currently a no-op.

## 19.6 Constraints from Usage

What the compiler derives from the body instead of from a declaration:

- Type inference unifies the uses of a parameter. A body that adds 1 to
  `x` gives `x` the type `Int` at that site.
- A failed unification is not an error (Chapter 15). It leaves a type
  variable.
- Usage therefore guides code generation, such as print formats and float
  arithmetic, but it constrains nothing.

## 19.7 Errors

| Code | Condition (§6.7) | Status |
|------|------------------|--------|
| `E_CANNOT_INFER` | a generic parameter with no call-site evidence | catalogued; never raised |
| `E_TRAIT_BOUND_NOT_SATISFIED` | a concrete type violates a bound | catalogued; never raised |
| `E_UNKNOWN_GENERIC_PARAM` | reference to an undeclared type parameter | catalogued; never raised |
| `E_TRAIT_NOT_DERIVABLE` | a derive constraint fails | catalogued; never raised |
| `E_MALFORMED_PARAMETER` | `((T) x)`: not a name or `(name Type)` | raised |
| `E_ARITY_MISMATCH` | follows from `((T : Ord) ...)` adding a value parameter | raised |

§6.1 makes shadowing a type parameter in a nested `defn` an error, but it
assigns no code.

## 19.8 Higher-Kinded Types

Not supported in v5.0. Type parameters range over proper types, not type
constructors:

```lisp
;; NOT SUPPORTED:
(defn lift ((F : Functor) (T) ft) ...)   ; F would be * -> *
```

There are no associated types either (Chapter 20). Write the operation
for each concrete container, or pass the operations in as function
arguments.

## 19.9 Code Size

In the specification, each distinct combination of types produces a new
function, which can grow code size; dead-code elimination (Phase 7) and
the cache of step 4 limit that.

In the current compiler, a polymorphic user function is compiled exactly
once, so generics add no code. The per-type copies that do exist are impl
methods, one per `(Trait, Type)` pair.

## 19.10 Comparison with Rust

| Feature | Rust | Zyl (specification) | Zyl (today) |
|---------|------|---------------------|-------------|
| Syntax | `fn foo<T: Trait>(x: T)` | `(defn foo ((T : Trait) x) ...)` | unannotated `(defn foo (x) ...)` |
| Specialization | monomorphized | monomorphized | one shared body; per-site type inference |
| Naming | mangled | `fn_Type1_Type2...`, sorted | canonical symbol key, then mangled (§31.2) |
| Type checking | enforced | HM + trait resolution | inferred, not enforced |
| Bounds | enforced | enforced | not expressible |
| Higher-kinded types | no (GATs cover some uses) | no | no |
| Const generics | yes | no | no |
