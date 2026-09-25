# Chapter 29: Code Generation and x86_64 Backend

Reference for Zyl's code generator, `stdlib/compiler/codegen.zyl` and
its machine IR, `stdlib/compiler/mir.zyl`: how a function is chosen for
one of the two emitters, how the native path allocates registers, how
calls and stack frames are laid out, and how the generated program
meets the C runtime. The design and its staging are recorded in
`docs/native-backend-design.md`.

## 29.1 Code Generation Overview

- **Target**: x86_64 Linux, System V AMD64 calling convention at every
  call into C
- **Input**: the optimized, region-annotated ICNF function list, after
  in-place reuse (Chapter 28)
- **Output**: GNU assembler text in `.intel_syntax noprefix`, built in a
  fixed 64 MiB buffer
- **Two emitters, one ABI**: a function whose ICNF the native backend
  supports is lowered to MIR, given registers by linear scan and emitted
  from that; every other function goes through the older stack-machine
  emitter. Both use the same calling convention and frame-region layout,
  so they call each other freely (§29.2)
- **Assemble and link**: `cc -no-pie <prog>.s actor_runtime.o -o <prog> -lpthread`,
  run from the compiler's bundle directory. `./boot.sh` and
  `./install.sh` compile the runtime once, at `-O2`, into
  `actor_runtime.o`; when that object is older than `actor_runtime.c`,
  the link compiles the source with the same flag instead.

```bash
zyl prog.zyl -o prog              # writes prog.s, then links prog
zyl prog.zyl -o prog.s --emit-asm # writes the assembly only
```

## 29.2 The Two Emitters

### Which path a function takes

`cg-function` asks `mb-eligible` first. A function goes to the native
backend when all of these hold:

- it has at most six parameters;
- it is not a function whose frame must be wiped for a `Secret`
  (Chapter 33, §33.5);
- every node of its body is in the supported set (`ml-ok`): integer
  constants, strings, Float constants, symbol addresses, locals and
  function references, integer operators (not a String, Float or
  variant comparison), `if`, `while`, `let`, `set!`, sequences, direct
  calls of known functions and runtime calls with at most six
  arguments, variant construction, stack variants and `match`;
- no call or allocation in it is placed in a `with-region` scope.

What keeps a function on the stack machine is therefore a `print`,
Float arithmetic, a String or variant comparison, a closure or any other
call through a local, `try`, a `with-region` scope, frame wiping, or
more than six parameters or arguments. About 95% of the compiler's own
functions take the native path. `ZYL_MIR=0` at compile time sends every
function through the stack machine, for bisecting a suspected backend
bug.

### The native path

The native path has three steps, each a function of instruction order
alone, so the same ICNF always gives the same assembly:

1. **Lowering** (`ml-expr`, `ml-tail` in `codegen.zyl`) turns the ICNF
   tree into a linear list of MIR instructions over *virtual registers*
   (vregs), numbered in lowering order. `let` and `set!` locals are
   vregs too: a `set!` is one more definition of the same vreg, which
   linear scan handles without SSA.
2. **Allocation** (`mir.zyl`) computes liveness and live intervals and
   assigns each vreg a register or a spill slot by linear scan.
3. **Emission** (`mb-emit-one`) prints each instruction with its
   operands' locations substituted.

MIR is a three-address IR (`deftype MI` in `mir.zyl`):

| Instructions | Meaning |
|---|---|
| `MConst`, `MMov`, `MParam` | constant, copy, incoming argument |
| `MBin`, `MBinI` | integer operator on two vregs, or on a vreg and an immediate that fits in 32 bits |
| `MCall`, `MTail` | a user or runtime call with an explicit argument list and the call site's region level; a tail call |
| `MLabel`, `MJmp`, `MJf`, `MJfI`, `MJz`, `MRet` | labels, jumps, compare-and-branch, return |
| `MAlloc`, `MReuse`, `MStackBlk` | a block in the region the analysis chose; a block that may take a dead value's (§29.7); a block in the frame |
| `MLoad`, `MStore`, `MStoreI` | `[base + off]` loads and stores |
| `MStr`, `MFlt`, `MSym`, `MFnRef` | a string constant, a Float's bits, a symbol's address, a function's address |
| `MByte`, `MByteData`, `MByteBound`, `MByteFast`, `MArr` | inline byte-buffer and `Array` access (§29.5) |
| `MRegionCycle` | empty the frame region before a loop's next iteration (§29.6) |

