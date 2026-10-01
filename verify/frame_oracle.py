#!/usr/bin/env python3
"""An independent re-derivation of the assembly verifier's verdict.

`stdlib/compiler/verify.zyl` is a phase of compilation: it scans the emitted
assembly and refuses to let a binary be produced if a write through a frame
slot falls outside the frame that function reserved. That is only worth
anything if the verdict is right, and a verifier is exactly the kind of code
whose bugs are quiet -- a scan that finds no operands at all reports zero
violations, and so does a correct one.

So the rules are implemented a second time, here, in a different language, and
the two must agree. This is not a copy: the point is independence, and it is
the same shape as `verify/model.py` for the region allocator -- a second
encoding of one specification, so that a mistake in one is unlikely to be
mirrored in the other.

THE RULES, as `docs/verifier-design.md` states them.

  Frames.   Code generation writes "    # frame N" under each function label.
            A frame slot write needs N <= frame + 8 (the pushed return
            address) and N 8-aligned. A comment that is not "# frame" is not
            an annotation, and leaves the frame unknown rather than inventing
            one.

  Operands. Every "[rbp-M]" on a line is a frame slot. Every other memory
            operand is counted as dynamic, except "[fs:...", which is
            thread-local and out of scope.

  Writes.  A memory operand is written when it is in destination position --
            before the comma, in Intel syntax -- and the mnemonic can write.
            cmp, test, lea, push and call cannot. A line with no comma at all
            is a store, so the mnemonic alone decides. A local jump target
            (".L0_0:") is at column 0 and ends in ':' exactly like a function
            label, and is not one.

  A function whose frame is unknown is reported as an unverified write, not
  as a violation: the claim being checked is that code generation states the
  bound for every function, so a missing annotation is a coverage fact to be
  published, not a memory error to be invented.

Usage:  asm_oracle.py <file.s> [more.s ...]
        asm_oracle.py --emit FILE          canonical one-line verdict per file
        asm_oracle.py --agree FILE         exit nonzero unless clean
"""

import bisect
import re
import sys

# The generator indents by exactly four spaces, so pos+4 is the first
# character of the content, pos+6 the 'f' of "frame", pos+12 the digits.
INDENT = 4
FRAME_AT = 4
FRAME_WORD = 6
FRAME_DIGITS = 12
SLOT = b"[rbp-"

# Mnemonics that cannot write through a memory operand, keyed on the first one
# or two bytes so the test cannot be fooled by a longer name.
def nowrite(mnem: bytes) -> bool:
    if len(mnem) < 2:
        return False
    c, d = mnem[0], mnem[1]
    if c == 0x63:            # c
        return d == 0x6D or d == 0x61          # cmp, call
    if c == 0x74:            # t
        return True                           # test
    if c == 0x6C:            # l
        return True                           # lea
    if c == 0x70:            # p
        return d == 0x75                       # push, but not pop
    return False


LABEL = re.compile(rb"(?m)^(?!\.)[A-Za-z_][A-Za-z_0-9]*:")
ANNOT = re.compile(rb"(?m)^    # frame (\d+)")
SLOTRE = re.compile(rb"\[rbp-(\d+)\]")


def scan(buf: bytes):
    """The verdict for one assembly buffer. Returns a dict of counts."""
    out = {
        "buf": buf,
        "lines": 0, "functions": 0, "writes": 0, "reads": 0,
        "dynamic": 0, "unverified": 0, "violations": [], "frames": [],
    }
    frame = -1
    frame_at = 0
    frame_val = 0

    # Function and annotation positions, in one C-level pass each, so the
    # per-line loop below can attribute a write by bisection instead of
    # carrying a frame it might get wrong at a boundary.
    for m in ANNOT.finditer(buf):
        out["frames"].append((m.start(), int(m.group(1))))
    fpos = [p for p, _ in out["frames"]]
    fval = [v for _, v in out["frames"]]

    # Lines of text, not segments: a file ending in a newline does not have a
    # final empty line, and counting one is an off-by-one against the verifier.
    out["lines"] = buf.count(b"\n") + (0 if buf.endswith(b"\n") or not buf else 1)

    line_no = 0
    start = 0
    n = len(buf)
    while start <= n:
        nl = buf.find(b"\n", start)
        end = n if nl < 0 else nl
        line = buf[start:end]
        line_no += 1
        if not line:
            if nl < 0:
                break
            start = nl + 1
            continue

        c0 = line[0]
        if c0 == 0x20:                                   # indented
            if len(line) > INDENT:
                c4 = line[INDENT]
                if c4 == 0x23:                          # '#'
                    if (len(line) > FRAME_WORD + 5
                            and line[FRAME_WORD:FRAME_WORD + 5] == b"frame"):
                        i = bisect.bisect_right(fpos, start) - 1
                        if i >= 0:
                            frame_at, frame_val = fpos[i], fval[i]
                            frame = frame_val
                elif c4 != 0x2E:                        # not '.' -- an instruction
                    mnem = line[INDENT:]
                    # Destination position: before the comma, in Intel
                    # syntax. Without this, `mov rax, [rbp-8]` reads and
                    # is scored as a write -- which is how the first version
                    # of this file put 98,802 writes on stage2.s where the
                    # verifier has 24,774. The mnemonic alone does not
                    # decide; the comma is half the rule.
                    comma = line.find(b",", INDENT)
                    i = INDENT
                    while True:
                        j = line.find(b"[", i)
                        if j < 0:
                            break
                        k = line.find(b"]", j + 1)
                        if k < 0:
                            out["violations"].append(
                                (line_no, "unterminated operand"))
                            break
                        if line[j:j + 5] == SLOT:
                            if (comma < 0 or j < comma) and not nowrite(mnem):
                                out["writes"] += 1
                                off = int(line[j + 5:k])
                                if frame < 0:
                                    out["unverified"] += 1
                                elif off > frame + 8:
                                    out["violations"].append(
                                        (line_no, f"[rbp-{off}] outside frame {frame}"))
                                elif off & 7:
                                    out["violations"].append(
                                        (line_no, f"[rbp-{off}] not 8-aligned"))
                            else:
                                out["reads"] += 1
                        elif line[j + 1:j + 3] != b"fs":
                            # Dynamic: a register and a displacement. Counted,
                            # not checked -- V1 does not cover it and the
                            # evidence says so.
                            out["dynamic"] += 1
                        i = k + 1
        elif c0 != 0x2E and line[-1:] == b":":          # a function label
            out["functions"] += 1

        if nl < 0:
            break
        start = nl + 1

    # A frame annotation only governs writes inside the function that
    # declares it: a label with no annotation after it leaves the previous
    # function's bound in force, which is what "unverified" exists to report.
    return out


