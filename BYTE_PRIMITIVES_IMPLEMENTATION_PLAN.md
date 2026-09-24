# Zyl Byte-Level Primitives — Implementation Plan

## Current Status (verified against the code, 2026-09-23)

**Implemented and in the shipping compiler:**

- Types `TByte`, `TByteSlice Region`, `TByteBuf Region` and capability kinds
  `TCByte`/`TCAtomicByte` — `stdlib/compiler/type_system.zyl`.
- Surface forms `byte`, `load-u8`/`load-i8`, `store-u8`/`store-i8` (with a
  `:le`/`:be` endian selector), `byteslice`, `byteslice-sub`, `bytebuf`,
  `bytebuf-append`, `bytebuf-len`, `bytebuf-cap`, `bytebuf-ptr`,
  `align-check`, and the eight `bytebuf-atomic-*` forms —
  `stdlib/compiler/expr_inner.zyl` (`byte-form-dispatch`).
- Type rules — `stdlib/compiler/type_inference.zyl`.
- Lowering to generic `IFfi` calls into the runtime —
  `stdlib/compiler/icnf.zyl`. No dedicated ICNF nodes, no codegen changes.
- Runtime functions (`zyl_load_byte`, `zyl_byte_slice`, `zyl_bytebuf_new`,
  `zyl_bytebuf_atomic_*`, ...) — `runtime/actor_runtime.c`.
- Regression test `tests/regression/byte-primitives.zyl` (29 tests,
  round-trip assertions).
- Book chapter `book/src/part4/ch32-bits-and-bytes.md`; forms listed in
  `book/src/appendix/appendix-c-builtins.md`, codes in
  `book/src/appendix/appendix-a-errors.md`.

**Deviations from the original plan:** atomic forms are named
`bytebuf-atomic-*` (not `atomic-*`) to avoid shadowing
`stdlib/atomic/atomic.zyl`; lowering goes through `IFfi` rather than 19 new
ICNF variants; the runtime header is a magic tag plus bounds checks, not the
planned canary/version layout; wide-width forms (`load-u16` ... `store-i64`)
are reserved and rejected with `E_RESERVED_KEYWORD`. The endian selector is
parsed and passed to the runtime but ignored there, since every implemented
load and store is one byte wide.

**Not done:** no compile-time region enforcement of any kind (Pin-only
`bytebuf-ptr`, Stack constant capacity, Stack-return promotion,
Global immutability); the `region` argument to `bytebuf` is accepted and
ignored at runtime. Several error codes for that enforcement
(`E_BYTEBUF_NOT_PIN`, `E_ATOMIC_ABA`, `E_BYTEBUF_OVERLAP`,
`E_STACK_BYTEBUF_RETURN`, `E_GLOBAL_BYTEBUF_MUT`) are defined in
`stdlib/compiler/error_codes.zyl` but never raised. No constant-time bounds
checks, no property tests, no fuzzing harness, no wide-width loads/stores.

The sections below are the original plan annotated with what was actually
built. Historical statements (test counts, the seed-commit note) describe
the state at the time each section was written.

---

This document was previously written as a prescriptive spec before
implementation started, including a Phase 0 step that told the reader to add
these primitives to `archive/rust-bootstrap-2026/src/` and a "30-Iteration Red
Team Audit" / "120 CVEs Mitigated" section. Neither reflected anything that
actually happened:

- `archive/rust-bootstrap-2026/` is a frozen fallback, not part of the active
  compiler (see `AGENTS.md`) — it is never touched for language feature work,
  and `boot.sh --bootstrap-from-rust` exists only as a last resort for
  genuinely new unparseable syntax, not the normal workflow. That step has
  been removed from this plan.
- The audit numbers did not correspond to any actual review process on this
  codebase and have been removed rather than carried forward as if they were
  real.

---

## 1. Type System (`stdlib/compiler/type_system.zyl`) — Implemented

```zyl
(deftype Type
  ...
  (TByte)
  (TByteSlice Region)          ; region-carrying, invariant
  (TByteBuf Region))           ; region-carrying, invariant

(deftype CapKind
  ...
  (TCByte)
  (TCAtomicByte))

(deftype Region (RStack) (RHeap) (RGlobal) (RCircular) (RPin))
```

