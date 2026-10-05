# Chapter 12: FFI and Systems Programming

Zyl's Foreign Function Interface (FFI) calls C functions directly. The specification's safety rules (Spec §16) are that every FFI call carries a **timeout**, that only **FFI-pinnable** types cross the boundary, and that memory C must hold on to lives in the non-moving **Pin region**. This chapter shows how FFI works in the current compiler and which of those rules are enforced today. Every example was compiled with `zyl`, linked, and run.

## 12.1 FFI Basics

### Calling C Functions

```lisp
(ffi-call "c_function_name" arg ... timeout-ms)
```

- `"c_function_name"`: the C symbol, as a string literal
- `arg ...`: the arguments, passed to C in order
- `timeout-ms`: the maximum execution time in milliseconds, as a positive integer literal; **always the last argument**

Any C function linked into the program can be called: the C library (`libc` is always linked), the Zyl runtime's helpers, and your own C code (§12.4). Before the first call, declare the function's C signature with `extern`:

```lisp
(extern "c_function_name" (ParamType ...) ResultType)
```

```lisp
(capabilities ffi)

(extern "puts" (String) Int)
(extern "abs" (Int) Int)
(extern "strlen" (String) Int)

(defn main ()
  (begin
    (ffi-call "puts" "Hello from C!" 1000)
    (print (ffi-call "abs" -42 1000))
    (print (ffi-call "strlen" "hello" 1000))
    0))
```

Output:

```
Hello from C!
42
5
```

Arguments do not need to be pinned: an `Int` or `Bool` is passed as its value and a `String` as a pointer to its bytes.

### Declaring a C Signature

The type checker cannot see into C, so the `extern` declaration is where a foreign function gets its type. Every `ffi-call` to that symbol is checked against it: the arguments must have the declared parameter types, the call must pass as many arguments as there are parameters, and the result has the declared result type. An `ffi-call` to a foreign symbol with no `extern` is an error:

```
error[E_CANNOT_INFER]: no type for ffi-call to `strlen`, which has no (extern ...) declaration
  --> lengths.zyl:5:12
   |
 5 |     (print (ffi-call "strlen" "hello" 1000))
   |            ^
```

The declaration is a top-level form, and it describes the C function; it does not define anything. The types it may use are the ones that fit in one machine word:

| Type in `extern` | C side |
|------------------|--------|
| `Int` | `int64_t` |
| `Bool` | `int64_t`, 0 or 1 |
| `String` | `const char*` |
| `Ptr` | any pointer; an opaque address Zyl can only pass back to C or to the `allocator/allocator` functions |
| `Unit` | `void`, as a result |
| `(Pin a)` | `a *`, the address of a one-word slot from `ffi-pin` (§12.1) |
| `(Fn (A ...) R)` | a function pointer, for a C callback (§12.6) |

### A Default Timeout on the `extern`

When every call to a function wants the same budget, write it once on the declaration:

```lisp
(capabilities ffi)

(extern "abs" (Int) Int :timeout 1000)

(defn main ()
  (begin
    (print (ffi-call "abs" -42))        ; uses the extern's 1000 ms
    (print (ffi-call "abs" -7 50))      ; its own 50 ms wins
    0))
```

The count of arguments decides which: a call passing exactly as many arguments as the `extern` has parameters takes the default, and one passing one more ends with its own timeout. The `:timeout` must be a positive integer literal, like a call's. With no timeout at the call and none on the `extern`, the compiler names both places:

```
error[E_FFI_TIMEOUT_REQUIRED]: the call to `abs` has no timeout: its last argument is not a positive integer literal
  --> magnitude.zyl:3:21
   |
 3 | (defn magnitude (n) (ffi-call "abs" n))
   |                     ^
   = help: add the timeout here: (ffi-call "abs" args 1000), or once on the extern: (extern "abs" (...) R :timeout 1000)
```

The runtime's `zyl_*` functions take no `extern`, so a call to one always ends with its own timeout.

The types must be concrete: a type variable, such as `(extern "abs" (a) b)`, would let one call pretend C returned any type at all, so it is `E_TYPE_MISMATCH`. A `Float` crosses on its own but not inside a type (§12.2). There is no cast form in Zyl, so the `extern` is the only place a C value's type is decided: get it right, because the compiler takes it on trust.

