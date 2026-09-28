.file "rt.zyl"
.intel_syntax noprefix
.text
zy_local_x2Fmain_0__base__rt_x2Dstrlen:
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
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dfrom
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
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dfrom:
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
    call zy_local_x2Fmain_0__base__rt_x2Davx2
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
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D32
.L1_3:
    mov rsi, r12
    add rsi, 16
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D16
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
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D16:
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
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D32:
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
zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L4_0:
    cmp r8, 16
    jl .L4_1
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r9, rax
    cmp r9, 65535
    jne .L4_2
    mov r9, rdi
    add r9, 16
    mov r10, rsi
    add r10, 16
    mov rbx, r8
    sub rbx, 16
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L4_0
.L4_2:
    mov r9, 0
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L4_1:
    mov rdx, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dbytes_x2Deq
zy_local_x2Fmain_0__base__rt_x2Dbytes_x2Deq:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L5_0:
    cmp r8, 0
    jne .L5_1
    mov r9, 1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L5_1:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jne .L5_2
    mov r9, rdi
    add r9, 1
    mov r10, rsi
    add r10, 1
    mov rbx, r8
    sub rbx, 1
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L5_0
.L5_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrcmp:
    push rbp
    mov rbp, rsp
.L6_0:
    mov r8, rdi
    and r8, 4095
    cmp r8, 4080
    jle .L6_2
    jmp .L6_3
.L6_2:
    mov r8, rsi
    and r8, 4095
    cmp r8, 4080
    jle .L6_1
.L6_3:
    mov r8, 16
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrcmp_x2Dbytes
.L6_1:
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
    jne .L6_4
    mov r9, rdi
    add r9, 16
    mov r10, rsi
    add r10, 16
    mov rdi, r9
    mov rsi, r10
    jmp .L6_0
.L6_4:
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
    jge .L6_5
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L6_5:
    cmp rdi, rsi
    jle .L6_6
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L6_6:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrcmp_x2Dbytes:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L7_0:
    cmp r8, 0
    jne .L7_1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrcmp
.L7_1:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jne .L7_5
    mov r10, 0
    jmp .L7_6
.L7_5:
    mov rbx, 1
    mov r10, rbx
.L7_6:
    cmp r10, 0
    je .L7_3
    jmp .L7_4
.L7_3:
    cmp r9, 0
    jne .L7_2
.L7_4:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jge .L7_7
    mov rbx, -1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L7_7:
    cmp r9, r10
    jle .L7_8
    mov r9, 1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L7_8:
    mov r9, 0
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L7_2:
    mov r9, rdi
    add r9, 1
    mov r10, rsi
    add r10, 1
    mov rbx, r8
    sub rbx, 1
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L7_0
zy_local_x2Fmain_0__base__rt_x2Dbyte_x2Dorder:
    push rbp
    mov rbp, rsp
.L8_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rdi, rsi
    jge .L8_1
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L8_1:
    cmp rdi, rsi
    jle .L8_2
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L8_2:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dhex:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L9_0:
    lea rax, [rip+.L10]
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
    jge .L9_1
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
.L9_1:
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
    jmp .L9_0
zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rsi
.L11_0:
    lea rax, [rip+.L12]
    mov r12, rax
    lea rax, [rip+.L13]
    mov r13, rax
    lea rax, [rip+.L14]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dhex
    mov rsi, rax
    lea rax, [rip+.L15]
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
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
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
zy_local_x2Fmain_0__base__strlen_x2Dof:
    push rbp
    mov rbp, rsp
.L16_0:
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen
zy_local_x2Fmain_0__base__rt_x2Dcopy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L17_0:
    cmp r13, 16
    jl .L17_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L17_1:
    cmp r13, 8
    jl .L17_2
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
.L17_2:
    cmp r13, 4
    jl .L17_3
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
.L17_3:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2Dbytes
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L18_0:
    cmp r8, 16
    jle .L18_1
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
    jmp .L18_0
.L18_1:
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
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2Dbytes:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
    mov rdi, rdx
.L19_0:
    cmp rdi, 0
    jne .L19_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L19_1:
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
    call zy_local_x2Fmain_0__base__rt_x2Dcopy_x2Dbytes
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dmem_x2Dcmp:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
.L20_0:
    cmp r8, 16
    jl .L20_1
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r9, rax
    xor r9, 65535
    cmp r9, 0
    jne .L20_2
    mov r10, rdi
    add r10, 16
    mov rbx, rsi
    add rbx, 16
    mov r12, r8
    sub r12, 16
    mov rdi, r10
    mov rsi, rbx
    mov r8, r12
    jmp .L20_0
