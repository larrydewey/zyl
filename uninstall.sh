#!/usr/bin/env bash
# Removes what install.sh put in place (~/.zyl, or $ZYL_HOME if set).
# Nothing else on the system is touched -- install.sh never edits your
# shell profile or writes anywhere outside that one directory, so this
# is the whole story. Any PATH export you added yourself for
# ~/.zyl/bin is left in place; remove that line by hand if you added
# one.
set -euo pipefail
TARGET="${ZYL_HOME:-$HOME/.zyl}"

if [ ! -d "$TARGET" ]; then
    echo "Nothing to remove: $TARGET does not exist"
    exit 0
fi

echo "Removing $TARGET"
rm -rf "$TARGET"
echo "Done."
