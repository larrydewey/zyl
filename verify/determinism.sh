#!/usr/bin/env bash
# Determinism gate: the same source must produce a byte-identical binary, and
# the region allocator's transition relation must be a function.
#
# Determinism is not a side property of Zyl, it is the reason the language
# exists (spec 14, docs/design-rationale.md): no randomness, no clock, no
# scheduling dependence, every iterated collection ordered. Two things can
# break it, and this checks both.
#
#   End to end.  Compile each program twice, in separate processes, and
#   require the binaries to be identical byte for byte. This catches an
#   address, a hash-table iteration order or a timestamp leaking into output
#   -- the ways determinism actually breaks in practice. The self-hosting
#   fixed point is the same check at far larger scale, and runs on the
#   compiler rather than on tests.
#
#   By construction.  verify/model.py explores the region allocator's
#   reachable state space exhaustively and requires the transition relation
#   to be a *function*: one successor per (state, operation). If it were a
#   relation, an allocation could land in two different blocks and the
#   emitted code would depend on something other than the program text.
#   That check also verifies the model's block-conservation and
#   release-only-while-owned invariants, so it is the machine-checked half of
#   the region story.
#
# Its own detection path is exercised the same way memcheck's is: model.py
# can be run against a deliberately broken allocator, and verify/model_selftest.sh
# does exactly that to prove the checker fails when it should.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ZYL="${ZYL:-$REPO_ROOT/build/boot/zyl-self}"
SCRATCH="${SCRATCH:-$(mktemp -d "${TMPDIR:-/tmp}/zyl-determinism.XXXXXX")}"
KEEP="${KEEP:-0}"

cleanup() {
    if [ "$KEEP" = "1" ]; then echo "scratch kept: $SCRATCH"; else rm -rf "$SCRATCH"; fi
}
trap cleanup EXIT

if [ ! -x "$ZYL" ]; then
    echo "determinism: no compiler at $ZYL -- run ./boot.sh first" >&2
    exit 2
fi
export ZYL_HOME="${ZYL_HOME:-$REPO_ROOT/build/boot}"

RED=$'\033[31m'; GREEN=$'\033[32m'; NC=$'\033[0m'

# --- by construction ------------------------------------------------------
model_log="$SCRATCH/model.log"
if python3 "$SCRIPT_DIR/model.py" > "$model_log" 2>&1; then
    grep -E '^  (ok|x) ' "$model_log" | sed 's/^/      /'
    echo -e "  ${GREEN}✓${NC} determinism/model (exhaustive: transition relation is a function)"
else
    echo -e "  ${RED}✗${NC} determinism/model"
    sed 's/^/      /' "$model_log"
    exit 1
fi

# The model checker must fail on a broken allocator, or the line above means
# nothing. Inject a double release and require it to be caught.
if bash "$SCRIPT_DIR/model_selftest.sh" > "$SCRATCH/selftest.log" 2>&1; then
    sed 's/^/      /' "$SCRATCH/selftest.log"
    echo -e "  ${GREEN}✓${NC} determinism/model-selfcheck (a broken allocator is caught)"
else
    echo -e "  ${RED}✗${NC} determinism/model-selfcheck"
    sed 's/^/      /' "$SCRATCH/selftest.log"
    exit 1
fi

# --- end to end -----------------------------------------------------------
identical=0
differ=0
built=0
diffs=""

for src in "$REPO_ROOT"/tests/regression/*.zyl; do
    [ -f "$src" ] || continue
    name=$(basename "$src" .zyl)
    if ! "$ZYL" "$src" -o "$SCRATCH/$name.a" > "$SCRATCH/$name.build" 2>&1; then
        echo -e "  ${RED}x${NC} $name did not build"
        sed 's/^/      /' "$SCRATCH/$name.build" | head -4
        differ=$((differ + 1))
        diffs="$diffs\n  $name: failed to build"
        continue
    fi
    built=$((built + 1))
    # A second, separate process: an in-process repeat could share a warm
    # table or a cached address and hide exactly what this is looking for.
    "$ZYL" "$src" -o "$SCRATCH/$name.b" > /dev/null 2>&1
    if cmp -s "$SCRATCH/$name.a" "$SCRATCH/$name.b"; then
        identical=$((identical + 1))
    else
        differ=$((differ + 1))
        diffs="$diffs\n  $name: binaries differ"
    fi
done

if [ "$differ" -gt 0 ]; then
    echo -e "${RED}determinism: $differ of $built programs are not reproducible${NC}"
    printf "$diffs\n" | sed 's/^/    /'
    exit 1
fi

echo -e "  ${GREEN}✓${NC} determinism/codegen ($identical programs byte-identical across processes)"
exit 0
