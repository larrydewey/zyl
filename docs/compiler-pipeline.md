# Compiler Pipeline

## Overview

The Zyl compiler is a deterministic, single-pass-through, multi-phase compiler from S-expression source to x86_64 native binary. All phases execute in strict order; no phase may depend on output from a later phase.

**Canonical reference:** `zyl_specification.txt` §22
**Navigation:** `spec/11-icnf-ir.md`, `spec/13-code-generation.md`

---

## Phase 1: Parsing

**Input:** `.zyl` source file (UTF-8 text)
**Output:** AST (Expr tree)
**Implementation:** `src/lexer.rs`, `src/parser.rs`, `src/ast.rs`

**Process:**
1. Lexer tokenizes source into tokens (IDENTIFIER, INTEGER, FLOAT, STRING, BOOLEAN, SYMBOL, KEYWORD, parentheses, brackets)
2. Strips line comments (`;`)
3. Parser produces raw S-expressions as Call/Apply nodes (no-dispatch mode)
4. PostProcessor converts raw nodes to specialized ExprInner variants

**Invariants:**
- All expressions are strict left-to-right
- Reserved keywords cannot be used as identifiers (E_RESERVED_KEYWORD)
- Location tracking for all syntax errors

---

## Phase 2: Macro Expansion

**Input:** AST from Phase 1
**Output:** Expanded AST (macros replaced with their templates)
**Implementation:** `src/macro_expander.rs`

**Process:**
1. Macro registration: Collect all defmacro definitions
2. Post-order traversal (innermost-first): Expand macros recursively
3. Gensym hygiene: All macro-introduced variables renamed to unique symbols
4. `___skip_` placeholder: Omitted if branches produce Unit type

**Invariants:**
- Expansion is deterministic (innermost-first order)
- Hygiene prevents variable capture
- Macros cannot access runtime values (E_MACRO_ILLEGAL_ACCESS)

---

## Phase 3: Type Inference + Trait Resolution

**Input:** Expanded AST
**Output:** Typed AST (types assigned to all expressions)
**Implementation:** `src/type_system.rs`, `src/type_inference.rs`

**Process:**
1. Two-pass algorithm:
   - Pass 1: `collect_definitions()` — register all def/defn/defstruct definitions
   - Pass 2: `infer_expr()` — infer types for all expressions
2. Hindley-Milner unification with occurs check
3. Trait resolution with transitive bound checking
4. Derive validation (Eq, Ord, Debug, Clone, Hash)
5. Struct field type lookup from struct_defs

**Invariants:**
- All expressions are well-typed or produce a type error
- TMut/TCap aliasing constraints enforced
- Capability types govern aliasing (TMut exclusive, TCap shared)

---

## Phase 4: Region Inference + Capture Analysis

**Input:** Typed AST
**Output:** Region-annotated AST
**Implementation:** `src/region_inference.rs`

**Process:**
1. Two-pass algorithm with region lattice:
   - Pass 1: Collect region constraints from expression structure
   - Pass 2: Solve constraints via region lattice (least fixed point)
2. Capture analysis for closures
3. Escape promotion (Stack → Heap) for values that outlive scope

**Region rules (R1–R8):**
| Rule | Condition | Region |
|------|-----------|--------|
| R1 | Local, no escape | Stack |
| R2 | Escapes (returned, captured by escaping closure, sent to actor) | Heap |
| R3 | Actor transfer (spawn/send) | Heap |
| R4 | FFI | Pin |
| R5 | Closure capture promotion | Heap |
| R6 | Cyclic structures | Circular |
| R7 | Global constant | Global |
| R8 | Explicit pin | Pin |

**Invariants:**
- No value escapes its region
- Struct instances default to Heap
- FFI values pinned for non-moving access

---

## Phase 5: Monomorphization

**Input:** Region-annotated typed AST
**Output:** Monomorphized AST (no generic types)
**Implementation:** `src/monomorphization.rs`

**Process:**
1. Detect generic functions (uppercase parameter convention)
2. For each concrete type instantiation:
   - Sort type parameters alphabetically (canonical naming)
   - Generate specialization name
   - Substitute type variables
3. Verify trait bounds for each instantiation
4. Instantiate generic ADTs

**Invariants:**
- Naming is deterministic (alphabetical sort of types)
- No generic types remain in output
- Trait bounds verified before instantiation

---

## Phase 6: ICNF Generation (SSA IR)

**Input:** Monomorphized AST
**Output:** ICNFProgram (SSA IR with region annotations)
**Implementation:** `src/icnf.rs`