The Zyl runtime's own `zyl_*` functions need no declaration: the compiler types each one from its signature table, `stdlib/compiler/ffi_sigs.zyl`, so `(ffi-call "zyl_int_text" 42 1000)` needs no `extern` and has type `String`. An `extern` is only for foreign code. Calling a runtime entry declared with one, such as `(extern "zyl_int_text" (Int) Int)`, is `E_FFI_RESTRICTED`: the program may not retype the runtime. A few runtime functions that read raw memory or reinterpret a machine word as another type (an arbitrary `Int` as a pointer or a `String`, say) are reserved for the standard library; calling one from a program is `E_FFI_RESTRICTED`.

**The timeout is positional, and it must be a literal.** The compiler takes the last argument of every `ffi-call` as the timeout and requires it to be a positive integer literal. Anything else is rejected at compile time with `E_FFI_TIMEOUT_REQUIRED`, so a forgotten timeout cannot silently swallow your last real argument:

```
(defn magnitude (n) (ffi-call "abs" n))   ; E_FFI_TIMEOUT_REQUIRED: n is not a literal
(ffi-call "abs" -5)                       ; E_FFI_TIMEOUT_REQUIRED: -5 is not positive
(ffi-call "abs" -5 0)                     ; E_FFI_TIMEOUT_REQUIRED: 0 is not positive
```

The symbol must likewise be a string literal (`E_FFI_SYMBOL_REQUIRED`). One ambiguity remains: a call whose only argument is a positive literal, such as `(ffi-call "f" 5)`, is read as a call with no arguments and a 5 ms timeout.

### Pinning Values

```lisp
(ffi-pin value)     ; copy value into a Pin-region slot; a (Pin a)
(ffi-unpin pinned)  ; the value now in the slot, an a
```

The **Pin region** is a non-moving arena owned by the runtime. `ffi-pin` copies one 64-bit word into a fresh slot there and returns the slot. When the value has type `a`, the slot has type `(Pin a)`: a pinned `Int` is a `(Pin Int)`, not an `Int`, so it cannot be used as the number by mistake. Passed to C, the slot is its address, so the `extern` parameter that receives it is declared `(Pin Int)` and C sees an `int64_t *`. The address never moves, so C can read or write through it for as long as it needs. `ffi-unpin` takes the `(Pin a)` and returns the `a` now in the slot: the value pinned, or whatever C wrote there. It checks that the pointer really came from `ffi-pin`; for any other address it prints `zyl: ffi-unpin: pointer not from ffi-pin/Pin arena`. It does not free the slot: pinned slots are released in bulk, with the Pin arena, when the program exits.

```lisp
(capabilities ffi)

(defn main ()
  (let pinned (ffi-pin 42)
    (begin
      (print (ffi-unpin pinned))   ; 42
      0)))
```

Only data can be pinned: `(ffi-pin (fn (x) x))` is `E_FFI_TYPE_NOT_PINNABLE`.

An **out-parameter**, a word C writes for you to read, is a pinned slot: pin a starting value, pass the `(Pin Int)` to a parameter declared `(Pin Int)`, and read the result back with `ffi-unpin` (see `print-divmod` in §12.4). A buffer longer than one word does not fit in a slot; allocate a `(bytebuf Heap N)` and pass `bytebuf-ptr` of it (see `print-reversed`).

Values of the `Secret` capability type (Chapter 33) are the exception to "no pinning needed": a `Secret` passed straight to `ffi-call` is rejected at compile time with `E_FFI_PIN_REQUIRED`, and must be handed over through `ffi-pin`. C then receives the address of the pinned copy, so the parameter is declared `(Pin Int)` for a secret `Int`.

## 12.2 FFI-Pinnable Types

The specification allows only these types across the FFI boundary (Spec §16):

| Zyl Type | Passed to C as | Notes |
|----------|----------------|-------|
| `Int` | `int64_t` | 64-bit signed |
| `Bool` | `int64_t` (0 or 1) | |
| `String` | `const char*` | NUL-terminated bytes |
| `Float` | `double` | IEEE-754 binary64, in an SSE register |
| `Vec<T>` (T pinnable) | pointer | No C header describes the layout |
| Struct / ADT with pinnable fields | pointer to its heap block | |

Every argument is one 64-bit word, and where it goes is the System V ABI's decision: an integer or pointer in `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9` and then the stack, a `double` in `xmm0`..`xmm7` and then the stack; a result in `rax`, or in `xmm0` for a `double`. The compiler reads the `extern` to work out which class each argument is, emits that with the call, and the runtime puts each word where it belongs before the call (§12.10). Two consequences:

