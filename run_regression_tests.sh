#!/usr/bin/env bash
# Zyl Regression Test Runner
# Usage: ./run_regression_tests.sh [OPTIONS]
#   --quick      Run the unit test and the smoke tests (default)
#   --full       Run every suite (~45s via the self-hosted compiler),
#                then the self-hosting fixed-point check (./boot.sh)
#                unless --no-boot is given
#   --dry-run    List the tests the same options would run, without
#                running them (honours --filter and the mode)
#   --filter N   Only run tests whose name contains N (case-insensitive
#                substring), within the chosen mode -- regression and
#                stress tests only run in --full, so e.g.
#                `--full --no-boot --filter structs`
#   --verbose    Print compiler output
#   --timeout N  Per-test timeout in seconds (default: 10)
#   --boot       Force the self-hosting fixed-point verification
#                (./boot.sh) in any mode
#   --no-boot    Skip the fixed-point verification in --full mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZYL_BIN="${SCRIPT_DIR}/build/boot/zyl-self"
# Pin stdlib resolution to this checkout's build/boot/stdlib, the copy
# boot.sh re-syncs from stdlib/ on every build. Without this the
# compiler prefers a populated $HOME/.zyl left behind by install.sh
# (see cli-resolve-bundledir in selfhost/driver.zyl), so a test could
# pass or fail against a stdlib from an unrelated older checkout --
# and an edit made to stdlib/ in THIS one would be invisible to the
# suite. boot.sh already exports the same thing for the same reason.
export ZYL_HOME="${SCRIPT_DIR}/build/boot"
TESTS_DIR="${SCRIPT_DIR}/tests"

# Per-run scratch directory, so two checkouts (or worktrees) can run the
# suite at the same time without overwriting each other's test binaries.
RUN_TMP="$(mktemp -d "${TMPDIR:-/tmp}/zyl_tests.XXXXXX")"
trap 'rm -rf "$RUN_TMP"' EXIT

# Defaults
MODE="quick"
FILTER=""
VERBOSE=0
TIMEOUT=10
# The interpreted side of a differential run is slower than native code
# by the usual interpreter factor, so it gets its own budget.
DIFF_TIMEOUT=60
DRY_RUN=0
BOOT=0
NO_BOOT=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --quick) MODE="quick"; shift ;;
        --full) MODE="full"; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        --boot) BOOT=1; shift ;;
        --no-boot) NO_BOOT=1; shift ;;
        # The filter is a case-insensitive SUBSTRING of the test's own
        # name -- `--filter math` runs every math-* file, `--filter
        # structs` runs the struct tests. It used to be compared the
        # other way round (test name matched against the filter text),
        # so a filter could only ever select a test whose whole name it
        # contained: `--filter math` matched nothing at all.
        --filter) FILTER="$2"; shift 2 ;;
        --verbose) VERBOSE=1; shift ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 2 ;;
    esac
done

# The self-hosting fixed-point check runs by default in --full mode;
# opt out with --no-boot.
if [ "$MODE" = "full" ]; then
    BOOT=1
fi

# Counters
PASS=0
FAIL=0
TOTAL=0
START_TIME=$(date +%s)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --dry-run: count and list a selected test instead of running it. Every
# suite goes through this, so a dry run selects exactly what a real run
# with the same mode and --filter would.
dry_listed() {
    if [ "$DRY_RUN" -eq 1 ]; then
        TOTAL=$((TOTAL + 1))
        echo "  - $1"
        return 0
    fi
    return 1
}

