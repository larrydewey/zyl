# Chapter 19: Generic Programming and Monomorphization

This chapter is the reference for generics: generic functions, generic
ADTs, type-parameter constraints and monomorphization. The normative text
is `zyl_specification.txt` §6 (generics) and §17 (monomorphization),
formalized in v4.2 (§30). The implementation is
`stdlib/compiler/type_annotate.zyl` (inference and per-type instances)
and `stdlib/compiler/monomorphization.zyl` (impl lifting).

The specification and the compiler diverge further here than anywhere
else in Part II:

- **Generic ADTs** work and are tested.
- **Explicit generic-function syntax** (§6.1) does not work.
- **Polymorphic functions** exist all the same: an unannotated
  parameter gets a type variable, and the function is generalized.

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

A function whose parameters are unannotated is generic: inference gives
it a type scheme, instantiated at each call site (19.4).

```lisp
(defn first-of (a _) a)

(defn smaller (a b)
  (if (< a b) a b))

(defn main ()
  (begin
    (print (first-of 5 "s"))           ; 5
    (print (first-of "a" 2))           ; a
    (print (smaller 3 5))              ; 3
    (print (smaller "b" "a"))          ; a
    0))
```

A call's result has its instantiated type, so `print` formats it
correctly. `smaller` compares Strings as text and Ints as numbers,
because its body depends on the type of `a` and is therefore compiled
once per argument type (19.3).

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

Specialization happens in the type annotation pass
(`type_annotate.zyl`), after inference, at the close of each strongly
connected component of the call graph:

- **Which functions it specializes.** Because every value is one word,
  most generic functions need only one body. A function gets per-type
  instances only when its body *depends* on a type variable: it prints a
  value of that type, compares one (`=`, `<`, ...), does arithmetic on
  one, or calls a trait method on one — directly or through another such
  function. These are *trait-generic*.
- **Instances.** Each call of a trait-generic function with concrete
  argument types gets an instance, a copy of the body typed with those
  types, so everything type-dependent inside it resolves. The call is
  redirected to the instance; calls inside the instance may create more.
  A variable that only the call site mentions and nothing can fix (the
  error type of `(Ok "yes")`) defaults to `Int`. At most 32 instances are
  made per function; beyond that, calls use the shared body.
- **Naming.** An instance is named by the function's key, `~`, and its
  argument types in order, fully spelled: `smaller~String,String`,
  `show~(Vec String)` style keys. Distinct type tuples always get distinct
  names; the spec's sorted `f_Int_String` form is not used.
- **Impl methods.** `monomorphization.zyl` lifts an impl method body to a
  top-level function named `Trait.method_Type` (Chapter 20). An impl for a
  generic type (`(impl Show Vec ...)`) is itself trait-generic when it
  calls a trait method on the element type, and is instantiated per
  element type.

The name the linker sees is then mangled from the canonical symbol key
(§31.2), for example
`zy_local_x2Fmain_0__prog__Area_x2Earea_5F...Point` for `Area.area_Point`
in a program `prog.zyl`. The exact spelling is an implementation detail.

## 19.4 Per-Call-Site Inference

Top-level functions are generalized (let-polymorphism): a function's
type is inferred once, with the functions it calls first, and each call
site instantiates it with fresh type variables. That is how one ADT or
function can be used at `Int` and `String` in the same program. Mutually
recursive functions are inferred together.

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

`(derive T Show)` works on generic ADTs (§6.6); the generated `show`
is instantiated per concrete type argument (Chapter 20).

## 19.6 Constraints from Usage

What the compiler derives from the body instead of from a declaration:

- Type inference unifies the uses of a parameter. A body that adds 1 to
  `x` gives `x` the type `Int` at that site.
- A failed unification is not an error (Chapter 15). It marks the
  variables involved as unknown.
- Usage therefore guides code generation, such as print formats, String
  comparison and float arithmetic, and which instances are made, but it
  rejects nothing.

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

In the current compiler, a polymorphic function is compiled once unless
its body depends on a type variable (19.3); those get one instance per
concrete argument-type tuple used, capped at 32. Impl methods add one
function per `(Trait, Type)` pair.

## 19.10 Comparison with Rust

| Feature | Rust | Zyl (specification) | Zyl (today) |
|---------|------|---------------------|-------------|
| Syntax | `fn foo<T: Trait>(x: T)` | `(defn foo ((T : Trait) x) ...)` | unannotated `(defn foo (x) ...)` |
| Specialization | monomorphized | monomorphized | shared body; per-type instances where the body depends on the type |
| Naming | mangled | `fn_Type1_Type2...`, sorted | `key~T1,T2`, then mangled (§31.2) |
| Type checking | enforced | HM + trait resolution | HM + static trait resolution, not enforced |
| Bounds | enforced | enforced | not expressible |
| Higher-kinded types | no (GATs cover some uses) | no | no |
| Const generics | yes | no | no |