Evaluation order is the ICNF's. Operands are lowered left to right,
and a local that a later operand could `set!` is first copied into a
fresh vreg (`ml-operand`), so the earlier operand sees the value it had
when it was evaluated.

### Liveness and linear scan

Liveness is a backward dataflow over the instruction list, with one
bit per vreg, iterated to a fixpoint. From it each vreg gets an
interval (first and last position where it is live) and a flag saying
whether a call lies strictly inside the interval.

The allocator (`mir-allocate`) is Poletto–Sarkar linear scan over the
intervals sorted by start, then by vreg number:

- `rax`, `rcx`, `rdx` and `r11` are never allocated; the emitter uses
  them as scratch.
- A value that is not live across a call takes the first free
  caller-saved register of `rsi`, `rdi`, `r8`, `r9`, `r10`, then a
  callee-saved one. A value live across a call takes one of `rbx`,
  `r12`–`r15`.
- A move's destination prefers its source's register, and a parameter
  the register it arrives in (`mir-hints`), so most copies vanish.
- When nothing is free, the active interval that ends last gives up its
  register if it ends after the new one; otherwise the new one is
  spilled to a frame slot.

The leading parameter moves, and the argument moves before each call,
are *parallel moves* (`pm-sequence`): a move whose destination no
pending move still reads goes first, and a cycle is broken through
`rax`.

Here is `fib` as the native path emits it. `n` is live across the first
call, so it lives in `rbx`; the first result is live across the second
call, so it lives in `r12`:

```asm
fib:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L221_0:
    cmp rbx, 2
    jge .L221_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L221_1:
    mov rsi, rbx
    sub rsi, 1
    mov rdi, rsi
    call fib
    mov r12, rax
    mov rsi, rbx
    sub rsi, 2
    mov rdi, rsi
    call fib
    mov rsi, rax
    add rsi, r12
    mov rax, rsi
    ...                          ; restore rbx, r12; ret
```

(Symbols are shortened here; the real label is the mangled canonical
key, §29.3.)

### The stack machine

The older emitter is a **stack machine over `rax`**. Every expression
leaves its value in `rax`; parameters and locals live in stack slots
addressed from `rbp`. A binary operator loads its right operand into
`rcx` directly when that operand is a constant or a local, and otherwise
pushes the left operand around the right one's evaluation:

```asm
    mov rax, [rbp-8]      ; left: a local
    mov rcx, 7            ; right: a constant, loaded straight into rcx
    imul rax, rcx

    ...                   ; left: anything else
    push rax
    ...                   ; right, into rax
    mov rcx, rax
    pop rax
    add rax, rcx
```

When only the left operand is simple, the right one is evaluated first,
unless it contains a `set!` that could change the local. An integer
comparison in an `if` or `while` condition is a `cmp` and a conditional
jump in both emitters.

### Values and representation kinds

Every value is a 64-bit word. A String is a pointer to NUL-terminated
bytes; a Float travels as its IEEE-754 bit pattern and is moved to
`xmm0`/`xmm1` only for arithmetic; an ADT or struct value is a pointer
to a block (§29.7). Codegen keeps a small static *kind* per expression
(`kind-of`: 0 word, 1 String, 2 Float, 3 variant), read from the kind
the type checker recorded on the ICNF node (the `icnf-kinds` side
table, `node_tables.zyl`) where the node's own shape does not settle
it. The stack machine uses it to
choose:

- `print`'s format (`%lld`, `%s` or `%f`)
- float arithmetic (`addsd`, `subsd`, `mulsd`, `divsd`, compared with `comisd`)
- structural `=`/`!=` on Strings (`zyl_cstr_eq`) and on variants
  (`zyl_variant_eq`, a shallow fallback: an ADT comparison whose type is
  known has already become a call to a generated `T.==` function in
  `type_annotate.zyl`; the type pass rejects ordering on an ADT, so no
  ordering comparison reaches the runtime)

