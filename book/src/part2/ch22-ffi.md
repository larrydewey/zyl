# Chapter 22: FFI Safety and Pinning

Complete reference for Zyl's Foreign Function Interface: `ffi-call`, `extern` declarations, pinning, FFI-pinnable types, how values are represented on the C side, linking C code, and which of the specification's safety rules the compiler enforces today.

The normative text is spec v5.0 §16 (FFI model), §9.1 rules R4 and R8, §13.4 (Pin region), §31.9 (the `ffi` capability) and §31.10 (native dependencies). The implementation lives in `stdlib/compiler/icnf.zyl` (lowering), `stdlib/compiler/codegen.zyl` (the call itself), `stdlib/compiler/type_annotate.zyl` (the `extern` and pinnability checks), `stdlib/compiler/ffi_sigs.zyl` (runtime signatures), `stdlib/compiler/capability_check.zyl`, `stdlib/compiler/arity_check.zyl` (`ffi-check-call`), and the runtime (`zyl_ffi_pin`/`zyl_ffi_unpin` in `runtime/rt/alloc.zyl`, `zyl_ffi_timed` in `runtime/rt/ffitimed.zyl`). This chapter describes both, and says plainly where they differ: the FFI is one of the areas where the implementation lags furthest behind the specification.

## 22.1 FFI Overview

The specification's model (§16, R4, R8) is:

- **Pin region**: values cross the boundary through a non-moving arena.
- **Timeout**: every foreign call carries a maximum execution time.
- **Type restriction**: only FFI-pinnable types may cross.

What the compiler does today:

- Every foreign function is declared with `extern`, which gives its C signature; the type pass checks each `ffi-call` against it (§22.2). The runtime's own `zyl_*` functions are typed by the compiler's signature table, and an `extern` for one is `E_FFI_RESTRICTED`.
- `ffi-call` compiles to a System V call of the named C symbol. A word crosses as a 64-bit integer register; a `Float` crosses as a 64-bit SSE register (`xmm0`..`xmm7`, then the stack), and a `Float` result comes back from `xmm0`. A foreign symbol is called on a worker thread through the runtime's timed bridge; the runtime's own `zyl_*` symbols are called directly.
- `ffi-pin` copies one word into a slot in the Pin arena and returns the slot, a `(Pin a)`; `ffi-unpin` takes the slot and returns the `a` in it.
- The timeout argument must be a positive integer literal, and it is **enforced**: a foreign call that overruns it raises `E_FFI_TIMEOUT` (§22.7).
- Pinnability is checked for `ffi-pin` operands and for closures written inline as `ffi-call` arguments, not in general (§22.4).
- In a package with a `zyl.pkg`, using `ffi-call`, `ffi-pin` or `ffi-unpin` requires the `ffi` capability (§22.11).

C code runs with full access to the process. Nothing in the implementation stops a foreign function from writing anywhere in memory, so the FFI is the boundary where Zyl's no-undefined-behaviour guarantee (§0 P2, G5) stops holding.

## 22.2 FFI Call Syntax

```
ffi-call ::= "(" "ffi-call" String Expression* Timeout ")"
```

```lisp
(ffi-call "c_function_name" arg1 arg2 ... timeout-ms)
```

- `"c_function_name"`: the C symbol, which must be a string literal. Any byte outside `[A-Za-z0-9_]` is replaced with `_` before the name reaches the assembler, so a name cannot inject assembly.
- `arg1 arg2 ...`: the arguments, evaluated left to right.
- `timeout-ms`: the last argument, the timeout in milliseconds, which must be a positive integer literal.

```lisp
(capabilities ffi)

(extern "abs" (Int) Int)
(extern "strlen" (String) Int)
(extern "puts" (String) Int)

(defn main ()
  (begin
    (print (ffi-call "abs" -42 1000))        ; 42
    (print (ffi-call "strlen" "hello" 1000)) ; 5
    (ffi-call "puts" "from puts" 1000)       ; prints: from puts
    0))
```

**The last argument is always the timeout, and it is checked.** `ffi-check-call` (`arity_check.zyl`, also run by ICNF lowering) rejects a call whose symbol is not a string literal with `E_FFI_SYMBOL_REQUIRED`, and a call whose last argument is not a positive integer literal with `E_FFI_TIMEOUT_REQUIRED`. The literal requirement is what keeps a forgotten timeout from silently consuming the real last argument:

