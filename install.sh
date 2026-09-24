#!/usr/bin/env bash
# Installs the Zyl compiler, REPL and language server into a standard
# per-user location (~/.zyl, or $ZYL_HOME if set), so all three work
# from any directory without needing to sit next to a build/boot/
# checkout. This is the install path selfhost/driver.zyl's
# cli-resolve-bundledir and tools/repl.zyl's repl-resolve-bundledir look
# for first, ahead of the argv0-relative fallback used for this repo's
# own dev workflow.
#
# Not wired into ./boot.sh on purpose: boot.sh builds and verifies the
# compiler for THIS checkout; installing it system-/user-wide is a
# separate, opt-in step.
#
# Usage:
#   ./install.sh                 compiler + REPL + language server
#   ./install.sh --with-vscode   the above, plus the VS Code extension
#   ./install.sh --help
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${ZYL_HOME:-$HOME/.zyl}"
WITH_VSCODE=0

while [ $# -gt 0 ]; do
    case "$1" in
        --with-vscode) WITH_VSCODE=1; shift ;;
        -h|--help)
            sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "error: unknown option '$1' (try --help)" >&2
            exit 1
            ;;
    esac
done

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

# Both tools below are compiled BY the compiler just installed, against
# the stdlib just copied -- so they are built from exactly the sources
# this install ships, not from whatever build/boot happened to hold.
# ZYL_HOME is set explicitly for the same reason boot.sh sets it: an
# older populated ~/.zyl would otherwise win the bundledir search and
# silently compile these against stale stdlib sources.
echo "Building the REPL..."
ZYL_HOME="$TARGET" "$TARGET/bin/stage2.bin" "$SCRIPT_DIR/tools/repl.zyl" -o "$TARGET/bin/zyl-repl-bin"

echo "Building the language server..."
ZYL_HOME="$TARGET" "$TARGET/bin/stage2.bin" "$SCRIPT_DIR/selfhost/lsp_main.zyl" -o "$TARGET/bin/zyl-lsp-bin"

cat > "$TARGET/bin/zyl" <<WRAPPER
#!/usr/bin/env bash
# No arguments: start the REPL, same as \`python\`/\`node\` with no args --
# this is purely a shell-level dispatch to zyl-repl-bin, the separately
# compiled tools/repl.zyl. (The compiler binary has its own REPL too,
# \`zyl repl\`, which this passes through like any other subcommand.)
# It costs nothing to change and touches neither driver.zyl nor boot.sh's
# own direct stage1.bin/stage2.bin invocations.
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

cat > "$TARGET/bin/zyl-lsp" <<WRAPPER
#!/usr/bin/env bash
# Language server, JSON-RPC over stdio. Editors start this; there is
# nothing useful to see if you run it by hand.
set -euo pipefail
exec "$TARGET/bin/zyl-lsp-bin" "\$@"
WRAPPER
chmod +x "$TARGET/bin/zyl-lsp"

# Does the installed server actually answer? One real `initialize`
# request over the real transport, which is the same thing an editor
# does first -- an installed binary that cannot do this is worth
# finding out about now rather than the first time an editor is opened.
echo "Checking the language server responds..."
LSP_PROBE='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":null,"capabilities":{}}}'
LSP_EXIT='{"jsonrpc":"2.0","method":"exit","params":{}}'
lsp_frame() { printf 'Content-Length: %d\r\n\r\n%s' "${#1}" "$1"; }
if { lsp_frame "$LSP_PROBE"; lsp_frame "$LSP_EXIT"; } \
        | "$TARGET/bin/zyl-lsp" 2>/dev/null \
        | grep -q '"Zyl Language Server"'; then
    echo "  language server OK"
else
    echo "  WARNING: the language server did not answer an initialize request." >&2
    echo "  Editor features will not work. Try ./boot.sh, then re-run this script." >&2
fi

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

# The VS Code extension, only when asked for: it needs npm (which
# downloads packages) and a `code` on PATH, neither of which a compiler
# install should assume or invoke behind your back.
if [ "$WITH_VSCODE" -eq 1 ]; then
    EXT_DIR="$SCRIPT_DIR/editors/vscode"
    echo
    echo "Installing the VS Code extension from $EXT_DIR"
    if ! command -v npm >/dev/null 2>&1; then
        echo "  error: npm not found; install Node.js or skip --with-vscode" >&2
        exit 1
    fi
    ( cd "$EXT_DIR" && npm install --silent && npm run --silent compile )
    if command -v code >/dev/null 2>&1; then
        VSIX_DIR="$(mktemp -d)"
        # vsce is a devDependency, so the `npm install` above provides it;
        # stdin from /dev/null keeps any prompt from hanging the install.
        ( cd "$EXT_DIR" && npx vsce package --out "$VSIX_DIR/zyl.vsix" </dev/null >/dev/null )
        # 0.1.0 shipped as zyl-lang.zyl-lang (grammar only, no language
        # client); it claims the same language id, so it has to go.
        if code --list-extensions 2>/dev/null | grep -qx 'zyl-lang.zyl-lang'; then
            code --uninstall-extension zyl-lang.zyl-lang >/dev/null
        fi
        code --install-extension "$VSIX_DIR/zyl.vsix" --force
        rm -rf "$VSIX_DIR"
        echo "  extension installed; reload VS Code to pick it up"
    else
        # No `code` on PATH: link the built extension into the standard
        # extensions directory instead. It keeps working as long as this
        # checkout stays where it is, which is what a developer wants
        # anyway.
        mkdir -p "$HOME/.vscode/extensions"
        ln -sfn "$EXT_DIR" "$HOME/.vscode/extensions/zyl-lang"
        echo "  no 'code' command found; linked into ~/.vscode/extensions/zyl-lang"
    fi
fi

echo
echo "Installed:"
echo "  $TARGET/bin/zyl        compiler (no arguments: REPL)"
echo "  $TARGET/bin/zyl-repl   REPL"
echo "  $TARGET/bin/zyl-lsp    language server, for editors"
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
