#!/usr/bin/env bash
# Self-host under poisoned regions: rebuild the whole compiler with released
# region blocks overwritten with 0xDE, and require the seeds to come out
# byte-identical.
#
# Why this is the strongest single check in the repository. Region inference
# guarantees that no value outlives its region (docs/soundness.md L2), and
# that premise is otherwise an argument. verify/poison.sh checks 125 small
# programs; this runs the compiler -- the largest Zyl program in existence,
# self-hosting, ~100k lines -- through every stage of its own bootstrap, so
# the allocator, the escape analysis and the code generator are all exercised
# on real code at scale. If the compiler depended on reading dead frame memory
# anywhere, the fill would corrupt a value and the fixed point would break:
# the generated assembly would differ from the committed seed.
#
# It is also self-checking in a way the others are not. Byte-identity is
# already the property ./boot.sh verifies, so a poisoned run that reproduces
# the seeds is the same strong statement as the ordinary fixed-point check,
# now with the allocator unable to hide a stale read behind reused memory.
#
# Cost: a full bootstrap, so it is opt-in like the other gates.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED=$'\033[31m'; GREEN=$'\033[32m'; NC=$'\033[0m'

# Snapshot the seeds so a difference can be attributed rather than guessed at.
before=$(cd "$REPO_ROOT" && git status --porcelain build/boot/stage2.s build/boot/stage2.bin build/boot/rt.s)
before_hash=$(sha256sum "$REPO_ROOT/build/boot/stage2.s" | cut -d' ' -f1)

log=$(mktemp "${TMPDIR:-/tmp}/zyl-poison-selfhost.XXXXXX")
trap 'rm -f "$log"' EXIT

echo -e "  ${GREEN}o${NC} poison-selfhost (rebuilding the compiler with released regions filled)"

if ! (cd "$REPO_ROOT" && ZYL_NO_INSTALL_REFRESH=1 ZYL_REGION_POISON=1 ./boot.sh) > "$log" 2>&1; then
    echo -e "${RED}poison-selfhost: the poisoned bootstrap failed${NC}"
    tail -25 "$log" | sed 's/^/    /'
    exit 1
fi

if ! grep -q "fixed point holds" "$log"; then
    echo -e "${RED}poison-selfhost: the poisoned bootstrap did not reach a fixed point${NC}"
    tail -25 "$log" | sed 's/^/    /'
    exit 1
fi

after_hash=$(sha256sum "$REPO_ROOT/build/boot/stage2.s" | cut -d' ' -f1)
if [ "$after_hash" != "$before_hash" ]; then
    echo -e "${RED}poison-selfhost: the seeds changed under poisoning${NC}"
    echo "    before $before_hash"
    echo "    after  $after_hash"
    echo "    a program read released region memory and the difference reached codegen"
    (cd "$REPO_ROOT" && git diff --stat build/boot/stage2.s | sed 's/^/    /')
    exit 1
fi

echo -e "  ${GREEN}v${NC} poison-selfhost (fixed point holds, seeds byte-identical)"
exit 0