# Architecture Decisions

The decisions below are settled and are not to be reversed (see
`AGENTS.md`). Each one names where the active, self-hosted compiler
(`stdlib/compiler/*.zyl` + `selfhost/`) implements it, and says plainly
where the implementation does not yet deliver all of it. The Rust
bootstrap that first implemented these decisions is frozen in
`archive/rust-bootstrap-2026/`.

---

## A1: No-Dispatch S-Expression Parsing

**Decision:** The reader parses every S-expression as a plain list. A
later pass recognizes special forms and converts them into specialized
AST variants.

**Rationale:** Eliminates dispatch complexity in the parser. The parser
handles exactly one grammatical form (S-expression → list of
expressions), and all specialization is deferred to a separate tree
walk. This simplifies parsing, eliminates look-ahead ambiguity, and
keeps the grammar context-free.

**Spec reference:** `spec/02-syntax-and-forms.md`
**Implementation:** `stdlib/compiler/parser.zyl` produces `AList`
nodes; `stdlib/compiler/expr_inner.zyl`'s `convert-ast` and
`dispatch-special` build `ExprInner`. Module qualification
(`qualify.zyl`) runs on the raw lists in between, which is simpler
because the raw tree has only six shapes.
**Alternative considered:** Dispatcher parser with per-form handlers —
rejected because it increases parser complexity and couples parsing to
semantic knowledge.

---

## A2: Innermost-First Macro Expansion

**Decision:** Macros expand post-order (innermost first), with gensym
hygiene.

**Rationale:** Innermost-first ensures that nested macro calls expand
correctly: the innermost macro produces output that outer macros can
then match against. Gensym hygiene prevents variable capture across
macro boundaries, preserving lexical scoping semantics.

**Spec reference:** `spec/03-macros-and-hygiene.md`
**Implementation:** `stdlib/compiler/macro_expand.zyl`. A macro call's
arguments are expanded before the macro itself, and the expanded body
is walked again so a macro that calls another macro expands fully.
Hygiene renames every binder a template introduces to a fresh
`name__hygN` (a source-order counter, never an address); a free
template name that is a local at the call site is `E_UNBOUND_VARIABLE`
rather than captured. A macro reached during its own expansion is
`E_MACRO_NON_TERMINATION`.
**Alternative considered:** Pre-order expansion — rejected because it
would cause outer macros to see unexpanded inner macro calls,
producing incorrect results.

---

## A3: Determinism as a Core Invariant

**Decision:** Every compilation phase produces deterministic output from
the same input. Every collection the compiler iterates has a defined
order.

**Rationale:** Determinism is a first-class language property (P1).
Identical source + identical inputs must produce identical binaries and
observable outputs. This is critical for reproducibility, security
auditing, and testing.

**Spec reference:** `spec/14-determinism-and-hashing.md`
**Implementation:** All phases. The compiler's tables are association
lists and ordered `List`s walked in source order; the type checker
(`type_annotate.zyl`, which replaced `monomorphization.zyl`) names each
instance of a trait-generic function by its argument types in order
(`f~T1,T2`); the native backend's block order, register assignment and
spill slots depend only on instruction order (`mir.zyl`); module
resolution builds its symbol table only after the whole graph is
discovered, so the result does not depend on traversal order; locks
and manifests are written in canonical order. Hash tables (the
runtime's source-span table, the per-node side tables of
`node_tables.zyl`, string maps) are only probed by key and never
iterated.
`./boot.sh` checks the result: the compiler must reproduce its own
assembly byte for byte.
**Alternative considered:** Non-deterministic iteration with hash-based
ordering — rejected because it violates the determinism contract and
makes binary comparison impossible.

---

## A4: Strict Phase Separation

**Decision:** Compilation proceeds through strictly ordered,
non-overlapping phases. No phase may depend on output from a later
phase.

**Rationale:** Phase isolation enables correct ordering of
transformations that have irreversible effects (e.g., monomorphization
consumes generics, so it must follow type inference). It also enables
incremental compilation strategies and makes each phase independently
testable.

