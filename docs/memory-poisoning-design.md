# Memory Poisoning: How a Released Region Block Is Made Unreadable

Status: the mechanism is implemented and measured; this document
describes it. It is the answer to one question: **how do we know a region
block is not read after release?**

The *claim* that nothing reads released region memory is `docs/soundness.md`
L2, and it is the weakest load-bearing statement in the soundness document.
This file is not that argument — it is the machinery that lets the argument
be tested at all, plus an honest account of what the machinery can and
cannot see. The regions themselves are `docs/regions-design.md`; the region
allocator is `runtime/rt/alloc.zyl`; the gate is `verify/poison.sh`.

## The failure this targets

A region block is not returned to the operating system when its region is
released. It goes back to a per-thread free list for its size class
(`rt-release-block`), and the next allocation of that class is handed the
same memory. So a pointer into a dead frame region does not fault. It reads
whatever the next allocation happened to write, and a program holding such
a pointer can still print the right answer.

That is the worst shape a use-after-free can take in a bump allocator:
silent, and dependent on an allocation pattern nobody thought to test. It
is exactly the property region inference is supposed to guarantee — no
value outlives its region — and that guarantee is otherwise an argument
about code the reader cannot run.

## What release actually does

`zyl_region_free` walks the region's block chain through `rt-release-chain`
and calls `rt-release-block` on each block. That function has two arms,
and the difference matters:

- **A big block** — one allocation too large for a size class, flagged in
  its header — is handed straight back to the kernel with `munmap`
  (`%syscall2 11`). The memory is gone, so a stale pointer faults on
  access. Nothing needs to be done to make it unreadable.
- **A pooled block** goes back on the class free list, so its bytes stay
  mapped and readable. This is the arm that needs help, and it is the
  common one: the size classes are 1 KiB, 4 KiB, 16 KiB and 64 KiB, carved
  from 1 MiB mappings kept per thread, so nearly every frame block is
  pooled.

On the pooled arm, `rt-release-block` calls `rt-poison`, and that is the
whole mechanism:

```zyl
(defn rt-poison (b)
  (if (zyl_region_poison_enabled)
    (let sz (rt-ld64 (+ b 8)) (let _ (rt-fill-de (+ b 24) (- sz 24)) 0))
    0))
```

`rt-fill-de` is `rep stosb` with the byte 222 (`0xDE`). It starts at
offset 24, past the block header — `{next, size, big, cls}`, 24 bytes —
because the free list is about to read that header, and a poisoned header
would be a corrupted header rather than a poisoned payload.

Four release paths reach it, and it matters that it is the same path in
each:

- a frame region released on return (`zyl_region_free`);
- a `with-region` scope released at the end of its body
  (`zyl_region_exit`);
- a **self tail call** (`zyl_region_recycle`), which keeps the oldest block
  and releases the rest, since the frame's remaining work reuses it. When
  there is exactly one pooled block it is only emptied, not released, so
  there is nothing to poison — it is still owned;
- a **caught panic** (`zyl_region_unwind`, called from
  `runtime/rt/panic.zyl`), which pops every region pushed after the mark
  the try frame recorded and frees their blocks.

The consequence of poisoning in `rt-release-block` rather than in the
region-level code is that every release path inherits it. A new way to
release a region cannot forget.

## The switch

`zyl_region_poison_level` (`runtime/rt/misc.zyl`) reads one environment
variable, `ZYL_REGION_POISON`:

| value | effect |
|-------|--------|
| unset, `0`, or anything else | off; `rt-poison` returns immediately |
| exactly `1` | released pooled blocks are filled with `0xDE` |
| exactly `2` | as `1`, and the size-class pool is bypassed entirely |

Only the exact strings `1` and `2` enable anything. `true`, `yes` and `3`
all read as off. That narrowness is deliberate: a gate that silently
measures nothing is worse than no gate, because it reads as evidence.

Level 2 is not a stronger version of the same test, it is a different one.
With the pool bypassed, every block is its own `mmap` and release is a real
`munmap`, so there is no free list that could be wrong. A program that
faults in level 1 but runs in level 2 was reading memory the region no
longer owned; a program that faults in both was reading something else, and
the ambiguity is worth knowing about.

Arena blocks are poisoned unconditionally, not by this switch —
`rt-free-blocks` calls `rt-fill-de` with no test. There it is deliberate
rather than diagnostic: the compiler, the REPL and the language server keep
arenas, and a stale arena pointer reading recognizable garbage is the
point. No program can hold an arena handle at all
(`E_FFI_RESTRICTED`, spec G2).

## Why not page protection

The stronger version of this gate would `mprotect(PROT_NONE)` a released
block and restore it on reuse, so any stale access is a `SIGSEGV` at the
faulting instruction instead of a wrong answer. **It was built, measured,
and withdrawn.**

