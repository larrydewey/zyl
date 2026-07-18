# Zyl Specification — Evaluation Semantics

**Canonical authority:** `zyl_specification.txt` §3, §11
**Related:** `spec/12-control-flow.md`
**Implementation:** All phases (evaluation order enforced throughout)

---

## 3. Value Model

```
Value V :=
    Int64 | UInt64 | Float64 | Bool | String
  | Tuple(V*)
  | Closure(Environment, Expr, CaptureMap)
  | ActorRef(ID)
  | Address(Region, ID)
  | StructValue(Name, Map<Name, V>)
  | ResultValue(Ok V | Err String)
  | Unit
```

### CaptureMap

Maps captured variable names to inferred regions/capabilities (compile-time only).

### StructValue

Immutable aggregate. Fields cannot be mutated in place.
Mutation requires rebinding the entire struct instance.

### ResultValue

Represents success (Ok) or failure (Err).
`error "msg"` returns `(Err "msg")`.
`try` is sugar for matching on Result.

---

## 11. Evaluation Semantics (Big-Step)

### Judgment

```
⟨E, Σ⟩ → ⟨V, Σ'⟩
```

### State

```
Σ = ⟨H, S, R, A, F, M⟩
```

Where:
- H: Heap
- S: Stack
- R: Region map
- A: Actor registry
- F: Function table
- M: Mailbox state

### Evaluation Order

STRICT LEFT-TO-RIGHT

Function application: evaluate function then arguments sequentially.

### Closure Application

```
(Closure(env, body, captures), args):
    env' = env ∪ bind(params → args)
    captures' = resolve captured variables
    evaluate body under env' with captures'
```

### Test Execution

- Registration: `(test-suite ...)`, `(test ...)`
- Execution: `(run-tests ...)`
- Isolation: Fresh environment per test.
- Parallel: Default parallel execution (deterministic ordering enforced).

---

## 12. Control Flow

### 12.1 IF

```
if true-branch else-branch
```

If the else branch is omitted, the expression produces Unit (`___skip_`).

### 12.2 TRY/CATCH (Result Sugar)

```
(try Expr (catch Name Expr))
```

**Semantics:**
1. Evaluate Expr.
2. If Result is Ok(v), return v.
3. If Result is Err(e), bind e to Name and evaluate catch body.
4. Type of whole expression is Type of Ok branch AND Catch branch (must match).

### 12.3 MATCH

```
(match Expr (VariantName pattern* body) ...)
```

Matches variants in order. Exhaustiveness enforced at compile-time.
Missing cases produce compile error `E_MATCH_NONEXHAUSTIVE`.

### 12.4 ASSERT

```
(assert Expr String)
```

If condition is false → runtime error `E_ASSERT_FAIL`.

### 12.5 WHILE

```
(while Expr Expr)   ; (while condition body)
```

Strict left-to-right. No termination detection (Halting Problem).

### 12.6 FOR

```
(for (init-bindings) condition body)
```

**init-bindings:** list of `(name [value])` pairs, written as S-expressions:
- `(name)` — use existing variable (while-like)
- `(name value)` — new binding with initial value
- `(name1 value1 name2 value2 ...)` — multiple variables
- `()` — empty, pure while loop

**Examples:**
```lisp
(for () (counter < 5) (begin (print counter) (set! counter (+ counter 1))))
(for (i 0) (< i 5) (begin (print i) (set! i (+ i 1))))
(for (i 0 j 10) (< i 5) (begin (print i j) (set! i (+ i 1)) (set! j (+ j 1))))
```

**Semantics:**
1. Evaluate init-bindings: create bindings or use existing variables.
2. Evaluate condition. If false, exit loop.
3. Execute body.
4. Goto step 2.

**Note:** The body is a `begin`-block where the user is responsible for
updating loop variables via `set!`.

### 12.7 COND

```
(cond (condition-1 body-1) ... (else body))
```

### 12.8 BEGIN

```
(begin expr-1 ... expr-n)
```

Returns value of `expr-n`.

### 12.9 WITH-RESOURCE

```
(with-resource (Name Expr) Body)
```

**Semantics:**
1. Evaluate Expr to acquire resource R.
2. Bind Name to R.
3. Evaluate Body.
4. On exit (normal or error), call `(close R)` or Drop trait method BEFORE propagating error.
5. Returns value of Body (or propagates error).

### 12.10 ERROR

```
(error msg)
```

Returns `(Err msg)`. Does not throw.
