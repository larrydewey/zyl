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
| `--filter N` | Run tests whose name CONTAINS N (e.g. `--filter math` runs every `math-*` file, `--filter lsp` runs the language-server suite) |
| `--no-boot` | Skip the self-hosting fixed-point check at the end of `--full` |
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
│   ├── bitwise.zyl            # bit-and/or/xor/not, shl/shr/ashr, defined
│   │                          #   out-of-range shift counts, n-ary folding
│   ├── byte-primitives.zyl    # bytebuf, load/store round-trips, slices,
│   │                          #   atomics, alignment
│   ├── param-kinds.zyl        # String and Float parameters: printing,
│   │                          #   comparison, arithmetic, return kinds
│   ├── math-*.zyl             # Published NIST/FIPS/RFC vectors, one file per
│   │                          #   algorithm family (16 files)
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
├── integration/               # Multi-module tests
│   ├── use-stdlib.zyl         # Multi-module (use + export)
│   ├── trait-dispatch.zyl     # OutputStream trait dispatch
│   ├── actor-message.zyl      # Multi-actor message passing
│   └── math-protocol.zyl      # X25519 + HKDF + ChaCha20-Poly1305 + Ed25519
├── compile-fail/              # Programs that MUST be rejected, one per rule
│   ├── secret-*.zyl           # Secret capability violations
│   └── unclosed-opener.zyl    # Balance errors
└── lsp/                       # Language-server protocol tests
    └── lsp_protocol_test.py   # Real JSON-RPC against build/boot/zyl-lsp
```

---

## Language Server Tests

`tests/lsp/lsp_protocol_test.py` drives `build/boot/zyl-lsp` over real
JSON-RPC on stdio — the same transport an editor uses — and asserts on
the responses. Nothing in it reaches into the server's internals, so a
pass means an editor sees what the assertions describe.

```bash
./run_regression_tests.sh --filter lsp
python3 tests/lsp/lsp_protocol_test.py     # or run it directly
```

It covers advertised capabilities, hover (built-ins, functions, ADTs,
structs, fields), navigation (definition, type definition,
implementation, references with and without the declaration, document
highlight), symbols and folding, completion (general and inside
`(use ...)`), signature help, semantic tokens (full and by range),
rename, and one diagnostic case per compiler check the server runs.

It runs in both `--quick` and `--full` mode, and skips with a notice if
`build/boot/zyl-lsp` has not been built.

---

## Constant-Time (Timing Leakage) Harness

Opt in with `--filter timing`. It is deliberately not part of a plain
`--full` run: it spawns thousands of short processes and takes longer
than every other test combined, and its result is a statistic rather
than a pass or fail of the code itself.

```bash
./run_regression_tests.sh --filter timing
```

The harness carries a deliberately leaky comparison as a **positive
control** and fails if it cannot detect it, so a green result means the
measurement worked.

---

## Struct Regression Tests

**Trigger before modifying:** `ast.zyl`, `codegen.zyl`, `icnf.zyl`,
`type_inference.zyl`, `parser.zyl`, `region_inference.zyl` — all under
`stdlib/compiler/`.

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
echo 'hello world' | ./build/boot/zyl-self tests/manual/read-line.zyl -o t.bin && ./t.bin
# Expected: got: hello world
```

---

## Future Improvements

- [ ] Golden output comparison (tracked as future work)
- [ ] Parallel test execution
- [ ] Test filtering by keyword
- [ ] CI integration
