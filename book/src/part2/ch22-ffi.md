# Chapter 22: FFI Safety and Pinning

Complete reference for Zyl's Foreign Function Interface: `ffi-call`, `extern` declarations, pinning, FFI-pinnable types, how values are represented on the C side, linking C code, and which of the specification's safety rules the compiler enforces today.

The normative text is spec v5.0 §16 (FFI model), §9.1 rules R4 and R8, §13.4 (Pin region), §31.9 (the `ffi` capability) and §31.10 (native dependencies). The implementation lives in `stdlib/compiler/icnf.zyl` (lowering), `stdlib/compiler/codegen.zyl` (the call itself), `stdlib/compiler/type_system.zyl` (`is-ffi-pinnable`), `stdlib/compiler/capability_check.zyl`, `stdlib/compiler/arity_check.zyl` (`ffi-check-call`), and `runtime/actor_runtime.c` (`ffi_pin`, `ffi_unpin`, `zyl_ffi_timed`). This chapter describes both, and says plainly where they differ: the FFI is one of the areas where the implementation lags furthest behind the specification.

## 22.1 FFI Overview

The specification's model (§16, R4, R8) is:

- **Pin region**: values cross the boundary through a non-moving arena.
- **Timeout**: every foreign call carries a maximum execution time.
- **Type restriction**: only FFI-pinnable types may cross.

What the compiler does today:

- Every foreign function is declared with `extern`, which gives its C signature; the type pass checks each `ffi-call` against it (§22.2). The runtime's own `zyl_*` functions are typed by the compiler's signature table, and an `extern` for one is `E_FFI_RESTRICTED`.
- `ffi-call` compiles to a System V call of the named C symbol, passing every argument as a 64-bit word in the integer registers. A foreign symbol is called on a worker thread through the runtime's timed bridge; the runtime's own `zyl_*` symbols are called directly.
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
PANIC: error[E_FFI_TIMEOUT_REQUIRED]: the last argument of ffi-call must be a positive integer literal timeout
  --> magnitude.zyl:1:21
   |
 1 | (defn magnitude (n) (ffi-call "abs" n))
   |                     ^
   = help: end the call with a timeout in milliseconds, e.g. 1000; a missing timeout would otherwise drop the real last argument
