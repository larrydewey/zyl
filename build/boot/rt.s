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
zy_local_x2Fmain_0__ctab__rt_x2Dlshr:
    push rbp
    mov rbp, rsp
.L112_0:
    mov rax, rdi
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov r8, 1
    mov r9, 64
    mov rax, r9
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    mov rax, r8
    mov rcx, rsi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    sub rsi, 1
    and rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dld32s:
    push rbp
    mov rbp, rsp
.L113_0:
    mov rdx, rdi
    mov eax, dword ptr [rdx]
    mov rsi, rax
    cmp rsi, 2147483647
    jle .L113_1
    mov rdi, 4294967296
    mov rax, rsi
    mov rcx, rdi
    sub rax, rcx
    mov rdi, rax
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L113_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L114_0:
    mov rsi, 30
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Dlshr
    mov rsi, rax
    xor rsi, rbx
    mov rdi, -4658895280553007687
    imul rsi, rdi
    mov rbx, rsi
    mov rsi, 27
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Dlshr
    mov rsi, rax
    xor rsi, rbx
    mov rdi, -7723592293110705685
    imul rsi, rdi
    mov rbx, rsi
    mov rsi, 31
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Dlshr
    mov rsi, rax
    xor rsi, rbx
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dint_x2Dtext_x2Dheap:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L115_0:
    call zyl_int_text
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dgrow:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L116_0:
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r12, rdi
    cmp r12, 0
    jne .L116_1
    jmp .L116_2
.L116_1:
    mov rdi, r12
    imul rdi, 8
    mov rsi, rdi
.L116_2:
    mov r13, rsi
    mov rsi, 16
    mov rdi, r13
    call calloc
    mov rsi, rax
    mov r14, rsi
    cmp r14, 0
    jne .L116_3
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
.L116_3:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r15, rsi
    mov rsi, r13
    sub rsi, 1
    mov rdi, 0
    mov rdx, r14
    mov rcx, rsi
    mov rsi, r12
    mov r8, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Drehash
    mov rsi, rax
    mov rdi, r15
    call free
    mov rsi, rax
    mov rdx, rbx
    mov rcx, r14
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Drehash:
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
.L117_0:
    cmp r15, qword ptr [rbp-56]
    jl .L117_1
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
.L117_1:
    mov rsi, r15
    imul rsi, 16
    add rsi, qword ptr [rbp-48]
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L117_2
    mov rsi, 0
    mov r13, rsi
    jmp .L117_3
.L117_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
    mov rsi, rax
    and rsi, r14
    mov rdi, qword ptr [rbp-64]
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfree_x2Dslot
    mov rsi, rax
    mov rdi, rsi
    imul rdi, 16
    add rdi, qword ptr [rbp-64]
    mov rdx, rdi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    imul rsi, 16
    add rsi, 8
    add rsi, qword ptr [rbp-64]
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov r13, rsi
.L117_3:
    mov rsi, r15
    add rsi, 1
    mov r15, rsi
    jmp .L117_0
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfree_x2Dslot:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L118_0:
    mov r9, r8
    imul r9, 16
    add r9, rdi
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r9, 0
    jne .L118_1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L118_1:
    mov r9, r8
    add r9, 1
    and r9, rsi
    mov r8, r9
    jmp .L118_0
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dslot:
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
    mov rsi, rdx
.L119_0:
    mov rdi, rbx
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    imul rdi, 10
    mov r8, rbx
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    imul r8, 7
    cmp rdi, r8
    jl .L119_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dgrow
    mov rsi, rax
    jmp .L119_2
.L119_1:
    mov rdi, 0
    mov rsi, rdi
.L119_2:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L119_3
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
.L119_3:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov r14, rax
    mov r15, r13
    sub r15, 1
    mov rdi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
    mov rsi, rax
    mov rdi, r13
    sub rdi, 1
    and rsi, rdi
    mov rdi, r14
    mov rdx, r12
    mov rcx, rsi
    mov rsi, r15
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dprobe
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L119_4
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rbx
    add rdi, 16
    mov r8, rbx
    add r8, 16
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    add r8, 1
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L119_4:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dprobe:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L120_0:
    mov r10, r9
    imul r10, 16
    add r10, rdi
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp rbx, 0
    jne .L120_2
    jmp .L120_3
.L120_2:
    cmp rbx, r8
    jne .L120_1
.L120_3:
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L120_1:
    mov r10, r9
    add r10, 1
    and r10, rsi
    mov r9, r10
    jmp .L120_0
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rsi
.L121_0:
    mov rsi, rdi
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    cmp rbx, 0
    jne .L121_2
    jmp .L121_3
.L121_2:
    cmp r12, 0
    jne .L121_1
.L121_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L121_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r13, rax
    mov r14, r12
    sub r14, 1
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
    mov rsi, rax
    mov rdi, r12
    sub rdi, 1
    and rsi, rdi
    mov rdi, r13
    mov rdx, rbx
    mov rcx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dprobe
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L121_4
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L121_4:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dspans:
    push rbp
    mov rbp, rsp
.L122_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_span_set
zyl_span_set:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
    mov r12, rdx
.L123_0:
    cmp rdi, 0
    jne .L123_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L123_1:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov r8, 4096
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dslot
    mov rsi, rax
    cmp rsi, 0
    jne .L123_2
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L123_2:
    mov rdi, rsi
    add rdi, 8
    mov r8, 4294967295
    and r8, rbx
    mov rdx, rdi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    add rsi, 12
    mov rdi, 4294967295
    and rdi, r12
    mov rdx, rsi
    mov rcx, rdi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_span_off
zyl_span_off:
    push rbp
    mov rbp, rsp
.L124_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L124_1
    mov rdi, -1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L124_1:
    add rsi, 8
    mov rdi, rsi
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dld32s
.globl zyl_span_file
zyl_span_file:
    push rbp
    mov rbp, rsp
.L125_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L125_1
    mov rdi, -1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L125_1:
    add rsi, 12
    mov rdi, rsi
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dld32s
.globl zyl_span_copy
zyl_span_copy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
.L126_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L126_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L126_1:
    mov rsi, r12
    add rsi, 8
    mov rdi, rsi
    call zy_local_x2Fmain_0__ctab__rt_x2Dld32s
    mov r13, rax
    mov rsi, r12
    add rsi, 12
    mov rdi, rsi
    call zy_local_x2Fmain_0__ctab__rt_x2Dld32s
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zyl_span_set
zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab:
    push rbp
    mov rbp, rsp
.L127_0:
    lea rax, [rip+zyl_rtg_attrs]
    mov rsi, rax
    imul rdi, 24
    add rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_attr_set
zyl_attr_set:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
    mov r12, rdx
.L128_0:
    cmp rbx, 0
    jne .L128_2
    jmp .L128_3
.L128_2:
    cmp rdi, 0
    jge .L128_4
    jmp .L128_5
.L128_4:
    cmp rdi, 6
    jl .L128_1
.L128_5:
.L128_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L128_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rsi, rax
    mov rdi, 4096
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dslot
    mov rsi, rax
    cmp rsi, 0
    jne .L128_6
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L128_6:
    add rsi, 8
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_attr_get
zyl_attr_get:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rsi
.L129_0:
    cmp rdi, 0
    jge .L129_2
    jmp .L129_3
.L129_2:
    cmp rdi, 6
    jl .L129_1
.L129_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L129_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L129_4
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L129_4:
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_attr_clear
zyl_attr_clear:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L130_0:
    cmp rdi, 0
    jge .L130_2
    jmp .L130_3
.L130_2:
    cmp rdi, 6
    jl .L130_1
.L130_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L130_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rsi, rax
    mov rbx, rsi
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L130_4
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L130_4:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    imul rdi, 16
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dzero:
    push rbp
    mov rbp, rsp
.L131_0:
    cmp rsi, 0
    jg .L131_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L131_1:
    mov r8, 0
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    mov r8, rdi
    add r8, 8
    mov r9, rsi
    sub r9, 8
    mov rdi, r8
    mov rsi, r9
    jmp .L131_0
.globl zyl_attr_copy
zyl_attr_copy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L132_0:
    mov rdi, rbx
    call zyl_attr_get
    mov rsi, rax
    cmp rsi, 0
    jne .L132_1
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L132_1:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_attr_set
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L133_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov r8, -3750763034362895579
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L134_0:
    mov r10, r8
    add r10, 8
    cmp r10, rsi
    jg .L134_1
    mov r10, r8
    add r10, 8
    mov rbx, rdi
    add rbx, r8
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    xor rbx, r9
    mov r12, -7046029254386353131
    imul rbx, r12
    mov r8, r10
    mov r9, rbx
    jmp .L134_0
.L134_1:
    cmp r8, rsi
    jge .L134_2
    mov r10, r8
    add r10, 1
    mov rbx, rdi
    add rbx, r8
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rbx, rax
    xor rbx, r9
    mov r12, 1099511628211
    imul rbx, r12
    mov r8, r10
    mov r9, rbx
    jmp .L134_0
.L134_2:
    xor rsi, r9
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
.globl zyl_smap_new
zyl_smap_new:
    push rbp
    mov rbp, rsp
.L135_0:
    mov rsi, 1
    mov rdi, 24
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp calloc
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dgrow:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L136_0:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L136_1
    mov rsi, 1024
    jmp .L136_2
.L136_1:
    mov rdi, r12
    imul rdi, 4
    mov rsi, rdi
.L136_2:
    mov r13, rsi
    mov rsi, 24
    mov rdi, r13
    call calloc
    mov rsi, rax
    mov r14, rsi
    cmp r14, 0
    jne .L136_3
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
.L136_3:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r15, rsi
    mov rsi, r13
    sub rsi, 1
    mov rdi, 0
    mov rdx, r14
    mov rcx, rsi
    mov rsi, r12
    mov r8, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Drehash
    mov rsi, rax
    mov rdi, r15
    call free
    mov rsi, rax
    mov rdx, rbx
    mov rcx, r14
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Drehash:
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
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L137_0:
    cmp r15, qword ptr [rbp-56]
    jl .L137_1
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
.L137_1:
    mov rsi, r15
    imul rsi, 24
    add rsi, qword ptr [rbp-48]
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L137_2
    mov rsi, 0
    mov r12, rsi
    jmp .L137_3
.L137_2:
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    and rsi, r14
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dempty
    mov rsi, rax
    imul rsi, 24
    add rsi, r13
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 8
    mov r8, rbx
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    add rsi, 16
    mov rdi, rbx
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov r12, rsi
.L137_3:
    mov rsi, r15
    add rsi, 1
    mov r15, rsi
    jmp .L137_0
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dempty:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L138_0:
    mov r9, r8
    imul r9, 24
    add r9, rdi
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r9, 0
    jne .L138_1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L138_1:
    mov r9, r8
    add r9, 1
    and r9, rsi
    mov r8, r9
    jmp .L138_0
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dprobe:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov qword ptr [rbp-48], rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L139_0:
    mov rsi, r15
    imul rsi, 24
    add rsi, qword ptr [rbp-48]
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L139_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L139_1:
    mov rdi, rbx
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, r14
    jne .L139_2
    mov rdi, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    mov rsi, rax
    cmp rsi, 0
    jne .L139_2
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L139_2:
    mov rsi, r15
    add rsi, 1
    and rsi, r12
    mov r15, rsi
    jmp .L139_0
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
.L140_0:
    cmp rbx, 0
    jne .L140_2
    jmp .L140_3
.L140_2:
    cmp r12, 0
    jne .L140_4
    jmp .L140_5
.L140_4:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L140_1
.L140_5:
.L140_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L140_1:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    sub rsi, 1
    mov r13, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov r8, -3750763034362895579
    mov rdx, rdi
    mov rdi, r12
    mov rcx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
    mov rsi, rax
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, rsi
    and r8, r13
    mov rdx, r12
    mov rcx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dprobe
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L140_6
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L140_6:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_smap_put
zyl_smap_put:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov qword ptr [rbp-48], rdx
.L141_0:
    mov r14, r12
    cmp rbx, 0
    jne .L141_2
    jmp .L141_3
.L141_2:
    cmp r14, 0
    jne .L141_1
.L141_3:
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
.L141_1:
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    imul rsi, 10
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    imul rdi, 7
    cmp rsi, rdi
    jl .L141_4
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dgrow
    mov rsi, rax
    jmp .L141_5
.L141_4:
    mov rdi, 0
    mov rsi, rdi
.L141_5:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jne .L141_6
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
.L141_6:
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov r8, -3750763034362895579
    mov rdx, rdi
    mov rdi, r14
    mov rcx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
    mov rsi, rax
    mov r13, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r15
    sub rdi, 1
    mov r8, r15
    sub r8, 1
    and r8, r13
    mov rdx, r14
    mov rcx, r13
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dprobe
    mov rsi, rax
    mov r14, rsi
    mov rdx, r14
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L141_7
    mov rdi, r12
    call strdup
    mov rsi, rax
    cmp rsi, 0
    jne .L141_8
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L141_8:
    mov rdx, r14
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r14
    add rsi, 16
    mov rdx, rsi
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdi, rbx
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r14
    add rsi, 8
    mov rdx, rsi
    mov rcx, qword ptr [rbp-48]
    mov qword ptr [rdx], rcx
    mov rax, rcx
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
.L141_7:
    mov rsi, r14
    add rsi, 8
    mov rdx, rsi
    mov rcx, qword ptr [rbp-48]
    mov qword ptr [rdx], rcx
    mov rax, rcx
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
.globl zyl_smap_get
zyl_smap_get:
    push rbp
    mov rbp, rsp
.L142_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L142_1
    mov rdi, 0
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L142_1:
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_smap_has
zyl_smap_has:
    push rbp
    mov rbp, rsp
.L143_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L143_1
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L143_1:
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_smap_get_or
zyl_smap_get_or:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdx
.L144_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L144_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L144_1:
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dfree_x2Dkeys:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L145_0:
    cmp r12, r13
    jl .L145_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L145_1:
    mov rsi, r12
    imul rsi, 24
    add rsi, rbx
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call free
    mov rsi, rax
    mov rsi, r12
    add rsi, 1
    mov r12, rsi
    jmp .L145_0
.globl zyl_smap_clear
zyl_smap_clear:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L146_0:
    cmp rbx, 0
    jne .L146_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L146_1:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, 0
    mov rdx, r12
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Dfree_x2Dkeys
    mov rsi, rax
    cmp r12, 0
    jle .L146_2
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    imul rdi, 24
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    mov rsi, rax
    jmp .L146_3
.L146_2:
    mov rdi, 0
    mov rsi, rdi
.L146_3:
    mov rsi, rbx
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_wvec_new
zyl_wvec_new:
    push rbp
    mov rbp, rsp
.L147_0:
    mov rsi, 1
    mov rdi, 24
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp calloc
.globl zyl_wvec_push
zyl_wvec_push:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L148_0:
    cmp rbx, 0
    jne .L148_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L148_1:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp r13, rsi
    jl .L148_2
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L148_4
    mov rsi, 4096
    jmp .L148_5
.L148_4:
    mov rdi, rbx
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    imul rdi, 2
    mov rsi, rdi
.L148_5:
    mov r14, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r14
    imul rdi, 8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call realloc
    mov rsi, rax
    cmp rsi, 0
    jne .L148_6
    mov rdi, 0
    jmp .L148_7
.L148_6:
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rcx, r14
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 1
    mov rdi, rsi
.L148_7:
    jmp .L148_3
.L148_2:
    mov rsi, 1
    mov rdi, rsi
.L148_3:
    cmp rdi, 0
    je .L148_8
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r13
    imul rdi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdi, r13
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L148_8:
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_wvec_get
zyl_wvec_get:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov qword ptr [rbp-48], rsi
.L149_0:
    cmp rbx, 0
    jne .L149_1
    mov rsi, 0
    jmp .L149_2
.L149_1:
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rsi, rdi
.L149_2:
    mov r13, rsi
    cmp rbx, 0
    jne .L149_4
    jmp .L149_5
.L149_4:
    cmp qword ptr [rbp-48], 0
    jge .L149_6
    jmp .L149_7
.L149_6:
    cmp qword ptr [rbp-48], r13
    jl .L149_3
.L149_7:
.L149_5:
    lea rax, [rip+.L150]
    mov r14, rax
    mov rdi, qword ptr [rbp-48]
    call zyl_int_text
    mov r15, rax
    lea rax, [rip+.L151]
    mov r12, rax
    mov rdi, r13
    call zyl_int_text
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r15
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r14
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.L149_3:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    imul rdi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_wvec_set
zyl_wvec_set:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L152_0:
    cmp rdi, 0
    jne .L152_2
    jmp .L152_3
.L152_2:
    cmp rsi, 0
    jge .L152_4
    jmp .L152_5
.L152_4:
    mov r9, rdi
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp rsi, r9
    jl .L152_1
.L152_5:
.L152_3:
    mov r9, 0
    mov rax, r9
    mov rsp, rbp
    pop rbp
    ret
.L152_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    imul rsi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_wvec_len
zyl_wvec_len:
    push rbp
    mov rbp, rsp
.L153_0:
    cmp rdi, 0
    jne .L153_1
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L153_1:
    mov rsi, rdi
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_wvec_pop
zyl_wvec_pop:
    push rbp
    mov rbp, rsp
.L154_0:
    cmp rdi, 0
    jne .L154_2
    jmp .L154_3
.L154_2:
    mov rsi, rdi
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jg .L154_1
.L154_3:
    lea rax, [rip+.L155]
    mov rsi, rax
    mov rdi, rsi
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.L154_1:
    mov rsi, rdi
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    sub rsi, 1
    mov r8, rdi
    add r8, 8
    mov rdx, r8
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    imul rsi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_wvec_truncate
zyl_wvec_truncate:
    push rbp
    mov rbp, rsp
.L156_0:
    cmp rdi, 0
    jle .L156_1
    cmp rsi, 0
    jl .L156_1
    mov r8, rdi
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp rsi, r8
    jge .L156_1
    add rdi, 8
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L156_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dglobal_x2Dhandle:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov r8, rdx
.L157_0:
    cmp rsi, 0
    jge .L157_2
    jmp .L157_3
.L157_2:
    cmp rsi, 8
    jl .L157_1
.L157_3:
    mov r9, 0
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L157_1:
    imul rsi, 8
    add rsi, rdi
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L157_4
    cmp r8, 0
    je .L157_5
    mov rsi, 1
    mov rdi, 24
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call calloc
    mov rsi, rax
    mov r12, rsi
    jmp .L157_6
.L157_5:
    mov rsi, 1
    mov rdi, 24
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call calloc
    mov rsi, rax
    mov r12, rsi
.L157_6:
    mov rdx, rbx
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L157_4:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_wvec_global
zyl_wvec_global:
    push rbp
    mov rbp, rsp
.L158_0:
    lea rax, [rip+zyl_rtg_gwvecs]
    mov rsi, rax
    mov r8, 1
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dglobal_x2Dhandle
.globl zyl_smap_global
zyl_smap_global:
    push rbp
    mov rbp, rsp
.L159_0:
    lea rax, [rip+zyl_rtg_gsmaps]
    mov rsi, rax
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dglobal_x2Dhandle
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcached:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L160_0:
    mov rsi, rbx
    add rsi, 8
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jle .L160_1
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L160_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L160_2
    mov rdi, 0
    mov r13, rdi
    jmp .L160_3
.L160_2:
    mov rdi, rsi
    mov rsi, r12
    call zyl_smap_get
    mov rsi, rax
    mov r13, rsi
.L160_3:
    cmp r13, 0
    jne .L160_4
    mov rsi, 0
    mov r14, rsi
    jmp .L160_5
.L160_4:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dcache_x2Dcell
    mov rsi, rax
    mov r14, rsi
.L160_5:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcache_x2Dcell:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdx
.L161_0:
    add rdi, 8
    mov r8, 1024
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dslot
    mov rsi, rax
    cmp rsi, 0
    jne .L161_1
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L161_1:
    add rsi, 8
    mov rdx, rsi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L162_0:
    cmp r8, 0
    je .L162_1
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcached
.L162_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L162_2
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L162_2:
    mov rsp, rbp
    pop rbp
    jmp zyl_smap_get
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dget:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L163_0:
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell
    mov rsi, rax
    cmp rsi, 0
    jne .L163_1
    mov rdi, 0
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L163_1:
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dready:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L164_0:
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell
    mov rsi, rax
    cmp rsi, 0
    jne .L164_1
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L164_1:
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dput:
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
    mov r14, rcx
.L165_0:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L165_1
    mov rsi, 1
    mov rdi, 24
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call calloc
    mov rsi, rax
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    jmp .L165_2
.L165_1:
    mov rdi, 0
    mov rsi, rdi
.L165_2:
    mov rsi, 8
    mov rdi, rsi
    call malloc
    mov rsi, rax
    cmp rsi, 0
    jne .L165_3
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L165_3:
    mov rdx, rsi
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    mov rsi, r12
    call zyl_smap_put
    mov rsi, rax
    cmp r14, 0
    je .L165_4
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, r12
    call zyl_smap_get
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Dcache_x2Dcell
    mov rsi, rax
    jmp .L165_5
.L165_4:
    mov rdi, 0
    mov rsi, rdi
.L165_5:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L166_0:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L166_1
    mov rsi, 0
    mov r12, rsi
    jmp .L166_2
.L166_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zyl_smap_clear
    mov rsi, rax
    mov r12, rsi
.L166_2:
    mov rsi, rbx
    add rsi, 8
    mov rbx, rsi
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L166_3
    mov rsi, 0
    mov r12, rsi
    jmp .L166_4
.L166_3:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    imul rdi, 16
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    mov rsi, rax
    mov r12, rsi
.L166_4:
    mov rsi, rbx
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Ddefs:
    push rbp
    mov rbp, rsp
.L167_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Didefs:
    push rbp
    mov rbp, rsp
.L168_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Drepl_x2Ddefs:
    push rbp
    mov rbp, rsp
.L169_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_global_clear
zyl_global_clear:
    push rbp
    mov rbp, rsp
.L170_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rsi, rax
    mov rdi, rsi
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear
.globl zyl_global_ready
zyl_global_ready:
    push rbp
    mov rbp, rsp
.L171_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rsi, rax
    mov r8, 1
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dready
.globl zyl_global_get
zyl_global_get:
    push rbp
    mov rbp, rsp
.L172_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rsi, rax
    mov r8, 1
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dget
.globl zyl_global_put
zyl_global_put:
    push rbp
    mov rbp, rsp
.L173_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov r8, rax
    mov r9, 1
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dput
.globl zyl_iglobal_clear
zyl_iglobal_clear:
    push rbp
    mov rbp, rsp
.L174_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rsi, rax
    mov rdi, rsi
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear
.globl zyl_iglobal_ready
zyl_iglobal_ready:
    push rbp
    mov rbp, rsp
.L175_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rsi, rax
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dready
.globl zyl_iglobal_get
zyl_iglobal_get:
    push rbp
    mov rbp, rsp
.L176_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rsi, rax
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dget
.globl zyl_iglobal_put
zyl_iglobal_put:
    push rbp
    mov rbp, rsp
.L177_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov r8, rax
    mov r9, 0
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dput
.globl zyl_repl_global_set
zyl_repl_global_set:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L178_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov rsi, rax
    mov r13, rsi
    mov rdx, r13
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L178_1
    mov rsi, 1
    mov rdi, 24
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call calloc
    mov rsi, rax
    mov rdx, r13
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    jmp .L178_2
.L178_1:
    mov rdi, 0
    mov rsi, rdi
.L178_2:
    mov rdx, r13
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    mov rdx, r12
    call zyl_smap_put
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_repl_global_get
zyl_repl_global_get:
    push rbp
    mov rbp, rsp
.L179_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L179_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L179_1:
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zyl_smap_get
.globl zyl_contract_warn
zyl_contract_warn:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L180_0:
    cmp rdi, 0
    jne .L180_1
    lea rax, [rip+.L181]
    mov rsi, rax
    jmp .L180_2
.L180_1:
    mov rsi, rdi
.L180_2:
    lea rax, [rip+.L182]
    mov rbx, rax
    lea rax, [rip+.L183]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
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
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_err_is
zyl_err_is:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
.L184_0:
    mov rbx, rdi
    mov r12, rsi
    cmp rbx, 0
    jne .L184_2
    jmp .L184_3
.L184_2:
    cmp r12, 0
    jne .L184_1
.L184_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L184_1:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r13, rsi
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dprefix_x2Deq
    mov rsi, rax
    cmp rsi, 0
    je .L184_4
    mov rsi, rbx
    add rsi, r13
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 58
    jne .L184_5
    mov rdi, 1
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L184_5:
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L184_4:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dprefix_x2Deq:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L185_0:
    cmp r8, 0
    jne .L185_1
    mov r9, 1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L185_1:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jne .L185_2
    mov r9, rdi
    add r9, 1
    mov r10, rsi
    add r10, 1
    mov rbx, r8
    sub rbx, 1
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L185_0
.L185_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrcs:
    push rbp
    mov rbp, rsp
.L186_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dcount:
    push rbp
    mov rbp, rsp
.L187_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    add rsi, 6144
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc:
    push rbp
    mov rbp, rsp
.L188_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    imul rdi, 24
    add rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dfind:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L189_0:
    cmp r12, r13
    jl .L189_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L189_1:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rdi, r12
    imul rdi, 24
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    mov rsi, rax
    cmp rsi, 0
    jne .L189_2
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L189_2:
    mov rsi, r12
    add rsi, 1
    mov r12, rsi
    jmp .L189_0
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dset_x2Dtext:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L190_0:
    mov rdi, rsi
    call strdup
    mov rsi, rax
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    add rbx, 16
    cmp rsi, 0
    jne .L190_1
    mov rdi, 0
    mov r12, rdi
    jmp .L190_2
.L190_1:
    mov rdi, rsi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r12, rsi
.L190_2:
    mov rdx, rbx
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_source_register
zyl_source_register:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
.L191_0:
    cmp rdi, 0
    jne .L191_1
    lea rax, [rip+.L192]
    mov r8, rax
    jmp .L191_2
.L191_1:
    mov r8, rdi
.L191_2:
    mov rbx, r8
    cmp rsi, 0
    jne .L191_3
    lea rax, [rip+.L193]
    mov rdi, rax
    jmp .L191_4
.L191_3:
    mov rdi, rsi
.L191_4:
    mov r12, rdi
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    add rsi, 6144
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov qword ptr [rbp-48], rsi
    mov rsi, 0
    mov rdi, rbx
    mov rdx, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dfind
    mov rsi, rax
    mov r14, rsi
    cmp r14, 0
    jl .L191_5
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rdi, r14
    imul rdi, 24
    add rsi, rdi
    mov r15, rsi
    mov rsi, r15
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L191_6
    lea rax, [rip+.L194]
    mov rsi, rax
    jmp .L191_7
.L191_6:
    mov rdi, r15
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rsi, rdi
.L191_7:
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    mov rsi, rax
    cmp rsi, 0
    jne .L191_8
    mov rsi, 0
    mov r13, rsi
    jmp .L191_9
.L191_8:
    mov rsi, r15
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call free
    mov rsi, rax
    mov rdi, r15
    mov rsi, r12
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dset_x2Dtext
    mov rsi, rax
    mov r13, rsi
.L191_9:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L191_5:
    cmp qword ptr [rbp-48], 256
    jl .L191_10
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
.L191_10:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    imul rdi, 24
    add rsi, rdi
    mov r13, rsi
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    add rsi, 6144
    mov rdi, qword ptr [rbp-48]
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rdi, rbx
    call strdup
    mov rsi, rax
    mov rdx, r13
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rdi, r13
    mov rsi, r12
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dset_x2Dtext
    mov rsi, rax
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok:
    push rbp
    mov rbp, rsp
.L195_0:
    cmp rdi, 0
    jge .L195_2
    jmp .L195_3
.L195_2:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    add rsi, 6144
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rdi, rsi
    jl .L195_1
.L195_3:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L195_1:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    imul rdi, 24
    add rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_source_path
zyl_source_path:
    push rbp
    mov rbp, rsp
.L196_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    jne .L196_1
    lea rax, [rip+.L197]
    mov rdi, rax
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L196_1:
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rsi
.L198_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    jne .L198_2
    jmp .L198_3
.L198_2:
    cmp rbx, 0
    jge .L198_1
.L198_3:
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L198_1:
    mov rdi, rsi
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L198_5
    jmp .L198_6
.L198_5:
    mov rdi, rsi
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rbx, rdi
    jle .L198_4
.L198_6:
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L198_4:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dcount_x2Dlines:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L199_0:
    cmp rsi, r8
    jl .L199_1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L199_1:
    mov r10, rsi
    add r10, 1
    mov rbx, rdi
    add rbx, rsi
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rbx, rax
    cmp rbx, 10
    jne .L199_2
    mov rbx, r9
    add rbx, 1
    jmp .L199_3
.L199_2:
    mov rbx, r9
.L199_3:
    mov rsi, r10
    mov r9, rbx
    jmp .L199_0
.globl zyl_span_line
zyl_span_line:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rsi
.L200_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov rsi, rax
    cmp rsi, 0
    jne .L200_1
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L200_1:
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, 0
    mov r8, 1
    mov rdx, rbx
    mov rcx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__source__rt_x2Dcount_x2Dlines
zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart:
    push rbp
    mov rbp, rsp
.L201_0:
    cmp rsi, 0
    jle .L201_1
    mov r8, rsi
    sub r8, 1
    add r8, rdi
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 10
    jne .L201_2
    mov r8, 0
    jmp .L201_3
.L201_2:
    mov r9, 1
    mov r8, r9
.L201_3:
    cmp r8, 0
    je .L201_1
    mov r8, rsi
    sub r8, 1
    mov rsi, r8
    jmp .L201_0
.L201_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dline_x2Dend:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L202_0:
    cmp rsi, r8
    jge .L202_1
    mov r9, rdi
    add r9, rsi
    mov rdx, r9
    movzx eax, byte ptr [rdx]
    mov r9, rax
    cmp r9, 10
    jne .L202_2
    mov r9, 0
    jmp .L202_3
.L202_2:
    mov r10, 1
    mov r9, r10
.L202_3:
    cmp r9, 0
    je .L202_1
    mov r9, rsi
    add r9, 1
    mov rsi, r9
    jmp .L202_0
.L202_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_span_col
zyl_span_col:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rsi
.L203_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov rsi, rax
    cmp rsi, 0
    jne .L203_1
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L203_1:
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart
    mov rsi, rax
    mov rax, rbx
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    add rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dmcopy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L204_0:
    mov rsi, r12
    add rsi, 7
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jne .L204_1
    lea rax, [rip+.L205]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L204_1:
    cmp r13, 0
    je .L204_2
    lea rax, [rip+.L206]
    mov rsi, rax
    mov rdi, 3
    mov rdx, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, 3
    jmp .L204_3
.L204_2:
    mov rdi, 0
    mov rsi, rdi
.L204_3:
    mov r13, rsi
    mov rsi, r15
    add rsi, r13
    mov rdi, rsi
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, r13
    add rsi, r12
    mov rbx, rsi
    cmp r14, 0
    je .L204_4
    mov rsi, r15
    add rsi, rbx
    lea rax, [rip+.L207]
    mov rdi, rax
    mov r8, 3
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, 3
    jmp .L204_5
.L204_4:
    mov rsi, rbx
.L204_5:
    add rsi, r15
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_span_line_text
zyl_span_line_text:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, rsi
.L208_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L208_1
    lea rax, [rip+.L209]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L208_1:
    mov rsi, r12
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    mov rdi, r13
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart
    mov rsi, rax
    mov r14, rsi
    mov r15, r13
    add r15, r14
    mov rsi, r12
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dend
    mov rsi, rax
    sub rsi, r14
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, r15
    mov rcx, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__source__rt_x2Dmcopy
zy_local_x2Fmain_0__source__rt_x2Dsnip:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rsi
.L210_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L210_1
    push rsi
    push rdi
    push r8
    push r9
    push r10
    sub rsp, 8
    mov rdi, 8
    nop
    call zyl_heap_alloc
    add rsp, 8
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
.L210_m4d:
    mov rsi, rax
    mov qword ptr [rsi+0], 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L210_1:
    mov rsi, r12
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    mov rdi, r13
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart
    mov rsi, rax
    mov r14, rsi
    mov rsi, r12
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dend
    mov rsi, rax
    mov rdi, rsi
    sub rdi, r14
    cmp rdi, 120
    jg .L210_2
    mov rdi, 0
    mov r8, 0
    push rsi
    push rdi
    push r8
    push r9
    push r10
    sub rsp, 8
    mov rdi, 40
    nop
    call zyl_heap_alloc
    add rsp, 8
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
.L210_m21d:
    mov r9, rax
    mov qword ptr [r9+0], 0
    mov qword ptr [r9+8], r14
    mov qword ptr [r9+16], rsi
    mov qword ptr [r9+24], rdi
    mov qword ptr [r9+32], r8
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L210_2:
    mov rdi, rbx
    sub rdi, 60
    cmp rdi, r14
    jge .L210_3
    mov rdi, r14
    jmp .L210_4
.L210_3:
    mov r8, rbx
    sub r8, 60
    mov rdi, r8
.L210_4:
    mov r8, rdi
    add r8, 120
    cmp r8, rsi
    jle .L210_5
    mov r8, rsi
    sub r8, 120
    jmp .L210_6
.L210_5:
    mov r8, rdi
.L210_6:
    mov r9, rdi
    add r9, 120
    cmp r9, rsi
    jle .L210_7
    mov r9, rsi
    jmp .L210_8
.L210_7:
    add rdi, 120
    mov r9, rdi
.L210_8:
    mov rax, r8
    mov rcx, r14
    cmp rax, rcx
    setg al
    movzx rax, al
    mov rdi, rax
    mov rax, r9
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    mov rsi, rax
    push rsi
    push rdi
    push r8
    push r9
    push r10
    sub rsp, 8
    mov rdi, 40
    nop
    call zyl_heap_alloc
    add rsp, 8
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
.L210_m58d:
    mov r10, rax
    mov qword ptr [r10+0], 0
    mov qword ptr [r10+8], r8
    mov qword ptr [r10+16], r9
    mov qword ptr [r10+24], rdi
    mov qword ptr [r10+32], rsi
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_span_snippet
zyl_span_snippet:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L211_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsnip
    mov rsi, rax
    mov rdi, [rsi+0]
    cmp rdi, 0
    jne .L211_1
    mov rdi, [rsi+8]
    mov r8, [rsi+16]
    mov r9, [rsi+24]
    mov r10, [rsi+32]
    lea rax, [rip+zyl_rtg_src_files]
    mov r12, rax
    imul rbx, 24
    add rbx, r12
    add rbx, 8
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    add rbx, rdi
    mov rax, r8
    mov rcx, rdi
    sub rax, rcx
    mov rdi, rax
    mov rsi, rdi
    mov rdi, rbx
    mov rdx, r9
    mov rcx, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__source__rt_x2Dmcopy
.L211_1:
    mov rsi, [rsi+0]
    cmp rsi, 1
    jne .L211_2
    lea rax, [rip+.L212]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L211_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_span_snippet_col
zyl_span_snippet_col:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rsi
.L213_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsnip
    mov rsi, rax
    mov rdi, [rsi+0]
    cmp rdi, 0
    jne .L213_1
    mov rdi, [rsi+8]
    mov r8, [rsi+24]
    mov rax, rbx
    mov rcx, rdi
    sub rax, rcx
    mov rdi, rax
    add rdi, 1
    cmp r8, 0
    je .L213_2
    mov r8, 3
    jmp .L213_3
.L213_2:
    mov r9, 0
    mov r8, r9
.L213_3:
    add rdi, r8
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L213_1:
    mov rsi, [rsi+0]
    cmp rsi, 1
    jne .L213_4
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L213_4:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dskip_x2Dlines:
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
    mov r15, r8
.L214_0:
    cmp r13, r14
    jl .L214_1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L214_1:
    mov rsi, 10
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r15
    mov rcx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dfind_x2Dbyte
    mov rsi, rax
    cmp rsi, 0
    jge .L214_2
    mov rdi, -1
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L214_2:
    add rsi, 1
    mov rdi, r13
    add rdi, 1
    mov r12, rsi
    mov r13, rdi
    jmp .L214_0
.globl zyl_span_offset_at
zyl_span_offset_at:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rsi
    mov r12, rdx
.L215_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    jne .L215_2
    jmp .L215_3
.L215_2:
    cmp rbx, 1
    jge .L215_4
    jmp .L215_5
.L215_4:
    cmp r12, 1
    jge .L215_1
.L215_5:
.L215_3:
    mov rdi, -1
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L215_1:
    mov rdi, rsi
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L215_6
    mov r8, -1
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L215_6:
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    mov rsi, 0
    mov r8, 1
    mov rdx, r8
    mov rcx, rbx
    mov r8, r13
    call zy_local_x2Fmain_0__source__rt_x2Dskip_x2Dlines
    mov rsi, rax
    cmp rsi, 0
    jge .L215_7
    mov rdi, -1
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L215_7:
    mov rdi, r12
    sub rdi, 1
    add rsi, rdi
    cmp rsi, r13
    jg .L215_8
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L215_8:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Ditests:
    push rbp
    mov rbp, rsp
.L216_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Ditest_x2Dn:
    push rbp
    mov rbp, rsp
.L217_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    add rsi, 65536
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_itest_add
zyl_itest_add:
    push rbp
    mov rbp, rsp
.L218_0:
    lea rax, [rip+zyl_rtg_itests]
    mov r8, rax
    add r8, 65536
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp r8, 4096
    jl .L218_1
    mov r9, -1
    mov rax, r9
    mov rsp, rbp
    pop rbp
    ret
.L218_1:
    lea rax, [rip+zyl_rtg_itests]
    mov r9, rax
    mov r10, r8
    imul r10, 16
    add r9, r10
    mov rdx, r9
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, r9
    add rdi, 8
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    add rsi, 65536
    mov rdi, r8
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_itest_count
zyl_itest_count:
    push rbp
    mov rbp, rsp
.L219_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    add rsi, 65536
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_itest_name
zyl_itest_name:
    push rbp
    mov rbp, rsp
.L220_0:
    cmp rdi, 0
    jge .L220_2
    jmp .L220_3
.L220_2:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    add rsi, 65536
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rdi, rsi
    jl .L220_1
.L220_3:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L220_1:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    imul rdi, 16
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_itest_fn
zyl_itest_fn:
    push rbp
    mov rbp, rsp
.L221_0:
    cmp rdi, 0
    jge .L221_2
    jmp .L221_3
.L221_2:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    add rsi, 65536
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rdi, rsi
    jl .L221_1
.L221_3:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L221_1:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    imul rdi, 16
    add rsi, rdi
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_itest_reset
zyl_itest_reset:
    push rbp
    mov rbp, rsp
.L222_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    add rsi, 65536
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap:
    push rbp
    mov rbp, rsp
.L223_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap_x2Dused:
    push rbp
    mov rbp, rsp
.L224_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    add rsi, 262144
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_fnmap_reset
zyl_fnmap_reset:
    push rbp
    mov rbp, rsp
.L225_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rdi, 262152
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap_x2Dprobe:
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
.L226_0:
    cmp r14, 16384
    jl .L226_1
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
.L226_1:
    mov rsi, r13
    add rsi, r14
    and rsi, 16383
    imul rsi, 16
    add rsi, rbx
    mov r15, rsi
    mov rdx, r15
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L226_3
    jmp .L226_4
.L226_3:
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    mov rsi, rax
    cmp rsi, 0
    jne .L226_2
.L226_4:
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L226_2:
    mov rsi, r14
    add rsi, 1
    mov r14, rsi
    jmp .L226_0
.globl zyl_fnmap_put
zyl_fnmap_put:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rsi
.L227_0:
    mov r12, rdi
    cmp r12, 0
    jne .L227_2
    jmp .L227_3
.L227_2:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    add rsi, 262144
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 8192
    jl .L227_1
.L227_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L227_1:
    lea rax, [rip+zyl_rtg_fnmap]
    mov r13, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov r8, -3750763034362895579
    mov rdx, rdi
    mov rdi, r12
    mov rcx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
    mov rsi, rax
    and rsi, 16383
    mov rdi, 0
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rdi
    mov rdi, r13
    call zy_local_x2Fmain_0__interp__rt_x2Dfnmap_x2Dprobe
    mov rsi, rax
    cmp rsi, 0
    jne .L227_5
    jmp .L227_6
.L227_5:
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L227_7
    mov rdi, 0
    jmp .L227_8
.L227_7:
    mov r8, 1
    mov rdi, r8
.L227_8:
    cmp rdi, 0
    je .L227_4
.L227_6:
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L227_4:
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    add rsi, 8
    mov rdx, rsi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    add rsi, 262144
    lea rax, [rip+zyl_rtg_fnmap]
    mov rdi, rax
    add rdi, 262144
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_fnmap_get
zyl_fnmap_get:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L228_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L228_2
    jmp .L228_3
.L228_2:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    add rsi, 262144
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L228_1
.L228_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L228_1:
    lea rax, [rip+zyl_rtg_fnmap]
    mov r12, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov r8, -3750763034362895579
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
    mov rsi, rax
    and rsi, 16383
    mov rdi, 0
    mov rdx, rsi
    mov rsi, rbx
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__interp__rt_x2Dfnmap_x2Dprobe
    mov rsi, rax
    cmp rsi, 0
    jne .L228_5
    jmp .L228_6
.L228_5:
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L228_4
.L228_6:
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L228_4:
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dmagic:
    push rbp
    mov rbp, rsp
.L229_0:
    mov rsi, 1514885700
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_val_alloc
zyl_val_alloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rsi
    mov r12, rdx
.L230_0:
    cmp rdi, 0
    jge .L230_1
    mov rsi, 0
    jmp .L230_2
.L230_1:
    mov rsi, rdi
.L230_2:
    mov r13, rsi
    cmp r13, 1048576
    jle .L230_3
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L230_3:
    mov rsi, r13
    add rsi, 3
    imul rsi, 8
    mov rdi, rsi
    call zyl_heap_alloc
    mov rsi, rax
    cmp rsi, 0
    jne .L230_4
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L230_4:
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 8
    mov r8, 1514885700
    mov r9, 32
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    mov r9, 4294967295
    and r9, rbx
    or r8, r9
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 16
    mov rdx, rdi
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    add rsi, 24
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dword:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L231_0:
    cmp rbx, 0
    jne .L231_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L231_1:
    mov rsi, rbx
    sub rsi, 16
    mov rdi, rsi
    call zyl_heap_block_p
    mov rsi, rax
    cmp rsi, 0
    je .L231_2
    mov rsi, rbx
    sub rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, 32
    mov rax, rsi
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    cmp rdi, 1514885700
    jne .L231_3
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L231_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L231_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_val_kind
zyl_val_kind:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rsi
.L232_0:
    cmp rbx, 0
    jge .L232_2
    jmp .L232_3
.L232_2:
    cmp rbx, 31
    jl .L232_1
.L232_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L232_1:
    call zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dword
    mov rsi, rax
    cmp rsi, 0
    jne .L232_4
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L232_4:
    mov rdi, 2
    imul rdi, rbx
    mov rax, rsi
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    and rsi, 3
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_val_name
zyl_val_name:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L233_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dword
    mov rsi, rax
    cmp rsi, 0
    jne .L233_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L233_1:
    mov rsi, rbx
    sub rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_val_arity
zyl_val_arity:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L234_0:
    cmp rbx, 0
    jne .L234_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L234_1:
    mov rsi, rbx
    sub rsi, 8
    mov rdi, rsi
    call zyl_heap_block_p
    mov rsi, rax
    cmp rsi, 0
    je .L234_2
    mov rsi, rbx
    sub rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L234_2:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dnames:
    push rbp
    mov rbp, rsp
.L235_0:
    lea rax, [rip+zyl_rtg_names]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dnames_x2Dprobe:
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
.L236_0:
    cmp r14, 4096
    jl .L236_1
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
.L236_1:
    mov rsi, r13
    add rsi, r14
    and rsi, 4095
    imul rsi, 8
    add rsi, rbx
    mov r15, rsi
    mov rdx, r15
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L236_3
    jmp .L236_4
.L236_3:
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    mov rsi, rax
    cmp rsi, 0
    jne .L236_2
.L236_4:
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L236_2:
    mov rsi, r14
    add rsi, 1
    mov r14, rsi
    jmp .L236_0
.globl zyl_intern_name
zyl_intern_name:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
.L237_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L237_1
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
.L237_1:
    lea rax, [rip+zyl_rtg_names]
    mov rsi, rax
    mov r12, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov r8, -3750763034362895579
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
    mov rsi, rax
    and rsi, 4095
    mov rdi, 0
    mov rdx, rsi
    mov rsi, rbx
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__interp__rt_x2Dnames_x2Dprobe
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L237_2
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
.L237_2:
    mov rdx, r13
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L237_4
    mov rsi, 0
    jmp .L237_5
.L237_4:
    mov rdi, 1
    mov rsi, rdi
.L237_5:
    cmp rsi, 0
    je .L237_3
    mov rdx, r13
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L237_3:
    mov rsi, r12
    add rsi, 32768
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 2048
    jl .L237_6
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
.L237_6:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r14, rsi
    mov rsi, r14
    add rsi, 1
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jne .L237_7
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
.L237_7:
    mov rsi, r14
    add rsi, 1
    mov rdi, r15
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rdx, r13
    mov rcx, r15
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r12
    add rsi, 32768
    mov rdi, r12
    add rdi, 32768
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_fresh_id
zyl_fresh_id:
    push rbp
    mov rbp, rsp
.L238_0:
    lea rax, [rip+zyl_rtg_fresh_id]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_of_word
zyl_cstr_of_word:
    push rbp
    mov rbp, rsp
.L239_0:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_float_bits
zyl_float_bits:
    push rbp
    mov rbp, rsp
.L240_0:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_float_of_bits
zyl_float_of_bits:
    push rbp
    mov rbp, rsp
.L241_0:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_word_load
zyl_word_load:
    push rbp
    mov rbp, rsp
.L242_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_word_store
zyl_word_store:
    push rbp
    mov rbp, rsp
.L243_0:
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ptr_add
zyl_ptr_add:
    push rbp
    mov rbp, rsp
.L244_0:
    add rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ptr_cstr
zyl_ptr_cstr:
    push rbp
    mov rbp, rsp
.L245_0:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dsize:
    push rbp
    mov rbp, rsp
.L246_0:
    mov rsi, 2208
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dcompress:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 872
    mov qword ptr [rbp-56], rdi
    mov qword ptr [rbp-64], rsi
    mov qword ptr [rbp-120], rcx
    mov qword ptr [rbp-72], r8
    mov r8, rdx
    mov qword ptr [rbp-48], r9
.L247_0:
    mov r12, qword ptr [rbp-56]
    add r12, 0
    mov rdx, r12
    mov eax, dword ptr [rdx]
    mov r12, rax
    mov r13, qword ptr [rbp-56]
    add r13, 4
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    mov r14, qword ptr [rbp-56]
    add r14, 8
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    mov r15, qword ptr [rbp-56]
    add r15, 12
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    mov qword ptr [rbp-88], r15
    mov rbx, qword ptr [rbp-56]
    add rbx, 16
    mov rdx, rbx
    mov eax, dword ptr [rdx]
    mov rbx, rax
    mov rdi, qword ptr [rbp-56]
    add rdi, 20
    mov rdx, rdi
    mov eax, dword ptr [rdx]
    mov rdi, rax
    mov rsi, qword ptr [rbp-56]
    add rsi, 24
    mov rdx, rsi
    mov eax, dword ptr [rdx]
    mov rsi, rax
    mov qword ptr [rbp-96], rsi
    mov r10, qword ptr [rbp-56]
    add r10, 28
    mov rdx, r10
    mov eax, dword ptr [rdx]
    mov r10, rax
    mov qword ptr [rbp-80], r10
    mov r10, 1779033703
    mov r15, 3144134277
    mov rsi, 1013904242
    mov qword ptr [rbp-104], rsi
    mov rsi, 2773480762
    mov qword ptr [rbp-112], rsi
    mov rsi, 4294967295
    and rsi, r8
    mov r9, 32
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    mov r9, 4294967295
    and r8, r9
    mov r9, r12
    add r9, rbx
    mov r12, qword ptr [rbp-64]
    add r12, 0
    mov rdx, r12
    mov eax, dword ptr [rdx]
    mov r12, rax
    add r9, r12
    xor rsi, r9
    mov r12, 16
    mov rax, rsi
    mov rcx, r12
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r12, rax
    and r12, 65535
    imul rsi, 65536
    or rsi, r12
    add r10, rsi
    xor rbx, r10
    mov r12, 12
    mov rax, rbx
    mov rcx, r12
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r12, rax
    and r12, 1048575
    imul rbx, 1048576
    or rbx, r12
    add r9, rbx
    mov r12, qword ptr [rbp-64]
    add r12, 4
    mov rdx, r12
    mov eax, dword ptr [rdx]
    mov r12, rax
    add r9, r12
    xor rsi, r9
    mov r12, 8
    mov rax, rsi
    mov rcx, r12
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r12, rax
    and r12, 16777215
    imul rsi, 16777216
    or rsi, r12
    add r10, rsi
    mov qword ptr [rbp-144], r10
    xor rbx, qword ptr [rbp-144]
    mov r12, 7
    mov rax, rbx
    mov rcx, r12
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r12, rax
    and r12, 33554431
    imul rbx, 33554432
    or rbx, r12
    mov qword ptr [rbp-128], rbx
    mov r12, r13
    add r12, rdi
    mov r13, qword ptr [rbp-64]
    add r13, 8
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r12, r13
    xor r8, r12
    mov r13, 16
    mov rax, r8
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 65535
    imul r8, 65536
    or r8, r13
    mov r13, r15
    add r13, r8
    xor rdi, r13
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r12, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 12
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r8, r12
    mov r15, 8
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r8, 16777216
    or r8, r15
    mov qword ptr [rbp-160], r8
    add r13, qword ptr [rbp-160]
    mov qword ptr [rbp-136], r13
    xor rdi, qword ptr [rbp-136]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    add r14, qword ptr [rbp-96]
    mov r15, qword ptr [rbp-64]
    add r15, 16
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r14, r15
    mov r15, qword ptr [rbp-120]
    xor r15, r14
    mov rbx, 16
    mov rax, r15
    mov rcx, rbx
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    and rbx, 65535
    imul r15, 65536
    or rbx, r15
    mov r15, qword ptr [rbp-104]
    add r15, rbx
    mov r13, qword ptr [rbp-96]
    xor r13, r15
    mov r10, 12
    mov rax, r13
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r13, 1048576
    or r10, r13
    mov r13, r14
    add r13, r10
    mov r14, qword ptr [rbp-64]
    add r14, 20
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-168], r13
    xor rbx, qword ptr [rbp-168]
    mov r14, 8
    mov rax, rbx
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul rbx, 16777216
    or rbx, r14
    mov qword ptr [rbp-152], rbx
    mov r14, r15
    add r14, qword ptr [rbp-152]
    xor r10, r14
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-176], r10
    mov r15, qword ptr [rbp-88]
    add r15, qword ptr [rbp-80]
    mov rbx, qword ptr [rbp-64]
    add rbx, 24
    mov rdx, rbx
    mov eax, dword ptr [rdx]
    mov rbx, rax
    add rbx, r15
    mov r15, qword ptr [rbp-72]
    xor r15, rbx
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-112]
    add r15, r8
    mov r13, qword ptr [rbp-80]
    xor r13, r15
    mov r10, 12
    mov rax, r13
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r13, 1048576
    or r10, r13
    add rbx, r10
    mov r13, qword ptr [rbp-64]
    add r13, 28
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r8, rbx
    mov r13, 8
    mov rax, r8
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r8, 16777216
    or r8, r13
    mov r13, r15
    add r13, r8
    xor r10, r13
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 32
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r8, r9
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    add r14, r8
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 36
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r8, r9
    mov r15, 8
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r8, 16777216
    or r8, r15
    mov qword ptr [rbp-184], r8
    add r14, qword ptr [rbp-184]
    mov qword ptr [rbp-208], r14
    xor rdi, qword ptr [rbp-208]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-232], rdi
    add r12, qword ptr [rbp-176]
    mov r15, qword ptr [rbp-64]
    add r15, 40
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r13, rsi
    mov r15, qword ptr [rbp-176]
    xor r15, r13
    mov r8, 12
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r15, 1048576
    or r8, r15
    add r12, r8
    mov r15, qword ptr [rbp-64]
    add r15, 44
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r13, rsi
    mov qword ptr [rbp-192], r13
    xor r8, qword ptr [rbp-192]
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-200], r8
    mov r15, qword ptr [rbp-168]
    add r15, r10
    mov r13, qword ptr [rbp-64]
    add r13, 48
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    mov r15, qword ptr [rbp-160]
    xor r15, r13
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-144]
    add r15, r8
    xor r10, r15
    mov r14, 12
    mov rax, r10
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 1048575
    imul r10, 1048576
    or r10, r14
    add r13, r10
    mov r14, qword ptr [rbp-64]
    add r14, 52
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-224], r13
    xor r8, qword ptr [rbp-224]
    mov r14, 8
    mov rax, r8
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r8, 16777216
    or r8, r14
    mov r14, r15
    add r14, r8
    xor r10, r14
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-216], r10
    add rbx, qword ptr [rbp-128]
    mov r15, qword ptr [rbp-64]
    add r15, 56
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-152]
    xor r15, rbx
    mov r10, 16
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 65535
    imul r15, 65536
    or r10, r15
    mov r15, qword ptr [rbp-136]
    add r15, r10
    mov r13, qword ptr [rbp-128]
    xor r13, r15
    mov rdi, 12
    mov rax, r13
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r13, 1048576
    or rdi, r13
    add rbx, rdi
    mov r13, qword ptr [rbp-64]
    add r13, 60
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r10, rbx
    mov r13, 8
    mov rax, r10
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r10, 16777216
    or r10, r13
    mov r13, r15
    add r13, r10
    xor rdi, r13
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 8
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r14, rsi
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 24
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r14, rsi
    mov qword ptr [rbp-256], r14
    xor rdi, qword ptr [rbp-256]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-240], rdi
    add r12, qword ptr [rbp-232]
    mov r15, qword ptr [rbp-64]
    add r15, 12
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r8, r12
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    add r13, r8
    mov r15, qword ptr [rbp-232]
    xor r15, r13
    mov rdi, 12
    mov rax, r15
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r15, 1048576
    or rdi, r15
    add r12, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 40
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r8, r12
    mov r15, 8
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r8, 16777216
    or r8, r15
    mov qword ptr [rbp-264], r8
    add r13, qword ptr [rbp-264]
    mov qword ptr [rbp-248], r13
    xor rdi, qword ptr [rbp-248]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov r15, qword ptr [rbp-224]
    add r15, qword ptr [rbp-200]
    mov r13, qword ptr [rbp-64]
    add r13, 28
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    xor r10, r13
    mov r15, 16
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r10, 65536
    or r10, r15
    mov r15, qword ptr [rbp-208]
    add r15, r10
    mov r14, qword ptr [rbp-200]
    xor r14, r15
    mov r8, 12
    mov rax, r14
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r14, 1048576
    or r8, r14
    add r13, r8
    mov r14, qword ptr [rbp-64]
    add r14, 0
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-280], r13
    xor r10, qword ptr [rbp-280]
    mov r14, 8
    mov rax, r10
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r10, 16777216
    or r10, r14
    mov qword ptr [rbp-272], r10
    mov r14, r15
    add r14, qword ptr [rbp-272]
    xor r8, r14
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-288], r8
    add rbx, qword ptr [rbp-216]
    mov r15, qword ptr [rbp-64]
    add r15, 16
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-184]
    xor r15, rbx
    mov r10, 16
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 65535
    imul r15, 65536
    or r10, r15
    mov r15, qword ptr [rbp-192]
    add r15, r10
    mov r13, qword ptr [rbp-216]
    xor r13, r15
    mov r8, 12
    mov rax, r13
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r13, 1048576
    or r8, r13
    add rbx, r8
    mov r13, qword ptr [rbp-64]
    add r13, 52
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r10, rbx
    mov r13, 8
    mov rax, r10
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r10, 16777216
    or r10, r13
    mov r13, r15
    add r13, r10
    xor r8, r13
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 4
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r10, r9
    mov r15, 16
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r10, 65536
    or r10, r15
    add r14, r10
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 44
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r10, r9
    mov r15, 8
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r10, 16777216
    or r10, r15
    mov qword ptr [rbp-296], r10
    add r14, qword ptr [rbp-296]
    mov qword ptr [rbp-320], r14
    xor rdi, qword ptr [rbp-320]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-344], rdi
    add r12, qword ptr [rbp-288]
    mov r15, qword ptr [rbp-64]
    add r15, 48
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r13, rsi
    mov r15, qword ptr [rbp-288]
    xor r15, r13
    mov r10, 12
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r15, 1048576
    or r10, r15
    add r12, r10
    mov r15, qword ptr [rbp-64]
    add r15, 20
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r13, rsi
    mov qword ptr [rbp-304], r13
    xor r10, qword ptr [rbp-304]
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-312], r10
    mov r15, qword ptr [rbp-280]
    add r15, r8
    mov r13, qword ptr [rbp-64]
    add r13, 36
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    mov r15, qword ptr [rbp-264]
    xor r15, r13
    mov r10, 16
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 65535
    imul r15, 65536
    or r10, r15
    mov r15, qword ptr [rbp-256]
    add r15, r10
    xor r8, r15
    mov r14, 12
    mov rax, r8
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 1048575
    imul r8, 1048576
    or r8, r14
    add r13, r8
    mov r14, qword ptr [rbp-64]
    add r14, 56
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-336], r13
    xor r10, qword ptr [rbp-336]
    mov r14, 8
    mov rax, r10
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r10, 16777216
    or r10, r14
    mov r14, r15
    add r14, r10
    xor r8, r14
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-328], r8
    add rbx, qword ptr [rbp-240]
    mov r15, qword ptr [rbp-64]
    add r15, 60
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-272]
    xor r15, rbx
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-248]
    add r15, r8
    mov r13, qword ptr [rbp-240]
    xor r13, r15
    mov rdi, 12
    mov rax, r13
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r13, 1048576
    or rdi, r13
    add rbx, rdi
    mov r13, qword ptr [rbp-64]
    add r13, 32
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r8, rbx
    mov r13, 8
    mov rax, r8
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r8, 16777216
    or r8, r13
    mov r13, r15
    add r13, r8
    xor rdi, r13
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 12
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r14, rsi
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 16
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r14, rsi
    mov qword ptr [rbp-368], r14
    xor rdi, qword ptr [rbp-368]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-352], rdi
    add r12, qword ptr [rbp-344]
    mov r15, qword ptr [rbp-64]
    add r15, 40
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r10, r12
    mov r15, 16
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r10, 65536
    or r10, r15
    add r13, r10
    mov r15, qword ptr [rbp-344]
    xor r15, r13
    mov rdi, 12
    mov rax, r15
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r15, 1048576
    or rdi, r15
    add r12, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 48
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r10, r12
    mov r15, 8
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r10, 16777216
    or r10, r15
    mov qword ptr [rbp-376], r10
    add r13, qword ptr [rbp-376]
    mov qword ptr [rbp-360], r13
    xor rdi, qword ptr [rbp-360]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov r15, qword ptr [rbp-336]
    add r15, qword ptr [rbp-312]
    mov r13, qword ptr [rbp-64]
    add r13, 52
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    xor r8, r13
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    mov r15, qword ptr [rbp-320]
    add r15, r8
    mov r14, qword ptr [rbp-312]
    xor r14, r15
    mov r10, 12
    mov rax, r14
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r14, 1048576
    or r10, r14
    add r13, r10
    mov r14, qword ptr [rbp-64]
    add r14, 8
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-392], r13
    xor r8, qword ptr [rbp-392]
    mov r14, 8
    mov rax, r8
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r8, 16777216
    or r8, r14
    mov qword ptr [rbp-384], r8
    mov r14, r15
    add r14, qword ptr [rbp-384]
    xor r10, r14
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-400], r10
    add rbx, qword ptr [rbp-328]
    mov r15, qword ptr [rbp-64]
    add r15, 28
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-296]
    xor r15, rbx
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-304]
    add r15, r8
    mov r13, qword ptr [rbp-328]
    xor r13, r15
    mov r10, 12
    mov rax, r13
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r13, 1048576
    or r10, r13
    add rbx, r10
    mov r13, qword ptr [rbp-64]
    add r13, 56
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r8, rbx
    mov r13, 8
    mov rax, r8
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r8, 16777216
    or r8, r13
    mov r13, r15
    add r13, r8
    xor r10, r13
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 24
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r8, r9
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    add r14, r8
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 20
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r8, r9
    mov r15, 8
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r8, 16777216
    or r8, r15
    mov qword ptr [rbp-408], r8
    add r14, qword ptr [rbp-408]
    mov qword ptr [rbp-432], r14
    xor rdi, qword ptr [rbp-432]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-456], rdi
    add r12, qword ptr [rbp-400]
    mov r15, qword ptr [rbp-64]
    add r15, 36
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r13, rsi
    mov r15, qword ptr [rbp-400]
    xor r15, r13
    mov r8, 12
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r15, 1048576
    or r8, r15
    add r12, r8
    mov r15, qword ptr [rbp-64]
    add r15, 0
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r13, rsi
    mov qword ptr [rbp-416], r13
    xor r8, qword ptr [rbp-416]
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-424], r8
    mov r15, qword ptr [rbp-392]
    add r15, r10
    mov r13, qword ptr [rbp-64]
    add r13, 44
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    mov r15, qword ptr [rbp-376]
    xor r15, r13
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-368]
    add r15, r8
    xor r10, r15
    mov r14, 12
    mov rax, r10
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 1048575
    imul r10, 1048576
    or r10, r14
    add r13, r10
    mov r14, qword ptr [rbp-64]
    add r14, 60
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-448], r13
    xor r8, qword ptr [rbp-448]
    mov r14, 8
    mov rax, r8
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r8, 16777216
    or r8, r14
    mov r14, r15
    add r14, r8
    xor r10, r14
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-440], r10
    add rbx, qword ptr [rbp-352]
    mov r15, qword ptr [rbp-64]
    add r15, 32
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-384]
    xor r15, rbx
    mov r10, 16
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 65535
    imul r15, 65536
    or r10, r15
    mov r15, qword ptr [rbp-360]
    add r15, r10
    mov r13, qword ptr [rbp-352]
    xor r13, r15
    mov rdi, 12
    mov rax, r13
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r13, 1048576
    or rdi, r13
    add rbx, rdi
    mov r13, qword ptr [rbp-64]
    add r13, 4
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r10, rbx
    mov r13, 8
    mov rax, r10
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r10, 16777216
    or r10, r13
    mov r13, r15
    add r13, r10
    xor rdi, r13
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 40
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r14, rsi
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 28
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r14, rsi
    mov qword ptr [rbp-480], r14
    xor rdi, qword ptr [rbp-480]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-464], rdi
    add r12, qword ptr [rbp-456]
    mov r15, qword ptr [rbp-64]
    add r15, 48
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r8, r12
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    add r13, r8
    mov r15, qword ptr [rbp-456]
    xor r15, r13
    mov rdi, 12
    mov rax, r15
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r15, 1048576
    or rdi, r15
    add r12, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 36
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r8, r12
    mov r15, 8
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r8, 16777216
    or r8, r15
    mov qword ptr [rbp-488], r8
    add r13, qword ptr [rbp-488]
    mov qword ptr [rbp-472], r13
    xor rdi, qword ptr [rbp-472]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov r15, qword ptr [rbp-448]
    add r15, qword ptr [rbp-424]
    mov r13, qword ptr [rbp-64]
    add r13, 56
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    xor r10, r13
    mov r15, 16
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r10, 65536
    or r10, r15
    mov r15, qword ptr [rbp-432]
    add r15, r10
    mov r14, qword ptr [rbp-424]
    xor r14, r15
    mov r8, 12
    mov rax, r14
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r14, 1048576
    or r8, r14
    add r13, r8
    mov r14, qword ptr [rbp-64]
    add r14, 12
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-504], r13
    xor r10, qword ptr [rbp-504]
    mov r14, 8
    mov rax, r10
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r10, 16777216
    or r10, r14
    mov qword ptr [rbp-496], r10
    mov r14, r15
    add r14, qword ptr [rbp-496]
    xor r8, r14
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-512], r8
    add rbx, qword ptr [rbp-440]
    mov r15, qword ptr [rbp-64]
    add r15, 52
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-408]
    xor r15, rbx
    mov r10, 16
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 65535
    imul r15, 65536
    or r10, r15
    mov r15, qword ptr [rbp-416]
    add r15, r10
    mov r13, qword ptr [rbp-440]
    xor r13, r15
    mov r8, 12
    mov rax, r13
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r13, 1048576
    or r8, r13
    add rbx, r8
    mov r13, qword ptr [rbp-64]
    add r13, 60
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r10, rbx
    mov r13, 8
    mov rax, r10
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r10, 16777216
    or r10, r13
    mov r13, r15
    add r13, r10
    xor r8, r13
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 16
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r10, r9
    mov r15, 16
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r10, 65536
    or r10, r15
    add r14, r10
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 0
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r10, r9
    mov r15, 8
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r10, 16777216
    or r10, r15
    mov qword ptr [rbp-520], r10
    add r14, qword ptr [rbp-520]
    mov qword ptr [rbp-544], r14
    xor rdi, qword ptr [rbp-544]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-568], rdi
    add r12, qword ptr [rbp-512]
    mov r15, qword ptr [rbp-64]
    add r15, 44
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r13, rsi
    mov r15, qword ptr [rbp-512]
    xor r15, r13
    mov r10, 12
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r15, 1048576
    or r10, r15
    add r12, r10
    mov r15, qword ptr [rbp-64]
    add r15, 8
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r13, rsi
    mov qword ptr [rbp-528], r13
    xor r10, qword ptr [rbp-528]
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-536], r10
    mov r15, qword ptr [rbp-504]
    add r15, r8
    mov r13, qword ptr [rbp-64]
    add r13, 20
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    mov r15, qword ptr [rbp-488]
    xor r15, r13
    mov r10, 16
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 65535
    imul r15, 65536
    or r10, r15
    mov r15, qword ptr [rbp-480]
    add r15, r10
    xor r8, r15
    mov r14, 12
    mov rax, r8
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 1048575
    imul r8, 1048576
    or r8, r14
    add r13, r8
    mov r14, qword ptr [rbp-64]
    add r14, 32
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-560], r13
    xor r10, qword ptr [rbp-560]
    mov r14, 8
    mov rax, r10
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r10, 16777216
    or r10, r14
    mov r14, r15
    add r14, r10
    xor r8, r14
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-552], r8
    add rbx, qword ptr [rbp-464]
    mov r15, qword ptr [rbp-64]
    add r15, 4
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-496]
    xor r15, rbx
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-472]
    add r15, r8
    mov r13, qword ptr [rbp-464]
    xor r13, r15
    mov rdi, 12
    mov rax, r13
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r13, 1048576
    or rdi, r13
    add rbx, rdi
    mov r13, qword ptr [rbp-64]
    add r13, 24
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r8, rbx
    mov r13, 8
    mov rax, r8
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r8, 16777216
    or r8, r13
    mov r13, r15
    add r13, r8
    xor rdi, r13
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 48
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r14, rsi
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 52
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r14, rsi
    mov qword ptr [rbp-592], r14
    xor rdi, qword ptr [rbp-592]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-576], rdi
    add r12, qword ptr [rbp-568]
    mov r15, qword ptr [rbp-64]
    add r15, 36
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r10, r12
    mov r15, 16
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r10, 65536
    or r10, r15
    add r13, r10
    mov r15, qword ptr [rbp-568]
    xor r15, r13
    mov rdi, 12
    mov rax, r15
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r15, 1048576
    or rdi, r15
    add r12, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 44
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r10, r12
    mov r15, 8
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r10, 16777216
    or r10, r15
    mov qword ptr [rbp-600], r10
    add r13, qword ptr [rbp-600]
    mov qword ptr [rbp-584], r13
    xor rdi, qword ptr [rbp-584]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov r15, qword ptr [rbp-560]
    add r15, qword ptr [rbp-536]
    mov r13, qword ptr [rbp-64]
    add r13, 60
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    xor r8, r13
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    mov r15, qword ptr [rbp-544]
    add r15, r8
    mov r14, qword ptr [rbp-536]
    xor r14, r15
    mov r10, 12
    mov rax, r14
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r14, 1048576
    or r10, r14
    add r13, r10
    mov r14, qword ptr [rbp-64]
    add r14, 40
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-616], r13
    xor r8, qword ptr [rbp-616]
    mov r14, 8
    mov rax, r8
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r8, 16777216
    or r8, r14
    mov qword ptr [rbp-608], r8
    mov r14, r15
    add r14, qword ptr [rbp-608]
    xor r10, r14
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-624], r10
    add rbx, qword ptr [rbp-552]
    mov r15, qword ptr [rbp-64]
    add r15, 56
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-520]
    xor r15, rbx
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-528]
    add r15, r8
    mov r13, qword ptr [rbp-552]
    xor r13, r15
    mov r10, 12
    mov rax, r13
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r13, 1048576
    or r10, r13
    add rbx, r10
    mov r13, qword ptr [rbp-64]
    add r13, 32
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r8, rbx
    mov r13, 8
    mov rax, r8
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r8, 16777216
    or r8, r13
    mov r13, r15
    add r13, r8
    xor r10, r13
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 28
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r8, r9
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    add r14, r8
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 8
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r8, r9
    mov r15, 8
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r8, 16777216
    or r8, r15
    mov qword ptr [rbp-632], r8
    add r14, qword ptr [rbp-632]
    mov qword ptr [rbp-656], r14
    xor rdi, qword ptr [rbp-656]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-680], rdi
    add r12, qword ptr [rbp-624]
    mov r15, qword ptr [rbp-64]
    add r15, 20
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r13, rsi
    mov r15, qword ptr [rbp-624]
    xor r15, r13
    mov r8, 12
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r15, 1048576
    or r8, r15
    add r12, r8
    mov r15, qword ptr [rbp-64]
    add r15, 12
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r13, rsi
    mov qword ptr [rbp-640], r13
    xor r8, qword ptr [rbp-640]
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-648], r8
    mov r15, qword ptr [rbp-616]
    add r15, r10
    mov r13, qword ptr [rbp-64]
    add r13, 0
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    mov r15, qword ptr [rbp-600]
    xor r15, r13
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-592]
    add r15, r8
    xor r10, r15
    mov r14, 12
    mov rax, r10
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 1048575
    imul r10, 1048576
    or r10, r14
    add r13, r10
    mov r14, qword ptr [rbp-64]
    add r14, 4
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-672], r13
    xor r8, qword ptr [rbp-672]
    mov r14, 8
    mov rax, r8
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r8, 16777216
    or r8, r14
    mov r14, r15
    add r14, r8
    xor r10, r14
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-664], r10
    add rbx, qword ptr [rbp-576]
    mov r15, qword ptr [rbp-64]
    add r15, 24
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-608]
    xor r15, rbx
    mov r10, 16
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 65535
    imul r15, 65536
    or r10, r15
    mov r15, qword ptr [rbp-584]
    add r15, r10
    mov r13, qword ptr [rbp-576]
    xor r13, r15
    mov rdi, 12
    mov rax, r13
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r13, 1048576
    or rdi, r13
    add rbx, rdi
    mov r13, qword ptr [rbp-64]
    add r13, 16
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r10, rbx
    mov r13, 8
    mov rax, r10
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r10, 16777216
    or r10, r13
    mov r13, r15
    add r13, r10
    xor rdi, r13
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 36
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r14, rsi
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 56
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r14, rsi
    mov qword ptr [rbp-704], r14
    xor rdi, qword ptr [rbp-704]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-688], rdi
    add r12, qword ptr [rbp-680]
    mov r15, qword ptr [rbp-64]
    add r15, 44
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r8, r12
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    add r13, r8
    mov r15, qword ptr [rbp-680]
    xor r15, r13
    mov rdi, 12
    mov rax, r15
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r15, 1048576
    or rdi, r15
    add r12, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 20
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r8, r12
    mov r15, 8
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r8, 16777216
    or r8, r15
    mov qword ptr [rbp-712], r8
    add r13, qword ptr [rbp-712]
    mov qword ptr [rbp-696], r13
    xor rdi, qword ptr [rbp-696]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov r15, qword ptr [rbp-672]
    add r15, qword ptr [rbp-648]
    mov r13, qword ptr [rbp-64]
    add r13, 32
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    xor r10, r13
    mov r15, 16
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r10, 65536
    or r10, r15
    mov r15, qword ptr [rbp-656]
    add r15, r10
    mov r14, qword ptr [rbp-648]
    xor r14, r15
    mov r8, 12
    mov rax, r14
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r14, 1048576
    or r8, r14
    add r13, r8
    mov r14, qword ptr [rbp-64]
    add r14, 48
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-728], r13
    xor r10, qword ptr [rbp-728]
    mov r14, 8
    mov rax, r10
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r10, 16777216
    or r10, r14
    mov qword ptr [rbp-720], r10
    mov r14, r15
    add r14, qword ptr [rbp-720]
    xor r8, r14
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-736], r8
    add rbx, qword ptr [rbp-664]
    mov r15, qword ptr [rbp-64]
    add r15, 60
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-632]
    xor r15, rbx
    mov r10, 16
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 65535
    imul r15, 65536
    or r10, r15
    mov r15, qword ptr [rbp-640]
    add r15, r10
    mov r13, qword ptr [rbp-664]
    xor r13, r15
    mov r8, 12
    mov rax, r13
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r13, 1048576
    or r8, r13
    add rbx, r8
    mov r13, qword ptr [rbp-64]
    add r13, 4
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r10, rbx
    mov r13, 8
    mov rax, r10
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r10, 16777216
    or r10, r13
    mov r13, r15
    add r13, r10
    xor r8, r13
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 52
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r10, r9
    mov r15, 16
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r10, 65536
    or r10, r15
    add r14, r10
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 12
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r10, r9
    mov r15, 8
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r10, 16777216
    or r10, r15
    mov qword ptr [rbp-744], r10
    add r14, qword ptr [rbp-744]
    mov qword ptr [rbp-768], r14
    xor rdi, qword ptr [rbp-768]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-792], rdi
    add r12, qword ptr [rbp-736]
    mov r15, qword ptr [rbp-64]
    add r15, 0
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r13, rsi
    mov r15, qword ptr [rbp-736]
    xor r15, r13
    mov r10, 12
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r15, 1048576
    or r10, r15
    add r12, r10
    mov r15, qword ptr [rbp-64]
    add r15, 40
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r13, rsi
    mov qword ptr [rbp-752], r13
    xor r10, qword ptr [rbp-752]
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-760], r10
    mov r15, qword ptr [rbp-728]
    add r15, r8
    mov r13, qword ptr [rbp-64]
    add r13, 8
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    mov r15, qword ptr [rbp-712]
    xor r15, r13
    mov r10, 16
    mov rax, r15
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 65535
    imul r15, 65536
    or r10, r15
    mov r15, qword ptr [rbp-704]
    add r15, r10
    xor r8, r15
    mov r14, 12
    mov rax, r8
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 1048575
    imul r8, 1048576
    or r8, r14
    add r13, r8
    mov r14, qword ptr [rbp-64]
    add r14, 24
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-784], r13
    xor r10, qword ptr [rbp-784]
    mov r14, 8
    mov rax, r10
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r10, 16777216
    or r10, r14
    mov r14, r15
    add r14, r10
    xor r8, r14
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-776], r8
    add rbx, qword ptr [rbp-688]
    mov r15, qword ptr [rbp-64]
    add r15, 16
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-720]
    xor r15, rbx
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-696]
    add r15, r8
    mov r13, qword ptr [rbp-688]
    xor r13, r15
    mov rdi, 12
    mov rax, r13
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r13, 1048576
    or rdi, r13
    add rbx, rdi
    mov r13, qword ptr [rbp-64]
    add r13, 28
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r8, rbx
    mov r13, 8
    mov rax, r8
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r8, 16777216
    or r8, r13
    mov r13, r15
    add r13, r8
    xor rdi, r13
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 44
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r14, rsi
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 60
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor rsi, r9
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    add r14, rsi
    mov qword ptr [rbp-816], r14
    xor rdi, qword ptr [rbp-816]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-800], rdi
    add r12, qword ptr [rbp-792]
    mov r15, qword ptr [rbp-64]
    add r15, 20
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r10, r12
    mov r15, 16
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r10, 65536
    or r10, r15
    add r13, r10
    mov r15, qword ptr [rbp-792]
    xor r15, r13
    mov rdi, 12
    mov rax, r15
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 1048575
    imul r15, 1048576
    or rdi, r15
    add r12, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 0
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor r10, r12
    mov r15, 8
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r10, 16777216
    or r10, r15
    mov qword ptr [rbp-824], r10
    add r13, qword ptr [rbp-824]
    mov qword ptr [rbp-808], r13
    xor rdi, qword ptr [rbp-808]
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov r15, qword ptr [rbp-784]
    add r15, qword ptr [rbp-760]
    mov r13, qword ptr [rbp-64]
    add r13, 4
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add r13, r15
    xor r8, r13
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    mov r15, qword ptr [rbp-768]
    add r15, r8
    mov r14, qword ptr [rbp-760]
    xor r14, r15
    mov r10, 12
    mov rax, r14
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r14, 1048576
    or r10, r14
    add r13, r10
    mov r14, qword ptr [rbp-64]
    add r14, 36
    mov rdx, r14
    mov eax, dword ptr [rdx]
    mov r14, rax
    add r13, r14
    mov qword ptr [rbp-840], r13
    xor r8, qword ptr [rbp-840]
    mov r14, 8
    mov rax, r8
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    and r14, 16777215
    imul r8, 16777216
    or r8, r14
    mov qword ptr [rbp-832], r8
    mov r14, r15
    add r14, qword ptr [rbp-832]
    xor r10, r14
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    mov qword ptr [rbp-848], r10
    add rbx, qword ptr [rbp-776]
    mov r15, qword ptr [rbp-64]
    add r15, 32
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-744]
    xor r15, rbx
    mov r8, 16
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    imul r15, 65536
    or r8, r15
    mov r15, qword ptr [rbp-752]
    add r15, r8
    mov r13, qword ptr [rbp-776]
    xor r13, r15
    mov r10, 12
    mov rax, r13
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 1048575
    imul r13, 1048576
    or r10, r13
    add rbx, r10
    mov r13, qword ptr [rbp-64]
    add r13, 24
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor r8, rbx
    mov r13, 8
    mov rax, r8
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul r8, 16777216
    or r8, r13
    mov r13, r15
    add r13, r8
    xor r10, r13
    mov r15, 7
    mov rax, r10
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r10, 33554432
    or r10, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 56
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r8, r9
    mov r15, 16
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul r8, 65536
    or r8, r15
    add r14, r8
    xor rdi, r14
    mov r15, 12
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 1048575
    imul rdi, 1048576
    or rdi, r15
    add r9, rdi
    mov r15, qword ptr [rbp-64]
    add r15, 40
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r9, r15
    xor r8, r9
    mov r15, 8
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul r8, 16777216
    or r8, r15
    mov qword ptr [rbp-856], r8
    add r14, qword ptr [rbp-856]
    xor rdi, r14
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov qword ptr [rbp-872], rdi
    add r12, qword ptr [rbp-848]
    mov r15, qword ptr [rbp-64]
    add r15, 8
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 16
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 65535
    imul rsi, 65536
    or rsi, r15
    add r13, rsi
    mov r15, qword ptr [rbp-848]
    xor r15, r13
    mov r8, 12
    mov rax, r15
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 1048575
    imul r15, 1048576
    or r8, r15
    add r12, r8
    mov r15, qword ptr [rbp-64]
    add r15, 48
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add r12, r15
    xor rsi, r12
    mov r15, 8
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 16777215
    imul rsi, 16777216
    or rsi, r15
    mov qword ptr [rbp-880], rsi
    add r13, qword ptr [rbp-880]
    mov qword ptr [rbp-904], r13
    xor r8, qword ptr [rbp-904]
    mov r15, 7
    mov rax, r8
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul r8, 33554432
    or r8, r15
    mov qword ptr [rbp-864], r8
    mov r15, qword ptr [rbp-840]
    add r15, r10
    mov r8, qword ptr [rbp-64]
    add r8, 12
    mov rdx, r8
    mov eax, dword ptr [rdx]
    mov r8, rax
    add r8, r15
    mov r15, qword ptr [rbp-824]
    xor r15, r8
    mov rdi, 16
    mov rax, r15
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    and rdi, 65535
    imul r15, 65536
    or rdi, r15
    mov r15, qword ptr [rbp-816]
    add r15, rdi
    xor r10, r15
    mov rsi, 12
    mov rax, r10
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    and rsi, 1048575
    imul r10, 1048576
    or rsi, r10
    add r8, rsi
    mov r10, qword ptr [rbp-64]
    add r10, 16
    mov rdx, r10
    mov eax, dword ptr [rdx]
    mov r10, rax
    add r8, r10
    xor rdi, r8
    mov r10, 8
    mov rax, rdi
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    and r10, 16777215
    imul rdi, 16777216
    or rdi, r10
    mov qword ptr [rbp-896], rdi
    mov r10, r15
    add r10, qword ptr [rbp-896]
    xor rsi, r10
    mov r15, 7
    mov rax, rsi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rsi, 33554432
    or rsi, r15
    mov qword ptr [rbp-888], rsi
    add rbx, qword ptr [rbp-800]
    mov r15, qword ptr [rbp-64]
    add r15, 28
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    add rbx, r15
    mov r15, qword ptr [rbp-832]
    xor r15, rbx
    mov rsi, 16
    mov rax, r15
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    and rsi, 65535
    imul r15, 65536
    or rsi, r15
    mov r15, qword ptr [rbp-808]
    add r15, rsi
    mov rdi, qword ptr [rbp-800]
    xor rdi, r15
    mov r13, 12
    mov rax, rdi
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 1048575
    imul rdi, 1048576
    or rdi, r13
    add rbx, rdi
    mov r13, qword ptr [rbp-64]
    add r13, 52
    mov rdx, r13
    mov eax, dword ptr [rdx]
    mov r13, rax
    add rbx, r13
    xor rsi, rbx
    mov r13, 8
    mov rax, rsi
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    and r13, 16777215
    imul rsi, 16777216
    or rsi, r13
    mov qword ptr [rbp-912], rsi
    mov r13, r15
    add r13, qword ptr [rbp-912]
    xor rdi, r13
    mov r15, 7
    mov rax, rdi
    mov rcx, r15
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r15, rax
    and r15, 33554431
    imul rdi, 33554432
    or rdi, r15
    mov r15, qword ptr [rbp-48]
    add r15, 32
    mov rsi, qword ptr [rbp-56]
    add rsi, 0
    mov rdx, rsi
    mov eax, dword ptr [rdx]
    mov rsi, rax
    xor rsi, r10
    mov rdx, r15
    mov rcx, rsi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 36
    mov r15, qword ptr [rbp-56]
    add r15, 4
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    xor r15, r13
    mov rdx, rsi
    mov rcx, r15
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 40
    mov r15, qword ptr [rbp-56]
    add r15, 8
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    xor r15, r14
    mov rdx, rsi
    mov rcx, r15
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 44
    mov r15, qword ptr [rbp-56]
    add r15, 12
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    xor r15, qword ptr [rbp-904]
    mov rdx, rsi
    mov rcx, r15
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 48
    mov r15, qword ptr [rbp-56]
    add r15, 16
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    xor r15, qword ptr [rbp-880]
    mov rdx, rsi
    mov rcx, r15
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 52
    mov r15, qword ptr [rbp-56]
    add r15, 20
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    xor r15, qword ptr [rbp-896]
    mov rdx, rsi
    mov rcx, r15
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 56
    mov r15, qword ptr [rbp-56]
    add r15, 24
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    xor r15, qword ptr [rbp-912]
    mov rdx, rsi
    mov rcx, r15
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 60
    mov r15, qword ptr [rbp-56]
    add r15, 28
    mov rdx, r15
    mov eax, dword ptr [rdx]
    mov r15, rax
    xor r15, qword ptr [rbp-856]
    mov rdx, rsi
    mov rcx, r15
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 0
    xor r9, r10
    mov rdx, rsi
    mov rcx, r9
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 4
    mov r9, r12
    xor r9, r13
    mov rdx, rsi
    mov rcx, r9
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 8
    xor r8, r14
    mov rdx, rsi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 12
    mov r8, rbx
    xor r8, qword ptr [rbp-904]
    mov rdx, rsi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 16
    xor rdi, qword ptr [rbp-880]
    mov rdx, rsi
    mov rcx, rdi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 20
    mov rdi, qword ptr [rbp-872]
    xor rdi, qword ptr [rbp-896]
    mov rdx, rsi
    mov rcx, rdi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 24
    mov rdi, qword ptr [rbp-864]
    xor rdi, qword ptr [rbp-912]
    mov rdx, rsi
    mov rcx, rdi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 28
    mov rdi, qword ptr [rbp-888]
    xor rdi, qword ptr [rbp-856]
    mov rdx, rsi
    mov rcx, rdi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dzero64:
    push rbp
    mov rbp, rsp
.L248_0:
    cmp rsi, 64
    jl .L248_1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L248_1:
    mov r8, rdi
    add r8, rsi
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    mov r8, rsi
    add r8, 8
    mov rsi, r8
    jmp .L248_0
zy_local_x2Fmain_0__blake3__b3_x2Dinit:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L249_0:
    mov rsi, rbx
    add rsi, 1728
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 1768
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 1840
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 1848
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 1776
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__blake3__b3_x2Dzero64
    mov rsi, rax
    mov rsi, rbx
    add rsi, 2016
    mov rdi, 1779033703
    mov rdx, rsi
    mov rcx, rdi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 4
    mov r8, 3144134277
    mov rdx, rdi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 8
    mov r8, 1013904242
    mov rdx, rdi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 12
    mov r8, 2773480762
    mov rdx, rdi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 16
    mov r8, 1359893119
    mov rdx, rdi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 20
    mov r8, 2600822924
    mov rdx, rdi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 24
    mov r8, 528734635
    mov rdx, rdi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 28
    mov r8, 1541459225
    mov rdx, rdi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rbx
    add rdi, 1736
    mov r8, 32
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag:
    push rbp
    mov rbp, rsp
.L250_0:
    mov rsi, rdi
    add rsi, 1848
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L250_1
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L250_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dpush_x2Dcv:
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
.L251_0:
    mov rsi, rbx
    add rsi, 1728
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r14, rsi
    mov rsi, r13
    and rsi, 1
    cmp rsi, 0
    jne .L251_1
    cmp r14, 0
    jle .L251_1
    mov rsi, rbx
    add rsi, 1920
    mov r15, rsi
    mov rsi, r14
    sub rsi, 1
    imul rsi, 32
    add rsi, rbx
    mov rdi, 32
    mov rdx, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, r15
    add rsi, 32
    mov rdi, 32
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, 1728
    mov rdi, r14
    sub rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 2016
    mov rdi, 0
    mov r8, 64
    mov r9, 4
    mov r10, rbx
    add r10, 1856
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r15
    mov rcx, r8
    mov r8, r9
    mov r9, r10
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov rsi, rax
    mov rsi, rbx
    add rsi, 1856
    mov rdi, 1
    mov rax, r13
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov r12, rsi
    mov r13, rdi
    jmp .L251_0
.L251_1:
    mov rsi, r14
    imul rsi, 32
    add rsi, rbx
    mov rdi, 32
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, 1728
    mov rdi, r14
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dflush:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov qword ptr [rbp-48], rdi
.L252_0:
    mov rsi, qword ptr [rbp-48]
    add rsi, 1768
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rsi, qword ptr [rbp-48]
    add rsi, 1848
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 15
    jne .L252_1
    mov r13, qword ptr [rbp-48]
    add r13, 1736
    mov r14, qword ptr [rbp-48]
    add r14, 1776
    mov r15, 64
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag
    mov rsi, rax
    or rsi, 2
    mov rdi, qword ptr [rbp-48]
    add rdi, 1856
    mov rdx, r12
    mov rcx, r15
    mov r8, rsi
    mov rsi, r14
    mov r9, rdi
    mov rdi, r13
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 1856
    mov rdi, r12
    add rdi, 1
    mov rdx, rdi
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__blake3__b3_x2Dpush_x2Dcv
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 1768
    mov rdi, r12
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 1736
    mov rdi, qword ptr [rbp-48]
    add rdi, 2016
    mov r8, 32
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 1848
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov r13, rsi
    jmp .L252_2
.L252_1:
    mov r14, qword ptr [rbp-48]
    add r14, 1736
    mov r15, qword ptr [rbp-48]
    add r15, 1776
    mov rbx, 64
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    add rdi, 1856
    mov rdx, r12
    mov rcx, rbx
    mov r8, rsi
    mov rsi, r15
    mov r9, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 1736
    mov rdi, qword ptr [rbp-48]
    add rdi, 1856
    mov r8, 32
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 1848
    mov rdi, qword ptr [rbp-48]
    add rdi, 1848
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov r13, rsi
.L252_2:
    mov rsi, qword ptr [rbp-48]
    add rsi, 1840
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 1776
    mov rdi, 0
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
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dzero64
zy_local_x2Fmain_0__blake3__b3_x2Dupdate:
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
.L253_0:
    cmp r13, 0
    jg .L253_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L253_1:
    mov rsi, rbx
    add rsi, 1840
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 64
    jne .L253_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dflush
    mov rsi, rax
    jmp .L253_3
.L253_2:
    mov rdi, 0
    mov rsi, rdi
.L253_3:
    mov rsi, rbx
    add rsi, 1840
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r14, rsi
    mov rsi, 64
    sub rsi, r14
    cmp rsi, r13
    jle .L253_4
    mov rsi, r13
    jmp .L253_5
.L253_4:
    mov rdi, 64
    sub rdi, r14
    mov rsi, rdi
.L253_5:
    mov r15, rsi
    mov rsi, rbx
    add rsi, 1776
    add rsi, r14
    mov rdi, rsi
    mov rsi, r12
    mov rdx, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, 1840
    mov rdi, r14
    add rdi, r15
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r12
    add rsi, r15
    mov rdi, r13
    sub rdi, r15
    mov r12, rsi
    mov r13, rdi
    jmp .L253_0
zy_local_x2Fmain_0__blake3__b3_x2Dfold:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    mov qword ptr [rbp-56], rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
    mov qword ptr [rbp-48], r9
.L254_0:
    cmp r12, 0
    jne .L254_1
    mov rsi, 0
    mov rdi, r15
    or rdi, 8
    mov r8, 0
    mov rdx, r14
    mov rcx, rdi
    mov rdi, qword ptr [rbp-56]
    mov r9, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Demit
.L254_1:
    mov rsi, qword ptr [rbp-56]
    add rsi, 2080
    mov rbx, rsi
    mov rsi, qword ptr [rbp-56]
    add rsi, 2048
    mov rdi, qword ptr [rbp-56]
    add rdi, 1856
    mov rdx, r13
    mov rcx, r14
    mov r8, r15
    mov r9, rdi
    mov rdi, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov rsi, rax
    mov rsi, r12
    sub rsi, 1
    imul rsi, 32
    add rsi, qword ptr [rbp-56]
    mov rdi, 32
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, 32
    mov rdi, qword ptr [rbp-56]
    add rdi, 1856
    mov r8, 32
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, qword ptr [rbp-56]
    add rsi, 2048
    mov rdi, qword ptr [rbp-56]
    add rdi, 2016
    mov r8, 32
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, r12
    sub rsi, 1
    mov rdi, 0
    mov r8, 64
    mov r9, 4
    mov r12, rsi
    mov r13, rdi
    mov r14, r8
    mov r15, r9
    jmp .L254_0
zy_local_x2Fmain_0__blake3__b3_x2Demit:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    mov qword ptr [rbp-56], rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
    mov qword ptr [rbp-48], r9
.L255_0:
    cmp r15, qword ptr [rbp-48]
    jl .L255_1
    mov rax, qword ptr [rbp-56]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L255_1:
    mov rsi, qword ptr [rbp-56]
    add rsi, 2048
    mov rdi, qword ptr [rbp-56]
    add rdi, 2080
    mov r8, qword ptr [rbp-56]
    add r8, 1856
    mov rdx, r12
    mov rcx, r13
    mov r9, r8
    mov r8, r14
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    sub rsi, r15
    cmp rsi, 64
    jle .L255_2
    mov rsi, 64
    jmp .L255_3
.L255_2:
    mov rdi, qword ptr [rbp-48]
    sub rdi, r15
    mov rsi, rdi
.L255_3:
    mov rbx, rsi
    mov rsi, qword ptr [rbp-56]
    add rsi, 2144
    add rsi, r15
    mov rdi, qword ptr [rbp-56]
    add rdi, 1856
    mov rdx, rbx
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, r12
    add rsi, 1
    mov rdi, r15
    add rdi, rbx
    mov r12, rsi
    mov r15, rdi
    jmp .L255_0
zy_local_x2Fmain_0__blake3__b3_x2Dfinalize:
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
.L256_0:
    mov rsi, rbx
    add rsi, 2048
    mov rdi, rbx
    add rdi, 1736
    mov r8, 32
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, 2080
    mov rdi, rbx
    add rdi, 1776
    mov r8, 64
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, 1728
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov r13, rax
    mov rsi, rbx
    add rsi, 1768
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov r14, rax
    mov rsi, rbx
    add rsi, 1840
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov r15, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag
    mov rsi, rax
    or rsi, 2
    mov rdi, rbx
    mov rdx, r14
    mov rcx, r15
    mov r8, rsi
    mov rsi, r13
    mov r9, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dfold
zy_local_x2Fmain_0__blake3__b3_x2Dnew:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L257_0:
    mov rsi, 2208
    mov rdi, rsi
    call malloc
    mov rsi, rax
    cmp rsi, 0
    jne .L257_1
    mov rdi, 0
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L257_1:
    mov rdi, rsi
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dinit
zy_local_x2Fmain_0__blake3__rt_x2Dblake3_x2Draw:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L258_0:
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jne .L258_1
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
.L258_1:
    mov rdi, r15
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__blake3__b3_x2Dupdate
    mov rsi, rax
    mov rdi, r15
    mov rsi, r14
    call zy_local_x2Fmain_0__blake3__b3_x2Dfinalize
    mov rsi, rax
    mov rsi, r15
    add rsi, 2144
    mov rdi, r13
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rdi, r15
    call free
    mov rsi, rax
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
zy_local_x2Fmain_0__blake3__b3_x2Dhexdigits:
    push rbp
    mov rbp, rsp
.L259_0:
    lea rax, [rip+.L260]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__rt_x2Dhex_x2Dbytes:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L261_0:
    cmp r8, r9
    jl .L261_1
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L261_1:
    mov r10, rsi
    add r10, r8
    mov rdx, r10
    movzx eax, byte ptr [rdx]
    mov r10, rax
    lea rax, [rip+.L262]
    mov rbx, rax
    mov r12, r8
    imul r12, 2
    add r12, rdi
    mov r13, 4
    mov rax, r10
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    add r13, rbx
    mov rdx, r13
    movzx eax, byte ptr [rdx]
    mov r13, rax
    mov rdx, r12
    mov rcx, r13
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r12, rax
    mov r12, r8
    imul r12, 2
    add r12, 1
    add r12, rdi
    and r10, 15
    add r10, rbx
    mov rdx, r10
    movzx eax, byte ptr [rdx]
    mov r10, rax
    mov rdx, r12
    mov rcx, r10
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r10, rax
    mov r10, r8
    add r10, 1
    mov r8, r10
    jmp .L261_0
zy_local_x2Fmain_0__blake3__b3_x2Dclamp:
    push rbp
    mov rbp, rsp
.L263_0:
    cmp rdi, 0
    jg .L263_1
    mov rsi, 32
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L263_1:
    cmp rdi, 64
    jle .L263_2
    mov rsi, 64
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L263_2:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dhex_x2Dout:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L264_0:
    mov rdi, r12
    mov rsi, r13
    call zy_local_x2Fmain_0__blake3__b3_x2Dfinalize
    mov rsi, rax
    mov rsi, r13
    imul rsi, 2
    add rsi, 1
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rbx, rsi
    mov rsi, r12
    add rsi, 2144
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r13
    call zy_local_x2Fmain_0__blake3__rt_x2Dhex_x2Dbytes
    mov rsi, rax
    mov rsi, r13
    imul rsi, 2
    add rsi, rbx
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rdi, r12
    call free
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_blake3_hex
zyl_blake3_hex:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, rdi
    mov r12, rdx
    mov r13, rcx
.L265_0:
    mov r14, rsi
    cmp r14, 0
    jne .L265_1
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
.L265_1:
    cmp r12, 0
    jge .L265_2
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    jmp .L265_3
.L265_2:
    mov rsi, r12
.L265_3:
    mov r12, rsi
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jne .L265_4
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
.L265_4:
    mov rdi, r15
    mov rsi, r14
    mov rdx, r12
    call zy_local_x2Fmain_0__blake3__b3_x2Dupdate
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__blake3__b3_x2Dclamp
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dhex_x2Dout
zy_local_x2Fmain_0__blake3__b3_x2Dread_x2Dall:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L266_0:
    mov rsi, 1
    mov rdi, 65536
    mov rdx, rdi
    mov rdi, r13
    mov rcx, r12
    call fread
    mov rsi, rax
    cmp rsi, 0
    jle .L266_1
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__blake3__b3_x2Dupdate
    mov rsi, rax
    jmp .L266_0
.L266_1:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_blake3_file_hex
zyl_blake3_file_hex:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov qword ptr [rbp-48], rdi
    mov r12, rdx
.L267_0:
    cmp rsi, 0
    jne .L267_1
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L267_1:
    lea rax, [rip+.L268]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call fopen
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L267_2
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
.L267_2:
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov rsi, rax
    mov r14, rsi
    cmp r14, 0
    jne .L267_3
    mov rsi, 0
    mov r15, rsi
    jmp .L267_4
.L267_3:
    mov rsi, 65536
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov r15, rsi
.L267_4:
    cmp r15, 0
    jne .L267_5
    cmp r14, 0
    jne .L267_6
    mov rsi, 0
    mov rbx, rsi
    jmp .L267_7
.L267_6:
    mov rdi, r14
    call free
    mov rsi, rax
    mov rbx, rsi
.L267_7:
    mov rdi, r13
    call fclose
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
.L267_5:
    mov rdi, r14
    mov rsi, r13
    mov rdx, r15
    call zy_local_x2Fmain_0__blake3__b3_x2Dread_x2Dall
    mov rsi, rax
    mov rdi, r15
    call free
    mov rsi, rax
    mov rdi, r13
    call fclose
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__blake3__b3_x2Dclamp
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    mov rdx, rsi
    mov rsi, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dhex_x2Dout
zy_local_x2Fmain_0__mangle__mg_x2Dupper_x2Dhex:
    push rbp
    mov rbp, rsp
.L269_0:
    lea rax, [rip+.L270]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__mangle__mg_x2Dwidths:
    push rbp
    mov rbp, rsp
.L271_0:
    lea rax, [rip+.L272]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__mangle__mg_x2Desc_x2Dlen:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L273_0:
    cmp rsi, r8
    jl .L273_1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L273_1:
    mov r10, rsi
    add r10, 1
    lea rax, [rip+.L274]
    mov rbx, rax
    mov r12, rdi
    add r12, rsi
    mov rdx, r12
    movzx eax, byte ptr [rdx]
    mov r12, rax
    add rbx, r12
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rbx, rax
    add rbx, r9
    mov rsi, r10
    mov r9, rbx
    jmp .L273_0
zy_local_x2Fmain_0__mangle__mg_x2Desc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L275_0:
    cmp rsi, r8
    jl .L275_1
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L275_1:
    mov rbx, rdi
    add rbx, rsi
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rbx, rax
    lea rax, [rip+.L276]
    mov r12, rax
    add r12, rbx
    mov rdx, r12
    movzx eax, byte ptr [rdx]
    mov r12, rax
    cmp r12, 1
    jne .L275_2
    mov r13, r9
    add r13, r10
    mov rdx, r13
    mov rcx, rbx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r13, rax
    mov r13, rsi
    add r13, 1
    mov r14, r10
    add r14, 1
    mov rsi, r13
    mov r10, r14
    jmp .L275_0
.L275_2:
    cmp r12, 3
    jne .L275_3
    mov r12, r9
    add r12, r10
    mov r13, 95
    mov rdx, r12
    mov rcx, r13
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r12, rax
    mov r12, r10
    add r12, 1
    add r12, r9
    mov r13, 53
    mov rdx, r12
    mov rcx, r13
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r12, rax
    mov r12, r10
    add r12, 2
    add r12, r9
    mov r13, 70
    mov rdx, r12
    mov rcx, r13
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r12, rax
    mov r12, rsi
    add r12, 1
    mov r13, r10
    add r13, 3
    mov rsi, r12
    mov r10, r13
    jmp .L275_0
.L275_3:
    lea rax, [rip+.L277]
    mov r12, rax
    mov r13, r9
    add r13, r10
    mov r14, 95
    mov rdx, r13
    mov rcx, r14
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r13, rax
    mov r13, r10
    add r13, 1
    add r13, r9
    mov r14, 120
    mov rdx, r13
    mov rcx, r14
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r13, rax
    mov r13, r10
    add r13, 2
    add r13, r9
    mov r14, 4
    mov rax, rbx
    mov rcx, r14
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    add r14, r12
    mov rdx, r14
    movzx eax, byte ptr [rdx]
    mov r14, rax
    mov rdx, r13
    mov rcx, r14
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r13, rax
    mov r13, r10
    add r13, 3
    add r13, r9
    and rbx, 15
    add rbx, r12
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rbx, rax
    mov rdx, r13
    mov rcx, rbx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rbx, rax
    mov rbx, rsi
    add rbx, 1
    mov r12, r10
    add r12, 4
    mov rsi, rbx
    mov r10, r12
    jmp .L275_0
.globl zyl_sym_escape
zyl_sym_escape:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L278_0:
    mov r12, rsi
    cmp r12, 0
    jne .L278_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L278_1:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r13, rsi
    mov rsi, 0
    mov rdi, 0
    mov rdx, r13
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__mangle__mg_x2Desc_x2Dlen
    mov rsi, rax
    mov r14, rsi
    mov rsi, r14
    add rsi, 1
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rbx, rsi
    mov rsi, 0
    mov rdi, 0
    mov rdx, r13
    mov rcx, rbx
    mov r8, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__mangle__mg_x2Desc
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
zy_local_x2Fmain_0__mangle__mg_x2Dsep:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L279_0:
    mov r9, rsi
    add r9, 1
    cmp r9, r8
    jl .L279_1
    mov r9, -1
    mov rax, r9
    mov rsp, rbp
    pop rbp
    ret
.L279_1:
    mov r9, rdi
    add r9, rsi
    mov rdx, r9
    movzx eax, byte ptr [rdx]
    mov r9, rax
    cmp r9, 58
    jne .L279_2
    mov r9, rsi
    add r9, 1
    add r9, rdi
    mov rdx, r9
    movzx eax, byte ptr [rdx]
    mov r9, rax
    cmp r9, 58
    jne .L279_2
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L279_2:
    mov r9, rsi
    add r9, 1
    mov rsi, r9
    jmp .L279_0
zy_local_x2Fmain_0__mangle__mg_x2Dwrite:
    push rbp
    mov rbp, rsp
    sub rsp, 280
    mov [rbp-280], rbx
    mov [rbp-272], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    mov r10, [rbp+16]
    mov [rbp-56], r10
    mov r10, [rbp+24]
    mov [rbp-64], r10
    mov r10, [rbp+32]
    mov [rbp-72], r10
    mov rax, [rbp-8]
    push rax
    mov rax, 122
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-80], rax
    mov rax, [rbp-8]
    mov rcx, 1
    add rax, rcx
    push rax
    mov rax, 121
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-88], rax
    mov rax, [rbp-8]
    mov rcx, 2
    add rax, rcx
    push rax
    mov rax, 95
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-96], rax
    sub rsp, 8
    sub rsp, 40
    mov rdi, [rbp-16]
    mov rsi, 0
    mov rdx, [rbp-24]
    mov rcx, [rbp-8]
    mov r8, 3
call zy_local_x2Fmain_0__mangle__mg_x2Desc
    add rsp, 48
    mov [rbp-104], rax
    mov rax, [rbp-8]
    mov rcx, [rbp-104]
    add rax, rcx
    push rax
    mov rax, 95
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-112], rax
    sub rsp, 8
    sub rsp, 24
    mov rax, [rbp-104]
    mov rcx, 1
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    mov rdi, rax
    mov rsi, [rbp-32]
    mov rdx, [rbp-40]
call zy_local_x2Fmain_0__base__rt_x2Dcopy
    add rsp, 32
    mov [rbp-120], rax
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-104]
    add rax, rcx
    mov [rbp-128], rax
    mov rax, [rbp-8]
    mov rcx, [rbp-128]
    add rax, rcx
    push rax
    mov rax, 95
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-136], rax
    mov rax, [rbp-128]
    mov rcx, 1
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    push rax
    mov rax, 95
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-144], rax
    sub rsp, 8
    sub rsp, 40
    mov rax, [rbp-128]
    mov rcx, 2
    add rax, rcx
    mov r8, rax
    mov rdi, [rbp-48]
    mov rsi, 0
    mov rdx, [rbp-56]
    mov rcx, [rbp-8]
call zy_local_x2Fmain_0__mangle__mg_x2Desc
    add rsp, 48
    mov [rbp-152], rax
    mov rax, [rbp-8]
    mov rcx, [rbp-152]
    add rax, rcx
    push rax
    mov rax, 95
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-160], rax
    mov rax, [rbp-152]
    mov rcx, 1
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    push rax
    mov rax, 95
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-168], rax
    sub rsp, 8
    sub rsp, 40
    mov rax, [rbp-152]
    mov rcx, 2
    add rax, rcx
    mov r8, rax
    mov rdi, [rbp-64]
    mov rsi, 0
    mov rdx, [rbp-72]
    mov rcx, [rbp-8]
call zy_local_x2Fmain_0__mangle__mg_x2Desc
    add rsp, 48
    mov [rbp-176], rax
    mov rax, [rbp-8]
    mov rcx, [rbp-176]
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-184], rax
    mov rax, [rbp-176]
    mov rbx, [rbp-280]
    mov r12, [rbp-272]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__mangle__mg_x2Demit:
    push rbp
    mov rbp, rsp
    sub rsp, 280
    mov [rbp-280], rbx
    mov [rbp-272], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    mov r10, [rbp+16]
    mov [rbp-56], r10
    mov r10, [rbp+24]
    mov [rbp-64], r10
    mov r10, [rbp+32]
    mov [rbp-72], r10
    mov r10, [rbp+40]
    mov [rbp-80], r10
    mov r10, [rbp+48]
    mov [rbp-88], r10
    sub rsp, 32
    mov rdi, [rbp-32]
    mov rsi, 0
    mov rdx, [rbp-40]
    mov rcx, 0
call zy_local_x2Fmain_0__mangle__mg_x2Desc_x2Dlen
    add rsp, 32
    mov rcx, rax
    mov rax, 3
    add rax, rcx
    push rax
    mov rax, 1
    mov rcx, [rbp-56]
    add rax, rcx
    mov rcx, 2
    add rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    sub rsp, 32
    mov rdi, [rbp-64]
    mov rsi, 0
    mov rdx, [rbp-72]
    mov rcx, 0
call zy_local_x2Fmain_0__mangle__mg_x2Desc_x2Dlen
    add rsp, 32
    mov rcx, 2
    add rax, rcx
    push rax
    sub rsp, 32
    mov rdi, [rbp-80]
    mov rsi, 0
    mov rdx, [rbp-88]
    mov rcx, 0
call zy_local_x2Fmain_0__mangle__mg_x2Desc_x2Dlen
    add rsp, 32
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    mov [rbp-96], rax
    mov rax, [rbp-96]
    mov rcx, 200
    cmp rax, rcx
    jg .L280
    sub rsp, 16
    mov rax, [rbp-96]
    mov rcx, 1
    add rax, rcx
    mov rsi, rax
    mov rdi, [rbp-8]
    mov r12, rsp
    and rsp, -16
call zyl_arena_alloc_zeroed
    mov rsp, r12
    add rsp, 16
    mov [rbp-104], rax
    mov rax, [rbp-104]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-64]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-72]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-80]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-88]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r10, [rsp+16]
    push r10
    mov r10, [rsp+32]
    push r10
    mov r9, [rsp+48]
    mov r8, [rsp+56]
    mov rcx, [rsp+64]
    mov rdx, [rsp+72]
    mov rsi, [rsp+80]
    mov rdi, [rsp+88]
call zy_local_x2Fmain_0__mangle__mg_x2Dwrite
    add rsp, 96
    mov [rbp-112], rax
    mov rax, [rbp-104]
    jmp .L281
.L280:
    sub rsp, 8
    sub rsp, 8
    mov rax, [rbp-96]
    mov rcx, 1
    add rax, rcx
    mov rdi, rax
    mov r12, rsp
    and rsp, -16
call malloc
    mov rsp, r12
    add rsp, 16
    mov [rbp-120], rax
    mov rax, [rbp-120]
    mov rcx, 0
    cmp rax, rcx
    jne .L282
    mov rax, 0
    jmp .L283
.L282:
    mov rax, [rbp-120]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-64]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-72]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-80]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-88]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r10, [rsp+16]
    push r10
    mov r10, [rsp+32]
    push r10
    mov r9, [rsp+48]
    mov r8, [rsp+56]
    mov rcx, [rsp+64]
    mov rdx, [rsp+72]
    mov rsi, [rsp+80]
    mov rdi, [rsp+88]
call zy_local_x2Fmain_0__mangle__mg_x2Dwrite
    add rsp, 96
    mov [rbp-128], rax
    sub rsp, 32
    mov rax, [rbp-120]
    mov rcx, 192
    add rax, rcx
    mov rdx, rax
    mov rdi, [rbp-16]
    mov rsi, [rbp-24]
    mov rcx, 8
call zy_local_x2Fmain_0__blake3__rt_x2Dblake3_x2Draw
    add rsp, 32
    test rax, rax
    je .L286
    mov rax, 0
    jmp .L287
.L286:
    mov rax, 1
.L287:
    test rax, rax
    je .L284
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-120]
    mov r12, rsp
    and rsp, -16
call free
    mov rsp, r12
    add rsp, 16
    mov [rbp-136], rax
    mov rax, 0
    jmp .L285
.L284:
    sub rsp, 16
    mov rdi, [rbp-8]
    mov rsi, 201
    mov r12, rsp
    and rsp, -16
call zyl_arena_alloc_zeroed
    mov rsp, r12
    add rsp, 16
    mov [rbp-144], rax
    sub rsp, 8
    sub rsp, 24
    mov rdi, [rbp-144]
    mov rsi, [rbp-120]
    mov rdx, 184
call zy_local_x2Fmain_0__base__rt_x2Dcopy
    add rsp, 32
    mov [rbp-152], rax
    mov rax, [rbp-144]
    mov rcx, 184
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-120]
    mov rcx, 192
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov rax, 8
    sub rsp, 8
    mov [rsp], rax
    mov rcx, [rsp+0]
    mov rdx, [rsp+8]
    mov rsi, [rsp+16]
    mov rdi, [rsp+24]
call zy_local_x2Fmain_0__blake3__rt_x2Dhex_x2Dbytes
    add rsp, 32
    mov [rbp-160], rax
    mov rax, [rbp-144]
    mov rcx, 200
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-168], rax
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-120]
    mov r12, rsp
    and rsp, -16
call free
    mov rsp, r12
    add rsp, 16
    mov [rbp-176], rax
    mov rax, [rbp-144]
.L285:
.L283:
.L281:
    mov rbx, [rbp-280]
    mov r12, [rbp-272]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mangle_key
zyl_mangle_key:
    push rbp
    mov rbp, rsp
    sub rsp, 184
    mov [rbp-184], rbx
    mov [rbp-176], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    mov rcx, 0
    cmp rax, rcx
    jne .L288
    mov rax, 0
    jmp .L289
.L288:
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-24]
call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    add rsp, 16
    mov [rbp-32], rax
    sub rsp, 32
    mov rdi, [rbp-24]
    mov rsi, [rbp-32]
    mov rdx, 64
    mov rcx, 0
call zy_local_x2Fmain_0__base__rt_x2Dfind_x2Dbyte
    add rsp, 32
    mov [rbp-40], rax
    mov rax, [rbp-40]
    mov rcx, 0
    cmp rax, rcx
    jge .L290
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    lea rax, [rip+.L292]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 1
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r10, [rsp+16]
    push r10
    mov r10, [rsp+32]
    push r10
    mov r10, [rsp+48]
    push r10
    mov r10, [rsp+64]
    push r10
    mov r9, [rsp+80]
    mov r8, [rsp+88]
    mov rcx, [rsp+96]
    mov rdx, [rsp+104]
    mov rsi, [rsp+112]
    mov rdi, [rsp+120]
call zy_local_x2Fmain_0__mangle__mg_x2Demit
    add rsp, 128
    jmp .L291
.L290:
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-24]
    add rax, rcx
    mov [rbp-48], rax
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-32]
    sub rax, rcx
    mov [rbp-56], rax
    sub rsp, 8
    sub rsp, 24
    mov rdi, [rbp-48]
    mov rsi, 0
    mov rdx, [rbp-56]
call zy_local_x2Fmain_0__mangle__mg_x2Dsep
    add rsp, 32
    mov [rbp-64], rax
    mov rax, [rbp-64]
    mov rcx, 0
    cmp rax, rcx
    jge .L293
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    lea rax, [rip+.L295]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 1
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r10, [rsp+16]
    push r10
    mov r10, [rsp+32]
    push r10
    mov r10, [rsp+48]
    push r10
    mov r10, [rsp+64]
    push r10
    mov r9, [rsp+80]
    mov r8, [rsp+88]
    mov rcx, [rsp+96]
    mov rdx, [rsp+104]
    mov rsi, [rsp+112]
    mov rdi, [rsp+120]
call zy_local_x2Fmain_0__mangle__mg_x2Demit
    add rsp, 128
    jmp .L294
.L293:
    mov rax, [rbp-64]
    mov rcx, 2
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-48]
    add rax, rcx
    mov [rbp-72], rax
    mov rax, [rbp-64]
    mov rcx, 2
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-56]
    sub rax, rcx
    mov [rbp-80], rax
    sub rsp, 8
    sub rsp, 24
    mov rdi, [rbp-72]
    mov rsi, 0
    mov rdx, [rbp-80]
call zy_local_x2Fmain_0__mangle__mg_x2Dsep
    add rsp, 32
    mov [rbp-88], rax
    mov rax, [rbp-88]
    mov rcx, 0
    cmp rax, rcx
    jge .L296
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-64]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-72]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-80]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r10, [rsp+16]
    push r10
    mov r10, [rsp+32]
    push r10
    mov r10, [rsp+48]
    push r10
    mov r10, [rsp+64]
    push r10
    mov r9, [rsp+80]
    mov r8, [rsp+88]
    mov rcx, [rsp+96]
    mov rdx, [rsp+104]
    mov rsi, [rsp+112]
    mov rdi, [rsp+120]
call zy_local_x2Fmain_0__mangle__mg_x2Demit
    add rsp, 128
    jmp .L297
.L296:
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-64]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-72]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-88]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-88]
    mov rcx, 2
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-72]
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-88]
    mov rcx, 2
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-80]
    sub rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r10, [rsp+16]
    push r10
    mov r10, [rsp+32]
    push r10
    mov r10, [rsp+48]
    push r10
    mov r10, [rsp+64]
    push r10
    mov r9, [rsp+80]
    mov r8, [rsp+88]
    mov rcx, [rsp+96]
    mov rdx, [rsp+104]
    mov rsi, [rsp+112]
    mov rdi, [rsp+120]
call zy_local_x2Fmain_0__mangle__mg_x2Demit
    add rsp, 128
.L297:
.L294:
.L291:
.L289:
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dzalloc:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L298_0:
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Doob:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rdx
.L299_0:
    lea rax, [rip+.L300]
    mov qword ptr [rbp-48], rax
    lea rax, [rip+.L301]
    mov r14, rax
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r15, rax
    lea rax, [rip+.L302]
    mov r13, rax
    mov rsi, 0
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov rsi, rax
    mov rdi, r13
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r15
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r14
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dmagic:
    push rbp
    mov rbp, rsp
.L303_0:
    mov rsi, 6510318674217419859
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dnot_x2Dwords:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L304_0:
    lea rax, [rip+.L305]
    mov rbx, rax
    lea rax, [rip+.L306]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L307_0:
    cmp rbx, 4096
    jl .L307_1
    mov rdi, rbx
    and rdi, 7
    cmp rdi, 0
    jne .L307_1
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, 6510318674217419859
    cmp rdi, r8
    jne .L307_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L307_1:
    lea rax, [rip+.L308]
    mov r12, rax
    lea rax, [rip+.L309]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dhdr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rsi
    mov r12, rdx
.L310_0:
    mov rsi, 24
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L310_1
    lea rax, [rip+.L311]
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    jmp .L310_2
.L310_1:
    mov rdi, 0
    mov rsi, rdi
.L310_2:
    mov rsi, 6510318674217419859
    mov rdx, r13
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 8
    mov rdx, rsi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 16
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_words_new
zyl_words_new:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L312_0:
    cmp rsi, 0
    jge .L312_1
    mov rdi, 0
    jmp .L312_2
.L312_1:
    mov rdi, rsi
.L312_2:
    mov r12, rdi
    mov rsi, 24
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov r13, rsi
    cmp r12, 0
    jle .L312_3
    mov rsi, r12
    jmp .L312_4
.L312_3:
    mov rdi, 1
    mov rsi, rdi
.L312_4:
    imul rsi, 8
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rbx, rsi
    cmp r13, 0
    jne .L312_7
    jmp .L312_8
.L312_7:
    cmp rbx, 0
    jne .L312_5
.L312_8:
    lea rax, [rip+.L313]
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    jmp .L312_6
.L312_5:
    mov rdi, 0
    mov rsi, rdi
.L312_6:
    mov rsi, 6510318674217419859
    mov rdx, r13
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 8
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 16
    mov rdx, rsi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_words_len
zyl_words_len:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L314_0:
    cmp rdi, 4096
    jl .L314_1
    mov rsi, rdi
    and rsi, 7
    cmp rsi, 0
    jne .L314_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r8, 6510318674217419859
    cmp rsi, r8
    jne .L314_1
    mov rsi, rdi
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L314_1:
    lea rax, [rip+.L315]
    mov rsi, rax
    lea rax, [rip+.L316]
    mov rbx, rax
    lea rax, [rip+.L317]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dfail:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov r8, rdx
.L318_0:
    cmp rdi, 4096
    jl .L318_1
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L318_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, 6510318674217419859
    cmp r9, r10
    jne .L318_1
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L318_1:
    lea rax, [rip+.L319]
    mov rbx, rax
    lea rax, [rip+.L320]
    mov rsi, rax
    mov rdi, r8
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_words_get
zyl_words_get:
    push rbp
    mov rbp, rsp
.L321_0:
    cmp rdi, 4096
    jl .L321_1
    mov r8, rdi
    and r8, 7
    cmp r8, 0
    jne .L321_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 6510318674217419859
    cmp r8, r9
    jne .L321_1
    cmp rsi, 0
    jl .L321_1
    mov r8, rdi
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp rsi, r8
    jge .L321_1
    mov r8, rdi
    add r8, 16
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, rsi
    imul r9, 8
    add r8, r9
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L321_1:
    lea rax, [rip+.L322]
    mov r8, rax
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dfail
.globl zyl_words_set
zyl_words_set:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L323_0:
    cmp rdi, 4096
    jl .L323_1
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L323_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, 6510318674217419859
    cmp r9, r10
    jne .L323_1
    cmp rsi, 0
    jl .L323_1
    mov r9, rdi
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp rsi, r9
    jge .L323_1
    mov r9, rdi
    add r9, 16
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, rsi
    imul r10, 8
    add r9, r10
    mov rdx, r9
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r9, rax
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L323_1:
    lea rax, [rip+.L324]
    mov r8, rax
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dfail
.globl zyl_words_view
zyl_words_view:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rdx
    mov r13, rcx
.L325_0:
    lea rax, [rip+.L326]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov r14, rsi
    mov rsi, r14
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp r12, 0
    jge .L325_5
    jmp .L325_6
.L325_5:
    cmp r13, 0
    jge .L325_3
.L325_6:
    jmp .L325_4
.L325_3:
    cmp r12, rsi
    jle .L325_7
    jmp .L325_8
.L325_7:
    mov rdi, rsi
    sub rdi, r12
    cmp r13, rdi
    jle .L325_1
.L325_8:
.L325_4:
    lea rax, [rip+.L327]
    mov rdi, rax
    mov r8, r12
    add r8, r13
    mov rdx, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    mov rsi, rax
    jmp .L325_2
.L325_1:
    mov rdi, 0
    mov rsi, rdi
.L325_2:
    mov rsi, r14
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    imul rdi, 8
    add rsi, rdi
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dhdr
zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dmagic:
    push rbp
    mov rbp, rsp
.L328_0:
    mov rsi, 6510318579778470233
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dnot_x2Darray:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L329_0:
    lea rax, [rip+.L330]
    mov rbx, rax
    lea rax, [rip+.L331]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L332_0:
    cmp rbx, 4096
    jl .L332_1
    mov rdi, rbx
    and rdi, 7
    cmp rdi, 0
    jne .L332_1
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, 6510318579778470233
    cmp rdi, r8
    jne .L332_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L332_1:
    lea rax, [rip+.L333]
    mov r12, rax
    lea rax, [rip+.L334]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_array_new
zyl_array_new:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L335_0:
    cmp rsi, 0
    jge .L335_1
    mov rdi, 0
    jmp .L335_2
.L335_1:
    mov rdi, rsi
.L335_2:
    mov r12, rdi
    mov rsi, 32
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov r13, rsi
    cmp r12, 0
    jle .L335_3
    mov rsi, r12
    jmp .L335_4
.L335_3:
    mov rdi, 1
    mov rsi, rdi
.L335_4:
    imul rsi, 8
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    mov rbx, rsi
    cmp r13, 0
    jne .L335_7
    jmp .L335_8
.L335_7:
    cmp rbx, 0
    jne .L335_5
.L335_8:
    lea rax, [rip+.L336]
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    jmp .L335_6
.L335_5:
    mov rdi, 0
    mov rsi, rdi
.L335_6:
    mov rsi, 6510318579778470233
    mov rdx, r13
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 8
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 24
    mov rdx, rsi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_array_cap
zyl_array_cap:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L337_0:
    cmp rdi, 4096
    jl .L337_1
    mov rsi, rdi
    and rsi, 7
    cmp rsi, 0
    jne .L337_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r8, 6510318579778470233
    cmp rsi, r8
    jne .L337_1
    mov rsi, rdi
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L337_1:
    lea rax, [rip+.L338]
    mov rsi, rax
    lea rax, [rip+.L339]
    mov rbx, rax
    lea rax, [rip+.L340]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.globl zyl_array_filled
zyl_array_filled:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L341_0:
    cmp rdi, 4096
    jl .L341_1
    mov rsi, rdi
    and rsi, 7
    cmp rsi, 0
    jne .L341_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r8, 6510318579778470233
    cmp rsi, r8
    jne .L341_1
    mov rsi, rdi
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L341_1:
    lea rax, [rip+.L342]
    mov rsi, rax
    lea rax, [rip+.L343]
    mov rbx, rax
    lea rax, [rip+.L344]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dget_x2Dfail:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L345_0:
    cmp rdi, 4096
    jl .L345_1
    mov r8, rdi
    and r8, 7
    cmp r8, 0
    jne .L345_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 6510318579778470233
    cmp r8, r9
    jne .L345_1
    lea rax, [rip+.L346]
    mov r8, rax
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L345_1:
    lea rax, [rip+.L347]
    mov rsi, rax
    lea rax, [rip+.L348]
    mov rbx, rax
    lea rax, [rip+.L349]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_array_get
zyl_array_get:
    push rbp
    mov rbp, rsp
.L350_0:
    cmp rdi, 4096
    jl .L350_1
    mov r8, rdi
    and r8, 7
    cmp r8, 0
    jne .L350_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 6510318579778470233
    cmp r8, r9
    jne .L350_1
    cmp rsi, 0
    jl .L350_1
    mov r8, rdi
    add r8, 16
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp rsi, r8
    jge .L350_1
    mov r8, rdi
    add r8, 24
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, rsi
    imul r9, 8
    add r8, r9
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L350_1:
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dget_x2Dfail
.globl zyl_array_copy
zyl_array_copy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rsi
    mov r12, rdx
.L351_0:
    lea rax, [rip+.L352]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov rsi, rax
    mov r13, rsi
    lea rax, [rip+.L353]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov rsi, rax
    mov rbx, rsi
    mov rsi, r13
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp r12, 0
    jge .L351_3
    jmp .L351_4
.L351_3:
    cmp r12, rsi
    jle .L351_1
.L351_4:
    lea rax, [rip+.L354]
    mov rdi, rax
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    mov rsi, rax
    jmp .L351_2
.L351_1:
    mov rdi, 0
    mov rsi, rdi
.L351_2:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rbx
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L351_9
    mov rdi, 0
    jmp .L351_10
.L351_9:
    mov r8, 1
    mov rdi, r8
.L351_10:
    cmp rdi, 0
    je .L351_7
    jmp .L351_8
.L351_7:
    cmp r12, rsi
    jle .L351_5
.L351_8:
    lea rax, [rip+.L355]
    mov rdi, rax
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    mov rsi, rax
    jmp .L351_6
.L351_5:
    mov rdi, 0
    mov rsi, rdi
.L351_6:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r13
    add rdi, 24
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, r12
    imul r8, 8
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_array_set
zyl_array_set:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rsi
    mov r12, rdx
.L356_0:
    lea rax, [rip+.L357]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov rsi, rax
    mov r13, rsi
    mov rsi, r13
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r14, rsi
    cmp rbx, 0
    jge .L356_5
    jmp .L356_6
.L356_5:
    cmp rbx, r14
    jle .L356_3
.L356_6:
    jmp .L356_4
.L356_3:
    mov rsi, r13
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rbx, rsi
    jl .L356_1
.L356_4:
    lea rax, [rip+.L358]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    mov rdx, r14
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    mov rsi, rax
    jmp .L356_2
.L356_1:
    mov rdi, 0
    mov rsi, rdi
.L356_2:
    mov rsi, r13
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rbx
    imul rdi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    cmp rbx, r14
    jne .L356_7
    mov rsi, r13
    add rsi, 16
    mov rdi, r14
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    jmp .L356_8
.L356_7:
    mov rdi, 0
    mov rsi, rdi
.L356_8:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_attrh_new
zyl_attrh_new:
    push rbp
    mov rbp, rsp
.L359_0:
    mov rsi, 1
    mov rdi, 24
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp calloc
zy_local_x2Fmain_0__tables__tb_x2Dprobe:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L360_0:
    mov r10, r8
    imul r10, 16
    add r10, rdi
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp rbx, 0
    jne .L360_2
    jmp .L360_3
.L360_2:
    cmp rbx, r9
    jne .L360_1
.L360_3:
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L360_1:
    mov r10, r8
    add r10, 1
    and r10, rsi
    mov r8, r10
    jmp .L360_0
zy_local_x2Fmain_0__tables__tb_x2Drehash:
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
.L361_0:
    mov rax, qword ptr [rbp-56]
    cmp rax, qword ptr [rbp-64]
    jl .L361_1
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
.L361_1:
    mov rsi, qword ptr [rbp-56]
    imul rsi, 16
    add rsi, qword ptr [rbp-48]
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L361_2
    mov rsi, 0
    mov r13, rsi
    jmp .L361_3
.L361_2:
    mov rsi, 30
    mov rax, r12
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    mov rdi, 17179869183
    and rsi, rdi
    xor rsi, r12
    mov rdi, -4658895280553007687
    imul rsi, rdi
    mov rdi, 27
    mov rax, rsi
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov r8, 137438953471
    and rdi, r8
    xor rsi, rdi
    mov rdi, -7723592293110705685
    imul rsi, rdi
    mov rdi, 31
    mov rax, rsi
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov r8, 8589934591
    and rdi, r8
    xor rsi, rdi
    and rsi, r15
    mov rdi, r14
    mov rdx, rsi
    mov rsi, r15
    mov rcx, r12
    call zy_local_x2Fmain_0__tables__tb_x2Dprobe
    mov rsi, rax
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    add rsi, 8
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov r13, rsi
.L361_3:
    mov rsi, qword ptr [rbp-56]
    add rsi, 1
    mov qword ptr [rbp-56], rsi
    jmp .L361_0
zy_local_x2Fmain_0__tables__tb_x2Dgrow:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L362_0:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jle .L362_1
    mov rsi, r12
    imul rsi, 8
    jmp .L362_2
.L362_1:
    mov rdi, 4096
    mov rsi, rdi
.L362_2:
    mov r13, rsi
    mov rsi, 16
    mov rdi, r13
    call calloc
    mov rsi, rax
    mov r14, rsi
    cmp r14, 0
    jne .L362_3
    mov rsi, r13
    imul rsi, 16
    lea rax, [rip+.L363]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_arena_oom
    mov rsi, rax
    jmp .L362_4
.L362_3:
    mov rdi, 0
    mov rsi, rdi
.L362_4:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, 0
    mov r8, r13
    sub r8, 1
    mov rdx, r12
    mov rcx, r14
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Drehash
    mov rsi, rax
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call free
    mov rsi, rax
    mov rdx, rbx
    mov rcx, r14
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dattr_x2Dset:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L364_0:
    cmp rbx, 0
    jne .L364_2
    jmp .L364_3
.L364_2:
    cmp r12, 0
    jne .L364_1
.L364_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L364_1:
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    imul rsi, 10
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    imul rdi, 7
    cmp rsi, rdi
    jl .L364_4
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dgrow
    mov rsi, rax
    jmp .L364_5
.L364_4:
    mov rdi, 0
    mov rsi, rdi
.L364_5:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    sub rsi, 1
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, 30
    mov rax, r12
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    mov r9, 17179869183
    and r8, r9
    xor r8, r12
    mov r9, -4658895280553007687
    imul r8, r9
    mov r9, 27
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, 137438953471
    and r9, r10
    xor r8, r9
    mov r9, -7723592293110705685
    imul r8, r9
    mov r9, 31
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, 8589934591
    and r9, r10
    xor r8, r9
    and r8, rsi
    mov rdx, r8
    mov rcx, r12
    call zy_local_x2Fmain_0__tables__tb_x2Dprobe
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L364_6
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rbx
    add rdi, 16
    mov r8, rbx
    add r8, 16
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    add r8, 1
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    jmp .L364_7
.L364_6:
    mov r8, 0
    mov rdi, r8
.L364_7:
    add rsi, 8
    mov rdx, rsi
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_attrh_set
zyl_attrh_set:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L365_0:
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dattr_x2Dset
zy_local_x2Fmain_0__tables__tb_x2Dget_x2Dloop:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L366_0:
    mov rbx, r8
    imul rbx, 16
    add rbx, rdi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov r12, rax
    cmp r12, r9
    jne .L366_1
    add rbx, 8
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L366_1:
    cmp r12, 0
    jne .L366_2
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L366_2:
    mov rbx, r8
    add rbx, 1
    and rbx, rsi
    mov r8, rbx
    jmp .L366_0
.globl zyl_attrh_get_or
zyl_attrh_get_or:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
.L367_0:
    cmp rdi, 0
    jne .L367_4
    jmp .L367_5
.L367_4:
    cmp rsi, 0
    jne .L367_2
.L367_5:
    jmp .L367_3
.L367_2:
    mov r9, rdi
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r9, 0
    jne .L367_1
.L367_3:
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L367_1:
    mov r9, rdi
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    sub r9, 1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r10, 30
    mov rax, rsi
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov rbx, 17179869183
    and r10, rbx
    xor r10, rsi
    mov rbx, -4658895280553007687
    imul r10, rbx
    mov rbx, 27
    mov rax, r10
    mov rcx, rbx
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    mov r12, 137438953471
    and rbx, r12
    xor r10, rbx
    mov rbx, -7723592293110705685
    imul r10, rbx
    mov rbx, 31
    mov rax, r10
    mov rcx, rbx
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    mov r12, 8589934591
    and rbx, r12
    xor r10, rbx
    and r10, r9
    mov rdx, r10
    mov rcx, rsi
    mov rsi, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dget_x2Dloop
.globl zyl_attrh_has
zyl_attrh_has:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L368_0:
    cmp rdi, 0
    jne .L368_6
    jmp .L368_7
.L368_6:
    cmp rsi, 0
    jne .L368_4
.L368_7:
    jmp .L368_5
.L368_4:
    mov r8, rdi
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp r8, 0
    jne .L368_2
.L368_5:
    mov r8, 0
    mov rbx, r8
    jmp .L368_3
.L368_2:
    mov r8, rdi
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    sub r8, 1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r9, 30
    mov rax, rsi
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, 17179869183
    and r9, r10
    xor r9, rsi
    mov r10, -4658895280553007687
    imul r9, r10
    mov r10, 27
    mov rax, r9
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov r12, 137438953471
    and r10, r12
    xor r9, r10
    mov r10, -7723592293110705685
    imul r9, r10
    mov r10, 31
    mov rax, r9
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov r12, 8589934591
    and r10, r12
    xor r9, r10
    and r9, r8
    mov rdx, r9
    mov rcx, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__tables__tb_x2Dprobe
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L368_8
    mov rdi, 0
    jmp .L368_9
.L368_8:
    mov rdi, rsi
.L368_9:
    mov rbx, rdi
.L368_3:
    cmp rbx, 0
    jne .L368_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L368_1:
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_attrh_copy
zyl_attrh_copy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L369_0:
    cmp rbx, 0
    jne .L369_5
    jmp .L369_6
.L369_5:
    cmp rsi, 0
    jne .L369_3
.L369_6:
    jmp .L369_4
.L369_3:
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L369_1
.L369_4:
    mov rdi, 0
    mov r13, rdi
    jmp .L369_2
.L369_1:
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    sub rdi, 1
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 30
    mov rax, rsi
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, 17179869183
    and r9, r10
    xor r9, rsi
    mov r10, -4658895280553007687
    imul r9, r10
    mov r10, 27
    mov rax, r9
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov r14, 137438953471
    and r10, r14
    xor r9, r10
    mov r10, -7723592293110705685
    imul r9, r10
    mov r10, 31
    mov rax, r9
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov r14, 8589934591
    and r10, r14
    xor r9, r10
    and r9, rdi
    mov rdx, r9
    mov rcx, rsi
    mov rsi, rdi
    mov rdi, r8
    call zy_local_x2Fmain_0__tables__tb_x2Dprobe
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jne .L369_7
    mov rdi, 0
    jmp .L369_8
.L369_7:
    mov rdi, rsi
.L369_8:
    mov r13, rdi
.L369_2:
    cmp r13, 0
    jne .L369_9
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L369_9:
    mov rsi, r13
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dattr_x2Dset
.globl zyl_attrh_clear
zyl_attrh_clear:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L370_0:
    cmp rbx, 0
    jne .L370_2
    jmp .L370_3
.L370_2:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L370_1
.L370_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L370_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, 0
    mov r8, rbx
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    imul r8, 16
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call memset
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ref_new
zyl_ref_new:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L371_0:
    mov rsi, 8
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L371_1
    mov rsi, 8
    lea rax, [rip+.L372]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_arena_oom
    mov rsi, rax
    jmp .L371_2
.L371_1:
    mov rdi, 0
    mov rsi, rdi
.L371_2:
    mov rdx, r12
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ref_get
zyl_ref_get:
    push rbp
    mov rbp, rsp
.L373_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ref_set
zyl_ref_set:
    push rbp
    mov rbp, rsp
.L374_0:
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_uf_id
zyl_uf_id:
    push rbp
    mov rbp, rsp
.L375_0:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_getenv_str
zyl_getenv_str:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L376_0:
    cmp rdi, 0
    jne .L376_1
    mov rsi, 0
    mov rbx, rsi
    jmp .L376_2
.L376_1:
    call getenv
    mov rsi, rax
    mov rbx, rsi
.L376_2:
    cmp rbx, 0
    jne .L376_3
    lea rax, [rip+.L377]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L376_3:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dmagic:
    push rbp
    mov rbp, rsp
.L378_0:
    mov rsi, 6510318656819643953
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_strbuf_new
zyl_strbuf_new:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L379_0:
    cmp rsi, 0
    jle .L379_1
    jmp .L379_2
.L379_1:
    mov r8, 1
    mov rsi, r8
.L379_2:
    mov rbx, rsi
    mov rsi, rbx
    add rsi, 24
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    cmp rsi, 0
    jne .L379_3
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L379_3:
    mov rdi, 6510318656819643953
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 8
    mov r8, 0
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 16
    mov rdx, rdi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    add rsi, 24
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_strbuf_str
zyl_strbuf_str:
    push rbp
    mov rbp, rsp
.L380_0:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Duhex:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L381_0:
    lea rax, [rip+.L382]
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
    mov rsi, 4
    mov rax, rbx
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    mov rdi, 1152921504606846975
    and rsi, rdi
    mov r14, rsi
    cmp r14, 0
    jne .L381_1
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
.L381_1:
    mov rdi, r13
    mov rsi, r12
    call zyl_cstr_concat
    mov rsi, rax
    mov rbx, r14
    mov r12, rsi
    jmp .L381_0
zy_local_x2Fmain_0__tables__tb_x2Dbad:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L383_0:
    cmp rdi, 4096
    jge .L383_1
    lea rax, [rip+.L384]
    mov rbx, rax
    lea rax, [rip+.L385]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Duhex
    mov rsi, rax
    lea rax, [rip+.L386]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
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
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L383_1:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dappend:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L387_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r14, rsi
    mov rsi, rbx
    sub rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r15, rsi
    mov rsi, rbx
    sub rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp r13, 0
    jle .L387_1
    cmp r13, rsi
    jge .L387_1
    mov rdi, r13
    jmp .L387_2
.L387_1:
    mov rdi, rsi
.L387_2:
    mov rsi, r15
    add rsi, r14
    add rsi, 1
    cmp rsi, rdi
    jle .L387_3
    cmp r13, 0
    jle .L387_5
    lea rax, [rip+.L388]
    mov rsi, rax
    jmp .L387_6
.L387_5:
    lea rax, [rip+.L389]
    mov rdi, rax
    mov rsi, rdi
.L387_6:
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    jmp .L387_4
.L387_3:
    mov rdi, 0
    mov rsi, rdi
.L387_4:
    mov rsi, rbx
    add rsi, r15
    mov rdi, rsi
    mov rsi, r12
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, r15
    add rsi, r14
    add rsi, rbx
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    sub rsi, 16
    mov rdi, r15
    add rdi, r14
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
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
zy_local_x2Fmain_0__tables__tb_x2Dappend:
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
.L390_0:
    cmp rbx, 0
    jne .L390_2
    jmp .L390_3
.L390_2:
    cmp r12, 0
    jne .L390_1
.L390_3:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L390_1:
    cmp rbx, 4096
    jl .L390_4
    cmp r12, 4096
    jl .L390_4
    cmp rbx, 4120
    jl .L390_5
    mov rdi, rbx
    and rdi, 7
    cmp rdi, 0
    jne .L390_5
    mov rdi, rbx
    sub rdi, 24
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, 6510318656819643953
    cmp rdi, r8
    jne .L390_5
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dappend
.L390_5:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_str_append_scan
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L390_4:
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dbad
    mov rsi, rax
    cmp rsi, 0
    je .L390_6
    mov rsi, 1
    mov r13, rsi
    jmp .L390_7
.L390_6:
    mov rdi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Dbad
    mov rsi, rax
    mov r13, rsi
.L390_7:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_str_append
zyl_str_append:
    push rbp
    mov rbp, rsp
.L391_0:
    mov r8, 0
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dappend
.globl zyl_str_append_capped
zyl_str_append_capped:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L392_0:
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dappend
zy_local_x2Fmain_0__bytes__bb_x2Dmagic_x2Dbuf:
    push rbp
    mov rbp, rsp
.L393_0:
    mov rsi, 6510318584122966017
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dmagic_x2Dslice:
    push rbp
    mov rbp, rsp
.L394_0:
    mov rsi, 6510318584122966018
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dmax_x2Dcap:
    push rbp
    mov rbp, rsp
.L395_0:
    mov rsi, 1099511627776
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_load_byte
zyl_load_byte:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rdi, rdx
.L396_0:
    cmp rdi, 4096
    jge .L396_3
    jmp .L396_4
.L396_3:
    mov r8, rdi
    and r8, 7
    cmp r8, 0
    jne .L396_5
    mov r8, 0
    jmp .L396_6
.L396_5:
    mov r9, 1
    mov r8, r9
.L396_6:
    cmp r8, 0
    je .L396_1
.L396_4:
    mov r8, 0
    jmp .L396_2
.L396_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, 6510318584122966017
    cmp r9, r10
    jne .L396_7
    mov r10, rdi
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    jmp .L396_8
.L396_7:
    mov rbx, 6510318584122966018
    cmp r9, rbx
    jne .L396_9
    mov r9, rdi
    add r9, 16
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    jmp .L396_10
.L396_9:
    mov rbx, -1
    mov r9, rbx
.L396_10:
    mov r10, r9
.L396_8:
    cmp r10, 0
    jl .L396_11
    cmp rsi, 0
    jge .L396_15
    jmp .L396_16
.L396_15:
    cmp r10, 0
    jge .L396_17
    jmp .L396_18
.L396_17:
    mov r9, 1
    cmp r9, r10
    jle .L396_13
.L396_18:
.L396_16:
    mov r9, 0
    jmp .L396_14
.L396_13:
    sub r10, 1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
    mov r9, r10
.L396_14:
    cmp r9, 0
    je .L396_11
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rsi, rdi
    jmp .L396_12
.L396_11:
    mov rdi, 0
    mov rsi, rdi
.L396_12:
    mov r8, rsi
.L396_2:
    cmp r8, 0
    jne .L396_19
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L396_19:
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_load_byte_signed
zyl_load_byte_signed:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rdi, rdx
.L397_0:
    cmp rdi, 4096
    jge .L397_3
    jmp .L397_4
.L397_3:
    mov r8, rdi
    and r8, 7
    cmp r8, 0
    jne .L397_5
    mov r8, 0
    jmp .L397_6
.L397_5:
    mov r9, 1
    mov r8, r9
.L397_6:
    cmp r8, 0
    je .L397_1
.L397_4:
    mov r8, 0
    jmp .L397_2
.L397_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, 6510318584122966017
    cmp r9, r10
    jne .L397_7
    mov r10, rdi
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    jmp .L397_8
.L397_7:
    mov rbx, 6510318584122966018
    cmp r9, rbx
    jne .L397_9
    mov r9, rdi
    add r9, 16
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    jmp .L397_10
.L397_9:
    mov rbx, -1
    mov r9, rbx
.L397_10:
    mov r10, r9
.L397_8:
    cmp r10, 0
    jl .L397_11
    cmp rsi, 0
    jge .L397_15
    jmp .L397_16
.L397_15:
    cmp r10, 0
    jge .L397_17
    jmp .L397_18
.L397_17:
    mov r9, 1
    cmp r9, r10
    jle .L397_13
.L397_18:
.L397_16:
    mov r9, 0
    jmp .L397_14
.L397_13:
    sub r10, 1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
    mov r9, r10
.L397_14:
    cmp r9, 0
    je .L397_11
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rsi, rdi
    jmp .L397_12
.L397_11:
    mov rdi, 0
    mov rsi, rdi
.L397_12:
    mov r8, rsi
.L397_2:
    cmp r8, 0
    jne .L397_19
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L397_19:
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 127
    jle .L397_20
    mov rdi, rsi
    sub rdi, 256
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L397_20:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_store_byte
zyl_store_byte:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rdi, rdx
    mov r8, rcx
.L398_0:
    cmp rdi, 4096
    jge .L398_3
    jmp .L398_4
.L398_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L398_5
    mov r9, 0
    jmp .L398_6
.L398_5:
    mov r10, 1
    mov r9, r10
.L398_6:
    cmp r9, 0
    je .L398_1
.L398_4:
    mov r9, 0
    jmp .L398_2
.L398_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966017
    cmp r10, rbx
    jne .L398_7
    mov rbx, rdi
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    jmp .L398_8
.L398_7:
    mov r12, 6510318584122966018
    cmp r10, r12
    jne .L398_9
    mov r10, rdi
    add r10, 16
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    jmp .L398_10
.L398_9:
    mov r12, -1
    mov r10, r12
.L398_10:
    mov rbx, r10
.L398_8:
    cmp rbx, 0
    jl .L398_11
    cmp rsi, 0
    jge .L398_15
    jmp .L398_16
.L398_15:
    cmp rbx, 0
    jge .L398_17
    jmp .L398_18
.L398_17:
    mov r10, 1
    cmp r10, rbx
    jle .L398_13
.L398_18:
.L398_16:
    mov r10, 0
    jmp .L398_14
.L398_13:
    sub rbx, 1
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
    mov r10, rbx
.L398_14:
    cmp r10, 0
    je .L398_11
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rsi, rdi
    jmp .L398_12
.L398_11:
    mov rdi, 0
    mov rsi, rdi
.L398_12:
    mov r9, rsi
.L398_2:
    cmp r9, 0
    jne .L398_19
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L398_19:
    mov rdx, r9
    mov rcx, r8
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_store_byte_signed
zyl_store_byte_signed:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rdi, rdx
    mov r8, rcx
.L399_0:
    cmp rdi, 4096
    jge .L399_3
    jmp .L399_4
.L399_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L399_5
    mov r9, 0
    jmp .L399_6
.L399_5:
    mov r10, 1
    mov r9, r10
.L399_6:
    cmp r9, 0
    je .L399_1
.L399_4:
    mov r9, 0
    jmp .L399_2
.L399_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966017
    cmp r10, rbx
    jne .L399_7
    mov rbx, rdi
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    jmp .L399_8
.L399_7:
    mov r12, 6510318584122966018
    cmp r10, r12
    jne .L399_9
    mov r10, rdi
    add r10, 16
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    jmp .L399_10
.L399_9:
    mov r12, -1
    mov r10, r12
.L399_10:
    mov rbx, r10
.L399_8:
    cmp rbx, 0
    jl .L399_11
    cmp rsi, 0
    jge .L399_15
    jmp .L399_16
.L399_15:
    cmp rbx, 0
    jge .L399_17
    jmp .L399_18
.L399_17:
    mov r10, 1
    cmp r10, rbx
    jle .L399_13
.L399_18:
.L399_16:
    mov r10, 0
    jmp .L399_14
.L399_13:
    sub rbx, 1
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
    mov r10, rbx
.L399_14:
    cmp r10, 0
    je .L399_11
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rsi, rdi
    jmp .L399_12
.L399_11:
    mov rdi, 0
    mov rsi, rdi
.L399_12:
    mov r9, rsi
.L399_2:
    cmp r9, 0
    jne .L399_19
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L399_19:
    mov rdx, r9
    mov rcx, r8
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_load_n
zyl_load_n:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L400_0:
    cmp rdi, 2
    jne .L400_4
    jmp .L400_5
.L400_4:
    cmp rdi, 4
    jne .L400_6
    jmp .L400_7
.L400_6:
    cmp rdi, 8
    jne .L400_2
.L400_7:
.L400_5:
    mov r10, 0
    jmp .L400_3
.L400_2:
    mov rbx, 1
    mov r10, rbx
.L400_3:
    cmp r10, 0
    je .L400_1
    mov r10, 0
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L400_1:
    cmp r9, 4096
    jge .L400_10
    jmp .L400_11
.L400_10:
    mov r10, r9
    and r10, 7
    cmp r10, 0
    jne .L400_12
    mov r10, 0
    jmp .L400_13
.L400_12:
    mov rbx, 1
    mov r10, rbx
.L400_13:
    cmp r10, 0
    je .L400_8
.L400_11:
    mov r10, 0
    jmp .L400_9
.L400_8:
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov rbx, rax
    mov r12, 6510318584122966017
    cmp rbx, r12
    jne .L400_14
    mov r12, r9
    add r12, 24
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov r12, rax
    jmp .L400_15
.L400_14:
    mov r13, 6510318584122966018
    cmp rbx, r13
    jne .L400_16
    mov rbx, r9
    add rbx, 16
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    jmp .L400_17
.L400_16:
    mov r13, -1
    mov rbx, r13
.L400_17:
    mov r12, rbx
.L400_15:
    cmp r12, 0
    jl .L400_18
    cmp r8, 0
    jge .L400_22
    jmp .L400_23
.L400_22:
    cmp rdi, 0
    jge .L400_24
    jmp .L400_25
.L400_24:
    cmp r12, 0
    jge .L400_26
    jmp .L400_27
.L400_26:
    cmp rdi, r12
    jle .L400_20
.L400_27:
.L400_25:
.L400_23:
    mov rbx, 0
    jmp .L400_21
.L400_20:
    sub r12, rdi
    mov rax, r8
    mov rcx, r12
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r12, rax
    mov rbx, r12
.L400_21:
    cmp rbx, 0
    je .L400_18
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    add r8, r9
    jmp .L400_19
.L400_18:
    mov r9, 0
    mov r8, r9
.L400_19:
    mov r10, r8
.L400_9:
    cmp r10, 0
    jne .L400_28
    mov r8, 0
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L400_28:
    cmp rdi, 2
    jne .L400_29
    mov rdx, r10
    movzx eax, word ptr [rdx]
    mov r8, rax
    jmp .L400_30
.L400_29:
    cmp rdi, 4
    jne .L400_31
    mov rdx, r10
    mov eax, dword ptr [rdx]
    mov r9, rax
    jmp .L400_32
.L400_31:
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov r9, r10
.L400_32:
    mov r8, r9
.L400_30:
    cmp rsi, 0
    jne .L400_33
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L400_33:
    mov rsi, 8
    mov rax, r8
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    mov r9, 71777214294589695
    and rsi, r9
    mov r9, 71777214294589695
    and r8, r9
    mov r9, 8
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    or rsi, r8
    mov r8, 16
    mov rax, rsi
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    mov r9, 281470681808895
    and r8, r9
    mov r9, 281470681808895
    and rsi, r9
    mov r9, 16
    mov rax, rsi
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    or rsi, r8
    mov r8, 32
    mov rax, rsi
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    mov r9, 4294967295
    and r8, r9
    mov r9, 32
    mov rax, rsi
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    or rsi, r8
    cmp rdi, 8
    jne .L400_34
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L400_34:
    cmp rdi, 4
    jne .L400_35
    mov rdi, 32
    mov rax, rsi
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov r8, 4294967295
    and rdi, r8
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L400_35:
    mov rdi, 48
    mov rax, rsi
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    and rsi, 65535
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_load_n_signed
zyl_load_n_signed:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
    mov rdi, rdx
    mov r8, rcx
.L401_0:
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zyl_load_n
    mov rsi, rax
    cmp rbx, 8
    jl .L401_2
    jmp .L401_3
.L401_2:
    cmp rbx, 2
    jne .L401_6
    jmp .L401_7
.L401_6:
    cmp rbx, 4
    jne .L401_8
    jmp .L401_9
.L401_8:
    cmp rbx, 8
    jne .L401_4
.L401_9:
.L401_7:
    mov rdi, 0
    jmp .L401_5
.L401_4:
    mov r8, 1
    mov rdi, r8
.L401_5:
    cmp rdi, 0
    je .L401_1
.L401_3:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L401_1:
    mov rdi, 1
    mov r8, rbx
    imul r8, 8
    sub r8, 1
    mov rax, rdi
    mov rcx, r8
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    xor rsi, rdi
    sub rsi, rdi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_store_n
zyl_store_n:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L402_0:
    cmp rdi, 2
    jne .L402_4
    jmp .L402_5
.L402_4:
    cmp rdi, 4
    jne .L402_6
    jmp .L402_7
.L402_6:
    cmp rdi, 8
    jne .L402_2
.L402_7:
.L402_5:
    mov rbx, 0
    jmp .L402_3
.L402_2:
    mov r12, 1
    mov rbx, r12
.L402_3:
    cmp rbx, 0
    je .L402_1
    mov rbx, 0
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L402_1:
    cmp r9, 4096
    jge .L402_10
    jmp .L402_11
.L402_10:
    mov rbx, r9
    and rbx, 7
    cmp rbx, 0
    jne .L402_12
    mov rbx, 0
    jmp .L402_13
.L402_12:
    mov r12, 1
    mov rbx, r12
.L402_13:
    cmp rbx, 0
    je .L402_8
.L402_11:
    mov rbx, 0
    jmp .L402_9
.L402_8:
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r12, rax
    mov r13, 6510318584122966017
    cmp r12, r13
    jne .L402_14
    mov r13, r9
    add r13, 24
    mov rdx, r13
    mov rax, qword ptr [rdx]
    mov r13, rax
    jmp .L402_15
.L402_14:
    mov r14, 6510318584122966018
    cmp r12, r14
    jne .L402_16
    mov r12, r9
    add r12, 16
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov r12, rax
    jmp .L402_17
.L402_16:
    mov r14, -1
    mov r12, r14
.L402_17:
    mov r13, r12
.L402_15:
    cmp r13, 0
    jl .L402_18
    cmp r8, 0
    jge .L402_22
    jmp .L402_23
.L402_22:
    cmp rdi, 0
    jge .L402_24
    jmp .L402_25
.L402_24:
    cmp r13, 0
    jge .L402_26
    jmp .L402_27
.L402_26:
    cmp rdi, r13
    jle .L402_20
.L402_27:
.L402_25:
.L402_23:
    mov r12, 0
    jmp .L402_21
.L402_20:
    sub r13, rdi
    mov rax, r8
    mov rcx, r13
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r13, rax
    mov r12, r13
.L402_21:
    cmp r12, 0
    je .L402_18
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    add r8, r9
    jmp .L402_19
.L402_18:
    mov r9, 0
    mov r8, r9
.L402_19:
    mov rbx, r8
.L402_9:
    cmp rbx, 0
    jne .L402_28
    mov r8, 0
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L402_28:
    cmp rsi, 0
    jne .L402_29
    mov rsi, r10
    jmp .L402_30
.L402_29:
    mov r8, 8
    mov rax, r10
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    mov r9, 71777214294589695
    and r8, r9
    mov r9, 71777214294589695
    and r9, r10
    mov r10, 8
    mov rax, r9
    mov rcx, r10
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    or r8, r9
    mov r9, 16
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, 281470681808895
    and r9, r10
    mov r10, 281470681808895
    and r8, r10
    mov r10, 16
    mov rax, r8
    mov rcx, r10
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    or r8, r9
    mov r9, 32
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, 4294967295
    and r9, r10
    mov r10, 32
    mov rax, r8
    mov rcx, r10
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    or r8, r9
    cmp rdi, 8
    jne .L402_31
    mov r9, r8
    jmp .L402_32
.L402_31:
    cmp rdi, 4
    jne .L402_33
    mov r10, 32
    mov rax, r8
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov r12, 4294967295
    and r10, r12
    jmp .L402_34
.L402_33:
    mov r12, 48
    mov rax, r8
    mov rcx, r12
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r8, rax
    and r8, 65535
    mov r10, r8
.L402_34:
    mov r9, r10
.L402_32:
    mov rsi, r9
.L402_30:
    cmp rdi, 2
    jne .L402_35
    mov rdx, rbx
    mov rcx, rsi
    mov word ptr [rdx], cx
    mov rax, rcx
    mov r8, rax
    jmp .L402_36
.L402_35:
    cmp rdi, 4
    jne .L402_37
    mov rdx, rbx
    mov rcx, rsi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rdi, rax
    jmp .L402_38
.L402_37:
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rdi, rsi
.L402_38:
    mov r8, rdi
.L402_36:
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L403_0:
    mov rsi, 24
    mov rdi, rsi
    call malloc
    mov rsi, rax
    cmp rsi, 0
    jne .L403_1
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L403_1:
    mov rdi, 6510318584122966018
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 8
    mov rdx, rdi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rsi
    add rdi, 16
    mov rdx, rdi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_byte_slice
zyl_byte_slice:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L404_0:
    cmp rdi, 4096
    jge .L404_3
    jmp .L404_4
.L404_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L404_5
    mov r9, 0
    jmp .L404_6
.L404_5:
    mov r10, 1
    mov r9, r10
.L404_6:
    cmp r9, 0
    je .L404_1
.L404_4:
    mov r9, 0
    jmp .L404_2
.L404_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966017
    cmp r10, rbx
    jne .L404_7
    jmp .L404_8
.L404_7:
    mov r10, 0
    mov rdi, r10
.L404_8:
    mov r9, rdi
.L404_2:
    cmp r9, 0
    jne .L404_10
    jmp .L404_11
.L404_10:
    cmp rsi, 0
    jge .L404_16
    jmp .L404_17
.L404_16:
    cmp r8, 0
    jge .L404_18
    jmp .L404_19
.L404_18:
    mov rdi, r9
    add rdi, 24
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jge .L404_20
    jmp .L404_21
.L404_20:
    mov rdi, r9
    add rdi, 24
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp r8, rdi
    jle .L404_14
.L404_21:
.L404_19:
.L404_17:
    mov rdi, 0
    jmp .L404_15
.L404_14:
    mov r10, r9
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    sub r10, r8
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
    mov rdi, r10
.L404_15:
    cmp rdi, 0
    je .L404_12
    mov rdi, 0
    jmp .L404_13
.L404_12:
    mov r10, 1
    mov rdi, r10
.L404_13:
    cmp rdi, 0
    je .L404_9
.L404_11:
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L404_9:
    mov rdi, r9
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rsi, rdi
    mov rdi, rsi
    mov rsi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice
.globl zyl_byte_slice_sub
zyl_byte_slice_sub:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L405_0:
    cmp rdi, 4096
    jge .L405_3
    jmp .L405_4
.L405_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L405_5
    mov r9, 0
    jmp .L405_6
.L405_5:
    mov r10, 1
    mov r9, r10
.L405_6:
    cmp r9, 0
    je .L405_1
.L405_4:
    mov r9, 0
    jmp .L405_2
.L405_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966018
    cmp r10, rbx
    jne .L405_7
    jmp .L405_8
.L405_7:
    mov r10, 0
    mov rdi, r10
.L405_8:
    mov r9, rdi
.L405_2:
    cmp r9, 0
    jne .L405_10
    jmp .L405_11
.L405_10:
    cmp rsi, 0
    jge .L405_16
    jmp .L405_17
.L405_16:
    cmp r8, 0
    jge .L405_18
    jmp .L405_19
.L405_18:
    mov rdi, r9
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jge .L405_20
    jmp .L405_21
.L405_20:
    mov rdi, r9
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp r8, rdi
    jle .L405_14
.L405_21:
.L405_19:
.L405_17:
    mov rdi, 0
    jmp .L405_15
.L405_14:
    mov r10, r9
    add r10, 16
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    sub r10, r8
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
    mov rdi, r10
.L405_15:
    cmp rdi, 0
    je .L405_12
    mov rdi, 0
    jmp .L405_13
.L405_12:
    mov r10, 1
    mov rdi, r10
.L405_13:
    cmp rdi, 0
    je .L405_9
.L405_11:
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L405_9:
    mov rdi, r9
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rsi, rdi
    mov rdi, rsi
    mov rsi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice
zy_local_x2Fmain_0__bytes__bb_x2Dinit:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L406_0:
    mov r9, 6510318584122966017
    mov rdx, rdi
    mov rcx, r9
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r9, rax
    mov r9, rdi
    add r9, 8
    mov rdx, r9
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 16
    mov r9, 0
    mov rdx, rsi
    mov rcx, r9
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 24
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok:
    push rbp
    mov rbp, rsp
.L407_0:
    cmp rdi, 0
    jl .L407_1
    mov rsi, 1099511627776
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L407_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_new
zyl_bytebuf_new:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rsi
.L408_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L408_2
    mov rsi, 0
    jmp .L408_3
.L408_2:
    mov rdi, 1
    mov rsi, rdi
.L408_3:
    cmp rsi, 0
    je .L408_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L408_1:
    mov rsi, 32
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L408_4
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L408_4:
    cmp rbx, 0
    jle .L408_5
    mov rsi, rbx
    jmp .L408_6
.L408_5:
    mov rdi, 1
    mov rsi, rdi
.L408_6:
    mov r13, rsi
    mov rdi, r13
    call malloc
    mov rsi, rax
    mov r14, rsi
    cmp r14, 0
    jne .L408_7
    mov rdi, r12
    call free
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
.L408_7:
    mov rsi, 0
    mov rdi, r14
    mov rdx, r13
    call memset
    mov rsi, rax
    mov rdi, r12
    mov rsi, r14
    mov rdx, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dinit
.globl zyl_bytebuf_new_r
zyl_bytebuf_new_r:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rsi
.L409_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L409_2
    mov rsi, 0
    jmp .L409_3
.L409_2:
    mov rdi, 1
    mov rsi, rdi
.L409_3:
    cmp rsi, 0
    je .L409_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L409_1:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov r12, rsi
    mov rsi, 32
    mov rdi, rsi
    mov rsi, r12
    call zyl_ralloc
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L409_4
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L409_4:
    cmp rbx, 0
    jle .L409_5
    mov rsi, rbx
    jmp .L409_6
.L409_5:
    mov rdi, 1
    mov rsi, rdi
.L409_6:
    mov r14, rsi
    mov rdi, r14
    mov rsi, r12
    call zyl_ralloc
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L409_7
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L409_7:
    mov rsi, 0
    mov rdi, r12
    mov rdx, r14
    call memset
    mov rsi, rax
    mov rdi, r13
    mov rsi, r12
    mov rdx, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dinit
.globl zyl_bytebuf_append
zyl_bytebuf_append:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L410_0:
    cmp rdi, 4096
    jge .L410_3
    jmp .L410_4
.L410_3:
    mov r8, rdi
    and r8, 7
    cmp r8, 0
    jne .L410_5
    mov r8, 0
    jmp .L410_6
.L410_5:
    mov r9, 1
    mov r8, r9
.L410_6:
    cmp r8, 0
    je .L410_1
.L410_4:
    mov r8, 0
    jmp .L410_2
.L410_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, 6510318584122966017
    cmp r9, r10
    jne .L410_7
    jmp .L410_8
.L410_7:
    mov r9, 0
    mov rdi, r9
.L410_8:
    mov r8, rdi
.L410_2:
    mov rbx, r8
    cmp rsi, 4096
    jge .L410_11
    jmp .L410_12
.L410_11:
    mov rdi, rsi
    and rdi, 7
    cmp rdi, 0
    jne .L410_13
    mov rdi, 0
    jmp .L410_14
.L410_13:
    mov r8, 1
    mov rdi, r8
.L410_14:
    cmp rdi, 0
    je .L410_9
.L410_12:
    mov rdi, 0
    jmp .L410_10
.L410_9:
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 6510318584122966018
    cmp r8, r9
    jne .L410_15
    jmp .L410_16
.L410_15:
    mov r8, 0
    mov rsi, r8
.L410_16:
    mov rdi, rsi
.L410_10:
    cmp rbx, 0
    jne .L410_18
    jmp .L410_19
.L410_18:
    cmp rdi, 0
    jne .L410_17
.L410_19:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L410_17:
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rsi, rdi
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    cmp r12, 0
    jge .L410_25
    jmp .L410_26
.L410_25:
    cmp r13, 0
    jge .L410_27
    jmp .L410_28
.L410_27:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jge .L410_29
    jmp .L410_30
.L410_29:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp r13, rsi
    jle .L410_23
.L410_30:
.L410_28:
.L410_26:
    mov rsi, 0
    jmp .L410_24
.L410_23:
    mov r8, rbx
    add r8, 24
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    sub r8, r13
    mov rax, r12
    mov rcx, r8
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r8, rax
    mov rsi, r8
.L410_24:
    cmp rsi, 0
    je .L410_21
    mov rsi, 0
    jmp .L410_22
.L410_21:
    mov r8, 1
    mov rsi, r8
.L410_22:
    cmp rsi, 0
    je .L410_20
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L410_20:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    add rsi, r12
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, r13
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call memmove
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdi, r12
    add rdi, r13
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_len
zyl_bytebuf_len:
    push rbp
    mov rbp, rsp
.L411_0:
    cmp rdi, 4096
    jge .L411_3
    jmp .L411_4
.L411_3:
    mov rsi, rdi
    and rsi, 7
    cmp rsi, 0
    jne .L411_5
    mov rsi, 0
    jmp .L411_6
.L411_5:
    mov r8, 1
    mov rsi, r8
.L411_6:
    cmp rsi, 0
    je .L411_1
.L411_4:
    mov rsi, 0
    jmp .L411_2
.L411_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 6510318584122966017
    cmp r8, r9
    jne .L411_7
    jmp .L411_8
.L411_7:
    mov r8, 0
    mov rdi, r8
.L411_8:
    mov rsi, rdi
.L411_2:
    cmp rsi, 0
    jne .L411_9
    mov rdi, 0
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L411_9:
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_cap
zyl_bytebuf_cap:
    push rbp
    mov rbp, rsp
.L412_0:
    cmp rdi, 4096
    jge .L412_3
    jmp .L412_4
.L412_3:
    mov rsi, rdi
    and rsi, 7
    cmp rsi, 0
    jne .L412_5
    mov rsi, 0
    jmp .L412_6
.L412_5:
    mov r8, 1
    mov rsi, r8
.L412_6:
    cmp rsi, 0
    je .L412_1
.L412_4:
    mov rsi, 0
    jmp .L412_2
.L412_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 6510318584122966017
    cmp r8, r9
    jne .L412_7
    jmp .L412_8
.L412_7:
    mov r8, 0
    mov rdi, r8
.L412_8:
    mov rsi, rdi
.L412_2:
    cmp rsi, 0
    jne .L412_9
    mov rdi, 0
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L412_9:
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_ptr
zyl_bytebuf_ptr:
    push rbp
    mov rbp, rsp
.L413_0:
    cmp rdi, 4096
    jge .L413_3
    jmp .L413_4
.L413_3:
    mov rsi, rdi
    and rsi, 7
    cmp rsi, 0
    jne .L413_5
    mov rsi, 0
    jmp .L413_6
.L413_5:
    mov r8, 1
    mov rsi, r8
.L413_6:
    cmp rsi, 0
    je .L413_1
.L413_4:
    mov rsi, 0
    jmp .L413_2
.L413_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 6510318584122966017
    cmp r8, r9
    jne .L413_7
    jmp .L413_8
.L413_7:
    mov r8, 0
    mov rdi, r8
.L413_8:
    mov rsi, rdi
.L413_2:
    cmp rsi, 0
    jne .L413_9
    mov rdi, 0
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L413_9:
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_align_check
zyl_align_check:
    push rbp
    mov rbp, rsp
.L414_0:
    cmp rsi, 0
    jg .L414_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L414_1:
    mov rax, rdi
    mov rcx, rsi
    cqo
    idiv rcx
    mov rax, rdx
    mov rsi, rax
    cmp rsi, 0
    jne .L414_2
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L414_2:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_atomic_load
zyl_atomic_load:
    push rbp
    mov rbp, rsp
.L415_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_atomic_store
zyl_atomic_store:
    push rbp
    mov rbp, rsp
.L416_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rdi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_atomic_fetch_add
zyl_atomic_fetch_add:
    push rbp
    mov rbp, rsp
.L417_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_atomic_add
zyl_atomic_add:
    push rbp
    mov rbp, rsp
.L418_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rdi, rax
    add rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_atomic_sub
zyl_atomic_sub:
    push rbp
    mov rbp, rsp
.L419_0:
    mov r8, 0
    sub r8, rsi
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rdi, rax
    mov rax, rdi
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_atomic_cas
zyl_atomic_cas:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L420_0:
    mov rdx, rdi
    mov rcx, rsi
    mov r11, r8
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    mov rdi, rax
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L421_0:
    cmp r9, 0
    je .L421_1
    cmp rsi, r8
    jle .L421_3
    mov r10, rsi
    jmp .L421_4
.L421_3:
    mov r10, r8
.L421_4:
    jmp .L421_2
.L421_1:
    cmp rsi, r8
    jge .L421_5
    mov rbx, rsi
    jmp .L421_6
.L421_5:
    mov rbx, r8
.L421_6:
    mov r10, rbx
.L421_2:
    mov rdx, rdi
    mov rcx, rsi
    mov r11, r10
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    mov rbx, rax
    cmp rbx, rsi
    jne .L421_7
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L421_7:
    mov rsi, rbx
    jmp .L421_0
.globl zyl_atomic_max
zyl_atomic_max:
    push rbp
    mov rbp, rsp
.L422_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 1
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick
.globl zyl_atomic_min
zyl_atomic_min:
    push rbp
    mov rbp, rsp
.L423_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, 0
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick
.globl zyl_bytebuf_atomic_load
zyl_bytebuf_atomic_load:
    push rbp
    mov rbp, rsp
.L424_0:
    cmp rdi, 4096
    jge .L424_3
    jmp .L424_4
.L424_3:
    mov r8, rdi
    and r8, 7
    cmp r8, 0
    jne .L424_5
    mov r8, 0
    jmp .L424_6
.L424_5:
    mov r9, 1
    mov r8, r9
.L424_6:
    cmp r8, 0
    je .L424_1
.L424_4:
    mov r8, 0
    jmp .L424_2
.L424_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, 6510318584122966017
    cmp r9, r10
    jne .L424_7
    jmp .L424_8
.L424_7:
    mov r9, 0
    mov rdi, r9
.L424_8:
    mov r8, rdi
.L424_2:
    cmp r8, 0
    jne .L424_11
    jmp .L424_12
.L424_11:
    cmp rsi, 0
    jge .L424_13
    jmp .L424_14
.L424_13:
    mov rdi, rsi
    and rdi, 7
    cmp rdi, 0
    jne .L424_15
    mov rdi, 0
    jmp .L424_16
.L424_15:
    mov r9, 1
    mov rdi, r9
.L424_16:
    cmp rdi, 0
    je .L424_9
.L424_14:
.L424_12:
    mov rdi, 0
    jmp .L424_10
.L424_9:
    cmp rsi, 0
    jge .L424_21
    jmp .L424_22
.L424_21:
    mov r9, r8
    add r9, 24
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r9, 0
    jge .L424_23
    jmp .L424_24
.L424_23:
    mov r9, 8
    mov r10, r8
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    cmp r9, r10
    jle .L424_19
.L424_24:
.L424_22:
    mov r9, 0
    jmp .L424_20
.L424_19:
    mov r10, r8
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    sub r10, 8
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
    mov r9, r10
.L424_20:
    cmp r9, 0
    je .L424_17
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    add rsi, r8
    jmp .L424_18
.L424_17:
    mov r8, 0
    mov rsi, r8
.L424_18:
    mov rdi, rsi
.L424_10:
    cmp rdi, 0
    jne .L424_25
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L424_25:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_atomic_store
zyl_bytebuf_atomic_store:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L425_0:
    cmp rdi, 4096
    jge .L425_3
    jmp .L425_4
.L425_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L425_5
    mov r9, 0
    jmp .L425_6
.L425_5:
    mov r10, 1
    mov r9, r10
.L425_6:
    cmp r9, 0
    je .L425_1
.L425_4:
    mov r9, 0
    jmp .L425_2
.L425_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966017
    cmp r10, rbx
    jne .L425_7
    jmp .L425_8
.L425_7:
    mov r10, 0
    mov rdi, r10
.L425_8:
    mov r9, rdi
.L425_2:
    cmp r9, 0
    jne .L425_11
    jmp .L425_12
.L425_11:
    cmp rsi, 0
    jge .L425_13
    jmp .L425_14
.L425_13:
    mov rdi, rsi
    and rdi, 7
    cmp rdi, 0
    jne .L425_15
    mov rdi, 0
    jmp .L425_16
.L425_15:
    mov r10, 1
    mov rdi, r10
.L425_16:
    cmp rdi, 0
    je .L425_9
.L425_14:
.L425_12:
    mov rdi, 0
    jmp .L425_10
.L425_9:
    cmp rsi, 0
    jge .L425_21
    jmp .L425_22
.L425_21:
    mov r10, r9
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    cmp r10, 0
    jge .L425_23
    jmp .L425_24
.L425_23:
    mov r10, 8
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp r10, rbx
    jle .L425_19
.L425_24:
.L425_22:
    mov r10, 0
    jmp .L425_20
.L425_19:
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    sub rbx, 8
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
    mov r10, rbx
.L425_20:
    cmp r10, 0
    je .L425_17
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    add rsi, r9
    jmp .L425_18
.L425_17:
    mov r9, 0
    mov rsi, r9
.L425_18:
    mov rdi, rsi
.L425_10:
    cmp rdi, 0
    jne .L425_25
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L425_25:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rsi, rax
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_atomic_add
zyl_bytebuf_atomic_add:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L426_0:
    cmp rdi, 4096
    jge .L426_3
    jmp .L426_4
.L426_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L426_5
    mov r9, 0
    jmp .L426_6
.L426_5:
    mov r10, 1
    mov r9, r10
.L426_6:
    cmp r9, 0
    je .L426_1
.L426_4:
    mov r9, 0
    jmp .L426_2
.L426_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966017
    cmp r10, rbx
    jne .L426_7
    jmp .L426_8
.L426_7:
    mov r10, 0
    mov rdi, r10
.L426_8:
    mov r9, rdi
.L426_2:
    cmp r9, 0
    jne .L426_11
    jmp .L426_12
.L426_11:
    cmp rsi, 0
    jge .L426_13
    jmp .L426_14
.L426_13:
    mov rdi, rsi
    and rdi, 7
    cmp rdi, 0
    jne .L426_15
    mov rdi, 0
    jmp .L426_16
.L426_15:
    mov r10, 1
    mov rdi, r10
.L426_16:
    cmp rdi, 0
    je .L426_9
.L426_14:
.L426_12:
    mov rdi, 0
    jmp .L426_10
.L426_9:
    cmp rsi, 0
    jge .L426_21
    jmp .L426_22
.L426_21:
    mov r10, r9
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    cmp r10, 0
    jge .L426_23
    jmp .L426_24
.L426_23:
    mov r10, 8
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp r10, rbx
    jle .L426_19
.L426_24:
.L426_22:
    mov r10, 0
    jmp .L426_20
.L426_19:
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    sub rbx, 8
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
    mov r10, rbx
.L426_20:
    cmp r10, 0
    je .L426_17
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    add rsi, r9
    jmp .L426_18
.L426_17:
    mov r9, 0
    mov rsi, r9
.L426_18:
    mov rdi, rsi
.L426_10:
    cmp rdi, 0
    jne .L426_25
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L426_25:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    add rsi, r8
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_atomic_sub
zyl_bytebuf_atomic_sub:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L427_0:
    cmp rdi, 4096
    jge .L427_3
    jmp .L427_4
.L427_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L427_5
    mov r9, 0
    jmp .L427_6
.L427_5:
    mov r10, 1
    mov r9, r10
.L427_6:
    cmp r9, 0
    je .L427_1
.L427_4:
    mov r9, 0
    jmp .L427_2
.L427_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966017
    cmp r10, rbx
    jne .L427_7
    jmp .L427_8
.L427_7:
    mov r10, 0
    mov rdi, r10
.L427_8:
    mov r9, rdi
.L427_2:
    cmp r9, 0
    jne .L427_11
    jmp .L427_12
.L427_11:
    cmp rsi, 0
    jge .L427_13
    jmp .L427_14
.L427_13:
    mov rdi, rsi
    and rdi, 7
    cmp rdi, 0
    jne .L427_15
    mov rdi, 0
    jmp .L427_16
.L427_15:
    mov r10, 1
    mov rdi, r10
.L427_16:
    cmp rdi, 0
    je .L427_9
.L427_14:
.L427_12:
    mov rdi, 0
    jmp .L427_10
.L427_9:
    cmp rsi, 0
    jge .L427_21
    jmp .L427_22
.L427_21:
    mov r10, r9
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    cmp r10, 0
    jge .L427_23
    jmp .L427_24
.L427_23:
    mov r10, 8
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp r10, rbx
    jle .L427_19
.L427_24:
.L427_22:
    mov r10, 0
    jmp .L427_20
.L427_19:
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    sub rbx, 8
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
    mov r10, rbx
.L427_20:
    cmp r10, 0
    je .L427_17
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    add rsi, r9
    jmp .L427_18
.L427_17:
    mov r9, 0
    mov rsi, r9
.L427_18:
    mov rdi, rsi
.L427_10:
    cmp rdi, 0
    jne .L427_25
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L427_25:
    mov rsi, 0
    sub rsi, r8
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    sub rsi, r8
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_atomic_fetch_add
zyl_bytebuf_atomic_fetch_add:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L428_0:
    cmp rdi, 4096
    jge .L428_3
    jmp .L428_4
.L428_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L428_5
    mov r9, 0
    jmp .L428_6
.L428_5:
    mov r10, 1
    mov r9, r10
.L428_6:
    cmp r9, 0
    je .L428_1
.L428_4:
    mov r9, 0
    jmp .L428_2
.L428_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966017
    cmp r10, rbx
    jne .L428_7
    jmp .L428_8
.L428_7:
    mov r10, 0
    mov rdi, r10
.L428_8:
    mov r9, rdi
.L428_2:
    cmp r9, 0
    jne .L428_11
    jmp .L428_12
.L428_11:
    cmp rsi, 0
    jge .L428_13
    jmp .L428_14
.L428_13:
    mov rdi, rsi
    and rdi, 7
    cmp rdi, 0
    jne .L428_15
    mov rdi, 0
    jmp .L428_16
.L428_15:
    mov r10, 1
    mov rdi, r10
.L428_16:
    cmp rdi, 0
    je .L428_9
.L428_14:
.L428_12:
    mov rdi, 0
    jmp .L428_10
.L428_9:
    cmp rsi, 0
    jge .L428_21
    jmp .L428_22
.L428_21:
    mov r10, r9
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    cmp r10, 0
    jge .L428_23
    jmp .L428_24
.L428_23:
    mov r10, 8
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp r10, rbx
    jle .L428_19
.L428_24:
.L428_22:
    mov r10, 0
    jmp .L428_20
.L428_19:
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    sub rbx, 8
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
    mov r10, rbx
.L428_20:
    cmp r10, 0
    je .L428_17
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    add rsi, r9
    jmp .L428_18
.L428_17:
    mov r9, 0
    mov rsi, r9
.L428_18:
    mov rdi, rsi
.L428_10:
    cmp rdi, 0
    jne .L428_25
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L428_25:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_atomic_max
zyl_bytebuf_atomic_max:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L429_0:
    cmp rdi, 4096
    jge .L429_3
    jmp .L429_4
.L429_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L429_5
    mov r9, 0
    jmp .L429_6
.L429_5:
    mov r10, 1
    mov r9, r10
.L429_6:
    cmp r9, 0
    je .L429_1
.L429_4:
    mov r9, 0
    jmp .L429_2
.L429_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966017
    cmp r10, rbx
    jne .L429_7
    jmp .L429_8
.L429_7:
    mov r10, 0
    mov rdi, r10
.L429_8:
    mov r9, rdi
.L429_2:
    cmp r9, 0
    jne .L429_11
    jmp .L429_12
.L429_11:
    cmp rsi, 0
    jge .L429_13
    jmp .L429_14
.L429_13:
    mov rdi, rsi
    and rdi, 7
    cmp rdi, 0
    jne .L429_15
    mov rdi, 0
    jmp .L429_16
.L429_15:
    mov r10, 1
    mov rdi, r10
.L429_16:
    cmp rdi, 0
    je .L429_9
.L429_14:
.L429_12:
    mov rdi, 0
    jmp .L429_10
.L429_9:
    cmp rsi, 0
    jge .L429_21
    jmp .L429_22
.L429_21:
    mov r10, r9
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    cmp r10, 0
    jge .L429_23
    jmp .L429_24
.L429_23:
    mov r10, 8
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp r10, rbx
    jle .L429_19
.L429_24:
.L429_22:
    mov r10, 0
    jmp .L429_20
.L429_19:
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    sub rbx, 8
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
    mov r10, rbx
.L429_20:
    cmp r10, 0
    je .L429_17
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    add rsi, r9
    jmp .L429_18
.L429_17:
    mov r9, 0
    mov rsi, r9
.L429_18:
    mov rdi, rsi
.L429_10:
    cmp rdi, 0
    jne .L429_25
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L429_25:
    mov rsi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_atomic_max
.globl zyl_bytebuf_atomic_min
zyl_bytebuf_atomic_min:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L430_0:
    cmp rdi, 4096
    jge .L430_3
    jmp .L430_4
.L430_3:
    mov r9, rdi
    and r9, 7
    cmp r9, 0
    jne .L430_5
    mov r9, 0
    jmp .L430_6
.L430_5:
    mov r10, 1
    mov r9, r10
.L430_6:
    cmp r9, 0
    je .L430_1
.L430_4:
    mov r9, 0
    jmp .L430_2
.L430_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    mov rbx, 6510318584122966017
    cmp r10, rbx
    jne .L430_7
    jmp .L430_8
.L430_7:
    mov r10, 0
    mov rdi, r10
.L430_8:
    mov r9, rdi
.L430_2:
    cmp r9, 0
    jne .L430_11
    jmp .L430_12
.L430_11:
    cmp rsi, 0
    jge .L430_13
    jmp .L430_14
.L430_13:
    mov rdi, rsi
    and rdi, 7
    cmp rdi, 0
    jne .L430_15
    mov rdi, 0
    jmp .L430_16
.L430_15:
    mov r10, 1
    mov rdi, r10
.L430_16:
    cmp rdi, 0
    je .L430_9
.L430_14:
.L430_12:
    mov rdi, 0
    jmp .L430_10
.L430_9:
    cmp rsi, 0
    jge .L430_21
    jmp .L430_22
.L430_21:
    mov r10, r9
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    cmp r10, 0
    jge .L430_23
    jmp .L430_24
.L430_23:
    mov r10, 8
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp r10, rbx
    jle .L430_19
.L430_24:
.L430_22:
    mov r10, 0
    jmp .L430_20
.L430_19:
    mov rbx, r9
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    sub rbx, 8
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
    mov r10, rbx
.L430_20:
    cmp r10, 0
    je .L430_17
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    add rsi, r9
    jmp .L430_18
.L430_17:
    mov r9, 0
    mov rsi, r9
.L430_18:
    mov rdi, rsi
.L430_10:
    cmp rdi, 0
    jne .L430_25
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L430_25:
    mov rsi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_atomic_min
.globl zyl_bytebuf_atomic_cas
zyl_bytebuf_atomic_cas:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L431_0:
    cmp rdi, 4096
    jge .L431_3
    jmp .L431_4
.L431_3:
    mov r10, rdi
    and r10, 7
    cmp r10, 0
    jne .L431_5
    mov r10, 0
    jmp .L431_6
.L431_5:
    mov rbx, 1
    mov r10, rbx
.L431_6:
    cmp r10, 0
    je .L431_1
.L431_4:
    mov r10, 0
    jmp .L431_2
.L431_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rbx, rax
    mov r12, 6510318584122966017
    cmp rbx, r12
    jne .L431_7
    jmp .L431_8
.L431_7:
    mov rbx, 0
    mov rdi, rbx
.L431_8:
    mov r10, rdi
.L431_2:
    cmp r10, 0
    jne .L431_11
    jmp .L431_12
.L431_11:
    cmp rsi, 0
    jge .L431_13
    jmp .L431_14
.L431_13:
    mov rdi, rsi
    and rdi, 7
    cmp rdi, 0
    jne .L431_15
    mov rdi, 0
    jmp .L431_16
.L431_15:
    mov rbx, 1
    mov rdi, rbx
.L431_16:
    cmp rdi, 0
    je .L431_9
.L431_14:
.L431_12:
    mov rdi, 0
    jmp .L431_10
.L431_9:
    cmp rsi, 0
    jge .L431_21
    jmp .L431_22
.L431_21:
    mov rbx, r10
    add rbx, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    cmp rbx, 0
    jge .L431_23
    jmp .L431_24
.L431_23:
    mov rbx, 8
    mov r12, r10
    add r12, 24
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov r12, rax
    cmp rbx, r12
    jle .L431_19
.L431_24:
.L431_22:
    mov rbx, 0
    jmp .L431_20
.L431_19:
    mov r12, r10
    add r12, 24
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov r12, rax
    sub r12, 8
    mov rax, rsi
    mov rcx, r12
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r12, rax
    mov rbx, r12
.L431_20:
    cmp rbx, 0
    je .L431_17
    add r10, 8
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    add rsi, r10
    jmp .L431_18
.L431_17:
    mov r10, 0
    mov rsi, r10
.L431_18:
    mov rdi, rsi
.L431_10:
    cmp rdi, 0
    jne .L431_25
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L431_25:
    mov rdx, rdi
    mov rcx, r8
    mov r11, r9
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    mov rsi, rax
    cmp rsi, r8
    jne .L431_26
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L431_26:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_add
zyl_f_add:
    push rbp
    mov rbp, rsp
    sub rsp, 120
    mov [rbp-120], rbx
    mov [rbp-112], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    addsd xmm0, xmm1
    movq rax, xmm0
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_sub
zyl_f_sub:
    push rbp
    mov rbp, rsp
    sub rsp, 120
    mov [rbp-120], rbx
    mov [rbp-112], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    subsd xmm0, xmm1
    movq rax, xmm0
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_mul
zyl_f_mul:
    push rbp
    mov rbp, rsp
    sub rsp, 120
    mov [rbp-120], rbx
    mov [rbp-112], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    mulsd xmm0, xmm1
    movq rax, xmm0
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_div
zyl_f_div:
    push rbp
    mov rbp, rsp
    sub rsp, 120
    mov [rbp-120], rbx
    mov [rbp-112], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    divsd xmm0, xmm1
    movq rax, xmm0
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_of_int
zyl_f_of_int:
    push rbp
    mov rbp, rsp
.L432_0:
    mov rdx, rdi
    cvtsi2sd xmm0, rdx
    movq rax, xmm0
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_to_int
zyl_f_to_int:
    push rbp
    mov rbp, rsp
.L433_0:
    mov rdx, rdi
    movq xmm0, rdx
    cvttsd2si rax, xmm0
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_rem
zyl_f_rem:
    push rbp
    mov rbp, rsp
    sub rsp, 152
    mov [rbp-152], rbx
    mov [rbp-144], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, [rbp-16]
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    movsd xmm0, [rip+.L436]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm0, xmm1
    sete al
    setnp cl
    and al, cl
    movzx rax, al
    test rax, rax
    je .L434
    movsd xmm0, [rip+.L437]
    movq rax, xmm0
    jmp .L435
.L434:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    divsd xmm0, xmm1
    movq rax, xmm0
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    movsd xmm0, [rip+.L442]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm0, xmm1
    seta al
    movzx rax, al
    test rax, rax
    je .L440
    mov rax, [rbp-40]
    push rax
    movsd xmm0, [rip+.L443]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm1, xmm0
    seta al
    movzx rax, al
    jmp .L441
.L440:
    mov rax, 0
.L441:
    test rax, rax
    je .L438
    mov rax, [rbp-40]
    mov rdx, rax
    movq xmm0, rdx
    cvttsd2si rax, xmm0
    mov rdx, rax
    cvtsi2sd xmm0, rdx
    movq rax, xmm0
    jmp .L439
.L438:
    mov rax, [rbp-40]
.L439:
    mov [rbp-48], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-32]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    mulsd xmm0, xmm1
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    subsd xmm0, xmm1
    movq rax, xmm0
.L435:
    mov rbx, [rbp-152]
    mov r12, [rbp-144]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_cmp
zyl_f_cmp:
    push rbp
    mov rbp, rsp
    sub rsp, 136
    mov [rbp-136], rbx
    mov [rbp-128], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, [rbp-16]
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm1, xmm0
    seta al
    movzx rax, al
    test rax, rax
    je .L444
    mov rax, -1
    jmp .L445
.L444:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm0, xmm1
    seta al
    movzx rax, al
    test rax, rax
    je .L446
    mov rax, 1
    jmp .L447
.L446:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm0, xmm1
    sete al
    setnp cl
    and al, cl
    movzx rax, al
    test rax, rax
    je .L448
    mov rax, 0
    jmp .L449
.L448:
    mov rax, 2
.L449:
.L447:
.L445:
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_now_ms
zyl_now_ms:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L450_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_timespec@tpoff]
    mov rsi, rax
    mov rbx, rsi
    mov rsi, 1
    mov rdi, rsi
    mov rsi, rbx
    call zyl_rt_sys_228
    mov rsi, rax
    cmp rsi, 0
    jne .L450_2
    mov rsi, 0
    jmp .L450_3
.L450_2:
    mov rdi, 1
    mov rsi, rdi
.L450_3:
    cmp rsi, 0
    je .L450_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L450_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    imul rsi, 1000
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rcx, rdi
    movabs rax, 4835703278458516699
    imul rcx
    sar rdx, 18
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    mov rax, rdx
    mov rdi, rax
    add rsi, rdi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dbudget:
    push rbp
    mov rbp, rsp
.L451_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dparse_x2Du:
    push rbp
    mov rbp, rsp
.L452_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 48
    jl .L452_1
    cmp r8, 57
    jg .L452_1
    mov r9, rdi
    add r9, 1
    mov r10, rsi
    imul r10, 10
    sub r8, 48
    add r8, r10
    mov rdi, r9
    mov rsi, r8
    jmp .L452_0
.L452_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dskip_x2Dws:
    push rbp
    mov rbp, rsp
.L453_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 32
    jne .L453_2
    jmp .L453_3
.L453_2:
    cmp rsi, 9
    jl .L453_1
    cmp rsi, 13
    jg .L453_1
.L453_3:
    mov rsi, rdi
    add rsi, 1
    mov rdi, rsi
    jmp .L453_0
.L453_1:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dstrtoull:
    push rbp
    mov rbp, rsp
.L454_0:
    call zy_local_x2Fmain_0__alloc__rt_x2Dskip_x2Dws
    mov rsi, rax
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    cmp rdi, 43
    jne .L454_1
    mov rdi, rsi
    add rdi, 1
    jmp .L454_2
.L454_1:
    mov rdi, rsi
.L454_2:
    mov rsi, 0
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dparse_x2Du
zy_local_x2Fmain_0__alloc__rt_x2Dmeminfo_x2Dfield:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L455_0:
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov rdx, r13
    mov rcx, rsi
    mov rsi, r12
    mov r8, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dmeminfo_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jge .L455_1
    mov rdi, -1
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L455_1:
    add rsi, rbx
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dstrtoull
zy_local_x2Fmain_0__alloc__rt_x2Dmeminfo_x2Dfind:
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
    mov r15, r8
.L456_0:
    mov rsi, r15
    add rsi, r14
    cmp rsi, r12
    jle .L456_1
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
.L456_1:
    cmp r15, 0
    jne .L456_3
    jmp .L456_4
.L456_3:
    mov rsi, r15
    sub rsi, 1
    add rsi, rbx
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 10
    jne .L456_2
.L456_4:
    mov rsi, rbx
    add rsi, r15
    mov rdi, rsi
    mov rsi, r13
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    mov rsi, rax
    cmp rsi, 0
    je .L456_2
    mov rsi, r15
    add rsi, r14
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L456_2:
    mov rsi, r15
    add rsi, 1
    mov r15, rsi
    jmp .L456_0
zy_local_x2Fmain_0__alloc__rt_x2Dread_x2Dall:
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
    mov r14, rcx
.L457_0:
    cmp r14, r13
    jl .L457_1
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L457_1:
    mov rsi, r12
    add rsi, r14
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L457_2
    add rsi, r14
    mov r14, rsi
    jmp .L457_0
.L457_2:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dmeminfo_x2Davailable:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L458_0:
    lea rax, [rip+.L459]
    mov rsi, rax
    mov rdi, 524288
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_2
    mov rsi, rax
    mov rbx, rsi
    cmp rbx, 0
    jge .L458_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L458_1:
    mov rsi, 16384
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L458_2
    mov rdi, rbx
    call zyl_rt_sys_3
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L458_2:
    mov rsi, 16383
    mov rdi, 0
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dread_x2Dall
    mov rsi, rax
    mov r13, rsi
    mov rdi, rbx
    call zyl_rt_sys_3
    mov rsi, rax
    mov rsi, r12
    add rsi, r13
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    lea rax, [rip+.L460]
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__alloc__rt_x2Dmeminfo_x2Dfield
    mov rsi, rax
    mov rbx, rsi
    lea rax, [rip+.L461]
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__alloc__rt_x2Dmeminfo_x2Dfield
    mov rsi, rax
    mov r13, rsi
    mov rdi, r12
    call free
    mov rsi, rax
    cmp rbx, 0
    jle .L458_3
    mov rsi, rbx
    imul rsi, 1024
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L458_3:
    cmp r13, 0
    jle .L458_4
    mov rsi, r13
    imul rsi, 1024
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L458_4:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dsysinfo_x2Dtotal:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L462_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_sysinfo@tpoff]
    mov rsi, rax
    mov rbx, rsi
    mov rdi, rbx
    call zyl_rt_sys_99
    mov rsi, rax
    cmp rsi, 0
    jne .L462_2
    mov rsi, 0
    jmp .L462_3
.L462_2:
    mov rdi, 1
    mov rsi, rdi
.L462_3:
    cmp rsi, 0
    je .L462_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L462_1:
    mov rsi, rbx
    add rsi, 32
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rbx
    add rdi, 104
    mov rdx, rdi
    mov eax, dword ptr [rdx]
    mov rdi, rax
    imul rsi, rdi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dbudget_x2Dvalue:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L463_0:
    lea rax, [rip+.L464]
    mov rsi, rax
    mov rdi, rsi
    call zyl_getenv_str
    mov rsi, rax
    cmp rsi, 0
    jle .L463_1
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jle .L463_1
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dstrtoull
.L463_1:
    call zy_local_x2Fmain_0__alloc__rt_x2Dmeminfo_x2Davailable
    mov rsi, rax
    cmp rsi, 0
    jle .L463_2
    mov rbx, rsi
    jmp .L463_3
.L463_2:
    call zy_local_x2Fmain_0__alloc__rt_x2Dsysinfo_x2Dtotal
    mov rsi, rax
    mov rbx, rsi
.L463_3:
    cmp rbx, 0
    jle .L463_4
    mov rcx, rbx
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 1
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    mov rax, rdx
    mov rsi, rax
    imul rsi, 4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L463_4:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dbudget_x2Donce:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L465_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 2
    jne .L465_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L465_1:
    mov rsi, 0
    mov rdi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov r11, rdi
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    mov rsi, rax
    cmp rsi, 0
    jne .L465_2
    mov r12, rbx
    add r12, 8
    call zy_local_x2Fmain_0__alloc__rt_x2Dbudget_x2Dvalue
    mov rsi, rax
    mov rdx, r12
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 2
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L465_2:
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dbudget_x2Dwait
zy_local_x2Fmain_0__alloc__rt_x2Dbudget_x2Dwait:
    push rbp
    mov rbp, rsp
.L466_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 2
    jne .L466_1
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L466_1:
    jmp .L466_0
zy_local_x2Fmain_0__alloc__rt_x2Dcharge:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L467_0:
    call zy_local_x2Fmain_0__alloc__rt_x2Dbudget_x2Donce
    mov rsi, rax
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    mov rdi, rsi
    add rdi, 16
    mov rdx, rdi
    mov rcx, rbx
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rdi, rax
    add rdi, rbx
    mov r8, rsi
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp r8, 0
    jle .L467_1
    mov r8, rsi
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp rdi, r8
    jle .L467_1
    add rsi, 16
    mov rdi, 0
    sub rdi, rbx
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L467_1:
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drefund:
    push rbp
    mov rbp, rsp
.L468_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    add rsi, 16
    mov r8, 0
    mov rax, r8
    mov rcx, rdi
    sub rax, rcx
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dutext:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L469_0:
    call zyl_int_text
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Doom:
    push rbp
    mov rbp, rsp
.L470_0:
    mov rsp, rbp
    pop rbp
    jmp zyl_arena_oom
.globl zyl_arena_oom
zyl_arena_oom:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 32
    mov qword ptr [rbp-56], rsi
.L471_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    mov r12, rsi
    lea rax, [rip+.L472]
    mov qword ptr [rbp-48], rax
    lea rax, [rip+.L473]
    mov qword ptr [rbp-64], rax
    call zyl_int_text
    mov r15, rax
    lea rax, [rip+.L474]
    mov r13, rax
    mov rsi, r12
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zyl_int_text
    mov rbx, rax
    lea rax, [rip+.L475]
    mov r14, rax
    mov rsi, r12
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zyl_int_text
    mov rsi, rax
    lea rax, [rip+.L476]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r14
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r13
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r15
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, qword ptr [rbp-64]
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, qword ptr [rbp-56]
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
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
    mov rsi, 1
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_sys_231
zy_local_x2Fmain_0__alloc__rt_x2Dthreads:
    push rbp
    mov rbp, rsp
.L477_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_threads_started_mark
zyl_threads_started_mark:
    push rbp
    mov rbp, rsp
.L478_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dalign16:
    push rbp
    mov rbp, rsp
.L479_0:
    mov rsi, rdi
    add rsi, 15
    and rsi, -16
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dnew_x2Dblock:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L480_0:
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rsi, rdi
    jge .L480_1
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    jmp .L480_2
.L480_1:
    mov rdi, rsi
.L480_2:
    mov r12, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dcharge
    mov rsi, rax
    cmp rsi, 0
    je .L480_3
    mov rsi, 0
    mov r13, rsi
    jmp .L480_4
.L480_3:
    lea rax, [rip+.L481]
    mov rsi, rax
    mov rdi, r12
    call zyl_arena_oom
    mov rsi, rax
    mov r13, rsi
.L480_4:
    mov rsi, 32
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L480_5
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Drefund
    mov rsi, rax
    mov rsi, 32
    lea rax, [rip+.L482]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zyl_arena_oom
.L480_5:
    mov rdi, r12
    call malloc
    mov rsi, rax
    mov r14, rsi
    cmp r14, 0
    jne .L480_6
    mov rdi, r13
    call free
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Drefund
    mov rsi, rax
    lea rax, [rip+.L483]
    mov rsi, rax
    mov rdi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zyl_arena_oom
.L480_6:
    mov rdx, r13
    mov rcx, r14
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 8
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 24
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rdx, rbx
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdi, rbx
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, r12
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_arena_create
zyl_arena_create:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L484_0:
    cmp rdi, 16
    jge .L484_1
    mov rsi, 65536
    jmp .L484_2
.L484_1:
    mov rsi, rdi
.L484_2:
    mov rbx, rsi
    mov rsi, 1
    mov rdi, 72
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call calloc
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L484_3
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L484_3:
    mov rsi, r12
    add rsi, 8
    mov rdx, rsi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dnew_x2Dblock
    mov rsi, rax
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L485_0:
    cmp rbx, 0
    jne .L485_2
    jmp .L485_3
.L485_2:
    cmp rsi, 0
    jge .L485_4
    jmp .L485_5
.L485_4:
    mov rdi, 281474976710656
    cmp rsi, rdi
    jle .L485_1
.L485_5:
.L485_3:
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L485_1:
    add rsi, 15
    and rsi, -16
    mov r12, rsi
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L485_6
    mov rsi, 0
    mov r13, rsi
    jmp .L485_7
.L485_6:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_lock
    mov rsi, rax
    mov r13, rsi
.L485_7:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L485_10
    jmp .L485_11
.L485_10:
    mov rsi, r13
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r13
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    sub rsi, rdi
    cmp r12, rsi
    jle .L485_8
.L485_11:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dnew_x2Dblock
    mov rsi, rax
    jmp .L485_9
.L485_8:
    mov rsi, r13
.L485_9:
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, rsi
    add r8, 16
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    add rdi, r8
    mov r13, rdi
    mov rdi, rsi
    add rdi, 16
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    add rsi, r12
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 24
    mov rdi, rbx
    add rdi, 24
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, r12
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L485_12
    mov rsi, 0
    mov r12, rsi
    jmp .L485_13
.L485_12:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_unlock
    mov rsi, rax
    mov r12, rsi
.L485_13:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_arena_alloc
zyl_arena_alloc:
    push rbp
    mov rbp, rsp
.L486_0:
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
.globl zyl_arena_alloc_zeroed
zyl_arena_alloc_zeroed:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L487_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L487_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L487_1:
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dfill0
    mov rsi, rax
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfill0:
    push rbp
    mov rbp, rsp
.L488_0:
    cmp rsi, 0
    jle .L488_1
    mov r8, 0
    mov rdx, rdi
    mov rcx, r8
    mov r11, rsi
    push rdi
    mov rdi, rdx
    mov rax, rcx
    mov rcx, r11
    rep stosb
    pop rdi
    xor eax, eax
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L488_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfill_x2Dde:
    push rbp
    mov rbp, rsp
.L489_0:
    cmp rsi, 0
    jle .L489_1
    mov r8, 222
    mov rdx, rdi
    mov rcx, r8
    mov r11, rsi
    push rdi
    mov rdi, rdx
    mov rax, rcx
    mov rcx, r11
    rep stosb
    pop rdi
    xor eax, eax
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L489_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L490_0:
    cmp rbx, 0
    jne .L490_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L490_1:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rbx
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rdi, 0
    jle .L490_2
    mov r8, 222
    mov rdx, rsi
    mov rcx, r8
    mov r11, rdi
    push rdi
    mov rdi, rdx
    mov rax, rcx
    mov rcx, r11
    rep stosb
    pop rdi
    xor eax, eax
    mov rsi, rax
    jmp .L490_3
.L490_2:
    mov rdi, 0
    mov rsi, rdi
.L490_3:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    lea rax, [rip+zyl_rtg_budget]
    mov rdi, rax
    add rdi, 16
    mov r8, 0
    mov rax, r8
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call free
    mov rsi, rax
    mov rdi, rbx
    call free
    mov rsi, rax
    mov rbx, r12
    jmp .L490_0
.globl zyl_arena_reset
zyl_arena_reset:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L491_0:
    cmp rbx, 0
    jne .L491_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L491_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L491_2
    mov rsi, 0
    mov r12, rsi
    jmp .L491_3
.L491_2:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_lock
    mov rsi, rax
    mov r12, rsi
.L491_3:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks
    mov rsi, rax
    mov rsi, 0
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 24
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L491_4
    mov rsi, 0
    mov r12, rsi
    jmp .L491_5
.L491_4:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_unlock
    mov rsi, rax
    mov r12, rsi
.L491_5:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_arena_destroy
zyl_arena_destroy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L492_0:
    cmp rbx, 0
    jne .L492_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L492_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L492_2
    mov rsi, 0
    mov r12, rsi
    jmp .L492_3
.L492_2:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_lock
    mov rsi, rax
    mov r12, rsi
.L492_3:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks
    mov rsi, rax
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L492_4
    mov rsi, 0
    mov r12, rsi
    jmp .L492_5
.L492_4:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_unlock
    mov rsi, rax
    mov r12, rsi
.L492_5:
    mov rdi, rbx
    call free
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_arena_used
zyl_arena_used:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L493_0:
    cmp rbx, 0
    jne .L493_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L493_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L493_2
    mov rsi, 0
    mov r12, rsi
    jmp .L493_3
.L493_2:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_lock
    mov rsi, rax
    mov r12, rsi
.L493_3:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L493_4
    mov rsi, 0
    mov r13, rsi
    jmp .L493_5
.L493_4:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_unlock
    mov rsi, rax
    mov r13, rsi
.L493_5:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_arena_capacity
zyl_arena_capacity:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L494_0:
    cmp rbx, 0
    jne .L494_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L494_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L494_2
    mov rsi, 0
    mov r12, rsi
    jmp .L494_3
.L494_2:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_lock
    mov rsi, rax
    mov r12, rsi
.L494_3:
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L494_4
    mov rsi, 0
    mov r13, rsi
    jmp .L494_5
.L494_4:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_unlock
    mov rsi, rax
    mov r13, rsi
.L494_5:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Din_x2Dblocks:
    push rbp
    mov rbp, rsp
.L495_0:
    cmp rdi, 0
    jne .L495_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L495_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp rsi, r8
    jl .L495_2
    mov r8, rsi
    add r8, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, rdi
    add r10, 16
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    add r9, r10
    cmp r8, r9
    jg .L495_2
    mov r8, 1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L495_2:
    mov r8, rdi
    add r8, 24
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov rdi, r8
    jmp .L495_0
zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L496_0:
    cmp rbx, 0
    jne .L496_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L496_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L496_2
    mov rsi, 0
    mov r13, rsi
    jmp .L496_3
.L496_2:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_lock
    mov rsi, rax
    mov r13, rsi
.L496_3:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Din_x2Dblocks
    mov rsi, rax
    mov r12, rsi
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L496_4
    mov rsi, 0
    mov r13, rsi
    jmp .L496_5
.L496_4:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    call pthread_mutex_unlock
    mov rsi, rax
    mov r13, rsi
.L496_5:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Darenas:
    push rbp
    mov rbp, rsp
.L497_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dheap:
    push rbp
    mov rbp, rsp
.L498_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dpin:
    push rbp
    mov rbp, rsp
.L499_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_arenas_init
zyl_arenas_init:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L500_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L500_1
    mov rsi, 1048576
    mov rdi, rsi
    call zyl_arena_create
    mov rsi, rax
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    jmp .L500_2
.L500_1:
    mov rdi, 0
    mov rsi, rdi
.L500_2:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L500_3
    add rbx, 8
    mov rsi, 262144
    mov rdi, rsi
    call zyl_arena_create
    mov rsi, rax
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    jmp .L500_4
.L500_3:
    mov rdi, 0
    mov rsi, rdi
.L500_4:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_arenas_destroy
zyl_arenas_destroy:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L501_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rbx, rsi
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L501_1
    mov rsi, 0
    mov r12, rsi
    jmp .L501_2
.L501_1:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zyl_arena_destroy
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov r12, rsi
.L501_2:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L501_3
    mov rsi, 0
    mov r12, rsi
    jmp .L501_4
.L501_3:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zyl_arena_destroy
    mov rsi, rax
    mov rsi, 0
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov r12, rsi
.L501_4:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L502_0:
    mov rdi, rsi
    call zyl_int_text
    mov rsi, rax
    lea rax, [rip+.L503]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
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
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_heap_alloc
zyl_heap_alloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L504_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L504_2
    jmp .L504_3
.L504_2:
    cmp rbx, 0
    jg .L504_1
.L504_3:
    mov rdi, 0
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L504_1:
    mov rdi, 281474976710656
    cmp rbx, rdi
    jle .L504_4
    lea rax, [rip+.L505]
    mov rdi, rax
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L504_4:
    mov rdi, rbx
    add rdi, 7
    mov rcx, rdi
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov rdi, rax
    mov r12, rdi
    mov rdi, r12
    imul rdi, 8
    add rdi, 8
    add rdi, 15
    and rdi, -16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov r8, rax
    lea rax, [rip+zyl_rtg_threads_started]
    mov r9, rax
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r9, 0
    jne .L504_5
    cmp r8, 0
    jle .L504_5
    mov r9, r8
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, r8
    add r10, 16
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    sub r9, r10
    cmp rdi, r9
    jg .L504_5
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, r8
    add r10, 16
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    add r9, r10
    mov r10, r8
    add r10, 16
    add r8, 16
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    add r8, rdi
    mov rdx, r10
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    mov r8, rsi
    add r8, 24
    mov r10, rsi
    add r10, 24
    mov rdx, r10
    mov rax, qword ptr [rdx]
    mov r10, rax
    add rdi, r10
    mov rdx, r8
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdx, r9
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, r9
    add rdi, 8
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L504_5:
    mov rdi, r12
    imul rdi, 8
    add rdi, 8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    cmp rsi, 0
    jne .L504_6
    lea rax, [rip+.L506]
    mov rdi, rax
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L504_6:
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    add rsi, 8
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_heap_swap
zyl_heap_swap:
    push rbp
    mov rbp, rsp
.L507_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp rdi, 0
    jne .L507_1
    mov r9, 0
    jmp .L507_2
.L507_1:
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov r9, rsi
.L507_2:
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_session_arena
zyl_session_arena:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L508_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    add rsi, 16
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L508_1
    mov rsi, 1048576
    mov rdi, rsi
    call zyl_arena_create
    mov rsi, rax
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    jmp .L508_2
.L508_1:
    mov rdi, 0
    mov rsi, rdi
.L508_2:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_heap_block_p
zyl_heap_block_p:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L509_0:
    cmp rbx, 4096
    jge .L509_2
    jmp .L509_3
.L509_2:
    mov rsi, rbx
    and rsi, 7
    cmp rsi, 0
    jne .L509_4
    mov rsi, 0
    jmp .L509_5
.L509_4:
    mov rdi, 1
    mov rsi, rdi
.L509_5:
    cmp rsi, 0
    je .L509_1
.L509_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L509_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
    mov rsi, rax
    cmp rsi, 0
    je .L509_6
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L509_6:
    call zyl_session_arena
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
.globl zyl_pin_owns
zyl_pin_owns:
    push rbp
    mov rbp, rsp
.L510_0:
    cmp rdi, 0
    jne .L510_2
    jmp .L510_3
.L510_2:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L510_1
.L510_3:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L510_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
.globl zyl_pin_word
zyl_pin_word:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L511_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L511_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L511_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, 8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    cmp rsi, 0
    jne .L511_2
    mov rdi, 0
    jmp .L511_3
.L511_2:
    mov rdx, rsi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    mov rdi, r8
.L511_3:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mlock
zyl_mlock:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L512_0:
    cmp rdi, 0
    jne .L512_2
    jmp .L512_3
.L512_2:
    cmp rsi, 0
    jg .L512_1
.L512_3:
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L512_1:
    mov r8, rdi
    and r8, -4096
    sub rdi, r8
    add rsi, rdi
    mov rdi, r8
    call zyl_rt_sys_149
    mov rsi, rax
    cmp rsi, 0
    jne .L512_4
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L512_4:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_pin_alloc
zyl_pin_alloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
.L513_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L513_2
    jmp .L513_3
.L513_2:
    cmp rbx, 0
    jg .L513_1
.L513_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L513_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L513_4
    mov rsi, 0
    mov r13, rsi
    jmp .L513_5
.L513_4:
    mov rdi, r12
    mov rsi, rbx
    call zyl_mlock
    mov rsi, rax
    mov r13, rsi
.L513_5:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dclass_x2Dsize:
    push rbp
    mov rbp, rsp
.L514_0:
    cmp rdi, 0
    jne .L514_1
    mov rsi, 1024
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L514_1:
    cmp rdi, 1
    jne .L514_2
    mov rsi, 4096
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L514_2:
    cmp rdi, 2
    jne .L514_3
    mov rsi, 16384
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L514_3:
    mov rsi, 65536
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drpool:
    push rbp
    mov rbp, rsp
.L515_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dlive:
    push rbp
    mov rbp, rsp
.L516_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drmap:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L517_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dcharge
    mov rsi, rax
    cmp rsi, 0
    je .L517_1
    mov rsi, 0
    mov r12, rsi
    jmp .L517_2
.L517_1:
    lea rax, [rip+.L518]
    mov rsi, rax
    mov rdi, rbx
    call zyl_arena_oom
    mov rsi, rax
    mov r12, rsi
.L517_2:
    mov rsi, 0
    mov rdi, 3
    mov r8, 34
    mov r9, -1
    mov r10, 0
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, rbx
    mov rcx, r8
    mov r8, r9
    mov r9, r10
    call zyl_rt_sys_9
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jge .L517_3
    cmp r12, -4096
    jle .L517_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Drefund
    mov rsi, rax
    lea rax, [rip+.L519]
    mov rsi, rax
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zyl_arena_oom
.L517_3:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit:
    push rbp
    mov rbp, rsp
    mov r8, rdx
    mov r9, rcx
.L520_0:
    mov r10, 0
    mov rdx, rdi
    mov rcx, r10
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r10, rax
    mov r10, rdi
    add r10, 8
    mov rdx, r10
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 16
    mov rdx, rsi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 20
    mov r8, 4294967295
    and r8, r9
    mov rdx, rsi
    mov rcx, r8
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dcarve:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L521_0:
    mov rsi, r14
    add rsi, r13
    cmp rsi, 1048576
    jle .L521_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L521_1:
    mov rsi, r12
    add rsi, r14
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r13
    mov rcx, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit
    mov rsi, rax
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rdi, rax
    mov r8, rbx
    imul r8, 8
    add rdi, r8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r14
    add rsi, r13
    mov r14, rsi
    jmp .L521_0
zy_local_x2Fmain_0__alloc__rt_x2Dpick_x2Dclass:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L522_0:
    cmp rsi, 4
    jge .L522_1
    mov r8, rdi
    add r8, 24
    cmp rsi, 0
    jne .L522_2
    mov r9, 1024
    jmp .L522_3
.L522_2:
    cmp rsi, 1
    jne .L522_4
    mov r10, 4096
    jmp .L522_5
.L522_4:
    cmp rsi, 2
    jne .L522_6
    mov rbx, 16384
    jmp .L522_7
.L522_6:
    mov r12, 65536
    mov rbx, r12
.L522_7:
    mov r10, rbx
.L522_5:
    mov r9, r10
.L522_3:
    cmp r8, r9
    jle .L522_1
    mov r8, rsi
    add r8, 1
    mov rsi, r8
    jmp .L522_0
.L522_1:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dget:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
.L523_0:
    cmp rsi, 4
    jge .L523_1
    jmp .L523_2
.L523_1:
    mov rdi, 3
    mov rsi, rdi
.L523_2:
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dpick_x2Dclass
    mov rsi, rax
    mov r12, rsi
    cmp r12, 4
    jl .L523_3
    mov rsi, rbx
    add rsi, 24
    add rsi, 4095
    and rsi, -4096
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Drmap
    mov rsi, rax
    mov rdi, 1
    mov r8, -1
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, rbx
    mov rcx, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit
.L523_3:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rsi, rax
    mov rdi, r12
    imul rdi, 8
    add rsi, rdi
    mov rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L523_4
    mov rsi, 1048576
    mov rdi, rsi
    call zy_local_x2Fmain_0__alloc__rt_x2Drmap
    mov r13, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dclass_x2Dsize
    mov rsi, rax
    mov rdi, 0
    mov rdx, rsi
    mov rsi, r13
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dcarve
    mov rsi, rax
    jmp .L523_5
.L523_4:
    mov rdi, 0
    mov rsi, rdi
.L523_5:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rbx
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drset_x2Dblocks:
    push rbp
    mov rbp, rsp
.L524_0:
    mov r8, rdi
    add r8, 24
    add rdi, 24
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    and rdi, 1
    or rsi, rdi
    mov rdx, r8
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dcount_x2Dblocks:
    push rbp
    mov rbp, rsp
.L525_0:
    cmp rdi, 0
    jne .L525_2
    jmp .L525_3
.L525_2:
    cmp rsi, 4
    jl .L525_1
.L525_3:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L525_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, rsi
    add r9, 1
    mov rdi, r8
    mov rsi, r9
    jmp .L525_0
zy_local_x2Fmain_0__alloc__rt_x2Dpush_x2Dblock:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L526_0:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    and rsi, -2
    mov rdx, r12
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Drset_x2Dblocks
    mov rsi, rax
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov rdi, r12
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdi, r12
    add rdi, 24
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdi, r12
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, r12
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dexhausted:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L527_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    lea rax, [rip+.L528]
    mov rbx, rax
    cmp rsi, 2
    jne .L527_1
    lea rax, [rip+.L529]
    mov r8, rax
    mov r12, r8
    jmp .L527_2
.L527_1:
    lea rax, [rip+.L530]
    mov r8, rax
    mov r12, r8
.L527_2:
    lea rax, [rip+.L531]
    mov r13, rax
    cmp rsi, 2
    jne .L527_3
    mov rsi, rdi
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    jmp .L527_4
.L527_3:
    add rdi, 24
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rsi, rdi
.L527_4:
    mov rdi, rsi
    call zyl_int_text
    mov rsi, rax
    lea rax, [rip+.L532]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r13
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dpolicy_x2Dalloc:
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
.L533_0:
    mov rsi, rbx
    add rsi, 32
    mov rdi, rsi
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, r12
    add r8, 7
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov r8, rax
    imul r8, 8
    mov r9, rbx
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    mov r10, r9
    add r10, 8
    add r10, rdi
    sub r10, 1
    mov r14, 0
    sub r14, rdi
    and r10, r14
    mov r14, r10
    add r14, r8
    cmp r9, 0
    jle .L533_1
    mov r15, rbx
    add r15, 16
    mov rdx, r15
    mov rax, qword ptr [rdx]
    mov r15, rax
    cmp r14, r15
    jg .L533_1
    mov r15, rsi
    add r15, 32
    mov rdx, r15
    mov rax, qword ptr [rdx]
    mov r15, rax
    mov rax, r14
    mov rcx, r9
    sub rax, rcx
    mov r9, rax
    add r9, r15
    mov r15, rsi
    add r15, 24
    mov rdx, r15
    mov rax, qword ptr [rdx]
    mov r15, rax
    cmp r15, 0
    jle .L533_2
    mov r15, rsi
    add r15, 24
    mov rdx, r15
    mov rax, qword ptr [rdx]
    mov r15, rax
    cmp r9, r15
    jle .L533_2
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dexhausted
.L533_2:
    mov r15, rsi
    add r15, 32
    mov rdx, r15
    mov rcx, r9
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r9, rax
    mov r9, rbx
    add r9, 8
    mov rdx, r9
    mov rcx, r14
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r9, rax
    mov r9, r10
    sub r9, 8
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov r14, rax
    mov rdx, r9
    mov rcx, r14
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r9, rax
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L533_1:
    cmp r13, 1
    jl .L533_4
    jmp .L533_5
.L533_4:
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r9, 2
    jne .L533_3
    mov r9, rbx
    add r9, 24
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    and r9, -2
    cmp r9, 0
    jle .L533_3
.L533_5:
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dexhausted
.L533_3:
    add r8, 8
    add r8, rdi
    add r8, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r9, 2
    jne .L533_6
    mov r9, rsi
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    add r9, 8
    add rdi, r9
    add rdi, 24
    jmp .L533_7
.L533_6:
    mov r9, rsi
    add r9, 8
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r9, r8
    jge .L533_8
    jmp .L533_9
.L533_8:
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r8, rsi
.L533_9:
    mov rdi, r8
.L533_7:
    mov rsi, rdi
    add rsi, 4095
    and rsi, -4096
    mov r14, rsi
    mov rdi, r14
    call zy_local_x2Fmain_0__alloc__rt_x2Drmap
    mov rsi, rax
    mov rdi, 1
    mov r8, 0
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r14
    mov rcx, r8
    call zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dpush_x2Dblock
    mov rsi, rax
    mov rsi, r13
    add rsi, 1
    mov r13, rsi
    jmp .L533_0
.globl zyl_ralloc
zyl_ralloc:
    push rbp
    mov rbp, rsp
.L534_0:
    cmp rsi, 0
    jne .L534_1
    mov rsp, rbp
    pop rbp
    jmp zyl_heap_alloc
.L534_1:
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dralloc_x2Din
zy_local_x2Fmain_0__alloc__rt_x2Dralloc_x2Din:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
.L535_0:
    cmp rbx, 0
    jg .L535_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L535_1:
    mov rsi, r12
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    and rsi, 1
    cmp rsi, 1
    jne .L535_2
    mov rsi, 0
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dpolicy_x2Dalloc
.L535_2:
    mov rsi, 281474976710656
    cmp rbx, rsi
    jle .L535_3
    lea rax, [rip+.L536]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L535_3:
    mov rsi, rbx
    add rsi, 7
    mov rcx, rsi
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov rsi, rax
    imul rsi, 8
    add rsi, 8
    mov r13, rsi
    mov rsi, r12
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L535_6
    jmp .L535_7
.L535_6:
    mov rsi, r12
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    sub rsi, rdi
    cmp rsi, r13
    jge .L535_4
.L535_7:
    mov rsi, r12
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    and rsi, -2
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__alloc__rt_x2Dcount_x2Dblocks
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dget
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dpush_x2Dblock
    mov rsi, rax
    jmp .L535_5
.L535_4:
    mov rdi, 0
    mov rsi, rdi
.L535_5:
    mov rsi, r12
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    add rdi, 8
    mov r8, rsi
    add r8, r13
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, rbx
    add rdi, 7
    mov rcx, rdi
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    add rsi, 8
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dblock:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L537_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov rdi, 0
    mov r8, rbx
    add r8, 8
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    sub rdi, r8
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov eax, dword ptr [rdx]
    mov rsi, rax
    cmp rsi, 1
    jne .L537_1
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rdi, rbx
    mov rsi, r12
    call zyl_rt_sys_11
    mov rsi, rax
    mov rdi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Drefund
.L537_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rsi, rax
    mov rdi, rbx
    add rdi, 20
    mov rdx, rdi
    mov eax, dword ptr [rdx]
    mov rdi, rax
    imul rdi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, rbx
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdx, rsi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dchain:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
.L538_0:
    cmp rbx, 0
    jne .L538_2
    jmp .L538_3
.L538_2:
    cmp rbx, r12
    jne .L538_1
.L538_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L538_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dblock
    mov rsi, rax
    mov rbx, r13
    jmp .L538_0
zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L539_0:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    and rsi, -2
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dchain
    mov rsi, rax
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Drset_x2Dblocks
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_region_enter
zyl_region_enter:
    push rbp
    mov rbp, rsp
.L540_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rsi, rax
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 8
    mov r8, 0
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 16
    mov r8, 0
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 24
    mov r8, 0
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rdi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_region_scope_enter
zyl_region_scope_enter:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L541_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rbx, rax
    mov rdx, rdi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rbx, rax
    mov rbx, rdi
    add rbx, 8
    mov r12, 0
    mov rdx, rbx
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rbx, rax
    mov rbx, rdi
    add rbx, 16
    mov r12, 0
    mov rdx, rbx
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rbx, rax
    mov rbx, rdi
    add rbx, 24
    mov r12, 1
    mov rdx, rbx
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rbx, rax
    mov rbx, rdi
    add rbx, 32
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 40
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 48
    cmp r9, 8
    jge .L541_1
    mov r8, 8
    jmp .L541_2
.L541_1:
    mov r8, r9
.L541_2:
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 56
    mov rdx, rsi
    mov rcx, r10
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rdi
    add rsi, 64
    mov r8, 0
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rdi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_region_free
zyl_region_free:
    push rbp
    mov rbp, rsp
.L542_0:
    mov rsi, rdi
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    and rsi, -2
    cmp rsi, 0
    jle .L542_1
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    mov rsi, rax
    jmp .L542_2
.L542_1:
    mov rdi, 0
    mov rsi, rdi
.L542_2:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dlast_x2Dblock:
    push rbp
    mov rbp, rsp
.L543_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L543_1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L543_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    jmp .L543_0
.globl zyl_region_recycle
zyl_region_recycle:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
.L544_0:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    and rsi, -2
    mov r12, rsi
    cmp r12, 0
    jne .L544_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L544_1:
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dlast_x2Dblock
    mov rsi, rax
    mov r13, rsi
    mov rsi, r13
    add rsi, 16
    mov rdx, rsi
    mov eax, dword ptr [rdx]
    mov rsi, rax
    cmp rsi, 1
    jne .L544_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L544_2:
    mov rdi, r12
    mov rsi, r13
    call zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dchain
    mov rsi, rax
    mov rdi, rbx
    mov rsi, r13
    call zy_local_x2Fmain_0__alloc__rt_x2Drset_x2Dblocks
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdi, r13
    add rdi, 24
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdi, r13
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, r13
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_region_exit
zyl_region_exit:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L545_0:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    and rsi, -2
    cmp rsi, 0
    jle .L545_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    mov rsi, rax
    jmp .L545_2
.L545_1:
    mov rdi, 0
    mov rsi, rdi
.L545_2:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    mov rsi, rax
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    cmp rsi, rbx
    jne .L545_3
    mov rsi, 0
    mov rax, rsi
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    mov rsi, rax
    jmp .L545_4
.L545_3:
    mov rdi, 0
    mov rsi, rdi
.L545_4:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_region_unwind
zyl_region_unwind:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L546_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rsi, rax
    mov r12, rsi
    cmp r12, 0
    jne .L546_2
    jmp .L546_3
.L546_2:
    cmp r12, rbx
    jne .L546_1
.L546_3:
    mov rsi, 0
    mov rax, rsi
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L546_1:
    mov rsi, r12
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    and rsi, -2
    cmp rsi, 0
    jle .L546_4
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    mov rsi, rax
    jmp .L546_5
.L546_4:
    mov rdi, 0
    mov rsi, rdi
.L546_5:
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    mov rsi, rax
    jmp .L546_0
.globl zyl_region_mark
zyl_region_mark:
    push rbp
    mov rbp, rsp
.L547_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_region_live_bytes
zyl_region_live_bytes:
    push rbp
    mov rbp, rsp
.L548_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dtls:
    push rbp
    mov rbp, rsp
.L549_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_cur_region@tpoff]
    mov rsi, rax
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_region_top@tpoff]
    mov rdi, rax
    add rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dret:
    push rbp
    mov rbp, rsp
.L550_0:
    cmp rdi, 0
    jge .L550_1
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L550_1:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dbad:
    push rbp
    mov rbp, rsp
.L551_0:
    cmp rdi, 0
    jle .L551_1
    cmp rdi, 4096
    jge .L551_1
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rsi, rax
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L551_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_file_open_c
zyl_file_open_c:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L552_0:
    cmp rsi, 4096
    jge .L552_1
    mov r8, 0
    jmp .L552_2
.L552_1:
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov r8, rsi
.L552_2:
    cmp r8, 114
    jne .L552_3
    mov rsi, 0
    jmp .L552_4
.L552_3:
    cmp r8, 97
    jne .L552_5
    mov r8, 1089
    jmp .L552_6
.L552_5:
    mov r9, 577
    mov r8, r9
.L552_6:
    mov rsi, r8
.L552_4:
    mov r8, 420
    mov rdx, r8
    call zyl_rt_sys_2
    mov rsi, rax
    cmp rsi, 0
    jge .L552_7
    mov rdi, -1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L552_7:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dread:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov rdi, rdx
.L553_0:
    cmp rsi, 0
    jge .L553_1
    mov r8, 0
    jmp .L553_2
.L553_1:
    cmp rsi, 67108864
    jle .L553_3
    mov r9, 67108864
    jmp .L553_4
.L553_3:
    mov r9, rsi
.L553_4:
    mov r8, r9
.L553_2:
    mov r12, r8
    mov rsi, r12
    add rsi, 1
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_ralloc
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L553_5
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L553_5:
    mov rdi, rbx
    mov rsi, r13
    mov rdx, r12
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jge .L553_6
    mov rdi, 0
    jmp .L553_7
.L553_6:
    mov rdi, rsi
.L553_7:
    mov rsi, r13
    add rsi, rdi
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
.globl zyl_file_read_c
zyl_file_read_c:
    push rbp
    mov rbp, rsp
.L554_0:
    mov r8, 0
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dread
.globl zyl_file_read_c_r
zyl_file_read_c_r:
    push rbp
    mov rbp, rsp
.L555_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r8, rax
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dread
.globl zyl_file_write_c
zyl_file_write_c:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L556_0:
    mov r12, rsi
    cmp r12, 0
    jne .L556_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L556_1:
    lea rax, [rip+.L557]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dbad
    mov rsi, rax
    cmp rsi, 0
    je .L556_2
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L556_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jge .L556_3
    mov rdi, -1
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L556_3:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_file_close_c
zyl_file_close_c:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L558_0:
    call zyl_rt_sys_3
    mov rsi, rax
    cmp rsi, 0
    jge .L558_1
    mov rdi, -1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L558_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_path_exists
zyl_path_exists:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L559_0:
    mov rsi, 0
    call zyl_rt_sys_21
    mov rsi, rax
    cmp rsi, 0
    jne .L559_1
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L559_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_chdir
zyl_chdir:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L560_0:
    call zyl_rt_sys_80
    mov rsi, rax
    cmp rsi, 0
    jge .L560_1
    mov rdi, -1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L560_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_getcwd
zyl_getcwd:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L561_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_cwd@tpoff]
    mov rsi, rax
    mov rbx, rsi
    mov rsi, 4096
    mov rdi, rbx
    call zyl_rt_sys_79
    mov rsi, rax
    cmp rsi, 0
    jg .L561_2
    jmp .L561_3
.L561_2:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 47
    jne .L561_4
    mov rsi, 0
    jmp .L561_5
.L561_4:
    mov rdi, 1
    mov rsi, rdi
.L561_5:
    cmp rsi, 0
    je .L561_1
.L561_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L561_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r12, rsi
    mov rsi, r12
    add rsi, 1
    mov rdi, rsi
    call zyl_heap_alloc
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L561_6
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L561_6:
    mov rsi, r12
    add rsi, 1
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mkdir_p
zyl_mkdir_p:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
.L562_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L562_2
    jmp .L562_3
.L562_2:
    lea rax, [rip+.L563]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    mov rsi, rax
    cmp rsi, 0
    je .L562_1
.L562_3:
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L562_1:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L562_4
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L562_4:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r12, rsi
    cmp r12, 4096
    jl .L562_5
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L562_5:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_mkdir@tpoff]
    mov rsi, rax
    mov r13, rsi
    mov rsi, r12
    add rsi, 1
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, 1
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Dparents
    mov rsi, rax
    cmp rsi, 0
    je .L562_6
    mov rdi, r13
    call zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Done
    mov rsi, rax
    cmp rsi, 0
    je .L562_7
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L562_7:
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L562_6:
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Done:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L564_0:
    mov rsi, 493
    call zyl_rt_sys_83
    mov rsi, rax
    cmp rsi, 0
    jne .L564_1
    mov rdi, 1
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L564_1:
    mov rax, rsi
    cmp rax, -17
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Dparents:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L565_0:
    cmp r13, r12
    jl .L565_1
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L565_1:
    mov rsi, rbx
    add rsi, r13
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 47
    jne .L565_2
    mov rsi, rbx
    add rsi, r13
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, 493
    mov rdi, rbx
    call zyl_rt_sys_83
    mov rsi, rax
    cmp rsi, 0
    jne .L565_3
    mov rdi, 1
    jmp .L565_4
.L565_3:
    mov rax, rsi
    cmp rax, -17
    sete al
    movzx rax, al
    mov rsi, rax
    mov rdi, rsi
.L565_4:
    mov rsi, rbx
    add rsi, r13
    mov r8, 47
    mov rdx, rsi
    mov rcx, r8
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    cmp rdi, 0
    je .L565_5
    mov rsi, r13
    add rsi, 1
    mov r13, rsi
    jmp .L565_0
.L565_5:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L565_2:
    mov rsi, r13
    add rsi, 1
    mov r13, rsi
    jmp .L565_0
.globl zyl_save_args
zyl_save_args:
    push rbp
    mov rbp, rsp
.L566_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov r8, rax
    mov r9, 4294967295
    and rdi, r9
    cmp rdi, 2147483647
    jle .L566_1
    mov r9, 4294967296
    mov rax, rdi
    mov rcx, r9
    sub rax, rcx
    mov r9, rax
    jmp .L566_2
.L566_1:
    mov r9, rdi
.L566_2:
    mov rdx, r8
    mov rcx, r9
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, r8
    add rdi, 8
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_argc
zyl_argc:
    push rbp
    mov rbp, rsp
.L567_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov rsi, rax
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_arg_str
zyl_arg_str:
    push rbp
    mov rbp, rsp
.L568_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov rsi, rax
    cmp rdi, 0
    jge .L568_2
    jmp .L568_3
.L568_2:
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp rdi, r8
    jl .L568_1
.L568_3:
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L568_1:
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    imul rdi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dcat3:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 32
    mov rbx, rdi
    mov r12, rsi
    mov qword ptr [rbp-48], rdx
    mov r14, rcx
.L569_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r15, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r13, rsi
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov qword ptr [rbp-56], rsi
    mov rsi, r13
    add rsi, qword ptr [rbp-56]
    add rsi, r15
    mov rdi, r14
    sub rdi, 1
    cmp rsi, rdi
    jle .L569_1
    mov rdi, r14
    sub rdi, 1
    jmp .L569_2
.L569_1:
    mov rdi, rsi
.L569_2:
    mov r14, rdi
    mov rsi, r14
    add rsi, 1
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov qword ptr [rbp-64], rsi
    cmp qword ptr [rbp-64], 0
    jne .L569_3
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
.L569_3:
    mov rsi, 0
    mov rdi, qword ptr [rbp-64]
    mov rdx, rbx
    mov rcx, r15
    mov r8, r14
    call zy_local_x2Fmain_0__os__os_x2Dput
    mov rsi, rax
    mov rdi, qword ptr [rbp-64]
    mov rsi, r15
    mov rdx, r12
    mov rcx, r13
    mov r8, r14
    call zy_local_x2Fmain_0__os__os_x2Dput
    mov rsi, rax
    mov rsi, r15
    add rsi, r13
    mov rdi, qword ptr [rbp-64]
    mov rdx, qword ptr [rbp-48]
    mov rcx, qword ptr [rbp-56]
    mov r8, r14
    call zy_local_x2Fmain_0__os__os_x2Dput
    mov rsi, rax
    mov rsi, qword ptr [rbp-64]
    add rsi, r14
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, qword ptr [rbp-64]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dput:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L570_0:
    cmp rsi, r10
    jl .L570_1
    mov rbx, 0
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L570_1:
    add rdi, rsi
    mov rbx, rsi
    add rbx, r9
    cmp rbx, r10
    jle .L570_2
    mov rax, r10
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    jmp .L570_3
.L570_2:
    mov rsi, r9
.L570_3:
    mov rdx, rsi
    mov rsi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy
zy_local_x2Fmain_0__os__os_x2Dsep:
    push rbp
    mov rbp, rsp
.L571_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L571_1
    lea rax, [rip+.L572]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L571_1:
    lea rax, [rip+.L573]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dhas_x2Dsuffix:
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
.L574_0:
    mov rdi, r13
    call zy_local_x2Fmain_0__os__os_x2Dskip_x2Dsp
    mov rsi, rax
    mov r14, rsi
    mov rdx, r14
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L574_1
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
.L574_1:
    mov rdi, r14
    call zy_local_x2Fmain_0__os__os_x2Dword_x2Dend
    mov rsi, rax
    mov r15, rsi
    mov rsi, r15
    sub rsi, r14
    cmp rsi, 0
    jle .L574_2
    cmp r12, rsi
    jle .L574_2
    mov rdi, r12
    sub rdi, rsi
    add rdi, rbx
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    mov rsi, rax
    cmp rsi, 0
    je .L574_2
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
.L574_2:
    mov r13, r15
    jmp .L574_0
zy_local_x2Fmain_0__os__os_x2Dskip_x2Dsp:
    push rbp
    mov rbp, rsp
.L575_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 32
    jne .L575_1
    mov rsi, rdi
    add rsi, 1
    mov rdi, rsi
    jmp .L575_0
.L575_1:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dword_x2Dend:
    push rbp
    mov rbp, rsp
.L576_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L576_2
    jmp .L576_3
.L576_2:
    cmp rsi, 32
    jne .L576_1
.L576_3:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L576_1:
    mov rsi, rdi
    add rsi, 1
    mov rdi, rsi
    jmp .L576_0
zy_local_x2Fmain_0__os__os_x2Dpush:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L577_0:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp r13, rsi
    jne .L577_1
    cmp rsi, 0
    jne .L577_2
    mov rdi, 64
    jmp .L577_3
.L577_2:
    imul rsi, 2
    mov rdi, rsi
.L577_3:
    mov r14, rdi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r14
    imul rdi, 8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call realloc
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jne .L577_4
    mov rdi, r12
    call free
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L577_4:
    mov rdx, rbx
    mov rcx, r15
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 16
    mov rdx, rsi
    mov rcx, r14
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    jmp .L577_0
.L577_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r13
    imul rdi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdi, r13
    add rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dwalk:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 32
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L578_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dsep
    mov rsi, rax
    mov rdi, 4096
    mov rdx, r12
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dcat3
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jne .L578_1
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
.L578_1:
    mov rsi, 591872
    mov rdi, 0
    mov rdx, rdi
    mov rdi, r15
    call zyl_rt_sys_2
    mov rsi, rax
    mov qword ptr [rbp-48], rsi
    mov rdi, r15
    call free
    mov rsi, rax
    cmp qword ptr [rbp-48], 0
    jge .L578_2
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
.L578_2:
    mov rsi, 32768
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov qword ptr [rbp-56], rsi
    cmp qword ptr [rbp-56], 0
    jne .L578_3
    mov rsi, 0
    mov r15, rsi
    jmp .L578_4
.L578_3:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    mov r8, qword ptr [rbp-48]
    mov r9, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dfill
    mov rsi, rax
    mov r15, rsi
.L578_4:
    mov rdi, qword ptr [rbp-56]
    call free
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    call zyl_rt_sys_3
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dfill:
    push rbp
    mov rbp, rsp
    sub rsp, 168
    mov [rbp-168], rbx
    mov [rbp-160], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    sub rsp, 8
    sub rsp, 24
    mov rdi, [rbp-40]
    mov rsi, [rbp-48]
    mov rdx, 32768
    mov r12, rsp
    and rsp, -16
call zyl_rt_sys_217
    mov rsp, r12
    add rsp, 32
    mov [rbp-56], rax
    mov rax, [rbp-56]
    mov rcx, 0
    cmp rax, rcx
    jg .L579
    mov rax, 0
    jmp .L580
.L579:
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r9, [rsp+16]
    mov r8, [rsp+24]
    mov rcx, [rsp+32]
    mov rdx, [rsp+40]
    mov rsi, [rsp+48]
    mov rdi, [rsp+56]
call zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dents
    add rsp, 64
    mov [rbp-64], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov r9, [rsp+0]
    mov r8, [rsp+8]
    mov rcx, [rsp+16]
    mov rdx, [rsp+24]
    mov rsi, [rsp+32]
    mov rdi, [rsp+40]
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dfill
.L580:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dents:
    push rbp
    mov rbp, rsp
    sub rsp, 184
    mov [rbp-184], rbx
    mov [rbp-176], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    mov r10, [rbp+16]
    mov [rbp-56], r10
    mov rax, [rbp-48]
    mov rcx, [rbp-56]
    cmp rax, rcx
    jl .L581
    mov rax, 0
    jmp .L582
.L581:
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    add rax, rcx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    mov rcx, 19
    add rax, rcx
    mov [rbp-72], rax
    mov rax, [rbp-72]
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov rcx, 46
    cmp rax, rcx
    jne .L583
    mov rax, 0
    jmp .L584
.L583:
    sub rsp, 8
    sub rsp, 40
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    mov rdx, [rbp-24]
    mov rcx, [rbp-32]
    mov r8, [rbp-72]
call zy_local_x2Fmain_0__os__os_x2Dwalk_x2Done
    add rsp, 48
.L584:
    mov [rbp-80], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-64]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    movzx eax, word ptr [rdx]
    mov rcx, rax
    mov rax, [rbp-48]
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    mov [rbp+16], r10
    mov r9, [rsp+8]
    mov r8, [rsp+16]
    mov rcx, [rsp+24]
    mov rdx, [rsp+32]
    mov rsi, [rsp+40]
    mov rdi, [rsp+48]
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dents
.L582:
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dwalk_x2Done:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 32
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov qword ptr [rbp-56], rcx
    mov r15, r8
.L585_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dsep
    mov rsi, rax
    mov rdi, 4096
    mov rdx, r15
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dcat3
    mov rsi, rax
    mov qword ptr [rbp-48], rsi
    cmp qword ptr [rbp-48], 0
    jne .L585_1
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
.L585_1:
    lea rax, [rip+.L586]
    mov rsi, rax
    mov rdi, 8200
    mov rdx, qword ptr [rbp-48]
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dcat3
    mov rsi, rax
    mov r15, rsi
    cmp r15, 0
    jne .L585_2
    mov rdi, qword ptr [rbp-48]
    call free
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L585_2:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_stat@tpoff]
    mov rsi, rax
    mov r12, rsi
    mov rdi, r15
    mov rsi, r12
    call zyl_rt_sys_4
    mov rsi, rax
    mov r14, rsi
    mov rdi, r15
    call free
    mov rsi, rax
    cmp r14, 0
    jne .L585_4
    mov rsi, 0
    jmp .L585_5
.L585_4:
    mov rdi, 1
    mov rsi, rdi
.L585_5:
    cmp rsi, 0
    je .L585_3
    mov rdi, qword ptr [rbp-48]
    call free
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L585_3:
    mov rsi, r12
    add rsi, 24
    mov rdx, rsi
    mov eax, dword ptr [rdx]
    mov rsi, rax
    and rsi, 61440
    cmp rsi, 16384
    jne .L585_6
    mov rdi, rbx
    mov rsi, qword ptr [rbp-48]
    mov rdx, r13
    mov rcx, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__os__os_x2Dwalk
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    call free
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L585_6:
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    mov rdx, r13
    call zy_local_x2Fmain_0__os__os_x2Dhas_x2Dsuffix
    mov rsi, rax
    cmp rsi, 0
    je .L585_7
    mov rdi, qword ptr [rbp-56]
    mov rsi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dpush
.L585_7:
    mov rdi, qword ptr [rbp-48]
    call free
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dsort:
    push rbp
    mov rbp, rsp
    sub rsp, 168
    mov [rbp-168], rbx
    mov [rbp-160], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov rax, [rbp-32]
    mov rcx, [rbp-24]
    sub rax, rcx
    mov rcx, 2
    cmp rax, rcx
    jge .L587
    mov rax, 0
    jmp .L588
.L587:
    mov rax, [rbp-32]
    mov rcx, [rbp-24]
    sub rax, rcx
    mov rcx, 2
    cqo
    idiv rcx
    mov rcx, rax
    mov rax, [rbp-24]
    add rax, rcx
    mov [rbp-40], rax
    sub rsp, 32
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    mov rdx, [rbp-24]
    mov rcx, [rbp-40]
call zy_local_x2Fmain_0__os__os_x2Dsort
    add rsp, 32
    mov [rbp-48], rax
    sub rsp, 32
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    mov rdx, [rbp-40]
    mov rcx, [rbp-32]
call zy_local_x2Fmain_0__os__os_x2Dsort
    add rsp, 32
    mov [rbp-56], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r9, [rsp+16]
    mov r8, [rsp+24]
    mov rcx, [rsp+32]
    mov rdx, [rsp+40]
    mov rsi, [rsp+48]
    mov rdi, [rsp+56]
call zy_local_x2Fmain_0__os__os_x2Dmerge
    add rsp, 64
    mov [rbp-64], rax
    mov rax, [rbp-24]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-16]
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    mov rcx, [rbp-24]
    sub rax, rcx
    mov rcx, 8
    imul rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rdx, [rsp+0]
    mov rsi, [rsp+8]
    mov rdi, [rsp+16]
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy
.L588:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dmerge:
    push rbp
    mov rbp, rsp
    sub rsp, 168
    mov [rbp-168], rbx
    mov [rbp-160], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    mov r10, [rbp+16]
    mov [rbp-56], r10
    mov rax, [rbp-24]
    mov rcx, [rbp-32]
    cmp rax, rcx
    jl .L591
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    cmp rax, rcx
    setge al
    movzx rax, al
    jmp .L592
.L591:
    mov rax, 0
.L592:
    test rax, rax
    je .L589
    mov rax, 0
    jmp .L590
.L589:
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    cmp rax, rcx
    jl .L595
    mov rax, 1
    jmp .L596
.L595:
    mov rax, [rbp-24]
    mov rcx, [rbp-32]
    cmp rax, rcx
    jge .L597
    mov rax, [rbp-24]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rsi, [rsp+0]
    mov rdi, [rsp+8]
call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    add rsp, 16
    mov rcx, 0
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L598
.L597:
    mov rax, 0
.L598:
.L596:
    test rax, rax
    je .L593
    mov rax, [rbp-56]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-16]
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-64], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    mov [rbp+16], r10
    mov r9, [rsp+8]
    mov r8, [rsp+16]
    mov rcx, [rsp+24]
    mov rdx, [rsp+32]
    mov rsi, [rsp+40]
    mov rdi, [rsp+48]
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dmerge
    jmp .L594
.L593:
    mov rax, [rbp-56]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-16]
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-72], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    mov [rbp+16], r10
    mov r9, [rsp+8]
    mov r8, [rsp+16]
    mov rcx, [rsp+24]
    mov rdx, [rsp+32]
    mov rsi, [rsp+40]
    mov rdi, [rsp+48]
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dmerge
.L594:
.L590:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dtotal:
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
.L599_0:
    cmp r12, r13
    jl .L599_1
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L599_1:
    mov rsi, r12
    add rsi, 1
    mov r15, rsi
    mov rsi, r12
    imul rsi, 8
    add rsi, rbx
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    add rsi, 1
    add rsi, r14
    mov r12, r15
    mov r14, rsi
    jmp .L599_0
zy_local_x2Fmain_0__os__os_x2Demit:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 32
    mov qword ptr [rbp-48], rdi
    mov qword ptr [rbp-56], rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L600_0:
    cmp qword ptr [rbp-56], r13
    jl .L600_1
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L600_1:
    mov rsi, qword ptr [rbp-56]
    imul rsi, 8
    add rsi, qword ptr [rbp-48]
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r12, rsi
    mov rsi, r14
    add rsi, r15
    mov rdi, rsi
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, r15
    add rsi, r12
    add rsi, r14
    mov rdi, 10
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rdi, rbx
    call free
    mov rsi, rax
    mov rsi, qword ptr [rbp-56]
    add rsi, 1
    mov rdi, r12
    add rdi, 1
    add rdi, r15
    mov qword ptr [rbp-56], rsi
    mov r15, rdi
    jmp .L600_0
zy_local_x2Fmain_0__os__os_x2Dfree_x2Dall:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L601_0:
    cmp r12, r13
    jl .L601_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L601_1:
    mov rsi, r12
    imul rsi, 8
    add rsi, rbx
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call free
    mov rsi, rax
    mov rsi, r12
    add rsi, 1
    mov r12, rsi
    jmp .L601_0
zy_local_x2Fmain_0__os__os_x2Djoin:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L602_0:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    cmp r13, 2
    jge .L602_1
    mov rsi, 0
    mov r14, rsi
    jmp .L602_2
.L602_1:
    mov rsi, r13
    imul rsi, 8
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov r14, rsi
.L602_2:
    cmp r14, 0
    jne .L602_3
    mov rsi, 0
    mov r15, rsi
    jmp .L602_4
.L602_3:
    mov rsi, 0
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r14
    mov rcx, r13
    call zy_local_x2Fmain_0__os__os_x2Dsort
    mov rsi, rax
    mov rdi, r14
    call free
    mov rsi, rax
    mov r15, rsi
.L602_4:
    mov rsi, 0
    mov rdi, 1
    mov rdx, r13
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dtotal
    mov rsi, rax
    mov rdi, rsi
    call zyl_heap_alloc
    mov rsi, rax
    mov r14, rsi
    cmp r14, 0
    jne .L602_5
    mov rsi, 0
    mov rdi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__os__os_x2Dfree_x2Dall
    mov rsi, rax
    mov rdi, r12
    call free
    mov rsi, rax
    mov rdi, rbx
    call free
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
.L602_5:
    mov rsi, 0
    mov rdi, 0
    mov rdx, r13
    mov rcx, r14
    mov r8, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Demit
    mov rsi, rax
    add rsi, r14
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rdi, r12
    call free
    mov rsi, rax
    mov rdi, rbx
    call free
    mov rsi, rax
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dlist:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L603_0:
    mov rsi, 24
    mov rdi, rsi
    call malloc
    mov rsi, rax
    mov r13, rsi
    cmp r13, 0
    jne .L603_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L603_1:
    mov rsi, 0
    mov rdx, r13
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 8
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    cmp rbx, 0
    jne .L603_4
    jmp .L603_5
.L603_4:
    cmp r12, 0
    jne .L603_2
.L603_5:
    mov rsi, 0
    mov r14, rsi
    jmp .L603_3
.L603_2:
    lea rax, [rip+.L604]
    mov rsi, rax
    mov rdi, rbx
    mov rdx, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__os__os_x2Dwalk
    mov rsi, rax
    mov r14, rsi
.L603_3:
    mov rdi, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Djoin
.globl zyl_list_zyl_files
zyl_list_zyl_files:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L605_0:
    mov rbx, rdi
    lea rax, [rip+.L606]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    mov rsi, rax
    cmp rsi, 0
    je .L605_1
    mov rsi, 0
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.L605_1:
    lea rax, [rip+.L607]
    mov rsi, rax
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.globl zyl_list_files
zyl_list_files:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L608_0:
    mov rbx, rdi
    mov r12, rsi
    lea rax, [rip+.L609]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    mov rsi, rax
    cmp rsi, 0
    je .L608_2
    jmp .L608_3
.L608_2:
    lea rax, [rip+.L610]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dbad
    mov rsi, rax
    cmp rsi, 0
    je .L608_1
.L608_3:
    mov rsi, 0
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.L608_1:
    mov rdi, rbx
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
zy_local_x2Fmain_0__os__os_x2Dterm_x2Dstate:
    push rbp
    mov rbp, rsp
.L611_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dterm_x2Dsaved:
    push rbp
    mov rbp, rsp
.L612_0:
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_is_tty
zyl_term_is_tty:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L613_0:
    mov rsi, 21505
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_tios@tpoff]
    mov r8, rax
    mov rdx, r8
    call zyl_rt_sys_16
    mov rsi, rax
    cmp rsi, 0
    jne .L613_1
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L613_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dtcset:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L614_0:
    mov rsi, 0
    mov r8, 21508
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r8
    call zyl_rt_sys_16
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_restore_atexit
zyl_term_restore_atexit:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L615_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rsi, rax
    mov rbx, rsi
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 1
    jne .L615_1
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 1
    jne .L615_1
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rdi, 0
    mov r8, 21508
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_16
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 1
    lea rax, [rip+.L616]
    mov rdi, rax
    mov r8, 12
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_1
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L615_1:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_raw_on
zyl_term_raw_on:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L617_0:
    mov rsi, 0
    mov rdi, rsi
    call zyl_term_is_tty
    mov rsi, rax
    cmp rsi, 0
    jne .L617_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L617_1:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rsi, rax
    mov rbx, rsi
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 1
    jne .L617_2
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L617_2:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 1
    jne .L617_3
    mov rsi, 1
    mov r12, rsi
    jmp .L617_4
.L617_3:
    mov rsi, 0
    mov rdi, 21505
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov r8, rax
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_16
    mov rsi, rax
    cmp rsi, 0
    jne .L617_5
    mov rsi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    call zyl_term_atexit
    mov rsi, rax
    mov rsi, 1
    jmp .L617_6
.L617_5:
    mov rdi, 0
    mov rsi, rdi
.L617_6:
    mov r12, rsi
.L617_4:
    cmp r12, 0
    je .L617_8
    mov rsi, 0
    jmp .L617_9
.L617_8:
    mov rdi, 1
    mov rsi, rdi
.L617_9:
    cmp rsi, 0
    je .L617_7
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L617_7:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_tios@tpoff]
    mov rsi, rax
    mov r12, rsi
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rdi, 64
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rdx, r12
    mov eax, dword ptr [rdx]
    mov rsi, rax
    mov rdi, 4294967295
    xor rdi, 1330
    and rsi, rdi
    mov rdx, r12
    mov rcx, rsi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r12
    add rsi, 12
    mov rdi, r12
    add rdi, 12
    mov rdx, rdi
    mov eax, dword ptr [rdx]
    mov rdi, rax
    mov r8, 4294967295
    xor r8, 32779
    and rdi, r8
    mov rdx, rsi
    mov rcx, rdi
    mov dword ptr [rdx], ecx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r12
    add rsi, 23
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, r12
    add rsi, 22
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rdi, 21508
    mov rdx, r12
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_16
    mov rsi, rax
    cmp rsi, 0
    jne .L617_11
    mov rsi, 0
    jmp .L617_12
.L617_11:
    mov rdi, 1
    mov rsi, rdi
.L617_12:
    cmp rsi, 0
    je .L617_10
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L617_10:
    mov rsi, rbx
    add rsi, 8
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_raw_off
zyl_term_raw_off:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L618_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rsi, rax
    mov rbx, rsi
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 1
    jne .L618_4
    mov rsi, 0
    jmp .L618_5
.L618_4:
    mov rdi, 1
    mov rsi, rdi
.L618_5:
    cmp rsi, 0
    je .L618_2
    jmp .L618_3
.L618_2:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 1
    jne .L618_6
    mov rsi, 0
    jmp .L618_7
.L618_6:
    mov rdi, 1
    mov rsi, rdi
.L618_7:
    cmp rsi, 0
    je .L618_1
.L618_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L618_1:
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rdi, 0
    mov r8, 21508
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_16
    mov rsi, rax
    cmp rsi, 0
    jne .L618_9
    mov rsi, 0
    jmp .L618_10
.L618_9:
    mov rdi, 1
    mov rsi, rdi
.L618_10:
    cmp rsi, 0
    je .L618_8
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L618_8:
    mov rsi, rbx
    add rsi, 8
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_read_byte
zyl_term_read_byte:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L619_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_byte@tpoff]
    mov rsi, rax
    mov rbx, rsi
    mov rsi, 0
    mov rdi, 1
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 1
    jne .L619_1
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L619_1:
    cmp rsi, -4
    jne .L619_2
    mov rsi, -2
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L619_2:
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_read_byte_timeout
zyl_term_read_byte_timeout:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L620_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_pollfd@tpoff]
    mov rsi, rax
    mov r8, 4294967296
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    mov r8, 1
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r8
    call zyl_rt_sys_7
    mov rsi, rax
    cmp rsi, 0
    jne .L620_1
    mov rdi, -3
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L620_1:
    cmp rsi, 0
    jge .L620_2
    cmp rsi, -4
    jne .L620_3
    mov rsi, -2
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L620_3:
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L620_2:
    mov rsp, rbp
    pop rbp
    jmp zyl_term_read_byte
zy_local_x2Fmain_0__os__os_x2Dwinsz:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L621_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_winsz@tpoff]
    mov rsi, rax
    mov r13, rsi
    mov rsi, 1
    mov rdi, 21523
    mov rdx, r13
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_16
    mov rsi, rax
    cmp rsi, 0
    jne .L621_1
    mov rsi, r13
    add rsi, rbx
    mov rdx, rsi
    movzx eax, word ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jle .L621_2
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L621_2:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L621_1:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_width
zyl_term_width:
    push rbp
    mov rbp, rsp
.L622_0:
    mov rsi, 2
    mov rdi, 80
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dwinsz
.globl zyl_term_height
zyl_term_height:
    push rbp
    mov rbp, rsp
.L623_0:
    mov rsi, 0
    mov rdi, 24
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dwinsz
.globl zyl_term_write
zyl_term_write:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L624_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L624_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L624_1:
    lea rax, [rip+.L625]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    mov rsi, rax
    cmp rsi, 0
    je .L624_2
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L624_2:
    call zyl_term_flush
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dwrite_x2Dall
zy_local_x2Fmain_0__os__os_x2Dwrite_x2Dall:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L626_0:
    cmp r13, r12
    jl .L626_1
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L626_1:
    mov rsi, 1
    mov rdi, rbx
    add rdi, r13
    mov r8, r12
    sub r8, r13
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L626_2
    mov rdi, r13
    add rdi, rsi
    mov r13, rdi
    jmp .L626_0
.L626_2:
    cmp rsi, -4
    jne .L626_3
    jmp .L626_0
.L626_3:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf:
    push rbp
    mov rbp, rsp
.L627_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_uf_reset
zyl_uf_reset:
    push rbp
    mov rbp, rsp
.L628_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    add rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dgrow:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L629_0:
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L629_1
    mov rsi, 4096
    jmp .L629_2
.L629_1:
    mov rdi, rbx
    add rdi, 24
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    imul rdi, 2
    mov rsi, rdi
.L629_2:
    mov r12, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    imul rdi, 8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call realloc
    mov rsi, rax
    mov r13, rsi
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    imul rdi, 8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call realloc
    mov rsi, rax
    mov r14, rsi
    cmp r13, 0
    jne .L629_5
    jmp .L629_6
.L629_5:
    cmp r14, 0
    jne .L629_3
.L629_6:
    mov rsi, r12
    imul rsi, 16
    lea rax, [rip+.L630]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_arena_oom
    mov rsi, rax
    jmp .L629_4
.L629_3:
    mov rdi, 0
    mov rsi, rdi
.L629_4:
    mov rdx, rbx
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rcx, r14
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 24
    mov rdx, rsi
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_uf_new
zyl_uf_new:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L631_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov r12, rsi
    mov rsi, r12
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    add rdi, 24
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rsi, rdi
    jne .L631_1
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dgrow
    mov rsi, rax
    jmp .L631_2
.L631_1:
    mov rdi, 0
    mov rsi, rdi
.L631_2:
    mov rsi, r12
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, rsi
    imul r8, 8
    add rdi, r8
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, r12
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, rsi
    imul r8, 8
    add rdi, r8
    mov rdx, rdi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rdi, r12
    add rdi, 16
    mov r8, rsi
    add r8, 1
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Droot:
    push rbp
    mov rbp, rsp
.L632_0:
    mov r8, rsi
    imul r8, 8
    add r8, rdi
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp r8, rsi
    jne .L632_1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L632_1:
    mov rsi, r8
    jmp .L632_0
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dcompress:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L633_0:
    mov r9, rsi
    imul r9, 8
    add r9, rdi
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r9, r8
    jne .L633_1
    mov r10, 0
    mov rax, r10
    mov rsp, rbp
    pop rbp
    ret
.L633_1:
    mov r10, rsi
    imul r10, 8
    add r10, rdi
    mov rdx, r10
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r10, rax
    mov rsi, r9
    jmp .L633_0
.globl zyl_uf_find
zyl_uf_find:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
.L634_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    cmp rbx, 0
    jge .L634_2
    jmp .L634_3
.L634_2:
    mov rdi, rsi
    add rdi, 16
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rbx, rdi
    jl .L634_1
.L634_3:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L634_1:
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Droot
    mov rsi, rax
    mov r13, rsi
    mov rdi, r12
    mov rsi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dcompress
    mov rsi, rax
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok:
    push rbp
    mov rbp, rsp
.L635_0:
    cmp rdi, 0
    jl .L635_1
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L635_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_uf_union
zyl_uf_union:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L636_0:
    call zyl_uf_find
    mov rsi, rax
    mov r12, rsi
    mov rdi, rbx
    call zyl_uf_find
    mov rsi, rax
    mov rbx, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L636_4
    mov rsi, 0
    jmp .L636_5
.L636_4:
    mov rdi, 1
    mov rsi, rdi
.L636_5:
    cmp rsi, 0
    je .L636_2
    jmp .L636_3
.L636_2:
    mov rdi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L636_6
    mov rsi, 0
    jmp .L636_7
.L636_6:
    mov rdi, 1
    mov rsi, rdi
.L636_7:
    cmp rsi, 0
    je .L636_1
.L636_3:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L636_1:
    cmp r12, rbx
    jne .L636_8
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L636_8:
    cmp r12, rbx
    jge .L636_9
    mov rsi, r12
    jmp .L636_10
.L636_9:
    mov rsi, rbx
.L636_10:
    cmp r12, rbx
    jge .L636_11
    jmp .L636_12
.L636_11:
    mov rbx, r12
.L636_12:
    lea rax, [rip+zyl_rtg_uf]
    mov rdi, rax
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, rbx
    imul r8, 8
    add r8, rdi
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    mov r9, rsi
    imul r9, 8
    add r9, rdi
    mov rdx, r9
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r8, r9
    jle .L636_13
    mov r8, rsi
    imul r8, 8
    add r8, rdi
    mov r9, rbx
    imul r9, 8
    add rdi, r9
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov rdx, r8
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    jmp .L636_14
.L636_13:
    mov r8, 0
    mov rdi, r8
.L636_14:
    lea rax, [rip+zyl_rtg_uf]
    mov rdi, rax
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    mov r8, rbx
    imul r8, 8
    add rdi, r8
    mov rdx, rdi
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rdi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_uf_raise
zyl_uf_raise:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L637_0:
    call zyl_uf_find
    mov rsi, rax
    mov r12, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L637_2
    mov rsi, 0
    jmp .L637_3
.L637_2:
    mov rdi, 1
    mov rsi, rdi
.L637_3:
    cmp rsi, 0
    je .L637_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L637_1:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    imul rdi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    cmp rbx, rdi
    jle .L637_4
    mov rdx, rsi
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    jmp .L637_5
.L637_4:
    mov rdi, 0
    mov rsi, rdi
.L637_5:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_uf_level
zyl_uf_level:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L638_0:
    call zyl_uf_find
    mov rsi, rax
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L638_2
    mov rsi, 0
    jmp .L638_3
.L638_2:
    mov rdi, 1
    mov rsi, rdi
.L638_3:
    cmp rsi, 0
    je .L638_1
    mov rsi, 2
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L638_1:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rbx
    imul rdi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__misc__rt_x2Dnote:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L639_0:
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
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mem_alloc
zyl_mem_alloc:
    push rbp
    mov rbp, rsp
.L640_0:
    mov rsp, rbp
    pop rbp
    jmp malloc
.globl zyl_mem_free
zyl_mem_free:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L641_0:
    call free
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mem_read
zyl_mem_read:
    push rbp
    mov rbp, rsp
.L642_0:
    cmp rdi, 0
    jne .L642_1
    lea rax, [rip+.L643]
    mov rsi, rax
    mov rdi, rsi
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__misc__rt_x2Dnote
.L642_1:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mem_write
zyl_mem_write:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L644_0:
    cmp rbx, 0
    jne .L644_1
    lea rax, [rip+.L645]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__misc__rt_x2Dnote
    mov rsi, rax
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L644_1:
    mov rdx, rbx
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_byte_set
zyl_cstr_byte_set:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L646_0:
    cmp rbx, 0
    jne .L646_2
    jmp .L646_3
.L646_2:
    cmp r12, 0
    jge .L646_1
.L646_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L646_1:
    cmp rbx, 4096
    jge .L646_4
    lea rax, [rip+.L647]
    mov rsi, rax
    mov rdi, rbx
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
.L646_4:
    mov rsi, rbx
    add rsi, r12
    mov rdi, r13
    and rdi, 255
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_getenv
zyl_getenv:
    push rbp
    mov rbp, rsp
.L648_0:
    mov rsp, rbp
    pop rbp
    jmp getenv
.globl zyl_regions_enabled
zyl_regions_enabled:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L649_0:
    lea rax, [rip+.L650]
    mov rsi, rax
    mov rdi, rsi
    call getenv
    mov rsi, rax
    cmp rsi, 0
    jle .L649_1
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rdi, rax
    cmp rdi, 48
    jne .L649_1
    add rsi, 1
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L649_1
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L649_1:
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__misc__rt_x2Dlshr64:
    push rbp
    mov rbp, rsp
.L651_0:
    mov rax, rdi
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov r8, 1
    mov r9, 64
    mov rax, r9
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    mov rax, r8
    mov rcx, rsi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    sub rsi, 1
    and rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__misc__rt_x2Dzsa_x2Dindex:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L652_0:
    mov rsi, 33
    mov rdi, rbx
    call zy_local_x2Fmain_0__misc__rt_x2Dlshr64
    mov rsi, rax
    xor rsi, rbx
    mov rdi, -49064778989728563
    imul rsi, rdi
    mov rbx, rsi
    mov rsi, 33
    mov rdi, rbx
    call zy_local_x2Fmain_0__misc__rt_x2Dlshr64
    mov rsi, rax
    xor rsi, rbx
    mov rdi, -4265267296055464877
    imul rsi, rdi
    mov rbx, rsi
    mov rsi, 33
    mov rdi, rbx
    call zy_local_x2Fmain_0__misc__rt_x2Dlshr64
    mov rsi, rax
    xor rsi, rbx
    and rsi, 63
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_str_append_scan
zyl_str_append_scan:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    mov qword ptr [rbp-48], rdi
    mov r12, rsi
    mov r13, rdx
.L653_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_zsa@tpoff]
    mov rsi, rax
    mov r14, rsi
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__misc__rt_x2Dzsa_x2Dindex
    mov rsi, rax
    mov r15, rsi
    mov rsi, r15
    imul rsi, 8
    add rsi, r14
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, qword ptr [rbp-48]
    jne .L653_1
    mov rsi, r14
    add rsi, 512
    mov rdi, r15
    imul rdi, 8
    add rsi, rdi
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rbx, rsi
    jmp .L653_2
.L653_1:
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    add rsi, qword ptr [rbp-48]
    mov rbx, rsi
.L653_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov qword ptr [rbp-56], rsi
    cmp r13, 0
    jle .L653_3
    mov rsi, rbx
    sub rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-56]
    add rsi, 1
    cmp rsi, r13
    jle .L653_3
    lea rax, [rip+.L654]
    mov rsi, rax
    mov rdi, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.L653_3:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rax
    mov rsi, rbx
    add rsi, qword ptr [rbp-56]
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, r15
    imul rsi, 8
    add rsi, r14
    mov rdx, rsi
    mov rcx, qword ptr [rbp-48]
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r14
    add rsi, 512
    mov rdi, r15
    imul rdi, 8
    add rsi, rdi
    mov rdi, rbx
    add rdi, qword ptr [rbp-56]
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dmulhi:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L655_0:
    mov r8, 4294967295
    and r8, rdi
    mov r9, 32
    mov rax, rdi
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov r9, 4294967295
    and r9, rsi
    mov r10, 32
    mov rax, rsi
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    mov r10, r8
    imul r10, r9
    imul r8, rsi
    imul r9, rdi
    mov rbx, 32
    mov rax, r10
    mov rcx, rbx
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov rbx, 4294967295
    and rbx, r8
    add r10, rbx
    mov rbx, 4294967295
    and rbx, r9
    add r10, rbx
    imul rsi, rdi
    mov rdi, 32
    mov rax, r8
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    add rsi, rdi
    mov rdi, 32
    mov rax, r9
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    add rsi, rdi
    mov rdi, 32
    mov rax, r10
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    add rsi, rdi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dclz:
    push rbp
    mov rbp, rsp
.L656_0:
    mov rsi, 0
    mov r8, 32
    mov rdx, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo
zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
.L657_0:
    cmp r8, 0
    jne .L657_1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L657_1:
    mov r9, 64
    sub r9, r8
    mov rax, rdi
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, 1
    mov rax, r10
    mov rcx, r8
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    sub r10, 1
    and r9, r10
    cmp r9, 0
    jne .L657_2
    mov rax, rdi
    mov rcx, r8
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, rsi
    add r10, r8
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 63
    add rax, rcx
    sar rax, 1
    mov rbx, rax
    mov rdi, r9
    mov rsi, r10
    mov r8, rbx
    jmp .L657_0
.L657_2:
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 63
    add rax, rcx
    sar rax, 1
    mov r9, rax
    mov r8, r9
    jmp .L657_0
zy_local_x2Fmain_0__fmt__fm_x2Disdig:
    push rbp
    mov rbp, rsp
.L658_0:
    cmp rdi, 48
    jl .L658_1
    mov rax, rdi
    cmp rax, 57
    setle al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L658_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dtab:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L659_0:
    lea rax, [rip+zyl_rtg_fmt_tab]
    mov rsi, rax
    mov rbx, rsi
    mov rsi, rbx
    add rsi, 10600
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 1
    jne .L659_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L659_1:
    lea rax, [rip+.L660]
    mov rsi, rax
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dtab_x2Dfill
    mov rsi, rax
    mov rsi, rbx
    add rsi, 10416
    mov rdi, 0
    movsd xmm0, [rip+.L661]
    movq rax, xmm0
    mov r8, rax
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dp10_x2Dfill
    mov rsi, rax
    mfence
    xor eax, eax
    mov rsi, rax
    mov rsi, rbx
    add rsi, 10600
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dhex16:
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
.L662_0:
    cmp r12, 16
    jne .L662_1
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L662_1:
    mov rsi, r12
    add rsi, 1
    mov r14, rsi
    mov r15, r13
    imul r15, 16
    mov rsi, rbx
    add rsi, r12
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    add rsi, r15
    mov r12, r14
    mov r13, rsi
    jmp .L662_0
zy_local_x2Fmain_0__fmt__fm_x2Dtab_x2Dfill:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L663_0:
    cmp r13, 1302
    jne .L663_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L663_1:
    mov rsi, r13
    imul rsi, 8
    mov r14, rbx
    add r14, rsi
    mov rsi, r13
    imul rsi, 16
    add rsi, r12
    mov rdi, 0
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dhex16
    mov rsi, rax
    mov rdx, r14
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r13
    add rsi, 1
    mov r13, rsi
    jmp .L663_0
zy_local_x2Fmain_0__fmt__fm_x2Dp10_x2Dfill:
    push rbp
    mov rbp, rsp
    sub rsp, 136
    mov [rbp-136], rbx
    mov [rbp-128], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-16]
    mov rcx, 23
    cmp rax, rcx
    jne .L664
    mov rax, 0
    jmp .L665
.L664:
    mov rax, [rbp-16]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-32], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    push rax
    movsd xmm0, [rip+.L666]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    mulsd xmm0, xmm1
    movq rax, xmm0
    sub rsp, 8
    mov [rsp], rax
    mov rdx, [rsp+0]
    mov rsi, [rsp+8]
    mov rdi, [rsp+16]
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dp10_x2Dfill
.L665:
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dp5_x2Dhex:
    push rbp
    mov rbp, rsp
.L667_0:
    lea rax, [rip+.L668]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dspace:
    push rbp
    mov rbp, rsp
.L669_0:
    cmp rdi, 32
    jne .L669_1
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L669_1:
    cmp rdi, 9
    jl .L669_2
    mov rax, rdi
    cmp rax, 13
    setle al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L669_2:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dskip_x2Dws:
    push rbp
    mov rbp, rsp
.L670_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 32
    jne .L670_2
    mov r8, 1
    jmp .L670_3
.L670_2:
    cmp rsi, 9
    jl .L670_4
    mov rax, rsi
    cmp rax, 13
    setle al
    movzx rax, al
    mov rsi, rax
    jmp .L670_5
.L670_4:
    mov r9, 0
    mov rsi, r9
.L670_5:
    mov r8, rsi
.L670_3:
    cmp r8, 0
    je .L670_1
    mov rsi, rdi
    add rsi, 1
    mov rdi, rsi
    jmp .L670_0
.L670_1:
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_parse
zyl_f_parse:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L671_0:
    cmp rdi, 0
    jne .L671_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L671_1:
    call zy_local_x2Fmain_0__fmt__fm_x2Dskip_x2Dws
    mov rsi, rax
    mov rbx, rsi
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    cmp r12, 45
    jne .L671_2
    mov rsi, rbx
    add rsi, 1
    mov rdi, rsi
    call zy_local_x2Fmain_0__fmt__fm_x2Dbody
    mov rsi, rax
    mov rdi, -9223372036854775808
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dsigned
.L671_2:
    cmp r12, 43
    jne .L671_3
    mov rsi, rbx
    add rsi, 1
    jmp .L671_4
.L671_3:
    mov rsi, rbx
.L671_4:
    mov rdi, rsi
    call zy_local_x2Fmain_0__fmt__fm_x2Dbody
    mov rsi, rax
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dsigned
zy_local_x2Fmain_0__fmt__fm_x2Dsigned:
    push rbp
    mov rbp, rsp
.L672_0:
    cmp rdi, -1
    jne .L672_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L672_1:
    or rsi, rdi
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dbody:
    push rbp
    mov rbp, rsp
    sub rsp, 120
    mov [rbp-120], rbx
    mov [rbp-112], r12
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov rcx, 32
    or rax, rcx
    mov [rbp-16], rax
    mov rax, [rbp-16]
    mov rcx, 105
    cmp rax, rcx
    jne .L673
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dinf_x2Dword
    jmp .L674
.L673:
    mov rax, [rbp-16]
    mov rcx, 110
    cmp rax, rcx
    jne .L675
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dword
    jmp .L676
.L675:
    mov rax, [rbp-8]
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov rcx, 48
    cmp rax, rcx
    jne .L679
    mov rax, [rbp-8]
    mov rcx, 1
    add rax, rcx
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov rcx, 32
    or rax, rcx
    mov rcx, 120
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L680
.L679:
    mov rax, 0
.L680:
    test rax, rax
    je .L677
    sub rsp, 8
    sub rsp, 40
    mov rax, [rbp-8]
    mov rcx, 2
    add rax, rcx
    mov rdi, rax
    mov rsi, 0
    mov rdx, 0
    mov rcx, 0
    mov r8, 0
call zy_local_x2Fmain_0__fmt__fh_x2Dint
    add rsp, 48
    mov [rbp-24], rax
    mov rax, [rbp-24]
    mov rcx, -1
    cmp rax, rcx
    jne .L681
    mov rax, 0
    jmp .L682
.L681:
    mov rax, [rbp-24]
.L682:
    jmp .L678
.L677:
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov rax, 0
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r9, [rsp+16]
    mov r8, [rsp+24]
    mov rcx, [rsp+32]
    mov rdx, [rsp+40]
    mov rsi, [rsp+48]
    mov rdi, [rsp+56]
call zy_local_x2Fmain_0__fmt__fd_x2Dscan
    add rsp, 64
.L678:
.L676:
.L674:
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dinf_x2Dword:
    push rbp
    mov rbp, rsp
.L683_0:
    mov rsi, rdi
    add rsi, 1
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    or rsi, 32
    cmp rsi, 110
    jne .L683_1
    mov rsi, rdi
    add rsi, 2
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    or rsi, 32
    cmp rsi, 102
    jne .L683_1
    mov rsi, 9218868437227405312
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L683_1:
    mov rsi, -1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dword:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L684_0:
    mov rsi, rdi
    add rsi, 1
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    or rsi, 32
    cmp rsi, 97
    jne .L684_1
    mov rsi, rdi
    add rsi, 2
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    or rsi, 32
    cmp rsi, 110
    jne .L684_1
    mov rsi, rdi
    add rsi, 3
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 40
    jne .L684_2
    mov rbx, rdi
    add rbx, 4
    mov rsi, rdi
    add rsi, 4
    mov rdi, rsi
    call zy_local_x2Fmain_0__fmt__fm_x2Dseq_x2Dend
    mov rsi, rax
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dseq
.L684_2:
    mov rsi, 9221120237041090560
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L684_1:
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dalnum:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L685_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Disdig
    mov rsi, rax
    cmp rsi, 0
    je .L685_1
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L685_1:
    mov rsi, rbx
    or rsi, 32
    cmp rsi, 97
    jl .L685_2
    mov rsi, rbx
    or rsi, 32
    cmp rsi, 122
    jg .L685_2
    mov rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L685_2:
    mov rax, rbx
    cmp rax, 95
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dseq_x2Dend:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L686_0:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__fmt__fm_x2Dalnum
    mov rsi, rax
    cmp rsi, 0
    je .L686_1
    mov rsi, rbx
    add rsi, 1
    mov rbx, rsi
    jmp .L686_0
.L686_1:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dseq:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L687_0:
    mov rdx, r12
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 41
    jne .L687_2
    mov rsi, 0
    jmp .L687_3
.L687_2:
    mov rdi, 1
    mov rsi, rdi
.L687_3:
    cmp rsi, 0
    je .L687_1
    mov rsi, 9221120237041090560
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L687_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dend
    mov rsi, rax
    cmp rsi, r12
    jne .L687_4
    mov r12, 9221120237041090560
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull
    mov rsi, rax
    mov rdi, 2251799813685247
    and rsi, rdi
    or rsi, r12
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L687_4:
    mov rsi, 9221120237041090560
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rsi
.L688_0:
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L688_1
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setl al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L688_1:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase:
    push rbp
    mov rbp, rsp
.L689_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 48
    jne .L689_1
    mov rsi, rdi
    add rsi, 1
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    or rsi, 32
    cmp rsi, 120
    jne .L689_2
    mov rsi, rdi
    add rsi, 2
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, 16
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L689_2
    mov rsi, 16
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L689_2:
    mov rsi, 8
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L689_1:
    mov rsi, 10
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dend:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
.L690_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase
    mov rsi, rax
    mov r12, rsi
    cmp r12, 16
    jne .L690_1
    mov rsi, rbx
    add rsi, 2
    jmp .L690_2
.L690_1:
    mov rsi, rbx
.L690_2:
    mov r13, rsi
    mov rdx, r13
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L690_3
    mov rdi, r13
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Ddigits_x2Dend
.L690_3:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Ddigits_x2Dend:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L691_0:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L691_1
    mov rsi, rbx
    add rsi, 1
    mov rbx, rsi
    jmp .L691_0
.L691_1:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L692_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase
    mov rsi, rax
    cmp rsi, 16
    jne .L692_1
    mov rdi, rbx
    add rdi, 2
    jmp .L692_2
.L692_1:
    mov rdi, rbx
.L692_2:
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dgo
zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dgo:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov qword ptr [rbp-48], rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L693_0:
    mov rdx, qword ptr [rbp-48]
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov r15, rsi
    mov rdi, r15
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L693_2
    mov rsi, 0
    jmp .L693_3
.L693_2:
    mov rdi, 1
    mov rsi, rdi
.L693_3:
    cmp rsi, 0
    je .L693_1
    cmp r14, 0
    je .L693_4
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
.L693_4:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L693_1:
    cmp r14, 0
    je .L693_5
    mov rsi, qword ptr [rbp-48]
    add rsi, 1
    mov rdi, 1
    mov qword ptr [rbp-48], rsi
    mov r14, rdi
    jmp .L693_0
.L693_5:
    mov rsi, r13
    imul rsi, r12
    mov rbx, rsi
    mov rdi, r15
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    add rsi, rbx
    mov r15, rsi
    mov rdi, r13
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dmulhi
    mov rsi, rax
    cmp rsi, 0
    jne .L693_9
    mov rsi, 0
    jmp .L693_10
.L693_9:
    mov rdi, 1
    mov rsi, rdi
.L693_10:
    cmp rsi, 0
    je .L693_7
    jmp .L693_8
.L693_7:
    mov rsi, -9223372036854775808
    xor rsi, r15
    mov rdi, -9223372036854775808
    xor rdi, rbx
    cmp rsi, rdi
    jge .L693_6
.L693_8:
    mov rsi, qword ptr [rbp-48]
    add rsi, 1
    mov rdi, 1
    mov qword ptr [rbp-48], rsi
    mov r14, rdi
    jmp .L693_0
.L693_6:
    mov rsi, qword ptr [rbp-48]
    add rsi, 1
    mov rdi, 0
    mov qword ptr [rbp-48], rsi
    mov r13, r15
    mov r14, rdi
    jmp .L693_0
zy_local_x2Fmain_0__fmt__fm_x2Dexp:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L694_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    cmp rax, 45
    sete al
    movzx rax, al
    mov r8, rax
    mov rbx, r8
    cmp rsi, 45
    jne .L694_3
    jmp .L694_4
.L694_3:
    cmp rsi, 43
    jne .L694_1
.L694_4:
    mov rsi, rdi
    add rsi, 1
    jmp .L694_2
.L694_1:
    mov rsi, rdi
.L694_2:
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dgo
    mov rsi, rax
    cmp rbx, 0
    je .L694_5
    mov rdi, 0
    sub rdi, rsi
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L694_5:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dgo:
    push rbp
    mov rbp, rsp
.L695_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 48
    jl .L695_1
    cmp r8, 57
    jg .L695_1
    mov r9, rdi
    add r9, 1
    mov r10, 1000000000000000
    cmp rsi, r10
    jge .L695_2
    mov r10, rsi
    imul r10, 10
    sub r8, 48
    add r8, r10
    jmp .L695_3
.L695_2:
    mov r8, rsi
.L695_3:
    mov rdi, r9
    mov rsi, r8
    jmp .L695_0
.L695_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat:
    push rbp
    mov rbp, rsp
.L696_0:
    mov rdx, rdi
    movzx eax, byte ptr [rdx]
    mov r8, rax
    or r8, 32
    cmp r8, rsi
    jne .L696_1
    mov rsi, rdi
    add rsi, 1
    mov rdi, rsi
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dexp
.L696_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fh_x2Dint:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, rdi
    mov qword ptr [rbp-48], rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L697_0:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L697_1
    mov rdi, 56
    mov rax, qword ptr [rbp-48]
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    cmp rdi, 0
    jne .L697_2
    mov rdi, rbx
    add rdi, 1
    mov r8, qword ptr [rbp-48]
    imul r8, 16
    add r8, rsi
    mov r9, 1
    mov rbx, rdi
    mov qword ptr [rbp-48], r8
    mov r15, r9
    jmp .L697_0
.L697_2:
    mov rdi, rbx
    add rdi, 1
    mov r8, r13
    add r8, 4
    cmp r14, 0
    je .L697_3
    mov r9, 1
    jmp .L697_4
.L697_3:
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov rsi, rax
    mov r9, rsi
.L697_4:
    mov rsi, 1
    mov rbx, rdi
    mov r13, r8
    mov r14, r9
    mov r15, rsi
    jmp .L697_0
.L697_1:
    cmp r12, 46
    jne .L697_5
    mov rsi, rbx
    add rsi, 1
    mov rdi, rsi
    mov rsi, qword ptr [rbp-48]
    mov rdx, r13
    mov rcx, r14
    mov r8, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fh_x2Dfrac
.L697_5:
    cmp r15, 0
    je .L697_6
    mov rsi, 112
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat
    mov rsi, rax
    add rsi, r13
    mov rdi, qword ptr [rbp-48]
    mov rdx, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fh_x2Dround
.L697_6:
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
zy_local_x2Fmain_0__fmt__fh_x2Dfrac:
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
    mov r15, r8
.L698_0:
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L698_1
    mov rdi, 56
    mov rax, r12
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    cmp rdi, 0
    jne .L698_2
    mov rdi, rbx
    add rdi, 1
    mov r8, r12
    imul r8, 16
    add r8, rsi
    mov r9, r13
    sub r9, 4
    mov r10, 1
    mov rbx, rdi
    mov r12, r8
    mov r13, r9
    mov r15, r10
    jmp .L698_0
.L698_2:
    mov rdi, rbx
    add rdi, 1
    cmp r14, 0
    je .L698_3
    mov r8, 1
    jmp .L698_4
.L698_3:
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov rsi, rax
    mov r8, rsi
.L698_4:
    mov rsi, 1
    mov rbx, rdi
    mov r14, r8
    mov r15, rsi
    jmp .L698_0
.L698_1:
    cmp r15, 0
    je .L698_5
    mov rsi, 112
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat
    mov rsi, rax
    add rsi, r13
    mov rdi, r12
    mov rdx, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fh_x2Dround
.L698_5:
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
zy_local_x2Fmain_0__fmt__fh_x2Dround:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L699_0:
    cmp rbx, 0
    jne .L699_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L699_1:
    mov r14, 63
    mov rsi, 0
    mov rdi, 32
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo
    mov rsi, rax
    mov rax, r14
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    add rsi, r12
    mov r14, rsi
    cmp r14, 1023
    jle .L699_2
    mov rsi, 9218868437227405312
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L699_2:
    cmp r14, -1022
    jge .L699_3
    mov rsi, -1074
    jmp .L699_4
.L699_3:
    mov rdi, r14
    sub rdi, 52
    mov rsi, rdi
.L699_4:
    sub rsi, r12
    cmp rsi, 0
    jg .L699_5
    mov rdi, 0
    sub rdi, rsi
    mov rax, rbx
    mov rcx, rdi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov r12, rdi
    jmp .L699_6
.L699_5:
    mov rdi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__fmt__fh_x2Dshift_x2Dround
    mov rsi, rax
    mov r12, rsi
.L699_6:
    cmp r14, -1022
    jge .L699_7
    mov rsi, r12
    jmp .L699_8
.L699_7:
    mov rdi, r14
    add rdi, 1022
    mov r8, 52
    mov rax, rdi
    mov rcx, r8
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    add rdi, r12
    mov rsi, rdi
.L699_8:
    mov rdi, 9218868437227405312
    cmp rsi, rdi
    jl .L699_9
    mov rdi, 9218868437227405312
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L699_9:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fh_x2Dshift_x2Dround:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L700_0:
    cmp rsi, 62
    jle .L700_1
    mov r9, 0
    mov rax, r9
    mov rsp, rbp
    pop rbp
    ret
.L700_1:
    mov rax, rdi
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, 1
    mov rax, r10
    mov rcx, rsi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    sub r10, 1
    and rdi, r10
    mov r10, 1
    sub rsi, 1
    mov rax, r10
    mov rcx, rsi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    cmp rdi, rsi
    jle .L700_3
    jmp .L700_4
.L700_3:
    cmp rdi, rsi
    jne .L700_2
    cmp r8, 0
    je .L700_5
    jmp .L700_6
.L700_5:
    mov rsi, r9
    and rsi, 1
    cmp rsi, 1
    jne .L700_2
.L700_6:
.L700_4:
    mov rsi, r9
    add rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L700_2:
    mov rax, r9
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fd_x2Dscan:
    push rbp
    mov rbp, rsp
    sub rsp, 184
    mov [rbp-184], rbx
    mov [rbp-176], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    mov r10, [rbp+16]
    mov [rbp-56], r10
    mov rax, [rbp-16]
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov [rbp-64], rax
    mov rax, [rbp-64]
    mov rcx, 48
    cmp rax, rcx
    jl .L703
    mov rax, [rbp-64]
    mov rcx, 57
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L704
.L703:
    mov rax, 0
.L704:
    test rax, rax
    je .L701
    mov rax, [rbp-56]
    test rax, rax
    je .L705
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    jmp .L706
.L705:
    mov rax, [rbp-40]
.L706:
    mov [rbp-72], rax
    mov rax, [rbp-32]
    mov rcx, 0
    cmp rax, rcx
    jne .L709
    mov rax, [rbp-64]
    mov rcx, 48
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L710
.L709:
    mov rax, 0
.L710:
    test rax, rax
    je .L707
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-72]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 1
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    mov [rbp+16], r10
    mov r9, [rsp+8]
    mov r8, [rsp+16]
    mov rcx, [rsp+24]
    mov rdx, [rsp+32]
    mov rsi, [rsp+40]
    mov rdi, [rsp+48]
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fd_x2Dscan
    jmp .L708
.L707:
    mov rax, [rbp-32]
    mov rcx, 19
    cmp rax, rcx
    jge .L711
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 10
    imul rax, rcx
    push rax
    mov rax, [rbp-64]
    mov rcx, 48
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-72]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 1
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    mov [rbp+16], r10
    mov r9, [rsp+8]
    mov r8, [rsp+16]
    mov rcx, [rsp+24]
    mov rdx, [rsp+32]
    mov rsi, [rsp+40]
    mov rdi, [rsp+48]
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fd_x2Dscan
    jmp .L712
.L711:
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-72]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 1
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    mov [rbp+16], r10
    mov r9, [rsp+8]
    mov r8, [rsp+16]
    mov rcx, [rsp+24]
    mov rdx, [rsp+32]
    mov rsi, [rsp+40]
    mov rdi, [rsp+48]
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fd_x2Dscan
.L712:
.L708:
    jmp .L702
.L701:
    mov rax, [rbp-64]
    mov rcx, 46
    cmp rax, rcx
    jne .L715
    mov rax, [rbp-56]
    test rax, rax
    je .L717
    mov rax, 0
    jmp .L718
.L717:
    mov rax, 1
.L718:
    jmp .L716
.L715:
    mov rax, 0
.L716:
    test rax, rax
    je .L713
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    mov rcx, 1
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 1
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    mov [rbp+16], r10
    mov r9, [rsp+8]
    mov r8, [rsp+16]
    mov rcx, [rsp+24]
    mov rdx, [rsp+32]
    mov rsi, [rsp+40]
    mov rdi, [rsp+48]
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fd_x2Dscan
    jmp .L714
.L713:
    mov rax, [rbp-48]
    test rax, rax
    je .L721
    mov rax, 0
    jmp .L722
.L721:
    mov rax, 1
.L722:
    test rax, rax
    je .L719
    mov rax, -1
    jmp .L720
.L719:
    sub rsp, 16
    mov rdi, [rbp-16]
    mov rsi, 101
call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat
    add rsp, 16
    mov [rbp-80], rax
    mov rax, [rbp-32]
    mov rcx, 0
    cmp rax, rcx
    jne .L723
    mov rax, 0
    jmp .L724
.L723:
    mov rax, [rbp-32]
    mov rcx, 19
    cmp rax, rcx
    jg .L725
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-80]
    mov rcx, [rbp-40]
    sub rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rsi, [rsp+0]
    mov rdi, [rsp+8]
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fd_x2Dexact
    jmp .L726
.L725:
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-80]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-80]
    mov rcx, [rbp-40]
    sub rax, rcx
    push rax
    mov rax, [rbp-32]
    mov rcx, 19
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rcx, [rsp+0]
    mov rdx, [rsp+8]
    mov rsi, [rsp+16]
    mov rdi, [rsp+24]
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fd_x2Dinexact
.L726:
.L724:
.L720:
.L714:
.L702:
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fd_x2Dexact:
    push rbp
    mov rbp, rsp
    sub rsp, 136
    mov [rbp-136], rbx
    mov [rbp-128], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    mov rcx, -22
    cmp rax, rcx
    jl .L731
    mov rax, [rbp-16]
    mov rcx, 22
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L732
.L731:
    mov rax, 0
.L732:
    test rax, rax
    je .L729
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jl .L733
    mov rax, [rbp-8]
    mov rcx, 9007199254740992
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L734
.L733:
    mov rax, 0
.L734:
    jmp .L730
.L729:
    mov rax, 0
.L730:
    test rax, rax
    je .L727
call zy_local_x2Fmain_0__fmt__fm_x2Dtab
    add rsp, 0
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov rdx, rax
    cvtsi2sd xmm0, rdx
    movq rax, xmm0
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov rcx, 0
    cmp rax, rcx
    jl .L735
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, 10416
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-24]
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    mulsd xmm0, xmm1
    movq rax, xmm0
    jmp .L736
.L735:
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rcx, [rbp-16]
    sub rax, rcx
    mov rcx, 8
    imul rax, rcx
    mov rcx, rax
    mov rax, 10416
    add rax, rcx
    mov rcx, rax
    mov rax, [rbp-24]
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    divsd xmm0, xmm1
    movq rax, xmm0
.L736:
    jmp .L728
.L727:
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rsi, [rsp+0]
    mov rdi, [rsp+8]
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Del
.L728:
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fd_x2Dinexact:
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
.L737_0:
    mov rdi, r14
    mov rsi, r13
    call zy_local_x2Fmain_0__fmt__fm_x2Del
    mov rsi, rax
    mov r15, rsi
    mov rsi, r13
    add rsi, 1
    mov rdi, r14
    call zy_local_x2Fmain_0__fmt__fm_x2Del
    mov rsi, rax
    cmp r15, rsi
    jne .L737_1
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L737_1:
    mov rdi, rbx
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dparse
zy_local_x2Fmain_0__fmt__fm_x2Del:
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
.L738_0:
    cmp rbx, -342
    jge .L738_1
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
.L738_1:
    cmp rbx, 308
    jle .L738_2
    mov rsi, 9218868437227405312
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L738_2:
    mov rsi, 0
    mov rdi, 32
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo
    mov rsi, rax
    mov r13, rsi
    mov rax, r12
    mov rcx, r13
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    mov r12, rsi
    call zy_local_x2Fmain_0__fmt__fm_x2Dtab
    mov rsi, rax
    mov rdi, rbx
    add rdi, 342
    imul rdi, 16
    add rsi, rdi
    mov r14, rsi
    mov rdx, r14
    mov rax, qword ptr [rdx]
    mov rsi, rax
    imul rsi, r12
    mov r15, rsi
    mov rdx, r14
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dmulhi
    mov rsi, rax
    mov qword ptr [rbp-48], rsi
    mov rsi, qword ptr [rbp-48]
    and rsi, 511
    cmp rsi, 511
    jne .L738_3
    mov rsi, r14
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dmulhi
    mov rsi, rax
    add rsi, r15
    mov rdi, -9223372036854775808
    xor rdi, rsi
    mov r8, -9223372036854775808
    xor r8, r15
    cmp rdi, r8
    jge .L738_4
    mov rdi, qword ptr [rbp-48]
    add rdi, 1
    jmp .L738_5
.L738_4:
    mov rdi, qword ptr [rbp-48]
.L738_5:
    mov rdx, rsi
    mov rsi, r13
    mov rcx, rdi
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Del_x2Dround
.L738_3:
    mov rdi, rbx
    mov rsi, r13
    mov rdx, r15
    mov rcx, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Del_x2Dround
zy_local_x2Fmain_0__fmt__fm_x2Del_x2Dround:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov r8, rdx
    mov r9, rcx
.L739_0:
    mov r10, 63
    mov rax, r9
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov rbx, r10
    add rbx, 9
    mov rax, r9
    mov rcx, rbx
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r12, rax
    mov r13, 217706
    imul r13, rdi
    mov r14, 16
    mov rax, r13
    mov rcx, r14
    mov rdx, 63
    cmp rcx, 64
    cmovae rcx, rdx
    sar rax, cl
    mov r13, rax
    add r13, 63
    add r10, r13
    mov rax, r10
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    add rsi, 1023
    cmp rsi, 0
    jg .L739_1
    mov r10, 0
    sub r10, rsi
    add r10, 1
    cmp r10, 64
    jl .L739_2
    mov r10, 0
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L739_2:
    mov r10, 0
    sub r10, rsi
    add r10, 1
    mov rax, r12
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov r13, r10
    and r13, 1
    add r10, r13
    mov r13, 1
    mov rax, r10
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L739_1:
    mov r10, -9223372036854775808
    xor r8, r10
    mov r10, 2
    mov r13, -9223372036854775808
    xor r10, r13
    cmp r8, r10
    jge .L739_3
    cmp rdi, -4
    jl .L739_3
    cmp rdi, 23
    jg .L739_3
    mov rdi, r12
    and rdi, 3
    cmp rdi, 1
    jne .L739_3
    mov rax, r12
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    cmp rdi, r9
    jne .L739_3
    mov rdi, r12
    and rdi, -2
    jmp .L739_4
.L739_3:
    mov rdi, r12
.L739_4:
    mov r8, rdi
    and r8, 1
    add rdi, r8
    mov r8, 1
    mov rax, rdi
    mov rcx, r8
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov r8, 9007199254740992
    cmp rdi, r8
    jl .L739_5
    mov r8, rsi
    add r8, 1
    jmp .L739_6
.L739_5:
    mov r8, rsi
.L739_6:
    mov rsi, 9007199254740992
    cmp rdi, rsi
    jl .L739_7
    mov rsi, 0
    jmp .L739_8
.L739_7:
    mov r9, 4503599627370495
    and rdi, r9
    mov rsi, rdi
.L739_8:
    cmp r8, 2047
    jl .L739_9
    mov rdi, 9218868437227405312
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L739_9:
    mov rdi, 52
    mov rax, r8
    mov rcx, rdi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    or rsi, rdi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dbuf:
    push rbp
    mov rbp, rsp
.L740_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_fmt_dec@tpoff]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dparse:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L741_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_fmt_dec@tpoff]
    mov rsi, rax
    mov r12, rsi
    mov rsi, 0
    mov rdx, r12
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r12
    add rsi, 8
    mov r8, 0
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, r12
    add rsi, 16
    mov r8, 0
    mov rdx, rsi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 0
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__sd_x2Dread
    mov rsi, rax
    mov rsi, r12
    add rsi, 8
    mov rdi, r12
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, rbx
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__sd_x2Dtrim
    mov rsi, rax
    mov rdi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dbits
zy_local_x2Fmain_0__fmt__sd_x2Dread:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r8, rdx
.L742_0:
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov r9, rax
    cmp r9, 48
    jl .L742_1
    cmp r9, 57
    jg .L742_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    cmp r10, 0
    jne .L742_2
    cmp r9, 48
    jne .L742_2
    cmp r8, 0
    je .L742_3
    mov rbx, rdi
    add rbx, 8
    mov r12, rdi
    add r12, 8
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov r12, rax
    sub r12, 1
    mov rdx, rbx
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rbx, rax
    jmp .L742_4
.L742_3:
    mov r12, 0
    mov rbx, r12
.L742_4:
    mov rbx, rsi
    add rbx, 1
    mov rsi, rbx
    jmp .L742_0
.L742_2:
    cmp r10, 800
    jge .L742_5
    mov rbx, rdi
    add rbx, 32
    add rbx, r10
    mov r12, r9
    sub r12, 48
    mov rdx, rbx
    mov rcx, r12
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rbx, rax
    add r10, 1
    mov rdx, rdi
    mov rcx, r10
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r10, rax
    jmp .L742_6
.L742_5:
    cmp r9, 48
    jne .L742_7
    mov rbx, 0
    jmp .L742_8
.L742_7:
    mov r12, rdi
    add r12, 16
    mov r13, 1
    mov rdx, r12
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r12, rax
    mov rbx, r12
.L742_8:
    mov r10, rbx
.L742_6:
    cmp r8, 0
    je .L742_9
    mov r10, 0
    jmp .L742_10
.L742_9:
    mov rbx, rdi
    add rbx, 8
    mov r12, rdi
    add r12, 8
    mov rdx, r12
    mov rax, qword ptr [rdx]
    mov r12, rax
    add r12, 1
    mov rdx, rbx
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rbx, rax
    mov r10, rbx
.L742_10:
    mov r10, rsi
    add r10, 1
    mov rsi, r10
    jmp .L742_0
.L742_1:
    cmp r9, 46
    jne .L742_11
    cmp r8, 0
    je .L742_12
    mov r9, 0
    jmp .L742_13
.L742_12:
    mov r10, 1
    mov r9, r10
.L742_13:
    cmp r9, 0
    je .L742_11
    mov r9, rsi
    add r9, 1
    mov r10, 1
    mov rsi, r9
    mov r8, r10
    jmp .L742_0
.L742_11:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dtrim:
    push rbp
    mov rbp, rsp
.L743_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jle .L743_1
    mov r8, rdi
    add r8, 32
    mov r9, rsi
    sub r9, 1
    add r8, r9
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 0
    jne .L743_1
    mov r8, rsi
    sub r8, 1
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    jmp .L743_0
.L743_1:
    cmp rsi, 0
    jne .L743_2
    mov rsi, rdi
    add rsi, 8
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L743_2:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dshift:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L744_0:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L744_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L744_1:
    cmp r12, 25
    jle .L744_2
    mov rsi, 25
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dlshift
    mov rsi, rax
    mov rsi, r12
    sub rsi, 25
    mov r12, rsi
    jmp .L744_0
.L744_2:
    cmp r12, 0
    jle .L744_3
    mov rdi, rbx
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dlshift
.L744_3:
    cmp r12, -59
    jge .L744_4
    mov rsi, 59
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
    mov rsi, rax
    mov rsi, r12
    add rsi, 59
    mov r12, rsi
    jmp .L744_0
.L744_4:
    cmp r12, 0
    jge .L744_5
    mov rsi, 0
    sub rsi, r12
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
.L744_5:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Drshift:
    push rbp
    mov rbp, rsp
.L745_0:
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L746_0:
    mov rax, r9
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    cmp r10, 0
    jne .L746_1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r10, rax
    cmp r8, r10
    jl .L746_2
    cmp r9, 0
    jne .L746_3
    mov r10, 0
    mov rdx, rdi
    mov rcx, r10
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r10, rax
    mov r10, rdi
    add r10, 8
    mov rbx, 0
    mov rdx, r10
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r10, rax
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L746_3:
    mov rdx, r8
    mov rcx, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dpad
.L746_2:
    mov r10, r8
    add r10, 1
    mov rbx, r9
    imul rbx, 10
    mov r12, rdi
    add r12, 32
    add r12, r8
    mov rdx, r12
    movzx eax, byte ptr [rdx]
    mov r12, rax
    add rbx, r12
    mov r8, r10
    mov r9, rbx
    jmp .L746_0
.L746_1:
    mov rdx, r8
    mov rcx, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dpad:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L747_0:
    mov rax, r9
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    cmp r10, 0
    jne .L747_1
    mov r10, r8
    add r10, 1
    mov rbx, r9
    imul rbx, 10
    mov r8, r10
    mov r9, rbx
    jmp .L747_0
.L747_1:
    mov rdx, r8
    mov rcx, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L748_0:
    mov r10, rdi
    add r10, 8
    mov rbx, rdi
    add rbx, 8
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    mov r12, r8
    sub r12, 1
    sub rbx, r12
    mov rdx, r10
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r10, rax
    mov r10, 1
    mov rax, r10
    mov rcx, rsi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    sub r10, 1
    mov rbx, 0
    mov rdx, r10
    mov rcx, r8
    mov r8, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dwrite
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dwrite:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r10, r8
    mov r8, rdx
    mov rbx, r9
    mov r9, rcx
.L749_0:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r12, rax
    cmp r9, r12
    jge .L749_1
    mov r12, rdi
    add r12, 32
    add r12, r10
    mov rax, rbx
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    mov rdx, r12
    mov rcx, r13
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r12, rax
    mov r12, r9
    add r12, 1
    mov r13, r10
    add r13, 1
    mov r14, rbx
    and r14, r8
    imul r14, 10
    mov r15, rdi
    add r15, 32
    add r15, r9
    mov rdx, r15
    movzx eax, byte ptr [rdx]
    mov r15, rax
    add r14, r15
    mov r9, r12
    mov r10, r13
    mov rbx, r14
    jmp .L749_0
.L749_1:
    mov rdx, r8
    mov rcx, r10
    mov r8, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dtail
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dtail:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L750_0:
    cmp r10, 0
    jle .L750_1
    mov rax, r10
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    cmp r9, 800
    jge .L750_2
    mov r12, rdi
    add r12, 32
    add r12, r9
    mov rdx, r12
    mov rcx, rbx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r12, rax
    mov r12, r9
    add r12, 1
    mov r13, r10
    and r13, r8
    imul r13, 10
    mov r9, r12
    mov r10, r13
    jmp .L750_0
.L750_2:
    cmp rbx, 0
    jle .L750_3
    mov rbx, rdi
    add rbx, 16
    mov r12, 1
    mov rdx, rbx
    mov rcx, r12
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rbx, rax
    jmp .L750_4
.L750_3:
    mov r12, 0
    mov rbx, r12
.L750_4:
    mov rbx, r10
    and rbx, r8
    imul rbx, 10
    mov r10, rbx
    jmp .L750_0
.L750_1:
    mov rdx, rdi
    mov rcx, r9
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dtrim
zy_local_x2Fmain_0__fmt__fm_x2Dndig:
    push rbp
    mov rbp, rsp
.L751_0:
    cmp rdi, 10
    jge .L751_1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L751_1:
    mov rcx, rdi
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 2
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    mov rax, rdx
    mov r8, rax
    mov r9, rsi
    add r9, 1
    mov rdi, r8
    mov rsi, r9
    jmp .L751_0
zy_local_x2Fmain_0__fmt__fm_x2Dpow5:
    push rbp
    mov rbp, rsp
.L752_0:
    cmp rdi, 0
    jne .L752_1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L752_1:
    mov r8, rdi
    sub r8, 1
    mov r9, rsi
    imul r9, 5
    mov rdi, r8
    mov rsi, r9
    jmp .L752_0
zy_local_x2Fmain_0__fmt__sd_x2Dprefix:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L753_0:
    cmp rsi, r8
    jne .L753_1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L753_1:
    mov r10, rsi
    add r10, 1
    mov rbx, r9
    imul rbx, 10
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r12, rax
    cmp rsi, r12
    jge .L753_2
    mov r12, rdi
    add r12, 32
    add r12, rsi
    mov rdx, r12
    movzx eax, byte ptr [rdx]
    mov r12, rax
    jmp .L753_3
.L753_2:
    mov r13, 0
    mov r12, r13
.L753_3:
    add rbx, r12
    mov rsi, r10
    mov r9, rbx
    jmp .L753_0
zy_local_x2Fmain_0__fmt__sd_x2Ddelta:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L754_0:
    mov rsi, 1
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dpow5
    mov rsi, rax
    mov r13, rsi
    mov rsi, 1
    mov rdi, r13
    call zy_local_x2Fmain_0__fmt__fm_x2Dndig
    mov rsi, rax
    mov r14, rsi
    mov rsi, 1
    mov rax, rsi
    mov rcx, r12
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    mov rdi, 1
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dndig
    mov rsi, rax
    mov r12, rsi
    mov rsi, 0
    mov rdi, 0
    mov rdx, r14
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dprefix
    mov rsi, rax
    cmp rsi, r13
    jge .L754_1
    mov rsi, r12
    sub rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L754_1:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dlshift:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L755_0:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__sd_x2Ddelta
    mov rsi, rax
    mov r13, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r14, rsi
    mov rsi, r14
    sub rsi, 1
    mov rdi, r14
    add rdi, r13
    mov r8, 0
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dgo
    mov rsi, rax
    mov rsi, r14
    add rsi, r13
    cmp rsi, 800
    jl .L755_1
    mov rdi, 800
    jmp .L755_2
.L755_1:
    mov rdi, rsi
.L755_2:
    mov rdx, rbx
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, rbx
    add rsi, 8
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    add rdi, r13
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dtrim
zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dput:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L756_0:
    cmp rsi, 800
    jge .L756_1
    mov r9, rdi
    add r9, 32
    add rsi, r9
    mov rdx, rsi
    mov rcx, r8
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L756_1:
    cmp r8, 0
    jne .L756_2
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L756_2:
    mov rsi, rdi
    add rsi, 16
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dgo:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov qword ptr [rbp-48], rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L757_0:
    cmp r13, 0
    jl .L757_1
    mov rsi, qword ptr [rbp-48]
    add rsi, 32
    add rsi, r13
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rcx, r12
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    add rsi, r15
    mov rcx, rsi
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 2
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    mov rax, rdx
    mov rdi, rax
    mov rbx, rdi
    mov rdi, r14
    sub rdi, 1
    mov r8, rbx
    imul r8, 10
    sub rsi, r8
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dput
    mov rsi, rax
    mov rsi, r13
    sub rsi, 1
    mov rdi, r14
    sub rdi, 1
    mov r13, rsi
    mov r14, rdi
    mov r15, rbx
    jmp .L757_0
.L757_1:
    cmp r15, 0
    jle .L757_2
    mov rcx, r15
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 2
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    mov rax, rdx
    mov rsi, rax
    mov rbx, rsi
    mov rsi, r14
    sub rsi, 1
    mov rdi, rbx
    imul rdi, 10
    mov rax, r15
    mov rcx, rdi
    sub rax, rcx
    mov rdi, rax
    mov rdx, rdi
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dput
    mov rsi, rax
    mov rsi, -1
    mov rdi, r14
    sub rdi, 1
    mov r13, rsi
    mov r14, rdi
    mov r15, rbx
    jmp .L757_0
.L757_2:
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
zy_local_x2Fmain_0__fmt__sd_x2Dpowtab:
    push rbp
    mov rbp, rsp
.L758_0:
    cmp rdi, 0
    jne .L758_1
    mov rsi, 1
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L758_1:
    cmp rdi, 1
    jne .L758_2
    mov rsi, 3
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L758_2:
    cmp rdi, 2
    jne .L758_3
    mov rsi, 6
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L758_3:
    cmp rdi, 3
    jne .L758_4
    mov rsi, 9
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L758_4:
    cmp rdi, 4
    jne .L758_5
    mov rsi, 13
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L758_5:
    cmp rdi, 5
    jne .L758_6
    mov rsi, 16
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L758_6:
    cmp rdi, 6
    jne .L758_7
    mov rsi, 19
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L758_7:
    cmp rdi, 7
    jne .L758_8
    mov rsi, 23
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L758_8:
    mov rsi, 26
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dstep:
    push rbp
    mov rbp, rsp
.L759_0:
    cmp rdi, 9
    jl .L759_1
    mov rsi, 27
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L759_1:
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dpowtab
zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Ddown:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
.L760_0:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jle .L760_1
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__fmt__sd_x2Dstep
    mov rsi, rax
    mov r13, rsi
    mov rsi, 0
    sub rsi, r13
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    mov rsi, rax
    mov rsi, r12
    add rsi, r13
    mov r12, rsi
    jmp .L760_0
.L760_1:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Dup:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
.L761_0:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jge .L761_2
    jmp .L761_3
.L761_2:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L761_1
    mov rsi, rbx
    add rsi, 32
    add rsi, 0
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    cmp rsi, 5
    jge .L761_1
.L761_3:
    mov rsi, 0
    mov rdi, rbx
    add rdi, 8
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    sub rsi, rdi
    mov rdi, rsi
    call zy_local_x2Fmain_0__fmt__sd_x2Dstep
    mov rsi, rax
    mov r13, rsi
    mov rdi, rbx
    mov rsi, r13
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    mov rsi, rax
    mov rsi, r12
    sub rsi, r13
    mov r12, rsi
    jmp .L761_0
.L761_1:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dbits:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
.L762_0:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 0
    jne .L762_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L762_1:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, 310
    jle .L762_2
    mov rsi, 9218868437227405312
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L762_2:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    cmp rsi, -330
    jge .L762_3
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L762_3:
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Ddown
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Dup
    mov rsi, rax
    sub rsi, 1
    mov r12, rsi
    cmp r12, -1022
    jge .L762_4
    mov rsi, -1022
    sub rsi, r12
    mov r13, rsi
    mov rsi, 0
    sub rsi, r13
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    mov rsi, rax
    mov rsi, r12
    add rsi, r13
    jmp .L762_5
.L762_4:
    mov rsi, r12
.L762_5:
    mov r12, rsi
    mov rsi, r12
    add rsi, 1023
    cmp rsi, 2047
    jl .L762_6
    mov rsi, 9218868437227405312
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L762_6:
    mov rsi, 53
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Drounded
    mov rsi, rax
    mov rdi, 9007199254740992
    cmp rsi, rdi
    jne .L762_7
    mov rdi, r12
    add rdi, 1
    jmp .L762_8
.L762_7:
    mov rdi, r12
.L762_8:
    mov r8, 9007199254740992
    cmp rsi, r8
    jne .L762_9
    mov r8, 4503599627370496
    jmp .L762_10
.L762_9:
    mov r8, rsi
.L762_10:
    mov rsi, rdi
    add rsi, 1023
    cmp rsi, 2047
    jl .L762_11
    mov rsi, 9218868437227405312
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L762_11:
    mov rsi, 4503599627370496
    and rsi, r8
    cmp rsi, 0
    jne .L762_12
    mov rsi, -1023
    jmp .L762_13
.L762_12:
    mov rsi, rdi
.L762_13:
    mov rdi, 4503599627370495
    and rdi, r8
    add rsi, 1023
    and rsi, 2047
    mov r8, 52
    mov rax, rsi
    mov rcx, r8
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    or rsi, rdi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dint:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L763_0:
    cmp rsi, r8
    jl .L763_1
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L763_1:
    mov r10, rsi
    add r10, 1
    mov rbx, r9
    imul rbx, 10
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r12, rax
    cmp rsi, r12
    jge .L763_2
    mov r12, rdi
    add r12, 32
    add r12, rsi
    mov rdx, r12
    movzx eax, byte ptr [rdx]
    mov r12, rax
    jmp .L763_3
.L763_2:
    mov r13, 0
    mov r12, r13
.L763_3:
    add rbx, r12
    mov rsi, r10
    mov r9, rbx
    jmp .L763_0
zy_local_x2Fmain_0__fmt__sd_x2Drounded:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
.L764_0:
    mov rsi, rbx
    add rsi, 8
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rsi, 0
    mov rdi, 0
    mov rdx, r12
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dint
    mov rsi, rax
    mov r13, rsi
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__sd_x2Dround_x2Dup
    mov rsi, rax
    cmp rsi, 0
    je .L764_1
    mov rsi, r13
    add rsi, 1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L764_1:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dround_x2Dup:
    push rbp
    mov rbp, rsp
.L765_0:
    cmp rsi, 0
    jge .L765_2
    jmp .L765_3
.L765_2:
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp rsi, r8
    jl .L765_1
.L765_3:
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L765_1:
    mov r8, rdi
    add r8, 32
    add r8, rsi
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    cmp r8, 5
    jne .L765_4
    mov r8, rsi
    add r8, 1
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov r9, rax
    cmp r8, r9
    jne .L765_4
    mov r8, rdi
    add r8, 16
    mov rdx, r8
    mov rax, qword ptr [rdx]
    mov r8, rax
    cmp r8, 1
    jne .L765_5
    mov r8, 1
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L765_5:
    cmp rsi, 0
    jle .L765_6
    mov r8, rdi
    add r8, 32
    mov r9, rsi
    sub r9, 1
    add r8, r9
    mov rdx, r8
    movzx eax, byte ptr [rdx]
    mov r8, rax
    and r8, 1
    mov rax, r8
    cmp rax, 1
    sete al
    movzx rax, al
    mov r8, rax
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L765_6:
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L765_4:
    add rdi, 32
    add rsi, rdi
    mov rdx, rsi
    movzx eax, byte ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    cmp rax, 5
    setge al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_text
zyl_f_text:
    push rbp
    mov rbp, rsp
.L766_0:
    mov rsi, 0
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext
.globl zyl_f_text_r
zyl_f_text_r:
    push rbp
    mov rbp, rsp
.L767_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext
zy_local_x2Fmain_0__fmt__fm_x2Dtext:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
.L768_0:
    mov rax, rdi
    cmp rax, 0
    setl al
    movzx rax, al
    mov r8, rax
    mov r9, 9223372036854775807
    and rdi, r9
    mov r9, 52
    mov rax, rdi
    mov rcx, r9
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r10, 4503599627370495
    and rdi, r10
    cmp r9, 2047
    jne .L768_1
    cmp rdi, 0
    jne .L768_2
    cmp r8, 0
    je .L768_3
    lea rax, [rip+.L769]
    mov r10, rax
    mov rbx, 4
    mov rdi, r10
    mov rdx, rsi
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L768_3:
    lea rax, [rip+.L770]
    mov r10, rax
    mov rbx, 3
    mov rdi, r10
    mov rdx, rsi
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L768_2:
    cmp r8, 0
    je .L768_4
    lea rax, [rip+.L771]
    mov r10, rax
    mov rbx, 4
    mov rdi, r10
    mov rdx, rsi
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L768_4:
    lea rax, [rip+.L772]
    mov r10, rax
    mov rbx, 3
    mov rdi, r10
    mov rdx, rsi
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L768_1:
    cmp r9, 0
    jne .L768_5
    mov r10, rdi
    jmp .L768_6
.L768_5:
    mov rbx, 4503599627370496
    or rdi, rbx
    mov r10, rdi
.L768_6:
    cmp r9, 0
    jne .L768_7
    mov rdi, -1074
    jmp .L768_8
.L768_7:
    sub r9, 1075
    mov rdi, r9
.L768_8:
    cmp rdi, 10
    jle .L768_9
    mov rdx, rdi
    mov rdi, r8
    mov rcx, rsi
    mov rsi, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dbig
.L768_9:
    cmp rdi, 0
    jl .L768_10
    mov rax, r10
    mov rcx, rdi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov rbx, 0
    mov rdi, r8
    mov rdx, rbx
    mov rcx, rsi
    mov rsi, r9
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dsmall
.L768_10:
    mov r9, 0
    mov rax, r9
    mov rcx, rdi
    sub rax, rcx
    mov rdi, rax
    mov rdx, rdi
    mov rdi, r8
    mov rcx, rsi
    mov rsi, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dfrac
zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dfrac:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    mov qword ptr [rbp-48], rdi
    mov r12, rdx
    mov qword ptr [rbp-56], rcx
.L773_0:
    cmp r12, 76
    jl .L773_1
    mov rdi, 0
    mov r8, 0
    mov rsi, rdi
    mov rdi, qword ptr [rbp-48]
    mov rdx, r8
    mov rcx, qword ptr [rbp-56]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dsmall
.L773_1:
    cmp r12, 64
    jge .L773_2
    mov rax, rsi
    mov rcx, r12
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    jmp .L773_3
.L773_2:
    mov r8, 0
    mov rdi, r8
.L773_3:
    mov r14, rdi
    cmp r12, 64
    jge .L773_4
    mov rdi, 1
    mov rax, rdi
    mov rcx, r12
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    sub rdi, 1
    and rdi, rsi
    jmp .L773_5
.L773_4:
    mov rdi, rsi
.L773_5:
    mov rsi, rdi
    imul rsi, 1000000
    mov r15, rsi
    mov rsi, 1000000
    call zy_local_x2Fmain_0__fmt__fm_x2Dmulhi
    mov rsi, rax
    mov rbx, rsi
    mov rdi, r12
    mov rsi, r15
    mov rdx, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dfrac_x2Dq
    mov rsi, rax
    mov r13, rsi
    mov rsi, r13
    and rsi, 1
    mov rax, rsi
    cmp rax, 1
    sete al
    movzx rax, al
    mov rsi, rax
    mov rdi, r12
    mov rdx, rbx
    mov rcx, rsi
    mov rsi, r15
    call zy_local_x2Fmain_0__fmt__fm_x2Dfrac_x2Dup
    mov rsi, rax
    cmp rsi, 0
    je .L773_6
    mov rsi, r13
    add rsi, 1
    jmp .L773_7
.L773_6:
    mov rsi, r13
.L773_7:
    cmp rsi, 1000000
    jne .L773_8
    mov rdi, r14
    add rdi, 1
    mov r8, 0
    mov rsi, rdi
    mov rdi, qword ptr [rbp-48]
    mov rdx, r8
    mov rcx, qword ptr [rbp-56]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dsmall
.L773_8:
    mov rdi, qword ptr [rbp-48]
    mov rdx, rsi
    mov rsi, r14
    mov rcx, qword ptr [rbp-56]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dsmall
zy_local_x2Fmain_0__fmt__fm_x2Dfrac_x2Dq:
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L774_0:
    cmp rdi, 64
    jge .L774_1
    mov rax, rsi
    mov rcx, rdi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    mov r9, 64
    sub r9, rdi
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    or rsi, r9
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L774_1:
    mov rsi, rdi
    sub rsi, 64
    mov rax, r8
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dfrac_x2Dup:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L775_0:
    cmp rdi, 64
    jge .L775_1
    mov r10, 1
    mov rax, r10
    mov rcx, rdi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    sub r10, 1
    and r10, rsi
    mov rbx, 1
    mov r12, rdi
    sub r12, 1
    mov rax, rbx
    mov rcx, r12
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    cmp r10, rbx
    jle .L775_2
    mov r12, 1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L775_2:
    cmp r10, rbx
    jne .L775_3
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L775_3:
    mov r10, 0
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L775_1:
    sub rdi, 64
    mov r10, 1
    mov rax, r10
    mov rcx, rdi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    sub r10, 1
    and r8, r10
    cmp rdi, 0
    jne .L775_4
    mov r10, 0
    jmp .L775_5
.L775_4:
    mov rbx, 1
    mov r12, rdi
    sub r12, 1
    mov rax, rbx
    mov rcx, r12
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    mov r10, rbx
.L775_5:
    cmp rdi, 0
    jne .L775_6
    mov rdi, -9223372036854775808
    jmp .L775_7
.L775_6:
    mov rbx, 0
    mov rdi, rbx
.L775_7:
    cmp r8, r10
    jle .L775_8
    mov rbx, 1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L775_8:
    cmp r8, r10
    jne .L775_9
    mov r8, -9223372036854775808
    xor r8, rdi
    mov r10, -9223372036854775808
    xor r10, rsi
    cmp r8, r10
    jge .L775_10
    mov r8, 1
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L775_10:
    cmp rsi, rdi
    jne .L775_11
    mov rax, r9
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L775_11:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L775_9:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dsmall:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 32
    mov rbx, rdi
    mov r12, rsi
    mov qword ptr [rbp-48], rdx
    mov r14, rcx
.L776_0:
    cmp rbx, 0
    je .L776_1
    mov rsi, 1
    jmp .L776_2
.L776_1:
    mov rdi, 0
    mov rsi, rdi
.L776_2:
    mov r15, rsi
    mov rsi, 0
    sub rsi, r12
    mov rdi, -10
    mov r8, 1
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__text__rt_x2Dnd
    mov rsi, rax
    mov r13, rsi
    mov rsi, r15
    add rsi, r13
    add rsi, 7
    mov qword ptr [rbp-56], rsi
    mov rsi, qword ptr [rbp-56]
    add rsi, 1
    mov rdi, rsi
    mov rsi, r14
    call zyl_ralloc
    mov rsi, rax
    mov r14, rsi
    cmp rbx, 0
    je .L776_3
    mov rsi, 45
    mov rdx, r14
    mov rcx, rsi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    jmp .L776_4
.L776_3:
    mov rdi, 0
    mov rsi, rdi
.L776_4:
    mov rsi, 0
    sub rsi, r12
    mov rdi, r15
    add rdi, r13
    sub rdi, 1
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    mov rsi, rax
    mov rsi, r15
    add rsi, r13
    add rsi, r14
    mov rdi, 46
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, r15
    add rsi, r13
    add rsi, 1
    add rsi, r14
    mov rdi, 6
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dzeros
    mov rsi, rax
    mov rsi, 0
    sub rsi, qword ptr [rbp-48]
    mov rdi, qword ptr [rbp-56]
    sub rdi, 1
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    mov rsi, rax
    mov rsi, r14
    add rsi, qword ptr [rbp-56]
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
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dzeros:
    push rbp
    mov rbp, rsp
.L777_0:
    cmp rsi, 0
    jne .L777_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L777_1:
    mov r8, 48
    mov rdx, rdi
    mov rcx, r8
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r8, rax
    mov r8, rdi
    add r8, 1
    mov r9, rsi
    sub r9, 1
    mov rdi, r8
    mov rsi, r9
    jmp .L777_0
zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dbig:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov rdi, rdx
    mov r12, rcx
.L778_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_fmt_big@tpoff]
    mov r8, rax
    mov r13, r8
    mov rcx, rsi
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    imul rdx, rdx, 1000000000
    mov rax, rcx
    sub rax, rdx
    mov r8, rax
    mov rdx, r13
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    mov r8, r13
    add r8, 8
    mov rcx, rsi
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    mov rax, rdx
    mov rsi, rax
    mov rdx, r8
    mov rcx, rsi
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rsi, rax
    mov rsi, 2
    mov rdx, rdi
    mov rdi, r13
    call zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dshift
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    mov rcx, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dout
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dshift:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L779_0:
    cmp r13, 0
    jne .L779_1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L779_1:
    cmp r13, 32
    jle .L779_2
    mov rsi, 32
    jmp .L779_3
.L779_2:
    mov rsi, r13
.L779_3:
    mov r14, rsi
    mov rsi, 0
    mov rdi, 0
    mov rdx, r12
    mov rcx, r14
    mov r8, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dmul
    mov rsi, rax
    mov rdi, r13
    sub rdi, r14
    mov r12, rsi
    mov r13, rdi
    jmp .L779_0
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dmul:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L780_0:
    cmp rsi, r8
    jge .L780_1
    mov rbx, rsi
    imul rbx, 8
    add rbx, rdi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    mov rax, rbx
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    add rbx, r10
    mov rcx, rbx
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    mov rax, rdx
    mov r12, rax
    mov r13, rsi
    imul r13, 8
    add r13, rdi
    mov r14, r12
    imul r14, 1000000000
    sub rbx, r14
    mov rdx, r13
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov rbx, rax
    mov rbx, rsi
    add rbx, 1
    mov rsi, rbx
    mov r10, r12
    jmp .L780_0
.L780_1:
    cmp r10, 0
    jle .L780_2
    mov rcx, r10
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rdx
    shr rax, 63
    add rdx, rax
    mov rax, rdx
    mov rbx, rax
    mov r12, rsi
    imul r12, 8
    add r12, rdi
    mov r13, rbx
    imul r13, 1000000000
    mov rax, r10
    mov rcx, r13
    sub rax, rcx
    mov r13, rax
    mov rdx, r12
    mov rcx, r13
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r12, rax
    mov r12, rsi
    add r12, 1
    mov r13, r8
    add r13, 1
    mov rsi, r12
    mov r8, r13
    mov r10, rbx
    jmp .L780_0
.L780_2:
    mov rax, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dout:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 48
    mov rbx, rdi
    mov qword ptr [rbp-56], rsi
    mov r13, rdx
    mov r14, rcx
.L781_0:
    cmp rbx, 0
    je .L781_1
    mov rsi, 1
    jmp .L781_2
.L781_1:
    mov rdi, 0
    mov rsi, rdi
.L781_2:
    mov qword ptr [rbp-48], rsi
    mov rsi, r13
    sub rsi, 1
    imul rsi, 8
    add rsi, qword ptr [rbp-56]
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r15, rsi
    mov rsi, 0
    sub rsi, r15
    mov rdi, -10
    mov r8, 1
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__text__rt_x2Dnd
    mov rsi, rax
    mov r12, rsi
    mov rsi, 9
    mov rdi, r13
    sub rdi, 1
    imul rsi, rdi
    add rsi, r12
    mov qword ptr [rbp-64], rsi
    mov rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-64]
    add rsi, 7
    mov qword ptr [rbp-72], rsi
    mov rsi, qword ptr [rbp-72]
    add rsi, 1
    mov rdi, rsi
    mov rsi, r14
    call zyl_ralloc
    mov rsi, rax
    mov r14, rsi
    cmp rbx, 0
    je .L781_3
    mov rsi, 45
    mov rdx, r14
    mov rcx, rsi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    jmp .L781_4
.L781_3:
    mov rdi, 0
    mov rsi, rdi
.L781_4:
    mov rsi, r14
    add rsi, qword ptr [rbp-48]
    mov rdi, rsi
    mov rsi, qword ptr [rbp-64]
    call zy_local_x2Fmain_0__fmt__fm_x2Dzeros
    mov rsi, rax
    mov rsi, 0
    sub rsi, r15
    mov rdi, qword ptr [rbp-48]
    add rdi, r12
    sub rdi, 1
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    mov rsi, rax
    mov rsi, r13
    sub rsi, 2
    mov rdi, qword ptr [rbp-48]
    add rdi, r12
    add rdi, 8
    mov rdx, rsi
    mov rsi, qword ptr [rbp-56]
    mov rcx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dlimbs
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-64]
    add rsi, r14
    mov rdi, 46
    mov rdx, rsi
    mov rcx, rdi
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov rsi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-64]
    add rsi, 1
    add rsi, r14
    mov rdi, 6
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dzeros
    mov rsi, rax
    mov rsi, r14
    add rsi, qword ptr [rbp-72]
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
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dlimbs:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L782_0:
    cmp r13, 0
    jge .L782_1
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L782_1:
    mov rsi, 0
    mov rdi, r13
    imul rdi, 8
    add rdi, r12
    mov rdx, rdi
    mov rax, qword ptr [rdx]
    mov rdi, rax
    sub rsi, rdi
    mov rdi, rbx
    mov rdx, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    mov rsi, rax
    mov rsi, r13
    sub rsi, 1
    mov rdi, r14
    add rdi, 9
    mov r13, rsi
    mov r14, rdi
    jmp .L782_0
.globl zyl_zeroize
zyl_zeroize:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rsi
.L783_0:
    cmp rdi, 0
    jne .L783_2
    jmp .L783_3
.L783_2:
    cmp rbx, 0
    jg .L783_1
.L783_3:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L783_1:
    mov rsi, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Dzero_x2Dbytes
    mov rsi, rax
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Dzero_x2Dbytes:
    push rbp
    mov rbp, rsp
.L784_0:
    cmp rsi, 0
    jg .L784_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L784_1:
    mov r8, 0
    mov rdx, rdi
    mov rcx, r8
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r8, rax
    mov r8, rdi
    add r8, 1
    mov r9, rsi
    sub r9, 1
    mov rdi, r8
    mov rsi, r9
    jmp .L784_0
zy_local_x2Fmain_0__crypto__cr_x2Dwipe:
    push rbp
    mov rbp, rsp
.L785_0:
    cmp rsi, 0
    jg .L785_1
    mov r8, 0
    mov rax, r8
    mov rsp, rbp
    pop rbp
    ret
.L785_1:
    mov r8, 0
    mov rdx, rdi
    mov rcx, r8
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r8, rax
    mov r8, rdi
    add r8, 8
    mov r9, rsi
    sub r9, 8
    mov rdi, r8
    mov rsi, r9
    jmp .L785_0
zy_local_x2Fmain_0__crypto__cr_x2Dpack:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L786_0:
    cmp r9, r8
    jl .L786_1
    mov r10, 0
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L786_1:
    mov r10, rdi
    add r10, r9
    mov rbx, r9
    imul rbx, 8
    add rbx, rsi
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rbx, rax
    mov rdx, r10
    mov rcx, rbx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov r10, rax
    mov r10, r9
    add r10, 1
    mov r9, r10
    jmp .L786_0
zy_local_x2Fmain_0__crypto__cr_x2Dunpack:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov r8, rdx
    mov r9, rcx
.L787_0:
    cmp r9, r8
    jl .L787_1
    mov r10, 0
    mov rax, r10
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L787_1:
    mov r10, r9
    imul r10, 8
    add r10, rdi
    mov rbx, rsi
    add rbx, r9
    mov rdx, rbx
    movzx eax, byte ptr [rdx]
    mov rbx, rax
    mov rdx, r10
    mov rcx, rbx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov r10, rax
    mov r10, r9
    add r10, 1
    mov r9, r10
    jmp .L787_0
zy_local_x2Fmain_0__crypto__cr_x2Dwords_x2Ddata:
    push rbp
    mov rbp, rsp
.L788_0:
    lea rax, [rip+.L789]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock:
    push rbp
    mov rbp, rsp
.L790_0:
    call zyl_words_len
    mov rsi, rax
    cmp rsi, 16
    jge .L790_1
    lea rax, [rip+.L791]
    mov rdi, rax
    mov r8, 15
    mov rdx, rsi
    mov rsi, r8
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L790_1:
    mov rsi, 0
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Dscratch:
    push rbp
    mov rbp, rsp
.L792_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_aes@tpoff]
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Drounds:
    push rbp
    mov rbp, rsp
    mov r8, rdx
    mov r9, rcx
.L793_0:
    cmp r8, r9
    jge .L793_1
    mov r10, r8
    imul r10, 16
    add r10, rsi
    mov rdx, rdi
    mov rcx, r10
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    aesenc xmm0, xmm1
    movdqu [rdx], xmm0
    pxor xmm0, xmm0
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3
    mov rax, rdx
    mov r10, rax
    mov r10, r8
    add r10, 1
    mov r8, r10
    jmp .L793_0
.L793_1:
    mov r8, r9
    imul r8, 16
    add rsi, r8
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    aesenclast xmm0, xmm1
    movdqu [rdx], xmm0
    pxor xmm0, xmm0
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3
    mov rax, rdx
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_aes_encrypt_block
zyl_aes_encrypt_block:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    mov rbx, rdi
    mov qword ptr [rbp-48], rsi
    mov r13, rdx
    mov r14, rcx
.L794_0:
    call zyl_cpuid_features
    mov rsi, rax
    and rsi, 1
    cmp rsi, 0
    jle .L794_2
    mov rsi, 0
    jmp .L794_3
.L794_2:
    mov rdi, 1
    mov rsi, rdi
.L794_3:
    cmp rsi, 0
    je .L794_1
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
.L794_1:
    cmp qword ptr [rbp-48], 16
    jne .L794_7
    jmp .L794_8
.L794_7:
    cmp qword ptr [rbp-48], 32
    jne .L794_5
.L794_8:
    mov rsi, 0
    jmp .L794_6
.L794_5:
    mov rdi, 1
    mov rsi, rdi
.L794_6:
    cmp rsi, 0
    je .L794_4
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
.L794_4:
    mov rdi, rbx
    call zyl_words_len
    mov rsi, rax
    cmp rsi, qword ptr [rbp-48]
    jge .L794_9
    lea rax, [rip+.L795]
    mov r15, rax
    mov r12, qword ptr [rbp-48]
    sub r12, 1
    mov rdi, rbx
    call zyl_words_len
    mov rsi, rax
    mov rdi, r15
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    mov rsi, rax
    jmp .L794_10
.L794_9:
    mov rdi, 0
    mov rsi, rdi
.L794_10:
    lea rax, [rip+.L796]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rbx, rsi
    mov rdi, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock
    mov rsi, rax
    lea rax, [rip+.L797]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r12, rsi
    mov rdi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock
    mov rsi, rax
    lea rax, [rip+.L798]
    mov rsi, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_aes@tpoff]
    mov rsi, rax
    mov qword ptr [rbp-56], rsi
    mov rsi, qword ptr [rbp-56]
    add rsi, 240
    mov r15, rsi
    mov rsi, qword ptr [rbp-56]
    add rsi, 272
    mov r14, rsi
    mov rsi, 0
    mov rdi, r15
    mov rdx, qword ptr [rbp-48]
    mov rcx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Dpack
    mov rsi, rax
    mov rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dpack
    mov rsi, rax
    cmp qword ptr [rbp-48], 16
    jne .L794_11
    mov rsi, 10
    jmp .L794_12
.L794_11:
    mov rdi, 14
    mov rsi, rdi
.L794_12:
    cmp qword ptr [rbp-48], 16
    jne .L794_13
    mov rdx, qword ptr [rbp-56]
    mov rcx, r15
    movdqu xmm1, [rcx]
    movdqu [rdx+0], xmm1
    aeskeygenassist xmm2, xmm1, 1
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+16], xmm1
    aeskeygenassist xmm2, xmm1, 2
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+32], xmm1
    aeskeygenassist xmm2, xmm1, 4
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+48], xmm1
    aeskeygenassist xmm2, xmm1, 8
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+64], xmm1
    aeskeygenassist xmm2, xmm1, 16
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+80], xmm1
    aeskeygenassist xmm2, xmm1, 32
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+96], xmm1
    aeskeygenassist xmm2, xmm1, 64
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+112], xmm1
    aeskeygenassist xmm2, xmm1, 128
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+128], xmm1
    aeskeygenassist xmm2, xmm1, 27
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+144], xmm1
    aeskeygenassist xmm2, xmm1, 54
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+160], xmm1
    pxor xmm0, xmm0
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3
    mov rax, rdx
    mov rdi, rax
    jmp .L794_14
.L794_13:
    mov rdx, qword ptr [rbp-56]
    mov rcx, r15
    movdqu xmm0, [rcx]
    movdqu xmm1, [rcx+16]
    movdqu [rdx+0], xmm0
    movdqu [rdx+16], xmm1
    aeskeygenassist xmm2, xmm1, 1
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pxor xmm0, xmm2
    movdqu [rdx+32], xmm0
    aeskeygenassist xmm2, xmm0, 0
    pshufd xmm2, xmm2, 170
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+48], xmm1
    aeskeygenassist xmm2, xmm1, 2
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pxor xmm0, xmm2
    movdqu [rdx+64], xmm0
    aeskeygenassist xmm2, xmm0, 0
    pshufd xmm2, xmm2, 170
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+80], xmm1
    aeskeygenassist xmm2, xmm1, 4
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pxor xmm0, xmm2
    movdqu [rdx+96], xmm0
    aeskeygenassist xmm2, xmm0, 0
    pshufd xmm2, xmm2, 170
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+112], xmm1
    aeskeygenassist xmm2, xmm1, 8
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pxor xmm0, xmm2
    movdqu [rdx+128], xmm0
    aeskeygenassist xmm2, xmm0, 0
    pshufd xmm2, xmm2, 170
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+144], xmm1
    aeskeygenassist xmm2, xmm1, 16
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pxor xmm0, xmm2
    movdqu [rdx+160], xmm0
    aeskeygenassist xmm2, xmm0, 0
    pshufd xmm2, xmm2, 170
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+176], xmm1
    aeskeygenassist xmm2, xmm1, 32
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pxor xmm0, xmm2
    movdqu [rdx+192], xmm0
    aeskeygenassist xmm2, xmm0, 0
    pshufd xmm2, xmm2, 170
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    movdqu [rdx+208], xmm1
    aeskeygenassist xmm2, xmm1, 64
    pshufd xmm2, xmm2, 255
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pxor xmm0, xmm2
    movdqu [rdx+224], xmm0
    pxor xmm0, xmm0
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3
    mov rax, rdx
    mov r8, rax
    mov rdi, r8
.L794_14:
    mov rdx, r14
    mov rcx, qword ptr [rbp-56]
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pxor xmm0, xmm1
    movdqu [rdx], xmm0
    pxor xmm0, xmm0
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3
    mov rax, rdx
    mov rdi, rax
    mov rdi, 1
    mov rdx, rdi
    mov rdi, r14
    mov rcx, rsi
    mov rsi, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Drounds
    mov rsi, rax
    mov rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rsi, r14
    mov rcx, rdi
    mov rdi, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dunpack
    mov rsi, rax
    mov rsi, 288
    mov rdi, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__crypto__cr_x2Dwipe
    mov rsi, rax
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
zy_local_x2Fmain_0__crypto__cr_x2Dgetrandom:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L799_0:
    cmp r13, r12
    jl .L799_1
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L799_1:
    mov rsi, rbx
    add rsi, r13
    mov rdi, r12
    sub rdi, r13
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_318
    mov rsi, rax
    cmp rsi, 0
    jge .L799_2
    cmp rsi, -4
    jne .L799_3
    jmp .L799_0
.L799_3:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L799_2:
    add rsi, r13
    mov r13, rsi
    jmp .L799_0
zy_local_x2Fmain_0__crypto__cr_x2Dread_x2Dall:
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
    mov r14, rcx
.L800_0:
    cmp r14, r13
    jl .L800_1
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L800_1:
    mov rsi, r12
    add rsi, r14
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L800_2
    mov rdi, r14
    add rdi, rsi
    mov r14, rdi
    jmp .L800_0
.L800_2:
    cmp rsi, -4
    jne .L800_3
    jmp .L800_0
.L800_3:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Durandom:
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
.L801_0:
    lea rax, [rip+.L802]
    mov rsi, rax
    mov rdi, 524288
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_2
    mov rsi, rax
    mov r14, rsi
    cmp r14, 0
    jge .L801_1
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L801_1:
    mov rdi, r14
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dread_x2Dall
    mov rsi, rax
    mov rbx, rsi
    mov rdi, r14
    call zyl_rt_sys_3
    mov rsi, rax
    cmp rbx, r12
    jne .L801_2
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L801_2:
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_random_fill
zyl_random_fill:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L803_0:
    cmp rbx, 0
    jne .L803_2
    jmp .L803_3
.L803_2:
    cmp r12, 0
    jg .L803_1
.L803_3:
    mov rsi, -1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L803_1:
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__crypto__cr_x2Dgetrandom
    mov rsi, rax
    cmp rsi, r12
    jne .L803_4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L803_4:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__crypto__cr_x2Durandom
zy_local_x2Fmain_0__crypto__cr_x2Drand_x2Dchunks:
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
.L804_0:
    cmp r13, r12
    jl .L804_1
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L804_1:
    mov rsi, r12
    sub rsi, r13
    cmp rsi, 256
    jle .L804_2
    mov rsi, 256
    jmp .L804_3
.L804_2:
    mov rdi, r12
    sub rdi, r13
    mov rsi, rdi
.L804_3:
    mov r15, rsi
    mov rdi, r14
    mov rsi, r15
    call zyl_random_fill
    mov rsi, rax
    cmp rsi, r15
    jne .L804_5
    mov rsi, 0
    jmp .L804_6
.L804_5:
    mov rdi, 1
    mov rsi, rdi
.L804_6:
    cmp rsi, 0
    je .L804_4
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
.L804_4:
    mov rsi, r13
    imul rsi, 8
    add rsi, rbx
    mov rdi, 0
    mov rdx, r15
    mov rcx, rdi
    mov rdi, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dunpack
    mov rsi, rax
    mov rsi, r13
    add rsi, r15
    mov r13, rsi
    jmp .L804_0
.globl zyl_random_words
zyl_random_words:
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
.L805_0:
    cmp rbx, 0
    jne .L805_2
    jmp .L805_3
.L805_2:
    cmp r12, 0
    jg .L805_1
.L805_3:
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
.L805_1:
    lea rax, [rip+.L806]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    add rsi, 16
    mov rdx, rsi
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov r13, rsi
    mov rdi, rbx
    call zyl_words_len
    mov rsi, rax
    cmp r12, rsi
    jle .L805_4
    lea rax, [rip+.L807]
    mov r14, rax
    mov r15, r12
    sub r15, 1
    mov rdi, rbx
    call zyl_words_len
    mov rsi, rax
    mov rdi, r14
    mov rdx, rsi
    mov rsi, r15
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    mov rsi, rax
    jmp .L805_5
.L805_4:
    mov rdi, 0
    mov rsi, rdi
.L805_5:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rand@tpoff]
    mov rsi, rax
    mov rbx, rsi
    mov rsi, 0
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Drand_x2Dchunks
    mov rsi, rax
    mov r12, rsi
    mov rsi, 256
    mov rdi, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Dwipe
    mov rsi, rax
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dguard:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L808_0:
    cmp rdi, 4096
    jge .L808_1
    lea rax, [rip+.L809]
    mov rbx, rax
    lea rax, [rip+.L810]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dhex
    mov rsi, rax
    lea rax, [rip+.L811]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
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
    mov rsi, 1
    mov rdi, rsi
    call exit
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L808_1:
    mov rsi, 0
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dcode_x2Dp:
    push rbp
    mov rbp, rsp
.L812_0:
    mov rsi, 4294967296
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_call0
zyl_call0:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
.L813_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rsi, rax
    mov rsi, 4294967296
    cmp rbx, rsi
    jge .L813_1
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call0
.L813_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call1
.globl zyl_call1
zyl_call1:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L814_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rsi, rax
    mov rsi, 4294967296
    cmp rbx, rsi
    jge .L814_1
    mov rdi, rbx
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call1
.L814_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    mov rdx, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call2
.globl zyl_call2
zyl_call2:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L815_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rsi, rax
    mov rsi, 4294967296
    cmp rbx, rsi
    jge .L815_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call2
.L815_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call3
.globl zyl_call3
zyl_call3:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L816_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rsi, rax
    mov rsi, 4294967296
    cmp rbx, rsi
    jge .L816_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call3
.L816_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    mov r8, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call4
.globl zyl_call4
zyl_call4:
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
    mov r15, r8
.L817_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rsi, rax
    mov rsi, 4294967296
    cmp rbx, rsi
    jge .L817_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    mov r8, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call4
.L817_1:
    mov rdx, rbx
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    mov r8, r14
    mov r9, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call5
.globl zyl_call5
zyl_call5:
    push rbp
    mov rbp, rsp
    sub rsp, 152
    mov [rbp-152], rbx
    mov [rbp-144], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-8]
call zy_local_x2Fmain_0__call__rt_x2Dguard
    add rsp, 16
    mov [rbp-56], rax
    mov rax, [rbp-8]
    mov rcx, 4294967296
    cmp rax, rcx
    jge .L818
    sub rsp, 48
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    mov rdx, [rbp-24]
    mov rcx, [rbp-32]
    mov r8, [rbp-40]
    mov r9, [rbp-48]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call5
    mov rsp, r12
    add rsp, 48
    jmp .L819
.L818:
    mov rax, [rbp-8]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r9, [rsp+16]
    mov r8, [rsp+24]
    mov rcx, [rsp+32]
    mov rdx, [rsp+40]
    mov rsi, [rsp+48]
    mov rdi, [rsp+56]
    mov r12, rsp
    sub rsp, 8
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
call zyl_rt_call6
    mov rsp, r12
    add rsp, 64
.L819:
    mov rbx, [rbp-152]
    mov r12, [rbp-144]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_call6
zyl_call6:
    push rbp
    mov rbp, rsp
    sub rsp, 168
    mov [rbp-168], rbx
    mov [rbp-160], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    mov r10, [rbp+16]
    mov [rbp-56], r10
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-8]
call zy_local_x2Fmain_0__call__rt_x2Dguard
    add rsp, 16
    mov [rbp-64], rax
    mov rax, [rbp-8]
    mov rcx, 4294967296
    cmp rax, rcx
    jge .L820
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r9, [rsp+16]
    mov r8, [rsp+24]
    mov rcx, [rsp+32]
    mov rdx, [rsp+40]
    mov rsi, [rsp+48]
    mov rdi, [rsp+56]
    mov r12, rsp
    sub rsp, 8
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
call zyl_rt_call6
    mov rsp, r12
    add rsp, 64
    jmp .L821
.L820:
    mov rax, [rbp-8]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r10, [rsp+16]
    push r10
    mov r9, [rsp+32]
    mov r8, [rsp+40]
    mov rcx, [rsp+48]
    mov rdx, [rsp+56]
    mov rsi, [rsp+64]
    mov rdi, [rsp+72]
    mov r12, rsp
    sub rsp, 16
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
call zyl_rt_call7
    mov rsp, r12
    add rsp, 80
.L821:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dmin64:
    push rbp
    mov rbp, rsp
.L822_0:
    mov rsi, -9223372036854775808
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dult:
    push rbp
    mov rbp, rsp
.L823_0:
    mov r8, -9223372036854775808
    xor rdi, r8
    mov r8, -9223372036854775808
    xor rsi, r8
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dmagic_x2Dloop:
    push rbp
    mov rbp, rsp
    sub rsp, 264
    mov [rbp-264], rbx
    mov [rbp-256], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    mov r10, [rbp+16]
    mov [rbp-56], r10
    mov r10, [rbp+24]
    mov [rbp-64], r10
    mov r10, [rbp+32]
    mov [rbp-72], r10
    mov rax, [rbp-32]
    mov rcx, 1
    add rax, rcx
    mov [rbp-80], rax
    mov rax, [rbp-40]
    mov rcx, 2
    imul rax, rcx
    mov [rbp-88], rax
    mov rax, [rbp-48]
    mov rcx, 2
    imul rax, rcx
    mov [rbp-96], rax
    mov rax, [rbp-96]
    mov rcx, -9223372036854775808
    xor rax, rcx
    push rax
    mov rax, [rbp-24]
    mov rcx, -9223372036854775808
    xor rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    jge .L824
    mov rax, 0
    jmp .L825
.L824:
    mov rax, 1
.L825:
    mov [rbp-104], rax
    mov rax, [rbp-104]
    test rax, rax
    je .L826
    mov rax, [rbp-88]
    mov rcx, 1
    add rax, rcx
    jmp .L827
.L826:
    mov rax, [rbp-88]
.L827:
    mov [rbp-112], rax
    mov rax, [rbp-104]
    test rax, rax
    je .L828
    mov rax, [rbp-96]
    mov rcx, [rbp-24]
    sub rax, rcx
    jmp .L829
.L828:
    mov rax, [rbp-96]
.L829:
    mov [rbp-120], rax
    mov rax, [rbp-56]
    mov rcx, 2
    imul rax, rcx
    mov [rbp-128], rax
    mov rax, [rbp-64]
    mov rcx, 2
    imul rax, rcx
    mov [rbp-136], rax
    mov rax, [rbp-136]
    mov rcx, -9223372036854775808
    xor rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rcx, -9223372036854775808
    xor rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    jge .L830
    mov rax, 0
    jmp .L831
.L830:
    mov rax, 1
.L831:
    mov [rbp-144], rax
    mov rax, [rbp-144]
    test rax, rax
    je .L832
    mov rax, [rbp-128]
    mov rcx, 1
    add rax, rcx
    jmp .L833
.L832:
    mov rax, [rbp-128]
.L833:
    mov [rbp-152], rax
    mov rax, [rbp-144]
    test rax, rax
    je .L834
    mov rax, [rbp-136]
    mov rcx, [rbp-16]
    sub rax, rcx
    jmp .L835
.L834:
    mov rax, [rbp-136]
.L835:
    mov [rbp-160], rax
    mov rax, [rbp-16]
    mov rcx, [rbp-160]
    sub rax, rcx
    mov [rbp-168], rax
    mov rax, [rbp-112]
    mov rcx, -9223372036854775808
    xor rax, rcx
    push rax
    mov rax, [rbp-168]
    mov rcx, -9223372036854775808
    xor rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    jge .L838
    mov rax, 1
    jmp .L839
.L838:
    mov rax, [rbp-112]
    mov rcx, [rbp-168]
    cmp rax, rcx
    jne .L840
    mov rax, [rbp-120]
    mov rcx, 0
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L841
.L840:
    mov rax, 0
.L841:
.L839:
    test rax, rax
    je .L836
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-80]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-112]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-120]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-152]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-160]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-72]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+16]
    mov [rbp+16], r10
    mov r10, [rsp+8]
    mov [rbp+24], r10
    mov r10, [rsp+0]
    mov [rbp+32], r10
    mov r9, [rsp+24]
    mov r8, [rsp+32]
    mov rcx, [rsp+40]
    mov rdx, [rsp+48]
    mov rsi, [rsp+56]
    mov rdi, [rsp+64]
    mov rbx, [rbp-264]
    mov r12, [rbp-256]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic_x2Dloop
    jmp .L837
.L836:
    mov rax, [rbp-72]
    test rax, rax
    je .L842
    mov rax, [rbp-80]
    mov rcx, 64
    sub rax, rcx
    jmp .L843
.L842:
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jge .L844
    mov rax, [rbp-152]
    mov rcx, 1
    add rax, rcx
    mov rcx, rax
    mov rax, 0
    sub rax, rcx
    jmp .L845
.L844:
    mov rax, [rbp-152]
    mov rcx, 1
    add rax, rcx
.L845:
.L843:
.L837:
    mov rbx, [rbp-264]
    mov r12, [rbp-256]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dmagic:
    push rbp
    mov rbp, rsp
    sub rsp, 168
    mov [rbp-168], rbx
    mov [rbp-160], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov rcx, 1
    cmp rax, rcx
    jg .L848
    mov rax, [rbp-8]
    mov rcx, -1
    cmp rax, rcx
    setge al
    movzx rax, al
    jmp .L849
.L848:
    mov rax, 0
.L849:
    test rax, rax
    je .L846
    mov rax, 0
    jmp .L847
.L846:
    mov rax, -9223372036854775808
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jge .L850
    mov rax, 0
    mov rcx, [rbp-8]
    sub rax, rcx
    jmp .L851
.L850:
    mov rax, [rbp-8]
.L851:
    mov [rbp-32], rax
    mov rax, [rbp-8]
    mov rcx, 63
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rcx, 1
    and rax, rcx
    mov rcx, rax
    mov rax, [rbp-24]
    add rax, rcx
    mov [rbp-40], rax
    mov rax, [rbp-40]
    mov rcx, 1
    sub rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rdx
    mov rax, rdx
    xor edx, edx
    div rcx
    mov rax, rdx
    mov rcx, rax
    pop rax
    sub rax, rcx
    mov [rbp-48], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rdx
    mov rax, rdx
    xor edx, edx
    div rcx
    mov [rbp-56], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rdx
    mov rax, rdx
    xor edx, edx
    div rcx
    mov [rbp-64], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 63
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    mov rcx, [rbp-48]
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-24]
    sub rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-64]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-64]
    mov rcx, [rbp-32]
    imul rax, rcx
    mov rcx, rax
    mov rax, [rbp-24]
    sub rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov r10, [rsp+0]
    push r10
    mov r10, [rsp+16]
    push r10
    mov r10, [rsp+32]
    push r10
    mov r9, [rsp+48]
    mov r8, [rsp+56]
    mov rcx, [rsp+64]
    mov rdx, [rsp+72]
    mov rsi, [rsp+80]
    mov rdi, [rsp+88]
call zy_local_x2Fmain_0__call__rt_x2Dmagic_x2Dloop
    add rsp, 96
.L847:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_div_magic
zyl_div_magic:
    push rbp
    mov rbp, rsp
.L852_0:
    mov rsi, 0
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic
.globl zyl_div_shift
zyl_div_shift:
    push rbp
    mov rbp, rsp
.L853_0:
    mov rsi, 1
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic
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
.L854_0:
    cmp r8, r9
    jl .L854_1
    cmp r10, rbx
    jge .L854_2
    mov r12, -1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L854_2:
    cmp r10, rbx
    jle .L854_3
    mov r12, 1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L854_3:
    mov r12, 0
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L854_1:
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
    jge .L854_4
    mov r14, -1
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L854_4:
    cmp r12, r13
    jle .L854_5
    mov r12, 1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L854_5:
    mov r12, r8
    add r12, 1
    mov r8, r12
    jmp .L854_0
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
.L150:
    .string "E_INDEX_OUT_OF_BOUNDS: vector index "
.L151:
    .string " outside length "
.L155:
    .string "E_INDEX_OUT_OF_BOUNDS: pop from an empty vector"
.L181:
    .string "contract violated"
.L182:
    .string "warning: "
.L183:
    .string "\n"
.L192:
    .string "<input>"
.L193:
    .string ""
.L194:
    .string ""
.L197:
    .string "<input>"
.L205:
    .string ""
.L206:
    .string "..."
.L207:
    .string "..."
.L209:
    .string ""
.L212:
    .string ""
.L260:
    .string "0123456789abcdef"
.L262:
    .string "0123456789abcdef"
.L268:
    .string "rb"
.L270:
    .string "0123456789ABCDEF"
.L272:
    .string ""
.L274:
    .string ""
.L276:
    .string ""
.L277:
    .string "0123456789ABCDEF"
.L292:
    .string "0"
.L295:
    .string "0"
.L300:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L301:
    .string ": index "
.L302:
    .string " outside a word array of length "
.L305:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L306:
    .string ": not a word array"
.L308:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L309:
    .string ": not a word array"
.L311:
    .string "E_OUT_OF_MEMORY: word array view"
.L313:
    .string "E_OUT_OF_MEMORY: word array"
.L315:
    .string "w-len"
.L316:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L317:
    .string ": not a word array"
.L319:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L320:
    .string ": not a word array"
.L322:
    .string "w-get"
.L324:
    .string "w-set"
.L326:
    .string "w-view"
.L327:
    .string "w-view"
.L330:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L331:
    .string ": not an array"
.L333:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L334:
    .string ": not an array"
.L336:
    .string "E_OUT_OF_MEMORY: array"
.L338:
    .string "array-cap"
.L339:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L340:
    .string ": not an array"
.L342:
    .string "array-filled"
.L343:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L344:
    .string ": not an array"
.L346:
    .string "array-get"
.L347:
    .string "array-get"
.L348:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L349:
    .string ": not an array"
.L352:
    .string "array-copy"
.L353:
    .string "array-copy"
.L354:
    .string "array-copy"
.L355:
    .string "array-copy"
.L357:
    .string "array-set"
.L358:
    .string "array-set"
.L363:
    .string "attribute table"
.L372:
    .string "ref cell"
.L377:
    .string ""
.L382:
    .string "0123456789abcdef"
.L384:
    .string "zyl: str-append: invalid string pointer 0x"
.L385:
    .string ""
.L386:
    .string "\n"
.L388:
    .string "codegen buffer limit exceeded"
.L389:
    .string "E_INDEX_OUT_OF_BOUNDS: string buffer full"
.L436:
    .double 0.0
.L437:
    .double 0.0
.L442:
    .double -9.22e18
.L443:
    .double 9.22e18
.L459:
    .string "/proc/meminfo"
.L460:
    .string "MemAvailable:"
.L461:
    .string "MemTotal:"
.L464:
    .string "ZYL_MAX_MEMORY"
.L472:
    .string "PANIC: error[E_OUT_OF_MEMORY]: "
.L473:
    .string "\n  = requested "
.L474:
    .string " bytes; "
.L475:
    .string " bytes already allocated; budget "
.L476:
    .string " bytes\n  = help: set ZYL_MAX_MEMORY to a byte count to raise the budget, or ZYL_MAX_MEMORY=0 to remove it\n"
.L481:
    .string "memory budget exhausted"
.L482:
    .string "out of memory allocating an arena block header"
.L483:
    .string "out of memory allocating an arena block"
.L503:
    .string "\n"
.L505:
    .string "zyl_heap_alloc: size too large size="
.L506:
    .string "zyl_heap_alloc: FAILED size="
.L518:
    .string "memory budget exhausted"
.L519:
    .string "mmap failed for a region block"
.L528:
    .string "E_REGION_EXHAUSTED: "
.L529:
    .string "fixed"
.L530:
    .string "arena"
.L531:
    .string " region of "
.L532:
    .string " bytes is full"
.L536:
    .string "zyl_ralloc: size too large size="
.L557:
    .string "file-write"
.L563:
    .string "mkdir-p"
.L572:
    .string ""
.L573:
    .string "/"
.L586:
    .string "/"
.L604:
    .string ""
.L606:
    .string "list-zyl-files"
.L607:
    .string ".zyl"
.L609:
    .string "list-files"
.L610:
    .string "list-files"
.L616:
    .string "[?2004l[0m"
.L625:
    .string "term-write"
.L630:
    .string "union-find table"
.L643:
    .string "zyl: mem-read: null pointer\n"
.L645:
    .string "zyl: mem-write: null pointer\n"
.L647:
    .string "cstr-byte-set"
.L650:
    .string "ZYL_REGIONS"
.L654:
    .string "codegen buffer limit exceeded"
.L660:
    .string "eef453d6923bd65a113faa2906a13b3f9558b4661b6565f84ac7ca59a424c507baaee17fa23ebf765d79bcf00d2df649e95a99df8ace6f53f4d82c2c107973dc91d8a02bb6c1059479071b9b8a4be869b64ec836a47146f99748e2826cdee284e3e27a444d8d98b7fd1b1b2308169b258e6d8c6ab0787f72fe30f0f5e50e20f7b208ef855c969f4fbdbd2d335e51a935de8b2b66b3bc4723ad2c788035e613828b16fb203055ac764c3bcb5021afcc31addcb9e83c6b1793df4abe242a1bbf3dd953e8624b85dd78d71d6dad34a2af0d87d4713d6f33aa6b8672648c40e5ad68a9c98d8ccb009506680efdaf511f18c2d43bf0effdc0ba480212bd1b2566def284a57695fe98746d014bb630f7604b57a5ced43b7e3e9188419ea3bd35385e2dcf42894a5dce35ea52064cac828675b9818995ce7aa0e1b27343efebd1940993a1ebfb4219491a1f1014ebe6c5f90bf8ca66fa129f9b60a6d41a26e077774ef6fd00b897478238d08920b098955522b49e20735e8cb1638255b46e5f5d5535b0c5a890362fddbc62eb2189f734aa831df712b443bbd52b7ba5e9ec7501d523e49a6bb0aa55653b2d47b233c92125366ec1069cd4eabe89f8999ec0bb696e840af148440a256e2c76c00670ea43ca250d96cd2a865764dbca380406926a5e5728bc807527ed3e12bcc605083704f5ecf2eba09271e88d976bf7864a44c633682e93445b8731587ea37ab3ee6afbe0211db8157268fdae9e4c5960ea05bad82964e61acf033d1a45df6fb92487298e33bd8fd0c16206306baba5d3b6d479f8e056b3c4f1ba87bc86968f48a4899877186ce0b62e2929aba83c331acdabfe94de878c71dcd9ba0b49259ff0c08b7f1d0b14af8e5410288e1b6f07ecf0ae5ee44dd9db71e91432b1a24ac9e82cd9f69d6150892731ac9faf056ebe311c083a225cd2ab70fe17c79ac6ca6dbd630a48aaf406d64d3d9db981787d092cbbccdad5b10885f0468293f0eb4e25bbf56008c58ea5a76c582338ed2621af2af2b80af6f24ed1476e2c07286faa1af5af660db4aee182cca4db847945ca50d98d9fc890ed4da37fce126597973ce50ff107bab528a0cc5fc196fefd7d0c1e53ed49a96272c8ff77b1fcbebcdc4f25e8e89c13bb0f7a9faacf3df73609b177b191618c54e9acc795830d75038c1dd59df5b9ef6a2417f97ae3d0d2446f254b0573286b44ad1d9becce62836ac5774ee367f9430aec32c2e801fb244576d5229c41f793cda73ff3a20279ed56d48a6b43527578c1110f9845418c345644d6830a13896b78aaa9be5691ef416bd60c23cc986bc656d553edec366b11c6cb8f2cbfbe86b7ec8aa894b3a202eb1c3f397bf7d71432f3d6a9b9e08a83a5e34f07daf5ccd93fb0cc53e858ad248f5c22c9d1b3400f8f9cff6891376c36d99995be23100809b9c21fa1b58547448ffffb2dabd40a0c2832a78ae2e69915b3fff9f916c90c8f323f516c8dd01fad907ffc3bae3da7d97f6792e3b1442798f49ffb4a99cd11cfdf41779cdd95317f31c7fa1d40405643d711d5838a7d3eef7f1cfc52482835ea666b2572ad1c8eab5ee43b66da3243650005eecfd863b256369d4a4090bed43e40076a82873e4f75e2224e685a7744a6e804a291a90de3535aaae202711515d0a205cb36d3515c2831559a830d5a5b44ca873e038412d9991ed58091e858790afe9486c2a5178fff668ae0b6626e974dbe39a872ce5d73ff402d98e3fb0a3d212dc8128f80fa687f881c7f8e7ce66634bc9d0b99a139029f6a239f721c1fffc1ebc44e80c987434744ac874ea327ffb266b56220fbe9141915d7a9224bf1ff9f0062baa89d71ac8fada6c9b56f773fc3603db4a9c4ce17b399107c22cb550fb4384d21d3f6019da07f549b2b7e2a53a146606a4899c102844f94e0fb2eda7444cbfc426dc0314325637a1939fa911155fefb5308f03d93eebc589f88793555ab7eba27ca96267c7535b763b54bc1558b2f3458debbb01b9283253ca29eb1aaedfb016f16ea9c227723ee8bcb465e15a979c1cadc92a1958a7675175f0bfacd89ec191ec9b749faed14125d36cef980ec671f667be51c79a85916f48482b7e12780e7401a8f31cc0937ae58d2d1b2ecb8b0908810b2fe3f0b8599ef07861fa7e6dcb4aa15dfbdcece67006ac967a791e093e1d49a8bd6a141006042bde0c8bb2c5c6d24e0aecc49914078536d58fae9f773886e18da7f5bf590966848af39a475506a899e888f99797a5e012d6d8406c952429603aab37fd7d8f58178c8e5087ba6d33b83d5605fcdcf32e1d6fb1e4a9a90880a64855c3be0a17fcd265cf2eea09a55067fa6b34ad8c9dfc06ff42faa48c0ea481ed0601d8efc57b08bf13b94daf124da26823c12795db6ce5776c53d08d6b70858a2cb1717b52481ed54768c4b0c64ca6ecb7ddcdda26da268a9942f5dcf7dfd09fe5d54150b090b02d3f93b35435d7c4c9efa548d26e5a6e1c47bc5014a1a6dafc6b8e9b0709f109a359ab6419ca1091bf867241c8cc6d4c0c30163d203c94b629b407691d7fc44f879e0de63425dcf1dc21094364dfb5636985915fc12f542e4f294b943e17a2bc43e6f5b7b17b2939d979cf3ca6cec5b5aa705992ceecf9c42bd8430bd0827723150c6ff782a838353ece53cec4a314ebda4f8bf5635246428940f4613ae5ed136871b7795e136be99b913179899f6858428e2557b59846e3fe757dd7ec07426e5331aeada2fe589cf9096ea6f3848984f3ff0d2c85def7621b4bca50b065abe630fed077a756b53a9e1ebce4dc7f16dfbd3e8495912c628948d3360f09cf6e4bd64712dd7abbbd95cb080392cc4349decbd8d794d96aacfb3dca04777f541c567ecf0d7a0fc5583a089e42caaf9491b60f41686c49db57244ac5d37d5b79b6239311c2875c522ced5d77485cb25823ac77d633293366b828b86a8d39ef77164bcae5dff9c02033197a8530886b54dbdebd9f57f830283fdfcd267caa862a12d66d072df63c324fd7b8380dea93da4bc604247cb9e59f71e6da46116538d0deb7852d9be85f074e608cd795be87051665667902e276c921f8b806bd9714632dff600ba1cd8a3db53b6a086cfcd97bf97f380e8a40eccd228a4c8a883c0fdaf7df06122cd128006b2cdfad2a4b13d1b5d6c796b805720085f819cc3a6eec6311a63cbe3303674053bb0c3f490aa77bd60fcbedbfc4411068a9cf4f1b4d515acb93bee92fb5515482d44991711052d8bf3c5751bdd152d4d1c4abf5cd54678eef0b6d262d45a78a0635def340a98172aace486fb897116c87c349580869f0e7aac0ed45d35e6ae3d4da0bae0a846d21957128974836059cca109e998d258869facd72bd1a438703fc94b91ff83775423cc067b6306a34627ddcfb67f6455292cbf081a3bc84c17b1d542e41f3d6a7377eeca20caba5f1d9e4a938e938662882af53e547eb47b7282ee9cb23867fb2a35b28de99e619a4f23aa43dec681f9f4c31f316405fa00e2ec94d48b3c113c38f9f37ede83bc408dd3dd04ae0b158b4738705e9624ab50b148d445d98ddaee19068c763badd624dd9b095787f8a8d4cfa417c9e54ca5d70a80e5d6a9f6d30a038d1dbc5e9fcf4ccd211f4cd47487cc8470652b7647c3200069671f84c8d4dfd2c63f3b29ecd9f40041e073a5fb0a17c777cf09f468107100525890cf79cc9db955c2cc7182148d4066eeb481ac1fe293d599bfc6f14cd848405530a21727db38cb002fb8ada00e5a506a7cca9cf1d206fdc03ba6d90811f0e4851cfd442e4688bd304a908f4a166d1da6639e4a9cec15763e2e9a598e4e043287fec5dd44271ad3cdba40eff1e1853f29fdf7549530e188c128d12bee59e68ef47c9a94dd3e8cf578b982bb74f8301958cec13a148e3032d6e7e36a52363c1faf01f18899b1bc3f8ca1dc44e6c3cb279ac196f5600f15a7b7e529ab103a5ef8c0b9bcb2b812db11a5de7415d448f6b6f0e7ebdf661791d60f56111b495b3464ad21936b9fcebb25c995cab10dd900beec34b84687c269ef3bfb3d5d514f40eea742e65829b3046b0afa0cb4a5a3112a51128ff71a0fe2c2e6dc47f0e785eaba72abb3f4e093db73a09359ed216765690f56e0f218b8d25088b8306869c13ec3532c8c974f73837255731e414218c73a13fbafbd2350644eeacfe5d1929ef90898fadbac6c247d62a583df45f746b74abf39894bc396ce5da7726b8bba8c328eb783ab9eb47c81f5114f066ea92f3f326564d686619ba27255a2c80a537b0efefebd8613fd0145877585bd06742ce95f5f36a798fc4196e952e72c48113823b73704d17f3b51fca3a7a0f75a15862ca504c582ef85133de648c49a984d73dbe722fba3ab66580d5fdaf5c13e60d0d2e0ebbacc963fee10b7d1b3318df905079926a8ffbbcfe994e5c61ffdf17746497f70529fd561f1fd0f9bd3feb6ea8bedefa633c7caba6e7c5382c8fe64a52ee96b8fc0f9bd690a1b68637b3dfdce7aa3c673b09c1661a651213e2d06bea10ca65c084ec31bfa0fe5698db8486e494fcff30a62f3e2f893dec3f1265a89dba3c3efccfa986ddb5c6b3a76b7f89629465a75e01cbe89523386091465f6bbb397f1135823ee2ba6c0678b597f746aa07ded582e2c94db483840b717efa8c2a44eb4571cdcba121a4650e4ddeb92f34d62616ce413e896a0d7e51e156677b020baf9c81d17915e2486ef32cd600ace1474dc1d122eb5b5ada8aaff80b80d819992132456bae3231912d5bf60e610e1fff697ed6c698df5efabc5979c8fca8d3ffa1ef463c1b1736b96b6fd83b3bd308ff8a6b17cb2ddd0467c64bce4a0ac7cb3f6d05ddbde8aa22c0dbef60ee46bcdf07a423aa96bad4ab7112eb3929d86c16c98d2c953c6d89d64d57a607744e871c7bf077ba8b787625f056c7c4a8b11471cd764ad4972a93af6c6c79b5d2dd598e40d3dd89bcfd389b478798234794aff1d108d4ec2c3843610cb4bf160cbcedf722a585139baa54394fe1eedb8fec2974eb4ee658828ce947a3da6a9273e733d226229feea32811ccc668829b8870806357d5a3f525fa163ff802a3426a8ca07c2dcb0cf26f7c9bcff6034c13052fc89b393dd02f0b5fc2c3f3841f17c67bbac2078d443ace29d9ba7832936edc0d54b944b84aa4c0dc5029163f384a9310a9e795e65d4df11f64335bcf065d37d4d4617b5ff4a16d599ea0196163fa42e504bced1bf8e4e45c06481fb9bcf8d39e45ec2862f71e1d6f07da27a82c370885d767327bb4e5a4c964e858c91ba26553a6a07f8d510f86fbbe226efb628afea890489f70a55368beadab0aba3b2dbe52b45ac74ccea842e92c8ae6b464fc96f3b0b8bc90012929db77ada0617e3bbcb09ce6ebb40173744e55990879ddcaabdcc420a6a101d05158f57fa54c2a9eab69fa946824a12232db32df8e9f354656447939822dc96abf9dff9772470297ebd59787e2b93bc56f78bfbea76c619ef3657eb4edb3c55b65aaefae51477a06b03ede622920b6b23f1dab99e59958885c4e95fab368e45eced88b402f7fd75539b11dbcb0218ebb414aae103b5fcd2a881d652bdc29f26a119d59944a37c0752a24be76d3346f0495f857fcae62d8493a56f70a4400c562ddba6dfbd9fb8e5b88ecb4ccd500f6bb952d097ad07a71f26b27e2000a41346a7a7825ecc24c873782f8ed400668c0c28c8a2f67f2dfa90563b728900802f0f32facbb41ef979346bca4f2b40a03ad2ffb9fea126b7d78186bce2f610c84987bfa89f24b832e6b0f4360dd9ca7d2df4d7c9c6ede63fa05d314391503d1c79720dbbf8a95fcf88747d9475a44c6397ce912a9b69dbe1b548ce7cc986afbe3ee11abac24452da229b021bfbe85badce996168f2d56790ab41c2a2fae27299423fb9c397c560ba6b0919a5dccd879fc967d41abdb6b8e905cb600f5400e987bbc1c920ed246723473e3813290123e9aab23b689436c0760c86e30bf9a0b6720aaf6521b94470938fa89bcef808e40e8d5b3e69e7958cb87392c2c2b60b1d1230b20e0490bd77f3483bb9b9b1c6f22b5e6f48c2b4ecd5f01a4aa8281e38aeb6360b1af3e2280b6c20dd523225c6da63c38de1b08d590723948a535f579c487e5a38ad0eb0af48ec79ace8372d835a9df0c6d851dcdb1b2798182244f8e431456cf88e658a08f0f8bf0f156b1b8e9ecb641b58ffac8b2d36eed2dac5e272467e3d222f3fd7adf884aa8791775b0ed81dcc6abb0f86ccbb52ea94baea98e947129fc2b4e9a87fea27a539e9a53f2398d747b36224d29fe4b18e88640e8eec7f0d19a03aad83a3eeeef9153e891953cf68300424aca48ceaaab75a8e2b5fa8c3423c052dd7cdb02555653131b63792f412cb06794d808e17555f3ebf11e2bbd88bbee40bd0a0b19d2ab70e6ed65b6aceaeae9d0ec4c8de047564d20a8bf245825a5a445275fb158592be068d2eeed6e2f0f0d567129ced737bb6c4183d55464dd69685606bc428d05aa4751e4caa97e14c3c26b886f53304714d9265dfd53dd99f4b3066a8993fe2c6d07b7fabe546a8038efe4029bf8fdb78849a5f96de98520472bdd033ef73d256a5c0f77c963e66858f6d444095a8637627989aaddde7001379a44aa8bb127c53b17ec1595560c018580d5d52e9d71b689dde71afaab8f01e6e10b4a69226712162ab070dcab3961304ca70e8b6b00d69bb55c8d13d607b97c5fd0d22e45c10c42a2b3b058cb89a7db77c506a8eb98a7a9a5b04e377f3608e92adb242b267ed1940f1c61c55f038b237591ed3df01e85f912e37a36b6c46dec52f66888b61313bbabce2c62323ac4b3b3da015ae397d8aa96c1b77abec975e0a0d081ad9c7dced53c7225596e7bd358c904a21881cea14545c75757e50d64177da2e54aa242499697392d2dde50bd1d5d0b9e9d4ad2dbfc3d07787955e4ec64b44e86484ec3c97da624ab4bd5af13bef0b113ea6274bbdd0fadd61ecb1ad8aeacdd58ecfb11ead453994ba67de18eda5814af281ceb32c4b43fcf480eacf948770ced7a2425ff75e14fc31a1258379a94d028dcad2f7f5359a3b3e096ee45813a04330fd87b5f28300ca0d8bca9d6e188853fc9e74d1b791e07e48775ea264cf55347ec612062576589dda95364afe032a819ef79687aed3eec5513a83ddbd83f522059abe14cd44753b52c4926a9672793543c16d9a0095928a2775b7053c0f178294f1c90080baf72cb15324c68b12dd6339971da05074da7beed3f6fc16ebca5e04bce5086492111aea88f4bb1ca6bcf585ec1e4a7db69561a52b31e9e3d06c32e69392ee8e921d5d073aff322e62439fd0b877aa3236a4b44909befeb9fad487c3e69594bec44de15b4c2ebe687989a9b4901d7cf73ab0acd90f9d37014bf60a11b424dc35095cd80f538484c19ef38c95e12e13424bb40e132865a5f206b06fba8cbccc096f5088cbf93f87b7442e45d4afebff0bcb24aafef78f69a51539d749dbe6fecebdedd5beb573440e5a884d1c89705f4136b4a59731680a88f8953031abcc77118461cefcfdc20d2b36ba7c3ed6bf94d5e57a42bc3d32907604691b4d8637bd05af6c69b5a63f9a49c2c1b110a7c5ac471b4784230fcf80dc33721d54d1b71758e219652bd3c36113404ea4a983126e978d4fdf3b645a1cac083126eaa3d70a3d70a3d70a3d70a3d70a3d70a4cccccccccccccccccccccccccccccccd80000000000000000000000000000000a0000000000000000000000000000000c8000000000000000000000000000000fa0000000000000000000000000000009c400000000000000000000000000000c3500000000000000000000000000000f424000000000000000000000000000098968000000000000000000000000000bebc2000000000000000000000000000ee6b28000000000000000000000000009502f900000000000000000000000000ba43b740000000000000000000000000e8d4a5100000000000000000000000009184e72a000000000000000000000000b5e620f4800000000000000000000000e35fa931a000000000000000000000008e1bc9bf040000000000000000000000b1a2bc2ec50000000000000000000000de0b6b3a7640000000000000000000008ac7230489e800000000000000000000ad78ebc5ac6200000000000000000000d8d726b7177a80000000000000000000878678326eac90000000000000000000a968163f0a57b4000000000000000000d3c21bcecceda100000000000000000084595161401484a00000000000000000a56fa5b99019a5c80000000000000000cecb8f27f4200f3a0000000000000000813f3978f89409844000000000000000a18f07d736b90be55000000000000000c9f2c9cd04674edea400000000000000fc6f7c40458122964d000000000000009dc5ada82b70b59df020000000000000c5371912364ce3056c28000000000000f684df56c3e01bc6c7320000000000009a130b963a6c115c3c7f400000000000c097ce7bc90715b34b9f100000000000f0bdc21abb48db201e86d4000000000096769950b50d88f41314448000000000bc143fa4e250eb3117d955a000000000eb194f8e1ae525fd5dcfab080000000092efd1b8d0cf37be5aa1cae500000000b7abc627050305adf14a3d9e40000000e596b7b0c643c7196d9ccd05d00000008f7e32ce7bea5c6fe4820023a2000000b35dbf821ae4f38bdda2802c8a800000e0352f62a19e306ed50b2037ad2000008c213d9da502de454526f422cc340000af298d050e4395d69670b12b7f410000daf3f04651d47b4c3c0cdd765f11400088d8762bf324cd0fa5880a69fb6ac800ab0e93b6efee00538eea0d047a457a00d5d238a4abe9806872a4904598d6d88085a36366eb71f04147a6da2b7f864750a70c3c40a64e6c51999090b65f67d924d0cf4b50cfe20765fff4b4e3f741cf6d82818f1281ed449fbff8f10e7a8921a4a321f2d7226895c7aff72d52192b6a0dcbea6f8ceb02bb399bf4f8a69f764490fee50b7025c36a0802f236d04753d5b49f4f2726179a224501d762422c946590c722f0ef9d80aad6424d3ad2b7b97ef5f8ebad2b84e0d58bd2e0898765a7deb29b934c3b330c857763cc55f49f88eb2fc2781f49ffcfa6d53cbf6b71c76b25fbf316271c7fc3908a8bef464e3945ef7a97edd871cfda3a5697758bf0e3cbb5acbde94e8e43d0c8ec3d52eeed1cbea317ed63a231d4c4fb274ca7aaa863ee4bdd945e455f24fb1cf88fe8caa93e74ef6ab975d6b6ee39e436b3e2fd538e122b44e7d34c64a9c85d4460dbbca87196b61690e40fbeea1d3a4abc8955e946fe31cdb51d13aea4a488dd6babab6398bdbe41e264589a4dcdab14c696963c7eed2dd18d7eb76070a08aecfc1e1de5cf543ca2b0de65388cc8ada83b25a55f43294bcbdd15fe86affad91249ef0eb713f39ebe8a2dbf142dfcc7ab6e3569326c784337acb92ed9397bf99649c2c37f07965404d7e77a8f87daf7fbdc33745ec97be90686f0ac99b4e8dafd69a028bb3ded71a3a8acd7c0222311bcc40832ea0d68ce0cd2d80db02aabd62bf50a3fa490c3019083c7088e1aab65db792667c6da79e0faa4b8cab1a1563f52577001b891185938cde6fd5e09abcf26ed4c0226b55e6f8680b05e5ac60b6178544f8158315b05b4a0dc75f1778e39d6696361ae3db1c721c913936dd571c84c03bc3a19cd1e38e9fb5878494ace3a5f04ab48a04065c7239d174b2dcec0e47b62eb0d64283f9c76c45d1df942711d9a3ba5d0bd324f8394f5746577930d6500ca8f44ec7ee364799968bf6abbe85f207e998b13cf4e1ecbbfc2ef456ae276e89e3fedd8c321a67eefb3ab16c59b14a2c5cfe94ef3ea101e95d04aee3b80ece5bba1f1d158724a12bb445da9ca61281f2a8a6e45ae8edc97ea1575143cf97226f52d09d71a3293bd924d692ca61be758593c2626705f9c56b6e0c377cfa2e12e6f8b2fb00c77836ce498f455c38b997a0b6dfb9c0f9564478edf98b59a373fec4724bd4189bd5eacb2977ee300c50fe758edec91ec2cb657df3d5e9bc0f653e12f2967b66737e3ed8b865b215899f46cbd79e0d20082ee74ae67f1e9aec07187ecd8590680a3aa11da01ee641a708de9e80e6f4820cc9495884134fe908658b23109058d147fdcddaa51823e34a7eedebd4b46f0599fd415d4e5e2cdc1d1ea966c9e18ac7007c91a850fadc09923329e03e2cf6bc604ddb0a6539930bf6bff4584db8346b786151ccfe87f7cef46ff16e612641865679a6381f14fae158c5f6e4fcb7e8f3f60c07ea26da3999aef7749e3be5e330f38f09dcb090c8001ab551c5cadf5bfd3072cc5fdcb4fa002162a6373d9732fc7c8f7f69e9f11c4014dda7e2867e7fddcdd9afac646d63501a1511db281e1fd541501b8f7d88bc24209a5651f225a7ca91a42269ae757596946075f3375788de9b06958c1a12d2fc39789370052d6b1641c83aef209787bb47d6b84c0678c5dbd23a49a9745eb4d50ce6332f840b7ba963646e0bd176620a501fbffb650e5a93bc3d898ec5d3fa8ce427affa3e51f138ab4cebe93ba47c980e98cdfc66f336c36b10137b8a8d9bbe123f017b80b0047445d4184e6d3102ad96cec1da60dc059157491e59043ea1ac7e4139287c89837ad68db2fb454e4a179dd187729babe4598c311fbe16a1dc9d8545e94f4296dd6fef3d67a8ce2529e2734bb1d1899e4a65f58660cb01ae745b101e9e45ec05dcff72e7f8fdc21a1171d42645d76707543f4fa1f73899504ae72497eba6a06494a791c53a8abfa45da0edbde690487db9d17636892d6f8d7509292d60345a9d2845d3c42b6865b86925b9bc5c20b8a2392ba45a9b2a7f26836f282b7328e6cac7768d7141ed1ef0244af2364ff3207d795430cd9268335616aed761f1f7f44e6bd49e807b8a402b9c5a8d3a6e75f16206c9c6209a6cd036837130890a136dba887c37a8c0f802221226be55a64c2494954da2c9789a02aa96b06deb0fdf2db9baa10b7bd6cc83553c5c8965d3d6f92829494e5acc7fa42a8b73abbf48ccb772339ba1f17f99c69a97284b578d7ff2a760414536efbc38413cf25e2d70dfef5138519684abaf46518c2ef5b8cd17eb258665fc25d6998bf2f79d5993802ef2f773ffbd97a61beeefb584aff8603aafb550ffacfd8faeeaaba2e5dbf678495ba2a53f983cf38952ab45cfa97a0b2dd945a747bf26183ba756174393d88df94f971119aeef9e4e912b9d1478ceb177a37cd5601aab85d91abb422ccb812eeac62e055c10ab33ab616a12b7fe617aa577b986b314d6009e39c49765fdf9d94ed5a7e85fda0b80b8e41ade9fbebc27d14588f13be847307b1d219647ae6b31c596eb2d8ae258fc8de469fbd99a05fe36fca5f8ed9aef3bb8aec23d680043bee25de7bb9480d5854ada72ccc20054ae9af561aa79a10ae6ad910f7ff28069da41b2ba1518094da0487aa9aff7904228690fb44d2f05d0842a99541bf57452b28353a1607ac744a53d3fa922f2d1675f242889b8997915ce8847c9b5d7c2e09b769956135febada11a59bc234db398c2543fab9837e699095cf02b2c21207ef2e94f967e45e03f4bb8161afb94b44f57d1d1be0eebac278f5a1ba1ba79e1632dc6462d92a69731732ca28a291859bbf937d7b8f7503cfdcfefcb2cb35e702af785cda735244c3d43e9defbf01b061adab3a0888136afa64a7c56baec21c7a1916088aaa1845b8fdd0f6c69a72a3989f5b8aad549e57273d459a3c2087a63f639936ac54e2f678864bc0cb28a98fcf3c7f84576a1bb416a7ddf0fdf2d3f3c30b9f656d44a2a11c51d5969eb7c47859e7439f644ae5a4b1b325bc4665b596706114873d5d9f0dde1feeeb57ff22fc0c7959a90cb506d155a7ea9316ff75dd87cbd809a7f12442d588f2b7dcbf5354e9bece0c11ed6d538aeb2fe5d3ef282a242e818f1668c8a86da5fa8fa475791a569d10f96e017d694487bcb38d92d760ec445537c981dcc395a9ace070f78d3927556a85bbe253f47b14178c469ab843b8956293956d7478ccec8eaf58416654a6babb387ac8d1970027b2db2e51bfe9d0696a06997b05fcc0319e88fcf317f22241e2441fece3bdf81f03ab3c2fddeeaad25ad527e81cad7626c3d60b3bd56a5586f18a71e223d8d3b07485c7056562757456f6872d5667844e49a738c6bebb12d16cb428f8ac016561dbd106f86e69d785c7e13336d701beba5282a45b450226b39cecc0024661173473a34d721642b0608427f002d7f95d0190cc20ce9bd35c78a531ec038df7b441f4ff290242c83396ce7e67047175a152719f79a169bd203e410f0062c6e984d386c75809c42c684dd152c07b78a3e60868f92e0c3537826145a7709a56ccdf8a829bbcc7a142b17ccb88a66076400bb691c2abf989935ddbfe6acff893d00ea435f356f7ebf83552fe0583f6b8c4124d4398165af37b2153dec3727a337a8b704abe1bf1b059e9a8d6744f18c0592e4c5ceda2ee1c7064130c1162def06f79df739485d4d1c63e8be78addcb5645ac2ba8b9a74a0637ce2ee16d953e2bd7173692e8111c87c5c1ba99c8fa8db6ccdd0437910ab1d4db9914a01d9c9892400a22a2b54d5e4a127f59c82503beb6d00cab4be2a0b5dc971f303a2e44ae64840fd61d8da471a9de737e245ceaecfed289e5d2b10d8e1456105dad7425a83e872c5f47dd50f1996b947518d12f124e28f777198a5296ffe33cc92f82bd6b70d99aaa6face73cbfdc0bfb7b636cc64d1001550bd8210befd30efa5a3c47f7e05401aa4e8714a775e3e95c7865acfaec34810a71a8d9d1535ce3b3967f1839a741a14d0dd31045a8341ca07c1ede48111209a05083ea2b892091e44d934aed0aab460432a4e4b66b68b65d60f81da84d5617853fce1de40642e3f4b936251260ab9d668e80d2ae83e9ce78f3c1d72b7c6b426019a1075a24e4421730b24cf65b8612f81fc94930ae1d529cfcdee033f26797b627fb9b7cd9a4a7443c169840ef017da3b19d412e0806e88aa58e1f289560ee864ec491798a08a2ad4ef1a6f2bab92a27e2f5b5d7ec8acb58a2ae10af696774b1db9991a6f3d6bf1765acca6da1e0a8ef29bff610b0cc6edd3f17fd090a58d32af3eff394dcff8a948eddfc4b4cef07f5b095f83d0a1fb69cd94abdaf101564f98ebb764c4ca7a4440f9d6d1ad41abe37f1ea53df5fd18d551384c86189216dc5ed92746b9be2f8552c32fd3cf5b4e49bb4b7118682dbb66a773fbc8c33221dc2a1e4d5e82392a405150fabaf3feaa5334a8f05b1163ba6832d29cb4d87f2a7400eb2c71d5bca9023f8743e20e9ef511012df78e4b2bd342cf6914da9246b2554168bab8eefb6409c1a1ad089b6c2f7548eae9672aba3d0c320a184ac2473b529b1da3c0f568cc4f3e8c9e5d72d90a2741e8865899617fb18717e2fa67c7a658892aa7eebfb9df9de8dddbb901b98feeab7d51ea6fa85785631552a74227f3ea5658533285c936b35ded53a88958f87275fa67ff273b84603568a892abaf368f137d01fef10a657842c2d2b7569b0432d858213f56a67f6b29b9c3b29620e29fc73a298f2c501f45f428349f3ba91b47b8fcb3f2f7642717713241c70a936219a73fe0efb53d30dd4d7ed238cd383aa01109ec95d1463e8a506f4363804324a40aac67bb4597ce2ce48b143c6053edcd0d5f81aa16fdc1b81dadd94b7868e94050a9b10a4e5e9913128ca7cf2b4191c8326c1d4ce1f63f57d72fd1c2f611f63a3f0f24a01a73cf2dccfbc633b39673c8cec976e41088617ca01d5be0503e085d813bd49d14aa79dbc824b2d8644d8a74e18ec9c459d51852ba2ddf8e7d60ed1219e93e1ab8252f33b45cabb90e5c942b503b8da1662e7b00a173d6a751f3b936243e7109bfba19c0c9d0cc512670a783ad4906a617d450187e227fb2b80668b24c5b484f9dc9641e9dab1f9f660802dedf6e1a63853bbd264515e7873f8a03969738d07e33455637eb2db0b487b6423e1e8b049dc016abc5e5f91ce1a9a3d2cda62dc5c5301c56b75f77641a140cc7810fb89b9b3e11b6329baa9e904c87fcb0a9dac2820d9623bf429546345fa9fbdcd44d732290fbacaf133a97c177947ad4095867f59a9d4bed6c049ed8eabcccc485da81f301449ee8c705c68f256bfff5a74d226fc195c6a2f8c73832eec6fff311183585d8fd9c25db7c831fd53c5ff7eaba42e74f3d032f525ba3e7ca8b77f5e55cd3a1230c43fb26f28ce1bd2e55f35eb80444b5e7aa7cf857980d163cf5b81b3a0555e361951c366d7e105bcc332621fc86ab5c39fa634408dd9472bf3fefaa7fa856334878fc150b14f98f6f0feb9519c935e00d4b9d8d26ed1bf9a569f33d3c3b8358109e84f070a862f80ec4700c8f4a642e14c6262c8cd27bb612758c0fa98e7e9cccfbd7dbd8038d51cb897789cbf21e44003acdd2ce0470a63e6bd56c3eeea5d50049814781858ccfce06cac7495527a5202df0ccb0f37801e0c43ebc8baa718e68396cffdd30560258f54e6bae950df20247c83fd47c6b82ef32a206991d28b7416cdd27e4cdc331d57fa5441b6472e511c81471de0133fe4adf8e952e3d8f9e563a198e558180fddd97723a68e679c2f5e44ff8f570f09eaa7ea7648"
.L661:
    .double 1.0
.L666:
    .double 10.0
.L668:
    .string "eef453d6923bd65a113faa2906a13b3f9558b4661b6565f84ac7ca59a424c507baaee17fa23ebf765d79bcf00d2df649e95a99df8ace6f53f4d82c2c107973dc91d8a02bb6c1059479071b9b8a4be869b64ec836a47146f99748e2826cdee284e3e27a444d8d98b7fd1b1b2308169b258e6d8c6ab0787f72fe30f0f5e50e20f7b208ef855c969f4fbdbd2d335e51a935de8b2b66b3bc4723ad2c788035e613828b16fb203055ac764c3bcb5021afcc31addcb9e83c6b1793df4abe242a1bbf3dd953e8624b85dd78d71d6dad34a2af0d87d4713d6f33aa6b8672648c40e5ad68a9c98d8ccb009506680efdaf511f18c2d43bf0effdc0ba480212bd1b2566def284a57695fe98746d014bb630f7604b57a5ced43b7e3e9188419ea3bd35385e2dcf42894a5dce35ea52064cac828675b9818995ce7aa0e1b27343efebd1940993a1ebfb4219491a1f1014ebe6c5f90bf8ca66fa129f9b60a6d41a26e077774ef6fd00b897478238d08920b098955522b49e20735e8cb1638255b46e5f5d5535b0c5a890362fddbc62eb2189f734aa831df712b443bbd52b7ba5e9ec7501d523e49a6bb0aa55653b2d47b233c92125366ec1069cd4eabe89f8999ec0bb696e840af148440a256e2c76c00670ea43ca250d96cd2a865764dbca380406926a5e5728bc807527ed3e12bcc605083704f5ecf2eba09271e88d976bf7864a44c633682e93445b8731587ea37ab3ee6afbe0211db8157268fdae9e4c5960ea05bad82964e61acf033d1a45df6fb92487298e33bd8fd0c16206306baba5d3b6d479f8e056b3c4f1ba87bc86968f48a4899877186ce0b62e2929aba83c331acdabfe94de878c71dcd9ba0b49259ff0c08b7f1d0b14af8e5410288e1b6f07ecf0ae5ee44dd9db71e91432b1a24ac9e82cd9f69d6150892731ac9faf056ebe311c083a225cd2ab70fe17c79ac6ca6dbd630a48aaf406d64d3d9db981787d092cbbccdad5b10885f0468293f0eb4e25bbf56008c58ea5a76c582338ed2621af2af2b80af6f24ed1476e2c07286faa1af5af660db4aee182cca4db847945ca50d98d9fc890ed4da37fce126597973ce50ff107bab528a0cc5fc196fefd7d0c1e53ed49a96272c8ff77b1fcbebcdc4f25e8e89c13bb0f7a9faacf3df73609b177b191618c54e9acc795830d75038c1dd59df5b9ef6a2417f97ae3d0d2446f254b0573286b44ad1d9becce62836ac5774ee367f9430aec32c2e801fb244576d5229c41f793cda73ff3a20279ed56d48a6b43527578c1110f9845418c345644d6830a13896b78aaa9be5691ef416bd60c23cc986bc656d553edec366b11c6cb8f2cbfbe86b7ec8aa894b3a202eb1c3f397bf7d71432f3d6a9b9e08a83a5e34f07daf5ccd93fb0cc53e858ad248f5c22c9d1b3400f8f9cff6891376c36d99995be23100809b9c21fa1b58547448ffffb2dabd40a0c2832a78ae2e69915b3fff9f916c90c8f323f516c8dd01fad907ffc3bae3da7d97f6792e3b1442798f49ffb4a99cd11cfdf41779cdd95317f31c7fa1d40405643d711d5838a7d3eef7f1cfc52482835ea666b2572ad1c8eab5ee43b66da3243650005eecfd863b256369d4a4090bed43e40076a82873e4f75e2224e685a7744a6e804a291a90de3535aaae202711515d0a205cb36d3515c2831559a830d5a5b44ca873e038412d9991ed58091e858790afe9486c2a5178fff668ae0b6626e974dbe39a872ce5d73ff402d98e3fb0a3d212dc8128f80fa687f881c7f8e7ce66634bc9d0b99a139029f6a239f721c1fffc1ebc44e80c987434744ac874ea327ffb266b56220fbe9141915d7a9224bf1ff9f0062baa89d71ac8fada6c9b56f773fc3603db4a9c4ce17b399107c22cb550fb4384d21d3f6019da07f549b2b7e2a53a146606a4899c102844f94e0fb2eda7444cbfc426dc0314325637a1939fa911155fefb5308f03d93eebc589f88793555ab7eba27ca96267c7535b763b54bc1558b2f3458debbb01b9283253ca29eb1aaedfb016f16ea9c227723ee8bcb465e15a979c1cadc92a1958a7675175f0bfacd89ec191ec9b749faed14125d36cef980ec671f667be51c79a85916f48482b7e12780e7401a8f31cc0937ae58d2d1b2ecb8b0908810b2fe3f0b8599ef07861fa7e6dcb4aa15dfbdcece67006ac967a791e093e1d49a8bd6a141006042bde0c8bb2c5c6d24e0aecc49914078536d58fae9f773886e18da7f5bf590966848af39a475506a899e888f99797a5e012d6d8406c952429603aab37fd7d8f58178c8e5087ba6d33b83d5605fcdcf32e1d6fb1e4a9a90880a64855c3be0a17fcd265cf2eea09a55067fa6b34ad8c9dfc06ff42faa48c0ea481ed0601d8efc57b08bf13b94daf124da26823c12795db6ce5776c53d08d6b70858a2cb1717b52481ed54768c4b0c64ca6ecb7ddcdda26da268a9942f5dcf7dfd09fe5d54150b090b02d3f93b35435d7c4c9efa548d26e5a6e1c47bc5014a1a6dafc6b8e9b0709f109a359ab6419ca1091bf867241c8cc6d4c0c30163d203c94b629b407691d7fc44f879e0de63425dcf1dc21094364dfb5636985915fc12f542e4f294b943e17a2bc43e6f5b7b17b2939d979cf3ca6cec5b5aa705992ceecf9c42bd8430bd0827723150c6ff782a838353ece53cec4a314ebda4f8bf5635246428940f4613ae5ed136871b7795e136be99b913179899f6858428e2557b59846e3fe757dd7ec07426e5331aeada2fe589cf9096ea6f3848984f3ff0d2c85def7621b4bca50b065abe630fed077a756b53a9e1ebce4dc7f16dfbd3e8495912c628948d3360f09cf6e4bd64712dd7abbbd95cb080392cc4349decbd8d794d96aacfb3dca04777f541c567ecf0d7a0fc5583a089e42caaf9491b60f41686c49db57244ac5d37d5b79b6239311c2875c522ced5d77485cb25823ac77d633293366b828b86a8d39ef77164bcae5dff9c02033197a8530886b54dbdebd9f57f830283fdfcd267caa862a12d66d072df63c324fd7b8380dea93da4bc604247cb9e59f71e6da46116538d0deb7852d9be85f074e608cd795be87051665667902e276c921f8b806bd9714632dff600ba1cd8a3db53b6a086cfcd97bf97f380e8a40eccd228a4c8a883c0fdaf7df06122cd128006b2cdfad2a4b13d1b5d6c796b805720085f819cc3a6eec6311a63cbe3303674053bb0c3f490aa77bd60fcbedbfc4411068a9cf4f1b4d515acb93bee92fb5515482d44991711052d8bf3c5751bdd152d4d1c4abf5cd54678eef0b6d262d45a78a0635def340a98172aace486fb897116c87c349580869f0e7aac0ed45d35e6ae3d4da0bae0a846d21957128974836059cca109e998d258869facd72bd1a438703fc94b91ff83775423cc067b6306a34627ddcfb67f6455292cbf081a3bc84c17b1d542e41f3d6a7377eeca20caba5f1d9e4a938e938662882af53e547eb47b7282ee9cb23867fb2a35b28de99e619a4f23aa43dec681f9f4c31f316405fa00e2ec94d48b3c113c38f9f37ede83bc408dd3dd04ae0b158b4738705e9624ab50b148d445d98ddaee19068c763badd624dd9b095787f8a8d4cfa417c9e54ca5d70a80e5d6a9f6d30a038d1dbc5e9fcf4ccd211f4cd47487cc8470652b7647c3200069671f84c8d4dfd2c63f3b29ecd9f40041e073a5fb0a17c777cf09f468107100525890cf79cc9db955c2cc7182148d4066eeb481ac1fe293d599bfc6f14cd848405530a21727db38cb002fb8ada00e5a506a7cca9cf1d206fdc03ba6d90811f0e4851cfd442e4688bd304a908f4a166d1da6639e4a9cec15763e2e9a598e4e043287fec5dd44271ad3cdba40eff1e1853f29fdf7549530e188c128d12bee59e68ef47c9a94dd3e8cf578b982bb74f8301958cec13a148e3032d6e7e36a52363c1faf01f18899b1bc3f8ca1dc44e6c3cb279ac196f5600f15a7b7e529ab103a5ef8c0b9bcb2b812db11a5de7415d448f6b6f0e7ebdf661791d60f56111b495b3464ad21936b9fcebb25c995cab10dd900beec34b84687c269ef3bfb3d5d514f40eea742e65829b3046b0afa0cb4a5a3112a51128ff71a0fe2c2e6dc47f0e785eaba72abb3f4e093db73a09359ed216765690f56e0f218b8d25088b8306869c13ec3532c8c974f73837255731e414218c73a13fbafbd2350644eeacfe5d1929ef90898fadbac6c247d62a583df45f746b74abf39894bc396ce5da7726b8bba8c328eb783ab9eb47c81f5114f066ea92f3f326564d686619ba27255a2c80a537b0efefebd8613fd0145877585bd06742ce95f5f36a798fc4196e952e72c48113823b73704d17f3b51fca3a7a0f75a15862ca504c582ef85133de648c49a984d73dbe722fba3ab66580d5fdaf5c13e60d0d2e0ebbacc963fee10b7d1b3318df905079926a8ffbbcfe994e5c61ffdf17746497f70529fd561f1fd0f9bd3feb6ea8bedefa633c7caba6e7c5382c8fe64a52ee96b8fc0f9bd690a1b68637b3dfdce7aa3c673b09c1661a651213e2d06bea10ca65c084ec31bfa0fe5698db8486e494fcff30a62f3e2f893dec3f1265a89dba3c3efccfa986ddb5c6b3a76b7f89629465a75e01cbe89523386091465f6bbb397f1135823ee2ba6c0678b597f746aa07ded582e2c94db483840b717efa8c2a44eb4571cdcba121a4650e4ddeb92f34d62616ce413e896a0d7e51e156677b020baf9c81d17915e2486ef32cd600ace1474dc1d122eb5b5ada8aaff80b80d819992132456bae3231912d5bf60e610e1fff697ed6c698df5efabc5979c8fca8d3ffa1ef463c1b1736b96b6fd83b3bd308ff8a6b17cb2ddd0467c64bce4a0ac7cb3f6d05ddbde8aa22c0dbef60ee46bcdf07a423aa96bad4ab7112eb3929d86c16c98d2c953c6d89d64d57a607744e871c7bf077ba8b787625f056c7c4a8b11471cd764ad4972a93af6c6c79b5d2dd598e40d3dd89bcfd389b478798234794aff1d108d4ec2c3843610cb4bf160cbcedf722a585139baa54394fe1eedb8fec2974eb4ee658828ce947a3da6a9273e733d226229feea32811ccc668829b8870806357d5a3f525fa163ff802a3426a8ca07c2dcb0cf26f7c9bcff6034c13052fc89b393dd02f0b5fc2c3f3841f17c67bbac2078d443ace29d9ba7832936edc0d54b944b84aa4c0dc5029163f384a9310a9e795e65d4df11f64335bcf065d37d4d4617b5ff4a16d599ea0196163fa42e504bced1bf8e4e45c06481fb9bcf8d39e45ec2862f71e1d6f07da27a82c370885d767327bb4e5a4c964e858c91ba26553a6a07f8d510f86fbbe226efb628afea890489f70a55368beadab0aba3b2dbe52b45ac74ccea842e92c8ae6b464fc96f3b0b8bc90012929db77ada0617e3bbcb09ce6ebb40173744e55990879ddcaabdcc420a6a101d05158f57fa54c2a9eab69fa946824a12232db32df8e9f354656447939822dc96abf9dff9772470297ebd59787e2b93bc56f78bfbea76c619ef3657eb4edb3c55b65aaefae51477a06b03ede622920b6b23f1dab99e59958885c4e95fab368e45eced88b402f7fd75539b11dbcb0218ebb414aae103b5fcd2a881d652bdc29f26a119d59944a37c0752a24be76d3346f0495f857fcae62d8493a56f70a4400c562ddba6dfbd9fb8e5b88ecb4ccd500f6bb952d097ad07a71f26b27e2000a41346a7a7825ecc24c873782f8ed400668c0c28c8a2f67f2dfa90563b728900802f0f32facbb41ef979346bca4f2b40a03ad2ffb9fea126b7d78186bce2f610c84987bfa89f24b832e6b0f4360dd9ca7d2df4d7c9c6ede63fa05d314391503d1c79720dbbf8a95fcf88747d9475a44c6397ce912a9b69dbe1b548ce7cc986afbe3ee11abac24452da229b021bfbe85badce996168f2d56790ab41c2a2fae27299423fb9c397c560ba6b0919a5dccd879fc967d41abdb6b8e905cb600f5400e987bbc1c920ed246723473e3813290123e9aab23b689436c0760c86e30bf9a0b6720aaf6521b94470938fa89bcef808e40e8d5b3e69e7958cb87392c2c2b60b1d1230b20e0490bd77f3483bb9b9b1c6f22b5e6f48c2b4ecd5f01a4aa8281e38aeb6360b1af3e2280b6c20dd523225c6da63c38de1b08d590723948a535f579c487e5a38ad0eb0af48ec79ace8372d835a9df0c6d851dcdb1b2798182244f8e431456cf88e658a08f0f8bf0f156b1b8e9ecb641b58ffac8b2d36eed2dac5e272467e3d222f3fd7adf884aa8791775b0ed81dcc6abb0f86ccbb52ea94baea98e947129fc2b4e9a87fea27a539e9a53f2398d747b36224d29fe4b18e88640e8eec7f0d19a03aad83a3eeeef9153e891953cf68300424aca48ceaaab75a8e2b5fa8c3423c052dd7cdb02555653131b63792f412cb06794d808e17555f3ebf11e2bbd88bbee40bd0a0b19d2ab70e6ed65b6aceaeae9d0ec4c8de047564d20a8bf245825a5a445275fb158592be068d2eeed6e2f0f0d567129ced737bb6c4183d55464dd69685606bc428d05aa4751e4caa97e14c3c26b886f53304714d9265dfd53dd99f4b3066a8993fe2c6d07b7fabe546a8038efe4029bf8fdb78849a5f96de98520472bdd033ef73d256a5c0f77c963e66858f6d444095a8637627989aaddde7001379a44aa8bb127c53b17ec1595560c018580d5d52e9d71b689dde71afaab8f01e6e10b4a69226712162ab070dcab3961304ca70e8b6b00d69bb55c8d13d607b97c5fd0d22e45c10c42a2b3b058cb89a7db77c506a8eb98a7a9a5b04e377f3608e92adb242b267ed1940f1c61c55f038b237591ed3df01e85f912e37a36b6c46dec52f66888b61313bbabce2c62323ac4b3b3da015ae397d8aa96c1b77abec975e0a0d081ad9c7dced53c7225596e7bd358c904a21881cea14545c75757e50d64177da2e54aa242499697392d2dde50bd1d5d0b9e9d4ad2dbfc3d07787955e4ec64b44e86484ec3c97da624ab4bd5af13bef0b113ea6274bbdd0fadd61ecb1ad8aeacdd58ecfb11ead453994ba67de18eda5814af281ceb32c4b43fcf480eacf948770ced7a2425ff75e14fc31a1258379a94d028dcad2f7f5359a3b3e096ee45813a04330fd87b5f28300ca0d8bca9d6e188853fc9e74d1b791e07e48775ea264cf55347ec612062576589dda95364afe032a819ef79687aed3eec5513a83ddbd83f522059abe14cd44753b52c4926a9672793543c16d9a0095928a2775b7053c0f178294f1c90080baf72cb15324c68b12dd6339971da05074da7beed3f6fc16ebca5e04bce5086492111aea88f4bb1ca6bcf585ec1e4a7db69561a52b31e9e3d06c32e69392ee8e921d5d073aff322e62439fd0b877aa3236a4b44909befeb9fad487c3e69594bec44de15b4c2ebe687989a9b4901d7cf73ab0acd90f9d37014bf60a11b424dc35095cd80f538484c19ef38c95e12e13424bb40e132865a5f206b06fba8cbccc096f5088cbf93f87b7442e45d4afebff0bcb24aafef78f69a51539d749dbe6fecebdedd5beb573440e5a884d1c89705f4136b4a59731680a88f8953031abcc77118461cefcfdc20d2b36ba7c3ed6bf94d5e57a42bc3d32907604691b4d8637bd05af6c69b5a63f9a49c2c1b110a7c5ac471b4784230fcf80dc33721d54d1b71758e219652bd3c36113404ea4a983126e978d4fdf3b645a1cac083126eaa3d70a3d70a3d70a3d70a3d70a3d70a4cccccccccccccccccccccccccccccccd80000000000000000000000000000000a0000000000000000000000000000000c8000000000000000000000000000000fa0000000000000000000000000000009c400000000000000000000000000000c3500000000000000000000000000000f424000000000000000000000000000098968000000000000000000000000000bebc2000000000000000000000000000ee6b28000000000000000000000000009502f900000000000000000000000000ba43b740000000000000000000000000e8d4a5100000000000000000000000009184e72a000000000000000000000000b5e620f4800000000000000000000000e35fa931a000000000000000000000008e1bc9bf040000000000000000000000b1a2bc2ec50000000000000000000000de0b6b3a7640000000000000000000008ac7230489e800000000000000000000ad78ebc5ac6200000000000000000000d8d726b7177a80000000000000000000878678326eac90000000000000000000a968163f0a57b4000000000000000000d3c21bcecceda100000000000000000084595161401484a00000000000000000a56fa5b99019a5c80000000000000000cecb8f27f4200f3a0000000000000000813f3978f89409844000000000000000a18f07d736b90be55000000000000000c9f2c9cd04674edea400000000000000fc6f7c40458122964d000000000000009dc5ada82b70b59df020000000000000c5371912364ce3056c28000000000000f684df56c3e01bc6c7320000000000009a130b963a6c115c3c7f400000000000c097ce7bc90715b34b9f100000000000f0bdc21abb48db201e86d4000000000096769950b50d88f41314448000000000bc143fa4e250eb3117d955a000000000eb194f8e1ae525fd5dcfab080000000092efd1b8d0cf37be5aa1cae500000000b7abc627050305adf14a3d9e40000000e596b7b0c643c7196d9ccd05d00000008f7e32ce7bea5c6fe4820023a2000000b35dbf821ae4f38bdda2802c8a800000e0352f62a19e306ed50b2037ad2000008c213d9da502de454526f422cc340000af298d050e4395d69670b12b7f410000daf3f04651d47b4c3c0cdd765f11400088d8762bf324cd0fa5880a69fb6ac800ab0e93b6efee00538eea0d047a457a00d5d238a4abe9806872a4904598d6d88085a36366eb71f04147a6da2b7f864750a70c3c40a64e6c51999090b65f67d924d0cf4b50cfe20765fff4b4e3f741cf6d82818f1281ed449fbff8f10e7a8921a4a321f2d7226895c7aff72d52192b6a0dcbea6f8ceb02bb399bf4f8a69f764490fee50b7025c36a0802f236d04753d5b49f4f2726179a224501d762422c946590c722f0ef9d80aad6424d3ad2b7b97ef5f8ebad2b84e0d58bd2e0898765a7deb29b934c3b330c857763cc55f49f88eb2fc2781f49ffcfa6d53cbf6b71c76b25fbf316271c7fc3908a8bef464e3945ef7a97edd871cfda3a5697758bf0e3cbb5acbde94e8e43d0c8ec3d52eeed1cbea317ed63a231d4c4fb274ca7aaa863ee4bdd945e455f24fb1cf88fe8caa93e74ef6ab975d6b6ee39e436b3e2fd538e122b44e7d34c64a9c85d4460dbbca87196b61690e40fbeea1d3a4abc8955e946fe31cdb51d13aea4a488dd6babab6398bdbe41e264589a4dcdab14c696963c7eed2dd18d7eb76070a08aecfc1e1de5cf543ca2b0de65388cc8ada83b25a55f43294bcbdd15fe86affad91249ef0eb713f39ebe8a2dbf142dfcc7ab6e3569326c784337acb92ed9397bf99649c2c37f07965404d7e77a8f87daf7fbdc33745ec97be90686f0ac99b4e8dafd69a028bb3ded71a3a8acd7c0222311bcc40832ea0d68ce0cd2d80db02aabd62bf50a3fa490c3019083c7088e1aab65db792667c6da79e0faa4b8cab1a1563f52577001b891185938cde6fd5e09abcf26ed4c0226b55e6f8680b05e5ac60b6178544f8158315b05b4a0dc75f1778e39d6696361ae3db1c721c913936dd571c84c03bc3a19cd1e38e9fb5878494ace3a5f04ab48a04065c7239d174b2dcec0e47b62eb0d64283f9c76c45d1df942711d9a3ba5d0bd324f8394f5746577930d6500ca8f44ec7ee364799968bf6abbe85f207e998b13cf4e1ecbbfc2ef456ae276e89e3fedd8c321a67eefb3ab16c59b14a2c5cfe94ef3ea101e95d04aee3b80ece5bba1f1d158724a12bb445da9ca61281f2a8a6e45ae8edc97ea1575143cf97226f52d09d71a3293bd924d692ca61be758593c2626705f9c56b6e0c377cfa2e12e6f8b2fb00c77836ce498f455c38b997a0b6dfb9c0f9564478edf98b59a373fec4724bd4189bd5eacb2977ee300c50fe758edec91ec2cb657df3d5e9bc0f653e12f2967b66737e3ed8b865b215899f46cbd79e0d20082ee74ae67f1e9aec07187ecd8590680a3aa11da01ee641a708de9e80e6f4820cc9495884134fe908658b23109058d147fdcddaa51823e34a7eedebd4b46f0599fd415d4e5e2cdc1d1ea966c9e18ac7007c91a850fadc09923329e03e2cf6bc604ddb0a6539930bf6bff4584db8346b786151ccfe87f7cef46ff16e612641865679a6381f14fae158c5f6e4fcb7e8f3f60c07ea26da3999aef7749e3be5e330f38f09dcb090c8001ab551c5cadf5bfd3072cc5fdcb4fa002162a6373d9732fc7c8f7f69e9f11c4014dda7e2867e7fddcdd9afac646d63501a1511db281e1fd541501b8f7d88bc24209a5651f225a7ca91a42269ae757596946075f3375788de9b06958c1a12d2fc39789370052d6b1641c83aef209787bb47d6b84c0678c5dbd23a49a9745eb4d50ce6332f840b7ba963646e0bd176620a501fbffb650e5a93bc3d898ec5d3fa8ce427affa3e51f138ab4cebe93ba47c980e98cdfc66f336c36b10137b8a8d9bbe123f017b80b0047445d4184e6d3102ad96cec1da60dc059157491e59043ea1ac7e4139287c89837ad68db2fb454e4a179dd187729babe4598c311fbe16a1dc9d8545e94f4296dd6fef3d67a8ce2529e2734bb1d1899e4a65f58660cb01ae745b101e9e45ec05dcff72e7f8fdc21a1171d42645d76707543f4fa1f73899504ae72497eba6a06494a791c53a8abfa45da0edbde690487db9d17636892d6f8d7509292d60345a9d2845d3c42b6865b86925b9bc5c20b8a2392ba45a9b2a7f26836f282b7328e6cac7768d7141ed1ef0244af2364ff3207d795430cd9268335616aed761f1f7f44e6bd49e807b8a402b9c5a8d3a6e75f16206c9c6209a6cd036837130890a136dba887c37a8c0f802221226be55a64c2494954da2c9789a02aa96b06deb0fdf2db9baa10b7bd6cc83553c5c8965d3d6f92829494e5acc7fa42a8b73abbf48ccb772339ba1f17f99c69a97284b578d7ff2a760414536efbc38413cf25e2d70dfef5138519684abaf46518c2ef5b8cd17eb258665fc25d6998bf2f79d5993802ef2f773ffbd97a61beeefb584aff8603aafb550ffacfd8faeeaaba2e5dbf678495ba2a53f983cf38952ab45cfa97a0b2dd945a747bf26183ba756174393d88df94f971119aeef9e4e912b9d1478ceb177a37cd5601aab85d91abb422ccb812eeac62e055c10ab33ab616a12b7fe617aa577b986b314d6009e39c49765fdf9d94ed5a7e85fda0b80b8e41ade9fbebc27d14588f13be847307b1d219647ae6b31c596eb2d8ae258fc8de469fbd99a05fe36fca5f8ed9aef3bb8aec23d680043bee25de7bb9480d5854ada72ccc20054ae9af561aa79a10ae6ad910f7ff28069da41b2ba1518094da0487aa9aff7904228690fb44d2f05d0842a99541bf57452b28353a1607ac744a53d3fa922f2d1675f242889b8997915ce8847c9b5d7c2e09b769956135febada11a59bc234db398c2543fab9837e699095cf02b2c21207ef2e94f967e45e03f4bb8161afb94b44f57d1d1be0eebac278f5a1ba1ba79e1632dc6462d92a69731732ca28a291859bbf937d7b8f7503cfdcfefcb2cb35e702af785cda735244c3d43e9defbf01b061adab3a0888136afa64a7c56baec21c7a1916088aaa1845b8fdd0f6c69a72a3989f5b8aad549e57273d459a3c2087a63f639936ac54e2f678864bc0cb28a98fcf3c7f84576a1bb416a7ddf0fdf2d3f3c30b9f656d44a2a11c51d5969eb7c47859e7439f644ae5a4b1b325bc4665b596706114873d5d9f0dde1feeeb57ff22fc0c7959a90cb506d155a7ea9316ff75dd87cbd809a7f12442d588f2b7dcbf5354e9bece0c11ed6d538aeb2fe5d3ef282a242e818f1668c8a86da5fa8fa475791a569d10f96e017d694487bcb38d92d760ec445537c981dcc395a9ace070f78d3927556a85bbe253f47b14178c469ab843b8956293956d7478ccec8eaf58416654a6babb387ac8d1970027b2db2e51bfe9d0696a06997b05fcc0319e88fcf317f22241e2441fece3bdf81f03ab3c2fddeeaad25ad527e81cad7626c3d60b3bd56a5586f18a71e223d8d3b07485c7056562757456f6872d5667844e49a738c6bebb12d16cb428f8ac016561dbd106f86e69d785c7e13336d701beba5282a45b450226b39cecc0024661173473a34d721642b0608427f002d7f95d0190cc20ce9bd35c78a531ec038df7b441f4ff290242c83396ce7e67047175a152719f79a169bd203e410f0062c6e984d386c75809c42c684dd152c07b78a3e60868f92e0c3537826145a7709a56ccdf8a829bbcc7a142b17ccb88a66076400bb691c2abf989935ddbfe6acff893d00ea435f356f7ebf83552fe0583f6b8c4124d4398165af37b2153dec3727a337a8b704abe1bf1b059e9a8d6744f18c0592e4c5ceda2ee1c7064130c1162def06f79df739485d4d1c63e8be78addcb5645ac2ba8b9a74a0637ce2ee16d953e2bd7173692e8111c87c5c1ba99c8fa8db6ccdd0437910ab1d4db9914a01d9c9892400a22a2b54d5e4a127f59c82503beb6d00cab4be2a0b5dc971f303a2e44ae64840fd61d8da471a9de737e245ceaecfed289e5d2b10d8e1456105dad7425a83e872c5f47dd50f1996b947518d12f124e28f777198a5296ffe33cc92f82bd6b70d99aaa6face73cbfdc0bfb7b636cc64d1001550bd8210befd30efa5a3c47f7e05401aa4e8714a775e3e95c7865acfaec34810a71a8d9d1535ce3b3967f1839a741a14d0dd31045a8341ca07c1ede48111209a05083ea2b892091e44d934aed0aab460432a4e4b66b68b65d60f81da84d5617853fce1de40642e3f4b936251260ab9d668e80d2ae83e9ce78f3c1d72b7c6b426019a1075a24e4421730b24cf65b8612f81fc94930ae1d529cfcdee033f26797b627fb9b7cd9a4a7443c169840ef017da3b19d412e0806e88aa58e1f289560ee864ec491798a08a2ad4ef1a6f2bab92a27e2f5b5d7ec8acb58a2ae10af696774b1db9991a6f3d6bf1765acca6da1e0a8ef29bff610b0cc6edd3f17fd090a58d32af3eff394dcff8a948eddfc4b4cef07f5b095f83d0a1fb69cd94abdaf101564f98ebb764c4ca7a4440f9d6d1ad41abe37f1ea53df5fd18d551384c86189216dc5ed92746b9be2f8552c32fd3cf5b4e49bb4b7118682dbb66a773fbc8c33221dc2a1e4d5e82392a405150fabaf3feaa5334a8f05b1163ba6832d29cb4d87f2a7400eb2c71d5bca9023f8743e20e9ef511012df78e4b2bd342cf6914da9246b2554168bab8eefb6409c1a1ad089b6c2f7548eae9672aba3d0c320a184ac2473b529b1da3c0f568cc4f3e8c9e5d72d90a2741e8865899617fb18717e2fa67c7a658892aa7eebfb9df9de8dddbb901b98feeab7d51ea6fa85785631552a74227f3ea5658533285c936b35ded53a88958f87275fa67ff273b84603568a892abaf368f137d01fef10a657842c2d2b7569b0432d858213f56a67f6b29b9c3b29620e29fc73a298f2c501f45f428349f3ba91b47b8fcb3f2f7642717713241c70a936219a73fe0efb53d30dd4d7ed238cd383aa01109ec95d1463e8a506f4363804324a40aac67bb4597ce2ce48b143c6053edcd0d5f81aa16fdc1b81dadd94b7868e94050a9b10a4e5e9913128ca7cf2b4191c8326c1d4ce1f63f57d72fd1c2f611f63a3f0f24a01a73cf2dccfbc633b39673c8cec976e41088617ca01d5be0503e085d813bd49d14aa79dbc824b2d8644d8a74e18ec9c459d51852ba2ddf8e7d60ed1219e93e1ab8252f33b45cabb90e5c942b503b8da1662e7b00a173d6a751f3b936243e7109bfba19c0c9d0cc512670a783ad4906a617d450187e227fb2b80668b24c5b484f9dc9641e9dab1f9f660802dedf6e1a63853bbd264515e7873f8a03969738d07e33455637eb2db0b487b6423e1e8b049dc016abc5e5f91ce1a9a3d2cda62dc5c5301c56b75f77641a140cc7810fb89b9b3e11b6329baa9e904c87fcb0a9dac2820d9623bf429546345fa9fbdcd44d732290fbacaf133a97c177947ad4095867f59a9d4bed6c049ed8eabcccc485da81f301449ee8c705c68f256bfff5a74d226fc195c6a2f8c73832eec6fff311183585d8fd9c25db7c831fd53c5ff7eaba42e74f3d032f525ba3e7ca8b77f5e55cd3a1230c43fb26f28ce1bd2e55f35eb80444b5e7aa7cf857980d163cf5b81b3a0555e361951c366d7e105bcc332621fc86ab5c39fa634408dd9472bf3fefaa7fa856334878fc150b14f98f6f0feb9519c935e00d4b9d8d26ed1bf9a569f33d3c3b8358109e84f070a862f80ec4700c8f4a642e14c6262c8cd27bb612758c0fa98e7e9cccfbd7dbd8038d51cb897789cbf21e44003acdd2ce0470a63e6bd56c3eeea5d50049814781858ccfce06cac7495527a5202df0ccb0f37801e0c43ebc8baa718e68396cffdd30560258f54e6bae950df20247c83fd47c6b82ef32a206991d28b7416cdd27e4cdc331d57fa5441b6472e511c81471de0133fe4adf8e952e3d8f9e563a198e558180fddd97723a68e679c2f5e44ff8f570f09eaa7ea7648"
.L769:
    .string "-inf"
.L770:
    .string "inf"
.L771:
    .string "-nan"
.L772:
    .string "nan"
.L789:
    .string "words"
.L791:
    .string "aes block"
.L795:
    .string "aes key"
.L796:
    .string "words"
.L797:
    .string "words"
.L798:
    .string "words"
.L802:
    .string "/dev/urandom"
.L806:
    .string "words"
.L807:
    .string "random-words"
.L809:
    .string "zyl: invalid callee address 0x"
.L810:
    .string ""
.L811:
    .string "\n"
.bss
.p2align 6
zyl_rtg_cpu_avx2:
    .zero 8
.p2align 6
zyl_rtg_empty:
    .zero 64
.p2align 6
zyl_rtg_spans:
    .zero 24
.p2align 6
zyl_rtg_attrs:
    .zero 144
.p2align 6
zyl_rtg_gwvecs:
    .zero 64
.p2align 6
zyl_rtg_gsmaps:
    .zero 64
.p2align 6
zyl_rtg_def_cells:
    .zero 32
.p2align 6
zyl_rtg_idef_cells:
    .zero 32
.p2align 6
zyl_rtg_repl_globals:
    .zero 8
.p2align 6
zyl_rtg_src_files:
    .zero 6152
.p2align 6
zyl_rtg_itests:
    .zero 65544
.p2align 6
zyl_rtg_fnmap:
    .zero 262152
.p2align 6
zyl_rtg_names:
    .zero 32776
.p2align 6
zyl_rtg_fresh_id:
    .zero 8
.p2align 6
zyl_rtg_budget:
    .zero 24
.p2align 6
zyl_rtg_threads_started:
    .zero 8
.p2align 6
zyl_rtg_arenas:
    .zero 24
.p2align 6
zyl_rtg_region_live:
    .zero 8
.p2align 6
zyl_rtg_os_args:
    .zero 16
.p2align 6
zyl_rtg_os_term_state:
    .zero 16
.p2align 6
zyl_rtg_os_term_saved:
    .zero 64
.p2align 6
zyl_rtg_uf:
    .zero 32
.p2align 6
zyl_rtg_fmt_tab:
    .zero 10608
.section .tbss,"awT",@nobits
.p2align 6
zyl_rtt_timespec:
    .zero 16
.p2align 6
zyl_rtt_sysinfo:
    .zero 128
.p2align 6
zyl_rtt_rpool:
    .zero 32
.p2align 6
zyl_rtt_os_cwd:
    .zero 4096
.p2align 6
zyl_rtt_os_mkdir:
    .zero 4096
.p2align 6
zyl_rtt_os_stat:
    .zero 144
.p2align 6
zyl_rtt_os_tios:
    .zero 64
.p2align 6
zyl_rtt_os_byte:
    .zero 8
.p2align 6
zyl_rtt_os_pollfd:
    .zero 8
.p2align 6
zyl_rtt_os_winsz:
    .zero 8
.p2align 6
zyl_rtt_zsa:
    .zero 1024
.p2align 6
zyl_rtt_fmt_dec:
    .zero 832
.p2align 6
zyl_rtt_fmt_big:
    .zero 384
.p2align 6
zyl_rtt_aes:
    .zero 288
.p2align 6
zyl_rtt_rand:
    .zero 256
.globl zyl_cur_region
.p2align 3
zyl_cur_region:
    .zero 8
.globl zyl_region_top
.p2align 3
zyl_region_top:
    .zero 8
.text
zyl_rt_sys_228:
    mov r10, rcx
    mov eax, 228
    syscall
    ret
zyl_rt_sys_0:
    mov r10, rcx
    mov eax, 0
    syscall
    ret
zyl_rt_sys_2:
    mov r10, rcx
    mov eax, 2
    syscall
    ret
zyl_rt_sys_3:
    mov r10, rcx
    mov eax, 3
    syscall
    ret
zyl_rt_sys_99:
    mov r10, rcx
    mov eax, 99
    syscall
    ret
zyl_rt_sys_231:
    mov r10, rcx
    mov eax, 231
    syscall
    ret
zyl_rt_sys_149:
    mov r10, rcx
    mov eax, 149
    syscall
    ret
zyl_rt_sys_9:
    mov r10, rcx
    mov eax, 9
    syscall
    ret
zyl_rt_sys_11:
    mov r10, rcx
    mov eax, 11
    syscall
    ret
zyl_rt_sys_1:
    mov r10, rcx
    mov eax, 1
    syscall
    ret
zyl_rt_sys_21:
    mov r10, rcx
    mov eax, 21
    syscall
    ret
zyl_rt_sys_80:
    mov r10, rcx
    mov eax, 80
    syscall
    ret
zyl_rt_sys_79:
    mov r10, rcx
    mov eax, 79
    syscall
    ret
zyl_rt_sys_83:
    mov r10, rcx
    mov eax, 83
    syscall
    ret
zyl_rt_sys_217:
    mov r10, rcx
    mov eax, 217
    syscall
    ret
zyl_rt_sys_4:
    mov r10, rcx
    mov eax, 4
    syscall
    ret
zyl_rt_sys_16:
    mov r10, rcx
    mov eax, 16
    syscall
    ret
zyl_rt_sys_7:
    mov r10, rcx
    mov eax, 7
    syscall
    ret
zyl_rt_sys_318:
    mov r10, rcx
    mov eax, 318
    syscall
    ret
zyl_rt_call0:
    mov rax, rdi
    jmp rax
zyl_rt_call1:
    mov rax, rdi
    mov rdi, rsi
    jmp rax
zyl_rt_call2:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    jmp rax
zyl_rt_call3:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    jmp rax
zyl_rt_call4:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    jmp rax
zyl_rt_call5:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    jmp rax
zyl_rt_call6:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    jmp rax
zyl_rt_call7:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    jmp rax
