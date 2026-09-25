#!/usr/bin/env bash
# Zyl boot build + self-hosting fixed-point verification (cargo-free).
#
# Default flow — no Rust anywhere:
#   1. cc-links the committed seed build/boot/stage2.s -> stage1.bin
#   2. stage1 compiles the selfhost source  -> stage2.s (must byte-match seed)
#   3. stage2 compiles the selfhost source  -> stage3.s
#   4. stage3.s must be byte-identical to stage2.s (fixed point)
#   5. CLI smoke-test + cargo-free zyl-self wrapper
#   6. an existing install (~/.zyl, or $ZYL_INSTALL_HOME) is refreshed with
#      uninstall.sh + install.sh; ZYL_NO_INSTALL_REFRESH=1 skips it
#
# Re-seeding (only needed when the compiler source changes the fixed point):
#   ./boot.sh --bootstrap-from-self  rebuild stage2.s/stage2.bin using the
#                                    CURRENT committed seed as the starting
#                                    compiler, no Rust anywhere. A source
#                                    change doesn't take full effect in one
#                                    round -- the compiler that compiled the
#                                    new source doesn't yet BEHAVE per that
#                                    new source until it's compiled AGAIN by
#                                    the result -- so this iterates
#                                    stage1->stage2->stage3->... up to
#                                    MAX_SELF_ROUNDS, comparing consecutive
#                                    outputs, until two consecutive rounds
#                                    match. Verified empirically: starting
#                                    from a seed many commits stale (predating
#                                    closures, try/catch, exhaustiveness
#                                    checking, and more), two rounds converged
#                                    to a fixed point BYTE-IDENTICAL to the one
#                                    Rust produced for the same source. Only
#                                    fails to converge for a change so large
#                                    the OLD seed can't even PARSE the new
#                                    source at all (new syntax, not just new
#                                    behavior) -- archive/rust-bootstrap-2026's
#                                    README covers that fallback.
#   ./boot.sh --bootstrap-from-rust  retired; exits with a pointer to
#                                    archive/rust-bootstrap-2026/README.md.
#
# Artifacts land in build/boot/. Exit 0 only if the fixed point holds.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# The compiler is built like any program: its entry file, with every
# `(use ...)` resolved from the stdlib/ tree synced into OUT below.
SRC="${SCRIPT_DIR}/selfhost/driver.zyl"
OUT="${SCRIPT_DIR}/build/boot"
RUNTIME="${SCRIPT_DIR}/runtime/actor_runtime.c"

# Force stdlib resolution to this checkout's freshly-synced build/boot/stdlib
# (see cli-resolve-bundledir in selfhost/driver.zyl) instead of silently
# preferring a populated $HOME/.zyl from an old `install.sh` run, which would
# make this build depend on unrelated machine state and mask edits to
# stdlib/ made in this checkout (confirmed to happen in practice).
export ZYL_HOME="${OUT}"
BOOTSTRAP=0
BOOTSTRAP_SELF=0
[ "${1:-}" = "--bootstrap-from-rust" ] && BOOTSTRAP=1
[ "${1:-}" = "--bootstrap-from-self" ] && BOOTSTRAP_SELF=1

# One stage compiles the whole self-hosted compiler. When the package
# system landed (spec v5.0 SS31, which brought in the Ed25519 stack that
# SS31.8's mandatory signature verification needs) a stage took about ten
# minutes, right at the old 600-second cap, and the reseed failed on the
# timeout rather than on anything about the code. The type-inference
# exponential fixed since then brought a stage down to about ten seconds;
# the generous cap stays as headroom for a slow machine.
STAGE_TIMEOUT="${ZYL_STAGE_TIMEOUT:-2400}"
# Allocation ceiling per stage (cumulative bytes allocated, nothing is
# freed during a compile). With inlining, in-place reuse and the native
# backend a self-compile allocates somewhat over 2 GB, so the cap is 4 GB:
# growth past it is a regression and fails loudly instead of swapping the
# machine. Bringing the compiler's own allocation down is open work.
export ZYL_MAX_MEMORY="${ZYL_STAGE_MEMORY:-4294967296}"

mkdir -p "$OUT"
cd "$SCRIPT_DIR"

