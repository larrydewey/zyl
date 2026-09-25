# Zyl Specification — Language Overview

**Canonical authority:** `zyl_specification.txt` v5.0 — §0 (principles), §29 (guarantees), §30 (roadmap)
**Related:** `docs/architecture-decisions.md`, `docs/design-rationale.md`, `docs/compiler-pipeline.md`

`spec/` is a structured reference copy of the canonical specification,
organised by topic. The canonical text wins wherever the two disagree.
Sections headed "Implementation Notes" describe the self-hosted compiler
(`stdlib/compiler/*.zyl`, `selfhost/driver.zyl`, `runtime/actor_runtime.c`)
and are not normative; they record where the implementation departs from
the specification rather than correcting the specification to match.

## Section Map

| Canonical section | File |
|-------------------|------|
| §0 Principles, §22 Pipeline, §25 Standard library, §29 Guarantees, §30 Roadmap | this file |
| §1 Lexical structure | `01-lexing-and-tokens.md` |
| §2 Abstract syntax | `02-syntax-and-forms.md` |
| §19 Macros | `03-macros-and-hygiene.md` |
| §3 Values, §7 Closures, §11 Evaluation, §12 Control flow, §20.5 Testing | `04-evaluation-semantics.md` |
| §4 Types, §5 Traits, §6 Generics, §17 Monomorphization | `05-types-and-inference.md` |
| §4.3 Capability types, Secret | `06-capability-types.md` |
| §9 Regions, §10 Mutability, §13 Memory, §14 Stack safety | `07-region-memory-model.md` |
| §15 Actors | `08-actors-and-concurrency.md` |
| §16 FFI, §23 Contracts | `09-ffi-contracts.md` |
| §8 ADTs, structs, aliases, pattern matching | `10-structs-and-data-types.md` |
| §18 ICNF | `11-icnf-ir.md` |
| §26 Implementation contract, optimization | `12-optimization-rules.md` |
| §21 Built-in operations, code generation | `13-code-generation.md` |
| §20 Numeric model, §27 Determinism | `14-determinism-and-hashing.md` |
| §28 Error model | `15-error-model.md` |
| §20.6, §24 Modules, §31 Package system | `16-package-system.md` |

---

## Core Design Principles (Normative)

### P1. Determinism
Same source program + same inputs → identical observable outputs and binaries.

### P2. Safety
No undefined behavior exists. No use-after-free, no data races, no nulls.

### P3. Explicit Effects
All effects (mutation, IO, FFI, concurrency) are statically trackable.

### P4. Region-Based Memory
Memory assigned via static region inference (Stack, Heap, Global, Circular, Pin).
No manual allocation; no garbage collector for Stack/Heap (region-based reclamation).

### P5. Strict Evaluation
Evaluation order is deterministic and strictly left-to-right.

### P6. Phase Isolation
Compilation phases are strictly ordered (Parsing → Macro Expansion → Type Inference → Region Inference → Monomorphization → ICNF → Codegen).

### P7. Inference Over Annotation
If the compiler can prove it, the programmer does not write it.
Syntax exists only where inference cannot decide.

### P8. Optional Layers Do Not Interfere
Contracts, recovery, and testing frameworks never alter core semantics.

### P9. Testability
Testing is a core language built-in. Tests define behavior and drive implementation.

---

## 22. Compilation Pipeline

Phases (strict order):

1. Parsing — tokenize and parse to AST
2. Macro Expansion — expand macros (innermost-first, hygiene)
3. Type Inference + Trait Resolution — includes derive validation;
   validates struct field types and mutability; validates alias targets
4. Region Inference + Capture Analysis — assigns regions (Stack, Heap, Pin, etc.)
5. Monomorphization (deterministic naming, §17)
6. ICNF Generation (SSA IR)
7. Optimization (safe only)
8. Code Generation
9. Linking
10. Contract Injection (optional)
11. Hash Finalization

Rule: no phase may depend on a later phase.

### Implementation Notes

The self-hosted pipeline (`compile-to-asm` in
`stdlib/compiler/pipeline.zyl`) runs, in order:

1. bracket balance check (`sexp_balance.zyl`)
2. lexing and reading (`lexer.zyl`, `parser.zyl`)
3. module resolution and name qualification (`module_resolver.zyl`,
   `qualify.zyl`), which also converts the tree to `ExprInner`
4. macro expansion (`macro_expand.zyl`)
5. static checks: capabilities, duplicate definitions (including
   prelude constructor names), arity and malformed forms, mutability,
   match exhaustiveness, unused bindings, Secret taint
6. derive expansion (`derive.zyl`) and impl lifting (`lift_impls.zyl`,
   each impl method becomes `Trait.method_Type`)
7. closure inlining (`closure_inline.zyl`, now an identity pass)
8. type checking (`type_annotate.zyl`): Hindley–Milner inference, static
   trait resolution, per-type specialization of trait-generic functions,
   generated structural `T.==`; every type error is reported, then the
   compile fails (§4.8)
