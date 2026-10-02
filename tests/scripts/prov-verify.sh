#!/bin/sh
# `zyl verify`: the three trust modes, the two halves of the report, and every
# way a trailer can stop being true.
#
# prov-sign.sh proves a signed build is the unsigned one plus a trailer. This
# script takes that binary and asks the verifier about it -- then changes one
# thing at a time and requires the verdict to change with it. The order
# matters: the YES cases come first, because a verifier that refuses
# everything passes every refusal test, and that is exactly how the first
# record reader shipped with an inverted bounds check.
#
# What is required of the report, beyond the exit status:
#
#   - EVIDENCE and ATTESTATION are separate lines. A single PASS is the
#     failure mode the design exists to prevent.
#   - The trust mode is NAMED, and the verdict word is the mode's: VERIFIED
#     only for a pinned key, ATTESTED for a supplied one, SELF-ASSERTED for
#     the record's own kid. Never a stronger word for a weaker check.
#   - The census is reported as attested, in that word, because it is not
#     re-derived from the image.
set -e
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export ZYL_HOME="$PWD/build/boot"
ZYL="$PWD/build/boot/zyl-self"
[ -x "$ZYL" ] || { echo "prov-verify.sh: no compiler at $ZYL -- run ./boot.sh first"; exit 1; }

WORK=$(mktemp -d)
BUNDLE="$PWD/build/boot"
PKG="$BUNDLE/provverify"
PIN="$BUNDLE/keys/acme_provverify"
trap 'rm -rf "$WORK" "$PKG" "$PIN"' EXIT

# RFC 8032 test vector 1 and its public key; a second key that signed nothing.
echo 9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60 > "$WORK/key.seed"
PUB=d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a
echo "ed25519:$PUB" > "$WORK/key.pub"
OTHER=1111111111111111111111111111111111111111111111111111111111111111

fails=0
pass() { echo "ok   -- $1"; }
fail() { echo "FAIL -- $1"; fails=$((fails+1)); }

# Run the verifier, keep its output and exit status.
verify() {
  rc=0
  "$ZYL" verify "$@" >"$WORK/out" 2>&1 || rc=$?
}
expect_rc() { [ "$rc" -eq "$1" ] && pass "$2 (exit $rc)" || { fail "$2 (exit $rc, wanted $1)"; sed 's/^/     /' "$WORK/out"; }; }
expect_line() { grep -q -- "$1" "$WORK/out" && pass "$2" || { fail "$2: no line matching '$1'"; sed 's/^/     /' "$WORK/out"; }; }
expect_no_line() { grep -q -- "$1" "$WORK/out" && { fail "$2: found '$1'"; sed 's/^/     /' "$WORK/out"; } || pass "$2"; }

# A signed package build, as prov-sign.sh makes one. `zyl new` writes into the
# bundle directory (the driver chdirs there), hence PKG under build/boot.
( cd "$BUNDLE" && rm -rf provverify && "$ZYL" new acme/provverify ) >/dev/null 2>&1 || {
  echo "FAIL -- could not create a package"; exit 1; }
( cd "$PKG" && "$ZYL" build --sign-with "$WORK/key.seed" ) >"$WORK/build.log" 2>&1 || {
  echo "FAIL -- the signed build did not succeed"; cat "$WORK/build.log"; exit 1; }
BIN="$PKG/provverify"
[ -f "$BIN" ] || { echo "FAIL -- no binary"; exit 1; }
[ -f "$BIN.buildinfo" ] || { echo "FAIL -- no buildinfo beside the binary"; exit 1; }
cp "$BIN" "$WORK/good"; cp "$BIN.buildinfo" "$WORK/good.buildinfo"

# --- the yes cases -----------------------------------------------------------

verify "$BIN"
expect_rc 0 "a signed binary verifies with no key given"
expect_line "^VERDICT *SELF-ASSERTED" "the verdict for the record's own kid is SELF-ASSERTED"
expect_line "trust: self-asserted" "the trust mode is named"
expect_line "^EVIDENCE *binary-hash .*matches the record" "binary-hash is re-derived and matches"
expect_line "^ATTESTATION *COSE_Sign1 valid under kid ed25519:$PUB" "the attestation names the kid"
expect_line "compiler-hash .*the same compiler" "the compiler that built it is the one verifying"
expect_line "buildinfo .*all six hashes agree.*final-hash recomputes" "the buildinfo beside the binary agrees, final-hash included"
expect_line "census *attested, not re-derived" "the census is reported as attested, in that word"
expect_line "V3 provenance and bounds: not implemented" "the unimplemented checks are named as absent"
expect_no_line "VERIFIED" "SELF-ASSERTED is never reported as VERIFIED"