- **A C `double` is a Zyl `Float`.** The 64 bits are moved across unchanged, so an infinity, a negative zero and a NaN survive the trip exactly; `(extern "snprintf" (Ptr Int String Float) Int)` and `(extern "strtod" (String) Float)` are ordinary declarations. What does *not* cross is a `Float` inside another type — `(extern "f" ((Pin Float)) Float)` and a `(Fn (Float) R)` callback parameter are `E_TYPE_MISMATCH`, because an aggregate's eightbyte class is not computed. Pass a struct with a `Float` field as a pointer, or convert at the C side.
- **Write C signatures with `int64_t` (or `long long`) and pointers**, and return `int64_t`, a pointer, `double` or `void`.

The `extern` declaration is what enforces the table: `(ffi-call "abs" (Some 1) 1000)` against `(extern "abs" (Int) Int)` is `E_TYPE_MISMATCH`. Structs, ADTs and `Vec`s cannot be named in an `extern` at all today; pass their fields one by one.

## 12.3 Writing C Functions for Zyl

There is no Zyl-specific C header to include. Use the fixed-width types from `<stdint.h>`:

```c
#include <stdint.h>
#include <string.h>

/* Every argument arrives as a 64-bit word; every result goes back in one. */
int64_t demo_factorial(int64_t n) {
    if (n <= 1) return 1;
    return n * demo_factorial(n - 1);
}

/* Reverse `input` into `output`, which holds at least `cap` bytes.
   Returns the number of bytes written, excluding the terminator. */
int64_t demo_reverse_string(const char* input, char* output, int64_t cap) {
    int64_t len = (int64_t)strlen(input);
    if (len >= cap) len = cap - 1;
    for (int64_t i = 0; i < len; i++) {
        output[i] = input[len - 1 - i];
    }
    output[len] = '\0';
    return len;
}

/* Quotient as the result, remainder through an out-parameter. */
int64_t demo_divmod(int64_t a, int64_t b, int64_t* rem) {
    *rem = a % b;
    return a / b;
}
```

`ffi-call` uses the symbol name exactly as written. Do not start your own C functions' names with `zyl_`: that prefix belongs to the runtime. A symbol declared with an `extern` is always foreign code and runs on the timeout worker (§12.7), whatever its prefix; only the runtime's own `zyl_*` entries, which take no `extern`, are called directly.

## 12.4 Complete FFI Example

### C Code (`mylib.c`)

The three functions from §12.3.

### Zyl Code (`ffi-demo.zyl`)

```lisp
(capabilities ffi)

(use allocator/allocator)

(extern "demo_factorial" (Int) Int)
(extern "demo_reverse_string" (String Ptr Int) Int)
(extern "demo_divmod" (Int Int (Pin Int)) Int)   ; C writes the remainder into the slot

(defn factorial (n)
  (ffi-call "demo_factorial" n 1000))

; C writes the reversed text into a buffer Zyl allocated. The buffer is a
; (bytebuf Heap 256), so the region system accounts for it, and
; bytebuf-ptr is its address -- the only way a program gets one.
(defn print-reversed ((s String))
  (let buf (bytebuf Heap 256)
    (let p (bytebuf-ptr buf)
      (begin
        (ffi-call "demo_reverse_string" s p 256 1000)
        (print (alloc-cstr p))))))

; C writes the remainder into a pinned slot; ffi-unpin reads it back.
(defn print-divmod (a b)
  (let slot (ffi-pin 0)
    (let q (ffi-call "demo_divmod" a b slot 1000)
      (begin
        (print "quotient:" q)
        (print "remainder:" (ffi-unpin slot))))))

(defn main ()
  (begin
    (print "factorial of 5:" (factorial 5))
    (print-reversed "hello")
    (print-divmod 17 5)
    0))
```

Four details:

- Each C function is declared once with `extern`, and each call is checked against the declaration.
- The remainder comes back through a pinned slot: `demo_divmod` takes a `(Pin Int)`, and `ffi-unpin` reads what C wrote into it.
- The output buffer is a `(bytebuf Heap N)`, so the region that owns it reclaims it when the frame returns; there is nothing to release by hand. A program cannot create an arena and cannot call `alloc-malloc`: the arena entries and the raw allocator are `E_FFI_RESTRICTED`, which is why the buffer is a `bytebuf`.
- A C buffer is a `Ptr` to Zyl, and `bytebuf-ptr` gives one. `alloc-cstr` gives the NUL-terminated bytes at a `Ptr` the type `String`, so `print` prints them as text. It does not copy: the `String` is only valid as long as the buffer is.
- The file starts with `(capabilities ffi)`: calling foreign code is a capability, and a program has none it did not declare.

