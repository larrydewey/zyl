# Chapter 4: Data Structures — Structs, ADTs, and Collections

Zyl provides three primary ways to structure data: **structs** (named product types), **algebraic data types** (sum types), and **collections** (Vec, Map, Set). This chapter covers all three with working examples from the test suite.

## 4.1 Structs — Named Product Types

Structs are immutable aggregates with named fields. Think of them like `struct` in C/Rust, but **immutable by default**.

### Declaration

```lisp
(defstruct Point
  (x)
  (y))

(defstruct Person
  (name)
  (age))

(defstruct Vec3
  (x)
  (y)
  (z))
```

**Field syntax**: `(field-name)` — no type annotation in the declaration. Types are inferred from usage.

### Creating Instances

The compiler auto-generates a constructor `make-<StructName>`:

```lisp
(def p (make-Point 3 4))
(def alice (make-Person "Alice" 30))
(def v (make-Vec3 1 2 3))
```

Arguments are evaluated left-to-right, matched to fields in declaration order.

### Accessing Fields

```lisp
(struct-get p "x")        ; 3 (field name is a STRING)
(struct-get alice "name") ; "Alice"
(struct-get v "z")        ; 3
```

**Field names are strings** — not symbols, not bare identifiers. This avoids naming conflicts with variables.

### Immutability by Default (Critical!)

```lisp
;; THIS IS A COMPILE ERROR:
(set! (struct-get p "x") 10)
;; Error: direct field mutation forbidden
```

Struct fields **cannot be mutated in place**. This is a core design decision — it simplifies reasoning about aliasing and enables the capability type system.

### "Mutating" a Struct: Rebind the Whole Value

To "mutate" a struct, use `let-mut` and `set!` to rebind the **entire struct**:

```lisp
(let-mut (p (make-Point 0 0))
  (set! p (make-Point 10 20))   ; Replace with new struct
  (print (struct-get p "x")))   ; 10
```

This creates a new `Point` and rebinds `p` to it. The old `Point` becomes unreachable.

### `defstruct+` — With Auto-Derived Traits

```lisp
(defstruct+ Color
  (r)
  (g)
  (b)
  (:derive [Eq Ord Debug Show]))
```

Auto-derives trait implementations (Chapter 7). All fields must implement the trait, or you get `E_TRAIT_NOT_DERIVABLE`.

### Nested Structs

```lisp
(defstruct Level3 (content))
(defstruct Level2 (data))
(defstruct Level1 (val))

(def deep (make-Level1 (make-Level2 (make-Level3 99))))

(struct-get (struct-get (struct-get deep "val") "data") "content")
;; 99
```

Each `struct-get` returns the field value, which can be another struct.

## 4.2 Algebraic Data Types (ADTs) — Sum Types

ADTs represent **"one of several variants"** — like `enum` in Rust, `data` in Haskell, or tagged unions in C.

### Declaration

```lisp
;; Option type (like Rust's Option, Haskell's Maybe)
(deftype Option
  (Some T)       ; Variant with one field of type T
  None)          ; Variant with no fields

;; Result type (like Rust's Result)
(deftype Result
  (Ok T)         ; Success with value
  (Err E))       ; Error with error value

;; List (recursive ADT)
(deftype List
  (Cons T (List T))   ; Head + tail
  Nil)                ; Empty list

;; Shape with different variants
(deftype Shape
  (Circle Float)              ; radius
  (Rectangle Float Float)     ; width height
  (Triangle Float Float Float)) ; three sides
```

**Type parameters**: Uppercase identifiers in variant fields (`T`, `E`) make the ADT generic. They're collected from all variant fields — duplicates are merged (same-type constraint).

### Constructing Variants

```lisp
(Some 42)              ; Option<Int>
None                   ; Option<Int> (no args)
(Ok "success")         ; Result<String, E>
(Err "failed")        ; Result<T, String>
(Cons 1 (Cons 2 Nil)) ; List<Int>
(Circle 5.0)          ; Shape
```

Variant names must be **unique across all ADTs in scope** (or qualified via modules — Chapter 25).

### Pattern Matching — The Power of ADTs

```lisp
(match expr
  (Variant1 pattern1 body1)
  (Variant2 pattern2 body2)
  ...)
```

**Exhaustiveness is mandatory** — missing a variant is a compile error (`E_MATCH_NONEXHAUSTIVE`).

```lisp
(defn describe-option (opt)
  (match opt
    (Some x (print "Has value: " x))
    (None (print "Empty"))))
```

### Patterns

