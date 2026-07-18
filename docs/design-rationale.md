# Design Rationale

## Overview

This document explains why key architectural choices were made in the Zyl compiler. It captures tradeoffs, rejected alternatives, and constraints that future developers should understand.

**Related:** `docs/architecture-decisions.md` (the decisions themselves), `zyl_specification.txt` (the formal spec)

---

## D1: Why S-Expression Syntax?

**Decision:** Zyl uses Lisp-style S-expressions.

**Rationale:**
- Uniform syntax eliminates precedence rules and operator ambiguity
- Homoiconicity (code = data) makes macros powerful and simple
- S-expressions map naturally to AST structure (tree = list of children)
- No-dispatch parsing works because every list is a Call node

**Rejected alternatives:**
- C-style syntax with precedence: more familiar but requires complex parser with precedence climbing
- Token-based DSL: simpler to parse but less expressive for macros
- JSON: structured but verbose and not designed for code

---

## D2: Why No-Dispatch Parsing?

**Decision:** Parser produces raw Call/Apply for all S-expressions. PostProcessor specializes them.

**Rationale:**
- Parser handles exactly one form: "parse a list of expressions"
- No look-ahead, no ambiguity, no context-sensitive parsing
- Specialization is a simple tree walk (O(n))
- Easier to add new special forms (add to PostProcessor, not parser)

**Rejected alternative:** Dispatcher parser with per-form handlers. This would require the parser to know about all 40+ special forms, creating coupling between parsing and semantics.

**Spec reference:** `spec/02-syntax-and-forms.md`

---

## D3: Why Region-Based Memory Instead of GC?

**Decision:** Explicit regions (Stack, Heap, Global, Circular, Pin) with static inference.

**Rationale:**
- Deterministic memory reclamation (no collection pauses)
- No runtime GC overhead (critical for systems programming)
- Region types are part of the type system (TMut/TCap work with regions)
- FFI safety via Pin region (non-moving arena)
- Circular region handles reference cycles without GC

**Rejected alternatives:**
- Garbage collection: non-deterministic collection timing, runtime overhead
- Manual memory management (C-style): error-prone, no compile-time safety
- Ownership without regions (Rust-style): Zyl already uses regions for lifetime tracking; capabilities add the aliasing dimension

**Tradeoff:** Region inference is more complex than GC. The two-pass escape analysis algorithm requires careful design. However, the tradeoff is justified by deterministic reclamation and no runtime overhead.

**Spec reference:** `spec/07-region-memory-model.md`

---

## D4: Why Capability Types (TCap/TMut)?

**Decision:** Types carry capability annotations that govern aliasing.

**Rationale:**
- TCap (shared, immutable) allows multiple references
- TMut (exclusive, mutable) allows only one reference
- Alias invariant enforced at compile time: any location has either one TMut OR any number of TCap
- Enables safe actor concurrency without locks (no shared mutable state)

**Rejected alternatives:**
- Rust borrow checker: more complex because it tracks lifetimes explicitly; Zyl uses regions for lifetime tracking
- Software transactional memory: runtime overhead, non-deterministic retry behavior

**Tradeoff:** Capability types add syntax and inference complexity. However, they provide a simpler model than full ownership tracking because they only govern aliasing, not ownership.

**Spec reference:** `spec/06-capability-types.md`

---

## D5: Why Innermost-First Macro Expansion?

**Decision:** Macros expand post-order (innermost first).

**Rationale:**
- Nested macros must expand from the inside out
- Example: `(when (condition) (body))` expands to `(unless (not condition) (body))` which expands to `(if (not (not condition)) (body))`
- Pre-order would leave inner macros unexpanded, producing incorrect code

**Rejected alternative:** Pre-order expansion. This would cause outer macros to see unexpanded inner macro calls.

**Spec reference:** `spec/03-macros-and-hygiene.md`

---

## D6: Why Gensym Hygiene?

**Decision:** All macro-introduced variables are renamed to unique symbols (gensyms).

**Rationale:**
- Prevents variable capture: `(let x 1 (my-macro (let x 2 body)))` should not have `my-macro`'s internal `x` capture the outer `x`
- Gensyms are globally unique (monotonically increasing counter)
- Hygiene is compile-time (no runtime cost)

**Rejected alternative:** Syntactic closures (syntax-rules with lexical scope tracking). More complex implementation, harder to debug.

**Spec reference:** `spec/03-macros-and-hygiene.md`

---

## D7: Why Structs Are Immutable by Default?

**Decision:** Struct fields cannot be mutated in place. Mutation requires rebinding the entire struct.

**Rationale:**
- Simpler memory model: struct instances are allocated on Heap and never modified
- Eliminates aliasing issues (if you have a reference to a field, the struct is not being mutated)
- Consistent with capability types (TCap for shared access)
- Direct field mutation (`set! (struct-get p "x") 5`) is forbidden

**Tradeoff:** Less convenient for performance-critical code that needs in-place mutation. However, the safety benefits outweigh the convenience cost. For in-place mutation, use `let-mut` to rebind the entire struct.