```
error[E_FFI_TIMEOUT_REQUIRED]: the call to `abs` has no timeout: its last argument is not a positive integer literal
  --> magnitude.zyl:1:21
   |
 1 | (defn magnitude (n) (ffi-call "abs" n))
   |                     ^
   = help: add the timeout here: (ffi-call "abs" args 1000), or once on the extern: (extern "abs" (...) R :timeout 1000)
```

`(ffi-call "abs" -42)` and `(ffi-call "abs" -42 0)` are rejected the same way, since neither ends with a positive timeout, unless the `extern` gives a default (below); `(ffi-call "abs" -42 0)` is rejected even then. A call with more than 16 arguments is `E_ARITY_MISMATCH`.

The result is whatever the function left in `rax`, as a 64-bit word (§22.5), with the type its `extern` declares.

### Declaring a foreign function: `extern`

```
extern ::= "(" "extern" String "(" Type* ")" Type ( ":timeout" Integer )? ")"
```

```lisp
(extern "strlen" (String) Int)
(extern "free" (String) Unit)
(extern "qsort" (Ptr Int Int (Fn (Ptr Ptr) Int)) Unit)
```

An `extern` names a C symbol, the types of its parameters and its result type. It must appear before any `ffi-call` to that symbol. The type pass then checks each call like a call of a Zyl function: the arguments unify with the parameter types (`E_TYPE_MISMATCH` otherwise, or when the count differs), and the call has the result type. The form itself evaluates to Unit.

**A default timeout.** `(extern "abs" (Int) Int :timeout 1000)` makes 1000 ms the timeout of every call to `abs` that gives none. Before the arity check runs, the compiler collects the program's externs (`extern-collect`, `expr_inner.zyl`) and appends the default to each `ffi-call` of that symbol whose argument count equals the extern's parameter count (`ffi-default-timeout`); a call with one argument more keeps its own last argument as the timeout, so a call-site literal wins. The extern may come before or after the calls. A `:timeout` that is not a positive integer literal is `E_FFI_TIMEOUT_REQUIRED` at the extern. Because the count decides, a call that forgets an argument and ends with a timeout literal (`(ffi-call "f" a 500)` against a two-parameter `f` with a default) passes 500 as the second argument; the type check sees a well-typed call. `zyl_*` runtime calls are unchanged: they have no extern, so they always end with their own timeout.

A call to a foreign symbol with no `extern` is rejected:

```
error[E_CANNOT_INFER]: no type for ffi-call to `abs`, which has no (extern ...) declaration
```

The types must be concrete and must fit in one machine word:

- `Int`, `Bool`, `String`, `Float`, `Unit` (for a `void` result), declared ADTs and structs (passed as a pointer), and the runtime's handle types: `Ptr` (an address, as `bytebuf-ptr` returns, that Zyl code can only pass back to C), `Fd` and the rest listed in `stdlib/compiler/ffi_sigs.zyl`. `Ptr` is a spelling for `Int` in a signature: an address is a machine word, and the runtime's own entry for it is the identity function. What is enforced is where an address may come from -- `bytebuf-ptr`, `ffi-pin`, or a foreign call -- never from memory no region accounts for, since `alloc-malloc` and the arena wrappers are `E_FFI_RESTRICTED`.
- `Float` is a `double` (§22.5). It may be a parameter, the result, or both.
- `(Fn (A ...) R)` is a C function pointer: a top-level Zyl function passed as a callback (§22.9), whose parameters take the types `A ...` — but not `Float`, since a callback Zyl hands to C is entered with the integer registers set up and the SSE ones not (§22.4).
- No `Float` *inside* a type: `(Pin Float)` or a struct with a `Float` field is `E_TYPE_MISMATCH`, because an aggregate is classified eightbyte by eightbyte and the compiler does not compute that class. A `Float` crosses on its own or not at all.
- No type variables: `(extern "abs" (a) b)` would let any value become any other, so it is `E_TYPE_MISMATCH`. There is no unsafe cast form in Zyl, and `extern` is not one.

These checks run when a call to the symbol is typed, so an `extern` that no call uses is not checked. A program has one `extern` per symbol; a later one for the same symbol replaces the earlier.

The `extern` is a promise about C, not a check of it. Nothing compares it with the C prototype, so declaring `(extern "strlen" (Int) Int)` compiles and passes an integer where C reads a pointer. Declare what the C code actually takes.