The native path takes only integer-kind operators, which is why a
function with any of those stays on the stack machine.

## 29.3 Calling Convention

### Zyl-to-Zyl and Zyl-to-C calls

Both emitters use the SysV integer registers for the first six
arguments:

| Position | Register |
|----------|----------|
| 1 | `rdi` |
| 2 | `rsi` |
| 3 | `rdx` |
| 4 | `rcx` |
| 5 | `r8` |
| 6 | `r9` |
| 7+ | stack, argument 7 at `[rsp]` at the call (stack machine only) |

The result comes back in `rax`. Floats are passed as bit patterns in
integer registers between Zyl functions; the only place a Float goes
through `xmm0` to C is `print`.

On the native path every argument is already in a vreg, evaluated in
source order, so a call is one parallel move into the argument
registers followed by the `call`. The allocator never keeps a value
that is live across a call in a caller-saved register, so nothing is
saved around it.

The stack machine stages arguments so that evaluation stays strictly
left to right (`cg-call-args`). When at most one argument is more than a
constant or a local and none contains a `set!`, the complex one is
evaluated straight into its register and the others are moved in after
it. Otherwise:

1. an 8-byte pad if the number of pushed words will be odd
2. each argument evaluated in source order into its own scratch slot
   (`sub rsp, 8` / `mov [rsp], rax`)
3. stack arguments (index 6 and up) copied down in reverse order
4. register arguments loaded from their scratch slots
5. the `call`, then one `add rsp, N` to discard pad, scratch and copies

```asm
    sub rsp, 8            ; parity pad
    ...                   ; (g 1)
    sub rsp, 8
    mov [rsp], rax        ; arg 1
    ...                   ; (g 2)
    sub rsp, 8
    mov [rsp], rax        ; arg 2
    mov rax, 3
    sub rsp, 8
    mov [rsp], rax        ; arg 3
    mov rdx, [rsp+0]
    mov rsi, [rsp+8]
    mov rdi, [rsp+16]
    call zy_local_x2Fmain_0__b__add3_x7EInt_x2CInt_x2CInt
    add rsp, 32
```

A stack-machine callee spills its incoming register arguments to
`[rbp-8]`, `[rbp-16]`, ... in its prologue, and copies arguments 7 and
up from `[rbp+16]`, `[rbp+24]`, ... into slots of its own.

### Symbol names

A user function's label is its canonical symbol key (spec §31.2,
`pkg@major::module::name`) mangled by the runtime's `zyl_mangle_key`,
so `add3` in `add.zyl` compiled as a plain program becomes
`zy_local_x2Fmain_0__add__add3`, and its instance at three `Int`s
(Chapter 30, §30.5) `zy_local_x2Fmain_0__add__add3_x7EInt_x2CInt_x2CInt`.
The handful of names the compiler recognizes by spelling keep an older
`_ZYL_` + sanitized form — the user's entry point is `_ZYL_main`. An
`ffi-call` target is sanitized to `[A-Za-z0-9_]` before it is emitted,
so a crafted name cannot inject assembly.

### Stack alignment at C calls

SysV requires `rsp` to be 16-byte aligned at a `call`. Most C functions
do not care; those that copy a struct or an SSE local with `movaps`
fault. The REPL found this the hard way — `tcsetattr` crashed on its
second call and not its first, because the two call sites sat at
different depths.

A native function that calls C itself (a runtime call, an allocation
or `Array` slow path, a region operation) aligns its frame once, in the
prologue (`and rsp, -16`), and keeps `rsp` fixed for the rest of the
body, so its C calls need nothing more. One that calls only Zyl
functions skips the alignment: each callee aligns its own frame when it
needs to.

The stack machine cannot promise alignment by construction: its body
runs with `rsp` at 8 mod 16 (§29.4), and every intermediate push shifts
it again. Every C call of arity six or less therefore forces alignment
around the call itself, after the argument registers are loaded:

```asm
    mov r12, rsp
    and rsp, -16
    call zyl_cstr_len
    mov rsp, r12
```

`r12` is callee-saved in C, so the callee hands it back. `print`
(`printf`) and variant allocation (`zyl_ralloc`, `zyl_heap_alloc`) use
the same sequence. A C call with seven or more arguments must have its
stack arguments at `[rsp]`, so rounding `rsp` down would move them out
from under the callee; instead the stack arguments are copied into a
fresh aligned block below the current `rsp`:

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

Calls through a local holding a function value are compiled by the
stack machine only. `cg-call-indirect` stages one argument more than
the source wrote. The extra, last argument is the closure's environment,
or 0 when the value is a plain code address; the tag word tells the two
apart:

```asm
    mov rax, [rbp-56]     ; the function value
    mov r11, 2051230803   ; ic-closure-magic
    cmp qword ptr [rax], r11
    jne .L221
    mov rax, [rax+16]     ; closure: its environment
    jmp .L222
.L221:
    xor eax, eax          ; plain function: 0
.L222:
    sub rsp, 8            ; staged as the last argument
    mov [rsp], rax
    ...                   ; registers loaded from the scratch slots
    mov r10, [rbp-56]
    mov r11, 2051230803
    cmp qword ptr [r10], r11
    jne .L223
    mov r10, [r10+8]      ; closure: its code pointer
.L223:
    call r10              ; or, in tail position, jmp r10
```

A plain function ignores the extra argument (the SysV caller owns every
argument slot), so a function value of either kind can be passed
anywhere and the arity of a closure is not limited. A code address's
first word is a function prologue, which starts with `push rbp` (0x55)
in both emitters, so it never equals the tag. A call by name to
something that is neither a local nor a known function is reported by
`cg-call-user` as a located `E_UNBOUND_VARIABLE` instead of an undefined
symbol at link time.

## 29.4 Stack Frame Layout

### Native frames

A native frame holds only what the function needs, from `rbp` down:

```
Higher addresses
+------------------------+
| return address         | [rbp+8]
+------------------------+
| saved rbp              | [rbp]      <- rbp
+------------------------+
| region words           | 48 bytes, only in a region function (below)
+------------------------+
| saved callee-saved     | only the ones the allocation used,
| registers              | in the order rbx r12 r13 r14 r15
+------------------------+
| spill slots            | one per spilled vreg
+------------------------+
| tail-call staging      | six words, only with a frame region (§29.6)
+------------------------+
| stack-variant blocks   | one block per IStackVariant
+------------------------+  <- rsp (16-aligned when the function calls C)
Lower addresses
```

A leaf that needs no registers beyond the caller-saved ones, no spill
slots and no region has no frame beyond the saved `rbp`. Without region
words the saved registers are pushed right after `rbp` and reloaded
from those slots on the way out; with them they are stored below the
region words.

### Stack-machine frames

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
|                        | (from [rbp-56] in a region function, below)
+------------------------+
| local slots            | one per let, match binding, loop value,
| ...                    | and word of every stack-allocated variant
+------------------------+
| saved rbx, r12         | the two lowest words of the frame
+------------------------+  <- rsp after the prologue (8 mod 16)
| argument staging       | pushed and popped around each call
Lower addresses
```

The frame is sized from the function's actual slot count: parameters
plus one slot per binding the body needs plus eight slots of headroom,
rounded so that the frame size is 16n+8. There is no red-zone use and
no frame-pointer omission in either emitter.

### Region functions

A function that region inference flags (it has a frame region, or it
keeps its caller's result region; Chapter 28, §28.5) reserves six words
at the top of its frame, in both emitters:

```
[rbp-8]     saved rax (the return value while the region is released)
[rbp-16]    the result region, read from zyl_cur_region at entry
[rbp-48]    the frame region's header: prev, bump, end, blocks
            (at [rbp-48], [rbp-40], [rbp-32], [rbp-24])
