# Zyl Specification — Capability Types

**Canonical authority:** `zyl_specification.txt` §4.3, §7.4, §10, §15, §31.9 (`secret`)
**Related:** `spec/05-types-and-inference.md`, `spec/07-region-memory-model.md`
**Implementation:** `stdlib/compiler/type_system.zyl` (`CapKind`), `stdlib/compiler/mutability_check.zyl` (aliasing), `stdlib/compiler/secret_check.zyl` (`Secret`)

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

Rules 1, 2 and 5 restate §10 and §15. Rules 3 and 4 are not stated in the
canonical text; they follow from the invariant.

1. **TMut exclusivity:** Only one TMut reference may exist to any location at a time.
2. **TCap sharing:** Any number of TCap references may coexist.
3. **TMut → TCap downgrade:** TMut can be downgraded to TCap (loss of exclusive access).
4. **No TCap → TMut upgrade:** TCap cannot be upgraded to TMut (would violate exclusivity).
5. **Actor transfer:** Messages sent to actors must be Send-capable (TCap or TAtomic).

## Capability and Concurrency

- Spawned closures must only capture Send-capable variables (TCap/TAtomic).
- No shared mutable state between actors.
- Deterministic FIFO per actor.

## The Secret Capability

§31.9 names `secret` as a package capability covering "the Secret
capability type and `stdlib/math/secret`". The canonical text does not
otherwise define the `Secret` type; its behaviour is set by the
implementation, described below.

---

## Implementation Notes

Not normative.

### Capability kinds

The type checker (`type_annotate.zyl`) has no capability types: `TCap`,
`TMut` and the other wrappers of §4.3 are not represented (except
`Pin`, below), and the old
`CapKind`, `is-ffi-pinnable` and `tc-is-send` were removed with the
unused type ADT of `type_system.zyl`. What remains is enforced by
syntactic passes:

- FFI_Pinnable (§16) is checked in two places. `ffi-pin` of a function
  is `E_FFI_TYPE_NOT_PINNABLE` (the type pass); otherwise `(ffi-pin v)`
  is a `(Pin a)` for v : a (§4.9), the address of the 8-byte Pin-arena
  slot the runtime copied v's word into, and `ffi-unpin` takes that
  `(Pin a)` back to `a`. `Pin` is the one §4.3 wrapper with a type, as
  an opaque handle. A closure passed as an `ffi-call` argument is
  `E_INVALID_CAPABILITY` (`mutability_check.zyl`). The arguments of an
  `ffi-call` are otherwise typed by the callee's signature (the runtime
  table `ffi_sigs.zyl` or the program's `extern`).
- Send-capability is checked syntactically (the `let-mut` rule below and
  `spec/08-actors-and-concurrency.md`); no type carries it.

### Aliasing and mutation

`mutability_check.zyl` is a syntactic pass over the program before
lowering. It treats a `let` binding as `TCap` and a `let-mut` binding as
`TMut`, and enforces:

- `set!` on a name that is not an in-scope `let-mut` binding is
  `E_MUT_CONFLICT`;
- a `spawn` whose closure, or a `send` whose message, refers to an
  in-scope `let-mut` binding is `E_CAPABILITY_LEAK`;
- a closure passed as an `ffi-call` argument is `E_INVALID_CAPABILITY`.

`set!` on anything other than a plain name, such as a struct field, is
rejected earlier by the parser with `E_MUT_CONFLICT`.

It does not check a `let-mut` binding captured and mutated by an ordinary
closure, and it does not track aliasing through the raw allocation, atomic
or FFI primitives. Rules 3 and 4 above (downgrade and no upgrade) have no
dedicated check.

### Secret

To the type checker `(Secret T)` is `T`, and a bare `Secret` field
annotation marks the field secret without giving it a type (it is then an
implicit type parameter of its struct). The obligations of key material
(not sent, pinned for FFI, constant-time use) are tracked as taint by
`secret_check.zyl`, not by the unifier.

A parameter annotated `(k Secret)` or `(k (Secret Int))` seeds a taint
that propagates through `let`, calls, arithmetic, constructors and byte
loads, and across functions by a fixpoint. The pass rejects:

| Shape | Code |
|-------|------|
| Condition of `if`/`while`/`for`/`cond`, or a `match` subject, derived from a Secret | `E_CT_VIOLATION` |
| Secret used as an index or byte offset | `E_CT_VIOLATION` |
| Secret operand of `/` or `mod` | `E_CT_VIOLATION` |
| Secret reaching `print` | `E_SECRET_DEBUG` |
| Secret reaching `spawn`, `send` or `file-write` | `E_SECRET_ESCAPE` |
| Secret passed to `ffi-call` without `ffi-pin` | `E_FFI_PIN_REQUIRED` |
| Secret consumed into a public result with no `zeroize` | `E_ZEROIZE_MISSING` (warning) |

`declassify` in `stdlib/math/secret/secret.zyl` is the one named way out.
Taint crosses a call only where the callee's parameters are annotated, so
an unannotated helper launders a secret. Under the package system, calling
into `stdlib/math/secret` needs the `secret` capability (§31.9); writing a
`Secret` annotation does not. See `docs/math-crypto.md`.