run_test() {
    local name="$1"
    local file="$2"
    
    dry_listed "$name" && return
    TOTAL=$((TOTAL + 1))
    
    if [ ! -f "$file" ]; then
        echo -e "  ${RED}✗${NC} ${name}: source file not found (${file})"
        FAIL=$((FAIL + 1))
        return
    fi
    
    # Compile
    local output
    if ! output=$("${ZYL_BIN}" "$file" "$RUN_TMP/zyl_test_${TOTAL}.bin" 2>&1); then
        echo -e "  ${RED}✗${NC} ${name}: compilation failed"
        if [ "$VERBOSE" -eq 1 ]; then
            echo "    $output"
        fi
        FAIL=$((FAIL + 1))
        return
    fi
    
    # Run
    local actual exit_code
    actual=$(timeout "$TIMEOUT" "$RUN_TMP/zyl_test_${TOTAL}.bin" 2>/dev/null) || exit_code=$?
    
    if [ "${exit_code:-0}" -ne 0 ]; then
        echo -e "  ${RED}✗${NC} ${name}: runtime failure (exit ${exit_code:-1})"
        FAIL=$((FAIL + 1))
        return
    fi
    
    # Check for test failures in output
    if echo "$actual" | grep -q "FAIL"; then
        echo -e "  ${RED}✗${NC} ${name}: test assertion failed"
        if [ "$VERBOSE" -eq 1 ]; then
            echo "    $actual"
        fi
        FAIL=$((FAIL + 1))
        return
    fi
    
    echo -e "  ${GREEN}✓${NC} ${name}"
    PASS=$((PASS + 1))
}

# Compile-fail test: compilation is EXPECTED to fail (e.g. exhaustiveness,
# type errors, unbalanced parens). A successful compile is a regression.
run_fail_test() {
    local name="$1"
    local file="$2"
    
    dry_listed "$name" && return
    TOTAL=$((TOTAL + 1))
    
    if [ ! -f "$file" ]; then
        echo -e "  ${RED}✗${NC} ${name}: source file not found (${file})"
        FAIL=$((FAIL + 1))
        return
    fi
    
    local output
    if output=$("${ZYL_BIN}" "$file" "$RUN_TMP/zyl_test_${TOTAL}.bin" 2>&1); then
        echo -e "  ${RED}✗${NC} ${name}: expected compilation to fail, but it succeeded"
        if [ "$VERBOSE" -eq 1 ]; then
            echo "    $output"
        fi
        FAIL=$((FAIL + 1))
        return
    fi
    
    # A `; expect-error: CODE` line pins the failure to one diagnostic,
    # so an unrelated failure (out of memory, a crash) cannot pass it.
    local expected
    expected=$(sed -n 's/^; expect-error: *\([A-Z_0-9]*\).*/\1/p' "$file" | head -1)
    if [ -n "$expected" ] && ! echo "$output" | grep -q -- "$expected"; then
        echo -e "  ${RED}✗${NC} ${name}: expected ${expected}, got a different failure"
        if [ "$VERBOSE" -eq 1 ]; then
            echo "    $output"
        fi
        FAIL=$((FAIL + 1))
        return
    fi

    # `; expect-at: FILE:LINE:COL` pins where that diagnostic points.
    local at
    at=$(sed -n 's/^; expect-at: *\([^ ]*\).*/\1/p' "$file" | head -1)
    if [ -n "$at" ] && ! echo "$output" | grep -A1 -- "error\[${expected}\]" | grep -- '-->' | grep -qE -- "[ /]${at}\$"; then
        echo -e "  ${RED}✗${NC} ${name}: expected ${expected} at ${at}, got another location"
        if [ "$VERBOSE" -eq 1 ]; then
            echo "    $output"
        fi
        FAIL=$((FAIL + 1))
        return
    fi

    echo -e "  ${GREEN}✓${NC} ${name}"
    PASS=$((PASS + 1))
}

