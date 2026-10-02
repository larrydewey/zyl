#!/bin/sh
# zyl fmt: indentation is recovered exactly, and --check refuses to write.
set -e
ZYL="$PWD/build/boot/zyl-self"
export ZYL_HOME="$PWD/build/boot"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT

cp "$PWD/tests/explain_test.zyl" "$T/a.zyl"
"$ZYL" fmt --check "$T/a.zyl" >/dev/null
echo "ok 1 -- already-formatted source is left alone"

sed 's/^[[:space:]]*//' "$PWD/tests/explain_test.zyl" > "$T/b.zyl"
if "$ZYL" fmt --check "$T/b.zyl" >/dev/null; then
  echo "not ok 2 -- --check accepted a misformatted file"; exit 1
fi
echo "ok 2 -- --check rejects a misformatted file"

cmp -s "$T/b.zyl" <(sed 's/^[[:space:]]*//' "$PWD/tests/explain_test.zyl") \
  || { echo "not ok 3 -- --check wrote to the file"; exit 1; }
echo "ok 3 -- --check reports without writing"

"$ZYL" fmt "$T/b.zyl" >/dev/null
cmp -s "$T/a.zyl" "$T/b.zyl" \
  || { echo "not ok 4 -- fmt did not restore the original indentation"; exit 1; }
echo "ok 4 -- fmt restores indentation exactly"

"$ZYL" fmt --check "$T/b.zyl" >/dev/null
echo "ok 5 -- fmt is idempotent"

# Indentation only: a paren inside a string must not change the depth.
printf '(defn f ()\n(print "("))\n(main (f))\n' > "$T/c.zyl"
"$ZYL" fmt "$T/c.zyl" >/dev/null
grep -q '^  (print "(")' "$T/c.zyl" \
  || { echo "not ok 6 -- a paren in a string changed the indentation"; exit 1; }
echo "ok 6 -- a paren inside a string is not counted"

# A paren in a COMMENT must not change the depth either. This one cost a real
# file: a comment mentioning `(checked via ...` left the depth one too high for
# every line after it, so fmt reindented the rest of the file -- and because
# spec 1.6 wants a top-level form in column 1 and no nested opener in it, the
# file stopped balancing. Indentation-only is not the same as harmless.
printf '; a comment with (an open paren\n(defn f ()\n  (print 1))\n(main (f))\n' > "$T/d.zyl"
"$ZYL" fmt "$T/d.zyl" >/dev/null
cmp -s "$T/d.zyl" <(printf '; a comment with (an open paren\n(defn f ()\n  (print 1))\n(main (f))\n') \
  || { echo "not ok 7 -- a paren in a comment changed the indentation"; exit 1; }
build/boot/zyl-self balance "$T/d.zyl" >/dev/null 2>&1 \
  || { echo "not ok 8 -- fmt left the file unbalanced"; exit 1; }
echo "ok 7 -- a paren inside a comment is not counted"
echo "ok 8 -- formatting a commented file leaves it balanced"

echo "all fmt tests passed"
