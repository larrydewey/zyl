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
    jmp .L10_3
.L10_2:
    mov r8, rsi
    and r8, 4095
    cmp r8, 4080
    jle .L10_1
.L10_3:
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
    pcmpeqb xmm1, xmm0
    pxor xmm2, xmm2
    pcmpeqb xmm2, xmm0
    pmovmskb eax, xmm1
    pmovmskb ecx, xmm2
    xor eax, 65535
    or eax, ecx
    mov r8, rax
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
    mov r8, rax
    add rdi, r8
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
    jmp .L11_4
.L11_3:
    cmp r9, 0
    jne .L11_2
.L11_4:
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
    jmp .L33_4
.L33_3:
    cmp r13, 0
    jne .L33_2
.L33_4:
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
zy_local_x2Fmain_0__rt__rt_x2Dcopy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L34_0:
    cmp r13, 16
    jl .L34_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__rt__rt_x2Dcopy_x2D16
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L34_1:
    cmp r13, 8
    jl .L34_2
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    sub rsi, 8
    add rsi, rbx
    mov rdi, r13
    sub rdi, 8
    add rdi, r12
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L34_2:
    cmp r13, 4
    jl .L34_3
    mov rdx, r12
    mov eax, dword ptr [rdx]
    mov rsi, rax
    mov rdx, rbx
    mov rcx, rsi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    sub rsi, 4
    add rsi, rbx
    mov rdi, r13
    sub rdi, 4
    add rdi, r12
    mov rdx, rdi
    mov eax, dword ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L34_3:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dcopy_x2Dbytes
zy_local_x2Fmain_0__rt__rt_x2Dcopy_x2D16:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L35_0:
    cmp r8, 16
    jle .L35_1
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    mov r9, rax
    mov r9, rdi
    add r9, 16
    mov r10, rsi
    add r10, 16
    mov rbx, r8
    sub rbx, 16
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L35_0
.L35_1:
    mov r9, r8
    sub r9, 16
    add rdi, r9
    sub r8, 16
    add rsi, r8
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dcopy_x2Dbytes:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
    mov rdi, rdx
.L36_0:
    cmp rdi, 0
    jne .L36_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L36_1:
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r8, rax
    mov rdx, rbx
    mov rcx, r8
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r8, rax
    mov r8, rbx
    add r8, 1
    add rsi, 1
    sub rdi, 1
    mov rdx, rdi
    mov rdi, r8
    call zy_local_x2Fmain_0__rt__rt_x2Dcopy_x2Dbytes
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dmem_x2Dcmp:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
.L37_0:
    cmp r8, 16
    jl .L37_1
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r9, rax
    xor r9, 65535
    cmp r9, 0
    jne .L37_2
    mov r10, rdi
    add r10, 16
    mov rbx, rsi
    add rbx, 16
    mov r12, r8
    sub r12, 16
    mov rdi, r10
    mov rsi, rbx
    mov r8, r12
    jmp .L37_0
