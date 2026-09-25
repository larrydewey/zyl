# Chapter 16: Region-Based Memory Model

This chapter is the reference for Zyl's memory model: the five regions,
the rules that assign values to them, escape analysis and reclamation.
The normative text is `zyl_specification.txt` §9 (region system), §13
(memory operations), §14 (stack safety) and principle P4 in §0. The
implementation is `stdlib/compiler/region_inference.zyl` together with the
allocators in `runtime/actor_runtime.c`.

The specification describes a complete static region system. The
self-hosted compiler implements the Stack, Heap and Pin regions with
region inference and per-call reclamation, plus explicit `with-region`
scopes; Global and Circular remain names only. Each section below
separates the rule from what the compiler does today. The design and its
history are in `docs/regions-design.md`.

## 16.1 Regions

§9 defines five regions, and §13 says what each is for.

| Region | Purpose (§13) | Implementation today |
|--------|---------------|----------------------|
| **Stack** | automatic, scope-based allocation | Parameters and `let` locals live in the function's frame. An ADT value, struct or runtime string that does not outlive its call is allocated in the call's own **frame region**, released on return; one shape is placed directly in the frame (16.3). A `(bytebuf Stack N)` lives in the frame region. |
| **Heap** | escaped values and captured closure variables | Values the analysis cannot bound come from `zyl_heap_alloc`, a bump allocator over one process-wide arena. |
| **Global** | immutable constants only | A top-level `def` is an immutable global, evaluated once, in source order, before `main` or the tests run (Chapter 14). String literals are placed in read-only data. |
| **Circular** | detected cyclic structures | Not implemented. There is no cycle detection. |
| **Pin** | FFI-safe memory (non-moving arena) | `ffi-pin` copies a one-word value into a separate pin arena and returns a stable pointer; the pointer has type `(Pin a)`, and `ffi-unpin` validates it and returns the value in the slot (16.6). |

## 16.2 Region Rules (Normative, §9.1)

```
R1. Local stack allocation: If variable does not escape → Stack.
R2. Escape allocation: If returned, captured by escaping closure, or sent to actor → Heap.
R3. Actor transfer: spawn/send requires Send-capable type.
R4. FFI rule: ffi-call requires Pin region AND FFI_Pinnable type.
R5. Closure capture promotion: Escaping closure captures promoted to Heap.
R6. Cyclic structures: Cyclic references detected among heap values → Circular region.
R7. Global Region: Immutable constants only. Eager initialization. No mutation allowed.
R8. Pin Region: Non-moving arena. Values physically copied here for FFI. Never compacted.
```

§7.4 adds that a Send-capable capture is `TCap` or `TAtomic`.

How each rule is met today:

| Rule | Status |
|------|--------|
| R1 | Met by region inference (16.3–16.4): a value that does not outlive its call goes in the call's frame region. |
| R2, R5 | A value returned from a call goes in the region its caller chose for the result, and ends in the heap only if it escapes further. A closure and its captured values are allocated the same way. Anything the analysis cannot bound is heap-allocated. |
| R3 | Checked syntactically: a `spawn` closure or a `send` message that refers to an in-scope `let-mut` variable is `E_CAPABILITY_LEAK` (Chapter 17). |
| R4 | The FFI_Pinnable half is met by `extern` declarations, whose C types are concrete machine-word types that every argument must match (Chapter 22). The Pin-region half is not: plain values may be passed straight to `ffi-call`. Only a `Secret` must go through `ffi-pin` (`E_FFI_PIN_REQUIRED`). |
| R6 | Not implemented. |
| R7 | A top-level `def` is immutable and eagerly initialized; its value lives in the heap. |
| R8 | Implemented by the pin arena. |

## 16.3 Escape Analysis

§9.1 says a value escapes when it is returned, captured by an escaping
closure, or sent to an actor (R2), and that an FFI value belongs in the
Pin region (R4).

The compiler classifies every allocation into one of three levels,
ordered frame < result < heap:

- **Frame (L).** The value does not outlive the current call. It goes in
  the call's own region, released when the call returns, before a tail
  jump, or when a caught panic or a failing test unwinds the frame.
- **Result (R).** The value may be part of the call's result but goes no
  further. It goes in the region the caller chose for the result. Every
  call passes that region implicitly, so a function is polymorphic in the
  region of its result.
