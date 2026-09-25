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
under `stdlib/repl/`. `install.sh` compiles `tools/repl.zyl` into
`~/.zyl/bin/zyl-repl-bin` and installs a `zyl-repl` wrapper for it; the
installed `zyl` wrapper starts it when given no arguments. `./boot.sh`
does not build the standalone binary (any `build/boot/zyl-repl` is a
leftover of an older build); from a checkout, use
`build/boot/zyl-self repl`.

## How an entry is evaluated

Every entry goes through the real compiler. Parsing, module resolution,
macro expansion, the capability, duplicate, arity, mutability,
exhaustiveness, unused and secret checks, derive expansion, impl lifting,
closure lifting, type checking (with static trait resolution and
per-type specialization), ICNF lowering, inlining and optimization,
region inference and in-place reuse all run exactly as they do for a
compile with `zyl` — the shared implementation is
`stdlib/compiler/pipeline.zyl`, and the REPL calls `compile-to-fns`,
which is `compile-to-asm` minus code generation. (The interpreter
ignores the regions and the reuse decisions; see below.)

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
| `globals` | the values bound by `(def name expr)` | passed to the entry as arguments, and readable by definitions as top-level defs |

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

In a file, a top-level `def` is an immutable global initialized before
`main`. At the prompt the REPL gives it the matching meaning: the
expression is evaluated once, now, and the value is bound for every
later entry. It is an immutable binding, like any other in the language;
`set!` on it is refused the same way it would be in a file.

### Definitions

`defn`, `deftype`, `defstruct`, `defmacro`, `trait` and `impl` entries
are added to the session's text and checked by compiling the session
with them. Nothing runs — a definition has no effect until something
calls it. A name can be defined only once per session: entering a second
`(defn f ...)` is rejected with `E_DUPLICATE_DEFINITION` (the duplicate
check sees the whole session as one program), and the first definition
stays in force. `:reset` clears the session so a name can be defined
afresh. The location of that diagnostic is a line of the session's
generated program (`<repl>:N:1`), not a position in what you typed,
though the source line it shows is your entry's text.

A definition can refer to a `def` binding: after `(def k 5)`,
`(defn f (x) (+ x k))` and `(f 1)` give 6. Each binding is also emitted
into the session program as a top-level `(def k (if false SRC
(zyl-repl-global "k")))`: the live branch reads the value the binding
stored (a runtime table), and the dead branch gives type inference SRC's
type without running SRC again. `zyl-repl-global` is typed (`String ->
a`) only while the REPL compiles its own generated program; anywhere
else, the prompt included, it is an undefined function
(`E_UNBOUND_VARIABLE`). Cached `def` values are cleared before
each entry, so `:reset` never leaves an old value behind.

### Modules

`(use module/name)` extends the session's module set (the REPL answers
`using module/name`), and is rejected if the module does not resolve or
collides with a name already in scope; a module path naming a package
the session has no manifest entry for is reported as
`E_PKG_UNDECLARED_DEP`. A
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
| `PageUp` / `PageDown` | walk history directly |
| `Left` / `Right`, `Ctrl-B` / `Ctrl-F` | move by character |
| `Ctrl-Left` / `Ctrl-Right`, `Alt-b` / `Alt-f` | move by word |
| `Home` / `End`, `Ctrl-A` / `Ctrl-E` | start and end of the current line |
| `Alt-<` / `Alt->` | start and end of the whole entry |
| `Ctrl-K` / `Ctrl-U` | kill to end / to start of line |
| `Ctrl-W`, `Alt-Backspace` / `Alt-d` | kill the word behind / ahead |
| `Backspace`, `Ctrl-H` / `Delete` | delete the character behind / under the cursor |
| `Ctrl-Y` | yank what was last killed |
| `Ctrl-T` | transpose the two characters at the cursor |
| `Ctrl-R` | search history backwards; `Ctrl-R` again for the next match, `Enter` to run it, `Esc` to edit it, `Ctrl-G` to forget it |
| `Tab` | complete a name; at the start of a token, indent |
| `Ctrl-L` | clear the screen, keeping the entry |
| `Ctrl-C` | abandon this entry |
| `Ctrl-D` | delete forward, or leave the session on an empty entry |
| `Alt-Enter` | insert an indented newline without evaluating |
| `Ctrl-O` | submit the entry as it stands, even if it is not a complete form |

`Ctrl-J` sends the same byte as a newline, which the terminal decoder
(`stdlib/repl/terminal.zyl`) reads as `Enter`; the reader's separate
`Ctrl-J` binding is therefore never reached, and `Ctrl-J` behaves like
`Enter`.

The entry is syntax-highlighted as it is typed (`stdlib/repl/highlight.zyl`:
comments, strings, numbers, keywords, type names and parentheses, colored
lexically on every keystroke).

An entry that is not a complete S-expression continues on the next line,
indented two columns per open paren. Pasted text arrives through
bracketed paste, so a pasted newline inserts a line instead of
submitting.

History lives in `~/.zyl/repl_history` (or `$ZYL_REPL_HISTORY`; the
`~/.zyl` state directory itself can be moved with `$ZYL_STATE_DIR`, which
is deliberately separate from `$ZYL_HOME`, the compiler bundle), written
as each entry is submitted rather than at exit, with newlines escaped so
the file stays one entry per line.

## Meta commands

| command | short form | |
|---|---|---|
| `:help` | `:h` | the commands and the main keys |
| `:quit` | `:q` | leave |
| `:history` | `:hist` | entries from this and earlier sessions |
| `:defs` | `:browse` | the modules, bindings and definitions in scope |
| `:doc NAME` | `:d` | documentation for a built-in or special form |
| `:type EXPR` | `:t` | the type of an expression, without evaluating it |
| `:time EXPR` | `:tm` | evaluate it and say how long it took |
| `:load PATH` | `:l` | read a file's modules and definitions into the session |
| `:save PATH` | `:s` | write the session's definitions (not its modules or bindings) to a file |
| `:reset` | `:r` | forget everything, here and on disk, and start over |
| `:clear` | `:cls` | clear the screen |