.L20_2:
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
    jge .L20_3
    mov rbx, -1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L20_3:
    cmp r10, r9
    jle .L20_4
    mov r9, 1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L20_4:
    mov r9, 0
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L20_1:
    cmp r8, 0
    jne .L20_5
    mov r9, 0
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L20_5:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jne .L20_6
    mov r9, rdi
    add r9, 1
    mov r10, rsi
    add r10, 1
    mov rbx, r8
    sub rbx, 1
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L20_0
.L20_6:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rdi, rsi
    jge .L20_7
    mov r8, -1
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L20_7:
    cmp rdi, rsi
    jle .L20_8
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L20_8:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dfind_x2Dbyte:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L21_0:
    mov r10, rsi
    sub r10, r9
    cmp r10, 16
    jl .L21_1
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
    jne .L21_2
    mov rbx, r9
    add rbx, 16
    mov r9, rbx
    jmp .L21_0
.L21_2:
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
.L21_1:
    cmp r9, rsi
    jl .L21_3
    mov r10, -1
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L21_3:
    mov r10, rdi
    add r10, r9
    mov rdx, r10
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r10, r8
    jne .L21_4
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L21_4:
    mov r10, r9
    add r10, 1
    mov r9, r10
    jmp .L21_0
zy_local_x2Fmain_0__base__rt_x2Dalloc:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L22_0:
    call zyl_ralloc
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dcur_x2Dregion:
    push rbp
    mov rbp, rsp
.L23_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof:
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
.L24_0:
    mov rdi, r12
    add rdi, 1
    call zyl_ralloc
    mov rsi, rax
    mov r13, rsi
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
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
zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dnull:
    push rbp
    mov rbp, rsp
.L25_0:
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Davx2:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L26_0:
    lea rax, [rip+zyl_rtg_cpu_avx2]
    mov rsi, rax
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L26_1
    call zy_local_x2Fmain_0__base__rt_x2Davx2_x2Dprobe
    mov rsi, rax
    cmp rsi, 0
    je .L26_2
    mov rsi, 2
    jmp .L26_3
.L26_2:
    mov rdi, 1
    mov rsi, rdi
.L26_3:
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
.L26_1:
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
zy_local_x2Fmain_0__base__rt_x2Davx2_x2Dprobe:
    push rbp
    mov rbp, rsp
.L27_0:
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
    jge .L27_1
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L27_1:
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
    jne .L27_2
    xor ecx, ecx
    xgetbv
    mov eax, eax
    mov rsi, rax
    and rsi, 6
    cmp rsi, 6
    jne .L27_3
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
.L27_3:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L27_2:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cpuid_features
zyl_cpuid_features:
    push rbp
    mov rbp, rsp
.L28_0:
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
    jle .L28_1
    mov rdi, 1
    jmp .L28_2
.L28_1:
    mov r8, 0
    mov rdi, r8
.L28_2:
    mov r8, rsi
    and r8, 2
    cmp r8, 0
    jle .L28_3
    mov r8, 2
    jmp .L28_4
.L28_3:
    mov r9, 0
    mov r8, r9
.L28_4:
    mov r9, rsi
    and r9, 524288
    cmp r9, 0
    jle .L28_5
    mov r9, 4
    jmp .L28_6
.L28_5:
    mov r10, 0
    mov r9, r10
.L28_6:
    and rsi, 268435456
    cmp rsi, 0
    jle .L28_7
    mov rsi, 8
    jmp .L28_8
.L28_7:
    mov r10, 0
    mov rsi, r10
.L28_8:
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
.L29_0:
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
.globl zyl_cstr_len
zyl_cstr_len:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L30_0:
    mov rsi, rbx
    cmp rsi, 4096
    jge .L30_1
    cmp rsi, 0
    jne .L30_2
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L30_2:
    lea rax, [rip+.L31]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L30_1:
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen
zy_local_x2Fmain_0__cstr__rt_x2Dbad_x2Dlen:
    push rbp
    mov rbp, rsp