.L37_2:
    mov rdx, r9
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r10, rax
    add r10, rdi
    mov rdx, r9
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r9, rax
    add r9, rsi
    mov rdx, r10
    movzx eax, byte ptr [rdx]
    mov r10, rax
    mov rdx, r9
    movzx eax, byte ptr [rdx]
    mov r9, rax
    cmp r10, r9
    jge .L37_3
    mov rbx, -1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L37_3:
    cmp r10, r9
    jle .L37_4
    mov r9, 1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L37_4:
    mov r9, 0
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L37_1:
    cmp r8, 0
    jne .L37_5
    mov r9, 0
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L37_5:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jne .L37_6
    mov r9, rdi
    add r9, 1
    mov r10, rsi
    add r10, 1
    mov rbx, r8
    sub rbx, 1
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L37_0
.L37_6:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rdi, rsi
    jge .L37_7
    mov r8, -1
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L37_7:
    cmp rdi, rsi
    jle .L37_8
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L37_8:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dfind_x2Dbyte:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L38_0:
    mov r10, rsi
    sub r10, r9
    cmp r10, 16
    jl .L38_1
    mov r10, rdi
    add r10, r9
    mov rdx, r10
    mov rcx, r8
    movd xmm1, ecx
    punpcklbw xmm1, xmm1
    punpcklwd xmm1, xmm1
    pshufd xmm1, xmm1, 0
    movdqu xmm0, [rdx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r10, rax
    cmp r10, 0
    jne .L38_2
    mov rbx, r9
    add rbx, 16
    mov r9, rbx
    jmp .L38_0
.L38_2:
    mov rdx, r10
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r10, rax
    add r10, r9
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L38_1:
    cmp r9, rsi
    jl .L38_3
    mov r10, -1
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L38_3:
    mov r10, rdi
    add r10, r9
    mov rdx, r10
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r10, r8
    jne .L38_4
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L38_4:
    mov r10, r9
    add r10, 1
    mov r9, r10
    jmp .L38_0
zy_local_x2Fmain_0__rt__rt_x2Dalloc:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L39_0:
    call zyl_ralloc
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dcur_x2Dregion:
    push rbp
    mov rbp, rsp
.L40_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dstr_x2Dof:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L41_0:
    mov rdi, r12
    add rdi, 1
    call zyl_ralloc
    mov rsi, rax
    mov r13, rsi
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dcopy
    mov rsi, rax
    mov rsi, r13
    add rsi, r12
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dconcat:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdx
.L42_0:
    mov r12, rdi
    mov r13, rsi
    cmp r12, 0
    jle .L42_1
    cmp r12, 4096
    jge .L42_1
    lea rax, [rip+.L43]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L42_1:
    cmp r13, 0
    jle .L42_2
    cmp r13, 4096
    jge .L42_2
    lea rax, [rip+.L44]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L42_2:
    cmp r12, 0
    jne .L42_3
    mov rsi, 0
    mov r14, rsi
    jmp .L42_4
.L42_3:
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    mov r14, rsi
.L42_4:
    cmp r13, 0
    jne .L42_5
    mov rsi, 0
    mov r15, rsi
    jmp .L42_6
.L42_5:
    mov rdi, r13
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    mov r15, rsi
.L42_6:
    mov rsi, r14
    add rsi, r15
    add rsi, 1
    mov rdi, rsi
    mov rsi, rbx
    call zyl_ralloc
    mov rsi, rax
    mov rbx, rsi
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r14
    call zy_local_x2Fmain_0__rt__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, r14
    mov rdi, rsi
    mov rsi, r13
    mov rdx, r15
    call zy_local_x2Fmain_0__rt__rt_x2Dcopy
    mov rsi, rax
    mov rsi, r14
    add rsi, r15
    add rsi, rbx
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dnull:
    push rbp
    mov rbp, rsp
.L45_0:
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_concat
zyl_cstr_concat:
    push rbp
    mov rbp, rsp
.L46_0:
    mov r8, 0
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dconcat
.globl zyl_cstr_concat_r
zyl_cstr_concat_r:
    push rbp
    mov rbp, rsp
.L47_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r8, rax
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dconcat
zy_local_x2Fmain_0__rt__rt_x2Dsubstr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, rsi
    mov r12, rdx
    mov r13, rcx
.L48_0:
    mov r14, rdi
    cmp r14, 0
    jle .L48_1
    cmp r14, 4096
    jge .L48_1
    lea rax, [rip+.L49]
    mov rsi, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L48_1:
    cmp r14, 0
    jne .L48_2
    mov rsi, 0
    mov r15, rsi
    jmp .L48_3
.L48_2:
    mov rdi, r14
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    mov r15, rsi
.L48_3:
    cmp rbx, 0
    jge .L48_4
    mov rsi, 0
    jmp .L48_5
.L48_4:
    cmp rbx, r15
    jle .L48_6
    mov rdi, r15
    jmp .L48_7
.L48_6:
    mov rdi, rbx
.L48_7:
    mov rsi, rdi
.L48_5:
    cmp r12, 0
    jge .L48_8
    mov rdi, 0
    jmp .L48_9
.L48_8:
    mov r8, r15
    sub r8, rsi
    cmp r12, r8
    jle .L48_10
    mov r8, r15
    sub r8, rsi
    jmp .L48_11
.L48_10:
    mov r8, r12
.L48_11:
    mov rdi, r8
.L48_9:
    add rsi, r14
    mov rdx, r13
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dstr_x2Dof
.globl zyl_cstr_substr
zyl_cstr_substr:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L50_0:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dsubstr
.globl zyl_cstr_substr_r
zyl_cstr_substr_r:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L51_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r9, rax
    mov rdx, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dsubstr
zy_local_x2Fmain_0__rt__rt_x2Dfrom_x2Dbyte:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L52_0:
    mov rdi, 2
    call zyl_ralloc
    mov rsi, rax
    cmp rsi, 0
    jne .L52_1
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L52_1:
    mov rdi, rbx
    and rdi, 255
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 1
    mov r8, 0
    mov rdx, rdi
    mov rcx, r8
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rdi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_from_byte
zyl_cstr_from_byte:
    push rbp
    mov rbp, rsp
.L53_0:
    mov rsi, 0
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dfrom_x2Dbyte
.globl zyl_cstr_from_byte_r
zyl_cstr_from_byte_r:
    push rbp
    mov rbp, rsp
.L54_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dfrom_x2Dbyte
zy_local_x2Fmain_0__rt__rt_x2Dndigits:
    push rbp
    mov rbp, rsp
.L55_0:
    mov rsi, -10
    mov r8, 1
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dnd
zy_local_x2Fmain_0__rt__rt_x2Dnd:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L56_0:
    cmp rdi, rsi
    jle .L56_2
    jmp .L56_3
.L56_2:
    cmp r8, 19
    jne .L56_1
.L56_3:
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L56_1:
    mov r9, rsi
    imul r9, 10
    mov r10, r8
    add r10, 1
    mov rsi, r9
    mov r8, r10
    jmp .L56_0
zy_local_x2Fmain_0__rt__rt_x2Ddigit_x2Dpairs:
    push rbp
    mov rbp, rsp
.L57_0:
    lea rax, [rip+.L58]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dput_x2Ddigits:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
.L59_0:
    cmp rsi, -100
    jg .L59_1
    mov rcx, rsi
    movabs rax, -6640827866535438581
    imul rcx
    add rdx, rcx
    sar rdx, 6
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    mov rax, rdx
    mov r9, rax
    mov r10, r9
    imul r10, 100
    sub r10, rsi
    lea rax, [rip+.L60]
    mov rbx, rax
    imul r10, 2
    add r10, rbx
    mov rbx, r8
    sub rbx, 1
    add rbx, rdi
    mov rdx, r10
    movzx eax, byte ptr [rdx]
    mov r12, rax
    mov rdx, rbx
    mov rcx, r12
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rbx, rax
    mov rbx, rdi
    add rbx, r8
    add r10, 1
    mov rdx, r10
    movzx eax, byte ptr [rdx]
    mov r10, rax
    mov rdx, rbx
    mov rcx, r10
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r10, rax
    mov r10, r8
    sub r10, 2
    mov rsi, r9
    mov r8, r10
    jmp .L59_0
.L59_1:
    cmp rsi, -10
    jg .L59_2
    lea rax, [rip+.L61]
    mov r9, rax
    mov r10, 0
    sub r10, rsi
    imul r10, 2
    add r9, r10
    mov r10, r8
    sub r10, 1
    add r10, rdi
    mov rdx, r9
    movzx eax, byte ptr [rdx]
    mov rbx, rax
    mov rdx, r10
    mov rcx, rbx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r10, rax
    mov r10, rdi
    add r10, r8
    add r9, 1
    mov rdx, r9
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, r10
    mov rcx, r9
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r9, rax
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L59_2:
    add rdi, r8
    mov r8, 48
    mov rax, r8
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    mov rdx, rdi
    mov rcx, rsi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dint_x2Dtext:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rsi
.L62_0:
    cmp rdi, 0
    jle .L62_1
    mov rsi, 0
    sub rsi, rdi
    jmp .L62_2
.L62_1:
    mov rsi, rdi
.L62_2:
    mov r12, rsi
    cmp rdi, 0
    jge .L62_3
    mov rsi, 1
    jmp .L62_4
.L62_3:
    mov rdi, 0
    mov rsi, rdi
.L62_4:
    mov r13, rsi
    mov rsi, -10
    mov rdi, 1
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dnd
    mov rsi, rax
    add rsi, r13
    mov r14, rsi
    mov rsi, r14
    add rsi, 1
    mov rdi, rsi
    mov rsi, rbx
    call zyl_ralloc
    mov rsi, rax
    mov rbx, rsi
    cmp r13, 1
    jne .L62_5
    mov rsi, 45
    mov rdx, rbx
    mov rcx, rsi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    jmp .L62_6
.L62_5:
    mov rdi, 0
    mov rsi, rdi
.L62_6:
    mov rsi, r14
    sub rsi, 1
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dput_x2Ddigits
    mov rsi, rax
    mov rsi, rbx
    add rsi, r14
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_int_text
zyl_int_text:
    push rbp
    mov rbp, rsp
.L63_0:
    mov rsi, 0
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dint_x2Dtext
.globl zyl_int_text_r
zyl_int_text_r:
    push rbp
    mov rbp, rsp
.L64_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dint_x2Dtext
zy_local_x2Fmain_0__rt__rt_x2Darena_x2Dstr:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L65_0:
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_sub
zyl_cstr_sub:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
    mov r12, rdx
    mov r13, rcx
.L66_0:
    mov r14, rsi
    cmp r14, 0
    jne .L66_2
    jmp .L66_3
.L66_2:
    cmp r12, 0
    jge .L66_4
    jmp .L66_5
.L66_4:
    cmp r13, 0
    jge .L66_1
.L66_5:
.L66_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L66_1:
    cmp r14, 4096
    jge .L66_6
    lea rax, [rip+.L67]
    mov rsi, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L66_6:
    mov rdi, r14
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r12
    add rdi, r13
    cmp rdi, rsi
    jle .L66_7
    mov rdi, rsi
    sub rdi, r12
    cmp rdi, 0
    jge .L66_9
    mov rdi, 0
    jmp .L66_10
.L66_9:
    sub rsi, r12
    mov rdi, rsi
.L66_10:
    jmp .L66_8
.L66_7:
    mov rdi, r13
.L66_8:
    mov r13, rdi
    mov rsi, r13
    add rsi, 1
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rbx, rsi
    mov rsi, r14
    add rsi, r12
    mov rdi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__rt__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, r13
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_from_int
zyl_cstr_from_int:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L68_0:
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__rt__rt_x2Dint_x2Dtext
    mov rsi, rax
    mov r12, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    mov r13, rsi
    mov rsi, r13
    add rsi, 1
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rbx, rsi
    mov rsi, r13
    add rsi, 1
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dcopy
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dllong_x2Dmin:
    push rbp
    mov rbp, rsp
.L69_0:
    mov rsi, -9223372036854775808
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Ddigit_x2Dof:
    push rbp
    mov rbp, rsp
.L70_0:
    cmp rdi, 48
    jl .L70_1
    cmp rdi, 57
    jg .L70_1
    mov rsi, rdi
    sub rsi, 48
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L70_1:
    cmp rdi, 97
    jl .L70_2
    cmp rdi, 102
    jg .L70_2
    mov rsi, rdi
    sub rsi, 87
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L70_2:
    cmp rdi, 65
    jl .L70_3
    cmp rdi, 70
    jg .L70_3
    mov rsi, rdi
    sub rsi, 55
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L70_3:
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dacc_x2Dok:
    push rbp
    mov rbp, rsp
    mov r8, rdx
    mov r9, rcx
.L71_0:
    cmp rdi, 0
    je .L71_1
    mov rdi, -9223372036854775808
    add rdi, r8
    mov rax, rdi
    mov rcx, r9
    cqo
    idiv rcx
    mov rdi, rax
    cmp rsi, rdi
    jge .L71_2
    mov rdi, 0
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L71_2:
    mov rdi, 1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L71_1:
    mov rdi, 9223372036854775807
    sub rdi, r8
    mov rax, rdi
    mov rcx, r9
    cqo
    idiv rcx
    mov rdi, rax
    cmp rsi, rdi
    jle .L71_3
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L71_3:
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dto_x2Dint_x2Dloop:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L72_0:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov r14, rsi
    cmp r14, 48
    jl .L72_1
    cmp r14, 57
    jg .L72_1
    mov rsi, r14
    sub rsi, 48
    mov rdi, 10
    mov rdx, rsi
    mov rsi, r13
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dacc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L72_2
    mov rsi, rbx
    add rsi, 1
    mov rdi, r13
    imul rdi, 10
    mov r8, r14
    sub r8, 48
    add rdi, r8
    mov rbx, rsi
    mov r13, rdi
    jmp .L72_0
.L72_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L72_1:
    cmp r12, 0
    je .L72_3
    mov rsi, 0
    sub rsi, r13
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L72_3:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_to_int
zyl_cstr_to_int:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L73_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L73_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L73_1:
    cmp rbx, 4096
    jge .L73_2
    lea rax, [rip+.L74]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L73_2:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 45
    jne .L73_3
    mov rsi, rbx
    add rsi, 1
    mov rdi, 1
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dto_x2Dint_x2Dloop
.L73_3:
    mov rsi, 0
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dto_x2Dint_x2Dloop
zy_local_x2Fmain_0__rt__rt_x2Dto_x2Dint_x2Dbase_x2Dloop:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L75_0:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__rt__rt_x2Ddigit_x2Dof
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jge .L75_2
    jmp .L75_3
.L75_2:
    cmp r15, r14
    jl .L75_1
.L75_3:
    cmp r12, 0
    je .L75_4
    mov rsi, 0
    sub rsi, r13
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L75_4:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L75_1:
    mov rdi, r12
    mov rsi, r13
    mov rdx, r15
    mov rcx, r14
    call zy_local_x2Fmain_0__rt__rt_x2Dacc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L75_5
    mov rsi, rbx
    add rsi, 1
    mov rdi, r13
    imul rdi, r14
    add rdi, r15
    mov rbx, rsi
    mov r13, rdi
    jmp .L75_0
.L75_5:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dbase_x2Dof:
    push rbp
    mov rbp, rsp
.L76_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 48
    jne .L76_1
    mov rsi, rdi
    add rsi, 1
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 120
    jne .L76_3
    jmp .L76_4
.L76_3:
    cmp rsi, 88
    jne .L76_2
.L76_4:
    mov rdi, 16
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L76_2:
    cmp rsi, 111
    jne .L76_6
    jmp .L76_7
.L76_6:
    cmp rsi, 79
    jne .L76_5
.L76_7:
    mov rdi, 8
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L76_5:
    cmp rsi, 98
    jne .L76_9
    jmp .L76_10
.L76_9:
    cmp rsi, 66
    jne .L76_8
.L76_10:
    mov rsi, 2
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L76_8:
    mov rsi, 10
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L76_1:
    mov rsi, 10
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_to_int_base
zyl_cstr_to_int_base:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L77_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L77_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L77_1:
    cmp rbx, 4096
    jge .L77_2
    lea rax, [rip+.L78]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L77_2:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    cmp rax, 45
    sete al
    movzx rax, al
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    je .L77_3
    mov rsi, rbx
    add rsi, 1
    jmp .L77_4
.L77_3:
    mov rsi, rbx
.L77_4:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__rt__rt_x2Dbase_x2Dof
    mov rsi, rax
    cmp rsi, 10
    jne .L77_5
    mov rdi, rbx
    jmp .L77_6
.L77_5:
    mov r8, rbx
    add r8, 2
    mov rdi, r8
.L77_6:
    mov r8, 0
    mov rdx, r8
    mov rcx, rsi
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dto_x2Dint_x2Dbase_x2Dloop
zy_local_x2Fmain_0__rt__rt_x2Dident_x2Dbyte:
    push rbp
    mov rbp, rsp
.L79_0:
    cmp rdi, 65
    jl .L79_2
    cmp rdi, 90
    jg .L79_2
    jmp .L79_3
.L79_2:
    cmp rdi, 97
    jl .L79_4
    cmp rdi, 122
    jg .L79_4
    jmp .L79_5
.L79_4:
    cmp rdi, 48
    jl .L79_6
    cmp rdi, 57
    jg .L79_6
    jmp .L79_7
.L79_6:
    cmp rdi, 95
    jne .L79_1
.L79_7:
.L79_5:
.L79_3:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L79_1:
    mov rsi, 95
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dsanitize_x2Dloop:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L80_0:
    cmp r13, r14
    jl .L80_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L80_1:
    mov r15, rbx
    add r15, r13
    mov rsi, r12
    add rsi, r13
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__rt__rt_x2Dident_x2Dbyte
    mov rsi, rax
    mov rdx, r15
    mov rcx, rsi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 1
    mov r13, rsi
    jmp .L80_0
.globl zyl_cstr_sanitize
zyl_cstr_sanitize:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L81_0:
    mov r12, rsi
    cmp r12, 0
    jne .L81_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L81_1:
    cmp r12, 4096
    jge .L81_2
    lea rax, [rip+.L82]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L81_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    mov r13, rsi
    mov rsi, r13
    add rsi, 1
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rbx, rsi
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__rt__rt_x2Dsanitize_x2Dloop
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dhexval:
    push rbp
    mov rbp, rsp
.L83_0:
    cmp rdi, 48
    jl .L83_1
    cmp rdi, 57
    jg .L83_1
    mov rsi, rdi
    sub rsi, 48
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L83_1:
    cmp rdi, 97
    jl .L83_2
    cmp rdi, 102
    jg .L83_2
    mov rsi, rdi
    sub rsi, 87
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L83_2:
    cmp rdi, 65
    jl .L83_3
    cmp rdi, 70
    jg .L83_3
    mov rsi, rdi
    sub rsi, 55
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L83_3:
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Descape_x2Dbyte:
    push rbp
    mov rbp, rsp
.L84_0:
    cmp rdi, 110
    jne .L84_1
    mov rsi, 10
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L84_1:
    cmp rdi, 116
    jne .L84_2
    mov rsi, 9
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L84_2:
    cmp rdi, 114
    jne .L84_3
    mov rsi, 13
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L84_3:
    cmp rdi, 48
    jne .L84_4
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L84_4:
    cmp rdi, 34
    jne .L84_5
    mov rsi, 34
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L84_5:
    cmp rdi, 92
    jne .L84_6
    mov rsi, 92
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L84_6:
    cmp rdi, 101
    jne .L84_7
    mov rsi, 27
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L84_7:
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dhex_x2Descape_x2Dok:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L85_0:
    mov rdi, r12
    add rdi, 3
    cmp rdi, rsi
    jge .L85_1
    mov rsi, r12
    add rsi, 2
    add rsi, rbx
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__rt__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L85_2
    mov rsi, r12
    add rsi, 3
    add rsi, rbx
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__rt__rt_x2Dhexval
    mov rsi, rax
    mov rax, rsi
    cmp rax, 0
    setge al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L85_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L85_1:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Ddecode_x2Dloop:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    mov qword ptr [rbp-48], rdi
    mov qword ptr [rbp-56], rsi
    mov qword ptr [rbp-64], rdx
    mov r14, rcx
    mov r15, r8
.L86_0:
    mov rax, qword ptr [rbp-56]
    cmp rax, qword ptr [rbp-64]
    jl .L86_1
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L86_1:
    mov rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-56]
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rbx, rsi
    cmp rbx, 92
    jne .L86_2
    mov rsi, qword ptr [rbp-56]
    add rsi, 1
    cmp rsi, qword ptr [rbp-64]
    jl .L86_3
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L86_3:
    mov rsi, qword ptr [rbp-56]
    add rsi, 1
    add rsi, qword ptr [rbp-48]
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Descape_x2Dbyte
    mov rsi, rax
    cmp rsi, 0
    jl .L86_4
    mov rdi, r14
    add rdi, r15
    mov rdx, rdi
    mov rcx, rsi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-56]
    add rsi, 2
    mov rdi, r15
    add rdi, 1
    mov qword ptr [rbp-56], rsi
    mov r15, rdi
    jmp .L86_0
