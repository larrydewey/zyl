# Appendix E: Migration from Rust/C++

Guide for systems programmers coming from Rust or C++.

## E.1 From Rust

### Ownership → Regions + Capabilities

| Rust | Zyl |
|------|-----|
| `&T` (shared ref) | `TCap<T>` — inferred, read-only |
| `&mut T` (exclusive ref) | `TMut<T>` — inferred, mutable |
| `Box<T>` | `TBox<T>` — explicit heap allocation |
| `Pin<&mut T>` | `TPin<T>` — FFI via `ffi-pin` |
| `Arc<T>` | `TCap<T>` (immutable) or `TAtomic<T>` (mutable) |
| `Mutex<T>` | `TAtomic<T>` for simple cases; actors for complex |
| Ownership/borrow checker | Region inference + capability types |

**Key difference**: Zyl infers capabilities — you rarely annotate them.

### Lifetimes → Regions

```rust
// Rust: explicit lifetimes
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str { ... }

// Zyl: inferred regions
(defn longest (x y) ...)  // Regions inferred from usage
```

### Traits → Traits (Similar)

```rust
// Rust
trait Drawable { fn draw(&self); }
impl Drawable for Circle { ... }

// Zyl
(trait Drawable (draw (self T) Unit))
(impl Drawable Circle (defn draw (self) ...))
```

**Differences**:
- Zyl: no trait objects (`dyn Trait`) yet
- Zyl: derive via `(:derive [])` or `(derive Type [Traits])`
- Zyl: orphan rule same

### Generics → Generics (Similar)

```rust
// Rust
fn identity<T>(x: T) -> T { x }
fn min<T: Ord>(a: T, b: T) -> T { ... }

// Zyl
(defn identity ((T) x) x)
(defn min ((T : Ord) a b) ...)
```

**Differences**:
- Zyl: type params in separate parens `(T)`
- Zyl: canonical naming alphabetical (`min_Int`, not `min_Int_Int`)
- Zyl: no const generics, no GATs, no specialization

### Error Handling → Result/Option

```rust
// Rust
fn read() -> Result<String, Error> { ... }
let x = read()?;

// Zyl
(defn read () (Result String String))
(try (read) (catch err ...))
```

**No `?` operator** — use `try/catch` or `match`.

### Pattern Matching → Match (Similar)

```rust
// Rust
match opt {
    Some(x) => x,
    None => 0,
}

// Zyl
(match opt
  (Some x x)
  (None 0))
```

**Differences**:
- Zyl: mandatory exhaustiveness
- Zyl: wildcards must be named (`d1`, not `_`)
- Zyl: no guards (`if` in body instead)

### Concurrency → Actors

```rust
// Rust: threads + channels
let (tx, rx) = channel();
thread::spawn(move || tx.send(42));
let val = rx.recv();

// Zyl: actors
(let actor (spawn (fn (msg) ...)))
(send actor 42)
```

**Differences**:
- Zyl: no shared memory between actors
- Zyl: deterministic scheduling
- Zyl: `wait_all` for synchronization

### Macros → Macros (Different)

```rust
// Rust: procedural or declarative
macro_rules! vec { ($($x:expr),*) => { ... } }

// Zyl: template-based, hygienic
(defmacro my-vec (elements...)
  `(vec-create ,@elements))
```

**Differences**:
- Zyl: only template macros (no procedural)
- Zyl: hygiene automatic (gensym)
- Zyl: innermost-first expansion

## E.2 From C/C++

### Memory Management → Regions

```c
// C: manual
int* arr = malloc(n * sizeof(int));
// ... use arr ...
free(arr);

// Zyl: automatic
(let arr (vec-create 0 n))
;; ... use arr ... (freed when scope exits)
```

**No `malloc`/`free`** — region system handles it.

### Pointers → Capabilities + FFI

```c
// C: raw pointers
void process(int* data, size_t len);

// Zyl: FFI with pinning
(ffi-call "process" (ffi-pin data) (ffi-pin len) 1000)
```

**No raw pointers in safe Zyl** — only via `ffi-pin`.

### Structs → Structs (Similar but Immutable)

```c
// C: mutable
struct Point { int x, y; };
p.x = 10;

// Zyl: immutable, rebind
(defstruct Point (x) (y))
(let-mut p (make-Point 1 2)
  (set! p (make-Point 10 (struct-get p "y"))))
```

**No field mutation** — rebind entire struct.

### Headers → Modules

```c
// C: header files
// point.h
struct Point { int x, y; };

// Zyl: modules
(module geometry)
(export Point)
(defstruct Point (x) (y))
```

**No header files** — single source of truth.

### Error Handling → Result

```c
// C: error codes
int result = func();
if (result == -1) handle_error();

// Zyl: Result type
(match (func)
  (Ok val val)
  (Err err (handle-error err)))
```

**No error codes** — `Result` type.

### Concurrency → Actors

```c
// C: pthreads + mutex
pthread_mutex_t lock;
pthread_mutex_lock(&lock);
shared_data++;
pthread_mutex_unlock(&lock);

// Zyl: actors (no shared state)
(spawn (fn (msg)
  (match msg
    (Inc (set! count (+ count 1))))))
```

**No mutexes** — actor isolation.

### Macros → Macros (Different)

```c
// C: textual substitution
#define MAX(a,b) ((a)>(b)?(a):(b))

// Zyl: hygienic, typed
(defmacro max (a b)
  `(if (> ,a ,b) ,a ,b))
```

**Differences**:
- Zyl: hygienic (no capture)
- Zyl: operates on AST, not text
- Zyl: type-checked after expansion

### Build System → Deterministic Pipeline

```makefile
# C: Makefile, timestamps
prog: prog.c
    gcc -o prog prog.c

# Zyl: deterministic pipeline
zyl prog.zyl
# Same source → identical binary every time
```

**No timestamps** — determinism guaranteed.

## E.3 Quick Reference Card

| Concept | Rust | C/C++ | Zyl |
|---------|------|-------|-----|
| Memory safety | Borrow checker | Manual | Region inference |
| Mutability | `mut` | Default | `let-mut` + `set!` |
| Null | `Option` | `NULL` | `Option` (`None`) |
| Errors | `Result` | Codes/errno | `Result` |
| Generics | Monomorphized | Templates | Monomorphized |
| Traits | Traits | Virtual fns | Traits |
| Macros | Procedural/declarative | Textual | Hygienic template |
| Concurrency | Threads + channels | pthreads | Actors |
| Determinism | Configurable | No | Mandatory |
| FFI | `extern "C"` | Native | `ffi-call` + pinning |
| Build | Cargo | Make/CMake | `zyl` (pipeline) |