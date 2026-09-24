# Chapter 29: Code Generation and x86_64 Backend

Reference for Zyl's code generator, `stdlib/compiler/codegen.zyl`: how
it evaluates expressions, how it calls functions, how a stack frame is
laid out, and how the generated program meets the C runtime.

## 29.1 Code Generation Overview

- **Target**: x86_64 Linux, System V AMD64 calling convention at every
  call into C
- **Input**: the optimized, region-rewritten ICNF function list
  (Chapter 28)
- **Output**: GNU assembler text in `.intel_syntax noprefix`, built in a
  fixed 64 MiB buffer
- **Assemble and link**: `cc -no-pie <prog>.s actor_runtime.c -o <prog> -lpthread`,
  run from the compiler's bundle directory. The runtime is compiled from
  C source on every link.

```bash
zyl prog.zyl -o prog              # writes prog.s, then links prog
zyl prog.zyl -o prog.s --emit-asm # writes the assembly only
```

## 29.2 The Evaluation Model

The backend is a **stack machine over `rax`**. Every expression leaves
its value in `rax`. A binary operator evaluates its left operand,
pushes it, evaluates the right operand, moves that to `rcx`, pops the
left back into `rax` and combines them:

```asm
    mov rax, [rbp-8]      ; left
    push rax
    mov rax, [rbp-16]     ; right
    mov rcx, rax
    pop rax
    add rax, rcx
```

There is **no register allocator**. Parameters and locals live in stack
slots addressed from `rbp`, and `rax`, `rcx`, `rdx`, `r10`, `r11`,
`r12` and `rbx` are used as fixed scratch registers by particular
instruction sequences (the last two are saved by every function's
prologue, §29.6). That makes the output long but trivially
deterministic: the same ICNF always produces the same text.

### Values and representation kinds

Every value is a 64-bit word. A String is a pointer to NUL-terminated
bytes; a Float travels in `rax` as its IEEE-754 bit pattern and is moved
to `xmm0`/`xmm1` only for arithmetic; an ADT or struct value is a pointer
to a heap block (§29.7). Codegen tracks a small static *kind* per
expression (`kind-of`: 0 word, 1 String, 2 Float, 3 variant) and uses it
to choose:

- `print`'s format (`%lld`, `%s` or `%f`)
- float arithmetic (`addsd`, `subsd`, `mulsd`, `divsd`, compared with `comisd`)
- structural `=`/`!=` on Strings (`zyl_cstr_eq`) and on variants
  (`zyl_variant_eq`; ordering comparisons use `zyl_variant_cmp`)

`kind-of` has no return-type inference. A function's result kind is
read off its body when that body has a fixed shape; otherwise it
defaults to 0, which is why `print` of a String computed in some ways
shows a pointer.

## 29.3 Calling Convention

### Zyl-to-Zyl and Zyl-to-C calls

Both use the SysV integer registers for the first six arguments:

| Position | Register |
|----------|----------|
| 1 | `rdi` |
| 2 | `rsi` |
| 3 | `rdx` |
| 4 | `rcx` |
| 5 | `r8` |
| 6 | `r9` |
| 7+ | stack, argument 7 at `[rsp]` at the call |

The result comes back in `rax`. Floats are passed as bit patterns in
integer registers between Zyl functions; the only place a Float goes
through `xmm0` to C is `print`.

Arguments are staged so that evaluation stays strictly left to right
(`cg-call-args`):

1. an 8-byte pad if the number of pushed words will be odd
2. each argument evaluated in source order into its own scratch slot
   (`sub rsp, 8` / `mov [rsp], rax`)
3. stack arguments (index 6 and up) copied down in reverse order
4. register arguments loaded from their scratch slots
5. the `call`, then one `add rsp, N` to discard pad, scratch and copies

