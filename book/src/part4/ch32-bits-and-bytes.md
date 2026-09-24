# Chapter 32: Bits, Bytes, and Buffers

Most of this book is about keeping you away from raw memory. This
chapter is the exception: the operations here are what a hash function,
a cipher, a wire-format parser or a lock-free counter is actually made
of.

They divide cleanly. The bitwise operators are complete, tested and
used throughout `stdlib/math`. The byte-buffer family is younger: it
works, but several of the region rules the design calls for are not
enforced yet, and §32.9 is explicit about which parts are ready.

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

`bit-and`, `bit-or` and `bit-xor` each lower to a single machine
instruction, and `bit-not` is an XOR with -1. The shifts are a short
fixed sequence (§32.3). None of them branches, and none of their
instruction streams depends on the operand values, which is what makes
them the vocabulary of constant-time code (Chapter 33).

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
count behaves the same way (it compares as a huge unsigned count). This
costs three extra branchless instructions per logical shift (a compare,
a subtract-with-borrow that builds a mask, and an AND) and a compare and
conditional move per `ashr`, and it buys a language where `(shl x n)`
means the same thing for every `n` — including the `n` your loop
reached that you did not think about.

One consequence worth knowing: constant folding does not cover the
bitwise operators. The reason recorded in `optimization.zyl` is
historical — folding a `bit-and` inside the compiler requires the
compiler's own source to use `bit-and`, which the seed of the day could
not compile. The operators are a few instructions each, so little is
lost.

## 32.4 A Worked Example

Here is a small mixing step, the shape of which recurs in every hash
function:

```lisp
(use core/core)

(defn rotl64 (x n)
  (bit-or (shl x n) (shr x (- 64 n))))

;; 0xFF51AFD7ED558CCD, written as the signed Int it is
(defn mix (x)
  (let a (bit-xor x (shr x 33))
    (let b (* a -49064778989728563)
      (bit-xor b (shr b 29)))))

(defn main ()
  (print (rotl64 1 8)))     ; 256
```

Note `shr`, not `ashr`, in both places: these are bit patterns, not
magnitudes.

Note also how the multiplier is written. `Int` is a signed 64-bit
integer, so a constant at or above 2^63 has to be written as its value
minus 2^64 — the bit pattern is identical, and `+`, `*`, `bit-xor` and
the shifts do not care about the sign. `stdlib/math/hash/sha512.zyl`
writes all of its round constants this way. Do not write the unsigned
spelling: an integer literal too large for `Int`, decimal
(`18397679294719823053`) or hexadecimal (`0xFF51AFD7ED558CCD`),
currently compiles *silently to 0* rather than being rejected. And note that `rotl64` is correct only for `n` in 1..63 —
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
(bytebuf-ptr buf)      ; raw address of the data
```

`bytebuf-ptr` is the FFI hatch: it gives a stable address good for
exactly `bytebuf-cap` bytes. By design it belongs to the Pin region,
because an address into a region that may move is not an address at
all.

**The region is currently recorded, not enforced.** The runtime gives
every region the same stable, zero-initialized heap allocation, so
nothing is unsound — but the rules the design specifies are not checked
yet:

| Rule | Designated error | Today |
|---|---|---|
| `bytebuf-ptr` only in the Pin region | `E_BYTEBUF_NOT_PIN` | Not checked; works on any buffer |
| A Stack buffer may not escape its scope | `E_STACK_BYTEBUF_RETURN` | Not checked |
| A Global buffer may not be mutated | `E_GLOBAL_BYTEBUF_MUT` | Not checked |

Write `Pin` when you mean to take an address, so the program stays
correct when the check arrives.

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

Every access is bounds-checked against the buffer's capacity (or a
slice's length). An out-of-range offset is not undefined behaviour and
not a crash: a load returns 0 and a store does nothing and returns 0 (a
successful store returns 1). That is the same fail-closed posture the
rest of the runtime takes, and it means a bug in offset arithmetic
corrupts nothing.

```lisp
(let buf (bytebuf Heap 64)
  (begin
    (store-u8 :le buf 0 200)
    (load-u8 :le buf 0)       ; 200
    (load-i8 :le buf 0)       ; -56
    (load-u8 :le buf 64)      ; 0 -- out of range
    (store-u8 :le buf 100 1)  ; 0 -- ignored
    0))