# ── sync stdlib + runtime into OUT (ZYL_HOME) ─────────────────────────────
# Before any stage: every stage resolves the compiler's own modules from
# OUT/stdlib, so it must be this checkout's stdlib/, not a stale copy.
# rm first: `cp -R stdlib OUT/stdlib` nests a fresh copy INSIDE an
# already-existing OUT/stdlib instead of updating it (cp -R's directory-
# target semantics), so every run after the first silently left the real
# resolution path (OUT/stdlib/*, what module_resolver.zyl actually reads
# after chdir-ing to OUT) frozen at whatever it was on the very first
# boot.sh run in this checkout -- real, dependency-graph-wide staleness
# that took a full stdlib diff to actually find (see docs/rust-eviction-
# plan.md).
rm -rf "${OUT}/stdlib"
cp -R "${SCRIPT_DIR}/stdlib" "${OUT}/stdlib"
cp "${SCRIPT_DIR}/runtime/actor_runtime.c" "${OUT}/actor_runtime.c"
cp "${SCRIPT_DIR}/runtime/actor_runtime.h" "${OUT}/actor_runtime.h"
# The runtime, compiled once (-O2): every stage and every program the
# compiler links uses this object (driver.zyl's cli-link-command).
RUNTIME_O="${OUT}/actor_runtime.o"
cc -O2 -c "${OUT}/actor_runtime.c" -o "${RUNTIME_O}.tmp" && mv -f "${RUNTIME_O}.tmp" "${RUNTIME_O}"


step() { echo -e "\033[1;34m==>\033[0m $*"; }
ok()   { echo -e "  \033[0;32m✓\033[0m $*"; }
die()  { echo -e "  \033[0;31m✗\033[0m $*"; exit 1; }

link_cc() { # link_cc <asm> <out-bin>
    cc -no-pie "$1" "$RUNTIME_O" -o "$2" -lpthread
}

# ── Re-seed path: iterate the self-hosted compiler to a new fixed point ──
MAX_SELF_ROUNDS=10
if [ "$BOOTSTRAP_SELF" -eq 1 ]; then
    step "Bootstrap: reseeding from the self-hosted compiler (no Rust)"
    [ -f "${OUT}/stage2.s" ] || die "missing committed seed ${OUT}/stage2.s — restore it with: git checkout -- build/boot/stage2.s"
    link_cc "${OUT}/stage2.s" "${OUT}/stage1.bin"
    PREV_S="${OUT}/stage2.s"
    PREV_BIN="${OUT}/stage1.bin"
    i=1
    while [ "$i" -le "$MAX_SELF_ROUNDS" ]; do
        NEXT_S="${OUT}/reseed_round${i}.s"
        timeout "$STAGE_TIMEOUT" "$PREV_BIN" "$SRC" -o "$NEXT_S" --emit-asm
        [ -f "$NEXT_S" ] || die "round $i produced no output"
        if cmp -s "$PREV_S" "$NEXT_S"; then
            ok "converged after $i round$([ "$i" -eq 1 ] && echo "" || echo "s")"
            cp "$NEXT_S" "${OUT}/stage2.s"
            link_cc "${OUT}/stage2.s" "${OUT}/stage2.bin"
            rm -f "${OUT}"/reseed_round*.s "${OUT}"/reseed_round*.bin
            ok "stage2 seeded from the self-hosted compiler"
            echo ""
            echo "Verify with a clean ./boot.sh (no args) and commit the new seed:"
            echo "  git add -f build/boot/stage2.s build/boot/stage2.bin && git commit"
            exit 0
        fi
        NEXT_BIN="${OUT}/reseed_round${i}.bin"
        link_cc "$NEXT_S" "$NEXT_BIN"
        PREV_S="$NEXT_S"
        PREV_BIN="$NEXT_BIN"
        i=$((i + 1))
    done
    rm -f "${OUT}"/reseed_round*.s "${OUT}"/reseed_round*.bin
    die "did not converge after ${MAX_SELF_ROUNDS} rounds — likely a genuinely new language construct the old seed can't parse at all (not just new behavior); land the syntax in two steps (teach the parser first, reseed, then use it) -- the archived Rust bootstrap can no longer parse the current source (see archive/rust-bootstrap-2026/README.md)"
fi

# ── Retired re-seed path: --bootstrap-from-rust (use --bootstrap-from-self) ─
if [ "$BOOTSTRAP" -eq 1 ]; then
    # It needed a single-file source and cannot lex today's compiler anyway.
    die "--bootstrap-from-rust is retired: use --bootstrap-from-self (history in archive/rust-bootstrap-2026/README.md)"
fi

# ── 1. stage1 from committed seed ────────────────────────────────────────
step "stage1: cc from committed stage2.s"
[ -f "${OUT}/stage2.s" ] || die "missing committed seed ${OUT}/stage2.s — restore it with: git checkout -- build/boot/stage2.s"
link_cc "${OUT}/stage2.s" "${OUT}/stage1.bin"
ok "stage1 linked"

