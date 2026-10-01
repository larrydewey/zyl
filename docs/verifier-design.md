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

## THE DESIGN, AS MEASURED

Everything below supersedes the slice plan above. That plan was written from
the shape of the emitted code rather than from the emitted code, and four of
its load-bearing claims did not survive measurement. The measurements are on
the compiler's own 778,094-line assembly (`build/boot/stage2.s`, 218,744
memory operands) and on `build/boot/rt.s` (3,039), with nothing wired in.

The stance is unchanged and is the right part: stop trusting the compiler,
check the artifact. What changed is which obligations the artifact can
actually discharge, and one axiom set.

### The census, measured

| class | stage2.s | share | rt.s | bound recoverable from text? |
|---|---|---|---|---|
| frame slot `[rbp-N]` | 111,096 | 50.8% | — | yes, with a symbolic stack (below) |
| **stack scratch `[rsp+N]`** | 19,998 | 9.1% | 967 | yes, same model |
| thread-local `fs:NAME@tpoff` | ~200 | 0.1% | ~200 | yes, fixed offsets |
| dynamic `[reg+disp]` | 87,650 | 40.1% | 3,039 | 86% yes, 14% no |

`[rsp+N]` is a **fourth class the enumeration above does not contain**, and
it is 9% of the surface. The three-class table is the premise the whole
argument rests on, and it was incomplete. The class is self-contained -- the
staging area a function builds for its own outgoing calls -- and the same
symbolic stack model discharges it.

### Deviation 1: the kill set is far coarser than "any call"

The invariant above says a `call` to a runtime entry kills every register
holding a dynamic pointer. Measured against the 33,979 dynamic operands whose
nearest establishing idiom is a literal-size allocation:

| intervening calls between the allocation and the use | sites |
|---|---|
| none at all | 28,363 (83%) |
| some, but none of them can release | 4,825 (14%) |
| at least one genuine release | 791 (2%) |

The doc's rule rejects 86% of the corpus to catch 2%. The kill set is
narrowed to the entries that actually release a region -- `zyl_region_free`,
`zyl_region_exit`, `zyl_region_recycle`, `zyl_region_unwind`,
`zyl_arena_reset`/`_destroy` -- plus a tail `jmp` that recycles the frame
region and the frame epilogue. Narrowing is a soundness-preserving
refinement: it removes kills, so it can only admit more programs, and the
programs it newly admits are exactly the ones where nothing released.

### Deviation 2: the frame bound *is* recoverable, if the stack is modelled

The table of false positives below is real, and so is the diagnosis of its
four causes. But all four are artifacts of reading the bound off a single
`sub rsp` rather than carrying the stack symbolically as `rsp = rbp - F - k`:

- *frames grown by more than one `sub rsp`* -- accumulate into `k` instead of
  overwriting `F`;
- *742 red-zone leaves with no `sub rsp`* -- `k` starts at 0, not at `sub`;
- *push-only frames* -- `k` starts at 8 per push;
- *"a read of the return address is indistinguishable from a write"* -- it is
  distinguishable: `[rbp+8]` is **above** the frame, so a read there is
  legal and a write is a different rule, not the same offset.

At a control-flow join the depth merges by maximum. So the frame bound is
derived, and codegen *also* states it as `; frame N`. The verifier requires
the two to agree. That is strictly stronger than either alone: it is two
independent derivations that must match, and the mismatch -- an `fsz` that
code generation intended and an operand it actually emitted -- is the exact
bug class this exists to catch. A stated bound that is merely trusted proves
nothing against a compiler that states a large one.

### Deviation 3: the residue is a type fact, and needs an interprocedural fixpoint

86% of the dynamic surface is provable from the text: a `mov rdi, <literal>`
before `call zyl_ralloc` fixes the block's size; the inline region bump
establishes its bound by `cmp rdx, [r11+16]` / `ja`; the array and byte
fast paths establish theirs by a magic word plus `cmp rax, [rdx+16]` / `jae`;
the 20 SIB sites each follow a dominating index compare.

