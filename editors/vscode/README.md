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

Then install the extension:

```bash
cd editors/vscode
npm install
npm run compile
npx vsce package                       # produces zyl-0.2.0.vsix
code --install-extension zyl-0.2.0.vsix
```

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
| Document symbols | Outline and breadcrumbs, each symbol spanning its whole form |
| Semantic tokens | Keyword, operator, function, type, variant, property, string, number and comment, full-document or by range |
| Folding / selection | Per top-level form; selection expands from the identifier to the enclosing form |
| Call hierarchy | Incoming and outgoing calls within the document |
| Inlay hints | Parameter names at call sites |
| Formatting | Re-indent by parenthesis depth |

**From the extension itself:** a TextMate grammar covering every special
form, bitwise and byte operation, atomic, region, capability and
built-in; 17 snippets; a `zyl` build task; and **Zyl: Run Current File**
(`Ctrl+Shift+Enter`), which compiles and runs the *unsaved* buffer and
shows its output in the Zyl output channel.

## Settings

| Setting | Default | Meaning |
|---|---|---|
| `zyl.lsp.enable` | `true` | Run the language server at all |
| `zyl.lsp.path` | `""` | Explicit path to `zyl-lsp`; empty means search |
| `zyl.lsp.arguments` | `[]` | Extra arguments for the server |
| `zyl.lsp.trace.server` | `"off"` | Log JSON-RPC traffic |
| `zyl.inlayHints.parameterNames` | `true` | Parameter-name hints at call sites |
| `zyl.compiler.path` | `""` | Explicit path to `zyl` for the build task |

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
- **Completion does not offer local variables.** Nothing in the
  compiler's AST carries a source position, so there is no scope to
  read at a cursor; every other feature here is built from a text scan
  plus the real macro-expanded program.
- **Navigation is per-document.** A workspace symbol search covers every
  file you have open, not files you have not opened.
- **Renaming is textual**, and would rename a local binding that shadows
  the name being renamed.