- **Heap (H).** The value escapes in a way the compiler does not track:
  stored in a global, sent to an actor, handed to foreign code, passed to
  a closure called through an unknown function value, or passed to a
  runtime function not known to be region-safe.

In addition, a `(let x (Variant ...) body)` in which every use of `x` is
the subject of a `match` or an argument to `print` is placed directly in
the stack frame (`ri-transform-fns`).

A missed case costs a heap allocation. It can never produce a dangling
pointer.

```lisp
(deftype Shape (Circle Int) (Square Int))

(defn area (s)
  (match s
    (Circle r (* 3 (* r r)))
    (Square n (* n n))))

;; Stack: `s` is only ever the subject of a match.
(defn local-area ()
  (let s (Square 4)
    (match s
      (Circle r r)
      (Square n (* n n)))))

;; Result region: `area` does not keep `s`, but the call is a tail call,
;; so `s` goes in the region the caller of `passed-area` chose.
(defn passed-area ()
  (let s (Square 4)
    (area s)))

;; Result region: the value is returned, so it goes where the caller says.
(defn make-circle (r) (Circle r))

;; Result region: the closure and its environment are returned.
(defn make-adder (n)
  (fn (x) (+ x n)))

(defn main ()
  (let add5 (make-adder 5)
    (begin
      (print (local-area))            ; 16
      (print (passed-area))           ; 16
      (print (area (make-circle 1)))  ; 3: the circle lives in main's frame region
      (print (add5 3))                ; 8
      0)))
```

A value handed to C is copied into the Pin region by `ffi-pin` (Chapter
22):

```lisp
(defn main ()
  (let p (ffi-pin 42)             ; a (Pin Int)
    (begin
      (print (ffi-unpin p))       ; 42
      0)))
```

## 16.4 Region Inference Algorithm

The specification assigns regions in Phase 4, "Region Inference + Capture
Analysis" (§22), but does not prescribe an algorithm. The implementation
runs later than the specification places it: on ICNF, after optimization
(§22 steps 6–7), rather than before monomorphization. `pipeline.zyl` runs
the stack-variant rewrite `ri-transform-fns` and then `rg-regions`.
Optimization includes inlining: a call of a small, non-recursive function
with `Int`-kind parameters (at most 6 ICNF nodes, `ZYL_INLINE_LIMIT`; no
`try`, region scope, lambda, closure call or `print` in it) is replaced
by its body, except inside a `try` body. Because inlining comes first, the
inlined code is placed like any other code of its caller. `ZYL_INLINE=0`
turns it off.

- **Object classes.** Values that may point to each other share an
  abstract object class, kept in a union-find structure. Classes are
  field-insensitive: a variant, its fields and anything read out of it
  share one class. A node the type pass proves to be `Int`, `Bool` or
  `Float` never joins a class. The level belongs to the class.
- **Constraints.** `let` gives the name its value's class; `set!`, the
  branches of `if` and `match`, and a `match` subject with its binders
  are unified; a constructor unifies its fields with the new object. A
  call in tail position makes each argument at least R, because the frame
  is gone when the callee runs. A call through a function value makes its
  arguments H and unifies the result with the closure's class. A foreign
  `ffi-call` makes its arguments H.
- **Runtime functions.** Only functions in an explicit table
  (`rg-ffi-kind`) are trusted. The fresh-result producers
  (`zyl_cstr_concat`, `zyl_cstr_substr`, `zyl_cstr_from_byte`,
  `zyl_int_text`, `zyl_f_text`, `zyl_file_read_c`) have region-aware
  `_r` entry points that compiled code calls from annotated sites; any
  other runtime function keeps its arguments and result in the heap.
- **Summaries.** Each function has a summary per parameter: 0 (does not
  escape), 1 (may reach the result) or 2 (escapes), plus a flag for
  "may allocate into its result region". A call applies the callee's
  summary to its arguments. Summaries are recomputed over the whole
  program until none changes; each new summary is joined with the old
  one (per-parameter maximum), because the constraints are not monotone
  in the summary and plain replacement could cycle forever.

`ZYL_REGIONS=0` at compile time makes every site H, the behaviour before
region inference existed.

## 16.5 Region Annotations

