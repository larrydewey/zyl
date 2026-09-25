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

A function whose parameters carry no type annotation is generic: type
inference gives it a polymorphic type, and each call site instantiates
it with that site's argument types.

```lisp
(defn first-of (a _) a)

(defn choose (c t f)
  (if c t f))

(defn smaller (a b)
  (if (< a b) a b))

(defn main ()
  (begin
    (print (first-of 5 "s"))             ; 5
    (print (first-of "a" 2))             ; a
    (print (choose true "yes" "no"))     ; yes
    (print (smaller 3 5))                ; 3
    (print (smaller "b" "a"))            ; a
    0))
```

A result's type flows back to the caller, so `print` shows it correctly.
Where a generic body does something that depends on the type — `print`,
`=`, `<`, arithmetic, or a trait method on a parameter — the compiler
generates one instance of the function per concrete argument-type
combination it is called with (§7.6), so `smaller` on Strings compares
text and on Ints compares numbers.

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
| `((T : Ord) a b)` | `E_MALFORMED_PARAMETER`: a parameter's type is written `(name Type)`, without a colon. Writing `(a Ord)` instead is also `E_MALFORMED_PARAMETER`, because `Ord` is a trait, not a type. |

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
    (print (maybe-or (Just 4) 0))                    ; 4
    (print (maybe-or (Just "hi") "none"))            ; hi
    (print (maybe-or (Nothing) "default"))           ; default
    (print (count-items (Cons 1 (Cons 2 Nil))))      ; 2
    (print (count-items (Cons "a" Nil)))             ; 1
    0))
```

The type arguments are inferred from the field values; you never write
them. Every occurrence of one parameter must be the same type, so
`(Make 1 "hi")` is `E_TYPE_MISMATCH`: both fields are `T`, and `T` cannot
be `Int` and `String` at once.

A struct gets its type parameters without any syntax: a field with no
type is an implicit parameter. `(defstruct Box (v))` is generic in `v`,
so `(make-Box 3)` and `(make-Box "s")` are a box of `Int` and a box of
`String`, and `(+ (struct-get (make-Box "s") "v") 1)` is a type error.
Write `(v Int)` when the field should only ever hold one type.

## 7.3 Traits — Ad-Hoc Polymorphism

A trait names a set of methods that several types can implement.

### Declaration

```lisp
(trait Area
  (area (self) Int))
```

A declaration lists each method as `(name (params...) Result)`. The
receiver comes first and is written `self`; its type is whatever type
the impl is for. A parameter that must have the receiver's type is
written `(other Self)`:

```lisp
(trait Cmp
  (cmp (self (other Self)) Int))
```

`Self` stands for the implementing type, so `Cmp.cmp` on a `Money`
takes a second `Money`, and `(Cmp.cmp (make-Money 500) 3)` is
`E_TYPE_MISMATCH`. The standard library's own traits are declared this
way: `(trait Eq (eq (self (other Self)) Bool))`,
`(trait Ord (compare (self (other Self)) Int))`,
`(trait Clone (clone (self) Self))`.

The signature is what a trait call is checked against: an impl method
that returns a `String` for `(area (self) Int)` is a type error, and so
is a call with the wrong number of arguments. Write the parameter list
in parentheses even when it is only `self`: the older form
`(area self)`, with a bare `self`, is `E_MALFORMED_FORM`.

### Implementation and Calls

```lisp
(defstruct Rect (w) (h))
(defstruct Circle (r))

(trait Area
  (area (self) Int))

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

- **Call a method with dot syntax**, `(r.area)` or `(r.scale 3)`, or by
  its qualified name, `(Area.area r)` / `(Scale.scale r 3)`. A dot call
  picks the trait from the receiver's type, so two traits may share a
  method name; when the receiver's type is not known where the call is
  written (an unannotated parameter) and several traits declare the
  method, it is `E_TRAIT_NOT_FOUND`: use the qualified name there. For
  an expression receiver, write `((make-Rect 2 3).area)`. A bare
  `(area r)` does not find the method.
