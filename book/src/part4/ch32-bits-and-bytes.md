# Chapter 32: Bits, Bytes, and Buffers

Most of this book is about keeping you away from raw memory. This
chapter is the exception: the operations here are what a hash function,
a cipher, a wire-format parser or a lock-free counter is actually made
of.

They divide cleanly. The bitwise operators are complete, tested and
used throughout `stdlib/math`. The byte-buffer family is younger, and
§32.9 is explicit about which parts of it are ready.

## 32.1 Bitwise Operators

| Operator | Form | Meaning |
|---|---|---|
| `bit-and` | `(bit-and a b ...)` | bitwise AND |
| `bit-or` | `(bit-or a b ...)` | bitwise OR |
| `bit-xor` | `(bit-xor a b ...)` | bitwise XOR |
| `bit-not` | `(bit-not a)` | complement |
| `shl` | `(shl a n)` | logical left shift |
| `shr` | `(shr a n)` | **logical** right shift, zero fill |
| `ashr` | `(ashr a n)` | **arithmetic** right shift, sign fill |

All operate on 64-bit signed integers. The three binary operators are
n-ary and left-associative, like the arithmetic operators:

```lisp
(bit-and 12 10)      ; 8
(bit-or  12 10)      ; 14
(bit-xor 12 10)      ; 6
(bit-not 0)          ; -1

(bit-xor 1 2 4)      ; 7   -- n-ary
(bit-and 15 12 10)   ; 8
```

Each lowers to a single machine instruction, which is what makes them
the entire vocabulary of constant-time code (Chapter 33).

## 32.2 Two Right Shifts, on Purpose

`shr` fills with zeros; `ashr` fills with the sign bit. The difference
matters as soon as a negative number is involved:

```lisp
(shr  -1 60)   ; 15  -- -1 is all ones; zero-filling leaves four
(ashr -1 60)   ; -1  -- sign-filling leaves all ones
```

Use `shr` when the value is a bit pattern and `ashr` when it is a
number. Getting this wrong is the classic source of "works for positive
inputs" bugs, which is why the two have different names rather than one
operator with a mode.

## 32.3 Out-of-Range Shift Counts Are Defined

On x86, a shift count is taken modulo 64, so shifting by 64 is a no-op
and shifting by 65 is a shift by 1. Zyl does not expose that:

```lisp
(shl 1 64)       ; 0, not 1
(shl 1 65)       ; 0
(shr -1 64)      ; 0
(ashr -1 64)     ; -1   -- saturates to the sign bit
(ashr 1024 64)   ; 0
```

Logical shifts by 64 or more give zero; `ashr` saturates. A negative
count behaves the same way. This costs a compare and a conditional move
per shift, and it buys a language where `(shl x n)` means the same
thing for every `n` — including the `n` your loop reached that you did
not think about.

One consequence worth knowing: constant folding deliberately does not
cover the bitwise operators. Folding a `bit-and` inside the compiler
would require the compiler's own source to use `bit-and`, which the
previous-generation seed cannot compile. The operators are one
instruction each, so nothing is lost.

## 32.4 A Worked Example

Here is a small mixing step, the shape of which recurs in every hash
function:

```lisp
(use core/core)

(defn rotl64 (x n)
  (bit-or (shl x n) (shr x (- 64 n))))

(defn mix (x)
  (let a (bit-xor x (shr x 33))
    (let b (* a 18397679294719823053)
      (bit-xor b (shr b 29)))))

(defn main ()
  (print (rotl64 1 8)))
```

Note `shr`, not `ashr`, in both places: these are bit patterns, not
magnitudes. And note that `rotl64` is correct only for `n` in 1..63 —
at `n` of 0 the second shift is by 64, which is defined here to be
zero, so the rotation degrades to `(bit-or x 0)`, which happens to be
right. That is the kind of edge the defined-shift rule quietly removes.

For ready-made versions of these, `math/bits` has rotations, unsigned
comparison and byte packing for both 32- and 64-bit widths.

## 32.5 Byte Buffers

A `bytebuf` is a fixed-capacity block of bytes in a named region:

```lisp
(bytebuf Heap 64)      ; 64 bytes in the Heap region
(bytebuf Pin 32)       ; 32 bytes at a stable address, for FFI
```

Both arguments are compile-time literals — the region is one of
`Stack`, `Heap`, `Global`, `Circular` or `Pin`, and the capacity is an
integer literal. The whole capacity is zero-initialised up front, so
reading a byte you have not written is well defined and gives 0.

```lisp
(bytebuf-cap buf)      ; capacity, fixed at allocation
(bytebuf-len buf)      ; bytes appended so far
(bytebuf-ptr buf)      ; raw address -- Pin region only
```

