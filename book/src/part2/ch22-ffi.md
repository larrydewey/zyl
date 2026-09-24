# Chapter 22: FFI Safety and Pinning

Complete reference for Zyl's Foreign Function Interface: `ffi-call`, pinning, FFI-pinnable types, how values are represented on the C side, linking C code, and which of the specification's safety rules the compiler enforces today.

The normative text is spec v5.0 §16 (FFI model), §9.1 rules R4 and R8, §13.4 (Pin region), §31.9 (the `ffi` capability) and §31.10 (native dependencies). The implementation lives in `stdlib/compiler/icnf.zyl` (lowering), `stdlib/compiler/codegen.zyl` (the call itself), `stdlib/compiler/type_system.zyl` (`is-ffi-pinnable`), `stdlib/compiler/capability_check.zyl`, and `runtime/actor_runtime.c` (`ffi_pin`, `ffi_unpin`). This chapter describes both, and says plainly where they differ: the FFI is one of the areas where the implementation lags furthest behind the specification.

## 22.1 FFI Overview

The specification's model (§16, R4, R8) is:

- **Pin region**: values cross the boundary through a non-moving arena.
- **Timeout**: every foreign call carries a maximum execution time.
- **Type restriction**: only FFI-pinnable types may cross.

What the compiler does today:

- `ffi-call` compiles to a direct System V `call` of the named C symbol, passing every argument as a 64-bit word in the integer registers.
- `ffi-pin` copies one word into the Pin arena and returns the address of the copy.
- The timeout argument is required by the syntax but **not enforced** (§22.7).
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
- `timeout-ms`: the last argument, the timeout in milliseconds.

```lisp
(defn main ()
  (begin
    (print (ffi-call "abs" -42 1000))        ; 42
    (print (ffi-call "strlen" "hello" 1000)) ; 5
    (ffi-call "puts" "from puts" 1000)       ; prints: from puts
    0))
```

**The last argument is always treated as the timeout and discarded, whatever it is.** Nothing checks that it is present or that it is an integer. If you forget it, your real last argument is silently dropped: `(ffi-call "abs" -42)` calls `abs` with an uninitialised register and prints garbage. The compiler's own source passes 0 or 1000 by convention. Always write the timeout.

The result is whatever the function left in `rax`, as a 64-bit word (§22.5).

## 22.3 Pinning

### ffi-pin

```lisp
(ffi-pin value)
```

Spec §16: `ffi-pin` copies the value to the Pin region (a non-moving arena) and returns a stable pointer. Pin lifetime is tied to the FFI call scope unless the program manages it manually.

Implementation (`ffi_pin`, `actor_runtime.c`): `ffi-pin` allocates one 8-byte slot in the process-wide Pin arena, stores the value's word in it, and returns the slot's address. The C function therefore receives a **pointer to the value**, not the value:

| Pinned value | C receives |
|--------------|------------|
| `Int` 21 | `const int64_t *` pointing at 21 |
| `String` | `char **`: a pointer to the string pointer |
| a struct or ADT value | a pointer to the value's heap pointer |

```c
/* C side: reads through the pinned slot */
int64_t ml_deref(const int64_t *slot) { return *slot * 2; }
```

```lisp
(let slot (ffi-pin 21)
  (begin
    (print (ffi-call "ml_deref" slot 1000))  ; 42
    (print (ffi-unpin slot))))               ; 21
```

Passing `(ffi-pin "text")` to a function that expects `const char *`, such as `puts`, is a bug: it receives a `char **`.

### ffi-unpin

```lisp
(ffi-unpin pinned-pointer)
```

Spec §16: `ffi-unpin` explicitly frees pinned memory.

Implementation: `ffi-unpin` returns the word stored in the slot and frees nothing. It can be called on the same slot more than once. A pointer that did not come from the Pin arena prints `zyl: ffi-unpin: pointer not from ffi-pin/Pin arena` to stderr and yields 0.

### The Pin arena

- **Non-moving**: slots never move. Nothing in Zyl compacts memory.
- **Process-wide**: one arena, grown in 256 KiB blocks, destroyed at process exit.
- **Not freed per pin**: there is no reference counting and no scope-exit release. Every `ffi-pin` holds its slot until the process ends.

`stdlib/ffi/ffi.zyl` offers thin wrappers: `ffi-pin-value`, `ffi-unpin-value`, and `ffi-safe-call` / `ffi-pin-call-unpin`, which wrap an already-computed value in `Ok`. None of them add checking.

## 22.4 FFI-Pinnable Types

Spec §16: the FFI-pinnable types are `Int`, `Float`, `Bool`, `String`, `Vec<T>` where `T` is pinnable, and types composed solely of pinnable types. §9.1 R4 requires `ffi-call` arguments to be in the Pin region and of an FFI-pinnable type.

