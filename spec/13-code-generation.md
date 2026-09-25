# Zyl Specification — Code Generation

**Canonical authority:** `zyl_specification.txt` §21 (Built-In Operations semantics), §22 steps 8–9
**Related:** `spec/11-icnf-ir.md`, `spec/07-region-memory-model.md`
**Implementation:** `stdlib/compiler/codegen.zyl`, `stdlib/compiler/mir.zyl` (MIR, liveness, linear-scan allocation), `runtime/actor_runtime.c`

---

The canonical specification fixes only the target (x86_64 native code)
and the pipeline position of code generation and linking (§22). The
sections marked "Implementation" describe the self-hosted backend and are
not normative.

---

## Implementation: Two Emitters

Each function is compiled by one of two emitters that share one ABI, so
they call each other freely (`docs/native-backend-design.md`):

- **The native path.** A function whose ICNF is in the supported set
  (`mb-eligible`, `ml-ok`: constants, locals, function references,
  integer operators, `if`, `while`, `let`, `set!`, sequences, direct
  user calls and runtime calls with at most six arguments, byte
  access, variants, stack variants, `match`, string, Float and symbol
  constants, frame and result regions) and has at most six parameters is
  lowered to MIR (`mir.zyl`), a linear three-address IR over virtual
  registers. Liveness is computed over the instruction order, and
  registers are assigned by linear scan over `rsi`, `rdi`, `r8`, `r9`,
  `r10` and the callee-saved `rbx`, `r12`–`r15` (a value live across a
  call gets a callee-saved register; only the ones used are saved);
  what does not fit is spilled to a frame slot. Every step depends on
  instruction order alone, so the assignment is deterministic.
- **The stack machine.** Every other function: one that uses Float
  arithmetic, string or other non-integer operators, `print`, closures
  or calls through a local, `try`, a `with-region` scope, more than six
  parameters, or whose frame is wiped because it holds a Secret.
  `ZYL_MIR=0` at compile time sends every function here.

## Implementation: Output Format

- Intel syntax: `.intel_syntax noprefix`.
- Sections: `.text` for code; `.rodata` for the print formats (`%lld`,
  `%f`, `%s`), string literals (`.string`) and float literals
  (`.double`). No `.data` or `.bss` section is emitted; a package build
  appends a `.zyl_build` section holding `zyl_build_hash`.
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

Arguments are evaluated left to right. On the native path they are
evaluated into virtual registers and moved into the argument registers
by a parallel move. The stack machine evaluates them into stack scratch
slots, pushes arguments beyond the sixth, and then loads the registers
from the slots; a call whose arguments are constants or locals, with at
most one more complex argument and no `set!` among them, loads the
registers directly. Every value, including a Float's bit pattern, is
returned in `rax`. A call to a closure passes the closure's environment
as one extra trailing argument.

On the native path a function that calls C (a runtime call, an
allocation or array slow path, a region operation) realigns its frame to
16 bytes in the prologue; a Zyl callee aligns its own frame. In the
stack machine a C call (runtime helper, `printf`, `ffi-call`) with up to
six arguments is wrapped as `mov r12, rsp; and rsp, -16; call ...;
mov rsp, r12`, so the callee sees the 16-byte alignment System V
guarantees.

## Implementation: Stack Frame

- Prologue `push rbp; mov rbp, rsp`, epilogue `mov rsp, rbp; pop rbp;
  ret`. The stack machine then reserves `sub rsp, N` and spills
  parameter `i` (from 0) to `[rbp - 8*(i+1)]`, with locals in the
  following 8-byte slots downward. On the native path parameters and
  locals live in registers; a function without region words pushes the
  callee-saved registers it uses after `rbp` and reloads them from their
  slots on exit, and spill slots are reserved only when needed.
- A function that region inference flags (it has a frame region or keeps
  its result region, `icnf-regions`) reserves six words above its
  parameters: `[rbp-8]` the saved `rax`, `[rbp-16]` the result region
  (read from `zyl_cur_region` at entry), `[rbp-48]` a four-word region
  header (`prev`, `bump`, `end`, `blocks`). Both emitters use this
  layout; in the stack machine the parameters then start at `[rbp-56]`. Entry pushes the header on the thread-local
  `zyl_region_top` chain inline; exit, and every tail jump, pops it inline
  and calls `zyl_region_free` only if a block was taken.
- Before each call, the region the call site was given (frame, result, a
  `with-region` scope, or 0 for the heap) is stored in the thread-local
  `zyl_cur_region`, addressed `fs`-relative.