The `Type` ADT has no `Ptr`/pointer constructor at all, and never has —
pointer-shaped values (including `bytebuf-ptr`'s result) are represented as
plain `Int`, matching this codebase's existing universal convention that
"pointers are ints." The plan's original §1 sketch of `TByteBuf`/`TByteSlice`
matches what's implemented; no separate coercion or trait-derivation logic
was needed beyond what already exists for other capability-carrying types.

---

## 2. Expression Bridge (`stdlib/compiler/expr_inner.zyl`) — Implemented

```zyl
(deftype Endian (ELe) (EBe))

(deftype ExprInner
  ...
  (EByteLit Int)
  (ELoadByte Endian Expr Expr)
  (ELoadByteSigned Endian Expr Expr)
  (EStoreByte Endian Expr Expr Expr)
  (EStoreByteSigned Endian Expr Expr Expr)
  (EByteSlice Expr Expr Expr)
  (EByteSliceSub Expr Expr Expr)
  (EByteBuf Region Int)
  (EByteBufAppend Expr Expr)          ; takes a whole ByteSlice, not a byte
  (EByteBufLen Expr)
  (EByteBufCap Expr)
  (EByteBufPtr Expr)
  (EAlignCheck Expr Int)
  (EAtomicLoad Expr Expr)
  (EAtomicStore Expr Expr Expr)
  (EAtomicAdd Expr Expr Expr)
  (EAtomicSub Expr Expr Expr)
  (EAtomicCAS Expr Expr Expr Expr)
  (EAtomicFetchAdd Expr Expr Expr)
  (EAtomicMax Expr Expr Expr)
  (EAtomicMin Expr Expr Expr))
```

Recognized surface forms: `byte`, `load-u8`/`load-i8`, `store-u8`/`store-i8`,
`byteslice`, `byteslice-sub`, `bytebuf`, `bytebuf-append`, `bytebuf-len`,
`bytebuf-cap`, `bytebuf-ptr`, `align-check`.

**Naming collision, found and fixed**: the plan's original names
`atomic-load`/`atomic-store`/`atomic-add`/`atomic-sub`/`atomic-cas`/
`atomic-max`/`atomic-min` collide with pre-existing, unrelated functions of
the same names in `stdlib/atomic/atomic.zyl` (raw-address atomics used by the
actor runtime, signature `(addr value)` — 2 args, vs. the new bytebuf-offset
forms' `(buf offset value)` — 3 args). Because form recognition happens in
`byte-form-dispatch` before any function-name resolution, the new forms would
silently shadow every call to the old ones, breaking existing code
(`tests/unit_test.zyl`'s atomic tests failed this way when the collision was
in place). Fixed by renaming the new forms to `bytebuf-atomic-load`,
`bytebuf-atomic-store`, `bytebuf-atomic-add`, `bytebuf-atomic-sub`,
`bytebuf-atomic-fetch-add`, `bytebuf-atomic-max`, `bytebuf-atomic-min`,
`bytebuf-atomic-cas` — matching the `zyl_bytebuf_atomic_*` runtime naming
already in use.

Wide-width forms (`load-u16`/`u32`/`u64`, `i16`/`i32`/`i64`, and their
`store-*` counterparts) are recognized and rejected with
`E_RESERVED_KEYWORD` rather than silently falling through to an unresolvable
call — not implemented, reserved for future work.

**Two real bugs found and fixed in this file** (both were malformed
s-expressions committed as part of this feature, both were the actual root
cause of the memory-ballooning bug described in §12 below — not anything to
do with lowering or codegen):

- `parse-bytebuf` was missing one closing paren, leaving its `(Some r ...)`
  match arm unterminated.
- `reserved-byte-name`'s final `if` chain had one closing paren too many.

Either bug, on its own, desyncs this reader from the intended form
boundaries for everything after it in the file, since this reader has no
separate validation pass — nesting depth alone decides where one top-level
form ends and the next begins.

---

## 3. Type Inference (`stdlib/compiler/type_inference.zyl`) — Implemented

| Expression | Result Type |
|------------|-------------|
| `EByteLit n` | `TByte` |
| `ELoadByte`/`ELoadByteSigned` | `TInt` |
| `EStoreByte`/`EStoreByteSigned` | `TUnit` |
| `EByteSlice`/`EByteSliceSub` | `(TByteSlice R)`, `R` taken from the source buffer/slice's own inferred region (falls back to `RHeap` if the source's type isn't a byte-region-carrying type) |
| `EByteBuf region _cap` | `(TByteBuf region)` |
| `EByteBufPtr` | `TInt` — no `Ptr` type exists in this ADT (see §1). The Pin-region restriction is not enforced anywhere: a comment in `type_inference.zyl` says it is enforced at runtime, but `zyl_bytebuf_ptr` only checks the magic tag and `zyl_bytebuf_new` ignores its region argument |
| `EByteBufAppend` | `TUnit` (the runtime returns 1/0 for success, but the type discards it) |
| `EByteBufLen`/`EByteBufCap` | `TInt` |
| `EAlignCheck` | `TBool` |
| `EAtomicLoad`/`Add`/`Sub`/`FetchAdd`/`Max`/`Min` | `TInt` |
| `EAtomicStore` | `TUnit` |
| `EAtomicCAS` | `TBool` |
| anything else | a fresh type variable (`inferer-return-var`) |

`type_inference.zyl` is a best-effort pass throughout this codebase, not a
hard type-checker: many arms already collapse to a generic `TInt` for
handle-like values (e.g. `EFileOpen`), and `unify` failures are frequently
degraded to a best-guess return rather than a compile error. The rules above
follow that existing convention rather than introducing new hard-error
plumbing. Region tracking for `TByteSlice`/`TByteBuf` is preserved (the
reason those two `Type` variants carry a `Region` at all), but nothing in
this pass enforces the "Pin-only" constraint on `bytebuf-ptr` or
`TAtomicByte`-only constraint on the atomic ops described in the original
plan — see §5.

---

## 4. ICNF Lowering (`stdlib/compiler/icnf.zyl`) — Implemented, differently than planned

The original plan proposed 19 new dedicated `ICNFInner` variants
(`ICLoadByte`, `ICAtomicCAS`, etc.) with their own codegen paths. That is
**not** what got built, and doing so was unnecessary: `icnf.zyl` already has
a generic `IFfi "name" args` node for calling any C runtime function by name,
and every byte/atomic primitive lowers through it, e.g.:

```zyl
(EAtomicCAS buf offset expected newval
  (IFfi "zyl_bytebuf_atomic_cas"
    (Cons (ic-expr arena buf vt)
      (Cons (ic-expr arena offset vt)
        (Cons (ic-expr arena expected vt)
          (Cons (ic-expr arena newval vt) Nil))))))
```

This avoids touching `codegen.zyl` at all — `IFfi` already has a working,
tested codegen path (a normal C call) that every other runtime-backed
primitive in this compiler already goes through.

**Two type-confusion bugs found and fixed**: `EByteBuf`'s `region` (a bare
`Region` ADT value, not an `Expr`) and `EAlignCheck`'s `align` (a bare `Int`
literal, not an `Expr`) were being passed through `ic-expr` — which calls
`Expr.inner` on its argument — instead of being lowered directly via
`IConst`. Same bug, independently, in `ELoadByte`/`ELoadByteSigned`/
`EStoreByte`/`EStoreByteSigned`'s `endian` argument (an `Endian` ADT value).
All three are fixed the same way: convert to an `Int` first (`region-to-int`,
`endian-to-int`, or the literal itself) and wrap in `IConst`, never
`ic-expr`. Passing a non-`Expr` value into `ic-expr` reads it as if it were
an `Expr` struct — undefined behavior, not a compile error in this
untyped-at-the-IR-level pipeline — and was the direct cause of a segfault in
`ic-expr` when compiling any program that used `load-u8`/`store-u8`.

