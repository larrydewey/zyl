# Regression Tests

## Overview

This file documents the test infrastructure and how to run tests for Zyl.
Everything runs through the self-hosted compiler, `build/boot/zyl-self`;
build it with `./boot.sh` first.

**Canonical spec reference:** `spec/10-structs-and-data-types.md`, `spec/02-syntax-and-forms.md`

---

## Quick Start

```bash
./run_regression_tests.sh --quick            # the default mode
./run_regression_tests.sh --full             # every section below, then ./boot.sh
./run_regression_tests.sh --full --no-boot   # every section, without the fixed-point check
./run_regression_tests.sh --dry-run          # list the selected tests without running them
```

`--full --no-boot` is **495 tests** (78 s on this machine as of
2026-10-02); `--quick` is **22**, and `--full` adds `boot/fixed-point`,
which runs `./boot.sh` and takes as long as a bootstrap does.

### Options

| Flag | Description |
|------|-------------|
| `--quick` | The default: the top-level `tests/*.zyl` tests, `tests/fmt_test.sh`, the five smoke tests, the LSP protocol test and the frame oracle |
| `--full` | Everything above plus regression, stress, integration, interpreter-agreement, schedule-agreement, packages, packages-fail, packages-build, compile-fail and script sections, then the fixed-point check |
| `--dry-run` | List the tests the same mode and `--filter` would run, without running them, and print their count |
| `--filter N` | Run only tests whose printed name contains N, case-insensitively (see below) |
| `--boot` | Run the fixed-point check (`./boot.sh`) in any mode |
| `--no-boot` | Skip the fixed-point check that `--full` otherwise runs at the end |
| `--verbose` | Print compiler output for a failed compile, the test output for a failed assertion, and the diff for an interpreter disagreement |
| `--timeout N` | Per-test run timeout in seconds for compiled binaries (default: 10; the interpreted side of the agreement section has its own 60 s budget) |

**`--filter` works within the mode, not across it.** The default mode is
`--quick`, which runs none of the regression sections, so `--filter
structs` on its own selects nothing. Combine it with `--full`, and add
`--no-boot` unless you also want a bootstrap:

```bash
./run_regression_tests.sh --full --no-boot --filter structs
./run_regression_tests.sh --full --no-boot --filter math        # every math-* file
./run_regression_tests.sh --filter lsp                          # works in --quick too
```

The filter is a case-insensitive substring of the name the test is
*printed* under, which is why the prefix matters: a single-file test
prints as `regression/NAME`, `smoke/NAME`, `stress/NAME`,
`integration/NAME`, `compile-fail/NAME`, `sched/NAME` or
`scripts/NAME`; the agreement section prints as `interpreter/NAME`, the
package sections as `packages/NAME`, `packages-fail/NAME` and
`packages-build/NAME`; and the top-level ones print as their own name
(`unit_test`, `cbor_test`, `lsp/protocol`, `frame-oracle`). So
`--filter compile-fail` does select the whole compile-fail section, and
`--filter struct` reaches `interpreter/structs` and
`compile-fail/struct-field-ambiguous` as well as `regression/structs`.
The five opt-in gates print under their own names — `timing-leakage`,
`memcheck`, `poison`, `poison-selfhost`, `determinism` — and
`boot/fixed-point` is the last one.

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
  the compiler must exit non-zero. A test file that carries a
  `; expect-error: CODE` line (for a package case, in `app/main.zyl`)
  must also report that code: the runner requires `CODE` to appear in
  the compiler's output, so an unrelated failure such as a crash or an
  out-of-memory stop does not count as a pass. Without such a line the
  runner does not check which code was reported.
  A `; expect-at: FILE:LINE:COL` line also pins the location: the
  `-->` line under that code's `error[CODE]` header must end in it
  (FILE is the basename, e.g. `main.zyl` or `zyl.pkg`). The runner then
  runs `zyl check` on the same program (a copy under the same name, for a
  file in `tests/compile-fail/`, which `check` skips) and requires it to
  fail with the same code: a clean check must mean the program builds.
