# Memory safety: what is enforced, argued, and still open

This document states Zyl's memory-safety claim as precisely as the
implementation allows, and marks each part for how it is established. It
exists because the alternative has been worse: the claim "Zyl is 100%
memory safe" was previously an assertion with no argument and no
measurement behind it. Every "verified" statement in this repository's
history until now came from reading code and writing targeted probes.

Three kinds of statement appear below, and they are not
interchangeable:

- **Enforced** — a check in the compiler rejects the program. Decidable,
  and re-checked on every build.
- **Measured** — a dynamic check ran the programs and saw no error. True of
  those programs on that run; silent about everything else.
- **Argued** — a reasoning chain whose premises are themselves enforced or
  measured. Sound if the premises hold; not machine-checked.

Nothing here is a machine-checked proof. A real proof would need a
verified compiler and a verified runtime, and Zyl has neither. What
follows is the strongest honest statement.

---

## 1. The claim

**Theorem (memory safety, informal).** For any program the compiler
accepts, and any execution of it, the program performs no access to memory
it should not access: no read or write outside a live allocation, no access
to a released allocation, no double release, no access through a capability
the program does not hold.

Three corollaries the implementation goes further than this:

- **Determinism.** The same binary produces the same output. There is no
  randomness, no clock, and no scheduling dependence in the observable
  behaviour of a program (spec 14). This is stronger than what most
  memory-safe languages offer.
- **Deterministic reclamation.** There is no collector and no cycle
  collector. A region is released by construction, at a point the compiler
  chose. A heap value lives until exit.
- **No unsafe.** A program has no way to express a raw memory operation
  outside the typed primitives, and cannot name a raw runtime entry.

## 2. What a program can do to memory

The set of memory operations available to a program is finite and small.
This matters: safety follows from the *absence* of a feature, so the
enumeration is the argument.

| Operation | How a program reaches memory |
|---|---|
| allocate a region-owned value | `Vec`, `IntMap`, `Set`, `Slice`, `bytebuf`, string ops |
| read/write a field | `struct-get`; fields are immutable, `set!` on one is `E_MUT_CONFLICT` |
| index a collection | `vec-get!` and friends; bounds-checked, out of range is an error |
| load/store a byte | `load-u8`/`store-u8` and the wider forms; bounds-checked against the buffer |
| atomic RMW | `atomic-*`; operand is a `ByteBuf` region slot |
| write a file | `file-write`; a descriptor, released exactly once |
| call foreign code | `ffi-call`; symbol must be a literal, timeout required, raw runtime entries refused |
| spawn / send | actors; Kahn channels, single writer, single reader |

There is no pointer arithmetic a program can name, no way to reinterpret a
word as a different type, and no `unsafe`.

## 3. Lemmas

### L1 — Every allocation is owned by exactly one region · *Enforced*

Region inference (`region_inference.zyl`) assigns each allocation to the
frame region of the allocating call, to the caller-chosen result region, or
to the process heap. Nothing is allocated outside those three, and a
region is released only at a point the compiler determined: on return from
its frame, before a tail jump, when a caught panic unwinds it, or at exit.

### L2 — No value outlives the region that holds it · *Enforced + Argued*

The static half is `E_REGION_ESCAPE`: a `(bytebuf Stack N)` or a
`with-region` value that would outlive its region is rejected, located at
the point of escape, and 165 compile-fail tests pin it.

The load-bearing premise is that escape analysis **over**-approximates: a
value whose liveness the analysis cannot prove is placed in a longer-lived
region or the heap. Over-approximation is the safe direction — it costs
memory, never soundness. The residual risk is *under*-approximation, i.e.
a value the analysis believes dead while a reference survives.

This is still the weakest link in this document, and it is now *measured*
rather than only argued — but read the caveat, because it is a real limit on
what the measurement shows.

`verify/poison.sh` runs all 125 regression and smoke programs with released
region blocks overwritten with 0xDE — the same fill the runtime already
applies to arena blocks — and requires unchanged behaviour. All 125 are
unchanged. The failure mode this targets is the quietest one available: a
region block returns to a size-class pool on release and is handed to the
next allocation of that class, so a stale pointer does not fault, it reads
whatever the next allocation wrote. A program can hold a pointer into a
dead frame region and still produce the right answer.

Two limits, both stated rather than glossed:

- **It catches a stale read only when that read reaches observable
  output.** A stale read whose value is overwritten before anyone inspects
  it is invisible to it. This cannot be strengthened with page protection:
  mprotect works in whole pages and rounds the length up, so protecting a
  pooled block whose class size is not a page multiple denies three
  still-live neighbours. That approach was built, measured, and withdrawn —
  it reported 18 of 125 programs faulting, and bypassing the block pool to
  check whether those were real made all of them pass, which is ambiguous
  rather than informative. The reason is recorded at the bottom of
  `runtime/rt/alloc.zyl` so nobody retries it blind.
- **This gate has no positive control and cannot have one.** The violation
  it looks for is exactly what the static checks exist to prevent: a test
  program that reads released region memory does not compile, because
  returning a `Stack` bytebuf from its frame is `E_REGION_ESCAPE` and using
  a resource after release is `E_MOVE_VALUE`. So a failure here would be a
  genuine escape from the static checks, and a green run is weaker evidence
  than a validated detector would be.

`verify/poison-selfhost.sh` is the stronger of the two. It rebuilds the
entire compiler — the largest Zyl program in existence, ~100k lines,
self-hosting — with released region blocks refilled, and requires the seeds
to come out byte-identical. Byte-identity is already the property `boot.sh`
checks, so a poisoned run reproducing the seeds is the same strong statement
with the allocator no longer able to hide a stale read behind reused memory.
If the compiler read dead frame memory anywhere, the fill would corrupt a
value and codegen output would differ from the committed seed. It passes.

**Trying to break it, and failing.** The adversarial version of this is to
manufacture the violation the gate cannot otherwise see, so the gate has a
positive control. That needs a compiler with the escape *diagnostic*
suppressed, built in a scratch tree so the check never ships weakened. It
was built, and the manufactured escape — a `Stack` bytebuf returned from its
frame and then written and read by the caller — still read back the value it
wrote, with and without poisoning. The reason is that the escape path
*promotes* the allocation to a longer-lived region rather than leaving it
dangling, which is the safe direction; `E_REGION_ESCAPE` is a guarantee to
the programmer that their `Stack` request could not be honoured, not a
report of a dangling pointer. So the failure mode this document worries
about is largely designed out rather than merely unobserved.

What this leaves: escape analysis under-approximation is no longer a bare
assertion, it is checked on 125 programs and on the compiler's own full
bootstrap, and an attempt to break it the obvious way did not succeed. It is
still not a proof. The cases that remain open are a stale read that never
reaches any output and is overwritten before anyone inspects it, and
interprocedural flows through a returned handle.

### L3 — A resource is released exactly once · *Enforced, plus a runtime floor*

Two independent mechanisms:

*Static.* `linearity.zyl` rejects `E_MOVE_VALUE` for a resource used after
its release. The rule is affine and per alias class: `file-close`,
`Drop.drop` and `string-buffer-destroy` consume their argument, every name
bound to the same resource dies with it, and a release inside an exception
handler is conditional so it does not consume. Types are discovered from
the program's own `impl Drop` forms, so a user resource is covered without
compiler support.

*Runtime.* `zyl_arena_destroy` is idempotent — it keeps its 72-byte handle
rather than freeing it, because a released handle cannot otherwise be told
apart from a live one — and a released `StringBuffer` raises
`E_USE_AFTER_FREE`.

The runtime half is not redundant. It is the floor: a release reached
through a path the pass cannot see — a builtin, or a value that crossed a
function boundary — stays *defined* rather than becoming undefined
behaviour. The static half is what stops a program from asking.

### L4 — One mutable location, one writer · *Enforced*

spec 06's aliasing invariant ("either exactly one `TMut` reference or any
number of `TCap` references") needs a `TMut` to hold. Zyl has no reference
or borrow type: `TaTy` is `TaV | TaC | TaF`, with no capability dimension,
so a plain binding cannot be a `TMut` reference to alias with. What the
language has is mutable locations — a `bytebuf`, written through by
`store-u8`, the atomic forms and `bytebuf-append`.

A name becomes `TMut` by being *written*, so the rule is: within one
location, at most one name may be written. A writer plus any number of
readers is one `TMut` and many `TCap`, which the invariant permits, so
naming a location twice is not itself an error.

Both halves of this were wrong before they were right, in ways worth
recording because the failure mode was silence:

- Keying alias classes by *name* rather than per allocation let two
  sibling buffers that shared a name inherit each other's writer.
- Treating a `byteslice` as a new location rather than a window onto its
  base's let `(let v (byteslice b 8 4))` written through both `v` and `b`
  look like two locations.

### L5 — A program cannot name a raw memory operation · *Enforced*

`E_FFI_RESTRICTED` refuses an `ffi-call` naming a raw runtime entry
(`ffi_sigs.zyl`'s `ffi-raw-p` — 37 entries covering `zyl_mem_alloc`,
`zyl_arena_*`, `zyl_word_*`, `zyl_heap_alloc`, `zyl_val_*` and the rest).
The allocator wrappers are refused by name at the call site, so all three
routes are closed: the raw `ffi-call`, the wrapper, and reading an `Arena`
field, which is nominal and will not unify with `Int`.

A program also cannot obtain an arena. The collections allocate from
regions and take no arena parameter; what still holds one is the compiler,
the LSP and the REPL, whose parse trees and scratch outlive any frame, and
those are compiled in an internal mode.

### L6 — Indexed access is bounds-checked · *Enforced*

`vec-set!` returns the vector unchanged rather than writing when the index
is out of range, and reads report rather than fault. Collections are typed:
an array's slots are filled in order so a collection only ever reads
elements it wrote, and there is no word-level cast anywhere
(`docs/sound-types-design.md`).

### L7 — Generated code does not write outside the frame it reserved · *Enforced, on the artifact*

Every function's emitted assembly carries `# frame N`, the bound code
generation computed from actual slot usage, and `verify-asm` — a phase of
`compile-to-asm`, not a check run afterwards — rejects the build if a write
through `[rbp-M]` has `M > N + 8` or `M` is not 8-aligned. Both are complete
for that operand class: a write outside the frame lands in a caller's frame,
and a misaligned slot is a torn word.

On the compiler's own output this covers 24,774 writes with zero violations
and zero writes whose function stated no bound. The remaining 118,515
dynamic accesses — a register plus a displacement — are **counted, not
checked**; that census is V2, and `verify-report` says so rather than
reporting a pass. The bound is stated rather than inferred because it cannot
be recovered from the assembly: every formulation taken from the text
produced thousands of false positives, measured in
`docs/verifier-design.md`.

What this is not: a proof of the verifier, which is itself unverified until
someone checks it in a proof assistant. V3 (provenance and bounds for
dynamic accesses) and V4 (region liveness) are not implemented, and the
evidence reports them as absent rather than as passed.

## 4. What the aliasing that exists is

