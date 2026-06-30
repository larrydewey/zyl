# Zyl — Vision & Agent Instructions

## Project Vision

**Zyl** is a deterministic Lisp systems language with:
- Region-based memory management (no GC, no manual allocation)
- Hindley-Milner type inference with capability types
- Actor concurrency model (no shared mutable state)
- SSA-based intermediate representation (ICNF)
- FFI safety through pinning and timeout enforcement
- Hygienic macro system
- Full determinism contract: same source + same inputs → identical outputs

The language uses S-expression syntax (Lisp-family) and targets x86_64 native code.

**Ultimate goal**: Self-hosting — write the standard library in Zyl and compile it with Zyl itself.

---

## How to Work on This Project

### ALWAYS READ FIRST
1. **`PROGRESS.md`** — Current status, what's built, what's broken, next steps
2. **`zyl_specification.txt`** — The authoritative spec for all language features
3. **`AGENTS.md`** — This file (vision and instructions)

### Project Structure Reference
```
src/
├── main.rs          # CLI: compile files or evaluate expressions
├── repl.rs          # Interactive REPL
├── ast/mod.rs       # AST nodes: Expr, AtomKind, TypeExpr, Region, CapType
├── lexer/mod.rs     # Tokenizer → Vec<Token>
├── parser/mod.rs    # Token stream → Program (AST)
├── typeck/mod.rs    # HM type inference with region/capability constraints
├── region/mod.rs    # Escape analysis → RegionMap (Stack/Heap/etc.)
├── macros/mod.rs    # Hygienic macro expansion (gensym-based)
├── ir/mod.rs        # ICNF SSA IR: Functions, Blocks, Instructions, SsaValue
├── codegen/mod.rs   # ICNF → x86_64 assembly / LLVM IR
├── actor/mod.rs     # Actor system: spawn, send, FIFO mailboxes
├── ffi/mod.rs       # FFI registry with pinning and timeout
├── eval/mod.rs      # Bootstrap interpreter (big-step semantics)
├── compiler/mod.rs  # Full 10-phase pipeline tying everything together
└── util/mod.rs      # Helpers
```

### Key Specifications to Reference
- **§1**: Lexical structure — tokens, comments, whitespace
- **§2**: AST — all expression forms (def, defn, let, if, try/catch, spawn, send, ffi-call, ffi-pin, assert)
- **§3**: Value model — Int64, Float64, Bool, String, Tuple, Closure, ActorRef, Address, Unit
- **§4**: Type system — HM inference, capabilities (TCap, TMut, TAtomic, TBox, TPin)
- **§5-5.1**: Region system — Stack/Heap/Global/Circular/Pin allocation rules
- **§7**: Evaluation semantics — big-step judgment ⟨E, Σ⟩ → ⟨V, Σ'⟩
- **§11**: Actor concurrency — private state + FIFO mailbox, no shared mutation
- **§12**: FFI — (ffi-call name args timeout), pinning, isolation
- **§14**: ICNF — SSA IR with phi nodes and dominance
- **§15**: Macro system — AST-only, hygienic, gensym-based
- **§17**: Compilation pipeline — 10 phases in strict order
- **§18**: Determinism contract — what is/isn't observable
- **§20**: Standard library modules

### Error Model (Spec §19)
Errors are `(code, location, message)` tuples:
- `E_MUT_CONFLICT` — aliasing invariant violation
- `E_ASSERT_FAIL` — runtime assertion failure
- `E_FFI_TIMEOUT` — FFI call exceeded timeout
- `E_REGION_ESCAPE` — region rule violation
- `E_MACRO_NON_TERMINATION` — macro expansion loop

### Compilation Rules (Spec §21)
**MUST**: preserve evaluation order, enforce aliasing/region/FFI/determinism contracts
**MAY**: optimize, inline, remove dead code, refine register allocation
**MUST NOT**: reorder side effects, violate determinism, bypass region system, weaken FFI

---

## Current State

See **`PROGRESS.md`** for the latest status. It tracks:
- What's implemented
- Build errors and their status
- Next steps
- Design decisions made

Always read PROGRESS.md before making changes to avoid duplicating work or going in the wrong direction.

Always update PROGRESS.md after tests and validation successfully prove working state.