.L86_4:
    cmp r12, 120
    jne .L86_5
    mov rdi, qword ptr [rbp-48]
    mov rsi, qword ptr [rbp-56]
    mov rdx, qword ptr [rbp-64]
    call zy_local_x2Fmain_0__rt__rt_x2Dhex_x2Descape_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L86_5
    mov r12, r14
    add r12, r15
    mov r13, 16
    mov rsi, qword ptr [rbp-56]
    add rsi, 2
    add rsi, qword ptr [rbp-48]
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__rt__rt_x2Dhexval
    mov rsi, rax
    imul r13, rsi
    mov rsi, qword ptr [rbp-56]
    add rsi, 3
    add rsi, qword ptr [rbp-48]
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__rt__rt_x2Dhexval
    mov rsi, rax
    add rsi, r13
    mov rdx, r12
    mov rcx, rsi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-56]
    add rsi, 4
    mov rdi, r15
    add rdi, 1
    mov qword ptr [rbp-56], rsi
    mov r15, rdi
    jmp .L86_0
.L86_5:
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L86_2:
    mov rsi, r14
    add rsi, r15
    mov rdx, rsi
    mov rcx, rbx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-56]
    add rsi, 1
    mov rdi, r15
    add rdi, 1
    mov qword ptr [rbp-56], rsi
    mov r15, rdi
    jmp .L86_0
