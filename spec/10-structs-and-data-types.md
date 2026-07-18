# Zyl Specification — Structs and Data Types

**Canonical authority:** `zyl_specification.txt` §8, §10 (mutability), §21.11
**Related:** `spec/04-evaluation-semantics.md`, `spec/05-types-and-inference.md`
**Implementation:** `src/parser.rs`, `src/ast.rs`, `src/type_inference.rs`, `src/codegen.rs`

---

## 8. Algebraic Data Types (ADTs)

### 8.1 ADT Declaration

```lisp
(deftype Name (Variant1 TypeExpr*) (Variant2 TypeExpr*) ...)
```

### 8.2 Variant Construction

```lisp
(Some 42)    ; constructs Some variant with value 42
None         ; constructs None variant
(Red)        ; constructs Red variant (no fields)
```

Auto-detection: variant construction is detected via uppercase heuristic
(constructors start with uppercase letter).

### 8.3 Pattern Matching

```lisp
(match Expr (VariantName pattern* body) ...)
```

Exhaustiveness required. Missing cases = Compile Error (`E_MATCH_NONEXHAUSTIVE`).

### 8.4 ADTs and Generics

```lisp
(deftype Option (Some T) None)
```

Monomorphized per concrete type.

---

## Struct System

### Syntax

```lisp
(defstruct Name (Field1) (Field2) ...)
(defstruct+ Name (Field1) (Field2) ...)  ; variant alias
(defstruct Name (Field1 Type1) (Field2 Type2) ...)  ; with type annotations
(defstruct Name (Field1) (Field2) (:derive Eq Ord))  ; with trait derives
```

### Constructor

```lisp
(make-StructName val1 val2 ...)
```

Auto-generated for every `defstruct`. Allocates struct on Heap.

### Field Access

```lisp
(struct-get struct "field-name")
```

Retrieves field value by name. Compiler generates accessors for every defstruct field.

### Field Types

Optional type annotations: `(Field Name Type)`.
Field type lookup from struct_defs during type inference.

### Struct Immutability

Fields defined in `defstruct` are **immutable by default**.

**Mutation requires rebinding the entire struct:**
```lisp
(let-mut p (make-Point 10 20)
  (set! p (make-Point 30 20)))  ; OK: rebinding
```

**Direct field mutation is FORBIDDEN:**
```lisp
(set! (struct-get p "x") 5)  ; ERROR: E_MUT_CONFLICT
```

### Struct Region

Struct instances are allocated on Heap by default (per R2 escape rule).

---

## 10. Mutability and Aliasing (Struct Context)

- Struct instances are immutable: no in-place field mutation
- Rebinding requires `let-mut` binding
- Struct field access returns a copy of the field value (or a reference, depending on capability)
- Alias transparency: struct aliases are zero-cost (no runtime unwrap)

---

## 21.11 Struct Accessors

```lisp
(struct-get struct field-name)
```

Retrieves field value. Compiler generates these for every defstruct field.

---

## Value Model: StructValue

```
StructValue(Name, Map<Name, V>)
```

Immutable aggregate. Fields cannot be mutated in place.
Mutation requires rebinding the entire struct instance.