---

## 5. Region Inference — Not applicable, out of scope

The plan's original §5 described a general worklist/cycle-detection region
promotion pass operating on a borrow graph. That machinery does not exist in
this codebase and never has in any form this plan could build on: the
general `Region` ADT propagation system was deliberately deleted as dead
code (see `region_inference.zyl`'s header comment) because "region inference
had never affected a single compiled program's behavior in any
implementation this compiler has ever had." What remains is a narrower
`ri-transform-fns` pass that promotes provably-non-escaping heap allocations
to the stack — unrelated to byte buffers specifically, and not extended for
this feature.

Practical effect: `TByteBuf`/`TByteSlice`'s region parameter is tracked
through the type system (§1, §3) and used only to keep slice/buffer regions
consistent at the type level. There is no compile-time enforcement of
Stack-capacity-must-be-constant, Stack-return-promotes-to-Heap, or
Global-must-be-immutable — none of that machinery exists to enforce it. If
this needs to become a real, enforced constraint later, it is new work, not
"wire up the existing pass."

---

## 6. Codegen (`stdlib/compiler/codegen.zyl`) — Not touched, not needed

Because every byte/atomic primitive lowers through the existing generic
`IFfi` node (§4), `codegen.zyl` required no changes: `IFfi` already has a
tested emission path (ordinary C call, System V ABI). The original plan's
proposed constant-time `cmov`-based bounds checks, atomic instruction
emission, and stack `ByteBuf` frame layout were not implemented — bounds
checking happens in the C runtime (§7) with an ordinary branch, not
speculation-hardened asm. If constant-time bounds checks are a real
requirement later, that is new codegen work against a currently
nonexistent code path, not a tweak to something in place.

---

## 7. Runtime (`runtime/actor_runtime.c`) — Implemented, leaner than planned

Actual header layout (not the plan's originally proposed 48-byte
canary/magic/version/data layout):

```c
#define ZYL_BYTEBUF_MAGIC   0x5A594C4255460001ULL
#define ZYL_BYTESLICE_MAGIC 0x5A594C4255460002ULL
#define ZYL_BYTEBUF_MAX_CAP (1LL << 40)

typedef struct {
    unsigned long long magic;
    unsigned char* data;   /* separate malloc, sized to cap */
    long long len;
    long long cap;
} ZylByteBufHeader;

typedef struct {
    unsigned long long magic;
    unsigned char* data;   /* borrowed -- never freed through this handle */
    long long len;
} ZylByteSliceHeader;
```

No canary, no ABI version field, no built-in ABA-detection counter — magic
tag + bounds check on every access is the actual (and, for this codebase's
existing threat model, consistent) level of hardening; every other
handle-shaped value in this runtime (actors, arena blocks) uses the same
magic-tag-after-dereference convention, not a stronger one.

What's implemented (at the time, checked by a standalone C smoke test
that was not committed to the repository; the committed coverage is
`tests/regression/byte-primitives.zyl`, §10) — bounds
rejection, embedded-null-byte safety, zero-copy slicing, cap-overflow
rejection, self-aliasing `memmove`-safe append, magic-tag type-confusion
rejection, atomic load/store/add/fetch_add/CAS/alignment/bounds):