.globl zyl_cstr_decode
zyl_cstr_decode:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
    mov r12, rdx
    mov r13, rcx
.L87_0:
    mov r14, rsi
    cmp r14, 0
    jne .L87_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L87_1:
    cmp r14, 4096
    jge .L87_2
    lea rax, [rip+.L88]
    mov rsi, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L87_2:
    mov rsi, r13
    sub rsi, r12
    add rsi, 1
    add rsi, 1
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rbx, rsi
    mov rsi, 0
    mov rdi, r14
    mov rdx, r13
    mov rcx, rbx
    mov r8, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Ddecode_x2Dloop
    mov rsi, rax
    cmp rsi, 0
    jge .L87_3
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L87_3:
    add rsi, rbx
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dcount_x2Dnl:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L89_0:
    cmp rsi, r8
    jl .L89_1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L89_1:
    mov r10, rdi
    add r10, rsi
    mov rdx, r10
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r10, 0
    jne .L89_2
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L89_2:
    mov rbx, rsi
    add rbx, 1
    cmp r10, 10
    jne .L89_3
    mov r10, r9
    add r10, 1
    jmp .L89_4
.L89_3:
    mov r10, r9
.L89_4:
    mov rsi, rbx
    mov r9, r10
    jmp .L89_0
.globl zyl_cstr_count_newlines
zyl_cstr_count_newlines:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L90_0:
    mov r12, rdi
    cmp r12, 0
    jne .L90_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L90_1:
    cmp r12, 4096
    jge .L90_2
    lea rax, [rip+.L91]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L90_2:
    mov rsi, 0
    mov rdi, 0
    mov rdx, rbx
    mov rcx, rdi
    mov rdi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dcount_x2Dnl
