# Regression Tests

## Overview

This file documents the test infrastructure and how to run tests for Zyl.
Everything runs through the self-hosted compiler, `build/boot/zyl-self`;
build it with `./boot.sh` first.

**Canonical spec reference:** `spec/10-structs-and-data-types.md`, `spec/02-syntax-and-forms.md`

---

## Quick Start

```bash
./run_regression_tests.sh --quick            # unit test + smoke tests + LSP protocol test (the default)
./run_regression_tests.sh --full             # every section below, then ./boot.sh
./run_regression_tests.sh --full --no-boot   # every section, without the fixed-point check
./run_regression_tests.sh --dry-run          # list the selected tests without running them
```

A `--full --no-boot` run is 121 tests and takes well under a minute on a
current machine (43 s as of 2026-09-23). `--full` adds one more entry,
`boot/fixed-point`, which runs `./boot.sh` and takes as long as a
bootstrap does.

### Options

| Flag | Description |
|------|-------------|
| `--quick` | Run `tests/unit_test.zyl`, `tests/smoke/*.zyl` and the LSP protocol test (default) |
| `--full` | Run the unit test, regression, stress, integration, interpreter-agreement, package, compile-fail and LSP sections, then the fixed-point check |
| `--dry-run` | List the tests the same mode and `--filter` would run, without running them |
| `--filter N` | Run only tests whose name contains N, case-insensitively (see below) |
| `--boot` | Run the fixed-point check (`./boot.sh`) in any mode |
| `--no-boot` | Skip the fixed-point check that `--full` otherwise runs at the end |
| `--verbose` | Print compiler output for a failed compile, the test output for a failed assertion, and the diff for an interpreter disagreement |
| `--timeout N` | Per-test run timeout in seconds for compiled binaries (default: 10; the interpreted side of the agreement section has its own 60 s budget) |

**`--filter` works within the mode, not across it.** The default mode is
`--quick`, which only runs the unit test, the smoke tests and the LSP
test, so `--filter structs` on its own selects nothing. Combine it with
`--full`, and add `--no-boot` unless you also want a bootstrap:

```bash
./run_regression_tests.sh --full --no-boot --filter structs
./run_regression_tests.sh --full --no-boot --filter math        # every math-* file
./run_regression_tests.sh --filter lsp                          # works in --quick too
```

The name matched is the file's basename for single-file tests;
`interpreter NAME` for the agreement section (so `--filter interpreter`
selects that whole section, and `--filter structs` also selects
`interpreter/structs`); and `packages NAME` for the three package
sections.

`--dry-run` goes through the same selection as a real run, so it lists
exactly the tests the same mode and `--filter` would run (every section,
including the interpreter, package, LSP and fixed-point checks) and
prints their count.

### What counts as a pass