```

In the stack machine the first parameter slot follows at `[rbp-56]`;
in a native frame the saved registers do. The runtime's `ZylRegion`
shares this layout. The header is pushed on the thread-local
`zyl_region_top` chain inline in the prologue, and popped inline at
every exit and before every tail jump; `zyl_region_free` is called only
if the region actually took a block (`blocks` nonzero). A `with-region`
scope (stack machine only) uses the same four-word header layout,
marked by the low bit of `blocks`.

## 29.5 Instruction Selection

### Integer arithmetic

The native path uses the two-operand forms where it can: `add`, `sub`,
`imul`, `and`, `or` and `xor` are `d op= s` on the allocated registers,
with an immediate right operand when it fits in 32 bits:

```asm
    mov rsi, rbx
    sub rsi, 1
```

Shifts, comparisons and division keep fixed sequences through `rax`
and `rcx`, shared with the stack machine:

```asm
    add rax, rcx
    sub rax, rcx
    imul rax, rcx
    cqo
    idiv rcx              ; quotient in rax; remainder via mov rax, rdx
```

### Division by a constant

On the native path, `/` and `%` by a constant other than 0 and -1 do
not use `idiv` (`mb-divmod-const`). Division by 1 is a move; by a power
of two, a shift with a bias so that the result truncates toward zero;
by anything else, a multiply by the constant's magic number
(`zyl_div_magic`, `zyl_div_shift` in the runtime, Hacker's Delight
§10-1) and a correction. The results are exactly `idiv`'s, including at
the most negative and most positive integers. `(% n 10)`:

```asm
    mov rcx, rdi
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 2
    mov rax, rdx
    shr rax, 63
    add rdx, rax          ; rdx = n / 10
    imul rdx, rdx, 10
    mov rax, rcx
    sub rax, rdx          ; rax = n % 10
```

A variable divisor, or the constants 0 and -1, keep `idiv`. Division by
zero is not checked; `idiv` raises `SIGFPE`.

### Comparison

A comparison used as a value is `cmp` and `setcc`:

```asm
    cmp rax, rcx
    setg al
    movzx rax, al
```

In a condition it is fused into the branch (`MJf`/`MJfI` on the native
path, `cg-cond-jump` on the stack machine):

```asm
    cmp rbx, 2
    jge .L221_1           ; the else branch
```

### Bitwise operators

`and`, `or` and `xor` are one instruction each. Shifts are defined for
every count: a logical shift by 64 or more gives 0 and an arithmetic
shift saturates to the sign bit. The sequences are branchless, do not
depend on operand values, and are the same in both emitters
(`cg-bit-mnem`):

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

A `while` has a value, 0 before the first iteration and the body's
value after each one. A `begin` with no forms is 0.

### Match

Each arm loads the scrutinee's tag word and compares it with the arm's
tag; on the native path the fields an arm binds are loaded into
registers:

```asm
.L223_0:
    mov rsi, [rdi+0]      ; tag word
    cmp rsi, 0
    jne .L223_1           ; next arm
    mov rsi, [rdi+8]      ; field 0
    ...
```

A wildcard arm (tag -1) skips the comparison. If no arm matches, the
result is 0 — exhaustiveness checking makes that unreachable for a
checked program. A `match` in tail position ends each arm with its own
return or tail call.

### Inline runtime operations

Both emitters open-code one-byte loads and stores (`load-u8`,
`store-u8` and their signed forms): the handle's magic word selects a
buffer or a slice, the offset is checked against its capacity or
length, and anything the runtime would reject gives the runtime's
result, 0, without a call.

On the native path a byte-buffer parameter that is used as the handle of
such an access, is never `set!`, and is passed unchanged by every self
tail call has its data pointer and bound loaded once, before the loop
head (`MByteData`, `MByteBound`). Each access is then a bound check and
the load or store:

```asm
    mov rax, rsi          ; the offset
    cmp rax, rdi          ; the bound, loaded once
    jae .L221_q8
    mov rdx, r10          ; the data pointer, loaded once
    movzx eax, byte ptr [rdx+rax]