.L32_0:
    lea rax, [rip+.L33]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
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
.L34_0:
    cmp rdi, rsi
    jne .L34_1
    mov r8, 1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L34_1:
    cmp rdi, 4096
    jge .L34_2
    cmp rdi, 0
    jne .L34_3
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L34_3:
    lea rax, [rip+.L35]
    mov r8, rax
    mov rsi, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L34_2:
    cmp rsi, 4096
    jge .L34_4
    cmp rsi, 0
    jne .L34_5
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L34_5:
    lea rax, [rip+.L36]
    mov r8, rax
    mov rdi, rsi
    mov rsi, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L34_4:
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
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
.L37_0:
    cmp rdi, rsi
    jne .L37_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L37_1:
    cmp rdi, 0
    jne .L37_2
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L37_2:
    cmp rsi, 0
    jne .L37_3
    mov r8, 1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L37_3:
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrcmp
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
.L38_0:
    mov r13, rbx
    cmp r12, 0
    jge .L38_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L38_1:
    cmp r13, 4096
    jge .L38_2
    cmp r13, 0
    jne .L38_3
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L38_3:
    lea rax, [rip+.L39]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L38_2:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    cmp r12, rsi
    jl .L38_4
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L38_4:
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
zy_local_x2Fmain_0__cstr__rt_x2Dbad_x2Dat:
    push rbp
    mov rbp, rsp
.L40_0:
    lea rax, [rip+.L41]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
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
.L42_0:
    mov r12, rdi
    mov r13, rbx
    cmp r12, r13
    jne .L42_1
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L42_1:
    cmp r12, 0
    jne .L42_3
    jmp .L42_4
.L42_3:
    cmp r13, 0
    jne .L42_2
.L42_4:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L42_2:
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r14, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    cmp r14, rsi
    jne .L42_5
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
.L42_5:
    mov rdi, rsi
    add rdi, 2
    cmp r14, rdi
    jge .L42_6
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L42_6:
    mov rdi, r14
    sub rdi, rsi
    add rdi, r12
    mov r8, rdi
    sub r8, 1
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 58
    jne .L42_7
    mov r8, rdi
    sub r8, 2
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 58
    jne .L42_8
    mov rdx, rsi
    mov rsi, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
.L42_8:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L42_7:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__cstr__rt_x2Dconcat:
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
.L43_0:
    mov r12, rdi
    mov r13, rsi
    cmp r12, 0
    jle .L43_1
    cmp r12, 4096
    jge .L43_1
    lea rax, [rip+.L44]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
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
.L43_1:
    cmp r13, 0
    jle .L43_2
    cmp r13, 4096
    jge .L43_2
    lea rax, [rip+.L45]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
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
.L43_2:
    cmp r12, 0
    jne .L43_3
    mov rsi, 0
    mov r14, rsi
    jmp .L43_4
.L43_3:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r14, rsi
.L43_4:
    cmp r13, 0
    jne .L43_5
    mov rsi, 0
    mov r15, rsi
    jmp .L43_6
.L43_5:
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r15, rsi
.L43_6:
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
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, r14
    mov rdi, rsi
    mov rsi, r13
    mov rdx, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
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
.globl zyl_cstr_concat
zyl_cstr_concat:
    push rbp
    mov rbp, rsp
.L46_0:
    mov r8, 0
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dconcat
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
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dconcat
zy_local_x2Fmain_0__cstr__rt_x2Dsubstr:
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
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
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
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
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
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
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
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dsubstr
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
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dsubstr
zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte:
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
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte
.globl zyl_cstr_from_byte_r
zyl_cstr_from_byte_r:
    push rbp
    mov rbp, rsp
.L54_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte
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
.L55_0:
    cmp rbx, 0
    jge .L55_2
    jmp .L55_3
.L55_2:
    cmp r12, 0
    jge .L55_1
.L55_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L55_1:
    cmp rdi, 0
    jle .L55_4
    cmp rdi, 4096
    jge .L55_4
    lea rax, [rip+.L56]
    mov rsi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L55_4:
    cmp rdi, 0
    jne .L55_5
    mov rsi, 0
    mov r13, rsi
    jmp .L55_6
.L55_5:
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r13, rsi
.L55_6:
    cmp rbx, r13
    jg .L55_7
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
.L55_7:
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
.L57_0:
    cmp rdi, 0
    jne .L57_2
    jmp .L57_3
.L57_2:
    cmp r9, 0
    jge .L57_4
    jmp .L57_5
.L57_4:
    cmp r9, r8
    jl .L57_1
.L57_5:
.L57_3:
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L57_1:
    add rsi, r9
    add rsi, rdi
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dbase:
    push rbp
    mov rbp, rsp
.L58_0:
    cmp rdi, 0
    jne .L58_1
    lea rax, [rip+zyl_rtg_empty]
    mov r8, rax
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L58_1:
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
.L59_0:
    cmp qword ptr [rbp-48], r14
    jge .L59_1
    mov r8, qword ptr [rbp-48]
    jmp .L59_2
.L59_1:
    mov r8, r14