```asm
    sub rsp, 8            ; parity pad
    mov rax, 1
    sub rsp, 8
    mov [rsp], rax        ; arg 1
    mov rax, 2
    sub rsp, 8
    mov [rsp], rax        ; arg 2
    mov rax, 3
    sub rsp, 8
    mov [rsp], rax        ; arg 3
    mov rdx, [rsp+0]
    mov rsi, [rsp+8]
    mov rdi, [rsp+16]
    call zy_local_x2Fmain_0__add__add3
    add rsp, 32
```

A callee spills its incoming register arguments to
`[rbp-8]`, `[rbp-16]`, ... in its prologue, and copies arguments 7 and
up from `[rbp+16]`, `[rbp+24]`, ... into slots of its own.

### Symbol names

A user function's label is its canonical symbol key (spec §31.2,
`pkg@major::module::name`) mangled by the runtime's `zyl_mangle_key`,
so `add3` in `add.zyl` compiled as a plain program becomes
`zy_local_x2Fmain_0__add__add3`. The handful of names the compiler
recognizes by spelling keep an older `_ZYL_` + sanitized form — the
user's entry point is `_ZYL_main`. An `ffi-call` target is sanitized to
`[A-Za-z0-9_]` before it is emitted, so a crafted name cannot inject
assembly.

### Stack alignment at C calls

SysV requires `rsp` to be 16-byte aligned at a `call`. The backend
cannot promise that by construction: a function body runs with `rsp`
at 8 mod 16 (§29.4), and every intermediate push shifts it again. Most
C functions do not care. Those that copy a struct or an SSE local with
`movaps` fault. The REPL found this the hard way — `tcsetattr`
crashed on its second call and not its first, because the two call
sites sat at different depths.

Every C call of arity six or less therefore forces alignment around
the call itself, after the argument registers are loaded:

```asm
    mov r12, rsp
    and rsp, -16
    call zyl_cstr_len
    mov rsp, r12
```

`r12` is callee-saved in C, so the callee hands it back. `print`
(`printf`) and variant allocation (`zyl_heap_alloc`) use the same
sequence. A C call with seven or more arguments must have its stack
arguments at `[rsp]`, so rounding `rsp` down would move them out from
under the callee; instead the stack arguments are copied into a fresh
aligned block below the current `rsp`:

```asm
    mov r12, rsp
    sub rsp, 24           ; 8 * stack-argument count
    and rsp, -16
    mov r10, [r12+0]      ; copy each stack argument
    mov [rsp+0], r10
    ...
    call snprintf
    mov rsp, r12
```

### Closure calls

An `ICallClosure` stages its arguments the same way, then unpacks the
closure block held in the local's slot and passes the environment as
one extra trailing register argument:

```asm
    mov r11, [rbp-24]     ; the closure block [tag, code, env]
    mov rsi, [r11+16]     ; env as the argument after the real ones
    mov r11, [r11+8]      ; code pointer
    call r11
```

A call through a local that holds a plain function pointer is
`mov r10, [rbp+off]` / `call r10`.

## 29.4 Stack Frame Layout

```
Higher addresses
+------------------------+
| stack arguments 7+     | [rbp+16], [rbp+24], ...
+------------------------+
| return address         | [rbp+8]
+------------------------+
| saved rbp              | [rbp]      <- rbp
+------------------------+
| parameter slots        | [rbp-8], [rbp-16], ... one per parameter
+------------------------+
| local slots            | one per let, match binding, loop value,
| ...                    | and word of every stack-allocated variant
+------------------------+  <- rsp after the prologue (8 mod 16)
| argument staging       | pushed and popped around each call
Lower addresses
```

The frame is sized from the function's actual slot count: parameters
plus one slot per binding the body needs plus eight slots of headroom,
rounded so that the frame size is 16n+8. There is no red-zone use and
no frame-pointer omission.

## 29.5 Instruction Selection

### Integer arithmetic

```asm
    add rax, rcx
    sub rax, rcx
    imul rax, rcx
    cqo
    idiv rcx              ; quotient in rax; remainder via mov rax, rdx
```