§18 describes every ICNF value as a pair `(SSA_ID, Region)`. ICNF is still
a tree, not SSA, and nodes carry no region field; instead the analysis
records its decision for each allocation and call site in a side table
keyed by the node (frame, result, heap, or the enclosing `with-region`
scope), plus flags on each function (has a frame region, keeps its result
region). The ICNF printer shows a site's annotation as ` @r`, so the ICNF
hash of a package build covers region decisions (Chapter 28).

In types, the region appears as the parameter of `ByteBuf` and
`ByteSlice` (Chapter 15), but the type pass does not tell two regions
apart; a buffer's region is enforced here, by `E_REGION_ESCAPE`.

### Explicit regions: `with-region`

The region extension registry is closed: a program asks for one of two
audited kinds, and the allocations in the body go to it.

```lisp
(with-region (arena :block B :align A :limit L) body)
(with-region (fixed :size S :align A) body)
```

An `arena` grows in blocks of `B` bytes (a multiple of 4096, at most
64 MiB) up to `L` bytes in total (0: no limit). A `fixed` region holds
exactly `S` bytes. `A` is a power of two from 8 to 4096 (default 8). The
region is released when `body` ends, including when a panic unwinds out
of it.

- A malformed spec is `E_REGION_SPEC` at compile time.
- Running out is `E_REGION_EXHAUSTED` at run time, catchable with `try`.
  It depends only on the sequence of allocation requests (blocks are
  page-aligned, so padding is the same on every run), so it is
  deterministic.
- A value allocated inside the scope that reaches the body's result, or
  anything longer-lived, is `E_REGION_ESCAPE` at compile time.

```lisp
(defn build (n acc)
  (if (= n 0) acc (build (- n 1) (Cons n acc))))

(defn total (l)
  (match l (Nil 0) (Cons h t (+ h (total t)))))

(defn small-total (n)
  (with-region (fixed :size 4096)
    (total (build n Nil))))

(defn main ()
  (begin
    (print (small-total 10))                      ; 55
    (print (try (small-total 1000) (catch _ -1))) ; -1: E_REGION_EXHAUSTED
    0))
```

The REPL's interpreter ignores regions (it allocates in its own arenas),
so byte limits are enforced only in compiled code.

## 16.6 Reclamation

The specification promises region-based reclamation without a garbage
collector (P4). What happens today:

| Region | Reclamation |
|--------|-------------|
| Stack | On function return, by restoring the stack pointer. |
| Frame region | On function return, before a tail jump, or when a caught panic or failing test unwinds the frame. Its blocks go back to a per-thread pool. A self tail call (a loop) instead empties the region and keeps its first block for the next iteration (`zyl_region_recycle`). |
| Result region | Along with the caller's region it was allocated in. |
| `with-region` scope | When the body ends or is unwound. |
| Heap | Never during the program. The heap arena is a bump allocator that generated code does not reset or free; values that escape to the heap live until the process exits. |
| Global | Top-level `def` values live in the heap. |
| Circular | Not applicable (not implemented). |
| Pin | §16 says `ffi-unpin` frees pinned memory. In the runtime, `ffi-unpin` checks that the pointer came from the pin arena and returns the value in the slot; the slot itself is not freed, because the pin arena reclaims storage only in bulk. |

Region blocks come in four size classes (1, 4, 16 and 64 KiB): a
region's first block is the smallest and each further block is the next
class up, so a deep recursion that keeps a little local data in every
frame costs about 1 KiB a frame. Blocks are taken from per-thread pools
carved from `mmap`ed chunks, and count against the same memory budget as the heap.
`zyl_region_live_bytes` reports the bytes held by live regions; a program
that builds and drops 20000 lists fell from a 630 MB to a 12 MB peak with
per-call regions. The compiler's own peak barely moves, because its data
mostly escapes into its results or into global tables.

### In-place reuse

Values are immutable, but an update that builds a new record from an old
one (a `vec-push`, a struct with one field changed, a list rebuilt cell by
cell) need not allocate. After region inference, `compiler/reuse.zyl`
marks a construction that may take the block of a value that is provably
unique (bound to a fresh value, and never stored, aliased, captured or
passed where its region summary lets it escape) and dead (not used later
in evaluation order, and not bound outside a loop the construction is
in). The new record must hold a pointer read out of the old one, so
region inference has already put both in one class and one region. A
function whose parameters could be reused this way gets an owning copy,
`f~own`, called where the arguments are owned and dead. At run time the
block is taken only when its size header covers the new record. Only
functions compiled by the register-allocating backend (Chapter 29) honour
the mark; the stack-machine code path and the REPL interpreter allocate
as before, so the program's meaning cannot change.
`ZYL_REUSE=0` turns the pass off.

