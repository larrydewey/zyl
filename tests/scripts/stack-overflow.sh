#!/usr/bin/env bash
# Deep recursion under a memory budget stops with E_STACK_OVERFLOW, not a
# bare SIGSEGV, and the stack it may use is a quarter of the budget.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_stack.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

cat > "$SCRATCH/deep.zyl" <<'ZYL'
(use core/core)
(defn down (n) (if (= n 0) 0 (let r (down (- n 1)) (if (> r -1) (+ r 1) r))))
(defn main () (begin (print "start") (print (down 100000000)) 0))
ZYL
sed 's/100000000/1000/' "$SCRATCH/deep.zyl" > "$SCRATCH/shallow.zyl"
for p in deep shallow; do
    "$ZYL" "$SCRATCH/$p.zyl" -o "$SCRATCH/$p" > "$SCRATCH/build.log" 2>&1 || fail "build: $(cat "$SCRATCH/build.log")"
done

out=$(ZYL_MAX_MEMORY=268435456 "$SCRATCH/shallow" 2>&1) || fail "shallow recursion failed: $out"
echo "$out" | grep -q '^1000$' || fail "shallow: $out"

set +e
out=$(ZYL_MAX_MEMORY=268435456 "$SCRATCH/deep" 2>&1); rc=$?
set -e
[ "$rc" -eq 1 ] || fail "deep recursion exited $rc: $out"
echo "$out" | grep -q '^start$' || fail "output before the overflow was lost: $out"
echo "$out" | grep -q 'error\[E_STACK_OVERFLOW\]' || fail "no E_STACK_OVERFLOW: $out"
echo "$out" | grep -q '67108864-byte stack' || fail "the stack is not a quarter of the budget: $out"
echo "stack-overflow: ok"