zy_local_x2Fmain_0__rt__rt_x2Dlast_x2Dnl:
    push rbp
    mov rbp, rsp
.L92_0:
    cmp rsi, 0
    jge .L92_1
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L92_1:
    mov r8, rdi
    add r8, rsi
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 10
    jne .L92_2
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L92_2:
    mov r8, rsi
    sub r8, 1
    mov rsi, r8
    jmp .L92_0
.globl zyl_cstr_last_newline
zyl_cstr_last_newline:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L93_0:
    mov r12, rdi
    cmp r12, 0
    jne .L93_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L93_1:
    cmp r12, 4096
    jge .L93_2
    lea rax, [rip+.L94]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L93_2:
    mov rsi, rbx
    sub rsi, 1
    mov rdi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dlast_x2Dnl
zy_local_x2Fmain_0__rt__rt_x2Descapes_x2Dloop:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L95_0:
    cmp r12, r13
    jl .L95_1
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L95_1:
    mov rsi, rbx
    add rsi, r12
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 92
    jne .L95_2
    mov rsi, r12
    add rsi, 1
    cmp rsi, r13
    jl .L95_3
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L95_3:
    mov rsi, r12
    add rsi, 1
    add rsi, rbx
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__rt__rt_x2Descape_x2Dbyte
    mov rsi, rax
    cmp rsi, 0
    jl .L95_4
    mov rsi, r12
    add rsi, 2
    mov r12, rsi
    jmp .L95_0
