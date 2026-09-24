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
    interpreted=$(timeout "$DIFF_TIMEOUT" "${ZYL_BIN}" eval "$file" 2>/dev/null) || true

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
#   actors, actor-receive, concurrency — spawning an actor hands the runtime a native
#                          function pointer, which an interpreted
#                          function does not have. The interpreter says
#                          so (E_UNSUPPORTED_INTERPRETED) rather than
#                          jumping to a number.
#   derive               — one of its tests prints a value's address,
#                          which is not the same number in two different
#                          runtimes and is not meant to be.
#   collections          — asserts that a fresh alloc-malloc block reads
#                          back as zeroes, which malloc does not promise.
#   ffi-advanced         — prints the bytes at a pinned address, which
#                          are not the same bytes in two runtimes.
#   modules              — one of its tests spawns an actor.
#   package-system       — its signature tests are Ed25519.
#   c-abi                — hands a function to qsort as a C callback,
#                          which needs a native function pointer.
#   math-*               — minutes of interpreted arithmetic for what
#                          the compiled suite already covers in seconds.
#                          Matched by prefix, below.
#   tail-calls           — 10^8-deep loops, far too slow interpreted.
DIFF_SKIP="actors actor-receive concurrency modules derive collections ffi-advanced package-system selfhost-codegen c-abi tail-calls"

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