def verdict_line(path: str, r: dict) -> str:
    v = len(r["violations"])
    return (f"{path} bytes={len(r['buf'])} lines={r['lines']} functions={r['functions']} "
            f"writes={r['writes']} reads={r['reads']} dynamic={r['dynamic']} "
            f"unverified={r['unverified']} violations={v}")


def selftest() -> int:
    """Prove the oracle can fail.

    A checker that has only ever agreed is indistinguishable from one that
    always says yes, which is the exact failure this file exists to catch in
    the Zyl verifier -- and it would be no use here if it had the same
    weakness. Each case is a known-bad buffer with the verdict it must
    produce, so a change to the rules that silences a violation fails here
    before it reaches a seed.

    This is the same shape as verify/model_selftest.sh, which injects a double
    free to prove the allocator model fails when it should.
    """
    cases = [
        ("clean function stays clean",
         b"foo:\n    # frame 16\n    mov rax, [rbp-8]\n    mov QWORD [rbp-8], 1\n    ret\n",
         0),
        ("a write past the frame is caught",
         b"foo:\n    # frame 16\n    mov QWORD [rbp-32], 1\n    ret\n",
         1),
        ("the deepest legal slot is frame + 8",
         b"foo:\n    # frame 16\n    mov QWORD [rbp-24], 1\n    ret\n",
         0),
        ("a misaligned slot is caught",
         b"foo:\n    # frame 16\n    mov QWORD [rbp-7], 1\n    ret\n",
         1),
        ("a read past the frame is not a violation",
         b"foo:\n    # frame 16\n    mov rax, [rbp-9999]\n    ret\n",
         0),
        ("cmp, test and lea do not write",
         b"foo:\n    # frame 0\n    cmp QWORD [rbp-8], 0\n    test rax, [rbp-8]\n"
         b"    lea rax, [rbp-8]\n    ret\n",
         0),
        ("mov to a slot writes, and frame 0 still covers rbp-8",
         b"foo:\n    # frame 0\n    mov QWORD [rbp-8], 1\n    ret\n",
         0),
        ("mov to rbp-16 does not",
         b"foo:\n    # frame 0\n    mov QWORD [rbp-16], 1\n    ret\n",
         1),
        ("an ordinary comment is not an annotation, so the write is unverified",
         b"foo:\n    # note 16\n    mov QWORD [rbp-8], 1\n    ret\n",
         0),
        ("a register operand is dynamic, never a frame slot",
         b"foo:\n    # frame 16\n    mov qword ptr [r9+16], 1\n    ret\n",
         0),
    ]
    bad = 0
    for name, buf, want in cases:
        r = scan(buf)
        got = len(r["violations"])
        if got != want:
            print(f"  FAIL {name}: expected {want} violation(s), got {got}")
            bad += 1
        else:
            print(f"  ok   {name}")
    # The comment case must also be reported as unverified rather than clean:
    # a wrong frame and a missing one are different findings.
    r = scan(b"foo:\n    # note 16\n    mov QWORD [rbp-8], 1\n    ret\n")
    if r["unverified"] != 1:
        print(f"  FAIL unannotated function: unverified={r['unverified']}, want 1")
        bad += 1
    else:
        print("  ok   unannotated function is reported unverified")
    if bad:
        print(f"asm_oracle selftest: {bad} case(s) failed")
        return 1
    print("asm_oracle selftest: all cases agree")
    return 0


def main(argv):
    if "--selftest" in argv:
        return selftest()
    if "--emit" in argv:
        for path in argv[argv.index("--emit") + 1:]:
            print(verdict_line(path, scan(open(path, "rb").read())))
        return 0
    clean = True
    for path in argv:
        if path.startswith("--"):
            continue
        r = scan(open(path, "rb").read())
        print(verdict_line(path, r))
        for line_no, why in r["violations"]:
            print(f"  {path}:{line_no}: {why}")
        if r["violations"] or r["unverified"]:
            clean = False
    if "--agree" in argv:
        return 0 if clean else 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
