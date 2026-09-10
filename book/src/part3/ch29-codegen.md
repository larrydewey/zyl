# Chapter 29: Code Generation and x86_64 Backend

Complete reference for Zyl's code generator: register allocation, calling convention, stack frames, and instruction selection.

## 29.1 Code Generation Overview

- **Target**: x86_64 Linux (System V AMD64 ABI)
- **Input**: Optimized ICNF (Phase 7 output)
- **Output**: Assembly (`.s` file)
- **Assembler**: `cc` (GCC/Clang)
- **Linker**: `cc` + `actor_runtime.o` + `pthread`

## 29.2 Calling Convention (System V AMD64)

### Argument Registers

| Position | Integer/Pointer | Float |
|----------|-----------------|-------|
| 1 | `rdi` | `xmm0` |
| 2 | `rsi` | `xmm1` |
| 3 | `rdx` | `xmm2` |
| 4 | `rcx` | `xmm3` |
| 5 | `r8` | `xmm4` |
| 6 | `r9` | `xmm5` |
| 7+ | Stack (right-to-left) | Stack |

### Return Registers

| Type | Register |
|------|----------|
| Integer/Pointer | `rax` |
| Float | `xmm0` |
| 128-bit (pair) | `rax` + `rdx` |

### Callee-Saved Registers

`rbx`, `rbp`, `r12`, `r13`, `r14`, `r15`

### Stack Alignment

- 16-byte aligned before `call`
- `rsp % 16 == 8` at function entry (return address pushed)

## 29.3 Stack Frame Layout

```
Higher addresses
+------------------------+
| Caller's stack frame   |
+------------------------+
| Return address         | ← rsp at entry
+------------------------+
| Saved rbp              | ← rbp after prologue
+------------------------+
| Spill slots            | Local variables, temps
| ...                    |
+------------------------+
| Param spill area       | For >6 args (callee allocates)
+------------------------+
| RSP-stash slot         | 8 bytes (for alignment save)
+------------------------+
| Red zone (128 bytes)   | Not used by Zyl
Lower addresses
```

### Frame Size

- Uniform for all functions (enables TCO)
- Minimum 256 bytes + spill slots
- RSP-stash slot at fixed offset for alignment save/restore

## 29.4 Register Allocation

### Algorithm: Linear Scan (Deterministic)

1. **Compute live intervals** for each SSA value
2. **Sort by start point** (deterministic: FNV-1a hash tiebreaker)
3. **Allocate registers** greedily
4. **Spill to stack** when registers exhausted

### Register Classes

| Class | Registers | Use For |
|-------|-----------|---------|
| General | `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`-`r11` | Int, pointers |
| Float | `xmm0`-`xmm15` | Float |
| Callee-saved | `rbx`, `rbp`, `r12`-`r15` | Preserved across calls |
| Special | `rsp`, `rbp` | Stack/frame pointers |

### Spilling

- Spilled values stored in stack frame at fixed offsets
- Reloaded before use
- Deterministic spill order (by SSA ID)

## 29.5 Instruction Selection

### Arithmetic

```asm
; Int add
add rax, rdi

; Float add
addsd xmm0, xmm1

; Int mul
imul rax, rdi

; Int div (requires rdx:rax)
cqo
idiv rdi
```

### Comparison

```asm
; Int compare
cmp rax, rdi
setg al        ; > → 1/0
movzx rax, al  ; zero-extend to 64-bit

; Float compare
ucomisd xmm0, xmm1
seta al        ; > (unordered = false)
movzx rax, al
```

### Control Flow

```asm
; Direct call
call function_name

; Indirect call (closure)
mov rax, [closure_env + fn_ptr_offset]
call rax

; Conditional branch
cmp rax, 0
jne label_true
jmp label_false

; Return
mov rax, return_value
mov rsp, rbp
pop rbp
ret
```

### Memory Access

```asm
; Struct field (offset known at compile time)
mov rax, [rdi + 8]    ; field at offset 8

; Array/Vec element
mov rax, [rdi + rsi*8]  ; rdi=base, rsi=index

; Stack slot
mov rax, [rbp - 24]   ; fixed offset
```

## 29.6 Function Prologue/Epilogue

### Prologue

```asm
function_name:
  push rbp
  mov rbp, rsp
  sub rsp, FRAME_SIZE        ; Align to 16 bytes + RSP-stash
  mov [rbp - RSP_STASH_OFF], rsp  ; Save rsp for alignment restore
```

### Epilogue

```asm
  mov rsp, [rbp - RSP_STASH_OFF]  ; Restore rsp (handles alignment)
  pop rbp
  ret
```

### Tail Call (TCO)

```asm
; Instead of call + ret:
; 1. Pop our frame
; 2. Reuse caller's frame
; 3. Jump to callee
mov rsp, [rbp - RSP_STASH_OFF]
pop rbp
jmp callee_function
```

## 29.7 Closure Representation

```c
struct Closure {
    void* fn_ptr;      // Code pointer
    void* env_ptr;     // Captured environment (struct)
};
```

### Closure Call

```asm
; Load fn_ptr from closure
mov rax, [rdi + 0]      ; rdi = closure pointer
; Load env_ptr
mov rdi, [rdi + 8]      ; New first arg = env
; Call
call rax
```

## 29.8 Actor Runtime Integration

### Spawn

```asm
; zyl_spawn(behavior_fn_ptr) → ActorRef
; Creates pthread, passes behavior_fn_ptr
call zyl_spawn
```

### Send

```asm
; zyl_send(actor_ref, message_ptr)
; Lock-free queue push
call zyl_send
```

### Wait All

```asm
; zyl_wait_all(actor_refs...)
; Barrier wait
call zyl_wait_all
```

## 29.9 FFI Call Sequence

```asm
; 1. Pin args (already in Pin region)
; 2. Save callee-saved registers
push rbx
push r12
push r13
push r14
push r15

; 3. Switch to C stack (large guard page)
mov rsp, c_stack_top

; 4. Call C function
call c_function

; 5. Restore Zyl stack
mov rsp, zyl_stack_top

; 6. Restore callee-saved
pop r15
pop r14
pop r13
pop r12
pop rbx

; 7. Handle timeout (separate watchdog thread)
```

## 29.10 Codegen Errors

| Error | Cause |
|-------|-------|
| `E_CODEGEN_BUFFER_FULL` | Assembly buffer exceeded (64MB) |
| `E_REG_ALLOC_FAILED` | Register pressure too high |
| `E_STACK_FRAME_TOO_LARGE` | Frame size exceeds limit |
| `E_TCO_FAILED` | Tail call not in tail position |

## 29.11 Debugging Codegen

```bash
# Emit assembly
zyl --emit-asm prog.zyl

# Inspect .s file
cat prog.s

# Compile with debug info
cc -g prog.s actor_runtime.o -o prog

# Debug with gdb
gdb ./prog
```

## 29.12 Comparison with Other Backends

| Feature | LLVM | Cranelift | Zyl Codegen |
|---------|------|-----------|-------------|
| Target | Multi | Multi | x86_64 only |
| Register alloc | Greedy/Graph | Linear scan | Linear scan (det) |
| Optimizations | Many | Some | Const fold, DCE |
| Determinism | Configurable | Configurable | Mandatory |
| TCO | ✅ | ✅ | ✅ |
| Stack maps | ✅ | ✅ | Manual |
| Debug info | DWARF | DWARF | Planned |