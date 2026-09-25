# Appendix E: Migration from Rust/C++

Guide for systems programmers coming from Rust or C++. Each section
maps a familiar idea onto its Zyl counterpart and notes where the
current implementation differs from the specification.

## E.1 From Rust

### Types → Types (Stricter in Places)

Zyl infers types the way Rust infers local ones, but everywhere: a
top-level function needs no signature. The checker is strict, and a
program with a type error does not compile. A few rules are tighter
than Rust's:

- A condition is a `Bool`, as in Rust. `str-eq`, `=`, `<` and the
  library predicates all return `Bool`.
- `+ - * / %` take two `Int`s or two `Float`s, and nothing converts
  between them implicitly: `(+ 1 2.5)` is `E_TYPE_MISMATCH`. Write the
  literal in the type you mean. The one explicit conversion is the
  runtime's `Int -> Float`, `(ffi-call "zyl_f_of_int" n 1000)`; there
  is no general `as`.
- There is no `unsafe` block and no `transmute`. No form changes a
  value's type; the only trusted code is the compiler and its C runtime.
- A statement form (`print`, `set!`, `while`, an `if` without `else`)
  has type `Unit`, like Rust's `()`. `main` returns an `Int`, the exit
  status.

### Ownership → Regions + Capabilities

| Rust | Zyl |
|------|-----|
| `&T` (shared ref) | `TCap` — shared, read-only; what an ordinary `let` gives you |
| `&mut T` (exclusive ref) | `TMut` — exclusive, mutable; a `let-mut` binding |
| `Box<T>` | No box to write: a value that escapes goes on the heap. Spec §4.3 names `TBox<T>` |
| `Pin<&mut T>` | `ffi-pin` copies a value into the non-moving Pin region. Spec §4.3 names `TPin<T>` |
| `Arc<T>` | Share immutable data (`TCap`), or keep the state inside an actor. Spec §4.3 names `TAtomic<T>` |
| `Mutex<T>` | An actor that owns the state; `bytebuf-atomic-*` for counters in a Pin buffer |
| Ownership/borrow checker | `mutability_check` (the `TMut`/`TCap` rules) plus region inference |

**Key difference**: you do not annotate capabilities. `let` versus
`let-mut` decides `TCap` versus `TMut`, and the checker rejects
`set!` on anything that is not a `let-mut` name (`E_MUT_CONFLICT`) and a
`let-mut` variable captured by a spawned closure (`E_CAPABILITY_LEAK`).

### Lifetimes → Regions

```rust
// Rust: explicit lifetimes
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str { ... }
```

```lisp
;; Zyl: no lifetime syntax; regions are the compiler's business
(defn longest (x y) (if (> (str-length x) (str-length y)) x y))
```

Region inference today is conservative: a variant that is only matched
or printed is placed in its function's frame, and everything else goes
on the heap (Chapter 16).

### Traits → Traits (Similar)

```rust
// Rust
trait Drawable { fn draw(&self); }
impl Drawable for Circle { fn draw(&self) { ... } }
c.draw();
```

```lisp
;; Zyl
(trait Drawable (draw (self) Unit))
(impl Drawable Circle (defn draw (self) ...))
(Drawable.draw c)
```

**Differences**:
- A method is called by its qualified name, `(Trait.method receiver ...)`.
- No trait objects (`dyn Trait`); every call is resolved at compile
  time from the receiver's type, as with Rust generics.
- `Self` in a method signature is the implementing type, as in Rust:
  `(trait Ord (compare (self (other Self)) Int))`.
- Derive with `(derive Type Trait ...)`.
- The orphan rule works at the package boundary, as Rust's does at the
  crate boundary (`E_PKG_ORPHAN_IMPL`).

### Generics → Generics (Similar)

```rust
// Rust
fn identity<T>(x: T) -> T { x }
fn min<T: Ord>(a: T, b: T) -> T { ... }
```

```lisp
;; Zyl
(defn identity (x) x)
(defn smaller (a b) (if (< a b) a b))
```

