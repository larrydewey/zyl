# Chapter 12: FFI and Systems Programming

Zyl's Foreign Function Interface (FFI) lets you call C functions safely. The key principle: **FFI calls require explicit pinning and timeout** — no undefined behavior.

## 12.1 FFI Basics

### Calling C Functions

```lisp
(ffi-call "c_function_name" args... timeout-ms)
```

- `"c_function_name"`: C symbol name (string)
- `args...`: Arguments (must be FFI-pinnable)
- `timeout-ms`: Maximum execution time in milliseconds

```lisp
;; Call C's printf
(ffi-call "printf" (ffi-pin "Hello from C!\n") 1000)

;; Call a math function
(ffi-call "sqrt" (ffi-pin 2.0) 100)
```

### Pinning Values

```lisp
(ffi-pin value)     ; Copy to Pin region, return stable pointer
(ffi-unpin ptr)     ; Explicitly free pinned memory
```

**Pin region**: Non-moving arena. Values physically copied here for FFI. Never compacted.

```lisp
(let pinned (ffi-pin 42)
  (let result (ffi-call "some_func" pinned 1000)
    (ffi-unpin pinned)
    result))
```

## 12.2 FFI-Pinnable Types

Only these types can cross the FFI boundary (Spec §16):

| Zyl Type | C Equivalent | Notes |
|----------|--------------|-------|
| `Int` | `int64_t` | 64-bit signed |
| `Float` | `double` | IEEE-754 binary64 |
| `Bool` | `int` (0/1) | |
| `String` | `const char*` | Null-terminated UTF-8 |
| `Vec<T>` | `{ void* data; size_t len; size_t cap; }` | T must be pinnable |
| Struct/ADT | C struct | All fields pinnable |

### Composite Types

```lisp
;; Struct with pinnable fields → pinnable
(defstruct Point (x) (y))  ; Both Int → pinnable

(ffi-call "process_point" (ffi-pin (make-Point 1 2)) 100)

;; ADT with pinnable fields → pinnable
(deftype Result (Ok Int) (Err String))
;; Both variants pinnable → Result pinnable
```

## 12.3 Writing C Functions for Zyl

### C Signature

```c
// zyl_ffi.h (provided by Zyl)
#include "zyl_ffi.h"

// Function taking Int, returning Int
int64_t zyl_add(int64_t a, int64_t b) {
    return a + b;
}

// Function taking String (const char*)
void zyl_print(const char* s) {
    printf("%s", s);
}

// Function taking Vec<Int>
int64_t zyl_vec_sum(ZylVec* vec) {
    int64_t sum = 0;
    for (size_t i = 0; i < vec->len; i++) {
        sum += ((int64_t*)vec->data)[i];
    }
    return sum;
}
```

### Zyl FFI Types (from `zyl_ffi.h`)

```c
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
} ZylMap;  // Simplified
```

## 12.4 Complete FFI Example

### C Code (`mylib.c`)

```c
#include "zyl_ffi.h"
#include <string.h>

int64_t zyl_factorial(int64_t n) {
    if (n <= 1) return 1;
    return n * zyl_factorial(n - 1);
}

void zyl_reverse_string(ZylString input, ZylString output, size_t max_len) {
    size_t len = strlen(input);
    if (len >= max_len) len = max_len - 1;
    for (size_t i = 0; i < len; i++) {
        output[i] = input[len - 1 - i];
    }
    output[len] = '\0';
}
```

### Zyl Code (`ffi-demo.zyl`)

```lisp
;; Declare external functions
;; (No separate declaration needed — just call)

(defn factorial (n)
  (ffi-call "zyl_factorial" (ffi-pin n) 1000))

(defn reverse-string (s)
  (let buf (alloc-malloc 256)  ; Allocate output buffer
    (ffi-call "zyl_reverse_string"
      (ffi-pin s)
      (ffi-pin buf)
      (ffi-pin 256)
      1000)
    (let result (cstr-to-string buf)  ; Convert C string to Zyl String
      (alloc-free buf)
      result)))

(defn main ()
  (print "Factorial of 5: " (factorial 5))
  (print "Reversed: " (reverse-string "hello")))
```

### Compile and Link

```bash
# Compile C code
cc -c mylib.c -o mylib.o

# Compile Zyl (links automatically with actor_runtime.c)
zyl ffi-demo.zyl

# Or manually:
cc mylib.o actor_runtime.o ffi-demo.s -o ffi-demo
```

## 12.5 Memory Management Across FFI

### Zyl → C (Pinning)

```lisp
;; Zyl value copied to Pin region
;; C receives stable pointer
;; Lifetime: until ffi-unpin or end of ffi-call scope
(ffi-call "c_func" (ffi-pin my-int) 1000)
```

### C → Zyl (Allocation)

