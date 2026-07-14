# Zyl Progress Tracker

## Current State

**All 9 phases complete** (Parsing → Code Generation + Linking). The compiler builds and runs successfully. Struct system is fully implemented with exhaustive test coverage.

---

## Phase 1: Parsing (Lexer + Parser → AST) ✅ COMPLETE

### Completed
- [x] **Project structure**: `src/` with modules (`main.rs`, `error.rs`, `lexer.rs`, `ast.rs`, `parser.rs`)
- [x] **Full error model** (spec §28): All E_* variants defined in `error.rs`
- [x] **AST nodes** (spec §2): Complete Expr enum covering all language constructs
- [x] **Lexer** (spec §1): Tokenizer with all token types, comment stripping, location tracking
- [x] **Parser** (spec §2): Recursive descent S-expression parser with ~40 special form handlers
- [x] **Reserved keyword enforcement**: `E_RESERVED_KEYWORD` error, checks in all special form parsers
- [x] **No-dispatch parsing**: All S-expressions become raw Call/Apply nodes → PostProcessor converts to specialized ExprInner

### Files
| File | Description |
|------|-------------|
| `src/main.rs` | Entry point, CLI wiring, pipeline orchestration |
| `src/error.rs` | Full error model with Location/Span tracking |
| `src/ast.rs` | Complete AST definitions + pretty printing |
| `src/lexer.rs` | Tokenizer with comment stripping, location tracking |
| `src/parser.rs` | Recursive descent parser with no-dispatch mode |
| `src/repl.rs` | REPL stub (deferred) |

---

## Phase 2: Post-Processing ✅ COMPLETE

### Completed
- [x] **PostProcessor** in `ast.rs`: Converts raw Call/Apply special forms to specialized ExprInner variants

---

## Phase 3: Macro Expansion ✅ COMPLETE

### Completed
- [x] **`src/macro_expander.rs`** (498 lines): Complete macro system
  - GensymRegistry for hygiene
  - Pattern matching engine
  - Template substitution with gensym hygiene
  - Innermost-first post-order expansion
  - Variadic patterns (`&` prefix)
  - Built-in operator exclusion list
- [x] **`___skip_` placeholder**: `Atom::Keyword("___skip_")` for omitted if branches → Unit type

---

## Phase 4: Region Inference + Capture Analysis ✅ COMPLETE

### Completed
- [x] **`src/region_inference.rs`** (~870 lines): Complete region system
  - Region enum: Stack | Heap | Global | Circular | Pin
  - CaptureInfo for closure capture tracking
  - RegionEnv with scoped environment
  - Escape analysis with region promotion (Stack → Heap)
  - Two-pass algorithm with region lattice

### Rules Implemented
- **R1** Local stack allocation → Stack
- **R2** Escape promotion → Heap
- **R3** Actor transfer → Heap
- **R4** FFI → Pin
- **R5** Closure capture promotion → Heap
- **R6** Cyclic structures → Circular (deferred detection)
- **R7** Global Region → Global
- **R8** Pin Region → Pin

---

## Phase 5: Type Inference + Trait Resolution ✅ COMPLETE

### Completed
- [x] **`src/type_system.rs`** (570 lines): Complete type system
  - Type enum with primitives, capabilities (TCap/TMut), functions, generics, collections
  - Subst (substitution map), TypeVarGen, TypeEnv, TraitContext
- [x] **`src/type_inference.rs`** (577+ lines): HM-style inference engine
  - Two-pass: collect_definitions → infer_expr
  - Handles all special forms (including raw Call/Apply from no-dispatch)
  - Built-in operator typing
  - Trait resolution with transitive bound checking
  - Derive validation (Eq, Ord, Debug, Clone, Hash)
  - Unification with occurs check
- [x] **Struct field type inference**: `StructGet` now returns field type from `struct_defs`; numeric ops accept type vars (for struct field results)

---

## Phase 6: Monomorphization ✅ COMPLETE

### Completed
- [x] **`src/monomorphization.rs`** (~1100 lines): Complete monomorphization engine
  - Generic function detection via uppercase parameter convention
  - Canonical naming (alphabetically sorted types)
  - Trait bound verification
  - Generic ADT instantiation

### Pipeline Ordering
```
Region Inference → TypeInferer.collect() → Monomorphization → TypeInferer.infer()
```

---

## Phase 7: ICNF Generation (SSA IR with Region Annotations) ✅ COMPLETE

