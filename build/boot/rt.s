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
.L246_0:
    cmp r8, r9
    jl .L246_1
    cmp r10, rbx
    jge .L246_2
    mov r12, -1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L246_2:
    cmp r10, rbx
    jle .L246_3
    mov r12, 1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L246_3:
    mov r12, 0
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L246_1:
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
    jge .L246_4
    mov r14, -1
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L246_4:
    cmp r12, r13
    jle .L246_5
    mov r12, 1
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L246_5:
    mov r12, r8
    add r12, 1
    mov r8, r12
    jmp .L246_0
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