.L95_4:
    mov rsi, r12
    add rsi, 1
    add rsi, rbx
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 120
    jne .L95_5
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__rt__rt_x2Dhex_x2Descape_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L95_5
    mov rsi, r12
    add rsi, 4
    mov r12, rsi
    jmp .L95_0
.L95_5:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L95_2:
    mov rsi, r12
    add rsi, 1
    mov r12, rsi
    jmp .L95_0
.globl zyl_cstr_escapes_ok
zyl_cstr_escapes_ok:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L96_0:
    cmp rdi, 0
    jne .L96_1
    mov r9, 0
    mov rax, r9
    mov rsp, rbp
    pop rbp
    ret
.L96_1:
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Descapes_x2Dloop
.globl zyl_view_ok
zyl_view_ok:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rsi
    mov r12, rdx
.L97_0:
    cmp rbx, 0
    jge .L97_2
    jmp .L97_3
.L97_2:
    cmp r12, 0
    jge .L97_1
.L97_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L97_1:
    cmp rdi, 0
    jle .L97_4
    cmp rdi, 4096
    jge .L97_4
    lea rax, [rip+.L98]
    mov rsi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dbad_x2Dstr
.L97_4:
    cmp rdi, 0
    jne .L97_5
    mov rsi, 0
    mov r13, rsi
    jmp .L97_6
