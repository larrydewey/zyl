# Chapter 7: Generics and Traits

Zyl supports parametric polymorphism (generics) and ad-hoc polymorphism (traits) with full type inference. This chapter covers both.

## 7.1 Generic Functions

Type parameters are **uppercase identifiers** in parameter position:

```lisp
(defn identity ((T) x) x)

(defn pair ((T) (U) x y)
  (tuple x y))

(defn first ((T) (U) p)
  (match p (Tuple a b a)))
```

### Syntax

```lisp
(defn name ((TypeParam1) (TypeParam2) ... (param1 Type1) (param2 Type2) ...) body)
```

- Type params: `(T)`, `(U)`, etc. — uppercase, in their own parens
- Value params: `(name)` or `(name Type)` — optional type annotation
- Multiple type params: separate parens `(T) (U)`
- Type params can be interleaved with value params

```lisp
;; Two type params, two value params
(defn choose ((T) (U) cond t f)
  (if cond t f))

;; Type param with trait bound
(defn sort ((T : Ord) xs) ...)

;; Multiple bounds
(defn print-sorted ((T : Ord Show) xs) ...)
```

### Type Parameter Rules

1. **Scoped to function** — `T` in one function ≠ `T` in another
2. **Positional but canonicalized** — monomorphization names are alphabetical (see §7.4)
3. **Same-type constraint** — if `T` appears twice, both must be same concrete type
4. **Only in type positions** — variant fields, param types, collection types, return types
4. **Not runtime values** — no `if (int? T) ...`

```lisp
;; Same-type constraint
(deftype Pair (Make T T))  ; Both fields same type
(Pair 1 2)      ; OK: Pair<Int>
(Pair 1 "hi")  ; ERROR: Int vs String
```

### Calling Generic Functions

Type arguments are **inferred from call site**:

```lisp
(identity 42)           ; T = Int
(identity "hello")      ; T = String
(pair 1 "hi")           ; T = Int, U = String
(choose true 10 20)     ; T = Int (from 10 and 20)
```

**Every type parameter must have evidence** at some call site, or it's a compile error `E_CANNOT_INFER` (unless bounded by a trait with finite instances).

## 7.2 Generic ADTs

Type parameters collected from uppercase variant fields:

```lisp
(deftype Option
  (Some T)
  None)

(deftype Result
  (Ok T)
  (Err E))

(deftype List
  (Cons T (List T))
  Nil)

(deftype Tree
  (Node T (Tree T) (Tree T))
  Leaf)
```

**Duplicates merged** — same-type constraint applies:

```lisp
(deftype Result (Ok T) (Err T))  ; Both T → same type for Ok and Err
(Result (Ok 1) (Err "x"))  ; ERROR: Int vs String
```

### Constructing Generic ADTs

```lisp
(Some 42)           ; Option<Int>
(Some "hi")        ; Option<String>
(Ok 1)             ; Result<Int, E>
(Err "x")          ; Result<T, String>
(Cons 1 Nil)       ; List<Int>
```

Type inferred from field values.

## 7.3 Traits — Ad-Hoc Polymorphism

Traits define shared behavior across types. Like Rust traits, Haskell typeclasses.

### Declaration

```lisp
(trait Eq
  (eq (a T) (b T) Bool))

(trait Ord
  (lt (a T) (b T) Bool)
  (gt (a T) (b T) Bool))

(trait Show
  (show (x T) String))

(trait Add
  (add (a T) (b T) T))
```

- Methods are functions with `self` as first param (convention: `a`, `x`, `self`)
- Type parameter `T` is the implementing type
- Can have multiple methods
- Can have supertrait bounds: `(trait Ord (lt ...) (gt ...) : Eq)`

### Implementation

```lisp
(impl Eq Int
  (defn eq (a b) (== a b)))

(impl Eq String
  (defn eq (a b) (== a b)))

(impl Ord Int
  (defn lt (a b) (< a b))
  (defn gt (a b) (> a b)))

(impl Show Int
  (defn show (x) (int-to-string x)))
```

### Coherence Rules (Enforced at Compile Time)

1. **One impl per (Trait, Type) pair** — no overlapping impls
2. **Orphan rule** — impl valid only if trait OR type defined in current crate
3. **No conflicting impls** — enforced globally

Violation → `E_DUPLICATE_IMPL` or `E_TRAIT_NOT_FOUND`.

### Trait Bounds in Generics

```lisp
;; T must implement Ord
(defn min ((T : Ord) a b)
  (if (lt a b) a b))

;; Multiple bounds
(defn print-min ((T : Ord Show) a b)
  (print (show (min a b))))
```

### Trait Resolution

Done in **Phase 3 (Type Inference)**:
1. Collect all trait bounds from function signatures
2. At each call site, resolve concrete types
3. Look up impl for each (Trait, ConcreteType)
4. Verify all bounds satisfied
5. Substitute trait methods with concrete impls

Recursive bounds supported: `(trait Foo (bar () (Foo T)) : Bar)`.

## 7.4 Monomorphization — How Generics Become Concrete

For each call site of a generic function, the compiler:

1. **Infers concrete types** for ALL type parameters from argument types
2. **Verifies trait bounds** are satisfied by concrete types
3. **Generates specialized function** with canonical name:
   ```
   functionName_Type1_Type2_...
   ```
   Types sorted **alphabetically** for determinism:
   - `pair<Int, String>` and `pair<String, Int>` → both become `pair_Int_String`
4. **Caches** for reuse at other call sites with identical types

### Examples

```lisp
(min 3 5)       → min_Int
(min "a" "b")   → min_String
(pair 1 "hi")   → pair_Int_String
(pair 1.0 2.0)  → pair_Float
```

