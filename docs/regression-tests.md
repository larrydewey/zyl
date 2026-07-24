# Regression Tests

## Overview

This file documents regression test commands and test suites. Run these before modifying sensitive areas to ensure no regressions are introduced.

**Canonical spec reference:** `spec/10-structs-and-data-types.md`, `spec/02-syntax-and-forms.md`

---

## Struct Regression Tests

**Trigger before modifying:** `src/ast.rs`, `src/codegen.rs`, `src/icnf.rs`, `src/type_inference.rs`, `src/parser.rs`, `src/region_inference.rs`

### Test 1: Basic struct definition and construction
```bash
echo '(defstruct Point (x) (y))(let p (make-Point 10 20)(print (struct-get p "x"))(print (struct-get p "y")))' > t.zyl && ./target/debug/zyl t.zyl t.bin && ./t.bin
# Expected: 10 then 20
```

### Test 2: Struct field in arithmetic
```bash
echo '(defstruct Point (x) (y))(let p (make-Point 5 7)(print (+ (struct-get p "x") (struct-get p "y"))))' > t.zyl && ./target/debug/zyl t.zyl t.bin && ./t.bin
# Expected: 12
```

### Test 3: Nested struct-get (field values used to construct another struct)
```bash
echo '(defstruct Point (x) (y))(defstruct Pair (left) (right))(let p (make-Point 42 99)(let pair (make-Pair (struct-get p "x") (struct-get p "y")) (print (struct-get pair "left"))))' > t.zyl && ./target/debug/zyl t.zyl t.bin && ./t.bin
# Expected: 42
```

### Test 4: Struct with field types
```bash
echo '(defstruct Person (name String) (age Int))(let alice (make-Person "Alice" 30)(print (struct-get alice "age")))' > t.zyl && ./target/debug/zyl t.zyl t.bin && ./t.bin
# Expected: 30
```

### Test 5: Struct passed to function and returned
```bash
echo '(defstruct Point (x) (y))(defn make-point (x y) (make-Point x y))(defn get-x (p) (struct-get p "x"))(let p (make-point 256 512)(print (get-x p)))' > t.zyl && ./target/debug/zyl t.zyl t.bin && ./t.bin
# Expected: 256
```

### Test 6: defstruct+ variant
```bash
echo '(defstruct+ Color (r) (g) (b))(let c (make-Color 255 128 64)(print (struct-get c "r")))' > t.zyl && ./target/debug/zyl t.zyl t.bin && ./t.bin
# Expected: 255
```

### Run full struct test suite
```bash
./target/debug/zyl stdlib_test.zyl stdlib_test.s 2>&1 | tail -3
```

---

## Full Test Suite (`stdlib_test.zyl`)

**This file MUST be run every session before making changes. Update it when new functionality is added to ensure behavior remains consistent between sessions.**

The file `stdlib_test.zyl` contains 398 lines of tests covering:

### Basic Operations
- Arithmetic: `+`, `-`, `*`, `/` with multiple arguments
- Comparison: `>`, `<`, `>=`, `<=`, `==`, `!=`
- Logical: `and`, `or`, `not`
- Let bindings (nested)
- Let-mut bindings

### Control Flow
- If (with and without else branch)
- Nested if
- While loop
- For loop (new 3-arg syntax)
- Cond (single and multi-clause)
- Begin (empty)

### Functions
- Function definitions (zero-arg, multi-arg)
- Recursive functions (factorial)
- Nested function calls
- Function returning struct

### Macros
- `unless` macro (if → not)
- `when` macro (unless → if)
- Nested macros (`twice`)

### ADT System
- `deftype` with multiple variants
- Variant construction
- Match on ADT

### Struct System (20+ test cases)
- Basic construction and field access
- Field access in arithmetic
- Multiple field access from same struct
- Structs with 2, 3, 4 fields
- Structs with type annotations
- Nested struct-get (3+ levels deep)
- Struct construction from function results
- Struct passed through function calls
- Struct in control flow (if/while/cond)
- `defstruct+` variant
- Structs with boolean fields
- Multiple struct types interleaved
- Struct field in recursive function
- Large struct with same value in multiple fields
- Struct construction with arithmetic in constructor
- Struct rebinding via let-mut + set!
- Structs with all-zero fields
- Single-field struct

---

## Not Tested (By Design — Not Yet Implemented)

- `deftype` pattern matching with complex guards
- `ffi-call` code generation
- `spawn`/`send` runtime
- Closures (lambda/fn syntax)
- `try`/`catch` error handling
- `alias` type system
- `trait`/`impl`/`derive` runtime behavior
- Floating-point arithmetic
- Property-based testing framework
- Contract injection

---

## Quick Smoke Test

For a fast check that the compiler still works:

```bash
echo '(let x 42 x)' > t.zyl && ./target/debug/zyl t.zyl t.bin && ./t.bin
# Expected: 42
```
