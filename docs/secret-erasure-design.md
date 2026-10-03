# Secret Erasure: Design

Status: **layer 2 half built; layers 1, 3 and 4 planned.** Written down
2026-10-02 so the manual-cleanup problem stops being rediscovered and
disappears into a follow-up. One of the four layers below is already in
the compiler — the frame wipe — and the sections say exactly what it
covers, what it does not, and what each remaining layer would add.

## The problem

Reclamation is automatic and always was: a region is released on return,
on a tail jump, or when a caught panic unwinds it, and nothing is
`free`d by a program. What is still the developer's job is **erasure**.

A released region block goes back to the allocator with its contents
intact (`runtime/rt/alloc.zyl`, `rt-release-block`: a pooled block goes
back on its class free list, and `rt-poison` fills it with `0xDE` only
when the poison gate is on). So a `Secret` that was never erased is one
allocation away from being read back by whatever takes the block next.
The language makes the developer reason about the one thing it should
have made the compiler do:

```zyl
(defn verify ((key (Secret Words)))   ; warning[E_ZEROIZE_MISSING]
  0)                                   ; ... and the bytes are still there
```

A second, smaller hole: `alloc-malloc`/`alloc-free` in
`stdlib/allocator/allocator.zyl` is a manual free pair. It is stdlib
internals only — a program naming it is `E_FFI_RESTRICTED` — and it
should stay that way. Nothing developer-facing hands out a raw address,
and nothing should.

## What already exists: the frame wipe

A frame wipe is in the compiler today, and it is not a plan.
`secret_check.zyl` marks a function when a `Secret` parameter arrives,
when a `let` or `let-mut` binds a secret-derived value, or when a
`let-mut` is ever `set!` to one (`sc-mark-wipe`); `codegen.zyl` looks the
mark up (`cg-wipes-frame`, through `cg-base-name`, so a specialized
`f~T` is wiped like `f`) and at the return path either emits the usual
tail call or, instead, zeroes the whole frame with `rep stosq`
(`cg-wipe-frame`, the result parked in `r11` across it):

```asm
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov r11, rax
    lea rdi, [rbp-120]
    mov ecx, 15
    xor eax, eax
    rep stosq
    mov rax, r11
    mov rsp, rbp
```

`--emit-asm` shows it: a function with a `(Secret String)` parameter
comes out with `# frame 120` and those seven instructions, while its
neighbour `plain` in the same file is `# frame 0` with a bare `ret`. A
wiped function also makes **no tail calls**, because a tail call would
hand its live frame to the callee and the wipe would then clear the
callee's frame instead of the caller's; and it is kept off the
register-allocating backend (`mb-eligible` excludes it), so it stays on
the stack machine where every value really is in a slot.

What the wipe does **not** cover is the rest of this document:

- a secret live in a **register** at the point of return — a caller-saved
  one, which the caller will overwrite but which is readable until it
  does, and which the frame wipe has no way to name (layer 2);
- a secret in a **region block**, whose bytes the wipe never sees
  (layer 1);
- a secret that **escaped the frame** — returned, stored in a heap `Vec`,
  handed to `ffi-pin` — whose lifetime is not the frame's (layer 3).

This is also the correction to a claim the specification used to make.
§6 read that a scalar `(Secret Int)` parameter "is erased by the frame
wipe, so it does not draw `E_ZEROIZE_MISSING`", and `secret_check.zyl`
carried a matching exclusion (`sc-memory-secret-params`) that exempted
scalar parameters from the warning. Both were wrong about the code, and
in the same way: a scalar *is* covered when it is spilled, so the
exemption was argued from the one case the wipe handles and generalized
to the cases it does not. `sc-memory-secret-params` is gone. Every
`Secret` parameter that consumes its argument into a **public** result
without mentioning `zeroize`/`zeroize-bytes` now draws the warning, a
scalar included; a function that returns a secret still does not, because
erasure can legitimately live one frame up.

## Who writes the zeros

Asked directly, because it decides the design: **both, split by what
each side knows.**

The no-inline-assembly rule is on the *language surface* -- a program
gets no `unsafe` and no asm (`AGENTS.md`,
`docs/architecture-decisions.md`). It says nothing about the compiler,
which is the assembly: `codegen.zyl` emits machine instructions, and the
runtime has the locked `%` primitives. So compiler-emitted erasure is
ordinary here, not a workaround.