**Spec reference:** `zyl_specification.txt` §22
**Implementation:** `stdlib/compiler/pipeline.zyl` is the single
definition of the phase order. `compile-to-fns` stops after region
inference and in-place reuse, for the REPL's interpreter;
`compile-to-asm` adds code generation. `docs/compiler-pipeline.md` lists the order.
**Alternative considered:** Interleaved phases — rejected because it
creates hidden dependencies and makes the compilation order
non-deterministic.

---

## A5: ICNF as a Custom IR

**Decision:** Intermediate Canonical Normal Form (ICNF) is the
compiler's own IR, specified as static single assignment with unique
IDs, region annotations, and embedded control-flow bodies.

**Rationale:** SSA form makes data flow explicit and simplifies
optimization. Region annotations at the IR level propagate region
information through the pipeline. Embedded branch bodies (rather than
labeled jumps) simplify IR traversal and code generation.

**Spec reference:** `spec/11-icnf-ir.md`
**Implementation:** `stdlib/compiler/icnf.zyl`. The self-hosted ICNF is
a tree of instructions with embedded control flow, but it is **not
SSA**: nodes refer to variables by name and `ISet` assigns them.
Region decisions are a side table keyed by node (`icnf-regions`,
`node_tables.zyl`), printed as ` @r` by `icnf_print.zyl` so the
package-build ICNF hash covers them, plus the `IStackVariant` rewrite
and the `IRegion` node for `with-region`. Codegen lowers most functions
further, to a linear machine IR with virtual registers (`mir.zyl`)
that exists only inside the backend.
**Alternative considered:** CPS (continuation-passing style) — rejected
because it complicates region reasoning and makes debugging output
harder to interpret.

---

## A6: Region-Based Memory with Escape Analysis

**Decision:** Memory regions (Stack, Heap, Global, Circular, Pin) are
assigned statically by escape analysis.

**Rationale:** Region-based memory eliminates garbage collection while
preventing use-after-free and double-free errors, and its static
assignment is deterministic. Escape promotion (Stack → Heap) handles
values that outlive their allocation scope.

**Spec reference:** `spec/07-region-memory-model.md`
**Implementation:** `stdlib/compiler/region_inference.zyl` runs on
ICNF after inlining and optimization. It puts a variant on the stack
when its binding is only matched on or printed, then (`rg-regions`)
places every allocation and call site, by escape analysis over
union-find object classes with per-function parameter summaries joined
to a whole-program fixpoint, in the frame's own region, the caller's
result region, or the process heap. `with-region` opens an explicit
arena or fixed region. `E_REGION_ESCAPE` is raised for a Stack
bytebuf or `with-region` value that would outlive its region. Pin
memory comes from `ffi-pin`. Global and Circular regions are not
inferred. `docs/regions-design.md` has the design.
**Alternatives considered:** Garbage collection (rejected: adds runtime
overhead, non-deterministic collection), manual memory management
(rejected: error-prone), ownership-only without explicit regions
(rejected: insufficient for FFI and circular structures).

---

## A7: Capability Types for Aliasing Control

**Decision:** Types use capability modifiers (TCap for shared
immutable, TMut for exclusive mutable) to control aliasing.

**Rationale:** Capability types enforce the invariant that any memory
location has either exactly one TMut reference OR any number of TCap
references. This prevents data races at compile time and enables safe
concurrency without locks.

**Spec reference:** `spec/06-capability-types.md`
**Implementation:** no type represents a capability (the type checker,
`type_annotate.zyl`, has none, and the unused capability ADT once in
`type_system.zyl` was removed). Enforcement is syntactic:
`mutability_check.zyl` treats a `let` binding as TCap and a `let-mut`
binding as TMut and rejects `set!` on anything else (`E_MUT_CONFLICT`),
and `secret_check.zyl` enforces the `Secret` capability's obligations.
The unifier itself has no capability polarity.
**Alternative considered:** Rust-style borrow checker — rejected
because Zyl's region system already handles lifetime tracking;
capabilities add only the aliasing dimension needed for
shared-state-free concurrency.
