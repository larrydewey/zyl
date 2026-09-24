# Chapter 7: Generics and Traits

Zyl's specification has parametric polymorphism (generics) and ad-hoc
polymorphism (traits), both resolved at compile time with full type
inference. The current compiler supports a practical subset: generic
ADTs, polymorphic functions written without annotations, and trait
`impl` blocks called through qualified names. This chapter shows what
works, and what the specified syntax does today. Chapters 19 and 20 are
the full reference.

## 7.1 Generic Functions

### Polymorphic Functions: Leave Parameters Unannotated

Every Zyl value is one 64-bit word, so a function whose parameters carry
no type annotation already accepts arguments of any type. Type
inference analyzes such a function separately at each call site, with
that site's argument types.

```lisp
(defn first-of (a _) a)

(defn choose (c t f)
  (if c t f))

(defn smaller (a b)
  (if (< a b) a b))

(defn main ()
  (begin
    (print-int (first-of 5 "s"))             ; 5
    (print-string (first-of "a" 2))          ; a
    (print-string (choose true "yes" "no"))  ; yes
    (print-int (smaller 3 5))                ; 3
    0))
```

Two things to know:

- **Print polymorphic results with a typed printer.** The type of a
  polymorphic call's result does not flow back into `print`, so
  `(print (first-of "a" 2))` prints the string's address. `print-int`,
  `print-string` and `print-float` say what to print.
- **Operators are not overloaded.** `<` compares machine words. On two
  strings, `smaller` compares their addresses. (On two struct or ADT
  values the comparison operators do compare fields — Chapter 4, §4.9.)

The core library already defines `identity`, `min`, `max`, `abs`,
`compose` and a few others. Defining a function with one of those names
is `E_DUPLICATE_DEFINITION`, so pick another name (as `smaller` does
here).

### The Specified Syntax

The specification (§6.1) declares type parameters explicitly, each in
its own parentheses and optionally with trait bounds:

```lisp
(defn identity ((T) x) x)                       ; one type parameter
(defn smallest ((T : Ord) a b) (if (< a b) a b)) ; with a bound
```

**Do not write these today.** The compiler does not implement them:

| Written | What happens |
|---------|--------------|
| `((T) x)` | `E_MALFORMED_PARAMETER`: `(T ...)` is not a parameter |
| `((T : Ord) a b)` | The lexer reads `: Ord` as the keyword `:Ord`, so `(T :Ord)` becomes an ordinary *value* parameter named `T`. The function then takes three arguments, and `(smallest 3 5)` is `E_ARITY_MISMATCH`. |

```
PANIC: error[E_MALFORMED_PARAMETER]: `(T ...)` is not a parameter - write a name, or (name Type)
```

The specification's rules for type parameters — scoped to one function,
the same concrete type for every occurrence, only in type positions —
describe the intended design; since the syntax is not accepted, none of
them is checked yet.

## 7.2 Generic ADTs

Generic ADTs work and are tested. A field type that is an uppercase
name that is not a known type is a type parameter:

```lisp
(deftype Maybe (Just T) (Nothing))            ; one parameter, T
(deftype Outcome (Success T) (Failure E))     ; two parameters, T and E
(deftype Pair (Make T T))                     ; T twice: one parameter
(deftype Tree (Node T (Tree T) (Tree T)) (Leaf))
```

The core library's `Option`, `Result` and `List` are declared the same
way. One generic ADT can be used at several types in the same program:

```lisp
(deftype Maybe (Just T) (Nothing))

(defn maybe-or (m d)
  (match m
    (Just x x)
    (Nothing d)))

(defn count-items (xs)
  (match xs
    (Nil 0)
    (Cons _ rest (+ 1 (count-items rest)))))

(defn main ()
  (begin
    (print-int (maybe-or (Just 4) 0))                ; 4
    (print-string (maybe-or (Just "hi") "none"))     ; hi
    (print-string (maybe-or (Nothing) "default"))    ; default
    (print (count-items (Cons 1 (Cons 2 Nil))))      ; 2
    (print (count-items (Cons "a" Nil)))             ; 1
    0))
```