- **Ordinary tests** (`unit_test`, regression, smoke, stress,
  integration, packages): the file must compile, the binary must exit 0
  within the timeout, and its output must not contain `FAIL`. The test
  harness (`stdlib/testing/testing.zyl` plus the runtime's test runner)
  prints `test: NAME ... ok` or `FAIL` per test and a
  `test result: N passed, M failed, T total` line.
- **Compile-fail tests** (`tests/compile-fail/`, `tests/packages-fail/`):
  the compiler must exit non-zero. The runner does not check which code
  was reported.
- **Package builds** (`tests/packages-build/`): `zyl build` in the
  case's `app/` directory must succeed, and the resulting binary must run
  without printing `FAIL`.

Compiled test binaries are written to `/tmp/zyl_test_N.bin` and
`/tmp/zyl_diff_N.bin`; logs for the package-build, LSP, timing and boot
steps go to `/tmp/zyl_*.log`.

### Sections and counts (`--full --no-boot`, 2026-09-23)

| Section | Source | Tests |
|---------|--------|-------|
| unit test | `tests/unit_test.zyl` | 1 |
| regression | `tests/regression/*.zyl` | 52 |
| stress | `tests/stress/*.zyl` | 4 |
| integration | `tests/integration/*.zyl` | 7 |
| interpreter agreement | regression + smoke, minus `DIFF_SKIP` | 34 |
| packages | `tests/packages/*/app/main.zyl` | 2 |
| packages-fail | `tests/packages-fail/*/app/main.zyl` | 7 |
| packages-build | `tests/packages-build/*/app` via `zyl build` | 1 |
| compile-fail | `tests/compile-fail/*.zyl` | 12 |
| LSP protocol | `tests/lsp/lsp_protocol_test.py` | 1 |
| **total** | | **121** |

The smoke tests run directly only in `--quick`; in `--full` they are
exercised through the interpreter-agreement section.

## Interpreter agreement

`--full` runs one more section: every regression and smoke test is run
**twice**, once as a compiled binary and once through the ICNF
interpreter (`zyl eval`, the REPL's evaluator), and the two outputs are
diffed. Two back ends for one language is exactly the kind of thing that
drifts silently, so the suite compares them rather than assuming.

```bash
./run_regression_tests.sh --full --no-boot --filter interpreter            # just this section
./run_regression_tests.sh --full --no-boot --filter interpreter --verbose  # with diffs
```

Only stdout is compared: compiler warnings go to stderr, and the
compiled run emits them at build time while the interpreted run emits
them at eval time — a difference in when, not in what.

Some tests are deliberately left out of this comparison, and
`DIFF_SKIP` in the runner records why for each: programs that spawn
actors (`actors`, `concurrency`, and `modules`, one of whose tests spawns
an actor; an interpreted function has no native entry point, so the
interpreter reports `E_UNSUPPORTED_INTERPRETED`), one that prints a
value's address (`derive`), one that prints the bytes at a pinned address
(`ffi-advanced`), one that assumes a fresh `alloc-malloc` block reads back
as zeroes (`collections`), `package-system` (its signature tests are
Ed25519), and every `math-*` file, which is minutes of interpreted
arithmetic for what the compiled run already covers in seconds. That is
23 of the 57 regression and smoke files, leaving 34.

`docs/repl.md` lists the places the two back ends differ on purpose.

---

## Test Directory Structure

```
tests/
├── unit_test.zyl              # Harness + stdlib tests (runs in --quick and --full)
├── regression/                # 52 domain-specific regression files (--full)
│   ├── arithmetic.zyl         # +, -, *, /, multi-operand, float chains
│   ├── bitwise.zyl            # bit-and/or/xor/not, shifts, n-ary folding
│   ├── byte-primitives.zyl    # bytebuf, load/store round-trips, slices,
│   │                          #   atomics, alignment
│   ├── control-flow.zyl       # if, while, for, cond, begin, nested
│   ├── control-flow-ext.zyl   # nested loops, else-arms, multi init, breaks
│   ├── functions.zyl          # defn, recursion, nested calls, HOFs
│   ├── closures.zyl           # fn, lambda, capture
│   ├── param-kinds.zyl        # String and Float parameters
│   ├── structs.zyl            # defstruct, defstruct+, struct-get (spec §8/§10)
│   ├── adts.zyl               # deftype, match, recursive ADTs
│   ├── alias.zyl              # transparent type wrappers
│   ├── match-exhaustive.zyl   # compile-time exhaustiveness (accepting side)
│   ├── match-value-position.zyl
│   ├── list-accessors.zyl     # car/cdr/cadr/caddr/cddr, list-rest
│   ├── macros.zyl             # defmacro, gensym, nested macros, unless/when
│   ├── types.zyl              # HM inference, traits, generics, TCap/TMut
│   ├── generics.zyl           # generic ADTs, per-site instantiation
│   ├── generics-multi-type.zyl
│   ├── traits.zyl             # trait definitions and impls
│   ├── derive.zyl             # derived traits for structs
│   ├── capabilities.zyl       # TCap/TMut
│   ├── regions.zyl            # region annotations, escape analysis
│   ├── contracts.zyl          # requires, ensures, invariant, recover, checkpoint
│   ├── with-resource.zyl      # lexically scoped resources
│   ├── unwrap-error.zyl       # Result/Option unwrapping, error propagation
│   ├── actors.zyl             # spawn, send, message patterns
│   ├── concurrency.zyl        # spawn, send, send-closure, mailboxes
│   ├── ffi.zyl                # ffi-call, ffi-pin, ffi-unpin, timeout
│   ├── ffi-advanced.zyl       # pinning, timeouts
│   ├── io.zyl                 # read-line, file-open/read/write/close
│   ├── collections.zyl        # Vec, Map, Set, StringBuffer, allocator
│   ├── modules.zyl            # module imports from stdlib
│   ├── package-system.zyl     # spec v5.0 §31 building blocks
│   ├── testing-framework.zyl  # test, assert-*, run-tests, test-suite, test-property
│   ├── secret-capability.zyl  # Secret / constant-time checker, accepting side
│   ├── compiler.zyl           # stdlib/compiler: lexer, parser, AST types
│   └── math-*.zyl             # Published NIST/FIPS/RFC vectors, one file per
│                              #   algorithm family (16 files)
├── smoke/                     # Quick sanity checks (--quick)
│   ├── hello-world.zyl
│   ├── let-binding.zyl
│   ├── struct-basic.zyl
│   ├── factorial.zyl
│   └── if-cond.zyl
├── stress/                    # Edge cases and stress tests (--full)
│   ├── balanced-parens.zyl    # S-expression balance edge cases
│   ├── deep-recursion.zyl     # factorial, fibonacci, mutual recursion
│   ├── large-struct.zyl       # 20+ field structs
│   └── multi-operand-chains.zyl # 20+ operand arithmetic, 10+ operand calls
├── integration/               # Multi-module and end-to-end tests (--full)
│   ├── use-stdlib.zyl         # multi-module use + export
│   ├── trait-dispatch.zyl     # OutputStream trait dispatch
│   ├── actor-message.zyl      # multi-actor message passing
│   ├── math-protocol.zyl      # X25519 + HKDF + ChaCha20-Poly1305 + Ed25519
│   ├── parser-verify.zyl      # reader/parser structure checks
│   ├── pv_min.zyl             # minimal reader smoke test
│   └── selfhost-codegen.zyl   # compiler/icnf + codegen end to end
├── compile-fail/              # 12 programs that MUST be rejected
│   ├── match-non-exhaustive.zyl
│   ├── match-nested-non-exhaustive.zyl
│   ├── unclosed-opener.zyl    # balance errors
│   ├── unexpected-close.zyl
│   ├── mismatched-bracket.zyl
│   └── secret-*.zyl           # 7 Secret capability violations (branch,
│                              #   divide, escape, ffi-unpinned, index,
│                              #   interprocedural, print)
├── packages/                  # multi-package builds that must succeed
│   ├── features/              #   (each case: app/ plus path dependencies)
│   └── two-parses/
├── packages-fail/             # multi-package builds that must be rejected
│   ├── bad-requirement/  capability/  feature-unknown/  orphan-impl/
│   └── private-symbol/  undeclared-dep/  unknown-edition/
├── packages-build/            # built with `zyl build` (native block, lock,
│   └── native/                #   zyl.buildinfo)
├── lsp/
│   └── lsp_protocol_test.py   # real JSON-RPC against build/boot/zyl-lsp
├── manual/
│   └── read-line.zyl          # needs stdin; not run by the suite
└── debug/
    └── stage2_hang_min.zyl    # a reduced reproducer; not run by the suite
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

It runs in both `--quick` and `--full` mode, counts as one test, and is
skipped with a notice if `build/boot/zyl-lsp` has not been built.

---

## Constant-Time (Timing Leakage) Harness

Opt in with `--filter timing` (in either mode). It is deliberately not
part of a plain `--full` run: it spawns thousands of short processes and
takes longer than every other test combined, and its result is a
statistic rather than a pass or fail of the code itself. The runner
calls `python3 verify/timing.py --quick`.

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
./run_regression_tests.sh --full --no-boot --filter struct
```

`struct` (rather than `structs`) also picks up `stress/large-struct` and
the agreement run of `structs`.

### Spec Coverage (spec §8/§10)

| Feature | Test File |
|---------|-----------|
| Basic construction | `tests/regression/structs.zyl` |
| defstruct+ variant | `tests/regression/structs.zyl` |
| Type-annotated fields | `tests/regression/structs.zyl` |
| Field access in arithmetic | `tests/regression/structs.zyl` |
| Nested structs | `tests/regression/structs.zyl` |
| Struct in control flow (`if`, `while`, `cond`) | `tests/regression/structs.zyl` |
| Struct immutability (rebinding, `let-mut`) | `tests/regression/structs.zyl` |
| Large structs (20+ fields) | `tests/stress/large-struct.zyl` |

---

## S-Expression Balance Testing

The S-expression balance is **critical** for this language. Any
imbalance causes parse failures that cascade through the entire
pipeline; the compiler reports it before parsing with
`E_UNBALANCED_UNCLOSED`, `E_UNBALANCED_UNEXPECTED_CLOSE` or
`E_UNBALANCED_MISMATCHED_BRACKET` (see `docs/errors.md`).

### Always test after modifying parser/lexer:

```bash
./run_regression_tests.sh --full --no-boot --filter balanced-parens
./run_regression_tests.sh --full --no-boot --filter unclosed
```

The compile-fail section is filtered by file basename (a filter of
`compile-fail` matches nothing), so the balance cases are selected by
`unclosed`, `unexpected-close` and `mismatched-bracket`.

### What is tested (`tests/stress/balanced-parens.zyl`):

- Deep nesting: 10- and 20-level `let` chains, a 10-level `if` chain
- String literals containing parens (must not affect balance)
- Comments containing parens
- A deep `let` chain spread over lines with irregular whitespace

The rejecting side is `tests/compile-fail/unclosed-opener.zyl`,
`unexpected-close.zyl` and `mismatched-bracket.zyl`.

---

## How to Add New Tests

1. Determine the category:
   - Quick smoke test → `tests/smoke/`
   - Domain-specific regression → `tests/regression/<domain>.zyl`
   - Stress/edge case → `tests/stress/`
   - Multi-module integration → `tests/integration/`
   - Must be rejected by the compiler → `tests/compile-fail/`
   - Multi-package case → a directory with an `app/` package under
     `tests/packages/`, `tests/packages-fail/` or `tests/packages-build/`

2. Use the assertion harness pattern:
   ```lisp
   (test "test name"
     (assert-equal (expression) expected-value))
   ```

3. End with `(run-tests)`. Top-level `test` forms are gathered into a
   generated `main`; a file that also defines its own `main` is rejected
   with `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN`.

4. Run: `./run_regression_tests.sh --full --no-boot --filter <name>`, then
   the whole suite.

A new regression or smoke file is also compared against the interpreter
automatically; if it legitimately cannot be (actors, addresses), add it
to `DIFF_SKIP` in `run_regression_tests.sh` with the reason.

---

## Manual Tests

`tests/manual/read-line.zyl` needs interactive input and is not run by
the suite. Its header still gives the Rust-era command
(`./target/debug/zyl`). With the current compiler the file does not
link: it is a bare top-level `let` with no `main`, and only top-level
`test` forms cause a `main` to be generated, so `zyl-self` reports
`undefined reference to _ZYL_main`. Wrapping the body in
`(defn main () ...)` makes it build.

---

## Future Improvements

- [ ] Golden output comparison (tracked as future work)
- [ ] Parallel test execution
- [ ] Compile-fail tests that assert the expected error code, not just a non-zero exit
- [ ] CI integration
