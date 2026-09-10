# Chapter 11: Testing and Property-Based Testing

Testing is a **core language built-in** in Zyl (Spec §20.5). The testing framework is part of the language, not an external library.

## 11.1 Basic Test Structure

```lisp
(test-suite "suite-name"
  (test "test-name"
    (assert-equal (my-fn 2) 4))
  
  (test "another-test"
    (assert-true (my-pred "hello"))))
```

Run with:
```lisp
(run-tests)
```

## 11.2 Test Suite and Tests

### `test-suite` — Group Related Tests

```lisp
(test-suite "math-tests"
  (test "addition"
    (assert-equal (+ 1 2) 3))
  
  (test "multiplication"
    (assert-equal (* 3 4) 12))
  
  ;; Nested suites
  (test-suite "advanced"
    (test "factorial"
      (assert-equal (factorial 5) 120))))
```

### `test` — Individual Test Case

```lisp
(test "test-name"
  body...)    ; Multiple expressions allowed (implicit begin)
```

Optional keywords:
```lisp
(test "flaky-test"
  (:parallel false)      ; Run sequentially (default: true)
  (:filter "slow")       ; Tag for filtering
  (assert-equal ...))
```

## 11.3 Assertions

| Assertion | Purpose |
|-----------|---------|
| `(assert-equal expr1 expr2)` | Fail if not structurally equal |
| `(assert-fail expr "msg")` | Fail if expr does NOT raise error |
| `(assert-true expr "msg")` | Fail if expr is false |
| `(assert-false expr "msg")` | Fail if expr is true |

### Examples

```lisp
(test "equality"
  (assert-equal (+ 1 2) 3)
  (assert-equal (make-Point 1 2) (make-Point 1 2))
  (assert-equal (vec 1 2) (vec 1 2)))

(test "error-handling"
  (assert-fail (divide 1 0) "division by zero"))

(test "boolean"
  (assert-true (> 5 3) "5 should be > 3")
  (assert-false (< 5 3) "5 should not be < 3"))
```

**All assertions use structural equality** — works on any type.

## 11.4 Setup and Teardown

```lisp
(test-suite "with-fixtures"
  (setup
    (print "Before each test")
    (def *db* (open-db)))
  
  (teardown
    (print "After each test")
    (close-db *db*))
  
  (test "test-1"
    (assert-equal (query *db* "x") 1))
  
  (test "test-2"
    (assert-equal (query *db* "y") 2)))
```

- `setup` runs **before each test** in the suite
- `teardown` runs **after each test** (even if test fails)
- Runs in same environment as test (can bind variables)

## 11.5 Property-Based Testing

Generate random inputs, verify properties hold:

```lisp
(test-property "addition-commutative"
  (gen-int)                    ; Generator for first arg
  (fn (a b)                    ; Property function
    (assert-equal (+ a b) (+ b a))))
```

### Generators

| Generator | Produces |
|-----------|----------|
| `gen-int` | Random `Int` |
| `gen-bool` | Random `Bool` |
| `gen-string` | Random `String` |
| `gen-float` | Random `Float` |

### Property Function

```lisp
(fn (generated-args...)
  (assert-equal ...))
```

- Called many times (default: 100 iterations)
- Fails on first counterexample
- Reports the failing input

### Example: List Reverse

```lisp
(test-property "reverse-involution"
  (gen-int) (gen-int) (gen-int)
  (fn (a b c)
    (let lst (Cons a (Cons b (Cons c Nil)))
      (assert-equal (reverse (reverse lst)) lst))))
```

## 11.6 Compile-Time Tests

Verify code compiles (or fails to compile):

```lisp
(test-compile "(defn foo () 42)" (:expect-error false))

(test-compile "(defn foo () (undefined-fn))" (:expect-error true))
```

Useful for:
- Testing macro expansions
- Verifying error messages
- Ensuring API compatibility

## 11.7 Running Tests

### In Source File

```lisp
;; At end of file:
(run-tests)
```

### Command Line

```bash
# Run all tests in file
zyl test-file.zyl
./test-file

# Run specific suite/filter
zyl test-file.zyl --filter "math"
```

### Test Runner Options

```lisp
(run-tests
  (:parallel true)       ; Parallel execution (default)
  (:filter "pattern")    ; Only run tests matching pattern
  (:verbose true))       ; Print each test name
```

## 11.8 Test Output

```
Running test suite: math-tests
  ✓ addition
  ✓ multiplication
  ✓ advanced/factorial

Running test suite: property-tests
  ✓ addition-commutative (100 iterations)
  ✓ reverse-involution (100 iterations)

All 5 tests passed!
```

Failure:
```
Running test suite: math-tests
  ✓ addition
  ✗ multiplication
    Expected: 12
    Actual: 13
    At: test-file.zyl:15

1 failed, 1 passed
```

## 11.9 Testing Best Practices

1. **One assertion per test** — easier to diagnose
2. **Descriptive names** — `test "add-two-positive-ints"` not `test "add"`
3. **Test edge cases** — zero, negative, empty, max values
4. **Use property-based testing** for algebraic laws
5. **Isolate tests** — no shared mutable state between tests
6. **Fast tests** — keep unit tests under 10ms each

## 11.10 Testing Actors

```lisp
(test "actor-counter"
  (let counter (make-counter)
    (send counter (Inc))
    (send counter (Inc))
    (send counter (Get))
    (wait_all counter)
    (assert-equal (captured-output) "Count: 2")))
```

Use `wait_all` to ensure actor processed messages before asserting.

## 11.11 Regression Test Suite

Zyl's own test suite uses this framework. Run it:

```bash
./run_regression_tests.sh --quick   # Smoke tests
./run_regression_tests.sh --full    # All tests
./run_regression_tests.sh --filter structs
```

---

## For Experts: Under the Hood

### Test Execution Model

1. **Registration phase**: `test-suite`/`test` forms register in global test registry
2. **Filtering**: Apply `:filter` and selection
3. **Parallel execution**: Tests distributed across worker threads
4. **Deterministic ordering**: Results sorted by test name for reproducibility
5. **Reporting**: Aggregated results printed

### Isolation

Each test runs in fresh environment:
- New region scope
- No shared mutable state (enforced by type system)
- `setup`/`teardown` run in test's scope

### Property-Based Testing Implementation

```lisp
(defn run-property (name generators property-fn)
  (for (i 0) (< i 100)
    (let args (map (fn (g) (g)) generators))
    (try (apply property-fn args)
      (catch err
        (print "Counterexample: " args)
        (error err)))))
```

---

**Next:** [Chapter 12: FFI and Systems Programming](ch12-ffi.md) — foreign function interface, pinning, and low-level systems programming.