.L97_5:
    call zy_local_x2Fmain_0__rt__rt_x2Dstrlen
    mov rsi, rax
    mov r13, rsi
.L97_6:
    cmp rbx, r13
    jg .L97_7
    mov rsi, r13
    sub rsi, rbx
    mov rax, r12
    mov rcx, rsi
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L97_7:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_view_byte
zyl_view_byte:
    push rbp
    mov rbp, rsp
    mov r8, rdx
    mov r9, rcx
.L99_0:
    cmp rdi, 0
    jne .L99_2
    jmp .L99_3
.L99_2:
    cmp r9, 0
    jge .L99_4
    jmp .L99_5
.L99_4:
    cmp r9, r8
    jl .L99_1
.L99_5:
.L99_3:
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L99_1:
    add rsi, r9
    add rsi, rdi
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__rt__rt_x2Dview_x2Dbase:
    push rbp
    mov rbp, rsp
.L100_0:
    cmp rdi, 0
    jne .L100_1
    lea rax, [rip+zyl_rtg_empty]
    mov r8, rax
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L100_1:
    add rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_view_cmp
zyl_view_cmp:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov qword ptr [rbp-48], rdx
    mov r12, rcx
    mov r13, r8
    mov r14, r9
.L101_0:
    cmp qword ptr [rbp-48], r14
    jge .L101_1
    mov r8, qword ptr [rbp-48]
    jmp .L101_2
.L101_1:
    mov r8, r14
