.file "rt.zyl"
.intel_syntax noprefix
.text
zy_local_x2Fmain_0__rt__rt_x2Dstrlen:
    push rbp
    mov rbp, rsp
.L0_0:
    mov rsi, rdi
    and rsi, -16
    mov rdx, rsi
    movdqu xmm0, [rdx]
    pxor xmm1, xmm1
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r8, rax
    mov r9, rdi
    and r9, 15
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    cmp r8, 0
    jne .L0_1
    add rsi, 16
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dstrlen_x2Dfrom
.L0_1:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dstrlen_x2Dfrom:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
.L1_0:
    mov rdx, r12
    movdqu xmm0, [rdx]
    pxor xmm1, xmm1
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L1_1
    mov rsi, r12
    and rsi, 31
    cmp rsi, 0
    jne .L1_2
    mov rsi, r12
    add rsi, 16
    mov r12, rsi
    jmp .L1_0
.L1_2:
    call zy_local_x2Fmain_0__rt__rt_x2Davx2
    mov rsi, rax
    cmp rsi, 0
    je .L1_3
    mov rsi, r12
    add rsi, 16
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dstrlen_x2D32
.L1_3:
    mov rsi, r12
    add rsi, 16
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dstrlen_x2D16
.L1_1:
    mov rdx, r13
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov rsi, rax
    add rsi, r12
    sub rsi, rbx
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dstrlen_x2D16:
    push rbp
    mov rbp, rsp
.L2_0:
    mov rdx, rsi
    movdqu xmm0, [rdx]
    pxor xmm1, xmm1
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r8, rax
    cmp r8, 0
    jne .L2_1
    mov r9, rsi
    add r9, 16
    mov rsi, r9
    jmp .L2_0
.L2_1:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    add rsi, r8
    sub rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dstrlen_x2D32:
    push rbp
    mov rbp, rsp
.L3_0:
    mov rdx, rsi
    vmovdqu ymm0, [rdx]
    vpxor xmm1, xmm1, xmm1
    vpcmpeqb ymm0, ymm0, ymm1
    vpmovmskb eax, ymm0
    vzeroupper
    mov r8, rax
    cmp r8, 0
    jne .L3_1
    mov r9, rsi
    add r9, 32
    mov rsi, r9
    jmp .L3_0
.L3_1:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    add rsi, r8
    sub rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Davx2:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L4_0:
    lea rax, [rip+zyl_rtg_cpu_avx2]
    mov rsi, rax
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L4_1
    call zy_local_x2Fmain_0__rt__rt_x2Davx2_x2Dprobe
    mov rsi, rax
    cmp rsi, 0
    je .L4_2
    mov rsi, 2
    jmp .L4_3
.L4_2:
    mov rdi, 1
    mov rsi, rdi
.L4_3:
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rax, rsi
    cmp rax, 2
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L4_1:
    mov rax, r12
    cmp rax, 2
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Davx2_x2Dprobe:
    push rbp
    mov rbp, rsp
.L5_0:
    mov rsi, 0
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov eax, edx
    mov r11, rbx
    cpuid
    mov eax, eax
    mov rbx, r11
    mov rsi, rax
    cmp rsi, 7
    jge .L5_1
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L5_1:
    mov rsi, 1
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov eax, edx
    mov r11, rbx
    cpuid
    mov eax, ecx
    mov rbx, r11
    mov rsi, rax
    and rsi, 402653184
    cmp rsi, 402653184
    jne .L5_2
    xor ecx, ecx
    xgetbv
    mov eax, eax
    mov rsi, rax
    and rsi, 6
    cmp rsi, 6
    jne .L5_3
    mov rsi, 7
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov eax, edx
    mov r11, rbx
    cpuid
    mov eax, ebx
    mov rbx, r11
    mov rsi, rax
    and rsi, 32
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L5_3:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L5_2:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cpuid_features
zyl_cpuid_features:
    push rbp
    mov rbp, rsp
.L6_0:
    mov rsi, 1
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov eax, edx
    mov r11, rbx
    cpuid
    mov eax, ecx
    mov rbx, r11
    mov rsi, rax
    mov rdi, rsi
    and rdi, 33554432
    cmp rdi, 0
    jle .L6_1
    mov rdi, 1
    jmp .L6_2