The remaining 12,236 sites (14% of dynamic in stage2.s) are accesses through
a pointer that arrived as a parameter -- `mov r8, [rdi+0]`,
`mov r13, [rdi+32]` -- or through a frame slot holding one. Their bound is
the size of the aggregate the caller passed, which is a **property of the
type, not of the instruction text**. Measured over the 5,689 functions with a
dynamic access on an argument register, the largest displacement per
(function, argument) is 0/8/16/24/32/40/48/64 bytes for all but a handful.
That is a layout table, and layout tables are computed by the type checker,
not recoverable from assembly.

So the residue is discharged by an interprocedural summary: each function
declares the minimum byte bound each pointer parameter requires, the
summaries are joined over the direct call graph to a fixpoint, and every call
site is checked to supply at least that. This is the shape
`region_inference.zyl` already uses for regions -- per-function parameter
summaries joined to a whole-program fixpoint -- so the precedent and much of
the code shape exist. It is the bulk of the work.

### Deviation 4: the axiom set is the `%` primitive table, not the allocator

Verifying the runtime as well as programs (chosen over exempting it) makes
the locked `%` primitives the axioms of the whole system, and that is a
*smaller* trusted base than "the verifier and the allocator": roughly twenty
contract entries instead of 42,000 lines of allocator. Each entry states what
the primitive establishes and what it requires of a pointer operand.

| primitive | establishes | requires |
|---|---|---|
| `%global "n" sz` / `%tls "n" sz` | a block of `sz` bytes, live for the program (TLS: for the thread) | -- |
| `%loadN p` / `%storeN p` | nothing | `p` valid for `N` bytes |
| `%cas p` / `%xchg p` / `%fill p n` | nothing | `p` valid for `n` bytes |
| `%syscallN ...` | nothing; `mmap` (`nr 9`) yields `n` bytes, read from the argument | -- |
| `%callN` | nothing; an indirect call | -- |
| `%fn "sym" n` | a code address, not data | -- |

The table is hand-written and **cross-checked against `runtime/rt` source**,
the way `verify/model.py` cross-checks the allocator: a primitive whose real
semantics drift from its contract fails here rather than being silently
verified against a fiction.

The runtime's own residue is 66% (2,008 of 3,039), against the program's 12%
-- and that is the point rather than a cost. What is left over there is
exactly the allocator's invariants: `rt-rblock-init` writing `[b+0..24]`,
`rt-carve` walking `chunk+off` under `(+ off sz) <= 1048576`. Checking those
instruction-for-instruction *is* the remaining step of the original slice 4,
so slice 4 stops being a separate hand-written cross-check and becomes a
consequence of the same machinery.

### The checks

| | check | how the bound is obtained |
|---|---|---|
| A | frame slots | derived by the symbolic stack, cross-checked against `; frame N` |
| B | stack scratch | the same model; a class the original enumeration missed |
| C | dynamic provenance and bounds | forward interval dataflow over the derivable idioms |
| D | parameter bounds | interprocedural summary joined over the call graph to a fixpoint |
| E | region liveness | the narrowed kill set |
| F | trust boundaries | indirect calls kill provenance and are **counted**, never hidden |

### Honest limits, restated for this design

- **The verifier is itself unverified** until someone proves it in a proof
  assistant. It is a few thousand lines of dataflow and a table of twenty
  contracts, which is plausible to state completely -- but until then it is a
  much smaller thing to trust than a compiler, not a trusted thing.
- **The twenty contract entries are axioms.** A wrong entry is a hole. The
  source cross-check bounds the drift; it does not prove the entry true.
- **Concurrency** is a separate obligation: the single-writer/single-reader
  rule is a property of the scheduler, not of a memory operand.
- **FFI**: a foreign call can do anything. The invariant holds for Zyl's own
  code; `ffi-call`'s Pin and timeout requirements are what stand at that
  boundary.
