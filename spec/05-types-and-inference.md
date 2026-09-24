# Zyl Specification — Types and Inference

**Canonical authority:** `zyl_specification.txt` §4, §5, §6, §17
**Related:** `spec/06-capability-types.md`, `spec/10-structs-and-data-types.md`
**Implementation:** `stdlib/compiler/type_system.zyl`, `stdlib/compiler/type_inference.zyl`, `stdlib/compiler/monomorphization.zyl`, `stdlib/compiler/type_annotate.zyl`, `stdlib/compiler/derive.zyl`

---

## 4. Type System

### 4.1 Primitive Types

```
Int | Float | Bool | String | Unit
```

### 4.2 Composite Types

```
Vec<T>     — contiguous array (O(1) access, deterministic iteration if sorted)
Map<K,V>   — hash map (deterministic iteration by sorted key hash)
Result<T, E> — error handling type
Struct     — named collection of fields (immutable by default)
Alias      — transparent wrapper (zero-cost)
```

### 4.3 Capability Types

`TCap<T>`, `TMut<T>`, `TAtomic<T>`, `TBox<T>`, `TPin<T>` — see
`spec/06-capability-types.md`.

### 4.4 Function Types

```
TFun([T*], TReturn)
```

### 4.5 Trait Bounds

```
T : TraitName
```

### 4.6 Inference

Hindley-Milner with region/capability constraints.
Monomorphization during Phase 5.

### 4.7 Type Equality

- Structural for primitives/collections.
- Nominal for Structs/ADTs/Aliases.
- Aliases are transparent: A is coerced to B (and vice versa) without runtime cost.

---

## 5. Trait System

### 5.1 Trait Declaration

```
(trait Name (method1 (params1) ReturnType1) ...) [where TypeParam : OtherTrait]
```

### 5.2 Trait Implementation

```
(impl TraitName TypeName (defn methodName (params) body) ...)
```

### 5.3 Coherence Rules

| Rule | Statement |
|------|-----------|
| C1 | One impl per (Trait, Type) pair. |
| C2 | Orphan rule: impl valid only if trait or type defined in current crate (the package, in v5.0; see §24.6). |
| C3 | No conflicting impls. |

Across packages, v5.0 states the orphan rule at the package boundary (§24.6):
a package may implement a trait for a type only if it defines the trait or
defines the type, otherwise `E_PKG_ORPHAN_IMPL`. Coherence is checked over
the whole resolved graph.

### 5.4 Trait Resolution

Resolved in Phase 3. Recursive transitive bounds supported.

### 5.5 Trait Bounds in Generics

```lisp
(defn sort ((T : Ord) xs) body)
```

### 5.6 Derive Mechanism

- Supported: Eq, Ord, Debug, Show, Clone, Hash.
- Constraint: All fields must implement the trait.
- Error: `E_TRAIT_NOT_DERIVABLE` if constraint fails.

### 5.7 Standalone Derive

```lisp
(derive TypeName [TraitA TraitB ...])
```

Must appear in same module as type. Fails if trait not derivable.

---

## 6. Generics

### 6.1 Generic Function Declaration

```lisp
(defn name ((TypeParam : TraitBound*) (param Type) ...) body)
```

- `defun` is a synonym.
- `TypeParam` is an uppercase identifier (convention).
- `TraitBound` is optional; absent = unbounded.
- Multiple bounds: `((T : Ord Eq))` → T must implement both.

Multiple type parameters are declared as multiple parameter groups:

```lisp
(defn pair ((T) (U)) (make-tuple t u))      ; 2 type params
(defn min ((T : Ord) a b) ...)               ; 1 bounded type param
(defn f ((T) (U) x Int) ...)                 ; interleaved with typed params
```

**Scope:** TypeParam is scoped to its own `defn`. Shadowing T in a nested defn is an error.

### 6.2 Type Param Semantics

- Type parameters are positional in declaration, but monomorphized naming is order-independent (§6.4).
- A type parameter used multiple times constrains both positions to the SAME concrete type.
- Type parameters appear ONLY in type position (variant field, param type, collection type). Never as runtime values.

### 6.3 Generic Type in Collections

```
Vec<T>, Map<K,V>   ; K, V, T inferred from usage context
```

### 6.4 Monomorphization

For each call site of a generic function, the compiler:

1. Infers concrete types for ALL type parameters from argument types.
   - A parameter with no evidence at any call site → `E_CANNOT_INFER`
     (unless a trait bound selects a finite set).
2. Verifies all trait bounds are satisfied (`E_TRAIT_BOUND_NOT_SATISFIED`).
3. Generates a canonical specialization name:
   ```
   functionName_Type1_Type2_...     ; types sorted alphabetically
   ```
   `f<Int, String>` and `f<String, Int>` → same name. Distinct maps → distinct names.
4. Caches the monomorphized function for reuse.

Examples:

```
(min 3 5)       → min_Int
(min "a" "b")   → min_String
(pair 1 "hi")   → pair_Int_String
(pair 1.0 2.0)  → pair_Float
```

### 6.5 Generic ADTs

```lisp
(deftype Option (Some T) None)
(deftype Result (Ok T) (Err E))       ; 2 type params from uppercase fields
(deftype List (Cons T (List T)) None) ; recursive generic reference
```

- `Option<Int>` and `Option<String>` are distinct types.
- Type params collected from uppercase variant field names; duplicates kept once (same-type constraint).
- Monomorphization applies to constructors and pattern matching on generic ADTs.
- **Generic structs not supported** — only ADTs and collections may be generic (a limitation, not a design goal).