.L59_2:
    mov r15, r8
    cmp r15, 0
    jle .L59_3
    call zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dbase
    mov rbx, rax
    mov rdi, r12
    mov rsi, r13
    call zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dbase
    mov rsi, rax
    mov rdi, rbx
    mov rdx, r15
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Dcmp
    mov rsi, rax
    jmp .L59_4
.L59_3:
    mov rdi, 0
    mov rsi, rdi
.L59_4:
    cmp rsi, 0
    jne .L59_6
    mov rdi, 0
    jmp .L59_7
.L59_6:
    mov r8, 1
    mov rdi, r8
.L59_7:
    cmp rdi, 0
    je .L59_5
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L59_5:
    cmp qword ptr [rbp-48], r14
    jge .L59_8
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
.L59_8:
    cmp qword ptr [rbp-48], r14
    jle .L59_9
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
.L59_9:
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
.L60_0:
    cmp rdi, 0
    jne .L60_2
    jmp .L60_3
.L60_2:
    cmp r9, 0
    jge .L60_4
    jmp .L60_5
.L60_4:
    cmp r9, r8
    jl .L60_1
.L60_5:
.L60_3:
    mov rbx, -1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L60_1:
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
    jmp zy_local_x2Fmain_0__base__rt_x2Dfind_x2Dbyte
zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dcopy:
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
.L61_0:
    mov rdi, r13
    add rdi, 1
    call zyl_ralloc
    mov rsi, rax
    mov r14, rsi
    cmp rbx, 0
    jle .L61_1
    cmp r13, 0
    jle .L61_1
    mov rsi, rbx
    add rsi, r12
    mov rdi, r14
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    jmp .L61_2
.L61_1:
    mov rdi, 0
    mov rsi, rdi
.L61_2:
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
.L62_0:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dcopy
.globl zyl_view_copy_r
zyl_view_copy_r:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L63_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r9, rax
    mov rdx, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dcopy
zy_local_x2Fmain_0__cstr__rt_x2Dlast_x2Dslash:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L64_0:
    mov r9, rdi
    add r9, rsi
    mov rdx, r9
    movzx eax, byte ptr [rdx]
    mov r9, rax
    cmp r9, 0
    jne .L64_1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L64_1:
    mov r10, rsi
    add r10, 1
    cmp r9, 47
    jne .L64_2
    mov r9, rsi
    jmp .L64_3
.L64_2:
    mov r9, r8
.L64_3:
    mov rsi, r10
    mov r8, r9
    jmp .L64_0
.globl zyl_dirname_cstr
zyl_dirname_cstr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L65_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L65_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L65_1:
    mov rsi, 0
    mov rdi, -1
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__cstr__rt_x2Dlast_x2Dslash
    mov rsi, rax
    cmp rsi, 0
    jge .L65_2
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L65_4
    mov rdi, 0
    jmp .L65_5
.L65_4:
    mov r8, 1
    mov rdi, r8
.L65_5:
    jmp .L65_3
.L65_2:
    add rsi, 1
    mov rdi, rsi
.L65_3:
    mov r12, rdi
    mov rsi, r12
    add rsi, 1
    mov rdi, rsi
    call zyl_heap_alloc
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L65_6
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L65_6:
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
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
zy_local_x2Fmain_0__text__rt_x2Dndigits:
    push rbp
    mov rbp, rsp
.L66_0:
    mov rsi, -10
    mov r8, 1
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dnd
zy_local_x2Fmain_0__text__rt_x2Dnd:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L67_0:
    cmp rdi, rsi
    jle .L67_2
    jmp .L67_3
.L67_2:
    cmp r8, 19
    jne .L67_1
.L67_3:
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L67_1:
    mov r9, rsi
    imul r9, 10
    mov r10, r8
    add r10, 1
    mov rsi, r9
    mov r8, r10
    jmp .L67_0
zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dpairs:
    push rbp
    mov rbp, rsp
.L68_0:
    lea rax, [rip+.L69]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
.L70_0:
    cmp rsi, -100
    jg .L70_1
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
    lea rax, [rip+.L71]
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
    jmp .L70_0
.L70_1:
    cmp rsi, -10
    jg .L70_2
    lea rax, [rip+.L72]
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
.L70_2:
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
zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rsi
.L73_0:
    cmp rdi, 0
    jle .L73_1
    mov rsi, 0
    sub rsi, rdi
    jmp .L73_2
.L73_1:
    mov rsi, rdi
.L73_2:
    mov r12, rsi
    cmp rdi, 0
    jge .L73_3
    mov rsi, 1
    jmp .L73_4
.L73_3:
    mov rdi, 0
    mov rsi, rdi
.L73_4:
    mov r13, rsi
    mov rsi, -10
    mov rdi, 1
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dnd
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
    jne .L73_5
    mov rsi, 45
    mov rdx, rbx
    mov rcx, rsi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    jmp .L73_6