- **Bugs that are not memory bugs** -- integer overflow, a miscompiled `+` --
  make programs wrong, not unsafe.

### Gate behaviour

A mandatory gate that rejects every build means nothing lands until the
residue reaches zero, so the machinery lands first and reports an explicit
uncovered-site count per check, and each check becomes fatal as its count
reaches zero. Two coverage counters and two fatal conditions: a program
binary, and the runtime. The runtime's residue is never hidden behind the
program's zero. The evidence line always distinguishes *ran, 0 uncovered*
from *not implemented*, and never prints the second as the first.

### Ordering, which is forced rather than chosen

The committed `stage2.s` seed recompiles the source, so the seed's assembler
must accept whatever codegen emits. Comment support must therefore land, be
reseeded, and only then may codegen emit `; frame N`. This is the two-step
rule from `docs/self-hosting.md` applied to a new *output* syntax rather than a
new input syntax.

Note also that `;` already occurs 103 times in `stage2.s` and twice in
`rt.s`, every one of them inside a `.string` literal. A comment stripper that
scans for `;` before dispatching on the directive would truncate those
strings, so the stripper is string-aware.

## PHASE LOG

### Phase 1 — assembler comments. Done.

`;` now runs to end of line in `compiler/asm_x86`, in both entry points that
read lines (`ax-line` and the `.globl`/`.weak` pre-scan), and a `;` inside a
quoted string is data. Six regression tests in `tests/regression/asm-x86.zyl`
cover the trailing comment, the whole-line comment, the annotation form, a
semicolon inside a `.string`, a comment after a `.string`, and an escaped
quote not ending the string. Seeds reseeded, fixed point verified.

Two hazards, both of which cost real time and are worth stating because the
rest of this work repeats them:

**A `;` in a `.string` is not hypothetical.** All 103 semicolons in
`stage2.s` are program text quoted into an error message. A stripper that
scanned before dispatching on the directive would truncate them silently, in
the emitted binary — a correctness bug with no symptom until some program's
error message came out short. Hence the quote tracking.

**The scan has to be bounded, and the obvious way to write it is not.** The
first version passed `zyl_view_find` the same `1099511627776` sentinel that
`ax-ch` uses for a single O(1) byte read. That sentinel is correct there and
catastrophic for a search: `rt-find-byte` stops at the length it is given,
**not** at the NUL, so every one of the 390,000 lines without a semicolon
scanned onward through the rest of its region looking for a `0x3B`. The
build went from seconds to minutes. Passing the string's real length fixed
it:

| | |
|---|---|
| assemble 15.9 MB `stage2.s` | 1895 ms |
| assemble 848 KB `rt.s` | 92 ms |
| `--bootstrap-from-self` | 11 s |
| full `./boot.sh`, fixed point verified | 20.9 s |
| `--full --no-boot` | 432/432 in 44 s |

### What phase 1 implies for the rest

The verifier goes on the same hot path: it runs on every build, over 218,744
operands in 15 MB, and its cost is paid by every compile from here on. So the
scanning primitives come first and get benchmarked before any dataflow is
written.

`stdlib/compiler/verify.zyl` is **untracked and used by nothing** — a prior
attempt's V1 and V2, never committed, never in the pipeline. Its scanner is
not reusable: `vy-find` allocates a one-character `str-substring` per byte
scanned and re-measures `str-length` at each step, `vy-atoi` recurses through
`str-substring` per digit, and `vy-trim`/`vy-word`/`vy-before-comma`/
`vy-after-comma` each allocate per line. On this corpus that is minutes. Its
V1 is also unsound in the way deviation 2 describes — it reads the frame bound
off a single `sub rsp`. So phase 2 is a rewrite, not an extension.

### Remaining phases, in order

1. **Scanner.** Bulk primitives (`zyl_view_find` to search, `zyl_view_byte`
   for O(1) reads), zero allocation per operand, no recursion per line.
   *Gate: under ~1 s on `stage2.s`, measured before anything else is written.*
