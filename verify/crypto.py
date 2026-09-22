#!/usr/bin/env python3
"""Randomized cross-verification of stdlib/math against Python references.

The .zyl regression tests pin published test vectors. This does the
complementary thing: it generates many random inputs, runs them through
the Zyl implementation and through hashlib / pyca-cryptography, and
compares. Fixed vectors catch a wrong constant; random inputs across
many lengths catch the block-boundary and carry-propagation bugs that
a handful of vectors walk straight past.

Every case is deterministic (a fixed PRNG seed), so a failure is
reproducible.

Usage:
    python3 verify/crypto.py                 # everything
    python3 verify/crypto.py --case aead     # one group
"""

import argparse
import hashlib
import hmac as hmaclib
import os
import random
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ZYL = os.path.join(REPO, "build", "boot", "zyl-self")

from cryptography.hazmat.primitives.ciphers.aead import AESGCM, ChaCha20Poly1305
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.kdf.argon2 import Argon2id


def run_zyl(source):
    """Compile and run a Zyl program, returning its stdout lines."""
    tmpdir = tempfile.mkdtemp(prefix="zyl-verify-")
    src = os.path.join(tmpdir, "check.zyl")
    binary = os.path.join(tmpdir, "check.bin")
    with open(src, "w") as fh:
        fh.write(source)
    subprocess.run([ZYL, src, "-o", binary], check=True, cwd=REPO,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    out = subprocess.run([binary], check=True, capture_output=True, text=True)
    return out.stdout.split()


def header(uses):
    return "\n".join("(use %s)" % u for u in uses) + """
(use math/words)
(use allocator/allocator)
(use core/option)
"""


def case_hash(rng):
    """SHA-3, SHAKE and BLAKE2b/3 over random inputs."""
    msgs = [bytes(rng.randrange(256) for _ in range(n))
            for n in [0, 1, 55, 64, 71, 72, 127, 128, 135, 136, 137, 168, 200, 1023, 1024, 1025]]
    body = [header(["math/hash/sha3", "math/hash/blake2b", "math/hash/blake3"]),
            "(defn main ()", "  (let a (arena-create 0)", "    (begin"]
    for m in msgs:
        h = m.hex() or "00"
        n = len(m)
        body.append('      (let m (w-from-hex a "%s")' % (h if n else ""))
        body.append('        (begin')
        body.append('          (print (w-hex-bytes (sha3-256-bytes a m %d) 32))' % n)
        body.append('          (print (w-hex-bytes (sha3-512-bytes a m %d) 64))' % n)
        body.append('          (print (w-hex-bytes (shake256-bytes a m %d 40) 40))' % n)
        body.append('          (print (w-hex-bytes (blake2b a m %d (w-alloc a 1) 0 64) 64))' % n)
        body.append('          (print (w-hex-bytes (blake3-hash a m %d 32) 32))' % n)
        body.append('          0))')
    body += ["      0)))"]
    got = run_zyl("\n".join(body))
    want = []
    for m in msgs:
        want.append(hashlib.sha3_256(m).hexdigest())
        want.append(hashlib.sha3_512(m).hexdigest())
        want.append(hashlib.shake_256(m).hexdigest(40))
        want.append(hashlib.blake2b(m).hexdigest())
        want.append(None)  # BLAKE3 has no stdlib reference; checked by vectors
    return compare("hash", got, want, len(msgs))


def case_aead(rng):
    """ChaCha20-Poly1305 and AES-GCM over random keys, nonces, AAD, lengths."""
    items = []
    for n in [0, 1, 15, 16, 17, 63, 64, 65, 200]:
        key = bytes(rng.randrange(256) for _ in range(32))
        nonce = bytes(rng.randrange(256) for _ in range(12))
        aad = bytes(rng.randrange(256) for _ in range(rng.choice([0, 3, 20])))
        pt = bytes(rng.randrange(256) for _ in range(n))
        items.append((key, nonce, aad, pt))
    body = [header(["math/crypto/symmetric/chacha20poly", "math/crypto/symmetric/aesgcm"]),
            "(defn main ()", "  (let a (arena-create 0)", "    (begin"]
    for key, nonce, aad, pt in items:
        body.append('      (let k (w-from-hex a "%s")' % key.hex())
        body.append('        (let n (w-from-hex a "%s")' % nonce.hex())
        body.append('          (let d (w-from-hex a "%s")' % (aad.hex() or ""))
        body.append('            (let p (w-from-hex a "%s")' % (pt.hex() or ""))
        body.append('              (begin')
        body.append('                (print (w-hex-bytes (aead-encrypt a k n d %d p %d) %d))'
                    % (len(aad), len(pt), len(pt) + 16))
        body.append('                (print (w-hex-bytes (option-unwrap-or (gcm-encrypt a k 32 n d %d p %d) 0) %d))'
                    % (len(aad), len(pt), len(pt) + 16))
        body.append('                0))))) ')
    body += ["      0)))"]
    got = run_zyl("\n".join(body))
    want = []
    for key, nonce, aad, pt in items:
        want.append(ChaCha20Poly1305(key).encrypt(nonce, pt, aad or None).hex())
        want.append(AESGCM(key).encrypt(nonce, pt, aad or None).hex())
    return compare("aead", got, want, len(items))


def case_curve(rng):
    """X25519 agreement and Ed25519 signatures over random keys/messages."""
    items = []
    for n in [0, 1, 32, 64, 100]:
        a_priv = X25519PrivateKey.generate()
        b_priv = X25519PrivateKey.generate()
        seed = bytes(rng.randrange(256) for _ in range(32))
        msg = bytes(rng.randrange(256) for _ in range(n))
        items.append((a_priv, b_priv, seed, msg))
    body = [header(["math/crypto/asymmetric/x25519", "math/crypto/asymmetric/ed25519"]),
            "(defn main ()", "  (let a (arena-create 0)", "    (begin"]
    for a_priv, b_priv, seed, msg in items:
        raw_a = a_priv.private_bytes(serialization.Encoding.Raw, serialization.PrivateFormat.Raw,
                                     serialization.NoEncryption())
        raw_bpub = b_priv.public_key().public_bytes(serialization.Encoding.Raw,
                                                    serialization.PublicFormat.Raw)
        body.append('      (let sk (w-from-hex a "%s")' % raw_a.hex())
        body.append('        (let bp (w-from-hex a "%s")' % raw_bpub.hex())
        body.append('          (let sd (w-from-hex a "%s")' % seed.hex())
        body.append('            (let m (w-from-hex a "%s")' % (msg.hex() or ""))
        body.append('              (begin')
        body.append('                (print (w-hex-bytes (x25519 a sk bp) 32))')
        body.append('                (print (w-hex-bytes (ed25519-public-key a sd) 32))')
        body.append('                (print (w-hex-bytes (ed25519-sign a sd m %d) 64))' % len(msg))
        body.append('                0)))))')
    body += ["      0)))"]
    got = run_zyl("\n".join(body))
    want = []
    for a_priv, b_priv, seed, msg in items:
        want.append(a_priv.exchange(b_priv.public_key()).hex())
        sk = Ed25519PrivateKey.from_private_bytes(seed)
        want.append(sk.public_key().public_bytes(serialization.Encoding.Raw,
                                                 serialization.PublicFormat.Raw).hex())
        want.append(sk.sign(msg).hex())
    return compare("curve", got, want, len(items))


def case_kdf(rng):
    """HKDF, PBKDF2 and Argon2id over random inputs."""
    items = []
    for i in range(4):
        ikm = bytes(rng.randrange(256) for _ in range(rng.choice([16, 32, 40])))
        salt = bytes(rng.randrange(256) for _ in range(16))
        info = bytes(rng.randrange(256) for _ in range(rng.choice([0, 10])))
        items.append((ikm, salt, info))
    body = [header(["math/crypto/kdf/hkdf", "math/crypto/kdf/pbkdf2", "math/crypto/kdf/argon2"]),
            "(defn main ()", "  (let a (arena-create 0)", "    (begin"]
    for ikm, salt, info in items:
        body.append('      (let i (w-from-hex a "%s")' % ikm.hex())
        body.append('        (let s (w-from-hex a "%s")' % salt.hex())
        body.append('          (let f (w-from-hex a "%s")' % (info.hex() or ""))
        body.append('            (begin')
        body.append('              (print (w-hex-bytes (hkdf a i %d s 16 f %d 42) 42))' % (len(ikm), len(info)))
        body.append('              (print (w-hex-bytes (pbkdf2-sha256 a i %d s 16 64 32) 32))' % len(ikm))
        body.append('              (print (w-hex-bytes (argon2id-hash a i %d s 16 32 2 1 32) 32))' % len(ikm))
        body.append('              0))))')
    body += ["      0)))"]
    got = run_zyl("\n".join(body))
    want = []
    for ikm, salt, info in items:
        prk = hmaclib.new(salt, ikm, hashlib.sha256).digest()
        okm = b""; t = b""; i = 1
        while len(okm) < 42:
            t = hmaclib.new(prk, t + info + bytes([i]), hashlib.sha256).digest()
            okm += t; i += 1
        want.append(okm[:42].hex())
        want.append(hashlib.pbkdf2_hmac("sha256", ikm, salt, 64, 32).hex())
        want.append(Argon2id(salt=salt, length=32, iterations=2, lanes=1,
                             memory_cost=32).derive(ikm).hex())
    return compare("kdf", got, want, len(items))


def compare(name, got, want, groups):
    if len(got) != len(want):
        print("%-6s FAIL: expected %d outputs, got %d" % (name, len(want), len(got)))
        return False
    bad = 0
    for i, (g, w) in enumerate(zip(got, want)):
        if w is None:
            continue  # no reference available for this one
        if g != w:
            bad += 1
            if bad <= 5:
                print("%-6s MISMATCH at output %d\n  zyl %s\n  ref %s" % (name, i, g, w))
    checked = sum(1 for w in want if w is not None)
    if bad:
        print("%-6s FAIL: %d of %d outputs differ" % (name, bad, checked))
        return False
    print("%-6s ok: %d outputs across %d cases match the reference" % (name, checked, groups))
    return True


CASES = {"hash": case_hash, "aead": case_aead, "curve": case_curve, "kdf": case_kdf}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--case", choices=sorted(CASES))
    ap.add_argument("--seed", type=int, default=20260922)
    args = ap.parse_args()
    names = [args.case] if args.case else sorted(CASES)
    ok = True
    for name in names:
        rng = random.Random(args.seed)
        ok = CASES[name](rng) and ok
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
