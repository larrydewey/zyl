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

### v4.1 (Current — Final Locked Version)
- alias, defstruct, defstruct+, derive, with-resource
- Immutable structs (rebinding only)
- Result-based error handling (no exceptions)
- Physical FFI pinning
- Gensym-based macro hygiene
- Deterministic iteration for Map
- Compile-time exhaustive match

### v5.0 (Planned)
- Package management (zyl.toml, registries, signing)
- Workspace support
- Feature flags

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
