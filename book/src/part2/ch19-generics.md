# Chapter 19: Generic Programming and Monomorphization

Complete reference for generics: generic functions, generic ADTs, monomorphization algorithm, canonical naming, and type parameter constraints.

## 19.1 Generic Functions

### Declaration Syntax

```
(defn name ((TypeParam Bound?) ... (param Type?) ...) body)
```

```lisp
;; Unbounded type parameter
(defn identity ((T) x) x)

;; Bounded type parameter
(defn min ((T : Ord) a b) (if (lt a b) a b))

;; Multiple type parameters
(defn pair ((T) (U) x y) (tuple x y))

;; Mixed with value parameters
(defn const ((T) x _) x)

;; Multiple bounds
(defn print-sorted ((T : Ord Show) xs) ...)
```

### Type Parameter Rules

1. **Uppercase identifiers**: `T`, `U`, `V`, `Element`, `Key`, `Value`
2. **Scoped to function**: `T` in one function ≠ `T` in another
3. **Positional but canonicalized**: Monomorphization sorts alphabetically
4. **Same-type constraint**: Multiple occurrences of same param = same concrete type
5. **Type positions only**: variant fields, param types, return types, collections
6. **Not runtime values**: Cannot pattern match on type params

### Type Parameter Bounds

```
Bound ::= ":" TraitName ("," TraitName)*
```

```lisp
(T : Ord)           ; T must implement Ord
(T : Ord, Show)     ; T must implement both Ord and Show
```

- Bounds checked at each call site after type inference
- Recursive bounds supported: `(trait Foo (bar () (Foo T)) : Bar)`

## 19.2 Generic ADTs

### Declaration

Type parameters collected from uppercase field names:

```lisp
(deftype Option (Some T) None)           ; T from Some
(deftype Result (Ok T) (Err E))          ; T, E from Ok, Err
(deftype List (Cons T (List T)) Nil)     ; T from Cons
(deftype Tree (Node T (Tree T) (Tree T)) Leaf)
```

### Same-Type Constraint

Duplicate type params merged:

```lisp
(deftype Pair (Make T T))      ; One param T (both fields same)
(Pair 1 2)     ; OK: Pair<Int>
(Pair 1 "hi") ; ERROR: Int vs String
```

### Generic ADT Monomorphization

Each concrete instantiation → distinct type:

```lisp
(Ok 42)       → Result_Int_E
(Ok "hi")     → Result_String_E
(None)        → Option_Int (if context demands)
```

## 19.3 Monomorphization Algorithm

### Phase 5: Monomorphization

For each call site of a generic function:

1. **Infer concrete types** for ALL type parameters from argument types
2. **Verify trait bounds** satisfied by concrete types
3. **Generate canonical name**: `fn_Type1_Type2...` (types sorted alphabetically)
4. **Cache** for reuse at other call sites with identical types

### Canonical Naming

```python
def canonical_name(base_name, type_map):
    # type_map: {T: Int, U: String}
    types = sorted(type_map.values(), key=lambda t: t.name)
    return f"{base_name}_{'_'.join(t.name for t in types)}"
```

Examples:
```lisp
(pair 1 "hi")        → pair_Int_String
(pair "hi" 1)        → pair_Int_String  (same! alphabetical)
(min 3 5)            → min_Int
(min "a" "b")        → min_String
```

**Determinism**: Same source → identical canonical names regardless of call order.

### Monomorphization of Generic ADTs

Each ADT instantiation gets canonical name:

```lisp
(Option_Int)
(Option_String)
(Result_Int_String)
(List_Int)
```

Constructors and match patterns also monomorphized.

## 19.4 Per-Call-Site Polymorphism

For functions with **untyped parameters** (no type annotations), Zyl uses per-call-site inference:

```lisp
(defn process ((T) xs) ...)  ; T unbounded

(process (Cons 1 Nil))    ; T = Int at this call site
(process (Cons "a" Nil))  ; T = String at this call site
```

Each call site gets its own monomorphized version.

### Recursion Guard

For recursive generic functions:

```lisp
(defn map ((T) (U) f xs)
  (match xs
    Nil Nil
    (Cons x rest (Cons (f x) (map f rest)))))
```

- `map` calls itself with same type params
- Monomorphization detects recursion, reuses same specialization

## 19.5 Trait Bounds and Monomorphization

### Bound Satisfaction

At each call site:
1. Infer concrete types for type params
2. Look up `impl Trait ConcreteType`
3. If not found → `E_TRAIT_BOUND_NOT_SATISFIED`

```lisp
(trait Ord (lt (a T) (b T) Bool))

(impl Ord Int (defn lt (a b) (< a b)))

(min 3 5)      ; OK: Int has Ord
(min "a" "b")  ; ERROR: String lacks Ord
```

### Derived Traits on Generic ADTs

```lisp
(derive Option [Eq])   ; Requires T: Eq
```

Monomorphized `Eq` impl generated for each `Option_T` where `T: Eq`.

## 19.6 Type Parameter Constraints

### Explicit Constraints

```lisp
(defn sort ((T : Ord) xs) ...)  ; T must have Ord
```

### Implicit Constraints (from usage)

```lisp
(defn process (xs)
  (map (fn (x) (+ x 1)) xs))   ; xs must be List<Int> or similar
```

Constraints propagated through unification.

## 19.7 Errors

| Error | Cause |
|-------|-------|
| `E_CANNOT_INFER` | Generic param unconstrained at all call sites |
| `E_TRAIT_BOUND_NOT_SATISFIED` | Concrete type lacks required trait |
| `E_UNKNOWN_GENERIC_PARAM` | Reference to undeclared type param |
| `E_DUPLICATE_TYPE_PARAM` | Same type param declared twice |
| `E_TYPE_PARAM_SHADOW` | Nested function shadows outer type param |

## 19.8 Advanced: Higher-Kinded Types

**Not supported in v4.2**. Type parameters are only proper types (`*`), not type constructors (`* → *`).

```lisp
;; NOT SUPPORTED:
(defn lift ((F : Functor) (T) ft) ...)  ; F is * → *
```

Workaround: Use traits with associated types.

## 19.9 Monomorphization and Code Size

- Each unique type combination → new function
- Can cause code bloat with many type combinations
- Compiler deduplicates identical specializations
- Dead code elimination (Phase 7) removes unused

## 19.10 Comparison with Rust

| Feature | Rust | Zyl |
|---------|------|-----|
| Syntax | `fn foo<T: Trait>(x: T)` | `(defn foo ((T : Trait) x) ...)` |
| Monomorphization | ✅ | ✅ |
| Canonical naming | Mangled | `fn_Type1_Type2...` (alphabetical) |
| Type inference | Local + global | Full HM + trait resolution |
| Higher-kinded | ✅ (GATs) | ❌ |
| Const generics | ✅ | ❌ |
| Specialization | ✅ (unstable) | ❌ |