```

An invalid handle gives a bound of 0, so every access through it fails
as the runtime's would.

`Array` access (`zyl_array_get`, `zyl_array_set`, `zyl_array_cap`) is
inline on the native path too: the magic word, then the index against
the filled length (and, for a set at the end, against the capacity,
which appends). Anything the runtime would reject calls the runtime
entry, which panics with its own message.

## 29.6 Function Prologue/Epilogue

### Native path

A native prologue pushes `rbp`, saves only the callee-saved registers
the allocation used, aligns and reserves the frame if it needs one, and
moves the parameters from their argument registers to their allocated
locations in one parallel move:

```asm
count_set:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx           ; parameters to their registers
    mov r9, rcx
    ...                   ; byte views loaded once (§29.5)
.L221_0:                  ; the loop head a self tail call jumps to
    ...
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
```

A region function's native prologue is `and rsp, -16`, the frame
reservation, the register saves below the region words, and the same
region push the stack machine emits (below). Every return releases the
region first, keeping the result in `[rbp-8]`.

### Stack machine

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

The stack machine uses `rbx` (the block pointer of a variant
construction) and `r12` (the saved `rsp` around a C call) as scratch,
and SysV makes both callee-saved. Zyl functions never rely on them
across a call, but a Zyl function is also called *from* C — the user's
`main` under `zyl_call_on_big_stack`, a test function under
`zyl_run_tests`, an actor body, a comparator handed to `qsort` — and an
optimized C caller keeps live values in them. So every stack-machine
prologue stores both in the two lowest words of the frame, below every
local slot, and the epilogue reloads them. A native function saves
exactly the callee-saved registers it allocates.

### Region prologue and epilogue

A region function's prologue pushes the frame region:

```asm
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov [rbp-48], rax            ; prev
    xor eax, eax
    mov [rbp-40], rax            ; bump
    mov [rbp-32], rax            ; end
    mov [rbp-24], rax            ; blocks
    lea rax, [rbp-48]
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
```

and its exit saves the result in `[rbp-8]`, frees the region's blocks
if it took any, pops the chain, and clears `zyl_cur_region` if it still
names the dying frame:

```asm
    mov [rbp-8], rax
    cmp qword ptr [rbp-24], 0
    je .L1
    lea rdi, [rbp-48]
    call zyl_region_free         ; aligned, as above
.L1:
    mov r10, [rbp-48]
    mov QWORD PTR fs:zyl_region_top@tpoff, r10
    lea r11, [rbp-48]
    cmp QWORD PTR fs:zyl_cur_region@tpoff, r11
    jne .L2
    mov QWORD PTR fs:zyl_cur_region@tpoff, 0
.L2:
    mov rax, [rbp-8]
```

Before a call whose callee may allocate into its result region, the call
site's region is stored in the thread-local `zyl_cur_region`, addressed
`fs`-relative, after the arguments are evaluated: the frame region
(`lea r11, [rbp-48]`), the saved result region (`[rbp-16]`), or 0 for the
heap. A function that keeps the result region reads `zyl_cur_region`
once, at entry, into `[rbp-16]`.

### Tail calls

On the native path a **self tail call** is a jump to the loop head just
after the parameter moves: each argument goes into a fresh vreg, then
into its parameter's vreg, and an argument that is its own parameter
unchanged is not copied at all. A function with a frame region empties
the region before the jump instead of releasing and re-opening it:
`zyl_region_recycle` keeps the region's first block and resets it, so a
loop that allocates a little per iteration does not return a block to
the pool and take it back each time. Region inference already keeps
every tail-call argument out of the frame region.

```asm
    mov rbx, r13          ; new parameter values
    mov r12, rsi
    cmp qword ptr [rbp-24], 0
    je .L224_c13
    lea rdi, [rbp-48]
    call zyl_region_recycle
.L224_c13:
    jmp .L224_0