The record is in `runtime/rt/alloc.zyl`, immediately above `rt-poison`,
and the reason is geometric. `mprotect` works in whole pages and rounds
the length up. The size classes are 1 KiB, 4 KiB, 16 KiB and 64 KiB, and
the 1 KiB and 16 KiB classes are not page multiples, so protecting one
block denies the three live neighbours carved out of the same page.
Restricting protection to the page-multiple classes still produced **18 of
125 programs faulting** — and bypassing the pool to find out whether those
faults were real made all 18 pass, which is ambiguous rather than
informative: either the bookkeeping was wrong or the programs were
reading memory they should not have been.

Filling cannot have that failure mode. It writes only to memory the
allocator has already taken back, so a program that never reads a released
block cannot notice it at all, and one that does reads `0xDE`. It is a
weaker detector in one specific, statable way — it needs the stale read to
be *used* — and that trade is worth taking over a detector whose own
bookkeeping produces false alarms.

There is no `mprotect` call anywhere in the runtime. A comment in
`runtime/rt/misc.zyl` described the withdrawn version for a while; it is
now corrected, and it is the reason this file exists.

## What the gates run

**`verify/poison.sh`** — the ordinary gate. It builds each of the 131
programs in `tests/regression` and `tests/smoke`, runs each twice (plain,
then with `ZYL_REGION_POISON=1`), and requires the exit status and the test
summary line to be identical. It deliberately does *not* diff raw output:
several of those programs print raw addresses, which differ between any two
runs because of ASLR, and a gate that reports those as failures is a gate
that gets ignored. All 131 are unchanged.

**`verify/poison-selfhost.sh`** — the strong one. It rebuilds the entire
compiler, the largest Zyl program in existence and self-hosting, with
released region blocks filled, and requires the seeds to come out
byte-identical. This is the same statement `./boot.sh` already makes about
byte-identity, now with the allocator unable to hide a stale read behind
reused memory. If the compiler read dead frame memory anywhere, the fill
would corrupt a value, the generated assembly would differ, and the fixed
point would break.

Both are opt-in (`--filter poison`, `--filter poison-selfhost`): the
first builds and runs 131 programs twice, the second a full bootstrap, so
between them they cost more than the whole quick suite (about 20 s and a
fixed-point rebuild against about 11 s for everything else).

## What this cannot show

Two limits, both stated rather than glossed.

**It catches a stale read only when that read reaches observable output.**
A stale read whose value is overwritten before anyone inspects it is
invisible to it. This is inherent to the fill, and it is the reason the
`mprotect` version was wanted; §"Why not page protection" is the reason it
is not available.

**The gate has no positive control, and cannot have one.** The violation it
looks for is precisely what the static checks exist to prevent: a test
program that reads released region memory does not compile, because
returning a `Stack` bytebuf from its frame is `E_REGION_ESCAPE` and using a
resource after release is `E_MOVE_VALUE`. So there is no in-language
program to use as a control without first weakening the compiler.

That cuts both ways, and both edges matter:

- a failure here would be a genuine escape from the static checks — the
  exact class of bug the gate exists to catch;
- a green run is weaker evidence than a validated detector would be. What
  is verified is that these 131 programs, and the compiler, do not depend
  on reading released region memory. It is *not* verified that the fill
  reaches every release path.

The adversarial version was attempted: a compiler with the escape
diagnostic suppressed, built in a scratch tree so the check never ships
weakened, manufacturing a `Stack` bytebuf returned from its frame and then
written and read by the caller. It still read back the value it wrote, with
and without poisoning. The reason is that the escape path *promotes* the
allocation to a longer-lived region rather than leaving it dangling, which
is the safe direction — `E_REGION_ESCAPE` is a guarantee that the request
could not be honoured, not a report of a dangling pointer. So the promotion
behaviour hides the very violation the gate was built to expose, and the
gate stays without a control.

What *is* verified mechanically: the flag reaches the runtime
(`zyl_region_poison_level` reads it), `rt-release-block` calls `rt-poison`
on the pool path, `rt-poison` calls `rt-fill-de`, and `build/boot/rt.s` is
regenerated and diffed by `./boot.sh` — so the shipped runtime is the one
containing that path, not a stale one.

## Cost, in a normal build

Off by default, and the fill is skipped, so the shipped runtime does no
`rep stosb` on release unless the variable is set. The *guard* is not
skipped: `zyl_rt_getenv` scans `environ` and does not cache, so the level
is re-read on every block release and every block acquisition. That is a
short scan of a small environment, not a syscall, and it has never shown up
in a benchmark. If it ever does, caching the level once at startup is the
fix, and it is a reseed because it touches the runtime.

## The same hook, a different byte

`docs/secret-erasure-design.md` proposes wiping released region blocks so a
secret is gone with the frame that held it. That is this exact code path
filling with zero instead of `0xDE`, and it is sound for a reason specific
to this compiler: region inference places a call's results in the region
*the caller chose*, so a released frame region holds no live value and
wiping it cannot corrupt a result that is still live.

Keeping both in one place is the point. The poison gate is the mechanism
that would prove the wipe works, because a wipe is invisible to a test
that only checks outputs — and a bug in wipe-on-release (releasing a block
that is still live) shows up as a corrupted value either way. `0xDE` makes
the failure loud in tests; `0x00` makes it invisible to everything except
the thing it is for.