# Differential test: the same program, compiled and interpreted, must
# print the same thing. `zyl eval` runs a program through the ICNF
# interpreter (stdlib/repl/interp), which is the REPL's evaluator; this
# is what keeps that second back end honest, since a divergence between
# it and code generation is exactly the risk of having two.
#
# stdout only: compiler warnings go to stderr, and the compiled run
# emits them at build time while the interpreted run emits them at eval
# time, which is a difference in when, not in what.
#
# The interpreter runs in its checking mode (ZYL_INTERP_CHECK=1): every
# operator checks its operands' tags and every condition must be a Bool,
# so a type the checker got wrong shows up as an E_INTERP_TAG failure
# (docs/sound-types-design.md, "Evidence").
# Schedule test: the program's stdout, stderr and exit status must be
# byte-identical under the default threads, ZYL_SCHED=deterministic and
# seeded chaos schedules (docs/concurrency-determinism-design.md).
SCHED_TESTS="actors channels concurrency runtime-actors"
SCHED_MODES="ZYL_SCHED=deterministic ZYL_SCHED_CHAOS=1 ZYL_SCHED_CHAOS=2 ZYL_SCHED_CHAOS=3"
run_sched_test() {
    local name="$1"
    local file="$2"

    dry_listed "$name" && return
    TOTAL=$((TOTAL + 1))

    local bin="$RUN_TMP/zyl_sched_${TOTAL}.bin"
    if ! "${ZYL_BIN}" "$file" -o "$bin" >/dev/null 2>&1; then
        echo -e "  ${RED}✗${NC} ${name}: does not compile"
        FAIL=$((FAIL + 1))
        return
    fi

    local ref out mode
    ref=$(timeout "$TIMEOUT" "$bin" 2>&1; echo "exit $?")
    for mode in $SCHED_MODES; do
        out=$(env "$mode" timeout "$TIMEOUT" "$bin" 2>&1; echo "exit $?")
        if [ "$out" != "$ref" ]; then
            echo -e "  ${RED}✗${NC} ${name}: output under ${mode} differs from the default schedule"
            if [ "$VERBOSE" -eq 1 ]; then
                diff <(echo "$ref") <(echo "$out") | head -20
            fi
            FAIL=$((FAIL + 1))
            return
        fi
    done
    echo -e "  ${GREEN}✓${NC} ${name}"
    PASS=$((PASS + 1))
}

run_diff_test() {
    local name="$1"
    local file="$2"

    dry_listed "$name" && return
    TOTAL=$((TOTAL + 1))

    if ! "${ZYL_BIN}" "$file" -o "$RUN_TMP/zyl_diff_${TOTAL}.bin" >/dev/null 2>&1; then
        echo -e "  ${RED}✗${NC} ${name}: does not compile"
        FAIL=$((FAIL + 1))
        return
    fi

    local compiled interpreted
    compiled=$(timeout "$TIMEOUT" "$RUN_TMP/zyl_diff_${TOTAL}.bin" 2>/dev/null) || true
    interpreted=$(ZYL_INTERP_CHECK=1 timeout "$DIFF_TIMEOUT" "${ZYL_BIN}" eval "$file" 2>/dev/null) || true

    if [ "$compiled" = "$interpreted" ]; then
        echo -e "  ${GREEN}✓${NC} ${name}"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}✗${NC} ${name}: interpreted output differs from compiled"
        if [ "$VERBOSE" -eq 1 ]; then
            diff <(echo "$compiled") <(echo "$interpreted") | head -20
        fi
        FAIL=$((FAIL + 1))
    fi
}

# Tests the differential run deliberately leaves out, with the reason:
#   derive               — one of its tests prints a value's address,
#                          which is not the same number in two different
#                          runtimes and is not meant to be.
#   collections          — asserts that a fresh alloc-malloc block reads
#                          back as zeroes, which malloc does not promise.
#   ffi-advanced         — prints the bytes at a pinned address, which
#                          are not the same bytes in two runtimes.
#   package-system       — its signature tests are Ed25519.
#   c-abi                — hands a function to qsort as a C callback,
#                          which needs a native function pointer.
#   math-*               — minutes of interpreted arithmetic for what
#                          the compiled suite already covers in seconds.
#                          Matched by prefix, below.
#   tail-calls           — 10^8-deep loops, far too slow interpreted.
#   balance-agreement    — lexes 160 mutated compiler sources: 0.2 s compiled,
#                          about 20 s interpreted.
#   with-region-limits   — region byte limits; the interpreter allocates
#                          in its own arenas and accounts no region bytes.
DIFF_SKIP="balance-agreement derive collections ffi-advanced package-system selfhost-codegen c-abi tail-calls with-region-limits"

diff_skipped() {
    local name="$1"
    case "$name" in
        math-*) return 0 ;;
    esac
    for s in $DIFF_SKIP; do
        [ "$s" = "$name" ] && return 0
    done
    return 1
}

echo "=== Zyl Regression Test Suite ==="
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    echo "=== Dry Run ==="
fi
echo "Mode: ${MODE} | Filter: ${FILTER:-none} | Timeout: ${TIMEOUT}s"
echo ""

