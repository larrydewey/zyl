# Chapter 35: Tooling — the Command Line, the REPL and the Editor

Zyl's tools are all built from the same self-hosted compiler: the `zyl`
command, the interactive REPL, and the language server, `zyl-lsp`. That
is the whole design idea. The command line, the REPL and the editor run
the same parser, the same macro expander and the same checkers, so they
cannot disagree about whether a program is valid.

## 35.1 Getting It

```bash
./boot.sh                  # build and verify the compiler, build the server
./install.sh               # install compiler, REPL and server into ~/.zyl
./install.sh --with-vscode # the above, plus the VS Code extension
./uninstall.sh             # remove what install.sh installed
./uninstall.sh --purge     # remove all of ~/.zyl, keys and store included
```

`./boot.sh` leaves the compiler at `build/boot/stage2.bin`, a wrapper
for it at `build/boot/zyl-self`, and the server at `build/boot/zyl-lsp`.
It does not build a standalone REPL binary; in a checkout, use
`build/boot/zyl-self repl`.

`./install.sh` requires a finished `./boot.sh` and installs into
`~/.zyl`, or `$ZYL_HOME` if that is set to an absolute path:

| Installed | What it is |
|---|---|
| `bin/zyl` | the compiler; with **no arguments** it starts the REPL |
| `bin/zyl-repl` | the REPL, built from `tools/repl.zyl` |
| `bin/zyl-lsp` | the language server |
| `bin/stage2.bin`, `bin/zyl-repl-bin`, `bin/zyl-lsp-bin` | the binaries the three wrappers run |
| `stdlib/`, `actor_runtime.c`, `actor_runtime.h`, `actor_runtime.o` | what every compile needs; the object is the runtime compiled once at `-O2`, which every link uses |
| `env`, `env.fish` | one line each that puts `bin/` on `PATH`; the script never edits your shell profile |

The REPL and the server are compiled by the just-installed compiler
against the just-copied standard library. The script then sends the
server one real `initialize` request and reports whether it answered,
so a broken install is visible immediately rather than the first time
you open an editor.

`./uninstall.sh` removes only what `install.sh` put in the install
directory: the programs in `bin/`, `stdlib/`, the runtime sources and
the `env` files. The same directory is also where the package store
(`store/`), your publisher key (`keys/publisher.seed`), the REPL history
and `replrc` live by default; those are kept, and the script lists
them. `./uninstall.sh --purge` deletes the whole directory, including
the key, after printing what it is about to delete and asking you to
type `purge` (`--yes` skips the question). The VS Code extension, if
installed, is not removed.

## 35.2 The Command Line

```
zyl <file.zyl> [-o out] [--emit-asm]   compile one file
  --error-format=json                    report diagnostics as JSON lines
  --contracts=strict|debug|warn|off|production   contract profile (default strict)
zyl new <name>                         create a package
zyl add <name> [version]               add a dependency
zyl fetch                              resolve, verify and populate the store
zyl build [--locked]                   compile this package
zyl test                               compile and run this package
zyl update                             re-resolve and rewrite zyl.lock
zyl vendor                             copy the graph into ./vendor
zyl audit                              report capabilities per package
zyl publish                            archive, hash and sign this package
zyl key                                show or create the publisher key
zyl repl                               start an interactive session
zyl eval <file.zyl>                    run a program without building one
zyl doc [file.zyl | dir] [-o out.md]   Markdown from doc comments
```

A first argument ending in `.zyl`, or starting with `-`, means "compile
this file"; any other word is a subcommand, and a word that is not one
of the above prints this list. `--help` is therefore treated as a file
name and fails with `cannot open source file`; use `zyl help`.

Compiling a file:

```bash
zyl hello.zyl               # writes hello.s, links ./hello
zyl hello.zyl -o bin/hello  # writes bin/hello.s, links bin/hello
zyl hello.zyl -o hello.s --emit-asm   # assembly only, no link
zyl hello.zyl --error-format=json     # diagnostics as JSON, one per line
```