### 6.6 Generic ADT Derivation

```lisp
(derive Result [Eq])   ; requires ALL type params to implement Eq
```

Deriving on a multi-param ADT is allowed; the impl is parameterized over the ADT's type params.
`E_TRAIT_NOT_DERIVABLE` if any concrete instantiation fails the field constraint.

### 6.7 Error Cases

| Code | Condition |
|------|-----------|
| `E_CANNOT_INFER` | generic param with no call-site evidence |
| `E_TRAIT_BOUND_NOT_SATISFIED` | concrete type violates a bound |
| `E_UNKNOWN_GENERIC_PARAM` | reference to undeclared type parameter |
| `E_TRAIT_NOT_DERIVABLE` | derive constraint fails |

---

## 17. Monomorphization

```
sort(type parameters alphabetically)
generate canonical specialization name
```

Deterministic output guaranteed. In v5.0 the canonical symbol key
(`<package>@<major>::<module-path>::<symbol>`, §31.2) is also the sort key,
so the ordering stays total over a multi-package graph.

---

## Implementation Notes

Not normative. These describe the self-hosted compiler and record where it
falls short of §4–§6 and §17.

### Types

`type_system.zyl` defines `Type` with the variants `TInt`, `TFloat`,
`TBool`, `TString`, `TUnit`, `TByte`, `TByteSlice Region`,
`TByteBuf Region`, `TFun`, `TList`, `TArray`, `TCap CapKind Type`,
`TStruct`, `TVar`, `TMap` and `TResult`. The capability wrappers of §4.3
are not separate types; they are `CapKind`s inside `TCap` (see
`spec/06-capability-types.md`).

### Inference

- Unification is Hindley–Milner style (`unify`, `unify-var`, with an
  occurs check). There is no let-generalisation.
- Inference does not reject ill-typed programs: a failed unification
  degrades to a fresh type variable rather than producing an error. The
  only fatal diagnostic it raises is `E_INVALID_CAPABILITY` for a
  non-pinnable FFI argument. `E_TYPE_MISMATCH` and
  `E_RETURN_TYPE_MISMATCH` are catalogued but not raised.
- `Int` and `Byte` unify with each other.
- Parameter annotations are `(name Type)`; see
  `spec/02-syntax-and-forms.md`.

### Generics

- A parameter whose name starts with an uppercase letter is treated as a
  type parameter, and the type slot of `(T Bound)` is read as its bound.
  The §6.1 spelling `((T : Ord) x)` does not work as written: the lexer
  reads `: Ord` as the keyword `:Ord`, so `(T :Ord)` is accepted as an
  ordinary *value* parameter `T` and the function's arity grows by one
  (`(defn mx ((T : Ord) a b) ...)` must then be called with three
  arguments). A bare `((T) x)` is rejected with `E_MALFORMED_PARAMETER`.
- Generic ADTs (§6.5) are the supported and tested case
  (`tests/regression/generics.zyl`, `generics-multi-type.zyl`): one ADT
  may be used at several concrete types in one program. The header of
  `generics.zyl` records that generic functions are not supported.
- Specialisation names are built by `canonical-name-from-type-map`: the
  base name, `_`, then the concrete type names deduplicated, sorted and
  joined with `_`. So `f<Int, String>` and `f<String, Int>` share a name,
  as §6.4 requires, but so do `f<Int, Int>` and `f<Int>`, and compound
  types are named by their outer constructor only (`List`, `Fn`), so
  `f<List<Int>>` and `f<List<String>>` collide. §6.4 requires distinct
  type maps to produce distinct names.
- A bounded type parameter gets one instantiation, the first type that
  satisfies the bound.
- `E_CANNOT_INFER`, `E_TRAIT_BOUND_NOT_SATISFIED` and
  `E_UNKNOWN_GENERIC_PARAM` are catalogued but never raised.

### Traits

- A call to `Trait.method` is resolved statically from the receiver's
  inferred type (`type_annotate.zyl`) to the per-type implementation
  (`Trait.method_Type`); only a receiver of unknown type falls back to a
  `match` on its runtime variant tag. A function that calls a trait
  method on a type variable is instantiated per concrete type.
- `trait` declarations are parsed (`ETraitDecl`); their method signatures
  type calls. There is no `where` clause.
- `(derive T Show)` generates a `Show` impl; the prelude trait `Show`
  (`core/show`) drives `print`. Other derivable traits generate nothing.
- Coherence (§5.3) is not checked: `E_DUPLICATE_IMPL` and
  `E_TRAIT_NOT_FOUND` are catalogued but never raised. A trait method call
  with no matching impl becomes an undefined symbol at link time.
- The package-boundary orphan rule (§24.6) is enforced by the module
  resolver (`E_PKG_ORPHAN_IMPL`).

### Derive

- `(derive Type Trait...)` is parsed, with the traits space-separated as in
  `tests/regression/derive.zyl`. `insert-derive` in `type_inference.zyl` is
  a no-op, and `E_TRAIT_NOT_DERIVABLE` is never raised. Structural
  equality of ADT and struct values in `assert-equal` goes through the
  runtime's `zyl_variant_eq` (shallow: tag plus raw field words) whether or
  not `Eq` was derived.
- The monomorphizer treats `Eq`, `Ord`, `Debug`, `Clone` and `Hash` as
  auto-derived. §5.6 also lists `Show`.