# Run unit test (comprehensive harness)
if [ "$MODE" = "full" ] || [ "$MODE" = "quick" ]; then
    if [ -z "$FILTER" ] || echo "unit_test" | grep -qi -- "$FILTER"; then
        run_test "unit_test" "${TESTS_DIR}/unit_test.zyl"
    fi
    # The CBOR encoder, against hand-computed canonical encodings. A COSE
    # signature is over these bytes, so an encoder that is merely valid is not
    # good enough -- it has to be the one encoding.
    if [ -z "$FILTER" ] || echo "cbor_test" | grep -qi -- "$FILTER"; then
        run_test "cbor_test" "${TESTS_DIR}/cbor_test.zyl"
    fi
    # ffi-call arity, and the counting rules behind it. A check that rejects
    # correct code is worse than none, and this one was wrong three times.
    if [ -z "$FILTER" ] || echo "ffi_arity_test" | grep -qi -- "$FILTER"; then
        run_test "ffi_arity_test" "${TESTS_DIR}/ffi_arity_test.zyl"
    fi
    # The provenance record. The Zyl test asks whether our key order is
    # self-consistent; the script asks cbor2 whether it is the canonical one.
    if [ -z "$FILTER" ] || echo "provenance" | grep -qi -- "$FILTER"; then
        run_test "provenance_test" "${TESTS_DIR}/provenance_test.zyl"
        if bash "${TESTS_DIR}/scripts/provenance.sh" >"$RUN_TMP/prov_cross.log" 2>&1; then
            PASS=$((PASS+1)); printf "  \033[0;32m\xe2\x9c\x93\033[0m provenance_cross\n"
        else
            FAIL=$((FAIL+1)); printf "  \033[0;31m\xe2\x9c\x97\033[0m provenance_cross\n"
        fi
        TOTAL=$((TOTAL+1))
    fi
    # COSE_Sign1. The Zyl test pins the bytes; the script asks cbor2 and
    # `cryptography` whether those bytes are RIGHT, which a self-consistent test
    # cannot say.
    if [ -z "$FILTER" ] || echo "cose" | grep -qi -- "$FILTER"; then
        run_test "cose_test" "${TESTS_DIR}/cose_test.zyl"
        if bash "${TESTS_DIR}/scripts/cose.sh" >"$RUN_TMP/cose_cross.log" 2>&1; then
            PASS=$((PASS+1)); printf "  \033[0;32m\xe2\x9c\x93\033[0m cose_cross\n"
        else
            FAIL=$((FAIL+1)); printf "  \033[0;31m\xe2\x9c\x97\033[0m cose_cross\n"
        fi
        TOTAL=$((TOTAL+1))
    fi
    # `zyl fmt`: indentation recovered exactly, --check never writing.
    if [ -z "$FILTER" ] || echo "fmt_test" | grep -qi -- "$FILTER"; then
        if bash "$TESTS_DIR/fmt_test.sh" >"$RUN_TMP/fmt_test.log" 2>&1; then
            PASS=$((PASS+1)); printf "  \033[0;32m\xe2\x9c\x93\033[0m fmt_test\n"
        else
            FAIL=$((FAIL+1)); printf "  \033[0;31m\xe2\x9c\x97\033[0m fmt_test\n"
        fi
        TOTAL=$((TOTAL+1))
    fi
    # `zyl explain`, on the parts that are pure functions of their input. Its
    # site scan had four bugs that each read as a working search.
    if [ -z "$FILTER" ] || echo "explain_test" | grep -qi -- "$FILTER"; then
        run_test "explain_test" "${TESTS_DIR}/explain_test.zyl"
    fi
    # The binary-safety verifier, on hand-written assembly. It runs in quick
    # mode because a check that only ever sees the compiler's own output
    # cannot be told apart from one that does nothing: these cases are the
    # only thing here that plants a fault and requires it to be caught.
    if [ -z "$FILTER" ] || echo "verify_test" | grep -qi -- "$FILTER"; then
        run_test "verify_test" "${TESTS_DIR}/verify_test.zyl"
    fi
fi