`--error-format=json` is for tools: every error and warning goes to
stderr as one JSON object per line (Appendix A, §A.1). A program the
compiler builds is not affected; its own panics stay plain text.

The type checker reports every type error in a file before it stops.
While porting code written for the old, lenient checker,
`ZYL_STRICT_TYPES=report` turns those errors into `W_TYPE_STRICT`
warnings so you can see the whole list shrink; the compile then goes
on, but a program built that way is not one the compiler vouches for.
Leave the variable unset for real builds.

The compiler changes directory to its bundle (the directory holding
`stdlib/` and `actor_runtime.c`: `$ZYL_HOME` or `~/.zyl` if it holds a
`stdlib/`, else the directory the binary is in) before it compiles, and
resolves relative paths against the directory you ran it from first.
Because an installed `~/.zyl` wins that search, running a checkout's
`build/boot/zyl-self` on a machine with an older install compiles
against the *installed* standard library; set
`ZYL_HOME=$PWD/build/boot` to use the checkout's (this is what
`./boot.sh` does). Linking runs `cc -no-pie` with the prebuilt runtime
object (or, when that is older than `actor_runtime.c`, the source at
`-O2`) and `-lpthread` (Chapter 29, §29.1).

`zyl eval file.zyl` runs a program through the REPL's interpreter
instead: no assembly, no linker, a few milliseconds for a small
program. It cannot run actors.

`zyl doc` writes Markdown documentation from the source's comments,
for one file or every `.zyl` file under a directory (sorted, so the
output is deterministic), to stdout or `-o`. It follows the convention
the standard library uses:

- the comment block at the top of a file is the module's doc; its
  `; === Title ===` line becomes the title and `Module:` lines are dropped;
- the contiguous `;` lines directly above a top-level `defn`, `def`,
  `deftype`, `defstruct`, `trait` or `defmacro` are that definition's doc,
  stopping at a blank line or a `; ===`/`; ---` separator;
- if that block has any `;|` lines, only they are used, so ordinary
  comments can sit beside a doc;
- each definition is shown with its signature; in a package (a `zyl.pkg`
  beside the file or in the directory) only `pub` definitions appear.

```bash
zyl doc stdlib/allocator/allocator.zyl      # one module to stdout
zyl doc . -o API.md                         # a package, pub items only
```

The package subcommands are covered in Chapter 25.

Run with no arguments, the installed `zyl` wrapper starts the REPL. The
raw compiler binary (`stage2.bin`, or `build/boot/zyl-self`) with no
arguments does something else entirely: it runs the legacy fixed-path
protocol boot scripts once used, compiling `/tmp/zyl_boot_in.zyl` to
`/tmp/zyl_boot_out.s`.

## 35.3 The REPL

```
$ zyl repl
Zyl REPL 0.1 — :help for commands, :q to quit
zyl> (+ 1 2)
=> 3
zyl> (defn double (n) (* n 2))
defined double
zyl> (def x 21)
x = 21
zyl> (double x)
=> 42
zyl> (Some "hi")
=> (Some "hi")
```

Every entry goes through the real compiler's phases — parsing, macro
expansion, every check, impl lifting, type checking and ICNF
lowering, the same `compile-to-fns` the CLI uses — and is then
*evaluated* by an ICNF interpreter (`stdlib/repl/interp.zyl`) in the
REPL's own process rather than compiled and linked. That is why an
entry takes milliseconds, and why a value bound with `def` survives
from one entry to the next without being recomputed; a `defn` entered
later can read it, as `double x` would inside a function body. The
interpreter runs tail calls in constant stack, so a recursive loop
behaves as it does compiled. An `Int` result of 0 is not echoed, so a
`print` entry does not add `=> 0` under its output. A `Bool` result is
echoed as its machine word: `true` as `=> 1`, and `false`, being 0, not
at all. Values print
structurally: a variant as its constructor and fields, a struct as its
name and fields.

