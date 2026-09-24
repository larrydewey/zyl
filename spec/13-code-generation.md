# Zyl Specification — Code Generation

**Canonical authority:** `zyl_specification.txt` §21 (Built-In Operations semantics), §22 steps 8–9
**Related:** `spec/11-icnf-ir.md`, `spec/07-region-memory-model.md`
**Implementation:** `stdlib/compiler/codegen.zyl`, `runtime/actor_runtime.c`

---

The canonical specification fixes only the target (x86_64 native code)
and the pipeline position of code generation and linking (§22). The
sections marked "Implementation" describe the self-hosted backend and are
not normative.

---

## Implementation: Output Format

- Intel syntax: `.intel_syntax noprefix`.
- Sections: `.text` for code; `.rodata` for the print formats (`%lld`,
  `%f`, `%s`), string literals (`.string`) and float literals
  (`.double`). No `.data` or `.bss` section is emitted.
- Labels: `.L<N>`, unique per compile.
- The assembly is linked by `cc` against `runtime/actor_runtime.c` (with
  `pthread`).

## Implementation: Symbols

- A definition's label comes from its canonical symbol key
  (`pkg@major::module::symbol`, §31.2) through the runtime's
  `zyl_mangle_key`, which is injective: `zy_<pkg>_<major>__<module>__<symbol>`
  with the §31.2 escape.
- The few names that carry no key (the generated `main` wrapper, inlined
  builtins, names from a nested compile) keep the older spelling `_ZYL_`
  followed by `zyl_cstr_sanitize` of the name.
- An `ffi-call` target is emitted as `call <sanitized symbol>`.

## Implementation: Entry Point

The emitted `main` saves `argc`/`argv` (`zyl_save_args`), sets up the heap
and pin arenas (`zyl_ensure_arenas`), then runs the program's `main` on a
large reserved stack through `zyl_call_on_big_stack` (see
`spec/07-region-memory-model.md`, §14). The value `main` returns is the
process exit status.

## Implementation: Calling Convention

System V AMD64, 64-bit registers.

| Argument | Register |
|----------|----------|
| 1 | `rdi` |
| 2 | `rsi` |
| 3 | `rdx` |
| 4 | `rcx` |
| 5 | `r8` |
| 6 | `r9` |

Arguments are evaluated left to right into stack scratch slots, arguments
beyond the sixth are pushed, and the registers are then loaded from the
slots. Every value, including a Float's bit pattern, is returned in `rax`.
A call to a closure passes the closure's environment as one extra trailing
argument.

A C call (runtime helper, `printf`, `ffi-call`) with up to six arguments
is wrapped as `mov r12, rsp; and rsp, -16; call ...; mov rsp, r12`, so the
callee sees the 16-byte alignment System V guarantees.

## Implementation: Stack Frame

- Prologue `push rbp; mov rbp, rsp; sub rsp, N`, epilogue
  `mov rsp, rbp; pop rbp; ret`.
- Parameter `i` (from 0) is spilled to `[rbp - 8*(i+1)]`; locals take the
  following 8-byte slots downward.
- The frame size is fixed per function from a slot count of the body,
  rounded to keep 16-byte alignment.
- Expression evaluation is a stack machine that leaves each result in
  `rax`.
- There is no tail-call optimization; every call is a `call`.

## Implementation: Values

- **Int / Bool:** 64-bit integers in `rax`; `true` is 1, `false` is 0.
  Arithmetic is plain `add`/`sub`/`imul`, so overflow wraps; `/` and `%`
  are `cqo; idiv` with no zero test, so integer division by zero raises
  SIGFPE.
- **Float:** loaded from `.rodata` with `movsd xmm0, [rip+label]` and moved
  to `rax` with `movq`; arithmetic uses `xmm0`/`xmm1`, comparison uses
  `comisd`.
- **String:** a pointer to `.rodata` or to runtime memory; `=`, `==` and
  `!=` on strings compare contents.
- **Variant / struct:** a `[tag][field0]...` block from `zyl_heap_alloc`
  (`rdi = 8 * (fields + 1)`), or rbp-relative stores for an
  `IStackVariant`. `match` compares the tag word.
- **Shifts:** counts outside 0–63 are defined: logical shifts give 0,
  `ashr` saturates to the sign bit.
