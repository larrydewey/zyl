#!/usr/bin/env bash
# Zyl boot build + self-hosting fixed-point verification.
#
# Builds the full bootstrap chain and verifies determinism:
#   1. Rust bootstrap compiles the selfhost source  -> stage1 (binary)
#   2. stage1 compiles the selfhost source          -> stage2 (binary)
#   3. stage2 compiles the selfhost source          -> stage3 asm
#   4. stage3 asm must be byte-identical to stage2's asm (fixed point)
#
# Usage:
#   ./boot.sh              full build + verification
#   ./boot.sh --skip-rust  reuse existing target/release/zyl
#
# Artifacts land in build/boot/. Exit 0 only if the fixed point holds.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="${SCRIPT_DIR}/selfhost/zyl_selfhost_compiler.zyl"
OUT="${SCRIPT_DIR}/build/boot"
RUNTIME="${SCRIPT_DIR}/src/runtime/actor_runtime.c"
SKIP_RUST=0
[ "${1:-}" = "--skip-rust" ] && SKIP_RUST=1

mkdir -p "$OUT"
cd "$SCRIPT_DIR"

step() { echo -e "\033[1;34m==>\033[0m $*"; }
ok()   { echo -e "  \033[0;32m✓\033[0m $*"; }
die()  { echo -e "  \033[0;31m✗\033[0m $*"; exit 1; }

link_cc() { # link_cc <asm> <out-bin>
    cc -no-pie "$1" "$RUNTIME" -o "$2" -lpthread
}

# ── 1. Rust bootstrap -> stage1 ──────────────────────────────────────────
if [ "$SKIP_RUST" -eq 0 ]; then
    step "Building Rust bootstrap compiler"
    cargo build --release --quiet
fi
ZYL="${SCRIPT_DIR}/target/release/zyl"
[ -x "$ZYL" ] || die "Rust compiler not found at $ZYL"

step "stage1: Rust compiler -> selfhost binary"
"$ZYL" "$SRC" -o "$OUT/stage1" >/dev/null
[ -f "${OUT}/stage1.s" ] || die "stage1 did not emit ${OUT}/stage1.s"
link_cc "${OUT}/stage1.s" "${OUT}/stage1.bin"
ok "stage1 linked"

# ── 2. stage1 -> stage2 ─────────────────────────────────────────────────
step "stage2: stage1 compiles the selfhost source"
cp "$SRC" /tmp/zyl_boot_in.zyl
rm -f /tmp/zyl_boot_out.s
timeout 600 "${OUT}/stage1.bin" >/dev/null
[ -f /tmp/zyl_boot_out.s ] || die "stage1 produced no output"
mv /tmp/zyl_boot_out.s "${OUT}/stage2.s"
link_cc "${OUT}/stage2.s" "${OUT}/stage2.bin"
ok "stage2 linked"

# ── 3+4. stage2 -> stage3, fixed-point check ────────────────────────────
step "stage3: stage2 compiles the selfhost source"
cp "$SRC" /tmp/zyl_boot_in.zyl
rm -f /tmp/zyl_boot_out.s
timeout 600 "${OUT}/stage2.bin" >/dev/null
[ -f /tmp/zyl_boot_out.s ] || die "stage2 produced no output"
mv /tmp/zyl_boot_out.s "${OUT}/stage3.s"
ok "stage3 emitted"

step "Fixed-point check: stage2 output == stage3 output"
if cmp -s "${OUT}/stage2.s" "${OUT}/stage3.s"; then
    HASH=$(sha256sum "${OUT}/stage2.s" | cut -c1-16)
    ok "deterministic (sha256 ${HASH})"
else
    diff "${OUT}/stage2.s" "${OUT}/stage3.s" | head -20 || true
    die "FIXED POINT BROKEN: stage2 and stage3 outputs differ"
fi

# ── smoke: compiled-by-stage2 program runs correctly ─────────────────────
step "Smoke: stage2-compiled program runs"
printf '(defn dbl (x) (* x 2))\n(defn applyit (f v) (f v))\n(defn main () (begin (print (applyit dbl 21)) (print (+ 1 2)) 0))\n' > /tmp/zyl_boot_in.zyl
rm -f /tmp/zyl_boot_out.s
timeout 120 "${OUT}/stage2.bin" >/dev/null
link_cc /tmp/zyl_boot_out.s "${OUT}/smoke.bin"
RESULT="$("${OUT}/smoke.bin")"
[ "$RESULT" = "$(printf '42\n3')" ] || die "smoke output was '$RESULT', expected '42 3'"
ok "smoke output correct ($RESULT)"

echo ""
echo "Self-hosting verified: fixed point holds."
