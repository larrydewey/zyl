# Chapter 11: Testing

Testing is a **core language built-in** in Zyl (Spec §20.5). The test forms are recognized by the compiler and executed by a harness in the runtime, not by an external library, and the same framework runs Zyl's own regression suite. Every example in this chapter was compiled with `zyl` and run; the output shown is what the binary prints.

## 11.1 The Simplest Test

A test is a top-level form that pairs a name with a body:

```lisp
(test "factorial-of-five"
  (assert-equal (factorial 5) 120))
```

When the compiled program starts, every top-level `test` is registered with the runtime harness. To run the registered tests, end the file with:

```lisp
(run-tests)
```

A file with tests needs no `main`: the compiler generates one that registers the tests and then evaluates the file's top-level forms, including `(run-tests)`. Leave out `(run-tests)` and the program registers its tests and exits without running any. A file may not have both tests and its own `main`. Top-level `test`/`run-tests` forms next to an explicit `(defn main ...)` are rejected with `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN`, so keep a program and its tests in separate files (Chapter 13 does this).

With `factorial` defined, the example above prints:

```
test: factorial-of-five ... ok

test result: 1 passed, 0 failed, 1 total
```

You can define any number of tests; each one is another top-level form:

```lisp
(test "addition"
  (assert-equal (+ 1 2) 3))

(test "multiplication"
  (assert-equal (* 3 4) 12))

(run-tests)
```

> **Note on `test-suite` (Spec §20.5.1):** the specification groups tests with `(test-suite "name" (test ...) ...)`. The form compiles, but the tests nested inside it are silently dropped: they are neither registered nor run. Use flat top-level `test` forms.

## 11.2 Assertions

| Assertion | Purpose |
|-----------|---------|
| `(assert-equal a b)` | Fail if the two values differ |
| `(assert-true expr)` or `(assert-true expr "msg")` | Fail if `expr` is false |
| `(assert-false expr)` or `(assert-false expr "msg")` | Fail if `expr` is true |

The optional message is accepted but not printed; a failing test is reported only as `FAIL`.

A test body may contain several forms, evaluated in order (wrapping them in `begin` is equivalent). The first failing assertion ends the test:

```lisp
(defstruct Point x y)

(test "equality"
  (begin
    (assert-equal (+ 1 2) 3)
    (assert-equal (struct-get (make-Point 1 2) "x") 1)))

(test "booleans"
  (begin
    (assert-true (> 5 3))
    (assert-false (< 5 3))))

(run-tests)
```

### What `assert-equal` Compares

- **Ints, Bools, and Floats** compare by value. Floats compare with a tolerance of `1e-5`.
- **Strings** compare by content: `(assert-equal "ab" (str-concat "a" "b"))` passes.
- **Structs and ADT values** compare **shallowly**: the variant tag and each field as a raw 64-bit word. `(assert-equal (Some 1) (Some 1))` and two `make-Point 1 2` values are equal, but a field that is itself a struct, ADT, or list is compared by address. `(assert-equal (Cons 1 Nil) (Cons 1 Nil))` and `(assert-equal (Some (Some 1)) (Some (Some 1)))` **fail**.

For nested data, assert on the individual fields, or on a count or sum computed from the structure.

> **`assert` and `assert-fail`:** a false `(assert expr "msg")` fails the test, but reports only `assert failed`, not your message; `assert-true` reports better. `assert-fail` is still not enforced: it evaluates its expression and always passes, so avoid it until the runtime check lands.

## 11.3 Running Tests

Compile the file, then run the program it produces. `-o <name>` makes the compiler write the executable `<name>` and its assembly `<name>.s`; without `-o`, the executable is named after the source file with `.zyl` removed:

```bash
# Build (produces ./test-file and test-file.s)
zyl test-file.zyl -o test-file

# Run the tests
./test-file
```

`zyl` works from any directory: it finds the standard library in `~/.zyl` (or `$ZYL_HOME`) after `./install.sh`, and otherwise next to the compiler binary. `(use name)` also finds your own modules next to the file being compiled (Chapter 13).

There is no command-line filter; tests always run in source order. A failing test does not stop the others, and the harness prints a summary at the end:

```
test: addition ... ok
test: multiplication ... FAIL

test result: 1 passed, 1 failed, 2 total
```

A failure is a runtime panic inside the test body (a failed `assert-equal`, `assert-true` or `assert-false`, or an `error` call) that the harness catches and attributes to that test. **Check the summary line, not the exit status:** a test program currently exits with status 0 even when tests fail. Zyl's own `run_regression_tests.sh` looks for `FAIL` in the output for that reason.

The harness holds at most 256 tests per program, and test names are truncated to 127 characters.

### Packages: `zyl test`

Inside a package (a directory with a `zyl.pkg`, Spec §31), `zyl test` resolves the package's dependencies, including `dev-deps`, compiles the package's root module, and runs the result. Put the package's tests in that module, or in a test file you compile directly.

