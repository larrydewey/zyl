# Codebase Map

## Overview

This file documents major source files, module responsibilities, and relationships between components.

**Related:** `docs/compiler-pipeline.md` (phase-to-file mapping)

---

## Entry Points

### `src/main.rs` (374 lines)
**Responsibility:** Compiler binary entry point, CLI argument parsing, pipeline orchestration.

**Wiring:**
1. Read source file
2. Run pipeline phases in order (1–9)
3. Invoke external linker (`cc -no-pie -lpthread actor_runtime.c`)
4. Output typed AST, monomorphized AST, and ICNF for debugging

**Relationships:** Imports from all phase modules. Orchestrates the compilation pipeline.

### `src/repl.rs` (4 lines)
**Responsibility:** REPL stub entry point.

**Status:** Minimal implementation. Full REPL is deferred.

---

## Core Compiler Modules

### `src/error.rs` (170 lines)
**Responsibility:** Error model implementation matching spec §28.

**Contents:**
- All E_* error variants (E_USER_ERROR, E_MUT_CONFLICT, E_ASSERT_FAIL, etc.)
- Location/Span tracking for error reporting
- Error formatting

**Phase:** Phase 1 (Parsing) — error reporting spans all phases.

---

### `src/ast.rs` (2005 lines)
**Responsibility:** AST definitions, pretty printing, and PostProcessor.

**Contents:**
- `Expr` enum — all AST node types (Atom, Def, Defn, Let, LetMut, If, Call, etc.)
- `ExprInner` — specialized inner types for each expression kind
- `DefStruct`, `StructDefPlus`, `MakeStruct`, `StructGet` — struct system nodes
- `DefType`, `Match` — ADT system nodes
- `TryCatch`, `Spawn`, `Send`, `SendClosure`, `ReadLine` — effect nodes
- `FfiCall`, `FfiPin`, `FfiUnpin` — FFI nodes
- `Lambda`, `Fn` — closure nodes
- `pretty_print()` — AST → S-expression string
- `PostProcessor` — converts raw Call/Apply to specialized ExprInner

**Relationships:** Used by all downstream phases. Parser produces raw nodes that PostProcessor enriches.

---

### `src/lexer.rs` (457 lines)
**Responsibility:** Tokenization.

**Contents:**
- `Token` enum: IDENTIFIER, INTEGER, FLOAT, STRING, BOOLEAN, SYMBOL, KEYWORD, (, ), {, }, :, [, ]
- `Location` struct: file, line, column
- `Lexer::next_token()` — produces token stream with location info
- Comment stripping (`;` line comments)
- Float token support (`f64::from_bits`)

**Phase:** Phase 1 (Parsing) — first phase of compilation.

**Output:** Token stream → consumed by Parser.

---

### `src/parser.rs` (1823 lines)
**Responsibility:** Recursive descent S-expression parser.

**Contents:**
- `Parser` struct with position tracking
- ~40 special form handlers (`p_def`, `p_defn`, `p_let`, `p_if`, `p_while`, `p_for`, `p_cond`, `p_defstruct`, `p_defmacro`, `p_deftype`, `p_match`, `p_spawn`, `p_send`, `p_ffi_call`, `p_try`, `p_lambda`, `p_read_line`, etc.)
- No-dispatch mode: all S-expressions parsed as raw Call/Apply
- Reserved keyword enforcement (E_RESERVED_KEYWORD) — 47 reserved keywords

**Phase:** Phase 1 (Parsing) — produces raw AST.

**Input:** Token stream from Lexer.
**Output:** Raw AST (Call/Apply) → PostProcessor.

---

### `src/macro_expander.rs` (1427 lines)
**Responsibility:** Macro expansion with gensym hygiene.

**Contents:**
- `MacroEnv` — macro registration and lookup
- `GensymRegistry` — unique symbol generation for hygiene
- Pattern matching engine (supports `&` variadic prefix)
- Template substitution with gensym renaming
- Built-in operator exclusion list (prevents macro expansion of +, -, *, etc.)
- `___skip_` placeholder handling

