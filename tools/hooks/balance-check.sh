#!/usr/bin/env bash
# Claude Code PostToolUse hook: runs `zyl balance` on the .zyl files a tool
# call touched (the edited file, or after a shell command every changed
# .zyl file in the checkout) and, on a fault, returns the located report
# to the agent (exit 2). Never count delimiters by hand or with a script.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
ZYL="$ROOT/build/boot/zyl-self"
[ -x "$ZYL" ] || ZYL="$(command -v zyl || true)"
[ -n "$ZYL" ] || exit 0
input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)"
files=()
case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    f="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
    case "$f" in */tests/compile-fail/*) ;; *.zyl) [ -f "$f" ] && files+=("$f") ;; esac ;;
  Bash)
    while IFS= read -r f; do [ -f "$ROOT/$f" ] && files+=("$ROOT/$f"); done < <(
      git -C "$ROOT" status --porcelain --untracked-files=all -- '*.zyl' 2>/dev/null |
        grep -v '^ *D' | sed 's/^...//; s/.* -> //' | grep -v '^tests/compile-fail/' ) ;;
esac
[ "${#files[@]}" -eq 0 ] && exit 0
if ! out="$(ZYL_HOME="$ROOT/build/boot" "$ZYL" balance "${files[@]}" 2>&1)"; then
  printf '%s\n' "$out" >&2
  exit 2
fi
exit 0
