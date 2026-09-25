# Zyl Specification — Evaluation Semantics

**Canonical authority:** `zyl_specification.txt` §3, §7, §11, §12, §20.5
**Related:** `spec/02-syntax-and-forms.md`, `spec/10-structs-and-data-types.md` (pattern matching)
**Implementation:** all phases (evaluation order); `stdlib/compiler/icnf.zyl` and `stdlib/compiler/codegen.zyl` (lowering); `runtime/actor_runtime.c` (`zyl_panic`, try frames, test runner)

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

## 7. Closures (Explicit Syntax Only)

### 7.1 Closure Syntax

```lisp
(fn (param*) body)
(lambda (param*) body)
```

No implicit sugar: `((x) body)` is rejected.

### 7.2 Capture Inference

Read-only capture → `TCap`. Mutated capture → `TMut`. Escaping closure → Heap.

### 7.3 Closure Value

```
(Closure Environment Expr CaptureMap)
```

### 7.4 Closure and Concurrency

Spawned closures must only capture Send-capable variables (`TCap`/`TAtomic`).

### 7.5 Closure and Effects

The effect set of a closure is the union of its body's effects.

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

The canonical grammar (§2) requires both branches. The implementation also
accepts `(if c t)`, which evaluates to Unit when `c` is false.

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

---

## 20.5 Testing Framework (Core Language Built-In)

### 20.5.1 Test Registration

```lisp
(test-suite "name" (TestOrSuite*) ...)
(test "name" Body ...)
```

### 20.5.2 Assertions

```lisp
(assert-equal Expr Expr)    ; fails if !=
(assert-fail Expr String?)  ; fails if Expr does not raise an error
(assert-true Expr String?)  ; fails if Expr is false
(assert-false Expr String?) ; fails if Expr is true
```

### 20.5.3 Test Fixtures

```lisp
(setup Body+)     ; run before each test in the suite
(teardown Body+)  ; run after each test in the suite
```

### 20.5.4 Property-Based Testing

```lisp
(test-property "name" Generator PropertyFn)
```

Generators: `gen-int`, `gen-bool`, `gen-string`, `gen-float`.

### 20.5.5 Test Runner

```lisp
(run-tests (:parallel Bool) (:filter String) ...)
```

Default: parallel execution with deterministic ordering.

### 20.5.6 Compile-Time Tests

```lisp
(test-compile Expr (:expect-error Bool))
```

Verifies that `Expr` compiles, or fails to compile, as expected.

---

## Implementation Notes

Not normative. These record how the self-hosted compiler and runtime
behave where it matters to §11, §12 and §20.5.

### Evaluation order

Operands and arguments are evaluated strictly left to right, and a call
through a local function value reads the function before the arguments
(`tests/regression/eval-order.zyl`). A load or store evaluates its
buffer before its offset, although the runtime takes them in the other
order. Code generation departs from the written order only where no
effect can tell (`icnf-has-set`): a local or constant operand is loaded
directly, and a right operand is evaluated first only when it contains no
`set!`. The optimizer folds constants, drops constant-false branches and
inlines small functions, binding the arguments by nested `let`s in call
order; none of it reorders a side effect.

### Errors: `error`, `try`, `unwrap`

- **`(error msg)` aborts; it does not return `(Err msg)`.** It is a library
  function (`stdlib/allocator/allocator.zyl`) that calls the runtime's
  `zyl_panic`. `zyl_panic` unwinds to the innermost `try` if there is one,
  otherwise to the test runner if a test is running, otherwise it prints
  `PANIC: msg` to stderr and exits with status 1. This contradicts §3,
  §12.10 and §21.8.
- **`try`/`catch`** is implemented with `setjmp` and a runtime stack of try
  frames. `(try body (catch e handler))` evaluates `body`; if anything in
  it panics (including `error`), `e` is bound to the panic message and
  `handler` is evaluated. It does not inspect a `Result` value, so an
  `Err` returned normally from `body` passes through unchanged. §12.2
  describes `try` as sugar for matching on `Result`.
- **`(unwrap x)`** takes an `Option` (`(Option a) -> a`, `ta-unwrap`):
  `(Some v)` gives `v`, and `None` panics with `unwrap on None`
  (`ic-unwrap`). A `Result` argument is `E_TYPE_MISMATCH`.
  `stdlib/core/result.zyl` and `stdlib/core/option.zyl` provide
  `result-unwrap` and `option-unwrap`, which take a default.

### `with-resource`

`(with-resource (name init) body)` lowers to a plain `let`. Neither
`close` nor a `Drop` method is called on exit, so §12.9 steps 4 and 5
and guarantee G11 are not met.

### Assertions

`assert`, `assert-equal`, `assert-true` and `assert-false` abort through
`zyl_panic` with a fixed message (`assert-equal failed` and so on) and no
error code; `E_ASSERT_FAIL` is catalogued but not printed.
`assert-equal` unifies its two sides. On ADT or struct values the type
pass renames it to the type's generated `T.==`, the same content
comparison as `==`; a Float type selects an epsilon comparison
(`|a - b| <= 1e-5`); anything else is `=`. `assert-fail` evaluates its
argument and checks nothing.

### Testing framework

- `(test "name" body)` becomes a function registered with the runtime, and
  `(run-tests)` runs every registered test, each under its own panic
  handler, printing `test: name ... ok` or `FAIL` and a summary line.
  Tests run sequentially in registration order; there is no parallel
  runner, and no fresh environment beyond each test being its own
  function.
- `test-suite`, `setup`, `teardown`, `test-property` and `test-compile`
  are parsed and then dropped; only definitions, tests and `run-tests`
  survive to code generation at top level.
- `stdlib/testing/testing.zyl` provides wrappers (`test-run`,
  `assert-equal-values`, `property-int` and similar). Its
  `run-tests-parallel`, `run-tests-filtered` and `run-tests-with-timeout`
  are placeholders that call `error`.
