#!/usr/bin/env bash
# Zyl boot build + self-hosting fixed-point verification (cargo-free).
#
# Default flow — no Rust anywhere:
#   1. cc-links the committed seed build/boot/stage2.s -> stage1.bin
#   2. stage1 compiles the selfhost source  -> stage2.s (must byte-match seed)
#   3. stage2 compiles the selfhost source  -> stage3.s
#   4. stage3.s must be byte-identical to stage2.s (fixed point)
#   5. CLI smoke-test + cargo-free zyl-self wrapper
#
# Re-seeding (only needed when the compiler source changes the fixed point):
#   ./boot.sh --bootstrap-from-rust   rebuild stage2.s/ stage2.bin via the
#                                     still-archived Rust bootstrap, verify,
#                                     then re-commit the new seed.
#
# Artifacts land in build/boot/. Exit 0 only if the fixed point holds.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="${SCRIPT_DIR}/selfhost/zyl_selfhost_compiler.zyl"
OUT="${SCRIPT_DIR}/build/boot"
RUNTIME="${SCRIPT_DIR}/runtime/actor_runtime.c"
BOOTSTRAP=0
[ "${1:-}" = "--bootstrap-from-rust" ] && BOOTSTRAP=1

mkdir -p "$OUT"
cd "$SCRIPT_DIR"

step() { echo -e "\033[1;34m==>\033[0m $*"; }
ok()   { echo -e "  \033[0;32m✓\033[0m $*"; }
die()  { echo -e "  \033[0;31m✗\033[0m $*"; exit 1; }

link_cc() { # link_cc <asm> <out-bin>
    cc -no-pie "$1" "$RUNTIME" -o "$2" -lpthread
}

# ── Re-seed path: Rust bootstrap -> fresh stage2 ─────────────────────────
if [ "$BOOTSTRAP" -eq 1 ]; then
    step "Bootstrap: rebuilding stage2 seed from the Rust bootstrap"
    cargo build --release --quiet
    ZYL="${SCRIPT_DIR}/target/release/zyl"
    [ -x "$ZYL" ] || die "Rust bootstrap not found at $ZYL"
    step "stage1: Rust bootstrap -> selfhost binary"
    "$ZYL" "$SRC" -o "$OUT/stage1" >/dev/null
    [ -f "${OUT}/stage1.s" ] || die "stage1 did not emit ${OUT}/stage1.s"
    link_cc "${OUT}/stage1.s" "${OUT}/stage1.bin"
    ok "stage1 linked (Rust-built entry is argv-blind; uses legacy /tmp protocol)"
    # Rust-built stage1 has no argv plumbing yet, so feed it via the legacy
    # fixed-path protocol. The generated stage2/s carries the real CLI stub.
    cp "$SRC" /tmp/zyl_boot_in.zyl
    rm -f /tmp/zyl_boot_out.s
    timeout 600 setarch -R "${OUT}/stage1.bin" >/dev/null
    [ -f /tmp/zyl_boot_out.s ] || die "stage1 produced no output"
    mv /tmp/zyl_boot_out.s "${OUT}/stage2.s"
    link_cc "${OUT}/stage2.s" "${OUT}/stage2.bin"
    ok "stage2 seeded from Rust bootstrap"
    echo ""
    echo "Verify with a clean ./boot.sh (no args) and commit the new seed:"
    echo "  git add -f build/boot/stage2.s build/boot/stage2.bin && git commit"
    exit 0
fi

# ── 1. stage1 from committed seed ────────────────────────────────────────
step "stage1: cc from committed stage2.s"
[ -f "${OUT}/stage2.s" ] || die "missing committed seed ${OUT}/stage2.s — run ./boot.sh --bootstrap-from-rust first"
link_cc "${OUT}/stage2.s" "${OUT}/stage1.bin"
ok "stage1 linked"

# ── 2. stage1 -> stage2 (must reproduce the committed seed) ──────────────
step "stage2: stage1 compiles the selfhost source"
timeout 600 setarch -R "${OUT}/stage1.bin" "$SRC" -o "${OUT}/stage2_gen.s" --emit-asm
[ -f "${OUT}/stage2_gen.s" ] || die "stage1 produced no output"
if cmp -s "${OUT}/stage2_gen.s" "${OUT}/stage2.s"; then
    HASH=$(sha256sum "${OUT}/stage2.s" | cut -c1-16)
    ok "reproduced committed seed exactly (sha256 ${HASH})"
else
    die "reproduced asm differs from committed seed — compiler source changed; re-seed with --bootstrap-from-rust and commit the new seed"
fi
link_cc "${OUT}/stage2.s" "${OUT}/stage2.bin"
ok "stage2 linked"

# ── 3+4. stage2 -> stage3, fixed-point check ─────────────────────────────
step "stage3: stage2 compiles the selfhost source"
timeout 600 setarch -R "${OUT}/stage2.bin" "$SRC" -o "${OUT}/stage3.s" --emit-asm
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
cat > /tmp/zyl_smoke.zyl <<'SMOKE_EOF'
(defn dbl (x) (* x 2))
(defn applyit (f v) (f v))
(defn main () (begin (print (applyit dbl 21)) (print (+ 1 2)) 0))
SMOKE_EOF
timeout 120 setarch -R "${OUT}/stage2.bin" /tmp/zyl_smoke.zyl -o "${OUT}/smoke.bin" >/dev/null
[ -x "${OUT}/smoke.bin" ] || die "smoke did not produce a linked binary"
RESULT="$(setarch -R "${OUT}/smoke.bin")"
[ "$RESULT" = "$(printf '42\n3')" ] || die "smoke output was '$RESULT'"
ok "smoke output correct ($RESULT)"

step "Generating build/boot/zyl-self wrapper"
cp -R "${SCRIPT_DIR}/stdlib" "${OUT}/stdlib"
cp "${SCRIPT_DIR}/runtime/actor_runtime.c" "${OUT}/actor_runtime.c"
cp "${SCRIPT_DIR}/runtime/actor_runtime.h" "${OUT}/actor_runtime.h"
cat > "${OUT}/zyl-self" <<'WRAPPER_EOF'
#!/usr/bin/env bash
# Cargo-free CLI wrapper: passes arguments straight to the self-hosted
# stage2 compiler, which handles compilation, linking and its own stdlib
# resolution (it chdirs to this directory).
# setarch -R disables ASLR for the big worker stack (see runtime/README or
# docs/rust-eviction-plan.md).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec setarch -R "$SCRIPT_DIR/stage2.bin" "$@"
WRAPPER_EOF
chmod +x "${OUT}/zyl-self"
ok "zyl-self wrapper written"

echo ""
echo "Self-hosting verified: fixed point holds (no Rust in the build path)."