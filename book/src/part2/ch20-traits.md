# Chapter 20: Trait System and Derivation

This chapter is the reference for traits: declaration, implementation,
coherence, resolution and derivation. The normative text is
`zyl_specification.txt` §5 (trait system), §6.6 (generic derivation) and
§24.6 (coherence across packages). The implementation is
`stdlib/compiler/trait_dispatch.zyl` (call rewriting),
`stdlib/compiler/monomorphization.zyl` (impl bodies) and
`stdlib/compiler/module_resolver.zyl` (the orphan rule).

In brief: `impl` blocks and qualified `Trait.method` calls work, and are
dispatched on the receiver's runtime tag. `trait` declarations, coherence
C1 and C3, bounds and `derive` are not enforced.

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

In the implementation, the post-processor does not recognize `trait`.
A declaration is accepted and has no effect:

- the method list is not recorded;
- there is no `where` clause;
- an `impl` of a trait that was never declared compiles when the type
  is local (a `defstruct` or `deftype` of this program); for a type the
  program does not own, such as `Int`, the undeclared trait is not local
  either, and the orphan rule rejects it with `E_PKG_ORPHAN_IMPL`
  (§20.3) — declaring the trait makes that `impl` legal;
- an `impl` that omits one of the declared methods compiles too.

Declaring the trait still documents the interface, and it is the style
used in the standard library.

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

- **Methods are called by their qualified name**, `(Trait.method receiver
  args...)`. The dot is part of the identifier (Chapter 14). A bare
  `(area r)` does not find the method; it is an undefined function at
  link time.
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

§5.4 resolves traits statically, during Phase 3. The implementation
resolves them at runtime instead. `trait_dispatch.zyl` runs after
monomorphization and rewrites each `(Trait.method recv args...)` into a
`match` on `recv`. The match has one arm per implementing type; each arm
is named after the type and calls that type's `Trait.method_Type`.

The arm name is treated like any other constructor pattern (Chapter 18),
so dispatch is correct only when the type name identifies the receiver's
runtime tag:

- **Structs** always work. A struct is a one-variant ADT named after
  itself, and its tag is unique in the program.
- **A trait with exactly one impl** always works, whatever the type,
  because a one-arm match has nothing to confuse.
- **Several impls on multi-variant ADTs, or a mix of a primitive type and
  other impls**, do not work. An ADT's name is not one of its variants,
  so its arm behaves as a catch-all.

> **Compiler defect.** With two ADT impls, the first impl's arm catches
> every receiver:
>
> ```lisp
> (deftype Shape (Circ Int) (Sq Int))
> (deftype Tri (Tri Int))
> (trait Area (area self))
> (impl Area Shape (defn area (self) (match self (Circ r (* 3 (* r r))) (Sq s (* s s)))))
> (impl Area Tri (defn area (self) (match self (Tri b b))))
>
> (defn main ()
>   (begin
>     (print (Area.area (Tri 9)))   ; expected 9; prints 243 (Shape's impl)
>     0))
> ```
>
> Likewise, `(impl Show Int ...)` next to `(impl Show Point ...)` sends a
> `Point` receiver to the `Int` impl. Until dispatch uses static types,
> implement traits for structs, or give an ADT-typed trait a single impl.

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

The type in an `impl` is a single name, so generic impls such as
`(impl Container (Vec T) ...)` cannot be written, and overlap between
impls cannot arise except as a C1 duplicate.

## 20.4 Trait Resolution

The specification resolves traits in Phase 3, with type inference (§5.4,
§22):

1. collect bounds from signatures and trait declarations;
2. at each call site, substitute concrete types;
3. find `impl Trait ConcreteType` for each bound;
4. verify every bound;
5. substitute the concrete method.

The implementation does none of this statically. Bounds cannot be
declared (Chapter 19). Method selection is the runtime tag match of 20.2,
inserted after monomorphization and before ICNF lowering. A call to a
`Trait.method` that has no impl at all is left unchanged and fails at
link time as an undefined symbol, not as `E_TRAIT_NOT_FOUND`.

## 20.5 Trait Objects

Not supported in v5.0: there is no `dyn` type and no vtable.

```lisp
;; NOT SUPPORTED:
(defn process (items (Vec (dyn Drawable))) ...)
```

The tag-based dispatch of 20.2 behaves like dynamic dispatch over a
closed set of struct types, because the receiver's runtime tag selects
the method. The usual alternatives still apply:

1. **An ADT wrapper**, such as `(deftype Drawable (DCircle Circle) (DRect Rect))`,
   with one function that matches on it.
2. **Function values** passed directly instead of a trait.

## 20.6 Derivation

§5.6 and §5.7:

```lisp
(defstruct+ Point (x) (y) (:derive [Eq Ord]))   ; inline, on defstruct+

(derive Point Eq Ord)                           ; standalone
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

`derive` is parsed and then ignored (`insert-derive` in
`type_inference.zyl` returns its input unchanged). No impl is generated,
no field requirement is checked, and an unknown trait name is accepted.
`E_TRAIT_NOT_DERIVABLE` is never raised. The behavior you get is the same
with or without a derive:

- **Equality.** `==`, `!=` and `assert-equal` on two struct or ADT values
  compare structurally: tag, then field words.
- **Ordering.** `<`, `>`, `<=` and `>=` compare the fields
  lexicographically.
- **Shallow comparison.** Both compare a string or nested-ADT field by
  address, not by content.
- **Output.** `print` of a struct prints its address. There is no derived
  `Show` or `Debug` text.
- **`Clone` and `Hash`** have no generated functions to call.

```lisp
(defstruct Pt (x) (y))
(derive Pt Eq Ord)

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

The same program prints the same results with the `derive` line removed.

## 20.7 Derivation Errors

| Code | Cause | Status |
|------|-------|--------|
| `E_TRAIT_NOT_DERIVABLE` | a field lacks the trait being derived (§5.6, §6.6) | catalogued; never raised |

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
| `E_TRAIT_NOT_FOUND` | no impl for a required (Trait, Type) | catalogued; a missing impl fails at link time instead |
| `E_DUPLICATE_IMPL` | two impls for one (Trait, Type) | catalogued; a duplicate fails in the assembler instead |
| `E_TRAIT_BOUND_NOT_SATISFIED` | a concrete type lacks a bound's trait (§6.7) | catalogued; never raised |
| `E_TRAIT_NOT_DERIVABLE` | a derive constraint fails | catalogued; never raised |

## 20.11 Traits in the Standard Library

| Trait | Methods | Impls | Where |
|-------|---------|-------|-------|
| `OutputStream` | `write`, `flush` | `Stdout`, `StringBuffer` | `stdlib/io/io.zyl` |

The derivable traits of §5.6 and `Iterator` (§21.10) are named in the
specification but not defined as traits in the standard library.

## 20.12 Comparison with Rust

| Feature | Rust | Zyl |
|---------|------|-----|
| Declaration | `trait Foo { fn bar(&self); }` | `(trait Foo (bar self))`: documentation only today |
| Implementation | `impl Foo for Bar { ... }` | `(impl Foo Bar (defn bar (self) ...))` |
| Call | `x.bar()` | `(Foo.bar x)` |
| Dispatch | static, or `dyn` | runtime tag match |
| Supertraits | `trait Foo: Bar` | not supported |
| Default methods | yes | no |
| Trait objects | `dyn Trait` | no |
| Orphan rule | crate boundary | package boundary (`E_PKG_ORPHAN_IMPL`) |
| Derive | `#[derive(...)]`, generates code | `(derive ...)`, currently a no-op |
| Associated types | yes | no |