### Building a Single File

Plain `zyl file.zyl` links only the runtime (and libc, once the program calls foreign C). To add your own C code, emit the assembly and link it yourself:

```bash
zyl ffi-demo.zyl -o ffi-demo.s --emit-asm
cc -no-pie ffi-demo.s mylib.c ~/.zyl/rt.o -o ffi-demo -lpthread -lm
./ffi-demo
```

With `--emit-asm`, the assembly is written to exactly the `-o` path, and nothing is assembled or linked. `rt.o` is the runtime, written in Zyl (`runtime/rt/`): it is in `~/.zyl` after `./install.sh`, or in `build/boot/` in a source checkout (`./boot.sh` assembles it from the committed `rt.s`). The `cc` line is the same one `zyl` itself runs (§12.9), plus `mylib.c`. Output:

```
factorial of 5:
120
olleh
quotient:
3
remainder:
2
```

### Building a Package with Native Code

A package can ship its C sources and let `zyl build` compile and link them (Spec §31.10). There are no build scripts, only a declaration in `zyl.pkg`:

```text
ffidemo/
├── zyl.pkg
├── ffidemo.zyl      # the Zyl code above, without its (capabilities ffi) line
└── c/
    └── mylib.c
```

```lisp
(package
  (name "book/ffidemo") (version "0.1.0") (zyl "5.0") (edition "2026")
  (capabilities ffi native)
  (native (sources "c/mylib.c") (cflags "-O2")))
```

```bash
cd ffidemo
zyl build
./ffidemo
```

In a package the capabilities are declared once, in `zyl.pkg`, so the
`(capabilities ffi)` line comes out of `ffidemo.zyl`: kept in a file of a
manifested package it is `E_MALFORMED_FORM` (`` `capabilities` is
declared in zyl.pkg, not in a file of package book/ffidemo ``).

`zyl build` compiles the module named by the package name's last segment (`ffidemo.zyl`), compiles `c/mylib.c` into `build/native/`, links everything into `./ffidemo`, and records what went into the binary in `ffidemo.buildinfo`.

Both capabilities are required, and both are checked:

- `native` to ship C sources: without it, `E_PKG_CAPABILITY_VIOLATION: capability: package book/ffidemo ships native sources without declaring the native capability`
- `ffi` to call into them: without it, ``error[E_PKG_CAPABILITY_VIOLATION]: `demo_factorial` needs the ffi capability, and package book/ffidemo declares only native``, located at the `ffi-call`, with `= help: add (capabilities native ffi) to zyl.pkg`

`cflags` are limited to an allowlist (`-O*`, `-D*`, `-std=*`, and a fixed set of `-f` flags). Anything else, such as `-lfoo`, is `E_PKG_NATIVE_FLAG_DENIED`; libraries go in `(link-libs "m")` and include paths in `(include-dirs "c/include")`.

## 12.5 Memory Management Across FFI

### Zyl to C

