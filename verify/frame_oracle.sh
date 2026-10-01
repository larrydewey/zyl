#!/usr/bin/env bash
# Two implementations of the assembly verifier's rules must agree.
#
# `stdlib/compiler/verify.zyl` is a phase of compilation: it decides whether
# the code the compiler just emitted is safe to hand to a linker. That verdict
# is worth nothing if the verifier is quietly wrong, and a verifier is exactly
# the kind of code that can be wrong while reporting success -- a scan that
# matches no operands finds no violations, and so does a correct one. Five
# defects did get through this way before this check existed, each of them
# producing a passing build with a check that was not running.
#
# So the rules are implemented twice: once in Zyl, in the compiler, and once
# in `verify/frame_oracle.py`, in a language the compiler does not emit. This
# script builds the Zyl one, runs the Python one over the same two committed
# seeds, and requires the verdicts to be equal field for field.
#
# The oracle is in Python on purpose, and it is worth being explicit about why,
# because "write it in Zyl, we already have Zyl" is the obvious objection. An
# oracle exists to catch bugs in the compiler. An oracle compiled by the
# compiler shares its codegen, so a miscompilation would be invisible to it by
# construction -- the one class of bug this whole arrangement exists to catch.
# That is the same argument as L7 in docs/soundness.md: the obligation has to
# sit outside the thing being checked.
#
# What a Zyl re-implementation *is* good for is checking the verifier rather
# than the compiler, and there is already one: tests/verify_test.zyl plants
# faults in hand-written assembly and requires them to be caught. The two
# together cover different failures, which is why both exist.
#
# Equality is exact, including the operand counts. A tolerance here would hide
# precisely the failure this is for: a scan that stops early reports fewer
# operands and still reports zero violations.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# The oracle's own positive control, first: if it cannot fail on assembly it
# is meant to reject, a green run below means nothing.
if ! python3 verify/frame_oracle.py --selftest > "$TMP/self.log" 2>&1; then
    echo -e "${RED}✗${NC} frame-oracle: the oracle fails its own selftest"
    sed 's/^/    /' "$TMP/self.log"
    exit 1
fi

SEEDS=("build/boot/stage2.s" "build/boot/rt.s")

for f in "${SEEDS[@]}"; do
    if [ ! -f "$f" ]; then
        echo -e "${RED}✗${NC} frame-oracle: missing seed $f"
        exit 1
    fi
done

# The Zyl verifier, reached through tools/verify_asm.zyl. ZYL_HOME is pinned
# to this checkout's stdlib: the compiler otherwise resolves ~/.zyl, which may
# be many commits stale, and a stale verifier disagrees with a fresh oracle for
# reasons that have nothing to do with either being wrong.
if ! ZYL_HOME="$SCRIPT_DIR/build/boot" build/boot/zyl-self tools/verify_asm.zyl \
        -o "$TMP/va.bin" >"$TMP/build.log" 2>&1; then
    echo -e "${RED}✗${NC} frame-oracle: could not build tools/verify_asm.zyl"
    sed 's/^/    /' "$TMP/build.log" | tail -20
    exit 1
fi

"$TMP/va.bin" > "$TMP/zyl.txt" 2>/dev/null
python3 verify/frame_oracle.py --emit "${SEEDS[@]}" > "$TMP/py.txt" 2>"$TMP/py.err"

if ! diff -u "$TMP/zyl.txt" "$TMP/py.txt" > "$TMP/diff.txt" 2>&1; then
    echo -e "${RED}✗${NC} frame-oracle: the two implementations disagree"
    echo "    (- Zyl verifier, + Python oracle)"
    sed 's/^/    /' "$TMP/diff.txt"
    [ -s "$TMP/py.err" ] && sed 's/^/    /' "$TMP/py.err" | tail -5
    exit 1
fi

# No bypass. The check above proves the verifier reaches the right verdict; this
# proves anything reaches the verifier at all.
#
# The verifier was first placed in `compile-to-asm`, on the reasoning that
# every path to an assembly goes through it. It does not: `drv-compile-uncached`
# needs the IR before code generation in order to hash it, so it calls
# `codegen-fns` directly, and `zyl build` and `zyl test` emitted binaries with
# no verification while the docstring claimed otherwise. So the check lives in
# `codegen-fns`, and what makes that safe is a structural fact rather than a
# convention: `cg-buffer` is how generated assembly text is extracted from
# codegen state, and it is read in exactly one place. If that stays true, no
# path to an assembly can skip the verifier without writing a second code
# generator.
extractors=$(grep -rn "cg-buffer" --include='*.zyl' stdlib selfhost \
    | grep -v "defn cg-buffer" | grep -v "^[^:]*:[0-9]*:;" | grep -v ";" || true)
n_extract=$(printf '%s\n' "$extractors" | grep -c . || true)
if [ "$n_extract" != "1" ]; then
    echo -e "${RED}✗${NC} frame-oracle: cg-buffer is read in $n_extract places, expected 1"
    printf '%s\n' "$extractors" | sed 's/^/      /'
    echo "    Every path to generated assembly must go through the one function that verifies it."
    exit 1
fi

# And that one function must actually verify.
body=$(sed -n '/^(defn codegen-fns /,/^$/p' stdlib/compiler/pipeline.zyl)
if ! printf '%s' "$body" | grep -q "verify-asm"; then
    echo -e "${RED}✗${NC} frame-oracle: codegen-fns does not call verify-asm"
    exit 1
fi

while read -r line; do
    case "$line" in
        *violations=0*) ;;
        *)
            echo -e "${RED}✗${NC} frame-oracle: $line"
            exit 1
            ;;
    esac
done < "$TMP/zyl.txt"

echo -e "${GREEN}✓${NC} frame-oracle: Zyl and Python agree on ${#SEEDS[@]} seeds; single verified path to assembly (oracle selftest ok)"
sed 's/^/    /' "$TMP/zyl.txt"
