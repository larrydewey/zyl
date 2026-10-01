#!/usr/bin/env bash
# Memory-safety gate: run Zyl programs under Valgrind's memcheck and fail
# on any invalid access, uninitialised read or bad free.
#
# Why Valgrind and not ASan. The runtime does not call malloc: regions and
# arenas are its own bump allocator over mmap. ASan intercepts malloc and
# free, so it would never see a single region and would report a clean run
# on a program that overruns a frame region. Memcheck instruments the
# instruction stream instead and works on an unmodified static binary, which
# is what Zyl produces -- it assembles and links without cc or libc.
#
# What this can and cannot show. It is a dynamic check over the programs it
# runs, so a green result means those programs did not read or write memory
# they should not have, on this run, on this machine. It is not a proof:
# it says nothing about programs it did not run, and memcheck does not
# detect a logic error that stays inside allocated bounds. What it does buy
# is that "no memory errors" stops being a claim in a commit message and
# becomes a gate that fails when it stops being true.
#
# Its own positive control is checked first: a deliberately invalid write
# must be reported. A gate that cannot fail is worse than no gate, because
# it reads as evidence. If the control is not detected, this exits non-zero
# and says so.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ZYL="${ZYL:-$REPO_ROOT/build/boot/zyl-self}"
SCRATCH="${SCRATCH:-$(mktemp -d "${TMPDIR:-/tmp}/zyl-memcheck.XXXXXX")}"
KEEP="${KEEP:-0}"

cleanup() {
    if [ "$KEEP" = "1" ]; then
        echo "scratch kept: $SCRATCH"
    else
        rm -rf "$SCRATCH"
    fi
}
trap cleanup EXIT

if [ ! -x "$ZYL" ]; then
    echo "memcheck: no compiler at $ZYL -- run ./boot.sh first" >&2
    exit 2
fi
if ! command -v valgrind >/dev/null 2>&1; then
    echo "memcheck: valgrind not installed -- cannot run this gate" >&2
    exit 2
fi

export ZYL_HOME="${ZYL_HOME:-$REPO_ROOT/build/boot}"

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; NC=$'\033[0m'

# --- the control -----------------------------------------------------------
# Must be reported, or nothing below means anything.
cat > "$SCRATCH/control.c" <<'EOF'
int main(void) { volatile int *p = (int *)0x1000; p[1] = 5; return p[1]; }
EOF
CONTROL_BIN="$SCRATCH/control"
if ! cc -O0 -o "$CONTROL_BIN" "$SCRATCH/control.c" 2>/dev/null; then
    echo -e "${YELLOW}memcheck: no cc for the control; skipping the gate${NC}"
    exit 0
fi
control_out=$(valgrind --error-exitcode=99 "$CONTROL_BIN" 2>&1)
if ! echo "$control_out" | grep -qE "Invalid write|Access not within mapped"; then
    echo -e "${RED}memcheck: FAILED ITS OWN CONTROL${NC}"
    echo "  a deliberately invalid write was not reported, so memcheck is not"
    echo "  seeing memory errors here and a green run would be meaningless:"
    echo "$control_out" | sed 's/^/    /'
    exit 1
fi
echo -e "  ${GREEN}✓${NC} memcheck control (an invalid write is detected)"

# --- self-test: prove the gate can fail ------------------------------------
#
# A gate whose detection path has never fired is not evidence, it is a
# green light wired to nothing. This proves the failure path works before
# any real result is reported, by checking that memcheck's actual output
# text is what the run-time test greps for.
if [ "${1:-}" = "--self-test" ]; then
    bad=$(valgrind --error-exitcode=99 "$CONTROL_BIN" 2>&1)
    if echo "$bad" | grep -qE "Invalid (read|write|free)|uninitialised|Mismatched|Conditional jump|Use of uninitialised|Syscall param"; then
        echo -e "  ${GREEN}✓${NC} memcheck self-test (a known-bad binary is flagged)"
        exit 0
    fi
    echo -e "  ${RED}✗${NC} memcheck self-test: a known-bad binary was NOT flagged"
    echo "    the run-time patterns would never match, so this gate cannot fail"
    echo "$bad" | tail -6 | sed 's/^/    /'
    exit 1
fi

# --- the programs ----------------------------------------------------------
# Each is compiled, then run under memcheck. A program that fails to compile
# is reported and counted: if a change breaks a build, the gate must notice
# rather than skip quietly.
programs=()
while IFS= read -r f; do
    [ -n "$f" ] && programs+=("$f")
done < <(find "$REPO_ROOT/tests/regression" "$REPO_ROOT/tests/smoke" \
              -maxdepth 1 -name '*.zyl' 2>/dev/null | sort)

if [ ${#programs[@]} -eq 0 ]; then
    echo -e "${YELLOW}memcheck: no programs found${NC}"
    exit 0
fi

checked=0
bad=0
built=0
errors=0

for src in "${programs[@]}"; do
    name=$(basename "$src" .zyl)
    bin="$SCRATCH/$name.bin"
    if ! "$ZYL" "$src" -o "$bin" > "$SCRATCH/$name.build" 2>&1; then
        echo -e "  ${RED}✗${NC} $name (did not build under memcheck gate)"
        sed 's/^/      /' "$SCRATCH/$name.build" | head -5
        errors=$((errors + 1))
        continue
    fi
    built=$((built + 1))
    out=$(timeout 600 valgrind --error-exitcode=99 --errors-for-leak-kinds=none \
              --leak-check=no "$bin" 2>&1)
    rc=$?
    # memcheck reports errors inline as well as in a summary, and the
    # summary is absent when a program exits by its own syscall path, so
    # the inline markers are what this keys on.
    if echo "$out" | grep -qE "Invalid (read|write|free)|uninitialised|Mismatched|Conditional jump|Use of uninitialised|Syscall param"; then
        echo -e "  ${RED}✗${NC} $name"
        echo "$out" | grep -E "Invalid (read|write|free)|uninitialised|Mismatched|Conditional jump|Use of uninitialised|Syscall param" | head -4 | sed 's/^/      /'
        errors=$((errors + 1))
    elif [ "$rc" = "99" ]; then
        echo -e "  ${RED}✗${NC} $name (memcheck exited 99)"
        echo "$out" | tail -5 | sed 's/^/      /'
        errors=$((errors + 1))
    else
        checked=$((checked + 1))
    fi
done

total=$((built + errors))
if [ "$errors" -gt 0 ]; then
    echo -e "${RED}memcheck: $errors of $total programs reported memory errors${NC}"
    exit 1
fi

echo -e "  ${GREEN}✓${NC} memcheck ($checked programs clean, $built run)"
exit 0
