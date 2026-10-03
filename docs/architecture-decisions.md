# Architecture Decisions

The decisions below are settled and are not to be reversed (see
`AGENTS.md`). Each one names where the active, self-hosted compiler
(`stdlib/compiler/*.zyl` + `selfhost/`) implements it, and says plainly
where the implementation does not yet deliver all of it. The Rust
bootstrap that first implemented these decisions has been removed from
the tree; it is in git history at commit `b8bc283`.

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

## A7: No In-Place Mutation; Capabilities Checked on Bindings

**Decision:** Zyl has no in-place mutation. Struct fields are immutable
and a "mutated" struct is a new value bound to the same name, so every
`let` binding is immutable and rebinding is the only update. `set!` is
accepted only on a `let-mut` binding (or a `for` loop variable) and
rebinds it; anywhere else it is `E_MUT_CONFLICT`. The capability rules
are decided from the binding form and enforced syntactically, before
lowering. No type carries a capability. `Secret` is the one exception,
because it has obligations the compiler enforces.

**Rationale:** What the decision delivers is stronger than the
exclusivity invariant the specification asks for: with no in-place
mutation a reader cannot observe a value change underneath it, because
there is no write to observe. So a shared immutable binding does not
need a type to say so — the absence of field mutation says it once for
every type, and the binding form says which name may be rebound. That is
also why the checks need no type information to be sound, which is what
lets them run as a cheap syntactic pass and lets them undershoot
deliberately: where the pass cannot decide, the program is let through
rather than rejected.

The one thing the binding form cannot say is who may cross an actor
boundary. That is checked too — a `let-mut` variable or a `Secret` in a
`spawn` closure or a `chan-send` value is `E_CAPABILITY_LEAK` — and a
resource that outlives its release is `E_MOVE_VALUE`, because a file
descriptor is a copyable `Int` and a stale one silently aliases whatever
the OS opened next.

**Spec reference:** `spec/06-capability-types.md`,
`zyl_specification.txt` §10. The specification's `TCap`/`TMut` type
names are retired: the model above is what the compiler does, and these
are the documents that used to argue the other way.

**Implementation:** `stdlib/compiler/mutability_check.zyl` is a
syntactic walk over the pre-lowering `Expr` tree tracking which names
are in-scope `let-mut` bindings; it rejects a `set!` of anything else,
a `set!` of a captured outer `let-mut` from inside a closure (the
closure holds a by-value copy, so the assignment could only ever change
the copy), and a `spawn` or `chan-send` mentioning one. It also rejects
a closure written inline as an `ffi-call` argument
(`E_INVALID_CAPABILITY`). `stdlib/compiler/linearity.zyl` handles moves
and, on mutable locations, the writer rule: a `bytebuf` is one location,
a name becomes its writer by writing through it, and alias classes are
keyed per allocation, so a second name writing to one is
`E_MUT_CONFLICT`. `stdlib/compiler/secret_check.zyl` enforces the
`Secret` capability's obligations and marks a function that takes or
binds a secret; `codegen.zyl`'s `cg-wipes-frame` zeroes that function's
frame on return. The unifier has no capability polarity at all —
`type_annotate.zyl`'s `TaTy` is `TaV | TaC | TaF`.

**Alternatives considered:**
- Rust-style borrow checker — rejected: Zyl's region system already
  handles lifetime tracking, and with no in-place mutation there is
  nothing left for a borrow to be wrong about except a mutable location,
  which is one location check in `linearity.zyl`.
- Making `TCap`/`TMut` real annotations the unifier carries — rejected
  (2026-10-02, `PROGRESS.md` item 10). Structs forbid field mutation, so
  an exclusive-mutable capability could never flow through a field, and
  the capabilities would exist only in the positions `let`/`let-mut`
  already cover; the price would be capability polarity in the unifier
  and in generated `T.==`.

---

## A8: The Runtime Is Zyl, With No libc

**Decision:** The runtime is written in Zyl and compiled by the
self-hosted compiler; programs that call no foreign code run without
libc.

**Rationale:** C in the trusted base is code the fixed point does not
cover and the language's checks never see. A libc under every program
adds start-up, locale and allocator behaviour Zyl does not control.

**Implementation:** `runtime/rt/*.zyl`, compiled with
`--runtime-module`, the only compile in which the locked `%` primitives
(raw loads and stores, syscalls, atomics, SIMD) exist
(`stdlib/compiler/rt_mode.zyl`); programs get no `unsafe`. Its output
`build/boot/rt.s` is a committed seed checked by `./boot.sh` like
`stage2.s`. `docs/runtime-in-zyl-design.md` has the design.
**Alternative considered:** Keeping a C runtime — rejected for the
reasons above; an `unsafe` form for programs — rejected, since the
runtime is the only code that needs the primitives.

---

## A9: Deterministic Concurrency Through Kahn Channels

**Decision:** Actors communicate only over single-writer,
single-reader channels with blocking receive and no select, so a
program's output never depends on scheduling.

**Rationale:** A multi-sender mailbox makes the receiver's input order,
and so its output, a function of the scheduler (spec §27).

**Implementation:** `runtime/rt/chan.zyl`, `actor.zyl`; typed in
`type_annotate.zyl`. `ZYL_SCHED=deterministic` and
`ZYL_SCHED_CHAOS=<seed>` are the test oracle.
`docs/concurrency-determinism-design.md` has the design.
**Alternative considered:** Mailboxes with a deterministic scheduler
only — rejected, since the guarantee would then depend on the
scheduler rather than on the program.

---

## A10: Deterministic Intrinsics Instead of Inline Assembly

**Decision:** There is no inline assembly. Machine operations a program
needs are typed builtins whose results never depend on the CPU
(`bit-popcount`, `bit-clz`, `bit-ctz`, `bit-bswap`, `bit-rotl`,
`bit-rotr`, `mul-hi`, `mul-hi-u`, `crc32c`, spec §21.13) and the portable
lane vectors of `stdlib/simd`. `ffi-call` stays the escape hatch.

**Rationale:** Raw assembly breaks determinism (`rdtsc`, `rdrand`,
`cpuid`, CPU-feature dependence) and can write outside any region.

---

## A11: The Compiler Assembles and Links

**Decision:** A freestanding program is assembled and linked by the
compiler itself (`asm_x86.zyl`, `elf_link.zyl`) against the cached
runtime `rt.zo`; no `cc`, `as` or `ld` runs.

**Rationale:** The output binary is then a function of the compiler and
its inputs alone, with no external toolchain version in the result.
Both steps are byte-deterministic, and the assembler's encodings are
checked against GNU as (`tests/scripts/asm-oracle.sh`). A program that
calls foreign C still links with `cc` over libc's crt.