.L73_5:
    mov rdi, 0
    mov rsi, rdi
.L73_6:
    mov rsi, r14
    sub rsi, 1
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
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
.L74_0:
    mov rsi, 0
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
.globl zyl_int_text_r
zyl_int_text_r:
    push rbp
    mov rbp, rsp
.L75_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
zy_local_x2Fmain_0__text__rt_x2Darena_x2Dstr:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L76_0:
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
.L77_0:
    mov r14, rsi
    cmp r14, 0
    jne .L77_2
    jmp .L77_3
.L77_2:
    cmp r12, 0
    jge .L77_4
    jmp .L77_5
.L77_4:
    cmp r13, 0
    jge .L77_1
.L77_5:
.L77_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L77_1:
    cmp r14, 4096
    jge .L77_6
    lea rax, [rip+.L78]
    mov rsi, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
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
.L77_6:
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r12
    add rdi, r13
    cmp rdi, rsi
    jle .L77_7
    mov rdi, rsi
    sub rdi, r12
    cmp rdi, 0
    jge .L77_9
    mov rdi, 0
    jmp .L77_10
.L77_9:
    sub rsi, r12
    mov rdi, rsi
.L77_10:
    jmp .L77_8
.L77_7:
    mov rdi, r13
.L77_8:
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
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
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
.L79_0:
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov rsi, rax
    mov r12, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
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
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dllong_x2Dmin:
    push rbp
    mov rbp, rsp
.L80_0:
    mov rsi, -9223372036854775808
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dof:
    push rbp
    mov rbp, rsp
.L81_0:
    cmp rdi, 48
    jl .L81_1
    cmp rdi, 57
    jg .L81_1
    mov rsi, rdi
    sub rsi, 48
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L81_1:
    cmp rdi, 97
    jl .L81_2
    cmp rdi, 102
    jg .L81_2
    mov rsi, rdi
    sub rsi, 87
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L81_2:
    cmp rdi, 65
    jl .L81_3
    cmp rdi, 70
    jg .L81_3
    mov rsi, rdi
    sub rsi, 55
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L81_3:
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dacc_x2Dok:
    push rbp
    mov rbp, rsp
    mov r8, rdx
    mov r9, rcx
.L82_0:
    cmp rdi, 0
    je .L82_1
    mov rdi, -9223372036854775808
    add rdi, r8
    mov rax, rdi
    mov rcx, r9
    cqo
    idiv rcx
    mov rdi, rax
    cmp rsi, rdi
    jge .L82_2
    mov rdi, 0
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L82_2:
    mov rdi, 1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L82_1:
    mov rdi, 9223372036854775807
    sub rdi, r8
    mov rax, rdi
    mov rcx, r9
    cqo
    idiv rcx
    mov rdi, rax
    cmp rsi, rdi
    jle .L82_3
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L82_3:
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L83_0:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov r14, rsi
    cmp r14, 48
    jl .L83_1
    cmp r14, 57
    jg .L83_1
    mov rsi, r14
    sub rsi, 48
    mov rdi, 10
    mov rdx, rsi
    mov rsi, r13
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dacc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L83_2
    mov rsi, rbx
    add rsi, 1
    mov rdi, r13
    imul rdi, 10
    mov r8, r14
    sub r8, 48
    add rdi, r8
    mov rbx, rsi
    mov r13, rdi
    jmp .L83_0
.L83_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L83_1:
    cmp r12, 0
    je .L83_3
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
.L83_3:
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
.L84_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L84_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L84_1:
    cmp rbx, 4096
    jge .L84_2
    lea rax, [rip+.L85]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L84_2:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 45
    jne .L84_3
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
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop
.L84_3:
    mov rsi, 0
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop
zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dbase_x2Dloop:
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
.L86_0:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dof
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jge .L86_2
    jmp .L86_3
.L86_2:
    cmp r15, r14
    jl .L86_1
.L86_3:
    cmp r12, 0
    je .L86_4
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
.L86_4:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L86_1:
    mov rdi, r12
    mov rsi, r13
    mov rdx, r15
    mov rcx, r14
    call zy_local_x2Fmain_0__text__rt_x2Dacc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L86_5
    mov rsi, rbx
    add rsi, 1
    mov rdi, r13
    imul rdi, r14
    add rdi, r15
    mov rbx, rsi
    mov r13, rdi
    jmp .L86_0
.L86_5:
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
zy_local_x2Fmain_0__text__rt_x2Dbase_x2Dof:
    push rbp
    mov rbp, rsp
