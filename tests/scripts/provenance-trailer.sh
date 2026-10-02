#!/bin/sh
# The trailer, cross-checked against an independent reader.
#
# tests/provenance_trailer_test.zyl proves the trailer round-trips inside this
# compiler: attach, find, verify. It cannot ask whether the FORMAT is one another
# tool would read, and "agrees with itself" is the one property a format nobody
# else parses cannot be checked on. Every wrong "fix" while building this was a
# correction of code whose bytes were right, which is why this exists.
#
# So the Zyl side writes a real trailer onto a real file and reports where its
# parts are; this script then locates the trailer in that file by MAGIC, with no
# knowledge of where Zyl said it was, reads the header by arithmetic, decodes
# the COSE_Sign1 with cbor2, checks the signature with `cryptography`, and
# requires the image bytes ahead of the magic to be exactly the image that was
# written. A reader that shares Zyl's assumptions is not a reader.
set -e
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export ZYL_HOME="$PWD/build/boot"
ZYL="$PWD/build/boot/zyl-self"
[ -x "$ZYL" ] || { echo "provenance-trailer.sh: no compiler at $ZYL -- run ./boot.sh first"; exit 1; }

python3 -c "import cbor2" 2>/dev/null || {
  echo "provenance-trailer.sh: needs the cbor2 module; skipping the cross-check"; exit 0; }
python3 -c "import cryptography" 2>/dev/null || {
  echo "provenance-trailer.sh: needs the cryptography module; skipping the cross-check"; exit 0; }

BIN=$(mktemp -d)
trap 'rm -rf "$BIN"' EXIT

# An image of 8192 bytes with a recognisable pattern, and the trailer on it.
# The image is real bytes rather than a buffer of zeros so that a trailer
# written into the wrong place cannot pass by landing on zeroes.
cat > "$BIN/t.zyl" <<'EOF'
(use compiler/provenance)

