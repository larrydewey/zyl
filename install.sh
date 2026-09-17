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

cat > "$TARGET/bin/zyl" <<WRAPPER
#!/usr/bin/env bash
# setarch -R disables ASLR for the big worker stack (see runtime/README).
set -euo pipefail
exec setarch -R "$TARGET/bin/stage2.bin" "\$@"
WRAPPER
chmod +x "$TARGET/bin/zyl"

echo "Building the REPL..."
"$TARGET/bin/zyl" "$SCRIPT_DIR/tools/repl.zyl" -o "$TARGET/bin/zyl-repl-bin"

cat > "$TARGET/bin/zyl-repl" <<WRAPPER
#!/usr/bin/env bash
set -euo pipefail
exec setarch -R "$TARGET/bin/zyl-repl-bin" "\$@"
WRAPPER
chmod +x "$TARGET/bin/zyl-repl"

echo
echo "Installed: $TARGET/bin/zyl, $TARGET/bin/zyl-repl"
echo "Add this to your shell profile if not already present:"
echo "  export PATH=\"$TARGET/bin:\$PATH\""
