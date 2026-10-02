#!/bin/sh
# COSE_Sign1, cross-checked against an independent implementation.
#
# The Zyl tests in tests/cose_test.zyl pin the bytes this compiler emits. They
# cannot tell whether those bytes are RIGHT -- only whether they are stable,
# which a wrong constant is equally good at. This script asks cbor2 and
# `cryptography` whether the same bytes are a conformant COSE_Sign1 carrying a
# signature that verifies, so a constant written from memory fails here.
#
# It reads a dump from the Zyl side, which is why the Zyl tests assert against
# literals: both sides derive from the same RFC, and neither is trusted alone.
set -e
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export ZYL_HOME="$PWD/build/boot"
ZYL="$PWD/build/boot/zyl-self"
[ -x "$ZYL" ] || { echo "cose.sh: no compiler at $ZYL -- run ./boot.sh first"; exit 1; }

python3 -c "import cbor2" 2>/dev/null || {
  echo "cose.sh: needs the cbor2 module; skipping the cross-check"; exit 0; }
python3 -c "import cryptography" 2>/dev/null || {
  echo "cose.sh: needs the cryptography module; skipping the cross-check"; exit 0; }

DUMP=$(mktemp); BIN=$(mktemp -d)
trap 'rm -f "$DUMP"; rm -rf "$BIN"' EXIT

cat > "$BIN/dump.zyl" <<'EOF'
(use encoding/cose)
(use encoding/cbor)

(def hexdigits "0123456789abcdef")

(defn byte-hex (v)
  (str-concat (str-substring hexdigits (/ v 16) 1) (str-substring hexdigits (bit-and v 15) 1)))

(defn bytes-hex ((b ByteBuf) (n Int) (i Int) (acc String))
  (if (>= i n)
    acc
    (bytes-hex b n (+ i 1) (str-concat acc (byte-hex (load-u8 :le b i))))))

(defn sig-hex (payload plen)
  (let prot (cose-protected)
    (let ss (cose-sig-structure (match prot (CB pb pu pb)) 0 payload 0 plen)
      (let ssb (match ss (CB sbuf sused sbuf))
        (bytes-hex ssb (match ss (CB _ u u)) 0 "")))))

(defn cose-hex (seedhex payload plen)
  (let out (cose-sign seedhex payload plen)
    (let cob (match out (CoseOut cbuf cused cbuf))
      (bytes-hex cob (match out (CoseOut _ u3 u3)) 0 ""))))

(defn payload-of (a b)
  (let p (cbor-buf 2)
    (begin (store-u8 :le p 0 a) (store-u8 :le p 1 b) p)))

(def seed1 "9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60")

(defn main ()
  (begin
    (print (str-concat "SIG0 " (sig-hex (payload-of 65 0) 0)))
    (print (str-concat "SIG2 " (sig-hex (payload-of 65 66) 2)))
    (print (str-concat "COSE " (cose-hex seed1 (payload-of 65 66) 2)))
    0))

(main)
(numeric checked)
EOF

"$ZYL" "$BIN/dump.zyl" -o "$BIN/dump.bin" >/dev/null 2>&1
"$BIN/dump.bin" > "$DUMP"

ZYL_SIG0=$(sed -n 's/^SIG0 //p' "$DUMP")
ZYL_SIG2=$(sed -n 's/^SIG2 //p' "$DUMP")
ZYL_COSE=$(sed -n 's/^COSE //p' "$DUMP")

[ -n "$ZYL_SIG0" ] && [ -n "$ZYL_SIG2" ] && [ -n "$ZYL_COSE" ] || {
  echo "not ok -- the Zyl side produced no dump"; exit 1; }

ZYL_SIG0="$ZYL_SIG0" ZYL_SIG2="$ZYL_SIG2" ZYL_COSE="$ZYL_COSE" python3 <<'PY'
import binascii, os, sys
import cbor2
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey

fail = []

def check(name, ok, detail=""):
    print(("ok   -- " if ok else "FAIL -- ") + name + (("  " + detail) if detail else ""))
    if not ok:
        fail.append(name)

prot = binascii.unhexlify("a2012703183c")

# 1. The protected header is {1: -8, 3: 60}: Ed25519, application/cbor.
hdr = cbor2.loads(prot)
check("the protected header is {1: -8, 3: 60}", hdr == {1: -8, 3: 60}, repr(hdr))
check("3 is 60 = application/cbor", hdr.get(3) == 60)

# 2. Both Sig_structures are what cbor2 builds for the same input. "Signature1"
#    is a TEXT string per RFC 9052 section 4.4 -- cbor2 encodes a str as one,
#    which is the whole reason this check is not vacuous.
for label, payload_len, got in (("SIG0", 0, os.environ["ZYL_SIG0"]),
                                ("SIG2", 2, os.environ["ZYL_SIG2"])):
    want = cbor2.dumps(["Signature1", prot, b"", b"AB"[:payload_len]])
    check("the %s Sig_structure matches cbor2" % label,
          binascii.hexlify(want).decode() == got,
          "" if binascii.hexlify(want).decode() == got else
          "want " + binascii.hexlify(want).decode() + " got " + got)
    dec = cbor2.loads(binascii.unhexlify(got))
    check("the %s Sig_structure decodes to 4 elements" % label, len(dec) == 4)
    check("the %s context string is Signature1" % label, dec[0] == "Signature1", repr(dec[0]))
    check("the %s external_aad is empty" % label, dec[2] == b"")

# 3. The COSE_Sign1 is a four-element array and the signature verifies.
cose = binascii.unhexlify(os.environ["ZYL_COSE"])
arr = cbor2.loads(cose)
check("the COSE_Sign1 is a four-element array", isinstance(arr, list) and len(arr) == 4)
prot_b, unprot, payload, sig = arr
check("the protected bstr is our header", prot_b == prot)
check("the unprotected map carries kid (4)", 4 in unprot)
check("the kid is 32 bytes", len(unprot.get(4, b"")) == 32)
check("the signature is 64 bytes", len(sig) == 64)

# 4. THE load-bearing check: an independent verifier accepts the signature over
#    an independently rebuilt Sig_structure.
struct = cbor2.dumps(["Signature1", prot_b, b"", payload])
try:
    Ed25519PublicKey.from_public_bytes(unprot[4]).verify(sig, struct)
    check("Ed25519 verifies over the independently rebuilt Sig_structure", True)
except Exception as exc:
    check("Ed25519 verifies over the independently rebuilt Sig_structure", False, repr(exc))

# 5. Determinism: re-encoding the decoded value reproduces our bytes exactly.
#    Two encodings of one record would verify differently, which is the whole
#    reason this encoder is canonical-only.
check("the COSE_Sign1 re-encodes byte-identically", cbor2.dumps(arr) == cose)

sys.exit(1 if fail else 0)
PY
rc=$?
[ $rc -eq 0 ] && echo "cose cross-check passed" || echo "cose cross-check FAILED"
exit $rc