`bytebuf-ptr` is the FFI hatch: it gives a stable address good for
exactly `bytebuf-cap` bytes, and it is rejected outside the Pin region
with `E_BYTEBUF_NOT_PIN`, because an address into a region that may
move is not an address at all.

The region rules are enforced, not advisory: a Stack `ByteBuf` may not
be returned from its scope (`E_STACK_BYTEBUF_RETURN`), and a Global one
may not be mutated (`E_GLOBAL_BYTEBUF_MUT`).

## 32.6 Loads and Stores

```lisp
(load-u8  :le buf offset)         ; zero-extended
(load-i8  :le buf offset)         ; sign-extended
(store-u8 :le buf offset value)
(store-i8 :le buf offset value)
```

The leading `:le` or `:be` selects endianness. For a single byte it
makes no difference, and it is required anyway so that the wider widths
— when they arrive — read the same way.

Every access is bounds-checked against the buffer's capacity. An
out-of-range offset is not undefined behaviour and not a crash: a load
returns 0 and a store does nothing. That is the same fail-closed
posture the rest of the runtime takes, and it means a bug in offset
arithmetic corrupts nothing.

**Only the 8-bit widths are implemented.** `load-u16`, `load-u32`,
`load-u64` and their signed and store counterparts are reserved names
that the compiler rejects with `E_RESERVED_KEYWORD` rather than
silently lowering to a call that cannot resolve. Build wider values
from bytes with the shift operators, or use `math/bits`'s packing
helpers.

## 32.7 Slices

A `byteslice` is a zero-copy view of part of a buffer:

```lisp
(byteslice buf offset length)          ; a view into a buffer
(byteslice-sub slice offset length)    ; a narrower view of a view
```

Both are bounds-checked against their parent when created, so a slice
that exists is a slice that is in range. `bytebuf-append` takes a
*slice*, not a single byte, and appends its whole contents:

```lisp
(bytebuf-append dst (byteslice src 0 16))
```

It fails closed — no partial write — if the append would exceed the
destination's fixed capacity, and it uses `memmove` rather than
`memcpy` because the slice may alias the destination's own storage.

## 32.8 Atomics and Alignment

```lisp
(bytebuf-atomic-load  buf offset)
(bytebuf-atomic-store buf offset value)
(bytebuf-atomic-add   buf offset value)
(bytebuf-atomic-sub   buf offset value)
(bytebuf-atomic-cas   buf offset expected desired)
(bytebuf-atomic-fetch-add buf offset value)
(bytebuf-atomic-max   buf offset value)
(bytebuf-atomic-min   buf offset value)
```

These operate on real memory at real offsets and are the building
blocks for a shared counter or a lock-free structure. A compare-and-swap
outside the Pin region is rejected with `E_ATOMIC_ABA`: a CAS on memory
that may move underneath it is exactly the ABA hazard the error is
named for.

`(align-check ptr alignment)` asserts a pointer's alignment before a
wide access, failing with `E_ALIGNMENT_FAILED` if it does not hold.

## 32.9 What Is Ready

Worth being precise about, because the two halves of this chapter are
at different stages:

| Feature | State |
|---|---|
| `bit-and`, `bit-or`, `bit-xor`, `bit-not`, `shl`, `shr`, `ashr` | Complete. Covered by `tests/regression/bitwise.zyl` and used throughout `stdlib/math` |
| `bytebuf`, `bytebuf-cap`, `bytebuf-len`, `bytebuf-ptr` | Working |
| `byteslice`, `byteslice-sub`, `bytebuf-append` | Working |
| `load-u8`, `load-i8`, `store-u8`, `store-i8` | Working |
| The atomic family | Working |
| `align-check` | Working |
| 16-, 32- and 64-bit loads and stores | **Reserved, not implemented** — rejected with `E_RESERVED_KEYWORD` |

Two further caveats:

- **Nothing in the standard library uses byte buffers yet.**
  `stdlib/math` represents byte strings as one byte per 8-byte word
  (`math/words`) rather than as packed buffers — see Chapter 34 for why
  that tradeoff was made. The buffer family is there for programs that
  need packed representations; it is not yet load-bearing.
- **A buffer handle is an integer.** Passing something that is not a
  buffer where one is expected — an ordinary number, say — is not
  currently a type error, and the runtime will dereference it. Keep
  buffer handles in their own bindings.

## Summary

- The bitwise operators are n-ary, one instruction each, and complete.
- `shr` is logical, `ashr` is arithmetic; the names differ because the
  behaviours do.
- Out-of-range shift counts are defined: logical shifts give 0, `ashr`
  saturates to the sign bit.
- `bytebuf` allocates a fixed-capacity, zero-initialised block in a
  named region; every access is bounds-checked and fails closed.
- Only 8-bit loads and stores exist; the wider widths are reserved and
  rejected rather than silently broken.