## 11.4 Example: A Complete Test File

```lisp
(use collections/vec)

(defn factorial (n)
  (if (<= n 1) 1 (* n (factorial (- n 1)))))

(test "factorial"
  (assert-equal (factorial 5) 120))

(test "edge-case-zero"
  (assert-equal (factorial 0) 1))

(test "vector-push"
  (assert-equal
    (vec-len (vec-push (vec-create 0 4) 42))
    1))

(run-tests)
```

```
test: factorial ... ok
test: edge-case-zero ... ok
test: vector-push ... ok

test result: 3 passed, 0 failed, 3 total
```

## 11.5 On the Roadmap (Spec §20.5)

The following parts of the specification's testing design **compile today but are not executed**:

- **`test-suite` grouping**: nested tests are dropped (§11.1).
- **`setup` / `teardown` fixtures**: accepted at top level, never run.
- **Property-based testing**: `(test-property "name" generator property-fn)` with `gen-int`/`gen-bool`/`gen-string`/`gen-float` generators compiles and is never run. The wrappers in `stdlib/testing/testing.zyl` (`property-int` and friends) only forward to it.
- **`test-compile`** compile-time tests: accepted, no effect.
- **Keyword options**: `:parallel`, `:filter`, `:verbose` and similar keywords on `test` and `run-tests` are accepted and ignored. The `run-tests-filtered`, `run-tests-parallel`, and `run-tests-with-timeout` helpers in `stdlib/testing/testing.zyl` are placeholders that raise an error.

Build suites from flat `test` forms today, which is exactly how Zyl's own `tests/regression/*.zyl` files work.

## 11.6 Testing Actors

Actors cannot yet receive messages or report results back to their parent (Chapter 9). What a test can check deterministically is an actor's lifecycle, after an explicit `actor-wait`:

```lisp
(use actor/actor)

(defn work () (+ 1 2 3))

(test "actor-finishes"
  (let a (spawn (fn () (work)))
    (begin
      (actor-wait a)
      (assert-false (actor-is-alive a)))))

(run-tests)
```

For the logic itself, keep it in ordinary functions (like `work` above) and test those directly, leaving a thin actor wrapper on top.

## 11.7 Testing Best Practices

1. **One behavior per test**: failures report only the test name, so a narrow test is easier to diagnose.
2. **Descriptive names**: `"add-two-positive-ints"`, not `"add"`.
3. **Test edge cases**: zero, negatives, empty collections, extreme values.
4. **Keep tests independent**: tests run in sequence in one process, so do not rely on state left by an earlier test.
5. **Extract pure logic** and test it directly rather than through actors.
6. **Read the summary line**: the exit status does not reflect failures yet (§11.3).

## 11.8 Zyl's Own Regression Suite

Zyl's test suite is written with this framework:

```bash
./run_regression_tests.sh --quick   # Smoke tests plus the unit test
./run_regression_tests.sh --full    # All tests
./run_regression_tests.sh --filter structs  # Only tests whose name contains "structs"
```

The tests live under `tests/` (`tests/regression/` for the `test`-based files). The harness itself is part of the compiler (the lowering of `test` and `run-tests`) and the runtime (`runtime/actor_runtime.c`). `stdlib/testing/testing.zyl` holds only thin helper wrappers around the built-in forms.

---

## For Experts: Under the Hood

### Test Execution Model

1. **Registration**: the compiler lowers each top-level `test` into a named test function plus a `zyl_register_test(name, fn)` call, made from the generated `main` before anything else runs.
2. **Execution**: `(run-tests)` lowers to a `zyl_run_tests()` call, which runs the tests sequentially in registration order and prints `ok` or `FAIL` for each, then the summary. It returns 1 if any test failed, but that value does not currently become the process exit status.
3. **Panic containment**: each test runs under a `setjmp` guard. `zyl_panic`, which every failed assertion calls, `longjmp`s back to the harness, so a failure marks that test as failed instead of ending the process. Outside a test, the same failure prints `PANIC: assert-equal failed` and exits with status 1.
4. **Deterministic**: there is no parallelism, and output order is fixed by the source.

### Isolation

- A panic inside a test unwinds to the harness; the process survives.
- There is no `try` boundary between assertions in the same test: the first failure abandons the rest of that test's body.
- Tests share one process and one heap; there is no fresh environment per test yet (Spec §11 calls for one).

### Why Suites Are Pending

`zyl_run_tests` iterates a flat registry. Supporting `test-suite`, fixtures, and property tests means either flattening suites into ordinary registrations at compile time or teaching the runtime about grouping. Compile-time flattening is the likely first step.

---

**Next:** [Chapter 12: FFI and Systems Programming](ch12-ffi.md) covers the foreign function interface, pinning, and calling C.
