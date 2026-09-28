#!/usr/bin/env bash
# The Zyl assembler + ELF linker (the default freestanding link): same output as the cc link, byte-identical across links and cache states, static; the rt.zo cache is rebuilt when stale or torn.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BOOT="$ROOT/build/boot"
ZYL="$BOOT/stage2.bin"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_selflink_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
# A private bundle, so the cache tests never touch build/boot/rt.zo.
H="$SCRATCH/home"; mkdir -p "$H"
ln -s "$BOOT/stdlib" "$H/stdlib"
cp "$BOOT/rt.s" "$BOOT/start.s" "$BOOT/rt.o" "$BOOT/start.o" "$H/"
export ZYL_HOME="$H"
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
ZYL_EXTERNAL_LD=1 "$ZYL" "$SCRATCH/p.zyl" -o "$SCRATCH/cc" >/dev/null 2>&1 || fail "cc link"
"$ZYL" "$SCRATCH/p.zyl" -o "$SCRATCH/self1" >/dev/null 2>&1 || fail "self link (cache miss)"
[ -f "$H/rt.zo" ] || fail "no rt.zo written"
"$ZYL" "$SCRATCH/p.zyl" -o "$SCRATCH/self2" >/dev/null 2>&1 || fail "self link (cache hit)"
cmp -s "$SCRATCH/self1" "$SCRATCH/self2" || fail "cache miss and hit links differ"
[ "$("$SCRATCH/self1")" = "$("$SCRATCH/cc")" ] || fail "self-linked output differs from the cc link"
head -c 4 "$SCRATCH/self1" | od -An -c | grep -q 'E   L   F' || fail "not an ELF file"
if command -v readelf >/dev/null; then
  readelf -l "$SCRATCH/self1" | grep -q INTERP && fail "self-linked binary has an interpreter"
  readelf -l "$SCRATCH/self1" | grep -A1 GNU_STACK | grep -q RWE && fail "executable stack"
fi
# A torn cache is rebuilt.
head -c 100 "$H/rt.zo" > "$SCRATCH/torn" && cp "$SCRATCH/torn" "$H/rt.zo"
"$ZYL" "$SCRATCH/p.zyl" -o "$SCRATCH/self3" >/dev/null 2>&1 || fail "self link over a torn cache"
cmp -s "$SCRATCH/self1" "$SCRATCH/self3" || fail "torn-cache link differs"
[ "$(wc -c < "$H/rt.zo")" -gt 100 ] || fail "torn cache not rewritten"
# A stale cache (start.s changed) is rebuilt.
cp "$H/rt.zo" "$SCRATCH/old.zo"
printf '\n' >> "$H/start.s"
"$ZYL" "$SCRATCH/p.zyl" -o "$SCRATCH/self4" >/dev/null 2>&1 || fail "self link over a stale cache"
cmp -s "$H/rt.zo" "$SCRATCH/old.zo" && fail "stale cache not rebuilt"
cmp -s "$SCRATCH/self1" "$SCRATCH/self4" || fail "stale-cache link differs"
echo ok
