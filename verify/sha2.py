#!/usr/bin/env python3
"""Cross-verify Zyl's SHA-256/SHA-512 against Python's hashlib.

Generates a Zyl program that hashes a deterministic corpus of inputs,
compiles it with the self-hosted compiler, runs it, and compares each
printed digest against hashlib's. Inputs cover every length from 0 to
200 bytes (so every padding and block boundary is crossed) plus a few
longer ones.

Usage:  python3 verify/sha2.py [--zyl build/boot/zyl-self]

Exit status is 0 only if every digest matches.
"""

import argparse
import hashlib
import os
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def corpus():
    """Deterministic inputs: every length 0..200, then a few longer."""
    out = []
    for n in range(0, 201):
        # A repeating, non-uniform pattern so a byte-order bug cannot
        # cancel out the way it can with a single repeated character.
        out.append("".join(chr(97 + (i * 7 + n) % 26) for i in range(n)))
    for n in (255, 256, 257, 511, 512, 1000):
        out.append("".join(chr(97 + (i * 13) % 26) for i in range(n)))
    return out


def gen_program(messages):
    lines = [
        "(use math/hash/sha2)",
        "(use math/hash/sha512)",
        "(use allocator/allocator)",
        "",
        "(defn main ()",
        "  (let a (arena-create 0)",
        "    (begin",
    ]
    for m in messages:
        lines.append('      (print (sha256-hex-of-string a "%s"))' % m)
        lines.append('      (print (sha512-hex-of-string a "%s"))' % m)
    lines.append("      0)))")
    return "\n".join(lines) + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--zyl", default=os.path.join(REPO, "build", "boot", "zyl-self"))
    args = ap.parse_args()

    messages = corpus()
    tmpdir = tempfile.mkdtemp(prefix="zyl-verify-sha2-")
    src = os.path.join(tmpdir, "sha2_verify.zyl")
    binary = os.path.join(tmpdir, "sha2_verify.bin")
    with open(src, "w") as fh:
        fh.write(gen_program(messages))

    subprocess.run([args.zyl, src, "-o", binary], check=True, cwd=REPO)
    got = subprocess.run([binary], check=True, capture_output=True, text=True).stdout.split()

    expected = []
    for m in messages:
        expected.append(hashlib.sha256(m.encode()).hexdigest())
        expected.append(hashlib.sha512(m.encode()).hexdigest())

    if len(got) != len(expected):
        print("FAIL: expected %d digests, got %d" % (len(expected), len(got)))
        return 1

    bad = 0
    for i, (g, e) in enumerate(zip(got, expected)):
        if g != e:
            bad += 1
            algo = "sha256" if i % 2 == 0 else "sha512"
            msg = messages[i // 2]
            if bad <= 10:
                print("FAIL %s len=%d\n  zyl      %s\n  hashlib  %s" % (algo, len(msg), g, e))

    if bad:
        print("%d/%d digests wrong" % (bad, len(expected)))
        return 1
    print("OK: %d digests match hashlib (%d messages, lengths 0..1000)" % (len(expected), len(messages)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