Allocation failure, or exceeding the memory budget, is reported as
`E_OUT_OF_MEMORY` instead of crashing on a null pointer. The budget is
`ZYL_MAX_MEMORY` when that variable is set (0 disables it), and otherwise
80% of available memory.

### Stack safety (§14)

§14 guarantees that deep recursion never overflows the stack. The code
generator turns tail calls into jumps (§3 has the exceptions); for every
other call, the generated `main` runs on a thread with a very large stack: a 64 GB reservation
(falling back to 16, 4 or 1 GB) mapped without committing memory, with a
guard page. Recursion depth is therefore bounded by that reservation
rather than unbounded.

## 16.7 Region Errors

| Code | Status |
|------|--------|
| `E_REGION_ESCAPE` | Raised at compile time, with a location, for a `(bytebuf Stack N)` that is returned, stored, sent or passed to code that may keep it, and for a value allocated inside `with-region` that outlives it. |
| `E_REGION_SPEC` | Raised at compile time for a malformed `with-region` spec. |
| `E_REGION_EXHAUSTED` | Raised at run time when a `with-region` scope runs out of space; catchable. |
| `E_CAPABILITY_LEAK` | Raised for a `let-mut` variable reaching `spawn` or `send` (R3; Chapter 17). |
| `E_INVALID_CAPABILITY` | Raised for a `fn` written directly as an `ffi-call` argument (R4). |
| `E_FFI_PIN_REQUIRED` | Raised for a `Secret` passed to `ffi-call` without `ffi-pin` (Chapter 17). |
| `E_OUT_OF_MEMORY` | Raised at runtime when an allocation fails or the budget is exhausted. |
| `E_STACK_BYTEBUF_RETURN`, `E_GLOBAL_BYTEBUF_MUT`, `E_BYTEBUF_NOT_PIN` | Catalogued for the byte primitives; not raised. A returned Stack bytebuf is reported as `E_REGION_ESCAPE`. |

## 16.8 Interaction with Capabilities

The specification ties the two systems together through R3 and R4.

| Capability | Spec placement | Today |
|------------|----------------|-------|
| `TCap<T>` | Stack, or Heap when it escapes | As 16.1. |
| `TMut<T>` | must not cross an actor boundary | `let-mut` captures in `spawn`/`send` are rejected. |
| `TAtomic<T>` | Send-capable, shared | Atomics exist as operations on addresses and byte buffers, not as a type (Chapter 17). |
| `TBox<T>` | Heap | No source construct produces it. |
| `TPin<T>` | Pin | `ffi-pin` copies the value into the pin arena; the result has type `(Pin a)`. |

## 16.9 Determinism

Region inference is a pure function of the ICNF tree: functions are
visited in program order, the summaries reach the same fixpoint every
time, and nothing is hashed or iterated in an unspecified order, so the
same program always gets the same allocation decisions. Because the
decisions are printed in the ICNF, a package build's ICNF hash records
them. The self-hosting fixed point (Chapter 31)
checks this on the compiler's own source on every `./boot.sh`. Memory
layout is not observable behavior (§27).

## 16.10 Practical Guidance

1. **Let the compiler decide.** Region inference needs no annotations,
   and temporaries that do not outlive their call are reclaimed on
   return.
2. **Keep temporaries away from globals, actors and function values.**
   Storing, sending, or passing a value through an unknown function value
   sends its whole class to the heap.
3. **Use `with-region` for a bounded phase** whose result is a number or
   data built outside it; the compiler rejects a result that points into
   the region.
4. **Expect data that escapes to the heap to stay.** Heap values are not
   reclaimed before exit. Long-lived collections that churn should use an
   explicit arena from `allocator/allocator` (`arena-create`,
   `arena-alloc`), as the compiler itself does.
5. **Pin only what C must reach through a pointer.** A pinned slot is
   not freed before exit, even after `ffi-unpin` reads it, and only
   `Secret` values are forced through `ffi-pin` today.