```

A **tail call of another function** moves the arguments into the
argument registers, restores the saved registers, tears the frame down
and jumps to the symbol. When the frame has a region, the arguments wait
in the six staging slots while the region is released, because the
release calls C.

On the stack machine a call in tail position is a jump too (`cg-tail`):
the arguments are staged in scratch slots, arguments beyond the sixth
copied into the caller's incoming stack-argument area (which bounds how
many a tail call may pass), registers loaded, `rbx`/`r12` restored, the
frame torn down, then `jmp` to the symbol, or to `r10` for a function
value. A function that wipes its frame for a `Secret` makes no tail
calls. Every other call is a real `call`; deep recursion there is
supported by running the program on a very large stack (§29.9).

## 29.7 Data Representation

### Variants and structs

A constructor application allocates `8 * (fields + 1)` bytes and fills
them as `[tag][field 0][field 1]...`. The fields are evaluated left to
right first, then the block is allocated, then the tag and fields are
stored. A site that region inference placed in a region allocates with
`zyl_ralloc(size, region)`, the region passed directly (the frame
header's address, the saved result region, or a `with-region` scope); a
heap site calls `zyl_heap_alloc(size)`.

On the native path a frame- or result-region allocation bumps the
region's pointer inline when the current block has room and the region
is not a `with-region` scope, writing `zyl_ralloc`'s size header itself.
The runtime path, and every heap allocation, saves the five allocatable
caller-saved registers around the call, so an allocation does not force
the allocator to treat it as a call:

```asm
    mov r11, [rbp-16]     ; the result region
    test r11, r11
    jz .L224_m2s
    test byte ptr [r11+24], 1
    jnz .L224_m2s         ; a with-region scope: the runtime path
    mov rax, [r11+8]      ; bump
    test rax, rax
    jz .L224_m2s
    lea rdx, [rax+32]
    cmp rdx, [r11+16]     ; end
    ja .L224_m2s
    mov [r11+8], rdx
    mov qword ptr [rax], 3    ; size header, in words
    add rax, 8
    jmp .L224_m2d
.L224_m2s:
    push rsi
    ...                       ; rdi r8 r9 r10
    mov rdi, 24
    mov rsi, r11
    call zyl_ralloc
    ...                       ; pop them back
.L224_m2d:
    mov r8, rax
    mov qword ptr [r8+0], 1   ; tag
    mov qword ptr [r8+8], rdi
    mov qword ptr [r8+16], rsi
```

The stack machine pushes the fields, calls the allocator with an aligned
stack, and pops the fields into place through `rbx`:

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

Both allocators place a hidden size header before the block, which is how
`zyl_variant_eq` compares two separately allocated values field word by
field word, and how in-place reuse (below) knows a block's size. Region
blocks come in size classes of 1, 4, 16 and 64 KiB (a region's first
block is the smallest, each further block the next class up), taken
from per-thread pools carved from `mmap`ed chunks above 4 GiB (so the
closure-versus-code address checks keep working) and charged to
`ZYL_MAX_MEMORY`. Region-aware runtime functions (`zyl_cstr_concat` and
the other fresh-string producers) have `_r` entry points that allocate
in `zyl_cur_region`; compiled code calls them from annotated sites.
An `IStackVariant` has the same layout written into a block of the
current frame, with no allocation call.

### In-place reuse

When `reuse.zyl` has marked a construction as able to take the block of
a unique, dead value (Chapter 28, §28.7), the native path emits
`MReuse`: it compares the old block's size header with the new record's
size in words and, when the old block is large enough, writes the new
record there; otherwise it allocates as usual. From `list-car`'s owning
clone:

```asm
    mov rax, rdi              ; the old value
    cmp qword ptr [rax-8], 2  ; its size header, in words
    jge .L164_u4              ; large enough: reuse it
    ...                       ; else allocate, as above
.L164_u4:
    mov r8, rax
    mov qword ptr [r8+0], 0   ; tag
    mov qword ptr [r8+8], rsi
