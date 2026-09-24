#!/usr/bin/env bash
# `zyl build` caches a package build by the content hash of its inputs
# (spec 31.4): a second build of unchanged sources is copied from the cache
# (same bytes, no compile), an edited source misses it, and
# ZYL_NO_BUILD_CACHE=1 bypasses it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
Z="$ROOT/build/boot/stage2.bin"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_cache_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

export HOME="$SCRATCH/home"
unset ZYL_HOME ZYL_NO_BUILD_CACHE
mkdir -p "$HOME" "$SCRATCH/app"
cat > "$SCRATCH/app/zyl.pkg" <<'PKG'
(package (name "app/cached") (version "0.1.0") (zyl "5.0") (edition "2026") (capabilities io))
PKG
cat > "$SCRATCH/app/cached.zyl" <<'ZYL'
(defn main () (begin (print 1) 0))
ZYL
cd "$SCRATCH/app"
"$Z" build >/dev/null
[ "$(./cached)" = "1" ] || fail "first build runs"
entries=$(ls "$HOME/.zyl/cache" | wc -l)
[ "$entries" = "1" ] || fail "one cache entry after the first build (got $entries)"
cp cached first.bin
rm -f cached.s
"$Z" build >/dev/null
[ ! -f cached.s ] || fail "an unchanged build must come from the cache (no assembly written)"
cmp -s cached first.bin || fail "the cached binary is the same bytes"

echo '(defn main () (begin (print 2) 0))' > cached.zyl
"$Z" build >/dev/null
[ "$(./cached)" = "2" ] || fail "an edited source rebuilds"
[ "$(ls "$HOME/.zyl/cache" | wc -l)" = "2" ] || fail "a second key after the edit"

rm -f cached.s
ZYL_NO_BUILD_CACHE=1 "$Z" build >/dev/null
[ -f cached.s ] || fail "ZYL_NO_BUILD_CACHE compiles"
echo "ok"
