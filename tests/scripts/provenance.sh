#!/bin/sh
# The provenance record, cross-checked against cbor2.
#
# tests/provenance_test.zyl asks whether the record's keys are in canonical
# order, which is a question about our own consistency. It cannot ask whether
# the ORDER ITSELF is the one RFC 8949 section 4.2.1 calls canonical -- a
# consistently wrong order is still consistently wrong. This script asks cbor2
# to sort the same keys the way it does, and fails if ours disagrees.
set -e
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export ZYL_HOME="$PWD/build/boot"
ZYL="$PWD/build/boot/zyl-self"
[ -x "$ZYL" ] || { echo "provenance.sh: no compiler at $ZYL -- run ./boot.sh first"; exit 1; }

python3 -c "import cbor2" 2>/dev/null || {
  echo "provenance.sh: needs the cbor2 module; skipping"; exit 0; }

BIN=$(mktemp -d)
trap 'rm -rf "$BIN"' EXIT

cat > "$BIN/rec.zyl" <<'EOF'
(use compiler/provenance)

(def hexdigits "0123456789abcdef")

(defn byte-hex (v)
  (str-concat (str-substring hexdigits (/ v 16) 1) (str-substring hexdigits (bit-and v 15) 1)))

(defn buf-hex ((b ByteBuf) (n Int) (i Int) (acc String))
  (if (>= i n)
    acc
    (buf-hex b n (+ i 1) (str-concat acc (byte-hex (load-u8 :le b i))))))

(def h1 "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
(def h2 "1f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100")
(def h3 "202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f")
(def h4 "404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f")
(def h5 "606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f")
(def h6 "7f7e7d7c7b7a797877767574737271706f6e6d6c6b6a69686766656463626160")
(def h7 "808f8e8d8c8b8a898877868584838281807f7e7d7c7b7a797877767574737271")

(defn main ()
  (let r (prov-record h1 h2 h3 h4 h5 h6 h7)
    (let b (match r (ProvOut buf n buf))
      (begin
        (print (buf-hex b (match r (ProvOut _ n2 n2)) 0 ""))
        0))))

(main)
(numeric checked)
EOF

"$ZYL" "$BIN/rec.zyl" -o "$BIN/rec.bin" >/dev/null 2>&1
HEX=$("$BIN/rec.bin")
[ -n "$HEX" ] || { echo "not ok -- the Zyl side produced no record"; exit 1; }

HEX="$HEX" python3 <<'PY'
import binascii, os, sys
import cbor2

fail = []


def check(name, ok, detail=""):
    print(("ok   -- " if ok else "FAIL -- ") + name + (("  " + detail) if detail else ""))
    if not ok:
        fail.append(name)


raw = binascii.unhexlify(os.environ["HEX"].strip())
rec = cbor2.loads(raw)

# 1. It decodes as a map, and it is the record.
check("the record decodes as a map", isinstance(rec, dict))
check("kind is provenance", rec.get("kind") == "provenance", repr(rec.get("kind")))
check("format is 1", rec.get("format") == 1, repr(rec.get("format")))

# 2. THE load-bearing check: our key order is the canonical one cbor2 computes.
#    `cbor2.dumps(k)` for a text key is the key's encoded bytes, and RFC 8949
#    4.2.1 sorts by exactly those.
ours = list(rec.keys())
want = sorted(ours, key=lambda k: cbor2.dumps(k))
check("our key order is cbor2's canonical order", ours == want,
      "" if ours == want else "\n         ours " + str(ours) + "\n         want " + str(want))

# 3. Re-encoding the decoded record must reproduce our bytes exactly. A record
#    that decodes correctly but does not re-encode identically is not canonical,
#    and a signature over it would verify against one encoding only.
check("the record re-encodes byte-identically", cbor2.dumps(rec) == raw)

# 4. The four 31.12 inputs are present as 32 raw bytes, not hex text.
for k in ("compiler-hash", "graph-hash", "objects-hash", "icnf-hash", "asm-hash",
          "binary-hash", "final-hash"):
    v = rec.get(k)
    check("%s is 32 raw bytes" % k, isinstance(v, bytes) and len(v) == 32,
          repr(v)[:40])

# 5. The hashes are the ones passed in, in the right fields -- so a record that
#    reuses one field's value for another is visible.
h = {n: bytes(range(0, 32)) for n in ()}
expect = {
    "compiler-hash": binascii.unhexlify("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"),
    "graph-hash": binascii.unhexlify("1f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100"),
    "objects-hash": binascii.unhexlify("202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f"),
    "icnf-hash": binascii.unhexlify("404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f"),
    "asm-hash": binascii.unhexlify("606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f"),
    "final-hash": binascii.unhexlify("7f7e7d7c7b7a797877767574737271706f6e6d6c6b6a69686766656463626160"),
    "binary-hash": binascii.unhexlify("808f8e8d8c8b8a898877868584838281807f7e7d7c7b7a797877767574737271"),
}
for k, v in expect.items():
    check("%s holds the value it was given" % k, rec.get(k) == v)

# 6. The evidence is nested, with its own canonical keys, and the unimplemented
#    checks are named as such rather than reported as passed.
ev = rec.get("evidence")
check("evidence is a map", isinstance(ev, dict))
if isinstance(ev, dict):
    ek = list(ev.keys())
    check("evidence keys are canonical too",
          ek == sorted(ek, key=lambda k: cbor2.dumps(k)), str(ek))
    for k in ("functions", "writes", "reads", "dynamic", "unverified"):
        check("evidence.%s is an integer" % k, isinstance(ev.get(k), int), repr(ev.get(k)))
    checks = ev.get("checks")
    check("evidence.checks is a list of strings",
          isinstance(checks, list) and all(isinstance(c, str) for c in checks))
    if isinstance(checks, list):
        check("all four checks are named", len(checks) == 4, str(len(checks)))
        joined = " ".join(checks)
        check("V3 is reported as not implemented", "V3" in joined and "not implemented" in joined)
        check("V4 is reported as not implemented", "V4" in joined and "not implemented" in joined)
        check("nothing claims to be an unimplemented check that passed",
              not any(("V3" in c or "V4" in c) and "ok" in c for c in checks))

sys.exit(1 if fail else 0)
PY
rc=$?
[ $rc -eq 0 ] && echo "provenance cross-check passed" || echo "provenance cross-check FAILED"
exit $rc