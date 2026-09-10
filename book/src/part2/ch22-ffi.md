# Chapter 22: FFI Safety and Pinning

Complete reference for Zyl's Foreign Function Interface: pinning, FFI-pinnable types, calling conventions, and safety guarantees.

## 22.1 FFI Overview

Zyl's FFI allows calling C functions with **provable safety**:

- **Pin region**: Arguments copied to non-moving memory
- **Timeout enforcement**: C calls bounded by max execution time
- **Type safety**: Only FFI-pinnable types allowed
- **No undefined behavior**: Guaranteed by compiler

## 22.2 FFI Call Syntax

```
ffi-call ::= "ffi-call" String Expression* Integer
```

```lisp
(ffi-call "c_function_name" arg1 arg2 ... timeout-ms)
```

- `"c_function_name"`: C symbol name (string literal)
- `arg1 arg2 ...`: Arguments (must be FFI-pinnable)
- `timeout-ms`: Maximum execution time in milliseconds (Int)

## 22.3 Pinning

### ffi-pin

```
ffi-pin ::= "ffi-pin" Expression
```

```lisp
(ffi-pin value)
```

- Copies `value` to **Pin region** (non-moving arena)
- Returns **stable pointer** for C function
- Lifetime: until `ffi-unpin` or end of `ffi-call` scope

### ffi-unpin

```
ffi-unpin ::= "ffi-unpin" Expression
```

```lisp
(ffi-unpin pinned-pointer)
```

- Explicitly frees pinned memory
- Required for long-lived pins
- Automatic at `ffi-call` scope exit for temporary pins

### Pin Region Properties

- **Non-moving**: Addresses never change (no compaction)
- **Separate arena**: `mmap`ed memory, not in Heap/Stack
- **Reference counted**: For lifetime management
- **Never freed automatically** (except scope-exit temporary pins)

## 22.4 FFI-Pinnable Types

Only these types can cross the FFI boundary (Spec §16):

| Zyl Type | C Type | Layout |
|----------|--------|--------|
| `Int` | `int64_t` | 8 bytes |
| `Float` | `double` | 8 bytes |
| `Bool` | `int` (0/1) | 4 bytes |
| `String` | `const char*` | Pointer to null-terminated UTF-8 |
| `Vec<T>` | `ZylVec*` | `{void* data; size_t len; size_t cap;}` |
| Struct | C struct | Fields in declaration order |
| ADT | C struct | Tag byte + payload (largest variant) |

### Composite Types

```lisp
;; Struct with pinnable fields → pinnable
(defstruct Point (x) (y))  ; Both Int

(ffi-call "process_point" (ffi-pin (make-Point 1 2)) 1000)

;; ADT with pinnable fields → pinnable
(deftype Result (Ok Int) (Err String))
;; Both variants pinnable
```

### Non-Pinnable Types

| Type | Reason |
|------|--------|
| `TMut<T>` | Exclusive ownership — can't share |
| `TBox<T>` | Unique ownership — move semantics |
| `TPin<T>` | Already pinned — double pin |
| Closures | Contain function pointers + env |
| Actors (`ActorRef`) | Runtime handles |
| Functions (`TFun`) | Code pointers not portable |

## 22.5 C Function Signatures

### Zyl FFI Types (from `zyl_ffi.h`)

```c
#include "zyl_ffi.h"

typedef int64_t ZylInt;
typedef double ZylFloat;
typedef int ZylBool;
typedef const char* ZylString;

typedef struct {
    void* data;
    size_t len;
    size_t cap;
} ZylVec;

typedef struct {
    void* data;
    size_t len;
    size_t cap;
} ZylMap;
```

### Calling Convention

- **System V AMD64 ABI** (standard on Linux x86_64)
- First 6 integer/pointer args: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`
- First 8 float args: `xmm0`-`xmm7`
- Additional args: stack (right-to-left)
- Return: `rax` (integer/pointer), `xmm0` (float)

### Example C Functions

```c
// mylib.c
#include "zyl_ffi.h"

int64_t zyl_add(int64_t a, int64_t b) {
    return a + b;
}

void zyl_print_string(const char* s) {
    printf("%s", s);
}

int64_t zyl_vec_sum(ZylVec* vec) {
    int64_t sum = 0;
    int64_t* data = (int64_t*)vec->data;
    for (size_t i = 0; i < vec->len; i++) {
        sum += data[i];
    }
    return sum;
}
```

## 22.6 Complete FFI Example

### C Code (`mathlib.c`)

```c
#include "zyl_ffi.h"
#include <math.h>

double zyl_sqrt(double x) {
    return sqrt(x);
}

int64_t zyl_factorial(int64_t n) {
    if (n <= 1) return 1;
    return n * zyl_factorial(n - 1);
}

void zyl_reverse(ZylString input, ZylString output, size_t max_len) {
    size_t len = strlen(input);
    if (len >= max_len) len = max_len - 1;
    for (size_t i = 0; i < len; i++) {
        output[i] = input[len - 1 - i];
    }
    output[len] = '\0';
}
```

### Zyl Code (`ffi-math.zyl`)

```lisp
;; ffi-math.zyl

