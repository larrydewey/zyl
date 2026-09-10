# Chapter 1: Getting Started

Welcome to *The Zyl Programming Language*! This chapter will guide you through installing Zyl, writing your first program, and understanding the basics of how Zyl works.

## 1.1 What is Zyl?

Zyl is a **deterministic Lisp systems language** designed for building reliable, high-performance software. Let's break down what that means:

- **Lisp**: Zyl uses S-expressions (parenthesized lists) for syntax — the same foundation as Lisp, Scheme, and Clojure. Code and data share the same structure.
- **Systems language**: Zyl compiles to native x86_64 machine code. It gives you control over memory layout, calling conventions, and FFI (foreign function interface) — like C, C++, or Rust.
- **Deterministic**: Same source code + same inputs → identical binaries and identical outputs, every time. No randomness in compilation, no non-deterministic hash maps, no timing-dependent behavior.
- **Region-based memory**: Instead of a garbage collector or manual `malloc`/`free`, Zyl assigns every value to a **region** (Stack, Heap, Global, Circular, or Pin) at compile time. The compiler proves no value escapes its region.
- **Capability types**: Two key capabilities control aliasing: `TCap` (shared, immutable access — any number of references) and `TMut` (exclusive, mutable ownership — exactly one reference). The compiler enforces this at compile time.
- **Actor concurrency**: Lightweight actors with isolated state and deterministic FIFO mailboxes. No shared mutable state between actors.
- **Self-hosting**: The Zyl compiler is written in Zyl and compiles itself. The Rust bootstrap is only needed for the very first build.

**Who is Zyl for?**
- Systems programmers who want Lisp's expressiveness with Rust-like safety
- Lispers who want native performance, static types, and deterministic memory
- Anyone building software where reproducibility and correctness are critical

## 1.2 Installation

### Prerequisites

- **Rust 1.70+** (for building the bootstrap compiler)
- **Linux x86_64** (other platforms may work but are not tested)
- `cc` (GCC or Clang) for the linking phase
- `pthread` library (for actor runtime)

### Building from Source

```bash
git clone https://github.com/your-org/zyl.git
cd zyl
cargo build --release
```

This builds two binaries in `target/release/`:
- `zyl` — The batch compiler (compile `.zyl` files to executables)
- `zyl-repl` — The interactive REPL (read-eval-print loop)

### Quick Test

```bash
# Create a test file
echo '(defn main () (print "Hello, Zyl!"))' > hello.zyl

# Compile
./target/release/zyl hello.zyl

# Run the resulting executable
./hello
# Output: Hello, Zyl!
```

### Using the REPL

```bash
./target/release/zyl-repl
```

You'll see:
```
Zyl REPL v0.1.0
Type :help for commands, :quit to exit
zyl>
```

Try some expressions:
```lisp
zyl> (+ 1 2 3)
6
zyl> (defn square (x) (* x x))
zyl> (square 5)
25
zyl> :quit
```

**REPL Commands:**
| Command | Description |
|---------|-------------|
| `:help` | Show available commands |
| `:quit` | Exit the REPL |
| `:type <expr>` | Show inferred type of expression |
| `:ast <expr>` | Show parsed AST |
| `:icnf <expr>` | Show ICNF (intermediate representation) |

## 1.3 Your First Zyl Program

Create a file `factorial.zyl`:

```lisp
;; factorial.zyl — Compute factorial recursively

(defn factorial (n)
  (if (== n 0)
    1
    (* n (factorial (- n 1)))))

(defn main ()
  (print "Factorial of 10: ")
  (print (factorial 10))
  (print "\n"))
```

Compile and run:
```bash
./target/release/zyl factorial.zyl
./factorial
# Output: Factorial of 10: 3628800
```

### Anatomy of This Program

| Line | Explanation |
|------|-------------|
| `;; ...` | Comment — ignored by compiler |
| `(defn factorial (n) ...)` | Define a function named `factorial` taking one parameter `n` |
| `(if (== n 0) 1 ...)` | If `n` equals 0, return 1; otherwise... |
| `(* n (factorial (- n 1)))` | Multiply `n` by factorial of `n-1` (recursive call) |
| `(defn main () ...)` | **Entry point** — every executable needs a `main` function with no parameters |
| `(print ...)` | Built-in function to write to stdout |
| `"\n"` | String literal with newline character |

**Key observations:**
- **Prefix notation**: Operator comes first: `(+ 1 2)` not `1 + 2`
- **Parentheses are mandatory**: No operator precedence rules — grouping is always explicit
- **Strict left-to-right evaluation**: In `(f a b c)`, evaluate `f`, then `a`, then `b`, then `c`, then call
- **Last expression returns**: Functions return the value of their final expression (no `return` keyword)

## 1.4 The Compilation Pipeline (High Level)

Zyl's compilation is a **strict 11-phase pipeline**. No phase depends on a later one — this is a hard architectural rule.

