#!/usr/bin/env bash
# The memory budget: E_OUT_OF_MEMORY flushes earlier stdout, a bytebuf over it
# is E_OUT_OF_MEMORY rather than a null handle, and ZYL_MAX_MEMORY takes K/M/G/T
# and refuses anything that is not a size.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_budget.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

cat > "$SCRATCH/grow.zyl" <<'ZYL'
(use collections/vec)
(defn grow (v n) (if (= n 0) (vec-len v) (grow (vec-push v n) (- n 1))))
(defn main () (begin (print "before") (print (grow (vec-new) 100000000000)) 0))
ZYL
cat > "$SCRATCH/bb.zyl" <<'ZYL'
(defn main ()
  (let b (bytebuf Heap 200000000)
    (begin (print (bytebuf-cap b)) (store-u8 :le b 5 7) (print (load-u8 :le b 5)) 0)))
ZYL
for p in grow bb; do
    "$ZYL" "$SCRATCH/$p.zyl" -o "$SCRATCH/$p" > "$SCRATCH/build.log" 2>&1 || fail "build: $(cat "$SCRATCH/build.log")"
done

# Piped stdout is fully buffered; the OOM report must not lose it.
set +e
out=$(ZYL_MAX_MEMORY=300000000 "$SCRATCH/grow" 2>/dev/null | cat)
err=$(ZYL_MAX_MEMORY=300000000 "$SCRATCH/grow" 2>&1 >/dev/null); rc=$?
set -e
[ "$out" = "before" ] || fail "output before E_OUT_OF_MEMORY was lost: [$out]"
[ "$rc" -eq 1 ] || fail "OOM exited $rc"
echo "$err" | grep -q 'error\[E_OUT_OF_MEMORY\]' || fail "no E_OUT_OF_MEMORY: $err"

set +e
out=$(ZYL_MAX_MEMORY=100000000 "$SCRATCH/bb" 2>&1); rc=$?
set -e
[ "$rc" -eq 1 ] || fail "bytebuf over budget exited $rc: $out"
echo "$out" | grep -q 'error\[E_OUT_OF_MEMORY\]: bytebuf' || fail "bytebuf over budget: $out"
out=$(ZYL_MAX_MEMORY=1G "$SCRATCH/bb" 2>&1) || fail "bytebuf under a 1G budget: $out"
[ "$out" = "$(printf '200000000\n7')" ] || fail "bytebuf under budget: $out"

set +e
out=$(ZYL_MAX_MEMORY=100M "$SCRATCH/bb" 2>&1)
set -e
echo "$out" | grep -q 'budget 104857600 bytes' || fail "100M is not 100 MiB: $out"
for bad in abc 10X 5kq 99999999999999999999; do
    set +e
    out=$(ZYL_MAX_MEMORY=$bad "$SCRATCH/bb" 2>&1); rc=$?
    set -e
    [ "$rc" -eq 2 ] || fail "ZYL_MAX_MEMORY=$bad exited $rc: $out"
    echo "$out" | grep -q "ZYL_MAX_MEMORY=$bad is not a size" || fail "ZYL_MAX_MEMORY=$bad: $out"
done
echo "memory-budget: ok"