The type arguments are inferred from the field values; you never write
them. The specification's same-type constraint — `(Make 1 "hi")` should
be rejected because both fields are `T` — is not enforced: it compiles.
Generic *structs* are not supported (§6.5 of the specification).

## 7.3 Traits — Ad-Hoc Polymorphism

A trait names a set of methods that several types can implement.

### Declaration

```lisp
(trait Area
  (area self))
```

A declaration lists the method names and their parameters. In the
current compiler it serves mainly as documentation: the method list is
not recorded, and an `impl` is not checked against it. It does matter
in one case, the orphan rule (§7.4).

### Implementation and Calls

```lisp
(defstruct Rect (w) (h))
(defstruct Circle (r))

(trait Area
  (area self))

(impl Area Rect
  (defn area (self) (* (struct-get self "w") (struct-get self "h"))))

(impl Area Circle
  (defn area (self) (* 3 (* (struct-get self "r") (struct-get self "r")))))

(defn total-area (a b)
  (+ (Area.area a) (Area.area b)))

(defn main ()
  (begin
    (print (Area.area (make-Rect 3 4)))                    ; 12
    (print (Area.area (make-Circle 2)))                    ; 12
    (print (total-area (make-Rect 1 2) (make-Circle 1)))   ; 5
    0))
```

- **Call a method by its qualified name**, `(Trait.method receiver
  args...)`. A bare `(area r)` does not find it: it fails at link time
  with an undefined reference.
- **The receiver is the first argument.** Calling it `self` is
  convention. Further parameters follow it as usual:
  `(defn scale (self k) ...)`, called as `(Scale.scale r 3)`.
- The method's parameters are whatever the `defn` inside the `impl`
  says; there are no default method bodies.

### How a Call Finds Its Method

The specification resolves trait calls statically, from types. The
current compiler instead turns each `(Trait.method recv ...)` into a
`match` on the receiver's runtime tag, with one arm per implementing
type. That works well for structs, because each struct has its own tag:

```lisp
(defstruct Circle (r))
(defstruct Rect (w) (h))

(trait Describe (describe self))

(impl Describe Circle
  (defn describe (self) (begin (print-string "circle") (struct-get self "r"))))

(impl Describe Rect
  (defn describe (self) (begin (print-string "rect") (* (struct-get self "w") (struct-get self "h")))))

(defn describe-all (xs)
  (match xs
    (Nil 0)
    (Cons x rest (+ (Describe.describe x) (describe-all rest)))))

(defn main ()
  (print (describe-all (Cons (make-Circle 2) (Cons (make-Rect 3 4) Nil)))))
;; circle
;; rect
;; 14
```

A list of different struct types, each dispatched to its own impl,
behaves like dynamic dispatch over a closed set of types.

It does not work for every combination:

- **A trait with exactly one impl** always works, whatever the type:
  a struct, an ADT or a primitive such as `Int`.
- **Several impls where one is for a multi-variant ADT or a primitive
  type** dispatch wrongly. An ADT's name is not one of its variants, so
  its arm catches every receiver. With `(impl Show Int ...)` next to
  `(impl Show Point ...)`, a `Point` receiver runs the `Int` impl.

> **Compiler defect.** A trait call written directly as the first
> argument of `struct-get` is not rewritten, and the program fails to
> link:
>
> ```lisp
> (struct-get (Scale.scale r 3) "h")     ; undefined reference to `_ZYL_Scale_scale'
> ```
>
> Bind the result first: `(let r2 (Scale.scale r 3) (struct-get r2 "h"))`.

Until dispatch uses static types, implement traits for structs, or give
a trait over an ADT or primitive type a single impl.

### The Standard Library's Trait

The standard library defines one trait, `OutputStream` in `io/io`, with
impls for `Stdout` and `StringBuffer`:

```lisp
(use io/io)

