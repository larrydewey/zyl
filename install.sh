#!/usr/bin/env bash
# Installs the Zyl compiler + REPL into a standard per-user location
# (~/.zyl, or $ZYL_HOME if set), so both work from any directory
# without needing to sit next to a build/boot/ checkout. This is the
# install path selfhost/driver.zyl's cli-resolve-bundledir and
# tools/repl.zyl's repl-resolve-bundledir look for first, ahead of the
# argv0-relative fallback used for this repo's own dev workflow.
#
# Not wired into ./boot.sh on purpose: boot.sh builds and verifies the
# compiler for THIS checkout; installing it system-/user-wide is a
# separate, opt-in step.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${ZYL_HOME:-$HOME/.zyl}"

# Guard against a mistyped/misexported ZYL_HOME turning `rm -rf "$TARGET/..."`
# below into something catastrophic (empty, "/", or a bare non-absolute path
# all resolve to places you do not want wiped).
case "$TARGET" in
    ""|/|"$HOME")
        echo "error: refusing unsafe install target: '$TARGET'" >&2
        exit 1
        ;;
    /*) ;;
    *)
        echo "error: ZYL_HOME must be an absolute path, got: '$TARGET'" >&2
        exit 1
        ;;
esac

[ -f "$SCRIPT_DIR/build/boot/stage2.bin" ] || {
    echo "error: build/boot/stage2.bin missing -- run ./boot.sh first" >&2
    exit 1
}

echo "Installing to $TARGET"
mkdir -p "$TARGET/bin"
rm -rf "$TARGET/stdlib"
cp -r "$SCRIPT_DIR/stdlib" "$TARGET/stdlib"
cp "$SCRIPT_DIR/runtime/actor_runtime.c" "$SCRIPT_DIR/runtime/actor_runtime.h" "$TARGET/"
cp "$SCRIPT_DIR/build/boot/stage2.bin" "$TARGET/bin/stage2.bin"

echo "Building the REPL..."
"$TARGET/bin/stage2.bin" "$SCRIPT_DIR/tools/repl.zyl" -o "$TARGET/bin/zyl-repl-bin"

cat > "$TARGET/bin/zyl" <<WRAPPER
#!/usr/bin/env bash
# No arguments: start the REPL, same as \`python\`/\`node\` with no args --
# this is purely a shell-level dispatch (the compiled zyl binary itself
# has no notion of a REPL; tools/repl.zyl is an entirely separate
# compiled program), so it costs nothing to change and touches neither
# driver.zyl nor boot.sh's own direct stage1.bin/stage2.bin invocations.
set -euo pipefail
if [ \$# -eq 0 ]; then
    exec "$TARGET/bin/zyl-repl-bin"
else
    exec "$TARGET/bin/stage2.bin" "\$@"
fi
WRAPPER
chmod +x "$TARGET/bin/zyl"

cat > "$TARGET/bin/zyl-repl" <<WRAPPER
#!/usr/bin/env bash
set -euo pipefail
exec "$TARGET/bin/zyl-repl-bin" "\$@"
WRAPPER
chmod +x "$TARGET/bin/zyl-repl"

# Shell env snippets, rustup/go-style: written to disk, never auto-
# appended to the user's own rc files. bash and zsh share `export`
# syntax; fish's is genuinely different (`set -gx`), so it gets its own
# file rather than a shared one with a conditional inside it.
cat > "$TARGET/env" <<ENVFILE
# source this file (or add the line below to your shell rc) to use zyl
export PATH="$TARGET/bin:\$PATH"
ENVFILE

cat > "$TARGET/env.fish" <<ENVFILE
# source this file (or add the line below to your fish config) to use zyl
set -gx PATH "$TARGET/bin" \$PATH
ENVFILE

echo
echo "Installed: $TARGET/bin/zyl, $TARGET/bin/zyl-repl"
echo

case "$(basename "${SHELL:-bash}")" in
    fish)
        echo "Add this to ~/.config/fish/config.fish:"
        echo "  source $TARGET/env.fish"
        ;;
    *)
        echo "Add this to your shell's rc file (~/.bashrc, ~/.zshrc, ...):"
        echo "  source $TARGET/env"
        ;;
esac
echo "Or just run that command directly to use zyl in this shell session."