The `zyl_*` runtime functions need no `extern`: the compiler has a signature for each one it expects programs to call (`stdlib/compiler/ffi_sigs.zyl`), such as `Int -> String` for `zyl_int_text`. An `extern` is only for foreign code: declaring one for a symbol the runtime exports is `E_FFI_RESTRICTED` ("`zyl_int_text` is a runtime entry; its type comes from the compiler's signature table, not from an extern"), whatever type it gives. A runtime export with no entry in the table, such as the channel internal `zyl_chan_main_done`, is `E_CANNOT_INFER` ("no type for ffi-call to `zyl_chan_main_done`, which has no (extern ...) declaration"), and cannot be called from a program at all. A few raw entries that would turn any word into any type, such as `zyl_cstr_of_word`, are reserved to the standard library: naming one in a user program is `E_FFI_RESTRICTED`.

## 22.3 Pinning

### ffi-pin

```lisp
(ffi-pin value)
```

Spec §16: `ffi-pin` copies the value to the Pin region (a non-moving arena) and returns a stable pointer. Pin lifetime is tied to the FFI call scope unless the program manages it manually.

Implementation (`zyl_ffi_pin`, `runtime/rt/alloc.zyl`): `ffi-pin` allocates one 8-byte slot in the process-wide Pin arena, stores the value's word in it, and returns the slot. When `value` has type `a`, `(ffi-pin value)` has type `(Pin a)`. The C function therefore receives a **pointer to the value**, not the value, and the `extern` parameter that takes it is declared `(Pin a)`:

| Pinned value | Zyl type | C receives |
|--------------|----------|------------|
| `Int` 21 | `(Pin Int)` | `int64_t *` pointing at 21 |
| `String` | `(Pin String)` | `char **`: a pointer to the string pointer |
| a struct or ADT value of type `T` | `(Pin T)` | a pointer to the value's heap pointer |

```c
/* C side: reads through the pinned slot */
int64_t ml_deref(const int64_t *slot) { return *slot * 2; }
```

```lisp
(extern "ml_deref" ((Pin Int)) Int)

(let slot (ffi-pin 21)
  (print (ffi-call "ml_deref" slot 1000)))  ; 42
```

A `(Pin a)` is not an `a`. `(ffi-pin "text")` is a `(Pin String)`, so passing it to `puts`, declared `(String) Int`, is `E_TYPE_MISMATCH`, and so is arithmetic on a pinned `Int`. Pinning a function is `E_FFI_TYPE_NOT_PINNABLE`.

### ffi-unpin

```lisp
(ffi-unpin pinned)
```

Spec §16: `ffi-unpin` explicitly frees pinned memory.

Implementation (`ffi_unpin`): `ffi-unpin` takes a `(Pin a)` and returns the `a` now in the slot. That is the value pinned, or the word C wrote there, so a pinned slot is how C hands a one-word out-parameter back to Zyl:

```c
/* C side: writes the remainder through the slot */
int64_t ml_divmod(int64_t a, int64_t b, int64_t *rem) { *rem = a % b; return a / b; }
```

```lisp
(extern "ml_divmod" (Int Int (Pin Int)) Int)

(let rem (ffi-pin 0)
  (let q (ffi-call "ml_divmod" 17 5 rem 1000)
    (print (+ (* q 10) (ffi-unpin rem)))))    ; 32
```

It frees nothing, so the same slot can be read more than once. A pointer that did not come from the Pin arena prints `zyl: ffi-unpin: pointer not from ffi-pin/Pin arena` to stderr, and the result is 0. A buffer of more than one word does not fit in a slot; allocate a `(bytebuf Heap N)` and pass `bytebuf-ptr` of it, a `Ptr` (§22.8). `alloc-malloc` and `arena-alloc-zeroed` are `E_FFI_RESTRICTED`: a program cannot allocate memory that no region accounts for.

### The Pin arena

- **Non-moving**: slots never move. Nothing in Zyl compacts memory.
- **Process-wide**: one arena, grown in 256 KiB blocks, destroyed at process exit.
- **Not freed per pin**: there is no reference counting and no scope-exit release. Every `ffi-pin` holds its slot until the process ends.

`stdlib/ffi/ffi.zyl` offers thin wrappers: `ffi-pin-value`, `ffi-unpin-value`, and `ffi-safe-call` / `ffi-pin-call-unpin`, which wrap an already-computed value in `Ok`. None of them add checking.

## 22.4 FFI-Pinnable Types

Spec §16: the FFI-pinnable types are `Int`, `Float`, `Bool`, `String`, `Vec<T>` where `T` is pinnable, and types composed solely of pinnable types. §9.1 R4 requires `ffi-call` arguments to be in the Pin region and of an FFI-pinnable type.

What the compiler checks (the type pass, `type_annotate.zyl`, and `mutability_check.zyl`):