9. ICNF lowering (`icnf.zyl`)
10. optimization (`optimization.zyl`)
11. region inference (`ri-transform-fns`, then the escape analysis
    `rg-regions`)
12. code generation (`codegen.zyl`), then linking with `cc`

This differs from §22: module resolution precedes macro expansion, type
checking and trait resolution run after derive expansion and impl
lifting, region inference runs after ICNF generation and optimization
rather than before monomorphization, contracts are lowered while the
parse tree is converted (`expr_inner.zyl`), and hash finalization
happens only for package builds (`zyl.buildinfo`, see
`14-determinism-and-hashing.md`).

---

## 25. Standard Library (Abstract)

Core modules:

| Module | Contents |
|--------|----------|
| core | identity, compose, arithmetic, bool, type-predicates, I/O |
| collections | Vec, Map (deterministic iteration) |
| option | Option (Some, None), is-some, unwrap, map |
| result | Result (Ok, Err), is-ok, unwrap, map |
| io | file-open, file-read, file-write, file-close |
| atomic | load, store, add |
| actor | spawn, send, receive |
| ffi | ffi-call, ffi-pin, ffi-unpin |
| testing | test-suite, test, assert-*, test-property, run-tests |

All obey region and capability rules.

The standard library is implicit: it needs no manifest entry, and its
version is the compiler's version, recorded in the lock (§31.6). Each
stdlib module declares the capability it provides, which is how §31.9
enforces capability grants at import time.

In the repository the standard library lives in `stdlib/` (`actor`,
`allocator`, `atomic`, `collections`, `compiler`, `core`, `ffi`, `io`,
`lsp`, `math`, `mlib`, `repl`, `testing`), as package `zyl/std`. Option
and Result are `stdlib/core/option.zyl` and `stdlib/core/result.zyl`. The
capability each module needs is decided by `capability_check.zyl` from its
module path, not declared by the module (see `16-package-system.md`).

---

## Version History

### v4.0 (Previous)
- Explicit closures, macros, testing as core.

### v4.1 (Previous)
- alias, defstruct, defstruct+, derive, with-resource
- Immutable structs (rebinding only)
- Result-based error handling (no exceptions)
- Physical FFI pinning
- Gensym-based macro hygiene
- Deterministic iteration for Map
- Compile-time exhaustive match

### v4.2 (Previous)
- Multi-parameter generics formalized (§6)
- Type param scope, same-type constraint, generic ADT derivation
- `E_CANNOT_INFER` for generic params with no call-site evidence

### v5.0 (Current)
- Package system (§31): `zyl.pkg` manifests, Minimal Version Selection,
  git-hosted index, mandatory Ed25519 signing with TOFU key pinning,
  BLAKE3 content addressing, offline builds
- Package- and module-qualified symbol identity with injective mangling
  (§31.2); two packages may define the same name, two majors coexist
- Two-level visibility: package-private by default, `pub` to export (§24.4)
- Trait orphan rule at the package boundary (§24.6)
- Per-package capability declarations, deny by default, compiler-enforced
  (§31.9)
- Workspaces with one root lock (§31.11)
- Additive-only unified feature flags (§31.10)
- Declarative native C dependencies; no build scripts (§31.10)
- Editions (§31.11); v5.0 defines exactly one (`2026`)

The package system is implemented; `PROGRESS.md` records the deliberate
deviations and the remaining gaps. See `spec/16-package-system.md` and
`docs/package-management-design.md`.

### Future (canonical §30)
- Reserved keyword enforcement in definition forms (§1.3.1)
- Custom generators for property testing
- Coverage reporting
- Snapshot testing
- Advanced derive macros

---

## Formal Guarantees

| Guarantee | Statement |
|-----------|-----------|
| G1 | Safety: No undefined behavior. |
| G2 | Memory Safety: No use-after-free, double free, invalid aliasing. |
| G3 | Concurrency Safety: No data races. |
| G4 | Determinism: Identical inputs → identical outputs/bins. |
| G5 | FFI Safety: External code cannot corrupt Zyl memory. |
| G6 | Trait Coherence: No conflicting impls; all bounds resolvable. |
| G7 | Closure Capture Safety: Captured vars correctly region-assigned. |
| G8 | Contract Non-Interference: Contracts never alter core semantics. |
| G9 | Struct Safety: Fields immutable; mutation requires rebinding. |
| G10 | Alias Transparency: Zero-cost coercion. |
| G11 | Resource Safety: with-resource guarantees cleanup before error. |
| G12 | Capability Containment: a package cannot exercise a capability it does not declare (§31.9). |
| G13 | Supply-Chain Integrity: a locked build is reproducible from pinned content hashes and publisher keys; an index compromise cannot alter it (§31.8, §31.12). |