# ── 2. stage1 -> stage2 (must reproduce the committed seed) ──────────────
step "stage2: stage1 compiles the selfhost source"
timeout "$STAGE_TIMEOUT" "${OUT}/stage1.bin" "$SRC" -o "${OUT}/stage2_gen.s" --emit-asm
[ -f "${OUT}/stage2_gen.s" ] || die "stage1 produced no output"
if cmp -s "${OUT}/stage2_gen.s" "${OUT}/stage2.s"; then
    HASH=$(sha256sum "${OUT}/stage2.s" | cut -c1-16)
    ok "reproduced committed seed exactly (sha256 ${HASH})"
else
    die "reproduced asm differs from committed seed — compiler source changed; reseed with: ./boot.sh --bootstrap-from-self, then commit the new seed"
fi
link_cc "${OUT}/stage2.s" "${OUT}/stage2.bin"
ok "stage2 linked"

# ── 3+4. stage2 -> stage3, fixed-point check ─────────────────────────────
step "stage3: stage2 compiles the selfhost source"
timeout "$STAGE_TIMEOUT" "${OUT}/stage2.bin" "$SRC" -o "${OUT}/stage3.s" --emit-asm
[ -f "${OUT}/stage3.s" ] || die "stage2 produced no output"
ok "stage3 emitted"

step "Fixed-point check: stage2 output == stage3 output"
if cmp -s "${OUT}/stage2.s" "${OUT}/stage3.s"; then
    HASH=$(sha256sum "${OUT}/stage2.s" | cut -c1-16)
    ok "deterministic (sha256 ${HASH})"
else
    diff "${OUT}/stage2.s" "${OUT}/stage3.s" | head -20 || true
    die "FIXED POINT BROKEN: stage2 and stage3 outputs differ"
fi

# ── smoke: stage2 CLI compiles, links and runs a program ─────────────────
step "Smoke: stage2 CLI compiles + links + runs"
cat > "${OUT}/smoke.zyl" <<'SMOKE_EOF'
(defn dbl (x) (* x 2))
(defn applyit (f v) (f v))
(defn main () (begin (print (applyit dbl 21)) (print (+ 1 2)) 0))
SMOKE_EOF
timeout 120 "${OUT}/stage2.bin" "${OUT}/smoke.zyl" -o "${OUT}/smoke.bin" >/dev/null
[ -x "${OUT}/smoke.bin" ] || die "smoke did not produce a linked binary"
RESULT="$("${OUT}/smoke.bin")"
[ "$RESULT" = "$(printf '42\n3')" ] || die "smoke output was '$RESULT'"
ok "smoke output correct ($RESULT)"

step "Generating build/boot/zyl-self wrapper"
cat > "${OUT}/zyl-self" <<'WRAPPER_EOF'
#!/usr/bin/env bash
# Cargo-free CLI wrapper: passes arguments straight to the self-hosted
# stage2 compiler, which handles compilation, linking and its own stdlib
# resolution (it chdirs to this directory).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/stage2.bin" "$@"
WRAPPER_EOF
chmod +x "${OUT}/zyl-self"
ok "zyl-self wrapper written"

step "Building zyl-lsp (LSP server)"
"${OUT}/stage2.bin" "${SCRIPT_DIR}/selfhost/lsp_main.zyl" -o "${OUT}/zyl-lsp" >/dev/null
[ -x "${OUT}/zyl-lsp" ] || die "zyl-lsp build failed"
ok "zyl-lsp linked"

# ── refresh an existing install so it never runs a stale stdlib ─────────
# ZYL_HOME may point at build/boot here, so the install location has its
# own variable. ZYL_NO_INSTALL_REFRESH=1 skips this.
INSTALL_HOME="${ZYL_INSTALL_HOME:-$HOME/.zyl}"
if [ -z "${ZYL_NO_INSTALL_REFRESH:-}" ] && [ -x "${INSTALL_HOME}/bin/zyl" ]; then
    step "Refreshing the install in ${INSTALL_HOME}"
    ZYL_HOME="$INSTALL_HOME" "${SCRIPT_DIR}/uninstall.sh" >/dev/null || die "uninstall.sh failed"
    ZYL_HOME="$INSTALL_HOME" "${SCRIPT_DIR}/install.sh" >/dev/null || die "install.sh failed"
    ok "install refreshed"
fi

echo ""
echo "Self-hosting verified: fixed point holds (no Rust in the build path)."