.L87_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 48
    jne .L87_1
    mov rsi, rdi
    add rsi, 1
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 120
    jne .L87_3
    jmp .L87_4
.L87_3:
    cmp rsi, 88
    jne .L87_2
.L87_4:
    mov rdi, 16
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L87_2:
    cmp rsi, 111
    jne .L87_6
    jmp .L87_7
.L87_6:
    cmp rsi, 79
    jne .L87_5
.L87_7:
    mov rdi, 8
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L87_5:
    cmp rsi, 98
    jne .L87_9
    jmp .L87_10
.L87_9:
    cmp rsi, 66
    jne .L87_8
.L87_10:
    mov rsi, 2
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L87_8:
    mov rsi, 10
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L87_1:
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
.L88_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L88_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L88_1:
    cmp rbx, 4096
    jge .L88_2
    lea rax, [rip+.L89]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L88_2:
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
    je .L88_3
    mov rsi, rbx
    add rsi, 1
    jmp .L88_4
.L88_3:
    mov rsi, rbx
.L88_4:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__text__rt_x2Dbase_x2Dof
    mov rsi, rax
    cmp rsi, 10
    jne .L88_5
    mov rdi, rbx
    jmp .L88_6
.L88_5:
    mov r8, rbx
    add r8, 2
    mov rdi, r8
.L88_6:
    mov r8, 0
    mov rdx, r8
    mov rcx, rsi
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dbase_x2Dloop
zy_local_x2Fmain_0__text__rt_x2Dident_x2Dbyte:
    push rbp
    mov rbp, rsp
.L90_0:
    cmp rdi, 65
    jl .L90_2
    cmp rdi, 90
    jg .L90_2
    jmp .L90_3
.L90_2:
    cmp rdi, 97
    jl .L90_4
    cmp rdi, 122
    jg .L90_4
    jmp .L90_5
.L90_4:
    cmp rdi, 48
    jl .L90_6
    cmp rdi, 57
    jg .L90_6
    jmp .L90_7
.L90_6:
    cmp rdi, 95
    jne .L90_1
.L90_7:
.L90_5:
.L90_3:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L90_1:
    mov rsi, 95
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dsanitize_x2Dloop:
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
.L91_0:
    cmp r13, r14
    jl .L91_1
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
.L91_1:
    mov r15, rbx
    add r15, r13
    mov rsi, r12
    add rsi, r13
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__text__rt_x2Dident_x2Dbyte
    mov rsi, rax
    mov rdx, r15
    mov rcx, rsi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 1
    mov r13, rsi
    jmp .L91_0
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
.L92_0:
    mov r12, rsi
    cmp r12, 0
    jne .L92_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L92_1:
    cmp r12, 4096
    jge .L92_2
    lea rax, [rip+.L93]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L92_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
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
    call zy_local_x2Fmain_0__text__rt_x2Dsanitize_x2Dloop
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dhexval:
    push rbp
    mov rbp, rsp
.L94_0:
    cmp rdi, 48
    jl .L94_1
    cmp rdi, 57
    jg .L94_1
    mov rsi, rdi
    sub rsi, 48
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L94_1:
    cmp rdi, 97
    jl .L94_2
    cmp rdi, 102
    jg .L94_2
    mov rsi, rdi
    sub rsi, 87
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L94_2:
    cmp rdi, 65
    jl .L94_3
    cmp rdi, 70
    jg .L94_3
    mov rsi, rdi
    sub rsi, 55
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L94_3:
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Descape_x2Dbyte:
    push rbp
    mov rbp, rsp
.L95_0:
    cmp rdi, 110
    jne .L95_1
    mov rsi, 10
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L95_1:
    cmp rdi, 116
    jne .L95_2
    mov rsi, 9
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L95_2:
    cmp rdi, 114
    jne .L95_3
    mov rsi, 13
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L95_3:
    cmp rdi, 48
    jne .L95_4
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L95_4:
    cmp rdi, 34
    jne .L95_5
    mov rsi, 34
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L95_5:
    cmp rdi, 92
    jne .L95_6
    mov rsi, 92
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L95_6:
    cmp rdi, 101
    jne .L95_7
    mov rsi, 27
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L95_7:
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dhex_x2Descape_x2Dok:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L96_0:
    mov rdi, r12
    add rdi, 3
    cmp rdi, rsi
    jge .L96_1
    mov rsi, r12
    add rsi, 2
    add rsi, rbx
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L96_2
    mov rsi, r12
    add rsi, 3
    add rsi, rbx
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
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
.L96_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L96_1:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Ddecode_x2Dloop:
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
.L97_0:
    mov rax, qword ptr [rbp-56]
    cmp rax, qword ptr [rbp-64]
    jl .L97_1
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L97_1:
    mov rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-56]
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rbx, rsi
    cmp rbx, 92
    jne .L97_2
    mov rsi, qword ptr [rbp-56]
    add rsi, 1
    cmp rsi, qword ptr [rbp-64]
    jl .L97_3
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
.L97_3:
    mov rsi, qword ptr [rbp-56]
    add rsi, 1
    add rsi, qword ptr [rbp-48]
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Descape_x2Dbyte
    mov rsi, rax
    cmp rsi, 0
    jl .L97_4
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
    jmp .L97_0
