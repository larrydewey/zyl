#!/usr/bin/env bash
# Assembles the GitHub Pages site: the landing page at the root and the book under book/.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
out=${1:-$root/build/site}

case "$out" in
    ""|"/"|"$root") echo "refusing to use $out as the output directory" >&2; exit 1 ;;
esac

rm -rf "$out"
mkdir -p "$out"
cp "$root/site/index.html" "$root/site/404.html" "$out/"
cp -R "$root/site/assets" "$out/assets"
mdbook build "$root/book" -d "$out/book"
# Pages must serve the files as they are, without Jekyll.
touch "$out/.nojekyll"
echo "site written to $out"