What the compiler checks (`is-ffi-pinnable`, `type_system.zyl`):

| Construct | Rejected | Error |
|-----------|----------|-------|
| `(ffi-pin e)` where `e` has a resolved TMut, TAtomic, TPin or TBox capability type, a function type, or a byte-buffer type | yes | `E_INVALID_CAPABILITY` |
| `(ffi-call "f" (fn (x) x) 1000)`, a closure written inline as an argument | yes | `E_INVALID_CAPABILITY` |
| a `Secret` passed to `ffi-call` without `ffi-pin` | yes | `E_FFI_PIN_REQUIRED` |
| a closure bound with `let` and then pinned or passed | **no** | none |
| a `let-mut` variable pinned or passed | **no** | none |
| an unpinned `Int` or `String` passed straight to `ffi-call` (R4) | **no** | none |
| a value whose type is still a type variable | **no** | none |

```
PANIC: E_INVALID_CAPABILITY: FFI value has type Fn which is not FFI_Pinnable
PANIC: E_INVALID_CAPABILITY: ffi-call argument is a closure, which is not FFI_Pinnable (Int/Float/Bool/String/composed only) -- pin its result data explicitly instead of passing the closure itself
```

Spec §28 does not define a dedicated pinnability code. The compiler's catalogue has `E_FFI_TYPE_NOT_PINNABLE`, but the checks emit `E_INVALID_CAPABILITY` instead.

Passing raw `Int` and `String` values directly, as in §22.2, is the idiom the standard library and the compiler itself use throughout. Rule R4 is not enforced.

## 22.5 How Values Look to C

Every argument travels as one 64-bit word in an integer register, and the result is read back from `rax`. There is no `zyl_ffi.h` header and there are no `ZylVec`/`ZylString` typedefs: declare the C side yourself with 64-bit integer and pointer types.

| Zyl value | What C receives | Declare as |
|-----------|-----------------|------------|
| `Int` | the integer | `int64_t` / `long long` |
| `Bool` | 1 or 0, as a 64-bit word | `int64_t` |
| `String` | pointer to NUL-terminated UTF-8 bytes | `const char *` |
| a buffer from `alloc-malloc` | the raw pointer, as an `Int` | `char *` / `void *` |
| struct / ADT value | pointer to a heap record `[tag][field0][field1]...` | `const int64_t *` (layout is internal) |
| `Vec` | pointer to a heap record `[tag][data][len][cap][arena]` | internal layout; avoid |
| `(ffi-pin v)` | pointer to an 8-byte slot holding `v`'s word | `const int64_t *` |
| `Float` | the IEEE-754 bits **in an integer register** | see below |

**Floats do not work across the FFI.** The compiler never loads `xmm` registers for arguments and never reads `xmm0` for a result. A C function declared `double f(double)` receives garbage and its result is lost: calling `sqrt`-style code with `2.0` returns `4611686018427387904`, the integer view of 2.0's bits. For floating-point work, keep it in Zyl, or pass integers (for example, fixed-point values).

The layouts of structs, ADTs and `Vec` are implementation details of the current code generator, not part of any specification. Do not write C that depends on them.

**Results.** The result is the raw `rax` word. To use a returned `char *` as a Zyl string, pass it through a string builtin:

```lisp
(print (str-concat "HOME=" (ffi-call "getenv" "HOME" 1000)))   ; HOME=/home/larry
```

`(print (ffi-call "getenv" "HOME" 1000))` prints the pointer as an integer. `print` treats an FFI result as an `Int`, except for a few runtime string functions that it recognises by name.

### Calling convention

- **System V AMD64**: the first six arguments go in `rdi`, `rsi`, `rdx`, `rcx`, `r8` and `r9`, and the rest go on the stack. Compiled code handles more than six arguments; an 8-argument C function works.
- The stack is 16-byte aligned at the call.
- `al` is not set for variadic functions. Calling `printf` with integer arguments happens to work; with floats it does not.
- **The interpreter (`zyl eval`, the REPL)** looks symbols up with `dlsym` and supports at most six arguments. A symbol it cannot find there is `E_FFI_SYMBOL_NOT_FOUND`.

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

(defn factorial (n) (ffi-call "ml_factorial" n 1000))

(defn count-char (s c) (ffi-call "ml_count_char" s c 1000))

(defn reverse-string (s)
  (let buf (alloc-malloc 256)
    (let _ (ffi-call "ml_reverse" s buf 256 1000)
      (let out (str-concat "" buf)
        (let _ (alloc-free buf)
          out)))))

