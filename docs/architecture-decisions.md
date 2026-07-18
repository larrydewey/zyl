# Architecture Decisions

## A1: No-Dispatch S-Expression Parsing

**Decision:** All S-expressions are parsed as raw Call/Apply nodes. A PostProcessor phase converts them into specialized AST variants.

**Rationale:** Eliminates dispatch complexity in the parser. The parser handles exactly one grammatical form (S-expression → list of expressions), and all specialization is deferred to PostProcessor. This simplifies parsing, eliminates look-ahead ambiguity, and keeps the grammar context-free.

**Spec reference:** `spec/02-syntax-and-forms.md`
**Implementation:** `src/ast.rs` (PostProcessor), `src/parser.rs`
**Alternative considered:** Dispatcher parser with per-form handlers — rejected because it increases parser complexity and couples parsing to semantic knowledge.

---

## A2: Innermost-First Macro Expansion

**Decision:** Macros expand post-order (innermost first), with gensym hygiene.

**Rationale:** Innermost-first ensures that nested macro calls expand correctly: the innermost macro produces output that outer macros can then match against. Gensym hygiene prevents variable capture across macro boundaries, preserving lexical scoping semantics.

**Spec reference:** `spec/03-macros-and-hygiene.md`
**Implementation:** `src/macro_expander.rs`
**Alternative considered:** Pre-order expansion — rejected because it would cause outer macros to see unexpanded inner macro calls, producing incorrect results.

---

## A3: Determinism as a Core Invariant

**Decision:** Every compilation phase produces deterministic output from the same input. All data structures use ordered iteration (indexmap, hashbrown with sorted keys).

**Rationale:** Determinism is a first-class language property (P1). Identical source + identical inputs must produce identical binaries and observable outputs. This is critical for reproducibility, security auditing, and testing.

**Spec reference:** `spec/14-determinism-and-hashing.md`
**Implementation:** All phases; `Cargo.toml` (indexmap, hashbrown dependencies)
**Alternative considered:** Non-deterministic iteration with hash-based ordering — rejected because it violates the determinism contract and makes binary comparison impossible.

---

## A4: Strict Phase Separation

**Decision:** Compilation proceeds through strictly ordered, non-overlapping phases. No phase may depend on output from a later phase.

**Rationale:** Phase isolation enables correct ordering of transformations that have irreversible effects (e.g., monomorphization consumes generics, so it must follow type inference). It also enables incremental compilation strategies and makes each phase independently testable.

**Spec reference:** `zyl_specification.txt` §22
**Implementation:** `src/main.rs` (pipeline orchestration)
**Alternative considered:** Interleaved phases — rejected because it creates hidden dependencies and makes the compilation order non-deterministic.

---

## A5: ICNF as SSA-Based IR

**Decision:** Intermediate Canonical Normal Form (ICNF) uses static single assignment with unique SSA IDs, region annotations, and embedded control flow bodies.

**Rationale:** SSA form makes data flow explicit and simplifies optimization. Region annotations at the IR level propagate region information through the pipeline. Embedded branch bodies (rather than labeled jumps) simplify IR traversal and code generation.

**Spec reference:** `spec/11-icnf-ir.md`
**Implementation:** `src/icnf.rs`
**Alternative considered:** CPS (continuation-passing style) — rejected because it complicates region reasoning and makes debugging output harder to interpret.

---

## A6: Region-Based Memory with Escape Analysis

**Decision:** Memory regions (Stack, Heap, Global, Circular, Pin) are assigned statically via two-pass escape analysis with a region lattice.

**Rationale:** Region-based memory eliminates garbage collection while preventing use-after-free and double-free errors. The two-pass algorithm (first: collect constraints; second: solve via region lattice) produces deterministic region assignments. Escape promotion (Stack → Heap) handles values that outlive their allocation scope.

**Spec reference:** `spec/07-region-memory-model.md`
**Implementation:** `src/region_inference.rs`
**Alternatives considered:** Garbage collection (rejected: adds runtime overhead, non-deterministic collection), manual memory management (rejected: error-prone), ownership-only without explicit regions (rejected: insufficient for FFI and circular structures).

---

## A7: Capability Types for Aliasing Control

**Decision:** Types use capability modifiers (TCap for shared immutable, TMut for exclusive mutable) to control aliasing at the type level.

**Rationale:** Capability types enforce the invariant that any memory location has either exactly one TMut reference OR any number of TCap references. This prevents data races at compile time and enables safe concurrency without locks.

**Spec reference:** `spec/06-capability-types.md`
**Implementation:** `src/type_system.rs`, `src/type_inference.rs`
**Alternative considered:** Rust-style borrow checker — rejected because Zyl's region system already handles lifetime tracking; capabilities add only the aliasing dimension needed for shared-state-free concurrency.
