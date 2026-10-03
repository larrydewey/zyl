# Zyl Specification — Capability Types

**Canonical authority:** `zyl_specification.txt` §4.3, §7.4, §10, §15, §31.9 (`secret`)
**Related:** `spec/05-types-and-inference.md`, `spec/07-region-memory-model.md`
**Implementation:** `stdlib/compiler/mutability_check.zyl` (`set!`, capture and send checks), `stdlib/compiler/linearity.zyl` (moves, mutable locations), `stdlib/compiler/type_annotate.zyl` (`Pin`, `E_FFI_TYPE_NOT_PINNABLE`), `stdlib/compiler/secret_check.zyl` (`Secret`)

---

## Capability Type Modifiers

Zyl has no capability types. The §4.3 wrappers are not type
constructors; what each stood for is carried by the binding a name has:

| §4.3 wrapper | Zyl |
|--------------|-----|
| `TCap<T>` — immutable shared access | a `let` binding — immutable, any number of readers |
| `TMut<T>` — exclusive mutable ownership | a `let-mut` binding — the only assignable binding; `set!` rebinds it |
| `TAtomic<T>` — atomic shared mutation | immutable (`let`) or atomic bindings: `stdlib/atomic/atomic.zyl` supplies functions over an address, not a type |
| `TBox<T>` — heap-managed allocation | nothing to write: a value's region is decided by escape analysis (`spec/07-region-memory-model.md`), not by its type |
| `TPin<T>` — FFI-pinned memory | `(Pin T)`, the one wrapper that is a type: an opaque handle |

`Ptr` is likewise not a type: in a signature it is a spelling for `Int`.

## Aliasing Invariant

Zyl has no in-place mutation: every `let` binding is immutable, `set!` on
a `let-mut` binding rebinds it, and `set!` on anything else is
`E_MUT_CONFLICT`.

The one mutable location the language has is a `bytebuf`, written through
`store-u8`, `bytebuf-append` or an atomic primitive. A name becomes a
writer by being *written*, and the invariant is that within one location
at most one name may be written: one writer plus any number of readers is
allowed, two writers are not. Violation is the compile-time error
`E_MUT_CONFLICT`.

## Capability Rules

Rules 1, 2 and 5 restate §10 and §15. Rules 3 and 4 are not stated in the
canonical text; they follow from the invariant.

1. **Writer exclusivity:** At most one name writes a mutable location.
2. **Sharing:** Any number of `let` bindings may name one location; only a `let-mut` binding may be assigned.
3. **No conversion:** A binding's capability is fixed by its `let` or `let-mut` form. There is no downgrade and no upgrade; a `let` binding cannot be made assignable.
4. **A closure captures a value, not a location:** it reads what the binding held at capture time, and assigning an enclosing `let-mut` from inside it is `E_MUT_CONFLICT`.
5. **Actor transfer:** Messages sent to actors must be immutable (`let`) or atomic bindings.

## Capability and Concurrency

- Spawned closures and sent messages must be immutable (`let`) or atomic
  bindings. A `let-mut` crossing an actor boundary is `E_CAPABILITY_LEAK`.
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
`TMut`, `TAtomic` and `TBox` are not represented (except `Pin`, below),
and the old `CapKind`, `is-ffi-pinnable` and `tc-is-send` were removed
with the unused type ADT of `type_system.zyl` — what remains there is
`Pair` and the `Region` ADT. `Ptr` is read as `Int`
(`ta-builtin-type`). What the wrappers meant is enforced by syntactic
passes:

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
lowering. It treats a `let` binding as immutable and a `let-mut` binding
as the only assignable one, and enforces:

- `set!` on a name that is not an in-scope `let-mut` binding is
  `E_MUT_CONFLICT`;
- a `spawn` whose closure, or a `send` whose message, refers to an
  in-scope `let-mut` binding is `E_CAPABILITY_LEAK`;
- a closure passed as an `ffi-call` argument is `E_INVALID_CAPABILITY`;
- a `set!` inside a closure on a `let-mut` of an enclosing scope is
  `E_MUT_CONFLICT` (`mc-fn-fence`): the closure captured a copy by value,
  so the assignment could never reach the outer binding.