- **`print`:** `printf` with `%lld`, `%f` or `%s` chosen by the value's
  kind, one value per line.
- **`try`/`catch`:** inline `setjmp` with `zyl_try_push`/`zyl_try_pop`.

---

## Built-In Operations (Semantics)

### 21.1 Arithmetic

```
(+ a b ...)       — sum (unary + returns 0)
(- a b)           — difference (unary - returns negation)
(* a b ...)       — product (unary * returns 1)
(/ a b)           — quotient; b!=0 (Int: error, Float: Inf/NaN)
(% a b)           — remainder; sign follows dividend
```

### 21.2 Comparison

```
(== a b)          — structural equality
(!= a b)          — structural inequality
(< a b)           — less than (Int, Float)
(> a b)           — greater than
(<= a b)          — less or equal
(>= a b)          — greater or equal
```

### 21.3 Boolean

```
(not x)           — logical negation
(and a b ...)     — short-circuit AND
(or a b ...)      — short-circuit OR
```

### 21.4 Type Predicates

```
(int? x), (float? x), (bool? x), (string? x)
(struct? x), (alias? x)
```

### 21.5 Collection

```
(len x)           — length of Vec, Map, String
(vec elem...)     — constructs Vec
(map key val...)  — constructs Map (deterministic iteration)
(tuple elems...)  — constructs Tuple
```

### 21.6 Mutation

```
(set! var value)  — rebinding only. Cannot mutate struct fields directly.
```

### 21.7 I/O & Resources

```
(print x ...)     — stdout
(read-line)       — stdin
(exit code)       — terminate
(close handle)    — free resource
```

### 21.8 Error Signaling

```
(error msg)       — returns (Err msg). Does not throw.
```

### 21.9 Sequencing

```
(begin e1 ... en) — returns value of en
```

### 21.10 Iterator Trait

```lisp
(trait Iterator (next () (Option T)))
```

Collections implement this for `for` loops.

### 21.11 Struct Accessors

```lisp
(struct-get struct field-name)
```

Compiler generates field accessors for every defstruct.

### 21.12 Alias Accessors

```lisp
(unwrap alias-val)
```

Explicit extraction (usually implicit).

---

## Implementation Notes on §21

Not normative. Probed with `build/boot/zyl-self`.

- The comparison operators accept `=` as a synonym for `==`.
- The bitwise operators `bit-and`, `bit-or`, `bit-xor`, `bit-not`, `shl`,
  `shr` (logical) and `ashr` are built in; §21 does not list them.
- `(+)` is 0 and `(- x)` is the negation of `x`, as §21.1 states. `(*)`
  evaluates to 0, and so does `(* x)` with a single argument; §21.1 says
  the unary (empty) product is 1.
- `print` with several arguments prints each on its own line.
- Booleans print as `1` and `0`.
- The type predicates of §21.4 (`int?`, `float?`, `bool?`, `string?`,
  `struct?`, `alias?`) and the collection constructors of §21.5 (`len`,
  `vec`, `map`, `tuple`) are not built in: a program that uses them
  without defining them fails at link time. Collections are provided by
  library modules (`stdlib/collections/`, `stdlib/core/list.zyl`,
  `stdlib/core/map.zyl`).
- There is no `Iterator` trait (§21.10); `for` is a counted loop
  (`spec/04-evaluation-semantics.md`).
- `(error msg)` aborts rather than returning `(Err msg)`, and `(unwrap x)`
  evaluates to 0; see `spec/04-evaluation-semantics.md`.
- Byte and atomic primitives (`(byte N)`, `load-u8`/`load-i8`,
  `store-u8`/`store-i8` with an optional `:le`/`:be` endianness selector,
  `byteslice`, `byteslice-sub`, `bytebuf`, `bytebuf-append`, `bytebuf-len`,
  `bytebuf-cap`, `bytebuf-ptr`, `align-check`, and `bytebuf-atomic-load`,
  `-store`, `-add`, `-sub`, `-fetch-add`, `-max`, `-min`, `-cas`) are
  special forms lowered to `zyl_bytebuf_*` runtime calls. The 16-, 32- and
  64-bit `load-`/`store-` widths are reserved and rejected with
  `E_RESERVED_KEYWORD`. `stdlib/atomic/atomic.zyl` wraps the runtime's
  sequentially consistent atomics on raw addresses. None of these are in
  the canonical text.