### Deterministic Naming

Canonical name = `fn_` + sorted type names joined by `_`:
- `fn<Int, String>` → `fn_Int_String`
- `fn<String, Int>` → `fn_Int_String` (same!)
- `fn<Int, Int>` → `fn_Int_Int`

This guarantees **same source → identical binary** regardless of call order.

## 7.5 Generic ADT Monomorphization

Each concrete instantiation gets a unique type:

```lisp
(deftype Option (Some T) None)

(Some 42)        ; Instantiates Option<Int> → Option_Int
(Some "hi")      ; Instantiates Option<String> → Option_String
```

Monomorphization applies to:
- ADT constructors: `Some_Int`, `Some_String`
- Pattern matching: match on `Option_Int` vs `Option_String`
- Derived trait impls: `Eq` for `Option_Int` ≠ `Eq` for `Option_String`

## 7.6 Deriving Traits Automatically

```lisp
(defstruct+ Point
  (x)
  (y)
  (:derive [Eq Ord Show]))

(derive Option [Eq])      ; Requires T: Eq
(derive Result [Eq])      ; Requires T: Eq, E: Eq
```

**Constraints:**
- All fields must implement the trait
- For generic ADTs: all type parameters must implement the trait
- Error if constraint fails: `E_TRAIT_NOT_DERIVABLE`

### Supported Derivable Traits

| Trait | Purpose | Required by Fields |
|-------|---------|-------------------|
| `Eq` | Structural equality | `Eq` |
| `Ord` | Ordering | `Ord` |
| `Show` | Human-readable string | `Show` |
| `Debug` | Debug representation | `Debug` |
| `Clone` | Deep copy | `Clone` |
| `Hash` | Hashable | `Hash` |

### Standalone Derive

```lisp
(derive MyType [Eq Ord])
```

Must appear in same module as type. Useful for types from other modules or ADTs.

## 7.7 Traits with Capability Types

Traits work with capability types:

```lisp
(trait Clone
  (clone (x T) T))  ; Returns owned T

(impl Clone (TCap T)
  (defn clone (x) x))  ; TCap is immutable — clone = identity

(impl Clone (TMut T)
  (defn clone (x) (deep-copy x)))  ; TMut needs actual copy
```

### Trait Objects? Not Yet

Zyl does **not** yet support trait objects (`dyn Trait`). All trait usage is monomorphized (static dispatch). Dynamic dispatch is planned.

## 7.8 Practical Examples

### Example: Generic Map Function

```lisp
(defn map ((T) (U) f xs)
  (match xs
    Nil Nil
    (Cons x rest (Cons (f x) (map f rest)))))

;; Usage:
(map (fn (x) (* x 2)) (Cons 1 (Cons 2 Nil)))
;; Infers: T=Int, U=Int
;; Monomorphizes: map_Int_Int
```

### Example: Trait-Bounded Sort

```lisp
(trait Ord
  (lt (a T) (b T) Bool))

(defn quicksort ((T : Ord) xs)
  (match xs
    Nil Nil
    (Cons pivot rest
      (let (less (filter (fn (x) (lt x pivot)) rest))
        (let (greater (filter (fn (x) (not (lt x pivot))) rest))
          (append (quicksort less) (Cons pivot (quicksort greater))))))))
```

### Example: Heterogeneous Collections via Traits

```lisp
(trait Drawable
  (draw (self T) Unit))

(defstruct Circle (r))
(defstruct Rect (w) (h))

(impl Drawable Circle
  (defn draw (self) (print "Circle " (struct-get self "r"))))

(impl Drawable Rect
  (defn draw (self) (print "Rect " (struct-get self "w") "x" (struct-get self "h"))))

;; Can't put in Vec directly (different types)
;; Use ADT wrapper:
(deftype Shape (CircleShape Circle) (RectShape Rect))

(impl Drawable Shape
  (defn draw (self)
    (match self
      (CircleShape c (draw c))
      (RectShape r (draw r)))))
```

## 7.9 Error Messages

| Error | Cause |
|-------|-------|
| `E_CANNOT_INFER` | Generic param has no call-site evidence |
| `E_TRAIT_BOUND_NOT_SATISFIED` | Concrete type doesn't implement required trait |
| `E_UNKNOWN_GENERIC_PARAM` | Reference to undeclared type parameter |
| `E_TRAIT_NOT_DERIVABLE` | Field doesn't implement derivable trait |
| `E_DUPLICATE_IMPL` | Two impls for same (Trait, Type) |
| `E_TRAIT_NOT_FOUND` | No impl for required trait |

---

## For Experts: Under the Hood

### Type Inference with Traits

1. **Unification** generates type variables with trait constraints
2. **Constraint solving** collects all `T : Trait` requirements
3. **Trait resolution** at call sites: substitute concrete types, lookup impls
4. **Monomorphization** generates specialized code

### Canonical Naming Algorithm

```python
def canonical_name(base_name, type_map):
    # type_map: {T: Int, U: String}
    types = sorted(type_map.values(), key=lambda t: t.name)
    return f"{base_name}_{'_'.join(types)}"
```

This runs in Phase 5 (Monomorphization), after type inference.

### Trait Method Dispatch

- **Static dispatch**: Trait methods inlined or direct-called in monomorphized code
- **No vtables**, no dynamic dispatch (yet)
- **Zero overhead** compared to hand-written specialized functions

### Generic ADT Representation

Each monomorphized ADT is a distinct type:
- `Option_Int` = tag + Int
- `Option_String` = tag + String pointer
- Different sizes, different layout

---

**Next:** [Chapter 8: Closures and Higher-Order Functions](ch08-closures.md) — explicit closure syntax, capture inference, and functional patterns.