(defn main ()
  (let out (make-stdout)
    (begin
      (OutputStream.write out "hello\n")
      (OutputStream.flush out)
      0)))
```

## 7.4 Coherence Rules

The specification (§5.3) has three coherence rules:

```
C1. One impl per (Trait, Type) pair.
C2. Orphan rule: impl valid only if trait or type defined in current crate.
C3. No conflicting impls.
```

- **C1** is not checked by a compiler pass. Two `(impl Area Rect ...)`
  blocks both define the same function, and the build fails in the
  assembler with "symbol ... is already defined", not with
  `E_DUPLICATE_IMPL`.
- **C2** applies at the package boundary (spec §24.6) and is enforced:
  an impl is allowed only if your package defines the trait or the
  type. Otherwise it is `E_PKG_ORPHAN_IMPL`. This is where a `trait`
  declaration matters: `(impl Describe Int ...)` with no
  `(trait Describe ...)` in your program is rejected, because neither
  the trait nor `Int` is yours.

  ```
  PANIC: E_PKG_ORPHAN_IMPL: trait: impl of Describe for Int where neither the trait nor the type is local to local/main
  ```

- **C3** cannot arise except as a C1 duplicate: an `impl` names a single
  type, so generic impls such as `(impl Container (Vec T) ...)` cannot
  be written.

## 7.5 Trait Bounds and Resolution

In the specification, a bound such as `(T : Ord)` requires every call
site's concrete type to implement the trait, and trait resolution
happens during type inference: collect the bounds, substitute the
concrete types at each call, find the impl, verify the bound. Since
bounds cannot be written (§7.1), none of this is checked, and a
`Trait.method` call with no impl at all fails at link time rather than
with `E_TRAIT_NOT_FOUND`.

## 7.6 Monomorphization

The specification generates a specialized copy of a generic function for
each distinct combination of concrete types, named
`functionName_Type1_Type2...` with the type names sorted alphabetically
so the name does not depend on parameter order:

```
(smallest 3 5)       → smallest_Int
(smallest "a" "b")   → smallest_String
(pair 1 "hi")        → pair_Int_String
```

The current compiler does not need these copies. Because every value is
one word, a polymorphic function is compiled once, and every call site
shares that body; only type inference is repeated per call site. The
per-type functions that do exist are impl methods: each method body
becomes a function named `Trait.method_Type`, such as `Area.area_Rect`.
Chapter 19 describes the naming and its limits.

## 7.7 Deriving Traits

The specification lets you derive `Eq`, `Ord`, `Show`, `Debug`, `Clone`
and `Hash`, inline on `defstruct+` or with a standalone `derive`:

```lisp
(defstruct+ Pt (x) (y) (:derive [Eq Ord]))
(derive Pt Eq Ord)
```

Both forms are accepted and currently do nothing: no impl is generated,
no field requirement is checked, and even an unknown trait name is
accepted. You get the same behavior with or without them:

- `==` and `!=` compare two struct or ADT values field by field;
- `<`, `>`, `<=` and `>=` compare the fields lexicographically;
- both are shallow: a string or nested-value field is compared by
  address;
- `print` of a struct prints its address — there is no derived `Show`.

```lisp
(defstruct Pt (x) (y))

(defn main ()
  (let a (make-Pt 1 2)
    (let b (make-Pt 1 2)
      (let c (make-Pt 2 0)
        (begin
          (print (== a b))    ; 1
          (print (== a c))    ; 0
          (print (< a c))     ; 1 (1 < 2 in the first field)
          0)))))
```

## 7.8 Traits and Capability Types

The specification does not define impls on capability types, and
capability types cannot be written in source (Chapter 5). An `impl`
names a plain type: a struct, an ADT or a primitive.

There are no trait objects (`dyn Trait`) either. Where you would use
one, use a list of structs dispatched by tag (§7.3), or an ADT wrapper:

```lisp
(defstruct Circle (r))
(defstruct Rect (w) (h))

