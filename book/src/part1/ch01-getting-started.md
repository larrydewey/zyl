# Chapter 1: Getting Started

Welcome to *The Zyl Programming Language*! This chapter will guide you through installing Zyl, writing your first program, and understanding the basics of how Zyl works.

## 1.1 What is Zyl?

Zyl is a **deterministic Lisp systems language** designed for building reliable, high-performance software. Let's break down what that means:

- **Lisp**: Zyl uses S-expressions (parenthesized lists) for syntax — the same foundation as Lisp, Scheme, and Clojure. Code and data share the same structure.
- **Systems language**: Zyl compiles to native x86_64 machine code through its own backend and the system C compiler's linker. It gives you FFI (foreign function interface) access to C, raw byte buffers and atomics.
- **Deterministic**: Same source code + same inputs → identical binaries and identical outputs, every time. No randomness in compilation, no unordered hash maps, no timing-dependent behavior.
- **Region-based memory**: Instead of a garbage collector or manual `malloc`/`free`, Zyl's design assigns every value to a **region** (Stack, Heap, Global, Circular, or Pin). The current compiler implements a conservative part of this model; Chapter 5 says exactly which part.
- **Capability types**: Two key capabilities control aliasing: `TCap` (shared, immutable access — any number of references) and `TMut` (exclusive, mutable ownership — exactly one reference). Only a `let-mut` binding is `TMut`, and the compiler rejects a `set!` on anything else.
- **Actor concurrency**: Lightweight actors with isolated state and deterministic FIFO mailboxes. No shared mutable state between actors.
- **Self-hosting**: The Zyl compiler is written in Zyl and compiles itself, verified by a byte-identical fixed point. The original Rust bootstrap is archived and no longer part of the build, test, or use path at all — building Zyl needs nothing but a C compiler.

**Who is Zyl for?**
- Systems programmers who want Lisp's expressiveness with compile-time aliasing rules
- Lispers who want native code, static types, and deterministic memory
- Anyone building software where reproducibility and correctness are critical

## 1.2 Installation

### Prerequisites

- **Linux x86_64** (other platforms are not tested)
- `cc` (GCC or Clang) — the only compiler you need; Zyl is self-hosting
- `pthread` library (for the actor runtime)

### Building from Source

```bash
git clone https://github.com/larrydewey/zyl.git
cd zyl
./boot.sh
```

`boot.sh` links the committed compiler seed with `cc`, verifies the
self-hosting fixed point (the compiler reproduces its own committed
output, byte for byte, when compiling itself), and writes
`build/boot/zyl-self` — a wrapper you invoke like a normal compiler
binary from any directory. It also builds the language server,
`build/boot/zyl-lsp`. It prints a good number of `W_UNUSED_PARAMETER`
and `W_SHADOWED_BINDING` warnings along the way; they are not errors.

### Quick Test

```bash
# Create a test file
echo '(defn main () (print "Hello, Zyl!"))' > hello.zyl

# Compile
build/boot/zyl-self hello.zyl -o hello

# Run the resulting executable
./hello
# Output: Hello, Zyl!
```

### Installing It

`boot.sh` builds everything in place. To use `zyl` from any directory,
install it:

```bash
./install.sh                 # compiler, REPL and language server into ~/.zyl
source ~/.zyl/env            # or add this line to your shell rc
```

That gives you three commands: `zyl` (the compiler — with no arguments
it starts the REPL), `zyl-repl`, and `zyl-lsp` (the language server,
which editors start for you). The installer compiles the REPL from
`tools/repl.zyl` as part of the install; `boot.sh` does not build a
standalone REPL. `./install.sh --with-vscode` also builds and installs
the VS Code extension. `./uninstall.sh` removes the lot; it touches
nothing outside `~/.zyl` (or `$ZYL_HOME`, if you set it).

In the rest of this book, `zyl` means either the installed command or
`build/boot/zyl-self` in a checkout — they take the same arguments.

### Setting Up an Editor

This is worth doing before you write much code. The language server is
built from the same compiler that builds your programs, so its
diagnostics are the compiler's diagnostics — unbalanced parentheses,
arity mismatches, non-exhaustive matches and capability violations
appear as you type, with the same error codes `zyl` would print.

In VS Code, run `./install.sh --with-vscode` (it needs `npm`) and the
extension will find the server by itself. For Neovim, Emacs, Helix or
anything else with an LSP client, point it at `~/.zyl/bin/zyl-lsp` and
associate it with `.zyl`. **Chapter 35** has the configuration for each.

### The REPL

Zyl has a working REPL. Start it with `zyl` (no arguments) after
installing, or with `build/boot/zyl-self repl` in a checkout:

