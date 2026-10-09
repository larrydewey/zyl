#!/usr/bin/env bash
# `zyl balance --fix`: forms closed from their indentation; a property over
# real files (delete or add one closer, the fix restores it); and agreement:
# `zyl check`, `zyl balance` and the fix read every mutation the same way.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_balance_fix.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

expect() {  # name, broken text, fixed text
    printf '%b' "$2" > "$SCRATCH/$1.zyl"
    "$ZYL" balance --fix "$SCRATCH/$1.zyl" > "$SCRATCH/$1.out" 2>&1 || fail "$1: $(cat "$SCRATCH/$1.out")"
    [ "$(cat "$SCRATCH/$1.zyl")" = "$(printf '%b' "$3")" ] || fail "$1: got $(cat "$SCRATCH/$1.zyl")"
}
expect missing '(defn f (x)\n  (let a 1\n    (+ a x)\n\n(defn main ()\n  (begin (print (f 2)) 0))\n' \
               '(defn f (x)\n  (let a 1\n    (+ a x)))\n\n(defn main ()\n  (begin (print (f 2)) 0))\n'
expect extra   '(defn f (x)\n  (+ x 1))))\n\n(defn main () 0)\n' '(defn f (x)\n  (+ x 1))\n\n(defn main () 0)\n'
expect midline '(defn f (x)\n  (if (> x 0)\n      (g x\n      0)) ; tail\n(defn g (y) y)\n' \
               '(defn f (x)\n  (if (> x 0)\n      (g x)\n      0)) ; tail\n(defn g (y) y)\n'
expect string  '(defn f (x) "a (string\n(" x)\n(defn main () (f 1\n' '(defn f (x) "a (string\n(" x)\n(defn main () (f 1))\n'
expect flat    '(defn k (a)\n  (if (= a 1) 10\n  (if (= a 2) 20\n  (if (= a 3) 30\n      0)))\n' \
               '(defn k (a)\n  (if (= a 1) 10\n  (if (= a 2) 20\n  (if (= a 3) 30\n      0))))\n'

printf '(defn ok () 1)\n' > "$SCRATCH/balanced.zyl"
"$ZYL" balance --fix "$SCRATCH/balanced.zyl" | grep -q "every file balances" || fail "a balanced file"
printf '(defn f () "open\n' > "$SCRATCH/hopeless.zyl"
if "$ZYL" balance --fix "$SCRATCH/hopeless.zyl" > "$SCRATCH/h.out" 2>&1; then fail "an unterminated string was fixed"; fi
grep -q "does not say how to balance" "$SCRATCH/h.out" || fail "hopeless: $(cat "$SCRATCH/h.out")"
[ "$(cat "$SCRATCH/hopeless.zyl")" = '(defn f () "open' ] || fail "hopeless file was written"

# Property: one closer deleted from, or added to, a line end of a real file.
python3 - "$ROOT" "$SCRATCH" <<'PY'
import glob, random, re, sys
root, out = sys.argv[1], sys.argv[2]
random.seed(7)
files = sorted(glob.glob(root + '/stdlib/**/*.zyl', recursive=True))
k = 0
while k < 80:
    src = open(random.choice(files)).read(); lines = src.split('\n')
    cand = [i for i, l in enumerate(lines) if re.search(r'\)\s*$', l) and '"' not in l and ';' not in l and not l.startswith('(')]
    if not cand: continue
    i = random.choice(cand); j = lines[i].rstrip().rfind(')')
    lines[i] = lines[i][:j] + ('' if k % 2 == 0 else '))') + lines[i][j + 1:]
    open(f'{out}/p{k}.zyl', 'w').write('\n'.join(lines)); open(f'{out}/p{k}.orig', 'w').write(src); k += 1
PY
"$ZYL" balance --fix "$SCRATCH"/p*.zyl > "$SCRATCH/p.out" 2>&1 || fail "property: a mutation was left unbalanced: $(grep -v 'closed forms' "$SCRATCH/p.out")"
same=0
for f in "$SCRATCH"/p*.zyl; do
    [ "$(tr -d ' \n\t' < "$f")" = "$(tr -d ' \n\t' < "${f%.zyl}.orig")" ] && same=$((same + 1))
done
[ "$same" -ge 76 ] || fail "property: only $same of 80 mutations restored"
# Agreement: check reports the same balance code as balance; the fix never
# touches a file balance accepts and never writes one it rejects. Mutations
# include brackets inside strings and comments, which all three must skip.
python3 - "$ROOT" "$SCRATCH" <<'PY'
import glob, random, re, sys
root, out = sys.argv[1], sys.argv[2]
random.seed(11)
files = sorted(glob.glob(root + '/stdlib/**/*.zyl', recursive=True))
kinds = ['del', 'add', 'swap', 'col1', 'strparen', 'commentparen', 'delquote']
k = 0
while k < 70:
    src = open(random.choice(files)).read(); L = src.split('\n'); kind = kinds[k % len(kinds)]
    idx = list(range(len(L))); random.shuffle(idx); done = False
    for i in idx:
        l = L[i]
        plain = re.search(r'\)\s*$', l) and ';' not in l and '"' not in l and not l.startswith('(')
        if kind in ('del', 'add', 'swap') and plain:
            j = l.rstrip().rfind(')')
            L[i] = l[:j] + {'del': '', 'add': '))', 'swap': ']'}[kind] + l[j + 1:]; done = True
        elif kind == 'col1' and l.startswith('  ('):
            L[i] = l.lstrip(); done = True
        elif kind == 'strparen' and ';' not in l and re.search(r'"[a-z ]+"', l):
            m = re.search(r'"[a-z ]+"', l); L[i] = l[:m.start() + 1] + '(]' + l[m.start() + 1:]; done = True
        elif kind == 'commentparen' and l.strip().startswith(';'):
            L[i] = l + ' (unclosed ['; done = True
        elif kind == 'delquote' and l.count('"') >= 2 and ';' not in l and '\\' not in l:
            j = l.find('"'); L[i] = l[:j] + l[j + 1:]; done = True
        if done: break
    if done:
        open(f'{out}/a{k:02d}.zyl', 'w').write('\n'.join(L)); k += 1
PY
for f in "$SCRATCH"/a*.zyl; do
    b=$("$ZYL" balance "$f" 2>&1 | grep -o 'error\[E_[A-Z_]*\]' | head -1 || true)
    c=$("$ZYL" check "$f" 2>&1 | grep -o 'error\[E_UN[A-Z_]*\]' | head -1 || true)
    [ "$b" = "$c" ] || fail "agreement: balance says '$b', check says '$c' for $(head -c 0 "$f")$f"
    g="${f%.zyl}_fixed.zyl"; cp "$f" "$g"
    "$ZYL" balance --fix "$g" > /dev/null 2>&1 || true
    if [ -z "$b" ] && ! cmp -s "$f" "$g"; then fail "agreement: the fix changed a balanced file $f"; fi
    if ! cmp -s "$f" "$g" && ! "$ZYL" balance "$g" > /dev/null 2>&1; then fail "agreement: the fix wrote an unbalanced $g"; fi
done
echo "balance-fix: ok ($same/80 restored; check, balance and the fix agree on 70 mutations)"