Two `Vec` handles derived from one another share storage — that is the
documented design (`vec.zyl`: "versions made from the same Vec share
storage until one of them outgrows it"), and it is *persistent*: an update
returns a new value and the old one stays valid.

This is not memory-unsafe. The shared array is region-owned and
bounds-checked, and a stale handle reads the old array rather than freed
memory. Measured rather than assumed: 300k iterations of a handle
outliving its own reallocation, reading every stale element under
allocation pressure, returned exactly the predicted sum
(`90000900000`), with memcheck clean and flat RSS.

It is a weaker *guarantee* than Rust's, though a safe one. Rust's aliasing
model tells you which reads see which writes; Zyl's does not, and a write
through one handle is visible in another by design. Making that an error
would mean making the collections non-persistent, contradicting
`docs/sound-types-design.md` and every caller in the tree.

## 4b. The machine-checked part

Everything above is either enforced at compile time or observed at run time.
One component is now *exhaustively* machine-checked, which is a different kind
of statement: not "no interleaving we ran violated this" but "no interleaving
in the reachable state space violated this, at the stated bounds".

`verify/model.py` encodes the region allocator and the scope discipline as a
finite transition system, transcribed from `runtime/rt/alloc.zyl` —
`rt-class-size`, `rt-pick-class`, `rt-carve`, `rt-rblock-get`,
`rt-release-block`, `zyl_region_scope_enter/exit` — and explores the
reachable state space by breadth-first search, checking the invariants on
every state. It proves, for the model:

- **P1** a block is never both owned and free (structural: the class pool is
  the only free list, and allocation removes from it while release adds);
- **P2** a block is released only while owned;
- **P3** every block a scope owned is free once it exits;
- **P4** block conservation: free + owned equals created;
- **D1** the transition relation is a *function* — one successor per (state,
  operation). This is the layer determinism bottoms out at. If the allocator
  could choose between two blocks, an allocation would depend on something
  other than the program text.

Results: 255,983 states explored at depth 10, 876,621 distinct states seen,
all properties holding. Raising `ZYL_MODEL_DEPTH` and `ZYL_MODEL_STATES`
widens the claim; the defaults are printed on every run so the coverage is
never implicit.

Two things keep this from being a proof of the runtime, and both are in the
script:

- **The model is checked against the source, not the binary.**
  `cross_check_source` reads `rt-class-size`, `rt-pick-class` and
  `rt-release-block` back out of `runtime/rt/alloc.zyl` and compares them with
  the model, so a runtime change the model has not absorbed fails here rather
  than being silently verified against a fiction. That covers the functions
  that decide every block's size and fate; it does not cover all of them.
- **The bounds are the claim.** A deeper or wider search covers more of the
  model, not more of the runtime.

The checker's own detection path is exercised by
`verify/model_selftest.sh`, which injects a double free into a scratch copy
and requires a counterexample trace. Without that, "all properties hold" would
be indistinguishable from "the checker looks for nothing".

`verify/determinism.sh` also checks determinism end to end: 120 programs
compiled twice in separate processes, byte-identical every time. The
self-hosting fixed point is the same property at far larger scale.

## 5. The comparison with Rust, stated carefully

Zyl is **safer than Rust in one respect that matters**: Rust's memory
safety is *conditional* on `unsafe` blocks being correct, and a large
minority of the ecosystem contains them. A Zyl program has no `unsafe`, no
raw pointer, and no way to express the operations that need one. The
trusted computing base for a Zyl program is the runtime; for a Rust
program it is the runtime plus every `unsafe` block in its dependency
graph.

Zyl is **weaker in three**:

1. **Aliasing discipline.** Rust enforces one; Zyl has persistent sharing
   and no discipline. Safe, but not the same guarantee.
2. **Evidence.** Rust has Miri, decades of production use, and an enormous
   body of fuzzing. Zyl had *no* dynamic memory-safety testing at all
   until `verify/memcheck.sh` was added, and no proof effort at all.
3. **Assortment.** The escape analysis underpinning L2 is a few thousand
   lines of flow-insensitive approximation whose under-approximation cases
   have not been hunted the way Rust's have.

So the honest summary: **at the language level, Zyl's guarantee is
unconditional where Rust's is conditional. In practice, Zyl's is far less
tested.** "Safer than Rust" is defensible as a statement about the type
system and indefensible as a statement about the artifact.

## 6. How to re-establish all of this

```bash
./boot.sh                                          # fixed point holds
./run_regression_tests.sh --full                   # 433 tests
./run_regression_tests.sh --full --no-boot --filter memcheck   # memory gate
./run_regression_tests.sh --full --no-boot --filter poison    # region gate
./run_regression_tests.sh --full --no-boot --filter poison-selfhost  # whole compiler
./run_regression_tests.sh --full --no-boot --filter determinism      # + exhaustive model
python3 verify/model.py                                              # model check alone
```

`verify/model.py` needs only the standard library -- no solver, no build step.
The state space is small enough to enumerate outright, which for a system
this finite is a stronger statement than a bounded solver answer: nothing is
assumed about a search depth being "deep enough".

The memcheck gate checks its own positive control and its own detection
path before reporting a result, so a green run means the measurement
worked rather than that nothing was measured. `KEEP=1` leaves the scratch
binaries for inspection.

## 7. What is explicitly not claimed

- `TCap<T>` and `TMut<T>` are not written as types. Rules 3 and 4
  (downgrade allowed, upgrade forbidden) hold *structurally* — with no
  conversion in the language there is none to forbid — not by unification.
- `TAtomic`, `TBox`, and rule 5's Send-capability are unrepresented; Send
  is tracked syntactically.
- Aliasing through raw allocation is covered for `bytebuf` and the atomic
  forms. Aliasing through a returned handle is not tracked
  interprocedurally: `(let y (f b))` where `f` returns its parameter is
  not followed.
- No proof assistant is involved. Section 3 is a set of arguments with
  named premises, not a machine-checked development.
- The memcheck sweep covers `tests/regression` and `tests/smoke`. It says
  nothing about `tests/stress`, the package suites, or the compiler
  compiling a large program, none of which are in the gate.