```
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1: Parsing                                                │
│   Lexer + Parser → Raw AST (no-dispatch, all S-expressions     │
│   become generic Call/Apply nodes)                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 2: Macro Expansion                                        │
│   Innermost-first, gensym hygiene (no variable capture)        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 3: Type Inference + Trait Resolution                      │
│   Hindley-Milner inference with capability types + traits      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 4: Region Inference + Capture Analysis                    │
│   Assign every value to Stack, Heap, Global, Circular, or Pin  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 5: Monomorphization                                       │
│   Instantiate generic functions/ADTs at each call site         │
│   Canonical naming (alphabetical type order) for determinism   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 6: ICNF Generation                                        │
│   SSA-based IR with region annotations on every value          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 7: Optimization                                           │
│   Constant folding, dead code elimination (safe only)          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 8: Code Generation                                        │
│   x86_64 assembly, System V AMD64 ABI                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 9: Linking                                                │
│   cc + actor_runtime.c (pthread-based actor system)            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 10: Contract Injection (Optional)                         │
│   Preconditions, postconditions, invariants, recovery          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 11: Hash Finalization                                     │
│   Binary hash for deterministic verification                   │
└─────────────────────────────────────────────────────────────────┘
```

**Why this matters for you:**
- Errors are caught early (type errors in Phase 3, region escapes in Phase 4)
- Determinism is guaranteed by construction (ordered maps, FNV-1a hashing, no randomness)
- You can inspect intermediate output: `zyl --emit-ast`, `--emit-icnf`, `--emit-asm`

## 1.5 Running the Test Suite

Zyl includes a comprehensive regression test suite:

```bash
# Quick smoke tests (~30 seconds)
./run_regression_tests.sh --quick

# Full suite including self-hosting verification (~5 minutes)
./run_regression_tests.sh --full

# Filter by category
./run_regression_tests.sh --filter structs
./run_regression_tests.sh --filter types
./run_regression_tests.sh --filter balanced-parens
```

All tests use Zyl's built-in testing framework (covered in Chapter 11).

## 1.6 Editor Support

### VS Code
```bash
code --install-extension editors/vscode/zyl-*.vsix
```
Features: syntax highlighting, bracket matching, snippets.

### Vim/Neovim
```vim
Plug 'larry/zyl', {'rtp': 'editors/vim/'}
```

### Other Editors
TextMate grammars in `editors/` for Sublime, Atom, etc.

## 1.7 Getting Help

| Resource | Purpose |
|----------|---------|
| `zyl --help` | Compiler flags (`--emit-ast`, `--emit-icnf`, `--emit-asm`, `-o`) |
| `:help` in REPL | REPL commands |
| `zyl_specification.txt` | Canonical language spec (v4.2) |
| `spec/` | Structured reference by topic |
| `docs/architecture-decisions.md` | Design rationale |
| `tests/regression/` | Runnable examples of every feature |

## 1.8 Mental Models: Coming from Other Languages

### From Rust
| Rust Concept | Zyl Equivalent |
|--------------|----------------|
| `&T` (shared reference) | `TCap<T>` (capability type, inferred) |
| `&mut T` (exclusive reference) | `TMut<T>` (capability type, inferred) |
| Ownership/borrow checker | Region inference + capability types (compile-time) |
| `Box<T>` | `TBox<T>` (heap-managed, explicit) |
| `Pin<&mut T>` | `TPin<T>` (FFI-pinned, non-moving) |
| `match` exhaustiveness | Same — compile error if non-exhaustive |
| Traits | Same concept, same coherence rules |
| Generics + monomorphization | Same, but canonical naming is alphabetical |

**Key difference**: Zyl infers regions and capabilities — you rarely annotate them. The compiler proves safety.

### From C/C++
- No manual memory management — regions are inferred and enforced
- No undefined behavior — capability types prevent aliasing violations
- No header files — modules use `(use module { symbol })` syntax
- Deterministic builds — same source always produces identical binary

### From Lisp (Scheme, Common Lisp, Clojure)
| Lisp Feature | Zyl Status |
|--------------|------------|
| S-expression syntax | ✅ Same |
| Homoiconicity | ✅ Code = data |
| Macros | ✅ Hygienic, innermost-first, gensym |
| `eval` at runtime | ❌ No — AOT compiled only |
| Dynamic typing | ❌ Static Hindley-Milner + capabilities |
| GC | ❌ Region-based (compile-time) |
| REPL | ✅ `zyl-repl` (interprets via compiled code) |
| `cons`/`car`/`cdr` | ❌ Use ADTs: `(Cons head tail)` / `Nil` |

### From Python/JavaScript
- **Compiled, not interpreted** — `zyl` produces a native executable
- **Static types** — inferred, not declared (mostly)
- **No `null`** — use `Option` ( `Some value` / `None` )
- **No exceptions** — use `Result` ( `Ok value` / `Err error` )
- **Immutable by default** — mutation requires explicit `let-mut` + `set!`

## 1.9 What's Next?

In [Chapter 2](ch02-syntax-and-types.md), we'll explore Zyl's syntax in depth: atoms (numbers, strings, booleans, symbols), lists, variables, bindings, and the core type system.

---

> **💡 For beginners**: Don't worry if the compilation pipeline seems complex. You don't need to understand all phases to write Zyl code. The compiler handles the hard parts — you write functions, the compiler proves they're safe.

> **💡 For experts**: The pipeline's phase isolation (P6) means you can reason about each phase independently. Type inference never depends on region inference; region inference never depends on monomorphization. This is unusual and powerful.