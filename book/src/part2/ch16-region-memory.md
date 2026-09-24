# Chapter 16: Region-Based Memory Model

This chapter is the reference for Zyl's memory model: the five regions,
the rules that assign values to them, escape analysis and reclamation.
The normative text is `zyl_specification.txt` §9 (region system), §13
(memory operations), §14 (stack safety) and principle P4 in §0. The
implementation is `stdlib/compiler/region_inference.zyl` together with the
allocators in `runtime/actor_runtime.c`.

The specification describes a complete static region system. The
self-hosted compiler implements a small, safe part of it, so each section
below separates the rule from what the compiler does today.

## 16.1 Regions

§9 defines five regions, and §13 says what each is for.

| Region | Purpose (§13) | Implementation today |
|--------|---------------|----------------------|
| **Stack** | automatic, scope-based allocation | Parameters and `let` locals live in the function's frame. One kind of ADT value is also stack-allocated (16.3). |
| **Heap** | escaped values and captured closure variables | Every other ADT value, struct and capturing closure comes from `zyl_heap_alloc`, a bump allocator over one process-wide arena. |
| **Global** | immutable constants only | Not implemented. A top-level `def` is currently not visible to later functions (Chapter 14). String literals are placed in read-only data. |
| **Circular** | detected cyclic structures | Not implemented. There is no cycle detection. |
| **Pin** | FFI-safe memory (non-moving arena) | `ffi-pin` copies a one-word value into a separate pin arena and returns a stable pointer; `ffi-unpin` validates that pointer and reads the value back (16.6). |

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
| R1 | Met for one proven shape (16.3). All other values go to the heap, which is always safe. |
| R2, R5 | Met trivially: anything not proven to stay local is heap-allocated, and a closure's captured values are copied into a heap environment block. |
| R3 | Checked syntactically: a `spawn` closure or a `send` message that refers to an in-scope `let-mut` variable is `E_CAPABILITY_LEAK` (Chapter 17). |
| R4 | The FFI_Pinnable half is checked (`E_INVALID_CAPABILITY`). The Pin-region half is not: plain values may be passed straight to `ffi-call`. Only a `Secret` must go through `ffi-pin` (`E_FFI_PIN_REQUIRED`). |
| R6 | Not implemented. |
| R7 | Not implemented. |
| R8 | Implemented by the pin arena. |

## 16.3 Escape Analysis

§9.1 says a value escapes when it is returned, captured by an escaping
closure, or sent to an actor (R2), and that an FFI value belongs in the
Pin region (R4).

The compiler proves non-escape for exactly one shape. After optimization
and just before code generation, `ri-transform-fns` looks at every
`(let x (Variant ...) body)`. When every use of `x` in `body` is either
the subject of a `match` or an argument to `print`, the construction is
rewritten to a stack allocation in the current frame. Any other use keeps
it on the heap:

- passing `x` to a function;
- storing it in another value;
- returning it;
- referring to it at all inside a nested `fn`.

A missed case costs an allocation. It can never produce a dangling
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

;; Heap: `s` is passed to a function.
(defn passed-area ()
  (let s (Square 4)
    (area s)))

;; Heap: the value is returned.
(defn make-circle (r) (Circle r))

;; Heap: a capturing closure's environment.
(defn make-adder (n)
  (fn (x) (+ x n)))

(defn main ()
  (let add5 (make-adder 5)
    (begin
      (print (local-area))            ; 16
      (print (passed-area))           ; 16
      (print (area (make-circle 1)))  ; 3
      (print (add5 3))                ; 8
      0)))
```

A value handed to C is copied into the Pin region by `ffi-pin` (Chapter
22):

```lisp
(defn main ()
  (let p (ffi-pin 42)
    (begin
      (ffi-unpin p)
      0)))
