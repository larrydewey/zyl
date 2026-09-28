#!/usr/bin/env bash
# The Zyl assembler + ELF linker (ZYL_SELF_LINK=1): same output as the cc link, byte-identical across links, static.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_selflink_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
cat > "$SCRATCH/p.zyl" <<'ZEOF'
(use actor/actor)
(defn sum (rx n acc) (if (= n 0) acc (sum rx (- n 1) (+ acc (chan-recv rx)))))
(defn feed (tx i) (if (= i 100) 0 (let _ (chan-send tx i) (feed tx (+ i 1)))))
(defn main ()
  (let c (chan 4)
    (let tx (chan-tx c)
      (let a (spawn (fn () (let _ (print "feeding") (feed tx 0))))
        (let _ (print (sum (chan-rx c) 100 0)) (let _ (print 2.5) (let _ (actor-wait a) 0)))))))
ZEOF
"$ZYL" "$SCRATCH/p.zyl" -o "$SCRATCH/cc" >/dev/null 2>&1 || fail "cc link"
ZYL_SELF_LINK=1 "$ZYL" "$SCRATCH/p.zyl" -o "$SCRATCH/self1" >/dev/null 2>&1 || fail "self link"
ZYL_SELF_LINK=1 "$ZYL" "$SCRATCH/p.zyl" -o "$SCRATCH/self2" >/dev/null 2>&1 || fail "second self link"
cmp -s "$SCRATCH/self1" "$SCRATCH/self2" || fail "self link is not byte-deterministic"
[ "$("$SCRATCH/self1")" = "$("$SCRATCH/cc")" ] || fail "self-linked output differs from the cc link"
head -c 4 "$SCRATCH/self1" | od -An -c | grep -q 'E   L   F' || fail "not an ELF file"
if command -v readelf >/dev/null; then
  readelf -l "$SCRATCH/self1" | grep -q INTERP && fail "self-linked binary has an interpreter"
  readelf -l "$SCRATCH/self1" | grep -A1 GNU_STACK | grep -q RWE && fail "executable stack"
fi
echo ok