Division by zero is not checked; `idiv` raises `SIGFPE`.

### Comparison

```asm
    cmp rax, rcx
    setg al
    movzx rax, al
```

### Bitwise operators

`and`, `or` and `xor` are one instruction each. Shifts are defined for
every count: a logical shift by 64 or more gives 0 and an arithmetic
shift saturates to the sign bit. The sequences are branchless and do
not depend on operand values:

```asm
    ; shl / shr
    mov rdx, rcx
    shl rax, cl           ; or shr
    cmp rdx, 64
    sbb rdx, rdx          ; all ones when count < 64, else 0
    and rax, rdx

    ; ashr
    mov rdx, 63
    cmp rcx, 64
    cmovae rcx, rdx
    sar rax, cl
```

### Control flow

```asm
    ; if
    test rax, rax
    je .L12               ; else branch
    ...
    jmp .L13
.L12:
    ...
.L13:
```

A `while` keeps its value in a slot, initialized to 0 and overwritten
by each iteration's body. A `begin` with no forms is `xor eax, eax`.

### Match

The scrutinee pointer is pushed; each arm loads its tag and compares:

```asm
    mov rax, [rsp]
    mov rax, [rax]        ; tag word
    cmp rax, 0
    jne .L21              ; next arm
    mov rax, [rsp]
    mov rax, [rax+8]      ; field 0 -> a slot
    ...
```

A wildcard arm (tag -1) skips the comparison. If no arm matches, the
result is 0 — exhaustiveness checking makes that unreachable for a
checked program.

## 29.6 Function Prologue/Epilogue

```asm
name:
    push rbp
    mov rbp, rsp
    sub rsp, 120          ; 16n+8
    mov [rbp-120], rbx    ; save the callee-saved registers codegen uses
    mov [rbp-112], r12
    mov [rbp-8], rdi      ; spill parameters
    mov [rbp-16], rsi
    ...
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
```

There is no tail-call elimination: every call is a real `call`. Deep
recursion is supported by running the program on a very large stack
instead (§29.9).

Generated code uses `rbx` (the block pointer of a variant
construction) and `r12` (the saved `rsp` around a C call) as scratch,
and SysV makes both callee-saved. Zyl functions never rely on them
across a call, but a Zyl function is also called *from* C — the user's
`main` under `zyl_call_on_big_stack`, a test function under
`zyl_run_tests`, an actor body, a comparator handed to `qsort` — and an
optimized C caller keeps live values in them. So every prologue stores
both in the two lowest words of the frame, below every local slot, and
the epilogue reloads them. No other callee-saved register is used.

## 29.7 Data Representation

### Variants and structs

A constructor application allocates `8 * (fields + 1)` bytes with
`zyl_heap_alloc` and fills them as `[tag][field 0][field 1]...`. The
fields are evaluated left to right and pushed, the block is allocated,
and the fields are popped into place:

```asm
    ; fields already pushed
    mov r12, rsp
    and rsp, -16
    mov rdi, 24
    call zyl_heap_alloc
    mov rsp, r12
    mov rbx, rax
    mov qword ptr [rbx], 0    ; tag
    pop rax
    mov [rbx+16], rax
    pop rax
    mov [rbx+8], rax
    mov rax, rbx
```

`zyl_heap_alloc` places a hidden header before the block, which is how
`zyl_variant_eq` compares two separately allocated values structurally.
An `IStackVariant` has the same layout written into consecutive slots
of the current frame, with no allocation call.

### Closures

A capturing lambda is a variant-shaped block `[tag, code, env]` whose
`env` field is another block holding one captured value per field
(Chapter 28, §28.4).

### Strings and floats

String literals and float literals are interned into `.rodata`
(`.string` and `.double` directives) and loaded with `lea`/`movq`.

## 29.8 Actor Runtime Integration

`spawn` and `send` lower to plain C calls into `runtime/actor_runtime.c`:

| Form | Runtime call | What it does |
|------|--------------|--------------|
| `(spawn (fn () ...))` | `zyl_actor_spawn(entry, state)` | Starts one pthread per actor; returns its id |
| `(send actor msg)` | `zyl_actor_send(id, msg)` | Appends to the actor's mailbox, a linked list guarded by a mutex and a condition variable |
| `actor-wait` (stdlib `actor/actor`) | `zyl_actor_wait(id)` | Joins one actor |

The spawn body is lifted like any other `fn`; its state pointer is
always 0, so a spawn body cannot capture. The message is passed as the
raw word, not boxed.

## 29.9 The Entry Stub

Every program gets the same `main`:

```asm
main:
    push rbp
    mov rbp, rsp
    call zyl_save_args        ; keep argc/argv for zyl_argc/zyl_arg_str
    call zyl_ensure_arenas    ; set up the heap and pin arenas
    lea rdi, [rip+_ZYL_main]
    call zyl_call_on_big_stack
    pop rbp
    ret
```

`zyl_call_on_big_stack` runs the user's `main` on a pthread whose stack
is reserved with `mmap` — 64 GiB, falling back to 16, 4 and 1 GiB —
with a guard page at the bottom, and returns its result as the
process's exit code. `print` always evaluates to 0, so a `main` that
ends in `print` exits 0, and one that ends in `(run-tests)` exits with
the test harness's pass/fail status.

## 29.10 FFI Call Sequence

An `ffi-call` is an ordinary C call: arguments staged as in §29.3, the
aligned `call`, the result in `rax`. There is no separate C stack, no
register save area and no watchdog thread. Lowering treats the *last*
argument of `(ffi-call "sym" arg... timeout)` as the timeout and drops
it: it is not passed to the callee and not enforced at run time.
Nothing checks that a timeout is actually there, so writing
`(ffi-call "zyl_cstr_len" s)` without one silently drops `s` and calls
the function with whatever `rdi` happens to hold. Always write the
timeout. `ffi-pin`/`ffi-unpin` are calls to `ffi_pin`/`ffi_unpin` in
the runtime.

## 29.11 Codegen Errors

| Error | Cause |
|-------|-------|
| `E_CODEGEN_BUFFER_FULL` | The generated assembly passed the buffer limit (63 MiB of the 64 MiB buffer); every write is also bounds-checked (`zyl_str_append_capped`) so an overflow can never corrupt memory |
| `E_UNBOUND_VARIABLE` | An identifier that names no local, parameter or function; reported at the identifier with a source line and caret |

The other codes earlier drafts listed (`E_REG_ALLOC_FAILED`,
`E_STACK_FRAME_TOO_LARGE`, `E_TCO_FAILED`) do not exist; there is no
register allocator and no tail-call elimination for them to report on.

## 29.12 Debugging Codegen

```bash
# Emit assembly instead of a binary
zyl prog.zyl -o prog.s --emit-asm

# The normal build leaves the assembly next to the binary
zyl prog.zyl -o prog && less prog.s

# Link it yourself with debug info for the runtime
cc -g -no-pie prog.s ~/.zyl/actor_runtime.c -o prog -lpthread
gdb ./prog
```

In a checkout, the runtime source is `runtime/actor_runtime.c` (also
copied to `build/boot/actor_runtime.c` by `./boot.sh`). The generated
assembly carries no DWARF line information of its own.

## 29.13 Comparison with Other Backends

| Feature | LLVM | Cranelift | Zyl Codegen |
|---------|------|-----------|-------------|
| Target | Multi | Multi | x86_64 Linux only |
| Register alloc | Greedy/Graph | Linear scan | None: stack slots, `rax` stack machine |
| Optimizations | Many | Some | Integer constant folding, dead-branch elimination (in ICNF) |
| Determinism | Configurable | Configurable | Mandatory |
| Tail calls | ✅ | ✅ | ❌ (large stack instead) |
| Debug info | DWARF | DWARF | None |