| Construct | Rejected | Error |
|-----------|----------|-------|
| `(ffi-pin e)` where `e` has a function type | yes | `E_FFI_TYPE_NOT_PINNABLE` |
| `(ffi-call "f" (fn (x) x) 1000)`, a closure written inline as an argument | yes | `E_INVALID_CAPABILITY` |
| a `Secret` passed to `ffi-call` without `ffi-pin` | yes | `E_FFI_PIN_REQUIRED` |
| a closure bound with `let` and then passed to `ffi-call` (an `extern` parameter that is not a `Fn` type rejects it as `E_TYPE_MISMATCH`) | only by the `extern` | none |
| a `let-mut` variable pinned or passed | **no** | none |
| an unpinned `Int` or `String` passed straight to `ffi-call` (R4) | **no** | none |
| a value whose type is still a type variable | **no** | none |
| a `Float` in an `extern` | **no**: allowed, in an SSE register (§22.5) | none |
| a `Float` inside an `extern`'s type, or as a `(Fn (Float) R)` callback parameter | yes | `E_TYPE_MISMATCH` |

```
error[E_FFI_TYPE_NOT_PINNABLE]: a function cannot be pinned: FFI_Pinnable types are Int, Float, Bool, String and data built from them
error[E_INVALID_CAPABILITY]: ffi-call argument is a closure, which is not FFI_Pinnable (Int/Float/Bool/String/composed only) -- pin its result data explicitly instead of passing the closure itself
```

Passing raw `Int` and `String` values directly, as in §22.2, is the idiom the standard library and the compiler itself use throughout. Rule R4 is not enforced.

## 22.5 How Values Look to C

Every argument travels as one 64-bit word, and the result is read back as one. Where the word goes is the System V ABI's decision: an integer or a pointer in `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9` and then the stack; a `double` in `xmm0`..`xmm7` and then the stack; a result in `rax` or in `xmm0`. There is no `zyl_ffi.h` header and there are no `ZylVec`/`ZylString` typedefs: declare the C side yourself with 64-bit integer and pointer types.

| Zyl value | What C receives | Declare as |
|-----------|-----------------|------------|
| `Int` | the integer | `int64_t` / `long long` |
| `Bool` | 1 or 0, as a 64-bit word | `int64_t` |
| `String` | pointer to NUL-terminated UTF-8 bytes | `const char *` |
| a `(bytebuf Heap N)` | `bytebuf-ptr` of it, a `Ptr` | `char *` / `void *` |
| struct / ADT value | pointer to a heap record `[tag][field0][field1]...` | `const int64_t *` (layout is internal) |
| `Vec` | pointer to a record `[tag][storage][len]`, the storage a runtime array | internal layout; avoid |
| `(ffi-pin v)`, a `(Pin a)` | pointer to an 8-byte slot holding `v`'s word | `int64_t *` |
| `Float` | the IEEE-754 binary64 value, in an SSE register | `double` |

**Floats cross, and the bits are the value.** A Zyl `Float` is its 64-bit pattern held in a general-purpose register (`movq rax, xmm0` after an arithmetic operation), so no floating-point arithmetic happens on the way out: the runtime moves the same 64 bits into the `xmm` register the ABI names for that argument, and reads a `double` result out of `xmm0`. Nothing is rounded, converted or re-encoded, which is why `inf`, `-0.0` and NaN survive a round trip unchanged.

```lisp
(capabilities ffi)
(use allocator/allocator)

(extern "strtod" (String) Float)
(extern "snprintf" (Ptr Int String Float) Int)

(print (ffi-call "strtod" "2.5" 1000))      ; 2.500000, read from xmm0

(let buf (bytebuf Heap 64)
  (let p (bytebuf-ptr buf)
    (begin
      (ffi-call "snprintf" p 64 "%.3f" -1.5 1000)
      (print (str-concat "" (alloc-cstr p))))))   ; -1.500, written from xmm0
```

Both are libc, so neither needs `-lm` (`fabs` and `sqrt` do, and the driver does not link it; see §22.10).

Which argument goes in which register is data, not assembly: the compiler reads the `extern` and emits the signature's class mask with the call, and the runtime's `ff-place` (`runtime/rt/ffitimed.zyl`) puts each word where the ABI wants it before `zyl_rt_callmix` (§22.7) loads the registers and calls. A signature with no `Float` in it has a mask of zero and takes the integer-only path, unchanged.

What does not work is a `Float` *inside* a type — `(extern "f" ((Pin Float)) Float)` and a `(Fn (Float) R)` callback parameter are both `E_TYPE_MISMATCH`:

```
error[E_TYPE_MISMATCH]: the extern declaration of `f` uses the type (Pin Float), and a Float crosses on its own but not inside a type
```

An aggregate is classified eightbyte by eightbyte, and the compiler does not compute that class. Pass a struct with a `Float` field as a pointer (§22.8), or convert to an integer word at the C side.

The layouts of structs, ADTs and `Vec` are implementation details of the current code generator, not part of any specification. Do not write C that depends on them.

**Results.** The result is the raw `rax` word, or `xmm0` for a `Float`, typed by the `extern`. A function returning `char *` that points at a NUL-terminated string can be declared to return `String`:

```lisp
(extern "getenv" (String) String)

(print (str-concat "HOME=" (ffi-call "getenv" "HOME" 1000)))   ; HOME=/home/larry
```

A function that returns a buffer or a pointer that is not a string returns `Ptr`; `alloc-cstr` (`allocator/allocator`) reads the NUL-terminated bytes at a `Ptr` as a `String`. A `String` declared this way is C's memory, not a copy: if C may free or reuse it, copy it first with `(str-concat "" s)`.

### Calling convention

- **System V AMD64**: the first six *integer-class* arguments go in `rdi`, `rsi`, `rdx`, `rcx`, `r8` and `r9`, the first eight *SSE-class* ones in `xmm0`..`xmm7`, and the rest on the stack in argument order. Compiled code handles more than six arguments of either class: a 9-argument C function works, and so does one taking 12 doubles.
- The stack is 16-byte aligned at the call.
- `al`, the count of vector registers used, is set when the signature has a `Float` in it, which is what a variadic callee reads to decide whether to spill the SSE registers — so `printf("%.1f", x)` works. An integer-only call does not set it: calling `printf` with integer arguments works because `al` is harmless there, not because it was set.
- **The interpreter (`zyl eval`, the REPL)** looks symbols up with `dlsym` and makes the call through the same timed bridge as compiled code (`zyl_ffi_timed_argv`), so timeouts are enforced there too. A symbol it cannot find is `E_FFI_SYMBOL_NOT_FOUND`.

## 22.6 Complete FFI Example

The supported way to ship C code with Zyl is a package with a `native` block (§31.10, and Chapter 25). `zyl build` compiles the C sources and links them into the binary.

### C code (`c/mathlib.c`)

```c
#include <stdint.h>
#include <string.h>

int64_t ml_factorial(int64_t n) {
    return n <= 1 ? 1 : n * ml_factorial(n - 1);
}

int64_t ml_count_char(const char *s, int64_t c) {
    int64_t k = 0;
    for (; *s; s++) if (*s == (char)c) k++;
    return k;
}

/* A double in, a double out: the SSE half of the sequence (§22.5). */
double ml_hypot2(double a, double b) { return a * a + b * b; }

/* Reverse `src` into the caller's buffer `dst` of `cap` bytes. */
int64_t ml_reverse(const char *src, char *dst, int64_t cap) {
    int64_t len = (int64_t)strlen(src);
    if (len >= cap) len = cap - 1;
    for (int64_t i = 0; i < len; i++) dst[i] = src[len - 1 - i];
    dst[len] = '\0';
    return len;
}

/* Receives the address of a pinned slot, not the value. */
int64_t ml_deref(const int64_t *slot) { return *slot * 2; }
```

### Manifest (`zyl.pkg`)

```lisp
(package
  (name "demo/mathlib") (version "0.1.0")
  (zyl "5.0") (edition "2026")
  (capabilities ffi native)
  (native (sources "c/mathlib.c") (cflags "-O2" "-std=c11")))
```

### Zyl code (`mathlib.zyl`)

The `ffi` and `native` grants come from the package's `zyl.pkg` above, not
from a line in this file: in a manifested package the grant belongs to the
manifest, and writing `(capabilities ...)` in a module of one is an error.

```lisp
(use allocator/allocator)

(extern "ml_factorial" (Int) Int)
(extern "ml_count_char" (String Int) Int)
(extern "ml_hypot2" (Float Float) Float)
(extern "ml_reverse" (String Ptr Int) Int)
(extern "ml_deref" ((Pin Int)) Int)
(extern "getenv" (String) String)

(defn factorial (n) (ffi-call "ml_factorial" n 1000))

(defn count-char (s c) (ffi-call "ml_count_char" s c 1000))

(defn hypot-squared (a b) (ffi-call "ml_hypot2" a b 1000))

(defn reverse-string ((s String))
  (let buf (bytebuf Heap 256)
    (let p (bytebuf-ptr buf)
      (let _ (ffi-call "ml_reverse" s p 256 1000)
        ; Copy out while the buffer is alive; there is no free to call,
        ; because a region owns this storage.
        (str-concat "" (alloc-cstr p))))))

(defn main ()
  (begin
    (print (factorial 10))
    (print (count-char "mississippi" 115))
    (print (hypot-squared 3.0 4.0))
    (print (str-concat "reversed: " (reverse-string "hello")))
    (print (ffi-call "ml_deref" (ffi-pin 21) 1000))
    (print (str-concat "HOME=" (ffi-call "getenv" "HOME" 1000)))
    0))
```

