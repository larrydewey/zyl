#!/usr/bin/env bash
# A closed file handle never reaches the file that reuses its number (spec G2, soundness L3 runtime floor).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_stalefd.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

# The release crosses a function boundary, so linearity cannot see it.
cat > "$SCRATCH/via_fn.zyl" <<ZYL
(capabilities io)
(use core/core)
(defn ident (x) x)
(defn main ()
  (let fd (file-open "$SCRATCH/a.txt" "w")
    (let copy (ident fd)
      (begin
        (file-close fd)
        (let g (file-open "$SCRATCH/victim.txt" "w")
          (begin (file-write copy "LEAKED") (file-close g) 0))))))
ZYL
# A second close through a helper is a no-op, not a close of the victim.
cat > "$SCRATCH/double.zyl" <<ZYL
(capabilities io)
(use core/core)
(defn ident (x) x)
(defn closer (f) (file-close f))
(defn main ()
  (let fd (file-open "$SCRATCH/b.txt" "w")
    (let copy (ident fd)
      (begin
        (file-close fd)
        (let g (file-open "$SCRATCH/victim2.txt" "w")
          (begin (print (closer copy)) (print (file-write g "victim-data")) (file-close g) 0))))))
ZYL
for p in via_fn double; do
    "$ZYL" "$SCRATCH/$p.zyl" -o "$SCRATCH/$p" > "$SCRATCH/build.log" 2>&1 || fail "build $p: $(cat "$SCRATCH/build.log")"
done

set +e
out=$("$SCRATCH/via_fn" 2>&1); rc=$?
set -e
[ "$rc" -eq 1 ] || fail "stale write exited $rc: $out"
echo "$out" | grep -q 'E_USE_AFTER_FREE' || fail "no E_USE_AFTER_FREE: $out"
[ ! -s "$SCRATCH/victim.txt" ] || fail "stale handle wrote into the victim: $(cat "$SCRATCH/victim.txt")"

out=$("$SCRATCH/double" 2>&1) || fail "double close failed: $out"
[ "$out" = "$(printf -- '-1\n11')" ] || fail "double close output: $out"
[ "$(cat "$SCRATCH/victim2.txt")" = "victim-data" ] || fail "victim lost its data"
echo ok
