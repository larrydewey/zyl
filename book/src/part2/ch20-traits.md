# Chapter 20: Trait System and Derivation

Complete reference for traits: declaration, implementation, coherence rules, resolution, and automatic derivation.

## 20.1 Trait Declaration

```
trait ::= "trait" Identifier "(" TraitMethod* ")" BoundClause?

TraitMethod ::= "(" Identifier "(" Param* ")" TypeExpr ")"

BoundClause ::= ":" Identifier "[" Identifier* "]"
```

### Examples

```lisp
;; Simple trait
(trait Eq
  (eq (a T) (b T) Bool))

;; With supertrait bound
(trait Ord
  (lt (a T) (b T) Bool)
  (gt (a T) (b T) Bool)
  : Eq [T])

;; Multiple methods
(trait Show
  (show (x T) String)
  (show-debug (x T) String))

;; With default? Not supported — all methods required
```

### Rules

1. **Trait name**: PascalCase convention
2. **Type parameter**: Implicit `T` (the implementing type)
3. **Methods**: First param is `self` (convention: `a`, `x`, `self`)
4. **Supertraits**: `: Trait [T]` — implementing type must also implement supertrait
5. **No default implementations** — all methods must be provided in `impl`

## 20.2 Trait Implementation

```
impl ::= "impl" TraitName TypeName "(" ImplBody* ")"

ImplBody ::= "defn" Identifier "(" Param* ")" Expression
```

### Examples

```lisp
(impl Eq Int
  (defn eq (a b) (== a b)))

(impl Ord Int
  (defn lt (a b) (< a b))
  (defn gt (a b) (> a b)))

(impl Show Int
  (defn show (x) (int-to-string x))
  (defn show-debug (x) (string-append "Int(" (int-to-string x) ")")))
```

### Rules

1. **One impl per (Trait, Type) pair** — enforced globally
2. **Orphan rule**: Valid only if trait OR type defined in current crate
3. **All methods required** — no partial impls
4. **Method signatures must match** trait declaration exactly

## 20.3 Coherence Rules (Normative)

### C1: One Impl Per Pair

```lisp
(impl Eq Int ...)   ; OK
(impl Eq Int ...)   ; ERROR: E_DUPLICATE_IMPL
```

### C2: Orphan Rule

```lisp
;; In crate A:
(trait Foo (foo (x T) Unit))
(defstruct MyType ...)

(impl Foo MyType ...)  ; OK: type defined here

;; In crate B:
(impl Foo MyType ...)  ; ERROR: neither trait nor type defined in B
```

Exception: If trait is `pub` and type is `pub`, impl allowed in third crate.

### C3: No Conflicting Impls

Overlapping impls forbidden even if technically disjoint:

```lisp
(trait Container (get (c T) Int))

(impl Container (Vec Int) ...)  ; OK
(impl Container (Vec String) ...)  ; OK (different types)

;; But NOT:
(impl Container (Vec T) ...)  ; Generic impl not allowed
```

## 20.4 Trait Resolution

### Phase 3: Type Inference + Trait Resolution

1. **Collect bounds** from function signatures and trait declarations
2. **At call sites**: Substitute concrete types for type parameters
3. **Lookup impl**: For each `T : Trait`, find `impl Trait ConcreteType`
4. **Verify all bounds** satisfied
5. **Substitute methods** with concrete implementations

### Recursive Bounds

```lisp
(trait Foo (bar () (Foo T)) : Bar)

;; Resolution: T must have Foo, and Foo T requires Bar T
```

Resolver handles recursive bounds via fixed-point iteration.

## 20.5 Trait Objects (Dynamic Dispatch)

**Not supported in v4.2**. All trait usage is monomorphized (static dispatch).

```lisp
;; NOT SUPPORTED:
(defn process (items (Vec (dyn Drawable))) ...)
```

Workarounds:
1. **ADT wrapper**: `(deftype DrawableWrapper (WrapCircle Circle) (WrapRect Rect))`
2. **Enum dispatch**: Match on ADT, call concrete impl
3. **Function pointers**: Pass `fn` directly instead of trait

## 20.6 Automatic Derivation