`set!` on anything other than a plain name, such as a struct field, is
rejected earlier by the parser with `E_MUT_CONFLICT`.

The invariant itself is enforced where the language can express it, by
`linearity.zyl`. The invariant needs two things to mean anything -- a way
to hold a writer, and a way to make two of them. There is no reference or
borrow type, so a plain binding cannot be one; what the language does have
is mutable locations, a `bytebuf`, written through by `store-u8`, the
atomic forms and `bytebuf-append`. A name becomes a writer by being
*written*, which is the distinction the rule turns on: within one location
at most one name may be written. A writer plus any number of readers is
one writer and many readers, which the invariant allows, so naming a
location twice is not itself an error -- writing through two names is.
Alias classes are per allocation rather than per name, and a `byteslice`
joins its base's class, so two names writing one buffer's memory is
`E_MUT_CONFLICT` however the second name was derived.

A closure may read a captured `let-mut` (it sees the value at capture
time). Aliasing through the raw allocation and atomic primitives is covered
by `linearity.zyl` as described above; the FFI primitives cannot alias,
because a program may not name a raw runtime entry (`E_FFI_RESTRICTED`).
Rules 3 and 4 above (no conversion, no outward write) have no dedicated
check because there is nothing to check: with no capability dimension in
`TaTy` a value is never converted, and a closure's captures are values.
`TAtomic` and `TBox` are unrepresented, and rule 5's Send-capability is
tracked syntactically as described above.

`linearity.zyl` also owns moves (`E_MOVE_VALUE`): a file descriptor or a
`StringBuffer` is consumed by the release that takes it over, and any use
afterwards is `E_MOVE_VALUE`.

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
| Secret passed to a parameter of a top-level `defn` that is not annotated `Secret` | `E_SECRET_UNANNOTATED` |
| Secret passed to `ffi-call` without `ffi-pin` | `E_FFI_PIN_REQUIRED` |
| Secret consumed into a public result with no `zeroize` | `E_ZEROIZE_MISSING` (warning) |

`declassify` in `stdlib/math/secret/secret.zyl` is the named way out.
Across a call the check fails closed: a tainted argument to a top-level
`defn` must meet a parameter annotated `Secret`, else
`E_SECRET_UNANNOTATED`, so a callee never holds key material it does not
check. Exempt are the declassifiers (`declassify`, `ct-declassify`,
`ct-eq-bool`, `ct-eq-words-bool`) and, when the callee is the standard
library's own, the erasers (`zeroize`, `zeroize-bytes`, `wipe`) and the
index-guarded memory primitives (`w-get`, `w-set`, `list-nth`,
`vec-get!`, `vec-get?`, `vec-set!`, `vec-set?`, `alloc-read-int`,
`alloc-write-int`), whose index argument is checked here instead. Builtin
operators, intrinsics and constructors propagate taint to their result as
before. Not covered: a call through a function value or a trait method
(`Trait.m`), whose callee is not a top-level `defn` at this stage.

Erasure itself is thin. A function that takes a `Secret` parameter,
returns a public value derived from it and never mentions `zeroize` draws
`E_ZEROIZE_MISSING` at severity 2 — a scalar `(Secret Int)`,
`(Secret Float)` or `(Secret Bool)` one included, because a released
region block goes back to the allocator and is not wiped (there is no
wipe-on-release; `ZYL_REGION_POISON=1` fills a released *pooled* block
with `0xDE` as a detector, see `docs/memory-poisoning-design.md`). What
*is* implemented is a separate mechanism: `sc-mark-wipe` marks every
`defn` that takes a `Secret` parameter, and `codegen.zyl`'s
`cg-wipes-frame` has the emitter zero the whole machine frame
(`rep stosq` over `[rbp-fsz, rbp)`) on return, in place of the tail call
it would otherwise make, so no copy of the value outlives the call. That
wipes the stack frame, not the region's blocks;
`docs/secret-erasure-design.md` is the write-up.

Under the package system, calling into `stdlib/math/secret` needs the
`secret` capability (§31.9); writing a `Secret` annotation does not. See
`docs/math-crypto.md`.