| Pattern | Matches | Binds |
|---------|---------|-------|
| `Some x` | `Some` variant | `x` = inner value |
| `None` | `None` variant | (nothing) |
| `Cons x xs` | `Cons` variant | `x` = head, `xs` = tail |
| `d1` | Wildcard (named dummy) | `d1` = value (ignored) |
| `_` | **FORBIDDEN** | Use named dummy `d1`, `d2`, etc. |

**Wildcard must be a named dummy** — bare `_` is rejected by the parser.

```lisp
(match shape
  (Circle r (print "Circle radius " r))
  (Rectangle w h (print "Rect " w "x" h))
  (Triangle a b c (print "Triangle")))
;; No wildcard needed — all variants covered
```

### Nested Patterns

```lisp
(defn sum-first-two (lst)
  (match lst
    (Cons x (Cons y d1) (+ x y))   ; At least 2 elements (d1 ignores rest)
    (Cons x d2 x)                  ; Exactly 1 element
    (Nil 0)))                      ; Empty
```

### Match as Expression (Returns a Value)

```lisp
(defn option-to-result (opt)
  (match opt
    (Some x (Ok x))
    (None (Err "empty"))))
```

Every arm must return the **same type** (enforced by type inference).

## 4.3 Collections (from `stdlib/collections/`)

Zyl's collections are library code, not built-in syntax. Import them:

```lisp
(use collections/vec { vec-create vec-push vec-get vec-len vec-cap vec-pop })
(use collections/map { map-create map-put map-get map-len map-has map-remove })
(use collections/set { set-create set-add set-len set-contains set-remove })
```

### Vectors (`Vec<T>`) — `collections/vec.zyl`

Growable contiguous arrays. O(1) indexing (bounds-checked).

```lisp
(def v (vec-create 0 10))    ; Create empty vec, capacity 10
(vec-push v 42)              ; Add element → returns NEW vec
(vec-push v 99)              ; Add another → returns NEW vec
(vec-len v)                  ; 2
(vec-get v 0)                ; 42 (returns -1 if index out of bounds)
(vec-cap v)                  ; 10
(vec-pop v)                  ; Remove last → returns NEW vec
```

**Important**: `vec-push` and `vec-pop` return **new vectors** — they don't mutate in place. Use `let-mut` to track the current version:

```lisp
(let-mut (v (vec-create 0 10))
  (set! v (vec-push v 1))
  (set! v (vec-push v 2))
  (vec-len v))    ; 2
```

### Maps (`Map<K,V>`) — `collections/map.zyl`

Hash maps with **deterministic iteration order** (sorted by key hash).

```lisp
(def m (map-create 0 10))    ; Create empty map, capacity 10
(map-put m "apple" 1)        ; Insert → returns NEW map
(map-put m "banana" 2)
(map-len m)                  ; 2
(map-get m "apple" 0)        ; 1 (default 0 if missing)
(map-has m "apple")          ; true
(map-remove m "apple")       ; Remove → returns NEW map
```

### Sets (`Set<T>`) — `collections/set.zyl`

```lisp
(def s (set-create 0 10))
(set-add s 42)               ; Insert → returns NEW set
(set-add s 42)               ; Duplicate ignored
(set-len s)                  ; 1
(set-contains s 42)          ; true
(set-remove s 42)            ; Remove → returns NEW set
```

## 4.4 Option and Result — Standard ADTs

Defined in `stdlib/core/option.zyl` and `stdlib/core/result.zyl`:

```lisp
;; Option
(deftype Option
  (Some T)
  None)

;; Result
(deftype Result
  (Ok T)
  (Err E))
```

### Option Helpers (import from `option` module)

```lisp
(use option { is-some unwrap map })

(is-some (Some 42))    ; true
(is-some None)         ; false

(unwrap (Some 42))     ; 42 (panics on None — avoid in production!)
(map (fn (x) (* x 2)) (Some 21))  ; (Some 42)
(map (fn (x) (* x 2)) None)       ; None
```

### Result Helpers (import from `result` module)

```lisp
(use result { is-ok unwrap map })

(is-ok (Ok 42))        ; true
(is-ok (Err "oops"))   ; false

(map (fn (x) (* x 2)) (Ok 21))   ; (Ok 42)
(map (fn (x) (* x 2)) (Err "x")) ; (Err "x")
```

## 4.5 Tuples

Anonymous fixed-size product types:

```lisp
(tuple 1 "hello" 3.14)     ; Tuple<Int, String, Float>
(tuple)                    ; Same as unit
```

Access via pattern matching:
```lisp
(match (tuple 1 2 3)
  (Tuple x y z (+ x y z)))  ; 6
```