```lisp
(defstruct+ Point
  (x)
  (y)
  (:derive [Eq Ord Show Debug]))

(derive Option [Eq])
(derive Result [Eq Ord])
```

### Supported Derivable Traits

| Trait | Purpose | Field Requirements |
|-------|---------|-------------------|
| `Eq` | Structural equality | All fields: `Eq` |
| `Ord` | Ordering | All fields: `Ord` |
| `Show` | Human-readable string | All fields: `Show` |
| `Debug` | Debug representation | All fields: `Debug` |
| `Clone` | Deep copy | All fields: `Clone` |
| `Hash` | Hashable | All fields: `Hash` |

### Derivation Algorithm

For each trait:
1. Check all fields implement trait (recursive for ADTs)
2. Generate impl with:
   - `Eq`: Compare tags, then fields structurally
   - `Ord`: Compare tags, then fields lexicographically
   - `Show`: Format as `VariantName(field1, field2, ...)`
   - `Clone`: Recursively clone each field

### Standalone Derive

```lisp
(derive MyType [Eq Ord])
```

- Must be in same module as type
- Useful for ADTs or types from other modules
- Same requirements as inline derive

## 20.7 Derivation Errors

| Error | Cause |
|-------|-------|
| `E_TRAIT_NOT_DERIVABLE` | Field lacks required trait |
| `E_DERIVE_CONFLICT` | Manual impl conflicts with derived |
| `E_DERIVE_CYCLE` | Recursive type without base case |

## 20.8 Traits with Capability Types

```lisp
(trait Clone
  (clone (x T) T))

(impl Clone (TCap T)
  (defn clone (x) x))  ; Immutable = clone is identity

(impl Clone (TMut T)
  (defn clone (x) (deep-copy x)))  ; Mutable needs copy

(impl Clone (TBox T)
  (defn clone (x) (box-clone x)))  ; Box clone
```

## 20.9 Associated Types

**Not supported in v4.2**. Use type parameters instead:

```lisp
;; Instead of:
(trait Iterator (next () (Option Item)) ...)

;; Use:
(trait Iterator (next (self T) (Option T)) ...)
(defn collect ((I : Iterator) iter) ...)
```

## 20.10 Trait Errors

| Error | Cause |
|-------|-------|
| `E_TRAIT_NOT_FOUND` | No impl for required (Trait, Type) |
| `E_DUPLICATE_IMPL` | Two impls for same (Trait, Type) |
| `E_ORPHAN_IMPL` | Impl violates orphan rule |
| `E_TRAIT_BOUND_NOT_SATISFIED` | Concrete type lacks trait at call site |
| `E_TRAIT_NOT_DERIVABLE` | Field constraint fails for derive |

## 20.11 Standard Library Traits

| Trait | Methods | Common Impls |
|-------|---------|--------------|
| `Eq` | `eq` | All primitives, structs, ADTs |
| `Ord` | `lt`, `gt` | Int, Float, String, tuples |
| `Show` | `show` | All (for user output) |
| `Debug` | `show-debug` | All (for debugging) |
| `Clone` | `clone` | Primitives, structs, ADTs |
| `Hash` | `hash` | Int, String, tuples |
| `Ord` | `lt`, `gt` | Int, Float, String |
| `Add` | `add` | Int, Float |
| `Mul` | `mul` | Int, Float |
| `Iterator` | `next` | Collections |

## 20.12 Comparison with Rust

| Feature | Rust | Zyl |
|---------|------|-----|
| Declaration | `trait Foo { fn bar(&self); }` | `(trait Foo (bar (self T) Unit))` |
| Implementation | `impl Foo for Bar { ... }` | `(impl Foo Bar (defn bar ...))` |
| Supertraits | `trait Foo: Bar` | `: Bar [T]` |
| Default methods | ✅ | ❌ |
| Trait objects | `dyn Trait` | ❌ |
| Orphan rule | ✅ | ✅ |
| Derive macros | `#[derive(...)]` | `(:derive [...])` / `(derive ...)` |
| Associated types | ✅ | ❌ |
| GATs | ✅ | ❌ |