.L97_4:
    cmp r12, 120
    jne .L97_5
    mov rdi, qword ptr [rbp-48]
    mov rsi, qword ptr [rbp-56]
    mov rdx, qword ptr [rbp-64]
    call zy_local_x2Fmain_0__text__rt_x2Dhex_x2Descape_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L97_5
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
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    imul r13, rsi
    mov rsi, qword ptr [rbp-56]
    add rsi, 3
    add rsi, qword ptr [rbp-48]
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
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
    jmp .L97_0
.L97_5:
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
.L97_2:
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
    jmp .L97_0
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
.L98_0:
    mov r14, rsi
    cmp r14, 0
    jne .L98_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L98_1:
    cmp r14, 4096
    jge .L98_2
    lea rax, [rip+.L99]
    mov rsi, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
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
.L98_2:
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
    call zy_local_x2Fmain_0__text__rt_x2Ddecode_x2Dloop
    mov rsi, rax
    cmp rsi, 0
    jge .L98_3
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L98_3:
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
zy_local_x2Fmain_0__text__rt_x2Dcount_x2Dnl:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L100_0:
    cmp rsi, r8
    jl .L100_1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L100_1:
    mov r10, rdi
    add r10, rsi
    mov rdx, r10
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r10, 0
    jne .L100_2
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L100_2:
    mov rbx, rsi
    add rbx, 1
    cmp r10, 10
    jne .L100_3
    mov r10, r9
    add r10, 1
    jmp .L100_4
.L100_3:
    mov r10, r9
.L100_4:
    mov rsi, rbx
    mov r9, r10
    jmp .L100_0
.globl zyl_cstr_count_newlines
zyl_cstr_count_newlines:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L101_0:
    mov r12, rdi
    cmp r12, 0
    jne .L101_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L101_1:
    cmp r12, 4096
    jge .L101_2
    lea rax, [rip+.L102]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L101_2:
    mov rsi, 0
    mov rdi, 0
    mov rdx, rbx
    mov rcx, rdi
    mov rdi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dcount_x2Dnl
zy_local_x2Fmain_0__text__rt_x2Dlast_x2Dnl:
    push rbp
    mov rbp, rsp
.L103_0:
    cmp rsi, 0
    jge .L103_1
    mov r8, -1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L103_1:
    mov r8, rdi
    add r8, rsi
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 10
    jne .L103_2
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L103_2:
    mov r8, rsi
    sub r8, 1
    mov rsi, r8
    jmp .L103_0
.globl zyl_cstr_last_newline
zyl_cstr_last_newline:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L104_0:
    mov r12, rdi
    cmp r12, 0
    jne .L104_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L104_1:
    cmp r12, 4096
    jge .L104_2
    lea rax, [rip+.L105]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L104_2:
    mov rsi, rbx
    sub rsi, 1
    mov rdi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dlast_x2Dnl
zy_local_x2Fmain_0__text__rt_x2Descapes_x2Dloop:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L106_0:
    cmp r12, r13
    jl .L106_1
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L106_1:
    mov rsi, rbx
    add rsi, r12
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 92
    jne .L106_2
    mov rsi, r12
    add rsi, 1
    cmp rsi, r13
    jl .L106_3
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L106_3:
    mov rsi, r12
    add rsi, 1
    add rsi, rbx
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__text__rt_x2Descape_x2Dbyte
    mov rsi, rax
    cmp rsi, 0
    jl .L106_4
    mov rsi, r12
    add rsi, 2
    mov r12, rsi
    jmp .L106_0
.L106_4:
    mov rsi, r12
    add rsi, 1
    add rsi, rbx
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 120
    jne .L106_5
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__text__rt_x2Dhex_x2Descape_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L106_5
    mov rsi, r12
    add rsi, 4
    mov r12, rsi
    jmp .L106_0
.L106_5:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L106_2:
    mov rsi, r12
    add rsi, 1
    mov r12, rsi
    jmp .L106_0