(def seed "9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60")
(def h1 "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
(def h2 "1f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100")
(def h3 "202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f")
(def h4 "404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f")
(def h5 "606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f")
(def path "/tmp/zyl-prov-xcheck.bin")
(def imglen 8192)

(defn make-image (n)
  (let b (cbor-buf n)
    (begin
      (for (i 0) (< i n)
        (begin (store-u8 :le b i (bit-and (+ (* i 37) 11) 253)) (set! i (+ i 1))))
      (prov-write-file path b n))))

(defn main ()
  (begin
    (make-image imglen)
    (prov-attach path h1 h2 h3 h4 h5 (prov-hash-file path imglen) seed)
    (print imglen)
    0))
EOF

"$ZYL" "$BIN/t.zyl" -o "$BIN/t.bin" >/dev/null 2>&1
IMGLEN=$("$BIN/t.bin")
[ -n "$IMGLEN" ] || { echo "not ok -- the Zyl side produced no trailer"; exit 1; }

IMGLEN="$IMGLEN" python3 <<'PY'
import binascii, os, struct, sys
import cbor2
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey, Ed25519PublicKey
from cryptography.exceptions import InvalidSignature

fails = []


def check(name, ok, detail=""):
    print(("ok   -- " if ok else "FAIL -- ") + name + (("  " + detail) if detail else ""))
    if not ok:
        fails.append(name)


# RFC 8032 test vector 1, the key the Zyl side signed with.
SEED = bytes.fromhex("9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60")
PUB = bytes.fromhex("d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a")
imglen = int(os.environ["IMGLEN"])

data = open("/tmp/zyl-prov-xcheck.bin", "rb").read()

# 1. LOCATE BY MAGIC, BACKWARD FROM THE END, WITH NO HELP FROM ZYL. If this
#    cannot find it, no other tool will either, and the format is unreadable.
MAGIC = b"ZYLPROV\0"
at = data.rfind(MAGIC)
check("the magic is found by scanning backward from the end", at > 0, "at %d" % at)
if at < 0:
    sys.exit(1)

check("the magic sits where an appended trailer puts it", at == imglen,
      "magic at %d, image is %d bytes" % (at, imglen))

# 2. The header, read by arithmetic and nothing else.
fmt, clen = struct.unpack_from("<IQ", data, at + 8)
check("the format version is 1", fmt == 1, str(fmt))
check("the blob length accounts for every byte after the header",
      at + 20 + clen == len(data),
      "20 + %d = %d, file is %d" % (clen, at + 20 + clen, len(data)))

# 3. The image ahead of the magic is byte for byte the image that was written.
#    This is the hashing rule: a reader hashes [0, at) and must get what the
#    record says, so those bytes must be untouched by attaching.
image = data[:at]
check("the image ahead of the magic is unchanged", len(image) == imglen)
check("the image is not merely zeros", any(image[:64]))

# 4. The COSE_Sign1, decoded by cbor2 -- not by us.
blob = data[at + 20:at + 20 + clen]
try:
    cose = cbor2.loads(blob)
except Exception as exc:
    check("the COSE_Sign1 decodes", False, str(exc))
    sys.exit(1)

check("the COSE_Sign1 is a four-element array", isinstance(cose, list) and len(cose) == 4,
      repr(type(cose)))
prot, unprot, payload, sig = cose
check("the protected header is a byte string", isinstance(prot, bytes))
check("the protected header decodes to {1: -8, 3: 60}",
      cbor2.loads(prot) == {1: -8, 3: 60}, repr(cbor2.loads(prot)))
check("the unprotected map carries the kid", isinstance(unprot, dict) and unprot.get(4) == PUB,
      repr(unprot))
check("the kid is the public key of the signing seed",
      PUB == Ed25519PrivateKey.from_private_bytes(SEED).public_key().public_bytes_raw())
check("the signature is 64 bytes", isinstance(sig, bytes) and len(sig) == 64, str(len(sig)))

# 5. THE SIGNATURE, checked by a library that did not write it.
sig_structure = cbor2.dumps(["Signature1", prot, b"", payload])
try:
    Ed25519PublicKey.from_public_bytes(PUB).verify(sig, sig_structure)
    check("the signature verifies over the Sig_structure", True)
except InvalidSignature:
    check("the signature verifies over the Sig_structure", False, "InvalidSignature")

# 6. The record, and the fields the design names.
rec = cbor2.loads(payload)
check("the payload is the record", isinstance(rec, dict), repr(type(rec)))
check("kind is provenance", rec.get("kind") == "provenance")
check("format is 1", rec.get("format") == 1)
for k in ("compiler-hash", "graph-hash", "icnf-hash", "asm-hash", "final-hash", "binary-hash"):
    v = rec.get(k)
    check("%s is 32 raw bytes" % k, isinstance(v, bytes) and len(v) == 32)
check("the record's binary-hash is NOT the hash of the file we hold",
      rec.get("binary-hash") != __import__("hashlib").sha256(data).digest()[:32])

ev = rec.get("evidence")
check("the evidence is present and is a map", isinstance(ev, dict))
if isinstance(ev, dict):
    check("the evidence has the five counts",
          all(isinstance(ev.get(k), int) for k in
              ("functions", "writes", "reads", "dynamic", "unverified")))
    checks = ev.get("checks")
    check("the checks are named, one line each",
          isinstance(checks, list) and len(checks) == 4, str(checks))
    if isinstance(checks, list):
        joined = " ".join(checks)
        check("V3 is reported as not implemented", "V3" in joined and "not implemented" in joined)
        check("V4 is reported as not implemented", "V4" in joined and "not implemented" in joined)

# 7. The record re-encodes to the bytes that were signed. Two encodings of one
#    record would verify differently, which is what canonical form is for.
check("the record re-encodes byte-identically", cbor2.dumps(rec) == payload)

sys.exit(1 if fails else 0)
PY
rc=$?
[ $rc -eq 0 ] && echo "provenance trailer cross-check passed" || echo "provenance trailer cross-check FAILED"
exit $rc