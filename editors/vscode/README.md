# VS Code Zyl Language Support

Minimal language definition for `.zyl` files: TextMate grammar, bracket
matching, auto-closing pairs, comment toggling, and indent guides.

## Install locally (no marketplace)

```bash
cd editors/vscode
npx vsce package          # produces zyl-lang-0.1.0.vsix
code --install-extension zyl-lang-0.1.0.vsix
```

Or for quick iteration without packaging, symlink into your extensions dir:

```bash
ln -s "$PWD/editors/vscode" ~/.vscode/extensions/zyl-lang
```

## What's highlighted

- `;` line comments, strings with escapes
- Special forms (`defn`, `let`, `match`, `deftype`, `trait`, ...)
- Control keywords (`if`, `while`, `for`, `cond`, `and`, `or`)
- Defined function names (`entity.name.function`)
- Variant/type names (capitalized), primitive types
- Capability/region keywords (`TCap`, `TMut`, `Stack`, `Heap`, `Pin`, ...)
- Builtins and FFI C symbols (`"zyl_*"` inside strings)

## Roadmap

This package is intentionally minimal. Semantic features (hover types,
go-to-definition, diagnostics) arrive with the LSP server — see the P2 item
in `PROGRESS.md`.