**IR structure:**
```
ICNFProgram {
  functions: [ICNFFuncSig, ...]
}

ICNFFuncSig {
  name: String,
  params: [(String, Type, Region)],
  body: [ICNFNode, ...]
}

ICNFNode {
  id: SSA_ID,
  region: Region,
  inner: ICNFInner
}
```

**ICNFInner operations:**
- Constant, Load, Store, BinOp, UnOp
- If, While, For (embedded branch bodies)
- Call, Return
- MakeStruct, StructGet
- Phi (join points)
- FFI, Spawn, Send

**Invariants:**
- Each variable assigned exactly once (SSA)
- Region annotations preserved from Phase 4
- Control flow embedded (not labeled jumps)
- Phi nodes at join points for values with multiple definitions

---

## Phase 7: Optimization

**Input:** ICNFProgram
**Output:** Optimized ICNFProgram (safe optimizations only)
**Implementation:** `src/optimization.rs`

**Optimizations:**
1. **Constant Folding (CF):** Fold BinOp/UnOp with compile-time constants. Fixed-point iteration until no more folds.
2. **Dead Code Elimination (DCE):** BFS-based transitive dependency collection from function returns.

**Invariants:**
- Only safe optimizations (no reordering, no spec-breaking transforms)
- Control flow structures (If/While/For) preserved in DCE
- Struct nodes preserved
- Evaluation order never changed

---

## Phase 8: Code Generation

**Input:** Optimized ICNFProgram
**Output:** x86_64 assembly (.s file)
**Implementation:** `src/codegen.rs`

**Process:**
1. Linear-scan register allocator (caller-saved registers only)
2. System V AMD64 ABI compliance:
   - Arguments: edi, esi, edx, ecx, r8d, r9d
   - Return: eax (64-bit), rax (pointer)
3. Stack frame: `[rbp - offset]` for local variables
4. String literals → .rodata section
5. hexbuf (for int-to-string) → .bss section

**Instructions emitted:**
- `mov` (64-bit and 32-bit)
- `add`, `sub`, `imul`, `idiv`
- `cmp` + `setcc` for comparisons
- `jmp`, `jl`, `jg`, `je`, `jne` etc.
- `call`, `ret`
- `malloc` for struct allocation
- `printf` for output

**Output format:** Intel syntax (`.intel_syntax noprefix`)

---

## Phase 9: Linking

**Input:** Assembly file (.s)
**Output:** Native binary (.bin)
**Implementation:** External toolchain (as + ld via shell invocation)

**Process:**
1. Assemble with `as` (GNU assembler, Intel syntax)
2. Link with `ld` (System V AMD64 ABI)

**External dependency:** GNU binutils (as, ld)

---

## Phase 10: Contract Injection (Optional)

**Input:** Compiled binary or assembly
**Output:** Contract-enriched binary
**Implementation:** Not yet implemented

**Status:** Contract system defined in spec §23 but not implemented. Contracts are an optional overlay that never alter core semantics.

---

## Phase 11: Hash Finalization

**Input:** Compiled binary
**Output:** SHA-256 hash of binary
**Implementation:** `sha2` crate

**Purpose:** Deterministic binary fingerprinting for reproducibility verification.

---

## Pipeline Summary

```
Source (.zyl)
  → [1] Lexer → Tokens
  → [2] Parser → Raw S-expressions
  → [2] PostProcessor → AST
  → [3] Macro Expansion → Expanded AST
  → [4] Type Inference → Typed AST
  → [5] Region Inference → Region-annotated AST
  → [6] Monomorphization → Monomorphized AST
  → [7] ICNF Generation → ICNFProgram
  → [8] Optimization → Optimized ICNFProgram
  → [9] Code Generation → x86_64 assembly (.s)
  → [10] Linking → Native binary (.bin)
  → [11] Contract Injection (optional)
  → [12] Hash Finalization → SHA-256 fingerprint
```

---

## Phase Ordering Constraints

| Phase | Depends On | Must Not Depend On |
|-------|-----------|-------------------|
| 1 (Parsing) | — | 2–11 |
| 2 (Macro Expansion) | 1 | 3–11 |
| 3 (Type Inference) | 2 | 4–11 |
| 4 (Region Inference) | 3 | 5–11 |
| 5 (Monomorphization) | 4 | 6–11 |
| 6 (ICNF) | 5 | 7–11 |
| 7 (Optimization) | 6 | 8–11 |
| 8 (Code Generation) | 7 | 9–11 |
| 9 (Linking) | 8 | — |

**Rule:** No phase may depend on a later phase. Determinism is required at every step.