## 4.6 Type Aliases

```lisp
(alias UserId Int)
(alias Point3D (Tuple Float Float Float))
(alias Callback (fn (Int) Int))
```

Aliases are **transparent** — zero-cost, fully interchangeable with their target type. Use for documentation and domain modeling.

```lisp
(defn get-user (id UserId) ...)   ; Same as (defn get-user (id Int) ...)
```

## 4.7 Recursive Data Structures

Zyl supports recursive ADTs naturally. For recursive structs, use `TBox` (heap allocation):

```lisp
;; Binary tree (ADT)
(deftype Tree
  (Node T (Tree T) (Tree T))
  Leaf)

;; Linked list with heap-allocated tail (struct)
(defstruct LinkedNode
  (value)
  (next))   ; In practice, would be (TBox (LinkedNode Int)) for heap allocation
```

The compiler handles recursive type definitions correctly through monomorphization.

## 4.8 Choosing Between Structs and ADTs

| Scenario | Use |
|----------|-----|
| Fixed set of fields, all always present | `defstruct` |
| One of several distinct shapes | `deftype` |
| Variants carry different data | `deftype` |
| Simple key-value pairs | `Map` or `defstruct` |
| Recursive structures | `deftype` (ADT) |
| Need to add fields later | `defstruct` (but breaks binary compat) |

**Rule of thumb:** If you find yourself writing `if (field? x) ... else ...`, you probably want an ADT.

## 4.9 Deriving Traits on ADTs/Structs

```lisp
(derive Option [Eq Ord])      ; Requires T: Eq/Ord
(derive Result [Debug])       ; Requires T: Debug, E: Debug
(derive Point [Eq Ord Hash])  ; Requires all fields: Eq/Ord/Hash
```

Derived implementations are generated at compile time. If a field doesn't implement the trait → `E_TRAIT_NOT_DERIVABLE`.

## 4.10 Module Imports for Stdlib Types

```lisp
(use option { Option Some None is-some unwrap map })
(use result { Result Ok Err is-ok unwrap map })
(use collections/vec { vec-create vec-push vec-get vec-len vec-cap vec-pop })
(use collections/map { map-create map-put map-get map-len map-has map-remove })
(use collections/set { set-create set-add set-len set-contains set-remove })
(use core { print struct-get make- })   ; make- prefix for constructors
```

See Appendix B for full stdlib overview.

---

## For Experts: Under the Hood

### Struct Representation

```c
// In memory: contiguous fields in declaration order
struct Point {
    int64_t x;    // 8 bytes
    int64_t y;    // 8 bytes
};  // Total: 16 bytes, no padding (all Int = 8-byte aligned)
```

- No hidden metadata, no vtable
- Fields laid out in declaration order
- Alignment follows System V AMD64 ABI
- Immutable → safe to share (`TCap`)

### ADT Representation

```c
// Tagged union: discriminant + payload
struct Option_Int {
    uint8_t tag;    // 0 = None, 1 = Some
    int64_t value;  // Only valid if tag == 1
};

struct List_Int {
    uint8_t tag;        // 0 = Nil, 1 = Cons
    int64_t head;       // Valid if tag == 1
    struct List_Int* tail; // Valid if tag == 1 (TBox for heap)
};
```

- Single byte tag (0-255 variants max per ADT)
- Payload follows tag, sized to largest variant
- `Nil`/nullary variants: just the tag byte
- Recursive variants use `TBox` (heap pointer) for the recursive field

### Region Assignment for Data Structures

| Construction | Default Region | Notes |
|--------------|----------------|-------|
| `(make-Point 1 2)` | Stack | Promoted to Heap if returned/captured |
| `(Some 42)` | Stack | Same |
| `(vec-create 0 10)` | Heap | Always Heap (growable) |
| `(map-create 0 10)` | Heap | Always Heap |
| `def` constant struct | Global | Immutable, eagerly initialized |

### Monomorphization of Generic ADTs

```lisp
(deftype Option (Some T) None)

(Some 42)       ; Instantiates Option<Int> → Option_Int
(Some "hi")     ; Instantiates Option<String> → Option_String
```

Each concrete instantiation gets a unique canonical name (alphabetical type order):
- `Option_Int`
- `Option_String`
- `Result_Int_String`
- `List_Int`

This is done in Phase 5 (Monomorphization) — see Chapter 19.

---

**Next:** [Chapter 5: Ownership, Regions, and Capability Types](ch05-ownership-regions-capabilities.md) — Zyl's unique memory model that replaces borrow checking with compile-time region inference and capability types.