- `zyl_load_byte`, `zyl_load_byte_signed`, `zyl_store_byte`,
  `zyl_store_byte_signed`
- `zyl_byte_slice` (zero-copy), `zyl_byte_slice_sub` (bounds against the
  parent slice's own `len`, not the backing buffer's `cap`)
- `zyl_bytebuf_new(region, cap)` — `region` is accepted but unused (no-op;
  see §5 — nothing downstream distinguishes Stack/Heap/Pin/etc. at the
  runtime level), fixed-capacity zero-initialized allocation
- `zyl_bytebuf_append(buf, slice)` — takes a whole `ByteSlice`, not a single
  byte (this is what `parse-bytebuf-append`'s own error string says, and
  matches the implementation); uses `memmove` for alias safety; fails closed
  (returns 0, no partial write) on capacity overflow
- `zyl_bytebuf_len`, `zyl_bytebuf_cap`, `zyl_bytebuf_ptr`, `zyl_align_check`
- Atomics: `zyl_bytebuf_atomic_load/store/add/sub/fetch_add/max/min/cas`,
  each delegating to the pre-existing raw-address `zyl_atomic_*` family
  (already used for actor messaging) after validating the target slot is
  `>= 0`, 8-byte-aligned, and fully within `[0, cap)`.

Not implemented from the original plan: PRNG canary, ABI version field,
atomic `len`/`cap` fields (the buffer's own length/capacity bookkeeping is
not itself atomic — only the 8-byte slot values an atomic op targets are),
custom `zyl_bytebuf_eq` (no equality primitive was requested or added),
`mprotect`-based Pin-region write protection.

