#!/usr/bin/env bash
# --error-format=json: the located diagnostics carry file/line/column, and
# E_REGION_ESCAPE a label at the point of escape.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_located_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
json() { "$ZYL" "$1" -o "$SCRATCH/out" --error-format=json 2>&1 || true; }

# A Stack bytebuf passed on to a function that keeps it.
printf '(defn keep (b) (chan-send (chan-tx (chan 1)) b))\n(defn leak ()\n  (let b (bytebuf Stack 16)\n    (let _ (keep b) 0)))\n(defn main () (begin (leak) 0))\n' > "$SCRATCH/esc.zyl"
out="$(json "$SCRATCH/esc.zyl")"
printf '%s\n' "$out" | grep -q '"code":"E_REGION_ESCAPE".*"line":3,"column":10,"labels":\[{"message":"escapes here[^"]*","file":"[^"]*esc.zyl","line":4,' \
  || fail "region escape label: $out"

# Returned through a let: the label is the returned name.
printf '(defn make ()\n  (let b (bytebuf Stack 16)\n    b))\n(defn main () (begin (print (bytebuf-cap (make))) 0))\n' > "$SCRATCH/ret.zyl"
out="$(json "$SCRATCH/ret.zyl")"
printf '%s\n' "$out" | grep -q '"code":"E_REGION_ESCAPE".*"line":2,"column":10,"labels":\[{"message":"escapes here: returned from the function","file":"[^"]*ret.zyl","line":3,"column":5}' \
  || fail "region return label: $out"

# with-region: a value that leaves the region.
printf '(deftype WL (WN) (WC Int WL))\n(defn build (n acc) (if (= n 0) acc (build (- n 1) (WC n acc))))\n(defn leak () (with-region (arena :block 4096) (build 10 (WN))))\n(defn main () (begin (print (match (leak) (WN 0) (WC h _ h))) 0))\n' > "$SCRATCH/wr.zyl"
out="$(json "$SCRATCH/wr.zyl")"
printf '%s\n' "$out" | grep -q '"code":"E_REGION_ESCAPE".*"line":3,"column":58,"labels":\[{"message":"[^"]*","file":"[^"]*wr.zyl","line":3,"column":15}' \
  || fail "with-region label: $out"

# E_ZEROIZE_MISSING is a located warning.
printf '(use math/secret/secret)\n(defn tag ((k Secret)) (declassify k))\n(defn main () (begin (print (tag 3)) 0))\n' > "$SCRATCH/zero.zyl"
out="$(json "$SCRATCH/zero.zyl")"
printf '%s\n' "$out" | grep -q '"severity":"warning","code":"E_ZEROIZE_MISSING".*"file":"[^"]*zero.zyl","line":2,"column":1' \
  || fail "zeroize warning: $out"

# A duplicate parameter, located at the repeat.
printf '(defn f (a b a) (+ a b))\n(defn main () (begin (print (f 1 2 3)) 0))\n' > "$SCRATCH/dup.zyl"
out="$(json "$SCRATCH/dup.zyl")"
printf '%s\n' "$out" | grep -q '"code":"E_DUPLICATE_PARAMETER".*"line":1,"column":14' \
  || fail "duplicate parameter: $out"
echo ok
