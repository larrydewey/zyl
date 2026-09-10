# Chapter 15: Type System and Inference

Complete reference for Zyl's type system: primitive types, composite types, capability types, function types, and Hindley-Milner inference.

## 15.1 Primitive Types

| Type | Literal | Size | Description |
|------|---------|------|-------------|
| `Int` | `42` | 64-bit | Signed integer |
| `Float` | `3.14` | 64-bit | IEEE-754 binary64 |
| `Bool` | `true`/`false` | 1-bit (tagged) | Boolean |
| `String` | `"hi"` | Variable | UTF-8, immutable |
| `Unit` | `unit` | 0-bit | No meaningful value |

### Type Equality

- **Primitives**: Structural (same bits = same type)
- **No subtyping** between primitives
- **No implicit conversion** — use explicit coercion: `(float 42)`, `(int 3.14)`

## 15.2 Composite Types

### Vectors (`Vec<T>`)

```
Vec<T> ::= "Vec" "<" Type ">"
```

- Contiguous, growable array
- O(1) indexing (bounds-checked)
- Region: Heap
- Created via `vec-create`, `vec-push`, etc. (stdlib)

### Maps (`Map<K,V>`)

```
Map<K,V> ::= "Map" "<" Type "," Type ">"
```

- Hash map with deterministic iteration (sorted by key hash)
- Region: Heap
- Created via `map-create`, `map-put`, etc. (stdlib)

### Sets (`Set<T>`)

```
Set<T> ::= "Set" "<" Type ">"
```

- Hash set with deterministic iteration
- Region: Heap

### Tuples (`Tuple<T...>`)

```
Tuple<T...> ::= "Tuple" "<" Type ("," Type)* ">"
```

- Fixed-size product type
- Anonymous (no name)
- Region: Stack/Heap

### Result (`Result<T,E>`)

```
Result<T,E> ::= "Result" "<" Type "," Type ">"
```

- ADT: `(Ok T)` | `(Err E)`
- Error handling without exceptions

### Option (`Option<T>`)

```
Option<T> ::= "Option" "<" Type ">"
```

- ADT: `(Some T)` | `None`
- Replaces null

## 15.3 Capability Types

Capabilities annotate types with **access permissions**:

| Capability | Notation | Meaning | Aliasing |
|------------|----------|---------|----------|
| Shared Immutable | `TCap<T>` | Read-only, any refs | ✅ Unlimited |
| Exclusive Mutable | `TMut<T>` | Read-write, one ref | ❌ None |
| Atomic | `TAtomic<T>` | Thread-safe mutation | ✅ Unlimited |
| Boxed | `TBox<T>` | Heap-owned | ❌ Single owner |
| Pinned | `TPin<T>` | FFI, non-moving | ❌ FFI only |

### Capability Rules

1. **TCap**: Any number of references allowed. Immutable.
2. **TMut**: Exactly one reference. Mutable via `let-mut` + `set!` (rebinding).
3. **TAtomic**: Shared mutation via atomic ops. Actor-safe.
4. **TBox**: Heap allocation with unique ownership.
5. **TPin**: Non-moving memory for FFI. Created via `ffi-pin`.

### Capability Subtyping

```
TMut<T> <: TCap<T>     (mutable can be used as immutable)
TAtomic<T> <: TCap<T>  (atomic can be used as immutable)
TBox<T> <: TCap<T>     (boxed can be used as immutable)
TPin<T> <: TCap<T>     (pinned can be used as immutable)
```

**No other subtyping** — capabilities are not interchangeable.

## 15.4 Function Types

```
TFun ::= "TFun" "(" ParamTypes ")" ReturnType
ParamTypes ::= Type ("," Type)*
ReturnType ::= Type
```

Examples:
- `TFun([Int, Int], Int)` — two Int params, Int return
- `TFun([], Unit)` — no params, Unit return
- `TFun([TFun([Int], Int)], Int)` — higher-order

### Calling Convention

- First 6 args: registers (`rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`)
- 7th+: stack (right-to-left)
- Return: `rax` (Int/pointer), `xmm0` (Float)

## 15.5 User-Defined Types

### Structs

```
StructType ::= Identifier   ; Name of defstruct
```

- Nominal typing: `Point` ≠ `Vec2` even with same fields
- Immutable by default
- Fields: `(name)` — types inferred

### ADTs

```
ADTType ::= Identifier TypeArgs?
TypeArgs ::= "<" Type ("," Type)* ">"
```

- Nominal typing
- Variants: `(VariantName Type*)`
- Recursive allowed

### Aliases

```
AliasType ::= Identifier
```

- Transparent: `UserId` = `Int` everywhere
- Zero-cost coercion

## 15.6 Type Inference (Hindley-Milner)

### Algorithm

1. **Constraint generation**: Walk AST, generate type variables and constraints
2. **Unification**: Solve constraints with occurs-check
3. **Generalization**: Quantify free type variables at `defn` boundaries
4. **Instantiation**: Fresh type variables at each call site

### Features

- **Full HM**: Let-polymorphism, higher-rank not supported
- **Trait constraints**: `T : Trait` added to type variables
- **Capability constraints**: Region/capability vars unified
- **Monomorphization**: After inference, concrete types substituted

### Inference Rules (Key)

```
Γ ⊢ x : τ          (Variable)
Γ ⊢ n : Int        (Integer literal)
Γ ⊢ f : σ          (Function name)
Γ ⊢ (f a...) : τ   (Application, with instantiation)

Γ, x:τ ⊢ e : τ'    (Let binding)
Γ ⊢ let x = e1 in e2 : τ2

Γ ⊢ λx.e : τ→τ'    (Lambda)
Γ ⊢ match e with p_i → e_i : τ   (Match, all arms same type)
```

### Type Annotations (Optional)

```lisp
(defn add ((a Int) (b Int)) Int
  (+ a b))
```

- Checked for consistency with inference
- Useful for documentation, resolving ambiguity
- Not required — inference is complete

## 15.7 Type Errors

| Error | Cause |
|-------|-------|
| `E_TYPE_MISMATCH` | Expected τ₁, found τ₂ |
| `E_UNIFICATION_FAILED` | Cannot unify τ₁ and τ₂ (occurs-check or conflict) |
| `E_TRAIT_BOUND_NOT_SATISFIED` | Concrete type lacks required trait |
| `E_CANNOT_INFER` | Type variable unconstrained |
| `E_INFINITE_TYPE` | Occurs-check failure (recursive type) |

## 15.8 Monomorphization

After inference (Phase 5):

1. Collect all call sites of generic functions
2. For each, infer concrete type arguments
3. Verify trait bounds satisfied
4. Generate specialized function: `fn_Type1_Type2...`
5. Types sorted alphabetically for determinism
6. Replace calls with specialized versions

```lisp
(defn id ((T) x) x)

(id 42)        → id_Int
(id "hi")      → id_String
(id 1.0)       → id_Float
```

## 15.9 Type Representation (Runtime)

| Type | Representation |
|------|----------------|
| `Int` | Tagged 64-bit (LSB=1) |
| `Float` | Boxed 64-bit IEEE-754 |
| `Bool` | Tagged immediate |
| `String` | Ref-counted pointer |
| `Vec<T>` | `{ptr, len, cap}` |
| `Struct` | Contiguous fields |
| `ADT` | Tag byte + payload |
| `Closure` | `{fn_ptr, env_ptr}` |
| `TCap<T>` | Same as T (erased) |
| `TMut<T>` | Same as T (erased) |

**Capabilities erased at runtime** — only affect compile-time checking.