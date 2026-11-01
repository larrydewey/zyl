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
    (let b (wrapping* a -49064778989728563)
      (bit-xor b (shr b 29)))))

(defn main ()
  (print (rotl64 1 8))      ; 256
  (print (mix 12345))
  0)
```

The multiply is `wrapping*`, not `*`. Int arithmetic is checked by
default, and a hash's mixing multiply overflows on purpose: written as
`*`, `(mix 12345)` would stop the program with `E_OVERFLOW`. `wrapping+`,
`wrapping-` and `wrapping*` say, at the operation, that wrap-around
modulo 2^64 is the intent; a file of nothing but such code can instead
declare `(numeric wrapping)` once at the top (Chapter 3, §3.12). The
bitwise operators and the shifts never trap.

Note `shr`, not `ashr`, in both places: these are bit patterns, not
magnitudes.

Note also how the multiplier is written. `Int` is a signed 64-bit
integer, so a constant at or above 2^63 has to be written as its value
minus 2^64 — the bit pattern is identical, and `wrapping+`,
`wrapping*`, `bit-xor` and the shifts do not care about the sign.
`stdlib/math/hash/sha512.zyl` writes all of its round constants this
way. The unsigned spelling does not compile: an integer literal too
large for `Int`, decimal (`18397679294719823053`) or hexadecimal
(`0xFF51AFD7ED558CCD`), is `E_INTEGER_OVERFLOW`. And note that `rotl64` is correct only for `n` in 1..63 —
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

`bytebuf-ptr` is the FFI hatch, and needs the `ffi` capability (the address
differs from run to run): it gives a stable address good for
exactly `bytebuf-cap` bytes. By design it belongs to the Pin region,
because an address into a region that may move is not an address at
all.

**The Stack region is enforced; the others are recorded.** A
`(bytebuf Stack N)` is allocated, zero-initialized, in the function's
frame region and released when the function returns. Returning it,
storing it in another value, or passing it to code that may keep it is
`E_REGION_ESCAPE` at compile time (sending any buffer to another actor is
already `E_CAPABILITY_LEAK`, §32.8). Byte loads, stores and appends are
known not to keep the buffer, so local use is
fine. Every other region gets the same stable, zero-initialized heap
allocation, so nothing is unsound, but the remaining rules are not
checked yet:

| Rule | Today |
|---|---|
| `bytebuf-ptr` needs the `ffi` capability | Checked, reported as `E_PKG_CAPABILITY_VIOLATION` |
| `bytebuf-ptr` only in the Pin region | Not checked; works on any buffer |
| A Stack buffer may not escape its scope | Checked, reported as `E_REGION_ESCAPE` |
| A Global buffer may not be mutated | Not checked |

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
slice's length), and an out-of-range access is a partial operation, like a
division (spec §20.3a). The plain form compiles only where the compiler can
see it fits: a literal offset into a buffer an enclosing `let` bound to
`(bytebuf R N)`. Anywhere else, say what out of range means:
`load-u8!`/`store-u8!` stop the program with `E_INDEX_OUT_OF_BOUNDS`, and
`load-u8?`/`store-u8?` give `None` (and write nothing). A plain access the
compiler cannot prove is `E_PARTIAL_OPERATION`. A successful store returns 1.

```lisp
(let buf (bytebuf Heap 64)
  (begin
    (store-u8 :le buf 0 200)  ; proven: literal 0 < 64
    (load-u8 :le buf 0)       ; 200
    (load-i8 :le buf 0)       ; -56
    (load-u8? :le buf 64)     ; None -- out of range
    (store-u8? :le buf 100 1) ; None -- nothing written
    (load-u8! :le buf 64)     ; stops: E_INDEX_OUT_OF_BOUNDS
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
    (load-u32? :le b 6)))           ; None -- bytes 6..9 do not all fit
```

The bounds check covers the whole width: an access that would run past
the end is out of range, exactly like an out-of-range byte. Signed loads sign-extend from the loaded width;
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

## 32.8 Sharing a Buffer Between Actors, and Alignment

A `ByteBuf` belongs to one actor. A spawned closure that captures one,
or a buffer sent over a channel, would let two actors write the same
bytes in an order the scheduler picks, so it is `E_CAPABILITY_LEAK` at
compile time; the same holds for a `Ref` and the other handles written
in place, and for one held inside a struct, an `Option`, a list or
another closure (spec §7.4).

The one buffer actors may share is an `AtomicBuf`, from `atomic/atomic`.
It is a row of slots, not bytes, and it has no conversion from or to a
`ByteBuf`. A spawned closure captures it directly; while any actor holds
it, the only operations are updates that commute and return nothing:

```lisp
(atomicbuf-new 4)          ; four slots of 0
(atomicbuf-add b i v)      ; slot i += v, kept in 128 bits
(atomicbuf-max b i v)      ; slot i = max(slot i, v)
(atomicbuf-min b i v)
(atomicbuf-and b i v)      ; bitwise
(atomicbuf-or  b i v)
(atomicbuf-xor b i v)
```

There is no load, store, compare-and-swap or fetch-and-add: any of
those would let a value depend on which actor got there first. Since
every update commutes, the buffer ends the same under every schedule.

You read it after joining, through a freeze. `atomicbuf-freeze!` is a
move (using the buffer again is `E_MOVE_VALUE`) that hands back a
read-only `AtomicView`, and it succeeds only when every actor that
captured the buffer has been joined by the actor that spawned it;
otherwise it stops with `E_ATOMIC_SHARED`, never a partial total
(`atomicbuf-freeze?` gives `None`, and `atomicbuf-held` asks first):

```lisp
(capabilities actor)
(use actor/actor)
(use atomic/atomic)

