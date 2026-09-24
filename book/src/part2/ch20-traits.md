# Chapter 20: Trait System and Derivation

This chapter is the reference for traits: declaration, implementation,
coherence, resolution and derivation. The normative text is
`zyl_specification.txt` §5 (trait system), §6.6 (generic derivation) and
§24.6 (coherence across packages). The implementation is
`stdlib/compiler/type_annotate.zyl` (resolution and per-type instances),
`stdlib/compiler/derive.zyl` (`derive Show`),
`stdlib/compiler/monomorphization.zyl` (impl bodies) and
`stdlib/compiler/module_resolver.zyl` (the orphan rule).

In brief: `trait` declarations, `impl` blocks and qualified
`Trait.method` calls work, resolved statically from the receiver's
inferred type. `derive Show` generates an impl, and the prelude's `Show`
trait drives `print`. Coherence C1 and C3, bounds and the other derivable
traits are not enforced or generated.

## 20.1 Trait Declaration

§5.1:

```
(trait Name (method1 (params1) ReturnType1) ...) [where TypeParam : OtherTrait]
```

```lisp
(trait Area
  (area self))

(trait OutputStream                    ; stdlib/io/io.zyl
  (write (self T) (chunk String) Int)
  (flush (self T) Int))
```

Rules from the specification: a trait lists method signatures, and §5.4
supports recursive transitive bounds through `where`.