What decides it is knowledge, not authorship. Nobody who writes the zeros
matters to confidentiality -- only whether the bytes still exist -- but
*where the bytes are* is known to exactly one of the two sides:

- the compiler knows which slot and which **register** holds a secret,
  and its width;
- the runtime knows the length of a buffer whose length is a runtime
  value.

That decides the layers below: fixed-size compiler-known locations
(parameter slots, spill slots, temporaries, callee-saved registers) are
zeroed by `codegen.zyl`, at the return path, where the information
exists; dynamic-length buffers go through `cr-wipe`/`zyl_zeroize`,
which is already the audited implementation
(`runtime/rt/crypto.zyl`). Neither choice is about trust in the emitter.

## The layers

Four layers, in the order they should be finished. Each closes a distinct
place a secret survives; none of them requires the developer to reason
about memory. The frame wipe is the memory half of layer 2 and is already
in the compiler, so what is listed under layer 2 is the half that is not.

### 1. Erase on release (runtime only, the big win)

A released region block is wiped before it returns to the allocator.

This is sound here for a reason specific to this compiler: region
inference places a call's results in the region **the caller chose**
(`docs/regions-design.md`), so a released frame region holds no live
values. Wiping on release cannot corrupt a result that is still live.
That is the property that makes this erasure rather than vandalism, and
it is worth stating in the region invariant rather than leaving implicit.

The mechanism is already there: the poison gate
(`rt-poison`, `rt-fill-de`, `0xDE`) fills released blocks so a stale read
is visible in tests. Wipe-on-release is that same code path filling with
zero instead of `0xDE`; the poison build stays available as the
development default. `docs/memory-poisoning-design.md` is the write-up of
that mechanism, including which release paths reach `rt-poison` and why
that matters for a wipe: a wipe on a path that still holds a live value
corrupts it, so "every release path is poisoned" is also "every release
path is safe to wipe." All four release paths today — a frame region on
return, a `with-region` scope at the end of its body, a self tail call's
`zyl_region_recycle`, and a caught panic's `zyl_region_unwind` — reach
`rt-poison` through `rt-release-block`, which is what makes that claim
about the wipe true rather than merely plausible.

What it kills: `E_ZEROIZE_MISSING` for everything region-allocated, and
the developer's need to know that a value's lifetime ended at all. What
it costs: a `memset` proportional to the released region, data-independent
and deterministic, so it shows up in the benchmarks and must be measured
there rather than assumed.

### 2. Zero the register copies (codegen)

Done, for memory: the frame wipe clears every slot, so a spilled or
parameter secret is erased on return. Not done, for registers: a
`Secret` may be live in a register at the return path, and a memory wipe
cannot see it. Nothing but `codegen.zyl` can, because it is the only
thing that knows which register holds it.

So codegen tracks the register locations the frame wipe does not reach —
a value still in `rax` or another caller-saved register on the way out,
which the caller will overwrite but which is readable until it does — and
zeroes them on the return path: unrolled word stores for a small fixed
count, the runtime `cr-wipe` call for whatever length is dynamic.
Constant-time by construction — the count is a compile-time constant and
no branch depends on the value. The frame wipe is the weaker version of
this and already works; zeroing the register directly is cheaper (no
extra frame traffic) and needs no new placement, so it is the one to add.

### 3. Compiler-inserted erasure for escaping values (codegen)

A value that escapes its frame — returned, stored in a heap `Vec`,
handed to `ffi-pin` — is not covered by the frame wipe, because its
lifetime is not the frame's. Where escape analysis proves the value dies
at a specific scope end, the compiler emits the erasure there rather
than trusting the developer to place it. This is the only layer that
needs new analysis, and it is the one to defer.

### 4. State the residual exposure (docs)

Swap, hibernation and core dumps are outside the compiler. `Pin`
allocations are `mlock`'d today. `docs/soundness.md` should list what
remains after layers 1–3 as *argued* rather than implied — a language
that claims "the developer never reasons about memory" owes the reader an
honest list of where the bytes are.

## Ordering

1. Layer 1, then re-measure: `E_ZEROIZE_MISSING` becomes a warning only
   for what layer 1 cannot reach, and the benchmarks show the cost.
2. The rest of layer 2.
3. Layer 3, with the analysis it needs.
4. Layer 4 prose.

Each layer is independent and shippable; none requires a language change,
and only layers 2 and 3 touch `codegen.zyl` (one reseed each).