(defn count-up ((b AtomicBuf) (n Int))
  (if (= n 0) unit
    (begin (atomicbuf-add! b 0 1) (atomicbuf-max! b 1 n) (count-up b (- n 1)))))

(defn main ()
  (let b (atomicbuf-new 2)
    (let a1 (spawn (fn () (count-up b 1000)))
      (let a2 (spawn (fn () (count-up b 2000)))
        (begin
          (actor-wait a1)
          (actor-wait a2)
          (let v (atomicbuf-freeze! b)
            (begin
              (print (atomicview-get! v 0))   ; 3000
              (print (atomicview-get! v 1))   ; 2000
              0)))))))
```

Each operation is spelled like a byte access. The plain form compiles
only where the compiler sees the slot fits: a literal slot into a
buffer a `let` bound to `(atomicbuf-new N)` with a literal `N`
(`(atomicbuf-add b 0 1)` inside `main` above would do). `count-up`
gets the buffer as a parameter, where nothing is proven, so it writes
`atomicbuf-add!`, which stops with `E_INDEX_OUT_OF_BOUNDS`
outside the buffer, or `atomicbuf-add?`, which gives `None`. A view is
read with `atomicview-get!` or `atomicview-get?`. A slot's sum is kept
in 128 bits, so adds never overflow while actors run; a final sum
outside `Int` is `E_OVERFLOW` at the read, and a slot updated with two
different kinds of operation (an add and a max, say) is
`E_MUT_CONFLICT` at the read, because its value would depend on their
order. Both depend only on the updates made, not on the schedule.

`atomic/atomic` also has sequentially consistent atomics on a raw
address (`atomic-load!`, `atomic-store!`, `atomic-add!`, `atomic-cas!`
and the rest), for memory shared with C. They take an `Int` address, so
they need the `ffi` capability; an address that is not a multiple of 8
stops with `E_MISALIGNED_ACCESS` (`atomic-load?` and the other `?`
forms give `None`).

`(align-check ptr alignment)` tests a pointer's alignment before a wide
access. It *returns* 1 when `ptr` is a multiple of `alignment` and 0
otherwise; it raises nothing, so act on the result.

## 32.9 What Is Ready

Worth being precise about, because the two halves of this chapter are
at different stages:

| Feature | State |
|---|---|
| `bit-and`, `bit-or`, `bit-xor`, `bit-not`, `shl`, `shr`, `ashr` | Complete. Covered by `tests/regression/bitwise.zyl` and used throughout `stdlib/math` |
| `bytebuf`, `bytebuf-cap`, `bytebuf-len`, `bytebuf-ptr` | Working; a `Stack` buffer lives in the frame region, every other region in the heap |
| `byteslice`, `byteslice-sub`, `bytebuf-append` | Working |
| `load-u8`, `load-i8`, `store-u8`, `store-i8` | Working; plain only where proven in range, else `!` (`E_INDEX_OUT_OF_BOUNDS`) or `?` (`None`) |
| 16-, 32- and 64-bit loads and stores | Working, little- or big-endian |
| `AtomicBuf` (shared between actors) | Working: commuting updates while held, read after a freeze (spec §7.4) |
| Address atomics (`atomic-load!` ..) | Working, `ffi`; `E_MISALIGNED_ACCESS` off an 8-byte boundary |
| `align-check` | Working, as a 1/0 test |
| Stack escape (`E_REGION_ESCAPE`) | Enforced |
| One writer per buffer (`E_MUT_CONFLICT` when two names write to one buffer or its slices) | Enforced (Chapter 17, §17.1) |
| Other region rules (Pin-only `bytebuf-ptr`, immutable Global buffers) | **Not enforced** |

Two further caveats:

- **Little of the standard library uses byte buffers.**
  `encoding/cbor` encodes into one, but `stdlib/math` represents byte
  strings as one byte per 8-byte word (`math/words`) rather than as
  packed buffers — see Chapter 34 for why that tradeoff was made.
- **Buffers and slices have their own types**, `ByteBuf` and
  `ByteSlice`, usable as annotations: `(defn fill ((b ByteBuf)) ...)`.
  Every offset, length and stored value is an `Int`, and each operation
  takes the handle its runtime entry accepts: `byteslice`,
  `bytebuf-append`, `bytebuf-len`, `bytebuf-cap` and `bytebuf-ptr` a
  `ByteBuf`, `byteslice-sub` and `bytebuf-append`'s second
  operand a `ByteSlice`, a load or store either. Anything else, a slice
  passed to `bytebuf-len` included, is `E_TYPE_MISMATCH`. A load or
  store whose handle's type nothing in its function group determines is
  `E_CANNOT_INFER`; annotate the parameter, `((b ByteBuf))`. The magic
  word in the handle's header is still checked at run time.

## Summary

- The bitwise operators are n-ary, one instruction each, and complete.
- `shr` is logical, `ashr` is arithmetic; the names differ because the
  behaviours do.
- Out-of-range shift counts are defined: logical shifts give 0, `ashr`
  saturates to the sign bit.
- `bytebuf` allocates a fixed-capacity, zero-initialised block; every
  access is bounds-checked and fails closed. A `Stack` buffer lives in
  the frame region and may not escape it (`E_REGION_ESCAPE`); the other
  region rules are not enforced yet.
- Write constants at or above 2^63 as negative `Int`s; an oversized
  literal is `E_INTEGER_OVERFLOW`. Mix them with `wrapping*` and
  `wrapping+`, since `+ - *` are checked by default.
- Loads and stores come in 8, 16, 32 and 64 bits, signed and unsigned,
  with an explicit byte order; buffers are typed `ByteBuf`/`ByteSlice`.
- A buffer stays in one actor. To accumulate across actors, capture an
  `AtomicBuf`: commuting updates while actors run, read through
  `atomicbuf-freeze!` once they are joined.
