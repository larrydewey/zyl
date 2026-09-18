#!/usr/bin/env bash
# Removes what install.sh put in place (~/.zyl, or $ZYL_HOME if set).
# Nothing else on the system is touched -- install.sh never edits your
# shell profile or writes anywhere outside that one directory, so this
# is the whole story. Any PATH export you added yourself for
# ~/.zyl/bin is left in place; remove that line by hand if you added
# one.
set -euo pipefail
TARGET="${ZYL_HOME:-$HOME/.zyl}"

# Guard against a mistyped/misexported ZYL_HOME turning the `rm -rf "$TARGET"`
# below into something catastrophic (empty, "/", or a bare non-absolute path
# all resolve to places you do not want wiped).
case "$TARGET" in
    ""|/|"$HOME")
        echo "error: refusing unsafe removal target: '$TARGET'" >&2
        exit 1
        ;;
    /*) ;;
    *)
        echo "error: ZYL_HOME must be an absolute path, got: '$TARGET'" >&2
        exit 1
        ;;
esac

if [ ! -d "$TARGET" ]; then
    echo "Nothing to remove: $TARGET does not exist"
    exit 0
fi

echo "Removing $TARGET"
rm -rf "$TARGET"
echo "Done."
