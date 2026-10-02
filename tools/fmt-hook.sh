#!/bin/sh
# Reject a commit whose staged .zyl files are not formatted.
#
# Install with:  ln -sf "$PWD/tools/fmt-hook.sh" .git/hooks/pre-commit
#
# --check, not a rewrite: a hook that reformats your files as a side effect of
# committing is a hook you will disable, and then the formatting is gone for
# good. This tells you what to run instead.
set -e
cd "$(git rev-parse --show-toplevel)"
export ZYL_HOME="$PWD/build/boot"
ZYL="$PWD/build/boot/zyl-self"
[ -x "$ZYL" ] || { echo "fmt: no compiler at $ZYL -- run ./boot.sh first"; exit 1; }

files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.zyl$' || true)
[ -n "$files" ] || exit 0

if ! "$ZYL" fmt --check $files; then
  echo
  echo "  Not formatted. Run:  zyl fmt $files"
  exit 1
fi