2. **Checks A and B.** The symbolic stack model, which discharges frame slots
   and stack scratch. Line-at-a-time parsing only; no CFG needed.
3. **Check C.** The interval dataflow over the derivable idioms.
4. **Check E.** The narrowed release kill set.
5. **Check D.** The interprocedural parameter summaries and the call-graph
   fixpoint. The bulk of the work, and the part that may not reach zero.
6. **`; frame N` emission**, last, because the reseed ordering requires it.
7. **The `%` contract table** and the runtime under it, with the
   `runtime/rt` source cross-check.
8. **Check F** and the two-gate pipeline wiring.

## Findings from the first implementation attempt

These are the measurements that produced the deviations above. All four were
measured on the compiler's own 778,094-line assembly before anything was
wired in.

### The scan is fast. That part is solved.

A single forward pass over the character buffer, classifying each `[...]`
operand in place, needs **0.036 s for 229,193 operands over 15 MB** with zero
allocations and no recursion. The three costs that made the first attempt
glacial -- six string allocations per line, a 21-entry mnemonic search per
line, one recursion frame per line -- are all removable, and two of them turn
out to be unnecessary at all:

- only `mov` and `cmp` ever carry a frame-slot operand, and both are 8-byte;
- **all 110,718 frame-slot offsets are 8-aligned**, so an 8-byte alignment
  rule is exact rather than conservative.

### The frame bound cannot be inferred from the assembly — *superseded by deviation 2*

This was the first result, and it was right about the measurements and wrong
about the conclusion. The invariant is "every *write* through `[rbp-N]` lies
inside the frame this function reserved". Deriving that from the prologue
does not work. Each formulation, measured as false positives out of 110,718
slots:

| bound taken from | false positives |
|---|---|
| the function's single `sub rsp, N` | 12,515 |
| + the 128-byte red zone, running max | 11,304 |
| + local labels are not functions | 9,503 |
| + red zone only in functions that make no call | 5,088 |

The residue is not noise. It is four independent things the text does not
state: frames are grown by more than one `sub rsp`; 742 leaf functions use
the red zone with no `sub rsp` at all; push-only frames never reserve
anything; and a *read* of the return address is indistinguishable from a
*write* to it by operand position alone. Guessing at any of them produces
false positives, and wiring it anyway would have failed every build while
looking like it found thousands of backend bugs.

So the bound must be **stated** — but see deviation 2: stated *and* derived,
which is strictly stronger than stated alone.

### The assembler has no comment syntax, so the statement needs a side channel

The obvious carrier — a `; frame N` annotation on the function — does not
work: Zyl's assembler has no comments at all. `build/boot/rt.s` contains
zero comment lines, and both `; frame 360` and `; @frame 360` are rejected
(`no such instruction`). A syntax assembler that cannot hold a comment is
also a standing obstacle to anyone reading generated assembly.

**Resolved by adding comment support**, which is the better carrier of the
two and is why this is no longer a side channel: the annotation travels
*inside* the artifact, so a signed `.s` states the frame bound of every
function in it, and the assembly hash covers it. A side table is not in the
artifact and is not covered by any hash. The cost is the reseed ordering
recorded above, and the string-awareness hazard.

The side-table plan it replaces, for the record:

1. `CGState` (`codegen.zyl:65`) is a 6-field record: arena, buffer,
   next-label, next-slot, rodata, fn-names. Add a seventh, `frames`, a list
   of `(name . fsz)`.
2. At `codegen.zyl:1792`, where `fsz` is computed, push `(name, fsz)` onto
   it.
3. `verify-asm` takes the assembly **and** that table. It reads each
   function name from the label in the text -- cheap, labels are at column 0
   -- looks up `fsz`, and checks every write to `[rbp-N]` against
   `fsz + 8` (the pushed return address).