```

`(ffi-call "abs" -42)` and `(ffi-call "abs" -42 0)` are rejected the same way, since neither ends with a positive timeout. A call with more than 16 arguments is `E_ARITY_MISMATCH`.

The result is whatever the function left in `rax`, as a 64-bit word (§22.5), with the type its `extern` declares.

### Declaring a foreign function: `extern`

```
extern ::= "(" "extern" String "(" Type* ")" Type ")"
```

```lisp
(extern "strlen" (String) Int)
(extern "free" (String) Unit)
(extern "qsort" (Ptr Int Int (Fn (Ptr Ptr) Int)) Unit)
```

An `extern` names a C symbol, the types of its parameters and its result type. It must appear before any `ffi-call` to that symbol. The type pass then checks each call like a call of a Zyl function: the arguments unify with the parameter types (`E_TYPE_MISMATCH` otherwise, or when the count differs), and the call has the result type. The form itself evaluates to Unit.

A call to a foreign symbol with no `extern` is rejected:

```
error[E_CANNOT_INFER]: no type for ffi-call to `abs`, which has no (extern ...) declaration
```

The types must be concrete and must fit in one machine word:

- `Int`, `Bool`, `String`, `Unit` (for a `void` result), declared ADTs and structs (passed as a pointer), and the runtime's handle types: `Ptr` (an opaque address, as `alloc-malloc` returns, that Zyl code can only pass back to C or to the `alloc-` functions), `Arena`, `Fd` and the rest listed in `stdlib/compiler/ffi_sigs.zyl`.
- `(Fn (A ...) R)` is a C function pointer: a top-level Zyl function passed as a callback (§22.9), whose parameters take the types `A ...`.
- No `Float`: the timed bridge passes every argument in an integer register (§22.5).
- No type variables: `(extern "abs" (a) b)` would let any value become any other, so it is `E_TYPE_MISMATCH`. There is no unsafe cast form in Zyl, and `extern` is not one.

These checks run when a call to the symbol is typed, so an `extern` that no call uses is not checked. A program has one `extern` per symbol; a later one for the same symbol replaces the earlier.

The `extern` is a promise about C, not a check of it. Nothing compares it with the C prototype, so declaring `(extern "strlen" (Int) Int)` compiles and passes an integer where C reads a pointer. Declare what the C code actually takes.

The `zyl_*` runtime functions need no `extern`: the compiler has a signature for each one it expects programs to call (`stdlib/compiler/ffi_sigs.zyl`), such as `-> Unit` for `zyl_actor_wait_all`. An `extern` is only for foreign code: declaring one for a symbol the runtime exports is `E_FFI_RESTRICTED` ("`zyl_actor_wait_all` is a runtime entry; its type comes from the compiler's signature table, not from an extern"), whatever type it gives. A runtime export with no entry in the table, such as `zyl_actor_send_closure`, is `E_CANNOT_INFER` ("no type for untyped ffi result"), and cannot be called from a program at all. A few raw entries that would turn any word into any type, such as `zyl_cstr_of_word`, are reserved to the standard library: naming one in a user program is `E_FFI_RESTRICTED`.

## 22.3 Pinning

### ffi-pin

```lisp
(ffi-pin value)
```

Spec §16: `ffi-pin` copies the value to the Pin region (a non-moving arena) and returns a stable pointer. Pin lifetime is tied to the FFI call scope unless the program manages it manually.

Implementation (`ffi_pin`, `actor_runtime.c`): `ffi-pin` allocates one 8-byte slot in the process-wide Pin arena, stores the value's word in it, and returns the slot. When `value` has type `a`, `(ffi-pin value)` has type `(Pin a)`. The C function therefore receives a **pointer to the value**, not the value, and the `extern` parameter that takes it is declared `(Pin a)`:

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

It frees nothing, so the same slot can be read more than once. A pointer that did not come from the Pin arena prints `zyl: ffi-unpin: pointer not from ffi-pin/Pin arena` to stderr, and the result is 0. A buffer of more than one word does not fit in a slot; allocate it with `alloc-malloc` or `arena-alloc-zeroed`, a `Ptr` (§22.8).

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

```
error[E_FFI_TYPE_NOT_PINNABLE]: a function cannot be pinned: FFI_Pinnable types are Int, Float, Bool, String and data built from them
PANIC: E_INVALID_CAPABILITY: ffi-call argument is a closure, which is not FFI_Pinnable (Int/Float/Bool/String/composed only) -- pin its result data explicitly instead of passing the closure itself
```

Passing raw `Int` and `String` values directly, as in §22.2, is the idiom the standard library and the compiler itself use throughout. Rule R4 is not enforced.

## 22.5 How Values Look to C

Every argument travels as one 64-bit word in an integer register, and the result is read back from `rax`. There is no `zyl_ffi.h` header and there are no `ZylVec`/`ZylString` typedefs: declare the C side yourself with 64-bit integer and pointer types.

| Zyl value | What C receives | Declare as |
|-----------|-----------------|------------|
| `Int` | the integer | `int64_t` / `long long` |
| `Bool` | 1 or 0, as a 64-bit word | `int64_t` |
| `String` | pointer to NUL-terminated UTF-8 bytes | `const char *` |
| a buffer from `alloc-malloc` | the raw pointer, a `Ptr` | `char *` / `void *` |
| struct / ADT value | pointer to a heap record `[tag][field0][field1]...` | `const int64_t *` (layout is internal) |
| `Vec` | pointer to a heap record `[tag][data][len][cap][arena]` | internal layout; avoid |
| `(ffi-pin v)`, a `(Pin a)` | pointer to an 8-byte slot holding `v`'s word | `int64_t *` |
| `Float` | the IEEE-754 bits **in an integer register** | see below |

**Floats do not cross the FFI.** The compiler never loads `xmm` registers for arguments and never reads `xmm0` for a result, so an `extern` that mentions `Float` is rejected at the first call:

```
error[E_TYPE_MISMATCH]: the extern declaration of `fabs` uses the type Float, which cannot cross the C boundary
```

For floating-point work, keep it in Zyl, or pass integers (for example, fixed-point values).

The layouts of structs, ADTs and `Vec` are implementation details of the current code generator, not part of any specification. Do not write C that depends on them.

**Results.** The result is the raw `rax` word, typed by the `extern`. A function returning `char *` that points at a NUL-terminated string can be declared to return `String`:

```lisp
(extern "getenv" (String) String)

