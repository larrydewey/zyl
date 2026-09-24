# Chapter 12: FFI and Systems Programming

Zyl's Foreign Function Interface (FFI) calls C functions directly. The specification's safety rules (Spec §16) are that every FFI call carries a **timeout**, that only **FFI-pinnable** types cross the boundary, and that memory C must hold on to lives in the non-moving **Pin region**. This chapter shows how FFI works in the current compiler and which of those rules are enforced today. Every example was compiled with `zyl`, linked, and run.

## 12.1 FFI Basics

### Calling C Functions

```lisp
(ffi-call "c_function_name" arg ... timeout-ms)
```

- `"c_function_name"`: the C symbol, as a string literal
- `arg ...`: the arguments, passed to C in order
- `timeout-ms`: the maximum execution time in milliseconds; **always the last argument**

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

**The timeout is positional.** The compiler removes the last argument of every `ffi-call` and treats it as the timeout. If you forget it, your last real argument becomes the timeout and C receives one argument too few, with no diagnostic: `(ffi-call "abs" -5)` calls `abs` with an unspecified value.

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

Not supported. There is no way to hand C a Zyl function to call back. (Actor mailboxes are no workaround: C has no Zyl function to post to one; see Chapter 9.)

## 12.7 Timeout and Safety

### Timeouts

The specification says a call that exceeds its timeout fails with `E_FFI_TIMEOUT`. **The current compiler does not enforce timeouts**: the value is removed from the call and never used. `(ffi-call "sleep" 3 100)` sleeps for the full three seconds and returns normally. Write the timeout anyway, because the syntax requires it, and a future compiler will honor it.

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
| Forgetting the timeout | The last argument is always taken as the timeout; C silently gets one argument too few |
| Passing a `Float` to a `double` parameter | Use an `int64_t` wrapper in C (§12.2) |
| Printing a C string pointer | Wrap it: `(print (str-concat "" ptr))` |
| Expecting the timeout to fire | Not enforced yet (§12.7) |
| Memory leaks | Free `malloc`ed results from C; prefer arenas for buffers |
| Calling your own C from a package without `ffi` | Declare `(capabilities ffi native)` |

---

## For Experts: Under the Hood

### FFI Call Sequence

`(ffi-call "sym" a b timeout)` reaches ICNF lowering (`ic-ffi` in `stdlib/compiler/icnf.zyl`) as an application of `ffi-call`. Lowering drops the trailing timeout and produces an `IFfi "sym" (a b)` node. Code generation evaluates the arguments left to right, loads them into the System V integer argument registers, aligns the stack, and emits `call sym`. The result is read from `rax`. There is no stack switching and no wrapper thread.

### Pin Region Implementation

The runtime keeps one Pin arena (`g_pin_arena`), created alongside the heap arena before the program's own code runs. `ffi_pin` allocates an 8-byte slot from it and stores the value; `ffi_unpin` validates the address against the arena's live blocks and returns the stored word. The arena is destroyed in a destructor when the process exits.

### Timeout Implementation

None yet. The error code `E_FFI_TIMEOUT` is defined in `stdlib/compiler/error_codes.zyl` for when it lands.

---

**Next:** [Chapter 13: A Complete Project Walkthrough](ch13-project-walkthrough.md) builds a small Zyl application from start to finish.