(deftype Shape (CircleShape Circle) (RectShape Rect))

(defn shape-area (s)
  (match s
    (CircleShape c (* 3 (* (struct-get c "r") (struct-get c "r"))))
    (RectShape r (* (struct-get r "w") (struct-get r "h")))))

(defn main ()
  (begin
    (print (shape-area (CircleShape (make-Circle 1))))   ; 3
    (print (shape-area (RectShape (make-Rect 2 5))))     ; 10
    0))
```

## 7.9 Practical Example: A Generic Map

```lisp
(defn my-map (f xs)
  (match xs
    (Nil Nil)
    (Cons x rest (Cons (f x) (my-map f rest)))))

(defn double (x) (* x 2))

(defn main ()
  (print (list-sum (my-map double (Cons 1 (Cons 2 (Cons 3 Nil)))))))   ; 12
```

`my-map` works for any element type. Pass it a named function or any
`fn`, capturing or not (Chapter 3, §3.3). The module
`collections/collections` has a ready-made `list-map`.

## 7.10 Error Messages

| Error | Cause | Status |
|-------|-------|--------|
| `E_MALFORMED_PARAMETER` | `((T) x)`: a type-parameter group | raised |
| `E_ARITY_MISMATCH` | follows from `((T : Ord) ...)` adding a value parameter | raised |
| `E_DUPLICATE_DEFINITION` | a function with the same name as one in the core library | raised |
| `E_PKG_ORPHAN_IMPL` | impl where neither the trait nor the type is yours | raised |
| `E_CANNOT_INFER` | generic parameter with no call-site evidence | in the specification; never raised |
| `E_TRAIT_BOUND_NOT_SATISFIED` | concrete type lacks a bound's trait | in the specification; never raised |
| `E_TRAIT_NOT_DERIVABLE` | a field lacks the derived trait | in the specification; never raised |
| `E_DUPLICATE_IMPL` | two impls for one (Trait, Type) | in the specification; fails in the assembler instead |
| `E_TRAIT_NOT_FOUND` | no impl for a required trait | in the specification; fails at link time instead |

---

## For Experts: Under the Hood

### Per-Call-Site Inference

For a function with unannotated parameters, type inference does not
generalize a type scheme. It infers the body again at each call site
with that site's argument types, and caches the result under a key built
from the function name and the argument types. A recursive call with the
same argument types reuses the cached result. Type errors found this way
are not reported (Chapter 15); the inferred types guide code generation
(print formats, float arithmetic) but do not reject programs.

### Canonical Naming

`canonical-name-from-type-map` in `stdlib/compiler/monomorphization.zyl`
builds a name from the base name and the concrete type names,
deduplicated, sorted and joined with `_`. The name the linker finally
sees is mangled from the canonical symbol key of the package system
(spec §31.2); for `Area.area_Rect` in a program `shapes.zyl` it is along
the lines of `zy_local_x2Fmain_0__shapes__Area_x2Earea_...Rect`.

### Trait Dispatch

`stdlib/compiler/trait_dispatch.zyl` runs after monomorphization. It
rewrites each qualified call into a `match` on the receiver whose arms
are named after the implementing types. Each arm calls that type's
lifted method. The arm names are ordinary constructor patterns, which is
why a struct (a one-variant ADT named after itself) dispatches correctly
and a multi-variant ADT's name acts as a catch-all.

### Representation

Every generic ADT instance has the same layout — a tag word followed by
one word per field — so `Option` of `Int` and `Option` of `String` share
constructors and `match` code. The specification's distinct per-instance
types (`Option_Int`, `Option_String`) exist only in type inference.

---

**Next:** [Chapter 8: Closures and Higher-Order Functions](ch08-closures.md) — explicit closure syntax, capture inference, and functional patterns.