# Run smoke tests (always in quick mode)
if [ "$MODE" = "quick" ]; then
    for f in "${TESTS_DIR}"/smoke/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        if [ -z "$FILTER" ] || echo "$local_name" | grep -qi -- "$FILTER"; then
            run_test "smoke/${local_name}" "$f"
        fi
    done
fi

# Run regression tests
if [ "$MODE" = "full" ]; then
    for f in "${TESTS_DIR}"/regression/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        if [ -z "$FILTER" ] || echo "$local_name" | grep -qi -- "$FILTER"; then
            run_test "regression/${local_name}" "$f"
        fi
    done
fi

# Run stress tests
if [ "$MODE" = "full" ]; then
    for f in "${TESTS_DIR}"/stress/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        if [ -z "$FILTER" ] || echo "$local_name" | grep -qi -- "$FILTER"; then
            run_test "stress/${local_name}" "$f"
        fi
    done
fi

# Run integration tests
if [ "$MODE" = "full" ]; then
    for f in "${TESTS_DIR}"/integration/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        if [ -z "$FILTER" ] || echo "$local_name" | grep -qi -- "$FILTER"; then
            run_test "integration/${local_name}" "$f"
        fi
    done
fi

# Actor programs agree across schedules (see run_sched_test).
if [ "$MODE" = "full" ]; then
    echo ""
    echo "=== Actor output is the same under every schedule ==="
    for local_name in $SCHED_TESTS; do
        f="${TESTS_DIR}/regression/${local_name}.zyl"
        if [ -z "$FILTER" ] || echo "sched ${local_name}" | grep -qi -- "$FILTER"; then
            run_sched_test "sched/${local_name}" "$f"
        fi
    done
fi

# Interpreter/codegen agreement (see run_diff_test).
if [ "$MODE" = "full" ]; then
    echo ""
    echo "=== Interpreter agrees with codegen ==="
    for f in "${TESTS_DIR}"/regression/*.zyl "${TESTS_DIR}"/smoke/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        diff_skipped "$local_name" && continue
        if [ -z "$FILTER" ] || echo "interpreter ${local_name}" | grep -qi -- "$FILTER"; then
            run_diff_test "interpreter/${local_name}" "$f"
        fi
    done
fi

# Multi-package builds (spec v5.0 §31). Each case is a DIRECTORY holding
# one `app/` package plus the packages it depends on by path, so the test
# exercises manifest reading, dependency resolution, canonical keys and
# visibility rather than a single file's syntax.
if [ "$MODE" = "full" ]; then
    for d in "${TESTS_DIR}"/packages/*/; do
        [ -d "$d" ] || continue
        local_name=$(basename "$d")
        if [ -z "$FILTER" ] || echo "packages ${local_name}" | grep -qi -- "$FILTER"; then
            run_test "packages/${local_name}" "${d}app/main.zyl"
        fi
    done
fi

