# The stance change: verify binaries, not compilers

## The problem with where we are

Everything in `docs/soundness.md` rests on one unexamined assumption: **the
compiler and the runtime are correct.** The 433 tests, the memcheck gate, the
poison gates and the exhaustive model all check the output of components
nobody has verified. Add a sixth gate and the assumption is unchanged. The
trust base is the compiler, the runtime, and a human reading both, and no
amount of testing shrinks it.

That is why "bulletproof" cannot be reached by more evidence, and why the
gates are worth having anyway: they catch the bugs a verifier would also
catch, cheaply, before anyone writes the verifier.

## The move

**Move the proof obligation off the compiler and onto the produced binary.**

The compiler may be arbitrarily buggy. It may be malicious. What it may not
do is emit a binary that accesses memory unsafely, because every binary is
checked after it is produced and rejected if it fails. Safety then depends
on a *verifier*, and the verifier is small enough to state completely — which
is the property the compiler never had.

This is the stance Java, WebAssembly and CHERI take, and it is the only
approach that gets to a real guarantee without a decade of proof
engineering. It changes the failure mode too: a compiler bug becomes a
rejected build, not a memory-corrupting program.

It is also genuinely tractable *here*, which is not obvious. Zyl's generated
code has an unusually small memory surface. Emitting one small program and
collecting every memory operand gives three classes and nothing else:

| Class | Example | Count | Why it is safe |
|---|---|---|---|
| Frame slots | `[rbp-16]`, `[rbp-56]` | the majority | a fixed offset into a frame the function itself reserved |
| TLS | `fs:zyl_region_top@tpoff` | a handful | a fixed offset into a thread-local block |
| **Dynamic** | `[r10+0]`, `[r12+8]`, `[r8+16]` | the only dangerous ones | a register plus a displacement — no static bound |

2576 memory operands in a small program, and only the third class can be
unsafe. That is the entire attack surface, and it is enumerable.

## The invariant

For every instruction `I` with a dynamic memory operand in any produced
binary, there is a dominating instruction sequence establishing the
provenance and bound of the base register and the displacement:

```
  (a) base register holds a region block pointer B
  (b) B is live: its owning region has not exited or been recycled
  (c) base + displacement + width  <=  B + remaining
```

Frame slots and TLS are accepted without proof. A `call` to a runtime entry
kills every register holding a dynamic pointer, because the callee may
release the region. A region exit, recycle, or any runtime call that can
release kills them too.

(b) is the part that matters and the part that is genuinely new. It is a
liveness property, checkable by a forward dataflow with a kill set — the
same shape as a liveness analysis, over a fixed point, with no heuristics.
That is exactly the premise L2 is currently argued for and dynamically
spot-checked. Here it becomes a *proof obligation on every binary*.

## Why this is the core, not an add-on

Region inference currently decides placement and is trusted to be
over-approximating. Under this scheme it stops being a safety argument
entirely: if it under-approximates, the binary is wrong and gets rejected.
The optimisations become safe by the same mechanism — a transform that breaks
the invariant is caught on its own output rather than needing a side
condition. And `E_REGION_ESCAPE` stops being a promise the compiler makes and
becomes a check the verifier makes.

The compiler keeps its job: reject programs it cannot compile. It loses its
job: being the reason a program is safe.

## Slices, in order of leverage

1. **Provenance and bounds, class 3 only.** A forward dataflow over emitted
   assembly tracking each register as *unknown*, *region base with remaining
   bound*, or *derived pointer into a known base*. Reject any dynamic access
   that is not dominated by a valid binding. This alone covers array
   indexing, byte buffers, slices and the atomics — i.e. L1, L4 and L6.
2. **Region liveness.** Extend the kill set to region exit and recycle, so a
   pointer into a released region is rejected at the access. This is L2, and
   it is the one that is currently only argued.
3. **Wire it into the pipeline** as a post-codegen gate, refuse to link a
   binary that fails, and run it over the compiler's own output.
4. **The runtime.** The verifier assumes the allocator's own bookkeeping is
   correct. That is what `verify/model.py` now models exhaustively; the
   remaining step is checking the extracted model against the real allocator
   instruction-for-instruction.

Slices 1 and 2 are the whole safety argument. After them the trusted base is:
the verifier, and the allocator, which is small and modelled.

## What it still will not give

Honesty about the residue, because a document that claims more than it has is
worse than no document:

- **The verifier is itself unverified** until someone proves it in a proof
  assistant. It is small enough that this is plausible — a few thousand lines
  of dataflow — but until then it is a much smaller thing to trust than a
  compiler, not a trusted thing.
- **Concurrency.** Actors and channels are a separate obligation: the
  single-writer/single-reader rule is a property of the scheduler, not of a
  memory operand.
- **FFI.** A foreign call can do anything. The invariant holds for Zyl's own
  code; the boundary needs its own argument, and `ffi-call`'s Pin and timeout
  requirements are what stands there today.
- **Bugs that are not memory bugs.** Integer overflow, a wrong bounds check
  that is too strict, a miscompiled `+`. This makes programs wrong, not
  unsafe. Determinism catches the class of these that changes output.

That list is shorter than the one we would have if we kept adding gates, and
every item on it is a specific piece of work rather than an open question.