**Phase:** Phase 2 (Macro Expansion).

**Input:** Raw AST from Parser.
**Output:** Expanded AST (macros replaced) → Region Inference.

---

### `src/type_system.rs` (612 lines)
**Responsibility:** Type definitions and type environment.

**Contents:**
- `Type` enum: Int, Float, Bool, String, Unit, Struct, Alias, TFun, TCap, TMut, TAtomic, TBox, TPin, TypeVar, Vec, Map, Result, ADT
- `Subst` — substitution map (TypeVar → Type)
- `TypeVarGen` — unique type variable generation
- `TypeEnv` — type environment (name → Type)
- `TraitContext` — trait bound resolution
- `is_send()` — Send-capable type check

**Phase:** Phase 4 (Type Inference) — shared definitions used by type_inference.rs.

---

### `src/type_inference.rs` (1836 lines)
**Responsibility:** Hindley-Milner type inference engine.

**Contents:**
- `TypeInferer` struct with type environment and substitution tracking
- `collect_definitions()` — Phase 1: register all definitions
- `infer_expr()` — Phase 2: infer types recursively
- Built-in operator typing (+, -, *, /, <, >, ==, !=, etc.)
- Float type handling and mixed Int/Float unification
- Trait resolution with transitive bound checking
- Derive validation (Eq, Ord, Debug, Clone, Hash)
- Struct field type lookup from struct_defs
- Unification with occurs check
- Capability type inference (TCap/TMut)
- FFI call type inference
- Spawn/Send Send-capable enforcement
- Match type resolution

**Phase:** Phase 4 (Type Inference).

**Input:** Region-annotated AST from Region Inference.
**Output:** Typed AST → Monomorphization.

---

### `src/region_inference.rs` (1132 lines)
**Responsibility:** Region assignment and escape analysis.

**Contents:**
- `Region` enum: Stack, Heap, Global, Circular, Pin
- `CaptureInfo` — closure capture tracking
- `RegionEnv` — scoped region environment
- Two-pass algorithm:
  - Pass 1: Collect constraints
  - Pass 2: Solve via region lattice (least fixed point)
- Rules R1–R8 (local stack, escape, actor transfer, FFI, closure capture, cyclic, global, pin)
- Closure capture analysis (TCap/TMut/Heap escape)

**Phase:** Phase 3 (Region Inference).

**Input:** Expanded AST from Macro Expander.
**Output:** Region-annotated AST → Type Inference.

---

### `src/monomorphization.rs` (1459 lines)
**Responsibility:** Generic type instantiation.

**Contents:**
- Generic function detection (uppercase parameter convention)
- Canonical naming (alphabetically sorted type parameters)
- Type variable substitution
- Trait bound verification for each instantiation
- Generic ADT instantiation

**Phase:** Phase 5 (Monomorphization).

