# Zyl Specification — Language Overview

**Canonical authority:** `zyl_specification.txt` §0
**Related:** `docs/architecture-decisions.md`, `docs/design-rationale.md`

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

### v5.0 (Current — specified, not implemented)
- Package system (§31): `zyl.pkg` manifests, Minimal Version Selection,
  git-hosted index, mandatory Ed25519 signing with TOFU key pinning,
  BLAKE3 content addressing, offline builds
- Package- and module-qualified symbol identity with injective mangling;
  two packages may define the same name, two majors coexist
- Two-level visibility: package-private by default, `pub` to export
- Trait orphan rule at the package boundary
- Per-package capability declarations, deny by default, compiler-enforced
- Workspaces with one root lock
- Additive-only unified feature flags
- Declarative native C dependencies; no build scripts
- Editions; v5.0 defines exactly one (`2026`)

See `spec/16-package-system.md` and `docs/package-management-design.md`.

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
| G12 | Capability Containment: a package cannot exercise a capability it does not declare. |
| G13 | Supply-Chain Integrity: a locked build is reproducible from pinned content hashes and publisher keys. |
