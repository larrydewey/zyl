# Zyl Specification — Capability Types

**Canonical authority:** `zyl_specification.txt` §4.3
**Related:** `spec/05-types-and-inference.md`, `spec/07-region-memory-model.md`
**Implementation:** `src/type_system.rs`, `src/type_inference.rs`

---

## Capability Type Modifiers

Capability types govern aliasing at the type level. They are prefixes on base types:

```
TCap<T>     — immutable shared access
TMut<T>     — exclusive mutable ownership
TAtomic<T>  — atomic shared mutation
TBox<T>     — heap-managed allocation
TPin<T>     — FFI-pinned memory (non-moving arena)
```

## Aliasing Invariant

For any memory location:
- Either exactly one `TMut` reference
- OR any number of `TCap` references

Violation produces compile-time error: `E_MUT_CONFLICT`.

## Capability Rules

1. **TMut exclusivity:** Only one TMut reference may exist to any location at a time.
2. **TCap sharing:** Any number of TCap references may coexist.
3. **TMut → TCap downgrade:** TMut can be downgraded to TCap (loss of exclusive access).
4. **No TCap → TMut upgrade:** TCap cannot be upgraded to TMut (would violate exclusivity).
5. **Actor transfer:** Messages sent to actors must be Send-capable (TCap or TAtomic).

## Capability and Concurrency

- Spawned closures must only capture Send-capable variables (TCap/TAtomic).
- No shared mutable state between actors.
- Deterministic FIFO per actor.
