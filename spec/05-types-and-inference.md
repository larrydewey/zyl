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

### 6.1 Generic Function Declaration

```lisp
(defn name ((TypeParam : TraitBound*) (param Type) ...) body)
```

### 6.2 Generic Type in Collections

```
Vec<T>, Map<K,V>
```

### 6.3 Monomorphization

Alphabetical canonical naming. Deterministic.

### 6.4 Generic ADTs

```lisp
(deftype Option (Some T) None)
```
