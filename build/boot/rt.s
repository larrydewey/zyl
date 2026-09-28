.file "rt.zyl"
.intel_syntax noprefix
.text
zy_local_x2Fmain_0__rt__rt_x2Dhex:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L0_0:
    lea rax, [rip+.L1]
    mov rsi, rax
    mov rdi, rbx
    and rdi, 15
    mov r8, 1
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_substr
    mov rsi, rax
    mov r13, rsi
    cmp rbx, 16
    jge .L0_1
    mov rdi, r13
    mov rsi, r12
    call zyl_cstr_concat
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L0_1:
    mov rsi, 4
    mov rax, rbx
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    mov r14, rsi
    mov rdi, r13
    mov rsi, r12
    call zyl_cstr_concat
    mov rsi, rax
    mov rbx, r14
    mov r12, rsi
    jmp .L0_0
zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rsi
.L2_0:
    lea rax, [rip+.L3]
    mov r12, rax
    lea rax, [rip+.L4]
    mov r13, rax
    lea rax, [rip+.L5]
    mov rsi, rax
    call zy_local_x2Fmain_0__rt__rt_x2Dhex
    mov rsi, rax
    lea rax, [rip+.L6]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r13
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rsi, rax
    mov rbx, rsi
    mov r12, 2
    mov rdi, rbx
    call strlen
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    call write
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__strlen_x2Dof:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L7_0:
    call strlen
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_len
zyl_cstr_len:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L8_0:
    mov rsi, rbx
    cmp rsi, 4096
    jge .L8_1
    cmp rsi, 0
    jne .L8_2
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L8_2:
    lea rax, [rip+.L9]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L8_1:
    mov rdi, rbx
    call strlen
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dlen:
    push rbp
    mov rbp, rsp
.L10_0:
    lea rax, [rip+.L11]
    mov rsi, rax
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_eq
zyl_cstr_eq:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L12_0:
    mov r8, rdi
    mov r9, rsi
    cmp r8, r9
    jne .L12_1
    mov r10, 1
    mov rax, r10
    mov rsp, rbp
    pop rbp
    ret
.L12_1:
    cmp r8, 4096
    jge .L12_2
    cmp r8, 0
    jne .L12_3
    mov r10, 0
    mov rax, r10
    mov rsp, rbp
    pop rbp
    ret
.L12_3:
    lea rax, [rip+.L13]
    mov r10, rax
    mov rdi, r8
    mov rsi, r10
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
.L12_2:
    cmp r9, 4096
    jge .L12_4
    cmp r9, 0
    jne .L12_5
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L12_5:
    lea rax, [rip+.L14]
    mov r8, rax
    mov rdi, r9
    mov rsi, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
.L12_4:
    call strcmp
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_cmp
zyl_cstr_cmp:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L15_0:
    mov r8, rdi
    mov r9, rsi
    cmp r8, r9
    jne .L15_1
    mov r10, 0
    mov rax, r10
    mov rsp, rbp
    pop rbp
    ret
.L15_1:
    cmp r8, 0
    jne .L15_2
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L15_2:
    cmp r9, 0
    jne .L15_3
    mov r8, 1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L15_3:
    call strcmp
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 0
    jne .L15_4
    mov rdi, 0
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L15_4:
    cmp rsi, 2147483647
    jle .L15_5
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L15_5:
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_byte_at
zyl_cstr_byte_at:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L16_0:
    mov r13, rbx
    cmp r12, 0
    jge .L16_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L16_1:
    cmp r13, 4096
    jge .L16_2
    cmp r13, 0
    jne .L16_3
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L16_3:
    lea rax, [rip+.L17]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L16_2:
    mov rdi, rbx
    call strlen
    mov rsi, rax
    cmp r12, rsi
    jl .L16_4
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L16_4:
    mov rsi, r13
    add rsi, r12
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dat:
    push rbp
    mov rbp, rsp
.L18_0:
    lea rax, [rip+.L19]
    mov rsi, rax
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_key_matches
zyl_cstr_key_matches:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rsi
.L20_0:
    mov r12, rdi
    mov r13, rbx
    cmp r12, r13
    jne .L20_1
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L20_1:
    cmp r12, 0
    jne .L20_3
    mov rsi, 1
    jmp .L20_4
.L20_3:
    mov rax, r13
    cmp rax, 0
    sete al
    movzx rax, al
    mov r8, rax
    mov rsi, r8
.L20_4:
    cmp rsi, 0
    je .L20_2
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L20_2:
    call strlen
    mov rsi, rax
    mov r14, rsi
    mov rdi, rbx
    call strlen
    mov rsi, rax
    mov rbx, rsi
    cmp r14, rbx
    jne .L20_5
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    call memcmp
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L20_5:
    mov rsi, rbx
    add rsi, 2
    cmp r14, rsi
    jge .L20_6
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L20_6:
    mov rsi, r14
    sub rsi, rbx
    add rsi, r12
    mov rdi, rsi
    sub rdi, 1
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    cmp rdi, 58
    jne .L20_7
    mov rdi, rsi
    sub rdi, 2
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    cmp rdi, 58
    jne .L20_8
    mov rdi, rsi
    mov rsi, r13
    mov rdx, rbx
    call memcmp
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L20_8:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L20_7:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.section .rodata
.Lfmtd:
    .string "%lld\n"
.Lfmtf:
    .string "%f\n"
.Lfmts:
    .string "%s\n"
.L1:
    .string "0123456789abcdef"
.L3:
    .string "zyl: "
.L4:
    .string ": invalid string pointer 0x"
.L5:
    .string ""
.L6:
    .string "\n"
.L9:
    .string "cstr-len"
.L11:
    .string "cstr-len"
.L13:
    .string "cstr-eq"
.L14:
    .string "cstr-eq"
.L17:
    .string "cstr-byte-at"
.L19:
    .string "cstr-byte-at"