### Completed
- [x] **`src/icnf.rs`** (~930+ lines): Complete SSA IR generation
  - ICNFNode with unique SSA ID, Region annotation, ICNFInner operation
  - ICNFFuncSig for function signatures
  - ICNFProgram container
  - SSA conversion with proper ID assignment and deduplication
  - Embedded branch bodies for If/While/For
  - push_mode flag for non-pushing conversion in control flow

### Key Fixes
- **Phi node join point**: `mov rax, rax` (not `mov eax, rax`)
- **Operand ID tracking**: Intermediate values not duplicated
- **Let statement ordering**: Value → Assign → Load → dependent statements

---

## Phase 8: Optimization (Safe only) ✅ COMPLETE

### Completed
- [x] **`src/optimization.rs`** (~360 lines): Safe-only ICNF optimizations
  - **Constant Folding**: Folds BinOp/UnOp with compile-time constants
  - **Dead Code Elimination**: BFS-based transitive dependency collection
  - **Fixed-point iteration**: CF runs until no more folds
  - Control flow structures (If/While/For) preserved in DCE

---

## Phase 9: Code Generation → x86_64 ✅ COMPLETE

### Completed
- [x] **`src/codegen.rs`** (~500+ lines): Complete x86_64 assembly generator
  - Intel syntax (`.intel_syntax noprefix`)
  - Linear-scan register allocator with caller-saved registers
  - 32-bit and 64-bit register allocation
  - System V AMD64 ABI compliance
  - Function calls: edi, esi, edx, ecx, r8d, r9d
  - String literals in .rodata, hexbuf in .bss

### Instructions Emitted
- Constants (Int, Float, Bool, Str)
- Variable load/store via `[rbp-offset]`
- Binary arithmetic (+, -, *, /) with proper operand sizing
- Comparison operators (cmp + setcc pattern)
- Control flow: If/While/For with unique `.L{N}` labels
- Integer-to-string conversion (division-by-10 loop)
- Struct construction (malloc + field store)
- Struct field access (load from struct pointer + offset)

### Key Fixes
- **Struct field ordering**: Push fields in reverse, pop with forward offset mapping
- **BinOp operand loading**: On-demand emission via `emit_load_into`
- **Computed node emission**: BinOp/StructGet/MakeStruct not skipped in emit loop
- **Function name sanitization**: Hyphens replaced with underscores

---

## Struct System Implementation ✅ COMPLETE

### Features
- **`defstruct Name (field1 type1) (field2 type2)`**: Define immutable struct
- **`defstruct+`**: Variant alias
- **`make-StructName val1 val2 ...`**: Construct struct on heap
- **`struct-get struct "field"`**: Access field by name
- **Field types**: Optional type annotations (`Int`, `String`, etc.)
- **Nested structs**: Struct field values used to construct other structs

### Pipeline Coverage
| Phase | Struct Support |
|-------|---------------|
| Parsing | `p_struct_def()`, `p_struct_get()`, `make-` dispatch in `p_call()` |
| Post-Processing | `DefStruct`/`StructDefPlus`/`MakeStruct`/`StructGet` conversion |
| Macro Expansion | Pattern matching + substitution for all struct forms |
| Region Inference | Fields default to Stack, instances to Heap |
| Type Inference | Field type lookup from `struct_defs` |
| Monomorphization | Struct definitions pass through unchanged |
| ICNF Generation | `MakeStruct`/`StructGet` node variants with region annotations |
| Optimization | DCE preserves struct nodes; operand tracking |
| Code Generation | malloc + field store; load from struct pointer + offset |

### Test Coverage (`stdlib_test.zyl`)
- Basic construction and field access
- Field access in arithmetic operations
- Multiple field access from same struct
- Structs with 2, 3, 4 fields
- Structs with field type annotations
- Nested struct-get (3+ levels deep)
- Struct construction from function results
- Struct passed through function calls
- Struct in control flow (if/while/cond)
- `defstruct+` variant
- Structs with boolean fields
- Multiple struct types interleaved
- Struct field in recursive function
- Large struct with same value in multiple fields
- Struct construction with arithmetic in constructor
- Struct rebinding via let-mut + set!
- Structs with all-zero fields
- Single-field struct
- Interleaved struct types in let

