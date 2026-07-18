# Codebase Map

## Overview

This file documents major source files, module responsibilities, and relationships between components.

**Related:** `docs/compiler-pipeline.md` (phase-to-file mapping)

---

## Entry Points

### `src/main.rs` (~300 lines)
**Responsibility:** Compiler binary entry point, CLI argument parsing, pipeline orchestration.

**Wiring:**
1. Read source file
2. Run pipeline phases in order (1–9)
3. Invoke external linker (as + ld)
4. Optionally print phase outputs (ICNF, assembly) for debugging

**Relationships:** Imports from all phase modules. Orchestrates the compilation pipeline.

### `src/repl.rs` (~3 lines)
**Responsibility:** REPL stub entry point.

**Status:** Minimal implementation. Full REPL is deferred.

---

## Core Compiler Modules

### `src/error.rs` (~165 lines)
**Responsibility:** Error model implementation matching spec §28.

**Contents:**
- All E_* error variants (E_USER_ERROR, E_MUT_CONFLICT, E_ASSERT_FAIL, etc.)
- Location/Span tracking for error reporting
- Error formatting

**Phase:** Phase 1 (Parsing) — error reporting spans all phases.

---

### `src/ast.rs` (~1400 lines)
**Responsibility:** AST definitions, pretty printing, and PostProcessor.

**Contents:**
- `Expr` enum — all AST node types (Atom, Def, Defn, Let, LetMut, If, Call, etc.)
- `ExprInner` — specialized inner types for each expression kind
- `DefStruct`, `StructDefPlus`, `MakeStruct`, `StructGet` — struct system nodes
- `DefType`, `Match` — ADT system nodes
- `pretty_print()` — AST → S-expression string
- `PostProcessor` — converts raw Call/Apply to specialized ExprInner

**Relationships:** Used by all downstream phases. Parser produces raw nodes that PostProcessor enriches.

---

### `src/lexer.rs` (~350 lines)
**Responsibility:** Tokenization.

**Contents:**
- `Token` enum: IDENTIFIER, INTEGER, FLOAT, STRING, BOOLEAN, SYMBOL, KEYWORD, (, ), {, }, :, [, ]
- `Location` struct: file, line, column
- `Lexer::next_token()` — produces token stream with location info
- Comment stripping (`;` line comments)

**Phase:** Phase 1 (Parsing) — first phase of compilation.

**Output:** Token stream → consumed by Parser.

---

### `src/parser.rs` (~1780 lines)
**Responsibility:** Recursive descent S-expression parser.

**Contents:**
- `Parser` struct with position tracking
- ~40 special form handlers (`p_def`, `p_defn`, `p_let`, `p_if`, `p_while`, `p_for`, `p_cond`, `p_defstruct`, `p_defmacro`, etc.)
- No-dispatch mode: all S-expressions parsed as raw Call/Apply
- `p_struct_def()`, `p_struct_get()` — struct parsing
- Reserved keyword enforcement (E_RESERVED_KEYWORD)

**Phase:** Phase 1 (Parsing) — produces raw AST.

**Input:** Token stream from Lexer.
**Output:** Raw AST (Call/Apply) → PostProcessor.

---

### `src/macro_expander.rs` (~498 lines)
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
**Output:** Expanded AST (macros replaced) → Type Inference.

---

### `src/type_system.rs` (~570 lines)
**Responsibility:** Type definitions and type environment.

**Contents:**
- `Type` enum: Int, Float, Bool, String, Unit, Struct, Alias, TFun, TCap, TMut, TAtomic, TBox, TPin, TypeVar, Vec, Map, Result, ADT
- `Subst` — substitution map (TypeVar → Type)
- `TypeVarGen` — unique type variable generation
- `TypeEnv` — type environment (name → Type)
- `TraitContext` — trait bound resolution

**Phase:** Phase 5 (Type Inference) — shared definitions used by type_inference.rs.

---

### `src/type_inference.rs` (~1600 lines)
**Responsibility:** Hindley-Milner type inference engine.