# Package cases that MUST be rejected: a private import, an undeclared
# dependency, a range requirement, an unknown edition.
if [ "$MODE" = "full" ]; then
    for d in "${TESTS_DIR}"/packages-fail/*/; do
        [ -d "$d" ] || continue
        local_name=$(basename "$d")
        if [ -z "$FILTER" ] || echo "packages ${local_name}" | grep -qi -- "$FILTER"; then
            run_fail_test "packages-fail/${local_name}" "${d}app/main.zyl"
        fi
    done
fi

# `zyl build` cases: a package directory built through the subcommand
# rather than by naming a file, which is what exercises the manifest's
# native block, the lock and zyl.buildinfo (§31.10, §31.12).
if [ "$MODE" = "full" ]; then
    for d in "${TESTS_DIR}"/packages-build/*/; do
        [ -d "$d" ] || continue
        local_name=$(basename "$d")
        if [ -z "$FILTER" ] || echo "packages ${local_name}" | grep -qi -- "$FILTER"; then
            dry_listed "packages-build/${local_name}" && continue
            TOTAL=$((TOTAL + 1))
            if (cd "${d}app" && "${ZYL_BIN}" build) > $RUN_TMP/zyl_pkgbuild.log 2>&1 \
               && (cd "${d}app" && ./"$(basename "$(ls "${d}app"/*.zyl | head -1)" .zyl)") > $RUN_TMP/zyl_pkgrun.log 2>&1 \
               && ! grep -q "FAIL" $RUN_TMP/zyl_pkgrun.log \
               && grep -q "(final-hash \"blake3:" "${d}app"/*.buildinfo \
               && grep -aq "$(sed -n 's/.*(final-hash "\(blake3:[0-9a-f]*\)").*/\1/p' "${d}app"/*.buildinfo)" "${d}app/$(basename "$(ls "${d}app"/*.zyl | head -1)" .zyl)"; then
                PASS=$((PASS + 1))
                echo -e "  ${GREEN}✓${NC} packages-build/${local_name}"
            else
                FAIL=$((FAIL + 1))
                echo -e "  ${RED}✗${NC} packages-build/${local_name}"
                if [ "$VERBOSE" -eq 1 ]; then
                    sed 's/^/      /' $RUN_TMP/zyl_pkgbuild.log
                    sed 's/^/      /' $RUN_TMP/zyl_pkgrun.log
                fi
            fi
        fi
    done
fi

# Run compile-fail tests (must-fail compilation)
if [ "$MODE" = "full" ]; then
    for f in "${TESTS_DIR}"/compile-fail/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        if [ -z "$FILTER" ] || echo "$local_name" | grep -qi -- "$FILTER"; then
            run_fail_test "compile-fail/${local_name}" "$f"
        fi
    done
fi

# Script tests: shell checks of the repository's own scripts (install,
# uninstall, ...). Each runs against scratch directories and must exit 0.
if [ "$MODE" = "full" ]; then
    for f in "${TESTS_DIR}"/scripts/*.sh; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .sh)
        if [ -z "$FILTER" ] || echo "scripts ${local_name}" | grep -qi -- "$FILTER"; then
            dry_listed "scripts/${local_name}" && continue
            TOTAL=$((TOTAL + 1))
            if TMPDIR="$RUN_TMP" bash "$f" > "$RUN_TMP/zyl_script.log" 2>&1; then
                PASS=$((PASS + 1))
                echo -e "  ${GREEN}✓${NC} scripts/${local_name}"
            else
                FAIL=$((FAIL + 1))
                echo -e "  ${RED}✗${NC} scripts/${local_name}"
                sed 's/^/      /' "$RUN_TMP/zyl_script.log"
            fi
        fi
    done
fi

# Language-server protocol tests. Real JSON-RPC over stdio against
# build/boot/zyl-lsp -- the same transport an editor uses -- so a pass
# means an editor sees what the assertions describe. Cheap (a handful of
# short-lived server processes), so it runs in both quick and full mode.
if [ "$MODE" = "full" ] || [ "$MODE" = "quick" ]; then
    if [ -z "$FILTER" ] || echo "lsp" | grep -qi -- "$FILTER"; then
        if dry_listed "lsp/protocol"; then
            :
        elif [ -x "${SCRIPT_DIR}/build/boot/zyl-lsp" ]; then
            TOTAL=$((TOTAL + 1))
            if python3 "${SCRIPT_DIR}/tests/lsp/lsp_protocol_test.py" > $RUN_TMP/zyl_lsp_test.log 2>&1; then
                PASS=$((PASS + 1))
                echo -e "  ${GREEN}✓${NC} lsp/protocol"
            else
                FAIL=$((FAIL + 1))
                echo -e "  ${RED}✗${NC} lsp/protocol"
                sed 's/^/      /' $RUN_TMP/zyl_lsp_test.log
            fi
        else
            echo -e "  ${YELLOW}-${NC} lsp/protocol (build/boot/zyl-lsp missing -- run ./boot.sh)"
        fi
    fi
fi

# Constant-time (timing leakage) harness — OPT IN with `--filter timing`.
#
# Deliberately not part of a plain `--full` run: it spawns thousands of
# short processes and takes longer than every other test combined, and
# its result is a statistic rather than a pass/fail of the code itself.
# It is the check that stdlib/math's constant-time claims are about, so
# it lives here rather than in a developer's shell history. The script
# fails if its own positive control (a deliberately leaky comparison)
# goes undetected, so a green result means the measurement worked.
if [ -n "$FILTER" ] && echo "timing-leakage" | grep -qi -- "$FILTER" \
   && ! dry_listed "timing-leakage"; then
    TOTAL=$((TOTAL + 1))
    if python3 "${SCRIPT_DIR}/verify/timing.py" --quick > $RUN_TMP/zyl_timing.log 2>&1; then
        PASS=$((PASS + 1))
        echo -e "  ${GREEN}✓${NC} timing-leakage"
        sed 's/^/      /' $RUN_TMP/zyl_timing.log
    else
        FAIL=$((FAIL + 1))
        echo -e "  ${RED}✗${NC} timing-leakage"
        sed 's/^/      /' $RUN_TMP/zyl_timing.log
    fi
fi

# Verifier cross-check: the assembly verifier's verdict against an independent
# implementation of the same rules.
#
# It runs in a plain `--full` and in `--quick`, because it costs about a second
# and it guards the check the whole binary-safety argument rests on. A
# verifier that is quietly wrong reports success, so it needs a second opinion
# on every run rather than on request; the oracle has its own selftest with
# planted violations, and the seed verdicts must match field for field,
# including operand counts.
if [ -z "$FILTER" ] || echo "frame-oracle" | grep -qi -- "$FILTER"; then
    if ! dry_listed "frame-oracle"; then
        TOTAL=$((TOTAL + 1))
        if "${SCRIPT_DIR}/verify/frame_oracle.sh" > "$RUN_TMP/zyl_frame_oracle.log" 2>&1; then
            PASS=$((PASS + 1))
            echo -e "  ${GREEN}✓${NC} frame-oracle"
            sed 's/^/      /' "$RUN_TMP/zyl_frame_oracle.log"
        else
            FAIL=$((FAIL + 1))
            echo -e "  ${RED}✗${NC} frame-oracle"
            sed 's/^/      /' "$RUN_TMP/zyl_frame_oracle.log"
        fi
    fi
fi

# Memory-safety gate (Valgrind memcheck) -- OPT IN with `--filter memcheck`.
#
# Also opt-in rather than part of a plain `--full`, because memcheck runs
# every program ~50x slower than native and the sweep takes minutes. It is
# here rather than in a shell history because "the programs have no memory
# errors" is a property that has to keep being true, not a claim made once
# in a commit message. The script checks its own positive control and then
# its own detection path (`--self-test`), so a green result means the
# measurement worked rather than that nothing was measured.
#
# Valgrind rather than ASan, deliberately: the runtime does not call malloc,
# so ASan's heap interception would never see a region. See verify/memcheck.sh.
if [ -n "$FILTER" ] && echo "memcheck" | grep -qi -- "$FILTER" \
   && ! dry_listed "memcheck"; then
    TOTAL=$((TOTAL + 1))
    if "${SCRIPT_DIR}/verify/memcheck.sh" --self-test > $RUN_TMP/zyl_memcheck.log 2>&1 \
       && "${SCRIPT_DIR}/verify/memcheck.sh" >> $RUN_TMP/zyl_memcheck.log 2>&1; then
        PASS=$((PASS + 1))
        echo -e "  ${GREEN}✓${NC} memcheck"
        sed 's/^/      /' $RUN_TMP/zyl_memcheck.log
    else
        FAIL=$((FAIL + 1))
        echo -e "  ${RED}✗${NC} memcheck"
        sed 's/^/      /' $RUN_TMP/zyl_memcheck.log
    fi
fi

# Region-lifetime gate (released blocks filled with 0xDE) -- OPT IN with
# `--filter poison`.
#
# This is the only dynamic check of L2 -- that no value outlives its region
# -- which is otherwise an argued premise, and the weakest link in the
# memory-safety story. The fill is the same 0xDE the runtime already uses
# for arena blocks. Unlike memcheck, this gate has no positive control and
# cannot have one: the violation it looks for is what the static checks
# exist to prevent, so no test program expressing it compiles. verify/
# poison.sh says so in full rather than papering over it.
if [ -n "$FILTER" ] && echo "poison" | grep -qi -- "$FILTER" \
   && ! dry_listed "poison"; then
    TOTAL=$((TOTAL + 1))
    if "${SCRIPT_DIR}/verify/poison.sh" > $RUN_TMP/zyl_poison.log 2>&1; then
        PASS=$((PASS + 1))
        echo -e "  ${GREEN}✓${NC} poison"
        sed 's/^/      /' $RUN_TMP/zyl_poison.log
    else
        FAIL=$((FAIL + 1))
        echo -e "  ${RED}✗${NC} poison"
        sed 's/^/      /' $RUN_TMP/zyl_poison.log
    fi
fi

# Self-hosting under poisoned regions — OPT IN with `--filter poison-selfhost`.
#
# The strongest single check in the repository for L2 (no value outlives its
# region). It rebuilds the entire compiler -- the largest Zyl program that
# exists -- with released region blocks refilled with 0xDE, and requires the
# seeds to come out byte-identical. If the compiler read dead frame memory
# anywhere, the fill would corrupt a value and codegen output would differ
# from the committed seed.
if [ -n "$FILTER" ] && echo "poison-selfhost" | grep -qi -- "$FILTER" \
   && ! dry_listed "poison-selfhost"; then
    TOTAL=$((TOTAL + 1))
    if "${SCRIPT_DIR}/verify/poison-selfhost.sh" > $RUN_TMP/zyl_poison_selfhost.log 2>&1; then
        PASS=$((PASS + 1))
        echo -e "  ${GREEN}✓${NC} poison-selfhost"
        sed 's/^/      /' $RUN_TMP/zyl_poison_selfhost.log
    else
        FAIL=$((FAIL + 1))
        echo -e "  ${RED}✗${NC} poison-selfhost"
        sed 's/^/      /' $RUN_TMP/zyl_poison_selfhost.log
    fi
fi

# Determinism gate — OPT IN with `--filter determinism`.
#
# Determinism is the reason the language exists (spec 14), and it breaks in
# two ways. End to end: the same program compiled twice, in separate
# processes, must be byte-identical -- 120 programs. By construction:
# verify/model.py explores the region allocator's reachable state space
# exhaustively and requires the transition relation to be a function, so an
# allocation cannot land in two different blocks. That check's own detection
# path is exercised too, against a deliberately double-freeing allocator.
if [ -n "$FILTER" ] && echo "determinism" | grep -qi -- "$FILTER" \
   && ! dry_listed "determinism"; then
    TOTAL=$((TOTAL + 1))
    if "${SCRIPT_DIR}/verify/determinism.sh" > $RUN_TMP/zyl_determinism.log 2>&1; then
        PASS=$((PASS + 1))
        echo -e "  ${GREEN}✓${NC} determinism"
        sed 's/^/      /' $RUN_TMP/zyl_determinism.log
    else
        FAIL=$((FAIL + 1))
        echo -e "  ${RED}✗${NC} determinism"
        sed 's/^/      /' $RUN_TMP/zyl_determinism.log
    fi
fi

# Self-hosting fixed-point verification (default in --full; slow)
if [ "$BOOT" -eq 1 ] && [ "$NO_BOOT" -eq 0 ] && ! dry_listed "boot/fixed-point"; then
    TOTAL=$((TOTAL + 1))
    echo ""
    echo "=== Self-hosting fixed point (boot.sh) ==="
    if "${SCRIPT_DIR}/boot.sh" > $RUN_TMP/zyl_boot_check.log 2>&1; then
        PASS=$((PASS + 1))
        echo -e "  ${GREEN}✓${NC} boot/fixed-point"
    else
        FAIL=$((FAIL + 1))
        cp "$RUN_TMP/zyl_boot_check.log" "${SCRIPT_DIR}/build/boot/boot_check.log" 2>/dev/null || true
        echo -e "  ${RED}✗${NC} boot/fixed-point (see build/boot/boot_check.log)"
    fi
fi

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

if [ "$DRY_RUN" -eq 1 ]; then
    echo ""
    echo "Total: $TOTAL tests"
    exit 0
fi

echo ""
echo "=== Results: ${PASS}/${TOTAL} passed, ${FAIL} failed (${ELAPSED}s) ==="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