- **The receiver is the first parameter.** Calling it `self` is
  convention. Further parameters follow it as usual:
  `(defn scale (self k) ...)`, declared in the trait as
  `(scale (self (k Int)) Int)`.
- There are no default method bodies: every impl writes each method.

### How a Call Finds Its Method

Trait calls are resolved statically, from the receiver's inferred type
(spec §5.4): `(Area.area (Tri 9))` calls the `Tri` impl directly,
whatever else implements `Area` — structs, multi-variant ADTs and
primitives such as `Int` alike.

There is no run-time dispatch. A list's elements all have one type, so
a list that mixes a `Circle` and a `Rect` is `E_TYPE_MISMATCH`, and a
trait call whose receiver type is never pinned down is `E_CANNOT_INFER`.
To hold several shapes in one collection, wrap them in one ADT and
`match` on it; each arm then calls the impl for a known type:

```lisp
(defstruct Circle (r))
(defstruct Rect (w) (h))

(trait Describe (describe (self) Int))

(impl Describe Circle
  (defn describe (self) (print "circle") (struct-get self "r")))

(impl Describe Rect
  (defn describe (self) (print "rect") (* (struct-get self "w") (struct-get self "h"))))

(deftype Shape (C Circle) (R Rect))

(defn describe-shape (s)
  (match s
    (C c (Describe.describe c))
    (R r (Describe.describe r))))

(defn describe-all (xs)
  (match xs
    (Nil 0)
    (Cons s rest (+ (describe-shape s) (describe-all rest)))))

(defn main ()
  (print (describe-all (Cons (C (make-Circle 2)) (Cons (R (make-Rect 3 4)) Nil))))
  0)
;; circle
;; rect
;; 14
```

A function body with several forms runs them in order and returns the
last, as if wrapped in `begin`.

A generic function that calls a trait method on one of its parameters is
compiled once per concrete receiver type (§7.6):

```lisp
(trait Desc (desc (self) String))
(impl Desc Int (defn desc (self) "int"))
(impl Desc String (defn desc (self) (str-concat "str:" self)))

(defn twice (x) (str-concat (Desc.desc x) (Desc.desc x)))

(defn main ()
  (begin
    (print (twice "a"))     ; str:astr:a
    (print (twice 1))       ; intint
    0))
```

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

- **C1** is checked: two `(impl Area Rect ...)` blocks, or an impl and
  a derive of the same trait for one type, are `E_DUPLICATE_IMPL`.
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
  type. An impl for a generic type is written with the bare type name,
  `(impl Show Vec ...)`, and covers every element type; its body is
  instantiated per element type where the element's own trait methods
  are called.

## 7.5 Trait Bounds and Resolution

In the specification, a bound such as `(T : Ord)` requires every call
site's concrete type to implement the trait, and trait resolution
happens during type inference: collect the bounds, substitute the
concrete types at each call, find the impl, verify the bound. Since
bounds cannot be written (§7.1), they are not checked as bounds. The
effect is close, though: the impl is found from the inferred receiver
type, and a `Trait.method` call with no impl for a known receiver type
is `E_TRAIT_NOT_FOUND`, located at the call. A receiver whose type is
never known is `E_CANNOT_INFER`, and a trait with no impls at all makes
the call `E_UNBOUND_VARIABLE`.

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

Because every value is one word, most polymorphic functions need no
copies and are compiled once. A copy is made only for a function whose
body depends on a type parameter — it prints one, compares or does
arithmetic on one, or calls a trait method on one. Each distinct tuple of
concrete argument types gets one instance, named after the function and
its argument types (`smaller~String,String`). A function that would
need more than 256 instances (almost always recursion at an ever larger
type) is `E_CANNOT_INFER`.
Impl methods become functions named `Trait.method_Type`, such as
`Area.area_Rect`. Chapter 19 has the details.

## 7.7 Deriving Traits

