#!/usr/bin/env python3
"""dudect-style timing leakage check for stdlib/math primitives.

The question this answers is narrow but real: does a primitive's
running time depend on the VALUE of its secret input? The method is
the one dudect uses -- run the primitive many times over two input
classes, collect timings, and apply Welch's t-test to the two
distributions. A |t| above ~4.5 is dudect's "leaking" threshold.

What makes the result trustworthy is the POSITIVE CONTROL: alongside
each constant-time primitive, the same measurement runs against a
deliberately leaky comparison (an early-exit loop). If the harness
cannot detect the leak it was built to detect, a clean result for the
real primitive means nothing, and the script says so.

Timing is per-process wall clock around a loop of N operations, which
is coarser than dudect's per-call cycle counter: it detects gross
data-dependence (an early exit, a secret-dependent branch or table
lookup), not a few cycles of cache effect. That is the class of leak
this library's constant-time discipline is designed to exclude.

Usage:
    python3 verify/timing.py              # all cases
    python3 verify/timing.py --quick      # fewer rounds
    python3 verify/timing.py --case ct-eq-words
"""

import argparse
import math
import os
import statistics
import subprocess
import sys
import tempfile
import time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ZYL = os.path.join(REPO, "build", "boot", "zyl-self")

# Each case builds a Zyl program whose main() runs `iters` operations
# over one of two input classes, selected by argv[1].
CASES = {
    # The real primitive: a constant-time word-array comparison. The two
    # classes differ in WHERE the arrays differ -- first word vs not at
    # all -- which is exactly what an early-exit compare leaks.
    "ct-eq-words": """
(use math/secret/secret)
(use math/words)
(use allocator/allocator)

(defn run ((a Int) (x Int) (y Int) (iters Int))
  (let acc 0
    (begin
      (for (i 0) (< i iters)
        (begin
          (ct-eq-words x y 32)
          (set! i (+ i 1))))
      0)))

(defn main ()
  (let a (arena-create 0)
    (let cls (ffi-call "zyl_cstr_to_int" (ffi-call "zyl_arg_str" 1 1000) 1000)
      (let iters (ffi-call "zyl_cstr_to_int" (ffi-call "zyl_arg_str" 2 1000) 1000)
        (let x (w-fill (w-alloc a 32) 32 7)
          (let y (w-fill (w-alloc a 32) 32 7)
            (begin
              (if (= cls 1) (w-set y 0 9) 0)
              (run a x y iters)
              0)))))))
""",
    # The positive control: the same comparison written the wrong way,
    # returning as soon as two words differ.
    "leaky-compare": """
(use math/words)
(use allocator/allocator)

(defn leaky-eq ((x Int) (y Int) (n Int) (i Int))
  (if (>= i n)
    1
    (if (= (w-get x i) (w-get y i))
      (leaky-eq x y n (+ i 1))
      0)))

(defn run ((x Int) (y Int) (iters Int))
  (begin
    (for (i 0) (< i iters)
      (begin
        (leaky-eq x y 32 0)
        (set! i (+ i 1))))
    0))

(defn main ()
  (let a (arena-create 0)
    (let cls (ffi-call "zyl_cstr_to_int" (ffi-call "zyl_arg_str" 1 1000) 1000)
      (let iters (ffi-call "zyl_cstr_to_int" (ffi-call "zyl_arg_str" 2 1000) 1000)
        (let x (w-fill (w-alloc a 32) 32 7)
          (let y (w-fill (w-alloc a 32) 32 7)
            (begin
              (if (= cls 1) (w-set y 0 9) 0)
              (run x y iters)
              0)))))))
""",
    # A whole AEAD tag verification, which is where a leaky compare
    # would actually be exploitable.
    "poly1305-verify": """
(use math/crypto/symmetric/poly1305)
(use math/words)
(use allocator/allocator)

(defn run ((a Int) (key Int) (msg Int) (tag Int) (iters Int))
  (begin
    (for (i 0) (< i iters)
      (begin
        (poly1305-verify a key msg 34 tag)
        (set! i (+ i 1))))
    0))

(defn main ()
  (let a (arena-create 0)
    (let cls (ffi-call "zyl_cstr_to_int" (ffi-call "zyl_arg_str" 1 1000) 1000)
      (let iters (ffi-call "zyl_cstr_to_int" (ffi-call "zyl_arg_str" 2 1000) 1000)
        (let key (w-from-hex a "85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b")
          (let msg (w-from-string a "Cryptographic Forum Research Group")
            (let tag (w-from-hex a "a8061dc1305136c6c22b8baf0c0127a9")
              (begin
                (if (= cls 1) (w-set tag 0 0) 0)
                (run a key msg tag iters)
                0))))))))
""",
}

# Cases where a difference between the two classes is EXPECTED: the
# control exists to prove the harness works.
EXPECT_LEAK = {"leaky-compare"}

THRESHOLD = 4.5  # dudect's |t| cutoff


def build(name, source):
    tmpdir = tempfile.mkdtemp(prefix="zyl-timing-")
    src = os.path.join(tmpdir, name.replace("-", "_") + ".zyl")
    binary = os.path.join(tmpdir, name.replace("-", "_") + ".bin")
    with open(src, "w") as fh:
        fh.write(source)
    subprocess.run([ZYL, src, "-o", binary], check=True, cwd=REPO,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return binary


def measure(binary, cls, iters):
    start = time.perf_counter()
    subprocess.run([binary, str(cls), str(iters)], check=True,
                   stdout=subprocess.DEVNULL)
    return time.perf_counter() - start


def welch_t(xs, ys):
    """Welch's t statistic for two samples of unequal variance."""
    if len(xs) < 2 or len(ys) < 2:
        return 0.0
    mx, my = statistics.fmean(xs), statistics.fmean(ys)
    vx, vy = statistics.variance(xs), statistics.variance(ys)
    denom = math.sqrt(vx / len(xs) + vy / len(ys))
    return 0.0 if denom == 0 else (mx - my) / denom


def run_case(name, source, rounds, iters):
    binary = build(name, source)
    a, b = [], []
    # Alternate classes so that machine-level drift (frequency scaling,
    # another process waking up) hits both samples equally instead of
    # landing entirely in one of them.
    for _ in range(rounds):
        a.append(measure(binary, 0, iters))
        b.append(measure(binary, 1, iters))
    t = welch_t(a, b)
    leaked = abs(t) > THRESHOLD
    expected = name in EXPECT_LEAK
    status = "LEAK" if leaked else "ok"
    verdict = "as expected" if leaked == expected else "UNEXPECTED"
    print("%-18s t=%8.2f  %-4s  (%s; mean %.4fs vs %.4fs)"
          % (name, t, status, verdict, statistics.fmean(a), statistics.fmean(b)))
    return leaked == expected


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true", help="fewer rounds")
    ap.add_argument("--case", help="run only this case")
    args = ap.parse_args()

    rounds = 12 if args.quick else 40
    iters = 20000 if args.quick else 60000

    names = [args.case] if args.case else list(CASES)
    ok = True
    control_ok = False
    for name in names:
        if name not in CASES:
            print("unknown case: %s" % name)
            return 2
        result = run_case(name, CASES[name], rounds, iters)
        ok = ok and result
        if name in EXPECT_LEAK:
            control_ok = control_ok or result

    if not args.case and not control_ok:
        print("\nPOSITIVE CONTROL FAILED: the harness did not detect the "
              "deliberately leaky comparison, so a clean result for the "
              "real primitives proves nothing on this machine. Try more "
              "rounds, or a quieter machine.")
        return 1
    print("\nAll cases behaved as expected." if ok else "\nSome cases did not.")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