```

## 16.4 Region Inference Algorithm

The specification assigns regions in Phase 4, "Region Inference + Capture
Analysis" (§22), but does not prescribe an algorithm.

The compiler once had a general two-pass design that assigned
Stack/Heap/Global/Circular/Pin to every value. Nothing downstream read its
result, and it never raised `E_REGION_ESCAPE`, so it was deleted.
`region_inference.zyl`'s header records the history. What remains is the
rewrite described in 16.3, and it runs later than the specification
places it: on ICNF, after optimization (§22 steps 6–7), rather than
before monomorphization.

## 16.5 Region Annotations

§18 describes every ICNF value as a pair `(SSA_ID, Region)`. ICNF nodes in
the implementation carry no region. The only place a region appears in a
type is the parameter of `ByteBuf` and `ByteSlice` (Chapter 15). There
the region is compared during unification, but a mismatch is not
reported, and the runtime allocator ignores it.

## 16.6 Reclamation

The specification promises region-based reclamation without a garbage
collector (P4). What happens today:

| Region | Reclamation |
|--------|-------------|
| Stack | On function return, by restoring the stack pointer. |
| Heap | Never during the program. The heap arena is a bump allocator that generated code does not reset or free; heap values live until the process exits. |
| Global | Not applicable (not implemented). |
| Circular | Not applicable (not implemented). |
| Pin | §16 says `ffi-unpin` frees pinned memory. In the runtime, `ffi-unpin` checks that the pointer came from the pin arena and returns the pinned value; the slot itself is not freed, because the pin arena reclaims storage only in bulk. |

Allocation failure, or exceeding the memory budget, is reported as
`E_OUT_OF_MEMORY` instead of crashing on a null pointer. The budget is
`ZYL_MAX_MEMORY` when that variable is set (0 disables it), and otherwise
80% of available memory.

### Stack safety (§14)

§14 guarantees that deep recursion never overflows the stack. The code
generator turns direct tail calls with at most six arguments into
jumps; for every other call, the generated `main` runs on a thread with a very large stack: a 64 GB reservation
(falling back to 16, 4 or 1 GB) mapped without committing memory, with a
guard page. Recursion depth is therefore bounded by that reservation
rather than unbounded.

## 16.7 Region Errors

| Code | Status |
|------|--------|
| `E_REGION_ESCAPE` | In §28; catalogued, never raised. |
| `E_CAPABILITY_LEAK` | Raised for a `let-mut` variable reaching `spawn` or `send` (R3; Chapter 17). |
| `E_INVALID_CAPABILITY` | Raised for a non-FFI_Pinnable value given to `ffi-call` or `ffi-pin` (R4). |
| `E_FFI_PIN_REQUIRED` | Raised for a `Secret` passed to `ffi-call` without `ffi-pin` (Chapter 17). |
| `E_OUT_OF_MEMORY` | Raised at runtime when an allocation fails or the budget is exhausted. |
| `E_STACK_BYTEBUF_RETURN`, `E_GLOBAL_BYTEBUF_MUT`, `E_BYTEBUF_NOT_PIN` | Catalogued for the byte primitives; not raised by the compiler. |

## 16.8 Interaction with Capabilities

The specification ties the two systems together through R3 and R4.

| Capability | Spec placement | Today |
|------------|----------------|-------|
| `TCap<T>` | Stack, or Heap when it escapes | As 16.1. |
| `TMut<T>` | must not cross an actor boundary | `let-mut` captures in `spawn`/`send` are rejected. |
| `TAtomic<T>` | Send-capable, shared | Atomics exist as operations on addresses and byte buffers, not as a type (Chapter 17). |
| `TBox<T>` | Heap | No source construct produces it. |
| `TPin<T>` | Pin | The type of an `ffi-pin` result. |

## 16.9 Determinism

The region rewrite is a pure function of the ICNF tree. It uses no
hashing, heuristics or randomness, so the same program always gets the
same allocation decisions. The self-hosting fixed point (Chapter 31)
checks this on the compiler's own source on every `./boot.sh`. Memory
layout is not observable behavior (§27).

## 16.10 Practical Guidance

1. **Let the compiler decide.** There is no syntax for choosing a region,
   and none is needed for correctness.
2. **To keep a short-lived ADT value on the stack**, construct it with
   `let` and only `match` on it or `print` it in the body.
3. **Expect long-running programs to grow.** Heap values are not reclaimed
   before exit. Code that allocates without bound should use an explicit
   arena from `allocator/allocator` (`arena-create`, `arena-alloc`), as
   the compiler itself does.
4. **Unpin what you pin**, and remember that only `Secret` values are
   forced through `ffi-pin` today.