.L6_1:
    mov r8, 0
    mov rdi, r8
.L6_2:
    mov r8, rsi
    and r8, 2
    cmp r8, 0
    jle .L6_3
    mov r8, 2
    jmp .L6_4
.L6_3:
    mov r9, 0
    mov r8, r9
.L6_4:
    mov r9, rsi
    and r9, 524288
    cmp r9, 0
    jle .L6_5
    mov r9, 4
    jmp .L6_6
.L6_5:
    mov r10, 0
    mov r9, r10
.L6_6:
    and rsi, 268435456
    cmp rsi, 0
    jle .L6_7
    mov rsi, 8
    jmp .L6_8
.L6_7:
    mov r10, 0
    mov rsi, r10
.L6_8:
    or rsi, r9
    or rsi, r8
    or rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_aesni_available
zyl_aesni_available:
    push rbp
    mov rbp, rsp
.L7_0:
    call zyl_cpuid_features
    mov rsi, rax
    and rsi, 1
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dmem_x2Deq:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L8_0:
    cmp r8, 16
    jl .L8_1
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r9, rax
    cmp r9, 65535
    jne .L8_2
    mov r9, rdi
    add r9, 16
    mov r10, rsi
    add r10, 16
    mov rbx, r8
    sub rbx, 16
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L8_0
.L8_2:
    mov r9, 0
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L8_1:
    mov rdx, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dbytes_x2Deq
zy_local_x2Fmain_0__rt__rt_x2Dbytes_x2Deq:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L9_0:
    cmp r8, 0
    jne .L9_1
    mov r9, 1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L9_1:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jne .L9_2
    mov r9, rdi
    add r9, 1
    mov r10, rsi
    add r10, 1
    mov rbx, r8
    sub rbx, 1
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L9_0
.L9_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dstrcmp:
    push rbp
    mov rbp, rsp
.L10_0:
    mov r8, rdi
    and r8, 4095
    cmp r8, 4080
    jle .L10_2
    mov r8, 1
    jmp .L10_3
.L10_2:
    mov r9, rsi
    and r9, 4095
    mov rax, r9
    cmp rax, 4080
    setg al
    movzx rax, al
    mov r9, rax
    mov r8, r9
.L10_3:
    cmp r8, 0
    je .L10_1
    mov r8, 16
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dstrcmp_x2Dbytes
.L10_1:
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r8, rax
    xor r8, 65535
    mov rdx, rdi
    movdqu xmm0, [rdx]
    pxor xmm1, xmm1
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r9, rax
    or r8, r9
    and r8, 65535
    cmp r8, 0
    jne .L10_4
    mov r9, rdi
    add r9, 16
    mov r10, rsi
    add r10, 16
    mov rdi, r9
    mov rsi, r10
    jmp .L10_0
.L10_4:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r9, rax
    add rdi, r9
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    add rsi, r8
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rdi, rsi
    jge .L10_5
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L10_5:
    cmp rdi, rsi
    jle .L10_6
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L10_6:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dstrcmp_x2Dbytes:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L11_0:
    cmp r8, 0
    jne .L11_1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dstrcmp
.L11_1:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jne .L11_5
    mov r10, 0
    jmp .L11_6
.L11_5:
    mov rbx, 1
    mov r10, rbx
.L11_6:
    cmp r10, 0
    je .L11_3
    mov r10, 1
    jmp .L11_4
.L11_3:
    mov rax, r9
    cmp rax, 0
    sete al
    movzx rax, al
    mov r9, rax
    mov r10, r9
.L11_4:
    cmp r10, 0
    je .L11_2
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jge .L11_7
    mov rbx, -1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L11_7:
    cmp r9, r10
    jle .L11_8
    mov r9, 1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L11_8:
    mov r9, 0
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L11_2:
    mov r9, rdi
    add r9, 1
    mov r10, rsi
    add r10, 1
    mov rbx, r8
    sub rbx, 1
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L11_0
zy_local_x2Fmain_0__rt__rt_x2Dbyte_x2Dorder:
    push rbp
    mov rbp, rsp
