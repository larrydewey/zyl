# Chapter 35: Editors and the Language Server

Zyl ships a language server, `zyl-lsp`, built from the same self-hosted
compiler that builds your programs. That is the whole design idea: the
editor and the command line run the same parser, the same macro
expander, and the same checkers, so they cannot disagree about whether
a program is valid.

## 35.1 Getting It

`./boot.sh` leaves the binary at `build/boot/zyl-lsp`, and `./install.sh`
puts a copy at `~/.zyl/bin/zyl-lsp` (or `$ZYL_HOME/bin/zyl-lsp`). The
install script then sends the server one real `initialize` request and
reports whether it answered, so a broken install is visible immediately
rather than the first time you open an editor.

```bash
./boot.sh                  # build and verify the compiler and the server
./install.sh               # install compiler, REPL and server
./install.sh --with-vscode # the above, plus the VS Code extension
```

The server speaks JSON-RPC 2.0 over stdio. There is nothing useful to
see if you run it by hand.

## 35.2 VS Code

```bash
cd editors/vscode
npm install && npm run compile
npx vsce package && code --install-extension zyl-0.2.0.vsix
```

The extension looks for the server in this order: the `zyl.lsp.path`
setting, `$ZYL_HOME/bin`, `~/.zyl/bin`, the `build/boot` directory of
any open workspace folder, and finally `$PATH`. A checkout you have run
`./boot.sh` in therefore needs no configuration at all.

Beyond the server, the extension contributes a TextMate grammar
covering every special form, bitwise and byte operation, atomic,
region and capability name; seventeen snippets; a `zyl` build task; and
**Zyl: Run Current File** (`Ctrl+Shift+Enter`), which compiles and runs
the *unsaved* buffer and shows its output in the Zyl output channel.
The status bar shows whether the server is running, and clicking it
opens the server log.

## 35.3 Any Other Editor

Any LSP client works. The server needs no arguments and no
configuration file; point the client at the binary and associate it
with `.zyl`.

Neovim, with the built-in client:

```lua
vim.lsp.config.zyl = {
  cmd = { vim.fn.expand('~/.zyl/bin/zyl-lsp') },
  filetypes = { 'zyl' },
  root_markers = { '.git' },
}
vim.lsp.enable('zyl')
vim.filetype.add({ extension = { zyl = 'zyl' } })
```

Emacs, with `eglot`:

```elisp
(add-to-list 'auto-mode-alist '("\\.zyl\\'" . lisp-mode))
(add-to-list 'eglot-server-programs
             '(lisp-mode . ("~/.zyl/bin/zyl-lsp")))
```

Helix, in `languages.toml`:

```toml
[language-server.zyl-lsp]
command = "zyl-lsp"

[[language]]
name = "zyl"
scope = "source.zyl"
file-types = ["zyl"]
roots = [".git"]
language-servers = ["zyl-lsp"]
```

## 35.4 What the Server Provides

| Request | What you get |
|---|---|
| `publishDiagnostics` | Unbalanced parentheses, parse errors, duplicate definitions, arity mismatches, mutability and capability conflicts, non-exhaustive matches, and `Secret` violations — each with its `E_*` code and a range pointing at the offending name |
| `hover` | Signatures for your own functions, variant and struct layouts, the owning struct of a field, and documentation for every built-in form, operator, type, region and capability |
| `definition` | Functions, types, structs, traits, macros and constants; a variant constructor resolves to its `deftype`, a field to its `defstruct` |
| `typeDefinition` | A variant to its ADT, a field to its struct |
| `implementation` | Every `impl` of the trait under the cursor |
| `references`, `documentHighlight` | Every whole-word occurrence, skipping strings and comments, honouring `includeDeclaration` |
| `rename` | The declaration and every reference in the file |
| `completion` | Special forms, operators, built-ins, types, regions and capabilities, each with its signature and documentation, plus this document's functions, ADTs, variants, structs and fields — and stdlib module paths inside `(use ...)` |
| `signatureHelp` | Parameter names from your own `defn`, signatures for built-ins, with the current argument highlighted |
| `documentSymbol`, `workspace/symbol` | Outline and breadcrumbs; each symbol's range spans its whole form and its selection range covers just the name |
| `semanticTokens` (full and range) | keyword, operator, function, type, enumMember, property, string, number, comment |
| `foldingRange`, `selectionRange` | Per top-level form; selection expands from the identifier to the enclosing form |
| `callHierarchy` | Incoming and outgoing calls within the document |
| `inlayHint` | Parameter names at call sites |
| `formatting` | Re-indent by parenthesis depth |
| `workspace/executeCommand` | `zyl.evalDocument` — compile and run the buffer, returning its output |

Diagnostics come from running the real checks: `duplicate_check`,
`arity_check`, `mutability_check`, `exhaustiveness_check` and
`secret_check`, in the same order `selfhost/driver.zyl` runs them.

## 35.5 How It Works, and What That Costs

Two facts about the compiler shape everything the server can do.

**Nothing in the compiler's AST carries a source position.** The
lexer, parser and expression tree all discard location. So every
feature that needs to answer "where" — hover, go-to-definition,
symbols, folding, semantic tokens, references — is computed by a
separate scan over the raw document text, using the same character
classification `sexp_balance.zyl` already uses. That scan is exact
about positions and knows nothing about scope.

**Everything that needs to answer "what" runs the real pipeline.** The
document is parsed, its modules resolved and its macros expanded, and a
flat symbol table is built from the resulting expression tree. That is
where the function signatures, ADT variants, struct fields and their
owners come from.

The two halves meet by *name*: the text scan says which identifier is
under the cursor, and the symbol table says what that name is. It is
less clever than an inference-driven server, and it is honest — the
server never reports a type it did not actually compute.

## 35.6 Known Limits

Each of these is a consequence of the design above, not an oversight:

- **One diagnostic at a time.** Every compiler check stops at its first
  problem, exactly as a command-line build does. Fix it, save, see the
  next.
- **Unused-binding warnings do not appear.** `unused_check` reports by
  printing to stdout, which is the server's JSON-RPC channel; a single
  warning line there would desynchronise the framing. Surfacing them
  needs the check to return warnings rather than print them.
- **Completion does not offer local variables.** There is no position
  information in the AST, so there is no scope to read at a cursor.
- **Hover shows declared types, not inferred ones.** A parameter's
  annotation is what the programmer wrote; an unannotated parameter
  hovers as a bare name.
- **Navigation is per-document.** Workspace symbol search covers every
  file you have open, not files you have never opened.
- **Renaming is textual.** It would also rename a local binding that
  shadows the name being renamed. Zyl rejects duplicate top-level
  definitions, so a top-level name is unambiguous file-wide; a shadowing
  `let` is the case to watch.

## 35.7 Testing the Server

`tests/lsp/lsp_protocol_test.py` drives the real binary over real
JSON-RPC and asserts on the responses — capabilities, hover, navigation,
symbols, completion, semantic tokens, rename, and one diagnostic case
per compiler check. Nothing in it reaches into the server's internals,
so a pass means an editor sees what the assertions describe.

```bash
./run_regression_tests.sh --filter lsp
```

It runs in both quick and full mode.

## Summary

- `zyl-lsp` is built from the self-hosted compiler, so the editor and
  `zyl` never disagree.
- The VS Code extension finds it automatically in a built checkout or
  an installed toolchain; any other LSP client works with a two-line
  configuration.
- Positions come from a text scan, meanings come from the real
  pipeline, and the two meet by name.
- The limits are stated rather than papered over: one diagnostic at a
  time, no local-variable completion, per-document navigation, textual
  rename.