### Build and run

```bash
$ zyl new demo/mathlib     # then add c/mathlib.c and edit the two files above
$ cd mathlib && zyl build && ./mathlib
3628800
4
25.0
reversed: olleh
42
HOME=/home/larry
```

`bytebuf-ptr` returns a `Ptr`, so `ml_reverse` is declared to take one for `dst`. `(alloc-cstr p)` reads the buffer as a `String` without copying it, and `(str-concat "" ...)` copies it into a fresh Zyl string while the buffer is still alive. Nothing is freed by hand: the buffer is a `(bytebuf Heap 256)`, so the region that owns it reclaims it when the frame returns.

## 22.7 Timeout Enforcement

Spec §16 and §28 describe a timeout on every foreign call, with `E_FFI_TIMEOUT` raised when a call exceeds it.

The implementation enforces it. ICNF lowering (`ic-ffi`) turns a call of a foreign symbol into a call of the runtime's bridge:

```
IFfi "zyl_ffi_timed" (ISymAddr sym, IStr sym, IConst timeout-ms, IConst request, arg...)
```

`request` is the argument count in its low byte and the signature's ABI class mask above it: bit 8+i set when argument i is a `Float`, bit 24 when the result is one. One word rather than two, because it is what the compiler emits and what the interpreter forwards unchanged, so the two cannot disagree about a signature. A signature with no `Float` in it masks to zero, and `request` is then exactly the argument count it always was.

`zyl_ffi_timed` (`runtime/rt/ffitimed.zyl`) runs the C function on a worker thread that belongs to the calling thread. The worker is created on first use and kept, so thread-local C state such as `errno` stays consistent between calls. The caller waits on `CLOCK_MONOTONIC`; if the function has not returned by the deadline, the caller raises:

```
E_FFI_TIMEOUT: ffi call `usleep` exceeded its timeout of 50 ms
```

This is an ordinary panic: `try`/`catch` catches it, and `recover` (or `zyl_err_is`) matches it by code.

```lisp
(capabilities ffi)

(extern "usleep" (Int) Int)
(extern "abs" (Int) Int)

(defn slow-call () (ffi-call "usleep" 300000 50))   ; 300 ms against 50 ms

(defn main ()
  (begin
    (print (try (slow-call) (catch e 0)))            ; 0
    (print (ffi-call "abs" -9 1000))                 ; 9: the next call works normally
    0))
```

**The C function is abandoned, not killed.** Stopping a running C function safely is impossible in general (it may hold a lock or be halfway through a write), so its worker is left to finish on its own and then frees itself; the caller gets a fresh worker for its next call. Nothing the abandoned call was handed is reclaimed: Pin slots are never freed individually, and once any call has been abandoned, the arena teardown at process exit is skipped. A C function that never returns therefore leaks one thread, but no longer hangs the caller.

**Determinism.** Whether a timeout fires depends on how long foreign code runs. Spec §27 treats FFI results as observable external input, and a timeout is one of them, just like a value the C function returns.

**Trusted runtime symbols.** Symbols beginning with `zyl_` belong to the Zyl runtime. They are called directly, without a worker thread; their timeout must still be a positive literal but is not used. Their types come from the compiler's signature table (§22.2).

**Callbacks** from C into Zyl run on the worker thread (§22.9).

## 22.8 Memory Management Across the FFI

### Zyl to C

Strings are passed by pointer to their bytes. C may read them but must not keep the pointer beyond the call, and must not write through it.

### C writes into Zyl-owned memory

Allocate a buffer, pass the pointer, copy the result out, and free the buffer. This is the pattern `reverse-string` uses above:

```lisp
(capabilities ffi)
(use allocator/allocator)

(extern "c_fill_buffer" (Ptr Int) Int)

(let buf (bytebuf Heap 1024)
  (let p (bytebuf-ptr buf)
    (let _ (ffi-call "c_fill_buffer" p 1024 1000)
      (str-concat "" (alloc-cstr p)))))   ; copy out as a Zyl string
```