- `IRegion` pushes a scope header with the same layout, marked by the low
  bit of `blocks`, and releases it when the body ends.
- The frame size is fixed per function from a slot count of the body,
  rounded to keep 16-byte alignment.
- In the stack machine, expression evaluation leaves each result in
  `rax`; a binary operator's constant or local operand is loaded
  straight into its register, and an integer comparison in an `if` or
  `while` condition is `cmp` and a conditional jump.
- A call in tail position is a jump when its stack arguments fit in the
  caller's incoming ones (see `docs/implementation-status.md`). On the
  native path a self tail call is a jump to the loop head with the
  arguments moved into the parameters' registers (an unchanged
  parameter is not copied); in a function with a frame region it first
  recycles the region (`zyl_region_recycle`).

## Implementation: Values

- **Int / Bool:** 64-bit integers in `rax`; `true` is 1, `false` is 0.
  Arithmetic is plain `add`/`sub`/`imul`, so overflow wraps. `/` and `%`
  by a constant avoid `idiv`: a power of two is a biased shift, 1 a move,
  and any other constant except 0 and -1 a multiply by the runtime's
  magic number (`zyl_div_magic`, `zyl_div_shift`), with `idiv`'s
  results. Otherwise they are `cqo; idiv` with no zero test, so integer
  division by zero raises SIGFPE.
- **Float:** loaded from `.rodata` with `movsd xmm0, [rip+label]` and moved
  to `rax` with `movq`; arithmetic uses `xmm0`/`xmm1`, comparison uses
  `comisd`.
- **String:** a pointer to `.rodata` or to runtime memory; `=`, `==` and
  `!=` on strings compare contents.
- **Variant / struct:** a `[tag][field0]...` block from
  `zyl_ralloc(size, region)` at a site region inference placed in a
  region, from `zyl_heap_alloc` (`rdi = 8 * (fields + 1)`) at a heap site,
  or rbp-relative stores for an `IStackVariant`. On the native path an
  allocation in a frame or result region bumps the region's pointer
  inline (writing `zyl_ralloc`'s size header) when the block has room,
  and calls `zyl_ralloc` otherwise. A construction that `reuse.zyl`
  marked takes the block of the dead value it names when that block's
  size header is at least the new record's size, and allocates as usual
  otherwise. `match` compares the tag word.
- **Inline runtime operations (native path):** `Array` get, set and
  capacity check the magic word and the index inline and call the
  runtime only for a case it would reject, which panics with its own
  message. One-byte loads and stores are inline; a handle parameter that
  is never `set!` and is passed unchanged by every self call has its
  data pointer and bound loaded once before the loop head.
- **Region-aware runtime calls:** at an annotated site, the fresh-result
  producers `zyl_cstr_concat`, `zyl_cstr_substr`, `zyl_cstr_from_byte`,
  `zyl_int_text`, `zyl_f_text` and `zyl_file_read_c` are called through
  their `_r` entry points, which allocate in `zyl_cur_region`.
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
- `(- x)` is the negation of `x`, and `(+ x)` and `(* x)` are `x`.
  `(+)` and `(*)` with no operands are rejected with `E_ARITY_MISMATCH`
  ("operator N needs two operands"); §21.1 gives the empty sum as 0 and
  the empty product as 1.
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
  takes an `Option` and panics on `None` rather than extracting an alias
  (§21.12); see `spec/04-evaluation-semantics.md`.
- Byte and atomic primitives (`(byte N)`; the loads `load-u8`,
  `load-i8`, `load-u16` .. `load-u64` and `load-i16` .. `load-i64`, and
  the matching stores, each taking a `:le`/`:be` endianness selector as
  its first operand, as in `(load-u32 :le b off)` and
  `(store-u8 :le b off v)`; `byteslice`, `byteslice-sub`, `bytebuf`,
  `bytebuf-append`, `bytebuf-len`, `bytebuf-cap`, `bytebuf-ptr`,
  `align-check`, and `bytebuf-atomic-load`, `-store`, `-add`, `-sub`,
  `-fetch-add`, `-max`, `-min`, `-cas`) are special forms. Loads and
  stores lower to `zyl_load_byte`/`zyl_store_byte` (one byte, inline on
  both emitters) or `zyl_load_n`/`zyl_store_n` (wider), the rest to
  `zyl_bytebuf_*` runtime calls. A load or store evaluates the buffer
  before the offset. `stdlib/atomic/atomic.zyl` wraps the runtime's
  sequentially consistent atomics on raw addresses. The canonical text
  types these operations (§4.9) but does not define them.