**Input:** Region-annotated AST from Region Inference (via Type Inference's collect).
**Output:** Monomorphized AST → ICNF Generation.

---

### `src/icnf.rs` (2862 lines)
**Responsibility:** SSA IR generation with region annotations.

**Contents:**
- `ICNFProgram` — top-level container
- `ICNFFuncSig` — function signature (name, params, region)
- `ICNFNode` — IR instruction with SSA ID, Region, and ICNFInner
- `ICNFInner` — operation types: Constant, Load, Store, BinOp, UnOp, If, While, For, Match, Call, Return, MakeStruct, StructGet, Phi, FFI, Spawn, Send, SendClosure, ReadLine
- SSA conversion with unique ID assignment
- Embedded branch bodies for control flow
- `push_mode` flag for non-pushing conversion
- Closure body support (`closure_bodies` HashMap)
- Capture metadata tracking (`closures` HashMap)

**Phase:** Phase 6 (ICNF Generation).

**Input:** Monomorphized AST from Monomorphization.
**Output:** ICNFProgram → Optimization.

---

### `src/optimization.rs` (514 lines)
**Responsibility:** Safe-only ICNF optimizations.

**Contents:**
- `constant_fold()` — fold BinOp/UnOp with compile-time constants (fixed-point iteration)
- `dead_code_elimination()` — BFS-based transitive dependency collection from function returns
- Preserves control flow structures (If/While/For/Match) and struct nodes
- Spawn/Send/ReadLine exempt from reordering

**Phase:** Phase 7 (Optimization).

**Input:** ICNFProgram from ICNF Generation.
**Output:** Optimized ICNFProgram → Code Generation.

---

### `src/codegen.rs` (4738 lines)
**Responsibility:** x86_64 assembly generation.

**Contents:**
- Intel syntax output (`.intel_syntax noprefix`)
- Linear-scan register allocator (caller-saved: eax, ebx, ecx, edx, esi, edi, r8–r15)
- SSE register handling (XMM0–XMM5 for float arguments)
- System V AMD64 ABI: arguments in edi, esi, edx, ecx, r8d, r9d
- Stack frame management: `[rbp - offset]` for locals
- Section management: .text, .rodata, .bss
- `emit_load_into()` — load value into register (operand handling)
- Struct construction: malloc + field store with offset mapping
- Struct field access: load from struct pointer + offset
- ADT variant construction with discriminant
- Match codegen: discriminant comparison + branch selection
- Integer-to-string conversion (division-by-10 loop with hexbuf)
- Float constants in rodata
- Closure invocation with env struct
- Spawn wrapper functions (anonymous closures as standalone functions)
- Send/SendClosure with actor runtime calls
- FFI code generation with Pin region
- TryCatch code generation
- ReadLine I/O (sys_read, 64-bit pointer storage)
- Print with ReadLine result string detection
- Assembly newline handling

**Phase:** Phase 8 (Code Generation).

**Input:** Optimized ICNFProgram from Optimization.
**Output:** x86_64 assembly (.s file) → external linker.

---

### `src/runtime.rs` (2 lines)
**Responsibility:** Re-export of actor runtime C file path for build-time access.

**Contents:**
- `RUNTIME_C` constant: `"src/runtime/actor_runtime.c"`

**Phase:** Phase 9 (Linking) — used by main.rs to locate actor runtime.

---

### `src/runtime/actor_runtime.c` (156 lines)
**Responsibility:** pthread-based actor runtime for Zyl concurrency.

**Contents:**
- `zyl_actor_init()` — initialize actor system
- `zyl_actor_spawn(fn, arg)` — spawn actor thread
- `zyl_actor_send(actor, data)` — send data message to actor mailbox
- `zyl_actor_send_closure(closure_id, captured_data, captured_len)` — send closure message
- `zyl_actor_wait_all()` — wait for all actors to complete
- `zyl_actor_thread_entry()` — thread entry point with mailbox loop
- Mailbox queue with message dispatch
- Closure dispatch: lookup closure by ID and execute

**Phase:** Phase 9 (Linking) — compiled alongside assembly.

---

### `src/runtime/actor_runtime.h` (52 lines)
**Responsibility:** Actor runtime API header.

**Contents:**
- Function declarations for actor runtime API
- Actor handle type
- Message types (data vs closure)

**Phase:** Phase 9 (Linking) — included by actor_runtime.c

---

## Module Dependency Graph

```
lexer.rs ──→ parser.rs ──→ ast.rs (PostProcessor)
                                         │
                                         ▼
                                macro_expander.rs
                                         │
                                         ▼
                                region_inference.rs
                                         │
                                         ▼
                     type_system.rs ──→ type_inference.rs
                                         │
                                         ▼
                               monomorphization.rs
                                         │
                                         ▼
                                       icnf.rs
                                         │
                                         ▼
                                optimization.rs
                                         │
                                         ▼
                                 codegen.rs
                                         │
                                         ▼
                          main.rs (linker orchestration)
                                         │
                                         ▼
                          runtime/actor_runtime.c (linked)

Note: error.rs is imported by all modules. repl.rs is independent.