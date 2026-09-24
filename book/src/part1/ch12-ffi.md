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

Any C function linked into the program can be called: the C library (`libc` is always linked), the Zyl runtime's helpers, and your own C code (§12.4).

```lisp
(defn main ()
  (begin
    (ffi-call "puts" "Hello from C!" 1000)
    (print (ffi-call "abs" -42 1000))
    (print (ffi-call "strlen" "hello" 1000))))
```

Output:

```
Hello from C!
42
5
```

Arguments do not need to be pinned: an `Int` or `Bool` is passed as its value and a `String` as a pointer to its bytes. `ffi-call` always returns an `Int`: whatever the C function left in the return register.

**The timeout is positional, and it must be a literal.** The compiler takes the last argument of every `ffi-call` as the timeout and requires it to be a positive integer literal. Anything else is rejected at compile time with `E_FFI_TIMEOUT_REQUIRED`, so a forgotten timeout cannot silently swallow your last real argument:

```
(defn magnitude (n) (ffi-call "abs" n))   ; E_FFI_TIMEOUT_REQUIRED: n is not a literal
(ffi-call "abs" -5)                       ; E_FFI_TIMEOUT_REQUIRED: -5 is not positive
(ffi-call "abs" -5 0)                     ; E_FFI_TIMEOUT_REQUIRED: 0 is not positive
```

The symbol must likewise be a string literal (`E_FFI_SYMBOL_REQUIRED`). One ambiguity remains: a call whose only argument is a positive literal, such as `(ffi-call "f" 5)`, is read as a call with no arguments and a 5 ms timeout.

### Pinning Values

```lisp
(ffi-pin value)     ; copy value into the Pin region; return its stable address
(ffi-unpin ptr)     ; read the value back from a pinned address
```

The **Pin region** is a non-moving arena owned by the runtime. `ffi-pin` copies one 64-bit word into a fresh slot there and returns the slot's address as an `Int`. That address never moves, so C can read or write through it for as long as it needs. `ffi-unpin` returns the word currently stored in the slot. It checks that the pointer really came from `ffi-pin`; for any other address it prints `zyl: ffi-unpin: pointer not from ffi-pin/Pin arena` and returns 0. Pinned slots are not freed one by one: the Pin arena is released in bulk when the program exits.

```lisp
(defn main ()
  (let pinned (ffi-pin 42)
    (print (ffi-unpin pinned))))     ; 42
```

The main use for pinning is an **out-parameter**: pin a placeholder, pass its address to C, and read the result back with `ffi-unpin` (see `print-divmod` in §12.4).

Values of the `Secret` capability type (Chapter 33) are the exception to "no pinning needed": a `Secret` passed straight to `ffi-call` is rejected at compile time with `E_FFI_PIN_REQUIRED`, and must be handed over through `ffi-pin`.

## 12.2 FFI-Pinnable Types

The specification allows only these types across the FFI boundary (Spec §16):

| Zyl Type | Passed to C as | Notes |
|----------|----------------|-------|
| `Int` | `int64_t` | 64-bit signed |
| `Bool` | `int64_t` (0 or 1) | |
| `String` | `const char*` | NUL-terminated bytes |
| `Float` | see below | IEEE-754 binary64 |
| `Vec<T>` (T pinnable) | pointer | No C header describes the layout |
| Struct / ADT with pinnable fields | pointer to its heap block | |

The code generator passes every argument as a 64-bit word in the integer argument registers (`rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`) and reads the result from `rax`. Two consequences:

- **Floats do not reach C `double` parameters.** A `Float` travels as its raw bit pattern in an integer register, where a C function declared `double f(double)` does not look for it. Write a small C wrapper that takes and returns `int64_t` and converts with `memcpy`.
- **Write C signatures with `int64_t` (or `long long`) and pointers only**, and return `int64_t` or a pointer.

The compiler contains a pinnability check for `ffi-call` arguments and `ffi-pin` values, but the current type checker does not reach it: `(ffi-call "abs" (Some 1) 1000)` compiles and passes the ADT's address. Until the check is wired in, keep to the types in the table.