**Contents:**
- `TypeInferer` struct with type environment and substitution tracking
- `collect_definitions()` — Phase 1: register all definitions
- `infer_expr()` — Phase 2: infer types recursively
- Built-in operator typing (+, -, *, /, <, >, ==, !=, etc.)
- Trait resolution with transitive bound checking
- Derive validation (Eq, Ord, Debug, Clone, Hash)
- Struct field type lookup from struct_defs
- Unification with occurs check
- Capability type inference (TCap/TMut)

**Phase:** Phase 5 (Type Inference).

**Input:** Expanded AST from Macro Expander.
**Output:** Typed AST → Region Inference.

---

### `src/region_inference.rs` (~870 lines)
**Responsibility:** Region assignment and escape analysis.

**Contents:**
- `Region` enum: Stack, Heap, Global, Circular, Pin
- `CaptureInfo` — closure capture tracking
- `RegionEnv` — scoped region environment
- Two-pass algorithm:
  - Pass 1: Collect constraints
  - Pass 2: Solve via region lattice (least fixed point)
- Rules R1–R8 (local stack, escape, actor transfer, FFI, closure capture, cyclic, global, pin)

**Phase:** Phase 4 (Region Inference).

**Input:** Typed AST from Type Inference.
**Output:** Region-annotated AST → Monomorphization.

---

### `src/monomorphization.rs` (~1100 lines)
**Responsibility:** Generic type instantiation.

**Contents:**
- Generic function detection (uppercase parameter convention)
- Canonical naming (alphabetically sorted type parameters)
- Type variable substitution
- Trait bound verification for each instantiation
- Generic ADT instantiation

**Phase:** Phase 6 (Monomorphization).

**Input:** Region-annotated AST from Region Inference.
**Output:** Monomorphized AST (no generics) → ICNF Generation.

---

### `src/icnf.rs` (~1900 lines)
**Responsibility:** SSA IR generation with region annotations.

**Contents:**
- `ICNFProgram` — top-level container
- `ICNFFuncSig` — function signature (name, params, region)
- `ICNFNode` — IR instruction with SSA ID, Region, and ICNFInner
- `ICNFInner` — operation types (Constant, Load, Store, BinOp, UnOp, If, While, For, Call, Return, MakeStruct, StructGet, Phi, FFI, Spawn, Send)
- SSA conversion with unique ID assignment
- Embedded branch bodies for control flow
- `push_mode` flag for non-pushing conversion

**Phase:** Phase 7 (ICNF Generation).

**Input:** Monomorphized AST from Monomorphization.
**Output:** ICNFProgram → Optimization.

---

### `src/optimization.rs` (~360 lines)
**Responsibility:** Safe-only ICNF optimizations.

**Contents:**
- `constant_fold()` — fold BinOp/UnOp with compile-time constants (fixed-point iteration)
- `dead_code_elimination()` — BFS-based transitive dependency collection from function returns
- Preserves control flow structures (If/While/For) and struct nodes

**Phase:** Phase 8 (Optimization).

**Input:** ICNFProgram from ICNF Generation.
**Output:** Optimized ICNFProgram → Code Generation.

---

### `src/codegen.rs` (~2600 lines)
**Responsibility:** x86_64 assembly generation.

**Contents:**
- Intel syntax output (`.intel_syntax noprefix`)
- Linear-scan register allocator (caller-saved: eax, ebx, ecx, edx, esi, edi, r8–r15)
- System V AMD64 ABI: arguments in edi, esi, edx, ecx, r8d, r9d
- Stack frame management: `[rbp - offset]` for locals
- Section management: .text, .rodata, .bss
- `emit_load_into()` — load value into register (operand handling)
- Struct construction: malloc + field store with offset mapping
- Struct field access: load from struct pointer + offset
- Integer-to-string conversion (division-by-10 loop with hexbuf)

**Phase:** Phase 9 (Code Generation).

**Input:** Optimized ICNFProgram from Optimization.
**Output:** x86_64 assembly (.s file) → external linker.

---

## Module Dependency Graph

```
lexer.rs ──→ parser.rs ──→ ast.rs (PostProcessor)
                                        │
                                        ▼
                               macro_expander.rs
                                        │
                                        ▼
                    type_system.rs ──→ type_inference.rs
                                        │
                                        ▼
                               region_inference.rs
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
```

Note: `error.rs` is imported by all modules. `repl.rs` is independent.