---

## 8. Error Codes (`stdlib/compiler/error_codes.zyl`) — Defined, mostly unused

The catalog defines `E_ALIGNMENT_FAILED`, `E_ALIGN_CHECK_FAILED`,
`E_BYTE_VALUE_OOB`, `E_BYTE_OOB`, `E_BYTEBUF_CAP_EXCEEDED`,
`E_BYTEBUF_NOT_PIN`, `E_BYTEBUF_INVALID`, `E_BYTEBUF_OVERLAP`,
`E_STACK_BYTEBUF_RETURN`, `E_GLOBAL_BYTEBUF_MUT` and `E_ATOMIC_ABA`.
(An earlier version of this section said the last four were never added;
they are in the catalog.) `E_BYTE_VALUE_OOB` is raised by `parse-byte` in `expr_inner.zyl` for a
`byte` literal outside 0-255 or not an integer. None of the other
compile-time codes is raised by any pass, because the enforcement they describe does not exist (§5). The runtime
does not raise the runtime codes either: out-of-bounds accesses, capacity
overflow and a bad magic tag fail closed by returning 0, not by reporting an
error. The other diagnostics the byte forms produce are
`E_ARITY_MISMATCH` (wrong argument count, from `expr_inner.zyl`) and
`E_RESERVED_KEYWORD` (a wide-width form).

---

## 9. Optimization — Not touched

No `optimization.zyl` changes were made. Volatile/no-fold treatment for
load/store/atomic/align-check nodes is inherited for free from lowering
through `IFfi` (external calls are already never constant-folded in this
pipeline) — no new logic was needed.

---

## 10. Testing — Now a real regression file (see §15)

`tests/regression/byte-primitives.zyl` covers allocation and capacity,
zero-initialisation, store/load round-trips at several offsets, offset
independence, `load-u8` zero-extension against `load-i8` sign-extension,
both endian selectors, fail-closed behaviour past capacity and at a
negative offset, slices and sub-slices (including writing through a
slice and seeing it in the parent), every atomic operation, and each
region.

The round-trip assertions are the point: the earlier "manual end-to-end
smoke test" listed here compiled and ran the forms without checking that
any value came back, which is exactly why the lowering bug in §15 went
unnoticed.

Still not done, real follow-up work: property tests (boundary sweeps,
concurrent atomic linearizability) and a fuzzing harness.

---

## 11. Documentation — Done, in the book

Chapter 32 of the book, *Bits, Bytes, and Buffers*
(`book/src/part4/ch32-bits-and-bytes.md`), documents the bitwise
operators and this whole family: buffers and regions, loads and stores,
slices, atomics, alignment, the fail-closed bounds behaviour, and a
table of exactly what is implemented against what is reserved. Appendix
C lists the forms; Appendix A lists the error codes.

---

## 12. What actually caused the memory-ballooning bug

Separately from the byte-primitives feature review, a real bug was found
and fixed: `./boot.sh` (plain, non-reseed mode) OOM-killed `stage1.bin` at
~42.5GB RSS while compiling the (pre-fix) selfhost source, confirmed via
`dmesg`/`journalctl -k`.

Root cause, isolated by bisecting the committed diff file-by-file and then
function-by-function against a fixed memory cap (`ulimit -v`): the two
malformed s-expressions in `expr_inner.zyl` described in §2
(`parse-bytebuf`'s missing close-paren, `reserved-byte-name`'s extra
close-paren). This reader has no form-boundary validation independent of
paren-nesting depth, so either bug alone desyncs where the reader thinks
top-level forms end, corrupting the parse of a large, unpredictable span of
the rest of the file into one pathologically oversized nested expression —
which is what actually drove RSS from a ~690MB baseline to >40GB. This had
nothing to do with the lexer, tail-call optimization, or closure conversion,
all of which were investigated and ruled out along the way.