## 12.3 Writing C Functions for Zyl

There is no Zyl-specific C header to include. Use the fixed-width types from `<stdint.h>`:

```c
#include <stdint.h>
#include <string.h>

/* Every argument arrives as a 64-bit word; every result goes back in one. */
int64_t zyl_factorial(int64_t n) {
    if (n <= 1) return 1;
    return n * zyl_factorial(n - 1);
}

/* Reverse `input` into `output`, which holds at least `cap` bytes.
   Returns the number of bytes written, excluding the terminator. */
int64_t zyl_reverse_string(const char* input, char* output, int64_t cap) {
    int64_t len = (int64_t)strlen(input);
    if (len >= cap) len = cap - 1;
    for (int64_t i = 0; i < len; i++) {
        output[i] = input[len - 1 - i];
    }
    output[len] = '\0';
    return len;
}

/* Quotient as the result, remainder through an out-parameter. */
int64_t zyl_divmod(int64_t a, int64_t b, int64_t* rem) {
    *rem = a % b;
    return a / b;
}
```

Naming C functions with a `zyl_` prefix is a convention, not a requirement; `ffi-call` uses the symbol name exactly as written.

## 12.4 Complete FFI Example

### C Code (`mylib.c`)

The three functions from §12.3.

### Zyl Code (`ffi-demo.zyl`)

```lisp
(use allocator/allocator)

(defn factorial (n)
  (ffi-call "zyl_factorial" n 1000))

; C writes the reversed text into a buffer Zyl allocated.
(defn print-reversed (arena (s String))
  (let buf (arena-alloc-zeroed arena 256)
    (begin
      (ffi-call "zyl_reverse_string" s buf 256 1000)
      (print (str-concat "" buf)))))

; ffi-pin gives C a stable address to write the remainder into;
; ffi-unpin reads the word back.
(defn print-divmod (a b)
  (let slot (ffi-pin 0)
    (let q (ffi-call "zyl_divmod" a b slot 1000)
      (begin
        (print "quotient:" q)
        (print "remainder:" (ffi-unpin slot))))))

(defn main ()
  (let arena (arena-create 4096)
    (begin
      (print "factorial of 5:" (factorial 5))
      (print-reversed arena "hello")
      (print-divmod 17 5)
      (arena-destroy arena)
      0)))
```

Three details:

- There is no declaration step for a C function; the call is the declaration.
- The output buffer comes from an arena (`allocator/allocator`), so it is released with the arena rather than one allocation at a time.
- A C buffer is an `Int` to Zyl. `(str-concat "" buf)` copies it into a Zyl `String`, which `print` then prints as text. Printing `buf` directly would print the address.

### Building a Single File

Plain `zyl file.zyl` links only the runtime and libc. To add your own C code, emit the assembly and link it yourself:

```bash
zyl ffi-demo.zyl -o ffi-demo.s --emit-asm
cc -no-pie ffi-demo.s mylib.c ~/.zyl/actor_runtime.c -o ffi-demo -lpthread
./ffi-demo
```

With `--emit-asm`, the assembly is written to exactly the `-o` path, and nothing is assembled or linked. `actor_runtime.c` is the runtime: `~/.zyl/actor_runtime.c` after `./install.sh`, or `build/boot/actor_runtime.c` in a source checkout. The `cc` line is the same one `zyl` itself runs, plus `mylib.c`. Output:

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
├── ffidemo.zyl      # the Zyl code above
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

`zyl build` compiles the module named by the package name's last segment (`ffidemo.zyl`), compiles `c/mylib.c` into `build/native/`, links everything into `./ffidemo`, and records what went into the binary in `ffidemo.buildinfo`.

Both capabilities are required, and both are checked:

- `native` to ship C sources: without it, `E_PKG_CAPABILITY_VIOLATION: capability: package book/ffidemo ships native sources without declaring the native capability`
- `ffi` to call into them: without it, `error[E_PKG_CAPABILITY_VIOLATION]: package book/ffidemo uses ffi in factorial without declaring it in zyl.pkg`, located at the `ffi-call` with a label at the definition

`cflags` are limited to an allowlist (`-O*`, `-D*`, `-std=*`, and a fixed set of `-f` flags). Anything else, such as `-lfoo`, is `E_PKG_NATIVE_FLAG_DENIED`; libraries go in `(link-libs "m")` and include paths in `(include-dirs "c/include")`.

## 12.5 Memory Management Across FFI

### Zyl to C

- **Strings** are passed as pointers to Zyl-owned bytes (a literal in the program's read-only data, or a heap string). C may read them for the duration of the call, but must not modify, free, or keep them.
- **Buffers C writes into** should come from `arena-alloc-zeroed` (freed with the arena) or `alloc-malloc` / `alloc-free` in `allocator/allocator`.
- **Single words C writes through a pointer** should be pinned with `ffi-pin` and read back with `ffi-unpin`.

### C to Zyl

A pointer returned by C is an `Int` in Zyl. If C allocated it with `malloc`, Zyl owns it now and must release it, for example with `(ffi-call "free" ptr 1000)`, after copying out what it needs:

```lisp
(let text (str-concat "" c-ptr)       ; copy into a Zyl String
  (begin
    (ffi-call "free" c-ptr 1000)      ; then release the C allocation
    text))
```

## 12.6 Callbacks (C Calling Zyl)

A top-level function named as an argument is passed to C as a function pointer, so C can call it back; `(ffi-call "qsort" p 64 8 compare 1000)` sorts with a Zyl comparator. Because the foreign call runs on its FFI worker thread (§12.7), the callback runs there too. It sees the caller's `actor-self`, but a panic inside it that no `try` within the callback catches ends the process. Closures written inline are still rejected as arguments (§12.2).

## 12.7 Timeout and Safety

### Timeouts

Timeouts are enforced. A call to a foreign symbol runs on a worker thread, and the calling thread waits for it on a monotonic clock. If the function has not returned when the timeout expires, the caller raises a panic:

```
E_FFI_TIMEOUT: ffi call `usleep` exceeded its timeout of 50 ms
```

It is an ordinary error, catchable with `try`/`catch` and matchable by code with `recover`:

```lisp
(defn slow-call () (ffi-call "usleep" 300000 50))   ; 300 ms against a 50 ms budget

(defn main ()
  (print (try (slow-call) (catch e 0))))            ; 0
```

A running C function cannot be stopped safely, so an overrunning call is **abandoned, not killed**. Its worker thread finishes on its own and then frees itself, and the next call gets a fresh worker. Anything the abandoned call was handed stays valid for the rest of the process: Pin slots are never freed individually, and once any call has been abandoned, the arenas are not torn down at exit. A call that returns in time costs a thread handoff, and the worker is kept between calls, so thread-local C state such as `errno` stays consistent from one call to the next.

Whether a timeout fires depends on how long the foreign code takes, which Zyl cannot control. Spec §27 treats FFI results as observable external input, and a timeout is one of those results.

The Zyl runtime's own `zyl_*` symbols are part of the trusted implementation: they are called directly, and their timeout is checked at compile time but not used at run time. The interpreter (`zyl eval`, the REPL) enforces timeouts in the same way as compiled code.

### What the Runtime Checks

The runtime rejects a few classes of bad pointers before using them:

- `ffi-unpin` accepts only addresses inside the Pin arena.
- The string helpers behind `str-length`, `str-eq`, `str-substring` and friends reject a non-zero pointer below `0x1000`, which can never be a real mapping, instead of reading from it.
- An indirect call through a value below `0x1000` (a null or small bogus "function") exits with `zyl: invalid callee address`.

Beyond that, C code runs with full access to the process. The specification's broader guarantees (no use-after-free and no data races across the boundary) depend on your C code keeping to the rules in §12.5.

## 12.8 Systems Programming Patterns

### File I/O Without FFI

Reading and writing files does not need FFI at all: `file-open`, `file-read`, `file-write` and `file-close` are built in (Chapter 13 uses them). In a package they need the `io` capability rather than `ffi`.

### Out-Parameters

When a C function returns more than one value, return the main result and write the rest through pinned slots, as `zyl_divmod` does in §12.4. Pin one slot per value.

### Wrapping libc

Most of libc is reachable directly: `(ffi-call "strlen" s 1000)`, `(ffi-call "abs" n 1000)`, `(ffi-call "getenv" "HOME" 1000)` (which returns a C string pointer, 0 when the variable is unset). Keep such calls inside small, named Zyl functions so the timeout and any pointer conversion live in one place.

## 12.9 Linking

Every program produced by `zyl` is linked with:

- `actor_runtime.c` (the Zyl runtime: actors, heap and Pin arenas, strings, the test harness)
- `libc` and `libpthread`

The link command `zyl` runs is:

```bash
cc -no-pie program.s actor_runtime.c -o program -lpthread
```

To link your own objects into a single-file program, use `--emit-asm` and run that command yourself with your `.c` or `.o` files added (§12.4). In a package, use `(native ...)` instead.

## 12.10 Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Forgetting the timeout | Compile error `E_FFI_TIMEOUT_REQUIRED`; end every call with a positive literal such as `1000` |
| Passing a `Float` to a `double` parameter | Use an `int64_t` wrapper in C (§12.2) |
| Printing a C string pointer | Wrap it: `(print (str-concat "" ptr))` |
| A timeout too tight for slow C code | The call raises `E_FFI_TIMEOUT` and the C function is abandoned (§12.7); budget generously |
| Memory leaks | Free `malloc`ed results from C; prefer arenas for buffers |
| Calling your own C from a package without `ffi` | Declare `(capabilities ffi native)` |

---

## For Experts: Under the Hood

### FFI Call Sequence

`(ffi-call "sym" a b timeout)` reaches ICNF lowering (`ic-ffi` in `stdlib/compiler/icnf.zyl`) as an application of `ffi-call`. Lowering first runs `ffi-check-call` (`stdlib/compiler/arity_check.zyl`), which rejects a non-literal symbol, a missing or non-positive timeout, and more than 16 arguments (`E_ARITY_MISMATCH`). A `zyl_*` runtime symbol becomes `IFfi "sym" (a b)`, a direct call. Any other symbol becomes a call of the runtime's timed bridge:

```
IFfi "zyl_ffi_timed" (ISymAddr "sym", IStr "sym", IConst timeout, IConst 2, a, b)
```

`ISymAddr` is the address of the C symbol, emitted as `mov rax, QWORD PTR [rip+sym@GOTPCREL]`. Code generation evaluates the arguments left to right, loads them into the System V integer argument registers (the rest on the stack), aligns the stack, and emits the call. The result is read from `rax`.

### Pin Region Implementation

The runtime keeps one Pin arena (`g_pin_arena`), created alongside the heap arena before the program's own code runs. `ffi_pin` allocates an 8-byte slot from it and stores the value; `ffi_unpin` validates the address against the arena's live blocks and returns the stored word. The arena is destroyed in a destructor when the process exits.

### Timeout Implementation

`zyl_ffi_timed` in `runtime/actor_runtime.c` looks up the calling thread's worker (creating it on first use), hands it the function address and arguments, and waits with `pthread_cond_timedwait` against a `CLOCK_MONOTONIC` deadline. On expiry it marks the worker abandoned, forgets it, records that some call has been abandoned (which disables the exit-time arena teardown), and raises `E_FFI_TIMEOUT`. The interpreter calls the same code through `zyl_ffi_timed_argv`, which takes the arguments as an array.

---

**Next:** [Chapter 13: A Complete Project Walkthrough](ch13-project-walkthrough.md) builds a small Zyl application from start to finish.
