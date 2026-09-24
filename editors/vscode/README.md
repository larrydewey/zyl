# Zyl for VS Code

Editor support for [Zyl](../../README.md): syntax highlighting, snippets,
and the full set of language-server features served by `zyl-lsp`, the
compiler's own self-hosted language server.

## Installing

Build the language server first — it ships with the compiler, not with
this extension:

```bash
./boot.sh          # leaves zyl-lsp in build/boot/
./install.sh       # also installs it to ~/.zyl/bin/zyl-lsp
```

Then install the extension — `./install.sh --with-vscode` does all of
this, including removing the grammar-only 0.1.0 (`zyl-lang.zyl-lang`),
which claims the same language id and would otherwise shadow this one:

```bash
cd editors/vscode
npm install
npx vsce package                       # type-checks and bundles, produces zyl-0.4.0.vsix
code --uninstall-extension zyl-lang.zyl-lang   # only if 0.1.0 is installed
code --install-extension zyl-0.4.0.vsix
```

Requires VS Code 1.91 or later (vscode-languageclient 10).

For quick iteration, symlink the directory into your extensions folder
instead of packaging it:

```bash
ln -s "$PWD" ~/.vscode/extensions/zyl-lang
```

The extension finds the server by looking, in order, at the
`zyl.lsp.path` setting, `$ZYL_HOME/bin`, `~/.zyl/bin`, the `build/boot`
directory of any open workspace folder, and finally `$PATH`. A checkout
you have run `./boot.sh` in therefore works with no configuration.

## What you get

**From the language server** (all of it computed by the same compiler
that builds your program, so the editor and `zyl` never disagree):

| Feature | What it does |
|---|---|
| Diagnostics | Unbalanced parentheses, parse errors, duplicate definitions, call arity, mutability and capability conflicts, non-exhaustive matches, and every `Secret` constant-time violation — each with its `E_*` code |
| Hover | Signatures for your functions, variant and struct layouts, field owners, and documentation for every built-in form, operator and capability |
| Go to definition | Functions, types, structs, traits, macros; a variant constructor resolves to its `deftype` |
| Go to type definition | A variant to its ADT, a field to its struct |
| Go to implementation | Every `impl` of the trait under the cursor |
| Find references / highlight | Every whole-word occurrence, skipping strings and comments |
| Rename | The declaration and every reference in the file |
| Completion | Special forms, operators, built-ins, types, regions and capabilities, plus your own functions, ADTs, variants, structs and fields — and stdlib module paths inside `(use ...)` |
| Signature help | Parameter names from your own `defn`, signatures for built-ins, with the current argument highlighted |
| Document symbols | Outline and breadcrumbs, each symbol spanning its whole form; `pub` and `feature-gate` wrappers show the definition inside |
| Semantic tokens | Keyword, operator, function, type, variant, property, string, number and comment, full-document or by range |
| Folding / selection | Per top-level form; selection expands from the identifier to the enclosing form |
| Call hierarchy | Incoming and outgoing calls within the document |
| Inlay hints | Parameter names at call sites |
| Code actions | A quick fix for each unbalanced-delimiter diagnostic, inserting the compiler's own fix-it text |
| Formatting | Re-indent by parenthesis depth, for the whole document or a range |

**From the extension itself:** a TextMate grammar covering every special
form, bitwise and byte operation, atomic, region, capability and
built-in; highlighting for `zyl.pkg` manifests (their own language,
`zyl-pkg`, so the server never compiles a manifest as a program); 17
snippets; build tasks — `build <file>` for each open file, and `build`,
`test` and `fetch` for every `zyl.pkg` in the workspace, run from the
package's directory; and **Zyl: Run Current File**
(`Ctrl+Shift+Enter`), which compiles and runs the *unsaved* buffer and
shows its output in the Zyl output channel.

## Settings

| Setting | Default | Meaning |
|---|---|---|
| `zyl.lsp.enable` | `true` | Run the language server at all |
| `zyl.lsp.path` | `""` | Explicit path to `zyl-lsp`; empty means search |
| `zyl.lsp.arguments` | `[]` | Extra arguments for the server |
| `zyl.lsp.trace.server` | `"off"` | Log JSON-RPC traffic; needs the server log's level set to Trace |
| `zyl.inlayHints.parameterNames` | `true` | Parameter-name hints at call sites; applies without a restart |
| `zyl.compiler.path` | `""` | Explicit path to `zyl` for the build tasks; empty searches `$ZYL_HOME/bin`, `~/.zyl/bin`, the workspace's `build/boot/zyl-self`, then `$PATH` |

The status bar item shows whether the server is running; clicking it
opens the server log. **Zyl: Restart Language Server** picks up a new
binary after a rebuild.

## Known limits

These come from the server, and are the honest edges of what the
compiler can currently report:

- **One diagnostic at a time.** Each compiler check stops at its first
  problem, exactly as a command-line build does.
- **Unused-binding warnings do not appear.** That check reports by
  printing to stdout, which is the server's JSON-RPC channel.
- **Completion does not offer local variables.** The compiler's AST
  carries no position-aware scopes (diagnostics are located through a
  separate table of byte offsets, which gives a position but not a
  scope), so there is nothing to read at a cursor; every other feature
  here is built from a text scan plus the real macro-expanded program.
- **No type hints.** Inlay hints are parameter names only, and hover
  shows declared signatures rather than inferred types.
- **Navigation is per-document.** A workspace symbol search covers every
  file you have open, not files you have not opened.
- **Renaming is textual**, and would rename a local binding that shadows
  the name being renamed.

## Problem matcher

The extension's build tasks use the `$zyl` problem matcher, which reads the
compiler's `error[CODE]: message` / `warning[CODE]: message` headline and the
`--> file:line:col` line under it. Use it in your own tasks with
`"problemMatcher": "$zyl"`.