verify "$BIN" --key "$PUB"
expect_rc 0 "a supplied key verifies"
expect_line "^VERDICT *ATTESTED" "the verdict for a supplied key is ATTESTED"
expect_line "trust: supplied" "the supplied mode is named"
expect_no_line "VERIFIED" "ATTESTED is never reported as VERIFIED"

verify "$BIN" --key "$WORK/key.pub"
expect_rc 0 "a supplied key may be a file, with the ed25519: prefix"
expect_line "^VERDICT *ATTESTED" "and it is still ATTESTED"

# The pinned key: what `zyl fetch` writes on first use (§31.8).
mkdir -p "$BUNDLE/keys"; echo "ed25519:$PUB" > "$PIN"
verify "$BIN" --package acme/provverify --anchored
expect_rc 0 "the key pinned for the package verifies under --anchored"
expect_line "^VERDICT *VERIFIED" "and only then is the verdict VERIFIED"
expect_line "trust: anchored -- the key pinned for package acme/provverify" "the anchored mode names the package"
rm -f "$PIN"

# --- the no cases ------------------------------------------------------------

verify "$BIN" --key "$OTHER"
expect_rc 1 "a key that did not sign it fails"
expect_line "^ATTESTATION *COSE_Sign1 does NOT verify under ed25519:$OTHER" "and the attestation line says so"
expect_line "^VERDICT *FAILED" "verdict FAILED"
expect_line "binary-hash .*matches the record" "while the evidence half still reports on its own"

verify "$BIN" --anchored
expect_rc 1 "--anchored with no pinned key fails"
expect_line "anchored was given and the key is not one pinned" "and says why"

verify "$BIN" --package acme/provverify
expect_rc 1 "--package with nothing pinned is an error, not a weaker mode"
expect_line "no key is pinned for package acme/provverify" "and it says where it looked"

# One byte of the image changed, after signing.
cp "$WORK/good" "$WORK/tampered"; cp "$WORK/good.buildinfo" "$WORK/tampered.buildinfo"
printf '\377' | dd of="$WORK/tampered" bs=1 seek=4096 conv=notrunc 2>/dev/null
verify "$WORK/tampered"
expect_rc 1 "a changed image fails"
expect_line "binary-hash .*DIFFERS from the record" "binary-hash is the line that differs"
expect_line "^VERDICT *FAILED" "verdict FAILED for a changed image"

# The trailer truncated by one byte, and extended by one.
head -c -1 "$WORK/good" > "$WORK/short"
verify "$WORK/short"
expect_rc 1 "a truncated trailer fails"
expect_line "truncated or extended" "and is named as such"
cp "$WORK/good" "$WORK/long"; printf 'x' >> "$WORK/long"
verify "$WORK/long"
expect_rc 1 "an extended file fails"

# The buildinfo beside the binary disagreeing with the record.
cp "$WORK/good" "$WORK/stale"; sed 's/(icnf-hash "blake3:\(.\)/(icnf-hash "blake3:0/' "$WORK/good.buildinfo" > "$WORK/stale.buildinfo"
cmp -s "$WORK/good.buildinfo" "$WORK/stale.buildinfo" && sed -i 's/(icnf-hash "blake3:0/(icnf-hash "blake3:1/' "$WORK/stale.buildinfo"
verify "$WORK/stale"
expect_rc 1 "a buildinfo that disagrees with the record fails"
expect_line "buildinfo .*DISAGREES with the record on: icnf-hash" "and names the field"
expect_line "final-hash recomputed from the four inputs" "and the recomputed final-hash disagrees with it too"

# No buildinfo at all: weaker, said so, not a failure.
cp "$WORK/good" "$WORK/alone"
verify "$WORK/alone"
expect_rc 0 "a binary with no buildinfo beside it still verifies"
expect_line "buildinfo *no .*attested only" "and the fields it would have checked are called attested"

# An unsigned binary.
( cd "$PKG" && ZYL_NO_BUILD_CACHE=1 "$ZYL" build ) >/dev/null 2>&1
verify "$BIN"
expect_rc 1 "an unsigned binary does not verify"
expect_line "^TRAILER *none" "and the report says there is no trailer"
expect_line "^VERDICT *UNSIGNED" "verdict UNSIGNED, which is not FAILED and not a pass"

[ "$fails" -eq 0 ] && echo "zyl verify checks passed" || echo "zyl verify checks FAILED ($fails)"
exit $fails