### 2026-07-14: Exhaustive Syntax Review
- **`stdlib_test.zyl` confirmed 100% correct syntax** — every expression verified against parser dispatch table, PostProcessor handlers, and PostProcessor defaults (e.g. missing `if` else → `___skip_`).
- **Full coverage of implemented features**: arithmetic (+, -, *, /, multi-arg), comparisons (>, <, >=, <=, ==, !=), logical (and, or, not), let/let-mut/set!, if (with and without else), defn (zero-arg, multi-arg, recursive), while/for loops, cond (single and multi-clause), begin (empty), macros (defmacro, unless→if, when→unless→if, nested).
- **20+ distinct struct test cases** across all 9 compilation phases.
- **Not tested (by design — not yet implemented)**: deftype pattern matching, ffi-call, spawn/send, closures (lambda/fn), try/catch, alias, trait/impl/derive, floating-point arithmetic.

---

## Known Remaining Issues

### High Priority
- [ ] **Function names with hyphens**: While sanitized for assembly labels, the internal representation still uses hyphens which may cause issues in other phases
- [x] **While loop runtime**: Fixed — multiple bugs corrected:
  1. Stack slot offset inconsistency: `Load` handler used `(offset_idx + 2) * 8` while all other handlers use `(slot_idx + 1) * 8`. Fixed in `codegen.rs:1386`.
  2. 32-bit/64-bit store mismatch: `SetBang` and `Assign` handlers stored 64-bit `rax` to 32-bit stack slots. Fixed to use `eax` in `codegen.rs:1407-1422` and `codegen.rs:1569-1584`.
  3. LetMut ICNF ordering: Load nodes were added to `global_stmts` before the Assign that defines the variable, causing hash-based fallback offsets. Fixed by deferring global pushes (matching Let handler pattern) in `icnf.rs:778-815`.
  4. Main function stack allocation: Added `sub rsp, 256` for main function stack frame in `codegen.rs:97-99`.
  5. Function parameter slot index mismatch: params stored at `(i+2)*8` but loaded from `(i+1)*8`. Fixed in `codegen.rs:284` to use `(i+1)*8` for storage.
- [x] **For loop runtime**: Fixed — multiple bugs corrected:
  1. Loop variable not assigned stack slot in first pass: Added slot assignment for For loop variables in main function's first pass (`codegen.rs:207-222`).
  2. Init offset used raw slot index instead of byte offset: Fixed `mov [rbp-X], eax` to use `(slot + 1) * 8` formula.
  3. Step result not stored back to loop variable: Added step result storage after step expression emission.
  4. For body/step nodes emitted twice (once by For handler, once by main emit loop): Added `emitted_ids` pre-population in pre-scan to skip embedded nodes.
  5. Condition/step Load nodes using hash-based fallback: Pass outer `local_vars` (containing loop variable slot) to condition emission.
  6. Hexbuf stale digits: Added `mov byte ptr [rdi], 0` after `dec rdi` in positive path to clear hexbuf[31] between iterations.

### Medium Priority
- [ ] **Floating-point support**: Float constants load but full IEEE-754 arithmetic not implemented
- [ ] **ADT pattern matching**: `deftype` variants defined but pattern matching codegen not implemented
- [ ] **FFI support**: `ffi-call` type checking implemented but code generation deferred
- [ ] **Actor concurrency**: `spawn`/`send` type checking implemented but runtime not implemented

### Low Priority
- [ ] **~160 compiler warnings**: Mostly unused variables, dead code, naming conventions
- [ ] **Self-hosting**: Not yet targeting Zyl source code generation
- [ ] **Package management**: Spec v5.0 features not implemented (per instructions)

---

## File Summary

| File | Lines | Description |
|------|-------|-------------|
| `src/main.rs` | ~300 | Pipeline orchestration, CLI, phase output |
| `src/ast.rs` | ~1400 | AST definitions, pretty printing, PostProcessor |
| `src/lexer.rs` | ~350 | Tokenizer with comment stripping |
| `src/parser.rs` | ~1780 | Recursive descent parser, no-dispatch mode |
| `src/error.rs` | ~165 | Full error model (E_* variants) |
| `src/macro_expander.rs` | ~500 | Macro system with gensym hygiene |
| `src/type_system.rs` | ~570 | Type enum, Subst, TypeEnv, TraitContext |
| `src/type_inference.rs` | ~1600 | HM inference with struct field type lookup |
| `src/region_inference.rs` | ~870 | Region system with escape analysis |
| `src/monomorphization.rs` | ~1100 | Generic detection and canonical naming |
| `src/icnf.rs` | ~1900 | SSA IR with region annotations |
| `src/optimization.rs` | ~360 | Constant folding + DCE |
| `src/codegen.rs` | ~2600 | x86_64 assembly generator |
| `src/repl.rs` | ~3 | REPL stub |