The buffer is a `(bytebuf Heap N)` and `bytebuf-ptr` gives its address, so no allocation call appears here at all -- which is the point: `alloc-malloc` and `alloc-free` are `E_FFI_RESTRICTED`, because their results are words no type follows. `alloc-cstr` (which reads bytes at an address) does come from `allocator/allocator`, which must be `use`d.

### C allocates, Zyl frees

```lisp
(capabilities ffi)

(extern "strdup" (String) String)
(extern "free" (String) Unit)

(defn c-owned-string ()
  (let p (ffi-call "strdup" "copied by C" 1000)
    (let s (str-concat "" p)        ; copy into Zyl memory
      (let _ (ffi-call "free" p 1000)
        s))))
```

Pass the returned pointer itself to `free`. `(ffi-pin p)` would be the address of a slot holding `p`; it is a `(Pin String)`, so the `extern` rejects it with `E_TYPE_MISMATCH`.

## 22.9 Callbacks (C to Zyl)

A top-level function named as an `ffi-call` argument is passed as its code address, so C can call it back with integer and pointer arguments. The `extern` gives the callback parameter a function type, `(Fn (A ...) R)`:

```lisp
(extern "qsort" (Ptr Int Int (Fn (Ptr Ptr) Int)) Unit)
```

`(ffi-call "qsort" p 64 8 compare 1000)` then sorts with a Zyl comparator `compare` whose two parameters are `Ptr`s, read with `alloc-read-int` (`tests/regression/c-abi.zyl`). The callback runs on the FFI worker thread that is running the foreign call (§22.7). It runs as the calling actor, owning the same channel endpoints, but a panic inside it that no `try` within the callback catches ends the process, since it cannot unwind into the caller, which is waiting on another thread. Closures are rejected as FFI arguments (§22.4).

When C needs to deliver events without calling back, have Zyl poll a C function that returns an integer code:

```lisp
(capabilities ffi)

(extern "c_poll_event" () Int)

(defn poll-loop (n)
  (let ev (ffi-call "c_poll_event" 1000)   ; returns 0 when idle
    (if (= ev 0)
      n
      (begin
        (handle-event ev)
        (poll-loop (+ n 1))))))
```

## 22.10 Linking

A program that calls foreign code links over libc's C runtime, so the
link reaches libc, libpthread and the runtime's own `zyl_*` symbols:

```bash
cc -no-pie prog.s rt.o -o prog -lpthread
```

`rt.o` is the Zyl runtime (`runtime/rt/`), which `./boot.sh` assembles
from the committed seed `build/boot/rt.s` and `install.sh` copies. A
program with no foreign `ffi-call` and no native objects takes the other
path: the compiler assembles and links it itself, against the cached
`rt.zo`, with no `cc`, `as` or `ld` and no libc at all (Chapter 26).

Besides `-o <file>` and `--emit-asm`, the command line accepts only
`--contracts=P` and `--error-format=json`: there is no way to add object
files, libraries or `-lm`, and any other word after the source file is
taken as the output path. A symbol that is not found is an ordinary
linker error, `undefined reference to 'name'`.

Two ways to link your own C:

1. **A package `native` block** (§22.6). `zyl build` compiles each source with `cc -c` into `build/native/`, checking the flags against the allowlist, and appends the objects and `(link-libs ...)` to the link. Only the **root** package's native block is built; a dependency's native sources are not linked yet.
2. **By hand.** Emit the assembly and link it yourself:

   ```bash
   zyl prog.zyl --emit-asm -o prog.s
   cc -no-pie prog.s ~/.zyl/rt.o mylib.c -o prog -lpthread -lm
   ```

   The runtime is `rt.o`, found in the install (`~/.zyl`) or next to the compiler (`build/boot/`). The `-no-pie` flag is required.

## 22.11 Capabilities

A foreign `ffi-call`, `ffi-pin`, `ffi-unpin`, and any call into `stdlib/ffi`, require the `ffi` capability (§31.9). Shipping C sources requires `native` as well. In a package the grant is a line of `zyl.pkg`:

```
error[E_PKG_CAPABILITY_VIOLATION]: `ml_factorial` needs the ffi capability, and package demo/mathlib declares only native
  --> mathlib.zyl:9:21
   |
 9 | (defn factorial (n) (ffi-call "ml_factorial" n 1000))
   |                     ^
   = note: a program names what it may do, so a reader sees it at the top
   = help: add `(capabilities native ffi)` to zyl.pkg
```

A lone file declares the grant itself with a top-level `(capabilities ffi)`; without it the file may not call foreign code:

```
error[E_PKG_CAPABILITY_VIOLATION]: `system` needs the ffi capability, and this file declares none
  --> run.zyl:3:5
   |
 3 |     (ffi-call "system" "ls" 1000)
   |     ^
   = note: a program names what it may do, so a reader sees it at the top
   = help: add `(capabilities ffi)` at the top of the file
```

An `ffi-call` of a `zyl_*` runtime entry is the language's own and needs no grant. A root package can forbid FFI for its whole graph with `(deny-capabilities ffi native)`; see Chapter 25, §25.11.

## 22.12 Safety: What Holds Today

| Property | Status |
|----------|--------|
| Only pinnable types cross the boundary | partial: `extern` types every argument, and inline closures, pinned functions and a `Float` inside a type are rejected (§22.4) |
| A `Float` crosses as the ABI says | holds: an SSE register for the argument, `xmm0` for the result, and the bits are the IEEE-754 value (§22.5) |
| Pinned memory does not move | holds: nothing in Zyl moves memory |
| Pinned memory stays alive during the call | holds: pins are never freed before exit |
| Calls are bounded by a timeout | holds for foreign symbols: an overrunning call raises `E_FFI_TIMEOUT` and is abandoned (§22.7) |
| C cannot corrupt Zyl memory (G5) | **not enforced**: C runs unrestricted in the process |
| Symbol names cannot inject assembly | holds: names are sanitised |
| FFI use is declared | holds for packages (in `zyl.pkg`) and lone files (a top-level `(capabilities ffi)`) (§22.11); a lone file that declares nothing has no `ffi` |
| Correct argument types | checked against the `extern` declaration (§22.2); the declaration itself is trusted, not compared with the C prototype |
| Floats | a bare `Float` crosses in an SSE register (§22.5); inside a type it is `E_TYPE_MISMATCH` |

## 22.13 Errors

| Error | When |
|-------|------|
| `E_CANNOT_INFER` | `ffi-call` to a foreign symbol with no `extern`, or to a `zyl_` symbol with no signature |
| `E_TYPE_MISMATCH` | an argument or result that does not match the `extern`; a type variable, or a `Float` inside a type, in an `extern` |
| `E_FFI_RESTRICTED` | a raw runtime entry reserved to the standard library, or an `extern` for a runtime entry |
| `E_MALFORMED_FORM` | an `extern` that is not `(extern "sym" (T ...) R)` |
| `E_FFI_TYPE_NOT_PINNABLE` | a function passed to `ffi-pin` |
| `E_INVALID_CAPABILITY` | an inline closure passed to `ffi-call` |
| `E_FFI_PIN_REQUIRED` | a `Secret` passed to `ffi-call` without `ffi-pin` |
| `E_PKG_CAPABILITY_VIOLATION` | FFI used in a file or package that does not declare `ffi`, or denied by the root |
| `E_FFI_SYMBOL_NOT_FOUND` | interpreter only (`zyl eval`, the REPL): symbol not found by `dlsym` |
| `E_FFI_SYMBOL_REQUIRED` | the symbol is not a string literal |
| `E_FFI_TIMEOUT_REQUIRED` | the last argument is missing or not a positive integer literal |
| `E_ARITY_MISMATCH` | more than 16 arguments |
| `E_FFI_TIMEOUT` | at run time: a foreign call did not return within its timeout |
| linker `undefined reference` | compiled code calls a symbol that is not linked |

`(ffi-call)` and an unquoted symbol name are rejected with `E_FFI_SYMBOL_REQUIRED`.

## 22.14 Best Practices

1. **Declare every foreign function with `extern`** next to one Zyl wrapper for it, so the word-level interface lives in one place.
2. **Write a realistic timeout** as the last argument, as a literal. A missing one is a compile error; a too-tight one abandons the C call with `E_FFI_TIMEOUT`.
3. **Pass integers, strings and floats directly.** Use `ffi-pin` only when C expects a pointer to a value, and declare that parameter `(Pin a)`.
4. **Declare C's `double` as `Float`.** It crosses in an SSE register with its bits intact (§22.5). A `Float` *inside* a type — a pinned slot's pointee, a callback parameter, a struct field — does not cross; pass a pointer, or convert at the C side.
5. **Copy C-owned data into Zyl strings** with `str-concat` before freeing it.
6. **Declare `ffi` and `native` in `zyl.pkg`**, and check `zyl audit` to see which dependencies use them.
7. **Test the C side with sanitizers** (ASan, UBSan). Nothing on the Zyl side can protect you from a C bug.