```
$ zyl repl
zyl> (+ 1 2)
=> 3
zyl> (defn double (n) (* n 2))
defined double
zyl> (def x 21)
x = 21
zyl> (double x)
=> 42
zyl> (Cons 1 (Cons 2 Nil))
=> (Cons 1 (Cons 2 Nil))
```

Every entry runs through the real compiler front end and is then
evaluated by an interpreter for the compiler's intermediate
representation, so an entry takes milliseconds and a `def` stays bound
from one entry to the next. `:help` lists the meta commands (`:type`,
`:time`, `:load`, `:save`, `:reset` and more). A session is saved to
`.zyl-session` in the directory you started it from and restored the
next time you start there. Chapter 35 covers the REPL in full.

The examples in this book are whole programs compiled with `zyl`, but
most of the expressions in them can be tried at the prompt first.

## 1.3 Your First Zyl Program

Create a file `factorial.zyl`:

```lisp
;; factorial.zyl — Compute factorial recursively

(defn factorial (n)
  (if (== n 0)
    1
    (* n (factorial (- n 1)))))

(defn main ()
  (print "Factorial of 10:")
  (print (factorial 10)))
```

Compile and run:
```bash
zyl factorial.zyl -o factorial
./factorial
# Output:
# Factorial of 10:
# 3628800
```

### Anatomy of This Program

| Line | Explanation |
|------|-------------|
| `;; ...` | Comment — ignored by compiler |
| `(defn factorial (n) ...)` | Define a function named `factorial` taking one parameter `n` |
| `(if (== n 0) 1 ...)` | If `n` equals 0, return 1; otherwise... |
| `(* n (factorial (- n 1)))` | Multiply `n` by factorial of `n-1` (recursive call) |
| `(defn main () ...)` | **Entry point** — every executable needs a `main` function with no parameters; the value it returns becomes the process exit status |
| `(print ...)` | Built-in: write one value to stdout, **followed by a newline** |

**Key observations:**
- **Prefix notation**: Operator comes first: `(+ 1 2)` not `1 + 2`
- **Parentheses are mandatory**: No operator precedence rules — grouping is always explicit
- **Strict left-to-right evaluation**: In `(f a b c)`, evaluate `f`, then `a`, then `b`, then `c`, then call
- **Last expression returns**: Functions return the value of their final expression (no `return` keyword)
- **`print` ends the line itself**: each `print` writes one value and a newline, which is why the output above is on two lines

### Running Without Building

`zyl eval` runs a program through the same interpreter the REPL uses,
without producing a binary or invoking the linker:

```bash
zyl eval factorial.zyl
# Output:
# Factorial of 10:
# 3628800
```

It is a quick way to try a program; `zyl file.zyl -o out` is what you
use to produce the native executable.

### A First Package

A single file is enough for everything in Part I. Larger programs are
**packages**: a directory with a `zyl.pkg` manifest. `zyl new` creates
one, and `zyl build` compiles it:

```bash
zyl new me/hello        # package names are scoped: owner/name
cd hello
zyl build               # writes ./hello (plus hello.s and hello.buildinfo)
./hello
```

`zyl new` writes `zyl.pkg` and a root module, `hello.zyl`. The
generated module's `main` returns 0 and prints nothing; replace it with
your own. Dependencies, the lock file and the package store are covered
in Chapter 25.

## 1.4 The Compilation Pipeline (High Level)

The specification describes an 11-phase pipeline in which no phase
depends on a later one. The self-hosted compiler follows that rule;
this is the order its driver (`stdlib/compiler/pipeline.zyl`) actually
runs:

```
┌─────────────────────────────────────────────────────────────────┐
│ Parsing                                                         │
│   Balance check, lexer + parser → raw AST (no-dispatch: every   │
│   S-expression becomes a generic call node, recognized later)   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Module resolution and qualification                             │
│   `use` lines, packages, canonical symbol names                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Macro expansion                                                 │
│   Innermost-first template substitution (not yet hygienic)      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Checks                                                          │
│   Capabilities, duplicate definitions, arity, mutability and    │
│   aliasing, match exhaustiveness, unused names, Secret taint    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Type inference                                                  │
│   Hindley-Milner inference with capability types               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Monomorphization, trait dispatch, closure lifting               │
│   Canonical (alphabetical) names for determinism                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ ICNF generation and optimization                                │
│   SSA-style IR; constant folding and dead-branch elimination    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Region inference                                                │
│   Values that provably never escape are placed on the stack     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Code generation and linking                                     │
│   x86_64 assembly (System V AMD64 ABI), then cc +               │
│   actor_runtime.c                                               │
└─────────────────────────────────────────────────────────────────┘
```

