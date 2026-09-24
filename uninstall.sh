#!/usr/bin/env bash
# Removes what install.sh put in place under ~/.zyl (or $ZYL_HOME if set):
# the programs in bin/, the stdlib/ copy, the runtime sources and the env
# snippets. Everything else in that directory is yours and is kept: the
# package store, the index cache, your publisher keys (keys/, which cannot
# be recreated), the REPL history and replrc, and anything you put there
# yourself. The script lists what it keeps.
#
# install.sh never edits your shell profile, so neither does this. Any
# `source ~/.zyl/env` line you added yourself stays; remove it by hand.
#
# Usage:
#   ./uninstall.sh            remove only what install.sh installed
#   ./uninstall.sh --purge    remove the whole directory, keys and package
#                             store included (asks first; --yes skips it)
#   ./uninstall.sh --help
set -euo pipefail
TARGET="${ZYL_HOME:-$HOME/.zyl}"
PURGE=0
YES=0

while [ $# -gt 0 ]; do
    case "$1" in
        --purge) PURGE=1; shift ;;
        -y|--yes) YES=1; shift ;;
        -h|--help)
            sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "error: unknown option '$1' (try --help)" >&2
            exit 1
            ;;
    esac
done

# Guard against a mistyped/misexported ZYL_HOME turning a removal below
# into something catastrophic (empty, "/", or a bare non-absolute path
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

if [ "$PURGE" -eq 1 ]; then
    echo "WARNING: --purge deletes all of $TARGET, including:"
    [ -d "$TARGET/keys" ]  && echo "  $TARGET/keys   publisher signing keys (cannot be recovered)"
    [ -d "$TARGET/store" ] && echo "  $TARGET/store  downloaded package store"
    [ -d "$TARGET/index" ] && echo "  $TARGET/index  package index cache"
    [ -e "$TARGET/repl_history" ] && echo "  $TARGET/repl_history"
    [ -e "$TARGET/replrc" ] && echo "  $TARGET/replrc"
    if [ "$YES" -eq 0 ]; then
        if [ ! -t 0 ]; then
            echo "error: --purge needs confirmation; re-run with --yes to confirm non-interactively" >&2
            exit 1
        fi
        printf "Type 'purge' to delete %s: " "$TARGET"
        read -r answer
        if [ "$answer" != "purge" ]; then
            echo "Aborted; nothing removed."
            exit 1
        fi
    fi
    rm -rf "$TARGET"
    echo "Removed $TARGET"
    exit 0
fi

# Exactly the files install.sh writes.
INSTALLED_BIN="stage2.bin zyl-repl-bin zyl-lsp-bin zyl zyl-repl zyl-lsp"
INSTALLED_TOP="actor_runtime.c actor_runtime.h env env.fish"

echo "Removing the Zyl installation from $TARGET"
for f in $INSTALLED_BIN; do
    if [ -e "$TARGET/bin/$f" ] || [ -L "$TARGET/bin/$f" ]; then
        rm -f "$TARGET/bin/$f"
        echo "  removed bin/$f"
    fi
done
# bin/ goes only if install.sh's files were all that was in it.
rmdir "$TARGET/bin" 2>/dev/null && echo "  removed bin/" || true
if [ -d "$TARGET/stdlib" ]; then
    rm -rf "$TARGET/stdlib"
    echo "  removed stdlib/"
fi
for f in $INSTALLED_TOP; do
    if [ -e "$TARGET/$f" ]; then
        rm -f "$TARGET/$f"
        echo "  removed $f"
    fi
done

# Whatever is left belongs to you.
KEPT="$(cd "$TARGET" && ls -A)"
if [ -z "$KEPT" ]; then
    rmdir "$TARGET"
    echo "Removed the now-empty $TARGET"
else
    echo "Kept in $TARGET (use --purge to delete these too):"
    printf '%s\n' "$KEPT" | while IFS= read -r name; do
        case "$name" in
            keys)         echo "  $name/  publisher signing keys" ;;
            store)        echo "  $name/  package store" ;;
            index)        echo "  $name/  package index cache" ;;
            repl_history) echo "  $name  REPL history" ;;
            replrc)       echo "  $name  REPL startup file" ;;
            *)            echo "  $name" ;;
        esac
    done
fi
echo "Done."