(print (str-concat "HOME=" (ffi-call "getenv" "HOME" 1000)))   ; HOME=/home/larry
```

A function that returns a buffer or a pointer that is not a string returns `Ptr`; `alloc-cstr` (`allocator/allocator`) reads the NUL-terminated bytes at a `Ptr` as a `String`. A `String` declared this way is C's memory, not a copy: if C may free or reuse it, copy it first with `(str-concat "" s)`.

### Calling convention

- **System V AMD64**: the first six arguments go in `rdi`, `rsi`, `rdx`, `rcx`, `r8` and `r9`, and the rest go on the stack. Compiled code handles more than six arguments; an 8-argument C function works.
- The stack is 16-byte aligned at the call.
- `al` is not set for variadic functions. Calling `printf` with integer arguments happens to work; with floats it does not.
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

```lisp
(use allocator/allocator)

(extern "ml_factorial" (Int) Int)
(extern "ml_count_char" (String Int) Int)
(extern "ml_reverse" (String Ptr Int) Int)
(extern "ml_deref" ((Pin Int)) Int)
(extern "getenv" (String) String)

(defn factorial (n) (ffi-call "ml_factorial" n 1000))

(defn count-char (s c) (ffi-call "ml_count_char" s c 1000))

(defn reverse-string (s)
  (let buf (alloc-malloc 256)
    (let _ (ffi-call "ml_reverse" s buf 256 1000)
      (let out (str-concat "" (alloc-cstr buf))
        (let _ (alloc-free buf)
          out)))))