**Spec reference:** `spec/10-structs-and-data-types.md`, `spec/10-mutability-and-aliasing.md`

---

## D8: Why ICNF (Custom SSA IR) Instead of LLVM?

**Decision:** Custom SSA IR (ICNF) with region annotations.

**Rationale:**
- Region annotations flow through the IR (LLVM has no region concept)
- Simpler integration: no LLVM dependency, no version compatibility issues
- Deterministic: LLVM's internal optimizations are not fully deterministic across versions
- Full control over IR structure (embedded branch bodies, not labeled jumps)

**Rejected alternatives:**
- LLVM: powerful optimizer but adds dependency, non-deterministic across versions, no region support
- LLVM IR codegen: more complex, harder to debug, larger binary

**Tradeoff:** Custom IR means no access to LLVM's optimization passes. However, the current optimization set (constant folding, DCE) covers the common cases. Advanced optimizations can be added incrementally.

**Spec reference:** `spec/11-icnf-ir.md`

---

## D9: Why Safe-Only Optimizations?

**Decision:** Only constant folding and dead code elimination are implemented. No reordering, no inlining, no loop optimizations.

**Rationale:**
- Determinism requires that optimization cannot change observable behavior
- Many optimizations (especially loop optimizations) require sophisticated data flow analysis
- Safety is paramount: a buggy optimization is worse than no optimization
- The spec (§26) explicitly forbids reordering side effects

**Rejected alternatives:**
- Aggressive optimization (like LLVM): faster code but harder to verify correctness
- Partial optimizations (some safe, some not): complex to manage the boundary

**Tradeoff:** Generated code is not as optimized as it could be. However, the Zyl compiler targets systems programming where correctness is more important than raw performance. Runtime performance can be improved by algorithmic choices in source code.

**Spec reference:** `zyl_specification.txt` §26

---

## D10: Why Determinism Everywhere?

**Decision:** Same source + same inputs → identical binaries and observable outputs.

**Rationale:**
- Determinism is P1 (core design principle)
- Reproducible builds for security auditing
- Binary comparison for testing
- Debugging is easier when behavior is predictable
- FFI safety: non-deterministic memory layout could expose sensitive data

**Implementation:** indexmap (ordered maps), hashbrown with sorted keys, deterministic iteration order in all data structures.

**Tradeoff:** Slightly slower data structure operations (ordered iteration vs. hash iteration). However, the difference is negligible for compilation workloads.

**Spec reference:** `spec/14-determinism-and-hashing.md`

---

## D11: Why Struct-Get Instead of Dot Notation?

**Decision:** `struct-get struct "field"` instead of `struct.field`.

**Rationale:**
- Uniform syntax: field access uses the same form as function application
- Field name as string enables dynamic field access (future feature)
- No ambiguity with method calls (Zyl has no methods)
- Consistent with Lisp tradition

**Rejected alternative:** Dot notation. Would require new parser token (`.`) and special-case handling in the parser.

**Spec reference:** `spec/10-structs-and-data-types.md`

---

## D12: Why For Loop Redesign (3-arg instead of 5-arg)?

**Decision:** `(for (init-bindings) condition body)` instead of `(for name init condition step body)`.

**Rationale:**
- 5-arg syntax conflates loop variable declaration with update step
- New syntax makes it explicit that the user controls loop variable updates via `set!`
- Supports multiple loop variables with `(i 0 j 10)`
- Empty init `()` makes pure while loops expressible as for loops
- Body is a `begin` block, making the loop structure clear

**Rejected alternative:** Keep 5-arg syntax. The step expression was confusing because it was implicit (executed every iteration without user control).

**Spec reference:** `spec/12-control-flow.md`

---

## D13: Why Result-Based Error Handling Instead of Exceptions?

**Decision:** `(error msg)` returns `(Err msg)`. No throw/catch.

**Rationale:**
- Errors are values, not control flow jumps
- Callers must explicitly handle errors (no implicit unwinding)
- Consistent with capability types (error handling is part of the type)
- Deterministic: no stack unwinding, no non-local control flow
- Simpler region reasoning: no need to track which regions are cleaned up by unwinding

**Rejected alternatives:**
- Exception-based (try/catch/throw): non-deterministic stack unwinding, harder to reason about regions
- Option types (Some/None): no error message, less informative

**Spec reference:** `spec/12-control-flow.md` (TRY/CATCH section)

---

## D14: Why No Implicit Closures?

**Decision:** `(fn (param*) body)` and `(lambda (param*) body)` are the only closure syntax. `((x) body)` is REJECTED.

**Rationale:**
- Explicit syntax makes closure parameters visible and unambiguous
- No confusion with function calls (where `(x body)` calls function `x` with argument `body`)
- Consistent with the no-dispatch parsing philosophy: no implicit special forms

**Rejected alternative:** Implicit closure syntax `((param*) body)`. This would conflict with function calls in the no-dispatch parser.

**Spec reference:** `spec/07-closures.md`