4. The same table is the evidence the provenance record needs: a signed
   artifact can then state the frame bound of every function in it, not just
   that a verifier ran.

A mismatch between the `fsz` code generation intended and an operand it
actually emitted is exactly the bug class this is for, and only a text-level
check catches it -- which is why the statement is a cross-check on the
emitted text rather than a replacement for reading it.

### What this changes about the plan

V1 is tractable and cheap **once the bound is stated rather than recovered**.
Until then it is not implementable, and the honest order is: side table
first, check second. V3 and V4 are unaffected -- they need provenance and
liveness, not a frame bound.

*(Superseded. The bound is both stated and derived, the carrier is a comment
rather than a side table, and V3 turns out to need the interprocedural
fixpoint of deviation 3. The measurements above stand; the conclusions drawn
from them did not.)*

## Landed: the bound is stated, and `#` not `;`

`codegen.zyl` now writes `# frame N` under every function label, at all
three emitters -- the main one that computes `fsz` from slot usage, the
synthetic `main` (frame 0), and the MIR backend's `mb-prologue` (which has
`fsz` in hand). Coverage in the compiler's own output: **5,150 of 5,150
functions in stage2.s, 955 of 1,103 in rt.s**, the remainder being runtime
stubs emitted from raw string lists.

`#` rather than `;` is forced by the bootstrap, and worth recording: the
runtime seed is assembled by cc (`boot.sh`'s `use_rt` runs `cc -c` on
rt.s), and GNU as reads `;` as a statement separator, so `; frame 168`
assembles there as an instruction called `frame`. Zyl's own assembler has
been taught `#` as well as `;`.

With the annotation in place the invariant was validated against the
compiler's own output before anything was wired in: **24,661 writes and
86,114 reads over 5,150 functions, zero bound violations, zero frameless,
zero misaligned**; rt.s likewise clean. Two write-detection rules had to be
right for that number to mean anything, and both were wrong first:

- a memory operand is a *write* only when it is the destination -- before
  the comma, in Intel syntax. `mov rdi, [rbp-8]` reads. Getting this
  backwards inflated the write count from 24,661 to 82,920.
- `.L0_0:` and its siblings sit at column 0 and end in `:` like a function
  label. They are local jump targets inside a function and must not reset
  the bound.

## Landed: the verifier is wired in, and it is fast

`compile-to-asm` calls `(verify-asm buf)` and a violation panics before the
assembly is returned, so no binary is produced. The placement is the point:
every path to an assembly — driver, LSP, REPL, package build — goes through
that one function. A check a build can skip with a flag is a convention, and
this is a phase.

`./boot.sh` runs in 14 s and the full regression suite in 56 s with the pass
in it. Scanning the compiler's own output takes **0.14 s**:

```
stage2.s   787,325 lines   16,072,608 bytes
           2,060,366 memchr calls over 26,926,187 bytes   0.14 s
```

That is ~115 MB/s, which is *faster* than a Python reference of the same
rules on the same file: a per-line Python version takes 0.32 s and a
whole-buffer `re.finditer` version 0.26 s. The three costs that make up the
pass were each measured, because the first three explanations for a slow pass
were all wrong — an FFI call is 2 ns, a Zyl function call 6 ns, and
`zyl_view_find` over a 16 MB buffer 8 ns, so the 178 ns per line is ordinary
per-line work and nothing is anomalous in it.

An earlier draft of this document claimed a Python reference ran the same
rules in 0.036 s, four times faster than this. It is not reproducible: two
references written to the same rules take 0.26 s and 0.32 s. The 0.036 s
figure came from a note and was not measured, and it is the one number here
that was wrong.

Getting there took four separate mistakes, each found by measurement:

| Cost | Cause | Fix |
|---|---|---|
| 9 min | `vy-loop` was a self tail call over 778,094 lines, asking the backend to recycle that many frames | `while`, so the position lives in a ref and the loop is a back edge |
| 9 min | `vy-frame-of` ran a character loop and a seven-character literal compare on *every* line | the generator indents by exactly four spaces, so one byte at `pos+4` classifies the line |
| quadratic | every search passed the *file* length as `zyl_view_find`'s bound, so a line with no operand memchr'd on to the next match anywhere in 16 MB | pass the end of the *line*; the newline search is the only one that wants the rest of the file |
| quadratic | `vy-slot?` called `(vy-len s)` per operand, and `vy-len` is a strlen over the whole 16 MB | the total length is already threaded through as `n` |

### How the first three of those were measured wrong

`zyl_view_find`'s third argument is the search *bound*, not a capacity, and
`zyl_view_byte`'s third argument is a capacity. Copying the `2^40` from one to
the other asks memchr to scan a terabyte per call. The symptom is a build
that takes nine minutes and looks like an algorithmic problem.

Worse, the numbers that pointed at it were not measurements of the current
code. `boot.sh` exports `ZYL_HOME=build/boot` so the build uses this
checkout's stdlib, and its refresh of `~/.zyl` is **conditional** on
`~/.zyl/bin/zyl` existing. Without an install there, running
`build/boot/zyl-self` directly resolves `~/.zyl/stdlib` — a copy that can be
many commits stale. Every "the verifier is quadratic" number in the first
three drafts of this section was the *old* verifier, measured through a
stale install, which is why it looked quadratic when the current code is
linear. Benchmark with `ZYL_HOME=$PWD/build/boot`, and check
`build/boot/stdlib/compiler/verify.zyl` is the file you think it is.

A full verification of the compiler's own output:

```
stage2.s  16,072,608 bytes   5,204 functions
          24,774 frame-slot writes   86,509 reads   118,515 dynamic   0 unverified
rt.s         862,052 bytes   1,103 functions
             482 frame-slot writes    2,488 reads     4,935 dynamic   0 unverified
```

The write and read counts match the independent Python reference (24,661 /
86,114) to within the new module's own delta, and `fns=1,103` is exactly the
function count of `rt.s` — every runtime function is annotated, so nothing is
checked against a bound nobody stated. V1 covers 24,774 of 140,000 memory
accesses; the other 118,515 are dynamic and counted, not checked, which is
what the evidence says.

## The planted-violation test, and the five bugs it exists for

A verifier run only on the compiler's own output cannot be told apart from one
that does nothing: both report zero violations on correct code. `tests/verify_test.zyl`
plants faults in hand-written assembly and requires them to be caught, and it
is the reason four real defects in the verifier were found rather than shipped:

- **`vy-num` read digits backwards.** `(+ (* 10 (rest)) digit)` makes `24`
  come out as `42` and `# frame 16` as `61`. Every write then looked out of
  bounds: 3,264 violations against assembly the reference scan had cleared,
  all of them `[rbp-42]`, which is `[rbp-24]` spelled backwards.
- **`vy-nowrite` was inverted.** It asked "is it `cmp`?" and answered *no
  write* for everything else, so every store was a read. The pass reported
  zero writes over 16 MB of assembly.
- **`vy-slot?` accepted any `[r…`.** `mov qword ptr [r9+16], rsi` is a write
  through a pointer; reading its displacement as a frame offset made it
  `[rbp-6]`, and 6 is not 8-aligned, so 1,641 false violations.
- **The annotation was read at `pos+11`**, the space before the digits, so
  every frame parsed as 0 and every write past `[rbp-8]` looked out of bounds.
- **Local jump targets counted as functions.** `.L0_0:` is at column 0 and
  ends in `:` exactly like a function label; there are 61,202 of them in
  `stage2.s` against 5,150 functions, so the reported coverage was wrong by
  more than a factor of ten.

Each of these produced a *passing* build with a check that was quietly not
running. That is the argument for planting faults rather than reasoning about
coverage numbers, and the reason the test is wired into `run_regression_tests.sh`
in quick mode rather than left for later.

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