**Differences**:
- Type parameters are inferred, never written: `identity` is generic
  because nothing constrains `x`. `smaller` works on any type `<`
  accepts (`Int`, `Float`, `String`); an ADT is ordered with
  `Ord.compare` instead.
- Specialisations are named canonically, with type arguments sorted
  alphabetically (`min_Int`; `pair_Int_String` for either argument
  order) (§6.4).
- A struct is generic in each field written without a type:
  `(defstruct Box (v))` is a box of any one type.
- No const generics, no GATs and no specialisation (§6.5).

### Error Handling → Result/Option

```rust
// Rust
fn parse(s: &str) -> Result<i64, String> { ... }
let n = parse(s)?;
```

```lisp
;; Zyl
(defn parse (s) (if (> (str-length s) 0) (Ok 42) (Err "empty")))

(match (parse s)
  (Ok n n)
  (Err e 0))
```

**No `?` operator.** Match on the `Result`, or use `core/result`'s
helpers (`result-map`, `result-and-then`, `result-unwrap` with a
default). `try`/`catch` catches a *panic* — what `(error "msg")` raises
— rather than an `Err` value; it is the counterpart of
`std::panic::catch_unwind`, not of `?`. The `unwrap` form panics on
`None` or `Err`, like Rust's, but always with the message `unwrap on
None` (Appendix C.7).

### Pattern Matching → Match (Similar)

```rust
// Rust
match opt {
    Some(x) => x,
    None => 0,
}
match n {
    0 => "zero",
    1 | 2 | 3 if verbose => "small",
    4..=9 => "medium",
    _ => "large",
}
```

```lisp
;; Zyl
(match opt
  (Some x x)
  (None 0))

(match n
  (0 "zero")
  (1 2 3 (when verbose) "small")
  ((range 4 9) "medium")
  (_ "large"))
```

**Differences**:
- Exhaustiveness is mandatory, and `_` must be the last arm.
- Guards `(when cond)` and ranges `(range lo hi)` apply to literal
  patterns only, and a guard can refer only to names bound outside the
  `match`.
- A `match` is either all literal patterns or all constructor
  patterns, never a mix.

### Concurrency → Actors

```rust
// Rust: threads + channels
let (tx, rx) = channel();
let h = thread::spawn(move || { let v = rx.recv().unwrap(); ... });
tx.send(42).unwrap();
h.join().unwrap();
```

```lisp
;; Zyl: actors
(use actor/actor)

(let a (spawn (fn () (print "working")))
  (begin
    (send a 42)
    (actor-wait a)))
