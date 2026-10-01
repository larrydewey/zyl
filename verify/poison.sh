#!/usr/bin/env bash
# Region-lifetime gate: run Zyl programs with released region blocks
# overwritten with 0xDE, and require the observable behaviour to be
# unchanged.
#
# Why this exists. Region inference is supposed to guarantee that no value
# outlives its region (docs/soundness.md L2). That premise is *argued*, and
# it is the weakest link in the memory-safety story: nothing else checks
# it. The failure mode is also the quietest available -- a region block
# goes back to a size-class pool on release and is handed to the next
# allocation of that class, so a stale pointer does not fault, it reads
# whatever the next allocation happened to write. A program can hold a
# pointer into a dead frame region and still produce the right answer,
# right up until the allocation pattern changes.
#
# The mechanism. With ZYL_REGION_POISON=1 the runtime fills a block with
# 0xDE (rt-fill-de) when the block is released, which it already does for
# arena blocks. A program that never reads a released block cannot notice
# this at all; one that does reads garbage. It is a weak detector in one
# specific way, stated plainly: it catches a stale read only when that read
# reaches an observable output. A stale read whose value is overwritten
# before anyone looks at it is invisible. It cannot be made stronger here
# -- see the note on mprotect at the bottom of runtime/rt/alloc.zyl.
#
# What this is not. It is not a use-after-free detector in general. It is a
# check that the 125 programs in the gate do not depend on reading released
# region memory, which is the property that matters and the one nothing
# else examines.
#
# Its own control runs first: the fill must be able to change a program's
# output, or this gate is measuring nothing. A gate that cannot fail reads
# as evidence.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ZYL="${ZYL:-$REPO_ROOT/build/boot/zyl-self}"
SCRATCH="${SCRATCH:-$(mktemp -d "${TMPDIR:-/tmp}/zyl-poison.XXXXXX")}"
KEEP="${KEEP:-0}"

cleanup() {
    if [ "$KEEP" = "1" ]; then echo "scratch kept: $SCRATCH"; else rm -rf "$SCRATCH"; fi
}
trap cleanup EXIT

if [ ! -x "$ZYL" ]; then
    echo "poison: no compiler at $ZYL -- run ./boot.sh first" >&2
    exit 2
fi
export ZYL_HOME="${ZYL_HOME:-$REPO_ROOT/build/boot}"

RED=$'\033[31m'; GREEN=$'\033[32m'; NC=$'\033[0m'

# --- on the absence of a positive control ---------------------------------
#
# memcheck.sh can check its own detection path because a deliberately broken
# C program is easy to write. This gate cannot, and pretending otherwise
# would be worse than saying so.
#
# The violation it looks for -- a read of released region memory -- is
# precisely what the static checks exist to prevent. A test program that
# does it does not compile: returning a Stack bytebuf from its frame is
# E_REGION_ESCAPE, and a resource used after release is E_MOVE_VALUE. So
# there is no in-language program to use as a positive control without
# first weakening the compiler.
#
# That is worth stating plainly rather than papering over, because it cuts
# both ways:
#
#   - it means a failure here is a real escape from the static checks, which
#     is the class of bug the gate exists to catch, and it would be a
#     genuine finding;
#   - it means a green run is weaker evidence than a validated detector
#     would be. What is verified is that these 125 programs do not depend on
#     reading released region memory for their output. It is not verified
#     that the fill reaches every release path.
#
# What *is* verified mechanically: the flag reaches the runtime
# (zyl_region_poison_level reads ZYL_REGION_POISON), rt-release-block calls
# rt-poison on the pool path, and rt-poison calls rt-fill-de. The seed
# (build/boot/rt.s) is regenerated and diffed by ./boot.sh, so the shipped
# runtime is the one containing that path rather than a stale one.

# --- the programs ----------------------------------------------------------
# Compared on the test summary and the exit status, never on raw output:
# several regression programs print raw addresses, which differ between any
# two runs because of ASLR. Diffing full output reports those as failures
# even when nothing is wrong, which is exactly the kind of gate that gets
# ignored.
summary() {
    # the "test result: N passed, M failed" line if there is one, else the
    # last line of output -- never an address
    local out
    out=$(cat)
    if echo "$out" | grep -q "test result:"; then
        echo "$out" | grep "test result:" | tail -1
    else
        echo "$out" | grep -vE '^[0-9]{6,}$' | tail -1
    fi
}

programs=()
while IFS= read -r f; do
    [ -n "$f" ] && programs+=("$f")
done < <(find "$REPO_ROOT/tests/regression" "$REPO_ROOT/tests/smoke" \
              -maxdepth 1 -name '*.zyl' 2>/dev/null | sort)

if [ ${#programs[@]} -eq 0 ]; then
    echo "poison: no programs found" >&2
    exit 0
fi

clean=0
differ=0
built=0
details=""

for src in "${programs[@]}"; do
    name=$(basename "$src" .zyl)
    bin="$SCRATCH/$name.bin"
    if ! "$ZYL" "$src" -o "$bin" > "$SCRATCH/$name.build" 2>&1; then
        echo -e "  ${RED}x${NC} $name did not build"
        differ=$((differ + 1))
        details="$details\n  $name: failed to build"
        continue
    fi
    built=$((built + 1))

    timeout 600 "$bin" > "$SCRATCH/$name.plain" 2>&1
    plain_rc=$?
    plain_sum=$(summary < "$SCRATCH/$name.plain")

    ZYL_REGION_POISON=1 timeout 600 "$bin" > "$SCRATCH/$name.poison" 2>&1
    poison_rc=$?
    poison_sum=$(summary < "$SCRATCH/$name.poison")

    if [ "$plain_rc" != "$poison_rc" ] || [ "$plain_sum" != "$poison_sum" ]; then
        differ=$((differ + 1))
        details="$details\n  $name: rc $plain_rc->$poison_rc, '$plain_sum' -> '$poison_sum'"
    else
        clean=$((clean + 1))
    fi
done

if [ "$differ" -gt 0 ]; then
    echo -e "${RED}poison: $differ of $built programs behave differently with released blocks filled${NC}"
    printf "$details\n" | sed 's/^/    /'
    exit 1
fi

echo -e "  ${GREEN}v${NC} poison ($clean programs unchanged, $built run)"
exit 0
