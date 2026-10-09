# Chapter 1: Getting Started

Welcome to *The Zyl Programming Language*! This chapter will guide you through installing Zyl, writing your first program, and understanding the basics of how Zyl works.

## 1.1 What is Zyl?

Zyl is a **deterministic Lisp systems language** designed for building reliable, high-performance software. Let's break down what that means:

- **Lisp**: Zyl uses S-expressions (parenthesized lists) for syntax — the same foundation as Lisp, Scheme, and Clojure. Code and data share the same structure.
- **Systems language**: Zyl compiles to native x86_64 machine code through its own backend, assembler and linker: a program that calls no C is a static executable with no libc. It gives you FFI (foreign function interface) access to C, raw byte buffers and atomics.
- **Deterministic**: Same source code + same inputs → identical binaries and identical outputs, every time. No randomness in compilation, no unordered hash maps, no timing-dependent behavior.
- **No silent failure**: `Int` arithmetic is checked by default, so an overflow stops the program with `E_OVERFLOW` instead of wrapping; a division whose divisor might be zero must say what happens (`div!` or `div?`); a program declares the capabilities it uses (`(capabilities io)` to open files; `actor`, `ffi` and `secret` likewise), and without the declaration it has none of them.
- **Region-based memory**: Instead of a garbage collector or manual `malloc`/`free`, Zyl's design assigns every value to a **region** (Stack, Heap, Global, Circular, or Pin). The current compiler infers Stack and Heap placement, reclaims short-lived values when their call returns, and implements Pin; Chapter 5 says exactly which part.
- **Capability types**: Zyl has no in-place mutation: every `let` binding is immutable, `set!` on a `let-mut` binding rebinds it, and `set!` on anything else is `E_MUT_CONFLICT`. A struct field is never assignable.
- **Actor concurrency**: Actors with isolated state that communicate over typed channels, each with one writer and one reader, so output does not depend on scheduling. No shared mutable state between actors.
- **Self-hosting**: The Zyl compiler is written in Zyl and compiles itself, verified by a byte-identical fixed point. The original Rust bootstrap is archived and no longer part of the build, test, or use path at all — building Zyl needs nothing but a C compiler.

**Who is Zyl for?**
- Systems programmers who want Lisp's expressiveness with compile-time aliasing rules
- Lispers who want native code, static types, and deterministic memory
- Anyone building software where reproducibility and correctness are critical

## 1.2 Installation

### Prerequisites

- **Linux x86_64** (other platforms are not tested)
- `cc` (GCC or Clang), to link the committed compiler seed and to link
  programs that call foreign C; Zyl is self-hosting, and other programs
  need no toolchain at all

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
`build/boot/zyl-lsp`. The compiler's own build is warning-free, so
anything `boot.sh` prints besides its progress lines is worth reading.

### Quick Test

```bash
# Create a test file
echo '(defn main () (print "Hello, Zyl!") 0)' > hello.zyl

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
the VS Code extension. `./uninstall.sh` removes what the installer put
in `~/.zyl` (or `$ZYL_HOME`, if you set it) and keeps your own files
there; `--purge` removes the whole directory.

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
  (print (factorial 10))
  0)
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
| `(defn main () ...)` | **Entry point** — every executable needs a `main` function with no parameters; it must return an `Int` (anything else is a type error), which becomes the process exit status |
| `0` | `main`'s last form, so `main` returns 0: success |
| `(print ...)` | Built-in: write one value to stdout, **followed by a newline** |

**Key observations:**
- **Prefix notation**: Operator comes first: `(+ 1 2)` not `1 + 2`
- **Parentheses are mandatory**: No operator precedence rules — grouping is always explicit
- **Strict left-to-right evaluation**: In `(f a b c)`, evaluate `f`, then `a`, then `b`, then `c`, then call
- **Last expression returns**: A function body may hold several forms, run in order; the function returns the value of the final one (no `return` keyword)
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
│   Innermost-first template substitution, gensym hygiene         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Checks                                                          │
│   Capabilities, duplicate definitions, arity, malformed forms,  │
│   mutability and aliasing, release linearity, match             │
│   exhaustiveness, unused names, Secret taint                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Derive expansion and impl lifting                               │
│   `derive` impls generated; impl bodies become                  │
│   `Trait.method_Type` functions                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Type checking                                                   │
│   Hindley-Milner inference; every type error reported; static   │
│   trait resolution and per-type specialization (`f~T1,T2`)      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Numeric check                                                   │
│   The package's `(numeric ...)` policy; a `/` or `%` whose      │
│   divisor is not a nonzero literal is E_PARTIAL_OPERATION       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ ICNF lowering and optimization                                  │
│   Tree-shaped IR; inlining of small functions, constant folding │
│   and dead-branch elimination (nothing is reordered)            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Region inference and reuse                                      │
│   Escape analysis places each allocation in the call's frame    │
│   region, the caller's result region or the heap; a dead,       │
│   unique value's block may be reused in place                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Code generation and linking                                     │
│   x86_64 assembly (System V AMD64 ABI): machine IR with         │
│   linear-scan register allocation where a function fits it,     │
│   the stack-machine generator otherwise; the emitted frames are │
│   verified; then Zyl's own assembler and static linker with the │
│   runtime (rt.zo): a static binary with no libc (cc + libc if   │
│   it calls foreign C)                                           │
└─────────────────────────────────────────────────────────────────┘
```

