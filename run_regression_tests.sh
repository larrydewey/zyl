#!/usr/bin/env bash
# Zyl Regression Test Runner
# Usage: ./run_regression_tests.sh [OPTIONS]
#   --quick      Run smoke tests only (~30s)
#   --full       Run all tests (~5min)
#   --dry-run    List tests without running
#   --filter N   Run test file N (basename, e.g. "structs")
#   --verbose    Print compiler output
#   --depth N    Set nesting depth for stress tests (default: 100)
#   --timeout N  Per-test timeout in seconds (default: 10)
#   --boot       Force the self-hosting fixed-point verification
#                (./boot.sh --skip-rust) in any mode
#   --no-boot    Skip the fixed-point verification in --full mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZYL_BIN="${SCRIPT_DIR}/target/debug/zyl"
TESTS_DIR="${SCRIPT_DIR}/tests"

# Defaults
MODE="quick"
FILTER=""
VERBOSE=0
DEPTH=100
TIMEOUT=10
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
        --filter) FILTER="$2"; shift 2 ;;
        --verbose) VERBOSE=1; shift ;;
        --depth) DEPTH="$2"; shift 2 ;;
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

run_test() {
    local name="$1"
    local file="$2"
    
    TOTAL=$((TOTAL + 1))
    
    if [ ! -f "$file" ]; then
        echo -e "  ${RED}✗${NC} ${name}: source file not found (${file})"
        FAIL=$((FAIL + 1))
        return
    fi
    
    # Compile
    local output
    if ! output=$("${ZYL_BIN}" "$file" "/tmp/zyl_test_${TOTAL}.bin" 2>&1); then
        echo -e "  ${RED}✗${NC} ${name}: compilation failed"
        if [ "$VERBOSE" -eq 1 ]; then
            echo "    $output"
        fi
        FAIL=$((FAIL + 1))
        return
    fi
    
    # Run
    local actual exit_code
    actual=$(timeout "$TIMEOUT" "/tmp/zyl_test_${TOTAL}.bin" 2>/dev/null) || exit_code=$?
    
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

echo "=== Zyl Regression Test Suite ==="
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    echo "=== Dry Run ==="
    if [ "$MODE" = "quick" ]; then
        for f in "${TESTS_DIR}"/smoke/*.zyl; do
            [ -f "$f" ] && echo "  - $(basename "$f" .zyl)"
        done
        echo "  - unit_test"
    else
        for dir in smoke stress regression integration; do
            for f in "${TESTS_DIR}"/${dir}/*.zyl; do
                [ -f "$f" ] && echo "  - ${dir}/$(basename "$f" .zyl)"
            done
        done
        echo "  - unit_test"
    fi
    echo ""
    echo "Total: $TOTAL tests"
    exit 0
fi

echo "Mode: ${MODE} | Filter: ${FILTER:-none} | Depth: ${DEPTH} | Timeout: ${TIMEOUT}s"
echo ""

# Run unit test (comprehensive harness)
if [ "$MODE" = "full" ] || [ "$MODE" = "quick" ]; then
    if [ -z "$FILTER" ] || echo "$FILTER" | grep -qi "unit"; then
        run_test "unit_test" "${TESTS_DIR}/unit_test.zyl"
    fi
fi

# Run smoke tests (always in quick mode)
if [ "$MODE" = "quick" ]; then
    for f in "${TESTS_DIR}"/smoke/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        if [ -z "$FILTER" ] || echo "$FILTER" | grep -qi "$local_name"; then
            run_test "smoke/${local_name}" "$f"
        fi
    done
fi

# Run regression tests
if [ "$MODE" = "full" ]; then
    for f in "${TESTS_DIR}"/regression/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        if [ -z "$FILTER" ] || echo "$FILTER" | grep -qi "$local_name"; then
            run_test "regression/${local_name}" "$f"
        fi
    done
fi

# Run stress tests
if [ "$MODE" = "full" ]; then
    for f in "${TESTS_DIR}"/stress/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        if [ -z "$FILTER" ] || echo "$FILTER" | grep -qi "$local_name"; then
            run_test "stress/${local_name}" "$f"
        fi
    done
fi

# Run integration tests
if [ "$MODE" = "full" ]; then
    for f in "${TESTS_DIR}"/integration/*.zyl; do
        [ -f "$f" ] || continue
        local_name=$(basename "$f" .zyl)
        if [ -z "$FILTER" ] || echo "$FILTER" | grep -qi "$local_name"; then
            run_test "integration/${local_name}" "$f"
        fi
    done
fi

# Self-hosting fixed-point verification (default in --full; slow)
if [ "$BOOT" -eq 1 ] && [ "$NO_BOOT" -eq 0 ]; then
    TOTAL=$((TOTAL + 1))
    echo ""
    echo "=== Self-hosting fixed point (boot.sh) ==="
    if "${SCRIPT_DIR}/boot.sh" --skip-rust > /tmp/zyl_boot_check.log 2>&1; then
        PASS=$((PASS + 1))
        echo -e "  ${GREEN}✓${NC} boot/fixed-point"
    else
        FAIL=$((FAIL + 1))
        echo -e "  ${RED}✗${NC} boot/fixed-point (see /tmp/zyl_boot_check.log)"
    fi
fi

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo ""
echo "=== Results: ${PASS}/${TOTAL} passed, ${FAIL} failed (${ELAPSED}s) ==="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