The line editor is written in Zyl over four terminal primitives in the
runtime: arrow and word motion, multi-line entries that continue until
the form closes, `Ctrl-R` history search, Tab completion, and syntax
highlighting as you type. `docs/repl.md` has the full key table.

### Meta commands

| Command | Short | |
|---|---|---|
| `:help` | `:h` | commands and main keys |
| `:quit` | `:q` | leave |
| `:history` | `:hist` | past entries |
| `:defs` | `:browse` | modules, bindings and definitions in scope |
| `:doc NAME` | `:d` | documentation for a built-in or special form |
| `:type EXPR` | `:t` | the type inference assigns, without evaluating |
| `:time EXPR` | `:tm` | evaluate and report the elapsed time |
| `:load PATH` | `:l` | read a file's modules and definitions into the session |
| `:save PATH` | `:s` | write the session's definitions to a file |
| `:reset` | `:r` | forget everything, including the saved session |
| `:clear` | `:cls` | clear the screen |

`:type` reports the type the checker assigns: `(+ 1 2)` is `Int`,
`(str-eq "a" "b")` is `Bool`, `(fn (x) x)` is `(a -> a)`. An entry that
does not type-check is rejected with the same `E_TYPE_MISMATCH` the
compiler would print, and nothing is evaluated. The error quotes the
entry you typed, but its line number counts the whole session's
program, and an expression entry is shown inside the wrapper function
the REPL compiles it as (`__zyl_repl_entry`). Relative paths in `:load` and `:save` resolve against
the directory you started in.

### What carries over

A session starts from three sources, in order: the default modules
(`core/core`, `core/list`, `core/option`, `core/result`,
`allocator/allocator`); `~/.zyl/replrc` (or `$ZYL_REPLRC`), replayed
form by form; and `.zyl-session` in the directory you started in, which
the REPL rewrites after every entry that changes the session. Both
files are ordinary Zyl source. History is global, in
`~/.zyl/repl_history` (`$ZYL_REPL_HISTORY`; the directory itself moves
with `$ZYL_STATE_DIR`).

When standard input is not a terminal, the REPL runs as a script: the
same meta commands work, but it reads no `replrc`, restores and writes
no session, loads no history and prints no banner, so a piped script
behaves the same on every machine.

### Limits

- **No actors.** `spawn` needs a native entry point; the interpreter
  reports `E_UNSUPPORTED_INTERPRETED`. Compile the program instead.
- **Heavy arithmetic is slow.** The interpreter allocates per operation;
  a signature verification that takes milliseconds compiled can take
  tens of seconds and stop at the memory budget (`E_OUT_OF_MEMORY`).
- **A name can be defined once per session**; `:reset` to redefine it.

## 35.4 VS Code

```bash
cd editors/vscode
npm install
npx vsce package              # type-checks and bundles; produces zyl-0.4.0.vsix
code --install-extension zyl-0.4.0.vsix
```

The build tasks (the file build, and `zyl build`/`test`/`fetch` for each
package) use the `$zyl` problem matcher, which turns the compiler's
`error[CODE]: message` / `warning[CODE]: message` headline and the
`--> file:line:col` line under it into Problems-panel entries. Use it in
your own `tasks.json` with `"problemMatcher": "$zyl"`. The package is
bundled with esbuild (`npm run bundle`, run by `vsce package`), so the
`.vsix` holds one `out/extension.js` rather than `node_modules`.


`./install.sh --with-vscode` does the same, uninstalls the old
grammar-only 0.1.0 extension (`zyl-lang.zyl-lang`) if present, and,
when there is no `code` command, links the extension into
`~/.vscode/extensions/zyl-lang` instead.

The extension looks for the server in this order: the `zyl.lsp.path`
setting, `$ZYL_HOME/bin`, `~/.zyl/bin`, the `build/boot` directory of
any open workspace folder, and finally `$PATH`. It finds the compiler
for its build tasks the same way (`zyl.compiler.path`, then
`$ZYL_HOME/bin/zyl`, `~/.zyl/bin/zyl`, a workspace's
`build/boot/zyl-self`, then `zyl` on `PATH`). A checkout you have run
`./boot.sh` in therefore needs no configuration at all.