An unknown command is answered with `unknown command :NAME — :help lists
them`. Tab completion offers the long forms of the commands except
`:type` and `:time`.

A relative path in `:load` or `:save` resolves against the directory you
started in, not the working directory — the REPL moved to the bundle
before the first prompt, because compiling needs `stdlib/` and
`actor_runtime.c` to be there.

The same commands work when input is piped, so a script can end with
`:defs` or start with `:load`.

`:type` reports the type `compiler/type_annotate.zyl` infers for the
expression, generalized: after `(use collections/vec)`, `:type (vec-push (vec-create-default 1) "a")`
is `(Vec String)`, `:type (fn (x) x)` is `(a -> a)`. A type the pass
could not pin down prints as `a` (unconstrained) or `?` (conflicting).

Known bug (2026-09-25): once the session holds a `def` binding, `:type`
fails with `E_UNBOUND_VARIABLE` on `zyl-repl-global`. The type-only path
compiles the session's generated `(def ...)` lines without setting the
flag (`repl-compiling`) that types that internal form, which only
`eval.zyl`'s compile of an entry sets. Evaluating entries is not
affected.

## What carries over between sessions

Three things, in the order they are applied when a session starts:

1. **The default modules** — `core/core`, `core/list`, `core/option`,
   `core/result`, `allocator/allocator`.
2. **`~/.zyl/replrc`** (or `$ZYL_REPLRC`), if it exists: ordinary Zyl
   source, one form per entry, replayed through the normal path. This is
   where a `(use ...)` you always want, or a helper you always reach
   for, belongs.
3. **`.zyl-session` in the directory you started in**, written after
   every entry that changes the session. It holds the modules, the
   definitions as entered, and a `(def ...)` per binding — ordinary Zyl
   source, editable by hand and loadable with `:load`.

So a terminal session picks up where the last one in that directory left
off. Because restoring replays the entries, a `def` whose expression had
an effect has that effect again; `:reset` clears the session and the
file, and deleting the file says the same thing.

A piped session (standard input is not a terminal) does none of this:
it reads no `replrc`, restores no `.zyl-session` and writes none, loads
no history and prints no banner. A script should do the same thing on
every machine, whatever happens to be saved next to it. Results are
still written with the same ANSI colors as at a terminal.

History is separate and global (`~/.zyl/repl_history`): what you typed
is worth keeping across projects, what you defined is not.

## How a value prints

A result prints as the value it is, not as an address:

```
zyl> (Cons 1 (Cons 2 Nil))
=> (Cons 1 (Cons 2 Nil))
zyl> (Some "hi")
=> (Some "hi")
zyl> (defstruct P (x) (y))
defined P
zyl> (make-P 3 4)
=> (P 3 4)
```

The interpreter's blocks carry their constructor's name and the kinds of
their fields in hidden words ahead of the payload, which is what makes
this possible without a `Show` instance and without changing the layout
compiled code reads. Nesting is bounded at six levels and twenty-four
fields per level, because a result line is not the place to print ten
thousand elements.

Compiled code prints a struct or ADT this way only through `Show`:
`(derive T Show)` (spec §5.6) generates an impl, and `print` of a value
whose type has one calls it. `print` of a value with no `Show` impl, in a
compiled program or through `zyl eval`, still prints an address; only the
REPL's result line reads the hidden words.

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
them, with the interpreter in its checking mode (below). Both take every
value's representation from the type checker, so `print`, `==` and a
field read out of a variant see the same String, Float or Int in both.
Where they knowingly differ:

- **`print` picks its format from the value in hand**; compiled code
  picks it from the node's inferred type. For a well-typed program the
  two are the same.
- **`IStackVariant` allocates on the heap.** Region inference chose the
  stack for a value that provably does not escape; allocating it on the
  heap instead is sound, just less tidy.
- **Regions and reuse are ignored.** The interpreter allocates in its
  own arenas, so a `with-region` byte limit holds only in compiled code,
  and every variant construction allocates a new block, whatever
  `reuse.zyl` decided.

### Values

An interpreted value is a `Val`: `VInt`, `VFlt` (a Float held as a
Float), `VStr` (a String held as a String) or `VPtr` (the address of a
heap block: a variant, a struct, a closure or a function reference). A
value becomes a machine word only where one is needed, to store it in a
block or pass it to a runtime entry, and those conversions go through
typed runtime entries: `zyl_float_bits` and `zyl_float_of_bits` for a
Float, and for a String `zyl_word_of_cstr` and `zyl_cstr_of_word`, raw
entries only the standard library may call (`E_FFI_RESTRICTED`). Heap blocks are laid out as compiled code lays them
out, `[tag][field]...`, with the fields' kinds and the constructor's name
in hidden words in front. A binding is a name and a `(Ref Val)` cell
that `set!` writes. The function index is an `(SMap Icnf)` from name to
lowered function. An FFI result is typed by the symbol's signature: a
String or Float result becomes `VStr` or `VFlt`, anything else `VInt`.

### Checking mode

`ZYL_INTERP_CHECK=1` makes every operator check its operands' tags
(arithmetic on two Ints or two Floats, comparison within one tag, bit
operations on Ints) and requires every condition to be exactly 0 or 1.
A violation is `E_INTERP_TAG`: the type checker accepted a program that
misuses a value, which is a checker bug (spec §4.8). The regression
suite's interpreter section always runs in this mode.

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