```

### Wider widths

`load-u16`, `load-u32`, `load-u64`, their signed forms `load-i16`,
`load-i32`, `load-i64`, and the matching `store-*` forms take the same
arguments as the 8-bit ones. The selector now matters: `:le` puts the
least significant byte first, `:be` the most significant.

```lisp
(let b (bytebuf Heap 8)
  (begin
    (store-u32 :le b 0 305419896)   ; bytes 78 56 34 12
    (load-u32 :be b 0)              ; 2018915346 (0x78563412)
    (load-i16 :le b 0)              ; 22136
    (load-u32 :le b 6)))            ; 0 -- bytes 6..9 do not all fit
```

The bounds check covers the whole width: an access that would run past
the end reads 0 or stores nothing (returning 0), exactly like an
out-of-range byte. Signed loads sign-extend from the loaded width;
`load-u64` returns the 64-bit pattern as an `Int`.

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

These operate on real memory at real offsets, sequentially
consistent, and are the building blocks for a shared counter or a
lock-free structure. Each works on an 8-byte word: the offset must be a
multiple of 8 and the word must fit inside the capacity, or the
operation does nothing and returns 0 (an unaligned atomic is not
lock-free on x86_64, so it is refused rather than allowed to tear).

`bytebuf-atomic-add`, `-sub`, `-max` and `-min` return the *new* value;
`bytebuf-atomic-fetch-add` returns the *old* one; `bytebuf-atomic-cas`
returns 1 if it swapped and 0 if not; `bytebuf-atomic-store` returns 1.

```lisp
(bytebuf-atomic-store buf 8 41)      ; 1
(bytebuf-atomic-add buf 8 1)         ; 42
(bytebuf-atomic-cas buf 8 42 7)      ; 1, and the word is now 7
(bytebuf-atomic-load buf 3)          ; 0 -- offset not 8-aligned
```

The design reserves `E_ATOMIC_ABA` for a compare-and-swap outside the
Pin region — a CAS on memory that may move underneath it is the ABA
hazard the name refers to — but that check is not implemented yet.

`(align-check ptr alignment)` tests a pointer's alignment before a wide
access. It *returns* 1 when `ptr` is a multiple of `alignment` and 0
otherwise; it does not raise `E_ALIGNMENT_FAILED`, so act on the result.

## 32.9 What Is Ready

Worth being precise about, because the two halves of this chapter are
at different stages:

| Feature | State |
|---|---|
| `bit-and`, `bit-or`, `bit-xor`, `bit-not`, `shl`, `shr`, `ashr` | Complete. Covered by `tests/regression/bitwise.zyl` and used throughout `stdlib/math` |
| `bytebuf`, `bytebuf-cap`, `bytebuf-len`, `bytebuf-ptr` | Working; the region argument does not change allocation |
| `byteslice`, `byteslice-sub`, `bytebuf-append` | Working |
| `load-u8`, `load-i8`, `store-u8`, `store-i8` | Working |
| 16-, 32- and 64-bit loads and stores | Working, little- or big-endian |
| The atomic family | Working, on 8-aligned offsets |
| `align-check` | Working, as a 1/0 test |
| Region rules (`E_BYTEBUF_NOT_PIN`, `E_STACK_BYTEBUF_RETURN`, `E_GLOBAL_BYTEBUF_MUT`, `E_ATOMIC_ABA`) | **Not enforced** |

Two further caveats:

- **Nothing in the standard library uses byte buffers yet.**
  `stdlib/math` represents byte strings as one byte per 8-byte word
  (`math/words`) rather than as packed buffers — see Chapter 34 for why
  that tradeoff was made. The buffer family is there for programs that
  need packed representations; it is not yet load-bearing.
- **Buffers and slices have their own types**, `ByteBuf` and
  `ByteSlice`, usable as annotations: `(defn fill ((b ByteBuf)) ...)`.
  Passing an `Int`, `Float`, `Bool` or `String` where a handle is
  expected is `E_TYPE_MISMATCH`. The byte operations accept either
  handle type. A value whose type inference cannot determine is still
  checked only at run time, by the magic word in the handle's header.

## Summary

- The bitwise operators are n-ary, one instruction each, and complete.
- `shr` is logical, `ashr` is arithmetic; the names differ because the
  behaviours do.
- Out-of-range shift counts are defined: logical shifts give 0, `ashr`
  saturates to the sign bit.
- `bytebuf` allocates a fixed-capacity, zero-initialised block; every
  access is bounds-checked and fails closed. The region is recorded but
  its rules are not enforced yet.
- Write constants at or above 2^63 as negative `Int`s; an oversized
  literal currently becomes 0.
- Loads and stores come in 8, 16, 32 and 64 bits, signed and unsigned,
  with an explicit byte order; buffers are typed `ByteBuf`/`ByteSlice`.