(defn main ()
  (begin
    (print (factorial 10))
    (print (count-char "mississippi" 115))
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
reversed: olleh
42
HOME=/home/larry
```

`alloc-malloc` returns a `Ptr`, so `ml_reverse` is declared to take one for `dst`. `(alloc-cstr buf)` reads the buffer as a `String` without copying it, and `(str-concat "" ...)` copies it into a fresh Zyl string before the buffer is freed.

## 22.7 Timeout Enforcement

Spec §16 and §28 describe a timeout on every foreign call, with `E_FFI_TIMEOUT` raised when a call exceeds it.

The implementation enforces it. ICNF lowering (`ic-ffi`) turns a call of a foreign symbol into a call of the runtime's bridge:

```
IFfi "zyl_ffi_timed" (ISymAddr sym, IStr sym, IConst timeout-ms, IConst argc, arg...)
```

`zyl_ffi_timed` (`runtime/actor_runtime.c`) runs the C function on a worker thread that belongs to the calling thread. The worker is created on first use and kept, so thread-local C state such as `errno` stays consistent between calls. The caller waits on `CLOCK_MONOTONIC`; if the function has not returned by the deadline, the caller raises:

```
E_FFI_TIMEOUT: ffi call `usleep` exceeded its timeout of 50 ms
```

This is an ordinary panic: `try`/`catch` catches it, and `recover` (or `zyl_err_is`) matches it by code.

```lisp
(extern "usleep" (Int) Int)
(extern "abs" (Int) Int)

(defn slow-call () (ffi-call "usleep" 300000 50))   ; 300 ms against 50 ms

(print (try (slow-call) (catch e 0)))               ; 0
(print (ffi-call "abs" -9 1000))                    ; 9: the next call works normally
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
(use allocator/allocator)

(extern "c_fill_buffer" (Ptr Int) Int)

(let buf (alloc-malloc 1024)
  (let _ (ffi-call "c_fill_buffer" buf 1024 1000)
    (let data (str-concat "" (alloc-cstr buf))   ; copy out as a Zyl string
      (let _ (alloc-free buf)
        data))))
```

`alloc-malloc` and `alloc-free` wrap `malloc` and `free`, and take and return `Ptr`. They come from `allocator/allocator`, which must be `use`d, as does `alloc-cstr`.

### C allocates, Zyl frees

```lisp
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

`(ffi-call "qsort" p 64 8 compare 1000)` then sorts with a Zyl comparator `compare` whose two parameters are `Ptr`s, read with `alloc-read-int` (`tests/regression/c-abi.zyl`). The callback runs on the FFI worker thread that is running the foreign call (§22.7). It sees the caller's `actor-self`, but a panic inside it that no `try` within the callback catches ends the process, since it cannot unwind into the caller, which is waiting on another thread. Closures are rejected as FFI arguments (§22.4).

When C needs to deliver events without calling back, have Zyl poll a C function that returns an integer code:

```lisp
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

A single-file compile always links with the same command:

```bash
cc -no-pie prog.s actor_runtime.c -o prog -lpthread
```

It reaches libc, libpthread and the runtime's own `zyl_*` symbols. The command line accepts only `-o <file>` and `--emit-asm`: there is no way to add object files, libraries or `-lm`, and any other word after the source file is taken as the output path. A symbol that is not found is an ordinary linker error, `undefined reference to 'name'`.

Two ways to link your own C:

1. **A package `native` block** (§22.6). `zyl build` compiles each source with `cc -c` into `build/native/`, checking the flags against the allowlist, and appends the objects and `(link-libs ...)` to the link. Only the **root** package's native block is built; a dependency's native sources are not linked yet.
2. **By hand.** Emit the assembly and link it yourself:

   ```bash
   zyl prog.zyl --emit-asm -o prog.s
   cc -no-pie prog.s ~/.zyl/actor_runtime.c mylib.c -o prog -lpthread -lm
   ```

   The runtime is linked from source, `actor_runtime.c`, found in the install (`~/.zyl`) or next to the compiler (`build/boot/`). The `-no-pie` flag is required.

## 22.11 Capabilities

In a package with a `zyl.pkg`, `ffi-call`, `ffi-pin`, `ffi-unpin`, and any call into `stdlib/ffi`, require the `ffi` capability (§31.9). Shipping C sources requires `native` as well:

```
PANIC: error[E_PKG_CAPABILITY_VIOLATION]: package me/mathy uses ffi in my-abs without declaring it in zyl.pkg
```

A root package can forbid FFI for its whole graph with `(deny-capabilities ffi native)`. A lone file compiled without a manifest is not checked. The current pass also skips the bodies of `main` and of top-level `test` forms, so an `ffi-call` placed directly in `main` is not caught; see Chapter 25, §25.11.

## 22.12 Safety: What Holds Today

| Property | Status |
|----------|--------|
| Only pinnable types cross the boundary | partial: `extern` types every argument, and inline closures and pinned functions are rejected (§22.4) |
| Pinned memory does not move | holds: nothing in Zyl moves memory |
| Pinned memory stays alive during the call | holds: pins are never freed before exit |
| Calls are bounded by a timeout | holds for foreign symbols: an overrunning call raises `E_FFI_TIMEOUT` and is abandoned (§22.7) |
| C cannot corrupt Zyl memory (G5) | **not enforced**: C runs unrestricted in the process |
| Symbol names cannot inject assembly | holds: names are sanitised |
| FFI use is declared per package | holds for `defn`/`def` bodies in manifest-bearing packages (§22.11) |
| Correct argument types | checked against the `extern` declaration (§22.2); the declaration itself is trusted, not compared with the C prototype |
| Floats | rejected in `extern` types |

## 22.13 Errors

| Error | When |
|-------|------|
| `E_CANNOT_INFER` | `ffi-call` to a foreign symbol with no `extern`, or to a `zyl_` symbol with no signature |
| `E_TYPE_MISMATCH` | an argument or result that does not match the `extern`; a `Float` or type variable in an `extern` |
| `E_FFI_RESTRICTED` | a raw runtime entry reserved to the standard library, or an `extern` for a runtime entry |
| `E_MALFORMED_FORM` | an `extern` that is not `(extern "sym" (T ...) R)` |
| `E_FFI_TYPE_NOT_PINNABLE` | a function passed to `ffi-pin` |
| `E_INVALID_CAPABILITY` | an inline closure passed to `ffi-call` |
| `E_FFI_PIN_REQUIRED` | a `Secret` passed to `ffi-call` without `ffi-pin` |
| `E_PKG_CAPABILITY_VIOLATION` | FFI used in a package that does not declare `ffi`, or denied by the root |
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
3. **Pass integers and strings directly.** Use `ffi-pin` only when C expects a pointer to a value, and declare that parameter `(Pin a)`.
4. **Keep floating point on the Zyl side**; `extern` rejects `Float`.
5. **Copy C-owned data into Zyl strings** with `str-concat` before freeing it.
6. **Declare `ffi` and `native` in `zyl.pkg`**, and check `zyl audit` to see which dependencies use them.
7. **Test the C side with sanitizers** (ASan, UBSan). Nothing on the Zyl side can protect you from a C bug.