The specification lets you derive `Eq`, `Ord`, `Show`, `Debug`, `Clone`
and `Hash`, inline on `defstruct+` or with a standalone `derive`:

```lisp
(derive Pt Show)            ; or (derive Pt [Show Eq])
```

`(derive T Show)` (or `(derive T [Show])`) generates a `Show` impl, and
`print` then shows the value (Chapter 4, §4.9). The inline `(:derive
...)` option on `defstruct+` is not parsed, and the other traits are
`Eq`, `Ord`, `Debug`, `Hash` and `Clone` derive the same way
(Chapter 20, §20.6). Equality needs no derive: `==` and `!=` compare two
struct or ADT values field by field, by content, with nested values and
strings compared recursively. Ordering does: `<`, `>`, `<=` and `>=`
take only `Int`, `Float` and `String`, and on a struct they are
`E_TYPE_MISMATCH`. A derived `Ord.compare` returns -1, 0 or 1, ordering
variants in declaration order and then the fields lexicographically:

```lisp
(defstruct Pt (x) (y))
(derive Pt Ord)

(defn main ()
  (let a (make-Pt 1 2)
    (let b (make-Pt 1 2)
      (let c (make-Pt 2 0)
        (begin
          (print (== a b))                ; 1 (true)
          (print (== a c))                ; 0 (false)
          (print (Ord.compare a c))       ; -1 (1 < 2 in the first field)
          0)))))
```

## 7.8 Traits and Capability Types

The specification does not define impls on capability types, and
capability types cannot be written in source (Chapter 5). An `impl`
names a plain type: a struct, an ADT or a primitive.

There are no trait objects (`dyn Trait`) either. Where you would use
one, use an ADT wrapper (§7.3):

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
  (print (list-sum (my-map double (Cons 1 (Cons 2 (Cons 3 Nil))))))   ; 12
  0)
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
| `E_CANNOT_INFER` | a trait call whose receiver type is never known, or more than 256 instances | raised |
| `E_TYPE_MISMATCH` | a trait call or impl that disagrees with the trait's signature, or two types for one parameter | raised |
| `E_TRAIT_BOUND_NOT_SATISFIED` | concrete type lacks a bound's trait | in the specification; never raised |
| `E_TRAIT_NOT_DERIVABLE` | a field lacks the derived trait, or the trait is not derivable | raised |
| `E_DUPLICATE_IMPL` | two impls for one (Trait, Type) | raised |
| `E_TRAIT_NOT_FOUND` | no impl for a known receiver type | raised |

---

## For Experts: Under the Hood

### Inference and Instances

`stdlib/compiler/type_annotate.zyl` runs Hindley–Milner inference over
the lowered program: top-level functions are inferred one strongly
connected component of the call graph at a time and generalized, so each
call instantiates a function's type afresh. Every unification failure
is an error (Chapter 15), and the inferred types then guide code
generation and trait resolution. A function whose body depends on a type
variable gets one instance per concrete argument-type tuple, named
`key~T1,T2`.

### Naming

Impl methods are named `Trait.method_Type`. The name the linker finally
sees is mangled from the canonical symbol key of the package system
(spec §31.2); for `Area.area_Rect` in a program `shapes.zyl` it is along
the lines of `zy_local_x2Fmain_0__shapes__Area_x2Earea_...Rect`.

### Trait Dispatch

The type annotation pass redirects each qualified call to the lifted
method for the receiver's inferred type. There is no fallback: a call
whose receiver type stays unknown is rejected rather than dispatched on
the value's run-time tag.

### Representation

Every generic ADT instance has the same layout — a tag word followed by
one word per field — so `Option` of `Int` and `Option` of `String` share
constructors and `match` code. The specification's distinct per-instance
types (`Option_Int`, `Option_String`) exist only in type inference.

---

**Next:** [Chapter 8: Closures and Higher-Order Functions](ch08-closures.md) — explicit closure syntax, capture inference, and functional patterns.
