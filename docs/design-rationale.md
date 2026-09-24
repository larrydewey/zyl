# Design Rationale

## Overview

This document explains why key architectural choices were made in the Zyl compiler. It captures tradeoffs, rejected alternatives, and constraints that future developers should understand. Where the self-hosted compiler (`stdlib/compiler/*.zyl`) does not yet deliver a decision in full, a **Current implementation** note says so; `docs/implementation-status.md` has the complete list of gaps.

**Related:** `docs/architecture-decisions.md` (the decisions themselves), `zyl_specification.txt` (the formal spec)

---

## D1: Why S-Expression Syntax?

**Decision:** Zyl uses Lisp-style S-expressions.

**Rationale:**
- Uniform syntax eliminates precedence rules and operator ambiguity
- Homoiconicity (code = data) makes macros powerful and simple
- S-expressions map naturally to AST structure (tree = list of children)
- No-dispatch parsing works because every form is a list

**Rejected alternatives:**
- C-style syntax with precedence: more familiar but requires complex parser with precedence climbing
- Token-based DSL: simpler to parse but less expressive for macros
- JSON: structured but verbose and not designed for code

---

## D2: Why No-Dispatch Parsing?

**Decision:** The parser produces a plain list for every S-expression. A later tree walk specializes them.

**Rationale:**
- Parser handles exactly one form: "parse a list of expressions"
- No look-ahead, no ambiguity, no context-sensitive parsing
- Specialization is a simple tree walk (O(n))
- Easier to add new special forms (add to the specializing walk, not the parser)

**Current implementation:** `parser.zyl` builds `AList` nodes; `expr_inner.zyl`'s `convert-ast` and `dispatch-special` recognize the special forms and build `ExprInner`.

**Rejected alternative:** Dispatcher parser with per-form handlers. This would require the parser to know about every special form, creating coupling between parsing and semantics.

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

**Tradeoff:** Region inference is more complex than GC, and escape analysis requires careful design. However, the tradeoff is justified by deterministic reclamation and no runtime overhead.

**Current implementation:** `region_inference.zyl` is deliberately narrow: it stack-allocates a variant whose binding is only matched on or printed, and leaves everything else on the heap arena, because a wrong stack assignment is silent memory corruption. Global and Circular regions are not inferred.

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

**Current implementation:** enforcement is syntactic. `mutability_check.zyl` treats `let` as TCap and `let-mut` as TMut and rejects `set!` on anything else; `secret_check.zyl` enforces the `Secret` capability.

**Spec reference:** `spec/06-capability-types.md`

---

## D5: Why Innermost-First Macro Expansion?

**Decision:** Macros expand post-order (innermost first).

**Rationale:**
- A macro call nested in another macro call's arguments must expand before the outer macro sees it
- A macro whose expansion calls another macro must keep expanding: `(when c body)` expanding to `(unless (not c) body)` must then expand `unless` too
- Pre-order would leave inner macros unexpanded, producing incorrect code

**Current implementation:** `macro_expand.zyl` expands a call's arguments first, then substitutes them into the macro body and walks the result again, which covers both cases.

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

**Current implementation:** not yet delivered. `macro_expand.zyl` substitutes arguments into the body without renaming the names the body binds, so a macro that binds `tmp` captures a caller's `tmp`. The Rust bootstrap in `archive/rust-bootstrap-2026/` had a gensym registry; the self-hosted expander does not.

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

**Current implementation:** `mutability_check.zyl` rejects `(set! (struct-get p "x") 5)` with `E_MUT_CONFLICT`. Struct instances are heap allocated.

**Spec reference:** `spec/10-structs-and-data-types.md`, `zyl_specification.txt` §10

---

## D8: Why ICNF (a Custom IR) Instead of LLVM?

**Decision:** A custom IR (ICNF), specified as SSA with region annotations.

**Rationale:**
- Region annotations flow through the IR (LLVM has no region concept)
- Simpler integration: no LLVM dependency, no version compatibility issues
- Deterministic: LLVM's internal optimizations are not fully deterministic across versions
- Full control over IR structure (embedded branch bodies, not labeled jumps)

**Rejected alternatives:**
- LLVM: powerful optimizer but adds dependency, non-deterministic across versions, no region support
- LLVM IR codegen: more complex, harder to debug, larger binary

**Tradeoff:** Custom IR means no access to LLVM's optimization passes. However, the current optimization set (constant folding, dead-branch elimination) covers the common cases. Advanced optimizations can be added incrementally.

**Current implementation:** the self-hosted ICNF (`icnf.zyl`) is a tree with embedded control flow, but it is not SSA: variables are named and `ISet` assigns them. Its only region annotation is `IStackVariant`. The code generator emits a stack-machine style, with no register allocator.

**Spec reference:** `spec/11-icnf-ir.md`

---

## D9: Why Safe-Only Optimizations?

**Decision:** Only constant folding and dead-branch elimination are implemented. No reordering, no general inlining, no loop optimizations.

