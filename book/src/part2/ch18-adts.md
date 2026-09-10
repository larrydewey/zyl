# Chapter 18: Algebraic Data Types and Exhaustive Matching

Complete reference for ADTs: declaration, construction, pattern matching, exhaustiveness, and generic ADTs.

## 18.1 ADT Declaration

```
deftype ::= "deftype" Identifier "(" Variant+ ")" BoundClause?

Variant ::= "(" Identifier TypeExpr* ")"

BoundClause ::= ":" Identifier "[" Identifier* "]"
```

### Examples

```lisp
;; Simple enum-like
(deftype Color (Red) (Green) (Blue))

;; With payloads
(deftype Option (Some T) None)

;; Multiple payloads
(deftype Result (Ok T) (Err E))

;; Recursive
(deftype List (Cons T (List T)) Nil)

;; Generic with multiple params
(deftype Either (Left L) (Right R))

;; With trait bound
(deftype Tree (Node T (Tree T) (Tree T)) Leaf : Ord [T])
```

### Rules

1. **Variant names unique** across all ADTs in scope (or qualified via module)
2. **Type parameters** = uppercase identifiers in variant fields
3. **Duplicates merged** — same-type constraint:
   ```lisp
   (deftype Pair (Make T T))  ; Both fields same T
   ```
4. **Recursive references** allowed (direct or mutual)
5. **Trait bounds** optional: `: Ord [T]` means T must implement Ord

## 18.2 Variant Construction

```
Construction ::= "(" VariantName Arg* ")"
             |  VariantName           ; Nullary variant
```

```lisp
(Some 42)           ; Option<Int>
None                ; Option<T>
(Ok "success")      ; Result<String, E>
(Err "failed")      ; Result<T, String>
(Cons 1 Nil)        ; List<Int>
(Red)               ; Color
```

- Arguments evaluated left-to-right
- Types inferred from argument types
- Must match variant's declared field types

## 18.3 Pattern Matching

```
MatchExpr ::= "match" Expression "(" MatchArm+ ")"

MatchArm ::= "(" VariantName Pattern* Expression ")"

Pattern ::= Identifier           ; Bind variable
          | "_"                  ; FORBIDDEN
          | "d" Digit+           ; Named dummy (wildcard)
          | "(" Pattern* ")"     ; Nested pattern
          | Literal              ; Constant pattern
```

### Patterns

| Pattern | Matches | Binds |
|---------|---------|-------|
| `Some x` | `Some` variant | `x` = inner value |
| `None` | `None` variant | (nothing) |
| `Cons x xs` | `Cons` variant | `x`=head, `xs`=tail |
| `d1` | Any variant/value | `d1` = value (ignored) |
| `42` | Exact Int value | (nothing) |
| `"hi"` | Exact String | (nothing) |
| `true` | Exact Bool | (nothing) |

### Exhaustiveness (Mandatory)

**All variants must be covered** — missing variant = compile error `E_MATCH_NONEXHAUSTIVE`.

```lisp
;; ✅ Exhaustive
(match opt
  (Some x (print x))
  (None (print "none")))

;; ❌ NON-EXHAUSTIVE — missing None
(match opt
  (Some x (print x)))

;; ✅ Exhaustive with catch-all
(match opt
  (Some x (print x))
  (d1 (print "other")))
```

### Match as Expression

```lisp
(defn option-to-result (opt)
  (match opt
    (Some x (Ok x))
    (None (Err "empty"))))
```

- All arms must have **same type**
- Returns value of matched arm

## 18.4 Nested Patterns

```lisp
(match expr
  (Cons (Cons x d1) (Cons y d2) (+ x y))  ; At least 2 elements
  (Cons x d3 x)                            ; Exactly 1 element
  (Nil 0))                                 ; Empty
```

- Patterns can be arbitrarily nested
- Compiler flattens to decision tree
- No pattern guards (use `if` in arm body)

## 18.5 Generic ADTs

### Type Parameters

Collected from **uppercase identifiers** in variant fields:

```lisp
(deftype Result (Ok T) (Err E))   ; Two params: T, E
(deftype Pair (Make T T))         ; One param: T (duplicate merged)
(deftype Triple (Make T U V))     ; Three params: T, U, V
```

### Monomorphization

Each concrete instantiation → distinct type:

```lisp
(Ok 42)          ; Result_Int_E
(Ok "hi")        ; Result_String_E
(Err "err")      ; Result_T_String
```

Canonical naming: `ADTName_Type1_Type2...` (alphabetical sort)

### Generic ADT Operations

```lisp
;; Map over Option
(defn option-map ((T) (U) f opt)
  (match opt
    (Some x (Some (f x)))
    (None None)))

;; Bind for Result
(defn result-bind ((T) (U) (E) r f)
  (match r
    (Ok x (f x))
    (Err e (Err e))))
```

## 18.6 ADTs and Capabilities

### Variant Capabilities

```lisp
;; ADT variants inherit capability from containing value
(let opt (Some (make-Point 1 2)))  ; opt : Option<Point> @ Stack
```

### Send Capability

ADT is Send if **all variant fields are Send**:

```lisp
(deftype Msg (Text String) (Data (Vec Int)) (Ping))
;; All fields Send → Msg is Send

(deftype BadMsg (Mut (TMut Int)))  ; TMut not Send → BadMsg not Send
```

## 18.7 Deriving Traits on ADTs

```lisp
(derive Option [Eq Ord Show])
(derive Result [Eq])
```

**Requirements:**
- All type parameters must implement the trait
- All variant fields must implement the trait
- For `Eq`/`Ord`: structural comparison (tag first, then payloads)

## 18.8 ADT Representation

### Memory Layout

```
Nullary variant (None, Red):
  [tag: 1 byte]

Unary variant (Some Int):
  [tag: 1 byte] [payload: 8 bytes]

Multi-field variant (Cons Int (List Int)):
  [tag: 1 byte] [field1: 8 bytes] [field2: 8 bytes]

Recursive variant (Cons T (List T)):
  [tag: 1 byte] [field1: 8 bytes] [field2: 8 bytes (TBox pointer)]
```

- Tag = variant index (0-based, declaration order)
- Payload sized to largest variant
- Recursive fields use `TBox` (heap pointer)

### Discriminant Values

```lisp
(deftype Color (Red) (Green) (Blue))
;; Red = 0, Green = 1, Blue = 2

(deftype Option (Some T) None)
;; Some = 0, None = 1
```

## 18.9 Match Compilation

1. **Pattern matrix**: Rows = arms, columns = pattern positions
2. **Decision tree**: Compile to efficient jumps
3. **Tag-based dispatch**: Load tag, jump table
4. **Exhaustiveness check**: Verify matrix covers all constructors

### Optimization

- Adjacent arms with same tag merged
- Redundant tests eliminated
- Fall-through for catch-all dummies

## 18.10 Errors

| Error | Cause |
|-------|-------|
| `E_MATCH_NONEXHAUSTIVE` | Missing variant coverage |
| `E_DUPLICATE_VARIANT` | Variant name used in multiple ADTs |
| `E_UNKNOWN_VARIANT` | Variant not in ADT |
| `E_TYPE_MISMATCH` | Pattern field type doesn't match variant |
| `E_WILDCARD_FORBIDDEN` | Bare `_` used as pattern |

## 18.11 Comparison with Other Languages

| Feature | Rust `enum` | Haskell `data` | Zyl `deftype` |
|---------|-------------|----------------|---------------|
| Syntax | `enum X { A, B(u32) }` | `data X = A \| B Int` | `(deftype X (A) (B Int))` |
| Exhaustiveness | ✅ | ✅ | ✅ (mandatory) |
| Pattern guards | `if` in arm | `|` guards | ❌ (use `if` in body) |
| Wildcard `_` | ✅ | ✅ | ❌ (use `d1`) |
| GADTs | ✅ | ✅ | ❌ |
| Deriving | `#[derive(...)]` | `deriving` | `(derive ...)` |