- **Strings** are passed as pointers to Zyl-owned bytes (a literal in the program's read-only data, or a heap string). C may read them for the duration of the call, but must not modify, free, or keep them.
- **Buffers C writes into** come from `(bytebuf Heap N)`, with `bytebuf-ptr` for the address. `alloc-malloc` and `alloc-free` are `E_FFI_RESTRICTED`.
- **Single words C writes through a pointer** are a pinned slot (`ffi-pin`, read back with `ffi-unpin`), or an 8-byte `(bytebuf Heap 8)` read back with `(load-i64 :le buf 0)`.

### C to Zyl

A pointer returned by C is declared `Ptr`. If C allocated it with `malloc`, Zyl owns it now and must release it, for example with `free` declared as `(extern "free" (Ptr) Unit)`, after copying out what it needs. `alloc-cstr` only relabels the bytes, so copy them with `str-concat` before freeing:

```lisp
(let text (str-concat "" (alloc-cstr c-ptr))   ; copy into a Zyl String
  (begin
    (ffi-call "free" c-ptr 1000)               ; then release the C allocation
    text))
```

## 12.6 Callbacks (C Calling Zyl)

A top-level function named as an argument is passed to C as a function pointer, so C can call it back. Declare the parameter with a function type, `(Fn (Params...) Result)`:

```lisp
(extern "qsort" (Ptr Int Int (Fn (Ptr Ptr) Int)) Unit)
```

Then `(ffi-call "qsort" p 64 8 compare 1000)` sorts with a Zyl comparator `compare`, which must take two `Ptr`s (read them with `alloc-read-int`) and return an `Int`. Because the foreign call runs on its FFI worker thread (§12.7), the callback runs there too. It runs as the calling actor, owning the same channel endpoints, but a panic inside it that no `try` within the callback catches ends the process. A `fn` written inline is not a top-level function: passing one is `E_INVALID_CAPABILITY`, because a closure is not FFI-pinnable.

## 12.7 Timeout and Safety

### Timeouts

Timeouts are enforced. A call to a foreign symbol runs on a worker thread, and the calling thread waits for it on a monotonic clock. If the function has not returned when the timeout expires, the caller raises a panic:

```
E_FFI_TIMEOUT: ffi call `usleep` exceeded its timeout of 50 ms
```

It is an ordinary error, catchable with `try`/`catch` and matchable by code with `recover`:

```lisp
(capabilities ffi)

(extern "usleep" (Int) Int)

(defn slow-call () (ffi-call "usleep" 300000 50))   ; 300 ms against a 50 ms budget

(defn main ()
  (begin
    (print (try (slow-call) (catch e 0)))           ; 0
    0))
```

A running C function cannot be stopped safely, so an overrunning call is **abandoned, not killed**. Its worker thread finishes on its own and then frees itself, and the next call gets a fresh worker. Anything the abandoned call was handed stays valid for the rest of the process: Pin slots are never freed individually, and once any call has been abandoned, the arenas are not torn down at exit. A call that returns in time costs a thread handoff, and the worker is kept between calls, so thread-local C state such as `errno` stays consistent from one call to the next.

Whether a timeout fires depends on how long the foreign code takes, which Zyl cannot control. Spec §27 treats FFI results as observable external input, and a timeout is one of those results.

The Zyl runtime's own `zyl_*` symbols are part of the trusted implementation: they are called directly, and their timeout is checked at compile time but not used at run time. The interpreter (`zyl eval`, the REPL) enforces timeouts in the same way as compiled code.

### What the Runtime Checks

The runtime rejects a few classes of bad pointers before using them:

- `ffi-unpin` accepts only addresses inside the Pin arena and reports any other.
- The string helpers behind `str-length`, `str-eq`, `str-substring` and friends reject a non-zero pointer below `0x1000`, which can never be a real mapping, instead of reading from it.
- An indirect call through a value below `0x1000` (a null or small bogus "function") exits with `zyl: invalid callee address`.

Beyond that, C code runs with full access to the process. The specification's broader guarantees (no use-after-free and no data races across the boundary) depend on your C code keeping to the rules in §12.5.

## 12.8 Systems Programming Patterns

### File I/O Without FFI

Reading and writing files does not need FFI at all: `file-open`, `file-read`, `file-write` and `file-close` are built in (Chapter 13 uses them). The mode given to `file-open` must be a string literal, `"r"`, `"w"` or `"a"`, optionally followed by `+` or `b` (`"r+"`, `"wb"`); anything else, including a mode held in a variable, is `E_TYPE_MISMATCH`. They need the `io` capability rather than `ffi`: `(capabilities io)` at the top of a lone file, or in a package's `zyl.pkg`.

### Out-Parameters

When a C function returns more than one value, return the main result and write the rest through pointers to words Zyl pinned, as `demo_divmod` does in §12.4: one `(ffi-pin 0)` per value, each passed as a `(Pin Int)` and read back with `ffi-unpin`.

### Wrapping libc

Most of libc is reachable with one `extern` each: `(extern "strlen" (String) Int)`, `(extern "abs" (Int) Int)`, `(extern "getenv" (String) Ptr)` (a C string pointer, null when the variable is unset; `(alloc-cstr p)` reads a non-null one). Keep such calls inside small, named Zyl functions so the declaration, the timeout and any pointer conversion live in one place.

## 12.9 Linking

A program with no foreign `ffi-call` is a static executable with no
libc: `zyl` assembles and links it itself, against the runtime cached as
`rt.zo`, and runs no `cc`. A program that calls foreign C, like every
program in this chapter, links **hosted** over libc, because the C
library needs it:

```bash
cc -no-pie program.s rt.o -o program -lpthread -lm
```

`-lpthread` and `-lm` are on the line unconditionally: libc and libm are
the two libraries C library code reaches for, and a lone file has no way
to ask for a library of its own (`(link-libs ...)` belongs to a package's
`native` block). So `(extern "fabs" (Float) Float)` and `(extern "sqrt"
(Float) Float)` link as they are declared.

`rt.o` is the Zyl runtime (`runtime/rt/`: actors, the heap and Pin
arenas, strings, the test harness), assembled by `./boot.sh` from the
committed seed `build/boot/rt.s` and copied into `~/.zyl` by
`./install.sh`.

To link your own objects into a single-file program, use `--emit-asm` and run that command yourself with your `.c` or `.o` files added (§12.4). In a package, use `(native ...)` instead.

## 12.10 Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Forgetting the timeout | Compile error `E_FFI_TIMEOUT_REQUIRED`; end every call with a positive literal such as `1000` |
| Calling a C function with no `extern` | Compile error `E_CANNOT_INFER`; declare `(extern "sym" (T ...) R)` first |
| A `Float` in an `extern` refused as "not inside a type" | Only a bare `Float` crosses; pass the containing value as a pointer, or convert in C (§12.2) |
| A symbol in neither libc nor libm failing to link | Add the library with `(link-libs "m")`-style native declarations, or link by hand (§12.9); libc, libm and libpthread are already on the line |
| Printing a C string pointer | Declare it `Ptr` and read it with `(alloc-cstr ptr)` |
| A timeout too tight for slow C code | The call raises `E_FFI_TIMEOUT` and the C function is abandoned (§12.7); budget generously |
| Memory leaks | Free `malloc`ed results from C; buffers should be a `(bytebuf R N)`, which a region accounts for |
| `E_PKG_CAPABILITY_VIOLATION` on the first `ffi-call` | Add `(capabilities ffi)` at the top of the file |
| Calling your own C from a package without `ffi` | Declare `(capabilities ffi native)` |

---

## For Experts: Under the Hood

### FFI Call Sequence

The arity pass (`stdlib/compiler/arity_check.zyl`) checks each `ffi-call` first: `ffi-check-call` rejects a non-literal symbol, a missing or non-positive timeout, and more than 16 arguments (`E_ARITY_MISMATCH`), and `ffi-check-raw` rejects a raw runtime entry outside the standard library (`E_FFI_RESTRICTED`). The type pass (`ta-ffi-typed` in `stdlib/compiler/type_annotate.zyl`) then types the call: a runtime symbol by its entry in the signature table `stdlib/compiler/ffi_sigs.zyl`, any other symbol by its `extern` declaration, which it checks for concrete, word-sized types.

`(ffi-call "sym" a b timeout)` then reaches ICNF lowering (`ic-ffi` in `stdlib/compiler/icnf.zyl`) as an application of `ffi-call`; lowering runs `ffi-check-call` again. A `zyl_*` runtime symbol becomes `IFfi "sym" (a b)`, a direct call. Any other symbol becomes a call of the runtime's timed bridge:

```
IFfi "zyl_ffi_timed" (ISymAddr "sym", IStr "sym", IConst timeout, IConst request, a, b)
```

`request` is the argument count (2 here) in its low byte, with the signature's ABI class mask above it: bit 8+i set when argument i is a `Float`, bit 24 when the result is one. A signature with no `Float` masks to zero, and the word is then exactly the argument count it has always been.

`ISymAddr` is the address of the C symbol, emitted as `mov rax, QWORD PTR [rip+sym@GOTPCREL]`. Code generation evaluates the arguments left to right and hands them over as words; the worker thread running the call loads them into the registers the ABI names for them (the rest on the stack) and emits the call with the stack 16-byte aligned. The result is read from `rax`, or from `xmm0` when the `extern` says the result is a `Float`.

### Pin Region Implementation

The runtime keeps one Pin arena (`runtime/rt/alloc.zyl`), created alongside the heap arena before the program's own code runs. `zyl_ffi_pin` allocates an 8-byte slot from it and stores the value; `zyl_ffi_unpin` checks that the address lies in the arena and returns the stored word. The arena is released at exit.

### Timeout Implementation

`zyl_ffi_timed` in `runtime/rt/ffitimed.zyl` looks up the calling thread's worker (creating it on first use), hands it the function address, the request word and the arguments, and waits on the runtime's futex condition variable (`zyl_rt_cond_timedwait`, `runtime/rt/thread.zyl`) against a monotonic deadline. On expiry it marks the worker abandoned, forgets it, records that some call has been abandoned (which disables the exit-time arena teardown), and raises `E_FFI_TIMEOUT`. The interpreter calls the same code through `zyl_ffi_timed_argv`, which takes the arguments as an array.

---

**Next:** [Chapter 13: A Complete Project Walkthrough](ch13-project-walkthrough.md) builds a small Zyl application from start to finish.