**Rationale:**
- Determinism requires that optimization cannot change observable behavior
- Many optimizations (especially loop optimizations) require sophisticated data flow analysis
- Safety is paramount: a buggy optimization is worse than no optimization
- The spec (§26) explicitly forbids reordering side effects

**Rejected alternatives:**
- Aggressive optimization (like LLVM): faster code but harder to verify correctness
- Partial optimizations (some safe, some not): complex to manage the boundary

**Tradeoff:** Generated code is not as optimized as it could be. However, the Zyl compiler targets systems programming where correctness is more important than raw performance. Runtime performance can be improved by algorithmic choices in source code.

**Current implementation:** `optimization.zyl` folds integer arithmetic and comparisons whose operands are constants and keeps only the taken branch of an `if` with a constant condition. It does not fold floats, bitwise operators, or a division by a constant zero (which must still fail at run time). `closure_inline.zyl` beta-reduces a let-bound lambda that is only ever called directly; that is a lowering step that lets such a lambda read its enclosing scope, not a performance pass.

**Spec reference:** `zyl_specification.txt` §26, `spec/12-optimization-rules.md`

---

## D10: Why Determinism Everywhere?

**Decision:** Same source + same inputs → identical binaries and observable outputs.

**Rationale:**
- Determinism is P1 (core design principle)
- Reproducible builds for security auditing
- Binary comparison for testing
- Debugging is easier when behavior is predictable
- FFI safety: non-deterministic memory layout could expose sensitive data

**Implementation:** the compiler's tables are association lists and lists walked in source order; monomorphization sorts type names; module resolution builds its symbol table only after the whole graph is discovered; locks and manifests are serialized canonically. The runtime's source-span hash table is only probed by key, never iterated. `./boot.sh` verifies that the compiler reproduces its own assembly byte for byte.

**Tradeoff:** Slower lookups (linear association lists rather than hash tables). However, the difference is small for compilation workloads.

**Spec reference:** `spec/14-determinism-and-hashing.md`

---

## D11: Why Struct-Get Instead of Dot Notation?

**Decision:** `struct-get struct "field"` instead of `struct.field`.

**Rationale:**
- Uniform syntax: field access uses the same form as function application
- Field name as string enables dynamic field access (future feature)
- No ambiguity with trait method calls, which are spelled `(Trait.method receiver ...)`
- Consistent with Lisp tradition

**Rejected alternative:** Dot notation. Would require new parser token (`.`) and special-case handling in the parser.

**Spec reference:** `spec/10-structs-and-data-types.md`

---

## D12: Why For Loop Redesign (3-arg instead of 5-arg)?

**Decision:** `(for (init-bindings) condition body)` instead of `(for name init condition step body)`.

**Rationale:**
- 5-arg syntax conflates loop variable declaration with update step
- New syntax makes it explicit that the user controls loop variable updates via `set!`
- Supports multiple loop variables
- Empty init `()` makes pure while loops expressible as for loops
- Body is a `begin` block, making the loop structure clear

**Current implementation:** the binding section is either one binding, `(i 0)`, or a list of bindings, `((i 0) (j 10))`. The flat multi-variable form `(i 0 j 10)` shown in the spec is not parsed as two bindings; use the list form.

**Rejected alternative:** Keep 5-arg syntax. The step expression was confusing because it was implicit (executed every iteration without user control).

**Spec reference:** `spec/04-evaluation-semantics.md` (§12 Control Flow)

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

**Current implementation:** the implementation departs from this decision. `(error msg)` calls the runtime's `zyl_panic`, which unwinds to the innermost `try` (implemented with `setjmp` and a runtime stack of try frames), or to the test runner, or ends the process with `PANIC: msg`. `(try body (catch e handler))` catches a panic rather than inspecting a `Result`, so an `Err` returned normally from `body` passes through unchanged. `Result` values and `stdlib/core/result.zyl` remain the way to handle errors as values. See the implementation notes in `spec/04-evaluation-semantics.md`.

**Spec reference:** `zyl_specification.txt` §12.2 and §12.10, `spec/04-evaluation-semantics.md`

---

## D14: Why No Implicit Closures?

**Decision:** `(fn (param*) body)` and `(lambda (param*) body)` are the only closure syntax. `((x) body)` is REJECTED.

**Rationale:**
- Explicit syntax makes closure parameters visible and unambiguous
- No confusion with function calls (where `(x body)` calls function `x` with argument `body`)
- Consistent with the no-dispatch parsing philosophy: no implicit special forms

**Rejected alternative:** Implicit closure syntax `((param*) body)`. This would conflict with function calls in the no-dispatch parser.

**Current implementation:** `((x) body)` is not accepted as a closure, but it is not rejected with a diagnostic either: it compiles as a call and fails at link time with an undefined reference.

**Spec reference:** `spec/04-evaluation-semantics.md` (Closures)
