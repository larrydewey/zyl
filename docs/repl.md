# The Zyl REPL

`zyl repl` is an interactive session: you type an expression, it answers.
A definition stays defined, a binding stays bound, and an error leaves
the session standing.

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
```

There are two entry points and one implementation: `zyl repl`, and the
standalone binary built from `tools/repl.zyl`. Both run the modules
under `stdlib/repl/`.

## How an entry is evaluated

Every entry goes through the real compiler. Parsing, macro expansion,
capability and duplicate and arity and mutability and exhaustiveness and
unused and secret checks, type inference, monomorphization, trait
dispatch, closure lifting, ICNF lowering, optimization and region
inference all run exactly as they do for `zyl build` — the shared
implementation is `stdlib/compiler/pipeline.zyl`, and the REPL calls
`compile-to-fns`, which is `compile-to-asm` minus the last phase.

What differs is the back end. Instead of generating x86_64 and linking a
binary, the REPL evaluates the lowered ICNF in its own process
(`stdlib/repl/interp.zyl`). That is what makes an entry cost a few
milliseconds instead of a `cc` invocation, and it is what lets a value —
not just a definition — survive from one entry to the next.

The session carries three things:

| | what it holds | how it is used |
|---|---|---|
| `uses` | the modules in scope | prepended to each entry's program as `(use ...)` lines |
| `defs` | the text of every definition entered | re-lowered with each entry, so type inference stays whole-program |
| `globals` | the values bound by `(def name expr)` | passed to the entry as arguments |

A global reaches an entry as a *parameter* of the function the entry is
wrapped in, and only when the entry's text mentions it. `(+ x 1)`
becomes, in effect:

```zyl
(defn __zyl_repl_entry (x) (+ x 1))
```

which is then called with the value `x` is bound to. This is why a
binding from three entries ago resolves, why an unused global costs
nothing, and why nothing that already ran ever runs again: a
`(def out (file-open "log" "w"))` opens one file, not one per later
entry.

### `def` at the prompt

Top-level `def` is not a compiled construct in this language — a
`(def name value)` at file scope never becomes a readable global (see
`cg-load-nonslot` in `stdlib/compiler/codegen.zyl`). At the prompt it is
the natural way to name a value, so the REPL gives it that meaning: the
expression is evaluated once, now, and the value is bound for every
later entry. It is an immutable binding, like any other in the language;
`set!` on it is refused the same way it would be in a file.

### Definitions

`defn`, `deftype`, `defstruct`, `defmacro`, `trait` and `impl` entries
are added to the session's text and checked by compiling the session
with them. Nothing runs — a definition has no effect until something
calls it. A redefinition shadows the earlier one.

### Modules

`(use module/name)` extends the session's module set, and is rejected if
the module does not resolve or collides with a name already in scope. A
new session starts with `core/core`, `core/list`, `core/option`,
`core/result` and `allocator/allocator`.

## Editing

The line editor is written in Zyl over four terminal primitives in the
runtime (raw mode, a byte with and without a timeout, the window size,
an unbuffered write). No readline, no libedit, no external dependency.

| key | what it does |
|---|---|
| `Enter` | evaluate, or continue an unfinished form on a new indented line |
| `Up` / `Down` | move between the lines of an entry; from the first or last line, walk history |
| `Left` / `Right` | move by character |
| `Ctrl-Left` / `Ctrl-Right`, `Alt-b` / `Alt-f` | move by word |
| `Home` / `End`, `Ctrl-A` / `Ctrl-E` | start and end of the current line |
| `Alt-<` / `Alt->` | start and end of the whole entry |
| `Ctrl-K` / `Ctrl-U` | kill to end / to start of line |
| `Ctrl-W`, `Alt-d` | kill the word behind / ahead |
| `Ctrl-Y` | yank what was last killed |
| `Ctrl-T` | transpose the two characters at the cursor |
| `Ctrl-R` | search history backwards; `Ctrl-R` again for the next match, `Enter` to run it, `Esc` to edit it, `Ctrl-G` to forget it |
| `Tab` | complete a name; at the start of a token, indent |
| `Ctrl-L` | clear the screen, keeping the entry |
| `Ctrl-C` | abandon this entry | 
| `Ctrl-D` | delete forward, or leave the session on an empty entry |
| `Ctrl-J`, `Alt-Enter` | insert a newline without evaluating |

An entry that is not a complete S-expression continues on the next line,
indented two columns per open paren. Pasted text arrives through
bracketed paste, so a pasted newline inserts a line instead of
submitting.

History lives in `~/.zyl/repl_history` (or `$ZYL_REPL_HISTORY`), written
as each entry is submitted rather than at exit, with newlines escaped so
the file stays one entry per line.

## Meta commands

| command | |
|---|---|
| `:help` | the key map and this list |
| `:quit`, `:q` | leave |
| `:history` | entries from this and earlier sessions |
| `:defs` | the modules, bindings and definitions in scope |
| `:doc NAME` | documentation for a built-in or special form |
| `:load PATH` | read a file's modules and definitions into the session |
| `:save PATH` | write the session's definitions to a file |
| `:reset` | forget everything and start over |
| `:clear` | clear the screen |

## `zyl eval`

`zyl eval file.zyl` runs a program through the same interpreter without
building a binary — the quick way to run a script, and the way the
regression suite checks that the interpreter and the code generator
agree. `./run_regression_tests.sh --full` runs every regression and
smoke test both ways and diffs the output; `--filter interpreter` runs
just that section.

## Memory

An entry compiles into an arena of its own, and evaluates against a heap
arena of its own; both are released when the entry finishes. Two things
are kept: a `def` runs against the session's own heap, because the value
it binds has to outlive the entry, and an entry that lifts a lambda
keeps its compile arena, because a closure value names the lifted
function and that function's body lives there. Typing expressions at the
prompt therefore costs no permanent memory — 200 entries move a session
from 17 MB to 28 MB — while binding a value costs the value.

The editor's own arena is reset at every prompt.

## Where the interpreter differs from compiled code

The two back ends are meant to agree, and the regression suite compares
them. Where they knowingly differ:

- **`print` picks its format from the value in hand**, not from
  codegen's static `kind-of` analysis. Every case where the two disagree
  is one codegen gets wrong — it prints a `String`-typed parameter as a
  pointer, having no return-type inference — and the interpreter prints
  the text.
- **A field read out of a variant keeps its kind.** The interpreter
  records the kinds of a block's fields in a hidden word in front of the
  block, so destructuring `(Some "hello")` gives a `String` back;
  `cg-bind-fields` binds every field as an `Int`.
- **`==` on two `String`s compares their bytes** (spec §7.4, structural
  equality). Compiled code compares them by address, which agrees
  whenever both sides are the same literal — codegen gives identical
  literals one rodata entry — and disagrees for strings built at
  runtime.
- **`IStackVariant` allocates on the heap.** Region inference chose the
  stack for a value that provably does not escape; allocating it on the
  heap instead is sound, just less tidy.

And what the interpreter does not do:

- **Actors.** `spawn` hands the runtime the address of an entry
  function, and an interpreted function does not have one. The
  interpreter says so (`E_UNSUPPORTED_INTERPRETED`) rather than jumping
  to a number. Compile the program to run actors.
- **Heavy numeric work at native speed.** An AST interpreter allocates
  per operation and never reclaims within a run, so an Ed25519
  verification that takes milliseconds compiled takes tens of seconds
  interpreted and gigabytes of arena. The memory budget stops it with
  `E_OUT_OF_MEMORY` rather than taking the machine down. Compile that
  work; the REPL is for reaching it.