```

**Differences**:
- No shared memory between actors, and messages must be Send-capable:
  a `let-mut` variable may not cross (`E_CAPABILITY_LEAK`).
- `spawn` takes a zero-argument closure and returns an `Actor`, the
  type `send` requires. The actor's work is that closure.
- An actor reads its messages with `(receive)`, which blocks until one
  arrives, and `(actor-self)` is its own handle, so a request can carry
  where to send the reply; a message field that carries it is typed
  `Actor`. `main` has a mailbox too. There is no selective receive or
  receive timeout: messages come out in FIFO order.
- Unlike an `mpsc::Receiver<T>`, a mailbox is not typed yet: `receive`
  returns whatever type its use expects, and nothing checks that the
  sender agreed. Typed channels will replace mailboxes.
- There is no `wait-all` form, but every program drains and stops its
  actors when `main` returns. `actor-wait` stops one actor and joins its
  thread; `(ffi-call "zyl_actor_wait_all" 1000)` drains every mailbox and
  then stops all actors.

### Macros → Macros (Different)

```rust
// Rust
macro_rules! max { ($a:expr, $b:expr) => { if $a > $b { $a } else { $b } } }
```

```lisp
;; Zyl: the template is the body; parameters are replaced by the
;; argument expressions, unevaluated
(defmacro my-max (a b) (if (> a b) a b))
```

**Differences**:
- Only template macros; no procedural macros. A template needs no
  quasiquote: parameters are substituted directly, and `&rest body` with
  `,@body` takes the place of `$($x:expr),*`.
- Arguments are spliced in as source, so an argument used twice is
  evaluated twice — as in Rust's `macro_rules!`.
- Hygiene is automatic (§19.2): names a template binds are renamed per
  expansion, and a template cannot see the caller's local variables, so
  pass anything it needs from the call site as an argument.

### Cargo → Packages

| Cargo | Zyl |
|-------|-----|
| `Cargo.toml` | `zyl.pkg`, an S-expression manifest (§31.3) |
| `Cargo.lock` | `zyl.lock`, an integrity record, committed for libraries too (§31.6) |
| `serde = "1.0"` (a range) | `(dep "acme/json" "1.4.0")` — a bare minimum; ranges are `E_PKG_BAD_REQUIREMENT` |
| SAT-style resolution | Minimal Version Selection: the greatest minimum any manifest asks for (§31.5) |
| crates.io | A git-hosted index with mandatory Ed25519 signatures and key pinning (§31.8) |
| `pub` | `(pub defn ...)`; everything else is package-private (§24.4) |
| `[features]` | `(features ...)` and `(feature-gate f definition)`, additive only (§31.10) |
| `build.rs` | Forbidden; C sources are declared in `(native ...)` (§31.10) |
| `[workspace]` | `zyl-workspace.zyl`, one root lock (§31.11) |
| `cargo build` / `cargo test` | `zyl build` / `zyl test` |
| `cargo fetch` | `zyl fetch` — the only command that uses the network |

A package also declares its capabilities — `(capabilities io)` — and
may not do IO, FFI, actors, secrets, native code or `:unsafe` imports
beyond what it declares (§31.9). Rust has no equivalent.

## E.2 From C/C++

### Memory Management → Regions and Arenas

```c
// C: manual
int* arr = malloc(n * sizeof(int));
// ... use arr ...
free(arr);
```

```lisp
;; Zyl: arena-backed collections
(let v (vec-push (vec-create-default n) 7)   ; a private arena
  (vec-get v 0))
```

Ordinary code never calls `malloc` or `free`: values are placed by the
compiler, and collections take their storage from an arena, released
with `arena-reset` or `arena-destroy` (`vec-free` only empties the value; the storage belongs to the arena). `allocator/allocator` exposes
`alloc-malloc` and `alloc-free` for the rare code that needs them.

### Pointers → Capabilities + FFI

```c
// C: a raw pointer to a value the callee may update
void process(int64_t* value);
```

```lisp
;; Zyl: declare the C signature, pin the value, give a timeout,
;; then read the (possibly updated) value back
(extern "process" ((Pin Int)) Unit)
(let slot (ffi-pin 42)
  (let _ (ffi-call "process" slot 1000)
    (ffi-unpin slot)))
```

A pin holds one word. An array goes in a buffer from
`allocator/allocator` (`alloc-malloc`, a `Ptr`).

**No raw pointers in ordinary Zyl** — addresses appear only through
`ffi-pin`, `bytebuf-ptr` and the allocator functions, and an opaque C
address is a `Ptr` that Zyl can only hand back to C. The `extern` is
the prototype a C header would give: an `ffi-call` to a foreign
function without one does not compile (`E_CANNOT_INFER`). Its types are
`Int`, `Bool`, `String`, `Ptr`, the byte handle types, `(Pin a)` for
a pinned slot, `Unit` as a result, and `(Fn (A ...) R)` for a callback; `Float` cannot cross yet.
The trailing timeout is a required integer literal in milliseconds; a
call that overruns it raises `E_FFI_TIMEOUT`.

### Integers and Truth → Bool and No Conversions

```c
// C: an int is a truth value, and arithmetic converts silently
if (count) ...
double avg = total / 2.0;
```

```lisp
;; Zyl: conditions are Bool; Int and Float never mix
(if (!= count 0) ...)
(/ total-f 2.0)        ; total-f is already a Float
```

`(if count ...)` with an `Int` `count` is `E_TYPE_MISMATCH`, as is
`(/ total 2.0)` with an `Int` `total`; convert explicitly with
`(ffi-call "zyl_f_of_int" total 1000)`. There is no cast form, and
nothing like `reinterpret_cast`: a value keeps the type it was built
with.

### Structs → Structs (Similar but Immutable)

```c
// C: mutable
struct Point { int x, y; };
p.x = 10;
```

```lisp
;; Zyl: immutable, rebind
(defstruct Point (x Int) (y Int))
(let-mut p (make-Point 1 2)
  (set! p (make-Point 10 (struct-get p "y"))))