- **Package builds** (`tests/packages-build/`): `zyl build` in the
  case's `app/` directory must succeed, the resulting binary must run
  without printing `FAIL`, the `.buildinfo` file must record a
  `(final-hash "blake3:...")`, and the binary must carry that hash.

Each run works in a scratch directory of its own
(`mktemp -d ${TMPDIR:-/tmp}/zyl_tests.XXXXXX`, removed on exit), so two
checkouts can run the suite at once: compiled test binaries are
`zyl_test_N.bin`, `zyl_diff_N.bin` and `zyl_sched_N.bin` there, and the
package-build, script, LSP, timing and boot logs are `zyl_*.log` there.
A failed fixed-point check copies its log to
`build/boot/boot_check.log`. The runner exports `ZYL_HOME` as
`build/boot`, so the suite always compiles against this checkout's
standard library, not an installed one.

### Sections and counts (`--full --no-boot` and `--quick`, 2026-10-09)

The authoritative count is what `--dry-run` prints.

| Section | Source | Printed as | Tests |
|---------|--------|------------|-------|
| top-level tests | `tests/*.zyl`, `tests/fmt_test.sh`, plus the provenance/cose cross-checks | own name | 15 |
| regression | `tests/regression/*.zyl` | `regression/NAME` | 128 |
| stress | `tests/stress/*.zyl` | `stress/NAME` | 4 |
| integration | `tests/integration/*.zyl` | `integration/NAME` | 7 |
| schedule agreement | the four actor regression files | `sched/NAME` | 4 |
| interpreter agreement | regression + smoke, minus `DIFF_SKIP` | `interpreter/NAME` | 109 |
| packages | `tests/packages/*/app/main.zyl` | `packages/NAME` | 3 |
| packages-fail | `tests/packages-fail/*/app/main.zyl` | `packages-fail/NAME` | 10 |
| packages-build | `tests/packages-build/*/app` via `zyl build` | `packages-build/NAME` | 1 |
| compile-fail | `tests/compile-fail/*.zyl` | `compile-fail/NAME` | 194 |
| scripts | `tests/scripts/*.sh` | `scripts/NAME` | 29 |
| LSP protocol | `tests/lsp/lsp_protocol_test.py` | `lsp/protocol` | 1 |
| LSP memory (`--full` only) | `tests/lsp/lsp_memory_test.py` | `lsp/memory` | 1 |
| frame oracle | `verify/frame_oracle.sh` | `frame-oracle` | 1 |
| **total** | | | **507** |

The fifteen top-level tests are `unit_test`, `cbor_test`,
`ffi_arity_test`, `provenance_test`, `provenance_cross`, `cose_test`,
`cose_cross`, `provenance_trailer_test`, `provenance_trailer_cross`,
`prov_sign`, `prov_verify`, `fmt_test`, `explain_test`,
`panic_unmarked_test` and `verify_test`. `--quick` is those fifteen, the
five smoke tests, `lsp/protocol` and `frame-oracle`: **22** in all. The
smoke tests run directly only in `--quick`; in `--full` they are
exercised through the interpreter-agreement section, which is why they
are not counted there.

The three `*_cross` entries ask the Python `cbor2` and `cryptography`
modules whether the bytes Zyl produced are the canonical ones — a
question a self-consistent Zyl test cannot ask — and each exits 0 with a
"skipping" notice when its module is not installed.

## Interpreter agreement