.L101_2:
    mov r15, r8
    cmp r15, 0
    jle .L101_3
    call zy_local_x2Fmain_0__rt__rt_x2Dview_x2Dbase
    mov rbx, rax
    mov rdi, r12
    mov rsi, r13
    call zy_local_x2Fmain_0__rt__rt_x2Dview_x2Dbase
    mov rsi, rax
    mov rdi, rbx
    mov rdx, r15
    call zy_local_x2Fmain_0__rt__rt_x2Dmem_x2Dcmp
    mov rsi, rax
    jmp .L101_4
.L101_3:
    mov rdi, 0
    mov rsi, rdi
.L101_4:
    cmp rsi, 0
    jne .L101_6
    mov rdi, 0
    jmp .L101_7
.L101_6:
    mov r8, 1
    mov rdi, r8
.L101_7:
    cmp rdi, 0
    je .L101_5
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L101_5:
    cmp qword ptr [rbp-48], r14
    jge .L101_8
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L101_8:
    cmp qword ptr [rbp-48], r14
    jle .L101_9
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L101_9:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_view_find
zyl_view_find:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L102_0:
    cmp rdi, 0
    jne .L102_2
    jmp .L102_3
.L102_2:
    cmp r9, 0
    jge .L102_4
    jmp .L102_5
.L102_4:
    cmp r9, r8
    jl .L102_1
.L102_5:
.L102_3:
    mov rbx, -1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L102_1:
    add rsi, rdi
    mov rdi, r10
    and rdi, 255
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r8
    mov rcx, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dfind_x2Dbyte
zy_local_x2Fmain_0__rt__rt_x2Dview_x2Dcopy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov rsi, rcx
.L103_0:
    mov rdi, r13
    add rdi, 1
    call zyl_ralloc
    mov rsi, rax
    mov r14, rsi
    cmp rbx, 0
    jle .L103_1
    cmp r13, 0
    jle .L103_1
    mov rsi, rbx
    add rsi, r12
    mov rdi, r14
    mov rdx, r13
    call zy_local_x2Fmain_0__rt__rt_x2Dcopy
    mov rsi, rax
    jmp .L103_2
.L103_1:
    mov rdi, 0
    mov rsi, rdi
.L103_2:
    mov rsi, r14
    add rsi, r13
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_view_copy
zyl_view_copy:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L104_0:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dview_x2Dcopy
.globl zyl_view_copy_r
zyl_view_copy_r:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L105_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r9, rax
    mov rdx, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__rt__rt_x2Dview_x2Dcopy
zy_local_x2Fmain_0__rt__rt_x2Dlast_x2Dslash:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L106_0:
    mov r9, rdi
    add r9, rsi
    mov rdx, r9
    movzx eax, byte ptr [rdx]
    mov r9, rax
    cmp r9, 0
    jne .L106_1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L106_1:
    mov r10, rsi
    add r10, 1
    cmp r9, 47
    jne .L106_2
    mov r9, rsi
    jmp .L106_3
.L106_2:
    mov r9, r8
.L106_3:
    mov rsi, r10
    mov r8, r9
    jmp .L106_0
.globl zyl_dirname_cstr
zyl_dirname_cstr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L107_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L107_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L107_1:
    mov rsi, 0
    mov rdi, -1
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__rt__rt_x2Dlast_x2Dslash
    mov rsi, rax
    cmp rsi, 0
    jge .L107_2
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L107_4
    mov rdi, 0
    jmp .L107_5
.L107_4:
    mov r8, 1
    mov rdi, r8
.L107_5:
    jmp .L107_3
.L107_2:
    add rsi, 1
    mov rdi, rsi
.L107_3:
    mov r12, rdi
    mov rsi, r12
    add rsi, 1
    mov rdi, rsi
    call zyl_heap_alloc
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L107_6
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L107_6:
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__rt__rt_x2Dcopy
    mov rsi, rax
    mov rsi, r13
    add rsi, r12
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
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
.L43:
    .string "cstr-concat"
.L44:
    .string "cstr-concat"
.L49:
    .string "cstr-substr"
.L58:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L60:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L61:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L67:
    .string "cstr-sub"
.L74:
    .string "cstr-to-int"
.L78:
    .string "cstr-to-int-base"
.L82:
    .string "cstr-sanitize"
.L88:
    .string "cstr-decode"
.L91:
    .string "cstr-count-newlines"
.L94:
    .string "cstr-last-newline"
.L98:
    .string "view"
.bss
.p2align 6
zyl_rtg_cpu_avx2:
    .zero 8
.p2align 6
zyl_rtg_empty:
    .zero 64