```c
// C allocates, returns pointer to Zyl
ZylString zyl_alloc_string(const char* src) {
    size_t len = strlen(src) + 1;
    char* buf = malloc(len);
    strcpy(buf, src);
    return buf;  // Zyl will free via alloc-free
}
```

```lisp
(defn c-str-to-zyl (c-str)
  (let zyl-str (ffi-call "zyl_alloc_string" (ffi-pin c-str) 1000)
    ;; Zyl takes ownership, must free
    (let result (cstr-to-string zyl-str)
      (ffi-call "free" (ffi-pin zyl-str) 100)  // Free C allocation
      result)))
```

## 12.6 Callbacks (C Calling Zyl)

Not directly supported yet. Workaround: use actor message passing.

```lisp
;; Zyl actor that C can notify via global queue
(let callback-actor (spawn (fn (msg) ...)))

;; C calls:
void notify_zyl(int event_id) {
    // Push to global queue that Zyl actor polls
    queue_push(global_queue, event_id);
}
```

## 12.7 Timeout and Safety

### Timeout Enforcement

```lisp
;; If C function runs > 1000ms → E_FFI_TIMEOUT
(ffi-call "slow_function" (ffi-pin 42) 1000)
```

- Implemented via `alarm()` or timer thread
- Kills C function if timeout exceeded
- Prevents hangs from blocking FFI

### No Undefined Behavior

Zyl guarantees:
- **No use-after-free**: Pin region keeps memory alive
- **No buffer overflow**: Bounds checked in Zyl, C gets valid pointers
- **No data races**: FFI calls serialized per actor (or global lock)
- **No stack corruption**: Stack switching for FFI calls

## 12.8 Systems Programming Patterns

### Pattern: File I/O via FFI

```lisp
;; Wrap C's fopen/fread/fclose
(defn file-read (path)
  (let c-path (string-to-cstr path)
    (let handle (ffi-call "fopen" (ffi-pin c-path) (ffi-pin "r") 1000)
      (if (== handle 0)
        (Err "fopen failed")
        (let buf (alloc-malloc 4096)
          (let bytes-read (ffi-call "fread" (ffi-pin buf) (ffi-pin 1) (ffi-pin 4096) (ffi-pin handle) 1000)
            (ffi-call "fclose" (ffi-pin handle) 100)
            (let result (bytes-to-string buf bytes-read)
              (alloc-free buf)
              (Ok result)))))))
```

### Pattern: Memory-Mapped Files

```c
// C side
void* zyl_mmap_file(const char* path, size_t* out_size) {
    int fd = open(path, O_RDONLY);
    struct stat st;
    fstat(fd, &st);
    *out_size = st.st_size;
    void* addr = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    close(fd);
    return addr;
}
```

```lisp
(defn mmap-file (path)
  (let size-ptr (alloc-malloc 8)
    (let addr (ffi-call "zyl_mmap_file" (ffi-pin (string-to-cstr path)) (ffi-pin size-ptr) 5000)
      (let size (load-int size-ptr)
        (alloc-free size-ptr)
        (Ok (make-Slice addr size))))))
```

## 12.9 Linking

Zyl links with:
- `actor_runtime.c` (pthread-based actor system)
- `libc` (standard C library)
- Any `.o` files you provide

```bash
# Automatic (recommended)
zyl myprog.zyl

# Manual
zyl --emit-asm myprog.zyl
cc myprog.s actor_runtime.o mylib.o -o myprog -lpthread
```

## 12.10 Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Forgetting `ffi-pin` | Every arg to `ffi-call` must be pinned |
| Wrong timeout | Set realistic timeout (100ms-5000ms typical) |
| C function never returns | Timeout kills it — check for infinite loops |
| Memory leak | `ffi-unpin` for long-lived pins; C allocations must be freed |
| Type mismatch | Ensure C signature matches Zyl types exactly |

---

## For Experts: Under the Hood

### FFI Call Sequence

```asm
; Zyl side (caller)
; 1. Pin args → Pin region (stable pointers)
; 2. Save Zyl registers (callee-saved)
; 3. Switch to C stack (large guard page)
; 4. Call C function
; 5. Restore Zyl registers
; 6. Unpin args (if not manually managed)
; 7. Return result to Zyl
```

### Pin Region Implementation

```c
// Pin region = separate mmap'd arena
// Never moved, never compacted
// Reference counted for lifetime

struct PinRegion {
    void* base;
    size_t size;
    size_t used;
    RefCount* refs;
};
```

### Timeout Implementation

```c
// SIGALRM handler kills thread
// Or: dedicated watchdog thread
void* ffi_wrapper(void* arg) {
    FFIRequest* req = arg;
    alarm(req->timeout_ms / 1000);
    req->result = req->fn(req->args);
    alarm(0);
    return NULL;
}
```

---

**Next:** [Chapter 13: A Complete Project Walkthrough](ch13-project-walkthrough.md) — building a real Zyl application from start to finish.