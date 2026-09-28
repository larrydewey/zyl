#!/usr/bin/env bash
# `zyl balance`: files and directories, located text and JSON reports, the exit status.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_balance_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

mkdir -p "$SCRATCH/src/sub"
printf '(defn f (x) (+ x 1))\n' > "$SCRATCH/src/good.zyl"
printf '(defn g (x)\n  (if (> x 0) x 0)\n(defn h () 1))\n' > "$SCRATCH/src/sub/misplaced.zyl"
printf '(defn k () "open)\n' > "$SCRATCH/src/sub/string.zyl"

"$ZYL" balance "$SCRATCH/src/good.zyl" > "$SCRATCH/out" 2>&1 || fail "a balanced file failed: $(cat "$SCRATCH/out")"
grep -q "1 file, balanced" "$SCRATCH/out" || fail "summary: $(cat "$SCRATCH/out")"

if "$ZYL" balance "$SCRATCH/src" > "$SCRATCH/out" 2> "$SCRATCH/err"; then fail "an unbalanced tree passed"; fi
grep -q "3 files, 2 unbalanced" "$SCRATCH/out" || fail "summary: $(cat "$SCRATCH/out")"
grep -q "error\[E_UNBALANCED_UNCLOSED\]" "$SCRATCH/err" || fail "no unclosed report: $(cat "$SCRATCH/err")"
grep -q "misplaced.zyl:1:1" "$SCRATCH/err" || fail "misplaced paren not located at its form: $(cat "$SCRATCH/err")"
grep -q "string.zyl:1:12" "$SCRATCH/err" || fail "unterminated string not located at its quote: $(cat "$SCRATCH/err")"

if "$ZYL" balance "$SCRATCH/src" --error-format=json > "$SCRATCH/out" 2> "$SCRATCH/err"; then fail "json run passed"; fi
[ "$(grep -c '^{' "$SCRATCH/err")" -eq 2 ] || fail "expected 2 JSON objects: $(cat "$SCRATCH/err")"

if "$ZYL" balance "$SCRATCH/missing.zyl" > /dev/null 2>&1; then fail "a missing file passed"; fi
echo "balance-cli: ok"