```

**No field mutation** — rebind the whole struct.

### Headers → Modules

```c
// C: header files
// point.h
struct Point { int x, y; };
```

```lisp
;; Zyl: one file is one module; pub marks the exported surface
(pub defstruct Point (x Int) (y Int))
(pub defn origin () (make-Point 0 0))
```

**No header files** — the definition is the declaration. Another
module imports it with `use`, naming the symbols it wants:
`(use geometry { Point origin })`.

### Error Handling → Result

```c
// C: error codes
int result = func();
if (result == -1) handle_error();
```

```lisp
;; Zyl: Result type
(match (func)
  (Ok val val)
  (Err err (handle-error err)))
```

**No error codes** — return a `Result`.

### Concurrency → Actors

```c
// C: pthreads + mutex
pthread_mutex_lock(&lock);
shared_data++;
pthread_mutex_unlock(&lock);
```

```lisp
;; Zyl: no shared state; each actor owns its data
(let worker (spawn (fn () (let-mut count 0 (begin (set! count (+ count 1)) count))))
  (actor-wait worker))
```

**No mutexes** — actors are isolated, and a spawned closure may not
capture a `let-mut` variable from outside it. State that several parts
of a program update lives in one actor, and the others `send` it
messages (E.1).

### Macros → Macros (Different)

```c
// C: textual substitution
#define MAX(a,b) ((a)>(b)?(a):(b))
```

```lisp
;; Zyl: substitution on the AST, then type checking
(defmacro my-max (a b) (if (> a b) a b))
```

**Differences**:
- Operates on the AST, not on text, so no stray-parenthesis surprises.
- Type-checked after expansion.
- Like the C macro, an argument used twice is evaluated twice.

### Build System → Deterministic Pipeline

```makefile
# C: Makefile, timestamps
prog: prog.c
    gcc -o prog prog.c
```

```bash
# Zyl: a single file ...
zyl prog.zyl -o prog
# ... or a package: zyl.pkg + zyl.lock
zyl build --locked
```

**No timestamps** — the same source, lock and compiler give an
identical binary (§27, §31.12). Builds never touch the network.

## E.3 Quick Reference Card

| Concept | Rust | C/C++ | Zyl |
|---------|------|-------|-----|
| Memory safety | Borrow checker | Manual | Regions + `TCap`/`TMut` checks |
| Mutability | `mut` | Default | `let-mut` + `set!` |
| Null | `Option` | `NULL` | `Option` (`None`) |
| Errors | `Result` | Codes/errno | `Result` |
| Generics | Monomorphised | Templates | Monomorphised, canonical names |
| Traits | Traits | Virtual fns | Traits, `(Trait.method x)` |
| Macros | Procedural/declarative | Textual | AST templates |
| Concurrency | Threads + channels | pthreads | Actors |
| Determinism | Configurable | No | Mandatory |
| Truth values | `bool` | Any scalar | `Bool` only |
| Numeric conversion | `as` | Implicit | Explicit only (`zyl_f_of_int`); `Int` and `Float` never mix |
| Unsafe casts | `transmute` | Casts | None |
| FFI | `extern "C"` | Native | `extern` + `ffi-call` + pinning + timeout |
| Packages | Cargo, crates.io | — | `zyl.pkg`, MVS, signed git index |
| Build | `cargo build` | Make/CMake | `zyl build` or `zyl file.zyl` |