What it contributes:

- two languages: `zyl` for `.zyl` files and `zyl-pkg` for `zyl.pkg`
  manifests, each with its own TextMate grammar, so a manifest is never
  compiled as a program
- seventeen snippets
- tasks: a `zyl` compile task per open `.zyl` file, and `build`, `test`
  and `fetch` for every `zyl.pkg` in the workspace
- commands: **Zyl: Run Current File** (`Ctrl+Shift+Enter`), which
  compiles and runs the *unsaved* buffer through the server and shows
  its output; **Restart Language Server**; **Stop Language Server**;
  **Show Language Server Log**
- settings: `zyl.lsp.enable`, `zyl.lsp.path`, `zyl.lsp.arguments`,
  `zyl.lsp.trace.server`, `zyl.inlayHints.parameterNames`,
  `zyl.compiler.path`

The status bar shows whether the server is running, and clicking it
opens the server log.

## 35.5 Any Other Editor

Any LSP client works. The server needs no arguments and no
configuration file; point the client at the binary and associate it
with `.zyl`. It speaks JSON-RPC 2.0 over stdio; there is nothing useful
to see if you run it by hand.

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

## 35.6 What the Server Provides

| Request | What you get |
|---|---|
| `publishDiagnostics` | Unbalanced delimiters (with a line, column and fix-it), parse errors, duplicate definitions, arity mismatches, mutability and aliasing conflicts, non-exhaustive matches, `Secret` violations and type errors — each with its `E_*` code and a range pointing at the offending name |
| `codeAction` | A quick fix for each balance error, applying the fix-it the diagnostic carries; none for other diagnostics |
| `hover` | Signatures for your own functions, variant and struct layouts, the owning struct of a field, and documentation for every built-in form, operator, type, region and capability; on dot syntax (`p.x`, `(p.area)`) the segment under the cursor |
| `definition` | Functions, types, structs, traits, macros and constants; a variant constructor resolves to its `deftype`, a field to its `defstruct` (also from a dot segment); `pub` and `feature-gate` wrappers are seen through |
| `typeDefinition` | A variant to its ADT, a field to its struct |
| `implementation` | Every `impl` of the trait under the cursor |
| `references`, `documentHighlight` | Every whole-word occurrence, skipping strings and comments, honouring `includeDeclaration` |
| `prepareRename`, `rename` | The declaration and every reference in the file |
| `completion` | Special forms, operators, built-ins, types, regions and capabilities, each with its signature and documentation, plus this document's functions, ADTs, variants, structs and fields — and stdlib module paths inside `(use ...)` |
| `signatureHelp` | Parameter names from your own `defn`, signatures for built-ins, with the current argument highlighted |
| `documentSymbol`, `workspace/symbol` | Outline and breadcrumbs; each symbol's range spans its whole form and its selection range covers just the name |
| `semanticTokens` (full and range) | keyword, operator, function, type, enumMember, property, string, number, comment |
| `foldingRange`, `selectionRange` | Per top-level form; selection expands from the identifier to the enclosing form |
| `callHierarchy` | Incoming and outgoing calls within the document |
| `inlayHint` | Parameter names at call sites |
| `formatting`, `rangeFormatting` | Re-indent by parenthesis depth (two spaces per level); no reflow |
| `workspace/executeCommand` | `zyl.evalDocument` — compile and run the buffer with the `zyl` CLI, returning its output |

Diagnostics come from running the real checks — `duplicate_check`,
`arity_check`, `mutability_check`, `exhaustiveness_check` and
`secret_check` — in the order `stdlib/compiler/pipeline.zyl` runs them,
plus `unused_check`, whose unused-binding and shadowing warnings appear
as Warning diagnostics. When those checks pass, the server runs the
steps that precede type checking in the compiler (derive expansion,
impl lifting, closure inlining) and then the type checker itself, and
publishes every type error located in the document; one the checker
places in another file belongs to that file. Each diagnostic sits at
the line and column the compiler reports. The package capability check (`capability_check`, spec
§31.9) is not run in the editor.

