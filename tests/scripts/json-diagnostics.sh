#!/usr/bin/env bash
# --error-format=json: one object per diagnostic, every one with its code
# (the type pass's closing summary included).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_json_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

printf '(defn g () (+ 1 "a"))\n(defn h () (str-concat 1 "b"))\n(defn main () 0)\n' > "$SCRATCH/t.zyl"
out="$("$ZYL" "$SCRATCH/t.zyl" -o "$SCRATCH/t" --error-format=json 2>&1 || true)"
n="$(printf '%s\n' "$out" | grep -c '^{')"
[ "$n" -eq 3 ] || fail "expected 3 JSON objects, got $n: $out"
printf '%s\n' "$out" | grep -q '"code":""' && fail "a diagnostic has an empty code: $out"
printf '%s\n' "$out" | tail -1 | grep -q '"code":"E_TYPE_MISMATCH","message":"the program does not type-check' || fail "summary: $out"
echo ok
