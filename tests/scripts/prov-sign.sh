#!/bin/sh
# `zyl build --sign-with`: the signed build, and the unsigned one it must not
# disturb.
#
# Three things here are easy to get wrong and hard to notice:
#
#   - An unsigned build must stay BYTE-IDENTICAL. This is the project's first
#     non-negotiable (spec 27), and the fixed point is a committed seed: a
#     feature that appended a trailer unconditionally would change every binary
#     in the tree and break every determinism test with it.
#   - A signed build must be the unsigned one plus a trailer, prefix included.
#     Anything else means the image moved, and the record's binary-hash -- taken
#     over [0, T-16) -- would be describing bytes that are not there.
#   - The cache must not serve one for the other. The cache is keyed on sources
#     and the trailer is not a function of the sources.
#
# The trailer's own format is checked by provenance-trailer.sh against cbor2 and
# `cryptography`. This script checks the BUILD PATH, which is the part that has
# no independent reader: that the flag reaches the linker, that the bytes it
# produces are the bytes the design says, and that not passing it changes
# nothing.
set -e
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export ZYL_HOME="$PWD/build/boot"
ZYL="$PWD/build/boot/zyl-self"
[ -x "$ZYL" ] || { echo "prov-sign.sh: no compiler at $ZYL -- run ./boot.sh first"; exit 1; }

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# RFC 8032 test vector 1, the key every other provenance test signs with.
echo 9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60 > "$WORK/key.seed"

# `zyl new` writes into the BUNDLE directory, not the caller's: the driver
# chdirs to argv[0]'s directory so that `(use module/name)` resolves against the
# compiler's own stdlib. So the package is created beside the compiler being
# tested, which for ZYL_HOME=$PWD/build/boot is build/boot/provsign. Getting
# this wrong is a silent "no package" rather than an error, and it drops a
# directory into the repository root -- which is exactly what it did the first
# time this ran.
BUNDLE="$PWD/build/boot"
PKG="$BUNDLE/provsign"
( cd "$BUNDLE" && rm -rf provsign && "$ZYL" new acme/provsign ) >/dev/null 2>&1 || {
  echo "FAIL -- could not create a package"; exit 1; }
[ -d "$PKG" ] || { echo "FAIL -- no package at $PKG"; exit 1; }
trap 'rm -rf "$PKG" "$WORK"' EXIT

# An unsigned build first: it is the reference the signed one must extend.
( cd "$PKG" && ZYL_NO_BUILD_CACHE=1 "$ZYL" build ) >/dev/null 2>&1 || {
  echo "FAIL -- the unsigned build did not succeed"; exit 1; }
[ -f "$PKG/provsign" ] || { echo "FAIL -- no binary from the unsigned build"; exit 1; }
cp "$PKG/provsign" "$WORK/unsigned"

# Two unsigned builds, byte for byte.
( cd "$PKG" && ZYL_NO_BUILD_CACHE=1 "$ZYL" build ) >/dev/null 2>&1
if cmp -s "$PKG/provsign" "$WORK/unsigned"; then
  echo "ok   -- two unsigned builds are byte-identical"
else
  echo "FAIL -- two unsigned builds differ"
fi

# Now the signed one, with the cache ON, to prove the cache does not serve the
# unsigned binary to a signing build.
( cd "$PKG" && "$ZYL" build --sign-with "$WORK/key.seed" ) >"$WORK/sign.log" 2>&1 || {
  echo "FAIL -- the signed build did not succeed"; cat "$WORK/sign.log"; exit 1; }
cp "$PKG/provsign" "$WORK/signed"

grep -q "trailer attached" "$WORK/sign.log" \
  && echo "ok   -- the build reports that it signed" \
  || echo "FAIL -- the build said nothing about signing"

PROV_SIGN="$WORK" python3 <<'PY'
import os, struct, sys

W = os.environ["PROV_SIGN"]
u = open(os.path.join(W, "unsigned"), "rb").read()
s = open(os.path.join(W, "signed"), "rb").read()

fails = []


def check(name, ok, detail=""):
    print(("ok   -- " if ok else "FAIL -- ") + name + (("  " + detail) if detail else ""))
    if not ok:
        fails.append(name)


check("the signed build is longer", len(s) > len(u), "%d vs %d" % (len(u), len(s)))
check("the signed build is the unsigned one plus a trailer", s[:len(u)] == u,
      "the first %d bytes %s" % (len(u), "match" if s[:len(u)] == u else "DIFFER"))
check("the image was not merely extended at the end", len(u) % 1 == 0)

at = len(u)
check("the magic is exactly where the image ends", s[at:at + 8] == b"ZYLPROV\0",
      repr(s[at:at + 8]))

fmt, clen = struct.unpack_from("<IQ", s, at + 8)
check("the format version is 1", fmt == 1, str(fmt))
check("the blob length accounts for every byte after the magic",
      len(s) == at + 20 + clen, "%d vs %d" % (len(s), at + 20 + clen))
check("the trailer is a small fraction of the binary", clen < len(u),
      "%d of %d" % (clen, len(u)))

sys.exit(1 if fails else 0)
PY
rc=$?
[ $rc -eq 0 ] && echo "signed build checks passed" || echo "signed build checks FAILED"
exit $rc