```

The stack machine and the interpreter ignore the mark and always
allocate, so the program's meaning does not depend on it.

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
process's exit code. `main` returns an `Int`, usually a final `0`;
a `main` that ends in `print`, a `Unit`, is `E_TYPE_MISMATCH`. A program built from top-level `test`
forms exits 0 even when a test fails; read the summary line.

## 29.10 FFI Call Sequence

An `ffi-call` is an ordinary C call: arguments passed as in §29.3, the
aligned `call`, the result in `rax`. Before lowering, `ffi-check-call`
(`arity_check.zyl`) requires the symbol of `(ffi-call "sym" arg...
timeout)` to be a string literal (`E_FFI_SYMBOL_REQUIRED`) and the last
argument to be a positive integer literal (`E_FFI_TIMEOUT_REQUIRED`),
so a forgotten timeout can no longer swallow a real argument. The type
pass has already given the call a type: a `zyl_` symbol from the
signature table in `ffi_sigs.zyl`, any other from its
`(extern "sym" (T ...) R)` declaration, whose types all fit in one
integer register (which is why `Float` is refused there for now). A
symbol of the runtime (`zyl_` prefix and no `extern`) is called
directly and its timeout is dropped. Any other symbol is called through the runtime's
`zyl_ffi_timed`, which receives the symbol's address, its name, the
timeout, the argument count and then the arguments; it runs the call on
a worker thread and raises `E_FFI_TIMEOUT` when the timeout expires
first. The address is an `ISymAddr` node, emitted as
`mov rax, QWORD PTR [rip+sym@GOTPCREL]`. `ffi-pin`/`ffi-unpin` are
calls to `ffi_pin`/`ffi_unpin` in the runtime.

## 29.11 Codegen Errors

| Error | Cause |
|-------|-------|
| `E_CODEGEN_BUFFER_FULL` | The generated assembly passed the buffer limit (63 MiB of the 64 MiB buffer); every write is also bounds-checked (`zyl_str_append_capped`) so an overflow can never corrupt memory |
| `E_UNBOUND_VARIABLE` | An identifier that names no local, parameter or function; reported at the identifier with a source line and caret |

The other codes earlier drafts listed (`E_REG_ALLOC_FAILED`,
`E_STACK_FRAME_TOO_LARGE`, `E_TCO_FAILED`) do not exist. Register
allocation cannot fail, because a value that gets no register is
spilled to a frame slot, and a tail call that cannot be a jump is
compiled as an ordinary call rather than reported (§29.6).

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

When a program misbehaves only when compiled, these compile-time
switches turn one transformation off at a time, each leaving the
program's meaning unchanged:

| Variable | Turns off |
|---|---|
| `ZYL_MIR=0` | the native backend: every function goes through the stack machine |
| `ZYL_INLINE=0` | inlining of small functions (Chapter 28, §28.7); `ZYL_INLINE_LIMIT=N` changes its size limit |
| `ZYL_REUSE=0` | in-place reuse |
| `ZYL_REGIONS=0` | region placement: every allocation goes to the heap |

A native function's labels are `.L<n>_<k>`, one base number per
function, so its code is easy to find in the output.

## 29.13 Comparison with Other Backends

| Feature | LLVM | Cranelift | Zyl Codegen |
|---------|------|-----------|-------------|
| Target | Multi | Multi | x86_64 Linux only |
| IR | SSA | SSA | MIR: linear three-address code over virtual registers, not SSA |
| Register alloc | Greedy/Graph | Backtracking (regalloc2) | Linear scan; the stack machine for functions outside the native path |
| Optimizations | Many | Some | On ICNF: inlining, copy propagation, integer constant folding, dead-branch elimination, in-place reuse; in the backend: immediates, fused compare-and-branch, division by constants, inline allocation and array and byte access |
| Determinism | Configurable | Configurable | Mandatory |
| Tail calls | ✅ | ✅ | ✅ (jumps; a self tail call is a loop; a few cases fall back to calls) |
| Debug info | DWARF | DWARF | None |

`bench/` holds seven small programs written in Zyl, C, C++, Rust and
Go (recursive calls, integer arithmetic, cons cells, binary trees,
integer-to-string concatenation, a byte sieve, a growable array), and
`bench/matrix.py` runs them; the table in
`docs/native-backend-design.md` is the stack machine's baseline that
the native backend is measured against.