.globl zyl_cstr_escapes_ok
zyl_cstr_escapes_ok:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L107_0:
    cmp rdi, 0
    jne .L107_1
    mov r9, 0
    mov rax, r9
    mov rsp, rbp
    pop rbp
    ret
.L107_1:
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Descapes_x2Dloop
zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Deq:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L108_0:
    cmp r8, r9
    jl .L108_1
    mov r10, 1
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L108_1:
    mov r10, r8
    imul r10, 8
    add r10, rdi
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, r8
    imul rbx, 8
    add rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp r10, rbx
    jne .L108_2
    mov r10, r8
    add r10, 1
    mov r8, r10
    jmp .L108_0
.L108_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_variant_eq
zyl_variant_eq:
    push rbp
    mov rbp, rsp
.L109_0:
    cmp rdi, rsi
    jne .L109_1
    mov r8, 1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L109_1:
    cmp rdi, 0
    jne .L109_3
    jmp .L109_4
.L109_3:
    cmp rsi, 0
    jne .L109_2
.L109_4:
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L109_2:
    mov r8, rdi
    sub r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, rsi
    sub r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r8, r9
    jne .L109_5
    mov r9, 0
    mov rdx, r9
    mov rcx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Deq
.L109_5:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_variant_cmp
zyl_variant_cmp:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L110_0:
    cmp rdi, rsi
    jne .L110_1
    mov r8, 0
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L110_1:
    cmp rdi, 0
    jne .L110_3
    jmp .L110_4
.L110_3:
    cmp rsi, 0
    jne .L110_2
.L110_4:
    cmp rdi, 0
    jne .L110_5
    mov r8, -1
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L110_5:
    mov r8, 1
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L110_2:
    mov r8, rdi
    sub r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, rsi
    sub r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, 1
    cmp r8, r9
    jge .L110_6
    mov rbx, r8
    jmp .L110_7
.L110_6:
    mov rbx, r9
.L110_7:
    mov rdx, r10
    mov rcx, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Dcmp_x7EInt_x2CInt_x2CInt_x2CInt_x2CInt_x2CInt
.globl zyl_variant_field
zyl_variant_field:
    push rbp
    mov rbp, rsp
.L111_0:
    cmp rdi, 0
    jne .L111_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L111_1:
    mov r8, 8
    add rsi, 1
    imul rsi, r8
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Dcmp_x7EInt_x2CInt_x2CInt_x2CInt_x2CInt_x2CInt:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov r10, r8
    mov r8, rdx
    mov rbx, r9
    mov r9, rcx
.L112_0:
    cmp r8, r9
    jl .L112_1
    cmp r10, rbx
    jge .L112_2
    mov r12, -1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L112_2:
    cmp r10, rbx
    jle .L112_3
    mov r12, 1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L112_3:
    mov r12, 0
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L112_1:
    mov r12, r8
    imul r12, 8
    add r12, rdi
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov r12, rax
    mov r13, r8
    imul r13, 8
    add r13, rsi
    mov rdx, r13
    mov rax, qword ptr [rdx]
    mov r13, rax
    cmp r12, r13
    jge .L112_4
    mov r14, -1
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L112_4:
    cmp r12, r13
    jle .L112_5
    mov r12, 1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L112_5:
    mov r12, r8
    add r12, 1
    mov r8, r12
    jmp .L112_0
.section .rodata
.Lfmtd:
    .string "%lld\n"
.Lfmtf:
    .string "%f\n"
.Lfmts:
    .string "%s\n"
.L10:
    .string "0123456789abcdef"
.L12:
    .string "zyl: "
.L13:
    .string ": invalid string pointer 0x"
.L14:
    .string ""
.L15:
    .string "\n"
.L31:
    .string "cstr-len"
.L33:
    .string "cstr-len"
.L35:
    .string "cstr-eq"
.L36:
    .string "cstr-eq"
.L39:
    .string "cstr-byte-at"
.L41:
    .string "cstr-byte-at"
.L44:
    .string "cstr-concat"
.L45:
    .string "cstr-concat"
.L49:
    .string "cstr-substr"
.L56:
    .string "view"
.L69:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L71:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L72:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L78:
    .string "cstr-sub"
.L85:
    .string "cstr-to-int"
.L89:
    .string "cstr-to-int-base"
.L93:
    .string "cstr-sanitize"
.L99:
    .string "cstr-decode"
.L102:
    .string "cstr-count-newlines"
.L105:
    .string "cstr-last-newline"
.bss
.p2align 6
zyl_rtg_cpu_avx2:
    .zero 8
.p2align 6
zyl_rtg_empty:
    .zero 64