.L12_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rdi, rsi
    jge .L12_1
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L12_1:
    cmp rdi, rsi
    jle .L12_2
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L12_2:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
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
.L13_0:
    lea rax, [rip+.L14]
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
    jge .L13_1
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
.L13_1:
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
    jmp .L13_0
zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rsi
.L15_0:
    lea rax, [rip+.L16]
    mov r12, rax
    lea rax, [rip+.L17]
    mov r13, rax
    lea rax, [rip+.L18]
    mov rsi, rax
    call zy_local_x2Fmain_0__rt__rt_x2Dhex
    mov rsi, rax
    lea rax, [rip+.L19]
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
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
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
.L20_0:
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dstrlen
.globl zyl_cstr_len
zyl_cstr_len:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L21_0:
    mov rsi, rbx
    cmp rsi, 4096
    jge .L21_1
    cmp rsi, 0
    jne .L21_2
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L21_2:
    lea rax, [rip+.L22]
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
.L21_1:
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dstrlen
zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dlen:
    push rbp
    mov rbp, rsp
.L23_0:
    lea rax, [rip+.L24]
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
.L25_0:
    cmp rdi, rsi
    jne .L25_1
    mov r8, 1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L25_1:
    cmp rdi, 4096
    jge .L25_2
    cmp rdi, 0
    jne .L25_3
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L25_3:
    lea rax, [rip+.L26]
    mov r8, rax
    mov rsi, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
.L25_2:
    cmp rsi, 4096
    jge .L25_4
    cmp rsi, 0
    jne .L25_5
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L25_5:
    lea rax, [rip+.L27]
    mov r8, rax
    mov rdi, rsi
    mov rsi, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
.L25_4:
    call zy_local_x2Fmain_0__rt__rt_x2Dstrcmp
    mov rsi, rax
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
.L28_0:
    cmp rdi, rsi
    jne .L28_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L28_1:
    cmp rdi, 0
    jne .L28_2
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L28_2:
    cmp rsi, 0
    jne .L28_3
    mov r8, 1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L28_3:
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dstrcmp
.globl zyl_cstr_byte_at
zyl_cstr_byte_at:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
.L29_0:
    mov r13, rbx
    cmp r12, 0
    jge .L29_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L29_1:
    cmp r13, 4096
    jge .L29_2
    cmp r13, 0
    jne .L29_3
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L29_3:
    lea rax, [rip+.L30]
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
.L29_2:
    mov rdi, rbx
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    cmp r12, rsi
    jl .L29_4
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L29_4:
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
.L31_0:
    lea rax, [rip+.L32]
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
    mov rbx, rsi
.L33_0:
    mov r12, rdi
    mov r13, rbx
    cmp r12, r13
    jne .L33_1
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L33_1:
    cmp r12, 0
    jne .L33_3
    mov rsi, 1
    jmp .L33_4
.L33_3:
    mov rax, r13
    cmp rax, 0
    sete al
    movzx rax, al
    mov r8, rax
    mov rsi, r8
.L33_4:
    cmp rsi, 0
    je .L33_2
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L33_2:
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    mov r14, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    cmp r14, rsi
    jne .L33_5
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dmem_x2Deq
.L33_5:
    mov rdi, rsi
    add rdi, 2
    cmp r14, rdi
    jge .L33_6
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L33_6:
    mov rdi, r14
    sub rdi, rsi
    add rdi, r12
    mov r8, rdi
    sub r8, 1
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 58
    jne .L33_7
    mov r8, rdi
    sub r8, 2
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 58
    jne .L33_8
    mov rdx, rsi
    mov rsi, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dmem_x2Deq
.L33_8:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L33_7:
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
.L14:
    .string "0123456789abcdef"
.L16:
    .string "zyl: "
.L17:
    .string ": invalid string pointer 0x"
.L18:
    .string ""
.L19:
    .string "\n"
.L22:
    .string "cstr-len"
.L24:
    .string "cstr-len"
.L26:
    .string "cstr-eq"
.L27:
    .string "cstr-eq"
.L30:
    .string "cstr-byte-at"
.L32:
    .string "cstr-byte-at"
.bss
.p2align 6
zyl_rtg_cpu_avx2:
    .zero 8
