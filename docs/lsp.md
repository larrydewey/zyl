# Language Server

`zyl-lsp` is the Zyl language server. Its source is `stdlib/lsp/` (plus
`stdlib/lsp/services/`), the entry point is `selfhost/lsp_main.zyl`, and
`./boot.sh` builds it as `build/boot/zyl-lsp`; `./install.sh` installs it
as `~/.zyl/bin/zyl-lsp`. It speaks JSON-RPC over stdio.
`tests/lsp/lsp_protocol_test.py` drives the real binary and checks the
responses (110 checks, one of them that the server answers while stdin stays open; `./run_regression_tests.sh --filter lsp`, in
quick and full mode).

## Requests

`initialize` (every provider below advertised), `initialized`,
`shutdown`, `exit`; `didOpen`, `didChange`, `didSave` (with text),
`didClose`; `publishDiagnostics`; and:

| Request | Notes |
|---|---|
| `hover` | MarkupContent, with a range; resolves the document's own definitions first, then the built-in table |
| `definition` | Functions, types, structs, traits, macros, constants; a variant resolves to its `deftype`, a field to its `defstruct`. Sees through `pub` and `feature-gate` wrappers |
| `typeDefinition` | Variant to ADT, field to struct |
| `implementation` | Every `impl` naming the trait under the cursor |
| `references` | Whole-word occurrences, honouring `context.includeDeclaration` |
| `documentHighlight` | The same occurrence set, as ranges |
| `rename` / `prepareRename` | Declaration plus every reference in the file |
| `completion` | Context-aware: module paths inside `(use ...)`, otherwise built-ins (with signature and documentation) plus the document's functions, ADTs, variants, structs and fields |
| `signatureHelp` | Real parameter names from `defn`; built-in signatures from the table; correct `activeParameter` |
| `documentSymbol` | Full-form `range`, name-only `selectionRange` |
| `workspace/symbol` | Across every open document |
| `semanticTokens/full` and `/range` | Ten standard token types, three modifiers |
| `foldingRange` | Per multi-line top-level form |
| `selectionRange` | Identifier, then enclosing form |
| `codeAction` | Quick-fixes from balance diagnostics' fix-it hints |
| `formatting` / `rangeFormatting` | Re-indent by paren depth |
| `prepareCallHierarchy`, `incomingCalls`, `outgoingCalls` | Per-document |
| `inlayHint` | Parameter names at call sites |
| `workspace/executeCommand` | `zyl.evalDocument`: writes the buffer to `/tmp/zyl_lsp_eval.zyl`, compiles it with the `zyl` on `PATH`, runs it, returns captured output |

Navigation, hover and completion are name-based over the document text
(`source_index.zyl`); diagnostics come from the compiler itself.

## Diagnostics

`document_manager.zyl` parses the document, resolves modules with the
document's path (so it finds the package the file belongs to, spec v5.0
§31.3), expands macros, runs `uc-check-program` with its warnings
captured, then runs `dc-check-program`, `ac-check-program`,
`mc-check-program`, `ec-check-program` and `sc-check-program` — the order
`compile-run-checks` in `stdlib/compiler/pipeline.zyl` uses — inside
`try`/`catch`, so a checker's `zyl_panic` becomes a Diagnostic instead of
killing the server. When they pass, the type checker runs (derive
expansion, impl lifting, closure inlining, `ta-annotate`) with its
reports captured, and every one located in the document is published.
Each diagnostic carries its `E_*` code in the LSP `code` field and is
placed at the message's `--> line:col`, or, for an unlocated message, at
the message's backticked name in the document text.

One of the pipeline's checks is not run: `cc-check-program` (package
capability enforcement, §31.9, which needs the resolver's grant/deny
sets). Nothing after type checking runs.

The symbol table is built BEFORE the checks run and kept whatever they
say, so a document that fails exhaustiveness still offers hover,
completion and go-to-definition for the names it declares.

## The builtin table

`stdlib/lsp/builtins.zyl` is the one table behind hover, completion,
signature help and token colouring; the REPL's Tab completion uses it
too. It holds every special form `convert-ast` recognises, every
operator and intrinsic, the byte, atomic and channel operations, and
every type, region and capability name, each with a signature and a
one-line description. Keep it in step when `expr_inner.zyl` gains a
form: a form missing from it shows in the editor as an unresolved
identifier.

## Known limits

- Hover shows declared annotations, not inferred types; the type
  checker's results are not kept per position, so there are no type
  inlay hints.
- Completion does not offer local variables: there is no scope to read
  at a cursor.
- Positions are byte columns, not UTF-16 code units, so a column after a
  non-ASCII character on the same line is off.
- Each check before the type checker stops at its first problem, as a
  command-line build does. Type errors are all reported at once.
- The package capability check (spec §31.9) is not run.
- Navigation is per document; workspace symbol search covers open
  documents only.
- Opening a 150 KB document takes about 470 MB: the front end and the
  type checker allocate on the process heap, which is never freed.

## Editors

`editors/vscode/` is the VS Code extension (0.5.0, esbuild bundle,
vscode-languageclient 10.1, engine ^1.91.0): the `zyl` and `zyl-pkg`
languages, a TextMate grammar, 19 snippets, build tasks with the `$zyl`
problem matcher, and **Zyl: Run Current File**. Its README lists the
settings. `./install.sh --with-vscode` builds and installs it. Chapter 35
of the book (`book/src/part5/ch35-tooling.md`) covers Neovim, Emacs and
Helix.