A declaration records its method signatures, which type every call of
the method (a `String` return type makes the call's result a String).
The implementation does not check the declaration against impls:

- there is no `where` clause;
- an `impl` of a trait that was never declared compiles when the type
  is local (a `defstruct` or `deftype` of this program); for a type the
  program does not own, such as `Int`, the undeclared trait is not local
  either, and the orphan rule rejects it with `E_PKG_ORPHAN_IMPL`
  (§20.3) — declaring the trait makes that `impl` legal;
- an `impl` that omits one of the declared methods compiles too.

There are no default method bodies.

## 20.2 Trait Implementation

§5.2:

```
(impl TraitName TypeName (defn methodName (params) body) ...)
```

```lisp
(defstruct Rect (w) (h))
(defstruct Circle (r))

(trait Area
  (area self))

(impl Area Rect
  (defn area (self) (* (struct-get self "w") (struct-get self "h"))))

(impl Area Circle
  (defn area (self) (* 3 (* (struct-get self "r") (struct-get self "r")))))

(defn main ()
  (begin
    (print (Area.area (make-Rect 3 4)))    ; 12
    (print (Area.area (make-Circle 2)))    ; 12
    0))
```

- **Methods are called with dot syntax**, `(r.area)`, `(r.scale 3)`,
  `((make-Circle 2).area)`, or by qualified name, `(Trait.method receiver
  args...)`. A dot call is rewritten to `(zyl-method "area" r)` before
  qualification, and the type pass picks the trait whose impl matches
  the receiver's type: the only trait declaring the method, or, when
  several do, the one with an impl for the receiver's known type.
  `E_TRAIT_NOT_FOUND` reports a method no trait declares, a type with no
  such impl, and an ambiguous call on a receiver of unknown type. A bare
  `(area r)` does not find the method.
- **The receiver is the first argument.** Naming it `self` is convention.
- **Parameters are not checked** against the declaration. They are
  whatever the `defn` inside the `impl` says.
- **Each method body is lifted** to a top-level function named
  `Trait.method_Type` (Chapter 19).

The standard library's one trait is `OutputStream` in `io/io`, with
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

### How dispatch works

§5.4 resolves traits statically, during type inference, and so does the
implementation. The type annotation pass infers the receiver's type at
each `(Trait.method recv args...)` call and redirects the call to that
type's `Trait.method_Type`. Structs, multi-variant ADTs and primitives
all dispatch exactly:

```lisp
(deftype Shape (Circ Int) (Sq Int))
(deftype Tri (Tri Int))
(trait Area (area self))
(impl Area Shape (defn area (self) (match self (Circ r (* 3 (* r r))) (Sq s (* s s)))))
(impl Area Tri (defn area (self) (match self (Tri b b))))
(impl Area Int (defn area (self) (* self 100)))

(defn main ()
  (begin
    (print (Area.area (Tri 9)))   ; 9
    (print (Area.area (Sq 3)))    ; 9
    (print (Area.area 2))         ; 200
    0))
```

When the receiver's type is a type variable — inside a generic function
— the function is compiled once per concrete receiver type it is called
with (Chapter 19), and each instance resolves the call. An impl for a
generic type, `(impl Show Vec ...)`, is handled the same way per element
type.

When inference cannot give the receiver one type (a list mixing two
struct types, for example), the call falls back to a `match` on the
receiver's runtime tag with one arm per implementing type. That is exact
for structs, whose tags are unique; an arm named after a multi-variant
ADT or a primitive acts as a catch-all, so keep such heterogeneous data
to structs or wrap it in one ADT.

## 20.3 Coherence Rules (Normative, §5.3)

```
C1. One impl per (Trait, Type) pair.
C2. Orphan rule: impl valid only if trait or type defined in current crate.
C3. No conflicting impls.
```

### C1: One impl per pair

Not checked by a compiler pass. Two `(impl Area Rect ...)` blocks both
define `Area.area_Rect`, and the build fails in the assembler with
"symbol ... is already defined", not with `E_DUPLICATE_IMPL`.

### C2: Orphan rule

In v5.0 the orphan rule applies at the package boundary (§24.6): a
package may implement a trait for a type only if it defines the trait or
defines the type. The module resolver enforces this over the whole
resolved graph and reports `E_PKG_ORPHAN_IMPL`. Within one package, any
module may implement any of the package's traits for any of its types.
There is no exception for `pub` items.

### C3: No conflicting impls

The type in an `impl` is a single name. An impl for a generic type names
the bare type, `(impl Show Vec ...)`, and covers every instantiation, so
overlap between impls cannot arise except as a C1 duplicate.

### Forbidding an implementation: `impl-not`

```lisp
(impl-not Trait Type)     ; Type may never implement Trait
(impl-not Trait Other)    ; no type implementing trait Other may implement Trait
```

`impl-not` is a top-level declaration, checked over the whole program
after module resolution. Any `impl` or `derive` of the forbidden pair,
in any module or package, is `E_IMPL_FORBIDDEN`, and the message names
the declaration. When the target is a trait, every type implementing it
is covered, whichever order the declarations appear in.

It also carries a **flow rule** that closes the wrapper loophole: the
result of any impl of `Trait`, for any type, may not be derived from a
value the declaration protects. A value is protected when its type is
the target (or implements the target trait), and so is a field of such
a type, or a `match` binder of one. So with `(impl-not Dump Handle)`, a
`Conn` holding a `Handle` cannot write a `Dump` that reads `self.h.fd`
(`E_IMPL_FORBIDDEN`), although it can dump its other fields.

For `Show`, the protected type gets a compiler-made `Show` that prints
`<hidden>`, and a derived `Show` of a record shows such fields as
`<hidden>`. The prelude uses this for key material,
`(impl-not Show Secret)` (Chapter 33), where the text is `<secret>`.
`declassify` is the explicit escape from the flow rule.

## 20.4 Trait Resolution

The specification resolves traits in Phase 3, with type inference (§5.4,
§22):

1. collect bounds from signatures and trait declarations;
2. at each call site, substitute concrete types;
3. find `impl Trait ConcreteType` for each bound;
4. verify every bound;
5. substitute the concrete method.

The implementation does steps 2, 3 and 5 at each call site from inferred
types (20.2). Bounds cannot be declared (Chapter 19), so 1 and 4 do not
exist. A call to a `Trait.method` on a receiver of known type that has
no impl for it is `E_TRAIT_NOT_FOUND`, located at the call.

## 20.5 Trait Objects

Not supported in v5.0: there is no `dyn` type and no vtable.

```lisp
;; NOT SUPPORTED:
(defn process (items (Vec (dyn Drawable))) ...)
```

The runtime fallback of 20.2 behaves like dynamic dispatch over a
closed set of struct types, because the receiver's runtime tag selects
the method. The usual alternatives still apply:

1. **An ADT wrapper**, such as `(deftype Drawable (DCircle Circle) (DRect Rect))`,
   with one function that matches on it.
2. **Function values** passed directly instead of a trait.

## 20.6 Derivation

§5.6 and §5.7:

```lisp
(defstruct+ Point (x) (y) (:derive [Eq Ord]))   ; inline

(derive Point Show)                             ; standalone; or (derive Point [Show Eq])
```

- `derive` takes the type name followed by the trait names, separated by
  spaces. The bracketed `[Eq Ord]` spelling of §5.7 also parses: brackets
  read as a list (Chapter 14).
- §5.7 requires a standalone derive to appear in the same module as its
  type.

### Derivable traits (§5.6)

| Trait | Specified meaning | Field requirement |
|-------|-------------------|-------------------|
| `Eq` | structural equality | all fields `Eq` |
| `Ord` | ordering | all fields `Ord` |
| `Show` | readable text | all fields `Show` |
| `Debug` | debug text | all fields `Debug` |
| `Clone` | deep copy | all fields `Clone` |
| `Hash` | hashing | all fields `Hash` |

§6.6 extends this to generic ADTs: `(derive Result Eq)` requires every
type parameter to implement `Eq`.

### What the compiler does

`(derive T Show)` generates `(impl Show T ...)`: each variant shows as
its name followed by its fields' `Show` text, and a struct as its name
and `field: value` pairs. Fields of a generic type are shown through the
instance for the concrete type:

```lisp
(deftype Shape (Circle Float) (Rect Int Int) (Empty))
(derive Shape Show)
(defstruct Person (name String) (age Int))
(derive Person Show)

(defn main ()
  (begin
    (print (Rect 2 3))                 ; Rect(2, 3)
    (print Empty)                      ; Empty
    (print (make-Person "Ann" 30))     ; Person { name: Ann, age: 30 }
    (print (Show.show (Circle 1.5)))   ; Circle(1.500000)
    0))
```

The other five traits are declared in the prelude (`core/show`) with
impls for `Int`, `Float`, `Bool`, `String`, `List`, `Option` and
`Result`, and each derives:

| Trait | Method | Derived meaning |
|-------|--------|-----------------|
| `Debug` | `(Debug.debug x)` | like `Show`, with strings quoted: `Person { name: "Ann", age: 30 }` |
| `Eq` | `(Eq.eq a b)` | structural equality, the same as `==` |
| `Ord` | `(Ord.compare a b)` | -1, 0 or 1: variants in declaration order, then fields lexicographically |
| `Hash` | `(Hash.hash x)` | a deterministic `Int`, equal for equal values |
| `Clone` | `(Clone.clone x)` | the value itself (values are immutable) |

```lisp
(deftype Shape (Circle Int) (Rect Int Int) (Empty))
(derive Shape Eq Ord Hash)
(Ord.compare (Circle 5) (Rect 1 1))   ; -1: Circle is declared first
(Ord.compare (Rect 1 2) (Rect 1 1))   ; 1
```

**The field requirement is checked.** Every field's type must implement
the trait: a primitive, the type being derived (recursion), a type
parameter or an untyped field is fine; any other type needs an impl or
a derive of its own, or the derive is `E_TRAIT_NOT_DERIVABLE`, naming
the field type. `Vec` and `Map` implement only `Show`. A `Secret` field
is redacted by `Show` and `Debug`, but a record with one cannot derive
`Eq`, `Ord` or `Hash`, since that comparison would not be constant-time
(Chapter 33). An unknown trait name is `E_TRAIT_NOT_DERIVABLE` too.

What the operators give you without a derive:

- **Equality.** `==`, `!=` and `assert-equal` on two struct or ADT values
  compare by content, through an equality function the type-annotation
  pass generates per type. A type with a `Secret` field, or a value of a
  type inference cannot determine, gets the runtime's shallow comparison.
- **Ordering.** `<`, `>`, `<=` and `>=` compare the fields
  lexicographically, and are shallow: a string or nested-ADT field is
  compared by address. Use a derived `Ord` for a real ordering.

## 20.7 Derivation Errors

| Code | Cause | Status |
|------|-------|--------|
| `E_TRAIT_NOT_DERIVABLE` | a field lacks the trait being derived (§5.6, §6.6), a Secret field under Eq/Ord/Hash, or a trait that is not derivable | raised |

The specification defines no other derive-specific codes.

## 20.8 Traits and Capability Types

The specification does not define impls on capability types, and
capability types cannot be written in source (Chapter 17). An `impl`
names a plain type: a struct, an ADT or a primitive.

## 20.9 Associated Types

Not supported. A trait has only methods. Where another language would use
an associated type, have the method return a concrete ADT, as §21.10's
`Iterator` does:

```lisp
(trait Iterator
  (next (self T) (Option T)))
```

§21.10 says collections implement `Iterator` for `for` loops. No
collection does today, and `for` is a condition loop (§12.6).

## 20.10 Trait Errors

| Code | Cause (§28) | Status |
|------|-------------|--------|
| `E_PKG_ORPHAN_IMPL` | impl where neither the trait nor the type belongs to the package (§24.6) | raised |
| `E_IMPL_FORBIDDEN` | an impl or derive an `impl-not` forbids, or an impl whose result exposes a protected value | raised |
| `E_TRAIT_NOT_FOUND` | no impl for a required (Trait, Type) | raised for a known receiver type, and for dot calls |
| `E_DUPLICATE_IMPL` | two impls for one (Trait, Type) | catalogued; a duplicate fails in the assembler instead |
| `E_TRAIT_BOUND_NOT_SATISFIED` | a concrete type lacks a bound's trait (§6.7) | catalogued; never raised |
| `E_TRAIT_NOT_DERIVABLE` | a derive constraint fails | raised |

## 20.11 Traits in the Standard Library

| Trait | Methods | Impls | Where |
|-------|---------|-------|-------|
| `Show` | `show` (returns `String`) | `Int`, `Float`, `Bool`, `String` (`core/show`); `List`, `Option`, `Result` (core); `Vec` (`collections/vec`); `Map` (`core/map`) | prelude |
| `OutputStream` | `write`, `flush` | `Stdout`, `StringBuffer` | `stdlib/io/io.zyl` |

`print` of a value whose type has a `Show` impl prints `(Show.show v)`;
Int, Float, Bool and String print natively as before. Containers show as
`[a, b]`, `{k: v}`, `Some(x)`, `Ok(x)`; a String inside one is not
quoted. The other derivable traits of §5.6 and `Iterator` (§21.10) are
named in the specification but not defined as traits in the standard
library.

## 20.12 Comparison with Rust

| Feature | Rust | Zyl |
|---------|------|-----|
| Declaration | `trait Foo { fn bar(&self); }` | `(trait Foo (bar (self) Ret))`; signatures type calls |
| Implementation | `impl Foo for Bar { ... }` | `(impl Foo Bar (defn bar (self) ...))` |
| Call | `x.bar()` | `(Foo.bar x)` |
| Dispatch | static, or `dyn` | static from inferred types; runtime tag match as fallback |
| Supertraits | `trait Foo: Bar` | not supported |
| Default methods | yes | no |
| Trait objects | `dyn Trait` | no |
| Orphan rule | crate boundary | package boundary (`E_PKG_ORPHAN_IMPL`) |
| Derive | `#[derive(...)]`, generates code | `(derive T Show)` generates code; other traits not yet |
| Associated types | yes | no |
