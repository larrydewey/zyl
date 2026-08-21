# Regression Tests

## Overview

This file documents the test infrastructure and how to run tests for Zyl.

**Canonical spec reference:** `spec/10-structs-and-data-types.md`, `spec/02-syntax-and-forms.md`

---

## Quick Start

```bash
./run_regression_tests.sh --quick   # Smoke tests + unit test (~30s)
./run_regression_tests.sh --full    # All tests (~5min)
./run_regression_tests.sh --dry-run # List tests without running
```

### Options

| Flag | Description |
|------|-------------|
| `--quick` | Run smoke tests + unit_test.zyl (default) |
| `--full` | Run all tests (smoke, regression, stress, integration) |
| `--dry-run` | List tests without running |
| `--filter N` | Run only test file N (basename, e.g. `--filter structs`) |
| `--verbose` | Print compiler/runtime output |
| `--depth N` | Set nesting depth for stress tests (default: 100) |
| `--timeout N` | Per-test timeout in seconds (default: 10) |

---

## Test Directory Structure

```
tests/
├── unit_test.zyl              # Comprehensive harness + all stdlib tests (primary)
├── regression/                # Domain-specific regression tests
│   ├── arithmetic.zyl         # +, -, *, /, multi-operand, float chains
│   ├── control-flow.zyl       # if, while, for, cond, begin, nested
│   ├── functions.zyl          # defn, recursion, nested calls, HOFs
│   ├── structs.zyl            # defstruct, defstruct+, struct-get (ALL spec §8/§10)
│   ├── adts.zyl               # deftype, match, exhaustiveness, recursive ADTs
│   ├── closures.zyl           # fn, lambda, capture, env structs
│   ├── macros.zyl             # defmacro, gensym, nested macros, unless/when
│   ├── types.zyl              # HM inference, traits, generics, TCap/TMut
│   ├── concurrency.zyl        # spawn, send, send-closure, actors, mailboxes
│   ├── ffi.zyl                # ffi-call, ffi-pin, ffi-unpin, timeout
│   ├── io.zyl                 # read-line, file-open/read/write/close
│   ├── collections.zyl        # Vec, Map, Set, StringBuffer growth
│   └── compiler.zyl           # stdlib/compiler: lexer, parser, ICNF
├── smoke/                     # Quick sanity checks (< 5s each)
│   ├── hello-world.zyl
│   ├── let-binding.zyl
│   ├── struct-basic.zyl
│   ├── factorial.zyl
│   └── if-cond.zyl
├── stress/                    # Edge cases and stress tests
│   ├── balanced-parens.zyl    # S-expression balance edge cases
│   ├── deep-recursion.zyl     # factorial, fibonacci, mutual recursion
│   ├── large-struct.zyl       # 20+ field structs
│   └── multi-operand-chains.zyl # 20+ operand arithmetic
└── integration/               # Multi-module tests
    ├── use-stdlib.zyl         # Multi-module (use + export)
    ├── trait-dispatch.zyl     # OutputStream trait dispatch
    └── actor-message.zyl      # Multi-actor message passing
```

---

## Struct Regression Tests

**Trigger before modifying:** `src/ast.rs`, `src/codegen.rs`, `src/icnf.rs`, `src/type_inference.rs`, `src/parser.rs`, `src/region_inference.rs`

```bash
./run_regression_tests.sh --filter structs
```

### Spec Coverage (spec §8/§10)

| Feature | Test File |
|---------|-----------|
| Basic construction | `tests/regression/structs.zyl` |
| defstruct+ variant | `tests/regression/structs.zyl` |
| Type-annotated fields | `tests/regression/structs.zyl` |
| Field access in arithmetic | `tests/regression/structs.zyl` |
| Nested struct-get (3+ levels) | `tests/regression/structs.zyl` |
| Struct in control flow | `tests/regression/structs.zyl` |
| Struct immutability (rebinding only) | `tests/regression/structs.zyl` |
| Large structs (20+ fields) | `tests/stress/large-struct.zyl` |

---

## S-Expression Balance Testing

The S-expression balance is **critical** for this language. Any imbalance causes parse failures that cascade through the entire pipeline.

### Always test after modifying parser/lexer:

```bash
./run_regression_tests.sh --filter balanced-parens
```

### What is tested (`tests/stress/balanced-parens.zyl`):

- Deep nesting (10, 20 level) via let chains, if chains, function calls
- Adjacent S-expressions at top level
- Empty forms `()`, `(begin)`
- String literals with parens (should not affect balance)
- Comment-interleaved forms
- Mixed depth nesting (let + if + while)

---

## How to Add New Tests

1. Determine the category:
   - Quick smoke test → `tests/smoke/`
   - Domain-specific regression → `tests/regression/<domain>.zyl`
   - Stress/edge case → `tests/stress/`
   - Multi-module integration → `tests/integration/`

2. Use the assertion harness pattern:
   ```lisp
   (test "test name"
     (assert-equal (expression) expected-value))
   ```

3. End with `(run-tests)`

4. Run: `./run_regression_tests.sh --full`

---

## Manual Tests

These tests require interactive input and cannot be automated:

### read-line

```bash
echo 'hello world' | ./target/debug/zyl tests/manual/read-line.zyl t.bin && ./t.bin
# Expected: got: hello world
```

---

## Future Improvements

- [ ] Golden output comparison (tracked as future work)
- [ ] Parallel test execution
- [ ] Test filtering by keyword
- [ ] CI integration