(defn sqrt (x)
  (ffi-call "zyl_sqrt" (ffi-pin x) 100))

(defn factorial (n)
  (ffi-call "zyl_factorial" (ffi-pin n) 1000))

(defn reverse-string (s)
  (let buf (alloc-malloc 256)
    (ffi-call "zyl_reverse"
      (ffi-pin s)
      (ffi-pin buf)
      (ffi-pin 256)
      1000)
    (let result (cstr-to-string buf)
      (alloc-free buf)
      result)))

(defn main ()
  (print "sqrt(2) = " (sqrt 2.0))
  (print "factorial(5) = " (factorial 5))
  (print "reverse('hello') = " (reverse-string "hello")))
```

### Build and Run

```bash
cc -c mathlib.c -o mathlib.o
zyl ffi-math.zyl   # Links mathlib.o automatically
./ffi-math
```

## 22.7 Timeout Enforcement

- **Mechanism**: `alarm()` signal or watchdog thread
- **Trigger**: C function exceeds `timeout-ms`
- **Result**: `E_FFI_TIMEOUT` error raised in Zyl
- **Safety**: C function interrupted, Zyl state preserved

```lisp
;; 100ms timeout — if C function hangs, Zyl recovers
(ffi-call "potentially_slow_func" (ffi-pin arg) 100)
```

### Choosing Timeout

| Operation | Typical Timeout |
|-----------|-----------------|
| Simple math | 1-10ms |
| String processing | 10-100ms |
| File I/O | 100-5000ms |
| Network | 1000-30000ms |
| Unknown/unsafe | Conservative (short) |

## 22.8 Memory Management Across FFI

### Zyl → C (Pinning)

```lisp
;; Zyl value → Pin region → C gets stable pointer
(ffi-call "c_func" (ffi-pin my-int) 1000)
```

- Zyl retains ownership
- Pin freed after call (or manual `ffi-unpin`)

### C → Zyl (Allocation)

```c
// C allocates, Zyl frees
ZylString zyl_make_string(const char* src) {
    size_t len = strlen(src) + 1;
    char* buf = malloc(len);
    strcpy(buf, src);
    return buf;
}
```

```lisp
(defn c-string-to-zyl (c-ptr)
  (let zyl-str (ffi-call "zyl_make_string" (ffi-pin c-ptr) 100)
    (let result (cstr-to-string zyl-str)
      (ffi-call "free" (ffi-pin zyl-str) 100)  // Free C allocation
      result)))
```

### Shared Ownership

```lisp
;; Zyl allocates, C uses, Zyl frees
(let buf (alloc-malloc 1024)
  (ffi-call "c_fill_buffer" (ffi-pin buf) (ffi-pin 1024) 1000)
  ;; C writes to buf
  (let data (bytes-to-vec buf 1024)
    (alloc-free buf)
    data))
```

## 22.9 Callbacks (C → Zyl)

**Not directly supported**. Workarounds:

### 1. Polling Loop

```lisp
;; Zyl actor polls C queue
(spawn (fn ()
  (while true
    (let event (ffi-call "c_poll_event" 10)
      (match event
        (Some e (handle e))
        (None unit))))))
```

### 2. Global Function Pointer

```c
// C side
void (*zyl_callback)(int event_id) = NULL;

void register_callback(void (*cb)(int)) {
    zyl_callback = cb;
}

void trigger_event(int id) {
    if (zyl_callback) zyl_callback(id);
}
```

```lisp
;; Zyl side — register actor as callback
(let actor (spawn (fn (id) (handle-event id))))
(ffi-call "register_callback" (ffi-pin (actor-to-fnptr actor)) 100)
```

## 22.10 Linking

Zyl links with:
- `actor_runtime.c` (pthread-based actor system)
- `libc` (standard C library)
- Any `.o` files in build directory

```bash
# Automatic
zyl myprog.zyl

# Manual
zyl --emit-asm myprog.zyl
cc myprog.s actor_runtime.o mylib.o -o myprog -lpthread
```

## 22.11 Safety Guarantees

| Guarantee | Mechanism |
|-----------|-----------|
| No use-after-free | Pin region keeps memory alive |
| No buffer overflow | Bounds checked in Zyl; C gets valid pointers |
| No data races | FFI calls serialized per actor |
| No stack corruption | Stack switching for FFI calls |
| No hang | Timeout kills C function |
| No type confusion | Only FFI-pinnable types allowed |

## 22.12 Errors

| Error | Cause |
|-------|-------|
| `E_FFI_TIMEOUT` | C function exceeded timeout |
| `E_FFI_PIN_TYPE` | Non-pinnable type passed to `ffi-pin` |
| `E_FFI_SYMBOL_NOT_FOUND` | C symbol not linked |
| `E_FFI_ARITY_MISMATCH` | Wrong number of arguments |

## 22.13 Best Practices

1. **Minimize FFI surface** — wrap in safe Zyl functions
2. **Set realistic timeouts** — not too short, not too long
3. **Pin at call site** — don't store pinned pointers
4. **Free C allocations** — pair `malloc`/`free` across boundary
5. **Test with sanitizers** — ASAN/UBSAN on C code