Both bugs are fixed. `./boot.sh` (plain) and `./boot.sh --bootstrap-from-self`
both verified clean afterward (peak RSS ~600MB, fixed point holds,
`run_regression_tests.sh` 6/6).

---

## 13. Bootstrap Compatibility

Constraints that were actually relevant and observed in this work:
functions with a small, fixed parameter count; paren discipline (see §2/§12
for what goes wrong when it slips); no duplicate `defn`/`deftype` across
files. "Match arms enumerate all constructors, no catchall" is real for some
top-level AST/IR dispatch functions (e.g. `ic-expr`'s outer match does use a
final catchall arm, `byte-form-dispatch` does not need one since it's a
plain cascade) but is not a universal rule — catchall arms are common
elsewhere in this codebase's smaller helper matches.

`build/boot/stage2.s`/`stage2.bin` must be regenerated after any change
here, via `./boot.sh --bootstrap-from-self` (not `--bootstrap-from-rust`),
and committed once verified. The seed has since been re-cut and committed
many times; the current committed seed contains all of this work.

---

## 14. Status Checklist

- [x] Type system changes compile
- [x] Parser accepts all new syntax
- [x] Naming collision with existing `stdlib/atomic/atomic.zyl` found and fixed
- [x] Two malformed-s-expression bugs found and fixed (root cause of the
      ballooning bug, §12)
- [x] One type-confusion lowering bug (bare `Endian`/`Region`/`Int` through
      `ic-expr`) found and fixed
- [x] Inference rules type-check
- [x] ICNF lowering produces valid IR (via `IFfi`, not dedicated nodes)
- [x] Runtime primitives pass a standalone smoke test
- [x] Manual end-to-end smoke test passes through the self-hosted pipeline
- [x] Determinism verified (stage2 == stage3)
- [x] Self-host fixed point holds
- [x] `run_regression_tests.sh` passes (6/6 at the time; the suite now has
      121 tests, all passing)
- [ ] Region inference enforcement (Pin-only, Stack-const-cap, etc.) — out
      of scope, no supporting machinery exists (§5)
- [ ] Dedicated codegen path / constant-time bounds checks — not needed for
      correctness, `IFfi` covers it (§6)
- [x] Round-trip regression tests (`tests/regression/byte-primitives.zyl`, §10)
- [x] Documentation (book Chapter 32, §11)
- [x] Load/store argument-order bug found and fixed (§15)
- [ ] Property tests / fuzzing (§10)
- [ ] Wide-width loads/stores (`load-u16` ... `store-i64`) — reserved only
- [ ] Error codes raised: the enforcement codes are defined but unused (§8)
- [x] New seed committed (`build/boot/stage2.s`/`.bin`)

---

## 15. The load/store argument-order bug

**Symptom.** Every `load-u8`/`load-i8` returned 0 and every
`store-u8`/`store-i8` silently did nothing, while both compiled and ran
without a diagnostic.

**Cause.** The `Expr` fields are `(endian, buf, offset)`, matching the
source form `(load-u8 :le buf off)`; the runtime entry points are
declared `(endian, offset, buf)`. The four ICNF arms in `icnf.zyl` bound
the fields as `endian offset buf` — reading the second field as the
offset and the third as the buffer — and then emitted them in that same
order. The runtime therefore received the buffer handle as its offset
and the offset as its handle. `zyl_bytes_view` resolved a small integer
as a handle, found no magic tag, and returned an invalid view, at which
point every load short-circuited to 0 and every store returned without
writing.

Nothing caught it because nothing asserted a round-trip: the manual
smoke test ran the forms and checked that the program did not crash.

**Fix.** Bind in field order, emit in runtime order — `icnf.zyl`'s
`ELoadByte`, `ELoadByteSigned`, `EStoreByte` and `EStoreByteSigned`
arms, with a comment recording why the two orders differ.

**Verification.** `tests/regression/byte-primitives.zyl` (§10), and a
fresh seed: the change alters the compiler's own source, so the seed was
re-cut with `./boot.sh --bootstrap-from-self` and the fixed point
re-verified.
