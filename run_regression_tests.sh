#!/bin/bash
set -e

echo "=== Zyl Regression Test Suite ==="
echo ""

PASS=0
FAIL=0

run_test() {
    local name="$1"
    local file="$2"
    local expected="$3"
    
    if [ ! -f "$file" ]; then
        echo "  ✗ $name: source file not found ($file)"
        FAIL=$((FAIL + 1))
        return
    fi
    
    # Compile
    if ! cargo run --bin zyl -- "$file" > /dev/null 2>&1; then
        echo "  ✗ $name: compilation failed"
        FAIL=$((FAIL + 1))
        return
    fi
    
    # Run
    local actual
    actual=$(timeout 5 ./a.out.bin 2>/dev/null || echo "TIMEOUT")
    
    # Check output
    if [ "$actual" = "$expected" ]; then
        echo "  ✓ $name"
        PASS=$((PASS + 1))
    else
        echo "  ✗ $name: expected '$expected', got '$actual'"
        FAIL=$((FAIL + 1))
    fi
}

# Test multi-operand calls and BinOps
run_test "test_max" "test_max.zyl" "6
10
15
106
25"

# Test basic BinOps
run_test "binop_test" "/tmp/binop_test.zyl" "106"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
