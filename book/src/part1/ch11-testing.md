# Chapter 11: Testing and Property-Based Testing

Testing is a **core language built-in** in Zyl (Spec §20.5). The testing framework
is part of the language, not an external library, and the same framework powers
Zyl's own regression suite.

## 11.1 The Simplest Test

A test is a top-level expression that pairs a name with a body:

```lisp
(test "factorial-of-five"
  (assert-equal (factorial 5) 120))
```

When the compiled program runs, every top-level `test` is registered with the
runtime harness. To execute all registered tests, end your file with:

```lisp
(run-tests)
```

That's the whole framework. Writing the code above and running it prints:

```
test: factorial-of-five ... ok

test result: 1 passed, 0 failed, 1 total
```

You can define any number of tests; each one is just another top-level form:

```lisp
(test "addition"
  (assert-equal (+ 1 2) 3))

(test "multiplication"
  (assert-equal (* 3 4) 12))

(run-tests)
```

> **Note on `test-suite` (Spec §20.5):** the specification describes grouping
> tests with `test-suite "name" (test ...) ...`. The form parses, but the
> runtime only runs bare top-level `test` forms today — nested suite tests are
> not yet wired into the harness. Prefer flat top-level `test` forms until
> suite support lands.

## 11.2 Assertions

Every test body uses the built-in assertions:

| Assertion | Purpose |
|-----------|---------|
| `(assert-equal expr1 expr2)` | Fail if the two values differ |
| `(assert-true expr "msg")` | Fail if `expr` is false |
| `(assert-false expr "msg")` | Fail if `expr` is true |

`assert-equal` uses **structural equality**, so it works on primitives, tuples,
structs, ADTs, and collections.

```lisp
(test "equality"
  (assert-equal (+ 1 2) 3)
  (assert-equal (struct-get (make-Point 1 2) "x") 1))

(test "booleans"
  (assert-true (> 5 3))
  (assert-false (< 5 3)))
```

> **Equality scope**: `==` compares primitives structurally. For structs and
> ADTs it compares identity, so assert on individual fields rather than whole
> structures (see Appendix C.2).

> **`assert-fail`** is parsed by the compiler but does not yet enforce that an
> expression raises an error; it simply evaluates the expression. Avoid it
> until the runtime check lands.

## 11.3 Running Tests

Compile your file, then run the produced binary. `-o <name>` makes the
compiler emit `<name>.s` (assembly) and `<name>.bin` (the executable); without
`-o` it uses the defaults `a.out.s` / `a.out.bin`:

```bash
# Build (produces test-file.s and test-file.bin)
zyl test-file.zyl -o test-file

# Run the tests
./test-file.bin
```

Run `zyl` from the directory that contains `stdlib/` — module resolution is
relative to the compiler's working directory (see Chapter 13).

There is no `--filter` command-line flag yet; tests always run in source order.
A failing test doesn't stop the others — the harness reports a summary at the
end:

```
test: addition ... ok
test: multiplication ... FAIL

test result: 1 passed, 1 failed, 2 total
```

A failure is a runtime panics (e.g. an `assert-equal` mismatch or an `assert`
inside the test body) that the harness catches and attributes to that test.

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

## 11.5 On the Roadmap (Spec §20.5)

The following are part of the specification's testing design and **parsed by
the compiler today, but not yet executed by the harness**:

- **`test-suite` grouping** — see the note in §11.1.
- **`setup` / `teardown` fixtures** — run before/after each test once wired up.
- **Property-based testing** — `(test-property "name" generator property-fn)`
  with `gen-int`/`gen-bool`/`gen-string`/`gen-float` generators, plus
  `test-compile` for compile-time checks.
- **Test options** — `:parallel`, `:filter`, and `:verbose` keyword arguments
  on `test` and `run-tests` are parsed but have no effect yet.

Treat these as reserved for future use; build your suites with flat `test`
forms today (which is exactly how Zyl's own `tests/regression/*.zyl` files
work).

## 11.6 Testing Actors

Actors process messages asynchronously, and Zyl has no `receive` primitive yet
— a spawned actor cannot reply back to the caller synchronously. The runtime
does ensure that when `main` returns, all spawned actors have drained their
mailboxes (the compiler emits `zyl_actor_wait_all` at the end of `main`).

Deterministic assertions on actor-produced state are therefore a current
limitation. A useful pattern while that matures is to have the actor format its
result and hand it to a captured sink:

```lisp
(test "counter"
  (let-mut (seen Nil)
    (def sink (fn (value) (set! seen value)))
    (spawn (fn (msg) (send sink (process msg))))
    ;; ... send messages, then rely on the end-of-main wait ...
    (assert-true true)))
```

For fully deterministic concurrency tests, prefer decomposing the pure logic
into ordinary functions and testing those — leaving a thin, manually-verified
actor wrapper on top.

## 11.7 Testing Best Practices

1. **One assertion per test** — easier to diagnose failures.
2. **Descriptive names** — `"add-two-positive-ints"`, not `"add"`.
3. **Test edge cases** — zero, negatives, empty collections, extreme values.
4. **Keep tests independent** — no shared mutable state between tests.
5. **Extract pure logic** and test it directly rather than through actors.

## 11.8 Zyl's Own Regression Suite

Zyl's test suite is written with this very framework:

```bash
./run_regression_tests.sh --quick   # Smoke tests
./run_regression_tests.sh --full    # All tests
./run_regression_tests.sh --filter structs  # Struct regression tests only
```

The harness lives in `stdlib/testing/testing.zyl` and the tests in
`tests/regression/`.

---

## For Experts: Under the Hood

### Test Execution Model

1. **Registration**: the compiler lowers each top-level `test` into a named
   `_test_<name>` function plus a `zyl_register_test(name, fn)` call in the
   runtime test registry.
2. **Execution**: `(run-tests)` lowers to a `zyl_run_tests()` call that runs
   tests sequentially in registration order and returns the count of failures
   as the process exit code.
3. **Panic containment**: each test runs inside a `setjmp`/`longjmp` guard, so
   an assertion failure inside a test marks that test as failed instead of
   killing the process.
4. **Deterministic**: no parallelism, no shared state — output order is
   compile-determined.

### Isolation

- A panic inside a test unwinds to the harness; the process survives.
- There is no `try` boundary between assertions in the same test — the first
  failure aborts the remaining body of that test.

### Why Suites Are Pending

The harness (`zyl_run_tests`) iterates the flat registry; implementing
`test-suite`/fixtures/property testing means either lowering suites to flat
registrations at compile time or teaching `zyl_run_tests` to understand
grouping — a compile-time flattening is the likely first step.

---

**Next:** [Chapter 12: FFI and Systems Programming](ch12-ffi.md) — foreign function interface, pinning, and low-level systems programming.