`--full` adds a section `--quick` does not have: every regression and
smoke test is run **twice**, once as a compiled binary and once through
the ICNF interpreter (`zyl eval`, the REPL's evaluator), and the two
outputs are diffed. Two back ends for one language is exactly the kind of
thing that drifts silently, so the suite compares them rather than
assuming.

```bash
./run_regression_tests.sh --full --no-boot --filter interpreter            # just this section
./run_regression_tests.sh --full --no-boot --filter interpreter --verbose  # with diffs
```

The interpreted run is in the interpreter's checking mode,
`ZYL_INTERP_CHECK=1` (the "CHECKING MODE" section of
`stdlib/repl/interp.zyl`). Every interpreted value carries its tag (Int,
Float, String or heap block); in this mode arithmetic must be on two Ints
or two Floats, a comparison on two values of one tag, a bit operation on
two Ints, and every condition exactly 0 or 1. A violation is
`E_INTERP_TAG`, which means the type checker accepted a program that
misuses a value: a checker bug, located at the expression. The section
passing is empirical evidence for spec §4.8 on the programs it covers.
To run a file the same way by hand:

```bash
ZYL_INTERP_CHECK=1 build/boot/zyl-self eval tests/regression/adts.zyl
```

Only stdout is compared: compiler warnings go to stderr, and the
compiled run emits them at build time while the interpreted run emits
them at eval time — a difference in when, not in what.

Some tests are deliberately left out of this comparison, and
`DIFF_SKIP` in the runner records why for each: one that
prints a value's address (`derive`), one that prints the bytes at a
pinned address (`ffi-advanced`), one that assumes a fresh `alloc-malloc`
block reads back as zeroes (`collections`), `package-system` (its
signature tests are Ed25519), `c-abi` (it hands a function to `qsort` as
a C callback, which needs a native function pointer),
`balance-agreement` (it lexes 160 mutated compiler sources: a fraction of
a second compiled, about 20 s interpreted), `tail-calls`
(10^8-deep loops, far too slow interpreted), `with-region-limits` (the
interpreter accounts no region bytes), and every `math-*` file, which is
minutes of interpreted arithmetic for what the compiled run already
covers in seconds. Actor programs are compared too: the interpreter
runs `spawn` and channels. (`DIFF_SKIP` also names `selfhost-codegen`, an integration
test the section never reaches.)

126 regression files plus 5 smoke files, minus the eight `DIFF_SKIP`
names that are regression files and the 16 `math-*` files, leaves the
107 agreement runs above.

`docs/repl.md` lists the places the two back ends differ on purpose.

---

## Schedule agreement

The `sched` category (`--full`) compiles `actors`, `channels`,
`concurrency` and `runtime-actors` once each. It runs every binary under
the default thread schedule, under `ZYL_SCHED=deterministic` (one actor
at a time), and under `ZYL_SCHED_CHAOS=1`, `2` and `3` (seeded yields and
sleeps at channel operations). Stdout, stderr and the exit status must be
byte-identical across all of them (docs/concurrency-determinism-design.md).
`tests/scripts/actor-schedules.sh` does the same for programs that are
meant to fail: a deadlock, an actor panic reported at exit, and main's
panic.

## Test Directory Structure

```
tests/
├── unit_test.zyl              # Harness + stdlib tests (runs in --quick and --full)
├── regression/                # 126 domain-specific regression files (--full)
│   ├── arithmetic.zyl         # +, -, *, /, multi-operand, float chains
│   ├── bitwise.zyl            # bit-and/or/xor/not, shifts, n-ary folding
│   ├── eval-order.zyl         # strict left-to-right evaluation
│   ├── byte-primitives.zyl    # bytebuf, load/store round-trips, slices,
│   │                          #   atomics, alignment
│   ├── views.zyl              # zero-copy string views and slices
│   ├── control-flow.zyl       # if, while, for, cond, begin, nested
│   ├── control-flow-ext.zyl   # nested loops, else-arms, multi init, breaks
│   ├── let-scope.zyl          # a let in a body scopes over its own body
│   ├── functions.zyl          # defn, recursion, nested calls, HOFs
│   ├── tail-calls.zyl         # tail calls are jumps
│   ├── toplevel-def.zyl       # top-level def
│   ├── closures.zyl           # fn, lambda, capture
│   ├── closures-core.zyl      # core/core's higher-order helpers
│   ├── param-kinds.zyl        # String and Float parameters
│   ├── structs.zyl            # defstruct, defstruct+, struct-get (spec §8/§10)
│   ├── dot-syntax.zyl         # v.field, (v.method args)
│   ├── adts.zyl               # deftype, match, recursive ADTs
│   ├── adt-equality.zyl       # == and != on ADTs and structs, by content
│   ├── alias.zyl              # transparent aliases: annotations, fields, chains
│   ├── run-tests-filter.zyl   # (run-tests (:filter ...)) runs only matching tests
│   ├── match-exhaustive.zyl   # compile-time exhaustiveness (accepting side)
│   ├── match-value-position.zyl
│   ├── list-accessors.zyl     # car/cdr/cadr/caddr/cddr, list-rest
│   ├── list-literals.zyl      # (list ...), [...], quoted constant data
│   ├── quasiquote.zyl         # `d, ,e and ,@e
│   ├── macros.zyl             # defmacro, gensym, nested macros, unless/when
│   ├── types.zyl              # HM inference, traits, generics, `let`
│   │                          #   and `let-mut` bindings
│   ├── generics.zyl           # generic ADTs, per-site instantiation
│   ├── generics-multi-type.zyl
│   ├── generic-collections.zyl # Vec, Map and generic ADTs over element types
│   ├── traits.zyl             # trait definitions and impls
│   ├── trait-static-dispatch.zyl # trait calls resolved from the receiver type
│   ├── trait-generic-value.zyl # a trait-generic function used as a value
│   ├── show-trait.zyl         # the prelude Show trait and print
│   ├── derive.zyl             # derived traits for structs
│   ├── derive-traits.zyl      # Show, Debug, Eq, Ord, Hash, Clone
│   ├── capabilities.zyl       # `let` sharing and the E_MUT_CONFLICT rules
│   ├── regions.zyl            # region annotations, escape analysis
│   ├── region-reclaim.zyl     # per-call regions reclaim short-lived values
│   ├── stack-bytebuf.zyl      # a Stack bytebuf in the frame region
│   ├── with-region.zyl        # explicit arena and fixed regions
│   ├── with-region-limits.zyl # :size and :limit raise E_REGION_EXHAUSTED
│   ├── reuse.zyl              # in-place reuse is never visible
│   ├── contracts.zyl          # requires, ensures, invariant, recover, checkpoint
│   ├── try-catch.zyl          # error inside a called function, caught
│   ├── with-resource.zyl      # Drop on normal exit and before an error
│   ├── unwrap-error.zyl       # Result/Option unwrapping, error propagation
│   ├── actors.zyl             # spawn, join, output at join
│   ├── channels.zyl           # Kahn channels: chan, chan-send, chan-recv
│   ├── concurrency.zyl        # spawn, join, atomics across actors
│   ├── ffi.zyl                # ffi-call, ffi-pin, ffi-unpin, timeout
│   ├── ffi-advanced.zyl       # pinning, timeouts
│   ├── ffi-timeout.zyl        # a foreign call that overruns raises E_FFI_TIMEOUT
│   ├── c-abi.zyl              # C callbacks keep callee-saved registers;
│   │                          #   C calls with more than six arguments
│   ├── io.zyl                 # read-line, file-open/read/write/close
│   ├── collections.zyl        # Vec, Map, Set, StringBuffer, allocator
│   ├── modules.zyl            # module imports from stdlib
│   ├── package-system.zyl     # spec v5.0 §31 building blocks
│   ├── testing-framework.zyl  # test, assert-*, test-suite fixtures,
│   │                          #   test-property, test-compile
│   ├── secret-capability.zyl  # Secret / constant-time checker, accepting side
│   ├── secret-types.zyl       # Secret types and impl-not, accepting side
│   ├── compiler.zyl           # stdlib/compiler: lexer, parser, AST types
│   ├── balance.zyl            # the delimiter check: every fault, the column-1
│   │                          #   rule, the indentation hint, strings, CRLF
│   ├── balance-agreement.zyl  # the delimiter check against the lexer's tokens
│   │                          #   on mutated compiler sources
│   ├── intrinsics.zyl         # bit-popcount, clz/ctz, bswap, rotl/rotr,
│   │                          #   mul-hi, crc32c against reference models
│   ├── simd.zyl               # simd/simd lane vectors
│   ├── float-literals.zyl, float-nan.zyl  # exact float bits; NaN compares
│   ├── exit.zyl               # exit flushes and ends the process
│   ├── asm-x86.zyl            # the Zyl assembler's encodings
│   ├── native-*.zyl           # native-backend shapes: accumulators,
│   │                          #   division by constants, modular loops, shifts
│   ├── vec-growth.zyl         # vec-push growth and reuse
│   ├── runtime-*.zyl          # the Zyl runtime by area: actors, blake3,
│   │                          #   bytes, crypto, ctab, env, fmt, heap, os,
│   │                          #   panic, proc, shortstr, strings, tables, text
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
├── compile-fail/              # 189 programs that MUST be rejected; 147 carry
│   │                          #   a `; expect-error: CODE` line, and 37 of
│   │                          #   those also pin a location with
│   │                          #   `; expect-at: FILE:LINE:COL`
│   ├── unclosed-opener.zyl    # balance errors
│   ├── unexpected-close.zyl
│   ├── mismatched-bracket.zyl
│   ├── misplaced-paren.zyl    # a missing ) balanced by an extra one
│   ├── type-*.zyl             # 11 type errors (mismatch, infinite type,
│   │                          #   Bool conditions, Int/Float mixing, ...)
│   ├── match-*.zyl            # 6 match errors (non-exhaustive, duplicate
│   │                          #   arm, nested pattern, constructor as binder)
│   ├── macro-*.zyl            # 11 macro errors (arity, capture, duplicate,
│   │                          #   function clash, recursion, nested
│   │                          #   definition, non-termination, splicing)
│   ├── secret-*.zyl           # 13 Secret capability violations
│   ├── ffi-*.zyl              # 10 FFI errors (timeout, symbol, extern,
│   │                          #   restricted entries, unpin)
│   ├── trait-*.zyl, derive-*.zyl, duplicate-*.zyl, impl-not-*.zyl,
│   │                          #   dot-*.zyl: traits, derive and impl-not
│   ├── bytes-*.zyl            # byte-operation operand types
│   ├── with-region-*.zyl, stack-bytebuf-*.zyl  # region errors
│   └── ...                    # parameters, quoting, forms, let/def rules
├── packages/                  # multi-package builds that must succeed
│   ├── features/              #   (each case: app/ plus path dependencies)
│   ├── struct-accessors/
│   └── two-parses/
├── packages-fail/             # multi-package builds that must be rejected
│   ├── bad-requirement/  capability/  capability-main/  feature-nested/
│   ├── feature-unknown/  malformed-dep/  orphan-impl/  private-symbol/
│   └── undeclared-dep/  unknown-edition/
├── packages-build/            # built with `zyl build` (native block, lock,
│   └── native/                #   <out>.buildinfo, embedded build hash)
├── scripts/                   # 27 shell checks of the repository's own
│   │                          # scripts, each against scratch directories
│   ├── actor-schedules.sh     # failing actor programs under every schedule
│   ├── asm-oracle.sh          # the Zyl assembler against GNU as
│   │                          #   (asm_oracle.py generates the sweep)
│   ├── self-link.sh           # freestanding self-link and rt.zo
│   ├── balance-cli.sh         # zyl balance: files, directories, JSON, status
│   ├── deterministic-link.sh, stdout-buffer.sh, ffi-stdio-order.sh
│   ├── json-diagnostics.sh, located-diagnostics.sh
│   ├── diagnostics-voice.sh   # the wording of docs/diagnostics.md's probe
│   ├── error-codes.sh         # the catalog against the raise sites
│   ├── explain-examples.sh    # every `zyl explain` wrong/fix pair
│   ├── panic-backtrace.sh, panic-unmarked.sh
│   ├── runtime-module-lock.sh # --runtime-module is refused elsewhere
│   ├── build-cache.sh, package-index.sh
│   ├── provenance.sh, provenance-trailer.sh, prov-sign.sh, prov-verify.sh,
│   │                          #   cose.sh: the record against cbor2
│   ├── repl-session.sh, uninstall.sh
│   ├── site-examples.sh       # website/examples compile and print their .out/.err
│   └── vscode-problem-matcher.sh, zyl-doc.sh
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
rename, package forms, diagnostics (a clean program, type errors
reported together on their own lines, an unused-binding warning), a
150 KB document, and UTF-8 text in both directions.

It runs in both `--quick` and `--full` mode, counts as one test, and is
skipped with a notice if `build/boot/zyl-lsp` has not been built.

`tests/lsp/lsp_memory_test.py` (`lsp/memory`, `--full` only, about 20 s)
sends 1500 edits, hovers and open/close pairs and requires the server's
resident set not to grow per message (0.5 kB at most). It measures the
floor -- the least reading over the last quarter of samples against the
first -- because arenas are reset by unmapping and remapping blocks, so a
single reading swings by megabytes.

---

## The Opt-in Gates

Five checks are **not** part of a plain `--full` run: `timing-leakage`,
`memcheck`, `poison`, `poison-selfhost` and `determinism`. Each is minutes
on its own, so the runner selects one only when `--filter` is given *and*
matches its name — an empty filter must never pull them in.

```bash
./run_regression_tests.sh --full --no-boot --filter memcheck
./run_regression_tests.sh --full --no-boot --filter poison        # also poison-selfhost
./run_regression_tests.sh --full --no-boot --filter poison-selfhost
./run_regression_tests.sh --full --no-boot --filter determinism
./run_regression_tests.sh --full --no-boot --filter timing
```

`--filter poison` is a substring match, so it selects both the
region-lifetime gate and the self-hosting one; `--filter
poison-selfhost` selects only the second. The gate that *is* part of a
plain run is `frame-oracle`, the independent cross-check of the
assembly verifier's verdicts: it costs about a second, and a verifier
that is quietly wrong reports success, so it needs a second opinion every
run rather than on request.

### Constant-Time (Timing Leakage) Harness

`timing-leakage` spawns thousands of short processes and takes longer
than every other test combined, and its result is a statistic rather than
a pass or fail of the code itself. The runner calls
`python3 verify/timing.py --quick`.

```bash
./run_regression_tests.sh --filter timing
```

The harness carries a deliberately leaky comparison as a **positive
control** and fails if it cannot detect it, so a green result means the
measurement worked.

### Memory safety, region lifetime and determinism

The other four gates are the dynamic half of `docs/soundness.md`, and
each has a design note saying what it can and cannot see:
`docs/memory-poisoning-design.md` for `poison` and `poison-selfhost`,
`verify/memcheck.sh` for `memcheck`, and `verify/model.py` for the
`determinism` gate's second half. `poison` is the only dynamic check of
the premise that no value outlives its region, and it has no positive
control: the violation it looks for is what the static checks already
prevent. `poison-selfhost` is the strongest single check for that
premise — it rebuilds the whole compiler with released region blocks
refilled with `0xDE` and requires byte-identical seeds.

---

## Struct Regression Tests

**Trigger before modifying:** `ast.zyl`, `codegen.zyl`, `icnf.zyl`,
`type_annotate.zyl`, `parser.zyl`, `region_inference.zyl` — all under
`stdlib/compiler/`.

```bash
./run_regression_tests.sh --full --no-boot --filter struct
```

`struct` (rather than `structs`) also picks up `stress/large-struct`,
`regression/struct-accessors` and `packages/struct-accessors`, the
agreement runs of `structs`, `struct-basic` and `struct-accessors`, and
five compile-fail cases: `misspelled-constructor-last-arm`,
`misspelled-constructor-no-suggestion`, `prelude-constructor`,
`reserved-make-constructor` and `struct-field-ambiguous`.

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
./run_regression_tests.sh --full --no-boot --filter balance
```

The compile-fail cases print as `compile-fail/NAME`, so they are selected
by `unclosed`, `unexpected-close`, `mismatched-bracket` and
`misplaced-paren` — or by the whole-section filter `compile-fail`.

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

2. Use the assertion harness pattern (with your own expression and
   expected value):
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

`tests/manual/read-line.zyl` needs input on stdin and is not run by
the suite; its header gives the command and the expected output.

---

## Future Improvements

- [ ] Golden output comparison (tracked as future work)
- [ ] Parallel test execution
- [ ] Every compile-fail test asserting its expected error code (147 of
      the 189 carry `; expect-error: CODE`, and 7 of the 10 packages-fail
      cases)
- [ ] CI integration
