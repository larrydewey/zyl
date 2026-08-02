# Zyl Specification — Types and Inference

**Canonical authority:** `zyl_specification.txt` §4, §5, §6
**Related:** `spec/06-capability-types.md`, `spec/05-types-and-inference.md`
**Implementation:** `src/type_system.rs`, `src/type_inference.rs`

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
| C2 | Orphan rule: impl valid only if trait or type defined in current crate. |
| C3 | No conflicting impls. |

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

> Canonical: `zyl_specification.txt` §6 (v4.2). This file is a structured copy.

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
- **Generic structs not supported** — only ADTs and collections may be generic (documented limitation).

### 6.6 Generic ADT Derivation

```lisp
(derive Result [Eq])   ; requires ALL type params to implement Eq
```

Deriving on a multi-param ADT is allowed; the impl is parameterized over the ADT's type params.

### 6.7 Error Cases

| Code | Condition |
|------|-----------|
| `E_CANNOT_INFER` | generic param with no call-site evidence |
| `E_TRAIT_BOUND_NOT_SATISFIED` | concrete type violates a bound |
| `E_UNKNOWN_GENERIC_PARAM` | reference to undeclared type parameter |
| `E_TRAIT_NOT_DERIVABLE` | derive constraint fails |
