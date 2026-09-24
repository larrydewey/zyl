#!/usr/bin/env bash
# A local package index end to end: `zyl publish --index` archives, signs
# and commits a package into a git index; with ZYL_INDEX pointing there,
# `zyl fetch` verifies and stores it and `zyl build` links it; the build's
# .buildinfo records the resolved graph; republishing a version fails.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
Z="$ROOT/build/boot/stage2.bin"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_index_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
command -v git >/dev/null || { echo "ok (git not installed; skipped)"; exit 0; }

# A private HOME: its ~/.zyl holds this test's store, keys and index clone.
export HOME="$SCRATCH/home"
unset ZYL_HOME
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
mkdir -p "$HOME" "$SCRATCH/lib" "$SCRATCH/app" "$SCRATCH/index"
git -C "$SCRATCH/index" init -q
git -C "$SCRATCH/index" commit -q --allow-empty -m init

cat > "$SCRATCH/lib/zyl.pkg" <<'PKG'
(package (name "acme/greet") (version "1.0.0") (zyl "5.0") (edition "2026"))
PKG
cat > "$SCRATCH/lib/greet.zyl" <<'ZYL'
(pub defn greeting () "hello from the index")
ZYL
(cd "$SCRATCH/lib" && "$Z" key >/dev/null && "$Z" publish --index "$SCRATCH/index" >/dev/null) || fail "publish"
[ -f "$SCRATCH/index/ac/me/acme/greet.zyl" ] || fail "index entry written"
git -C "$SCRATCH/index" log --oneline | grep -q "publish acme/greet 1.0.0" || fail "index commit"

again="$(cd "$SCRATCH/lib" && "$Z" publish --index "$SCRATCH/index" 2>&1 || true)"
echo "$again" | grep -q E_PKG_VERSION_EXISTS || fail "republishing a version must be E_PKG_VERSION_EXISTS"

cat > "$SCRATCH/app/zyl.pkg" <<'PKG'
(package (name "app/hello") (version "0.1.0") (zyl "5.0") (edition "2026")
  (capabilities io)
  (deps (dep "acme/greet" "1.0.0")))
PKG
cat > "$SCRATCH/app/hello.zyl" <<'ZYL'
(use acme/greet { greeting })
(defn main () (begin (print (greeting)) 0))
ZYL
export ZYL_INDEX="$SCRATCH/index"
(cd "$SCRATCH/app" && "$Z" fetch >/dev/null 2>&1) || fail "fetch"
(cd "$SCRATCH/app" && "$Z" build >/dev/null 2>&1) || fail "build"
[ "$("$SCRATCH/app/hello")" = "hello from the index" ] || fail "run"
grep -q '(package "acme/greet" "1.0.0" "blake3:' "$SCRATCH/app/hello.buildinfo" || fail "graph in buildinfo"
echo "ok"