(defn main ()
  (begin
    (print (factorial 10))
    (print (count-char "mississippi" 115))
    (print (str-concat "reversed: " (reverse-string "hello")))
    (let slot (ffi-pin 21)
      (begin
        (print (ffi-call "ml_deref" slot 1000))
        (print (ffi-unpin slot))))
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
21
HOME=/home/larry
```

`(str-concat "" buf)` copies the C-filled buffer into a fresh Zyl string before the buffer is freed.

## 22.7 Timeout Enforcement

Spec §16 and §28 describe a timeout on every foreign call, with `E_FFI_TIMEOUT` raised when a call exceeds it.

**The implementation does not enforce timeouts.** The argument is discarded at lowering (§22.2). The runtime has no alarm, signal or watchdog for foreign calls, and `E_FFI_TIMEOUT` is defined in the error catalogue but never emitted. `(ffi-call "sleep" 2 1)` blocks for two seconds and then returns normally. A foreign function that never returns hangs the calling thread.

Until enforcement exists, write the timeout you intend (it documents the call, and it keeps your code correct for when enforcement arrives), and bound blocking work on the C side.

## 22.8 Memory Management Across the FFI

### Zyl to C

Strings are passed by pointer to their bytes. C may read them but must not keep the pointer beyond the call, and must not write through it.

### C writes into Zyl-owned memory

Allocate a buffer, pass the pointer, copy the result out, and free the buffer. This is the pattern `reverse-string` uses above:

```lisp
(use allocator/allocator)

(let buf (alloc-malloc 1024)
  (let _ (ffi-call "c_fill_buffer" buf 1024 1000)
    (let data (str-concat "" buf)   ; copy out as a Zyl string
      (let _ (alloc-free buf)
        data))))
```

`alloc-malloc` and `alloc-free` wrap `malloc` and `free`. They come from `allocator/allocator`, which must be `use`d.

### C allocates, Zyl frees

```lisp
(defn c-owned-string ()
  (let p (ffi-call "strdup" "copied by C" 1000)
    (let s (str-concat "" p)        ; copy into Zyl memory
      (let _ (ffi-call "free" p 1000)
        s))))
```

Pass the returned pointer itself to `free`, not `(ffi-pin p)`, which would pass the address of a slot holding `p`.

## 22.9 Callbacks (C to Zyl)

**Not supported.** There is no way to hand C a function pointer that calls back into Zyl, and closures are rejected as FFI arguments (§22.4). When C needs to deliver events, have Zyl poll a C function that returns an integer code:

```lisp
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
| Only pinnable types cross the boundary | partial: inline closures and resolved non-pinnable types in `ffi-pin` are rejected (§22.4) |
| Pinned memory does not move | holds: nothing in Zyl moves memory |
| Pinned memory stays alive during the call | holds: pins are never freed before exit |
| Calls are bounded by a timeout | **not implemented** (§22.7) |
| C cannot corrupt Zyl memory (G5) | **not enforced**: C runs unrestricted in the process |
| Symbol names cannot inject assembly | holds: names are sanitised |
| FFI use is declared per package | holds for `defn`/`def` bodies in manifest-bearing packages (§22.11) |
| Correct argument types | not checked: C sees raw words; floats are mis-passed |

## 22.13 Errors

| Error | When |
|-------|------|
| `E_INVALID_CAPABILITY` | non-pinnable operand of `ffi-pin`, or inline closure passed to `ffi-call` |
| `E_FFI_PIN_REQUIRED` | a `Secret` passed to `ffi-call` without `ffi-pin` |
| `E_PKG_CAPABILITY_VIOLATION` | FFI used in a package that does not declare `ffi`, or denied by the root |
| `E_FFI_SYMBOL_NOT_FOUND` | interpreter only (`zyl eval`, the REPL): symbol not found by `dlsym` |
| `E_FFI_TIMEOUT` | specified (§28); never raised by the current implementation |
| linker `undefined reference` | compiled code calls a symbol that is not linked |

Malformed calls are not diagnosed by the compiler. `(ffi-call)` fails at link time with ``undefined reference to `_'``, and an unquoted symbol name fails in the assembler.

## 22.14 Best Practices

1. **Wrap every foreign function in one Zyl function**, so the raw word-level interface lives in one place.
2. **Always write the timeout** as the last argument. Omitting it drops a real argument silently.
3. **Pass integers and strings directly.** Use `ffi-pin` only when C expects a pointer to a value.
4. **Keep floating point on the Zyl side** until the FFI passes floats correctly.
5. **Copy C-owned data into Zyl strings** with `str-concat` before freeing it.
6. **Declare `ffi` and `native` in `zyl.pkg`**, and check `zyl audit` to see which dependencies use them.
7. **Test the C side with sanitizers** (ASan, UBSan). Nothing on the Zyl side can protect you from a C bug.