Two phases of the specification are not in the compiled pipeline yet:
**contract injection** (`requires`, `ensures` and the rest parse, but
are not checked — Chapter 24), and full **hash finalization** (a package
build writes a `.buildinfo` file with the compiler and assembly hashes,
but the dependency graph's hash is not yet mixed into the binary's).

**Why this matters for you:**
- Errors are caught early, and most carry a location: `error[CODE]`,
  `--> file:line:col`, the source line, a caret and a `= help:` hint
- Determinism is guaranteed by construction (ordered structures, no randomness)
- You can inspect the generated assembly: `zyl file.zyl --emit-asm -o file.s`

## 1.5 Running the Test Suite

Zyl includes a regression test suite:

```bash
# Quick smoke tests
./run_regression_tests.sh --quick

# Everything, including the self-hosting fixed-point check (./boot.sh)
./run_regression_tests.sh --full

# Everything except the fixed-point check
./run_regression_tests.sh --full --no-boot

# Only the tests whose name contains a word
./run_regression_tests.sh --filter structs
./run_regression_tests.sh --filter types
```

`--filter` is a case-insensitive substring match on the test name, so
`--filter structs` runs `tests/regression/structs.zyl` (and its
interpreter twin). The tests use Zyl's built-in testing framework
(covered in Chapter 11).

## 1.6 Getting Help

| Resource | Purpose |
|----------|---------|
| `zyl help` | Every subcommand, one line each (any unrecognized subcommand prints the same list) |
| `:help` in the REPL | REPL commands and editing keys |
| `:doc NAME` in the REPL | Documentation for a built-in or special form |
| `zyl_specification.txt` | Canonical language spec (v5.0) |
| `spec/` | Structured reference by topic |
| `docs/` | Design rationale, error codes (`docs/errors.md`), the REPL (`docs/repl.md`) |
| `tests/regression/` | Runnable examples of implemented features |

## 1.7 Mental Models: Coming from Other Languages

### From Rust
| Rust Concept | Zyl Equivalent |
|--------------|----------------|
| `&T` (shared reference) | `TCap` — every plain `let` binding |
| `&mut T` (exclusive reference) | `TMut` — only a `let-mut` binding |
| Ownership/borrow checker | Capability checks + region inference (compile time) |
| `match` exhaustiveness | Same — compile error if non-exhaustive |
| Traits | Similar declaration and `impl` syntax; calls are written `(Trait.method receiver ...)` |
| Generics | Inferred — you do not write type parameters on functions |

**Key difference**: Zyl infers types, regions and capabilities — you
rarely annotate anything. Annotations exist (`(x Int)`), and they
matter in a few places this book points out as they come up.

### From C/C++
- No manual `malloc`/`free` in ordinary code — values live in regions managed by the runtime
- Mutation is explicit: only `let-mut` bindings can be reassigned, and struct fields never can
- No header files — modules are imported with `(use collections/vec)`
- Deterministic builds — same source always produces identical assembly (the linked binary can differ by a few bytes of linker metadata)

### From Lisp (Scheme, Common Lisp, Clojure)
| Lisp Feature | Zyl Status |
|--------------|------------|
| S-expression syntax | ✅ Same |
| Homoiconicity | ✅ Code = data |
| Macros | ⚠️ Template macros, innermost-first; not yet hygienic (Chapter 10) |
| `eval` at runtime | ❌ No `eval` function in compiled programs (the REPL and `zyl eval` interpret whole entries) |
| Dynamic typing | ❌ Static Hindley-Milner inference + capabilities (type errors are not yet rejected; Chapter 15) |
| GC | ❌ Region-based |
| REPL | ✅ `zyl repl` (see above) |
| `cons`/`car`/`cdr` | Lists are an ADT: `(Cons head tail)` / `Nil`; `car` and `cdr` exist but return an `Option` |

### From Python/JavaScript
- **Compiled** — `zyl` produces a native executable
- **Static types** — inferred, not declared (mostly)
- **No `null`** — use `Option` ( `(Some value)` / `None` )
- **Errors are values** — use `Result` ( `(Ok value)` / `(Err error)` ); `error` aborts, and `try` / `catch` can intercept that (Chapter 3)
- **Immutable by default** — mutation requires explicit `let-mut` + `set!`

## 1.8 What's Next?

In [Chapter 2](ch02-syntax-and-types.md), we'll explore Zyl's syntax in depth: atoms (numbers, strings, booleans), lists, variables, bindings, and the core types.

---

> **💡 For beginners**: Don't worry if the compilation pipeline seems complex. You don't need to understand all phases to write Zyl code. The compiler handles the hard parts — you write functions, the compiler checks them.

> **💡 For experts**: Phase isolation means you can reason about each phase independently. Type inference never depends on region inference; region inference never depends on code generation. Each phase is a plain function over the previous phase's output in `stdlib/compiler/`.