Contracts (`requires`, `ensures`, `invariant`, `recover`,
`checkpoint`) are checked where they appear, and `(contracts off)` or
`--contracts=off` removes the checks (Chapter 24). A package build
finalizes a hash of its compiler, dependency graph, native objects and
ICNF, writes it to a `.buildinfo` file and embeds it in the binary
(Chapter 26).

**Why this matters for you:**
- Errors are caught early, and most carry a location: `error[CODE]`,
  `--> file:line:col`, the source line, a caret and a `= help:` hint
- Determinism is guaranteed by construction (ordered structures, no randomness)
- `zyl check file.zyl` runs every phase of a build except code generation and linking: the fast way to find errors without building, and a clean check means the program builds
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
./run_regression_tests.sh --full --no-boot --filter structs
./run_regression_tests.sh --full --no-boot --filter types
```

`--filter` is a case-insensitive substring match on the test name, and
it applies within the selected mode: `--full --no-boot --filter structs`
runs `tests/regression/structs.zyl` (and its interpreter twin), while
`--filter structs` alone stays in quick mode and selects nothing. The tests use Zyl's built-in testing framework
(covered in Chapter 11).

## 1.6 Getting Help

| Resource | Purpose |
|----------|---------|
| `zyl help` | Every subcommand, one line each (any unrecognized subcommand prints the same list) |
| `zyl explain CODE` | What a diagnostic means, with a wrong program and its fix; `zyl explain` alone lists every code |
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
| `&T` (shared reference) | an immutable `let` binding — any number of readers |
| `&mut T` (exclusive reference) | a `let-mut` binding — the only assignable binding; `set!` rebinds it |
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
- Deterministic builds — same source always produces a byte-identical binary
- Integer overflow is not undefined and does not wrap silently: it stops the program with `E_OVERFLOW` unless the file says `(numeric wrapping)`

### From Lisp (Scheme, Common Lisp, Clojure)
| Lisp Feature | Zyl Status |
|--------------|------------|
| S-expression syntax | ✅ Same |
| Homoiconicity | ✅ Code = data |
| Macros | ✅ Template macros, innermost-first, hygienic (Chapter 10) |
| `eval` at runtime | ❌ No `eval` function in compiled programs (the REPL and `zyl eval` interpret whole entries) |
| Dynamic typing | ❌ Static Hindley-Milner inference + capabilities; every type error stops the compile (Chapter 15) |
| GC | ❌ Region-based |
| REPL | ✅ `zyl repl` (see above) |
| `cons`/`car`/`cdr` | Lists are an ADT: `(Cons head tail)` / `Nil`; `car` and `cdr` exist but return an `Option` |

### From Python/JavaScript
- **Compiled** — `zyl` produces a native executable
- **Static types** — inferred, not declared (mostly), and checked strictly: an `if` needs a `Bool`, not a number, and `(+ 1 "a")` does not compile
- **No `null`** — use `Option` ( `(Some value)` / `None` )
- **Errors are values** — use `Result` ( `(Ok value)` / `(Err error)` ); `error` returns an `Err`, and `panic` aborts, which `try` / `catch` can intercept (Chapter 3)
- **Immutable by default** — mutation requires explicit `let-mut` + `set!`

## 1.8 What's Next?

In [Chapter 2](ch02-syntax-and-types.md), we'll explore Zyl's syntax in depth: atoms (numbers, strings, booleans), lists, variables, bindings, and the core types.

---

> **💡 For beginners**: Don't worry if the compilation pipeline seems complex. You don't need to understand all phases to write Zyl code. The compiler handles the hard parts — you write functions, the compiler checks them.

> **💡 For experts**: Phase isolation means you can reason about each phase independently. Type inference never depends on region inference; region inference never depends on code generation. Each phase is a plain function over the previous phase's output in `stdlib/compiler/`.