## 35.7 How It Works, and What That Costs

Two facts shape everything the server can do.

**The server does not use the compiler's source positions.** Tokens
now carry byte offsets and the runtime keeps a span table for parsed
nodes, which is how the command line prints `--> file:line:col` with a
caret. The server predates that and does not read it. Every feature
that needs to answer "where" — hover, go-to-definition, symbols,
folding, semantic tokens, references — is computed by a separate scan
over the raw document text, using the same character classification
`sexp_balance.zyl` uses. That scan is exact about positions and knows
nothing about scope. A diagnostic from a compiler check gets its range
from the `--> file:line:col` location the compiler writes into the
message, spanning the token there; a message without a location falls
back to the first name it quotes in backticks, and then to the top of
the file.

**Everything that needs to answer "what" runs the real front end.** The
document is parsed, its modules resolved and its macros expanded, and a
flat symbol table is built from the resulting expression tree. That is
where the function signatures, ADT variants, struct fields and their
owners come from. The type checker runs too, but only for diagnostics:
hover and navigation do not read its results (see
`stdlib/lsp/compiler_bridge.zyl`'s header).

The two halves meet by *name*: the text scan says which identifier is
under the cursor, and the symbol table says what that name is. It is
less clever than an inference-driven server, and it is honest — hover
shows the type the programmer wrote, never one the server guessed.

## 35.8 Known Limits

Each of these is a consequence of the design above, not an oversight:

- **One error at a time, before type checking.** Every check that
  runs before the type checker stops at its first problem, exactly as a
  command-line build does. Fix it, save, see the next. Type errors, like
  warnings, are reported all together, and only once those checks pass.
- **Completion does not offer local variables.** The text scan has no
  scope to read at a cursor.
- **Hover shows declared types, not inferred ones.** A parameter's
  annotation is what the programmer wrote; an unannotated parameter
  hovers as a bare name.
- **Navigation is per-document.** Workspace symbol search covers every
  file you have open, not files you have never opened.
- **Columns count bytes.** LSP positions are UTF-16 code units; the
  server reports byte columns, so a position after a non-ASCII
  character on the same line is off. The text itself survives in both
  directions.
- **Renaming is textual.** It would also rename a local binding that
  shadows the name being renamed. Zyl rejects duplicate top-level
  definitions, so a top-level name is unambiguous file-wide; a shadowing
  `let` is the case to watch.

## 35.9 Testing the Tools

`tests/lsp/lsp_protocol_test.py` drives the real `build/boot/zyl-lsp`
binary over real JSON-RPC and asserts on the responses — capabilities,
hover, navigation, symbols, completion, semantic tokens, rename, the
package forms, and one diagnostic case per compiler check. Nothing in
it reaches into the server's internals, so a pass means an editor sees
what the assertions describe.

```bash
./run_regression_tests.sh --filter lsp          # the protocol test
./run_regression_tests.sh --full --filter interpreter  # REPL interpreter vs compiled output
```

The protocol test runs in both quick and full mode.

## Summary

- `zyl`, the REPL and `zyl-lsp` are all built from the self-hosted
  compiler and share its front end, so they never disagree about
  validity.
- `zyl` compiles a file or runs a package subcommand; `zyl repl` and
  `zyl eval` evaluate ICNF in-process instead of linking a binary.
- The REPL keeps values, not just definitions, and picks up a
  directory's session where it left off.
- The VS Code extension finds the server and compiler automatically in
  a built checkout or an installed toolchain; any other LSP client works
  with a few lines of configuration.
- In the server, positions come from a text scan, meanings come from
  the real front end, and the two meet by name. The limits are stated
  rather than papered over.
