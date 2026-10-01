.file "rt.zyl"
.intel_syntax noprefix
.text
zy_local_x2Fmain_0__base__rt_x2Dwrite_x2Dfd:
    push rbp
    mov rbp, rsp
    and rsp, -16
    mov r8, rdx
.L0_0:
    mov rdx, r8
    call zyl_rt_sys_1
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrlen:
.L1_0:
    mov rax, rdi
    and rax, 4095
    cmp rax, 4080
    jg .L1_1
    mov rsi, qword ptr [rdi+0]
    mov r8, 72340172838076673
    mov rax, rsi
    mov rcx, r8
    sub rax, rcx
    mov r8, rax
    xor rsi, -1
    and r8, rsi
    mov rsi, -9187201950435737472
    and rsi, r8
    cmp rsi, 0
    jne .L1_2
    mov r8, qword ptr [rdi+8]
    mov r9, 72340172838076673
    mov rax, r8
    mov rcx, r9
    sub rax, rcx
    mov r9, rax
    xor r8, -1
    and r9, r8
    mov r8, -9187201950435737472
    and r8, r9
    cmp r8, 0
    jne .L1_3
    lea r9, [rdi+16]
    mov rdi, r9
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dv
    mov r9, rax
    add r9, 16
    mov rax, r9
    ret
.L1_3:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    shr r8, 3
    lea rax, [r8+8]
    ret
.L1_2:
    mov rdx, rsi
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov rsi, rax
    shr rsi, 3
    mov rax, rsi
    ret
.L1_1:
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dv
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dv:
.L2_0:
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
    jne .L2_1
    add rsi, 16
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dfrom
.L2_1:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dfrom:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L3_0:
    mov rdx, r12
    movdqu xmm0, [rdx]
    pxor xmm1, xmm1
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov rsi, rax
    cmp rsi, 0
    jne .L3_1
    mov rax, r12
    and rax, 31
    cmp rax, 0
    jne .L3_2
    add r12, 16
    jmp .L3_0
.L3_2:
    call zy_local_x2Fmain_0__base__rt_x2Davx2
    cmp rax, 0
    je .L3_3
    lea rdi, [r12+16]
    mov rsi, rdi
    mov rdi, rbx
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D32
.L3_3:
    lea rdi, [r12+16]
    mov rsi, rdi
    mov rdi, rbx
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D16
.L3_1:
    mov rdx, rsi
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov rsi, rax
    add rsi, r12
    sub rsi, rbx
    mov rax, rsi
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D16:
.L4_0:
    mov rdx, rsi
    movdqu xmm0, [rdx]
    pxor xmm1, xmm1
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r8, rax
    cmp r8, 0
    jne .L4_1
    add rsi, 16
    jmp .L4_0
.L4_1:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    add rsi, r8
    sub rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D32:
.L5_0:
    mov rdx, rsi
    vmovdqu ymm0, [rdx]
    vpxor xmm1, xmm1, xmm1
    vpcmpeqb ymm0, ymm0, ymm1
    vpmovmskb eax, ymm0
    vzeroupper
    mov r8, rax
    cmp r8, 0
    jne .L5_1
    add rsi, 32
    jmp .L5_0
.L5_1:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    add rsi, r8
    sub rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq:
    mov r8, rdx
.L6_0:
    cmp r8, 16
    jl .L6_1
.L6_4:
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    cmp rax, 65535
    jne .L6_2
    add rdi, 16
    add rsi, 16
    sub r8, 16
    cmp r8, 16
    jl .L6_1
    jmp .L6_4
.L6_2:
    mov rax, 0
    ret
.L6_1:
    cmp r8, 0
    jne .L6_3
    mov rax, 1
    ret
.L6_3:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dbytes_x2Deq
zy_local_x2Fmain_0__base__rt_x2Dbytes_x2Deq:
    mov r8, rdx
.L7_0:
    cmp r8, 0
    jne .L7_1
.L7_3:
    mov rax, 1
    ret
.p2align 4
.L7_1:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    jne .L7_2
    add rdi, 1
    add rsi, 1
    sub r8, 1
    cmp r8, 0
    jne .L7_1
    jmp .L7_3
.L7_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrcmp:
.L8_0:
    mov rax, rdi
    and rax, 4095
    cmp rax, 4080
    jg .L8_2
    mov rax, rsi
    and rax, 4095
    cmp rax, 4080
    jle .L8_1
.L8_2:
    mov r8, 16
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrcmp_x2Dbytes
.L8_1:
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
    jne .L8_3
    add rdi, 16
    add rsi, 16
    jmp .L8_0
.L8_3:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    add rdi, r8
    add rsi, r8
    movzx edi, byte ptr [rdi+0]
    movzx esi, byte ptr [rsi+0]
    cmp rdi, rsi
    jge .L8_4
    mov rax, -1
    ret
.L8_4:
    cmp rdi, rsi
    jle .L8_5
    mov rax, 1
    ret
.L8_5:
    mov rax, 0
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrcmp_x2Dbytes:
    mov r8, rdx
.L9_0:
    cmp r8, 0
    jne .L9_1
.L9_6:
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrcmp
.p2align 4
.L9_1:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    jne .L9_3
    cmp r9, 0
    jne .L9_2
.L9_3:
    movzx r9d, byte ptr [rdi+0]
    movzx r10d, byte ptr [rsi+0]
    cmp r9, r10
    jge .L9_4
    mov rax, -1
    ret
.L9_4:
    cmp r9, r10
    jle .L9_5
    mov rax, 1
    ret
.L9_5:
    mov rax, 0
    ret
.L9_2:
    add rdi, 1
    add rsi, 1
    sub r8, 1
    cmp r8, 0
    jne .L9_1
    jmp .L9_6
zy_local_x2Fmain_0__base__rt_x2Dbyte_x2Dorder:
.L10_0:
    movzx edi, byte ptr [rdi+0]
    movzx esi, byte ptr [rsi+0]
    cmp rdi, rsi
    jge .L10_1
    mov rax, -1
    ret
.L10_1:
    cmp rdi, rsi
    jle .L10_2
    mov rax, 1
    ret
.L10_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__base__rt_x2Dhex:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L11_0:
    lea rax, [rip+.L12]
    mov rdi, rax
    mov rsi, rbx
    and rsi, 15
    mov r8, 1
    mov rdx, r8
    call zyl_cstr_substr
    mov rdi, rax
    cmp rbx, 16
    jge .L11_1
    mov rsi, r12
    call zyl_cstr_concat
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L11_1:
    shr rbx, 4
    mov rsi, r12
    call zyl_cstr_concat
    mov r12, rax
    jmp .L11_0
zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rsi
.L13_0:
    lea rax, [rip+.L14]
    mov r12, rax
    lea rax, [rip+.L15]
    mov r13, rax
    lea rax, [rip+.L16]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dhex
    mov rdi, rax
    lea rax, [rip+.L17]
    mov rsi, rax
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
    mov rdi, rax
    mov rbx, 2
    mov r12, rdi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__strlen_x2Dof:
.L18_0:
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen
zy_local_x2Fmain_0__base__rt_x2Dcopy:
    push rbx
    mov rbx, rdi
    mov rdi, rdx
.L19_0:
    cmp rdi, 16
    jl .L19_1
.L19_4:
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16
    mov rax, rbx
    pop rbx
    ret
.L19_1:
    cmp rdi, 8
    jl .L19_2
    mov r8, qword ptr [rsi+0]
    mov qword ptr [rbx+0], r8
    lea r8, [rdi-8]
    add r8, rbx
    lea r9, [rdi-8]
    add r9, rsi
    mov r9, qword ptr [r9+0]
    mov qword ptr [r8+0], r9
    mov rax, rbx
    pop rbx
    ret
.L19_2:
    cmp rdi, 4
    jl .L19_3
    mov r8d, dword ptr [rsi+0]
    mov dword ptr [rbx+0], r8d
    lea r8, [rdi-4]
    add r8, rbx
    lea r9, [rdi-4]
    add r9, rsi
    mov r9d, dword ptr [r9+0]
    mov dword ptr [r8+0], r9d
    mov rax, rbx
    pop rbx
    ret
.L19_3:
    mov rdx, rdi
    mov rdi, rbx
    pop rbx
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2Dbytes
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16:
    mov r8, rdx
.L20_0:
    cmp r8, 256
    jl .L20_1
.L20_2:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D64
.L20_1:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16s
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D64:
    mov r8, rdx
.L21_0:
    cmp r8, 64
    jl .L21_1
.L21_4:
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    lea r9, [rdi+16]
    lea r10, [rsi+16]
    mov rdx, r9
    mov rcx, r10
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    lea r9, [rdi+32]
    lea r10, [rsi+32]
    mov rdx, r9
    mov rcx, r10
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    lea r9, [rdi+48]
    lea r10, [rsi+48]
    mov rdx, r9
    mov rcx, r10
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    add rdi, 64
    add rsi, 64
    sub r8, 64
    cmp r8, 64
    jl .L21_1
    jmp .L21_4
.L21_1:
    cmp r8, 16
    jle .L21_2
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16s
.L21_2:
    cmp r8, 0
    jle .L21_3
    lea r9, [r8-16]
    add r9, rdi
    sub r8, 16
    add rsi, r8
    mov rdx, r9
    mov rcx, rsi
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    ret
.L21_3:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16s:
    mov r8, rdx
.L22_0:
    cmp r8, 16
    jle .L22_1
.L22_2:
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    add rdi, 16
    add rsi, 16
    sub r8, 16
    cmp r8, 16
    jle .L22_1
    jmp .L22_2
.L22_1:
    lea r9, [r8-16]
    add rdi, r9
    sub r8, 16
    add rsi, r8
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    ret
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2Dbytes:
    push rbx
    mov rbx, rdi
    mov rdi, rdx
.L23_0:
    cmp rdi, 0
    jne .L23_1
.L23_2:
    mov rax, rbx
    pop rbx
    ret
.L23_1:
    movzx r8d, byte ptr [rsi+0]
    mov byte ptr [rbx+0], r8b
    lea r8, [rbx+1]
    add rsi, 1
    sub rdi, 1
    mov rdx, rdi
    mov rdi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy_x2Dbytes
    mov rax, rbx
    pop rbx
    ret
zy_local_x2Fmain_0__base__rt_x2Dmove:
    mov r8, rdx
.L24_0:
    cmp r8, 0
    jle .L24_2
.L24_5:
    cmp rdi, rsi
    jne .L24_1
.L24_2:
    mov rax, rdi
    ret
.L24_1:
    cmp rdi, rsi
    jl .L24_4
    lea rax, [rsi+r8]
    cmp rdi, rax
    jl .L24_3
.L24_4:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__base__rt_x2Dmove_x2Dfwd
.L24_3:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dmove_x2Dback
zy_local_x2Fmain_0__base__rt_x2Dmove_x2Dfwd:
    mov r8, rdx
    mov r9, rcx
.L25_0:
    mov rax, r8
    sub rax, r9
    cmp rax, 16
    jl .L25_1
    lea r10, [rdi+r9]
    lea r11, [rsi+r9]
    mov rdx, r10
    mov rcx, r11
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    add r9, 16
    jmp .L25_0
.L25_1:
    mov rax, r8
    sub rax, r9
    cmp rax, 8
    jl .L25_2
    lea r10, [rdi+r9]
    lea r11, [rsi+r9]
    mov r11, qword ptr [r11+0]
    mov qword ptr [r10+0], r11
    add r9, 8
    jmp .L25_0
.L25_2:
    cmp r9, r8
    jl .L25_3
    mov rax, rdi
    ret
.L25_3:
    lea r10, [rdi+r9]
    lea r11, [rsi+r9]
    movzx r11d, byte ptr [r11+0]
    mov byte ptr [r10+0], r11b
    add r9, 1
    jmp .L25_0
zy_local_x2Fmain_0__base__rt_x2Dmove_x2Dback:
    mov r8, rdx
.L26_0:
    cmp r8, 16
    jl .L26_1
.L26_4:
    lea r9, [r8-16]
    add r9, rdi
    lea r10, [r8-16]
    add r10, rsi
    mov rdx, r9
    mov rcx, r10
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    sub r8, 16
    cmp r8, 16
    jl .L26_1
    jmp .L26_4
.p2align 4
.L26_1:
    cmp r8, 8
    jl .L26_2
    lea r9, [r8-8]
    add r9, rdi
    lea r10, [r8-8]
    add r10, rsi
    mov r10, qword ptr [r10+0]
    mov qword ptr [r9+0], r10
    sub r8, 8
    cmp r8, 16
    jl .L26_1
    jmp .L26_4
.L26_2:
    cmp r8, 0
    jne .L26_3
    mov rax, rdi
    ret
.L26_3:
    lea r9, [r8-1]
    add r9, rdi
    lea r10, [r8-1]
    add r10, rsi
    movzx r10d, byte ptr [r10+0]
    mov byte ptr [r9+0], r10b
    sub r8, 1
    cmp r8, 16
    jl .L26_1
    jmp .L26_4
zy_local_x2Fmain_0__base__rt_x2Dmem_x2Dcmp:
    mov r8, rdx
.L27_0:
    cmp r8, 16
    jl .L27_1
.L27_9:
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r9, rax
    xor r9, 65535
    cmp r9, 0
    jne .L27_2
    add rdi, 16
    add rsi, 16
    sub r8, 16
    cmp r8, 16
    jl .L27_1
    jmp .L27_9
.L27_2:
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
    movzx r10d, byte ptr [r10+0]
    movzx r9d, byte ptr [r9+0]
    cmp r10, r9
    jge .L27_3
    mov rax, -1
    ret
.L27_3:
    cmp r10, r9
    jle .L27_4
    mov rax, 1
    ret
.L27_4:
    mov rax, 0
    ret
.p2align 4
.L27_1:
    cmp r8, 0
    jne .L27_5
    mov rax, 0
    ret
.L27_5:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    jne .L27_6
    add rdi, 1
    add rsi, 1
    sub r8, 1
    cmp r8, 16
    jl .L27_1
    jmp .L27_9
.L27_6:
    movzx edi, byte ptr [rdi+0]
    movzx esi, byte ptr [rsi+0]
    cmp rdi, rsi
    jge .L27_7
    mov rax, -1
    ret
.L27_7:
    cmp rdi, rsi
    jle .L27_8
    mov rax, 1
    ret
.L27_8:
    mov rax, 0
    ret
zy_local_x2Fmain_0__base__rt_x2Dfind_x2Dbyte:
    mov r8, rdx
    mov r9, rcx
.L28_0:
    mov rax, rsi
    sub rax, r9
    cmp rax, 16
    jl .L28_1
    lea r10, [rdi+r9]
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
    jne .L28_2
    add r9, 16
    jmp .L28_0
.L28_2:
    mov rdx, r10
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r10, rax
    lea rax, [r9+r10]
    ret
.L28_1:
    cmp r9, rsi
    jl .L28_3
    mov rax, -1
    ret
.L28_3:
    lea r10, [rdi+r9]
    movzx eax, byte ptr [r10+0]
    cmp rax, r8
    jne .L28_4
    mov rax, r9
    ret
.L28_4:
    add r9, 1
    jmp .L28_0
zy_local_x2Fmain_0__base__rt_x2Dalloc:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L29_0:
    call zyl_ralloc
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dcur_x2Dregion:
.L30_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rax, rsi
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
.L31_0:
    lea rdi, [r12+1]
    call zyl_ralloc
    mov r13, rax
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r13+r12]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dnull:
.L32_0:
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    ret
zy_local_x2Fmain_0__base__rt_x2Davx2:
    push rbx
.L33_0:
    lea rax, [rip+zyl_rtg_cpu_avx2]
    mov rbx, rax
    mov rsi, qword ptr [rbx+0]
    cmp rsi, 0
    jne .L33_1
    call zy_local_x2Fmain_0__base__rt_x2Davx2_x2Dprobe
    cmp rax, 0
    je .L33_2
    mov rdi, 2
    jmp .L33_3
.L33_2:
    mov rdi, 1
.L33_3:
    mov qword ptr [rbx+0], rdi
    mov rax, rdi
    cmp rax, 2
    sete al
    movzx rax, al
    pop rbx
    ret
.L33_1:
    mov rax, rsi
    cmp rax, 2
    sete al
    movzx rax, al
    pop rbx
    ret
zy_local_x2Fmain_0__base__rt_x2Davx2_x2Dprobe:
.L34_0:
    mov rsi, 0
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov eax, edx
    mov r11, rbx
    cpuid
    mov eax, eax
    mov rbx, r11
    cmp rax, 7
    jge .L34_1
    mov rax, 0
    ret
.L34_1:
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
    jne .L34_2
    xor ecx, ecx
    xgetbv
    mov eax, eax
    mov rsi, rax
    and rsi, 6
    cmp rsi, 6
    jne .L34_3
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
    ret
.L34_3:
    mov rax, 0
    ret
.L34_2:
    mov rax, 0
    ret
.globl zyl_cpuid_features
zyl_cpuid_features:
.L35_0:
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
    mov rax, rsi
    and rax, 33554432
    cmp rax, 0
    jle .L35_1
    mov rdi, 1
    jmp .L35_2
.L35_1:
    mov rdi, 0
.L35_2:
    mov rax, rsi
    and rax, 2
    cmp rax, 0
    jle .L35_3
    mov r8, 2
    jmp .L35_4
.L35_3:
    mov r8, 0
.L35_4:
    mov rax, rsi
    and rax, 524288
    cmp rax, 0
    jle .L35_5
    mov r9, 4
    jmp .L35_6
.L35_5:
    mov r9, 0
.L35_6:
    mov rax, rsi
    and rax, 268435456
    cmp rax, 0
    jle .L35_7
    mov rsi, 8
    jmp .L35_8
.L35_7:
    mov rsi, 0
.L35_8:
    or rsi, r9
    or rsi, r8
    mov rax, rdi
    or rax, rsi
    ret
.globl zyl_aesni_available
zyl_aesni_available:
.L36_0:
    call zyl_cpuid_features
    mov rsi, rax
    and rsi, 1
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    ret
.globl zyl_cstr_len
zyl_cstr_len:
.L37_0:
    mov rsi, rdi
    cmp rsi, 4096
    jge .L37_1
    cmp rsi, 0
    jne .L37_2
    mov rax, 0
    ret
.L37_2:
    lea rax, [rip+.L38]
    mov r8, rax
    mov rdi, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    ret
.L37_1:
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen
zy_local_x2Fmain_0__cstr__rt_x2Dbad_x2Dlen:
.L39_0:
    lea rax, [rip+.L40]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    ret
.globl zyl_cstr_eq
zyl_cstr_eq:
.L41_0:
    cmp rdi, rsi
    jne .L41_1
    mov rax, 1
    ret
.L41_1:
    cmp rdi, 4096
    jge .L41_2
    cmp rdi, 0
    jne .L41_3
    mov rax, 0
    ret
.L41_3:
    lea rax, [rip+.L42]
    mov r8, rax
    mov rsi, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L41_2:
    cmp rsi, 4096
    jge .L41_4
    cmp rsi, 0
    jne .L41_5
    mov rax, 0
    ret
.L41_5:
    lea rax, [rip+.L43]
    mov r8, rax
    mov rdi, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L41_4:
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    mov rsi, rax
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_cstr_cmp
zyl_cstr_cmp:
.L44_0:
    cmp rdi, rsi
    jne .L44_1
    mov rax, 0
    ret
.L44_1:
    cmp rdi, 0
    jne .L44_2
    mov rax, -1
    ret
.L44_2:
    cmp rsi, 0
    jne .L44_3
    mov rax, 1
    ret
.L44_3:
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrcmp
.globl zyl_cstr_byte_at
zyl_cstr_byte_at:
    push rbx
    push r12
    mov rbx, rsi
.L45_0:
    mov r12, rdi
    cmp rbx, 0
    jge .L45_1
    mov rax, -1
    pop r12
    pop rbx
    ret
.L45_1:
    cmp r12, 4096
    jge .L45_2
    cmp r12, 0
    jne .L45_3
    mov rax, -1
    pop r12
    pop rbx
    ret
.L45_3:
    lea rax, [rip+.L46]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, -1
    pop r12
    pop rbx
    ret
.L45_2:
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    cmp rbx, rax
    jl .L45_4
    mov rax, -1
    pop r12
    pop rbx
    ret
.L45_4:
    lea rsi, [r12+rbx]
    movzx eax, byte ptr [rsi+0]
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__cstr__rt_x2Dbad_x2Dat:
.L47_0:
    lea rax, [rip+.L48]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, -1
    ret
.globl zyl_cstr_key_matches
zyl_cstr_key_matches:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rsi
.L49_0:
    mov r12, rdi
    mov r13, rbx
    cmp r12, r13
    jne .L49_1
    mov rax, 1
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L49_1:
    cmp r12, 0
    je .L49_3
    cmp r13, 0
    jne .L49_2
.L49_3:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L49_2:
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    cmp r14, rsi
    jne .L49_4
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
.L49_4:
    lea rax, [rsi+2]
    cmp r14, rax
    jge .L49_5
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L49_5:
    mov rdi, r14
    sub rdi, rsi
    add rdi, r12
    lea r8, [rdi-1]
    movzx eax, byte ptr [r8+0]
    cmp rax, 58
    jne .L49_6
    lea r8, [rdi-2]
    movzx eax, byte ptr [r8+0]
    cmp rax, 58
    jne .L49_7
    mov rdx, rsi
    mov rsi, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
.L49_7:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L49_6:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
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
.L50_0:
    mov r12, rdi
    mov r13, rsi
    cmp r12, 0
    jle .L50_1
    cmp r12, 4096
    jge .L50_1
    lea rax, [rip+.L51]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L50_1:
    cmp r13, 0
    jle .L50_2
    cmp r13, 4096
    jge .L50_2
    lea rax, [rip+.L52]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L50_2:
    mov rsi, 0
    cmp r12, 0
    je .L50_3
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L50_3:
    mov r14, rsi
    mov rsi, 0
    cmp r13, 0
    je .L50_4
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L50_4:
    mov r15, rsi
    lea rdi, [r14+r15]
    add rdi, 1
    mov rsi, rbx
    call zyl_ralloc
    mov rbx, rax
    lea rax, [r14+r15]
    cmp rax, 16
    jge .L50_5
    cmp r14, 0
    je .L50_6
    mov rsi, r12
    and rsi, 4095
    mov rdi, 4080
    cmp r14, 8
    jg .L50_7
    mov rdi, 4088
.L50_7:
    cmp rsi, rdi
    jg .L50_5
.L50_6:
    cmp r15, 0
    je .L50_8
    mov rsi, r13
    and rsi, 4095
    mov rdi, 4080
    cmp r15, 8
    jg .L50_9
    mov rdi, 4088
.L50_9:
    cmp rsi, rdi
    jg .L50_5
.L50_8:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r14
    mov rcx, r13
    mov r8, r15
    call zy_local_x2Fmain_0__cstr__rt_x2Dconcat_x2Dwords
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L50_5:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rdi, [rbx+r14]
    mov rsi, r13
    mov rdx, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r14+r15]
    add rsi, rbx
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__cstr__rt_x2Dconcat_x2Dwords:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L53_0:
    mov r11, 0
    cmp r8, 0
    je .L53_1
    mov rbx, qword ptr [rsi+0]
    mov r12, rbx
    cmp r8, 8
    jge .L53_2
    mov r13, 1
    lea r14, [r8*8]
    mov rax, r13
    mov rcx, r14
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    sub r13, 1
    mov r12, rbx
    and r12, r13
.L53_2:
    mov r11, r12
.L53_1:
    cmp r8, 8
    jle .L53_3
    mov rsi, qword ptr [rsi+8]
    lea rbx, [r8-8]
    mov r12, rsi
    cmp rbx, 8
    jge .L53_5
    mov r13, 1
    shl rbx, 3
    mov rax, r13
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    sub rbx, 1
    mov r12, rsi
    and r12, rbx
.L53_5:
    jmp .L53_4
.L53_3:
    mov r12, 0
.L53_4:
    mov rsi, 0
    cmp r10, 0
    je .L53_6
    mov rbx, qword ptr [r9+0]
    mov r13, rbx
    cmp r10, 8
    jge .L53_7
    mov r14, 1
    lea r15, [r10*8]
    mov rax, r14
    mov rcx, r15
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    sub r14, 1
    mov r13, rbx
    and r13, r14
.L53_7:
    mov rsi, r13
.L53_6:
    cmp r10, 8
    jle .L53_8
    mov r9, qword ptr [r9+8]
    lea rbx, [r10-8]
    mov r13, r9
    cmp rbx, 8
    jge .L53_10
    mov r14, 1
    shl rbx, 3
    mov rax, r14
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    sub rbx, 1
    mov r13, r9
    and r13, rbx
.L53_10:
    jmp .L53_9
.L53_8:
    mov r13, 0
.L53_9:
    lea r9, [r8*8]
    mov rax, rsi
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    or r11, rbx
    mov rax, r13
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    mov r13, 64
    sub r13, r9
    mov rax, rsi
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    sub r9, 64
    mov rax, rsi
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    or r13, rsi
    or rbx, r13
    mov rsi, r12
    or rsi, rbx
    mov qword ptr [rdi+0], r11
    lea rax, [r8+r10]
    cmp rax, 8
    jl .L53_11
    mov qword ptr [rdi+8], rsi
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L53_11:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_cstr_concat
zyl_cstr_concat:
.L54_0:
    mov r8, 0
    mov rdx, r8
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dconcat
.globl zyl_cstr_concat_r
zyl_cstr_concat_r:
.L55_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r8, rax
    mov rdx, r8
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dconcat
zy_local_x2Fmain_0__cstr__rt_x2Dsubstr:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rsi
    mov r12, rdx
    mov r13, rcx
.L56_0:
    mov r14, rdi
    cmp r14, 0
    jle .L56_1
    cmp r14, 4096
    jge .L56_1
    lea rax, [rip+.L57]
    mov rsi, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L56_1:
    mov rsi, 0
    cmp r14, 0
    je .L56_2
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L56_2:
    mov rdi, 0
    cmp rbx, 0
    jl .L56_3
    mov r8, rsi
    cmp rbx, rsi
    jg .L56_4
    mov r8, rbx
.L56_4:
    mov rdi, r8
.L56_3:
    mov r8, 0
    cmp r12, 0
    jl .L56_5
    mov rax, rsi
    sub rax, rdi
    cmp r12, rax
    jle .L56_6
    sub rsi, rdi
    jmp .L56_7
.L56_6:
    mov rsi, r12
.L56_7:
    mov r8, rsi
.L56_5:
    add rdi, r14
    mov rsi, r8
    mov rdx, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.globl zyl_cstr_substr
zyl_cstr_substr:
    mov r8, rdx
.L58_0:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dsubstr
.globl zyl_cstr_substr_r
zyl_cstr_substr_r:
    mov r8, rdx
.L59_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r9, rax
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dsubstr
zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L60_0:
    mov rdi, 2
    call zyl_ralloc
    mov rsi, rax
    cmp rsi, 0
    jne .L60_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L60_1:
    mov rdi, rbx
    and rdi, 255
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+1], cl
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_cstr_from_byte
zyl_cstr_from_byte:
.L61_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte
.globl zyl_cstr_from_byte_r
zyl_cstr_from_byte_r:
.L62_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte
.globl zyl_view_ok
zyl_view_ok:
    push rbx
    push r12
    mov rbx, rsi
    mov r12, rdx
.L63_0:
    cmp rbx, 0
    jl .L63_2
.L63_6:
    cmp r12, 0
    jge .L63_1
.L63_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L63_1:
    cmp rdi, 0
    jle .L63_3
    cmp rdi, 4096
    jge .L63_3
    lea rax, [rip+.L64]
    mov rsi, rax
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L63_3:
    mov rsi, 0
    cmp rdi, 0
    je .L63_4
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L63_4:
    cmp rbx, rsi
    jg .L63_5
    sub rsi, rbx
    mov rax, r12
    mov rcx, rsi
    cmp rax, rcx
    setle al
    movzx rax, al
    pop r12
    pop rbx
    ret
.L63_5:
    mov rax, 0
    pop r12
    pop rbx
    ret
.globl zyl_view_byte
zyl_view_byte:
    mov r8, rdx
    mov r9, rcx
.L65_0:
    cmp rdi, 0
    je .L65_2
.L65_4:
    cmp r9, 0
    jl .L65_3
    cmp r9, r8
    jl .L65_1
.L65_3:
.L65_2:
    mov rax, -1
    ret
.L65_1:
    add rsi, r9
    add rsi, rdi
    movzx eax, byte ptr [rsi+0]
    ret
zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dbase:
.L66_0:
    cmp rdi, 0
    jne .L66_1
.L66_2:
    lea rax, [rip+zyl_rtg_empty]
    mov r8, rax
    mov rax, r8
    ret
.L66_1:
    lea rax, [rdi+rsi]
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
.L67_0:
    mov r8, qword ptr [rbp-48]
    cmp qword ptr [rbp-48], r14
    jl .L67_1
    mov r8, r14
.L67_1:
    mov r15, r8
    cmp r15, 0
    jle .L67_2
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
    jmp .L67_3
.L67_2:
    mov rsi, 0
.L67_3:
    cmp rsi, 0
    je .L67_4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L67_4:
    cmp qword ptr [rbp-48], r14
    jge .L67_5
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L67_5:
    cmp qword ptr [rbp-48], r14
    jle .L67_6
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L67_6:
    mov rax, 0
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
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L68_0:
    cmp rdi, 0
    je .L68_2
.L68_4:
    cmp r9, 0
    jl .L68_3
    cmp r9, r8
    jl .L68_1
.L68_3:
.L68_2:
    mov rax, -1
    ret
.L68_1:
    add rdi, rsi
    mov rsi, r10
    and rsi, 255
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
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
.L69_0:
    lea rdi, [r13+1]
    call zyl_ralloc
    mov r14, rax
    cmp rbx, 0
    jle .L69_1
    cmp r13, 0
    jle .L69_1
    lea rsi, [rbx+r12]
    mov rdi, r14
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    jmp .L69_2
.L69_1:
.L69_2:
    lea rsi, [r14+r13]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
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
    mov r8, rdx
.L70_0:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dcopy
.globl zyl_view_copy_r
zyl_view_copy_r:
    mov r8, rdx
.L71_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r9, rax
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dcopy
zy_local_x2Fmain_0__cstr__rt_x2Dlast_x2Dslash:
    mov r8, rdx
.L72_0:
    lea r9, [rdi+rsi]
    movzx r9d, byte ptr [r9+0]
    cmp r9, 0
    jne .L72_1
    mov rax, r8
    ret
.L72_1:
    lea r10, [rsi+1]
    mov r11, rsi
    cmp r9, 47
    je .L72_2
    mov r11, r8
.L72_2:
    mov r8, r11
    mov rsi, r10
    jmp .L72_0
.globl zyl_dirname_cstr
zyl_dirname_cstr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L73_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L73_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L73_1:
    mov rsi, 0
    mov rdi, -1
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__cstr__rt_x2Dlast_x2Dslash
    mov rsi, rax
    cmp rsi, 0
    jge .L73_2
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L73_4
    mov rdi, 0
    jmp .L73_5
.L73_4:
    mov rdi, 1
.L73_5:
    jmp .L73_3
.L73_2:
    lea rdi, [rsi+1]
.L73_3:
    mov r12, rdi
    lea rdi, [r12+1]
    call zyl_heap_alloc
    mov r13, rax
    cmp r13, 0
    jne .L73_6
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L73_6:
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r13+r12]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dndigits:
.L74_0:
    cmp rdi, -10000
    jle .L74_1
.L74_9:
    cmp rdi, -100
    jle .L74_2
    cmp rdi, -10
    jle .L74_3
    mov rax, 1
    ret
.L74_3:
    mov rax, 2
    ret
.L74_2:
    cmp rdi, -1000
    jle .L74_4
    mov rax, 3
    ret
.L74_4:
    mov rax, 4
    ret
.L74_1:
    cmp rdi, -100000000
    jle .L74_5
    cmp rdi, -1000000
    jle .L74_6
    cmp rdi, -100000
    jle .L74_7
    mov rax, 5
    ret
.L74_7:
    mov rax, 6
    ret
.L74_6:
    cmp rdi, -10000000
    jle .L74_8
    mov rax, 7
    ret
.L74_8:
    mov rax, 8
    ret
.L74_5:
    mov rsi, -1000000000
    mov r8, 9
    mov rdx, r8
    jmp zy_local_x2Fmain_0__text__rt_x2Dnd
zy_local_x2Fmain_0__text__rt_x2Dnd:
    mov r8, rdx
.L75_0:
    cmp rdi, rsi
    jg .L75_2
.L75_3:
    cmp r8, 19
    jne .L75_1
.L75_2:
    mov rax, r8
    ret
.L75_1:
    imul rsi, rsi, 10
    add r8, 1
    cmp rdi, rsi
    jg .L75_2
    jmp .L75_3
zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dpairs:
.L76_0:
    lea rax, [rip+.L77]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits:
    push rbx
    mov r8, rdx
.L78_0:
    cmp rsi, -100
    jg .L78_1
.L78_3:
    mov rcx, rsi
    movabs rax, -6640827866535438581
    imul rcx
    add rdx, rcx
    sar rdx, 6
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov r9, rax
    imul r10, r9, 100
    sub r10, rsi
    lea rax, [rip+.L79]
    mov r11, rax
    shl r10, 1
    add r11, r10
    lea r10, [r8-1]
    add r10, rdi
    movzx ebx, byte ptr [r11+0]
    mov byte ptr [r10+0], bl
    lea r10, [rdi+r8]
    movzx r11d, byte ptr [r11+1]
    mov byte ptr [r10+0], r11b
    mov rsi, r9
    sub r8, 2
    cmp rsi, -100
    jg .L78_1
    jmp .L78_3
.L78_1:
    cmp rsi, -10
    jg .L78_2
    lea rax, [rip+.L80]
    mov r9, rax
    mov r10, 0
    sub r10, rsi
    shl r10, 1
    add r9, r10
    lea r10, [r8-1]
    add r10, rdi
    movzx r11d, byte ptr [r9+0]
    mov byte ptr [r10+0], r11b
    lea r10, [rdi+r8]
    movzx r9d, byte ptr [r9+1]
    mov byte ptr [r10+0], r9b
    mov rax, r9
    pop rbx
    ret
.L78_2:
    add rdi, r8
    mov r8, 48
    sub r8, rsi
    mov byte ptr [rdi+0], r8b
    mov rsi, r8
    mov rax, rsi
    pop rbx
    ret
zy_local_x2Fmain_0__text__rt_x2Dtext_x2Dword:
    push rbx
.L81_0:
    mov rcx, rdi
    movabs rax, -6640827866535438581
    imul rcx
    add rdx, rcx
    sar rdx, 6
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov r8, rax
    mov rcx, rdi
    movabs rax, 3777893186295716171
    imul rcx
    sar rdx, 11
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov r9, rax
    mov rcx, rdi
    movabs rax, 4835703278458516699
    imul rcx
    sar rdx, 18
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov r10, rax
    lea rax, [rip+.L82]
    mov r11, rax
    mov rbx, 0
    sub rbx, r10
    shl rbx, 1
    add r11, rbx
    movzx r11d, word ptr [r11+0]
    lea rax, [rip+.L83]
    mov rbx, rax
    imul r10, r10, 100
    sub r10, r9
    shl r10, 1
    add rbx, r10
    movzx r10d, word ptr [rbx+0]
    shl r10, 16
    lea rax, [rip+.L84]
    mov rbx, rax
    imul r9, r9, 100
    sub r9, r8
    shl r9, 1
    add rbx, r9
    movzx r9d, word ptr [rbx+0]
    shl r9, 32
    lea rax, [rip+.L85]
    mov rbx, rax
    imul r8, r8, 100
    sub r8, rdi
    lea rdi, [r8*2]
    add rbx, rdi
    movzx edi, word ptr [rbx+0]
    shl rdi, 48
    or rdi, r9
    or rdi, r10
    or rdi, r11
    mov r8, 8
    sub r8, rsi
    lea rsi, [r8*8]
    mov rax, rdi
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    pop rbx
    ret
zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
    mov rbx, rsi
.L86_0:
    mov rsi, 0
    sub rsi, rdi
    cmp rdi, 0
    jg .L86_1
    mov rsi, rdi
.L86_1:
    mov r12, rsi
    mov rsi, 1
    cmp rdi, 0
    jl .L86_2
    mov rsi, 0
.L86_2:
    mov r13, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dndigits
    mov r14, rax
    add r14, r13
    cmp r14, 7
    jg .L86_3
    lea rdi, [r14+1]
    mov rsi, rbx
    call zyl_ralloc
    mov r15, rax
    mov rsi, r14
    sub rsi, r13
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dtext_x2Dword
    mov rsi, rax
    cmp r13, 1
    jne .L86_4
    mov rdi, rsi
    shl rdi, 8
    or rdi, 45
    jmp .L86_5
.L86_4:
    mov rdi, rsi
.L86_5:
    mov qword ptr [r15+0], rdi
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L86_3:
    lea rdi, [r14+1]
    mov rsi, rbx
    call zyl_ralloc
    mov rbx, rax
    cmp r13, 1
    jne .L86_6
    mov rsi, 45
    mov rcx, rsi
    mov byte ptr [rbx+0], cl
    jmp .L86_7
.L86_6:
.L86_7:
    lea rsi, [r14-1]
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    lea rsi, [rbx+r14]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_int_text
zyl_int_text:
.L87_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
.globl zyl_int_text_r
zyl_int_text_r:
.L88_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
zy_local_x2Fmain_0__text__rt_x2Darena_x2Dstr:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L89_0:
    call zyl_arena_alloc_zeroed
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
.L90_0:
    mov r14, rsi
    cmp r14, 0
    je .L90_2
    cmp r12, 0
    jl .L90_3
    cmp r13, 0
    jge .L90_1
.L90_3:
.L90_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L90_1:
    cmp r14, 4096
    jge .L90_4
    lea rax, [rip+.L91]
    mov rsi, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L90_4:
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    lea rax, [r12+r13]
    cmp rax, rsi
    jle .L90_5
    mov rax, rsi
    sub rax, r12
    cmp rax, 0
    jge .L90_7
    mov rdi, 0
    jmp .L90_8
.L90_7:
    mov rdi, rsi
    sub rdi, r12
.L90_8:
    jmp .L90_6
.L90_5:
    mov rdi, r13
.L90_6:
    mov r13, rdi
    lea rsi, [r13+1]
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    lea rsi, [r14+r12]
    mov rdi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [rbx+r13]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
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
.L92_0:
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    lea rsi, [r13+1]
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    lea rsi, [r13+1]
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dllong_x2Dmin:
.L93_0:
    mov rax, -9223372036854775808
    ret
zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dof:
.L94_0:
    cmp rdi, 48
    jl .L94_1
.L94_4:
    cmp rdi, 57
    jg .L94_1
    lea rax, [rdi-48]
    ret
.L94_1:
    cmp rdi, 97
    jl .L94_2
    cmp rdi, 102
    jg .L94_2
    lea rax, [rdi-87]
    ret
.L94_2:
    cmp rdi, 65
    jl .L94_3
    cmp rdi, 70
    jg .L94_3
    lea rax, [rdi-55]
    ret
.L94_3:
    mov rax, -1
    ret
zy_local_x2Fmain_0__text__rt_x2Dacc_x2Dok:
    mov r8, rdx
    mov r9, rcx
.L95_0:
    cmp rdi, 0
    je .L95_1
.L95_4:
    mov rdi, -9223372036854775808
    add rdi, r8
    mov rax, rdi
    mov rcx, r9
    cqo
    idiv rcx
    cmp rsi, rax
    jge .L95_2
    mov rax, 0
    ret
.L95_2:
    mov rax, 1
    ret
.L95_1:
    mov rdi, 9223372036854775807
    sub rdi, r8
    mov rax, rdi
    mov rcx, r9
    cqo
    idiv rcx
    cmp rsi, rax
    jle .L95_3
    mov rax, 0
    ret
.L95_3:
    mov rax, 1
    ret
zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop:
    push rbx
    push r12
    mov r8, rdx
.L96_0:
    movzx r9d, byte ptr [rdi+0]
    cmp r9, 48
    jl .L96_1
    cmp r9, 57
    jg .L96_1
    lea r10, [r9-48]
    mov r11, 10
    cmp rsi, 0
    je .L96_3
    mov rbx, -9223372036854775808
    add rbx, r10
    mov rax, rbx
    mov rcx, r11
    cqo
    idiv rcx
    cmp r8, rax
    jge .L96_5
    mov rbx, 0
    jmp .L96_6
.L96_5:
    mov rbx, 1
.L96_6:
    jmp .L96_4
.L96_3:
    mov r12, 9223372036854775807
    sub r12, r10
    mov rax, r12
    mov rcx, r11
    cqo
    idiv rcx
    cmp r8, rax
    jle .L96_7
    mov r10, 0
    jmp .L96_8
.L96_7:
    mov r10, 1
.L96_8:
    mov rbx, r10
.L96_4:
    cmp rbx, 0
    je .L96_2
    add rdi, 1
    imul r8, r8, 10
    sub r9, 48
    add r8, r9
    jmp .L96_0
.L96_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L96_1:
    cmp rsi, 0
    je .L96_9
    mov rsi, 0
    sub rsi, r8
    mov rax, rsi
    pop r12
    pop rbx
    ret
.L96_9:
    mov rax, r8
    pop r12
    pop rbx
    ret
.globl zyl_cstr_to_int
zyl_cstr_to_int:
.L97_0:
    cmp rdi, 0
    jne .L97_1
    mov rax, 0
    ret
.L97_1:
    cmp rdi, 4096
    jge .L97_2
    lea rax, [rip+.L98]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    ret
.L97_2:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 45
    jne .L97_3
    lea rsi, [rdi+1]
    mov r8, 1
    mov r9, 0
    mov rdi, rsi
    mov rsi, r8
    mov rdx, r9
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop
.L97_3:
    mov rsi, 0
    mov r8, 0
    mov rdx, r8
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop
zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dbase_x2Dloop:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L99_0:
    movzx edi, byte ptr [rbx+0]
    call zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dof
    mov rsi, rax
    cmp rsi, 0
    jl .L99_2
    cmp rsi, r14
    jl .L99_1
.L99_2:
    cmp r12, 0
    je .L99_3
    mov rdi, 0
    sub rdi, r13
    mov rax, rdi
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L99_3:
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L99_1:
    cmp r12, 0
    je .L99_5
    mov rdi, -9223372036854775808
    add rdi, rsi
    mov rax, rdi
    mov rcx, r14
    cqo
    idiv rcx
    cmp r13, rax
    jge .L99_7
    mov rdi, 0
    jmp .L99_8
.L99_7:
    mov rdi, 1
.L99_8:
    jmp .L99_6
.L99_5:
    mov r8, 9223372036854775807
    sub r8, rsi
    mov rax, r8
    mov rcx, r14
    cqo
    idiv rcx
    cmp r13, rax
    jle .L99_9
    mov r8, 0
    jmp .L99_10
.L99_9:
    mov r8, 1
.L99_10:
    mov rdi, r8
.L99_6:
    cmp rdi, 0
    je .L99_4
    add rbx, 1
    imul r13, r14
    add r13, rsi
    jmp .L99_0
.L99_4:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__text__rt_x2Dbase_x2Dof:
.L100_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 48
    jne .L100_1
    movzx esi, byte ptr [rdi+1]
    cmp rsi, 120
    je .L100_3
    cmp rsi, 88
    jne .L100_2
.L100_3:
    mov rax, 16
    ret
.L100_2:
    cmp rsi, 111
    je .L100_5
    cmp rsi, 79
    jne .L100_4
.L100_5:
    mov rax, 8
    ret
.L100_4:
    cmp rsi, 98
    je .L100_7
    cmp rsi, 66
    jne .L100_6
.L100_7:
    mov rax, 2
    ret
.L100_6:
    mov rax, 10
    ret
.L100_1:
    mov rax, 10
    ret
.globl zyl_cstr_to_int_base
zyl_cstr_to_int_base:
    push rbx
    push r12
.L101_0:
    cmp rdi, 0
    jne .L101_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L101_1:
    cmp rdi, 4096
    jge .L101_2
    lea rax, [rip+.L102]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop r12
    pop rbx
    ret
.L101_2:
    movzx ebx, byte ptr [rdi+0]
    mov rax, rbx
    cmp rax, 45
    sete al
    movzx rax, al
    mov rbx, rax
    cmp rbx, 0
    je .L101_3
    lea rsi, [rdi+1]
    jmp .L101_4
.L101_3:
    mov rsi, rdi
.L101_4:
    mov r12, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dbase_x2Dof
    mov rsi, rax
    mov rdi, r12
    cmp rsi, 10
    je .L101_5
    lea rdi, [r12+2]
.L101_5:
    mov r8, 0
    mov rdx, r8
    mov rcx, rsi
    mov rsi, rbx
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dbase_x2Dloop
zy_local_x2Fmain_0__text__rt_x2Dident_x2Dbyte:
.L103_0:
    cmp rdi, 65
    jl .L103_3
.L103_8:
    cmp rdi, 90
    jle .L103_2
.L103_3:
    cmp rdi, 97
    jl .L103_5
    cmp rdi, 122
    jle .L103_4
.L103_5:
    cmp rdi, 48
    jl .L103_7
    cmp rdi, 57
    jle .L103_6
.L103_7:
    cmp rdi, 95
    jne .L103_1
.L103_6:
.L103_4:
.L103_2:
    mov rax, rdi
    ret
.L103_1:
    mov rax, 95
    ret
zy_local_x2Fmain_0__text__rt_x2Dsanitize_x2Dloop:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L104_0:
    cmp r13, r14
    jl .L104_1
.L104_2:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L104_1:
    lea r15, [rbx+r13]
    lea rsi, [r12+r13]
    movzx edi, byte ptr [rsi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dident_x2Dbyte
    mov rsi, rax
    mov rcx, rsi
    mov byte ptr [r15+0], cl
    add r13, 1
    cmp r13, r14
    jl .L104_1
    jmp .L104_2
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
.L105_0:
    mov r12, rsi
    cmp r12, 0
    jne .L105_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L105_1:
    cmp r12, 4096
    jge .L105_2
    lea rax, [rip+.L106]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L105_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    lea rsi, [r13+1]
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__text__rt_x2Dsanitize_x2Dloop
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dhexval:
.L107_0:
    cmp rdi, 48
    jl .L107_1
.L107_4:
    cmp rdi, 57
    jg .L107_1
    lea rax, [rdi-48]
    ret
.L107_1:
    cmp rdi, 97
    jl .L107_2
    cmp rdi, 102
    jg .L107_2
    lea rax, [rdi-87]
    ret
.L107_2:
    cmp rdi, 65
    jl .L107_3
    cmp rdi, 70
    jg .L107_3
    lea rax, [rdi-55]
    ret
.L107_3:
    mov rax, -1
    ret
zy_local_x2Fmain_0__text__rt_x2Descape_x2Dbyte:
.L108_0:
    cmp rdi, 110
    jne .L108_1
.L108_8:
    mov rax, 10
    ret
.L108_1:
    cmp rdi, 116
    jne .L108_2
    mov rax, 9
    ret
.L108_2:
    cmp rdi, 114
    jne .L108_3
    mov rax, 13
    ret
.L108_3:
    cmp rdi, 48
    jne .L108_4
    mov rax, 0
    ret
.L108_4:
    cmp rdi, 34
    jne .L108_5
    mov rax, 34
    ret
.L108_5:
    cmp rdi, 92
    jne .L108_6
    mov rax, 92
    ret
.L108_6:
    cmp rdi, 101
    jne .L108_7
    mov rax, 27
    ret
.L108_7:
    mov rax, -1
    ret
zy_local_x2Fmain_0__text__rt_x2Dhex_x2Descape_x2Dok:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L109_0:
    lea rax, [r12+3]
    cmp rax, rsi
    jge .L109_1
    lea rsi, [r12+2]
    add rsi, rbx
    movzx edi, byte ptr [rsi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    cmp rax, 0
    jl .L109_2
    lea rsi, [r12+3]
    add rsi, rbx
    movzx edi, byte ptr [rsi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    mov rax, rsi
    cmp rax, 0
    setge al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    pop r12
    pop rbx
    ret
.L109_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L109_1:
    mov rax, 0
    pop r12
    pop rbx
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
    mov qword ptr [rbp-56], rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov qword ptr [rbp-48], r8
.L110_0:
    cmp r12, r13
    jl .L110_1
.L110_6:
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L110_1:
    mov rsi, qword ptr [rbp-56]
    add rsi, r12
    movzx esi, byte ptr [rsi+0]
    cmp rsi, 92
    jne .L110_2
    lea rax, [r12+1]
    cmp rax, r13
    jl .L110_3
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L110_3:
    lea rdi, [r12+1]
    add rdi, qword ptr [rbp-56]
    movzx r15d, byte ptr [rdi+0]
    mov rdi, r15
    call zy_local_x2Fmain_0__text__rt_x2Descape_x2Dbyte
    mov rdi, rax
    cmp rdi, 0
    jl .L110_4
    mov r8, r14
    add r8, qword ptr [rbp-48]
    mov rcx, rdi
    mov byte ptr [r8+0], cl
    add r12, 2
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    cmp r12, r13
    jl .L110_1
    jmp .L110_6
.L110_4:
    cmp r15, 120
    jne .L110_5
    mov rdi, qword ptr [rbp-56]
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__text__rt_x2Dhex_x2Descape_x2Dok
    cmp rax, 0
    je .L110_5
    mov r15, r14
    add r15, qword ptr [rbp-48]
    lea rdi, [r12+2]
    add rdi, qword ptr [rbp-56]
    movzx edi, byte ptr [rdi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rbx, rax
    shl rbx, 4
    lea rdi, [r12+3]
    add rdi, qword ptr [rbp-56]
    movzx edi, byte ptr [rdi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rdi, rax
    add rdi, rbx
    mov rcx, rdi
    mov byte ptr [r15+0], cl
    add r12, 4
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    cmp r12, r13
    jl .L110_1
    jmp .L110_6
.L110_5:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L110_2:
    mov rdi, r14
    add rdi, qword ptr [rbp-48]
    mov rcx, rsi
    mov byte ptr [rdi+0], cl
    add r12, 1
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    cmp r12, r13
    jl .L110_1
    jmp .L110_6
.globl zyl_cstr_decode
zyl_cstr_decode:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdx
    mov r12, rcx
.L111_0:
    mov r13, rsi
    cmp r13, 0
    jne .L111_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L111_1:
    cmp r13, 4096
    jge .L111_2
    lea rax, [rip+.L112]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L111_2:
    mov rsi, r12
    sub rsi, rbx
    add rsi, 1
    add rsi, 1
    call zyl_arena_alloc_zeroed
    mov r14, rax
    mov r8, 0
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r14
    call zy_local_x2Fmain_0__text__rt_x2Ddecode_x2Dloop
    mov rsi, rax
    cmp rsi, 0
    jge .L111_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L111_3:
    add rsi, r14
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dcount_x2Dnl:
    push rbx
    mov r8, rdx
    mov r9, rcx
.L113_0:
    cmp rsi, r8
    jl .L113_1
.L113_4:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L113_1:
    lea r10, [rdi+rsi]
    movzx r10d, byte ptr [r10+0]
    cmp r10, 0
    jne .L113_2
    mov rax, r9
    pop rbx
    ret
.L113_2:
    lea r11, [rsi+1]
    lea rbx, [r9+1]
    cmp r10, 10
    je .L113_3
    mov rbx, r9
.L113_3:
    mov r9, rbx
    mov rsi, r11
    cmp rsi, r8
    jl .L113_1
    jmp .L113_4
.globl zyl_cstr_count_newlines
zyl_cstr_count_newlines:
.L114_0:
    cmp rdi, 0
    jne .L114_1
    mov rax, 0
    ret
.L114_1:
    cmp rdi, 4096
    jge .L114_2
    lea rax, [rip+.L115]
    mov r8, rax
    mov rsi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    ret
.L114_2:
    mov r8, 0
    mov r9, 0
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__text__rt_x2Dcount_x2Dnl
zy_local_x2Fmain_0__text__rt_x2Dlast_x2Dnl:
.L116_0:
    cmp rsi, 0
    jge .L116_1
.L116_3:
    mov rax, -1
    ret
.p2align 4
.L116_1:
    lea r8, [rdi+rsi]
    movzx eax, byte ptr [r8+0]
    cmp rax, 10
    jne .L116_2
    mov rax, rsi
    ret
.L116_2:
    sub rsi, 1
    cmp rsi, 0
    jge .L116_1
    jmp .L116_3
.globl zyl_cstr_last_newline
zyl_cstr_last_newline:
.L117_0:
    cmp rdi, 0
    jne .L117_1
    mov rax, -1
    ret
.L117_1:
    cmp rdi, 4096
    jge .L117_2
    lea rax, [rip+.L118]
    mov r8, rax
    mov rsi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, -1
    ret
.L117_2:
    sub rsi, 1
    jmp zy_local_x2Fmain_0__text__rt_x2Dlast_x2Dnl
zy_local_x2Fmain_0__text__rt_x2Descapes_x2Dloop:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L119_0:
    cmp r12, r13
    jl .L119_1
.L119_6:
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L119_1:
    lea rsi, [rbx+r12]
    movzx eax, byte ptr [rsi+0]
    cmp rax, 92
    jne .L119_2
    lea rax, [r12+1]
    cmp rax, r13
    jl .L119_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L119_3:
    lea rsi, [r12+1]
    add rsi, rbx
    movzx edi, byte ptr [rsi+0]
    call zy_local_x2Fmain_0__text__rt_x2Descape_x2Dbyte
    cmp rax, 0
    jl .L119_4
    add r12, 2
    cmp r12, r13
    jl .L119_1
    jmp .L119_6
.L119_4:
    lea rsi, [r12+1]
    add rsi, rbx
    movzx eax, byte ptr [rsi+0]
    cmp rax, 120
    jne .L119_5
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__text__rt_x2Dhex_x2Descape_x2Dok
    cmp rax, 0
    je .L119_5
    add r12, 4
    cmp r12, r13
    jl .L119_1
    jmp .L119_6
.L119_5:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L119_2:
    add r12, 1
    cmp r12, r13
    jl .L119_1
    jmp .L119_6
.globl zyl_cstr_escapes_ok
zyl_cstr_escapes_ok:
    mov r8, rdx
.L120_0:
    cmp rdi, 0
    jne .L120_1
    mov rax, 0
    ret
.L120_1:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__text__rt_x2Descapes_x2Dloop
zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Deq:
    mov r8, rdx
    mov r9, rcx
.L121_0:
    cmp r8, r9
    jl .L121_1
.L121_3:
    mov rax, 1
    ret
.p2align 4
.L121_1:
    lea r10, [r8*8]
    add r10, rdi
    mov r10, qword ptr [r10+0]
    lea r11, [r8*8]
    add r11, rsi
    mov rax, qword ptr [r11+0]
    cmp r10, rax
    jne .L121_2
    add r8, 1
    cmp r8, r9
    jl .L121_1
    jmp .L121_3
.L121_2:
    mov rax, 0
    ret
.globl zyl_variant_eq
zyl_variant_eq:
.L122_0:
    cmp rdi, rsi
    jne .L122_1
.L122_5:
    mov rax, 1
    ret
.L122_1:
    cmp rdi, 0
    je .L122_3
    cmp rsi, 0
    jne .L122_2
.L122_3:
    mov rax, 0
    ret
.L122_2:
    lea r8, [rdi-8]
    mov r8, qword ptr [r8+0]
    lea r9, [rsi-8]
    mov rax, qword ptr [r9+0]
    cmp r8, rax
    jne .L122_4
    mov r9, 0
    mov rdx, r9
    mov rcx, r8
    jmp zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Deq
.L122_4:
    mov rax, 0
    ret
.globl zyl_variant_cmp
zyl_variant_cmp:
.L123_0:
    cmp rdi, rsi
    jne .L123_1
.L123_6:
    mov rax, 0
    ret
.L123_1:
    cmp rdi, 0
    je .L123_3
    cmp rsi, 0
    jne .L123_2
.L123_3:
    cmp rdi, 0
    jne .L123_4
    mov rax, -1
    ret
.L123_4:
    mov rax, 1
    ret
.L123_2:
    lea r8, [rdi-8]
    mov r8, qword ptr [r8+0]
    lea r9, [rsi-8]
    mov r9, qword ptr [r9+0]
    mov r10, 1
    mov r11, r8
    cmp r8, r9
    jl .L123_5
    mov r11, r9
.L123_5:
    mov rdx, r10
    mov rcx, r11
    jmp zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Dcmp_x7EInt_x2CInt_x2CInt_x2CInt_x2CInt_x2CInt
.globl zyl_variant_field
zyl_variant_field:
.L124_0:
    cmp rdi, 0
    jne .L124_1
.L124_2:
    mov rax, 0
    ret
.L124_1:
    add rsi, 1
    shl rsi, 3
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__heap__rt_x2Dbudget:
.L125_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__rt_x2Dparse_x2Du:
.L126_0:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 48
    jl .L126_1
    cmp r8, 57
    jg .L126_1
    add rdi, 1
    imul rsi, rsi, 10
    sub r8, 48
    add rsi, r8
    jmp .L126_0
.L126_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__rt_x2Dskip_x2Dws:
.L127_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 32
    je .L127_2
    cmp rsi, 9
    jl .L127_1
    cmp rsi, 13
    jg .L127_1
.L127_2:
    add rdi, 1
    jmp .L127_0
.L127_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__heap__rt_x2Dstrtoull:
.L128_0:
    call zy_local_x2Fmain_0__heap__rt_x2Dskip_x2Dws
    mov rsi, rax
    movzx eax, byte ptr [rsi+0]
    cmp rax, 43
    jne .L128_1
    lea rdi, [rsi+1]
    jmp .L128_2
.L128_1:
    mov rdi, rsi
.L128_2:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__heap__rt_x2Dparse_x2Du
zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Dfield:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L129_0:
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov r8, 0
    mov rdi, rbx
    mov rdx, r13
    mov rcx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jge .L129_1
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L129_1:
    lea rdi, [rbx+rsi]
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__heap__rt_x2Dstrtoull
zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Dfind:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L130_0:
    lea rax, [r15+r14]
    cmp rax, r12
    jle .L130_1
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L130_1:
    cmp r15, 0
    je .L130_3
    lea rsi, [r15-1]
    add rsi, rbx
    movzx eax, byte ptr [rsi+0]
    cmp rax, 10
    jne .L130_2
.L130_3:
    lea rdi, [rbx+r15]
    mov rsi, r13
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    cmp rax, 0
    je .L130_2
    lea rax, [r15+r14]
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L130_2:
    add r15, 1
    jmp .L130_0
zy_local_x2Fmain_0__heap__rt_x2Dread_x2Dall:
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
.L131_0:
    cmp r14, r13
    jl .L131_1
.L131_3:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L131_1:
    lea rsi, [r12+r14]
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L131_2
    add r14, rsi
    cmp r14, r13
    jl .L131_1
    jmp .L131_3
.L131_2:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Davailable:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L132_0:
    lea rax, [rip+.L133]
    mov rdi, rax
    mov rsi, 524288
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_2
    mov rbx, rax
    cmp rbx, 0
    jge .L132_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L132_1:
    mov rdi, 16384
    mov rsi, 0
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L132_2
    mov rdi, rbx
    call zyl_rt_sys_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L132_2:
    mov rsi, 16383
    mov rdi, 0
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dread_x2Dall
    mov r13, rax
    mov rdi, rbx
    call zyl_rt_sys_3
    lea rsi, [r12+r13]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    lea rax, [rip+.L134]
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Dfield
    mov rbx, rax
    lea rax, [rip+.L135]
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Dfield
    mov r13, rax
    mov rdi, r12
    call zyl_rt_free
    cmp rbx, 0
    jle .L132_3
    mov rax, rbx
    shl rax, 10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L132_3:
    cmp r13, 0
    jle .L132_4
    mov rax, r13
    shl rax, 10
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L132_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__heap__rt_x2Dsysinfo_x2Dtotal:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L136_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_sysinfo@tpoff]
    mov rbx, rax
    mov rdi, rbx
    call zyl_rt_sys_99
    cmp rax, 0
    je .L136_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L136_1:
    mov rsi, qword ptr [rbx+32]
    mov edi, dword ptr [rbx+104]
    imul rsi, rdi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Dvalue:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L137_0:
    lea rax, [rip+.L138]
    mov rdi, rax
    call zyl_getenv_str
    mov rdi, rax
    cmp rdi, 0
    jle .L137_1
    movzx eax, byte ptr [rdi+0]
    cmp rax, 0
    jle .L137_1
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__heap__rt_x2Dstrtoull
.L137_1:
    call zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Davailable
    mov rsi, rax
    mov rdi, rsi
    cmp rsi, 0
    jg .L137_2
    call zy_local_x2Fmain_0__heap__rt_x2Dsysinfo_x2Dtotal
    mov rdi, rax
.L137_2:
    cmp rdi, 0
    jle .L137_3
    mov rcx, rdi
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 1
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rsi, rax
    shl rsi, 2
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L137_3:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Donce:
    push rbx
.L139_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rbx, rax
    mov rax, qword ptr [rbx+0]
    cmp rax, 2
    jne .L139_1
    mov rax, 0
    pop rbx
    ret
.L139_1:
    mov rsi, 0
    mov rdi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov r11, rdi
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, 0
    jne .L139_2
    call zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Dvalue
    mov rsi, rax
    mov qword ptr [rbx+8], rsi
    mov rsi, 2
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    pop rbx
    ret
.L139_2:
    mov rdi, rbx
    pop rbx
    jmp zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Dwait
zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Dwait:
.L140_0:
    mov rax, qword ptr [rdi+0]
    cmp rax, 2
    jne .L140_1
    mov rax, 0
    ret
.L140_1:
    jmp .L140_0
zy_local_x2Fmain_0__heap__rt_x2Dcharge:
    push rbx
    mov rbx, rdi
.L141_0:
    call zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Donce
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    lea rdi, [rsi+16]
    mov rdx, rdi
    mov rcx, rbx
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rdi, rax
    add rdi, rbx
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jle .L141_1
    mov rax, qword ptr [rsi+8]
    cmp rdi, rax
    jle .L141_1
    add rsi, 16
    mov rdi, 0
    sub rdi, rbx
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rax, 0
    pop rbx
    ret
.L141_1:
    mov rax, 1
    pop rbx
    ret
zy_local_x2Fmain_0__heap__rt_x2Drefund:
.L142_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    add rsi, 16
    mov r8, 0
    sub r8, rdi
    mov rdx, rsi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    ret
zy_local_x2Fmain_0__heap__hp_x2Dmagic:
.L143_0:
    mov rax, 23130
    ret
zy_local_x2Fmain_0__heap__hp_x2Dbig:
.L144_0:
    mov rax, 255
    ret
zy_local_x2Fmain_0__heap__hp_x2Dlimit:
.L145_0:
    mov rax, 281474976710656
    ret
zy_local_x2Fmain_0__heap__hp_x2Dcls:
.L146_0:
    lea rax, [rip+zyl_rtg_heap_cls]
    mov rsi, rax
    shl rdi, 5
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__hp_x2Dthreaded:
.L147_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__hp_x2Dlock:
.L148_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jle .L148_1
    mov rsi, 0
    mov r8, 1
    mov rdx, rdi
    mov rcx, rsi
    mov r11, r8
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, 0
    jne .L148_2
    mov rax, 0
    ret
.L148_2:
    jmp zy_local_x2Fmain_0__heap__hp_x2Dlock_x2Dslow
.L148_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__heap__hp_x2Dlock_x2Dslow:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L149_0:
    mov rsi, 2
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L149_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L149_1:
    mov rsi, 128
    mov rdi, 2
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zyl_rt_sys_202
    jmp .L149_0
zy_local_x2Fmain_0__heap__hp_x2Dunlock:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L150_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jle .L150_1
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 2
    jne .L150_2
    mov rsi, 129
    mov r8, 1
    mov rdx, r8
    call zyl_rt_sys_202
    mov rsp, rbp
    pop rbp
    ret
.L150_2:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L150_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__heap__hp_x2Dmap:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L151_0:
    mov rsi, 0
    mov r8, 3
    mov r9, 34
    mov r10, -1
    mov r11, 0
    mov rdx, r8
    mov rcx, r9
    mov r8, r10
    mov r9, r11
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_9
    mov rsi, rax
    cmp rsi, 0
    jge .L151_1
    cmp rsi, -4096
    jle .L151_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L151_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__heap__hp_x2Dclass_x2Dof:
.L152_0:
    cmp rdi, 32
    jg .L152_1
.L152_3:
    mov rax, 0
    ret
.L152_1:
    mov rsi, 64
    sub rdi, 1
    mov rdx, rdi
    mov ecx, 127
    bsr rax, rdx
    cmovz rax, rcx
    xor rax, 63
    mov rdi, rax
    sub rsi, rdi
    cmp rsi, 16
    jle .L152_2
    mov rax, 12
    ret
.L152_2:
    lea rax, [rsi-5]
    ret
zy_local_x2Fmain_0__heap__hp_x2Dtag:
.L153_0:
    cmp rdi, 0
    je .L153_1
.L153_3:
    mov rdi, 256
    jmp .L153_2
.L153_1:
    mov rdi, 0
.L153_2:
    add rsi, rdi
    add rsi, 1515847680
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__hp_x2Dhead:
    mov r8, rdx
.L154_0:
    mov qword ptr [rdi+0], rsi
    mov qword ptr [rdi+8], r8
    lea rax, [rdi+16]
    ret
zy_local_x2Fmain_0__heap__hp_x2Dtake:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L155_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dcls
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dlock
    mov r13, qword ptr [r12+8]
    cmp r13, 0
    jle .L155_1
    mov rsi, qword ptr [r13+0]
    mov qword ptr [r12+8], rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dunlock
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
.L155_1:
    mov rsi, 32
    mov rax, rsi
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    mov r13, qword ptr [r12+16]
    cmp r13, 0
    jle .L155_2
    lea rsi, [r13+rbx]
    mov rax, qword ptr [r12+24]
    cmp rsi, rax
    jg .L155_2
    lea rsi, [r13+rbx]
    mov qword ptr [r12+16], rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dunlock
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
.L155_2:
    mov rdi, 1048576
    call zy_local_x2Fmain_0__heap__hp_x2Dmap
    mov r13, rax
    cmp r13, 0
    jne .L155_3
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dunlock
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L155_3:
    lea rsi, [r13+rbx]
    mov qword ptr [r12+16], rsi
    lea rsi, [r13+1048576]
    mov qword ptr [r12+24], rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dunlock
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__heap__hp_x2Dalloc:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L156_0:
    cmp rbx, 0
    jl .L156_2
.L156_12:
    mov rax, 281474976710656
    cmp rbx, rax
    jle .L156_1
.L156_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L156_1:
    lea rdi, [rbx+16]
    call zy_local_x2Fmain_0__heap__hp_x2Dclass_x2Dof
    mov r13, rax
    cmp r13, 12
    jl .L156_3
    add rbx, 4111
    and rbx, -4096
    cmp r12, 0
    je .L156_4
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    jne .L156_4
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L156_4:
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dmap
    mov r14, rax
    cmp r14, 0
    jne .L156_5
    cmp r12, 0
    je .L156_6
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    jmp .L156_7
.L156_6:
.L156_7:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L156_5:
    mov rsi, 255
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dtag
    mov rsi, rax
    mov rdi, r14
    mov rdx, rsi
    mov rsi, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__heap__hp_x2Dhead
.L156_3:
    mov rsi, 32
    mov rax, rsi
    mov rcx, r13
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    cmp r12, 0
    je .L156_8
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    jne .L156_8
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L156_8:
    mov rdi, r13
    call zy_local_x2Fmain_0__heap__hp_x2Dtake
    mov r14, rax
    cmp r14, 0
    jne .L156_9
    cmp r12, 0
    je .L156_10
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    jmp .L156_11
.L156_10:
.L156_11:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L156_9:
    mov rdi, r12
    mov rsi, r13
    call zy_local_x2Fmain_0__heap__hp_x2Dtag
    mov rsi, rax
    mov rdi, r14
    mov rdx, rsi
    mov rsi, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__heap__hp_x2Dhead
zy_local_x2Fmain_0__heap__hp_x2Dvalid:
.L157_0:
    cmp rdi, 4112
    jl .L157_1
.L157_3:
    mov rax, rdi
    and rax, 15
    cmp rax, 0
    jne .L157_2
    lea rsi, [rdi-8]
    mov rsi, qword ptr [rsi+0]
    shr rsi, 16
    mov rax, rsi
    cmp rax, 23130
    sete al
    movzx rax, al
    ret
.L157_2:
    mov rax, 0
    ret
.L157_1:
    mov rax, 0
    ret
.globl zyl_rt_malloc
zyl_rt_malloc:
.L158_0:
    mov rsi, 1
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
zy_local_x2Fmain_0__heap__rt_x2Draw_x2Dmalloc:
.L159_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
.globl zyl_rt_free
zyl_rt_free:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L160_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dvalid
    cmp rax, 0
    jne .L160_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L160_1:
    sub rbx, 16
    mov r12, qword ptr [rbx+0]
    mov r13, qword ptr [rbx+8]
    mov rdi, r13
    and rdi, 255
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
    cmp rdi, 255
    jne .L160_2
    mov rdi, rbx
    mov rsi, r12
    call zyl_rt_sys_11
    jmp .L160_3
.L160_2:
    call zy_local_x2Fmain_0__heap__hp_x2Dcls
    mov r14, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__heap__hp_x2Dlock
    mov rsi, qword ptr [r14+8]
    mov qword ptr [rbx+0], rsi
    mov qword ptr [r14+8], rbx
    mov rdi, r14
    call zy_local_x2Fmain_0__heap__hp_x2Dunlock
.L160_3:
    mov rax, r13
    and rax, 256
    cmp rax, 256
    jne .L160_4
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    jmp .L160_5
.L160_4:
.L160_5:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_rt_calloc
zyl_rt_calloc:
    push rbx
.L161_0:
    cmp rdi, 0
    jl .L161_2
.L161_7:
    cmp rsi, 0
    jge .L161_1
.L161_2:
    mov rax, 0
    pop rbx
    ret
.L161_1:
    cmp rdi, 0
    jle .L161_3
    mov r8, 281474976710656
    mov rax, r8
    mov rcx, rdi
    cqo
    idiv rcx
    cmp rsi, rax
    jle .L161_3
    mov rax, 0
    pop rbx
    ret
.L161_3:
    mov rbx, rdi
    imul rbx, rsi
    mov rsi, 1
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L161_4
    mov rax, 0
    pop rbx
    ret
.L161_4:
    cmp rbx, 0
    jle .L161_5
    lea rdi, [rsi-8]
    mov rdi, qword ptr [rdi+0]
    and rdi, 255
    cmp rdi, 255
    je .L161_5
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov r11, rbx
    push rdi
    mov rdi, rdx
    mov rax, rcx
    mov rcx, r11
    rep stosb
    pop rdi
    xor eax, eax
    jmp .L161_6
.L161_5:
.L161_6:
    mov rax, rsi
    pop rbx
    ret
.globl zyl_rt_realloc
zyl_rt_realloc:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L162_0:
    cmp rbx, 0
    jne .L162_1
.L162_8:
    mov rsi, 1
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
.L162_1:
    cmp r12, 0
    jne .L162_2
    mov rdi, rbx
    call zyl_rt_free
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L162_2:
    cmp r12, 0
    jl .L162_4
    mov rax, 281474976710656
    cmp r12, rax
    jg .L162_5
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dvalid
    cmp rax, 0
    jne .L162_3
.L162_5:
.L162_4:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L162_3:
    lea rsi, [rbx-16]
    mov r13, qword ptr [rsi+0]
    sub r13, 16
    cmp r12, r13
    jg .L162_6
    mov rax, rbx
    pop r13
    pop r12
    pop rbx
    ret
.L162_6:
    mov rsi, 1
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L162_7
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L162_7:
    mov rdi, r12
    mov rsi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdi, rbx
    call zyl_rt_free
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__heap__rt_x2Dstrdup:
    push rbx
    push r12
    push r13
.L163_0:
    mov rbx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    lea rdi, [r12+1]
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L163_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L163_1:
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r13+r12]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dld32s:
.L164_0:
    mov esi, dword ptr [rdi+0]
    cmp rsi, 2147483647
    jle .L164_1
    mov rdi, 4294967296
    mov rax, rsi
    sub rax, rdi
    ret
.L164_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash:
.L165_0:
    mov rsi, rdi
    shr rsi, 30
    xor rsi, rdi
    mov rdi, -4658895280553007687
    imul rsi, rdi
    mov rdi, rsi
    shr rdi, 27
    xor rsi, rdi
    mov rdi, -7723592293110705685
    imul rsi, rdi
    mov rdi, rsi
    shr rdi, 31
    mov rax, rsi
    xor rax, rdi
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dint_x2Dtext_x2Dheap:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L166_0:
    call zyl_int_text
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dgrow:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
.L167_0:
    mov r12, qword ptr [rbx+8]
    cmp r12, 0
    je .L167_1
    lea rsi, [r12*8]
.L167_1:
    mov r13, rsi
    mov rsi, 16
    mov rdi, r13
    call zyl_rt_calloc
    mov r14, rax
    cmp r14, 0
    jne .L167_2
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L167_2:
    mov r15, qword ptr [rbx+0]
    lea rsi, [r13-1]
    mov r8, 0
    mov rdi, r15
    mov rdx, r14
    mov rcx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Drehash
    mov rdi, r15
    call zyl_rt_free
    mov qword ptr [rbx+0], r14
    mov qword ptr [rbx+8], r13
    mov rsi, r13
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
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
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L168_0:
    cmp r15, qword ptr [rbp-56]
    jl .L168_1
.L168_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L168_1:
    mov rsi, r15
    shl rsi, 4
    mov rbx, qword ptr [rbp-48]
    add rbx, rsi
    mov r12, qword ptr [rbx+0]
    cmp r12, 0
    je .L168_2
    mov rsi, r12
    shr rsi, 30
    xor rsi, r12
    mov rdi, -4658895280553007687
    imul rsi, rdi
    mov rdi, rsi
    shr rdi, 27
    xor rsi, rdi
    mov rdi, -7723592293110705685
    imul rsi, rdi
    mov rdi, rsi
    shr rdi, 31
    xor rsi, rdi
    and rsi, r14
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfree_x2Dslot
    mov rsi, rax
    mov rdi, rsi
    shl rdi, 4
    add rdi, r13
    mov qword ptr [rdi+0], r12
    shl rsi, 4
    add rsi, 8
    add rsi, r13
    mov rdi, qword ptr [rbx+8]
    mov qword ptr [rsi+0], rdi
.L168_2:
    add r15, 1
    cmp r15, qword ptr [rbp-56]
    jl .L168_1
    jmp .L168_3
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfree_x2Dslot:
    mov r8, rdx
.L169_0:
    mov r9, r8
    shl r9, 4
    add r9, rdi
    mov rax, qword ptr [r9+0]
    cmp rax, 0
    jne .L169_1
    mov rax, r8
    ret
.L169_1:
    add r8, 1
    and r8, rsi
    jmp .L169_0
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dslot:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L170_0:
    mov rdi, qword ptr [rbx+16]
    imul rdi, rdi, 10
    mov r8, qword ptr [rbx+8]
    imul r8, r8, 7
    cmp rdi, r8
    jl .L170_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dgrow
    jmp .L170_2
.L170_1:
.L170_2:
    mov r13, qword ptr [rbx+8]
    cmp r13, 0
    jne .L170_3
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L170_3:
    mov r14, qword ptr [rbx+0]
    lea r15, [r13-1]
    mov rdi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
    mov rsi, rax
    lea rdi, [r13-1]
    and rsi, rdi
    mov rdi, r14
    mov rdx, r12
    mov rcx, rsi
    mov rsi, r15
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L170_4
    mov qword ptr [rsi+0], r12
    mov rdi, qword ptr [rbx+16]
    add rdi, 1
    mov qword ptr [rbx+16], rdi
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L170_4:
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dprobe:
    mov r8, rdx
    mov r9, rcx
.L171_0:
    mov r10, r9
    shl r10, 4
    add r10, rdi
    mov r11, qword ptr [r10+0]
    cmp r11, 0
    je .L171_2
    cmp r11, r8
    jne .L171_1
.L171_2:
    mov rax, r10
    ret
.L171_1:
    add r9, 1
    and r9, rsi
    jmp .L171_0
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rsi
.L172_0:
    mov r12, qword ptr [rdi+8]
    cmp rbx, 0
    je .L172_2
    cmp r12, 0
    jne .L172_1
.L172_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L172_1:
    mov r13, qword ptr [rdi+0]
    lea r14, [r12-1]
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
    mov rsi, rax
    lea rdi, [r12-1]
    and rsi, rdi
    mov rdi, r13
    mov rdx, rbx
    mov rcx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L172_3
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L172_3:
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dspans:
.L173_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_span_set
zyl_span_set:
    push rbx
    push r12
    mov rbx, rsi
    mov r12, rdx
.L174_0:
    cmp rdi, 0
    jne .L174_1
.L174_3:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L174_1:
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
    jne .L174_2
    mov rax, 0
    pop r12
    pop rbx
    ret
.L174_2:
    mov rdi, 4294967295
    and rdi, rbx
    mov dword ptr [rsi+8], edi
    mov rdi, 4294967295
    and rdi, r12
    mov dword ptr [rsi+12], edi
    mov rax, 0
    pop r12
    pop rbx
    ret
.globl zyl_span_off
zyl_span_off:
.L175_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L175_1
    mov rax, -1
    ret
.L175_1:
    lea rdi, [rsi+8]
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dld32s
.globl zyl_span_file
zyl_span_file:
.L176_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L176_1
    mov rax, -1
    ret
.L176_1:
    lea rdi, [rsi+12]
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dld32s
.globl zyl_span_copy
zyl_span_copy:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L177_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov r12, rax
    cmp r12, 0
    jne .L177_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L177_1:
    lea rdi, [r12+8]
    call zy_local_x2Fmain_0__ctab__rt_x2Dld32s
    mov r13, rax
    lea rdi, [r12+12]
    call zy_local_x2Fmain_0__ctab__rt_x2Dld32s
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    pop r13
    pop r12
    pop rbx
    jmp zyl_span_set
zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab:
.L178_0:
    lea rax, [rip+zyl_rtg_attrs]
    mov rsi, rax
    imul rdi, rdi, 24
    add rsi, rdi
    mov rax, rsi
    ret
.globl zyl_attr_set
zyl_attr_set:
    push rbx
    push r12
    mov rbx, rsi
    mov r12, rdx
.L179_0:
    cmp rbx, 0
    je .L179_2
.L179_5:
    cmp rdi, 0
    jl .L179_3
    cmp rdi, 6
    jl .L179_1
.L179_3:
.L179_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L179_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rdi, rax
    mov rsi, 4096
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dslot
    mov rsi, rax
    cmp rsi, 0
    jne .L179_4
    mov rax, 0
    pop r12
    pop rbx
    ret
.L179_4:
    mov qword ptr [rsi+8], r12
    mov rax, 0
    pop r12
    pop rbx
    ret
.globl zyl_attr_get
zyl_attr_get:
    push rbx
    mov rbx, rsi
.L180_0:
    cmp rdi, 0
    jl .L180_2
.L180_4:
    cmp rdi, 6
    jl .L180_1
.L180_2:
    mov rax, 0
    pop rbx
    ret
.L180_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rdi, rax
    mov rsi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L180_3
    mov rax, 0
    pop rbx
    ret
.L180_3:
    mov rax, qword ptr [rsi+8]
    pop rbx
    ret
.globl zyl_attr_clear
zyl_attr_clear:
    push rbx
.L181_0:
    cmp rdi, 0
    jl .L181_2
.L181_4:
    cmp rdi, 6
    jl .L181_1
.L181_2:
    mov rax, 0
    pop rbx
    ret
.L181_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L181_3
    mov rax, 0
    pop rbx
    ret
.L181_3:
    mov rdi, qword ptr [rbx+0]
    mov rsi, qword ptr [rbx+8]
    shl rsi, 4
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dzero:
.L182_0:
    cmp rsi, 0
    jg .L182_1
.L182_2:
    mov rax, 0
    ret
.p2align 4
.L182_1:
    mov r8, 0
    mov qword ptr [rdi+0], r8
    add rdi, 8
    sub rsi, 8
    cmp rsi, 0
    jg .L182_1
    jmp .L182_2
.globl zyl_attr_copy
zyl_attr_copy:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L183_0:
    mov rdi, rbx
    call zyl_attr_get
    mov rsi, rax
    cmp rsi, 0
    jne .L183_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L183_1:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_attr_set
    mov rax, 0
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash:
    push rbx
    mov rbx, rdi
.L184_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov r8, -3750763034362895579
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    pop rbx
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn:
    mov r8, rdx
    mov r9, rcx
.L185_0:
    lea rax, [r8+8]
    cmp rax, rsi
    jg .L185_1
    lea r10, [r8+8]
    lea r11, [rdi+r8]
    mov r11, qword ptr [r11+0]
    xor r9, r11
    mov r11, -7046029254386353131
    imul r9, r11
    mov r8, r10
    jmp .L185_0
.L185_1:
    cmp r8, rsi
    jge .L185_2
    lea r10, [r8+1]
    lea r11, [rdi+r8]
    movzx r11d, byte ptr [r11+0]
    xor r9, r11
    mov r11, 1099511628211
    imul r9, r11
    mov r8, r10
    jmp .L185_0
.L185_2:
    xor rsi, r9
    mov rdi, rsi
    shr rdi, 30
    xor rsi, rdi
    mov rdi, -4658895280553007687
    imul rsi, rdi
    mov rdi, rsi
    shr rdi, 27
    xor rsi, rdi
    mov rdi, -7723592293110705685
    imul rsi, rdi
    mov rdi, rsi
    shr rdi, 31
    mov rax, rsi
    xor rax, rdi
    ret
.globl zyl_smap_new
zyl_smap_new:
.L186_0:
    mov rdi, 1
    mov rsi, 24
    jmp zyl_rt_calloc
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dgrow:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
.L187_0:
    mov r12, qword ptr [rbx+8]
    mov rsi, 1024
    cmp r12, 0
    je .L187_1
    lea rsi, [r12*4]
.L187_1:
    mov r13, rsi
    mov rsi, 24
    mov rdi, r13
    call zyl_rt_calloc
    mov r14, rax
    cmp r14, 0
    jne .L187_2
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L187_2:
    mov r15, qword ptr [rbx+0]
    lea rsi, [r13-1]
    mov r8, 0
    mov rdi, r15
    mov rdx, r14
    mov rcx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Drehash
    mov rdi, r15
    call zyl_rt_free
    mov qword ptr [rbx+0], r14
    mov qword ptr [rbx+8], r13
    mov rsi, r13
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Drehash:
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
.L188_0:
    cmp r15, r12
    jl .L188_1
.L188_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L188_1:
    imul rsi, r15, 24
    mov rbx, qword ptr [rbp-48]
    add rbx, rsi
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L188_2
    jmp .L188_3
.L188_2:
    mov rsi, qword ptr [rbx+16]
    and rsi, r14
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dempty
    mov rsi, rax
    imul rsi, rsi, 24
    add rsi, r13
    mov rdi, qword ptr [rbx+0]
    mov qword ptr [rsi+0], rdi
    mov rdi, qword ptr [rbx+8]
    mov qword ptr [rsi+8], rdi
    mov rdi, qword ptr [rbx+16]
    mov qword ptr [rsi+16], rdi
.L188_3:
    add r15, 1
    cmp r15, r12
    jl .L188_1
    jmp .L188_4
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dempty:
    mov r8, rdx
.L189_0:
    imul r9, r8, 24
    add r9, rdi
    mov rax, qword ptr [r9+0]
    cmp rax, 0
    jne .L189_1
    mov rax, r8
    ret
.L189_1:
    add r8, 1
    and r8, rsi
    jmp .L189_0
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
.L190_0:
    imul rsi, r15, 24
    mov rbx, qword ptr [rbp-48]
    add rbx, rsi
    mov rdi, qword ptr [rbx+0]
    cmp rdi, 0
    jne .L190_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L190_1:
    mov rax, qword ptr [rbx+16]
    cmp rax, r14
    jne .L190_2
    mov rsi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L190_2
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L190_2:
    add r15, 1
    and r15, r12
    jmp .L190_0
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L191_0:
    cmp rbx, 0
    je .L191_2
.L191_5:
    cmp r12, 0
    je .L191_3
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L191_1
.L191_3:
.L191_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L191_1:
    mov r13, qword ptr [rbx+8]
    sub r13, 1
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
    mov rdi, qword ptr [rbx+0]
    mov r8, rsi
    and r8, r13
    mov rdx, r12
    mov rcx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L191_4
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L191_4:
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
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
    sub rsp, 8
    mov rbx, rdi
    mov r12, rsi
    mov qword ptr [rbp-48], rdx
.L192_0:
    mov r14, r12
    cmp rbx, 0
    je .L192_2
    cmp r14, 0
    jne .L192_1
.L192_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L192_1:
    mov rsi, qword ptr [rbx+16]
    imul rsi, rsi, 10
    mov rdi, qword ptr [rbx+8]
    imul rdi, rdi, 7
    cmp rsi, rdi
    jl .L192_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dgrow
    jmp .L192_4
.L192_3:
.L192_4:
    mov r15, qword ptr [rbx+8]
    cmp r15, 0
    jne .L192_5
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L192_5:
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov r8, -3750763034362895579
    mov rdx, rdi
    mov rdi, r14
    mov rcx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
    mov r13, rax
    mov rdi, qword ptr [rbx+0]
    lea rsi, [r15-1]
    lea r8, [r15-1]
    and r8, r13
    mov rdx, r14
    mov rcx, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dprobe
    mov r14, rax
    mov rax, qword ptr [r14+0]
    cmp rax, 0
    jne .L192_6
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov rsi, rax
    cmp rsi, 0
    jne .L192_7
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L192_7:
    mov qword ptr [r14+0], rsi
    mov qword ptr [r14+16], r13
    mov rsi, qword ptr [rbx+16]
    add rsi, 1
    mov qword ptr [rbx+16], rsi
    mov rcx, qword ptr [rbp-48]
    mov qword ptr [r14+8], rcx
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L192_6:
    mov rcx, qword ptr [rbp-48]
    mov qword ptr [r14+8], rcx
    mov rax, 0
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
.L193_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L193_1
    mov rax, 0
    ret
.L193_1:
    mov rax, qword ptr [rsi+8]
    ret
.globl zyl_smap_has
zyl_smap_has:
.L194_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    cmp rax, 0
    jne .L194_1
    mov rax, 0
    ret
.L194_1:
    mov rax, 1
    ret
.globl zyl_smap_get_or
zyl_smap_get_or:
    push rbx
    mov rbx, rdx
.L195_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L195_1
    mov rax, rbx
    pop rbx
    ret
.L195_1:
    mov rax, qword ptr [rsi+8]
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dfree_x2Dkeys:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L196_0:
    cmp r12, r13
    jl .L196_1
.L196_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L196_1:
    imul rsi, r12, 24
    add rsi, rbx
    mov rdi, qword ptr [rsi+0]
    call zyl_rt_free
    add r12, 1
    cmp r12, r13
    jl .L196_1
    jmp .L196_2
.globl zyl_smap_clear
zyl_smap_clear:
    push rbx
    push r12
    mov rbx, rdi
.L197_0:
    cmp rbx, 0
    jne .L197_1
.L197_4:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L197_1:
    mov r12, qword ptr [rbx+8]
    mov rdi, qword ptr [rbx+0]
    mov rsi, 0
    mov rdx, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Dfree_x2Dkeys
    cmp r12, 0
    jle .L197_2
    mov rdi, qword ptr [rbx+0]
    imul rsi, r12, 24
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    jmp .L197_3
.L197_2:
.L197_3:
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    mov rax, 0
    pop r12
    pop rbx
    ret
.globl zyl_wvec_new
zyl_wvec_new:
.L198_0:
    mov rdi, 1
    mov rsi, 24
    jmp zyl_rt_calloc
.globl zyl_wvec_push
zyl_wvec_push:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L199_0:
    cmp rbx, 0
    jne .L199_1
.L199_8:
    mov rax, -1
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L199_1:
    mov r13, qword ptr [rbx+8]
    mov rax, qword ptr [rbx+16]
    cmp r13, rax
    jl .L199_2
    mov rax, qword ptr [rbx+16]
    cmp rax, 0
    jne .L199_4
    mov rsi, 4096
    jmp .L199_5
.L199_4:
    mov rsi, qword ptr [rbx+16]
    shl rsi, 1
.L199_5:
    mov r14, rsi
    mov rdi, qword ptr [rbx+0]
    lea rsi, [r14*8]
    call zyl_rt_realloc
    mov rsi, rax
    mov rdi, 0
    cmp rsi, 0
    je .L199_6
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+16], r14
    mov rdi, 1
.L199_6:
    jmp .L199_3
.L199_2:
    mov rdi, 1
.L199_3:
    mov rax, rdi
    cmp rax, 0
    je .L199_7
    mov rsi, qword ptr [rbx+0]
    lea rdi, [r13*8]
    add rsi, rdi
    mov qword ptr [rsi+0], r12
    lea rsi, [r13+1]
    mov qword ptr [rbx+8], rsi
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L199_7:
    mov rax, -1
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_wvec_get
zyl_wvec_get:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
.L200_0:
    mov r8, 0
    cmp rdi, 0
    je .L200_1
    mov r8, qword ptr [rdi+8]
.L200_1:
    mov rbx, r8
    cmp rdi, 0
    je .L200_3
    cmp rsi, 0
    jl .L200_4
    cmp rsi, rbx
    jl .L200_2
.L200_4:
.L200_3:
    lea rax, [rip+.L201]
    mov r12, rax
    mov rdi, rsi
    call zyl_int_text
    mov r13, rax
    lea rax, [rip+.L202]
    mov r14, rax
    mov rdi, rbx
    call zyl_int_text
    mov r8, rax
    mov rdi, r14
    mov rsi, r8
    call zyl_cstr_concat
    mov r8, rax
    mov rdi, r13
    mov rsi, r8
    call zyl_cstr_concat
    mov r8, rax
    mov rdi, r12
    mov rsi, r8
    call zyl_cstr_concat
    mov r8, rax
    mov rdi, r8
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.L200_2:
    mov rdi, qword ptr [rdi+0]
    shl rsi, 3
    add rdi, rsi
    mov rax, qword ptr [rdi+0]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_wvec_set
zyl_wvec_set:
    mov r8, rdx
.L203_0:
    cmp rdi, 0
    je .L203_2
.L203_4:
    cmp rsi, 0
    jl .L203_3
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jl .L203_1
.L203_3:
.L203_2:
    mov rax, 0
    ret
.L203_1:
    mov rdi, qword ptr [rdi+0]
    shl rsi, 3
    add rdi, rsi
    mov qword ptr [rdi+0], r8
    mov rax, 0
    ret
.globl zyl_wvec_len
zyl_wvec_len:
.L204_0:
    cmp rdi, 0
    jne .L204_1
.L204_2:
    mov rax, 0
    ret
.L204_1:
    mov rax, qword ptr [rdi+8]
    ret
.globl zyl_wvec_pop
zyl_wvec_pop:
.L205_0:
    cmp rdi, 0
    je .L205_2
.L205_3:
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jg .L205_1
.L205_2:
    lea rax, [rip+.L206]
    mov rsi, rax
    mov rdi, rsi
    jmp zyl_panic
.L205_1:
    mov rsi, qword ptr [rdi+8]
    sub rsi, 1
    mov qword ptr [rdi+8], rsi
    mov rdi, qword ptr [rdi+0]
    shl rsi, 3
    add rdi, rsi
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_wvec_truncate
zyl_wvec_truncate:
.L207_0:
    cmp rdi, 0
    jle .L207_1
.L207_2:
    cmp rsi, 0
    jl .L207_1
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jge .L207_1
    mov qword ptr [rdi+8], rsi
    mov rax, 0
    ret
.L207_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dglobal_x2Dhandle:
    push rbx
    mov r8, rdx
.L208_0:
    cmp rsi, 0
    jl .L208_2
.L208_6:
    cmp rsi, 8
    jl .L208_1
.L208_2:
    mov rax, 0
    pop rbx
    ret
.L208_1:
    shl rsi, 3
    lea rbx, [rdi+rsi]
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L208_3
    cmp r8, 0
    je .L208_4
    mov rdi, 1
    mov rsi, 24
    call zyl_rt_calloc
    mov rsi, rax
    jmp .L208_5
.L208_4:
    mov rdi, 1
    mov r8, 24
    mov rsi, r8
    call zyl_rt_calloc
    mov rsi, rax
.L208_5:
    mov qword ptr [rbx+0], rsi
    mov rax, qword ptr [rbx+0]
    pop rbx
    ret
.L208_3:
    mov rax, qword ptr [rbx+0]
    pop rbx
    ret
.globl zyl_wvec_global
zyl_wvec_global:
.L209_0:
    lea rax, [rip+zyl_rtg_gwvecs]
    mov rsi, rax
    mov r8, 1
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dglobal_x2Dhandle
.globl zyl_smap_global
zyl_smap_global:
.L210_0:
    lea rax, [rip+zyl_rtg_gsmaps]
    mov rsi, rax
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dglobal_x2Dhandle
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcached:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L211_0:
    lea rdi, [rbx+8]
    mov rsi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jle .L211_1
    mov rax, qword ptr [rsi+8]
    pop r13
    pop r12
    pop rbx
    ret
.L211_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, 0
    cmp rdi, 0
    je .L211_2
    mov rsi, r12
    call zyl_smap_get
    mov rsi, rax
.L211_2:
    mov r13, rsi
    cmp r13, 0
    je .L211_3
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dcache_x2Dcell
.L211_3:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcache_x2Dcell:
    push rbx
    mov rbx, rdx
.L212_0:
    add rdi, 8
    mov r8, 1024
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dslot
    mov rsi, rax
    cmp rsi, 0
    jne .L212_1
    mov rax, 0
    pop rbx
    ret
.L212_1:
    mov qword ptr [rsi+8], rbx
    mov rsi, rbx
    mov rax, rsi
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell:
    mov r8, rdx
.L213_0:
    cmp r8, 0
    je .L213_1
.L213_3:
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcached
.L213_1:
    mov rdi, qword ptr [rdi+0]
    cmp rdi, 0
    jne .L213_2
    mov rax, 0
    ret
.L213_2:
    jmp zyl_smap_get
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dget:
    mov r8, rdx
.L214_0:
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell
    mov rsi, rax
    cmp rsi, 0
    jne .L214_1
    mov rax, 0
    ret
.L214_1:
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dready:
    mov r8, rdx
.L215_0:
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell
    cmp rax, 0
    jne .L215_1
    mov rax, 0
    ret
.L215_1:
    mov rax, 1
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dput:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L216_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L216_1
    mov rdi, 1
    mov rsi, 24
    call zyl_rt_calloc
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    jmp .L216_2
.L216_1:
.L216_2:
    mov rdi, 8
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L216_3
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L216_3:
    mov qword ptr [rsi+0], r13
    mov rdi, qword ptr [rbx+0]
    mov rdx, rsi
    mov rsi, r12
    call zyl_smap_put
    cmp r14, 0
    je .L216_4
    mov rdi, qword ptr [rbx+0]
    mov rsi, r12
    call zyl_smap_get
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Dcache_x2Dcell
    jmp .L216_5
.L216_4:
.L216_5:
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear:
    push rbx
    mov rbx, rdi
.L217_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L217_1
    jmp .L217_2
.L217_1:
    mov rdi, qword ptr [rbx+0]
    call zyl_smap_clear
.L217_2:
    add rbx, 8
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L217_3
    jmp .L217_4
.L217_3:
    mov rdi, qword ptr [rbx+0]
    mov rsi, qword ptr [rbx+8]
    shl rsi, 4
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
.L217_4:
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Ddefs:
.L218_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ctab__rt_x2Didefs:
.L219_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ctab__rt_x2Drepl_x2Ddefs:
.L220_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_global_clear
zyl_global_clear:
.L221_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear
.globl zyl_global_ready
zyl_global_ready:
.L222_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rsi, rax
    mov r8, 1
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dready
.globl zyl_global_get
zyl_global_get:
.L223_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rsi, rax
    mov r8, 1
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dget
.globl zyl_global_put
zyl_global_put:
.L224_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov r8, rax
    mov r9, 1
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dput
.globl zyl_iglobal_clear
zyl_iglobal_clear:
.L225_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear
.globl zyl_iglobal_ready
zyl_iglobal_ready:
.L226_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rsi, rax
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dready
.globl zyl_iglobal_get
zyl_iglobal_get:
.L227_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rsi, rax
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dget
.globl zyl_iglobal_put
zyl_iglobal_put:
.L228_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov r8, rax
    mov r9, 0
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dput
.globl zyl_repl_global_set
zyl_repl_global_set:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L229_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov r13, rax
    mov rax, qword ptr [r13+0]
    cmp rax, 0
    jne .L229_1
    mov rdi, 1
    mov rsi, 24
    call zyl_rt_calloc
    mov rsi, rax
    mov qword ptr [r13+0], rsi
    jmp .L229_2
.L229_1:
.L229_2:
    mov rdi, qword ptr [r13+0]
    mov rsi, rbx
    mov rdx, r12
    call zyl_smap_put
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_repl_global_get
zyl_repl_global_get:
.L230_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L230_1
    mov rax, 0
    ret
.L230_1:
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zyl_smap_get
.globl zyl_contract_warn
zyl_contract_warn:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L231_0:
    cmp rdi, 0
    jne .L231_1
.L231_3:
    lea rax, [rip+.L232]
    mov rsi, rax
    jmp .L231_2
.L231_1:
    mov rsi, rdi
.L231_2:
    lea rax, [rip+.L233]
    mov rbx, rax
    lea rax, [rip+.L234]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, 2
    mov r12, rdi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_err_is
zyl_err_is:
    push rbx
    push r12
    push r13
.L235_0:
    mov rbx, rdi
    mov r12, rsi
    cmp rbx, 0
    je .L235_2
    cmp r12, 0
    jne .L235_1
.L235_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L235_1:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dprefix_x2Deq
    cmp rax, 0
    je .L235_3
    lea rsi, [rbx+r13]
    movzx esi, byte ptr [rsi+0]
    cmp rsi, 58
    jne .L235_4
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    ret
.L235_4:
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    pop r13
    pop r12
    pop rbx
    ret
.L235_3:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dprefix_x2Deq:
    mov r8, rdx
.L236_0:
    cmp r8, 0
    jne .L236_1
.L236_3:
    mov rax, 1
    ret
.p2align 4
.L236_1:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    jne .L236_2
    add rdi, 1
    add rsi, 1
    sub r8, 1
    cmp r8, 0
    jne .L236_1
    jmp .L236_3
.L236_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrcs:
.L237_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dcount:
.L238_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rax, qword ptr [rsi+6144]
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc:
.L239_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    imul rdi, rdi, 24
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dfind:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L240_0:
    cmp r12, r13
    jl .L240_1
.L240_3:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L240_1:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    imul rdi, r12, 24
    add rsi, rdi
    mov rdi, qword ptr [rsi+0]
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L240_2
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    ret
.L240_2:
    add r12, 1
    cmp r12, r13
    jl .L240_1
    jmp .L240_3
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dset_x2Dtext:
    push rbx
    mov rbx, rdi
.L241_0:
    mov rdi, rsi
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov rdi, rax
    mov qword ptr [rbx+8], rdi
    mov rsi, 0
    cmp rdi, 0
    je .L241_1
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L241_1:
    mov qword ptr [rbx+16], rsi
    mov rax, rsi
    pop rbx
    ret
.globl zyl_source_register
zyl_source_register:
    push rbx
    push r12
    push r13
    push r14
    push r15
.L242_0:
    cmp rdi, 0
    jne .L242_1
.L242_11:
    lea rax, [rip+.L243]
    mov r8, rax
    jmp .L242_2
.L242_1:
    mov r8, rdi
.L242_2:
    mov rbx, r8
    cmp rsi, 0
    jne .L242_3
    lea rax, [rip+.L244]
    mov rdi, rax
    jmp .L242_4
.L242_3:
    mov rdi, rsi
.L242_4:
    mov r12, rdi
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov r13, qword ptr [rsi+6144]
    mov rsi, 0
    mov rdi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dfind
    mov r14, rax
    cmp r14, 0
    jl .L242_5
    lea rax, [rip+zyl_rtg_src_files]
    mov r15, rax
    imul rsi, r14, 24
    add r15, rsi
    mov rax, qword ptr [r15+8]
    cmp rax, 0
    jne .L242_6
    lea rax, [rip+.L245]
    mov rsi, rax
    jmp .L242_7
.L242_6:
    mov rsi, qword ptr [r15+8]
.L242_7:
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L242_8
    jmp .L242_9
.L242_8:
    mov rdi, qword ptr [r15+8]
    call zyl_rt_free
    mov rdi, r15
    mov rsi, r12
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dset_x2Dtext
.L242_9:
    mov rax, r14
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L242_5:
    cmp r13, 256
    jl .L242_10
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L242_10:
    lea rax, [rip+zyl_rtg_src_files]
    mov r14, rax
    imul rsi, r13, 24
    add r14, rsi
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    lea rdi, [r13+1]
    mov qword ptr [rsi+6144], rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov rsi, rax
    mov qword ptr [r14+0], rsi
    mov rdi, r14
    mov rsi, r12
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dset_x2Dtext
    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok:
.L246_0:
    cmp rdi, 0
    jl .L246_2
.L246_3:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rax, qword ptr [rsi+6144]
    cmp rdi, rax
    jl .L246_1
.L246_2:
    mov rax, 0
    ret
.L246_1:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    imul rdi, rdi, 24
    add rsi, rdi
    mov rax, rsi
    ret
.globl zyl_source_path
zyl_source_path:
.L247_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    jne .L247_1
    lea rax, [rip+.L248]
    mov rdi, rax
    mov rax, rdi
    ret
.L247_1:
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat:
    push rbx
    mov rbx, rsi
.L249_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L249_2
    cmp rbx, 0
    jge .L249_1
.L249_2:
    mov rax, 0
    pop rbx
    ret
.L249_1:
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    je .L249_4
    mov rax, qword ptr [rsi+16]
    cmp rbx, rax
    jle .L249_3
.L249_4:
    mov rax, 0
    pop rbx
    ret
.L249_3:
    mov rax, rsi
    pop rbx
    ret
zy_local_x2Fmain_0__source__rt_x2Dcount_x2Dlines:
    mov r8, rdx
    mov r9, rcx
.L250_0:
    cmp rsi, r8
    jl .L250_1
.L250_4:
    mov rax, r9
    ret
.p2align 4
.L250_1:
    lea r10, [rsi+1]
    lea r11, [rdi+rsi]
    movzx eax, byte ptr [r11+0]
    cmp rax, 10
    jne .L250_2
    lea r11, [r9+1]
    jmp .L250_3
.L250_2:
    mov r11, r9
.L250_3:
    mov r9, r11
    mov rsi, r10
    cmp rsi, r8
    jl .L250_1
    jmp .L250_4
.globl zyl_span_line
zyl_span_line:
    push rbx
    mov rbx, rsi
.L251_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov rsi, rax
    cmp rsi, 0
    jne .L251_1
    mov rax, 0
    pop rbx
    ret
.L251_1:
    mov rdi, qword ptr [rsi+8]
    mov rsi, 0
    mov r8, 1
    mov rdx, rbx
    mov rcx, r8
    pop rbx
    jmp zy_local_x2Fmain_0__source__rt_x2Dcount_x2Dlines
zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart:
.L252_0:
    cmp rsi, 0
    jle .L252_1
.L252_2:
    lea r8, [rsi-1]
    add r8, rdi
    movzx eax, byte ptr [r8+0]
    cmp rax, 10
    je .L252_1
    sub rsi, 1
    cmp rsi, 0
    jle .L252_1
    jmp .L252_2
.L252_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__source__rt_x2Dline_x2Dend:
    mov r8, rdx
.L253_0:
    cmp rsi, r8
    jge .L253_1
.L253_2:
    lea r9, [rdi+rsi]
    movzx eax, byte ptr [r9+0]
    cmp rax, 10
    je .L253_1
    add rsi, 1
    cmp rsi, r8
    jge .L253_1
    jmp .L253_2
.L253_1:
    mov rax, rsi
    ret
.globl zyl_span_col
zyl_span_col:
    push rbx
    mov rbx, rsi
.L254_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov rsi, rax
    cmp rsi, 0
    jne .L254_1
    mov rax, 0
    pop rbx
    ret
.L254_1:
    mov rdi, qword ptr [rsi+8]
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart
    mov rsi, rax
    mov rax, rbx
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    add rsi, 1
    mov rax, rsi
    pop rbx
    ret
zy_local_x2Fmain_0__source__rt_x2Dmcopy:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L255_0:
    lea rdi, [r12+7]
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    jne .L255_1
    lea rax, [rip+.L256]
    mov rsi, rax
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L255_1:
    cmp r13, 0
    je .L255_2
    lea rax, [rip+.L257]
    mov rsi, rax
    mov rdi, 3
    mov rdx, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, 3
    jmp .L255_3
.L255_2:
    mov rsi, 0
.L255_3:
    mov r13, rsi
    lea rdi, [r15+r13]
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rbx, [r13+r12]
    cmp r14, 0
    je .L255_4
    lea rdi, [r15+rbx]
    lea rax, [rip+.L258]
    mov rsi, rax
    mov r8, 3
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [rbx+3]
    jmp .L255_5
.L255_4:
    mov rsi, rbx
.L255_5:
    add rsi, r15
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_span_line_text
zyl_span_line_text:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rsi
.L259_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov r12, rax
    cmp r12, 0
    jne .L259_1
    lea rax, [rip+.L260]
    mov rsi, rax
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L259_1:
    mov r13, qword ptr [r12+8]
    mov rdi, r13
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart
    mov r14, rax
    lea r15, [r13+r14]
    mov rsi, qword ptr [r12+16]
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
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
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
.L261_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov r12, rax
    cmp r12, 0
    jne .L261_1
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
.L261_m3d:
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
.L261_1:
    mov r13, qword ptr [r12+8]
    mov rdi, r13
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart
    mov r14, rax
    mov rsi, qword ptr [r12+16]
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dend
    mov rsi, rax
    mov rax, rsi
    sub rax, r14
    cmp rax, 120
    jg .L261_2
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
.L261_m15d:
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
.L261_2:
    lea rax, [rbx-60]
    cmp rax, r14
    jge .L261_3
    mov rdi, r14
    jmp .L261_4
.L261_3:
    lea rdi, [rbx-60]
.L261_4:
    lea rax, [rdi+120]
    cmp rax, rsi
    jle .L261_5
    lea r8, [rsi-120]
    jmp .L261_6
.L261_5:
    mov r8, rdi
.L261_6:
    lea rax, [rdi+120]
    cmp rax, rsi
    jle .L261_7
    mov r9, rsi
    jmp .L261_8
.L261_7:
    lea r9, [rdi+120]
.L261_8:
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
.L261_m49d:
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
    push rbx
    mov rbx, rdi
.L262_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsnip
    mov rsi, rax
    mov rdi, [rsi+0]
    cmp rdi, 0
    jne .L262_1
    mov r8, [rsi+8]
    mov r9, [rsi+16]
    mov r10, [rsi+24]
    mov rsi, [rsi+32]
    lea rax, [rip+zyl_rtg_src_files]
    mov r11, rax
    imul rbx, rbx, 24
    add r11, rbx
    mov r11, qword ptr [r11+8]
    add r11, r8
    sub r9, r8
    mov rdi, r11
    mov rdx, r10
    mov rcx, rsi
    mov rsi, r9
    pop rbx
    jmp zy_local_x2Fmain_0__source__rt_x2Dmcopy
.L262_1:
    cmp rdi, 1
    jne .L262_2
    lea rax, [rip+.L263]
    mov rsi, rax
    mov rax, rsi
    pop rbx
    ret
.L262_2:
    mov rax, 0
    pop rbx
    ret
.globl zyl_span_snippet_col
zyl_span_snippet_col:
    push rbx
    mov rbx, rsi
.L264_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsnip
    mov rsi, rax
    mov rdi, [rsi+0]
    cmp rdi, 0
    jne .L264_1
    mov r8, [rsi+8]
    mov rsi, [rsi+24]
    mov rax, rbx
    mov rcx, r8
    sub rax, rcx
    mov r8, rax
    add r8, 1
    cmp rsi, 0
    je .L264_2
    mov rsi, 3
    jmp .L264_3
.L264_2:
    mov rsi, 0
.L264_3:
    lea rax, [r8+rsi]
    pop rbx
    ret
.L264_1:
    cmp rdi, 1
    jne .L264_4
    mov rax, 0
    pop rbx
    ret
.L264_4:
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__source__rt_x2Dskip_x2Dlines:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rdx
    mov r13, rcx
    mov r14, r8
.L265_0:
    cmp r12, r13
    jl .L265_1
.L265_3:
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L265_1:
    mov rdi, 10
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dfind_x2Dbyte
    mov rdi, rax
    cmp rdi, 0
    jge .L265_2
    mov rax, -1
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L265_2:
    lea rsi, [rdi+1]
    add r12, 1
    cmp r12, r13
    jl .L265_1
    jmp .L265_3
.globl zyl_span_offset_at
zyl_span_offset_at:
    push rbx
    push r12
    push r13
    mov rbx, rsi
    mov r12, rdx
.L266_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L266_2
    cmp rbx, 1
    jl .L266_3
    cmp r12, 1
    jge .L266_1
.L266_3:
.L266_2:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L266_1:
    mov rdi, qword ptr [rsi+8]
    cmp rdi, 0
    jne .L266_4
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L266_4:
    mov r13, qword ptr [rsi+16]
    mov rsi, 0
    mov r8, 1
    mov rdx, r8
    mov rcx, rbx
    mov r8, r13
    call zy_local_x2Fmain_0__source__rt_x2Dskip_x2Dlines
    mov rsi, rax
    cmp rsi, 0
    jge .L266_5
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L266_5:
    lea rdi, [r12-1]
    add rsi, rdi
    cmp rsi, r13
    jg .L266_6
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
.L266_6:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__thread__rt_x2Dfutex_x2Dwait:
    push rbp
    mov rbp, rsp
    and rsp, -16
    mov r8, rdx
.L267_0:
    mov r9, 128
    mov rdx, rsi
    mov rsi, r9
    mov rcx, r8
    call zyl_rt_sys_202
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__thread__rt_x2Dfutex_x2Dwake:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L268_0:
    mov r8, 129
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_202
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_rt_mutex_lock
zyl_rt_mutex_lock:
.L269_0:
    mov rsi, 0
    mov r8, 1
    mov rdx, rdi
    mov rcx, rsi
    mov r11, r8
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, 0
    jne .L269_1
    mov rax, 0
    ret
.L269_1:
    jmp zy_local_x2Fmain_0__thread__rt_x2Dmutex_x2Dcontend
zy_local_x2Fmain_0__thread__rt_x2Dmutex_x2Dcontend:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L270_0:
    mov rsi, 2
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L270_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L270_1:
    mov rsi, 2
    mov rdi, 0
    mov r8, 128
    mov rdx, rsi
    mov rsi, r8
    mov rcx, rdi
    mov rdi, rbx
    call zyl_rt_sys_202
    jmp .L270_0
.globl zyl_rt_mutex_unlock
zyl_rt_mutex_unlock:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L271_0:
    mov rsi, -1
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    cmp rax, 1
    jne .L271_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L271_1:
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rsi, 1
    mov r8, 129
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_202
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_rt_cond_wait
zyl_rt_cond_wait:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L272_0:
    mov r13, qword ptr [rbx+0]
    mov rsi, 4294967295
    and r13, rsi
    mov rdi, r12
    call zyl_rt_mutex_unlock
    mov rsi, 0
    mov rdi, 128
    mov rdx, r13
    mov rcx, rsi
    mov rsi, rdi
    mov rdi, rbx
    call zyl_rt_sys_202
    mov rdi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__thread__rt_x2Dmutex_x2Dcontend
.globl zyl_rt_cond_signal
zyl_rt_cond_signal:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L273_0:
    mov rsi, 1
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, 1
    mov r8, 129
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_202
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_rt_cond_broadcast
zyl_rt_cond_broadcast:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L274_0:
    mov rsi, 1
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, 2147483647
    mov r8, 129
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_202
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_rt_cond_timedwait
zyl_rt_cond_timedwait:
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
.L275_0:
    mov r14, qword ptr [rbx+0]
    mov rsi, 4294967295
    and r14, rsi
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_cond_now@tpoff]
    mov r15, rax
    mov rdi, 1
    mov rsi, r15
    call zyl_rt_sys_228
    mov rsi, qword ptr [r13+0]
    mov rdi, qword ptr [r15+0]
    sub rsi, rdi
    mov rdi, qword ptr [r13+8]
    mov r8, qword ptr [r15+8]
    sub rdi, r8
    lea r8, [rsi-1]
    cmp rdi, 0
    jl .L275_1
    mov r8, rsi
.L275_1:
    lea rsi, [rdi+1000000000]
    cmp rdi, 0
    jl .L275_2
    mov rsi, rdi
.L275_2:
    cmp r8, 0
    jge .L275_3
    mov rax, 110
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L275_3:
    lea r13, [r15+16]
    mov qword ptr [r13+0], r8
    mov qword ptr [r13+8], rsi
    mov rdi, r12
    call zyl_rt_mutex_unlock
    mov rsi, 128
    mov rdi, rbx
    mov rdx, r14
    mov rcx, r13
    call zyl_rt_sys_202
    mov rbx, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__thread__rt_x2Dmutex_x2Dcontend
    cmp rbx, -110
    jne .L275_4
    mov rax, 110
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L275_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dinfo:
.L276_0:
    lea rax, [rip+zyl_rtg_tls_info]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__thread__rt_x2Dfreestanding:
.L277_0:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_rt_hosted_p
zyl_rt_hosted_p:
.L278_0:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__thread__rt_x2Dmmap:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L279_0:
    mov rsi, 0
    mov r8, 3
    mov r9, 34
    mov r10, -1
    mov r11, 0
    mov rdx, r8
    mov rcx, r9
    mov r8, r10
    mov r9, r11
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_9
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__thread__rt_x2Dalign_x2Dup:
.L280_0:
    lea r8, [rsi-1]
    add rdi, r8
    mov r8, 0
    sub r8, rsi
    and rdi, r8
    mov rax, rdi
    ret
zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dnew:
    push rbx
    push r12
    push r13
    push r14
    push r15
.L281_0:
    lea rax, [rip+zyl_rtg_tls_info]
    mov rbx, rax
    mov rax, qword ptr [rbx+24]
    cmp rax, 64
    jge .L281_1
    mov rsi, 64
    jmp .L281_2
.L281_1:
    mov rsi, qword ptr [rbx+24]
.L281_2:
    mov r12, rsi
    mov rdi, qword ptr [rbx+16]
    mov rsi, r12
    call zy_local_x2Fmain_0__thread__rt_x2Dalign_x2Dup
    mov r13, rax
    lea rdi, [r13+64]
    add rdi, r12
    mov rsi, 4096
    call zy_local_x2Fmain_0__thread__rt_x2Dalign_x2Dup
    mov r14, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__thread__rt_x2Dmmap
    mov r15, rax
    cmp r15, 0
    jge .L281_3
    cmp r15, -4096
    jle .L281_3
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L281_3:
    lea rdi, [r15+r13]
    mov rsi, r12
    call zy_local_x2Fmain_0__thread__rt_x2Dalign_x2Dup
    mov r12, rax
    mov rdi, r12
    sub rdi, r13
    mov rsi, qword ptr [rbx+0]
    mov r8, qword ptr [rbx+8]
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov qword ptr [r12+0], r12
    mov qword ptr [r12+8], r15
    mov qword ptr [r12+16], r14
    mov rax, r12
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dfree:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L282_0:
    mov rsi, qword ptr [rdi+8]
    mov rdi, qword ptr [rdi+16]
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_11
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__thread__rt_x2Dfind_x2Dtls:
    mov r8, rdx
.L283_0:
    cmp r8, rsi
    jl .L283_1
.L283_3:
    mov rax, 0
    ret
.p2align 4
.L283_1:
    imul r9, r8, 56
    add r9, rdi
    mov eax, dword ptr [r9+0]
    cmp rax, 7
    jne .L283_2
    lea rax, [rip+zyl_rtg_tls_info]
    mov r10, rax
    mov r11, qword ptr [r9+16]
    mov qword ptr [r10+0], r11
    mov r11, qword ptr [r9+32]
    mov qword ptr [r10+8], r11
    mov r11, qword ptr [r9+40]
    mov qword ptr [r10+16], r11
    mov r9, qword ptr [r9+48]
    mov qword ptr [r10+24], r9
    mov rax, r9
    ret
.L283_2:
    add r8, 1
    cmp r8, rsi
    jl .L283_1
    jmp .L283_3
zy_local_x2Fmain_0__thread__rt_x2Dauxv:
.L284_0:
    mov r8, qword ptr [rdi+0]
    cmp r8, 0
    jne .L284_1
    mov rax, 0
    ret
.L284_1:
    cmp r8, rsi
    jne .L284_2
    mov rax, qword ptr [rdi+8]
    ret
.L284_2:
    add rdi, 16
    jmp .L284_0
zy_local_x2Fmain_0__thread__rt_x2Dskip_x2Denv:
.L285_0:
    mov rax, qword ptr [rdi+0]
    cmp rax, 0
    jne .L285_1
    lea rax, [rdi+8]
    ret
.L285_1:
    add rdi, 8
    jmp .L285_0
.globl zyl_rt_start
zyl_rt_start:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
.L286_0:
    mov rbx, qword ptr [rdi+0]
    lea r12, [rdi+8]
    lea rsi, [rbx+1]
    shl rsi, 3
    lea r13, [r12+rsi]
    mov rdi, r13
    call zy_local_x2Fmain_0__thread__rt_x2Dskip_x2Denv
    mov r14, rax
    mov rsi, 3
    mov rdi, r14
    call zy_local_x2Fmain_0__thread__rt_x2Dauxv
    mov r15, rax
    mov rsi, 5
    mov rdi, r14
    call zy_local_x2Fmain_0__thread__rt_x2Dauxv
    mov rsi, rax
    mov rdi, 0
    mov rdx, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__thread__rt_x2Dfind_x2Dtls
    call zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dnew
    mov rsi, rax
    mov rdi, 4098
    call zyl_rt_sys_158
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    mov rax, QWORD PTR [rip+main@GOTPCREL]
    mov rdi, rax
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    call zyl_rt_call3
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_exit
zy_local_x2Fmain_0__thread__rt_x2Dclone_x2Dflags:
.L287_0:
    mov rax, 4001536
    ret
zy_local_x2Fmain_0__thread__rt_x2Dstack_x2Dnew:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L288_0:
    call zy_local_x2Fmain_0__thread__rt_x2Dmmap
    mov rbx, rax
    cmp rbx, 0
    jge .L288_1
    cmp rbx, -4096
    jle .L288_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L288_1:
    mov rsi, 4096
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_10
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_rt_thread_create
zyl_rt_thread_create:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L289_0:
    mov rdi, 4096
    call zy_local_x2Fmain_0__thread__rt_x2Dmmap
    mov rdi, rax
    cmp rdi, 0
    jge .L289_1
    cmp rdi, -4096
    jle .L289_1
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L289_1:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L289_2
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    mov r8, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__thread__rt_x2Dthread_x2Dpthread
.L289_2:
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    mov r8, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__thread__rt_x2Dthread_x2Dclone
zy_local_x2Fmain_0__thread__rt_x2Dthread_x2Dclone:
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
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L290_0:
    mov rsi, 8388608
    cmp r14, 0
    je .L290_1
    mov rsi, r8
.L290_1:
    mov r15, rsi
    cmp r14, 0
    jne .L290_2
    mov rdi, r15
    call zy_local_x2Fmain_0__thread__rt_x2Dstack_x2Dnew
    mov rsi, rax
    jmp .L290_3
.L290_2:
    mov rsi, r14
.L290_3:
    mov rbx, rsi
    call zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dnew
    mov qword ptr [rbp-56], rax
    cmp rbx, 0
    je .L290_5
    cmp qword ptr [rbp-56], 0
    jne .L290_4
.L290_5:
    mov rsi, 4096
    mov rdi, qword ptr [rbp-48]
    call zyl_rt_sys_11
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L290_4:
    lea rsi, [rbx+r15]
    and rsi, -16
    lea rdi, [rsi-16]
    mov qword ptr [rdi+0], r12
    lea rdi, [rsi-8]
    mov qword ptr [rdi+0], r13
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+8], rbx
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+16], r15
    mov rdx, qword ptr [rbp-48]
    mov rcx, qword ptr [rbp-56]
    mov qword ptr [rdx+24], rcx
    mov rdi, 1
    cmp r14, 0
    je .L290_6
    mov rdi, 0
.L290_6:
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+40], rdi
    mov rdi, 4001536
    sub rsi, 16
    mov rdx, qword ptr [rbp-48]
    mov rcx, qword ptr [rbp-48]
    mov r8, qword ptr [rbp-56]
    call zyl_rt_clone
    cmp rax, 0
    jge .L290_7
    mov rdi, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dfree
    mov rsi, 4096
    mov rdi, qword ptr [rbp-48]
    call zyl_rt_sys_11
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L290_7:
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__thread__rt_x2Dthread_x2Dpthread:
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
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L291_0:
    mov rbx, qword ptr [rbp-48]
    add rbx, 64
    mov rax, QWORD PTR [rip+pthread_attr_init@GOTPCREL]
    mov rdi, rax
    mov rsi, rbx
    call zyl_rt_call1
    cmp r14, 0
    je .L291_1
    mov rax, QWORD PTR [rip+pthread_attr_setstack@GOTPCREL]
    mov rdi, rax
    mov rsi, rbx
    mov rdx, r14
    mov rcx, r15
    call zyl_rt_call3
.L291_1:
    mov rax, QWORD PTR [rip+pthread_create@GOTPCREL]
    mov rdi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 32
    mov rdx, rbx
    mov rcx, r12
    mov r8, r13
    call zyl_rt_call4
    mov r12, rax
    mov rsi, 4294967295
    and r12, rsi
    mov rax, QWORD PTR [rip+pthread_attr_destroy@GOTPCREL]
    mov rdi, rax
    mov rsi, rbx
    call zyl_rt_call1
    cmp r12, 0
    jne .L291_2
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L291_2:
    mov rsi, 4096
    mov rdi, qword ptr [rbp-48]
    call zyl_rt_sys_11
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__thread__rt_x2Dthread_x2Dfree:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L292_0:
    mov rsi, 4096
    call zyl_rt_sys_11
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__thread__rt_x2Djoin_x2Dwait:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L293_0:
    mov esi, dword ptr [rbx+0]
    cmp rsi, 0
    jne .L293_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L293_1:
    mov rdi, 0
    mov r8, 0
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, rbx
    mov rcx, r8
    call zyl_rt_sys_202
    jmp .L293_0
.globl zyl_rt_thread_join
zyl_rt_thread_join:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L294_0:
    cmp rbx, 0
    jne .L294_1
.L294_5:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L294_1:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L294_2
    mov rax, QWORD PTR [rip+pthread_join@GOTPCREL]
    mov rdi, rax
    mov rsi, qword ptr [rbx+32]
    mov r8, 0
    mov rdx, r8
    call zyl_rt_call2
    mov rsi, 4096
    mov rdi, rbx
    call zyl_rt_sys_11
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L294_2:
    mov rdi, rbx
    call zy_local_x2Fmain_0__thread__rt_x2Djoin_x2Dwait
    mov rax, qword ptr [rbx+40]
    cmp rax, 1
    jne .L294_3
    mov rdi, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+16]
    call zyl_rt_sys_11
    jmp .L294_4
.L294_3:
.L294_4:
    mov rdi, qword ptr [rbx+24]
    call zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dfree
    mov rsi, 4096
    mov rdi, rbx
    call zyl_rt_sys_11
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_rt_thread_exit
zyl_rt_thread_exit:
.L295_0:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L295_1
    mov rax, QWORD PTR [rip+pthread_exit@GOTPCREL]
    mov rdi, rax
    mov rsi, 0
    jmp zyl_rt_call1
.L295_1:
    mov rdi, 0
    jmp zyl_rt_sys_60
.globl zyl_rt_thread_detach
zyl_rt_thread_detach:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L296_0:
    cmp rdi, 0
    jle .L296_1
.L296_2:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L296_1
    mov rax, QWORD PTR [rip+pthread_detach@GOTPCREL]
    mov rsi, rax
    mov rdi, qword ptr [rdi+32]
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_call1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L296_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Ditests:
.L297_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__interp__rt_x2Ditest_x2Dn:
.L298_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    ret
.globl zyl_itest_add
zyl_itest_add:
.L299_0:
    lea rax, [rip+zyl_rtg_itests]
    mov r8, rax
    mov r8, qword ptr [r8+65536]
    cmp r8, 4096
    jl .L299_1
    mov rax, -1
    ret
.L299_1:
    lea rax, [rip+zyl_rtg_itests]
    mov r9, rax
    mov r10, r8
    shl r10, 4
    add r9, r10
    mov qword ptr [r9+0], rdi
    mov qword ptr [r9+8], rsi
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    lea rdi, [r8+1]
    mov qword ptr [rsi+65536], rdi
    mov rax, r8
    ret
.globl zyl_itest_count
zyl_itest_count:
.L300_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    ret
.globl zyl_itest_name
zyl_itest_name:
.L301_0:
    cmp rdi, 0
    jl .L301_2
.L301_3:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    cmp rdi, rax
    jl .L301_1
.L301_2:
    mov rax, 0
    ret
.L301_1:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    shl rdi, 4
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_itest_fn
zyl_itest_fn:
.L302_0:
    cmp rdi, 0
    jl .L302_2
.L302_3:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    cmp rdi, rax
    jl .L302_1
.L302_2:
    mov rax, 0
    ret
.L302_1:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    shl rdi, 4
    add rsi, rdi
    mov rax, qword ptr [rsi+8]
    ret
.globl zyl_itest_reset
zyl_itest_reset:
.L303_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+65536], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap:
.L304_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap_x2Dused:
.L305_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, qword ptr [rsi+262144]
    ret
.globl zyl_fnmap_reset
zyl_fnmap_reset:
.L306_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rdi, rax
    mov rsi, 262152
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    mov rax, 0
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap_x2Dprobe:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L307_0:
    cmp r14, 16384
    jl .L307_1
.L307_4:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L307_1:
    lea rsi, [r13+r14]
    and rsi, 16383
    shl rsi, 4
    lea r15, [rbx+rsi]
    mov rdi, qword ptr [r15+0]
    cmp rdi, 0
    je .L307_3
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L307_2
.L307_3:
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L307_2:
    add r14, 1
    cmp r14, 16384
    jl .L307_1
    jmp .L307_4
.globl zyl_fnmap_put
zyl_fnmap_put:
    push rbx
    push r12
    push r13
    mov rbx, rsi
.L308_0:
    mov r12, rdi
    cmp r12, 0
    je .L308_2
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, qword ptr [rsi+262144]
    cmp rax, 8192
    jl .L308_1
.L308_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L308_1:
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
    je .L308_4
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    je .L308_3
.L308_4:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L308_3:
    mov qword ptr [rsi+0], r12
    mov qword ptr [rsi+8], rbx
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    lea rax, [rip+zyl_rtg_fnmap]
    mov rdi, rax
    mov rdi, qword ptr [rdi+262144]
    add rdi, 1
    mov qword ptr [rsi+262144], rdi
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_fnmap_get
zyl_fnmap_get:
    push rbx
    push r12
.L309_0:
    mov rbx, rdi
    cmp rbx, 0
    je .L309_2
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, qword ptr [rsi+262144]
    cmp rax, 0
    jne .L309_1
.L309_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L309_1:
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
    je .L309_4
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L309_3
.L309_4:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L309_3:
    mov rax, qword ptr [rsi+8]
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dmagic:
.L310_0:
    mov rax, 1514885700
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
.L311_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L311_1
    mov rsi, rdi
.L311_1:
    mov r13, rsi
    cmp r13, 1048576
    jle .L311_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L311_2:
    lea rdi, [r13+3]
    shl rdi, 3
    call zyl_heap_alloc
    mov rsi, rax
    cmp rsi, 0
    jne .L311_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L311_3:
    mov qword ptr [rsi+0], r12
    mov rdi, 1514885700
    shl rdi, 32
    mov r8, 4294967295
    and r8, rbx
    or rdi, r8
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], r13
    lea rax, [rsi+24]
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
.L312_0:
    cmp rbx, 0
    jne .L312_1
.L312_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L312_1:
    lea rdi, [rbx-16]
    call zyl_heap_block_p
    cmp rax, 0
    je .L312_2
    lea rsi, [rbx-16]
    mov rsi, qword ptr [rsi+0]
    mov rax, rsi
    shr rax, 32
    cmp rax, 1514885700
    jne .L312_3
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L312_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L312_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_val_kind
zyl_val_kind:
    push rbx
    mov rbx, rsi
.L313_0:
    cmp rbx, 0
    jl .L313_2
.L313_4:
    cmp rbx, 31
    jl .L313_1
.L313_2:
    mov rax, 0
    pop rbx
    ret
.L313_1:
    call zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dword
    mov rsi, rax
    cmp rsi, 0
    jne .L313_3
    mov rax, 0
    pop rbx
    ret
.L313_3:
    lea rdi, [rbx*2]
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
    pop rbx
    ret
.globl zyl_val_name
zyl_val_name:
    push rbx
    mov rbx, rdi
.L314_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dword
    cmp rax, 0
    jne .L314_1
    mov rax, 0
    pop rbx
    ret
.L314_1:
    lea rsi, [rbx-24]
    mov rax, qword ptr [rsi+0]
    pop rbx
    ret
.globl zyl_val_arity
zyl_val_arity:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L315_0:
    cmp rbx, 0
    jne .L315_1
.L315_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L315_1:
    lea rdi, [rbx-8]
    call zyl_heap_block_p
    cmp rax, 0
    je .L315_2
    lea rsi, [rbx-8]
    mov rax, qword ptr [rsi+0]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L315_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dnames:
.L316_0:
    lea rax, [rip+zyl_rtg_names]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__interp__rt_x2Dnames_x2Dprobe:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L317_0:
    cmp r14, 4096
    jl .L317_1
.L317_4:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L317_1:
    lea rsi, [r13+r14]
    and rsi, 4095
    shl rsi, 3
    lea r15, [rbx+rsi]
    mov rdi, qword ptr [r15+0]
    cmp rdi, 0
    je .L317_3
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L317_2
.L317_3:
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L317_2:
    add r14, 1
    cmp r14, 4096
    jl .L317_1
    jmp .L317_4
.globl zyl_intern_name
zyl_intern_name:
    push rbx
    push r12
    mov rbx, rdi
.L318_0:
    lea rax, [rip+zyl_rtg_names_lock]
    mov r12, rax
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L318_1
    mov rdi, rbx
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__interp__rt_x2Dintern
.L318_1:
    mov rdi, r12
    call zyl_rt_mutex_lock
    mov rdi, rbx
    call zy_local_x2Fmain_0__interp__rt_x2Dintern
    mov rbx, rax
    mov rdi, r12
    call zyl_rt_mutex_unlock
    mov rax, rbx
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__interp__rt_x2Dintern:
    push rbx
    push r12
    push r13
    push r14
    push r15
.L319_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L319_1
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L319_1:
    lea rax, [rip+zyl_rtg_names]
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
    and rsi, 4095
    mov rdi, 0
    mov rdx, rsi
    mov rsi, rbx
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__interp__rt_x2Dnames_x2Dprobe
    mov r13, rax
    cmp r13, 0
    jne .L319_2
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L319_2:
    mov rax, qword ptr [r13+0]
    cmp rax, 0
    je .L319_3
    mov rax, qword ptr [r13+0]
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L319_3:
    mov rax, qword ptr [r12+32768]
    cmp rax, 2048
    jl .L319_4
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L319_4:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    lea rdi, [r14+1]
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    jne .L319_5
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L319_5:
    lea rsi, [r14+1]
    mov rdi, r15
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov qword ptr [r13+0], r15
    mov rsi, qword ptr [r12+32768]
    add rsi, 1
    mov qword ptr [r12+32768], rsi
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_fresh_id
zyl_fresh_id:
.L320_0:
    lea rax, [rip+zyl_rtg_fresh_id]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    add rdi, 1
    mov qword ptr [rsi+0], rdi
    mov rax, rdi
    ret
.globl zyl_cstr_of_word
zyl_cstr_of_word:
.L321_0:
    mov rax, rdi
    ret
.globl zyl_word_of_cstr
zyl_word_of_cstr:
.L322_0:
    mov rax, rdi
    ret
.globl zyl_float_bits
zyl_float_bits:
.L323_0:
    mov rax, rdi
    ret
.globl zyl_float_of_bits
zyl_float_of_bits:
.L324_0:
    mov rax, rdi
    ret
.globl zyl_word_load
zyl_word_load:
.L325_0:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_word_store
zyl_word_store:
.L326_0:
    mov qword ptr [rdi+0], rsi
    mov rax, 0
    ret
.globl zyl_ptr_add
zyl_ptr_add:
.L327_0:
    lea rax, [rdi+rsi]
    ret
.globl zyl_ptr_cstr
zyl_ptr_cstr:
.L328_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dsize:
.L329_0:
    mov rax, 2208
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dcompress:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 744
    mov qword ptr [rbp-56], rdi
    mov qword ptr [rbp-64], rsi
    mov qword ptr [rbp-80], r8
    mov r8, rdx
    mov qword ptr [rbp-48], r9
    mov r9, rcx
.L330_0:
    mov rdx, qword ptr [rbp-56]
    mov ebx, dword ptr [rdx+0]
    mov rdx, qword ptr [rbp-56]
    mov r12d, dword ptr [rdx+4]
    mov rdx, qword ptr [rbp-56]
    mov r13d, dword ptr [rdx+8]
    mov rdx, qword ptr [rbp-56]
    mov eax, dword ptr [rdx+12]
    mov qword ptr [rbp-88], rax
    mov rdx, qword ptr [rbp-56]
    mov r15d, dword ptr [rdx+16]
    mov rdx, qword ptr [rbp-56]
    mov r11d, dword ptr [rdx+20]
    mov rdx, qword ptr [rbp-56]
    mov eax, dword ptr [rdx+24]
    mov qword ptr [rbp-104], rax
    mov rdx, qword ptr [rbp-56]
    mov eax, dword ptr [rdx+28]
    mov qword ptr [rbp-72], rax
    mov rsi, 1779033703
    mov r10, 3144134277
    mov qword ptr [rbp-112], 1013904242
    mov rax, 2773480762
    mov qword ptr [rbp-96], rax
    mov rdi, 4294967295
    and rdi, r8
    shr r8, 32
    mov r14, 4294967295
    and r8, r14
    add rbx, r15
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+0]
    add rbx, r14
    xor rdi, rbx
    mov r14, rdi
    shr r14, 16
    and r14, 65535
    shl rdi, 16
    or rdi, r14
    add rsi, rdi
    mov r14, r15
    xor r14, rsi
    mov r15, r14
    shr r15, 12
    and r15, 1048575
    shl r14, 20
    or r14, r15
    add rbx, r14
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+4]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, rsi
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-144], rax
    xor r14, qword ptr [rbp-144]
    mov r15, r14
    shr r15, 7
    and r15, 33554431
    shl r14, 25
    mov rax, r15
    mov rcx, r14
    or rax, rcx
    mov qword ptr [rbp-120], rax
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+8]
    add r12, r15
    xor r8, r12
    mov r15, r8
    shr r15, 16
    and r15, 65535
    shl r8, 16
    or r8, r15
    add r10, r8
    xor r11, r10
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+12]
    add r12, r15
    xor r8, r12
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-152], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-152]
    add rax, rcx
    mov qword ptr [rbp-128], rax
    xor r11, qword ptr [rbp-128]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    add r13, qword ptr [rbp-104]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+16]
    add r13, r15
    xor r9, r13
    mov r15, r9
    shr r15, 16
    and r15, 65535
    shl r9, 16
    or r9, r15
    mov r15, qword ptr [rbp-112]
    add r15, r9
    mov r14, qword ptr [rbp-104]
    xor r14, r15
    mov r10, r14
    shr r10, 12
    and r10, 1048575
    shl r14, 20
    or r10, r14
    mov rax, r13
    mov rcx, r10
    add rax, rcx
    mov qword ptr [rbp-160], rax
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+20]
    mov rax, qword ptr [rbp-160]
    mov rcx, r14
    add rax, rcx
    mov qword ptr [rbp-160], rax
    xor r9, qword ptr [rbp-160]
    mov r14, r9
    shr r14, 8
    and r14, 16777215
    shl r9, 24
    mov rax, r14
    mov rcx, r9
    or rax, rcx
    mov qword ptr [rbp-136], rax
    mov r14, r15
    add r14, qword ptr [rbp-136]
    xor r10, r14
    mov r15, r10
    shr r15, 7
    and r15, 33554431
    shl r10, 25
    or r10, r15
    mov r15, qword ptr [rbp-88]
    add r15, qword ptr [rbp-72]
    mov rdx, qword ptr [rbp-64]
    mov r9d, dword ptr [rdx+24]
    add r15, r9
    mov r9, qword ptr [rbp-80]
    xor r9, r15
    mov rsi, r9
    shr rsi, 16
    and rsi, 65535
    shl r9, 16
    or rsi, r9
    mov r9, qword ptr [rbp-96]
    add r9, rsi
    mov r8, qword ptr [rbp-72]
    xor r8, r9
    mov r13, r8
    shr r13, 12
    and r13, 1048575
    shl r8, 20
    or r8, r13
    lea r13, [r15+r8]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+28]
    add r13, r15
    xor rsi, r13
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    or rsi, r15
    add r9, rsi
    xor r8, r9
    mov r15, r8
    shr r15, 7
    and r15, 33554431
    shl r8, 25
    or r8, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+32]
    add rbx, r15
    xor rsi, rbx
    mov r15, rsi
    shr r15, 16
    and r15, 65535
    shl rsi, 16
    or rsi, r15
    add r14, rsi
    xor r11, r14
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+36]
    add rbx, r15
    xor rsi, rbx
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-176], rax
    mov rax, r14
    mov rcx, qword ptr [rbp-176]
    add rax, rcx
    mov qword ptr [rbp-200], rax
    xor r11, qword ptr [rbp-200]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    add r12, r10
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+40]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r9, rdi
    xor r10, r9
    mov r15, r10
    shr r15, 12
    and r15, 1048575
    shl r10, 20
    or r10, r15
    add r12, r10
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+44]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r9
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-168], rax
    xor r10, qword ptr [rbp-168]
    mov r15, r10
    shr r15, 7
    and r15, 33554431
    shl r10, 25
    mov rax, r15
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-184], rax
    mov r15, qword ptr [rbp-160]
    add r15, r8
    mov rdx, qword ptr [rbp-64]
    mov r9d, dword ptr [rdx+48]
    add r15, r9
    mov r9, qword ptr [rbp-152]
    xor r9, r15
    mov rsi, r9
    shr rsi, 16
    and rsi, 65535
    shl r9, 16
    or rsi, r9
    mov r9, qword ptr [rbp-144]
    add r9, rsi
    xor r8, r9
    mov r10, r8
    shr r10, 12
    and r10, 1048575
    shl r8, 20
    or r8, r10
    mov rax, r15
    mov rcx, r8
    add rax, rcx
    mov qword ptr [rbp-208], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+52]
    mov rax, qword ptr [rbp-208]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-208], rax
    xor rsi, qword ptr [rbp-208]
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    or rsi, r15
    add r9, rsi
    xor r8, r9
    mov r15, r8
    shr r15, 7
    and r15, 33554431
    shl r8, 25
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-192], rax
    add r13, qword ptr [rbp-120]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+56]
    add r13, r15
    mov r15, qword ptr [rbp-136]
    xor r15, r13
    mov r8, r15
    shr r8, 16
    and r8, 65535
    shl r15, 16
    or r8, r15
    mov r15, qword ptr [rbp-128]
    add r15, r8
    mov r14, qword ptr [rbp-120]
    xor r14, r15
    mov r10, r14
    shr r10, 12
    and r10, 1048575
    shl r14, 20
    or r10, r14
    add r13, r10
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+60]
    add r13, r14
    xor r8, r13
    mov r14, r8
    shr r14, 8
    and r14, 16777215
    shl r8, 24
    or r8, r14
    lea r14, [r15+r8]
    xor r10, r14
    mov r15, r10
    shr r15, 7
    and r15, 33554431
    shl r10, 25
    or r10, r15
    add rbx, r10
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+8]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r9, rdi
    xor r10, r9
    mov r15, r10
    shr r15, 12
    and r15, 1048575
    shl r10, 20
    or r10, r15
    add rbx, r10
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+24]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r9
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-232], rax
    xor r10, qword ptr [rbp-232]
    mov r15, r10
    shr r15, 7
    and r15, 33554431
    shl r10, 25
    mov rax, r15
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-216], rax
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+12]
    add r12, r15
    xor rsi, r12
    mov r15, rsi
    shr r15, 16
    and r15, 65535
    shl rsi, 16
    or rsi, r15
    add r14, rsi
    xor r11, r14
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+40]
    add r12, r15
    xor rsi, r12
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-248], rax
    mov rax, r14
    mov rcx, qword ptr [rbp-248]
    add rax, rcx
    mov qword ptr [rbp-224], rax
    xor r11, qword ptr [rbp-224]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    mov r15, qword ptr [rbp-208]
    add r15, qword ptr [rbp-184]
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+28]
    add r15, r10
    xor r8, r15
    mov r10, r8
    shr r10, 16
    and r10, 65535
    shl r8, 16
    or r8, r10
    mov r10, qword ptr [rbp-200]
    add r10, r8
    mov r14, qword ptr [rbp-184]
    xor r14, r10
    mov r9, r14
    shr r9, 12
    and r9, 1048575
    shl r14, 20
    or r9, r14
    mov rax, r15
    mov rcx, r9
    add rax, rcx
    mov qword ptr [rbp-256], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+0]
    mov rax, qword ptr [rbp-256]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-256], rax
    xor r8, qword ptr [rbp-256]
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-240], rax
    add r10, qword ptr [rbp-240]
    xor r9, r10
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    or r9, r15
    add r13, qword ptr [rbp-192]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+16]
    add r13, r15
    mov r15, qword ptr [rbp-176]
    xor r15, r13
    mov r8, r15
    shr r8, 16
    and r8, 65535
    shl r15, 16
    or r8, r15
    mov r15, qword ptr [rbp-168]
    add r15, r8
    mov rsi, qword ptr [rbp-192]
    xor rsi, r15
    mov r14, rsi
    shr r14, 12
    and r14, 1048575
    shl rsi, 20
    or rsi, r14
    add r13, rsi
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+52]
    add r13, r14
    xor r8, r13
    mov r14, r8
    shr r14, 8
    and r14, 16777215
    shl r8, 24
    or r8, r14
    lea r14, [r15+r8]
    xor rsi, r14
    mov r15, rsi
    shr r15, 7
    and r15, 33554431
    shl rsi, 25
    or rsi, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+4]
    add rbx, r15
    xor r8, rbx
    mov r15, r8
    shr r15, 16
    and r15, 65535
    shl r8, 16
    or r8, r15
    add r10, r8
    xor r11, r10
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+44]
    add rbx, r15
    xor r8, rbx
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-272], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-272]
    add rax, rcx
    mov qword ptr [rbp-296], rax
    xor r11, qword ptr [rbp-296]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    add r12, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+48]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r9, r14
    mov r15, r9
    shr r15, 12
    and r15, 1048575
    shl r9, 20
    or r9, r15
    add r12, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+20]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-264], rax
    xor r9, qword ptr [rbp-264]
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    mov rax, r15
    mov rcx, r9
    or rax, rcx
    mov qword ptr [rbp-280], rax
    mov r15, qword ptr [rbp-256]
    add r15, rsi
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+36]
    add r15, r14
    mov r14, qword ptr [rbp-248]
    xor r14, r15
    mov r8, r14
    shr r8, 16
    and r8, 65535
    shl r14, 16
    or r8, r14
    mov r14, qword ptr [rbp-232]
    add r14, r8
    xor rsi, r14
    mov r9, rsi
    shr r9, 12
    and r9, 1048575
    shl rsi, 20
    or rsi, r9
    mov rax, r15
    mov rcx, rsi
    add rax, rcx
    mov qword ptr [rbp-304], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+56]
    mov rax, qword ptr [rbp-304]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-304], rax
    xor r8, qword ptr [rbp-304]
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    or r8, r15
    add r14, r8
    xor rsi, r14
    mov r15, rsi
    shr r15, 7
    and r15, 33554431
    shl rsi, 25
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-288], rax
    add r13, qword ptr [rbp-216]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+60]
    add r13, r15
    mov r15, qword ptr [rbp-240]
    xor r15, r13
    mov rsi, r15
    shr rsi, 16
    and rsi, 65535
    shl r15, 16
    or rsi, r15
    mov r15, qword ptr [rbp-224]
    add r15, rsi
    mov r10, qword ptr [rbp-216]
    xor r10, r15
    mov r9, r10
    shr r9, 12
    and r9, 1048575
    shl r10, 20
    or r9, r10
    lea r10, [r13+r9]
    mov rdx, qword ptr [rbp-64]
    mov r13d, dword ptr [rdx+32]
    add r10, r13
    xor rsi, r10
    mov r13, rsi
    shr r13, 8
    and r13, 16777215
    shl rsi, 24
    or rsi, r13
    lea r13, [r15+rsi]
    xor r9, r13
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+12]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r9, r14
    mov r15, r9
    shr r15, 12
    and r15, 1048575
    shl r9, 20
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+16]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-328], rax
    xor r9, qword ptr [rbp-328]
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    mov rax, r15
    mov rcx, r9
    or rax, rcx
    mov qword ptr [rbp-312], rax
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+40]
    add r12, r15
    xor r8, r12
    mov r15, r8
    shr r15, 16
    and r15, 65535
    shl r8, 16
    or r8, r15
    add r13, r8
    xor r11, r13
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+48]
    add r12, r15
    xor r8, r12
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-344], rax
    mov rax, r13
    mov rcx, qword ptr [rbp-344]
    add rax, rcx
    mov qword ptr [rbp-320], rax
    xor r11, qword ptr [rbp-320]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    mov r15, qword ptr [rbp-304]
    add r15, qword ptr [rbp-280]
    mov rdx, qword ptr [rbp-64]
    mov r9d, dword ptr [rdx+52]
    add r15, r9
    xor rsi, r15
    mov r9, rsi
    shr r9, 16
    and r9, 65535
    shl rsi, 16
    or rsi, r9
    mov r9, qword ptr [rbp-296]
    add r9, rsi
    mov r13, qword ptr [rbp-280]
    xor r13, r9
    mov r14, r13
    shr r14, 12
    and r14, 1048575
    shl r13, 20
    or r13, r14
    mov rax, r15
    mov rcx, r13
    add rax, rcx
    mov qword ptr [rbp-352], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+8]
    mov rax, qword ptr [rbp-352]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-352], rax
    xor rsi, qword ptr [rbp-352]
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-336], rax
    add r9, qword ptr [rbp-336]
    xor r13, r9
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    or r13, r15
    add r10, qword ptr [rbp-288]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+28]
    add r10, r15
    mov r15, qword ptr [rbp-272]
    xor r15, r10
    mov rsi, r15
    shr rsi, 16
    and rsi, 65535
    shl r15, 16
    or rsi, r15
    mov r15, qword ptr [rbp-264]
    add r15, rsi
    mov r8, qword ptr [rbp-288]
    xor r8, r15
    mov r14, r8
    shr r14, 12
    and r14, 1048575
    shl r8, 20
    or r8, r14
    add r10, r8
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+56]
    add r10, r14
    xor rsi, r10
    mov r14, rsi
    shr r14, 8
    and r14, 16777215
    shl rsi, 24
    or rsi, r14
    lea r14, [r15+rsi]
    xor r8, r14
    mov r15, r8
    shr r15, 7
    and r15, 33554431
    shl r8, 25
    or r8, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+24]
    add rbx, r15
    xor rsi, rbx
    mov r15, rsi
    shr r15, 16
    and r15, 65535
    shl rsi, 16
    or rsi, r15
    add r9, rsi
    xor r11, r9
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+20]
    add rbx, r15
    xor rsi, rbx
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-368], rax
    mov rax, r9
    mov rcx, qword ptr [rbp-368]
    add rax, rcx
    mov qword ptr [rbp-392], rax
    xor r11, qword ptr [rbp-392]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+36]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r13, r14
    mov r15, r13
    shr r15, 12
    and r15, 1048575
    shl r13, 20
    or r13, r15
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+0]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-360], rax
    xor r13, qword ptr [rbp-360]
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    mov rax, r15
    mov rcx, r13
    or rax, rcx
    mov qword ptr [rbp-376], rax
    mov r15, qword ptr [rbp-352]
    add r15, r8
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+44]
    add r15, r14
    mov r14, qword ptr [rbp-344]
    xor r14, r15
    mov rsi, r14
    shr rsi, 16
    and rsi, 65535
    shl r14, 16
    or rsi, r14
    mov r14, qword ptr [rbp-328]
    add r14, rsi
    xor r8, r14
    mov r13, r8
    shr r13, 12
    and r13, 1048575
    shl r8, 20
    or r8, r13
    mov rax, r15
    mov rcx, r8
    add rax, rcx
    mov qword ptr [rbp-400], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+60]
    mov rax, qword ptr [rbp-400]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-400], rax
    xor rsi, qword ptr [rbp-400]
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    or rsi, r15
    add r14, rsi
    xor r8, r14
    mov r15, r8
    shr r15, 7
    and r15, 33554431
    shl r8, 25
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-384], rax
    add r10, qword ptr [rbp-312]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+32]
    add r10, r15
    mov r15, qword ptr [rbp-336]
    xor r15, r10
    mov r8, r15
    shr r8, 16
    and r8, 65535
    shl r15, 16
    or r8, r15
    mov r15, qword ptr [rbp-320]
    add r15, r8
    mov r9, qword ptr [rbp-312]
    xor r9, r15
    mov r13, r9
    shr r13, 12
    and r13, 1048575
    shl r9, 20
    or r9, r13
    add r10, r9
    mov rdx, qword ptr [rbp-64]
    mov r13d, dword ptr [rdx+4]
    add r10, r13
    xor r8, r10
    mov r13, r8
    shr r13, 8
    and r13, 16777215
    shl r8, 24
    or r8, r13
    lea r13, [r15+r8]
    xor r9, r13
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+40]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r9, r14
    mov r15, r9
    shr r15, 12
    and r15, 1048575
    shl r9, 20
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+28]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-424], rax
    xor r9, qword ptr [rbp-424]
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    mov rax, r15
    mov rcx, r9
    or rax, rcx
    mov qword ptr [rbp-408], rax
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+48]
    add r12, r15
    xor rsi, r12
    mov r15, rsi
    shr r15, 16
    and r15, 65535
    shl rsi, 16
    or rsi, r15
    add r13, rsi
    xor r11, r13
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+36]
    add r12, r15
    xor rsi, r12
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-440], rax
    mov rax, r13
    mov rcx, qword ptr [rbp-440]
    add rax, rcx
    mov qword ptr [rbp-416], rax
    xor r11, qword ptr [rbp-416]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    mov r15, qword ptr [rbp-400]
    add r15, qword ptr [rbp-376]
    mov rdx, qword ptr [rbp-64]
    mov r9d, dword ptr [rdx+56]
    add r15, r9
    xor r8, r15
    mov r9, r8
    shr r9, 16
    and r9, 65535
    shl r8, 16
    or r8, r9
    mov r9, qword ptr [rbp-392]
    add r9, r8
    mov r13, qword ptr [rbp-376]
    xor r13, r9
    mov r14, r13
    shr r14, 12
    and r14, 1048575
    shl r13, 20
    or r13, r14
    mov rax, r15
    mov rcx, r13
    add rax, rcx
    mov qword ptr [rbp-448], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+12]
    mov rax, qword ptr [rbp-448]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-448], rax
    xor r8, qword ptr [rbp-448]
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-432], rax
    add r9, qword ptr [rbp-432]
    xor r13, r9
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    or r13, r15
    add r10, qword ptr [rbp-384]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+52]
    add r10, r15
    mov r15, qword ptr [rbp-368]
    xor r15, r10
    mov r8, r15
    shr r8, 16
    and r8, 65535
    shl r15, 16
    or r8, r15
    mov r15, qword ptr [rbp-360]
    add r15, r8
    mov rsi, qword ptr [rbp-384]
    xor rsi, r15
    mov r14, rsi
    shr r14, 12
    and r14, 1048575
    shl rsi, 20
    or rsi, r14
    add r10, rsi
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+60]
    add r10, r14
    xor r8, r10
    mov r14, r8
    shr r14, 8
    and r14, 16777215
    shl r8, 24
    or r8, r14
    lea r14, [r15+r8]
    xor rsi, r14
    mov r15, rsi
    shr r15, 7
    and r15, 33554431
    shl rsi, 25
    or rsi, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+16]
    add rbx, r15
    xor r8, rbx
    mov r15, r8
    shr r15, 16
    and r15, 65535
    shl r8, 16
    or r8, r15
    add r9, r8
    xor r11, r9
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+0]
    add rbx, r15
    xor r8, rbx
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-464], rax
    mov rax, r9
    mov rcx, qword ptr [rbp-464]
    add rax, rcx
    mov qword ptr [rbp-488], rax
    xor r11, qword ptr [rbp-488]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+44]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r13, r14
    mov r15, r13
    shr r15, 12
    and r15, 1048575
    shl r13, 20
    or r13, r15
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+8]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-456], rax
    xor r13, qword ptr [rbp-456]
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    mov rax, r15
    mov rcx, r13
    or rax, rcx
    mov qword ptr [rbp-472], rax
    mov r15, qword ptr [rbp-448]
    add r15, rsi
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+20]
    add r15, r14
    mov r14, qword ptr [rbp-440]
    xor r14, r15
    mov r8, r14
    shr r8, 16
    and r8, 65535
    shl r14, 16
    or r8, r14
    mov r14, qword ptr [rbp-424]
    add r14, r8
    xor rsi, r14
    mov r13, rsi
    shr r13, 12
    and r13, 1048575
    shl rsi, 20
    or rsi, r13
    mov rax, r15
    mov rcx, rsi
    add rax, rcx
    mov qword ptr [rbp-496], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+32]
    mov rax, qword ptr [rbp-496]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-496], rax
    xor r8, qword ptr [rbp-496]
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    or r8, r15
    add r14, r8
    xor rsi, r14
    mov r15, rsi
    shr r15, 7
    and r15, 33554431
    shl rsi, 25
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-480], rax
    add r10, qword ptr [rbp-408]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+4]
    add r10, r15
    mov r15, qword ptr [rbp-432]
    xor r15, r10
    mov rsi, r15
    shr rsi, 16
    and rsi, 65535
    shl r15, 16
    or rsi, r15
    mov r15, qword ptr [rbp-416]
    add r15, rsi
    mov r9, qword ptr [rbp-408]
    xor r9, r15
    mov r13, r9
    shr r13, 12
    and r13, 1048575
    shl r9, 20
    or r9, r13
    add r10, r9
    mov rdx, qword ptr [rbp-64]
    mov r13d, dword ptr [rdx+24]
    add r10, r13
    xor rsi, r10
    mov r13, rsi
    shr r13, 8
    and r13, 16777215
    shl rsi, 24
    or rsi, r13
    lea r13, [r15+rsi]
    xor r9, r13
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+48]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r9, r14
    mov r15, r9
    shr r15, 12
    and r15, 1048575
    shl r9, 20
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+52]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-520], rax
    xor r9, qword ptr [rbp-520]
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    mov rax, r15
    mov rcx, r9
    or rax, rcx
    mov qword ptr [rbp-504], rax
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+36]
    add r12, r15
    xor r8, r12
    mov r15, r8
    shr r15, 16
    and r15, 65535
    shl r8, 16
    or r8, r15
    add r13, r8
    xor r11, r13
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+44]
    add r12, r15
    xor r8, r12
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-536], rax
    mov rax, r13
    mov rcx, qword ptr [rbp-536]
    add rax, rcx
    mov qword ptr [rbp-512], rax
    xor r11, qword ptr [rbp-512]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    mov r15, qword ptr [rbp-496]
    add r15, qword ptr [rbp-472]
    mov rdx, qword ptr [rbp-64]
    mov r9d, dword ptr [rdx+60]
    add r15, r9
    xor rsi, r15
    mov r9, rsi
    shr r9, 16
    and r9, 65535
    shl rsi, 16
    or rsi, r9
    mov r9, qword ptr [rbp-488]
    add r9, rsi
    mov r13, qword ptr [rbp-472]
    xor r13, r9
    mov r14, r13
    shr r14, 12
    and r14, 1048575
    shl r13, 20
    or r13, r14
    mov rax, r15
    mov rcx, r13
    add rax, rcx
    mov qword ptr [rbp-544], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+40]
    mov rax, qword ptr [rbp-544]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-544], rax
    xor rsi, qword ptr [rbp-544]
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-528], rax
    add r9, qword ptr [rbp-528]
    xor r13, r9
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    or r13, r15
    add r10, qword ptr [rbp-480]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+56]
    add r10, r15
    mov r15, qword ptr [rbp-464]
    xor r15, r10
    mov rsi, r15
    shr rsi, 16
    and rsi, 65535
    shl r15, 16
    or rsi, r15
    mov r15, qword ptr [rbp-456]
    add r15, rsi
    mov r8, qword ptr [rbp-480]
    xor r8, r15
    mov r14, r8
    shr r14, 12
    and r14, 1048575
    shl r8, 20
    or r8, r14
    add r10, r8
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+32]
    add r10, r14
    xor rsi, r10
    mov r14, rsi
    shr r14, 8
    and r14, 16777215
    shl rsi, 24
    or rsi, r14
    lea r14, [r15+rsi]
    xor r8, r14
    mov r15, r8
    shr r15, 7
    and r15, 33554431
    shl r8, 25
    or r8, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+28]
    add rbx, r15
    xor rsi, rbx
    mov r15, rsi
    shr r15, 16
    and r15, 65535
    shl rsi, 16
    or rsi, r15
    add r9, rsi
    xor r11, r9
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+8]
    add rbx, r15
    xor rsi, rbx
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-560], rax
    mov rax, r9
    mov rcx, qword ptr [rbp-560]
    add rax, rcx
    mov qword ptr [rbp-584], rax
    xor r11, qword ptr [rbp-584]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+20]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r13, r14
    mov r15, r13
    shr r15, 12
    and r15, 1048575
    shl r13, 20
    or r13, r15
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+12]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-552], rax
    xor r13, qword ptr [rbp-552]
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    mov rax, r15
    mov rcx, r13
    or rax, rcx
    mov qword ptr [rbp-568], rax
    mov r15, qword ptr [rbp-544]
    add r15, r8
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+0]
    add r15, r14
    mov r14, qword ptr [rbp-536]
    xor r14, r15
    mov rsi, r14
    shr rsi, 16
    and rsi, 65535
    shl r14, 16
    or rsi, r14
    mov r14, qword ptr [rbp-520]
    add r14, rsi
    xor r8, r14
    mov r13, r8
    shr r13, 12
    and r13, 1048575
    shl r8, 20
    or r8, r13
    mov rax, r15
    mov rcx, r8
    add rax, rcx
    mov qword ptr [rbp-592], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+4]
    mov rax, qword ptr [rbp-592]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-592], rax
    xor rsi, qword ptr [rbp-592]
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    or rsi, r15
    add r14, rsi
    xor r8, r14
    mov r15, r8
    shr r15, 7
    and r15, 33554431
    shl r8, 25
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-576], rax
    add r10, qword ptr [rbp-504]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+24]
    add r10, r15
    mov r15, qword ptr [rbp-528]
    xor r15, r10
    mov r8, r15
    shr r8, 16
    and r8, 65535
    shl r15, 16
    or r8, r15
    mov r15, qword ptr [rbp-512]
    add r15, r8
    mov r9, qword ptr [rbp-504]
    xor r9, r15
    mov r13, r9
    shr r13, 12
    and r13, 1048575
    shl r9, 20
    or r9, r13
    add r10, r9
    mov rdx, qword ptr [rbp-64]
    mov r13d, dword ptr [rdx+16]
    add r10, r13
    xor r8, r10
    mov r13, r8
    shr r13, 8
    and r13, 16777215
    shl r8, 24
    or r8, r13
    lea r13, [r15+r8]
    xor r9, r13
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+36]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r9, r14
    mov r15, r9
    shr r15, 12
    and r15, 1048575
    shl r9, 20
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+56]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-616], rax
    xor r9, qword ptr [rbp-616]
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    mov rax, r15
    mov rcx, r9
    or rax, rcx
    mov qword ptr [rbp-600], rax
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+44]
    add r12, r15
    xor rsi, r12
    mov r15, rsi
    shr r15, 16
    and r15, 65535
    shl rsi, 16
    or rsi, r15
    add r13, rsi
    xor r11, r13
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+20]
    add r12, r15
    xor rsi, r12
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-632], rax
    mov rax, r13
    mov rcx, qword ptr [rbp-632]
    add rax, rcx
    mov qword ptr [rbp-608], rax
    xor r11, qword ptr [rbp-608]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    mov r15, qword ptr [rbp-592]
    add r15, qword ptr [rbp-568]
    mov rdx, qword ptr [rbp-64]
    mov r9d, dword ptr [rdx+32]
    add r15, r9
    xor r8, r15
    mov r9, r8
    shr r9, 16
    and r9, 65535
    shl r8, 16
    or r8, r9
    mov r9, qword ptr [rbp-584]
    add r9, r8
    mov r13, qword ptr [rbp-568]
    xor r13, r9
    mov r14, r13
    shr r14, 12
    and r14, 1048575
    shl r13, 20
    or r13, r14
    mov rax, r15
    mov rcx, r13
    add rax, rcx
    mov qword ptr [rbp-640], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+48]
    mov rax, qword ptr [rbp-640]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-640], rax
    xor r8, qword ptr [rbp-640]
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-624], rax
    add r9, qword ptr [rbp-624]
    xor r13, r9
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    or r13, r15
    add r10, qword ptr [rbp-576]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+60]
    add r10, r15
    mov r15, qword ptr [rbp-560]
    xor r15, r10
    mov r8, r15
    shr r8, 16
    and r8, 65535
    shl r15, 16
    or r8, r15
    mov r15, qword ptr [rbp-552]
    add r15, r8
    mov rsi, qword ptr [rbp-576]
    xor rsi, r15
    mov r14, rsi
    shr r14, 12
    and r14, 1048575
    shl rsi, 20
    or rsi, r14
    add r10, rsi
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+4]
    add r10, r14
    xor r8, r10
    mov r14, r8
    shr r14, 8
    and r14, 16777215
    shl r8, 24
    or r8, r14
    lea r14, [r15+r8]
    xor rsi, r14
    mov r15, rsi
    shr r15, 7
    and r15, 33554431
    shl rsi, 25
    or rsi, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+52]
    add rbx, r15
    xor r8, rbx
    mov r15, r8
    shr r15, 16
    and r15, 65535
    shl r8, 16
    or r8, r15
    add r9, r8
    xor r11, r9
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+12]
    add rbx, r15
    xor r8, rbx
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-656], rax
    mov rax, r9
    mov rcx, qword ptr [rbp-656]
    add rax, rcx
    mov qword ptr [rbp-680], rax
    xor r11, qword ptr [rbp-680]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+0]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r13, r14
    mov r15, r13
    shr r15, 12
    and r15, 1048575
    shl r13, 20
    or r13, r15
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+40]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-648], rax
    xor r13, qword ptr [rbp-648]
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    mov rax, r15
    mov rcx, r13
    or rax, rcx
    mov qword ptr [rbp-664], rax
    mov r15, qword ptr [rbp-640]
    add r15, rsi
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+8]
    add r15, r14
    mov r14, qword ptr [rbp-632]
    xor r14, r15
    mov r8, r14
    shr r8, 16
    and r8, 65535
    shl r14, 16
    or r8, r14
    mov r14, qword ptr [rbp-616]
    add r14, r8
    xor rsi, r14
    mov r13, rsi
    shr r13, 12
    and r13, 1048575
    shl rsi, 20
    or rsi, r13
    mov rax, r15
    mov rcx, rsi
    add rax, rcx
    mov qword ptr [rbp-688], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+24]
    mov rax, qword ptr [rbp-688]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-688], rax
    xor r8, qword ptr [rbp-688]
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    or r8, r15
    add r14, r8
    xor rsi, r14
    mov r15, rsi
    shr r15, 7
    and r15, 33554431
    shl rsi, 25
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-672], rax
    add r10, qword ptr [rbp-600]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+16]
    add r10, r15
    mov r15, qword ptr [rbp-624]
    xor r15, r10
    mov rsi, r15
    shr rsi, 16
    and rsi, 65535
    shl r15, 16
    or rsi, r15
    mov r15, qword ptr [rbp-608]
    add r15, rsi
    mov r9, qword ptr [rbp-600]
    xor r9, r15
    mov r13, r9
    shr r13, 12
    and r13, 1048575
    shl r9, 20
    or r9, r13
    add r10, r9
    mov rdx, qword ptr [rbp-64]
    mov r13d, dword ptr [rdx+28]
    add r10, r13
    xor rsi, r10
    mov r13, rsi
    shr r13, 8
    and r13, 16777215
    shl rsi, 24
    or rsi, r13
    lea r13, [r15+rsi]
    xor r9, r13
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+44]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r9, r14
    mov r15, r9
    shr r15, 12
    and r15, 1048575
    shl r9, 20
    or r9, r15
    add rbx, r9
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+60]
    add rbx, r15
    xor rdi, rbx
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    or rdi, r15
    mov rax, r14
    mov rcx, rdi
    add rax, rcx
    mov qword ptr [rbp-712], rax
    xor r9, qword ptr [rbp-712]
    mov r15, r9
    shr r15, 7
    and r15, 33554431
    shl r9, 25
    mov rax, r15
    mov rcx, r9
    or rax, rcx
    mov qword ptr [rbp-696], rax
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+20]
    add r12, r15
    xor r8, r12
    mov r15, r8
    shr r15, 16
    and r15, 65535
    shl r8, 16
    or r8, r15
    add r13, r8
    xor r11, r13
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add r12, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+0]
    add r12, r15
    xor r8, r12
    mov r15, r8
    shr r15, 8
    and r15, 16777215
    shl r8, 24
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-728], rax
    mov rax, r13
    mov rcx, qword ptr [rbp-728]
    add rax, rcx
    mov qword ptr [rbp-704], rax
    xor r11, qword ptr [rbp-704]
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    or r11, r15
    mov r15, qword ptr [rbp-688]
    add r15, qword ptr [rbp-664]
    mov rdx, qword ptr [rbp-64]
    mov r9d, dword ptr [rdx+4]
    add r15, r9
    xor rsi, r15
    mov r9, rsi
    shr r9, 16
    and r9, 65535
    shl rsi, 16
    or rsi, r9
    mov r9, qword ptr [rbp-680]
    add r9, rsi
    mov r13, qword ptr [rbp-664]
    xor r13, r9
    mov r14, r13
    shr r14, 12
    and r14, 1048575
    shl r13, 20
    or r13, r14
    mov rax, r15
    mov rcx, r13
    add rax, rcx
    mov qword ptr [rbp-736], rax
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+36]
    mov rax, qword ptr [rbp-736]
    mov rcx, r15
    add rax, rcx
    mov qword ptr [rbp-736], rax
    xor rsi, qword ptr [rbp-736]
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-720], rax
    add r9, qword ptr [rbp-720]
    xor r13, r9
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    or r13, r15
    add r10, qword ptr [rbp-672]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+32]
    add r10, r15
    mov r15, qword ptr [rbp-656]
    xor r15, r10
    mov rsi, r15
    shr rsi, 16
    and rsi, 65535
    shl r15, 16
    or rsi, r15
    mov r15, qword ptr [rbp-648]
    add r15, rsi
    mov r8, qword ptr [rbp-672]
    xor r8, r15
    mov r14, r8
    shr r14, 12
    and r14, 1048575
    shl r8, 20
    or r8, r14
    add r10, r8
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+24]
    add r10, r14
    xor rsi, r10
    mov r14, rsi
    shr r14, 8
    and r14, 16777215
    shl rsi, 24
    or rsi, r14
    lea r14, [r15+rsi]
    xor r8, r14
    mov r15, r8
    shr r15, 7
    and r15, 33554431
    shl r8, 25
    or r8, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+56]
    add rbx, r15
    xor rsi, rbx
    mov r15, rsi
    shr r15, 16
    and r15, 65535
    shl rsi, 16
    or rsi, r15
    add r9, rsi
    xor r11, r9
    mov r15, r11
    shr r15, 12
    and r15, 1048575
    shl r11, 20
    or r11, r15
    add rbx, r11
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+40]
    add rbx, r15
    xor rsi, rbx
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-744], rax
    add r9, qword ptr [rbp-744]
    xor r11, r9
    mov r15, r11
    shr r15, 7
    and r15, 33554431
    shl r11, 25
    mov rax, r15
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-760], rax
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+8]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 16
    and r15, 65535
    shl rdi, 16
    or rdi, r15
    add r14, rdi
    xor r13, r14
    mov r15, r13
    shr r15, 12
    and r15, 1048575
    shl r13, 20
    or r13, r15
    add r12, r13
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+48]
    add r12, r15
    xor rdi, r12
    mov r15, rdi
    shr r15, 8
    and r15, 16777215
    shl rdi, 24
    mov rax, r15
    mov rcx, rdi
    or rax, rcx
    mov qword ptr [rbp-784], rax
    add r14, qword ptr [rbp-784]
    xor r13, r14
    mov r15, r13
    shr r15, 7
    and r15, 33554431
    shl r13, 25
    mov rax, r15
    mov rcx, r13
    or rax, rcx
    mov qword ptr [rbp-752], rax
    mov r15, qword ptr [rbp-736]
    add r15, r8
    mov rdx, qword ptr [rbp-64]
    mov esi, dword ptr [rdx+12]
    add r15, rsi
    mov rsi, qword ptr [rbp-728]
    xor rsi, r15
    mov r13, rsi
    shr r13, 16
    and r13, 65535
    shl rsi, 16
    or rsi, r13
    mov r13, qword ptr [rbp-712]
    add r13, rsi
    xor r8, r13
    mov r11, r8
    shr r11, 12
    and r11, 1048575
    shl r8, 20
    or r8, r11
    lea r11, [r15+r8]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+16]
    add r11, r15
    xor rsi, r11
    mov r15, rsi
    shr r15, 8
    and r15, 16777215
    shl rsi, 24
    mov rax, r15
    mov rcx, rsi
    or rax, rcx
    mov qword ptr [rbp-776], rax
    add r13, qword ptr [rbp-776]
    xor r8, r13
    mov r15, r8
    shr r15, 7
    and r15, 33554431
    shl r8, 25
    mov rax, r15
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-768], rax
    add r10, qword ptr [rbp-696]
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+28]
    add r10, r15
    mov r15, qword ptr [rbp-720]
    xor r15, r10
    mov r8, r15
    shr r8, 16
    and r8, 65535
    shl r15, 16
    or r8, r15
    mov r15, qword ptr [rbp-704]
    add r15, r8
    mov rsi, qword ptr [rbp-696]
    xor rsi, r15
    mov rdi, rsi
    shr rdi, 12
    and rdi, 1048575
    shl rsi, 20
    or rsi, rdi
    lea rdi, [r10+rsi]
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+52]
    add rdi, r10
    xor r8, rdi
    mov r10, r8
    shr r10, 8
    and r10, 16777215
    shl r8, 24
    or r8, r10
    lea r10, [r15+r8]
    xor rsi, r10
    mov r15, rsi
    shr r15, 7
    and r15, 33554431
    shl rsi, 25
    or rsi, r15
    mov rdx, qword ptr [rbp-56]
    mov r15d, dword ptr [rdx+0]
    xor r15, r13
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+32], r15d
    mov rdx, qword ptr [rbp-56]
    mov r15d, dword ptr [rdx+4]
    xor r15, r10
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+36], r15d
    mov rdx, qword ptr [rbp-56]
    mov r15d, dword ptr [rdx+8]
    xor r15, r9
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+40], r15d
    mov rdx, qword ptr [rbp-56]
    mov r15d, dword ptr [rdx+12]
    xor r15, r14
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+44], r15d
    mov rdx, qword ptr [rbp-56]
    mov r15d, dword ptr [rdx+16]
    xor r15, qword ptr [rbp-784]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+48], r15d
    mov rdx, qword ptr [rbp-56]
    mov r15d, dword ptr [rdx+20]
    xor r15, qword ptr [rbp-776]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+52], r15d
    mov rdx, qword ptr [rbp-56]
    mov r15d, dword ptr [rdx+24]
    xor r15, r8
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+56], r15d
    mov rdx, qword ptr [rbp-56]
    mov r15d, dword ptr [rdx+28]
    xor r15, qword ptr [rbp-744]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+60], r15d
    xor rbx, r13
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+0], ebx
    xor r10, r12
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+4], r10d
    xor r9, r11
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+8], r9d
    xor rdi, r14
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+12], edi
    xor rsi, qword ptr [rbp-784]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+16], esi
    mov rsi, qword ptr [rbp-760]
    xor rsi, qword ptr [rbp-776]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+20], esi
    mov rsi, qword ptr [rbp-752]
    xor rsi, r8
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+24], esi
    mov rsi, qword ptr [rbp-768]
    xor rsi, qword ptr [rbp-744]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+28], esi
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
.L331_0:
    cmp rsi, 64
    jl .L331_1
.L331_2:
    mov rax, rdi
    ret
.p2align 4
.L331_1:
    lea r8, [rdi+rsi]
    mov r9, 0
    mov qword ptr [r8+0], r9
    add rsi, 8
    cmp rsi, 64
    jl .L331_1
    jmp .L331_2
zy_local_x2Fmain_0__blake3__b3_x2Dinit:
    push rbx
    mov rbx, rdi
.L332_0:
    mov rsi, 0
    mov qword ptr [rbx+1728], rsi
    mov rsi, 0
    mov qword ptr [rbx+1768], rsi
    mov rsi, 0
    mov qword ptr [rbx+1840], rsi
    mov rsi, 0
    mov qword ptr [rbx+1848], rsi
    lea rdi, [rbx+1776]
    mov rsi, 0
    call zy_local_x2Fmain_0__blake3__b3_x2Dzero64
    lea rsi, [rbx+2016]
    mov rdi, 1779033703
    mov dword ptr [rsi+0], edi
    mov rdi, 3144134277
    mov dword ptr [rsi+4], edi
    mov rdi, 1013904242
    mov dword ptr [rsi+8], edi
    mov rdi, 2773480762
    mov dword ptr [rsi+12], edi
    mov rdi, 1359893119
    mov dword ptr [rsi+16], edi
    mov rdi, 2600822924
    mov dword ptr [rsi+20], edi
    mov rdi, 528734635
    mov dword ptr [rsi+24], edi
    mov rdi, 1541459225
    mov dword ptr [rsi+28], edi
    lea rdi, [rbx+1736]
    mov r8, 32
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rax, rbx
    pop rbx
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag:
.L333_0:
    mov rax, qword ptr [rdi+1848]
    cmp rax, 0
    jne .L333_1
    mov rax, 1
    ret
.L333_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dpush_x2Dcv:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L334_0:
    mov r14, qword ptr [rbx+1728]
    mov rax, r13
    and rax, 1
    cmp rax, 0
    jne .L334_1
    cmp r14, 0
    jle .L334_1
    lea r15, [rbx+1920]
    lea rsi, [r14-1]
    shl rsi, 5
    add rsi, rbx
    mov rdi, 32
    mov rdx, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rdi, [r15+32]
    mov rsi, 32
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r14-1]
    mov qword ptr [rbx+1728], rsi
    lea rdi, [rbx+2016]
    mov rsi, 0
    mov r8, 64
    mov r9, 4
    lea r10, [rbx+1856]
    mov rdx, rsi
    mov rsi, r15
    mov rcx, r8
    mov r8, r9
    mov r9, r10
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    lea r12, [rbx+1856]
    shr r13, 1
    jmp .L334_0
.L334_1:
    mov rsi, r14
    shl rsi, 5
    lea rdi, [rbx+rsi]
    mov rsi, 32
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r14+1]
    mov qword ptr [rbx+1728], rsi
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dflush:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
.L335_0:
    mov r12, qword ptr [rbx+1768]
    mov rax, qword ptr [rbx+1848]
    cmp rax, 15
    jne .L335_1
    lea r13, [rbx+1736]
    lea r14, [rbx+1776]
    mov r15, 64
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag
    mov r8, rax
    or r8, 2
    lea r9, [rbx+1856]
    mov rdi, r13
    mov rsi, r14
    mov rdx, r12
    mov rcx, r15
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    lea rsi, [rbx+1856]
    lea rdi, [r12+1]
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dpush_x2Dcv
    lea rsi, [r12+1]
    mov qword ptr [rbx+1768], rsi
    lea rdi, [rbx+1736]
    lea rsi, [rbx+2016]
    mov r8, 32
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, 0
    mov qword ptr [rbx+1848], rsi
    jmp .L335_2
.L335_1:
    lea r13, [rbx+1736]
    lea r14, [rbx+1776]
    mov r15, 64
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag
    mov r8, rax
    lea r9, [rbx+1856]
    mov rdi, r13
    mov rsi, r14
    mov rdx, r12
    mov rcx, r15
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    lea rdi, [rbx+1736]
    lea rsi, [rbx+1856]
    mov r8, 32
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, qword ptr [rbx+1848]
    add rsi, 1
    mov qword ptr [rbx+1848], rsi
.L335_2:
    mov rsi, 0
    mov qword ptr [rbx+1840], rsi
    lea rdi, [rbx+1776]
    mov rsi, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dzero64
zy_local_x2Fmain_0__blake3__b3_x2Dupdate:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L336_0:
    cmp r13, 0
    jg .L336_1
.L336_6:
    mov rax, rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L336_1:
    mov rax, qword ptr [rbx+1840]
    cmp rax, 64
    jne .L336_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dflush
    jmp .L336_3
.L336_2:
.L336_3:
    mov r14, qword ptr [rbx+1840]
    mov rsi, 64
    sub rsi, r14
    cmp rsi, r13
    jle .L336_4
    mov rsi, r13
    jmp .L336_5
.L336_4:
    mov rsi, 64
    sub rsi, r14
.L336_5:
    mov r15, rsi
    lea rdi, [rbx+1776]
    add rdi, r14
    mov rsi, r12
    mov rdx, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r14+r15]
    mov qword ptr [rbx+1840], rsi
    add r12, r15
    sub r13, r15
    cmp r13, 0
    jg .L336_1
    jmp .L336_6
zy_local_x2Fmain_0__blake3__b3_x2Dfold:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
    mov rdi, rcx
    mov r13, r9
.L337_0:
    cmp r12, 0
    jne .L337_1
.L337_3:
    mov r9, 0
    mov r10, r8
    or r10, 8
    mov r11, 0
    cmp r11, r13
    jl .L337_2
    mov rax, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L337_2:
    mov rsi, r9
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r10
    mov r8, r11
    mov r9, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__blake3__b3_x2Demit
.p2align 4
.L337_1:
    lea r14, [rbx+2080]
    lea r9, [rbx+2048]
    lea r10, [rbx+1856]
    mov rdx, rsi
    mov rsi, r14
    mov rcx, rdi
    mov rdi, r9
    mov r9, r10
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    lea r9, [r12-1]
    shl r9, 5
    add r9, rbx
    mov r10, 32
    mov rdi, r14
    mov rsi, r9
    mov rdx, r10
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea r9, [r14+32]
    lea r10, [rbx+1856]
    mov r11, 32
    mov rdi, r9
    mov rsi, r10
    mov rdx, r11
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea r9, [rbx+2048]
    lea r10, [rbx+2016]
    mov r11, 32
    mov rdi, r9
    mov rsi, r10
    mov rdx, r11
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    sub r12, 1
    mov rsi, 0
    mov rdi, 64
    mov r8, 4
    cmp r12, 0
    jne .L337_1
    jmp .L337_3
zy_local_x2Fmain_0__blake3__b3_x2Demit:
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
    mov rbx, r9
.L338_0:
    cmp r15, rbx
    jl .L338_1
.L338_4:
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L338_1:
    mov rdi, qword ptr [rbp-48]
    add rdi, 2048
    mov rsi, qword ptr [rbp-48]
    add rsi, 2080
    mov r9, qword ptr [rbp-48]
    add r9, 1856
    mov rdx, qword ptr [rbp-56]
    mov rcx, r13
    mov r8, r14
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov rax, rbx
    sub rax, r15
    cmp rax, 64
    jle .L338_2
    mov rsi, 64
    jmp .L338_3
.L338_2:
    mov rsi, rbx
    sub rsi, r15
.L338_3:
    mov r12, rsi
    mov rdi, qword ptr [rbp-48]
    add rdi, 2144
    add rdi, r15
    mov rsi, qword ptr [rbp-48]
    add rsi, 1856
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rax, qword ptr [rbp-56]
    add rax, 1
    mov qword ptr [rbp-56], rax
    add r15, r12
    cmp r15, rbx
    jl .L338_1
    jmp .L338_4
zy_local_x2Fmain_0__blake3__b3_x2Dfinalize:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
.L339_0:
    lea rdi, [rbx+2048]
    lea rsi, [rbx+1736]
    mov r8, 32
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rdi, [rbx+2080]
    lea rsi, [rbx+1776]
    mov r8, 64
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov r13, qword ptr [rbx+1728]
    mov r14, qword ptr [rbx+1768]
    mov r15, qword ptr [rbx+1840]
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag
    mov r8, rax
    or r8, 2
    mov rdi, rbx
    mov rsi, r13
    mov rdx, r14
    mov rcx, r15
    mov r9, r12
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dfold
zy_local_x2Fmain_0__blake3__b3_x2Dnew:
.L340_0:
    mov rdi, 2208
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rdi, rax
    cmp rdi, 0
    jne .L340_1
    mov rax, 0
    ret
.L340_1:
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dinit
zy_local_x2Fmain_0__blake3__rt_x2Dblake3_x2Draw:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L341_0:
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r15, rax
    cmp r15, 0
    jne .L341_1
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L341_1:
    mov rdi, r15
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__blake3__b3_x2Dupdate
    mov rdi, r15
    mov rsi, r14
    call zy_local_x2Fmain_0__blake3__b3_x2Dfinalize
    lea rsi, [r15+2144]
    mov rdi, r13
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdi, r15
    call zyl_rt_free
    mov rax, 1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dhexdigits:
.L342_0:
    lea rax, [rip+.L343]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__blake3__rt_x2Dhex_x2Dbytes:
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L344_0:
    cmp r8, r9
    jl .L344_1
.L344_2:
    mov rax, rdi
    pop r12
    pop rbx
    ret
.p2align 4
.L344_1:
    lea r10, [rsi+r8]
    movzx r10d, byte ptr [r10+0]
    lea rax, [rip+.L345]
    mov r11, rax
    lea rbx, [r8*2]
    add rbx, rdi
    mov r12, r10
    shr r12, 4
    add r12, r11
    movzx r12d, byte ptr [r12+0]
    mov byte ptr [rbx+0], r12b
    lea rbx, [r8*2]
    add rbx, 1
    add rbx, rdi
    and r10, 15
    add r10, r11
    movzx r10d, byte ptr [r10+0]
    mov byte ptr [rbx+0], r10b
    add r8, 1
    cmp r8, r9
    jl .L344_1
    jmp .L344_2
zy_local_x2Fmain_0__blake3__b3_x2Dclamp:
.L346_0:
    cmp rdi, 0
    jg .L346_1
.L346_3:
    mov rax, 32
    ret
.L346_1:
    cmp rdi, 64
    jle .L346_2
    mov rax, 64
    ret
.L346_2:
    mov rax, rdi
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
.L347_0:
    mov rdi, r12
    mov rsi, r13
    call zy_local_x2Fmain_0__blake3__b3_x2Dfinalize
    lea rsi, [r13*2]
    add rsi, 1
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    lea rsi, [r12+2144]
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r13
    call zy_local_x2Fmain_0__blake3__rt_x2Dhex_x2Dbytes
    lea rsi, [r13*2]
    add rsi, rbx
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rdi, r12
    call zyl_rt_free
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_blake3_hex
zyl_blake3_hex:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov rdi, rdx
    mov r12, rcx
.L348_0:
    mov r13, rsi
    cmp r13, 0
    jne .L348_1
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L348_1:
    cmp rdi, 0
    jge .L348_2
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    jmp .L348_3
.L348_2:
    mov rsi, rdi
.L348_3:
    mov r14, rsi
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r15, rax
    cmp r15, 0
    jne .L348_4
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L348_4:
    mov rdi, r15
    mov rsi, r13
    mov rdx, r14
    call zy_local_x2Fmain_0__blake3__b3_x2Dupdate
    mov rdi, r12
    call zy_local_x2Fmain_0__blake3__b3_x2Dclamp
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
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
.L349_0:
    mov rsi, 65536
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L349_1
    cmp rsi, 0
    jle .L349_2
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__blake3__b3_x2Dupdate
.L349_2:
    jmp .L349_0
.L349_1:
    cmp rsi, -4
    jne .L349_3
    jmp .L349_0
.L349_3:
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
    mov rbx, rdi
    mov r12, rdx
.L350_0:
    cmp rsi, 0
    jne .L350_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L350_1:
    mov rdi, 0
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_2
    mov r13, rax
    cmp r13, 0
    jge .L350_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L350_2:
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r14, rax
    mov rsi, 0
    cmp r14, 0
    je .L350_3
    mov rdi, 65536
    mov r8, 1
    mov rsi, r8
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
.L350_3:
    mov r15, rsi
    cmp r15, 0
    jne .L350_4
    cmp r14, 0
    je .L350_5
    mov rdi, r14
    call zyl_rt_free
.L350_5:
    mov rdi, r13
    call zyl_rt_sys_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L350_4:
    mov rdi, r14
    mov rsi, r13
    mov rdx, r15
    call zy_local_x2Fmain_0__blake3__b3_x2Dread_x2Dall
    mov rdi, r15
    call zyl_rt_free
    mov rdi, r13
    call zyl_rt_sys_3
    mov rdi, r12
    call zy_local_x2Fmain_0__blake3__b3_x2Dclamp
    mov rsi, rax
    mov rdi, rbx
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
.L351_0:
    lea rax, [rip+.L352]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__mangle__mg_x2Dwidths:
.L353_0:
    lea rax, [rip+.L354]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__mangle__mg_x2Desc_x2Dlen:
    push rbx
    mov r8, rdx
    mov r9, rcx
.L355_0:
    cmp rsi, r8
    jl .L355_1
.L355_2:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L355_1:
    lea r10, [rsi+1]
    lea rax, [rip+.L356]
    mov r11, rax
    lea rbx, [rdi+rsi]
    movzx ebx, byte ptr [rbx+0]
    add r11, rbx
    movzx r11d, byte ptr [r11+0]
    add r9, r11
    mov rsi, r10
    cmp rsi, r8
    jl .L355_1
    jmp .L355_2
zy_local_x2Fmain_0__mangle__mg_x2Desc:
    push rbx
    push r12
    push r13
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L357_0:
    cmp rsi, r8
    jl .L357_1
.L357_4:
    mov rax, r10
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L357_1:
    lea r11, [rdi+rsi]
    movzx r11d, byte ptr [r11+0]
    lea rax, [rip+.L358]
    mov rbx, rax
    add rbx, r11
    movzx ebx, byte ptr [rbx+0]
    cmp rbx, 1
    jne .L357_2
    lea r12, [r9+r10]
    mov byte ptr [r12+0], r11b
    add rsi, 1
    add r10, 1
    cmp rsi, r8
    jl .L357_1
    jmp .L357_4
.L357_2:
    cmp rbx, 3
    jne .L357_3
    lea rbx, [r9+r10]
    mov r12, 95
    mov byte ptr [rbx+0], r12b
    lea rbx, [r10+1]
    add rbx, r9
    mov r12, 53
    mov byte ptr [rbx+0], r12b
    lea rbx, [r10+2]
    add rbx, r9
    mov r12, 70
    mov byte ptr [rbx+0], r12b
    add rsi, 1
    add r10, 3
    cmp rsi, r8
    jl .L357_1
    jmp .L357_4
.L357_3:
    lea rax, [rip+.L359]
    mov rbx, rax
    lea r12, [r9+r10]
    mov r13, 95
    mov byte ptr [r12+0], r13b
    lea r12, [r10+1]
    add r12, r9
    mov r13, 120
    mov byte ptr [r12+0], r13b
    lea r12, [r10+2]
    add r12, r9
    mov r13, r11
    shr r13, 4
    add r13, rbx
    movzx r13d, byte ptr [r13+0]
    mov byte ptr [r12+0], r13b
    lea r12, [r10+3]
    add r12, r9
    and r11, 15
    add r11, rbx
    movzx r11d, byte ptr [r11+0]
    mov byte ptr [r12+0], r11b
    add rsi, 1
    add r10, 4
    cmp rsi, r8
    jl .L357_1
    jmp .L357_4
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
.L360_0:
    mov r12, rsi
    cmp r12, 0
    jne .L360_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L360_1:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    mov rsi, 0
    mov rdi, 0
    mov rdx, r13
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__mangle__mg_x2Desc_x2Dlen
    mov r14, rax
    lea rsi, [r14+1]
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    mov rsi, 0
    mov r8, 0
    mov rdi, r12
    mov rdx, r13
    mov rcx, rbx
    call zy_local_x2Fmain_0__mangle__mg_x2Desc
    lea rsi, [rbx+r14]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__mangle__mg_x2Dsep:
    mov r8, rdx
.L361_0:
    lea rax, [rsi+1]
    cmp rax, r8
    jl .L361_1
    mov rax, -1
    ret
.L361_1:
    lea r9, [rdi+rsi]
    movzx eax, byte ptr [r9+0]
    cmp rax, 58
    jne .L361_2
    lea r9, [rsi+1]
    add r9, rdi
    movzx eax, byte ptr [r9+0]
    cmp rax, 58
    jne .L361_2
    mov rax, rsi
    ret
.L361_2:
    add rsi, 1
    jmp .L361_0
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
    jg .L362
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
    jmp .L363
.L362:
    mov rax, [rbp-96]
    mov rcx, 1
    add rax, rcx
    mov [rbp-128], rax
    sub rsp, 16
    mov rdi, [rbp-128]
    mov rsi, 1
call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    add rsp, 16
    mov [rbp-120], rax
    mov rax, [rbp-120]
    mov rcx, 0
    cmp rax, rcx
    jne .L364
    mov rax, 0
    jmp .L365
.L364:
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
    mov [rbp-136], rax
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
    je .L368
    mov rax, 0
    jmp .L369
.L368:
    mov rax, 1
.L369:
    test rax, rax
    je .L366
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-120]
call zyl_rt_free
    add rsp, 16
    mov [rbp-144], rax
    mov rax, 0
    jmp .L367
.L366:
    sub rsp, 16
    mov rdi, [rbp-8]
    mov rsi, 201
    mov r12, rsp
    and rsp, -16
call zyl_arena_alloc_zeroed
    mov rsp, r12
    add rsp, 16
    mov [rbp-152], rax
    sub rsp, 8
    sub rsp, 24
    mov rdi, [rbp-152]
    mov rsi, [rbp-120]
    mov rdx, 184
call zy_local_x2Fmain_0__base__rt_x2Dcopy
    add rsp, 32
    mov [rbp-160], rax
    mov rax, [rbp-152]
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
    mov [rbp-168], rax
    mov rax, [rbp-152]
    mov rcx, 200
    add rax, rcx
    push rax
    mov rax, 0
    mov rcx, rax
    pop rdx
    mov byte ptr [rdx], cl
    mov rax, rcx
    mov [rbp-176], rax
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-120]
call zyl_rt_free
    add rsp, 16
    mov [rbp-184], rax
    mov rax, [rbp-152]
.L367:
.L365:
.L363:
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
    jne .L370
    mov rax, 0
    jmp .L371
.L370:
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
    jge .L372
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
    lea rax, [rip+.L374]
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
    jmp .L373
.L372:
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
    jge .L375
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
    lea rax, [rip+.L377]
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
    jmp .L376
.L375:
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
    jge .L378
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
    jmp .L379
.L378:
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
.L379:
.L376:
.L373:
.L371:
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dutext:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L380_0:
    call zyl_int_text
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Doom:
.L381_0:
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
.L382_0:
    lea rax, [rip+zyl_rtg_budget]
    mov r12, rax
    lea rax, [rip+.L383]
    mov qword ptr [rbp-48], rax
    lea rax, [rip+.L384]
    mov qword ptr [rbp-64], rax
    call zyl_int_text
    mov r15, rax
    lea rax, [rip+.L385]
    mov r13, rax
    mov rdi, qword ptr [r12+16]
    call zyl_int_text
    mov rbx, rax
    lea rax, [rip+.L386]
    mov r14, rax
    mov rdi, qword ptr [r12+8]
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L387]
    mov rsi, rax
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
    mov rdi, rax
    mov rbx, 2
    mov r12, rdi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rdi, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_sys_231
zy_local_x2Fmain_0__alloc__rt_x2Dthreads:
.L388_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_threads_started_mark
zyl_threads_started_mark:
.L389_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dalign16:
.L390_0:
    lea rsi, [rdi+15]
    and rsi, -16
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dnew_x2Dblock:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L391_0:
    mov rax, qword ptr [rbx+8]
    cmp rsi, rax
    jge .L391_1
    mov rdi, qword ptr [rbx+8]
    jmp .L391_2
.L391_1:
    mov rdi, rsi
.L391_2:
    mov r12, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    je .L391_3
    jmp .L391_4
.L391_3:
    lea rax, [rip+.L392]
    mov rsi, rax
    mov rdi, r12
    call zyl_arena_oom
.L391_4:
    mov rdi, 32
    mov rsi, 0
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L391_5
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    mov rdi, 32
    lea rax, [rip+.L393]
    mov rsi, rax
    pop r13
    pop r12
    pop rbx
    jmp zyl_arena_oom
.L391_5:
    mov rsi, 0
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L391_6
    mov rdi, r13
    call zyl_rt_free
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    lea rax, [rip+.L394]
    mov rdi, rax
    mov rsi, rdi
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    jmp zyl_arena_oom
.L391_6:
    mov qword ptr [r13+0], rsi
    mov qword ptr [r13+8], r12
    mov rsi, 0
    mov qword ptr [r13+16], rsi
    mov rsi, qword ptr [rbx+0]
    mov qword ptr [r13+24], rsi
    mov qword ptr [rbx+0], r13
    mov rsi, qword ptr [rbx+16]
    add rsi, r12
    mov qword ptr [rbx+16], rsi
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_arena_create
zyl_arena_create:
    push rbx
    push r12
.L395_0:
    mov rsi, 65536
    cmp rdi, 16
    jl .L395_1
    mov rsi, rdi
.L395_1:
    mov rbx, rsi
    mov rdi, 72
    mov rsi, 0
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L395_2
    mov rax, 0
    pop r12
    pop rbx
    ret
.L395_2:
    mov rsi, 72
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dfill0
    mov qword ptr [r12+8], rbx
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dnew_x2Dblock
    mov rax, r12
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L396_0:
    cmp rbx, 0
    je .L396_2
.L396_11:
    cmp rsi, 0
    jl .L396_3
    mov rax, 281474976710656
    cmp rsi, rax
    jle .L396_1
.L396_3:
.L396_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L396_1:
    lea r12, [rsi+15]
    and r12, -16
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L396_4
    jmp .L396_5
.L396_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_lock
.L396_5:
    mov rsi, qword ptr [rbx+0]
    cmp rsi, 0
    je .L396_8
    mov rdi, qword ptr [rsi+8]
    mov r8, qword ptr [rsi+16]
    sub rdi, r8
    cmp r12, rdi
    jle .L396_6
.L396_8:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dnew_x2Dblock
    mov rdi, rax
    jmp .L396_7
.L396_6:
    mov rdi, rsi
.L396_7:
    mov r13, qword ptr [rdi+0]
    mov rsi, qword ptr [rdi+16]
    add r13, rsi
    mov rsi, qword ptr [rdi+16]
    add rsi, r12
    mov qword ptr [rdi+16], rsi
    mov rsi, qword ptr [rbx+24]
    add rsi, r12
    mov qword ptr [rbx+24], rsi
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L396_9
    jmp .L396_10
.L396_9:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L396_10:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_arena_alloc
zyl_arena_alloc:
.L397_0:
    jmp zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
.globl zyl_arena_alloc_zeroed
zyl_arena_alloc_zeroed:
    push rbx
    push r12
    mov rbx, rsi
.L398_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov r12, rax
    cmp r12, 0
    jne .L398_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L398_1:
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dfill0
    mov rax, r12
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfill0:
.L399_0:
    cmp rsi, 0
    jle .L399_1
.L399_2:
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
    ret
.L399_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfill_x2Dde:
.L400_0:
    cmp rsi, 0
    jle .L400_1
.L400_2:
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
    ret
.L400_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks:
    push rbx
    push r12
    mov rbx, rdi
.L401_0:
    cmp rbx, 0
    jne .L401_1
.L401_4:
    mov rax, 0
    pop r12
    pop rbx
    ret
.p2align 4
.L401_1:
    mov r12, qword ptr [rbx+24]
    mov rsi, qword ptr [rbx+0]
    mov rdi, qword ptr [rbx+16]
    cmp rdi, 0
    jle .L401_2
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
    jmp .L401_3
.L401_2:
.L401_3:
    mov rsi, qword ptr [rbx+8]
    lea rax, [rip+zyl_rtg_budget]
    mov rdi, rax
    add rdi, 16
    mov r8, 0
    sub r8, rsi
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rdi, qword ptr [rbx+0]
    call zyl_rt_free
    mov rdi, rbx
    call zyl_rt_free
    mov rbx, r12
    cmp rbx, 0
    jne .L401_1
    jmp .L401_4
.globl zyl_arena_reset
zyl_arena_reset:
    push rbx
    mov rbx, rdi
.L402_0:
    cmp rbx, 0
    jne .L402_1
.L402_6:
    mov rax, 0
    pop rbx
    ret
.L402_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L402_2
    jmp .L402_3
.L402_2:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_lock
.L402_3:
    mov rdi, qword ptr [rbx+0]
    call zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks
    mov rsi, 0
    mov qword ptr [rbx+0], rsi
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    mov rsi, 0
    mov qword ptr [rbx+24], rsi
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L402_4
    jmp .L402_5
.L402_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L402_5:
    mov rax, 0
    pop rbx
    ret
.globl zyl_arena_destroy
zyl_arena_destroy:
    push rbx
    mov rbx, rdi
.L403_0:
    cmp rbx, 0
    jne .L403_1
.L403_6:
    mov rax, 0
    pop rbx
    ret
.L403_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L403_2
    jmp .L403_3
.L403_2:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_lock
.L403_3:
    mov rdi, qword ptr [rbx+0]
    call zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L403_4
    jmp .L403_5
.L403_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L403_5:
    mov rdi, rbx
    call zyl_rt_free
    mov rax, 0
    pop rbx
    ret
.globl zyl_arena_used
zyl_arena_used:
    push rbx
    push r12
    mov rbx, rdi
.L404_0:
    cmp rbx, 0
    jne .L404_1
.L404_6:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L404_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L404_2
    jmp .L404_3
.L404_2:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_lock
.L404_3:
    mov r12, qword ptr [rbx+24]
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L404_4
    jmp .L404_5
.L404_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L404_5:
    mov rax, r12
    pop r12
    pop rbx
    ret
.globl zyl_arena_capacity
zyl_arena_capacity:
    push rbx
    push r12
    mov rbx, rdi
.L405_0:
    cmp rbx, 0
    jne .L405_1
.L405_6:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L405_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L405_2
    jmp .L405_3
.L405_2:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_lock
.L405_3:
    mov r12, qword ptr [rbx+16]
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L405_4
    jmp .L405_5
.L405_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L405_5:
    mov rax, r12
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__alloc__rt_x2Din_x2Dblocks:
.L406_0:
    cmp rdi, 0
    jne .L406_1
.L406_3:
    mov rax, 0
    ret
.p2align 4
.L406_1:
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jl .L406_2
    lea r8, [rsi+8]
    mov r9, qword ptr [rdi+0]
    mov r10, qword ptr [rdi+16]
    add r9, r10
    cmp r8, r9
    jg .L406_2
    mov rax, 1
    ret
.L406_2:
    mov rdi, qword ptr [rdi+24]
    cmp rdi, 0
    jne .L406_1
    jmp .L406_3
zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L407_0:
    cmp rbx, 0
    jne .L407_1
.L407_6:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L407_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L407_2
    jmp .L407_3
.L407_2:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_lock
.L407_3:
    mov rdi, qword ptr [rbx+0]
    mov rsi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Din_x2Dblocks
    mov r12, rax
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L407_4
    jmp .L407_5
.L407_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L407_5:
    mov rax, r12
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__alloc__rt_x2Darenas:
.L408_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dheap:
.L409_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dpin:
.L410_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    ret
.globl zyl_arenas_init
zyl_arenas_init:
    push rbx
.L411_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rbx, rax
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L411_1
    mov rdi, 1048576
    call zyl_arena_create
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    jmp .L411_2
.L411_1:
.L411_2:
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L411_3
    mov rdi, 262144
    call zyl_arena_create
    mov rsi, rax
    mov qword ptr [rbx+8], rsi
    jmp .L411_4
.L411_3:
.L411_4:
    mov rax, 0
    pop rbx
    ret
.globl zyl_arenas_destroy
zyl_arenas_destroy:
    push rbx
.L412_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L412_1
    jmp .L412_2
.L412_1:
    mov rdi, qword ptr [rbx+8]
    call zyl_arena_destroy
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
.L412_2:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L412_3
    jmp .L412_4
.L412_3:
    mov rdi, qword ptr [rbx+0]
    call zyl_arena_destroy
    mov rsi, 0
    mov qword ptr [rbx+0], rsi
.L412_4:
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L413_0:
    mov rdi, rsi
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L414]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, 2
    mov r12, rdi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_heap_alloc
zyl_heap_alloc:
    push rbx
    push r12
    mov rbx, rdi
.L415_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    cmp rdi, 0
    je .L415_2
    cmp rbx, 0
    jg .L415_1
.L415_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L415_1:
    mov rax, 281474976710656
    cmp rbx, rax
    jle .L415_3
    lea rax, [rip+.L416]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L415_3:
    lea rsi, [rbx+7]
    mov rcx, rsi
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov r12, rax
    lea rsi, [r12*8]
    add rsi, 8
    add rsi, 15
    and rsi, -16
    mov r8, qword ptr [rdi+0]
    lea rax, [rip+zyl_rtg_threads_started]
    mov r9, rax
    mov rax, qword ptr [r9+0]
    cmp rax, 0
    jne .L415_4
    cmp r8, 0
    jle .L415_4
    mov r9, qword ptr [r8+8]
    mov r10, qword ptr [r8+16]
    sub r9, r10
    cmp rsi, r9
    jg .L415_4
    mov r9, qword ptr [r8+0]
    mov r10, qword ptr [r8+16]
    add r9, r10
    mov r10, qword ptr [r8+16]
    add r10, rsi
    mov qword ptr [r8+16], r10
    mov r8, qword ptr [rdi+24]
    add r8, rsi
    mov qword ptr [rdi+24], r8
    mov qword ptr [r9+0], r12
    lea rax, [r9+8]
    pop r12
    pop rbx
    ret
.L415_4:
    lea rsi, [r12*8]
    add rsi, 8
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    cmp rsi, 0
    jne .L415_5
    lea rax, [rip+.L417]
    mov rdi, rax
    mov rsi, rbx
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L415_5:
    mov qword ptr [rsi+0], r12
    lea rax, [rsi+8]
    pop r12
    pop rbx
    ret
.globl zyl_heap_swap
zyl_heap_swap:
.L418_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov r8, qword ptr [rsi+0]
    cmp rdi, 0
    je .L418_1
    mov qword ptr [rsi+0], rdi
.L418_1:
    mov rax, r8
    ret
.globl zyl_session_arena
zyl_session_arena:
    push rbx
.L419_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rbx, rax
    add rbx, 16
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L419_1
    mov rdi, 1048576
    call zyl_arena_create
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    jmp .L419_2
.L419_1:
.L419_2:
    mov rax, qword ptr [rbx+0]
    pop rbx
    ret
.globl zyl_heap_block_p
zyl_heap_block_p:
    push rbx
    mov rbx, rdi
.L420_0:
    cmp rbx, 4096
    jl .L420_2
.L420_4:
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    je .L420_1
.L420_2:
    mov rax, 0
    pop rbx
    ret
.L420_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
    cmp rax, 0
    je .L420_3
    mov rax, 1
    pop rbx
    ret
.L420_3:
    call zyl_session_arena
    mov rdi, rax
    mov rsi, rbx
    pop rbx
    jmp zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
.globl zyl_pin_owns
zyl_pin_owns:
.L421_0:
    cmp rdi, 0
    je .L421_2
.L421_3:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jne .L421_1
.L421_2:
    mov rax, 0
    ret
.L421_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rsi, qword ptr [rsi+8]
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
.globl zyl_pin_word
zyl_pin_word:
    push rbx
    mov rbx, rdi
.L422_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jne .L422_1
    mov rax, 0
    pop rbx
    ret
.L422_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+8]
    mov rsi, 8
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    cmp rsi, 0
    je .L422_2
    mov qword ptr [rsi+0], rbx
.L422_2:
    mov rax, rsi
    pop rbx
    ret
.globl zyl_mlock
zyl_mlock:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L423_0:
    cmp rdi, 0
    je .L423_2
.L423_4:
    cmp rsi, 0
    jg .L423_1
.L423_2:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L423_1:
    mov r8, rdi
    and r8, -4096
    sub rdi, r8
    add rdi, rsi
    mov rsi, rdi
    mov rdi, r8
    call zyl_rt_sys_149
    cmp rax, 0
    jne .L423_3
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L423_3:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_pin_alloc
zyl_pin_alloc:
    push rbx
    push r12
    mov rbx, rdi
.L424_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    je .L424_2
    cmp rbx, 0
    jg .L424_1
.L424_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L424_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+8]
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov r12, rax
    cmp r12, 0
    je .L424_3
    mov rdi, r12
    mov rsi, rbx
    call zyl_mlock
.L424_3:
    mov rax, r12
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dclass_x2Dsize:
.L425_0:
    cmp rdi, 0
    jne .L425_1
.L425_4:
    mov rax, 1024
    ret
.L425_1:
    cmp rdi, 1
    jne .L425_2
    mov rax, 4096
    ret
.L425_2:
    cmp rdi, 2
    jne .L425_3
    mov rax, 16384
    ret
.L425_3:
    mov rax, 65536
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drpool:
.L426_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dlive:
.L427_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drmap:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L428_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    je .L428_1
    jmp .L428_2
.L428_1:
    lea rax, [rip+.L429]
    mov rsi, rax
    mov rdi, rbx
    call zyl_arena_oom
.L428_2:
    mov rdi, 0
    mov rsi, 3
    mov r8, 34
    mov r9, -1
    mov r10, 0
    mov rdx, rsi
    mov rsi, rbx
    mov rcx, r8
    mov r8, r9
    mov r9, r10
    call zyl_rt_sys_9
    mov rsi, rax
    cmp rsi, 0
    jge .L428_3
    cmp rsi, -4096
    jle .L428_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    lea rax, [rip+.L430]
    mov rdi, rax
    mov rsi, rdi
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_arena_oom
.L428_3:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit:
    mov r8, rdx
    mov r9, rcx
.L431_0:
    mov r10, 0
    mov qword ptr [rdi+0], r10
    mov qword ptr [rdi+8], rsi
    mov dword ptr [rdi+16], r8d
    mov rsi, 4294967295
    and rsi, r9
    mov dword ptr [rdi+20], esi
    mov rax, rdi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dcarve:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L432_0:
    lea rax, [r14+r13]
    cmp rax, 1048576
    jle .L432_1
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L432_1:
    lea rdi, [r12+r14]
    mov rsi, 0
    mov rdx, rsi
    mov rsi, r13
    mov rcx, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit
    mov rsi, rax
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rdi, rax
    lea r8, [rbx*8]
    add rdi, r8
    mov r8, qword ptr [rdi+0]
    mov qword ptr [rsi+0], r8
    mov qword ptr [rdi+0], rsi
    add r14, r13
    jmp .L432_0
zy_local_x2Fmain_0__alloc__rt_x2Dpick_x2Dclass:
.L433_0:
    cmp rsi, 4
    jge .L433_1
.L433_5:
    lea r8, [rdi+24]
    mov r9, 1024
    cmp rsi, 0
    je .L433_2
    mov r10, 4096
    cmp rsi, 1
    je .L433_3
    mov r11, 16384
    cmp rsi, 2
    je .L433_4
    mov r11, 65536
.L433_4:
    mov r10, r11
.L433_3:
    mov r9, r10
.L433_2:
    cmp r8, r9
    jle .L433_1
    add rsi, 1
    cmp rsi, 4
    jge .L433_1
    jmp .L433_5
.L433_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dget:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L434_0:
    mov rdi, rsi
    cmp rsi, 4
    jl .L434_1
    mov rdi, 3
.L434_1:
    mov rsi, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dpick_x2Dclass
    mov r12, rax
    cmp r12, 4
    jl .L434_2
    lea rsi, [rbx+24]
    add rsi, 4095
    mov rbx, rsi
    and rbx, -4096
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Drmap
    mov rdi, rax
    mov rsi, 1
    mov r8, -1
    mov rdx, rsi
    mov rsi, rbx
    mov rcx, r8
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit
.L434_2:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rbx, rax
    lea rsi, [r12*8]
    add rbx, rsi
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L434_3
    mov rdi, 1048576
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
    jmp .L434_4
.L434_3:
.L434_4:
    mov rsi, qword ptr [rbx+0]
    mov rdi, qword ptr [rsi+0]
    mov qword ptr [rbx+0], rdi
    mov rdi, 0
    mov qword ptr [rsi+0], rdi
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dcount_x2Dblocks:
.L435_0:
    cmp rdi, 0
    je .L435_2
.L435_3:
    cmp rsi, 4
    jl .L435_1
.L435_2:
    mov rax, rsi
    ret
.L435_1:
    mov rdi, qword ptr [rdi+0]
    add rsi, 1
    cmp rdi, 0
    je .L435_2
    jmp .L435_3
zy_local_x2Fmain_0__alloc__rt_x2Dpush_x2Dblock:
.L436_0:
    mov r8, qword ptr [rdi+24]
    and r8, -2
    mov qword ptr [rsi+0], r8
    mov r8, qword ptr [rdi+24]
    and r8, 1
    or r8, rsi
    mov qword ptr [rdi+24], r8
    lea rax, [rip+zyl_rtg_region_live]
    mov r8, rax
    mov r9, qword ptr [rsi+8]
    mov rdx, r8
    mov rcx, r9
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    lea r8, [rsi+24]
    mov qword ptr [rdi+8], r8
    mov r8, qword ptr [rsi+8]
    add rsi, r8
    mov qword ptr [rdi+16], rsi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dexhausted:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L437_0:
    mov rsi, qword ptr [rdi+0]
    lea rax, [rip+.L438]
    mov rbx, rax
    cmp rsi, 2
    jne .L437_1
    lea rax, [rip+.L439]
    mov r12, rax
    jmp .L437_2
.L437_1:
    lea rax, [rip+.L440]
    mov r12, rax
.L437_2:
    lea rax, [rip+.L441]
    mov r13, rax
    cmp rsi, 2
    jne .L437_3
    mov rsi, qword ptr [rdi+8]
    jmp .L437_4
.L437_3:
    mov rsi, qword ptr [rdi+24]
.L437_4:
    mov rdi, rsi
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L442]
    mov rsi, rax
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
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dpolicy_x2Dalloc:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L443_0:
    lea rdi, [rbx+32]
    mov rsi, qword ptr [rdi+16]
    lea r8, [r12+7]
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov r8, rax
    shl r8, 3
    mov r9, qword ptr [rbx+8]
    lea r10, [r9+8]
    add r10, rsi
    sub r10, 1
    mov r11, 0
    sub r11, rsi
    and r10, r11
    lea r11, [r10+r8]
    cmp r9, 0
    jle .L443_1
    mov rax, qword ptr [rbx+16]
    cmp r11, rax
    jg .L443_1
    mov r14, qword ptr [rdi+32]
    mov rax, r11
    mov rcx, r9
    sub rax, rcx
    mov r9, rax
    add r14, r9
    mov rax, qword ptr [rdi+24]
    cmp rax, 0
    jle .L443_2
    mov rax, qword ptr [rdi+24]
    cmp r14, rax
    jle .L443_2
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dexhausted
.L443_2:
    mov qword ptr [rdi+32], r14
    mov qword ptr [rbx+8], r11
    lea r9, [r10-8]
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov r11, rax
    mov qword ptr [r9+0], r11
    mov rax, r10
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L443_1:
    cmp r13, 1
    jge .L443_4
    mov rax, qword ptr [rdi+0]
    cmp rax, 2
    jne .L443_3
    mov r9, qword ptr [rbx+24]
    and r9, -2
    cmp r9, 0
    jle .L443_3
.L443_4:
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dexhausted
.L443_3:
    add r8, 8
    add r8, rsi
    add r8, 24
    mov rax, qword ptr [rdi+0]
    cmp rax, 2
    jne .L443_5
    mov r9, qword ptr [rdi+8]
    add r9, 8
    add rsi, r9
    add rsi, 24
    jmp .L443_6
.L443_5:
    mov rax, qword ptr [rdi+8]
    cmp rax, r8
    jge .L443_7
    jmp .L443_8
.L443_7:
    mov r8, qword ptr [rdi+8]
.L443_8:
    mov rsi, r8
.L443_6:
    add rsi, 4095
    mov r14, rsi
    and r14, -4096
    mov rdi, r14
    call zy_local_x2Fmain_0__alloc__rt_x2Drmap
    mov rdi, rax
    mov rsi, 1
    mov r8, 0
    mov rdx, rsi
    mov rsi, r14
    mov rcx, r8
    call zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dpush_x2Dblock
    add r13, 1
    jmp .L443_0
.globl zyl_ralloc
zyl_ralloc:
.L444_0:
    cmp rsi, 0
    jne .L444_1
.L444_5:
    jmp zyl_heap_alloc
.L444_1:
    cmp rdi, 0
    jle .L444_3
    cmp rdi, 65536
    jle .L444_2
.L444_3:
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dralloc_x2Din
.L444_2:
    mov r8, qword ptr [rsi+8]
    lea r9, [rdi+7]
    and r9, -8
    add r9, 8
    cmp r8, 0
    jle .L444_4
    mov r10, qword ptr [rsi+24]
    and r10, 1
    cmp r10, 1
    je .L444_4
    lea r10, [r8+r9]
    mov rax, qword ptr [rsi+16]
    cmp r10, rax
    jg .L444_4
    add r9, r8
    mov qword ptr [rsi+8], r9
    lea r9, [rdi+7]
    shr r9, 3
    mov qword ptr [r8+0], r9
    lea rax, [r8+8]
    ret
.L444_4:
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dralloc_x2Din
zy_local_x2Fmain_0__alloc__rt_x2Dralloc_x2Din:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L445_0:
    cmp rbx, 0
    jg .L445_1
.L445_7:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L445_1:
    mov rsi, qword ptr [r12+24]
    and rsi, 1
    cmp rsi, 1
    jne .L445_2
    mov rsi, 0
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dpolicy_x2Dalloc
.L445_2:
    mov rax, 281474976710656
    cmp rbx, rax
    jle .L445_3
    lea rax, [rip+.L446]
    mov rdi, rax
    mov rsi, rbx
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L445_3:
    lea rsi, [rbx+7]
    mov rcx, rsi
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov rsi, rax
    shl rsi, 3
    lea r13, [rsi+8]
    mov rax, qword ptr [r12+8]
    cmp rax, 0
    je .L445_6
    mov rsi, qword ptr [r12+16]
    mov rdi, qword ptr [r12+8]
    sub rsi, rdi
    cmp rsi, r13
    jge .L445_4
.L445_6:
    mov rdi, qword ptr [r12+24]
    and rdi, -2
    mov rsi, 0
    call zy_local_x2Fmain_0__alloc__rt_x2Dcount_x2Dblocks
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dget
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dpush_x2Dblock
    jmp .L445_5
.L445_4:
.L445_5:
    mov rsi, qword ptr [r12+8]
    lea rdi, [rsi+r13]
    mov qword ptr [r12+8], rdi
    lea rdi, [rbx+7]
    mov rcx, rdi
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov rdi, rax
    mov qword ptr [rsi+0], rdi
    lea rax, [rsi+8]
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dblock:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L447_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov r8, 0
    mov r9, qword ptr [rdi+8]
    sub r8, r9
    mov rdx, rsi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov eax, dword ptr [rdi+16]
    cmp rax, 1
    jne .L447_1
    mov rbx, qword ptr [rdi+8]
    mov rsi, rbx
    call zyl_rt_sys_11
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__heap__rt_x2Drefund
.L447_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rsi, rax
    mov r8d, dword ptr [rdi+20]
    shl r8, 3
    add rsi, r8
    mov r8, qword ptr [rsi+0]
    mov qword ptr [rdi+0], r8
    mov qword ptr [rsi+0], rdi
    mov rsi, rdi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dchain:
    push rbx
    push r12
    mov rbx, rsi
.L448_0:
    cmp rdi, 0
    je .L448_2
.L448_3:
    cmp rdi, rbx
    jne .L448_1
.L448_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L448_1:
    mov r12, qword ptr [rdi+0]
    call zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dblock
    mov rdi, r12
    cmp rdi, 0
    je .L448_2
    jmp .L448_3
zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks:
    push rbx
    mov rbx, rdi
.L449_0:
    mov rdi, qword ptr [rbx+24]
    and rdi, -2
    mov rsi, 0
    call zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dchain
    mov rsi, qword ptr [rbx+24]
    and rsi, 1
    or rsi, 0
    mov qword ptr [rbx+24], rsi
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    mov rax, rsi
    pop rbx
    ret
.globl zyl_region_enter
zyl_region_enter:
.L450_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rsi, rax
    mov qword ptr [rdi+0], rsi
    mov rsi, 0
    mov qword ptr [rdi+8], rsi
    mov rsi, 0
    mov qword ptr [rdi+16], rsi
    mov rsi, 0
    mov qword ptr [rdi+24], rsi
    mov rax, rdi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    mov rax, 0
    ret
.globl zyl_region_scope_enter
zyl_region_scope_enter:
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L451_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov r11, rax
    mov qword ptr [rdi+0], r11
    mov r11, 0
    mov qword ptr [rdi+8], r11
    mov r11, 0
    mov qword ptr [rdi+16], r11
    mov r11, 1
    mov qword ptr [rdi+24], r11
    mov qword ptr [rdi+32], rsi
    mov qword ptr [rdi+40], r8
    mov rsi, 8
    cmp r9, 8
    jl .L451_1
    mov rsi, r9
.L451_1:
    mov qword ptr [rdi+48], rsi
    mov qword ptr [rdi+56], r10
    mov rsi, 0
    mov qword ptr [rdi+64], rsi
    mov rax, rdi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    mov rax, 0
    ret
.globl zyl_region_free
zyl_region_free:
.L452_0:
    mov rsi, qword ptr [rdi+24]
    and rsi, -2
    cmp rsi, 0
    jle .L452_1
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    jmp .L452_2
.L452_1:
.L452_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dlast_x2Dblock:
.L453_0:
    mov rax, qword ptr [rdi+0]
    cmp rax, 0
    jne .L453_1
    mov rax, rdi
    ret
.L453_1:
    mov rdi, qword ptr [rdi+0]
    jmp .L453_0
.globl zyl_region_recycle
zyl_region_recycle:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L454_0:
    mov r12, qword ptr [rbx+24]
    and r12, -2
    cmp r12, 0
    jne .L454_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L454_1:
    mov rax, qword ptr [r12+0]
    cmp rax, 0
    jne .L454_2
    mov eax, dword ptr [r12+16]
    cmp rax, 0
    jne .L454_2
    lea rsi, [r12+24]
    mov qword ptr [rbx+8], rsi
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L454_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dlast_x2Dblock
    mov r13, rax
    mov eax, dword ptr [r13+16]
    cmp rax, 1
    jne .L454_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L454_3:
    mov rdi, r12
    mov rsi, r13
    call zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dchain
    mov rsi, qword ptr [rbx+24]
    and rsi, 1
    or rsi, r13
    mov qword ptr [rbx+24], rsi
    lea rsi, [r13+24]
    mov qword ptr [rbx+8], rsi
    mov rsi, qword ptr [r13+8]
    add rsi, r13
    mov qword ptr [rbx+16], rsi
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_region_exit
zyl_region_exit:
    push rbx
    mov rbx, rdi
.L455_0:
    mov rsi, qword ptr [rbx+24]
    and rsi, -2
    cmp rsi, 0
    jle .L455_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    jmp .L455_2
.L455_1:
.L455_2:
    mov rsi, qword ptr [rbx+0]
    mov rax, rsi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    cmp rsi, rbx
    jne .L455_3
    mov rsi, 0
    mov rax, rsi
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    jmp .L455_4
.L455_3:
.L455_4:
    mov rax, 0
    pop rbx
    ret
.globl zyl_region_unwind
zyl_region_unwind:
    push rbx
    push r12
    mov rbx, rdi
.L456_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov r12, rax
    cmp r12, 0
    je .L456_2
    cmp r12, rbx
    jne .L456_1
.L456_2:
    mov rsi, 0
    mov rax, rsi
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    mov rax, 0
    pop r12
    pop rbx
    ret
.L456_1:
    mov rsi, qword ptr [r12+24]
    and rsi, -2
    cmp rsi, 0
    jle .L456_3
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    jmp .L456_4
.L456_3:
.L456_4:
    mov rsi, qword ptr [r12+0]
    mov rax, rsi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    jmp .L456_0
.globl zyl_region_mark
zyl_region_mark:
.L457_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_region_live_bytes
zyl_region_live_bytes:
.L458_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dtls:
.L459_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_cur_region@tpoff]
    mov rsi, rax
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_region_top@tpoff]
    mov rdi, rax
    add rsi, rdi
    mov rax, rsi
    ret
.globl zyl_ffi_pin
zyl_ffi_pin:
.L460_0:
    jmp zyl_pin_word
.globl zyl_ffi_unpin
zyl_ffi_unpin:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L461_0:
    cmp rbx, 0
    jne .L461_1
.L461_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L461_1:
    mov rdi, rbx
    call zyl_pin_owns
    cmp rax, 0
    je .L461_2
    mov rax, qword ptr [rbx+0]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L461_2:
    lea rax, [rip+.L462]
    mov rdi, rax
    mov rbx, 2
    mov r12, rdi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dzalloc:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L463_0:
    call zyl_arena_alloc_zeroed
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
.L464_0:
    lea rax, [rip+.L465]
    mov qword ptr [rbp-48], rax
    lea rax, [rip+.L466]
    mov r14, rax
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r15, rax
    lea rax, [rip+.L467]
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
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dmagic:
.L468_0:
    mov rax, 6510318674217419859
    ret
zy_local_x2Fmain_0__tables__tb_x2Dnot_x2Dwords:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L469_0:
    lea rax, [rip+.L470]
    mov rbx, rax
    lea rax, [rip+.L471]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_panic
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
.L472_0:
    cmp rbx, 4096
    jl .L472_1
.L472_2:
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    jne .L472_1
    mov rdi, qword ptr [rbx+0]
    mov rax, 6510318674217419859
    cmp rdi, rax
    jne .L472_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L472_1:
    lea rax, [rip+.L473]
    mov r12, rax
    lea rax, [rip+.L474]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_panic
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
.L475_0:
    mov rsi, 24
    call zyl_arena_alloc_zeroed
    mov r13, rax
    cmp r13, 0
    jne .L475_1
    lea rax, [rip+.L476]
    mov rdi, rax
    call zyl_panic
    jmp .L475_2
.L475_1:
.L475_2:
    mov rsi, 6510318674217419859
    mov qword ptr [r13+0], rsi
    mov qword ptr [r13+8], rbx
    mov qword ptr [r13+16], r12
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
.L477_0:
    mov rdi, 0
    cmp rsi, 0
    jl .L477_1
    mov rdi, rsi
.L477_1:
    mov r12, rdi
    mov rsi, 24
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov r13, rax
    mov rsi, r12
    cmp r12, 0
    jg .L477_2
    mov rsi, 1
.L477_2:
    shl rsi, 3
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    cmp r13, 0
    je .L477_5
    cmp rbx, 0
    jne .L477_3
.L477_5:
    lea rax, [rip+.L478]
    mov rdi, rax
    call zyl_panic
    jmp .L477_4
.L477_3:
.L477_4:
    mov rsi, 6510318674217419859
    mov qword ptr [r13+0], rsi
    mov qword ptr [r13+8], r12
    mov qword ptr [r13+16], rbx
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Drzalloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L479_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rdi, rbx
    call zyl_ralloc
    mov r12, rax
    cmp r12, 0
    je .L479_1
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dfill0
.L479_1:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_words_alloc
zyl_words_alloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L480_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L480_1
    mov rsi, rdi
.L480_1:
    mov rbx, rsi
    mov rdi, 24
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r12, rax
    mov rsi, rbx
    cmp rbx, 0
    jg .L480_2
    mov rsi, 1
.L480_2:
    lea rdi, [rsi*8]
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r13, rax
    cmp r12, 0
    je .L480_5
    cmp r13, 0
    jne .L480_3
.L480_5:
    lea rax, [rip+.L481]
    mov rdi, rax
    call zyl_panic
    jmp .L480_4
.L480_3:
.L480_4:
    mov rsi, 6510318674217419859
    mov qword ptr [r12+0], rsi
    mov qword ptr [r12+8], rbx
    mov qword ptr [r12+16], r13
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_words_alloc_r
zyl_words_alloc_r:
.L482_0:
    jmp zyl_words_alloc
.globl zyl_words_len
zyl_words_len:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L483_0:
    cmp rdi, 4096
    jl .L483_1
.L483_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L483_1
    mov rsi, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp rsi, rax
    jne .L483_1
    mov rax, qword ptr [rdi+8]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L483_1:
    lea rax, [rip+.L484]
    mov rdi, rax
    lea rax, [rip+.L485]
    mov rbx, rax
    lea rax, [rip+.L486]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
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
.L487_0:
    cmp rdi, 4096
    jl .L487_1
.L487_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L487_1
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp r9, rax
    jne .L487_1
    mov rdi, qword ptr [rdi+8]
    mov rdx, rdi
    mov rdi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L487_1:
    lea rax, [rip+.L488]
    mov rbx, rax
    lea rax, [rip+.L489]
    mov rsi, rax
    mov rdi, r8
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_words_get
zyl_words_get:
.L490_0:
    cmp rdi, 4096
    jl .L490_1
.L490_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L490_1
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp r8, rax
    jne .L490_1
    cmp rsi, 0
    jl .L490_1
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jge .L490_1
    mov r8, qword ptr [rdi+16]
    lea r9, [rsi*8]
    add r8, r9
    mov rax, qword ptr [r8+0]
    ret
.L490_1:
    lea rax, [rip+.L491]
    mov r8, rax
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dfail
.globl zyl_words_set
zyl_words_set:
    mov r8, rdx
.L492_0:
    cmp rdi, 4096
    jl .L492_1
.L492_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L492_1
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp r9, rax
    jne .L492_1
    cmp rsi, 0
    jl .L492_1
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jge .L492_1
    mov r9, qword ptr [rdi+16]
    lea r10, [rsi*8]
    add r9, r10
    mov qword ptr [r9+0], r8
    mov rax, r8
    ret
.L492_1:
    lea rax, [rip+.L493]
    mov r8, rax
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dfail
.globl zyl_words_view
zyl_words_view:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rdx
    mov r13, rcx
.L494_0:
    lea rax, [rip+.L495]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov r14, rax
    mov rsi, qword ptr [r14+8]
    cmp r12, 0
    jl .L494_3
    cmp r13, 0
    jl .L494_3
    cmp r12, rsi
    jg .L494_4
    mov rax, rsi
    sub rax, r12
    cmp r13, rax
    jle .L494_1
.L494_4:
.L494_3:
    lea rax, [rip+.L496]
    mov rdi, rax
    lea r8, [r12+r13]
    mov rdx, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L494_2
.L494_1:
.L494_2:
    mov rsi, qword ptr [r14+16]
    lea rdi, [r12*8]
    add rsi, rdi
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dhdr
zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dmagic:
.L497_0:
    mov rax, 6510318579778470233
    ret
zy_local_x2Fmain_0__tables__tb_x2Dnot_x2Darray:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L498_0:
    lea rax, [rip+.L499]
    mov rbx, rax
    lea rax, [rip+.L500]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_panic
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
.L501_0:
    cmp rbx, 4096
    jl .L501_1
.L501_2:
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    jne .L501_1
    mov rdi, qword ptr [rbx+0]
    mov rax, 6510318579778470233
    cmp rdi, rax
    jne .L501_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L501_1:
    lea rax, [rip+.L502]
    mov r12, rax
    lea rax, [rip+.L503]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_panic
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
.L504_0:
    mov rdi, 0
    cmp rsi, 0
    jl .L504_1
    mov rdi, rsi
.L504_1:
    mov r12, rdi
    mov rsi, 32
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov r13, rax
    mov rsi, r12
    cmp r12, 0
    jg .L504_2
    mov rsi, 1
.L504_2:
    shl rsi, 3
    mov rdi, rbx
    call zyl_arena_alloc
    mov rbx, rax
    cmp r13, 0
    je .L504_5
    cmp rbx, 0
    jne .L504_3
.L504_5:
    lea rax, [rip+.L505]
    mov rdi, rax
    call zyl_panic
    jmp .L504_4
.L504_3:
.L504_4:
    mov rsi, 6510318579778470233
    mov qword ptr [r13+0], rsi
    mov qword ptr [r13+8], r12
    mov rsi, 0
    mov qword ptr [r13+16], rsi
    mov qword ptr [r13+24], rbx
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
.L506_0:
    cmp rdi, 4096
    jl .L506_1
.L506_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L506_1
    mov rsi, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp rsi, rax
    jne .L506_1
    mov rax, qword ptr [rdi+8]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L506_1:
    lea rax, [rip+.L507]
    mov rdi, rax
    lea rax, [rip+.L508]
    mov rbx, rax
    lea rax, [rip+.L509]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
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
.L510_0:
    cmp rdi, 4096
    jl .L510_1
.L510_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L510_1
    mov rsi, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp rsi, rax
    jne .L510_1
    mov rax, qword ptr [rdi+16]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L510_1:
    lea rax, [rip+.L511]
    mov rdi, rax
    lea rax, [rip+.L512]
    mov rbx, rax
    lea rax, [rip+.L513]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.globl zyl_vec_alloc
zyl_vec_alloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L514_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L514_1
    mov rsi, rdi
.L514_1:
    mov rbx, rsi
    mov rdi, 32
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r12, rax
    mov rsi, rbx
    cmp rbx, 0
    jg .L514_2
    mov rsi, 1
.L514_2:
    lea rdi, [rsi*8]
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    call zyl_ralloc
    mov r13, rax
    cmp r12, 0
    je .L514_5
    cmp r13, 0
    jne .L514_3
.L514_5:
    lea rax, [rip+.L515]
    mov rdi, rax
    call zyl_panic
    jmp .L514_4
.L514_3:
.L514_4:
    mov rsi, 6510318579778470233
    mov qword ptr [r12+0], rsi
    mov qword ptr [r12+8], rbx
    mov rsi, 0
    mov qword ptr [r12+16], rsi
    mov qword ptr [r12+24], r13
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_vec_alloc_r
zyl_vec_alloc_r:
.L516_0:
    jmp zyl_vec_alloc
.globl zyl_array_new_r
zyl_array_new_r:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L517_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L517_1
    mov rsi, rdi
.L517_1:
    mov rbx, rsi
    mov rdi, 32
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r12, rax
    mov rsi, rbx
    cmp rbx, 0
    jg .L517_2
    mov rsi, 1
.L517_2:
    lea rdi, [rsi*8]
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    call zyl_ralloc
    mov r13, rax
    cmp r12, 0
    je .L517_5
    cmp r13, 0
    jne .L517_3
.L517_5:
    lea rax, [rip+.L518]
    mov rdi, rax
    call zyl_panic
    jmp .L517_4
.L517_3:
.L517_4:
    mov rsi, 6510318579778470233
    mov qword ptr [r12+0], rsi
    mov qword ptr [r12+8], rbx
    mov rsi, 0
    mov qword ptr [r12+16], rsi
    mov qword ptr [r12+24], r13
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dget_x2Dfail:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L519_0:
    cmp rdi, 4096
    jl .L519_1
.L519_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L519_1
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp r8, rax
    jne .L519_1
    lea rax, [rip+.L520]
    mov r8, rax
    mov rdi, qword ptr [rdi+16]
    mov rdx, rdi
    mov rdi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L519_1:
    lea rax, [rip+.L521]
    mov rdi, rax
    lea rax, [rip+.L522]
    mov rbx, rax
    lea rax, [rip+.L523]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_array_get
zyl_array_get:
.L524_0:
    cmp rdi, 4096
    jl .L524_1
.L524_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L524_1
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp r8, rax
    jne .L524_1
    cmp rsi, 0
    jl .L524_1
    mov rax, qword ptr [rdi+16]
    cmp rsi, rax
    jge .L524_1
    mov r8, qword ptr [rdi+24]
    lea r9, [rsi*8]
    add r8, r9
    mov rax, qword ptr [r8+0]
    ret
.L524_1:
    jmp zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dget_x2Dfail
.globl zyl_array_copy
zyl_array_copy:
    push rbx
    push r12
    push r13
    mov rbx, rsi
    mov r12, rdx
.L525_0:
    lea rax, [rip+.L526]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov r13, rax
    lea rax, [rip+.L527]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov rbx, rax
    mov rsi, qword ptr [r13+16]
    cmp r12, 0
    jl .L525_3
    cmp r12, rsi
    jle .L525_1
.L525_3:
    lea rax, [rip+.L528]
    mov rdi, rax
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L525_2
.L525_1:
.L525_2:
    mov rsi, qword ptr [rbx+8]
    mov rax, qword ptr [rbx+16]
    cmp rax, 0
    jne .L525_6
    cmp r12, rsi
    jle .L525_4
.L525_6:
    lea rax, [rip+.L529]
    mov rdi, rax
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L525_5
.L525_4:
.L525_5:
    mov rdi, qword ptr [rbx+24]
    mov rsi, qword ptr [r13+24]
    lea r8, [r12*8]
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov qword ptr [rbx+16], r12
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_array_set
zyl_array_set:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rsi
    mov r12, rdx
.L530_0:
    lea rax, [rip+.L531]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov r13, rax
    mov r14, qword ptr [r13+16]
    cmp rbx, 0
    jl .L530_3
    cmp rbx, r14
    jg .L530_3
    mov rax, qword ptr [r13+8]
    cmp rbx, rax
    jl .L530_1
.L530_3:
    lea rax, [rip+.L532]
    mov rdi, rax
    mov rsi, rbx
    mov rdx, r14
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L530_2
.L530_1:
.L530_2:
    mov rsi, qword ptr [r13+24]
    lea rdi, [rbx*8]
    add rsi, rdi
    mov qword ptr [rsi+0], r12
    cmp rbx, r14
    jne .L530_4
    lea rsi, [r14+1]
    mov qword ptr [r13+16], rsi
    jmp .L530_5
.L530_4:
.L530_5:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_attrh_new
zyl_attrh_new:
.L533_0:
    mov rdi, 1
    mov rsi, 24
    jmp zyl_rt_calloc
zy_local_x2Fmain_0__tables__tb_x2Dprobe:
    mov r8, rdx
    mov r9, rcx
.L534_0:
    mov r10, r8
    shl r10, 4
    add r10, rdi
    mov r11, qword ptr [r10+0]
    cmp r11, 0
    je .L534_2
    cmp r11, r9
    jne .L534_1
.L534_2:
    mov rax, r10
    ret
.L534_1:
    add r8, 1
    and r8, rsi
    jmp .L534_0
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
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L535_0:
    cmp qword ptr [rbp-56], r13
    jl .L535_1
.L535_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L535_1:
    imul rsi, qword ptr [rbp-56], 16
    mov rbx, qword ptr [rbp-48]
    add rbx, rsi
    mov r12, qword ptr [rbx+0]
    cmp r12, 0
    je .L535_2
    mov rsi, r12
    shr rsi, 30
    mov rdi, 17179869183
    and rsi, rdi
    xor rsi, r12
    mov rdi, -4658895280553007687
    imul rsi, rdi
    mov rdi, rsi
    shr rdi, 27
    mov r8, 137438953471
    and rdi, r8
    xor rsi, rdi
    mov rdi, -7723592293110705685
    imul rsi, rdi
    mov rdi, rsi
    shr rdi, 31
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
    mov qword ptr [rsi+0], r12
    mov rdi, qword ptr [rbx+8]
    mov qword ptr [rsi+8], rdi
.L535_2:
    mov rax, qword ptr [rbp-56]
    add rax, 1
    mov qword ptr [rbp-56], rax
    cmp qword ptr [rbp-56], r13
    jl .L535_1
    jmp .L535_3
zy_local_x2Fmain_0__tables__tb_x2Dgrow:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L536_0:
    mov r12, qword ptr [rbx+8]
    lea rsi, [r12*8]
    cmp r12, 0
    jg .L536_1
    mov rsi, 4096
.L536_1:
    mov r13, rsi
    mov rsi, 16
    mov rdi, r13
    call zyl_rt_calloc
    mov r14, rax
    cmp r14, 0
    jne .L536_2
    mov rdi, r13
    shl rdi, 4
    lea rax, [rip+.L537]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L536_3
.L536_2:
.L536_3:
    mov rdi, qword ptr [rbx+0]
    mov rsi, 0
    lea r8, [r13-1]
    mov rdx, r12
    mov rcx, r14
    call zy_local_x2Fmain_0__tables__tb_x2Drehash
    mov rdi, qword ptr [rbx+0]
    call zyl_rt_free
    mov qword ptr [rbx+0], r14
    mov qword ptr [rbx+8], r13
    mov rsi, r13
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dattr_x2Dset:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L538_0:
    cmp rbx, 0
    je .L538_2
.L538_7:
    cmp r12, 0
    jne .L538_1
.L538_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L538_1:
    mov rsi, qword ptr [rbx+16]
    imul rsi, rsi, 10
    mov rdi, qword ptr [rbx+8]
    imul rdi, rdi, 7
    cmp rsi, rdi
    jl .L538_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dgrow
    jmp .L538_4
.L538_3:
.L538_4:
    mov rsi, qword ptr [rbx+8]
    sub rsi, 1
    mov rdi, qword ptr [rbx+0]
    mov r8, r12
    shr r8, 30
    mov r9, 17179869183
    and r8, r9
    xor r8, r12
    mov r9, -4658895280553007687
    imul r8, r9
    mov r9, r8
    shr r9, 27
    mov r10, 137438953471
    and r9, r10
    xor r8, r9
    mov r9, -7723592293110705685
    imul r8, r9
    mov r9, r8
    shr r9, 31
    mov r10, 8589934591
    and r9, r10
    xor r8, r9
    and r8, rsi
    mov rdx, r8
    mov rcx, r12
    call zy_local_x2Fmain_0__tables__tb_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L538_5
    mov qword ptr [rsi+0], r12
    mov rdi, qword ptr [rbx+16]
    add rdi, 1
    mov qword ptr [rbx+16], rdi
    jmp .L538_6
.L538_5:
.L538_6:
    mov qword ptr [rsi+8], r13
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_attrh_set
zyl_attrh_set:
    mov r8, rdx
.L539_0:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dattr_x2Dset
zy_local_x2Fmain_0__tables__tb_x2Dget_x2Dloop:
    push rbx
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L540_0:
    mov r11, r8
    shl r11, 4
    add r11, rdi
    mov rbx, qword ptr [r11+0]
    cmp rbx, r9
    jne .L540_1
    mov rax, qword ptr [r11+8]
    pop rbx
    ret
.L540_1:
    cmp rbx, 0
    jne .L540_2
    mov rax, r10
    pop rbx
    ret
.L540_2:
    add r8, 1
    and r8, rsi
    jmp .L540_0
.globl zyl_attrh_get_or
zyl_attrh_get_or:
    push rbx
    mov r8, rdx
.L541_0:
    cmp rdi, 0
    je .L541_2
.L541_3:
    cmp rsi, 0
    je .L541_2
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jne .L541_1
.L541_2:
    mov rax, r8
    pop rbx
    ret
.L541_1:
    mov r9, qword ptr [rdi+8]
    sub r9, 1
    mov rdi, qword ptr [rdi+0]
    mov r10, rsi
    shr r10, 30
    mov r11, 17179869183
    and r10, r11
    xor r10, rsi
    mov r11, -4658895280553007687
    imul r10, r11
    mov r11, r10
    shr r11, 27
    mov rbx, 137438953471
    and r11, rbx
    xor r10, r11
    mov r11, -7723592293110705685
    imul r10, r11
    mov r11, r10
    shr r11, 31
    mov rbx, 8589934591
    and r11, rbx
    xor r10, r11
    and r10, r9
    mov rdx, r10
    mov rcx, rsi
    mov rsi, r9
    pop rbx
    jmp zy_local_x2Fmain_0__tables__tb_x2Dget_x2Dloop
.globl zyl_attrh_has
zyl_attrh_has:
    push rbx
.L542_0:
    cmp rdi, 0
    je .L542_4
.L542_7:
    cmp rsi, 0
    je .L542_4
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jne .L542_2
.L542_4:
    mov r8, 0
    jmp .L542_3
.L542_2:
    mov r9, qword ptr [rdi+8]
    sub r9, 1
    mov rdi, qword ptr [rdi+0]
    mov r10, rsi
    shr r10, 30
    mov r11, 17179869183
    and r10, r11
    xor r10, rsi
    mov r11, -4658895280553007687
    imul r10, r11
    mov r11, r10
    shr r11, 27
    mov rbx, 137438953471
    and r11, rbx
    xor r10, r11
    mov r11, -7723592293110705685
    imul r10, r11
    mov r11, r10
    shr r11, 31
    mov rbx, 8589934591
    and r11, rbx
    xor r10, r11
    and r10, r9
    mov rdx, r10
    mov rcx, rsi
    mov rsi, r9
    call zy_local_x2Fmain_0__tables__tb_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L542_5
    mov rdi, 0
    jmp .L542_6
.L542_5:
    mov rdi, rsi
.L542_6:
    mov r8, rdi
.L542_3:
    cmp r8, 0
    jne .L542_1
    mov rax, 0
    pop rbx
    ret
.L542_1:
    mov rax, 1
    pop rbx
    ret
.globl zyl_attrh_copy
zyl_attrh_copy:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L543_0:
    cmp rbx, 0
    je .L543_3
.L543_7:
    cmp rsi, 0
    je .L543_3
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L543_1
.L543_3:
    mov rdi, 0
    jmp .L543_2
.L543_1:
    mov r8, qword ptr [rbx+8]
    sub r8, 1
    mov r9, qword ptr [rbx+0]
    mov r10, rsi
    shr r10, 30
    mov r11, 17179869183
    and r10, r11
    xor r10, rsi
    mov r11, -4658895280553007687
    imul r10, r11
    mov r11, r10
    shr r11, 27
    mov r13, 137438953471
    and r11, r13
    xor r10, r11
    mov r11, -7723592293110705685
    imul r10, r11
    mov r11, r10
    shr r11, 31
    mov r13, 8589934591
    and r11, r13
    xor r10, r11
    and r10, r8
    mov rdi, r9
    mov rdx, r10
    mov rcx, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__tables__tb_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L543_4
    mov r8, 0
    jmp .L543_5
.L543_4:
    mov r8, rsi
.L543_5:
    mov rdi, r8
.L543_2:
    cmp rdi, 0
    jne .L543_6
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L543_6:
    mov rsi, qword ptr [rdi+8]
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__tables__tb_x2Dattr_x2Dset
.globl zyl_attrh_clear
zyl_attrh_clear:
.L544_0:
    cmp rdi, 0
    je .L544_2
.L544_3:
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jne .L544_1
.L544_2:
    mov rax, 0
    ret
.L544_1:
    mov rsi, qword ptr [rdi+0]
    mov r8, 0
    mov r9, qword ptr [rdi+8]
    shl r9, 4
    mov rdx, rsi
    mov rcx, r8
    mov r11, r9
    push rdi
    mov rdi, rdx
    mov rax, rcx
    mov rcx, r11
    rep stosb
    pop rdi
    xor eax, eax
    mov rsi, 0
    mov qword ptr [rdi+16], rsi
    mov rax, 0
    ret
.globl zyl_ref_new
zyl_ref_new:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L545_0:
    mov rdi, 8
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L545_1
    mov rdi, 8
    lea rax, [rip+.L546]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L545_2
.L545_1:
.L545_2:
    mov qword ptr [r12+0], rbx
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ref_get
zyl_ref_get:
.L547_0:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_ref_set
zyl_ref_set:
.L548_0:
    mov qword ptr [rdi+0], rsi
    mov rax, 0
    ret
.globl zyl_uf_id
zyl_uf_id:
.L549_0:
    mov rax, rdi
    ret
.globl zyl_getenv_str
zyl_getenv_str:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L550_0:
    cmp rdi, 0
    jne .L550_1
.L550_4:
    mov rsi, 0
    jmp .L550_2
.L550_1:
    call zyl_rt_getenv
    mov rsi, rax
.L550_2:
    cmp rsi, 0
    jne .L550_3
    lea rax, [rip+.L551]
    mov rdi, rax
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L550_3:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dmagic:
.L552_0:
    mov rax, 6510318656819643953
    ret
.globl zyl_strbuf_new
zyl_strbuf_new:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L553_0:
    mov r8, rsi
    cmp rsi, 0
    jg .L553_1
    mov r8, 1
.L553_1:
    mov rbx, r8
    lea rsi, [rbx+24]
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    cmp rsi, 0
    jne .L553_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L553_2:
    mov rdi, 6510318656819643953
    mov qword ptr [rsi+0], rdi
    mov rdi, 0
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], rbx
    lea rax, [rsi+24]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_strbuf_str
zyl_strbuf_str:
.L554_0:
    mov rax, rdi
    ret
.globl zyl_strbuf_new_r
zyl_strbuf_new_r:
    push rbx
.L555_0:
    mov rsi, rdi
    cmp rdi, 0
    jg .L555_1
    mov rsi, 1
.L555_1:
    mov rbx, rsi
    lea rdi, [rbx+24]
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L555_2
    mov rax, 0
    pop rbx
    ret
.L555_2:
    mov rdi, 6510318656819643953
    mov qword ptr [rsi+0], rdi
    mov rdi, 0
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], rbx
    lea rax, [rsi+24]
    pop rbx
    ret
zy_local_x2Fmain_0__tables__tb_x2Duhex:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L556_0:
    lea rax, [rip+.L557]
    mov rdi, rax
    mov rsi, rbx
    and rsi, 15
    mov r8, 1
    mov rdx, r8
    call zyl_cstr_substr
    mov rdi, rax
    mov rsi, rbx
    shr rsi, 4
    mov r8, 1152921504606846975
    and rsi, r8
    cmp rsi, 0
    jne .L556_1
    mov rsi, r12
    call zyl_cstr_concat
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L556_1:
    mov rbx, rsi
    mov rsi, r12
    call zyl_cstr_concat
    mov r12, rax
    jmp .L556_0
zy_local_x2Fmain_0__tables__tb_x2Dbad:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L558_0:
    cmp rdi, 4096
    jge .L558_1
.L558_2:
    lea rax, [rip+.L559]
    mov rbx, rax
    lea rax, [rip+.L560]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Duhex
    mov rdi, rax
    lea rax, [rip+.L561]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, 2
    mov r12, rdi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L558_1:
    mov rax, 0
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
.L562_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    lea rsi, [rbx-16]
    mov r15, qword ptr [rsi+0]
    lea rsi, [rbx-8]
    mov rsi, qword ptr [rsi+0]
    cmp r13, 0
    jle .L562_1
    cmp r13, rsi
    jge .L562_1
    mov rdi, r13
    jmp .L562_2
.L562_1:
    mov rdi, rsi
.L562_2:
    lea rsi, [r15+r14]
    add rsi, 1
    cmp rsi, rdi
    jle .L562_3
    cmp r13, 0
    jle .L562_5
    lea rax, [rip+.L563]
    mov rdi, rax
    jmp .L562_6
.L562_5:
    lea rax, [rip+.L564]
    mov rdi, rax
.L562_6:
    call zyl_panic
    jmp .L562_4
.L562_3:
.L562_4:
    lea rdi, [rbx+r15]
    mov rsi, r12
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r15+r14]
    add rsi, rbx
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    lea rsi, [rbx-16]
    lea rdi, [r15+r14]
    mov qword ptr [rsi+0], rdi
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
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L565_0:
    cmp rbx, 0
    je .L565_2
.L565_7:
    cmp r12, 0
    jne .L565_1
.L565_2:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L565_1:
    cmp rbx, 4096
    jl .L565_3
    cmp r12, 4096
    jl .L565_3
    cmp rbx, 4120
    jl .L565_4
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    jne .L565_4
    lea rdi, [rbx-24]
    mov rdi, qword ptr [rdi+0]
    mov rax, 6510318656819643953
    cmp rdi, rax
    jne .L565_4
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dappend
.L565_4:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_str_append_scan
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L565_3:
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dbad
    cmp rax, 0
    je .L565_5
    jmp .L565_6
.L565_5:
    mov rdi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Dbad
.L565_6:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_str_append
zyl_str_append:
.L566_0:
    mov r8, 0
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dappend
.globl zyl_str_append_capped
zyl_str_append_capped:
    mov r8, rdx
.L567_0:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dappend
zy_local_x2Fmain_0__bytes__bb_x2Dmagic_x2Dbuf:
.L568_0:
    mov rax, 6510318584122966017
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dmagic_x2Dslice:
.L569_0:
    mov rax, 6510318584122966018
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dmax_x2Dcap:
.L570_0:
    mov rax, 1099511627776
    ret
.globl zyl_load_byte
zyl_load_byte:
    mov rdi, rdx
.L571_0:
    cmp rdi, 4096
    jl .L571_3
.L571_15:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L571_1
.L571_3:
    mov r8, 0
    jmp .L571_2
.L571_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L571_4
    mov r10, qword ptr [rdi+24]
    jmp .L571_5
.L571_4:
    mov rax, 6510318584122966018
    cmp r9, rax
    jne .L571_6
    mov r9, qword ptr [rdi+16]
    jmp .L571_7
.L571_6:
    mov r9, -1
.L571_7:
    mov r10, r9
.L571_5:
    cmp r10, 0
    jl .L571_8
    cmp rsi, 0
    jl .L571_12
    cmp r10, 0
    jl .L571_13
    mov rax, 1
    cmp rax, r10
    jle .L571_10
.L571_13:
.L571_12:
    mov r9, 0
    jmp .L571_11
.L571_10:
    sub r10, 1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r9, rax
.L571_11:
    cmp r9, 0
    je .L571_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jmp .L571_9
.L571_8:
    mov rdi, 0
.L571_9:
    mov r8, rdi
.L571_2:
    cmp r8, 0
    jne .L571_14
    mov rax, 0
    ret
.L571_14:
    movzx eax, byte ptr [r8+0]
    ret
.globl zyl_load_byte_signed
zyl_load_byte_signed:
    mov rdi, rdx
.L572_0:
    cmp rdi, 4096
    jl .L572_3
.L572_16:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L572_1
.L572_3:
    mov r8, 0
    jmp .L572_2
.L572_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L572_4
    mov r10, qword ptr [rdi+24]
    jmp .L572_5
.L572_4:
    mov rax, 6510318584122966018
    cmp r9, rax
    jne .L572_6
    mov r9, qword ptr [rdi+16]
    jmp .L572_7
.L572_6:
    mov r9, -1
.L572_7:
    mov r10, r9
.L572_5:
    cmp r10, 0
    jl .L572_8
    cmp rsi, 0
    jl .L572_12
    cmp r10, 0
    jl .L572_13
    mov rax, 1
    cmp rax, r10
    jle .L572_10
.L572_13:
.L572_12:
    mov r9, 0
    jmp .L572_11
.L572_10:
    sub r10, 1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r9, rax
.L572_11:
    cmp r9, 0
    je .L572_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jmp .L572_9
.L572_8:
    mov rdi, 0
.L572_9:
    mov r8, rdi
.L572_2:
    cmp r8, 0
    jne .L572_14
    mov rax, 0
    ret
.L572_14:
    movzx esi, byte ptr [r8+0]
    cmp rsi, 127
    jle .L572_15
    lea rax, [rsi-256]
    ret
.L572_15:
    mov rax, rsi
    ret
.globl zyl_store_byte
zyl_store_byte:
    mov rdi, rdx
    mov r8, rcx
.L573_0:
    cmp rdi, 4096
    jl .L573_3
.L573_15:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L573_1
.L573_3:
    mov r9, 0
    jmp .L573_2
.L573_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L573_4
    mov r11, qword ptr [rdi+24]
    jmp .L573_5
.L573_4:
    mov rax, 6510318584122966018
    cmp r10, rax
    jne .L573_6
    mov r10, qword ptr [rdi+16]
    jmp .L573_7
.L573_6:
    mov r10, -1
.L573_7:
    mov r11, r10
.L573_5:
    cmp r11, 0
    jl .L573_8
    cmp rsi, 0
    jl .L573_12
    cmp r11, 0
    jl .L573_13
    mov rax, 1
    cmp rax, r11
    jle .L573_10
.L573_13:
.L573_12:
    mov r10, 0
    jmp .L573_11
.L573_10:
    sub r11, 1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L573_11:
    cmp r10, 0
    je .L573_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jmp .L573_9
.L573_8:
    mov rdi, 0
.L573_9:
    mov r9, rdi
.L573_2:
    cmp r9, 0
    jne .L573_14
    mov rax, 0
    ret
.L573_14:
    mov byte ptr [r9+0], r8b
    mov rax, 1
    ret
.globl zyl_store_byte_signed
zyl_store_byte_signed:
    mov rdi, rdx
    mov r8, rcx
.L574_0:
    cmp rdi, 4096
    jl .L574_3
.L574_15:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L574_1
.L574_3:
    mov r9, 0
    jmp .L574_2
.L574_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L574_4
    mov r11, qword ptr [rdi+24]
    jmp .L574_5
.L574_4:
    mov rax, 6510318584122966018
    cmp r10, rax
    jne .L574_6
    mov r10, qword ptr [rdi+16]
    jmp .L574_7
.L574_6:
    mov r10, -1
.L574_7:
    mov r11, r10
.L574_5:
    cmp r11, 0
    jl .L574_8
    cmp rsi, 0
    jl .L574_12
    cmp r11, 0
    jl .L574_13
    mov rax, 1
    cmp rax, r11
    jle .L574_10
.L574_13:
.L574_12:
    mov r10, 0
    jmp .L574_11
.L574_10:
    sub r11, 1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L574_11:
    cmp r10, 0
    je .L574_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jmp .L574_9
.L574_8:
    mov rdi, 0
.L574_9:
    mov r9, rdi
.L574_2:
    cmp r9, 0
    jne .L574_14
    mov rax, 0
    ret
.L574_14:
    mov byte ptr [r9+0], r8b
    mov rax, 1
    ret
.globl zyl_load_n
zyl_load_n:
    push rbx
    mov r8, rdx
    mov r9, rcx
.L575_0:
    cmp rdi, 2
    je .L575_1
.L575_24:
    cmp rdi, 4
    je .L575_1
    cmp rdi, 8
    je .L575_1
    mov rax, 0
    pop rbx
    ret
.L575_1:
    cmp r9, 4096
    jl .L575_4
    mov rax, r9
    and rax, 7
    cmp rax, 0
    je .L575_2
.L575_4:
    mov r10, 0
    jmp .L575_3
.L575_2:
    mov r11, qword ptr [r9+0]
    mov rax, 6510318584122966017
    cmp r11, rax
    jne .L575_5
    mov rbx, qword ptr [r9+24]
    jmp .L575_6
.L575_5:
    mov rax, 6510318584122966018
    cmp r11, rax
    jne .L575_7
    mov r11, qword ptr [r9+16]
    jmp .L575_8
.L575_7:
    mov r11, -1
.L575_8:
    mov rbx, r11
.L575_6:
    cmp rbx, 0
    jl .L575_9
    cmp r8, 0
    jl .L575_13
    cmp rdi, 0
    jl .L575_14
    cmp rbx, 0
    jl .L575_15
    cmp rdi, rbx
    jle .L575_11
.L575_15:
.L575_14:
.L575_13:
    mov r11, 0
    jmp .L575_12
.L575_11:
    sub rbx, rdi
    mov rax, r8
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r11, rax
.L575_12:
    cmp r11, 0
    je .L575_9
    mov r9, qword ptr [r9+8]
    add r9, r8
    jmp .L575_10
.L575_9:
    mov r9, 0
.L575_10:
    mov r10, r9
.L575_3:
    cmp r10, 0
    jne .L575_16
    mov rax, 0
    pop rbx
    ret
.L575_16:
    cmp rdi, 2
    jne .L575_17
    movzx r8d, word ptr [r10+0]
    jmp .L575_18
.L575_17:
    cmp rdi, 4
    jne .L575_19
    mov r9d, dword ptr [r10+0]
    jmp .L575_20
.L575_19:
    mov r9, qword ptr [r10+0]
.L575_20:
    mov r8, r9
.L575_18:
    cmp rsi, 0
    jne .L575_21
    mov rax, r8
    pop rbx
    ret
.L575_21:
    mov rsi, r8
    shr rsi, 8
    mov r9, 71777214294589695
    and rsi, r9
    mov r9, 71777214294589695
    and r8, r9
    shl r8, 8
    or rsi, r8
    mov r8, rsi
    shr r8, 16
    mov r9, 281470681808895
    and r8, r9
    mov r9, 281470681808895
    and rsi, r9
    shl rsi, 16
    or rsi, r8
    mov r8, rsi
    shr r8, 32
    mov r9, 4294967295
    and r8, r9
    shl rsi, 32
    or rsi, r8
    cmp rdi, 8
    jne .L575_22
    mov rax, rsi
    pop rbx
    ret
.L575_22:
    cmp rdi, 4
    jne .L575_23
    mov rdi, rsi
    shr rdi, 32
    mov r8, 4294967295
    and rdi, r8
    mov rax, rdi
    pop rbx
    ret
.L575_23:
    shr rsi, 48
    and rsi, 65535
    mov rax, rsi
    pop rbx
    ret
.globl zyl_load_n_signed
zyl_load_n_signed:
    push rbx
    mov rbx, rdi
    mov rdi, rdx
    mov r8, rcx
.L576_0:
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zyl_load_n
    mov rsi, rax
    cmp rbx, 8
    jge .L576_2
    cmp rbx, 2
    je .L576_1
    cmp rbx, 4
    je .L576_1
    cmp rbx, 8
    je .L576_1
.L576_2:
    mov rax, rsi
    pop rbx
    ret
.L576_1:
    mov rdi, 1
    lea r8, [rbx*8]
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
    pop rbx
    ret
.globl zyl_store_n
zyl_store_n:
    push rbx
    push r12
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L577_0:
    cmp rdi, 2
    je .L577_1
.L577_25:
    cmp rdi, 4
    je .L577_1
    cmp rdi, 8
    je .L577_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L577_1:
    cmp r9, 4096
    jl .L577_4
    mov rax, r9
    and rax, 7
    cmp rax, 0
    je .L577_2
.L577_4:
    mov r11, 0
    jmp .L577_3
.L577_2:
    mov rbx, qword ptr [r9+0]
    mov rax, 6510318584122966017
    cmp rbx, rax
    jne .L577_5
    mov r12, qword ptr [r9+24]
    jmp .L577_6
.L577_5:
    mov rax, 6510318584122966018
    cmp rbx, rax
    jne .L577_7
    mov rbx, qword ptr [r9+16]
    jmp .L577_8
.L577_7:
    mov rbx, -1
.L577_8:
    mov r12, rbx
.L577_6:
    cmp r12, 0
    jl .L577_9
    cmp r8, 0
    jl .L577_13
    cmp rdi, 0
    jl .L577_14
    cmp r12, 0
    jl .L577_15
    cmp rdi, r12
    jle .L577_11
.L577_15:
.L577_14:
.L577_13:
    mov rbx, 0
    jmp .L577_12
.L577_11:
    sub r12, rdi
    mov rax, r8
    mov rcx, r12
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
.L577_12:
    cmp rbx, 0
    je .L577_9
    mov r9, qword ptr [r9+8]
    add r9, r8
    jmp .L577_10
.L577_9:
    mov r9, 0
.L577_10:
    mov r11, r9
.L577_3:
    cmp r11, 0
    jne .L577_16
    mov rax, 0
    pop r12
    pop rbx
    ret
.L577_16:
    mov r8, r10
    cmp rsi, 0
    je .L577_17
    mov rsi, r10
    shr rsi, 8
    mov r9, 71777214294589695
    and rsi, r9
    mov r9, 71777214294589695
    and r9, r10
    shl r9, 8
    or rsi, r9
    mov r9, rsi
    shr r9, 16
    mov r10, 281470681808895
    and r9, r10
    mov r10, 281470681808895
    and rsi, r10
    shl rsi, 16
    or rsi, r9
    mov r9, rsi
    shr r9, 32
    mov r10, 4294967295
    and r9, r10
    shl rsi, 32
    or rsi, r9
    mov r9, rsi
    cmp rdi, 8
    je .L577_18
    cmp rdi, 4
    jne .L577_19
    mov r10, rsi
    shr r10, 32
    mov rbx, 4294967295
    and r10, rbx
    jmp .L577_20
.L577_19:
    mov r10, rsi
    shr r10, 48
    and r10, 65535
.L577_20:
    mov r9, r10
.L577_18:
    mov r8, r9
.L577_17:
    cmp rdi, 2
    jne .L577_21
    mov word ptr [r11+0], r8w
    jmp .L577_22
.L577_21:
    cmp rdi, 4
    jne .L577_23
    mov dword ptr [r11+0], r8d
    jmp .L577_24
.L577_23:
    mov qword ptr [r11+0], r8
.L577_24:
.L577_22:
    mov rax, 1
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L578_0:
    mov rdi, 24
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L578_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L578_1:
    mov rdi, 6510318584122966018
    mov qword ptr [rsi+0], rdi
    mov qword ptr [rsi+8], rbx
    mov qword ptr [rsi+16], r12
    mov rax, rsi
    pop r12
    pop rbx
    ret
.globl zyl_byte_slice
zyl_byte_slice:
    mov r8, rdx
.L579_0:
    cmp rdi, 4096
    jl .L579_3
.L579_13:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L579_1
.L579_3:
    mov r9, 0
    jmp .L579_2
.L579_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L579_4
    jmp .L579_5
.L579_4:
    mov rdi, 0
.L579_5:
    mov r9, rdi
.L579_2:
    cmp r9, 0
    je .L579_7
    cmp rsi, 0
    jl .L579_10
    cmp r8, 0
    jl .L579_11
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L579_12
    mov rax, qword ptr [r9+24]
    cmp r8, rax
    jle .L579_8
.L579_12:
.L579_11:
.L579_10:
    mov rdi, 0
    jmp .L579_9
.L579_8:
    mov r10, qword ptr [r9+24]
    sub r10, r8
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rdi, rax
.L579_9:
    cmp rdi, 0
    jne .L579_6
.L579_7:
    mov rax, 0
    ret
.L579_6:
    mov rdi, qword ptr [r9+8]
    add rdi, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice
.globl zyl_byte_slice_sub
zyl_byte_slice_sub:
    mov r8, rdx
.L580_0:
    cmp rdi, 4096
    jl .L580_3
.L580_13:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L580_1
.L580_3:
    mov r9, 0
    jmp .L580_2
.L580_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966018
    cmp r10, rax
    jne .L580_4
    jmp .L580_5
.L580_4:
    mov rdi, 0
.L580_5:
    mov r9, rdi
.L580_2:
    cmp r9, 0
    je .L580_7
    cmp rsi, 0
    jl .L580_10
    cmp r8, 0
    jl .L580_11
    mov rax, qword ptr [r9+16]
    cmp rax, 0
    jl .L580_12
    mov rax, qword ptr [r9+16]
    cmp r8, rax
    jle .L580_8
.L580_12:
.L580_11:
.L580_10:
    mov rdi, 0
    jmp .L580_9
.L580_8:
    mov r10, qword ptr [r9+16]
    sub r10, r8
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rdi, rax
.L580_9:
    cmp rdi, 0
    jne .L580_6
.L580_7:
    mov rax, 0
    ret
.L580_6:
    mov rdi, qword ptr [r9+8]
    add rdi, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice
zy_local_x2Fmain_0__bytes__bb_x2Dinit:
    mov r8, rdx
.L581_0:
    mov r9, 6510318584122966017
    mov qword ptr [rdi+0], r9
    mov qword ptr [rdi+8], rsi
    mov rsi, 0
    mov qword ptr [rdi+16], rsi
    mov qword ptr [rdi+24], r8
    mov rax, rdi
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok:
.L582_0:
    cmp rdi, 0
    jl .L582_1
.L582_2:
    mov rsi, 1099511627776
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setle al
    movzx rax, al
    ret
.L582_1:
    mov rax, 0
    ret
.globl zyl_bytebuf_new
zyl_bytebuf_new:
    push rbx
    push r12
    push r13
    mov rbx, rsi
.L583_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok
    cmp rax, 0
    jne .L583_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L583_1:
    mov rdi, 32
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L583_2
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L583_2:
    mov rsi, rbx
    cmp rbx, 0
    jg .L583_3
    mov rsi, 1
.L583_3:
    mov r13, rsi
    mov rsi, 1
    mov rdi, r13
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L583_4
    mov rdi, r12
    call zyl_rt_free
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L583_4:
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov r11, r13
    push rdi
    mov rdi, rdx
    mov rax, rcx
    mov rcx, r11
    rep stosb
    pop rdi
    xor eax, eax
    mov rdi, r12
    mov rdx, rbx
    pop r13
    pop r12
    pop rbx
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
.L584_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok
    cmp rax, 0
    jne .L584_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L584_1:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r12, rax
    mov rdi, 32
    mov rsi, r12
    call zyl_ralloc
    mov r13, rax
    cmp r13, 0
    jne .L584_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L584_2:
    mov rsi, rbx
    cmp rbx, 0
    jg .L584_3
    mov rsi, 1
.L584_3:
    mov r14, rsi
    mov rdi, r14
    mov rsi, r12
    call zyl_ralloc
    mov rsi, rax
    cmp rsi, 0
    jne .L584_4
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L584_4:
    mov rdi, 0
    mov rdx, rsi
    mov rcx, rdi
    mov r11, r14
    push rdi
    mov rdi, rdx
    mov rax, rcx
    mov rcx, r11
    rep stosb
    pop rdi
    xor eax, eax
    mov rdi, r13
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
    push rbx
    push r12
    push r13
.L585_0:
    cmp rdi, 4096
    jl .L585_3
.L585_19:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L585_1
.L585_3:
    mov r8, 0
    jmp .L585_2
.L585_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L585_4
    jmp .L585_5
.L585_4:
    mov rdi, 0
.L585_5:
    mov r8, rdi
.L585_2:
    mov rbx, r8
    cmp rsi, 4096
    jl .L585_8
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L585_6
.L585_8:
    mov rdi, 0
    jmp .L585_7
.L585_6:
    mov r8, qword ptr [rsi+0]
    mov rax, 6510318584122966018
    cmp r8, rax
    jne .L585_9
    jmp .L585_10
.L585_9:
    mov rsi, 0
.L585_10:
    mov rdi, rsi
.L585_7:
    cmp rbx, 0
    je .L585_12
    cmp rdi, 0
    jne .L585_11
.L585_12:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L585_11:
    mov r12, qword ptr [rbx+16]
    mov r13, qword ptr [rdi+16]
    cmp r12, 0
    jl .L585_16
    cmp r13, 0
    jl .L585_17
    mov rax, qword ptr [rbx+24]
    cmp rax, 0
    jl .L585_18
    mov rax, qword ptr [rbx+24]
    cmp r13, rax
    jle .L585_14
.L585_18:
.L585_17:
.L585_16:
    mov rsi, 0
    jmp .L585_15
.L585_14:
    mov r8, qword ptr [rbx+24]
    sub r8, r13
    mov rax, r12
    mov rcx, r8
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rsi, rax
.L585_15:
    cmp rsi, 0
    jne .L585_13
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L585_13:
    mov rsi, qword ptr [rbx+8]
    add rsi, r12
    mov rdi, qword ptr [rdi+8]
    mov rdx, r13
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dmove
    lea rsi, [r12+r13]
    mov qword ptr [rbx+16], rsi
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_bytebuf_len
zyl_bytebuf_len:
.L586_0:
    cmp rdi, 4096
    jl .L586_3
.L586_7:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L586_1
.L586_3:
    mov rsi, 0
    jmp .L586_2
.L586_1:
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L586_4
    jmp .L586_5
.L586_4:
    mov rdi, 0
.L586_5:
    mov rsi, rdi
.L586_2:
    cmp rsi, 0
    jne .L586_6
    mov rax, 0
    ret
.L586_6:
    mov rax, qword ptr [rsi+16]
    ret
.globl zyl_bytebuf_cap
zyl_bytebuf_cap:
.L587_0:
    cmp rdi, 4096
    jl .L587_3
.L587_7:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L587_1
.L587_3:
    mov rsi, 0
    jmp .L587_2
.L587_1:
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L587_4
    jmp .L587_5
.L587_4:
    mov rdi, 0
.L587_5:
    mov rsi, rdi
.L587_2:
    cmp rsi, 0
    jne .L587_6
    mov rax, 0
    ret
.L587_6:
    mov rax, qword ptr [rsi+24]
    ret
.globl zyl_bytebuf_ptr
zyl_bytebuf_ptr:
.L588_0:
    cmp rdi, 4096
    jl .L588_3
.L588_7:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L588_1
.L588_3:
    mov rsi, 0
    jmp .L588_2
.L588_1:
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L588_4
    jmp .L588_5
.L588_4:
    mov rdi, 0
.L588_5:
    mov rsi, rdi
.L588_2:
    cmp rsi, 0
    jne .L588_6
    mov rax, 0
    ret
.L588_6:
    mov rax, qword ptr [rsi+8]
    ret
.globl zyl_align_check
zyl_align_check:
.L589_0:
    cmp rsi, 0
    jg .L589_1
.L589_3:
    mov rax, 0
    ret
.L589_1:
    mov rax, rdi
    mov rcx, rsi
    cqo
    idiv rcx
    mov rax, rdx
    cmp rax, 0
    jne .L589_2
    mov rax, 1
    ret
.L589_2:
    mov rax, 0
    ret
.globl zyl_atomic_load
zyl_atomic_load:
.L590_0:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_atomic_store
zyl_atomic_store:
.L591_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, rsi
    ret
.globl zyl_atomic_fetch_add
zyl_atomic_fetch_add:
.L592_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    ret
.globl zyl_atomic_add
zyl_atomic_add:
.L593_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rdi, rax
    add rdi, rsi
    mov rax, rdi
    ret
.globl zyl_atomic_sub
zyl_atomic_sub:
.L594_0:
    mov r8, 0
    sub r8, rsi
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rdi, rax
    sub rdi, rsi
    mov rax, rdi
    ret
.globl zyl_atomic_cas
zyl_atomic_cas:
    mov r8, rdx
.L595_0:
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
    ret
zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick:
    push rbx
    mov r8, rdx
    mov r9, rcx
.L596_0:
    cmp r9, 0
    je .L596_1
.L596_6:
    mov r10, rsi
    cmp rsi, r8
    jg .L596_3
    mov r10, r8
.L596_3:
    jmp .L596_2
.p2align 4
.L596_1:
    mov rbx, rsi
    cmp rsi, r8
    jl .L596_4
    mov rbx, r8
.L596_4:
    mov r10, rbx
.L596_2:
    mov rdx, rdi
    mov rcx, rsi
    mov r11, r10
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    mov rbx, rax
    cmp rbx, rsi
    jne .L596_5
    mov rax, r10
    pop rbx
    ret
.L596_5:
    mov rsi, rbx
    cmp r9, 0
    je .L596_1
    jmp .L596_6
.globl zyl_atomic_max
zyl_atomic_max:
.L597_0:
    mov r8, qword ptr [rdi+0]
    mov r9, 1
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick
.globl zyl_atomic_min
zyl_atomic_min:
.L598_0:
    mov r8, qword ptr [rdi+0]
    mov r9, 0
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick
.globl zyl_bytebuf_atomic_load
zyl_bytebuf_atomic_load:
.L599_0:
    cmp rdi, 4096
    jl .L599_3
.L599_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L599_1
.L599_3:
    mov r8, 0
    jmp .L599_2
.L599_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L599_4
    jmp .L599_5
.L599_4:
    mov rdi, 0
.L599_5:
    mov r8, rdi
.L599_2:
    cmp r8, 0
    je .L599_8
    cmp rsi, 0
    jl .L599_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L599_6
.L599_9:
.L599_8:
    mov rdi, 0
    jmp .L599_7
.L599_6:
    cmp rsi, 0
    jl .L599_14
    mov rax, qword ptr [r8+24]
    cmp rax, 0
    jl .L599_15
    mov r9, 8
    mov rax, qword ptr [r8+24]
    cmp r9, rax
    jle .L599_12
.L599_15:
.L599_14:
    mov r9, 0
    jmp .L599_13
.L599_12:
    mov r10, qword ptr [r8+24]
    sub r10, 8
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r9, rax
.L599_13:
    cmp r9, 0
    je .L599_10
    mov r8, qword ptr [r8+8]
    add r8, rsi
    jmp .L599_11
.L599_10:
    mov r8, 0
.L599_11:
    mov rdi, r8
.L599_7:
    cmp rdi, 0
    jne .L599_16
    mov rax, 0
    ret
.L599_16:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_bytebuf_atomic_store
zyl_bytebuf_atomic_store:
    mov r8, rdx
.L600_0:
    cmp rdi, 4096
    jl .L600_3
.L600_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L600_1
.L600_3:
    mov r9, 0
    jmp .L600_2
.L600_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L600_4
    jmp .L600_5
.L600_4:
    mov rdi, 0
.L600_5:
    mov r9, rdi
.L600_2:
    cmp r9, 0
    je .L600_8
    cmp rsi, 0
    jl .L600_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L600_6
.L600_9:
.L600_8:
    mov rdi, 0
    jmp .L600_7
.L600_6:
    cmp rsi, 0
    jl .L600_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L600_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L600_12
.L600_15:
.L600_14:
    mov r10, 0
    jmp .L600_13
.L600_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L600_13:
    cmp r10, 0
    je .L600_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L600_11
.L600_10:
    mov r9, 0
.L600_11:
    mov rdi, r9
.L600_7:
    cmp rdi, 0
    jne .L600_16
    mov rax, 0
    ret
.L600_16:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 1
    ret
.globl zyl_bytebuf_atomic_add
zyl_bytebuf_atomic_add:
    mov r8, rdx
.L601_0:
    cmp rdi, 4096
    jl .L601_3
.L601_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L601_1
.L601_3:
    mov r9, 0
    jmp .L601_2
.L601_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L601_4
    jmp .L601_5
.L601_4:
    mov rdi, 0
.L601_5:
    mov r9, rdi
.L601_2:
    cmp r9, 0
    je .L601_8
    cmp rsi, 0
    jl .L601_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L601_6
.L601_9:
.L601_8:
    mov rdi, 0
    jmp .L601_7
.L601_6:
    cmp rsi, 0
    jl .L601_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L601_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L601_12
.L601_15:
.L601_14:
    mov r10, 0
    jmp .L601_13
.L601_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L601_13:
    cmp r10, 0
    je .L601_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L601_11
.L601_10:
    mov r9, 0
.L601_11:
    mov rdi, r9
.L601_7:
    cmp rdi, 0
    jne .L601_16
    mov rax, 0
    ret
.L601_16:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    add rsi, r8
    mov rax, rsi
    ret
.globl zyl_bytebuf_atomic_sub
zyl_bytebuf_atomic_sub:
    mov r8, rdx
.L602_0:
    cmp rdi, 4096
    jl .L602_3
.L602_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L602_1
.L602_3:
    mov r9, 0
    jmp .L602_2
.L602_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L602_4
    jmp .L602_5
.L602_4:
    mov rdi, 0
.L602_5:
    mov r9, rdi
.L602_2:
    cmp r9, 0
    je .L602_8
    cmp rsi, 0
    jl .L602_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L602_6
.L602_9:
.L602_8:
    mov rdi, 0
    jmp .L602_7
.L602_6:
    cmp rsi, 0
    jl .L602_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L602_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L602_12
.L602_15:
.L602_14:
    mov r10, 0
    jmp .L602_13
.L602_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L602_13:
    cmp r10, 0
    je .L602_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L602_11
.L602_10:
    mov r9, 0
.L602_11:
    mov rdi, r9
.L602_7:
    cmp rdi, 0
    jne .L602_16
    mov rax, 0
    ret
.L602_16:
    mov rsi, 0
    sub rsi, r8
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    sub rsi, r8
    mov rax, rsi
    ret
.globl zyl_bytebuf_atomic_fetch_add
zyl_bytebuf_atomic_fetch_add:
    mov r8, rdx
.L603_0:
    cmp rdi, 4096
    jl .L603_3
.L603_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L603_1
.L603_3:
    mov r9, 0
    jmp .L603_2
.L603_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L603_4
    jmp .L603_5
.L603_4:
    mov rdi, 0
.L603_5:
    mov r9, rdi
.L603_2:
    cmp r9, 0
    je .L603_8
    cmp rsi, 0
    jl .L603_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L603_6
.L603_9:
.L603_8:
    mov rdi, 0
    jmp .L603_7
.L603_6:
    cmp rsi, 0
    jl .L603_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L603_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L603_12
.L603_15:
.L603_14:
    mov r10, 0
    jmp .L603_13
.L603_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L603_13:
    cmp r10, 0
    je .L603_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L603_11
.L603_10:
    mov r9, 0
.L603_11:
    mov rdi, r9
.L603_7:
    cmp rdi, 0
    jne .L603_16
    mov rax, 0
    ret
.L603_16:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    ret
.globl zyl_bytebuf_atomic_max
zyl_bytebuf_atomic_max:
    mov r8, rdx
.L604_0:
    cmp rdi, 4096
    jl .L604_3
.L604_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L604_1
.L604_3:
    mov r9, 0
    jmp .L604_2
.L604_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L604_4
    jmp .L604_5
.L604_4:
    mov rdi, 0
.L604_5:
    mov r9, rdi
.L604_2:
    cmp r9, 0
    je .L604_8
    cmp rsi, 0
    jl .L604_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L604_6
.L604_9:
.L604_8:
    mov rdi, 0
    jmp .L604_7
.L604_6:
    cmp rsi, 0
    jl .L604_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L604_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L604_12
.L604_15:
.L604_14:
    mov r10, 0
    jmp .L604_13
.L604_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L604_13:
    cmp r10, 0
    je .L604_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L604_11
.L604_10:
    mov r9, 0
.L604_11:
    mov rdi, r9
.L604_7:
    cmp rdi, 0
    jne .L604_16
    mov rax, 0
    ret
.L604_16:
    mov rsi, r8
    jmp zyl_atomic_max
.globl zyl_bytebuf_atomic_min
zyl_bytebuf_atomic_min:
    mov r8, rdx
.L605_0:
    cmp rdi, 4096
    jl .L605_3
.L605_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L605_1
.L605_3:
    mov r9, 0
    jmp .L605_2
.L605_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L605_4
    jmp .L605_5
.L605_4:
    mov rdi, 0
.L605_5:
    mov r9, rdi
.L605_2:
    cmp r9, 0
    je .L605_8
    cmp rsi, 0
    jl .L605_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L605_6
.L605_9:
.L605_8:
    mov rdi, 0
    jmp .L605_7
.L605_6:
    cmp rsi, 0
    jl .L605_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L605_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L605_12
.L605_15:
.L605_14:
    mov r10, 0
    jmp .L605_13
.L605_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L605_13:
    cmp r10, 0
    je .L605_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L605_11
.L605_10:
    mov r9, 0
.L605_11:
    mov rdi, r9
.L605_7:
    cmp rdi, 0
    jne .L605_16
    mov rax, 0
    ret
.L605_16:
    mov rsi, r8
    jmp zyl_atomic_min
.globl zyl_bytebuf_atomic_cas
zyl_bytebuf_atomic_cas:
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L606_0:
    cmp rdi, 4096
    jl .L606_3
.L606_18:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L606_1
.L606_3:
    mov r10, 0
    jmp .L606_2
.L606_1:
    mov rbx, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp rbx, rax
    jne .L606_4
    jmp .L606_5
.L606_4:
    mov rdi, 0
.L606_5:
    mov r10, rdi
.L606_2:
    cmp r10, 0
    je .L606_8
    cmp rsi, 0
    jl .L606_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L606_6
.L606_9:
.L606_8:
    mov rdi, 0
    jmp .L606_7
.L606_6:
    cmp rsi, 0
    jl .L606_14
    mov rax, qword ptr [r10+24]
    cmp rax, 0
    jl .L606_15
    mov rbx, 8
    mov rax, qword ptr [r10+24]
    cmp rbx, rax
    jle .L606_12
.L606_15:
.L606_14:
    mov rbx, 0
    jmp .L606_13
.L606_12:
    mov r12, qword ptr [r10+24]
    sub r12, 8
    mov rax, rsi
    mov rcx, r12
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
.L606_13:
    cmp rbx, 0
    je .L606_10
    mov r10, qword ptr [r10+8]
    add r10, rsi
    jmp .L606_11
.L606_10:
    mov r10, 0
.L606_11:
    mov rdi, r10
.L606_7:
    cmp rdi, 0
    jne .L606_16
    mov rax, 0
    pop r12
    pop rbx
    ret
.L606_16:
    mov rdx, rdi
    mov rcx, r8
    mov r11, r9
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, r8
    jne .L606_17
    mov rax, 1
    pop r12
    pop rbx
    ret
.L606_17:
    mov rax, 0
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dread_x2Dall:
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
.L607_0:
    cmp r14, r13
    jl .L607_1
.L607_4:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L607_1:
    lea rsi, [r12+r14]
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L607_2
    add r14, rsi
    cmp r14, r13
    jl .L607_1
    jmp .L607_4
.L607_2:
    cmp rsi, -4
    jne .L607_3
    cmp r14, r13
    jl .L607_1
    jmp .L607_4
.L607_3:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dwrite_x2Dall:
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
.L608_0:
    cmp r14, r13
    jl .L608_1
.L608_4:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L608_1:
    lea rsi, [r12+r14]
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L608_2
    add r14, rsi
    cmp r14, r13
    jl .L608_1
    jmp .L608_4
.L608_2:
    cmp rsi, -4
    jne .L608_3
    cmp r14, r13
    jl .L608_1
    jmp .L608_4
.L608_3:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_read_file
zyl_bytebuf_read_file:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
.L609_0:
    cmp rdi, 4096
    jge .L609_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L609_1:
    mov rsi, 0
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_2
    mov rbx, rax
    cmp rbx, 0
    jge .L609_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L609_2:
    mov rsi, 0
    mov rdi, 2
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_8
    mov r12, rax
    cmp r12, 0
    jl .L609_5
    mov rsi, 0
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_8
    cmp rax, 0
    jge .L609_3
.L609_5:
    mov rsi, 0
    jmp .L609_4
.L609_3:
    mov rdi, 0
    mov rsi, r12
    call zyl_bytebuf_new
    mov rsi, rax
.L609_4:
    mov r13, rsi
    mov rsi, -1
    cmp r13, 0
    je .L609_6
    mov rdi, qword ptr [r13+8]
    mov r8, 0
    mov rsi, rdi
    mov rdi, rbx
    mov rdx, r12
    mov rcx, r8
    call zy_local_x2Fmain_0__bytes__bb_x2Dread_x2Dall
    mov rsi, rax
.L609_6:
    mov r14, rsi
    mov rdi, rbx
    call zyl_rt_sys_3
    cmp r14, r12
    jne .L609_7
    mov qword ptr [r13+16], r12
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L609_7:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_bytebuf_write_exec
zyl_bytebuf_write_exec:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdx
.L610_0:
    mov r12, rdi
    cmp rsi, 4096
    jl .L610_3
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L610_1
.L610_3:
    mov rdi, 0
    jmp .L610_2
.L610_1:
    mov r8, qword ptr [rsi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L610_4
    jmp .L610_5
.L610_4:
    mov rsi, 0
.L610_5:
    mov rdi, rsi
.L610_2:
    mov r13, rdi
    cmp r12, 4096
    jl .L610_7
    cmp r13, 0
    je .L610_8
    cmp rbx, 0
    jl .L610_11
    mov rax, qword ptr [r13+24]
    cmp rax, 0
    jl .L610_12
    mov rax, qword ptr [r13+24]
    cmp rbx, rax
    jle .L610_9
.L610_12:
.L610_11:
    mov rsi, 0
    jmp .L610_10
.L610_9:
    mov rdi, 0
    mov r8, qword ptr [r13+24]
    sub r8, rbx
    mov rax, rdi
    mov rcx, r8
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rsi, rax
.L610_10:
    cmp rsi, 0
    jne .L610_6
.L610_8:
.L610_7:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L610_6:
    mov rdi, r12
    call zyl_rt_sys_87
    mov rsi, 577
    mov rdi, 493
    mov rdx, rdi
    mov rdi, r12
    call zyl_rt_sys_2
    mov r12, rax
    cmp r12, 0
    jge .L610_13
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L610_13:
    mov rsi, qword ptr [r13+8]
    mov rdi, 0
    mov rdx, rbx
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__bytes__bb_x2Dwrite_x2Dall
    mov r13, rax
    mov rdi, r12
    call zyl_rt_sys_3
    mov rsi, rax
    cmp r13, rbx
    jne .L610_14
    cmp rsi, 0
    jne .L610_14
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L610_14:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
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
.L611_0:
    mov rdx, rdi
    cvtsi2sd xmm0, rdx
    movq rax, xmm0
    ret
.globl zyl_f_to_int
zyl_f_to_int:
.L612_0:
    mov rdx, rdi
    movq xmm0, rdx
    cvttsd2si rax, xmm0
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
    movsd xmm0, [rip+.L615]
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
    je .L613
    movsd xmm0, [rip+.L616]
    movq rax, xmm0
    jmp .L614
.L613:
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
    movsd xmm0, [rip+.L621]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm0, xmm1
    seta al
    movzx rax, al
    test rax, rax
    je .L619
    mov rax, [rbp-40]
    push rax
    movsd xmm0, [rip+.L622]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm1, xmm0
    seta al
    movzx rax, al
    jmp .L620
.L619:
    mov rax, 0
.L620:
    test rax, rax
    je .L617
    mov rax, [rbp-40]
    mov rdx, rax
    movq xmm0, rdx
    cvttsd2si rax, xmm0
    mov rdx, rax
    cvtsi2sd xmm0, rdx
    movq rax, xmm0
    jmp .L618
.L617:
    mov rax, [rbp-40]
.L618:
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
.L614:
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
    je .L623
    mov rax, -1
    jmp .L624
.L623:
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
    je .L625
    mov rax, 1
    jmp .L626
.L625:
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
    je .L627
    mov rax, 0
    jmp .L628
.L627:
    mov rax, 2
.L628:
.L626:
.L624:
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
.L629_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_timespec@tpoff]
    mov rbx, rax
    mov rdi, 1
    mov rsi, rbx
    call zyl_rt_sys_228
    cmp rax, 0
    je .L629_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L629_1:
    mov rsi, qword ptr [rbx+0]
    imul rsi, rsi, 1000
    mov rdi, qword ptr [rbx+8]
    mov rcx, rdi
    movabs rax, 4835703278458516699
    imul rcx
    sar rdx, 18
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rdi, rax
    lea rax, [rsi+rdi]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dmulhi:
.L630_0:
    mov r8, 4294967295
    and r8, rdi
    shr rdi, 32
    mov r9, 4294967295
    and r9, rsi
    shr rsi, 32
    mov r10, r8
    imul r10, r9
    imul r8, rsi
    imul r9, rdi
    shr r10, 32
    mov r11, 4294967295
    and r11, r8
    add r10, r11
    mov r11, 4294967295
    and r11, r9
    add r10, r11
    imul rsi, rdi
    mov rdi, r8
    shr rdi, 32
    add rsi, rdi
    mov rdi, r9
    shr rdi, 32
    add rsi, rdi
    mov rdi, r10
    shr rdi, 32
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dclz:
.L631_0:
    mov rsi, 0
    mov r8, 32
    mov rdx, r8
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo
zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo:
    mov r8, rdx
.L632_0:
    cmp r8, 0
    jne .L632_1
.L632_3:
    mov rax, rsi
    ret
.p2align 4
.L632_1:
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
    jne .L632_2
    mov rax, rdi
    mov rcx, r8
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    add rsi, r8
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 63
    add rax, rcx
    sar rax, 1
    mov r8, rax
    cmp r8, 0
    jne .L632_1
    jmp .L632_3
.L632_2:
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 63
    add rax, rcx
    sar rax, 1
    mov r8, rax
    cmp r8, 0
    jne .L632_1
    jmp .L632_3
zy_local_x2Fmain_0__fmt__fm_x2Disdig:
.L633_0:
    cmp rdi, 48
    jl .L633_1
.L633_2:
    mov rax, rdi
    cmp rax, 57
    setle al
    movzx rax, al
    ret
.L633_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dtab:
    push rbx
.L634_0:
    lea rax, [rip+zyl_rtg_fmt_tab]
    mov rbx, rax
    mov rax, qword ptr [rbx+10600]
    cmp rax, 1
    jne .L634_1
    mov rax, rbx
    pop rbx
    ret
.L634_1:
    lea rax, [rip+.L635]
    mov rsi, rax
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dtab_x2Dfill
    lea rdi, [rbx+10416]
    mov rsi, 0
    movsd xmm0, [rip+.L636]
    movq rax, xmm0
    mov r8, rax
    mov rdx, r8
    call zy_local_x2Fmain_0__fmt__fm_x2Dp10_x2Dfill
    mfence
    xor eax, eax
    mov rsi, 1
    mov qword ptr [rbx+10600], rsi
    mov rax, rbx
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dhex16:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rdx
.L637_0:
    cmp rsi, 16
    jne .L637_1
.L637_2:
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L637_1:
    lea r13, [rsi+1]
    shl r12, 4
    lea rdi, [rbx+rsi]
    movzx edi, byte ptr [rdi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rdi, rax
    add r12, rdi
    mov rsi, r13
    cmp rsi, 16
    jne .L637_1
    jmp .L637_2
zy_local_x2Fmain_0__fmt__fm_x2Dtab_x2Dfill:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L638_0:
    cmp r13, 1302
    jne .L638_1
.L638_3:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L638_1:
    lea rsi, [r13*8]
    lea r14, [rbx+rsi]
    mov rsi, r13
    shl rsi, 4
    lea rdi, [r12+rsi]
    mov rsi, 0
    mov r8, 0
    mov r9, r8
    cmp rsi, 16
    je .L638_2
    mov rdx, r8
    call zy_local_x2Fmain_0__fmt__fm_x2Dhex16
    mov r9, rax
.L638_2:
    mov qword ptr [r14+0], r9
    add r13, 1
    cmp r13, 1302
    jne .L638_1
    jmp .L638_3
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
    jne .L639
    mov rax, 0
    jmp .L640
.L639:
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
    movsd xmm0, [rip+.L641]
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
.L640:
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dp5_x2Dhex:
.L642_0:
    lea rax, [rip+.L643]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dspace:
.L644_0:
    cmp rdi, 32
    jne .L644_1
.L644_3:
    mov rax, 1
    ret
.L644_1:
    cmp rdi, 9
    jl .L644_2
    mov rax, rdi
    cmp rax, 13
    setle al
    movzx rax, al
    ret
.L644_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dskip_x2Dws:
.L645_0:
    movzx esi, byte ptr [rdi+0]
    mov r8, 1
    cmp rsi, 32
    je .L645_2
    mov rax, rsi
    cmp rax, 13
    setle al
    movzx rax, al
    mov r9, rax
    cmp rsi, 9
    jge .L645_3
    mov r9, 0
.L645_3:
    mov r8, r9
.L645_2:
    cmp r8, 0
    je .L645_1
    add rdi, 1
    jmp .L645_0
.L645_1:
    mov rax, rdi
    ret
.globl zyl_f_parse
zyl_f_parse:
.L646_0:
    cmp rdi, 0
    jne .L646_1
    mov rax, 0
    ret
.L646_1:
    call zy_local_x2Fmain_0__fmt__fm_x2Dskip_x2Dws
    mov rsi, rax
    movzx edi, byte ptr [rsi+0]
    cmp rdi, 45
    jne .L646_2
    lea r8, [rsi+1]
    mov rdi, r8
    call zy_local_x2Fmain_0__fmt__fm_x2Dbody
    mov r8, rax
    mov r9, -9223372036854775808
    mov rdi, r8
    mov rsi, r9
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dsigned
.L646_2:
    lea r8, [rsi+1]
    cmp rdi, 43
    je .L646_3
    mov r8, rsi
.L646_3:
    mov rdi, r8
    call zy_local_x2Fmain_0__fmt__fm_x2Dbody
    mov rdi, rax
    mov rsi, 0
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dsigned
zy_local_x2Fmain_0__fmt__fm_x2Dsigned:
.L647_0:
    cmp rdi, -1
    jne .L647_1
.L647_2:
    mov rax, 0
    ret
.L647_1:
    mov rax, rdi
    or rax, rsi
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
    jne .L648
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dinf_x2Dword
    jmp .L649
.L648:
    mov rax, [rbp-16]
    mov rcx, 110
    cmp rax, rcx
    jne .L650
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dword
    jmp .L651
.L650:
    mov rax, [rbp-8]
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov rcx, 48
    cmp rax, rcx
    jne .L654
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
    jmp .L655
.L654:
    mov rax, 0
.L655:
    test rax, rax
    je .L652
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
    jne .L656
    mov rax, 0
    jmp .L657
.L656:
    mov rax, [rbp-24]
.L657:
    jmp .L653
.L652:
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
.L653:
.L651:
.L649:
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dinf_x2Dword:
.L658_0:
    movzx esi, byte ptr [rdi+1]
    or rsi, 32
    cmp rsi, 110
    jne .L658_1
    movzx esi, byte ptr [rdi+2]
    or rsi, 32
    cmp rsi, 102
    jne .L658_1
    mov rax, 9218868437227405312
    ret
.L658_1:
    mov rax, -1
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dword:
    push rbx
.L659_0:
    movzx esi, byte ptr [rdi+1]
    or rsi, 32
    cmp rsi, 97
    jne .L659_1
    movzx esi, byte ptr [rdi+2]
    or rsi, 32
    cmp rsi, 110
    jne .L659_1
    movzx eax, byte ptr [rdi+3]
    cmp rax, 40
    jne .L659_2
    lea rbx, [rdi+4]
    add rdi, 4
    call zy_local_x2Fmain_0__fmt__fm_x2Dseq_x2Dend
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dseq
.L659_2:
    mov rax, 9221120237041090560
    pop rbx
    ret
.L659_1:
    mov rax, -1
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dalnum:
    push rbx
    mov rbx, rdi
.L660_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Disdig
    cmp rax, 0
    je .L660_1
    mov rax, 1
    pop rbx
    ret
.L660_1:
    mov rax, rbx
    or rax, 32
    cmp rax, 97
    jl .L660_2
    mov rax, rbx
    or rax, 32
    cmp rax, 122
    jg .L660_2
    mov rax, 1
    pop rbx
    ret
.L660_2:
    mov rax, rbx
    cmp rax, 95
    sete al
    movzx rax, al
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dseq_x2Dend:
    push rbx
    mov rbx, rdi
.L661_0:
    movzx edi, byte ptr [rbx+0]
    call zy_local_x2Fmain_0__fmt__fm_x2Dalnum
    cmp rax, 0
    je .L661_1
    add rbx, 1
    jmp .L661_0
.L661_1:
    mov rax, rbx
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dseq:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L662_0:
    movzx eax, byte ptr [r12+0]
    cmp rax, 41
    je .L662_1
    mov rax, 9221120237041090560
    pop r12
    pop rbx
    ret
.L662_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dend
    cmp rax, r12
    jne .L662_2
    mov r12, 9221120237041090560
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull
    mov rsi, rax
    mov rdi, 2251799813685247
    and rsi, rdi
    or r12, rsi
    mov rax, r12
    pop r12
    pop rbx
    ret
.L662_2:
    mov rax, 9221120237041090560
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok:
    push rbx
    mov rbx, rsi
.L663_0:
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L663_1
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setl al
    movzx rax, al
    pop rbx
    ret
.L663_1:
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase:
.L664_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 48
    jne .L664_1
    movzx esi, byte ptr [rdi+1]
    or rsi, 32
    cmp rsi, 120
    jne .L664_2
    movzx edi, byte ptr [rdi+2]
    mov rsi, 16
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    je .L664_2
    mov rax, 16
    ret
.L664_2:
    mov rax, 8
    ret
.L664_1:
    mov rax, 10
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dend:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L665_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase
    mov r12, rax
    lea rsi, [rbx+2]
    cmp r12, 16
    je .L665_1
    mov rsi, rbx
.L665_1:
    mov r13, rsi
    movzx edi, byte ptr [r13+0]
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    je .L665_2
    mov rdi, r13
    mov rsi, r12
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__fm_x2Ddigits_x2Dend
.L665_2:
    mov rax, rbx
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Ddigits_x2Dend:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L666_0:
    movzx edi, byte ptr [rbx+0]
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    je .L666_1
    add rbx, 1
    jmp .L666_0
.L666_1:
    mov rax, rbx
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull:
    push rbx
    mov rbx, rdi
.L667_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase
    mov rsi, rax
    lea rdi, [rbx+2]
    cmp rsi, 16
    je .L667_1
    mov rdi, rbx
.L667_1:
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    pop rbx
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
.L668_0:
    mov rdx, qword ptr [rbp-48]
    movzx r15d, byte ptr [rdx+0]
    mov rdi, r15
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    jne .L668_1
    cmp r14, 0
    je .L668_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L668_2:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L668_1:
    cmp r14, 0
    je .L668_3
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov r14, 1
    jmp .L668_0
.L668_3:
    mov rbx, r13
    imul rbx, r12
    mov rdi, r15
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    lea r15, [rbx+rsi]
    mov rdi, r13
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dmulhi
    cmp rax, 0
    jne .L668_5
    mov rsi, -9223372036854775808
    xor rsi, r15
    mov rdi, -9223372036854775808
    mov rax, rbx
    xor rax, rdi
    cmp rsi, rax
    jge .L668_4
.L668_5:
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov r14, 1
    jmp .L668_0
.L668_4:
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov r13, r15
    mov r14, 0
    jmp .L668_0
zy_local_x2Fmain_0__fmt__fm_x2Dexp:
    push rbx
.L669_0:
    movzx esi, byte ptr [rdi+0]
    mov rax, rsi
    cmp rax, 45
    sete al
    movzx rax, al
    mov rbx, rax
    cmp rsi, 45
    je .L669_3
    cmp rsi, 43
    jne .L669_1
.L669_3:
    lea rsi, [rdi+1]
    jmp .L669_2
.L669_1:
    mov rsi, rdi
.L669_2:
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dgo
    mov rsi, rax
    cmp rbx, 0
    je .L669_4
    mov rdi, 0
    sub rdi, rsi
    mov rax, rdi
    pop rbx
    ret
.L669_4:
    mov rax, rsi
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dgo:
.L670_0:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 48
    jl .L670_1
    cmp r8, 57
    jg .L670_1
    lea r9, [rdi+1]
    mov rax, 1000000000000000
    cmp rsi, rax
    jge .L670_2
    imul r10, rsi, 10
    sub r8, 48
    add r10, r8
    jmp .L670_3
.L670_2:
    mov r10, rsi
.L670_3:
    mov rsi, r10
    mov rdi, r9
    jmp .L670_0
.L670_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat:
.L671_0:
    movzx r8d, byte ptr [rdi+0]
    or r8, 32
    cmp r8, rsi
    jne .L671_1
    add rdi, 1
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dexp
.L671_1:
    mov rax, 0
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
.L672_0:
    movzx r12d, byte ptr [rbx+0]
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L672_1
    mov rax, qword ptr [rbp-48]
    shr rax, 56
    cmp rax, 0
    jne .L672_2
    add rbx, 1
    mov rax, qword ptr [rbp-48]
    imul rax, 16
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-48]
    mov rcx, rsi
    add rax, rcx
    mov qword ptr [rbp-48], rax
    mov r15, 1
    jmp .L672_0
.L672_2:
    lea rdi, [rbx+1]
    lea r8, [r13+4]
    cmp r14, 0
    je .L672_3
    mov r9, 1
    jmp .L672_4
.L672_3:
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov r9, rax
.L672_4:
    mov r14, r9
    mov r15, 1
    mov rbx, rdi
    mov r13, r8
    jmp .L672_0
.L672_1:
    cmp r12, 46
    jne .L672_5
    lea rdi, [rbx+1]
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
.L672_5:
    cmp r15, 0
    je .L672_6
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
.L672_6:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fh_x2Dfrac:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L673_0:
    movzx edi, byte ptr [rbx+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L673_1
    mov rax, r12
    shr rax, 56
    cmp rax, 0
    jne .L673_2
    add rbx, 1
    shl r12, 4
    add r12, rsi
    sub r13, 4
    mov r15, 1
    jmp .L673_0
.L673_2:
    lea rdi, [rbx+1]
    cmp r14, 0
    je .L673_3
    mov r8, 1
    jmp .L673_4
.L673_3:
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov r8, rax
.L673_4:
    mov r14, r8
    mov r15, 1
    mov rbx, rdi
    jmp .L673_0
.L673_1:
    cmp r15, 0
    je .L673_5
    mov rsi, 112
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat
    mov rsi, rax
    add rsi, r13
    mov rdi, r12
    mov rdx, r14
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__fh_x2Dround
.L673_5:
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fh_x2Dround:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L674_0:
    cmp rbx, 0
    jne .L674_1
.L674_8:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L674_1:
    mov r14, 63
    mov rsi, 0
    mov rdi, 32
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo
    mov rsi, rax
    sub r14, rsi
    add r14, r12
    cmp r14, 1023
    jle .L674_2
    mov rax, 9218868437227405312
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L674_2:
    mov rsi, -1074
    cmp r14, -1022
    jl .L674_3
    lea rsi, [r14-52]
.L674_3:
    sub rsi, r12
    cmp rsi, 0
    jg .L674_4
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
    jmp .L674_5
.L674_4:
    mov rdi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__fmt__fh_x2Dshift_x2Dround
    mov rdi, rax
.L674_5:
    mov rsi, rdi
    cmp r14, -1022
    jl .L674_6
    lea r8, [r14+1022]
    shl r8, 52
    lea rsi, [rdi+r8]
.L674_6:
    mov rax, 9218868437227405312
    cmp rsi, rax
    jl .L674_7
    mov rax, 9218868437227405312
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L674_7:
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fh_x2Dshift_x2Dround:
    mov r8, rdx
.L675_0:
    cmp rsi, 62
    jle .L675_1
.L675_5:
    mov rax, 0
    ret
.L675_1:
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
    jg .L675_3
    cmp rdi, rsi
    jne .L675_2
    cmp r8, 0
    jne .L675_4
    mov rax, r9
    and rax, 1
    cmp rax, 1
    jne .L675_2
.L675_4:
.L675_3:
    lea rax, [r9+1]
    ret
.L675_2:
    mov rax, r9
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
    jl .L678
    mov rax, [rbp-64]
    mov rcx, 57
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L679
.L678:
    mov rax, 0
.L679:
    test rax, rax
    je .L676
    mov rax, [rbp-56]
    test rax, rax
    je .L680
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    jmp .L681
.L680:
    mov rax, [rbp-40]
.L681:
    mov [rbp-72], rax
    mov rax, [rbp-32]
    mov rcx, 0
    cmp rax, rcx
    jne .L684
    mov rax, [rbp-64]
    mov rcx, 48
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L685
.L684:
    mov rax, 0
.L685:
    test rax, rax
    je .L682
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
    jmp .L683
.L682:
    mov rax, [rbp-32]
    mov rcx, 19
    cmp rax, rcx
    jge .L686
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
    jmp .L687
.L686:
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
.L687:
.L683:
    jmp .L677
.L676:
    mov rax, [rbp-64]
    mov rcx, 46
    cmp rax, rcx
    jne .L690
    mov rax, [rbp-56]
    test rax, rax
    je .L692
    mov rax, 0
    jmp .L693
.L692:
    mov rax, 1
.L693:
    jmp .L691
.L690:
    mov rax, 0
.L691:
    test rax, rax
    je .L688
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
    jmp .L689
.L688:
    mov rax, [rbp-48]
    test rax, rax
    je .L696
    mov rax, 0
    jmp .L697
.L696:
    mov rax, 1
.L697:
    test rax, rax
    je .L694
    mov rax, -1
    jmp .L695
.L694:
    sub rsp, 16
    mov rdi, [rbp-16]
    mov rsi, 101
call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat
    add rsp, 16
    mov [rbp-80], rax
    mov rax, [rbp-32]
    mov rcx, 0
    cmp rax, rcx
    jne .L698
    mov rax, 0
    jmp .L699
.L698:
    mov rax, [rbp-32]
    mov rcx, 19
    cmp rax, rcx
    jg .L700
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
    jmp .L701
.L700:
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
.L701:
.L699:
.L695:
.L689:
.L677:
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
    jl .L706
    mov rax, [rbp-16]
    mov rcx, 22
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L707
.L706:
    mov rax, 0
.L707:
    test rax, rax
    je .L704
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jl .L708
    mov rax, [rbp-8]
    mov rcx, 9007199254740992
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L709
.L708:
    mov rax, 0
.L709:
    jmp .L705
.L704:
    mov rax, 0
.L705:
    test rax, rax
    je .L702
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
    jl .L710
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
    jmp .L711
.L710:
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
.L711:
    jmp .L703
.L702:
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
.L703:
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fd_x2Dinexact:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L712_0:
    mov rdi, r14
    mov rsi, r13
    call zy_local_x2Fmain_0__fmt__fm_x2Del
    mov r15, rax
    lea rsi, [r13+1]
    mov rdi, r14
    call zy_local_x2Fmain_0__fmt__fm_x2Del
    cmp r15, rax
    jne .L712_1
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L712_1:
    mov rdi, rbx
    mov rsi, r12
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
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
.L713_0:
    cmp rbx, -342
    jge .L713_1
.L713_6:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L713_1:
    cmp rbx, 308
    jle .L713_2
    mov rax, 9218868437227405312
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L713_2:
    mov rsi, 0
    mov rdi, 32
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo
    mov r13, rax
    mov rax, r12
    mov rcx, r13
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r12, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dtab
    mov r14, rax
    lea rsi, [rbx+342]
    shl rsi, 4
    add r14, rsi
    mov rsi, qword ptr [r14+0]
    mov r15, r12
    imul r15, rsi
    mov rsi, qword ptr [r14+0]
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dmulhi
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-48]
    and rax, 511
    cmp rax, 511
    jne .L713_3
    mov rsi, qword ptr [r14+8]
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dmulhi
    mov rsi, rax
    add rsi, r15
    mov rdi, -9223372036854775808
    xor rdi, rsi
    mov r8, -9223372036854775808
    mov rax, r15
    xor rax, r8
    cmp rdi, rax
    jge .L713_4
    mov rdi, qword ptr [rbp-48]
    add rdi, 1
    jmp .L713_5
.L713_4:
    mov rdi, qword ptr [rbp-48]
.L713_5:
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
.L713_3:
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
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L714_0:
    mov r10, r9
    shr r10, 63
    lea r11, [r10+9]
    mov rax, r9
    mov rcx, r11
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    imul r12, rdi, 217706
    sar r12, 16
    add r12, 63
    add r12, r10
    mov rax, r12
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    add rsi, 1023
    cmp rsi, 0
    jg .L714_1
    mov r10, 0
    sub r10, rsi
    lea rax, [r10+1]
    cmp rax, 64
    jl .L714_2
    mov rax, 0
    pop r12
    pop rbx
    ret
.L714_2:
    mov r10, 0
    sub r10, rsi
    add r10, 1
    mov rax, rbx
    mov rcx, r10
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
    mov r12, r10
    and r12, 1
    add r10, r12
    shr r10, 1
    mov rax, r10
    pop r12
    pop rbx
    ret
.L714_1:
    mov r10, -9223372036854775808
    xor r8, r10
    mov r10, -9223372036854775808
    xor r10, 2
    cmp r8, r10
    jge .L714_3
    cmp rdi, -4
    jl .L714_3
    cmp rdi, 23
    jg .L714_3
    mov rax, rbx
    and rax, 3
    cmp rax, 1
    jne .L714_3
    mov rax, rbx
    mov rcx, r11
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    cmp rax, r9
    jne .L714_3
    mov rdi, rbx
    and rdi, -2
    jmp .L714_4
.L714_3:
    mov rdi, rbx
.L714_4:
    mov r8, rdi
    and r8, 1
    add rdi, r8
    shr rdi, 1
    lea r8, [rsi+1]
    mov rax, 9007199254740992
    cmp rdi, rax
    jge .L714_5
    mov r8, rsi
.L714_5:
    mov rsi, 0
    mov rax, 9007199254740992
    cmp rdi, rax
    jge .L714_6
    mov r9, 4503599627370495
    mov rsi, rdi
    and rsi, r9
.L714_6:
    cmp r8, 2047
    jl .L714_7
    mov rax, 9218868437227405312
    pop r12
    pop rbx
    ret
.L714_7:
    mov rdi, r8
    shl rdi, 52
    mov rax, rsi
    or rax, rdi
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dbuf:
.L715_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_fmt_dec@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dparse:
    push rbx
    push r12
    mov rbx, rsi
.L716_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_fmt_dec@tpoff]
    mov r12, rax
    mov rsi, 0
    mov qword ptr [r12+0], rsi
    mov rsi, 0
    mov qword ptr [r12+8], rsi
    mov rsi, 0
    mov qword ptr [r12+16], rsi
    mov rsi, 0
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__sd_x2Dread
    mov rsi, qword ptr [r12+8]
    add rsi, rbx
    mov qword ptr [r12+8], rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__sd_x2Dtrim
    mov rdi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dbits
zy_local_x2Fmain_0__fmt__sd_x2Dread:
    push rbx
    mov r8, rdx
.L717_0:
    movzx r9d, byte ptr [rsi+0]
    cmp r9, 48
    jl .L717_1
    cmp r9, 57
    jg .L717_1
    mov r10, qword ptr [rdi+0]
    cmp r10, 0
    jne .L717_2
    cmp r9, 48
    jne .L717_2
    cmp r8, 0
    je .L717_3
    mov r11, qword ptr [rdi+8]
    sub r11, 1
    mov qword ptr [rdi+8], r11
    jmp .L717_4
.L717_3:
.L717_4:
    add rsi, 1
    jmp .L717_0
.L717_2:
    cmp r10, 800
    jge .L717_5
    lea r11, [rdi+32]
    add r11, r10
    lea rbx, [r9-48]
    mov byte ptr [r11+0], bl
    add r10, 1
    mov qword ptr [rdi+0], r10
    jmp .L717_6
.L717_5:
    cmp r9, 48
    je .L717_7
    mov r10, 1
    mov qword ptr [rdi+16], r10
.L717_7:
.L717_6:
    cmp r8, 0
    je .L717_8
    jmp .L717_9
.L717_8:
    mov r10, qword ptr [rdi+8]
    add r10, 1
    mov qword ptr [rdi+8], r10
.L717_9:
    add rsi, 1
    jmp .L717_0
.L717_1:
    cmp r9, 46
    jne .L717_10
    cmp r8, 0
    jne .L717_10
    add rsi, 1
    mov r8, 1
    jmp .L717_0
.L717_10:
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dtrim:
.L718_0:
    mov rsi, qword ptr [rdi+0]
    cmp rsi, 0
    jle .L718_1
    lea r8, [rdi+32]
    lea r9, [rsi-1]
    add r8, r9
    movzx eax, byte ptr [r8+0]
    cmp rax, 0
    jne .L718_1
    lea r8, [rsi-1]
    mov qword ptr [rdi+0], r8
    jmp .L718_0
.L718_1:
    cmp rsi, 0
    jne .L718_2
    mov rsi, 0
    mov qword ptr [rdi+8], rsi
    mov rax, rsi
    ret
.L718_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dshift:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L719_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L719_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L719_1:
    cmp r12, 25
    jle .L719_2
    mov rsi, 25
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dlshift
    sub r12, 25
    jmp .L719_0
.L719_2:
    cmp r12, 0
    jle .L719_3
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dlshift
.L719_3:
    cmp r12, -59
    jge .L719_4
    mov rsi, 59
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
    add r12, 59
    jmp .L719_0
.L719_4:
    cmp r12, 0
    jge .L719_5
    mov rsi, 0
    sub rsi, r12
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
.L719_5:
    mov rax, 0
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Drshift:
.L720_0:
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread:
    mov r8, rdx
    mov r9, rcx
.L721_0:
    mov rax, r9
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    cmp rax, 0
    jne .L721_1
    mov rax, qword ptr [rdi+0]
    cmp r8, rax
    jl .L721_2
    cmp r9, 0
    jne .L721_3
    mov r10, 0
    mov qword ptr [rdi+0], r10
    mov r10, 0
    mov qword ptr [rdi+8], r10
    mov rax, r10
    ret
.L721_3:
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dpad
.L721_2:
    lea r10, [r8+1]
    imul r9, r9, 10
    lea r11, [rdi+32]
    add r11, r8
    movzx r11d, byte ptr [r11+0]
    add r9, r11
    mov r8, r10
    jmp .L721_0
.L721_1:
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dpad:
    mov r8, rdx
    mov r9, rcx
.L722_0:
    mov rax, r9
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    cmp rax, 0
    jne .L722_1
    add r8, 1
    imul r9, r9, 10
    jmp .L722_0
.L722_1:
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart:
    mov r8, rdx
    mov r9, rcx
.L723_0:
    mov r10, qword ptr [rdi+8]
    lea r11, [r8-1]
    sub r10, r11
    mov qword ptr [rdi+8], r10
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
    mov r11, 0
    mov rdx, r10
    mov rcx, r8
    mov r8, r11
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dwrite
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dwrite:
    push rbx
    push r12
    push r13
    mov r10, r8
    mov r8, rdx
    mov r11, r9
    mov r9, rcx
.L724_0:
    mov rax, qword ptr [rdi+0]
    cmp r9, rax
    jge .L724_1
    lea rbx, [rdi+32]
    add rbx, r10
    mov rax, r11
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r12, rax
    mov byte ptr [rbx+0], r12b
    lea rbx, [r9+1]
    add r10, 1
    mov r12, r11
    and r12, r8
    imul r12, r12, 10
    lea r13, [rdi+32]
    add r13, r9
    movzx r13d, byte ptr [r13+0]
    lea r11, [r12+r13]
    mov r9, rbx
    jmp .L724_0
.L724_1:
    mov rdx, r8
    mov rcx, r10
    mov r8, r11
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dtail
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dtail:
    push rbx
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L725_0:
    cmp r10, 0
    jle .L725_1
.L725_5:
    mov rax, r10
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r11, rax
    cmp r9, 800
    jge .L725_2
    lea rbx, [rdi+32]
    add rbx, r9
    mov byte ptr [rbx+0], r11b
    add r9, 1
    and r10, r8
    imul r10, r10, 10
    cmp r10, 0
    jle .L725_1
    jmp .L725_5
.L725_2:
    cmp r11, 0
    jle .L725_3
    mov r11, 1
    mov qword ptr [rdi+16], r11
    jmp .L725_4
.L725_3:
.L725_4:
    and r10, r8
    imul r10, r10, 10
    cmp r10, 0
    jle .L725_1
    jmp .L725_5
.L725_1:
    mov qword ptr [rdi+0], r9
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dtrim
zy_local_x2Fmain_0__fmt__fm_x2Dndig:
.L726_0:
    cmp rdi, 10
    jge .L726_1
.L726_2:
    mov rax, rsi
    ret
.p2align 4
.L726_1:
    mov rcx, rdi
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 2
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rdi, rax
    add rsi, 1
    cmp rdi, 10
    jge .L726_1
    jmp .L726_2
zy_local_x2Fmain_0__fmt__fm_x2Dpow5:
.L727_0:
    cmp rdi, 0
    jne .L727_1
.L727_2:
    mov rax, rsi
    ret
.p2align 4
.L727_1:
    sub rdi, 1
    imul rsi, rsi, 5
    cmp rdi, 0
    jne .L727_1
    jmp .L727_2
zy_local_x2Fmain_0__fmt__sd_x2Dprefix:
    push rbx
    mov r8, rdx
    mov r9, rcx
.L728_0:
    cmp rsi, r8
    jne .L728_1
.L728_4:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L728_1:
    lea r10, [rsi+1]
    imul r11, r9, 10
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jge .L728_2
    lea rbx, [rdi+32]
    add rbx, rsi
    movzx ebx, byte ptr [rbx+0]
    jmp .L728_3
.L728_2:
    mov rbx, 0
.L728_3:
    lea r9, [r11+rbx]
    mov rsi, r10
    cmp rsi, r8
    jne .L728_1
    jmp .L728_4
zy_local_x2Fmain_0__fmt__sd_x2Ddelta:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L729_0:
    mov rsi, 1
    mov rdi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dpow5
    mov r13, rax
    mov rsi, 1
    mov rdi, r13
    call zy_local_x2Fmain_0__fmt__fm_x2Dndig
    mov r14, rax
    mov rsi, 1
    mov rax, rsi
    mov rcx, r12
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    mov rsi, 1
    call zy_local_x2Fmain_0__fmt__fm_x2Dndig
    mov r12, rax
    mov rsi, 0
    mov rdi, 0
    mov rdx, r14
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dprefix
    cmp rax, r13
    jge .L729_1
    lea rax, [r12-1]
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L729_1:
    mov rax, r12
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dlshift:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L730_0:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__sd_x2Ddelta
    mov r13, rax
    mov r14, qword ptr [rbx+0]
    lea rsi, [r14-1]
    lea rdi, [r14+r13]
    mov r8, 0
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dgo
    lea rsi, [r14+r13]
    mov rdi, 800
    cmp rsi, 800
    jge .L730_1
    mov rdi, rsi
.L730_1:
    mov qword ptr [rbx+0], rdi
    mov rsi, qword ptr [rbx+8]
    add rsi, r13
    mov qword ptr [rbx+8], rsi
    mov rdi, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dtrim
zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dput:
    mov r8, rdx
.L731_0:
    cmp rsi, 800
    jge .L731_1
.L731_3:
    lea r9, [rdi+32]
    add r9, rsi
    mov byte ptr [r9+0], r8b
    mov rsi, r8
    mov rax, rsi
    ret
.L731_1:
    cmp r8, 0
    jne .L731_2
    mov rax, 0
    ret
.L731_2:
    mov rsi, 1
    mov qword ptr [rdi+16], rsi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dgo:
    push rbx
    push r12
    push r13
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L732_0:
    cmp r8, 0
    jl .L732_1
.L732_9:
    lea r11, [rdi+32]
    add r11, r8
    movzx r11d, byte ptr [r11+0]
    mov rax, r11
    mov rcx, rsi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r11, rax
    add r11, r10
    mov rcx, r11
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 2
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rbx, rax
    lea r12, [r9-1]
    imul r13, rbx, 10
    sub r11, r13
    cmp r12, 800
    jge .L732_2
    lea r13, [rdi+32]
    add r13, r12
    mov byte ptr [r13+0], r11b
    jmp .L732_3
.L732_2:
    cmp r11, 0
    je .L732_4
    mov r11, 1
    mov qword ptr [rdi+16], r11
.L732_4:
.L732_3:
    sub r8, 1
    sub r9, 1
    mov r10, rbx
    cmp r8, 0
    jl .L732_1
    jmp .L732_9
.p2align 4
.L732_1:
    cmp r10, 0
    jle .L732_5
    mov rcx, r10
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 2
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov r11, rax
    lea rbx, [r9-1]
    imul r12, r11, 10
    mov rax, r10
    mov rcx, r12
    sub rax, rcx
    mov r12, rax
    cmp rbx, 800
    jge .L732_6
    lea r13, [rdi+32]
    add r13, rbx
    mov byte ptr [r13+0], r12b
    jmp .L732_7
.L732_6:
    cmp r12, 0
    je .L732_8
    mov rbx, 1
    mov qword ptr [rdi+16], rbx
.L732_8:
.L732_7:
    mov r8, -1
    sub r9, 1
    mov r10, r11
    cmp r8, 0
    jl .L732_1
    jmp .L732_9
.L732_5:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dpowtab:
.L733_0:
    cmp rdi, 0
    jne .L733_1
.L733_9:
    mov rax, 1
    ret
.L733_1:
    cmp rdi, 1
    jne .L733_2
    mov rax, 3
    ret
.L733_2:
    cmp rdi, 2
    jne .L733_3
    mov rax, 6
    ret
.L733_3:
    cmp rdi, 3
    jne .L733_4
    mov rax, 9
    ret
.L733_4:
    cmp rdi, 4
    jne .L733_5
    mov rax, 13
    ret
.L733_5:
    cmp rdi, 5
    jne .L733_6
    mov rax, 16
    ret
.L733_6:
    cmp rdi, 6
    jne .L733_7
    mov rax, 19
    ret
.L733_7:
    cmp rdi, 7
    jne .L733_8
    mov rax, 23
    ret
.L733_8:
    mov rax, 26
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dstep:
.L734_0:
    cmp rdi, 9
    jl .L734_1
.L734_2:
    mov rax, 27
    ret
.L734_1:
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dpowtab
zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Ddown:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L735_0:
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jle .L735_1
    mov rdi, qword ptr [rbx+8]
    call zy_local_x2Fmain_0__fmt__sd_x2Dstep
    mov r13, rax
    mov rsi, 0
    sub rsi, r13
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    add r12, r13
    jmp .L735_0
.L735_1:
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Dup:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L736_0:
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jl .L736_2
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L736_1
    lea rsi, [rbx+32]
    movzx eax, byte ptr [rsi+0]
    cmp rax, 5
    jge .L736_1
.L736_2:
    mov rdi, 0
    mov rsi, qword ptr [rbx+8]
    sub rdi, rsi
    call zy_local_x2Fmain_0__fmt__sd_x2Dstep
    mov r13, rax
    mov rdi, rbx
    mov rsi, r13
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    sub r12, r13
    jmp .L736_0
.L736_1:
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dbits:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L737_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L737_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L737_1:
    mov rax, qword ptr [rbx+8]
    cmp rax, 310
    jle .L737_2
    mov rax, 9218868437227405312
    pop r13
    pop r12
    pop rbx
    ret
.L737_2:
    mov rax, qword ptr [rbx+8]
    cmp rax, -330
    jge .L737_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L737_3:
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Ddown
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Dup
    mov r12, rax
    sub r12, 1
    cmp r12, -1022
    jge .L737_4
    mov r13, -1022
    sub r13, r12
    mov rsi, 0
    sub rsi, r13
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    lea rsi, [r12+r13]
    jmp .L737_5
.L737_4:
    mov rsi, r12
.L737_5:
    mov r12, rsi
    lea rax, [r12+1023]
    cmp rax, 2047
    jl .L737_6
    mov rax, 9218868437227405312
    pop r13
    pop r12
    pop rbx
    ret
.L737_6:
    mov rsi, 53
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Drounded
    mov rsi, rax
    lea rdi, [r12+1]
    mov rax, 9007199254740992
    cmp rsi, rax
    je .L737_7
    mov rdi, r12
.L737_7:
    mov r8, 4503599627370496
    mov rax, 9007199254740992
    cmp rsi, rax
    je .L737_8
    mov r8, rsi
.L737_8:
    lea rax, [rdi+1023]
    cmp rax, 2047
    jl .L737_9
    mov rax, 9218868437227405312
    pop r13
    pop r12
    pop rbx
    ret
.L737_9:
    mov rsi, 4503599627370496
    mov rax, r8
    and rax, rsi
    cmp rax, 0
    jne .L737_10
    mov rsi, -1023
    jmp .L737_11
.L737_10:
    mov rsi, rdi
.L737_11:
    mov rdi, 4503599627370495
    and rdi, r8
    add rsi, 1023
    and rsi, 2047
    shl rsi, 52
    or rdi, rsi
    mov rax, rdi
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dint:
    push rbx
    mov r8, rdx
    mov r9, rcx
.L738_0:
    cmp rsi, r8
    jl .L738_1
.L738_4:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L738_1:
    lea r10, [rsi+1]
    imul r11, r9, 10
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jge .L738_2
    lea rbx, [rdi+32]
    add rbx, rsi
    movzx ebx, byte ptr [rbx+0]
    jmp .L738_3
.L738_2:
    mov rbx, 0
.L738_3:
    lea r9, [r11+rbx]
    mov rsi, r10
    cmp rsi, r8
    jl .L738_1
    jmp .L738_4
zy_local_x2Fmain_0__fmt__sd_x2Drounded:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L739_0:
    mov r12, qword ptr [rbx+8]
    mov rsi, 0
    mov rdi, 0
    mov rdx, r12
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dint
    mov r13, rax
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__sd_x2Dround_x2Dup
    cmp rax, 0
    je .L739_1
    lea rax, [r13+1]
    pop r13
    pop r12
    pop rbx
    ret
.L739_1:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dround_x2Dup:
.L740_0:
    cmp rsi, 0
    jl .L740_2
.L740_6:
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jl .L740_1
.L740_2:
    mov rax, 0
    ret
.L740_1:
    lea r8, [rdi+32]
    add r8, rsi
    movzx eax, byte ptr [r8+0]
    cmp rax, 5
    jne .L740_3
    lea r8, [rsi+1]
    mov rax, qword ptr [rdi+0]
    cmp r8, rax
    jne .L740_3
    mov rax, qword ptr [rdi+16]
    cmp rax, 1
    jne .L740_4
    mov rax, 1
    ret
.L740_4:
    cmp rsi, 0
    jle .L740_5
    lea r8, [rdi+32]
    lea r9, [rsi-1]
    add r8, r9
    movzx r8d, byte ptr [r8+0]
    and r8, 1
    mov rax, r8
    cmp rax, 1
    sete al
    movzx rax, al
    ret
.L740_5:
    mov rax, 0
    ret
.L740_3:
    add rdi, 32
    add rdi, rsi
    movzx esi, byte ptr [rdi+0]
    mov rax, rsi
    cmp rax, 5
    setge al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_f_text
zyl_f_text:
.L741_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext
.globl zyl_f_text_r
zyl_f_text_r:
.L742_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext
zy_local_x2Fmain_0__fmt__fm_x2Dtext:
.L743_0:
    mov rax, rdi
    cmp rax, 0
    setl al
    movzx rax, al
    mov r8, rax
    mov r9, 9223372036854775807
    and rdi, r9
    mov r9, rdi
    shr r9, 52
    mov r10, 4503599627370495
    and rdi, r10
    cmp r9, 2047
    jne .L743_1
    cmp rdi, 0
    jne .L743_2
    cmp r8, 0
    je .L743_3
    lea rax, [rip+.L744]
    mov r10, rax
    mov r11, 4
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L743_3:
    lea rax, [rip+.L745]
    mov r10, rax
    mov r11, 3
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L743_2:
    cmp r8, 0
    je .L743_4
    lea rax, [rip+.L746]
    mov r10, rax
    mov r11, 4
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L743_4:
    lea rax, [rip+.L747]
    mov r10, rax
    mov r11, 3
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L743_1:
    mov r10, rdi
    cmp r9, 0
    je .L743_5
    mov r11, 4503599627370496
    mov r10, rdi
    or r10, r11
.L743_5:
    mov rdi, -1074
    cmp r9, 0
    je .L743_6
    lea rdi, [r9-1075]
.L743_6:
    cmp rdi, 10
    jle .L743_7
    mov rdx, rdi
    mov rdi, r8
    mov rcx, rsi
    mov rsi, r10
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dbig
.L743_7:
    cmp rdi, 0
    jl .L743_8
    mov rax, r10
    mov rcx, rdi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r9, rax
    mov r11, 0
    mov rdi, r8
    mov rdx, r11
    mov rcx, rsi
    mov rsi, r9
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dsmall
.L743_8:
    mov r9, 0
    sub r9, rdi
    mov rdi, r8
    mov rdx, r9
    mov rcx, rsi
    mov rsi, r10
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
.L748_0:
    cmp r12, 76
    jl .L748_1
.L748_8:
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
.L748_1:
    mov rax, rsi
    mov rcx, r12
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    cmp r12, 64
    jl .L748_2
    mov rdi, 0
.L748_2:
    mov r14, rdi
    cmp r12, 64
    jge .L748_3
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
    jmp .L748_4
.L748_3:
    mov rdi, rsi
.L748_4:
    imul r15, rdi, 1000000
    mov rsi, 1000000
    call zy_local_x2Fmain_0__fmt__fm_x2Dmulhi
    mov rbx, rax
    mov rdi, r12
    mov rsi, r15
    mov rdx, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dfrac_x2Dq
    mov r13, rax
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
    cmp rax, 0
    je .L748_5
    lea rsi, [r13+1]
    jmp .L748_6
.L748_5:
    mov rsi, r13
.L748_6:
    cmp rsi, 1000000
    jne .L748_7
    lea rdi, [r14+1]
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
.L748_7:
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
    mov r8, rdx
.L749_0:
    cmp rdi, 64
    jge .L749_1
.L749_2:
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
    ret
.L749_1:
    lea rsi, [rdi-64]
    mov rax, r8
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dfrac_x2Dup:
    push rbx
    mov r8, rdx
    mov r9, rcx
.L750_0:
    cmp rdi, 64
    jge .L750_1
.L750_10:
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
    mov r11, 1
    lea rbx, [rdi-1]
    mov rax, r11
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r11, rax
    cmp r10, r11
    jle .L750_2
    mov rax, 1
    pop rbx
    ret
.L750_2:
    cmp r10, r11
    jne .L750_3
    mov rax, r9
    pop rbx
    ret
.L750_3:
    mov rax, 0
    pop rbx
    ret
.L750_1:
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
    mov r10, 0
    cmp rdi, 0
    je .L750_4
    mov r11, 1
    lea rbx, [rdi-1]
    mov rax, r11
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
.L750_4:
    mov r11, -9223372036854775808
    cmp rdi, 0
    je .L750_5
    mov r11, 0
.L750_5:
    cmp r8, r10
    jle .L750_6
    mov rax, 1
    pop rbx
    ret
.L750_6:
    cmp r8, r10
    jne .L750_7
    mov rdi, -9223372036854775808
    xor rdi, r11
    mov r8, -9223372036854775808
    mov rax, rsi
    xor rax, r8
    cmp rdi, rax
    jge .L750_8
    mov rax, 1
    pop rbx
    ret
.L750_8:
    cmp rsi, r11
    jne .L750_9
    mov rax, r9
    pop rbx
    ret
.L750_9:
    mov rax, 0
    pop rbx
    ret
.L750_7:
    mov rax, 0
    pop rbx
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
.L751_0:
    cmp rbx, 0
    je .L751_1
.L751_5:
    mov rsi, 1
    jmp .L751_2
.L751_1:
    mov rsi, 0
.L751_2:
    mov r15, rsi
    mov rdi, 0
    sub rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dndigits
    mov r13, rax
    mov rax, r15
    mov rcx, r13
    add rax, rcx
    mov qword ptr [rbp-56], rax
    mov rax, qword ptr [rbp-56]
    add rax, 7
    mov qword ptr [rbp-56], rax
    mov rdi, qword ptr [rbp-56]
    add rdi, 1
    mov rsi, r14
    call zyl_ralloc
    mov r14, rax
    cmp rbx, 0
    je .L751_3
    mov rsi, 45
    mov rcx, rsi
    mov byte ptr [r14+0], cl
    jmp .L751_4
.L751_3:
.L751_4:
    mov rsi, 0
    sub rsi, r12
    lea rdi, [r15+r13]
    sub rdi, 1
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    lea rsi, [r15+r13]
    add rsi, r14
    mov rdi, 46
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    lea rsi, [r15+r13]
    add rsi, 1
    lea rdi, [r14+rsi]
    mov rsi, 6
    call zy_local_x2Fmain_0__fmt__fm_x2Dzeros
    mov rsi, 0
    sub rsi, qword ptr [rbp-48]
    mov rdi, qword ptr [rbp-56]
    sub rdi, 1
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    mov rsi, r14
    add rsi, qword ptr [rbp-56]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
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
.L752_0:
    cmp rsi, 0
    jne .L752_1
.L752_2:
    mov rax, 0
    ret
.p2align 4
.L752_1:
    mov r8, 48
    mov byte ptr [rdi+0], r8b
    add rdi, 1
    sub rsi, 1
    cmp rsi, 0
    jne .L752_1
    jmp .L752_2
zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dbig:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov rdi, rdx
    mov r12, rcx
.L753_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_fmt_big@tpoff]
    mov r13, rax
    mov rcx, rsi
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    imul rdx, rdx, 1000000000
    mov rax, rcx
    sub rax, rdx
    mov r8, rax
    mov qword ptr [r13+0], r8
    mov rcx, rsi
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rsi, rax
    mov qword ptr [r13+8], rsi
    mov rsi, 2
    mov rdx, rdi
    mov rdi, r13
    call zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dshift
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    mov rcx, r12
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dout
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dshift:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rdx
.L754_0:
    cmp r12, 0
    jne .L754_1
.L754_3:
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L754_1:
    mov rdi, 32
    cmp r12, 32
    jg .L754_2
    mov rdi, r12
.L754_2:
    mov r13, rdi
    mov rdi, 0
    mov r8, 0
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, rbx
    mov rcx, r13
    call zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dmul
    mov rsi, rax
    sub r12, r13
    cmp r12, 0
    jne .L754_1
    jmp .L754_3
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dmul:
    push rbx
    push r12
    push r13
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L755_0:
    cmp rsi, r8
    jge .L755_1
.L755_3:
    lea r11, [rsi*8]
    add r11, rdi
    mov r11, qword ptr [r11+0]
    mov rax, r11
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r11, rax
    add r11, r10
    mov rcx, r11
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rbx, rax
    lea r12, [rsi*8]
    add r12, rdi
    imul r13, rbx, 1000000000
    sub r11, r13
    mov qword ptr [r12+0], r11
    add rsi, 1
    mov r10, rbx
    cmp rsi, r8
    jge .L755_1
    jmp .L755_3
.p2align 4
.L755_1:
    cmp r10, 0
    jle .L755_2
    mov rcx, r10
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov r11, rax
    lea rbx, [rsi*8]
    add rbx, rdi
    imul r12, r11, 1000000000
    mov rax, r10
    mov rcx, r12
    sub rax, rcx
    mov r12, rax
    mov qword ptr [rbx+0], r12
    add rsi, 1
    add r8, 1
    mov r10, r11
    cmp rsi, r8
    jge .L755_1
    jmp .L755_3
.L755_2:
    mov rax, r8
    pop r13
    pop r12
    pop rbx
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
.L756_0:
    cmp rbx, 0
    je .L756_1
.L756_5:
    mov rsi, 1
    jmp .L756_2
.L756_1:
    mov rsi, 0
.L756_2:
    mov qword ptr [rbp-48], rsi
    lea rsi, [r13-1]
    shl rsi, 3
    add rsi, qword ptr [rbp-56]
    mov r15, qword ptr [rsi+0]
    mov rdi, 0
    sub rdi, r15
    call zy_local_x2Fmain_0__text__rt_x2Dndigits
    mov r12, rax
    lea rsi, [r13-1]
    imul rsi, rsi, 9
    mov rax, r12
    mov rcx, rsi
    add rax, rcx
    mov qword ptr [rbp-64], rax
    mov rax, qword ptr [rbp-48]
    mov rcx, qword ptr [rbp-64]
    add rax, rcx
    mov qword ptr [rbp-72], rax
    mov rax, qword ptr [rbp-72]
    add rax, 7
    mov qword ptr [rbp-72], rax
    mov rdi, qword ptr [rbp-72]
    add rdi, 1
    mov rsi, r14
    call zyl_ralloc
    mov r14, rax
    cmp rbx, 0
    je .L756_3
    mov rsi, 45
    mov rcx, rsi
    mov byte ptr [r14+0], cl
    jmp .L756_4
.L756_3:
.L756_4:
    mov rdi, r14
    add rdi, qword ptr [rbp-48]
    mov rsi, qword ptr [rbp-64]
    call zy_local_x2Fmain_0__fmt__fm_x2Dzeros
    mov rsi, 0
    sub rsi, r15
    mov rdi, qword ptr [rbp-48]
    add rdi, r12
    sub rdi, 1
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    lea rsi, [r13-2]
    mov rdi, qword ptr [rbp-48]
    add rdi, r12
    add rdi, 8
    mov rdx, rsi
    mov rsi, qword ptr [rbp-56]
    mov rcx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dlimbs
    mov rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-64]
    add rsi, r14
    mov rdi, 46
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-64]
    add rsi, 1
    lea rdi, [r14+rsi]
    mov rsi, 6
    call zy_local_x2Fmain_0__fmt__fm_x2Dzeros
    mov rsi, r14
    add rsi, qword ptr [rbp-72]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
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
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L757_0:
    cmp r13, 0
    jge .L757_1
.L757_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L757_1:
    mov rsi, 0
    lea rdi, [r13*8]
    add rdi, r12
    mov rdi, qword ptr [rdi+0]
    sub rsi, rdi
    mov rdi, rbx
    mov rdx, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    sub r13, 1
    add r14, 9
    cmp r13, 0
    jge .L757_1
    jmp .L757_2
zy_local_x2Fmain_0__out__ou_x2Dst:
.L758_0:
    lea rax, [rip+zyl_rtg_out_state]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Dbuf:
.L759_0:
    lea rax, [rip+zyl_rtg_out_buf]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Dlock:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L760_0:
    mov rsi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L760_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L760_1:
    call zyl_rt_sys_24
    jmp .L760_0
zy_local_x2Fmain_0__out__ou_x2Dunlock:
.L761_0:
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 0
    ret
zy_local_x2Fmain_0__out__ou_x2Dinit:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L762_0:
    mov rax, qword ptr [rbx+16]
    cmp rax, 0
    jle .L762_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L762_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_stat@tpoff]
    mov r12, rax
    mov rdi, 1
    mov rsi, r12
    call zyl_rt_sys_5
    cmp rax, 0
    jne .L762_2
    mov rsi, qword ptr [r12+56]
    jmp .L762_3
.L762_2:
    mov rsi, 0
.L762_3:
    cmp rsi, 0
    jle .L762_4
    cmp rsi, 8192
    jge .L762_4
    jmp .L762_5
.L762_4:
    mov rsi, 8192
.L762_5:
    mov qword ptr [rbx+24], rsi
    mov rdi, 1
    mov rsi, 21505
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_tios@tpoff]
    mov r8, rax
    mov rdx, r8
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L762_6
    mov rsi, 2
    jmp .L762_7
.L762_6:
    mov rsi, 1
.L762_7:
    mov qword ptr [rbx+16], rsi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__out__ou_x2Dsys_x2Dall:
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
.L763_0:
    cmp r13, 0
    jg .L763_1
.L763_4:
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L763_1:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L763_2
    add r12, rsi
    sub r13, rsi
    cmp r13, 0
    jg .L763_1
    jmp .L763_4
.L763_2:
    cmp rsi, -4
    jne .L763_3
    cmp r13, 0
    jg .L763_1
    jmp .L763_4
.L763_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked:
.L764_0:
    mov rsi, qword ptr [rdi+8]
    cmp rsi, 0
    jne .L764_1
    mov rax, 1
    ret
.L764_1:
    mov r8, 0
    mov qword ptr [rdi+8], r8
    mov rdi, 1
    lea rax, [rip+zyl_rtg_out_buf]
    mov r8, rax
    mov rdx, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__out__ou_x2Dsys_x2Dall
zy_local_x2Fmain_0__out__ou_x2Dappend:
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
.L765_0:
    cmp r13, 0
    jg .L765_1
.L765_5:
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L765_1:
    mov rdx, qword ptr [rbp-48]
    mov r14, qword ptr [rdx+8]
    mov rdx, qword ptr [rbp-48]
    mov r15, qword ptr [rdx+24]
    sub r15, r14
    mov rsi, r13
    cmp r13, r15
    jl .L765_2
    mov rsi, r15
.L765_2:
    mov rbx, rsi
    lea rax, [rip+zyl_rtg_out_buf]
    mov rdi, rax
    add rdi, r14
    mov rsi, r12
    mov rdx, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r14+rbx]
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+8], rsi
    cmp rbx, r15
    jne .L765_3
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked
    cmp rax, 0
    je .L765_4
    add r12, rbx
    sub r13, rbx
    cmp r13, 0
    jg .L765_1
    jmp .L765_5
.L765_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L765_3:
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__out__ou_x2Dput_x2Dfull:
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
.L766_0:
    mov rdx, qword ptr [rbp-48]
    mov r14, qword ptr [rdx+8]
    mov rdx, qword ptr [rbp-48]
    mov r15, qword ptr [rdx+24]
    mov rax, r15
    sub rax, r14
    cmp r13, rax
    jg .L766_1
    lea rax, [rip+zyl_rtg_out_buf]
    mov rdi, rax
    add rdi, r14
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r14+r13]
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+8], rsi
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L766_1:
    mov rbx, r15
    sub rbx, r14
    lea rax, [rip+zyl_rtg_out_buf]
    mov rdi, rax
    add rdi, r14
    mov rsi, r12
    mov rdx, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+8], r15
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked
    cmp rax, 0
    jne .L766_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L766_2:
    sub r13, rbx
    cmp r15, 128
    jl .L766_3
    mov rax, r13
    mov rcx, r15
    cqo
    idiv rcx
    mov rax, rdx
    mov rsi, rax
    jmp .L766_4
.L766_3:
    mov rsi, 0
.L766_4:
    mov r14, r13
    sub r14, rsi
    cmp r14, 0
    jle .L766_5
    mov rdi, 1
    lea rsi, [r12+rbx]
    mov rdx, r14
    call zy_local_x2Fmain_0__out__ou_x2Dsys_x2Dall
    cmp rax, 0
    jne .L766_5
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L766_5:
    lea rsi, [rbx+r14]
    add rsi, r12
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dappend
zy_local_x2Fmain_0__out__ou_x2Dlast_x2Dnl:
.L767_0:
    cmp rsi, 0
    jge .L767_1
.L767_3:
    mov rax, -1
    ret
.p2align 4
.L767_1:
    lea r8, [rdi+rsi]
    movzx eax, byte ptr [r8+0]
    cmp rax, 10
    jne .L767_2
    mov rax, rsi
    ret
.L767_2:
    sub rsi, 1
    cmp rsi, 0
    jge .L767_1
    jmp .L767_3
zy_local_x2Fmain_0__out__ou_x2Dput_x2Dline:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L768_0:
    lea rsi, [r13-1]
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dlast_x2Dnl
    mov r14, rax
    cmp r14, 0
    jge .L768_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__out__ou_x2Dappend
.L768_1:
    lea rsi, [r14+1]
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dappend
    cmp rax, 0
    je .L768_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked
    cmp rax, 0
    je .L768_2
    lea rsi, [r14+1]
    add rsi, r12
    lea rdi, [r14+1]
    mov rax, r13
    mov rcx, rdi
    sub rax, rcx
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__out__ou_x2Dappend
.L768_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__out__ou_x2Downer_x2Dcell:
.L769_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_owner_self
zyl_owner_self:
.L770_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L770_1
    mov rax, 1
    ret
.L770_1:
    mov rax, rsi
    ret
.globl zyl_owner_set
zyl_owner_set:
.L771_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__out__ou_x2Dabuf:
.L772_0:
    lea rax, [rip+zyl_rtg_actor_out]
    mov rsi, rax
    imul rdi, rdi, 24
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Debuf:
.L773_0:
    lea rax, [rip+zyl_rtg_actor_err]
    mov rsi, rax
    imul rdi, rdi, 24
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Dabuf_x2Dput:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L774_0:
    mov r14, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+16]
    lea rax, [r14+r13]
    cmp rax, rsi
    jg .L774_1
    mov rdi, 1
    jmp .L774_2
.L774_1:
    lea r8, [rsi*2]
    lea rax, [r14+r13]
    cmp r8, rax
    jge .L774_3
    lea r8, [r13+256]
    add r8, r14
    jmp .L774_4
.L774_3:
    lea r8, [rsi*2]
.L774_4:
    mov r15, r8
    mov rsi, qword ptr [rbx+0]
    mov rdi, rsi
    mov rsi, r15
    call zyl_rt_realloc
    mov rsi, rax
    mov r8, 0
    cmp rsi, 0
    je .L774_5
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+16], r15
    mov r8, 1
.L774_5:
    mov rdi, r8
.L774_2:
    mov rax, rdi
    cmp rax, 0
    je .L774_6
    mov rdi, qword ptr [rbx+0]
    add rdi, r14
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r14+r13]
    mov qword ptr [rbx+8], rsi
    mov rax, 1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L774_6:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_out_actor_emit
zyl_out_actor_emit:
    push rbx
    mov rbx, rdi
.L775_0:
    cmp rbx, 2
    jl .L775_2
.L775_3:
    cmp rbx, 1025
    jle .L775_1
.L775_2:
    mov rax, 0
    pop rbx
    ret
.L775_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dabuf
    mov rdi, rax
    mov rsi, 0
    call zy_local_x2Fmain_0__out__ou_x2Demit
    mov rdi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Debuf
    mov rdi, rax
    mov rsi, 1
    pop rbx
    jmp zy_local_x2Fmain_0__out__ou_x2Demit
zy_local_x2Fmain_0__out__ou_x2Demit:
    push rbx
.L776_0:
    mov rbx, qword ptr [rdi+0]
    mov r8, qword ptr [rdi+8]
    mov r9, 0
    mov qword ptr [rdi+0], r9
    mov r9, 0
    mov qword ptr [rdi+8], r9
    mov r9, 0
    mov qword ptr [rdi+16], r9
    cmp rbx, 0
    jne .L776_1
    mov rax, 0
    pop rbx
    ret
.L776_1:
    cmp rsi, 0
    je .L776_2
    mov rdi, rbx
    mov rsi, r8
    call zyl_err_write
    jmp .L776_3
.L776_2:
    mov rdi, rbx
    mov rsi, r8
    call zyl_out_write
.L776_3:
    mov rdi, rbx
    call zyl_rt_free
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__out__ou_x2Dput:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L777_0:
    call zyl_owner_self
    mov rdi, rax
    cmp rdi, 2
    jl .L777_1
    call zy_local_x2Fmain_0__out__ou_x2Dabuf
    mov rdi, rax
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__out__ou_x2Dabuf_x2Dput
.L777_1:
    mov rax, qword ptr [rbx+16]
    cmp rax, 2
    jne .L777_2
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__out__ou_x2Dput_x2Dline
.L777_2:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__out__ou_x2Dput_x2Dfull
zy_local_x2Fmain_0__out__ou_x2Dputs:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L778_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__out__ou_x2Dput
.globl zyl_out_write
zyl_out_write:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L779_0:
    lea rax, [rip+zyl_rtg_out_state]
    mov r13, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__out__ou_x2Dlock
    mov rdi, r13
    call zy_local_x2Fmain_0__out__ou_x2Dinit
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__out__ou_x2Dput
    mov rsi, 0
    mov rdx, r13
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_out_puts
zyl_out_puts:
    push rbx
    mov rbx, rdi
.L780_0:
    cmp rbx, 0
    jne .L780_1
.L780_2:
    mov rax, 0
    pop rbx
    ret
.L780_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    jmp zyl_out_write
.globl zyl_out_flush
zyl_out_flush:
    push rbx
.L781_0:
    lea rax, [rip+zyl_rtg_out_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L781_1
    mov rax, 0
    pop rbx
    ret
.L781_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dlock
    mov rdi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked
    mov rsi, 0
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 0
    pop rbx
    ret
.globl zyl_err_write
zyl_err_write:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L782_0:
    call zyl_owner_self
    mov rdi, rax
    cmp rdi, 2
    jl .L782_1
    call zy_local_x2Fmain_0__out__ou_x2Debuf
    mov rdi, rax
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__out__ou_x2Dabuf_x2Dput
    mov rax, 0
    pop r12
    pop rbx
    ret
.L782_1:
    mov rdi, 2
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__out__ou_x2Dsys_x2Dall
    mov rax, 0
    pop r12
    pop rbx
    ret
.globl zyl_err_puts
zyl_err_puts:
    push rbx
    mov rbx, rdi
.L783_0:
    cmp rbx, 0
    jne .L783_1
.L783_2:
    mov rax, 0
    pop rbx
    ret
.L783_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    jmp zyl_err_write
zy_local_x2Fmain_0__out__ou_x2Ddigits:
.L784_0:
    lea r8, [rsi-1]
    mov r9, 10
    mov rdx, rdi
    mov rcx, r9
    mov rax, rdx
    xor edx, edx
    div rcx
    mov rax, rdx
    mov r9, rax
    add r9, 48
    mov byte ptr [r8+0], r9b
    mov r9, 10
    mov rdx, rdi
    mov rcx, r9
    mov rax, rdx
    xor edx, edx
    div rcx
    mov r9, rax
    cmp r9, 0
    jne .L784_1
    mov rax, r8
    ret
.L784_1:
    mov rdi, r9
    mov rsi, r8
    jmp .L784_0
zy_local_x2Fmain_0__out__ou_x2Dint:
    push rbx
    mov rbx, rdi
.L785_0:
    mov rdi, 0
    sub rdi, rbx
    cmp rbx, 0
    jl .L785_1
    mov rdi, rbx
.L785_1:
    call zy_local_x2Fmain_0__out__ou_x2Ddigits
    mov rsi, rax
    cmp rbx, 0
    jge .L785_2
    lea rdi, [rsi-1]
    mov r8, 45
    mov byte ptr [rdi+0], r8b
    lea rax, [rsi-1]
    pop rbx
    ret
.L785_2:
    mov rax, rsi
    pop rbx
    ret
.globl zyl_out_int
zyl_out_int:
    push rbx
.L786_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_int@tpoff]
    mov rbx, rax
    add rbx, 31
    mov rsi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dint
    mov rdi, rax
    mov rsi, rbx
    sub rsi, rdi
    pop rbx
    jmp zyl_out_write
.globl zyl_print_int
zyl_print_int:
    push rbx
.L787_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_int@tpoff]
    mov rbx, rax
    add rbx, 31
    mov rsi, 10
    mov rcx, rsi
    mov byte ptr [rbx+0], cl
    mov rsi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dint
    mov rdi, rax
    lea rsi, [rbx+1]
    sub rsi, rdi
    call zyl_out_write
    mov rax, 0
    pop rbx
    ret
.globl zyl_print_str
zyl_print_str:
    push rbx
    push r12
    push r13
.L788_0:
    mov rbx, rdi
    lea rax, [rip+zyl_rtg_out_state]
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dlock
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dinit
    cmp rbx, 0
    jne .L788_1
    lea rax, [rip+.L789]
    mov r13, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__out__ou_x2Dput
    jmp .L788_2
.L788_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dput
.L788_2:
    lea rax, [rip+.L790]
    mov rsi, rax
    mov rdi, 1
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dput
    mov rsi, 0
    mov rdx, r12
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_print_float
zyl_print_float:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L791_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_frame@tpoff]
    mov r12, rax
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r13, rax
    mov rdi, r12
    call zyl_region_enter
    mov rax, r12
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dtext
    mov rbx, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    lea rdi, [rbx+rsi]
    mov r8, 10
    mov byte ptr [rdi+0], r8b
    add rsi, 1
    mov rdi, rbx
    call zyl_out_write
    mov rdi, r12
    call zyl_region_exit
    mov rax, r13
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__os__os_x2Dret:
.L792_0:
    cmp rdi, 0
    jge .L792_1
.L792_2:
    mov rax, -1
    ret
.L792_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__os__os_x2Dbad:
.L793_0:
    cmp rdi, 0
    jle .L793_1
.L793_2:
    cmp rdi, 4096
    jge .L793_1
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 1
    ret
.L793_1:
    mov rax, 0
    ret
.globl zyl_file_open_c
zyl_file_open_c:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L794_0:
    mov r8, 0
    cmp rsi, 4096
    jl .L794_1
    movzx r8d, byte ptr [rsi+0]
.L794_1:
    mov rsi, 0
    cmp r8, 114
    je .L794_2
    mov r9, 1089
    cmp r8, 97
    je .L794_3
    mov r9, 577
.L794_3:
    mov rsi, r9
.L794_2:
    mov r8, 420
    mov rdx, r8
    call zyl_rt_sys_2
    mov rsi, rax
    cmp rsi, 0
    jge .L794_4
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L794_4:
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
.L795_0:
    mov r8, 0
    cmp rsi, 0
    jl .L795_1
    mov r9, 67108864
    cmp rsi, 67108864
    jg .L795_2
    mov r9, rsi
.L795_2:
    mov r8, r9
.L795_1:
    mov r12, r8
    lea rsi, [r12+1]
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_ralloc
    mov r13, rax
    cmp r13, 0
    jne .L795_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L795_3:
    mov rdi, rbx
    mov rsi, r13
    mov rdx, r12
    call zyl_rt_sys_0
    mov rsi, rax
    mov rdi, 0
    cmp rsi, 0
    jl .L795_4
    mov rdi, rsi
.L795_4:
    lea rsi, [r13+rdi]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_file_read_c
zyl_file_read_c:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L796_0:
    cmp rbx, 0
    jne .L796_1
.L796_3:
    call zyl_out_flush
    jmp .L796_2
.L796_1:
.L796_2:
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__os__os_x2Dread
.globl zyl_file_read_c_r
zyl_file_read_c_r:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L797_0:
    cmp rbx, 0
    jne .L797_1
.L797_3:
    call zyl_out_flush
    jmp .L797_2
.L797_1:
.L797_2:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__os__os_x2Dread
.globl zyl_file_write_c
zyl_file_write_c:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L798_0:
    mov r12, rsi
    cmp r12, 0
    jne .L798_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L798_1:
    lea rax, [rip+.L799]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L798_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L798_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    cmp rbx, 1
    jne .L798_3
    mov rdi, r12
    mov rsi, r13
    call zyl_out_write
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L798_3:
    cmp rbx, 2
    jne .L798_4
    call zyl_owner_self
    cmp rax, 2
    jl .L798_4
    mov rdi, r12
    mov rsi, r13
    call zyl_err_write
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L798_4:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jge .L798_5
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L798_5:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_file_close_c
zyl_file_close_c:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L800_0:
    call zyl_rt_sys_3
    mov rsi, rax
    cmp rsi, 0
    jge .L800_1
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L800_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_path_exists
zyl_path_exists:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L801_0:
    mov rsi, 0
    call zyl_rt_sys_21
    cmp rax, 0
    jne .L801_1
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L801_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_chdir
zyl_chdir:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L802_0:
    call zyl_rt_sys_80
    mov rsi, rax
    cmp rsi, 0
    jge .L802_1
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L802_1:
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
.L803_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_cwd@tpoff]
    mov rbx, rax
    mov rsi, 4096
    mov rdi, rbx
    call zyl_rt_sys_79
    cmp rax, 0
    jle .L803_2
    movzx eax, byte ptr [rbx+0]
    cmp rax, 47
    je .L803_1
.L803_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L803_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    lea rdi, [r12+1]
    call zyl_heap_alloc
    mov r13, rax
    cmp r13, 0
    jne .L803_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L803_3:
    lea rsi, [r12+1]
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mkdir_p
zyl_mkdir_p:
    push rbx
    push r12
    push r13
.L804_0:
    mov rbx, rdi
    cmp rbx, 0
    je .L804_2
    lea rax, [rip+.L805]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L804_1
.L804_2:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L804_1:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L804_3
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L804_3:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    cmp r12, 4096
    jl .L804_4
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L804_4:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_mkdir@tpoff]
    mov r13, rax
    lea rsi, [r12+1]
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, 1
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Dparents
    cmp rax, 0
    je .L804_5
    mov rdi, r13
    call zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Done
    cmp rax, 0
    je .L804_6
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L804_6:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L804_5:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Done:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L806_0:
    mov rsi, 493
    call zyl_rt_sys_83
    mov rsi, rax
    cmp rsi, 0
    jne .L806_1
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L806_1:
    mov rax, rsi
    cmp rax, -17
    sete al
    movzx rax, al
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
.L807_0:
    cmp r13, r12
    jl .L807_1
.L807_5:
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L807_1:
    lea rsi, [rbx+r13]
    movzx eax, byte ptr [rsi+0]
    cmp rax, 47
    jne .L807_2
    lea rsi, [rbx+r13]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, 493
    mov rdi, rbx
    call zyl_rt_sys_83
    mov rsi, rax
    mov rdi, 1
    cmp rsi, 0
    je .L807_3
    mov rax, rsi
    cmp rax, -17
    sete al
    movzx rax, al
    mov rdi, rax
.L807_3:
    lea rsi, [rbx+r13]
    mov r8, 47
    mov byte ptr [rsi+0], r8b
    cmp rdi, 0
    je .L807_4
    add r13, 1
    cmp r13, r12
    jl .L807_1
    jmp .L807_5
.L807_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L807_2:
    add r13, 1
    cmp r13, r12
    jl .L807_1
    jmp .L807_5
.globl zyl_save_args
zyl_save_args:
.L808_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov r8, rax
    mov r9, 4294967295
    and rdi, r9
    mov r9, 4294967296
    mov rax, rdi
    mov rcx, r9
    sub rax, rcx
    mov r9, rax
    cmp rdi, 2147483647
    jg .L808_1
    mov r9, rdi
.L808_1:
    mov qword ptr [r8+0], r9
    mov qword ptr [r8+8], rsi
    mov rdi, 0
    cmp rsi, 0
    je .L808_2
    lea r8, [r9+1]
    shl r8, 3
    lea rdi, [rsi+r8]
.L808_2:
    jmp zyl_rt_set_env
.globl zyl_argc
zyl_argc:
.L809_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_arg_str
zyl_arg_str:
.L810_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov rsi, rax
    cmp rdi, 0
    jl .L810_2
    mov rax, qword ptr [rsi+0]
    cmp rdi, rax
    jl .L810_1
.L810_2:
    mov rax, 0
    ret
.L810_1:
    mov rsi, qword ptr [rsi+8]
    shl rdi, 3
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__os__os_x2Dcat3:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    mov rbx, rdi
    mov r12, rsi
    mov qword ptr [rbp-48], rdx
    mov r14, rcx
.L811_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r15, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov qword ptr [rbp-56], rax
    mov rsi, r13
    add rsi, qword ptr [rbp-56]
    add rsi, r15
    lea rax, [r14-1]
    cmp rsi, rax
    jle .L811_1
    lea rdi, [r14-1]
    jmp .L811_2
.L811_1:
    mov rdi, rsi
.L811_2:
    mov r14, rdi
    lea rdi, [r14+1]
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov qword ptr [rbp-64], rax
    cmp qword ptr [rbp-64], 0
    jne .L811_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L811_3:
    mov rsi, 0
    mov rdi, qword ptr [rbp-64]
    mov rdx, rbx
    mov rcx, r15
    mov r8, r14
    call zy_local_x2Fmain_0__os__os_x2Dput
    mov rdi, qword ptr [rbp-64]
    mov rsi, r15
    mov rdx, r12
    mov rcx, r13
    mov r8, r14
    call zy_local_x2Fmain_0__os__os_x2Dput
    lea rsi, [r15+r13]
    mov rdi, qword ptr [rbp-64]
    mov rdx, qword ptr [rbp-48]
    mov rcx, qword ptr [rbp-56]
    mov r8, r14
    call zy_local_x2Fmain_0__os__os_x2Dput
    mov rsi, qword ptr [rbp-64]
    add rsi, r14
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
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
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L812_0:
    cmp rsi, r10
    jl .L812_1
.L812_4:
    mov rax, 0
    ret
.L812_1:
    add rdi, rsi
    lea rax, [rsi+r9]
    cmp rax, r10
    jle .L812_2
    mov rax, r10
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    jmp .L812_3
.L812_2:
    mov rsi, r9
.L812_3:
    mov rdx, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy
zy_local_x2Fmain_0__os__os_x2Dsep:
.L813_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 0
    jne .L813_1
    lea rax, [rip+.L814]
    mov rsi, rax
    mov rax, rsi
    ret
.L813_1:
    lea rax, [rip+.L815]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__os__os_x2Dhas_x2Dsuffix:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov rdi, rdx
.L816_0:
    call zy_local_x2Fmain_0__os__os_x2Dskip_x2Dsp
    mov r13, rax
    movzx eax, byte ptr [r13+0]
    cmp rax, 0
    jne .L816_1
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L816_1:
    mov rdi, r13
    call zy_local_x2Fmain_0__os__os_x2Dword_x2Dend
    mov r14, rax
    mov rsi, r14
    sub rsi, r13
    cmp rsi, 0
    jle .L816_2
    cmp r12, rsi
    jle .L816_2
    mov r8, r12
    sub r8, rsi
    add r8, rbx
    mov rdi, r8
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    cmp rax, 0
    je .L816_2
    mov rax, 1
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L816_2:
    mov rdi, r14
    jmp .L816_0
zy_local_x2Fmain_0__os__os_x2Dskip_x2Dsp:
.L817_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 32
    jne .L817_1
    add rdi, 1
    jmp .L817_0
.L817_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__os__os_x2Dword_x2Dend:
.L818_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 0
    je .L818_2
    cmp rsi, 32
    jne .L818_1
.L818_2:
    mov rax, rdi
    ret
.L818_1:
    add rdi, 1
    jmp .L818_0
zy_local_x2Fmain_0__os__os_x2Dpush:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L819_0:
    mov rsi, qword ptr [rbx+8]
    mov rdi, qword ptr [rbx+16]
    cmp rsi, rdi
    jne .L819_1
    mov r8, 64
    cmp rdi, 0
    je .L819_2
    lea r8, [rdi*2]
.L819_2:
    mov r13, r8
    mov rdi, qword ptr [rbx+0]
    lea r8, [r13*8]
    mov rsi, r8
    call zyl_rt_realloc
    mov rdi, rax
    cmp rdi, 0
    jne .L819_3
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    jmp zyl_rt_free
.L819_3:
    mov qword ptr [rbx+0], rdi
    mov qword ptr [rbx+16], r13
    jmp .L819_0
.L819_1:
    mov rdi, qword ptr [rbx+0]
    lea r8, [rsi*8]
    add rdi, r8
    mov qword ptr [rdi+0], r12
    add rsi, 1
    mov qword ptr [rbx+8], rsi
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
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
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L820_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dsep
    mov rsi, rax
    mov rdi, 4096
    mov rdx, r12
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dcat3
    mov r15, rax
    cmp r15, 0
    jne .L820_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L820_1:
    mov rsi, 591872
    mov rdi, 0
    mov rdx, rdi
    mov rdi, r15
    call zyl_rt_sys_2
    mov qword ptr [rbp-48], rax
    mov rdi, r15
    call zyl_rt_free
    cmp qword ptr [rbp-48], 0
    jge .L820_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L820_2:
    mov rdi, 32768
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    je .L820_3
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    mov r8, qword ptr [rbp-48]
    mov r9, r15
    call zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dfill
.L820_3:
    mov rdi, r15
    call zyl_rt_free
    mov rdi, qword ptr [rbp-48]
    call zyl_rt_sys_3
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
    jg .L821
    mov rax, 0
    jmp .L822
.L821:
    mov rax, 0
    mov [rbp-72], rax
    mov rax, [rbp-72]
    mov rcx, [rbp-56]
    cmp rax, rcx
    jl .L823
    mov rax, 0
    jmp .L824
.L823:
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
    mov rax, [rbp-72]
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
.L824:
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
.L822:
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
    jl .L825
    mov rax, 0
    jmp .L826
.L825:
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
    jne .L827
    mov rax, 0
    jmp .L828
.L827:
    sub rsp, 8
    sub rsp, 40
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    mov rdx, [rbp-24]
    mov rcx, [rbp-32]
    mov r8, [rbp-72]
call zy_local_x2Fmain_0__os__os_x2Dwalk_x2Done
    add rsp, 48
.L828:
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
.L826:
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
.L829_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dsep
    mov rsi, rax
    mov rdi, 4096
    mov rdx, r15
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dcat3
    mov qword ptr [rbp-48], rax
    cmp qword ptr [rbp-48], 0
    jne .L829_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L829_1:
    lea rax, [rip+.L830]
    mov rsi, rax
    mov rdi, 8200
    mov rdx, qword ptr [rbp-48]
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dcat3
    mov r15, rax
    cmp r15, 0
    jne .L829_2
    mov rdi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_free
.L829_2:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_stat@tpoff]
    mov r12, rax
    mov rdi, r15
    mov rsi, r12
    call zyl_rt_sys_4
    mov r14, rax
    mov rdi, r15
    call zyl_rt_free
    cmp r14, 0
    je .L829_3
    mov rdi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_free
.L829_3:
    mov esi, dword ptr [r12+24]
    and rsi, 61440
    cmp rsi, 16384
    jne .L829_4
    mov rdi, rbx
    mov rsi, qword ptr [rbp-48]
    mov rdx, r13
    mov rcx, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__os__os_x2Dwalk
    mov rdi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_free
.L829_4:
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    mov rdx, r13
    call zy_local_x2Fmain_0__os__os_x2Dhas_x2Dsuffix
    cmp rax, 0
    je .L829_5
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
.L829_5:
    mov rdi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_free
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
    jge .L831
    mov rax, 0
    jmp .L832
.L831:
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
.L832:
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
    jl .L835
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    cmp rax, rcx
    setge al
    movzx rax, al
    jmp .L836
.L835:
    mov rax, 0
.L836:
    test rax, rax
    je .L833
    mov rax, 0
    jmp .L834
.L833:
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    cmp rax, rcx
    jl .L839
    mov rax, 1
    jmp .L840
.L839:
    mov rax, [rbp-24]
    mov rcx, [rbp-32]
    cmp rax, rcx
    jge .L841
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
    jmp .L842
.L841:
    mov rax, 0
.L842:
.L840:
    test rax, rax
    je .L837
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
    jmp .L838
.L837:
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
.L838:
.L834:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dtotal:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rdx
    mov r13, rcx
.L843_0:
    cmp rsi, r12
    jl .L843_1
.L843_2:
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L843_1:
    lea r14, [rsi+1]
    lea rdi, [rsi*8]
    add rdi, rbx
    mov rdi, qword ptr [rdi+0]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rdi, rax
    add rdi, 1
    add r13, rdi
    mov rsi, r14
    cmp rsi, r12
    jl .L843_1
    jmp .L843_2
zy_local_x2Fmain_0__os__os_x2Demit:
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
    mov qword ptr [rbp-48], r8
.L844_0:
    cmp r12, r13
    jl .L844_1
.L844_2:
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L844_1:
    lea rsi, [r12*8]
    add rsi, qword ptr [rbp-56]
    mov r15, qword ptr [rsi+0]
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rbx, rax
    mov rdi, r14
    add rdi, qword ptr [rbp-48]
    mov rsi, r15
    mov rdx, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, qword ptr [rbp-48]
    add rsi, rbx
    add rsi, r14
    mov rdi, 10
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rdi, r15
    call zyl_rt_free
    add r12, 1
    lea rsi, [rbx+1]
    mov rax, qword ptr [rbp-48]
    mov rcx, rsi
    add rax, rcx
    mov qword ptr [rbp-48], rax
    cmp r12, r13
    jl .L844_1
    jmp .L844_2
zy_local_x2Fmain_0__os__os_x2Dfree_x2Dall:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L845_0:
    cmp r12, r13
    jl .L845_1
.L845_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L845_1:
    lea rsi, [r12*8]
    add rsi, rbx
    mov rdi, qword ptr [rsi+0]
    call zyl_rt_free
    add r12, 1
    cmp r12, r13
    jl .L845_1
    jmp .L845_2
zy_local_x2Fmain_0__os__os_x2Djoin:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L846_0:
    mov r12, qword ptr [rbx+0]
    mov r13, qword ptr [rbx+8]
    mov rsi, 0
    cmp r13, 2
    jl .L846_1
    lea rdi, [r13*8]
    mov r8, 1
    mov rsi, r8
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
.L846_1:
    mov r14, rsi
    cmp r14, 0
    je .L846_2
    mov rsi, 0
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r14
    mov rcx, r13
    call zy_local_x2Fmain_0__os__os_x2Dsort
    mov rdi, r14
    call zyl_rt_free
.L846_2:
    mov rsi, 0
    mov rdi, 1
    mov rdx, r13
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dtotal
    mov rdi, rax
    call zyl_heap_alloc
    mov r14, rax
    cmp r14, 0
    jne .L846_3
    mov rsi, 0
    mov rdi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__os__os_x2Dfree_x2Dall
    mov rdi, r12
    call zyl_rt_free
    mov rdi, rbx
    call zyl_rt_free
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L846_3:
    mov rsi, 0
    mov r8, 0
    mov rdi, r12
    mov rdx, r13
    mov rcx, r14
    call zy_local_x2Fmain_0__os__os_x2Demit
    mov rsi, rax
    add rsi, r14
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rdi, r12
    call zyl_rt_free
    mov rdi, rbx
    call zyl_rt_free
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dlist:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L847_0:
    mov rdi, 24
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L847_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L847_1:
    mov rsi, 0
    mov qword ptr [r13+0], rsi
    mov rsi, 0
    mov qword ptr [r13+8], rsi
    mov rsi, 0
    mov qword ptr [r13+16], rsi
    cmp rbx, 0
    je .L847_4
    cmp r12, 0
    jne .L847_2
.L847_4:
    jmp .L847_3
.L847_2:
    lea rax, [rip+.L848]
    mov rsi, rax
    mov rdi, rbx
    mov rdx, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__os__os_x2Dwalk
.L847_3:
    mov rdi, r13
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__os__os_x2Djoin
.globl zyl_list_zyl_files
zyl_list_zyl_files:
    push rbx
.L849_0:
    mov rbx, rdi
    lea rax, [rip+.L850]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L849_1
    mov rdi, 0
    mov rsi, 0
    pop rbx
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.L849_1:
    lea rax, [rip+.L851]
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.globl zyl_list_files
zyl_list_files:
    push rbx
    push r12
.L852_0:
    mov rbx, rdi
    mov r12, rsi
    lea rax, [rip+.L853]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    jne .L852_2
    lea rax, [rip+.L854]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L852_1
.L852_2:
    mov rdi, 0
    mov rsi, 0
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.L852_1:
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
zy_local_x2Fmain_0__os__os_x2Dterm_x2Dstate:
.L855_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__os__os_x2Dterm_x2Dsaved:
.L856_0:
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_term_is_tty
zyl_term_is_tty:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L857_0:
    mov rsi, 21505
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_tios@tpoff]
    mov r8, rax
    mov rdx, r8
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L857_1
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L857_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dtcset:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L858_0:
    mov rsi, 0
    mov r8, 21508
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r8
    call zyl_rt_sys_16
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
.L859_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 1
    jne .L859_1
    mov rax, qword ptr [rbx+0]
    cmp rax, 1
    jne .L859_1
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rdi, 0
    mov r8, 21508
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_16
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
    mov rdi, 1
    lea rax, [rip+.L860]
    mov rsi, rax
    mov r8, 12
    mov rdx, r8
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L859_1:
    mov rax, 0
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
.L861_0:
    mov rdi, 0
    call zyl_term_is_tty
    cmp rax, 0
    jne .L861_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L861_1:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 1
    jne .L861_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L861_2:
    mov rax, qword ptr [rbx+0]
    cmp rax, 1
    jne .L861_3
    mov rsi, 1
    jmp .L861_4
.L861_3:
    mov rdi, 0
    mov r8, 21505
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov r9, rax
    mov rsi, r8
    mov rdx, r9
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L861_5
    mov rdi, 1
    mov qword ptr [rbx+0], rdi
    call zyl_term_atexit
    mov rdi, 1
    jmp .L861_6
.L861_5:
    mov rdi, 0
.L861_6:
    mov rsi, rdi
.L861_4:
    mov rax, rsi
    cmp rax, 0
    jne .L861_7
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L861_7:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_tios@tpoff]
    mov r12, rax
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rdi, 64
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov esi, dword ptr [r12+0]
    mov rdi, 4294967295
    xor rdi, 1330
    and rsi, rdi
    mov dword ptr [r12+0], esi
    mov esi, dword ptr [r12+12]
    mov rdi, 4294967295
    xor rdi, 32779
    and rsi, rdi
    mov dword ptr [r12+12], esi
    mov rsi, 1
    mov rcx, rsi
    mov byte ptr [r12+23], cl
    mov rsi, 0
    mov rcx, rsi
    mov byte ptr [r12+22], cl
    mov rdi, 0
    mov rsi, 21508
    mov rdx, r12
    call zyl_rt_sys_16
    cmp rax, 0
    je .L861_8
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L861_8:
    mov rsi, 1
    mov qword ptr [rbx+8], rsi
    mov rax, 0
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
.L862_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 1
    jne .L862_2
    mov rax, qword ptr [rbx+0]
    cmp rax, 1
    je .L862_1
.L862_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L862_1:
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rdi, 0
    mov r8, 21508
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_16
    cmp rax, 0
    je .L862_3
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L862_3:
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
    mov rax, 0
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
.L863_0:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_byte@tpoff]
    mov rbx, rax
    mov rdi, 0
    mov rsi, 1
    mov rdx, rsi
    mov rsi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 1
    jne .L863_1
    movzx eax, byte ptr [rbx+0]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L863_1:
    cmp rsi, -4
    jne .L863_2
    mov rax, -2
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L863_2:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_read_byte_timeout
zyl_term_read_byte_timeout:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L864_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_pollfd@tpoff]
    mov rsi, rax
    mov r8, 4294967296
    mov qword ptr [rsi+0], r8
    mov r8, 1
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r8
    call zyl_rt_sys_7
    mov rsi, rax
    cmp rsi, 0
    jne .L864_1
    mov rax, -3
    mov rsp, rbp
    pop rbp
    ret
.L864_1:
    cmp rsi, 0
    jge .L864_2
    cmp rsi, -4
    jne .L864_3
    mov rax, -2
    mov rsp, rbp
    pop rbp
    ret
.L864_3:
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L864_2:
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
.L865_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_winsz@tpoff]
    mov r13, rax
    mov rdi, 1
    mov rsi, 21523
    mov rdx, r13
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L865_1
    lea rsi, [r13+rbx]
    movzx esi, word ptr [rsi+0]
    cmp rsi, 0
    jle .L865_2
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L865_2:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L865_1:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_width
zyl_term_width:
.L866_0:
    mov rdi, 2
    mov rsi, 80
    jmp zy_local_x2Fmain_0__os__os_x2Dwinsz
.globl zyl_term_height
zyl_term_height:
.L867_0:
    mov rdi, 0
    mov rsi, 24
    jmp zy_local_x2Fmain_0__os__os_x2Dwinsz
.globl zyl_term_write
zyl_term_write:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L868_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L868_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L868_1:
    lea rax, [rip+.L869]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L868_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L868_2:
    call zyl_term_flush
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
.L870_0:
    cmp r13, r12
    jl .L870_1
.L870_4:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L870_1:
    mov rdi, 1
    lea rsi, [rbx+r13]
    mov r8, r12
    sub r8, r13
    mov rdx, r8
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L870_2
    add r13, rsi
    cmp r13, r12
    jl .L870_1
    jmp .L870_4
.L870_2:
    cmp rsi, -4
    jne .L870_3
    cmp r13, r12
    jl .L870_1
    jmp .L870_4
.L870_3:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf:
.L871_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_uf_reset
zyl_uf_reset:
.L872_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+16], rdi
    mov rax, 0
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
.L873_0:
    mov rax, qword ptr [rbx+24]
    cmp rax, 0
    jne .L873_1
    mov rsi, 4096
    jmp .L873_2
.L873_1:
    mov rsi, qword ptr [rbx+24]
    shl rsi, 1
.L873_2:
    mov r12, rsi
    mov rdi, qword ptr [rbx+0]
    lea rsi, [r12*8]
    call zyl_rt_realloc
    mov r13, rax
    mov rdi, qword ptr [rbx+8]
    lea rsi, [r12*8]
    call zyl_rt_realloc
    mov r14, rax
    cmp r13, 0
    je .L873_5
    cmp r14, 0
    jne .L873_3
.L873_5:
    mov rdi, r12
    shl rdi, 4
    lea rax, [rip+.L874]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L873_4
.L873_3:
.L873_4:
    mov qword ptr [rbx+0], r13
    mov qword ptr [rbx+8], r14
    mov qword ptr [rbx+24], r12
    mov rsi, r12
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
    push rbx
    push r12
    mov rbx, rdi
.L875_0:
    lea rax, [rip+zyl_rtg_uf]
    mov r12, rax
    mov rsi, qword ptr [r12+16]
    mov rax, qword ptr [r12+24]
    cmp rsi, rax
    jne .L875_1
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dgrow
    jmp .L875_2
.L875_1:
.L875_2:
    mov rsi, qword ptr [r12+16]
    mov rdi, qword ptr [r12+0]
    lea r8, [rsi*8]
    add rdi, r8
    mov qword ptr [rdi+0], rsi
    mov rdi, qword ptr [r12+8]
    lea r8, [rsi*8]
    add rdi, r8
    mov qword ptr [rdi+0], rbx
    lea rdi, [rsi+1]
    mov qword ptr [r12+16], rdi
    mov rax, rsi
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Droot:
.L876_0:
    lea r8, [rsi*8]
    add r8, rdi
    mov r8, qword ptr [r8+0]
    cmp r8, rsi
    jne .L876_1
    mov rax, rsi
    ret
.L876_1:
    mov rsi, r8
    jmp .L876_0
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dcompress:
    mov r8, rdx
.L877_0:
    lea r9, [rsi*8]
    add r9, rdi
    mov r9, qword ptr [r9+0]
    cmp r9, r8
    jne .L877_1
    mov rax, 0
    ret
.L877_1:
    lea r10, [rsi*8]
    add r10, rdi
    mov qword ptr [r10+0], r8
    mov rsi, r9
    jmp .L877_0
.globl zyl_uf_find
zyl_uf_find:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L878_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    cmp rbx, 0
    jl .L878_2
    mov rax, qword ptr [rsi+16]
    cmp rbx, rax
    jl .L878_1
.L878_2:
    mov rax, rbx
    pop r13
    pop r12
    pop rbx
    ret
.L878_1:
    mov r12, qword ptr [rsi+0]
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Droot
    mov r13, rax
    mov rdi, r12
    mov rsi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dcompress
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok:
.L879_0:
    cmp rdi, 0
    jl .L879_1
.L879_2:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rsi, qword ptr [rsi+16]
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    ret
.L879_1:
    mov rax, 0
    ret
.globl zyl_uf_union
zyl_uf_union:
    push rbx
    push r12
    mov rbx, rsi
.L880_0:
    call zyl_uf_find
    mov r12, rax
    mov rdi, rbx
    call zyl_uf_find
    mov rbx, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    je .L880_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    jne .L880_1
.L880_2:
    mov rax, r12
    pop r12
    pop rbx
    ret
.L880_1:
    cmp r12, rbx
    jne .L880_3
    mov rax, r12
    pop r12
    pop rbx
    ret
.L880_3:
    mov rsi, r12
    cmp r12, rbx
    jl .L880_4
    mov rsi, rbx
.L880_4:
    mov rdi, rbx
    cmp r12, rbx
    jl .L880_5
    mov rdi, r12
.L880_5:
    lea rax, [rip+zyl_rtg_uf]
    mov r8, rax
    mov r8, qword ptr [r8+8]
    lea r9, [rdi*8]
    add r9, r8
    mov r9, qword ptr [r9+0]
    lea r10, [rsi*8]
    add r10, r8
    mov rax, qword ptr [r10+0]
    cmp r9, rax
    jle .L880_6
    lea r9, [rsi*8]
    add r9, r8
    lea r10, [rdi*8]
    add r8, r10
    mov r8, qword ptr [r8+0]
    mov qword ptr [r9+0], r8
    jmp .L880_7
.L880_6:
.L880_7:
    lea rax, [rip+zyl_rtg_uf]
    mov r8, rax
    mov r8, qword ptr [r8+0]
    shl rdi, 3
    add r8, rdi
    mov qword ptr [r8+0], rsi
    mov rax, rsi
    pop r12
    pop rbx
    ret
.globl zyl_uf_raise
zyl_uf_raise:
    push rbx
    push r12
    mov rbx, rsi
.L881_0:
    call zyl_uf_find
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    jne .L881_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L881_1:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rsi, qword ptr [rsi+8]
    lea rdi, [r12*8]
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    cmp rbx, rax
    jle .L881_2
    mov qword ptr [rsi+0], rbx
    jmp .L881_3
.L881_2:
.L881_3:
    mov rax, 0
    pop r12
    pop rbx
    ret
.globl zyl_uf_level
zyl_uf_level:
    push rbx
.L882_0:
    call zyl_uf_find
    mov rbx, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    jne .L882_1
    mov rax, 2
    pop rbx
    ret
.L882_1:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rsi, qword ptr [rsi+8]
    lea rdi, [rbx*8]
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    pop rbx
    ret
zy_local_x2Fmain_0__misc__rt_x2Dnote:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L883_0:
    mov rbx, 2
    mov r12, rdi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mem_alloc
zyl_mem_alloc:
.L884_0:
    mov rax, QWORD PTR [rip+malloc@GOTPCREL]
    mov rsi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov r8, rax
    mov rax, qword ptr [r8+0]
    cmp rax, 0
    jne .L884_1
    cmp rsi, 0
    jle .L884_1
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zyl_rt_call1
.L884_1:
    mov rsi, 1
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
.globl zyl_mem_free
zyl_mem_free:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L885_0:
    mov rax, QWORD PTR [rip+free@GOTPCREL]
    mov rsi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov r8, rax
    mov rax, qword ptr [r8+0]
    cmp rax, 0
    jne .L885_1
    cmp rsi, 0
    jle .L885_1
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_call1
    jmp .L885_2
.L885_1:
    call zyl_rt_free
.L885_2:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mem_read
zyl_mem_read:
.L886_0:
    cmp rdi, 0
    jne .L886_1
.L886_2:
    lea rax, [rip+.L887]
    mov rsi, rax
    mov rdi, rsi
    jmp zy_local_x2Fmain_0__misc__rt_x2Dnote
.L886_1:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_mem_write
zyl_mem_write:
    push rbx
    mov rbx, rsi
.L888_0:
    cmp rdi, 0
    jne .L888_1
.L888_2:
    lea rax, [rip+.L889]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__misc__rt_x2Dnote
    mov rax, rbx
    pop rbx
    ret
.L888_1:
    mov qword ptr [rdi+0], rbx
    mov rax, rbx
    pop rbx
    ret
.globl zyl_cstr_byte_set
zyl_cstr_byte_set:
    mov r8, rdx
.L890_0:
    cmp rdi, 0
    je .L890_2
.L890_4:
    cmp rsi, 0
    jge .L890_1
.L890_2:
    mov rax, 0
    ret
.L890_1:
    cmp rdi, 4096
    jge .L890_3
    lea rax, [rip+.L891]
    mov r9, rax
    mov rsi, r9
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    ret
.L890_3:
    add rsi, rdi
    mov rdi, r8
    and rdi, 255
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, 0
    ret
.globl zyl_getenv
zyl_getenv:
.L892_0:
    jmp zyl_rt_getenv
.globl zyl_regions_enabled
zyl_regions_enabled:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L893_0:
    lea rax, [rip+.L894]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    cmp rsi, 0
    jle .L893_1
    movzx eax, byte ptr [rsi+0]
    cmp rax, 48
    jne .L893_1
    movzx eax, byte ptr [rsi+1]
    cmp rax, 0
    jne .L893_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L893_1:
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__misc__rt_x2Dlshr64:
.L895_0:
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
    sub r9, rsi
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    sub rsi, 1
    and rdi, rsi
    mov rax, rdi
    ret
zy_local_x2Fmain_0__misc__rt_x2Dzsa_x2Dindex:
    push rbx
    mov rbx, rdi
.L896_0:
    mov rsi, 33
    mov rdi, rbx
    call zy_local_x2Fmain_0__misc__rt_x2Dlshr64
    mov rsi, rax
    xor rbx, rsi
    mov rsi, -49064778989728563
    imul rbx, rsi
    mov rsi, 33
    mov rdi, rbx
    call zy_local_x2Fmain_0__misc__rt_x2Dlshr64
    mov rsi, rax
    xor rbx, rsi
    mov rsi, -4265267296055464877
    imul rbx, rsi
    mov rsi, 33
    mov rdi, rbx
    call zy_local_x2Fmain_0__misc__rt_x2Dlshr64
    mov rsi, rax
    xor rsi, rbx
    and rsi, 63
    mov rax, rsi
    pop rbx
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
.L897_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_zsa@tpoff]
    mov r14, rax
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__misc__rt_x2Dzsa_x2Dindex
    mov r15, rax
    lea rsi, [r15*8]
    add rsi, r14
    mov rax, qword ptr [rsi+0]
    cmp rax, qword ptr [rbp-48]
    jne .L897_1
    lea rsi, [r14+512]
    lea rdi, [r15*8]
    add rsi, rdi
    mov rsi, qword ptr [rsi+0]
    jmp .L897_2
.L897_1:
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rdi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, rdi
.L897_2:
    mov rbx, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov qword ptr [rbp-56], rax
    cmp r13, 0
    jle .L897_3
    mov rsi, rbx
    sub rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-56]
    lea rax, [rsi+1]
    cmp rax, r13
    jle .L897_3
    lea rax, [rip+.L898]
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.L897_3:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rbx
    add rsi, qword ptr [rbp-56]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    lea rsi, [r15*8]
    add rsi, r14
    mov rcx, qword ptr [rbp-48]
    mov qword ptr [rsi+0], rcx
    lea rsi, [r14+512]
    lea rdi, [r15*8]
    add rsi, rdi
    mov rdi, rbx
    add rdi, qword ptr [rbp-56]
    mov qword ptr [rsi+0], rdi
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_zeroize
zyl_zeroize:
    push rbx
    mov rbx, rsi
.L899_0:
    cmp rdi, 0
    je .L899_2
.L899_3:
    cmp rbx, 0
    jg .L899_1
.L899_2:
    mov rax, 0
    pop rbx
    ret
.L899_1:
    mov rsi, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Dzero_x2Dbytes
    mov rax, rbx
    pop rbx
    ret
zy_local_x2Fmain_0__crypto__cr_x2Dzero_x2Dbytes:
.L900_0:
    cmp rsi, 0
    jg .L900_1
.L900_2:
    mov rax, 0
    ret
.p2align 4
.L900_1:
    mov r8, 0
    mov byte ptr [rdi+0], r8b
    add rdi, 1
    sub rsi, 1
    cmp rsi, 0
    jg .L900_1
    jmp .L900_2
zy_local_x2Fmain_0__crypto__cr_x2Dwipe:
.L901_0:
    cmp rsi, 0
    jg .L901_1
.L901_2:
    mov rax, 0
    ret
.p2align 4
.L901_1:
    mov r8, 0
    mov qword ptr [rdi+0], r8
    add rdi, 8
    sub rsi, 8
    cmp rsi, 0
    jg .L901_1
    jmp .L901_2
zy_local_x2Fmain_0__crypto__cr_x2Dpack:
    mov r8, rdx
    mov r9, rcx
.L902_0:
    cmp r9, r8
    jl .L902_1
.L902_2:
    mov rax, 0
    ret
.p2align 4
.L902_1:
    lea r10, [rdi+r9]
    lea r11, [r9*8]
    add r11, rsi
    mov r11, qword ptr [r11+0]
    mov byte ptr [r10+0], r11b
    add r9, 1
    cmp r9, r8
    jl .L902_1
    jmp .L902_2
zy_local_x2Fmain_0__crypto__cr_x2Dunpack:
    mov r8, rdx
    mov r9, rcx
.L903_0:
    cmp r9, r8
    jl .L903_1
.L903_2:
    mov rax, 0
    ret
.p2align 4
.L903_1:
    lea r10, [r9*8]
    add r10, rdi
    lea r11, [rsi+r9]
    movzx r11d, byte ptr [r11+0]
    mov qword ptr [r10+0], r11
    add r9, 1
    cmp r9, r8
    jl .L903_1
    jmp .L903_2
zy_local_x2Fmain_0__crypto__cr_x2Dwords_x2Ddata:
.L904_0:
    lea rax, [rip+.L905]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov rax, qword ptr [rsi+16]
    ret
zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock:
.L906_0:
    call zyl_words_len
    mov rsi, rax
    cmp rsi, 16
    jge .L906_1
    lea rax, [rip+.L907]
    mov rdi, rax
    mov r8, 15
    mov rdx, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L906_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Dscratch:
.L908_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_aes@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Drounds:
    mov r8, rdx
    mov r9, rcx
.L909_0:
    cmp r8, r9
    jge .L909_1
.L909_2:
    mov r10, r8
    shl r10, 4
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
    add r8, 1
    cmp r8, r9
    jge .L909_1
    jmp .L909_2
.L909_1:
    mov r8, r9
    shl r8, 4
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
.L910_0:
    call zyl_cpuid_features
    mov rsi, rax
    and rsi, 1
    cmp rsi, 0
    jg .L910_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L910_1:
    cmp qword ptr [rbp-48], 16
    je .L910_2
    cmp qword ptr [rbp-48], 32
    je .L910_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L910_2:
    mov rdi, rbx
    call zyl_words_len
    cmp rax, qword ptr [rbp-48]
    jge .L910_3
    lea rax, [rip+.L911]
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
    jmp .L910_4
.L910_3:
.L910_4:
    lea rax, [rip+.L912]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov rbx, qword ptr [rsi+16]
    mov rdi, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock
    lea rax, [rip+.L913]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov r12, qword ptr [rsi+16]
    mov rdi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock
    lea rax, [rip+.L914]
    mov rsi, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov r13, qword ptr [rsi+16]
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_aes@tpoff]
    mov qword ptr [rbp-56], rax
    mov r15, qword ptr [rbp-56]
    add r15, 240
    mov r14, qword ptr [rbp-56]
    add r14, 272
    mov rsi, 0
    mov rdi, r15
    mov rdx, qword ptr [rbp-48]
    mov rcx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Dpack
    mov rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dpack
    mov rsi, 10
    cmp qword ptr [rbp-48], 16
    je .L910_5
    mov rsi, 14
.L910_5:
    cmp qword ptr [rbp-48], 16
    jne .L910_6
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
    jmp .L910_7
.L910_6:
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
.L910_7:
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
    mov rdi, 1
    mov rdx, rdi
    mov rdi, r14
    mov rcx, rsi
    mov rsi, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Drounds
    mov rsi, 16
    mov rdi, 0
    mov rdx, rsi
    mov rsi, r14
    mov rcx, rdi
    mov rdi, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dunpack
    mov rsi, 288
    mov rdi, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__crypto__cr_x2Dwipe
    mov rax, 1
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
.L915_0:
    cmp r13, r12
    jl .L915_1
.L915_4:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L915_1:
    lea rdi, [rbx+r13]
    mov rsi, r12
    sub rsi, r13
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_318
    mov rsi, rax
    cmp rsi, 0
    jge .L915_2
    cmp rsi, -4
    jne .L915_3
    cmp r13, r12
    jl .L915_1
    jmp .L915_4
.L915_3:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L915_2:
    add r13, rsi
    cmp r13, r12
    jl .L915_1
    jmp .L915_4
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
.L916_0:
    cmp r14, r13
    jl .L916_1
.L916_4:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L916_1:
    lea rsi, [r12+r14]
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L916_2
    add r14, rsi
    cmp r14, r13
    jl .L916_1
    jmp .L916_4
.L916_2:
    cmp rsi, -4
    jne .L916_3
    cmp r14, r13
    jl .L916_1
    jmp .L916_4
.L916_3:
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
.L917_0:
    lea rax, [rip+.L918]
    mov rdi, rax
    mov rsi, 524288
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_2
    mov r14, rax
    cmp r14, 0
    jge .L917_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L917_1:
    mov rdi, r14
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dread_x2Dall
    mov rbx, rax
    mov rdi, r14
    call zyl_rt_sys_3
    cmp rbx, r12
    jne .L917_2
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L917_2:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_random_fill
zyl_random_fill:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L919_0:
    cmp rbx, 0
    je .L919_2
.L919_4:
    cmp r12, 0
    jg .L919_1
.L919_2:
    mov rax, -1
    pop r12
    pop rbx
    ret
.L919_1:
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__crypto__cr_x2Dgetrandom
    mov rsi, rax
    cmp rsi, r12
    jne .L919_3
    mov rax, rsi
    pop r12
    pop rbx
    ret
.L919_3:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__crypto__cr_x2Durandom
zy_local_x2Fmain_0__crypto__cr_x2Drand_x2Dchunks:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L920_0:
    cmp r13, r12
    jl .L920_1
.L920_6:
    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L920_1:
    mov rax, r12
    sub rax, r13
    cmp rax, 256
    jle .L920_2
    mov rsi, 256
    jmp .L920_3
.L920_2:
    mov rsi, r12
    sub rsi, r13
.L920_3:
    mov r15, rsi
    mov rdi, r14
    mov rsi, r15
    call zyl_random_fill
    cmp rax, r15
    je .L920_4
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L920_4:
    lea rsi, [r13*8]
    lea rdi, [rbx+rsi]
    mov rsi, 0
    cmp rsi, r15
    jge .L920_5
    mov rdx, r15
    mov rcx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dunpack
.L920_5:
    add r13, r15
    cmp r13, r12
    jl .L920_1
    jmp .L920_6
.globl zyl_random_words
zyl_random_words:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
.L921_0:
    cmp rbx, 0
    je .L921_2
.L921_5:
    cmp r12, 0
    jg .L921_1
.L921_2:
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L921_1:
    lea rax, [rip+.L922]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov r13, qword ptr [rsi+16]
    mov rdi, rbx
    call zyl_words_len
    cmp r12, rax
    jle .L921_3
    lea rax, [rip+.L923]
    mov r14, rax
    lea r15, [r12-1]
    mov rdi, rbx
    call zyl_words_len
    mov rsi, rax
    mov rdi, r14
    mov rdx, rsi
    mov rsi, r15
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L921_4
.L921_3:
.L921_4:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rand@tpoff]
    mov rbx, rax
    mov rsi, 0
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Drand_x2Dchunks
    mov r12, rax
    mov rsi, 256
    mov rdi, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Dwipe
    mov rax, r12
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__call__rt_x2Dguard:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L924_0:
    cmp rdi, 4096
    jge .L924_1
.L924_2:
    lea rax, [rip+.L925]
    mov rbx, rax
    lea rax, [rip+.L926]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dhex
    mov rdi, rax
    lea rax, [rip+.L927]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, 2
    mov r12, rdi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rdi, 1
    call zyl_rt_exit
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L924_1:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dcode_x2Dp:
.L928_0:
    mov rsi, 4294967296
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    ret
.globl zyl_call0
zyl_call0:
    push rbx
    mov rbx, rdi
.L929_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L929_1
    mov rdi, rbx
    pop rbx
    jmp zyl_rt_call0
.L929_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, rbx
    pop rbx
    jmp zyl_rt_call1
.globl zyl_call1
zyl_call1:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L930_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L930_1
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    jmp zyl_rt_call1
.L930_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, rbx
    mov rdx, r12
    pop r12
    pop rbx
    jmp zyl_rt_call2
.globl zyl_call2
zyl_call2:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L931_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L931_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    jmp zyl_rt_call2
.L931_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    pop r13
    pop r12
    pop rbx
    jmp zyl_rt_call3
.globl zyl_call3
zyl_call3:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L932_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L932_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zyl_rt_call3
.L932_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    mov r8, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zyl_rt_call4
.globl zyl_call4
zyl_call4:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L933_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L933_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    mov r8, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zyl_rt_call4
.L933_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    mov r8, r14
    mov r9, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
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
    jge .L934
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
    jmp .L935
.L934:
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
.L935:
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
    jge .L936
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
    jmp .L937
.L936:
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
.L937:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dmin64:
.L938_0:
    mov rax, -9223372036854775808
    ret
zy_local_x2Fmain_0__call__rt_x2Dult:
.L939_0:
    mov r8, -9223372036854775808
    xor rdi, r8
    mov r8, -9223372036854775808
    xor rsi, r8
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
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
    jge .L940
    mov rax, 0
    jmp .L941
.L940:
    mov rax, 1
.L941:
    mov [rbp-104], rax
    mov rax, [rbp-104]
    test rax, rax
    je .L942
    mov rax, [rbp-88]
    mov rcx, 1
    add rax, rcx
    jmp .L943
.L942:
    mov rax, [rbp-88]
.L943:
    mov [rbp-112], rax
    mov rax, [rbp-104]
    test rax, rax
    je .L944
    mov rax, [rbp-96]
    mov rcx, [rbp-24]
    sub rax, rcx
    jmp .L945
.L944:
    mov rax, [rbp-96]
.L945:
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
    jge .L946
    mov rax, 0
    jmp .L947
.L946:
    mov rax, 1
.L947:
    mov [rbp-144], rax
    mov rax, [rbp-144]
    test rax, rax
    je .L948
    mov rax, [rbp-128]
    mov rcx, 1
    add rax, rcx
    jmp .L949
.L948:
    mov rax, [rbp-128]
.L949:
    mov [rbp-152], rax
    mov rax, [rbp-144]
    test rax, rax
    je .L950
    mov rax, [rbp-136]
    mov rcx, [rbp-16]
    sub rax, rcx
    jmp .L951
.L950:
    mov rax, [rbp-136]
.L951:
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
    jge .L954
    mov rax, 1
    jmp .L955
.L954:
    mov rax, [rbp-112]
    mov rcx, [rbp-168]
    cmp rax, rcx
    jne .L956
    mov rax, [rbp-120]
    mov rcx, 0
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L957
.L956:
    mov rax, 0
.L957:
.L955:
    test rax, rax
    je .L952
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
    jmp .L953
.L952:
    mov rax, [rbp-72]
    test rax, rax
    je .L958
    mov rax, [rbp-80]
    mov rcx, 64
    sub rax, rcx
    jmp .L959
.L958:
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jge .L960
    mov rax, [rbp-152]
    mov rcx, 1
    add rax, rcx
    mov rcx, rax
    mov rax, 0
    sub rax, rcx
    jmp .L961
.L960:
    mov rax, [rbp-152]
    mov rcx, 1
    add rax, rcx
.L961:
.L959:
.L953:
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
    jg .L964
    mov rax, [rbp-8]
    mov rcx, -1
    cmp rax, rcx
    setge al
    movzx rax, al
    jmp .L965
.L964:
    mov rax, 0
.L965:
    test rax, rax
    je .L962
    mov rax, 0
    jmp .L963
.L962:
    mov rax, -9223372036854775808
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jge .L966
    mov rax, 0
    mov rcx, [rbp-8]
    sub rax, rcx
    jmp .L967
.L966:
    mov rax, [rbp-8]
.L967:
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
.L963:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_div_magic
zyl_div_magic:
.L968_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic
.globl zyl_div_shift
zyl_div_shift:
.L969_0:
    mov rsi, 1
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic
zy_local_x2Fmain_0__ffitab__ft_x2Dslots:
.L970_0:
    lea rax, [rip+zyl_rtg_ffitab_slots]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dprobe:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L971_0:
    mov rsi, r13
    shl rsi, 4
    lea r14, [rbx+rsi]
    mov rdi, qword ptr [r14+0]
    cmp rdi, 0
    je .L971_2
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L971_1
.L971_2:
    mov rax, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L971_1:
    add r13, 1
    and r13, 1023
    jmp .L971_0
zy_local_x2Fmain_0__ffitab__ft_x2Dput:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rdx
.L972_0:
    mov r13, rsi
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 0
    mov r8, -3750763034362895579
    mov rdx, rdi
    mov rdi, r13
    mov rcx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
    mov rsi, rax
    and rsi, 1023
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__ffitab__ft_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L972_1
    mov qword ptr [rsi+8], r12
    mov qword ptr [rsi+0], r13
    mov rsi, r13
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
.L972_1:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dtable:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L973_0:
    lea rax, [rip+zyl_rtg_ffitab_state]
    mov rbx, rax
    mov rsi, qword ptr [rbx+0]
    cmp rsi, 2
    jne .L973_1
    lea rax, [rip+zyl_rtg_ffitab_slots]
    mov rdi, rax
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L973_1:
    cmp rsi, 0
    jne .L973_2
    mov rsi, 0
    mov rdi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov r11, rdi
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, 0
    jne .L973_2
    lea rax, [rip+zyl_rtg_ffitab_slots]
    mov rdi, rax
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill
    mfence
    xor eax, eax
    mov rsi, 2
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    lea rax, [rip+zyl_rtg_ffitab_slots]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L973_2:
    call zyl_rt_sys_24
    jmp .L973_0
zy_local_x2Fmain_0__ffitab__ft_x2Dfind:
    push rbx
    push r12
    mov rbx, rdi
.L974_0:
    call zy_local_x2Fmain_0__ffitab__ft_x2Dtable
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
    and rsi, 1023
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L974_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L974_1:
    mov rax, rsi
    pop r12
    pop rbx
    ret
.globl zyl_runtime_export_p
zyl_runtime_export_p:
.L975_0:
    cmp rdi, 0
    jne .L975_1
    mov rax, 0
    ret
.L975_1:
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfind
    mov rsi, rax
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_ffi_lookup
zyl_ffi_lookup:
    push rbx
.L976_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L976_1
    mov rax, 0
    pop rbx
    ret
.L976_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jle .L976_2
    mov rax, qword ptr [rsi+8]
    pop rbx
    ret
.L976_2:
    mov rdi, rbx
    pop rbx
    jmp zy_local_x2Fmain_0__ffitab__ft_x2Ddlsym
.globl zyl_ffi_addr
zyl_ffi_addr:
.L977_0:
    jmp zyl_ffi_lookup
zy_local_x2Fmain_0__ffitab__ft_x2Dnote:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L978_0:
    mov rbx, 2
    mov r12, rdi
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dhex:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L979_0:
    lea rax, [rip+.L980]
    mov rdi, rax
    mov rsi, rbx
    and rsi, 15
    mov r8, 1
    mov rdx, r8
    call zyl_cstr_substr
    mov rdi, rax
    mov rsi, rbx
    shr rsi, 4
    cmp rsi, 0
    jne .L979_1
    mov rsi, r12
    call zyl_cstr_concat
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L979_1:
    mov rbx, rsi
    mov rsi, r12
    call zyl_cstr_concat
    mov r12, rax
    jmp .L979_0
.globl zyl_call_argv
zyl_call_argv:
    push rbp
    mov rbp, rsp
    sub rsp, 168
    mov [rbp-168], rbx
    mov [rbp-160], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    mov rcx, 4096
    cmp rax, rcx
    jge .L981
    lea rax, [rip+.L983]
    sub rsp, 8
    mov [rsp], rax
    sub rsp, 16
    lea rax, [rip+.L984]
    mov rsi, rax
    mov rdi, [rbp-8]
call zy_local_x2Fmain_0__ffitab__ft_x2Dhex
    add rsp, 16
    sub rsp, 8
    mov [rsp], rax
    lea rax, [rip+.L985]
    sub rsp, 8
    mov [rsp], rax
    mov rsi, [rsp+0]
    mov rdi, [rsp+8]
    mov r12, rsp
    and rsp, -16
call zyl_cstr_concat
    mov rsp, r12
    add rsp, 16
    sub rsp, 8
    mov [rsp], rax
    mov rsi, [rsp+0]
    mov rdi, [rsp+8]
    mov r12, rsp
    and rsp, -16
call zyl_cstr_concat
    mov rsp, r12
    add rsp, 16
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitab__ft_x2Dnote
    jmp .L982
.L981:
    mov rax, [rbp-16]
    mov rcx, 0
    cmp rax, rcx
    jge .L988
    mov rax, 1
    jmp .L989
.L988:
    mov rax, [rbp-16]
    mov rcx, 6
    cmp rax, rcx
    setg al
    movzx rax, al
.L989:
    test rax, rax
    je .L986
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitab__ft_x2Dargc_x2Dbad
    jmp .L987
.L986:
    mov rax, [rbp-16]
    mov rcx, 0
    cmp rax, rcx
    jne .L990
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-8]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call0
    mov rsp, r12
    add rsp, 16
    jmp .L991
.L990:
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov rcx, 1
    cmp rax, rcx
    jne .L992
    sub rsp, 16
    mov rdi, [rbp-8]
    mov rsi, [rbp-32]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call1
    mov rsp, r12
    add rsp, 16
    jmp .L993
.L992:
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-40], rax
    mov rax, [rbp-16]
    mov rcx, 2
    cmp rax, rcx
    jne .L994
    sub rsp, 8
    sub rsp, 24
    mov rdi, [rbp-8]
    mov rsi, [rbp-32]
    mov rdx, [rbp-40]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call2
    mov rsp, r12
    add rsp, 32
    jmp .L995
.L994:
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-48], rax
    mov rax, [rbp-16]
    mov rcx, 3
    cmp rax, rcx
    jne .L996
    sub rsp, 32
    mov rdi, [rbp-8]
    mov rsi, [rbp-32]
    mov rdx, [rbp-40]
    mov rcx, [rbp-48]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call3
    mov rsp, r12
    add rsp, 32
    jmp .L997
.L996:
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-56], rax
    mov rax, [rbp-16]
    mov rcx, 4
    cmp rax, rcx
    jne .L998
    sub rsp, 8
    sub rsp, 40
    mov rdi, [rbp-8]
    mov rsi, [rbp-32]
    mov rdx, [rbp-40]
    mov rcx, [rbp-48]
    mov r8, [rbp-56]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call4
    mov rsp, r12
    add rsp, 48
    jmp .L999
.L998:
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-64], rax
    mov rax, [rbp-16]
    mov rcx, 5
    cmp rax, rcx
    jne .L1000
    sub rsp, 48
    mov rdi, [rbp-8]
    mov rsi, [rbp-32]
    mov rdx, [rbp-40]
    mov rcx, [rbp-48]
    mov r8, [rbp-56]
    mov r9, [rbp-64]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call5
    mov rsp, r12
    add rsp, 48
    jmp .L1001
.L1000:
    mov rax, [rbp-8]
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
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
.L1001:
.L999:
.L997:
.L995:
.L993:
.L991:
.L987:
.L982:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dargc_x2Dbad:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1002_0:
    lea rax, [rip+.L1003]
    mov rbx, rax
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L1004]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitab__ft_x2Dnote
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D0:
    push rbx
    mov rbx, rdi
.L1005_0:
    lea rax, [rip+.L1006]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_pin@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1007]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_unpin@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1008]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_init@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1009]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_is_alive@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1010]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_spawn@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1011]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1012]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_recv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1013]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_rx@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1014]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_send@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1015]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_tx@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1016]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_wait@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1017]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_wait_all@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1018]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_aes_encrypt_block@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1019]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_aesni_available@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1020]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_align_check@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1021]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1022]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_alloc_zeroed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D1:
    push rbx
    mov rbx, rdi
.L1023_0:
    lea rax, [rip+.L1024]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_capacity@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1025]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_create@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1026]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_destroy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1027]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1028]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_used@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1029]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arg_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1030]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_argc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1031]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1032]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_cas@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1033]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_fetch_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1034]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_load@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1035]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_max@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1036]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_min@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1037]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_store@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1038]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1039]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_blake3_file_hex@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D2:
    push rbx
    mov rbx, rdi
.L1040_0:
    lea rax, [rip+.L1041]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_blake3_hex@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1042]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_byte_slice@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1043]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_byte_slice_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1044]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_append@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1045]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1046]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_cas@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1047]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_fetch_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1048]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_load@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1049]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_max@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1050]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_min@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1051]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_store@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1052]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1053]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_cap@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1054]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1055]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1056]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_ptr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D3:
    push rbx
    mov rbx, rdi
.L1057_0:
    lea rax, [rip+.L1058]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call0@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1059]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call1@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1060]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call2@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1061]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call3@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1062]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call4@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1063]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call5@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1064]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call6@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1065]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call_argv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1066]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call_on_big_stack@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1067]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cc_compile@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1068]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cc_compile_log@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1069]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chdir@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1070]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cpuid_features@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1071]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_byte_at@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1072]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_byte_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1073]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_concat@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D4:
    push rbx
    mov rbx, rdi
.L1074_0:
    lea rax, [rip+.L1075]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_count_newlines@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1076]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_decode@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1077]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1078]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_eq@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1079]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_from_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1080]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_from_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1081]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_key_matches@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1082]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_div_magic@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1083]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_div_shift@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1084]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1085]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_ok@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1086]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1087]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1088]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_find@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1089]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1090]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_last_newline@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D5:
    push rbx
    mov rbx, rdi
.L1091_0:
    lea rax, [rip+.L1092]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1093]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_of_word@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1094]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_float_bits@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1095]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_float_of_bits@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1096]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_word_load@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1097]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_word_store@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1098]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ptr_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1099]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ptr_cstr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1100]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_addr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1101]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_sanitize@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1102]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1103]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_substr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1104]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_to_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1105]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_to_int_base@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1106]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_diag_json@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1107]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_diag_json_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D6:
    push rbx
    mov rbx, rdi
.L1108_0:
    lea rax, [rip+.L1109]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_dirname_cstr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1110]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1111]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1112]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1113]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1114]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ensure_arenas@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1115]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_exec_cmd@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1116]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1117]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1118]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_div@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1119]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_error@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1120]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_mul@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1121]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_of_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1122]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_parse@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1123]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_rem@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1124]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D7:
    push rbx
    mov rbx, rdi
.L1125_0:
    lea rax, [rip+.L1126]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_text@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1127]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_to_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1128]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_lookup@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1129]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_timed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1130]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_timed_argv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1131]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_close_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1132]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_exit@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1133]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_read_line@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1134]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_open_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1135]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_read_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1136]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_write_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1137]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fnmap_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1138]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fnmap_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1139]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fnmap_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1140]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fresh_id@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1141]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_getcwd@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D8:
    push rbx
    mov rbx, rdi
.L1142_0:
    lea rax, [rip+.L1143]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_getenv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1144]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_contract_warn@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1145]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_err_is@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1146]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_list_zyl_files@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1147]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_list_files@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1148]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_n@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1149]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_n_signed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1150]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_store_n@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1151]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1152]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1153]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_ready@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1154]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1155]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1156]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1157]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_ready@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1158]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D9:
    push rbx
    mov rbx, rdi
.L1159_0:
    lea rax, [rip+.L1160]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_repl_global_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1161]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_repl_global_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1162]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_id@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1163]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1164]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1165]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_find@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1166]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_union@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1167]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_raise@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1168]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_level@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1169]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_regions_enabled@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1170]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1171]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1172]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_alloc_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1173]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1174]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1175]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1176]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_view@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1177]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_has@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D10:
    push rbx
    mov rbx, rdi
.L1178_0:
    lea rax, [rip+.L1179]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_get_or@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1180]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1181]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_vec_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1182]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_vec_alloc_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1183]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_cap@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1184]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_filled@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1185]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1186]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1187]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1188]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1189]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_get_or@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1190]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_has@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1191]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1192]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1193]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ref_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1194]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ref_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1195]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ref_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1196]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_getenv_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D11:
    push rbx
    mov rbx, rdi
.L1197_0:
    lea rax, [rip+.L1198]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_strbuf_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1199]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_strbuf_new_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1200]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_strbuf_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1201]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_escapes_ok@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1202]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_heap_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1203]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ralloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1204]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_enter@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1205]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_exit@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1206]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_free@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1207]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_scope_enter@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1208]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_live_bytes@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1209]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_heap_block_p@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1210]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_heap_swap@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1211]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_int_text@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1212]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1213]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_count@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1214]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_fn@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D12:
    push rbx
    mov rbx, rdi
.L1215_0:
    lea rax, [rip+.L1216]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_name@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1217]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_outcome@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1218]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_fail@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1219]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1220]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_start@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1221]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_summary@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1222]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_json_quote@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1223]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1224]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_byte_signed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1225]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mangle_key@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1226]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1227]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_free@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1228]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_read@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1229]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_write@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1230]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mkdir_p@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1231]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mlock@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1232]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_panic@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D13:
    push rbx
    mov rbx, rdi
.L1233_0:
    lea rax, [rip+.L1234]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_path_exists@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1235]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_pin_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1236]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_print_float@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1237]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_print_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1238]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_print_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1239]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_random_fill@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1240]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_random_words@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1241]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_run_bin@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1242]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_session_arena@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1243]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1244]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1245]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_global@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1246]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1247]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1248]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_source_path@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1249]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_source_register@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D14:
    push rbx
    mov rbx, rdi
.L1250_0:
    lea rax, [rip+.L1251]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_col@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1252]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1253]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_file@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1254]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_line@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1255]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_line_text@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1256]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_off@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1257]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_snippet@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1258]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_snippet_col@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1259]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_offset_at@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1260]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1261]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_store_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1262]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_store_byte_signed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1263]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_str_append@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1264]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_str_append_capped@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1265]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_sym_escape@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1266]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_system_cmd@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D15:
    push rbx
    mov rbx, rdi
.L1267_0:
    lea rax, [rip+.L1268]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_flush@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1269]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_height@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1270]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_is_tty@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1271]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_raw_off@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1272]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_raw_on@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1273]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_read_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1274]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_read_byte_timeout@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1275]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_width@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1276]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_write@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1277]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_frame_msg@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1278]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_last_msg@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1279]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_pop@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1280]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_push@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1281]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_variant_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1282]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_variant_eq@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1283]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_variant_field@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D16:
    push rbx
    mov rbx, rdi
.L1284_0:
    lea rax, [rip+.L1285]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_warn_capture@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1286]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_warn_emit@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1287]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_warn_take@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1288]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_word_of_cstr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1289]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1290]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_global@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1291]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1292]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1293]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_pop@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1294]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_push@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1295]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1296]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_truncate@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1297]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_zeroize@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill:
    push rbx
    mov rbx, rdi
.L1298_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D0
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D1
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D2
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D3
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D4
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D5
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D6
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D7
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D8
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D9
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D10
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D11
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D12
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D13
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D14
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D15
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D16
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Ddlsym:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1299_0:
    mov rax, QWORD PTR [rip+dlsym@GOTPCREL]
    mov rsi, rax
    cmp rsi, 0
    jne .L1299_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1299_1:
    mov r8, 0
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r8
    call zyl_rt_call2
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dint:
.L1300_0:
    mov rsi, 4294967295
    and rsi, rdi
    cmp rsi, 2147483647
    jle .L1300_1
    mov rdi, 4294967296
    mov rax, rsi
    sub rax, rdi
    ret
.L1300_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__proc__pr_x2Denviron:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1301_0:
    call zyl_rt_envp
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dscratch:
.L1302_0:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__proc__pr_x2Dpid:
.L1303_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__proc__pr_x2Dstatus:
.L1304_0:
    lea rax, [rdi+8]
    ret
zy_local_x2Fmain_0__proc__pr_x2Dargv:
.L1305_0:
    lea rax, [rdi+16]
    ret
zy_local_x2Fmain_0__proc__pr_x2Dout:
.L1306_0:
    lea rax, [rdi+80]
    ret
zy_local_x2Fmain_0__proc__pr_x2Dwait:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1307_0:
    mov rdi, rsi
    call zy_local_x2Fmain_0__proc__pr_x2Dint
    cmp rax, 0
    je .L1307_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1307_1:
    mov edi, dword ptr [rbx+0]
    call zy_local_x2Fmain_0__proc__pr_x2Dint
    mov rdi, rax
    lea rsi, [rbx+8]
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    call zyl_rt_sys_61
    mov rdi, rax
    call zy_local_x2Fmain_0__proc__pr_x2Dint
    cmp rax, 0
    jge .L1307_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1307_2:
    mov esi, dword ptr [rbx+8]
    mov rax, rsi
    and rax, 127
    cmp rax, 0
    jne .L1307_3
    shr rsi, 8
    and rsi, 255
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1307_3:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dmap_x2Dsize:
.L1308_0:
    mov rax, 65536
    ret
zy_local_x2Fmain_0__proc__pr_x2Dbuf:
.L1309_0:
    lea rax, [rdi+64]
    ret
zy_local_x2Fmain_0__proc__pr_x2Dbuf_x2Dmax:
.L1310_0:
    mov rax, 4400
    ret
zy_local_x2Fmain_0__proc__pr_x2Dspawn:
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
    mov r15, r8
.L1311_0:
    mov rdi, 0
    mov rsi, 65536
    mov r8, 3
    mov r9, 131106
    mov r10, -1
    mov r11, 0
    mov rdx, r8
    mov rcx, r9
    mov r8, r10
    mov r9, r11
    call zyl_rt_sys_9
    mov qword ptr [rbp-48], rax
    cmp qword ptr [rbp-48], 0
    jge .L1311_1
    cmp qword ptr [rbp-48], -4096
    jle .L1311_1
    mov rsi, 0
    sub rsi, qword ptr [rbp-48]
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1311_1:
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+0], r12
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+8], r13
    call zyl_rt_envp
    mov rsi, rax
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+16], rsi
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+24], r14
    cmp r15, 0
    je .L1311_2
    mov rsi, 1
    jmp .L1311_3
.L1311_2:
    mov rsi, 0
.L1311_3:
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+32], rsi
    cmp r15, 0
    je .L1311_4
    lea rax, [rip+.L1312]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    jmp .L1311_5
.L1311_4:
    mov rsi, 0
.L1311_5:
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+48], rsi
    mov rsi, qword ptr [rbp-48]
    add rsi, 65504
    mov rax, QWORD PTR [rip+zyl_rt_spawn_child@GOTPCREL]
    mov rdi, rax
    mov qword ptr [rsi+0], rdi
    mov rdi, 0
    mov qword ptr [rsi+8], rdi
    mov rcx, qword ptr [rbp-48]
    mov qword ptr [rsi+16], rcx
    mov rdi, 16657
    call zyl_rt_sys_56
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Dspawn_x2Ddone
zy_local_x2Fmain_0__proc__pr_x2Dspawn_x2Ddone:
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
.L1313_0:
    mov rsi, 0
    sub rsi, r13
    cmp r13, 0
    jl .L1313_1
    mov rsi, qword ptr [r12+40]
.L1313_1:
    mov r14, rsi
    cmp r13, 0
    jle .L1313_2
    cmp r14, 0
    je .L1313_2
    mov rsi, 0
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, r13
    mov rcx, r8
    call zyl_rt_sys_61
    jmp .L1313_3
.L1313_2:
.L1313_3:
    cmp r13, 0
    jle .L1313_4
    cmp r14, 0
    jne .L1313_4
    mov dword ptr [rbx+0], r13d
    jmp .L1313_5
.L1313_4:
.L1313_5:
    mov rsi, 65536
    mov rdi, r12
    call zyl_rt_sys_11
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_rt_spawn_child
zyl_rt_spawn_child:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1314_0:
    mov rbx, qword ptr [rsi+16]
    mov rdi, qword ptr [rbx+24]
    mov rsi, 0
    cmp rdi, 0
    je .L1314_1
    call zy_local_x2Fmain_0__proc__pr_x2Dredirect
    mov rsi, rax
.L1314_1:
    mov rdi, rsi
    cmp rsi, 0
    jl .L1314_2
    mov rax, qword ptr [rbx+32]
    cmp rax, 0
    jne .L1314_3
    mov rsi, qword ptr [rbx+0]
    mov r8, qword ptr [rbx+8]
    mov r9, qword ptr [rbx+16]
    mov rdi, rsi
    mov rsi, r8
    mov rdx, r9
    call zyl_rt_sys_59
    mov rsi, rax
    jmp .L1314_4
.L1314_3:
    mov r8, qword ptr [rbx+0]
    mov rdi, rbx
    mov rsi, r8
    call zy_local_x2Fmain_0__proc__pr_x2Dexecvp
    mov rsi, rax
.L1314_4:
    mov rdi, rsi
.L1314_2:
    mov rsi, rdi
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Ddie
zy_local_x2Fmain_0__proc__pr_x2Ddie:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L1315_0:
    mov rsi, 0
    sub rsi, r12
    mov qword ptr [rbx+40], rsi
    mov rdi, 127
    call zyl_rt_sys_60
    jmp .L1315_0
zy_local_x2Fmain_0__proc__pr_x2Dredirect:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L1316_0:
    mov rsi, -100
    mov r8, 577
    mov r9, 420
    mov rdx, r8
    mov rcx, r9
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_257
    mov rbx, rax
    cmp rbx, 0
    jge .L1316_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1316_1:
    mov r12, 0
    cmp rbx, 1
    je .L1316_2
    mov rsi, 1
    mov rdi, rbx
    call zyl_rt_sys_33
    mov r12, rax
    mov rdi, rbx
    call zyl_rt_sys_3
.L1316_2:
    cmp r12, 0
    jge .L1316_3
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1316_3:
    mov rdi, 1
    mov rsi, 2
    call zyl_rt_sys_33
    mov rsi, rax
    cmp rsi, 0
    jge .L1316_4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1316_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dhas_x2Dslash:
.L1317_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 0
    jne .L1317_1
    mov rax, 0
    ret
.L1317_1:
    cmp rsi, 47
    jne .L1317_2
    mov rax, 1
    ret
.L1317_2:
    add rdi, 1
    jmp .L1317_0
zy_local_x2Fmain_0__proc__pr_x2Dstrnlen:
    mov r8, rdx
.L1318_0:
    cmp r8, rsi
    jge .L1318_2
.L1318_3:
    lea r9, [rdi+r8]
    movzx eax, byte ptr [r9+0]
    cmp rax, 0
    jne .L1318_1
.L1318_2:
    mov rax, r8
    ret
.L1318_1:
    add r8, 1
    cmp r8, rsi
    jge .L1318_2
    jmp .L1318_3
zy_local_x2Fmain_0__proc__pr_x2Dchrnul:
.L1319_0:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 0
    je .L1319_2
    cmp r8, rsi
    jne .L1319_1
.L1319_2:
    mov rax, rdi
    ret
.L1319_1:
    add rdi, 1
    jmp .L1319_0
zy_local_x2Fmain_0__proc__pr_x2Dexecvp:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L1320_0:
    movzx eax, byte ptr [r12+0]
    cmp rax, 0
    jne .L1320_1
    mov rax, -2
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1320_1:
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dhas_x2Dslash
    cmp rax, 0
    je .L1320_2
    mov rsi, qword ptr [rbx+8]
    mov rdi, qword ptr [rbx+16]
    mov rdx, rdi
    mov rdi, r12
    call zyl_rt_sys_59
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1320_2:
    mov rsi, qword ptr [rbx+48]
    cmp rsi, 0
    jne .L1320_3
    lea rax, [rip+.L1321]
    mov rdi, rax
    jmp .L1320_4
.L1320_3:
    mov rdi, rsi
.L1320_4:
    mov r13, rdi
    mov rsi, 255
    mov rdi, 0
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dstrnlen
    mov rsi, rax
    add rsi, 1
    cmp rsi, 255
    jle .L1320_5
    mov rax, -36
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1320_5:
    mov r8, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Dpath_x2Dloop
zy_local_x2Fmain_0__proc__pr_x2Dpath_x2Dnext_x2Dp:
.L1322_0:
    cmp rdi, 13
    jne .L1322_1
.L1322_6:
    mov rax, 1
    ret
.L1322_1:
    cmp rdi, 2
    jne .L1322_2
    mov rax, 1
    ret
.L1322_2:
    cmp rdi, 116
    jne .L1322_3
    mov rax, 1
    ret
.L1322_3:
    cmp rdi, 20
    jne .L1322_4
    mov rax, 1
    ret
.L1322_4:
    cmp rdi, 19
    jne .L1322_5
    mov rax, 1
    ret
.L1322_5:
    mov rax, rdi
    cmp rax, 110
    sete al
    movzx rax, al
    ret
zy_local_x2Fmain_0__proc__pr_x2Dpath_x2Dloop:
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
.L1323_0:
    mov rsi, 58
    mov rdi, r14
    call zy_local_x2Fmain_0__proc__pr_x2Dchrnul
    mov rbx, rax
    mov rsi, rbx
    sub rsi, r14
    lea rdi, [r13+1]
    lea rax, [rsi+rdi]
    cmp rax, 4400
    jle .L1323_1
    mov rdi, -36
    jmp .L1323_2
.L1323_1:
    mov rdi, qword ptr [rbp-48]
    mov rdx, rsi
    mov rsi, r14
    mov rcx, qword ptr [rbp-56]
    mov r8, r13
    call zy_local_x2Fmain_0__proc__pr_x2Dexec_x2Dat
    mov rdi, rax
.L1323_2:
    mov r12, rdi
    mov rdi, 0
    sub rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dpath_x2Dnext_x2Dp
    cmp rax, 0
    jne .L1323_3
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1323_3:
    cmp r15, 0
    je .L1323_4
    mov rsi, 1
    jmp .L1323_5
.L1323_4:
    mov rax, r12
    cmp rax, -13
    sete al
    movzx rax, al
    mov rsi, rax
.L1323_5:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L1323_6
    cmp rsi, 0
    je .L1323_7
    mov rax, -13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1323_7:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1323_6:
    lea r14, [rbx+1]
    mov r15, rsi
    jmp .L1323_0
zy_local_x2Fmain_0__proc__pr_x2Dexec_x2Dat:
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
    mov r13, rcx
    mov r14, r8
.L1324_0:
    lea r15, [rbx+64]
    mov rdi, r15
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r15+r12]
    mov rdi, 47
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, 1
    cmp r12, 0
    jg .L1324_1
    mov rsi, 0
.L1324_1:
    add rsi, r12
    lea rdi, [r15+rsi]
    mov rsi, r13
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, qword ptr [rbx+8]
    mov rdi, qword ptr [rbx+16]
    mov rdx, rdi
    mov rdi, r15
    call zyl_rt_sys_59
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_system_cmd
zyl_system_cmd:
    push rbx
    push r12
.L1325_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1325_1
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1325_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r12, rax
    lea rsi, [r12+16]
    lea rax, [rip+.L1326]
    mov rdi, rax
    mov qword ptr [rsi+0], rdi
    lea rax, [rip+.L1327]
    mov rdi, rax
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], rbx
    mov rdi, 0
    mov qword ptr [rsi+24], rdi
    lea rax, [rip+.L1328]
    mov rdi, rax
    mov r8, 0
    mov r9, 0
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, r12
    mov rcx, r8
    mov r8, r9
    call zy_local_x2Fmain_0__proc__pr_x2Dspawn
    mov rsi, rax
    mov rdi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwait
zy_local_x2Fmain_0__proc__pr_x2Dcat2:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1329_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    add rsi, r14
    lea rax, [r13-1]
    cmp rsi, rax
    jle .L1329_1
    lea rdi, [r13-1]
    jmp .L1329_2
.L1329_1:
    mov rdi, rsi
.L1329_2:
    mov r13, rdi
    lea rdi, [r13+1]
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    jne .L1329_3
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L1329_3:
    mov rsi, r13
    cmp r14, r13
    jg .L1329_4
    mov rsi, r14
.L1329_4:
    mov r14, rsi
    mov rdi, r15
    mov rsi, rbx
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rdi, [r15+r14]
    mov rsi, r13
    sub rsi, r14
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r15+r13]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall:
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
.L1330_0:
    cmp r13, 0
    jg .L1330_1
.L1330_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L1330_1:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L1330_2
    add r12, rsi
    sub r13, rsi
    cmp r13, 0
    jg .L1330_1
    jmp .L1330_4
.L1330_2:
    cmp rsi, -4
    jne .L1330_3
    cmp r13, 0
    jg .L1330_1
    jmp .L1330_4
.L1330_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dstr:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1331_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall
zy_local_x2Fmain_0__proc__pr_x2Dmkstemp:
    push rbx
    push r12
    mov rbx, rdi
.L1332_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    cmp r12, 6
    jl .L1332_2
    lea rsi, [r12-6]
    lea rdi, [rbx+rsi]
    lea rax, [rip+.L1333]
    mov rsi, rax
    mov r8, 6
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    cmp rax, 0
    jne .L1332_1
.L1332_2:
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1332_1:
    lea rsi, [r12-6]
    lea rdi, [rbx+rsi]
    mov rsi, 238328
    mov rdx, rsi
    mov rsi, rbx
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__proc__pr_x2Dmkstemp_x2Dtry
zy_local_x2Fmain_0__proc__pr_x2Dmkstemp_x2Dtry:
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
.L1334_0:
    cmp r13, 0
    jne .L1334_1
.L1334_6:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L1334_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_rand@tpoff]
    mov r14, rax
    mov rsi, 8
    mov rdi, r14
    call zyl_random_fill
    cmp rax, 8
    je .L1334_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1334_2:
    mov rsi, qword ptr [r14+0]
    mov rdi, 0
    cmp rdi, 6
    jge .L1334_3
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dfill_x2Dx
.L1334_3:
    mov rdi, -100
    mov rsi, 194
    mov r8, 384
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r8
    call zyl_rt_sys_257
    mov rsi, rax
    cmp rsi, 0
    jl .L1334_4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1334_4:
    cmp rsi, -17
    jne .L1334_5
    sub r13, 1
    cmp r13, 0
    jne .L1334_1
    jmp .L1334_6
.L1334_5:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dfill_x2Dx:
    mov r8, rdx
.L1335_0:
    cmp r8, 6
    jl .L1335_1
.L1335_2:
    mov rax, 0
    ret
.p2align 4
.L1335_1:
    lea r9, [rdi+r8]
    lea rax, [rip+.L1336]
    mov r10, rax
    mov r11, 62
    mov rdx, rsi
    mov rcx, r11
    mov rax, rdx
    xor edx, edx
    div rcx
    mov rax, rdx
    mov r11, rax
    add r10, r11
    movzx r10d, byte ptr [r10+0]
    mov byte ptr [r9+0], r10b
    mov r9, 62
    mov rdx, rsi
    mov rcx, r9
    mov rax, rdx
    xor edx, edx
    div rcx
    mov rsi, rax
    add r8, 1
    cmp r8, 6
    jl .L1335_1
    jmp .L1335_2
.globl zyl_exec_cmd
zyl_exec_cmd:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
.L1337_0:
    mov rbx, rdi
    lea rax, [rip+.L1338]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    cmp rsi, 0
    jne .L1337_1
    lea rax, [rip+.L1339]
    mov rdi, rax
    jmp .L1337_2
.L1337_1:
    mov rdi, rsi
.L1337_2:
    lea rax, [rip+.L1340]
    mov rsi, rax
    mov r8, 512
    mov rdx, r8
    call zy_local_x2Fmain_0__proc__pr_x2Dcat2
    mov r12, rax
    cmp r12, 0
    jne .L1337_3
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1337_3:
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dmkstemp
    mov r13, rax
    cmp r13, 0
    jge .L1337_4
    mov rdi, r12
    call zyl_rt_free
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1337_4:
    lea rax, [rip+.L1341]
    mov r14, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall
    cmp rbx, 0
    jne .L1337_5
    lea rax, [rip+.L1342]
    mov rsi, rax
    jmp .L1337_6
.L1337_5:
    mov rsi, rbx
.L1337_6:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall
    lea rax, [rip+.L1343]
    mov rbx, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall
    mov rdi, r13
    call zyl_rt_sys_3
    mov rsi, 493
    mov rdi, r12
    call zyl_rt_sys_90
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov rbx, rax
    add rbx, 16
    lea rax, [rip+.L1344]
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+8], r12
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    lea rax, [rip+.L1345]
    mov r13, rax
    call zyl_rt_envp
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zyl_rt_sys_59
    mov rdi, r12
    call zyl_rt_sys_87
    mov rdi, r12
    call zyl_rt_free
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dmtime:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rsi
.L1346_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_stat@tpoff]
    mov r12, rax
    mov rsi, r12
    call zyl_rt_sys_4
    cmp rax, 0
    je .L1346_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1346_1:
    mov rsi, qword ptr [r12+88]
    mov qword ptr [rbx+0], rsi
    mov rsi, qword ptr [r12+96]
    mov qword ptr [rbx+8], rsi
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dcc_x2Dargv:
    mov r8, rdx
.L1347_0:
    lea rax, [rip+.L1348]
    mov r9, rax
    mov qword ptr [rdi+0], r9
    lea rax, [rip+.L1349]
    mov r9, rax
    mov qword ptr [rdi+8], r9
    mov qword ptr [rdi+16], rsi
    lea rax, [rip+.L1350]
    mov rsi, rax
    mov qword ptr [rdi+24], rsi
    mov rsi, 4
    lea r9, [rsi*8]
    add r9, rdi
    lea rax, [rip+.L1351]
    mov r10, rax
    mov qword ptr [r9+0], r10
    lea r9, [rsi+1]
    shl r9, 3
    add r9, rdi
    mov qword ptr [r9+0], r8
    lea r8, [rsi+2]
    shl r8, 3
    add r8, rdi
    lea rax, [rip+.L1352]
    mov r9, rax
    mov qword ptr [r8+0], r9
    add rsi, 3
    shl rsi, 3
    add rsi, rdi
    mov rdi, 0
    mov qword ptr [rsi+0], rdi
    mov rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__proc__pr_x2Dout_x2Dpath:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L1353_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    cmp r13, 2
    jl .L1353_1
    lea rsi, [r13-2]
    add rsi, rbx
    movzx eax, byte ptr [rsi+0]
    cmp rax, 46
    jne .L1353_1
    lea rsi, [r13-1]
    add rsi, rbx
    movzx eax, byte ptr [rsi+0]
    cmp rax, 115
    jne .L1353_1
    lea rax, [r13-2]
    cmp rax, 512
    jl .L1353_2
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L1353_2:
    lea rsi, [r13-2]
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r13-2]
    add rsi, r12
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    ret
.L1353_1:
    lea rax, [r13+4]
    cmp rax, 512
    jl .L1353_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L1353_3:
    mov rdi, r12
    mov rsi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rdi, [r12+r13]
    lea rax, [rip+.L1354]
    mov rsi, rax
    mov r8, 5
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_cc_compile
zyl_cc_compile:
    push rbx
    push r12
.L1355_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1355_1
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1355_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r12, rax
    lea rsi, [r12+80]
    mov rdi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dout_x2Dpath
    cmp rax, 0
    jne .L1355_2
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1355_2:
    lea rdi, [r12+16]
    lea rsi, [r12+80]
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dcc_x2Dargv
    lea rax, [rip+.L1356]
    mov rsi, rax
    lea rdi, [r12+16]
    mov r8, 0
    mov r9, 1
    mov rdx, rdi
    mov rdi, r12
    mov rcx, r8
    mov r8, r9
    call zy_local_x2Fmain_0__proc__pr_x2Dspawn
    mov rsi, rax
    mov rdi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwait
.globl zyl_cc_compile_log
zyl_cc_compile_log:
    push rbx
    push r12
    push r13
.L1357_0:
    mov rbx, rdi
    mov r12, rsi
    cmp rbx, 0
    je .L1357_2
    cmp r12, 0
    jne .L1357_1
.L1357_2:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L1357_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r13, rax
    lea rsi, [r13+80]
    mov rdi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dout_x2Dpath
    cmp rax, 0
    jne .L1357_3
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret
.L1357_3:
    lea rdi, [r13+16]
    lea rsi, [r13+80]
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dcc_x2Dargv
    lea rax, [rip+.L1358]
    mov rsi, rax
    lea rdi, [r13+16]
    mov r8, 1
    mov rdx, rdi
    mov rdi, r13
    mov rcx, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dspawn
    mov rsi, rax
    mov rdi, r13
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwait
.globl zyl_run_bin
zyl_run_bin:
    push rbx
    push r12
.L1359_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1359_1
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1359_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r12, rax
    lea rsi, [r12+16]
    mov qword ptr [rsi+0], rbx
    mov rdi, 0
    mov qword ptr [rsi+8], rdi
    mov rdi, 0
    mov r8, 0
    mov rdx, rsi
    mov rsi, rbx
    mov rcx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dspawn
    mov rsi, rax
    mov rdi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwait
zy_local_x2Fmain_0__start__sr_x2Dult:
.L1360_0:
    mov r8, -9223372036854775808
    xor rdi, r8
    mov r8, -9223372036854775808
    xor rsi, r8
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    ret
zy_local_x2Fmain_0__start__sr_x2Draise_x2Dstack_x2Dlimit:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1361_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_start_rlimit@tpoff]
    mov rbx, rax
    mov rdi, 3
    mov rsi, rbx
    call zyl_rt_sys_97
    cmp rax, 0
    jne .L1361_1
    mov rdi, qword ptr [rbx+0]
    mov rsi, qword ptr [rbx+8]
    call zy_local_x2Fmain_0__start__sr_x2Dult
    cmp rax, 0
    je .L1361_1
    mov rsi, qword ptr [rbx+8]
    mov qword ptr [rbx+0], rsi
    mov rdi, 3
    mov rsi, rbx
    call zyl_rt_sys_160
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1361_1:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__start__sr_x2Dguard_x2Dinit:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1362_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_start_guard@tpoff]
    mov rbx, rax
    mov rsi, 8
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_318
    mov rsi, rax
    cmp rsi, -4
    jne .L1362_1
    jmp .L1362_0
.L1362_1:
    cmp rsi, 8
    jne .L1362_2
    mov rdi, qword ptr [rbx+0]
    jmp .L1362_3
.L1362_2:
    mov rdi, 0
.L1362_3:
    call zyl_rt_guard_set
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ensure_arenas
zyl_ensure_arenas:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1363_0:
    lea rax, [rip+zyl_rtg_start_once]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1363_1
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    call zy_local_x2Fmain_0__start__sr_x2Dguard_x2Dinit
    call zy_local_x2Fmain_0__start__sr_x2Draise_x2Dstack_x2Dlimit
    call zy_local_x2Fmain_0__start__sr_x2Dlibc_x2Datexit
    mov rax, QWORD PTR [rip+zyl_runtime_cleanup@GOTPCREL]
    mov rdi, rax
    call zyl_rt_atexit
    jmp .L1363_2
.L1363_1:
.L1363_2:
    mov rax, QWORD PTR [rip+zyl_actor_init@GOTPCREL]
    mov rdi, rax
    call zyl_rt_call0
    call zyl_arenas_init
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_runtime_cleanup
zyl_runtime_cleanup:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1364_0:
    call zyl_out_flush
    call zyl_ffi_abandoned
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 0
    jne .L1364_1
    call zyl_arenas_destroy
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1364_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_flush
zyl_term_flush:
.L1365_0:
    jmp zyl_out_flush
.globl zyl_term_atexit
zyl_term_atexit:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1366_0:
    mov rax, QWORD PTR [rip+zyl_term_restore_atexit@GOTPCREL]
    mov rdi, rax
    call zyl_rt_atexit
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__start__sr_x2Dlibc_x2Datexit:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1367_0:
    mov rax, QWORD PTR [rip+__cxa_atexit@GOTPCREL]
    mov rdi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1367_1
    cmp rdi, 0
    jle .L1367_1
    mov rax, QWORD PTR [rip+zyl_rt_run_atexit@GOTPCREL]
    mov rsi, rax
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    call zyl_rt_call3
    mov rsp, rbp
    pop rbp
    ret
.L1367_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dg:
.L1368_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Dlock:
.L1369_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    jmp zyl_rt_mutex_lock
zy_local_x2Fmain_0__chan__ch_x2Dunlock:
.L1370_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__chan__ch_x2Dwake:
.L1371_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    jmp zyl_rt_cond_broadcast
zy_local_x2Fmain_0__chan__ch_x2Dmode:
.L1372_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    ret
.globl zyl_chan_init
zyl_chan_init:
    push rbx
    push r12
    push r13
.L1373_0:
    lea rax, [rip+.L1374]
    mov rdi, rax
    call zyl_rt_getenv
    mov rbx, rax
    lea rax, [rip+.L1375]
    mov rdi, rax
    call zyl_rt_getenv
    mov r12, rax
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+32], rdi
    lea rax, [rip+zyl_rtg_chan_sched]
    mov r13, rax
    mov rsi, 0
    mov rdi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Ddigits
    mov rsi, rax
    or rsi, 1
    mov qword ptr [r13+40], rsi
    lea rax, [rip+zyl_rtg_chan_sched]
    mov r13, rax
    cmp rbx, 0
    jle .L1373_1
    lea rax, [rip+.L1376]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L1373_1
    mov rsi, 2
    jmp .L1373_2
.L1373_1:
    mov rdi, 3
    cmp r12, 0
    jg .L1373_3
    mov rdi, 1
.L1373_3:
    mov rsi, rdi
.L1373_2:
    mov qword ptr [r13+24], rsi
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__chan__ch_x2Ddigits:
.L1377_0:
    cmp rdi, 0
    jne .L1377_1
.L1377_3:
    mov rax, 0
    ret
.p2align 4
.L1377_1:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 48
    jl .L1377_2
    cmp r8, 57
    jg .L1377_2
    add rdi, 1
    imul rsi, rsi, 10
    sub r8, 48
    add rsi, r8
    cmp rdi, 0
    jne .L1377_1
    jmp .L1377_3
.L1377_2:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Ddet_x2Dp:
.L1378_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rsi, qword ptr [rsi+24]
    mov rax, rsi
    cmp rax, 2
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Dchaos:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1379_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 3
    je .L1379_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1379_1:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    add rsi, 48
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    mov rdi, qword ptr [rdi+40]
    mov r8, -7046029254386353131
    imul rsi, r8
    xor rdi, rsi
    call zy_local_x2Fmain_0__chan__ch_x2Dmix
    mov rsi, rax
    and rsi, 7
    cmp rsi, 4
    jge .L1379_2
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1379_2:
    cmp rsi, 6
    jge .L1379_3
    call zyl_rt_sys_24
    mov rsp, rbp
    pop rbp
    ret
.L1379_3:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_ts@tpoff]
    mov rdi, rax
    mov r8, 0
    mov qword ptr [rdi+0], r8
    mov r8, 20000
    cmp rsi, 6
    je .L1379_4
    mov r8, 200000
.L1379_4:
    mov qword ptr [rdi+8], r8
    mov rsi, 0
    call zyl_rt_sys_35
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dmix:
.L1380_0:
    mov rsi, 30
    mov rax, rdi
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    xor rsi, rdi
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
    mov rax, rsi
    xor rax, rdi
    ret
zy_local_x2Fmain_0__chan__ch_x2Dshr:
.L1381_0:
    mov rax, rdi
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    ret
zy_local_x2Fmain_0__chan__ch_x2Drec:
.L1382_0:
    lea rax, [rip+zyl_rtg_chan_owners]
    mov rsi, rax
    shl rdi, 5
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp:
.L1383_0:
    cmp rdi, 1
    jne .L1383_1
.L1383_5:
    mov r8, qword ptr [rsi+24]
    mov r9, qword ptr [rsi+8]
    mov rax, r8
    mov rcx, r9
    cmp rax, rcx
    setl al
    movzx rax, al
    ret
.L1383_1:
    cmp rdi, 2
    jne .L1383_2
    mov rax, qword ptr [rsi+24]
    cmp rax, 0
    jle .L1383_3
    mov rax, 1
    ret
.L1383_3:
    mov r8, qword ptr [rsi+32]
    mov rax, r8
    cmp rax, 1
    sete al
    movzx rax, al
    mov r8, rax
    mov rax, r8
    ret
.L1383_2:
    cmp rdi, 3
    jne .L1383_4
    mov rdi, rsi
    call zy_local_x2Fmain_0__chan__ch_x2Drec
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    mov rax, rsi
    cmp rax, 2
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    ret
.L1383_4:
    mov rax, 1
    ret
zy_local_x2Fmain_0__chan__ch_x2Dlive_x2Dp:
.L1384_0:
    cmp rdi, 1
    jne .L1384_1
.L1384_2:
    mov rax, 1
    ret
.L1384_1:
    call zy_local_x2Fmain_0__chan__ch_x2Drec
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    mov rax, rsi
    cmp rax, 1
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Dprogress_x2Dp:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L1385_0:
    cmp rbx, r12
    jle .L1385_1
.L1385_3:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L1385_1:
    lea rax, [rip+zyl_rtg_chan_owners]
    mov r13, rax
    mov rsi, rbx
    shl rsi, 5
    add r13, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dlive_x2Dp
    cmp rax, 0
    je .L1385_2
    mov rdi, qword ptr [r13+8]
    mov rsi, qword ptr [r13+16]
    call zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp
    cmp rax, 0
    je .L1385_2
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    ret
.L1385_2:
    add rbx, 1
    cmp rbx, r12
    jle .L1385_1
    jmp .L1385_3
zy_local_x2Fmain_0__chan__ch_x2Dwait:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L1386_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    mov rdi, 1
    cmp rsi, 0
    je .L1386_1
    mov rdi, rsi
.L1386_1:
    mov r13, rdi
    lea rax, [rip+zyl_rtg_chan_owners]
    mov r14, rax
    mov rsi, r13
    shl rsi, 5
    add r14, rsi
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp
    cmp rax, 0
    je .L1386_2
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 2
    jne .L1386_3
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+32]
    cmp rax, r13
    jne .L1386_2
.L1386_3:
    mov rsi, 0
    mov qword ptr [r14+8], rsi
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L1386_2:
    mov qword ptr [r14+8], rbx
    mov qword ptr [r14+16], r12
    call zy_local_x2Fmain_0__chan__ch_x2Dcheck
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 2
    jne .L1386_4
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+32]
    cmp rax, r13
    jne .L1386_4
    mov rdi, r13
    call zy_local_x2Fmain_0__chan__ch_x2Dpass
    jmp .L1386_5
.L1386_4:
.L1386_5:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    call zyl_rt_cond_wait
    jmp .L1386_0
zy_local_x2Fmain_0__chan__ch_x2Dcheck:
.L1387_0:
    mov rdi, 1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rsi, qword ptr [rsi+16]
    call zy_local_x2Fmain_0__chan__ch_x2Dprogress_x2Dp
    cmp rax, 0
    je .L1387_1
    mov rax, 0
    ret
.L1387_1:
    jmp zy_local_x2Fmain_0__chan__ch_x2Ddeadlock
zy_local_x2Fmain_0__chan__ch_x2Dpass:
    push rbx
    push r12
    mov rbx, rdi
.L1388_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov r12, qword ptr [rsi+16]
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Dsucc
    mov rdi, rax
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__chan__ch_x2Dnext_x2Dready
    mov rsi, rax
    cmp rsi, 0
    je .L1388_1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    mov qword ptr [rdi+32], rsi
.L1388_1:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    pop r12
    pop rbx
    jmp zyl_rt_cond_broadcast
zy_local_x2Fmain_0__chan__ch_x2Dsucc:
.L1389_0:
    cmp rdi, rsi
    jl .L1389_1
.L1389_2:
    mov rax, 1
    ret
.L1389_1:
    lea rax, [rdi+1]
    ret
zy_local_x2Fmain_0__chan__ch_x2Dnext_x2Dready:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1390_0:
    cmp rbx, r12
    jne .L1390_1
.L1390_4:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L1390_1:
    lea rax, [rip+zyl_rtg_chan_owners]
    mov r14, rax
    mov rsi, rbx
    shl rsi, 5
    add r14, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dlive_x2Dp
    cmp rax, 0
    je .L1390_2
    mov rdi, qword ptr [r14+8]
    mov rsi, qword ptr [r14+16]
    call zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp
    cmp rax, 0
    je .L1390_2
    mov rax, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L1390_2:
    mov rsi, 1
    cmp rbx, r13
    jge .L1390_3
    lea rsi, [rbx+1]
.L1390_3:
    mov rbx, rsi
    cmp rbx, r12
    jne .L1390_1
    jmp .L1390_4
zy_local_x2Fmain_0__chan__ch_x2Ddeadlock:
.L1391_0:
    mov rsi, 1
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rdi, rax
    mov qword ptr [rdi+0], rsi
    mov rdi, 2
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rsi, qword ptr [rsi+16]
    call zy_local_x2Fmain_0__chan__ch_x2Demit_x2Dall
    call zyl_out_flush
    lea rax, [rip+.L1392]
    mov rdi, rax
    call zyl_err_puts
    mov rdi, 1
    jmp zyl_chan_exit
zy_local_x2Fmain_0__chan__ch_x2Demit_x2Dall:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1393_0:
    cmp rbx, r12
    jle .L1393_1
.L1393_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.p2align 4
.L1393_1:
    mov rdi, rbx
    call zyl_out_actor_emit
    add rbx, 1
    cmp rbx, r12
    jle .L1393_1
    jmp .L1393_2
.globl zyl_chan_exit
zyl_chan_exit:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1394_0:
    call zyl_out_flush
    mov rax, QWORD PTR [rip+fflush@GOTPCREL]
    mov rdi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1394_1
    cmp rdi, 0
    jle .L1394_1
    mov rsi, 0
    call zyl_rt_call1
    jmp .L1394_2
.L1394_1:
.L1394_2:
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_sys_231
zy_local_x2Fmain_0__chan__ch_x2Dmagic:
.L1395_0:
    mov rax, 1514357326
    ret
zy_local_x2Fmain_0__chan__tx_x2Dmagic:
.L1396_0:
    mov rax, 1514363992
    ret
zy_local_x2Fmain_0__chan__rx_x2Dmagic:
.L1397_0:
    mov rax, 1514360920
    ret
zy_local_x2Fmain_0__chan__ch_x2Dpanic:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1398_0:
    call zyl_panic
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dendpoint:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1399_0:
    mov rdi, 24
    call zyl_heap_alloc
    mov rsi, rax
    mov qword ptr [rsi+0], rbx
    mov qword ptr [rsi+8], r12
    mov qword ptr [rsi+16], r13
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_chan_new
zyl_chan_new:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
.L1400_0:
    cmp rbx, 1
    jl .L1400_2
.L1400_5:
    cmp rbx, 16777216
    jle .L1400_1
.L1400_2:
    lea rax, [rip+.L1401]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zyl_panic
.L1400_1:
    mov rdi, 64
    call zyl_heap_alloc
    mov r12, rax
    lea rdi, [rbx*8]
    call zyl_heap_alloc
    mov r13, rax
    cmp r12, 0
    je .L1400_4
    cmp r13, 0
    jne .L1400_3
.L1400_4:
    lea rax, [rip+.L1402]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zyl_panic
.L1400_3:
    call zyl_owner_self
    mov r14, rax
    mov rsi, 1514357326
    mov qword ptr [r12+0], rsi
    mov qword ptr [r12+8], rbx
    mov rsi, 0
    mov qword ptr [r12+16], rsi
    mov rsi, 0
    mov qword ptr [r12+24], rsi
    mov rsi, 0
    mov qword ptr [r12+32], rsi
    mov rdi, 1514363992
    mov rsi, r12
    mov rdx, r14
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint
    mov rsi, rax
    mov qword ptr [r12+40], rsi
    mov rdi, 1514360920
    mov rsi, r12
    mov rdx, r14
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint
    mov rsi, rax
    mov qword ptr [r12+48], rsi
    mov qword ptr [r12+56], r13
    mov rdi, r12
    call zyl_chan_register
    mov rax, r12
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_chan_tx
zyl_chan_tx:
.L1403_0:
    mov rax, qword ptr [rdi+40]
    ret
.globl zyl_chan_rx
zyl_chan_rx:
.L1404_0:
    mov rax, qword ptr [rdi+48]
    ret
zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L1405_0:
    mov rdi, rbx
    call zyl_heap_block_p
    cmp rax, 0
    je .L1405_2
    lea rdi, [rbx+16]
    call zyl_heap_block_p
    cmp rax, 0
    jne .L1405_1
.L1405_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L1405_1:
    mov r12, qword ptr [rbx+0]
    cmp r12, 1514363992
    je .L1405_3
    cmp r12, 1514360920
    je .L1405_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L1405_3:
    mov r13, qword ptr [rbx+8]
    mov rdi, r13
    call zyl_heap_block_p
    cmp rax, 0
    je .L1405_5
    lea rdi, [r13+56]
    call zyl_heap_block_p
    cmp rax, 0
    jne .L1405_4
.L1405_5:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L1405_4:
    mov rax, qword ptr [r13+0]
    cmp rax, 1514357326
    jne .L1405_6
    mov rsi, 40
    cmp r12, 1514363992
    je .L1405_7
    mov rsi, 48
.L1405_7:
    add rsi, r13
    mov rsi, qword ptr [rsi+0]
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    sete al
    movzx rax, al
    pop r13
    pop r12
    pop rbx
    ret
.L1405_6:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__chan__ch_x2Down_x2Dcheck:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1406_0:
    mov rbx, qword ptr [rdi+16]
    call zyl_owner_self
    cmp rbx, rax
    jne .L1406_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1406_1:
    lea rax, [rip+.L1407]
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_chan_send
zyl_chan_send:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L1408_0:
    call zy_local_x2Fmain_0__chan__ch_x2Dchaos
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Down_x2Dcheck
    mov rdi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp
    mov r13, rax
    cmp r13, 0
    je .L1408_1
    mov rdi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Down_x2Dcheck
    jmp .L1408_2
.L1408_1:
.L1408_2:
    mov rbx, qword ptr [rbx+8]
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, 1
    mov rsi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dwait
    cmp r13, 0
    je .L1408_3
    mov rsi, 0
    mov qword ptr [r12+16], rsi
    jmp .L1408_4
.L1408_3:
.L1408_4:
    mov rsi, qword ptr [rbx+16]
    mov rdi, qword ptr [rbx+24]
    add rsi, rdi
    mov rdi, qword ptr [rbx+8]
    mov rax, rsi
    mov rcx, rdi
    cqo
    idiv rcx
    mov rax, rdx
    mov rsi, rax
    mov rdi, qword ptr [rbx+56]
    shl rsi, 3
    add rdi, rsi
    mov qword ptr [rdi+0], r12
    mov rsi, qword ptr [rbx+24]
    add rsi, 1
    mov qword ptr [rbx+24], rsi
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    call zyl_rt_cond_broadcast
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_unlock
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_chan_recv
zyl_chan_recv:
    push rbx
    push r12
    mov rbx, rdi
.L1409_0:
    call zy_local_x2Fmain_0__chan__ch_x2Dchaos
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Down_x2Dcheck
    mov rbx, qword ptr [rbx+8]
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, 2
    mov rsi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dwait
    mov rax, qword ptr [rbx+24]
    cmp rax, 0
    jne .L1409_1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_unlock
    lea rax, [rip+.L1410]
    mov rdi, rax
    pop r12
    pop rbx
    jmp zyl_panic
.L1409_1:
    mov rsi, qword ptr [rbx+16]
    mov rdi, qword ptr [rbx+56]
    lea r8, [rsi*8]
    add rdi, r8
    mov r12, qword ptr [rdi+0]
    add rsi, 1
    mov rdi, qword ptr [rbx+8]
    mov rax, rsi
    mov rcx, rdi
    cqo
    idiv rcx
    mov rax, rdx
    mov rsi, rax
    mov qword ptr [rbx+16], rsi
    mov rsi, qword ptr [rbx+24]
    sub rsi, 1
    mov qword ptr [rbx+24], rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp
    cmp rax, 0
    je .L1409_2
    mov rax, qword ptr [r12+16]
    cmp rax, 0
    jne .L1409_2
    call zyl_owner_self
    mov rsi, rax
    mov qword ptr [r12+16], rsi
    jmp .L1409_3
.L1409_2:
.L1409_3:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    call zyl_rt_cond_broadcast
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_unlock
    mov rax, r12
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__chan__ch_x2Dreg:
.L1411_0:
    lea rax, [rip+zyl_rtg_chan_reg]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_chan_register
zyl_chan_register:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
.L1412_0:
    lea rax, [rip+zyl_rtg_chan_reg]
    mov r12, rax
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov r13, qword ptr [r12+8]
    mov rax, qword ptr [r12+16]
    cmp r13, rax
    jge .L1412_1
    mov rsi, 1
    jmp .L1412_2
.L1412_1:
    mov rdi, 64
    cmp r13, 0
    je .L1412_3
    lea rdi, [r13*2]
.L1412_3:
    mov r14, rdi
    mov rdi, qword ptr [r12+0]
    lea r8, [r14*8]
    mov rsi, r8
    call zyl_rt_realloc
    mov rdi, rax
    mov r8, 0
    cmp rdi, 0
    je .L1412_4
    mov qword ptr [r12+0], rdi
    mov qword ptr [r12+16], r14
    mov r8, 1
.L1412_4:
    mov rsi, r8
.L1412_2:
    mov rax, rsi
    cmp rax, 0
    je .L1412_5
    mov rsi, qword ptr [r12+0]
    lea rdi, [r13*8]
    add rsi, rdi
    mov qword ptr [rsi+0], rbx
    lea rsi, [r13+1]
    mov qword ptr [r12+8], rsi
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zyl_rt_mutex_unlock
.L1412_5:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_unlock
    lea rax, [rip+.L1413]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zyl_panic
zy_local_x2Fmain_0__chan__ch_x2Dclose_x2Downed:
.L1414_0:
    lea rax, [rip+zyl_rtg_chan_reg]
    mov r8, rax
    mov rax, qword ptr [r8+8]
    cmp rsi, rax
    jl .L1414_1
    mov rax, 0
    ret
.L1414_1:
    mov r8, qword ptr [r8+0]
    lea r9, [rsi*8]
    add r8, r9
    mov r8, qword ptr [r8+0]
    mov r9, qword ptr [r8+40]
    mov rax, qword ptr [r9+16]
    cmp rax, rdi
    jne .L1414_2
    mov r9, 1
    mov qword ptr [r8+32], r9
    jmp .L1414_3
.L1414_2:
.L1414_3:
    add rsi, 1
    jmp .L1414_0
.globl zyl_chan_actor_spawn
zyl_chan_actor_spawn:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L1415_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Drec
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Drec
    mov rsi, rax
    mov rdi, 4
    mov qword ptr [rsi+8], rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Drec
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+24], rdi
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+16]
    cmp rbx, rax
    jle .L1415_1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov qword ptr [rsi+16], rbx
    jmp .L1415_2
.L1415_1:
.L1415_2:
    cmp r12, 0
    je .L1415_3
    mov r13, 0
    lea rsi, [r12-8]
    mov r14, qword ptr [rsi+0]
    call zyl_owner_self
    mov rsi, rax
    mov rdi, r12
    mov rdx, r14
    mov rcx, rsi
    mov rsi, r13
    mov r8, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dmove_x2Dwords
.L1415_3:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov r12, qword ptr [rsi+0]
    cmp r12, 0
    je .L1415_4
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+0], rdi
    mov r13, 0
    lea rsi, [r12-8]
    mov r14, qword ptr [rsi+0]
    call zyl_owner_self
    mov rsi, rax
    mov rdi, r12
    mov rdx, r14
    mov rcx, rsi
    mov rsi, r13
    mov r8, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dmove_x2Dwords
.L1415_4:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__chan__ch_x2Dmoves:
.L1416_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_chan_spawn_moves
zyl_chan_spawn_moves:
.L1417_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__chan__ch_x2Dmove_x2Dwords:
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
.L1418_0:
    cmp r12, r13
    jl .L1418_1
.L1418_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L1418_1:
    lea rsi, [r12*8]
    add rsi, qword ptr [rbp-48]
    mov rbx, qword ptr [rsi+0]
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp
    cmp rax, 0
    je .L1418_2
    mov rax, qword ptr [rbx+16]
    cmp rax, r14
    jne .L1418_2
    mov qword ptr [rbx+16], r15
    jmp .L1418_3
.L1418_2:
.L1418_3:
    add r12, 1
    cmp r12, r13
    jl .L1418_1
    jmp .L1418_4
.globl zyl_chan_actor_enter
zyl_chan_actor_enter:
.L1419_0:
    call zy_local_x2Fmain_0__chan__ch_x2Dchaos
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, 4
    mov rsi, 0
    call zy_local_x2Fmain_0__chan__ch_x2Dwait
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    jmp zyl_rt_mutex_unlock
.globl zyl_chan_actor_done
zyl_chan_actor_done:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1420_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dclose_x2Downed
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Drec
    mov rsi, rax
    mov qword ptr [rsi+24], r12
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Drec
    mov rsi, rax
    mov rdi, 2
    mov qword ptr [rsi+0], rdi
    call zy_local_x2Fmain_0__chan__ch_x2Dcheck
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 2
    jne .L1420_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dpass
    jmp .L1420_2
.L1420_1:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    call zyl_rt_cond_broadcast
.L1420_2:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    pop r12
    pop rbx
    jmp zyl_rt_mutex_unlock
.globl zyl_chan_actor_join
zyl_chan_actor_join:
    push rbx
    mov rbx, rdi
.L1421_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, 3
    mov rsi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dwait
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Drec
    mov rsi, rax
    mov rbx, qword ptr [rsi+24]
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_unlock
    mov rax, rbx
    pop rbx
    ret
.globl zyl_chan_main_done
zyl_chan_main_done:
.L1422_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, 1
    mov rsi, 0
    call zy_local_x2Fmain_0__chan__ch_x2Dclose_x2Downed
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    call zyl_rt_cond_broadcast
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__actor__ac_x2Dmax:
.L1423_0:
    mov rax, 1024
    ret
zy_local_x2Fmain_0__actor__ac_x2Dsys:
.L1424_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__actor__ac_x2Dslot:
.L1425_0:
    lea rax, [rip+zyl_rtg_actor_slots]
    mov rsi, rax
    shl rdi, 5
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__actor__ac_x2Dinited:
.L1426_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jne .L1426_1
    mov rax, 0
    ret
.L1426_1:
    mov rax, 1
    ret
zy_local_x2Fmain_0__actor__ac_x2Dnext:
.L1427_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_actor_init
zyl_actor_init:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1428_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    je .L1428_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1428_1:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rbx, rax
    mov rsi, 0
    mov qword ptr [rbx+0], rsi
    call zyl_chan_init
    mov rsi, 1
    mov qword ptr [rbx+8], rsi
    mov rax, QWORD PTR [rip+zyl_actor_wait_all@GOTPCREL]
    mov rdi, rax
    call zyl_rt_atexit
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_actor_abandon
zyl_actor_abandon:
.L1429_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+16], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__actor__ac_x2Dptr_x2Dp:
.L1430_0:
    cmp rdi, 0
    jge .L1430_1
.L1430_2:
    mov rax, 1
    ret
.L1430_1:
    mov rax, rdi
    cmp rax, 4096
    setge al
    movzx rax, al
    ret
.globl zyl_actor_spawn
zyl_actor_spawn:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1431_0:
    call zyl_actor_init
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dptr_x2Dp
    cmp rax, 0
    je .L1431_1
    mov rax, qword ptr [rbx+0]
    cmp rax, 2051230803
    jne .L1431_1
    mov rdi, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+16]
    mov r8, qword ptr [rbx+16]
    mov rdx, r8
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__actor__ac_x2Dspawn
.L1431_1:
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__actor__ac_x2Dspawn
.globl zyl_actor_id
zyl_actor_id:
.L1432_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__actor__ac_x2Dspawn:
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
.L1433_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov r14, rax
    cmp r14, 1024
    jl .L1433_1
    lea rax, [rip+.L1434]
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1433_1:
    mov rdi, r14
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov r15, rax
    mov qword ptr [r15+0], rbx
    mov qword ptr [r15+8], r12
    mov rsi, 0
    mov qword ptr [r15+24], rsi
    lea rdi, [r14+2]
    mov rsi, r13
    call zyl_chan_actor_spawn
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    mov rax, QWORD PTR [rip+zyl_actor_thread_entry@GOTPCREL]
    mov rdi, rax
    mov rsi, 0
    mov r8, 0
    mov rdx, rsi
    mov rsi, r14
    mov rcx, r8
    call zyl_rt_thread_create
    mov rsi, rax
    cmp rsi, 0
    jne .L1433_2
    lea rdi, [r14+2]
    mov r8, 0
    mov rsi, r8
    call zyl_chan_actor_done
    lea rax, [rip+.L1435]
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1433_2:
    mov qword ptr [r15+16], rsi
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_actor_body
zyl_actor_body:
.L1436_0:
    call zyl_owner_self
    mov rdi, rax
    sub rdi, 2
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    mov rsi, qword ptr [rsi+8]
    jmp zyl_rt_call1
.globl zyl_actor_thread_entry
zyl_actor_thread_entry:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L1437_0:
    mov rsi, 4294967295
    mov rbx, rdi
    and rbx, rsi
    lea rsi, [rbx+2]
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rdi, rax
    mov qword ptr [rdi+0], rsi
    call zyl_chan_actor_enter
    call zyl_try_push
    mov r12, rax
    mov r13, qword ptr [r12+64]
    mov rax, QWORD PTR [rip+zyl_actor_body@GOTPCREL]
    mov rsi, rax
    mov rdi, r12
    call zyl_rt_try_call
    cmp rax, 0
    jne .L1437_1
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov qword ptr [rsi+0], r13
    mov rdi, r12
    call zyl_rt_free
    lea rdi, [rbx+2]
    mov rsi, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zyl_chan_actor_done
.L1437_1:
    mov rsi, qword ptr [r12+72]
    cmp rsi, 0
    jne .L1437_2
    lea rax, [rip+.L1438]
    mov rdi, rax
    jmp .L1437_3
.L1437_2:
    mov rdi, rsi
.L1437_3:
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov r13, rax
    mov rdi, r12
    call zyl_rt_free
    lea rdi, [rbx+2]
    cmp r13, 0
    jne .L1437_4
    lea rax, [rip+.L1439]
    mov rsi, rax
    jmp .L1437_5
.L1437_4:
    mov rsi, r13
.L1437_5:
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zyl_chan_actor_done
zy_local_x2Fmain_0__actor__ac_x2Dvalid:
    push rbx
    mov rbx, rdi
.L1440_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    je .L1440_1
    cmp rbx, 0
    jl .L1440_2
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 1024
    jle .L1440_3
    mov rsi, 1024
    jmp .L1440_4
.L1440_3:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rdi, rax
    mov rsi, qword ptr [rdi+0]
.L1440_4:
    mov rax, rbx
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    pop rbx
    ret
.L1440_2:
    mov rax, 0
    pop rbx
    ret
.L1440_1:
    mov rax, 0
    pop rbx
    ret
.globl zyl_actor_wait
zyl_actor_wait:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L1441_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dvalid
    cmp rax, 0
    jne .L1441_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L1441_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov r12, rax
    mov rax, qword ptr [r12+24]
    cmp rax, 0
    je .L1441_2
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L1441_2:
    lea rdi, [rbx+2]
    call zyl_chan_actor_join
    mov r13, rax
    mov rdi, qword ptr [r12+16]
    call zyl_rt_thread_join
    mov rsi, 1
    mov qword ptr [r12+24], rsi
    lea rdi, [rbx+2]
    call zyl_out_actor_emit
    cmp r13, 0
    jne .L1441_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.L1441_3:
    mov rdi, r13
    pop r13
    pop r12
    pop rbx
    jmp zyl_panic
.globl zyl_actor_is_alive
zyl_actor_is_alive:
    push rbx
    mov rbx, rdi
.L1442_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dvalid
    cmp rax, 0
    jne .L1442_1
    mov rax, 0
    pop rbx
    ret
.L1442_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 0
    jne .L1442_2
    mov rax, 1
    pop rbx
    ret
.L1442_2:
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__actor__ac_x2Djoin_x2Drest:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1443_0:
    cmp rbx, r12
    jl .L1443_1
.L1443_4:
    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L1443_1:
    lea rax, [rip+zyl_rtg_actor_slots]
    mov r14, rax
    mov rsi, rbx
    shl rsi, 5
    add r14, rsi
    mov rax, qword ptr [r14+24]
    cmp rax, 0
    je .L1443_2
    add rbx, 1
    cmp rbx, r12
    jl .L1443_1
    jmp .L1443_4
.L1443_2:
    lea rdi, [rbx+2]
    call zyl_chan_actor_join
    mov r15, rax
    mov rdi, qword ptr [r14+16]
    call zyl_rt_thread_join
    mov rsi, 1
    mov qword ptr [r14+24], rsi
    lea rdi, [rbx+2]
    call zyl_out_actor_emit
    lea rsi, [rbx+1]
    cmp r13, 0
    je .L1443_3
    mov r15, r13
.L1443_3:
    mov r13, r15
    mov rbx, rsi
    cmp rbx, r12
    jl .L1443_1
    jmp .L1443_4
.globl zyl_actor_join_unjoined
zyl_actor_join_unjoined:
.L1444_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    jne .L1444_1
    mov rax, 0
    ret
.L1444_1:
    mov rdi, 0
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 1024
    jle .L1444_2
    mov rsi, 1024
    jmp .L1444_3
.L1444_2:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov r8, rax
    mov rsi, qword ptr [r8+0]
.L1444_3:
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__actor__ac_x2Djoin_x2Drest
    mov rdi, rax
    cmp rdi, 0
    jne .L1444_4
    mov rax, 0
    ret
.L1444_4:
    jmp zyl_panic
.globl zyl_actor_wait_all
zyl_actor_wait_all:
    push rbx
.L1445_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    je .L1445_2
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+16]
    cmp rax, 0
    je .L1445_1
.L1445_2:
    mov rax, 0
    pop rbx
    ret
.L1445_1:
    call zyl_chan_main_done
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 1024
    jle .L1445_3
    mov rsi, 1024
    jmp .L1445_4
.L1445_3:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rdi, rax
    mov rsi, qword ptr [rdi+0]
.L1445_4:
    mov rdi, 0
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__actor__ac_x2Djoin_x2Drest
    mov rbx, rax
    cmp rbx, 0
    jne .L1445_5
    mov rax, 0
    pop rbx
    ret
.L1445_5:
    call zyl_out_flush
    lea rax, [rip+.L1446]
    mov rdi, rax
    call zyl_err_puts
    mov rdi, rbx
    call zyl_err_puts
    lea rax, [rip+.L1447]
    mov rdi, rax
    call zyl_err_puts
    mov rdi, 1
    pop rbx
    jmp zyl_chan_exit
zy_local_x2Fmain_0__actor__bs_x2Dsize:
.L1448_0:
    cmp rdi, 0
    jne .L1448_1
.L1448_4:
    mov rax, 68719476736
    ret
.L1448_1:
    cmp rdi, 1
    jne .L1448_2
    mov rax, 17179869184
    ret
.L1448_2:
    cmp rdi, 2
    jne .L1448_3
    mov rax, 4294967296
    ret
.L1448_3:
    mov rax, 1073741824
    ret
.globl zyl_bigstack_tramp
zyl_bigstack_tramp:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1449_0:
    mov rdi, qword ptr [rbx+0]
    call zyl_rt_call0
    mov rsi, rax
    mov qword ptr [rbx+8], rsi
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_call_on_big_stack
zyl_call_on_big_stack:
    push rbx
    mov rbx, rdi
.L1450_0:
    mov rdi, 24
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L1450_1
    mov rdi, rbx
    pop rbx
    jmp zyl_rt_call0
.L1450_1:
    mov qword ptr [rsi+0], rbx
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    pop rbx
    jmp zy_local_x2Fmain_0__actor__bs_x2Dtry
zy_local_x2Fmain_0__actor__bs_x2Dunmap:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1451_0:
    call zyl_rt_sys_11
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__actor__bs_x2Dtry:
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
.L1452_0:
    cmp r13, 4
    jl .L1452_1
.L1452_7:
    mov rdi, r12
    call zyl_rt_free
    mov rdi, rbx
    call zyl_rt_call0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L1452_1:
    mov rsi, 68719476736
    cmp r13, 0
    je .L1452_2
    mov rdi, 17179869184
    cmp r13, 1
    je .L1452_3
    mov r8, 4294967296
    cmp r13, 2
    je .L1452_4
    mov r8, 1073741824
.L1452_4:
    mov rdi, r8
.L1452_3:
    mov rsi, rdi
.L1452_2:
    mov r14, rsi
    mov rdi, 0
    mov rsi, 3
    mov r8, 16418
    mov r9, -1
    mov r10, 0
    mov rdx, rsi
    mov rsi, r14
    mov rcx, r8
    mov r8, r9
    mov r9, r10
    call zyl_rt_sys_9
    mov r15, rax
    cmp r15, 0
    jge .L1452_5
    cmp r15, -4096
    jle .L1452_5
    add r13, 1
    cmp r13, 4
    jl .L1452_1
    jmp .L1452_7
.L1452_5:
    mov rsi, 4096
    mov rdi, 0
    mov rdx, rdi
    mov rdi, r15
    call zyl_rt_sys_10
    mov rsi, 0
    mov qword ptr [r12+8], rsi
    mov rax, QWORD PTR [rip+zyl_bigstack_tramp@GOTPCREL]
    mov rdi, rax
    mov rsi, r12
    mov rdx, r15
    mov rcx, r14
    call zyl_rt_thread_create
    mov rdi, rax
    cmp rdi, 0
    jne .L1452_6
    mov rdi, r15
    mov rsi, r14
    call zyl_rt_sys_11
    add r13, 1
    cmp r13, 4
    jl .L1452_1
    jmp .L1452_7
.L1452_6:
    call zyl_rt_thread_join
    mov rdi, r15
    mov rsi, r14
    call zyl_rt_sys_11
    mov rbx, qword ptr [r12+8]
    mov rdi, r12
    call zyl_rt_free
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dcell:
.L1453_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_worker@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Don_x2Dworker_x2Dcell:
.L1454_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_on_worker@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dany_x2Dabandoned:
.L1455_0:
    lea rax, [rip+zyl_rtg_ffi_any_abandoned]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_ffi_abandoned
zyl_ffi_abandoned:
.L1456_0:
    lea rax, [rip+zyl_rtg_ffi_any_abandoned]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_ffi_on_worker
zyl_ffi_on_worker:
.L1457_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_on_worker@tpoff]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dlock:
.L1458_0:
    mov rdi, qword ptr [rdi+0]
    jmp zyl_rt_mutex_lock
zy_local_x2Fmain_0__ffitimed__ff_x2Dunlock:
.L1459_0:
    mov rdi, qword ptr [rdi+0]
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__ffitimed__ff_x2Dcond:
.L1460_0:
    mov rax, qword ptr [rdi+8]
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dinvoke:
    push rbp
    mov rbp, rsp
    sub rsp, 120
    mov [rbp-120], rbx
    mov [rbp-112], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-16]
    mov rcx, 0
    cmp rax, rcx
    jne .L1461
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-8]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call0
    mov rsp, r12
    add rsp, 16
    jmp .L1462
.L1461:
    mov rax, [rbp-16]
    mov rcx, 1
    cmp rax, rcx
    jne .L1463
    sub rsp, 16
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov rsi, rax
    mov rdi, [rbp-8]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call1
    mov rsp, r12
    add rsp, 16
    jmp .L1464
.L1463:
    mov rax, [rbp-16]
    mov rcx, 2
    cmp rax, rcx
    jne .L1465
    sub rsp, 8
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rdx, [rsp+0]
    mov rsi, [rsp+8]
    mov rdi, [rsp+16]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call2
    mov rsp, r12
    add rsp, 32
    jmp .L1466
.L1465:
    mov rax, [rbp-16]
    mov rcx, 3
    cmp rax, rcx
    jne .L1467
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rcx, [rsp+0]
    mov rdx, [rsp+8]
    mov rsi, [rsp+16]
    mov rdi, [rsp+24]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call3
    mov rsp, r12
    add rsp, 32
    jmp .L1468
.L1467:
    mov rax, [rbp-16]
    mov rcx, 4
    cmp rax, rcx
    jne .L1469
    sub rsp, 8
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov r8, [rsp+0]
    mov rcx, [rsp+8]
    mov rdx, [rsp+16]
    mov rsi, [rsp+24]
    mov rdi, [rsp+32]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call4
    mov rsp, r12
    add rsp, 48
    jmp .L1470
.L1469:
    mov rax, [rbp-16]
    mov rcx, 5
    cmp rax, rcx
    jne .L1471
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov r9, [rsp+0]
    mov r8, [rsp+8]
    mov rcx, [rsp+16]
    mov rdx, [rsp+24]
    mov rsi, [rsp+32]
    mov rdi, [rsp+40]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call5
    mov rsp, r12
    add rsp, 48
    jmp .L1472
.L1471:
    mov rax, [rbp-16]
    mov rcx, 6
    cmp rax, rcx
    jne .L1473
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    jmp .L1474
.L1473:
    mov rax, [rbp-16]
    mov rcx, 7
    cmp rax, rcx
    jne .L1475
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    jmp .L1476
.L1475:
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rdx, [rsp+0]
    mov rsi, [rsp+8]
    mov rdi, [rsp+16]
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    jmp zyl_ffi_invoke_wide
.L1476:
.L1474:
.L1472:
.L1470:
.L1468:
.L1466:
.L1464:
.L1462:
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ffi_worker_main
zyl_ffi_worker_main:
    push rbx
    mov rbx, rdi
.L1477_0:
    mov rsi, qword ptr [rbx+32]
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rdi, rax
    mov qword ptr [rdi+0], rsi
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_on_worker@tpoff]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    mov rdi, qword ptr [rbx+0]
    call zyl_rt_mutex_lock
    mov rdi, rbx
    pop rbx
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dserve
zy_local_x2Fmain_0__ffitimed__ff_x2Dserve:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L1478_0:
    mov rax, qword ptr [rbx+16]
    cmp rax, 1
    je .L1478_1
    mov rdi, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+0]
    call zyl_rt_cond_wait
    jmp .L1478_0
.L1478_1:
    mov r12, qword ptr [rbx+40]
    mov r13, qword ptr [rbx+48]
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_args@tpoff]
    mov r14, rax
    lea rsi, [rbx+56]
    mov rdi, 128
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdi, qword ptr [rbx+0]
    mov rsi, -1
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    cmp rax, 1
    jne .L1478_2
    jmp .L1478_3
.L1478_2:
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rsi, 1
    mov r8, 129
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_202
.L1478_3:
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    call zy_local_x2Fmain_0__ffitimed__ff_x2Dinvoke
    mov r12, rax
    mov rdi, qword ptr [rbx+0]
    call zyl_rt_mutex_lock
    mov qword ptr [rbx+184], r12
    mov rsi, 2
    mov qword ptr [rbx+16], rsi
    mov rax, qword ptr [rbx+24]
    cmp rax, 0
    je .L1478_4
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dfinish
.L1478_4:
    mov rdi, qword ptr [rbx+8]
    mov rsi, 1
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, 2147483647
    mov r8, 129
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_202
    jmp .L1478_0
zy_local_x2Fmain_0__ffitimed__ff_x2Dfinish:
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L1479_0:
    mov r12, qword ptr [rbx+0]
    mov r13, qword ptr [rbx+8]
    mov rdi, r12
    call zyl_rt_mutex_unlock
    mov rdi, r13
    call zyl_rt_free
    mov rdi, r12
    call zyl_rt_free
    mov rdi, rbx
    call zyl_rt_free
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Doom:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1480_0:
    lea rax, [rip+.L1481]
    mov rdi, rax
    call zyl_panic
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dget:
.L1482_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_worker@tpoff]
    mov rdi, rax
    mov rsi, qword ptr [rdi+0]
    cmp rsi, 0
    jne .L1482_1
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dnew
.L1482_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dnew:
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
.L1483_0:
    mov rdi, 1
    mov rsi, 192
    call zyl_rt_calloc
    mov r12, rax
    cmp r12, 0
    jne .L1483_1
    lea rax, [rip+.L1484]
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1483_1:
    mov rdi, 40
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    mov rdi, 48
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r14, rax
    mov rdi, 8
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    mov rdi, 56
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov qword ptr [rbp-48], rax
    cmp r13, 0
    je .L1483_3
    cmp r14, 0
    je .L1483_3
    cmp r15, 0
    je .L1483_4
    cmp qword ptr [rbp-48], 0
    jne .L1483_2
.L1483_4:
.L1483_3:
    lea rax, [rip+.L1485]
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1483_2:
    mov rsi, 0
    mov qword ptr [r13+0], rsi
    mov rsi, 0
    mov qword ptr [r14+0], rsi
    mov rdi, r15
    call zyl_rt_free
    mov qword ptr [r12+0], r13
    mov qword ptr [r12+8], r14
    call zyl_owner_self
    mov rsi, rax
    mov qword ptr [r12+32], rsi
    mov rdi, rbx
    mov rsi, r12
    mov rdx, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dstart
zy_local_x2Fmain_0__ffitimed__ff_x2Dstart:
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
.L1486_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    mov rax, QWORD PTR [rip+zyl_ffi_worker_main@GOTPCREL]
    mov rdi, rax
    mov rsi, 0
    mov r8, 0
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r8
    call zyl_rt_thread_create
    mov r14, rax
    mov rdi, r13
    call zyl_rt_free
    cmp r14, 0
    jne .L1486_1
    lea rax, [rip+.L1487]
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1486_1:
    mov rdi, r14
    call zyl_rt_thread_detach
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_tid@tpoff]
    mov rsi, rax
    mov qword ptr [rsi+0], r14
    mov qword ptr [rbx+0], r12
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Ddeadline:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L1488_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_ts@tpoff]
    mov r12, rax
    mov rdi, 1
    mov rsi, r12
    call zyl_rt_sys_228
    mov rsi, qword ptr [r12+0]
    mov rcx, rbx
    movabs rax, 2361183241434822607
    imul rcx
    sar rdx, 7
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rdi, rax
    add rsi, rdi
    mov rdi, qword ptr [r12+8]
    mov rcx, rbx
    movabs rax, 2361183241434822607
    imul rcx
    sar rdx, 7
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    imul rdx, rdx, 1000
    mov rax, rcx
    sub rax, rdx
    mov r8, rax
    imul r8, r8, 1000000
    add rdi, r8
    cmp rdi, 1000000000
    jl .L1488_1
    lea r8, [rsi+1]
    mov qword ptr [r12+0], r8
    lea r8, [rdi-1000000000]
    mov qword ptr [r12+8], r8
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1488_1:
    mov qword ptr [r12+0], rsi
    mov qword ptr [r12+8], rdi
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dcopy_x2Dargs:
    mov r8, rdx
    mov r9, rcx
.L1489_0:
    cmp r9, r8
    jl .L1489_1
.L1489_2:
    mov rax, 0
    ret
.p2align 4
.L1489_1:
    lea r10, [r9*8]
    add r10, rdi
    lea r11, [r9*8]
    add r11, rsi
    mov r11, qword ptr [r11+0]
    mov qword ptr [r10+0], r11
    add r9, 1
    cmp r9, r8
    jl .L1489_1
    jmp .L1489_2
zy_local_x2Fmain_0__ffitimed__ff_x2Dcore:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
.L1490_0:
    call zyl_out_flush
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    mov r8, r15
    call zy_local_x2Fmain_0__ffitimed__ff_x2Dcore_x2Dgo
    mov rbx, rax
    call zy_local_x2Fmain_0__ffitimed__ff_x2Dlibc_x2Dflush
    mov rax, rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dlibc_x2Dflush:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1491_0:
    mov rax, QWORD PTR [rip+fflush@GOTPCREL]
    mov rdi, rax
    cmp rdi, 0
    jle .L1491_1
    mov rsi, 0
    call zyl_rt_call1
    mov rsp, rbp
    pop rbp
    ret
.L1491_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dcore_x2Dgo:
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
    mov rdi, rdx
    mov r12, rcx
    mov r13, r8
.L1492_0:
    cmp rsi, 0
    jne .L1492_1
.L1492_7:
    lea rax, [rip+.L1493]
    mov r8, rax
    jmp .L1492_2
.L1492_1:
    mov r8, rsi
.L1492_2:
    mov r14, r8
    cmp rbx, 4096
    jge .L1492_3
    lea rax, [rip+.L1494]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, r14
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1492_3:
    cmp r12, 0
    jl .L1492_5
    cmp r12, 16
    jle .L1492_4
.L1492_5:
    lea rax, [rip+.L1495]
    mov rsi, rax
    mov rdi, rsi
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1492_4:
    mov rsi, 1
    cmp rdi, 1
    jl .L1492_6
    mov rsi, rdi
.L1492_6:
    mov r15, rsi
    call zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dget
    mov qword ptr [rbp-48], rax
    mov rdi, r15
    call zy_local_x2Fmain_0__ffitimed__ff_x2Ddeadline
    mov qword ptr [rbp-56], rax
    mov rdx, qword ptr [rbp-48]
    mov rdi, qword ptr [rdx+0]
    call zyl_rt_mutex_lock
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+40], rbx
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+48], r12
    mov rsi, qword ptr [rbp-48]
    add rsi, 56
    mov rdi, 0
    mov r8, 128
    mov rdx, rsi
    mov rcx, rdi
    mov r11, r8
    push rdi
    mov rdi, rdx
    mov rax, rcx
    mov rcx, r11
    rep stosb
    pop rdi
    xor eax, eax
    mov rdi, qword ptr [rbp-48]
    add rdi, 56
    mov rsi, 0
    mov rdx, r12
    mov rcx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__ffitimed__ff_x2Dcopy_x2Dargs
    mov rsi, 1
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+16], rsi
    mov rdx, qword ptr [rbp-48]
    mov rdi, qword ptr [rdx+8]
    call zyl_rt_cond_broadcast
    mov rdi, qword ptr [rbp-48]
    mov rsi, qword ptr [rbp-56]
    mov rdx, r14
    mov rcx, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dawait
zy_local_x2Fmain_0__ffitimed__ff_x2Dawait:
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
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L1496_0:
    mov rdx, qword ptr [rbp-48]
    mov rax, qword ptr [rdx+16]
    cmp rax, 2
    jne .L1496_1
    mov rdx, qword ptr [rbp-48]
    mov r15, qword ptr [rdx+184]
    mov rsi, 0
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+16], rsi
    mov rdx, qword ptr [rbp-48]
    mov rdi, qword ptr [rdx+0]
    mov rsi, -1
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    cmp rax, 1
    jne .L1496_2
    jmp .L1496_3
.L1496_2:
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rsi, 1
    mov r8, 129
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_202
.L1496_3:
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1496_1:
    mov rdx, qword ptr [rbp-48]
    mov rdi, qword ptr [rdx+8]
    mov rdx, qword ptr [rbp-48]
    mov rsi, qword ptr [rdx+0]
    mov rdx, r12
    call zyl_rt_cond_timedwait
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 110
    jne .L1496_4
    mov rdx, qword ptr [rbp-48]
    mov rax, qword ptr [rdx+16]
    cmp rax, 2
    je .L1496_4
    mov rsi, 1
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+24], rsi
    mov rdx, qword ptr [rbp-48]
    mov rdi, qword ptr [rdx+0]
    mov rsi, -1
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    cmp rax, 1
    jne .L1496_5
    jmp .L1496_6
.L1496_5:
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rsi, 1
    mov r8, 129
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_202
.L1496_6:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_worker@tpoff]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+0], rdi
    lea rax, [rip+zyl_rtg_ffi_any_abandoned]
    mov rsi, rax
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    lea rax, [rip+.L1497]
    mov r15, rax
    lea rax, [rip+.L1498]
    mov rbx, rax
    mov rdi, r14
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L1499]
    mov rsi, rax
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
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1496_4:
    jmp .L1496_0
zy_local_x2Fmain_0__ffitimed__ff_x2Din_x2Dargs:
    push rbp
    mov rbp, rsp
    sub rsp, 360
    mov [rbp-360], rbx
    mov [rbp-352], r12
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
    mov r10, [rbp+56]
    mov [rbp-96], r10
    mov r10, [rbp+64]
    mov [rbp-104], r10
    mov r10, [rbp+72]
    mov [rbp-112], r10
    mov r10, [rbp+80]
    mov [rbp-120], r10
    mov r10, [rbp+88]
    mov [rbp-128], r10
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_in@tpoff]
    mov [rbp-136], rax
    mov rax, [rbp-136]
    push rax
    mov rax, [rbp-8]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-144], rax
    mov rax, [rbp-136]
    mov rcx, 8
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-152], rax
    mov rax, [rbp-136]
    mov rcx, 16
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-160], rax
    mov rax, [rbp-136]
    mov rcx, 24
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-168], rax
    mov rax, [rbp-136]
    mov rcx, 32
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-176], rax
    mov rax, [rbp-136]
    mov rcx, 40
    add rax, rcx
    push rax
    mov rax, [rbp-48]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-184], rax
    mov rax, [rbp-136]
    mov rcx, 48
    add rax, rcx
    push rax
    mov rax, [rbp-56]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-192], rax
    mov rax, [rbp-136]
    mov rcx, 56
    add rax, rcx
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-200], rax
    mov rax, [rbp-136]
    mov rcx, 64
    add rax, rcx
    push rax
    mov rax, [rbp-72]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-208], rax
    mov rax, [rbp-136]
    mov rcx, 72
    add rax, rcx
    push rax
    mov rax, [rbp-80]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-216], rax
    mov rax, [rbp-136]
    mov rcx, 80
    add rax, rcx
    push rax
    mov rax, [rbp-88]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-224], rax
    mov rax, [rbp-136]
    mov rcx, 88
    add rax, rcx
    push rax
    mov rax, [rbp-96]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-232], rax
    mov rax, [rbp-136]
    mov rcx, 96
    add rax, rcx
    push rax
    mov rax, [rbp-104]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-240], rax
    mov rax, [rbp-136]
    mov rcx, 104
    add rax, rcx
    push rax
    mov rax, [rbp-112]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-248], rax
    mov rax, [rbp-136]
    mov rcx, 112
    add rax, rcx
    push rax
    mov rax, [rbp-120]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-256], rax
    mov rax, [rbp-136]
    mov rcx, 120
    add rax, rcx
    push rax
    mov rax, [rbp-128]
    mov rcx, rax
    pop rdx
    mov qword ptr [rdx], rcx
    mov rax, rcx
    mov [rbp-264], rax
    mov rax, [rbp-136]
    mov rbx, [rbp-360]
    mov r12, [rbp-352]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ffi_timed
zyl_ffi_timed:
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
    mov r10, [rbp+40]
    mov [rbp-80], r10
    mov r10, [rbp+48]
    mov [rbp-88], r10
    mov r10, [rbp+56]
    mov [rbp-96], r10
    mov r10, [rbp+64]
    mov [rbp-104], r10
    mov r10, [rbp+72]
    mov [rbp-112], r10
    mov r10, [rbp+80]
    mov [rbp-120], r10
    mov r10, [rbp+88]
    mov [rbp-128], r10
    mov r10, [rbp+96]
    mov [rbp-136], r10
    mov r10, [rbp+104]
    mov [rbp-144], r10
    mov r10, [rbp+112]
    mov [rbp-152], r10
    mov r10, [rbp+120]
    mov [rbp-160], r10
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
    mov rax, [rbp-96]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-104]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-112]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-120]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-128]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-136]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-144]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-152]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-160]
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
    mov r10, [rsp+80]
    push r10
    mov r10, [rsp+96]
    push r10
    mov r10, [rsp+112]
    push r10
    mov r10, [rsp+128]
    push r10
    mov r10, [rsp+144]
    push r10
    mov r9, [rsp+160]
    mov r8, [rsp+168]
    mov rcx, [rsp+176]
    mov rdx, [rsp+184]
    mov rsi, [rsp+192]
    mov rdi, [rsp+200]
call zy_local_x2Fmain_0__ffitimed__ff_x2Din_x2Dargs
    add rsp, 208
    sub rsp, 8
    mov [rsp], rax
    mov r8, [rsp+0]
    mov rcx, [rsp+8]
    mov rdx, [rsp+16]
    mov rsi, [rsp+24]
    mov rdi, [rsp+32]
    mov rbx, [rbp-264]
    mov r12, [rbp-256]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dcore
    mov rbx, [rbp-264]
    mov r12, [rbp-256]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ffi_timed_argv
zyl_ffi_timed_argv:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L1500_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_in@tpoff]
    mov r15, rax
    mov rsi, 16
    cmp r14, 16
    jg .L1500_1
    mov rsi, r14
.L1500_1:
    mov rdi, 0
    mov rdx, rsi
    mov rsi, r8
    mov rcx, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__ffitimed__ff_x2Dcopy_x2Dargs
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    mov r8, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dcore
.globl zyl_ffi_invoke_wide
zyl_ffi_invoke_wide:
    push rbp
    mov rbp, rsp
    sub rsp, 120
    mov [rbp-120], rbx
    mov [rbp-112], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-16]
    mov rcx, 8
    cmp rax, rcx
    jne .L1501
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    mov r12, rsp
    sub rsp, 24
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
    mov r10, [r12+16]
    mov [rsp+16], r10
call zyl_rt_call8
    mov rsp, r12
    add rsp, 96
    jmp .L1502
.L1501:
    mov rax, [rbp-16]
    mov rcx, 9
    cmp rax, rcx
    jne .L1503
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    mov r9, [rsp+64]
    mov r8, [rsp+72]
    mov rcx, [rsp+80]
    mov rdx, [rsp+88]
    mov rsi, [rsp+96]
    mov rdi, [rsp+104]
    mov r12, rsp
    sub rsp, 32
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
    mov r10, [r12+16]
    mov [rsp+16], r10
    mov r10, [r12+24]
    mov [rsp+24], r10
call zyl_rt_call9
    mov rsp, r12
    add rsp, 112
    jmp .L1504
.L1503:
    mov rax, [rbp-16]
    mov rcx, 10
    cmp rax, rcx
    jne .L1505
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    mov r12, rsp
    sub rsp, 40
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
    mov r10, [r12+16]
    mov [rsp+16], r10
    mov r10, [r12+24]
    mov [rsp+24], r10
    mov r10, [r12+32]
    mov [rsp+32], r10
call zyl_rt_call10
    mov rsp, r12
    add rsp, 128
    jmp .L1506
.L1505:
    mov rax, [rbp-16]
    mov rcx, 11
    cmp rax, rcx
    jne .L1507
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    mov r10, [rsp+80]
    push r10
    mov r9, [rsp+96]
    mov r8, [rsp+104]
    mov rcx, [rsp+112]
    mov rdx, [rsp+120]
    mov rsi, [rsp+128]
    mov rdi, [rsp+136]
    mov r12, rsp
    sub rsp, 48
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
    mov r10, [r12+16]
    mov [rsp+16], r10
    mov r10, [r12+24]
    mov [rsp+24], r10
    mov r10, [r12+32]
    mov [rsp+32], r10
    mov r10, [r12+40]
    mov [rsp+40], r10
call zyl_rt_call11
    mov rsp, r12
    add rsp, 144
    jmp .L1508
.L1507:
    mov rax, [rbp-16]
    mov rcx, 12
    cmp rax, rcx
    jne .L1509
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    mov r10, [rsp+80]
    push r10
    mov r10, [rsp+96]
    push r10
    mov r9, [rsp+112]
    mov r8, [rsp+120]
    mov rcx, [rsp+128]
    mov rdx, [rsp+136]
    mov rsi, [rsp+144]
    mov rdi, [rsp+152]
    mov r12, rsp
    sub rsp, 56
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
    mov r10, [r12+16]
    mov [rsp+16], r10
    mov r10, [r12+24]
    mov [rsp+24], r10
    mov r10, [r12+32]
    mov [rsp+32], r10
    mov r10, [r12+40]
    mov [rsp+40], r10
    mov r10, [r12+48]
    mov [rsp+48], r10
call zyl_rt_call12
    mov rsp, r12
    add rsp, 160
    jmp .L1510
.L1509:
    mov rax, [rbp-16]
    mov rcx, 13
    cmp rax, rcx
    jne .L1511
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 96
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    mov r10, [rsp+80]
    push r10
    mov r10, [rsp+96]
    push r10
    mov r10, [rsp+112]
    push r10
    mov r9, [rsp+128]
    mov r8, [rsp+136]
    mov rcx, [rsp+144]
    mov rdx, [rsp+152]
    mov rsi, [rsp+160]
    mov rdi, [rsp+168]
    mov r12, rsp
    sub rsp, 64
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
    mov r10, [r12+16]
    mov [rsp+16], r10
    mov r10, [r12+24]
    mov [rsp+24], r10
    mov r10, [r12+32]
    mov [rsp+32], r10
    mov r10, [r12+40]
    mov [rsp+40], r10
    mov r10, [r12+48]
    mov [rsp+48], r10
    mov r10, [r12+56]
    mov [rsp+56], r10
call zyl_rt_call13
    mov rsp, r12
    add rsp, 176
    jmp .L1512
.L1511:
    mov rax, [rbp-16]
    mov rcx, 14
    cmp rax, rcx
    jne .L1513
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 96
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 104
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    mov r10, [rsp+80]
    push r10
    mov r10, [rsp+96]
    push r10
    mov r10, [rsp+112]
    push r10
    mov r10, [rsp+128]
    push r10
    mov r9, [rsp+144]
    mov r8, [rsp+152]
    mov rcx, [rsp+160]
    mov rdx, [rsp+168]
    mov rsi, [rsp+176]
    mov rdi, [rsp+184]
    mov r12, rsp
    sub rsp, 72
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
    mov r10, [r12+16]
    mov [rsp+16], r10
    mov r10, [r12+24]
    mov [rsp+24], r10
    mov r10, [r12+32]
    mov [rsp+32], r10
    mov r10, [r12+40]
    mov [rsp+40], r10
    mov r10, [r12+48]
    mov [rsp+48], r10
    mov r10, [r12+56]
    mov [rsp+56], r10
    mov r10, [r12+64]
    mov [rsp+64], r10
call zyl_rt_call14
    mov rsp, r12
    add rsp, 192
    jmp .L1514
.L1513:
    mov rax, [rbp-16]
    mov rcx, 15
    cmp rax, rcx
    jne .L1515
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 96
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 104
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 112
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    mov r10, [rsp+80]
    push r10
    mov r10, [rsp+96]
    push r10
    mov r10, [rsp+112]
    push r10
    mov r10, [rsp+128]
    push r10
    mov r10, [rsp+144]
    push r10
    mov r9, [rsp+160]
    mov r8, [rsp+168]
    mov rcx, [rsp+176]
    mov rdx, [rsp+184]
    mov rsi, [rsp+192]
    mov rdi, [rsp+200]
    mov r12, rsp
    sub rsp, 80
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
    mov r10, [r12+16]
    mov [rsp+16], r10
    mov r10, [r12+24]
    mov [rsp+24], r10
    mov r10, [r12+32]
    mov [rsp+32], r10
    mov r10, [r12+40]
    mov [rsp+40], r10
    mov r10, [r12+48]
    mov [rsp+48], r10
    mov r10, [r12+56]
    mov [rsp+56], r10
    mov r10, [r12+64]
    mov [rsp+64], r10
    mov r10, [r12+72]
    mov [rsp+72], r10
call zyl_rt_call15
    mov rsp, r12
    add rsp, 208
    jmp .L1516
.L1515:
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 96
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 104
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 112
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 120
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
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
    mov r10, [rsp+80]
    push r10
    mov r10, [rsp+96]
    push r10
    mov r10, [rsp+112]
    push r10
    mov r10, [rsp+128]
    push r10
    mov r10, [rsp+144]
    push r10
    mov r10, [rsp+160]
    push r10
    mov r9, [rsp+176]
    mov r8, [rsp+184]
    mov rcx, [rsp+192]
    mov rdx, [rsp+200]
    mov rsi, [rsp+208]
    mov rdi, [rsp+216]
    mov r12, rsp
    sub rsp, 88
    and rsp, -16
    mov r10, [r12+0]
    mov [rsp+0], r10
    mov r10, [r12+8]
    mov [rsp+8], r10
    mov r10, [r12+16]
    mov [rsp+16], r10
    mov r10, [r12+24]
    mov [rsp+24], r10
    mov r10, [r12+32]
    mov [rsp+32], r10
    mov r10, [r12+40]
    mov [rsp+40], r10
    mov r10, [r12+48]
    mov [rsp+48], r10
    mov r10, [r12+56]
    mov [rsp+56], r10
    mov r10, [r12+64]
    mov [rsp+64], r10
    mov r10, [r12+72]
    mov [rsp+72], r10
    mov r10, [r12+80]
    mov [rsp+80], r10
call zyl_rt_call16
    mov rsp, r12
    add rsp, 224
.L1516:
.L1514:
.L1512:
.L1510:
.L1508:
.L1506:
.L1504:
.L1502:
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Derr:
.L1517_0:
    jmp zyl_err_puts
zy_local_x2Fmain_0__panic__pn_x2Dout:
.L1518_0:
    jmp zyl_out_puts
zy_local_x2Fmain_0__panic__pn_x2Ds:
.L1519_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtop:
.L1520_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_try_push
zyl_try_push:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1521_0:
    mov rdi, 88
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rbx, rax
    cmp rbx, 0
    jne .L1521_1
    mov rdi, 88
    lea rax, [rip+.L1522]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L1521_2
.L1521_1:
.L1521_2:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    mov qword ptr [rbx+64], rdi
    mov rdi, 0
    mov qword ptr [rbx+72], rdi
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rdi, rax
    mov qword ptr [rbx+80], rdi
    mov qword ptr [rsi+0], rbx
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_try_pop
zyl_try_pop:
.L1523_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    cmp rdi, 0
    jne .L1523_1
    mov rax, 0
    ret
.L1523_1:
    mov r8, qword ptr [rdi+64]
    mov qword ptr [rsi+0], r8
    call zyl_rt_free
    mov rax, 0
    ret
.globl zyl_try_last_msg
zyl_try_last_msg:
.L1524_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L1524_1
    mov rax, 0
    ret
.L1524_1:
    mov rax, qword ptr [rsi+72]
    ret
.globl zyl_try_frame_msg
zyl_try_frame_msg:
    push rbx
.L1525_0:
    cmp rdi, 0
    jne .L1525_1
.L1525_2:
    mov rax, 0
    pop rbx
    ret
.L1525_1:
    mov rbx, qword ptr [rdi+72]
    call zyl_rt_free
    mov rax, rbx
    pop rbx
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtstate:
.L1526_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtests:
.L1527_0:
    lea rax, [rip+zyl_rtg_tests]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtbuf:
.L1528_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov rsi, rax
    add rsi, 24
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtmsg:
.L1529_0:
    lea rax, [rip+zyl_rtg_test_msg]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dfail_x2Dline:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L1530_0:
    lea rax, [rip+zyl_rtg_test_msg]
    mov rsi, rax
    mov rbx, qword ptr [rsi+0]
    cmp rbx, 0
    jne .L1530_1
    lea rax, [rip+.L1531]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1530_1:
    lea rax, [rip+zyl_rtg_test_msg]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+0], rdi
    lea rax, [rip+.L1532]
    mov r12, rax
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dline_x2Dlen
    mov rsi, rax
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
    mov rdi, rax
    lea rax, [rip+.L1533]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov r12, rax
    mov rdi, rbx
    call zyl_rt_free
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dline_x2Dlen:
.L1534_0:
    lea r8, [rdi+rsi]
    movzx r8d, byte ptr [r8+0]
    cmp r8, 0
    je .L1534_2
    cmp r8, 10
    jne .L1534_1
.L1534_2:
    mov rax, rsi
    ret
.L1534_1:
    add rsi, 1
    jmp .L1534_0
.globl zyl_register_test
zyl_register_test:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, rsi
.L1535_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov qword ptr [rbp-48], rax
    mov rdx, qword ptr [rbp-48]
    mov r13, qword ptr [rdx+0]
    cmp r13, 256
    jl .L1535_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1535_1:
    lea rax, [rip+zyl_rtg_tests]
    mov r14, rax
    imul rsi, r13, 136
    add r14, rsi
    mov r15, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 127
    cmp rsi, 127
    jg .L1535_2
    mov rdi, rsi
.L1535_2:
    mov r12, rdi
    mov rdi, r14
    mov rsi, r15
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r14+r12]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov qword ptr [r14+128], rbx
    lea rsi, [r13+1]
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+0], rsi
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dint_x2Dtext:
.L1536_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
.globl zyl_run_tests
zyl_run_tests:
.L1537_0:
    mov rdi, 0
    mov rsi, 0
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__panic__pn_x2Drun_x2Dtests
.globl zyl_run_tests_matching
zyl_run_tests_matching:
.L1538_0:
    mov rsi, 0
    mov r8, 0
    mov r9, 0
    mov rdx, r9
    mov rcx, rdi
    mov rdi, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__panic__pn_x2Drun_x2Dtests
zy_local_x2Fmain_0__panic__pn_x2Dcontains:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1539_0:
    movzx eax, byte ptr [r12+0]
    cmp rax, 0
    jne .L1539_1
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1539_1:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L1539_2
    mov rax, 0
    pop r12
    pop rbx
    ret
.L1539_2:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__panic__pn_x2Dprefix
    cmp rax, 0
    je .L1539_3
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1539_3:
    add rbx, 1
    jmp .L1539_0
zy_local_x2Fmain_0__panic__pn_x2Dprefix:
.L1540_0:
    movzx eax, byte ptr [rsi+0]
    cmp rax, 0
    jne .L1540_1
    mov rax, 1
    ret
.L1540_1:
    movzx r8d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r8, rax
    jne .L1540_2
    add rdi, 1
    add rsi, 1
    jmp .L1540_0
.L1540_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__panic__pn_x2Drun_x2Dtests:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 48
    mov qword ptr [rbp-48], rdi
    mov qword ptr [rbp-56], rsi
    mov qword ptr [rbp-64], rdx
    mov qword ptr [rbp-72], rcx
.L1541_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov qword ptr [rbp-80], rax
    mov rdx, qword ptr [rbp-80]
    mov rax, qword ptr [rdx+0]
    cmp qword ptr [rbp-48], rax
    jl .L1541_1
    lea rax, [rip+.L1542]
    mov rbx, rax
    mov rsi, 0
    mov rdi, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r12, rax
    lea rax, [rip+.L1543]
    mov r13, rax
    mov rsi, 0
    mov rdi, qword ptr [rbp-64]
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r14, rax
    lea rax, [rip+.L1544]
    mov r15, rax
    mov rdi, qword ptr [rbp-56]
    add rdi, qword ptr [rbp-64]
    mov rsi, 0
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov rdi, rax
    lea rax, [rip+.L1545]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r15
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r14
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
    mov rdi, rax
    call zyl_out_puts
    cmp qword ptr [rbp-64], 0
    jle .L1541_2
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1541_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1541_1:
    lea rax, [rip+zyl_rtg_tests]
    mov rbx, rax
    imul rsi, qword ptr [rbp-48], 136
    add rbx, rsi
    cmp qword ptr [rbp-72], 0
    je .L1541_3
    mov rdi, rbx
    mov rsi, qword ptr [rbp-72]
    call zy_local_x2Fmain_0__panic__pn_x2Dcontains
    cmp rax, 0
    jne .L1541_3
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    jmp .L1541_0
.L1541_3:
    lea rax, [rip+.L1546]
    mov r12, rax
    lea rax, [rip+.L1547]
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_out_puts
    call zyl_out_flush
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rsi, rax
    mov rdx, qword ptr [rbp-80]
    mov qword ptr [rdx+16], rsi
    mov rsi, 1
    mov rdx, qword ptr [rbp-80]
    mov qword ptr [rdx+8], rsi
    lea rax, [rip+zyl_rtg_test_state]
    mov rdi, rax
    add rdi, 24
    mov rsi, qword ptr [rbx+128]
    call zyl_rt_try_call
    cmp rax, 0
    jne .L1541_4
    mov rsi, 0
    mov rdx, qword ptr [rbp-80]
    mov qword ptr [rdx+8], rsi
    lea rax, [rip+zyl_rtg_test_state]
    mov rsi, rax
    add rsi, 24
    mov rsi, qword ptr [rsi+64]
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 0
    jne .L1541_5
    lea rax, [rip+.L1548]
    mov rdi, rax
    call zyl_out_puts
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-56]
    add rax, 1
    mov qword ptr [rbp-56], rax
    jmp .L1541_0
.L1541_5:
    call zy_local_x2Fmain_0__panic__pn_x2Dfail_x2Dline
    mov rdi, rax
    call zyl_out_puts
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-64]
    add rax, 1
    mov qword ptr [rbp-64], rax
    jmp .L1541_0
.L1541_4:
    call zy_local_x2Fmain_0__panic__pn_x2Dfail_x2Dline
    mov rdi, rax
    call zyl_out_puts
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-64]
    add rax, 1
    mov qword ptr [rbp-64], rax
    jmp .L1541_0
.globl zyl_panic
zyl_panic:
    push rbx
.L1549_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rbx, qword ptr [rsi+0]
    cmp rbx, 0
    jne .L1549_1
    pop rbx
    jmp zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Dtest
.L1549_1:
    mov r8, qword ptr [rbx+64]
    mov qword ptr [rsi+0], r8
    cmp rdi, 0
    jne .L1549_2
    lea rax, [rip+.L1550]
    mov rsi, rax
    jmp .L1549_3
.L1549_2:
    mov rsi, rdi
.L1549_3:
    mov qword ptr [rbx+72], rsi
    mov rdi, qword ptr [rbx+80]
    call zyl_region_unwind
    mov rsi, 1
    mov rdi, rbx
    pop rbx
    jmp zyl_rt_longjmp
zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Dtest:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1551_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov r12, rax
    mov rax, qword ptr [r12+8]
    cmp rax, 0
    je .L1551_1
    call zyl_ffi_on_worker
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 0
    jne .L1551_1
    mov rsi, 0
    mov qword ptr [r12+8], rsi
    lea rax, [rip+zyl_rtg_test_msg]
    mov r13, rax
    mov rsi, 0
    cmp rbx, 0
    je .L1551_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov rsi, rax
.L1551_2:
    mov qword ptr [r13+0], rsi
    mov rdi, qword ptr [r12+16]
    call zyl_region_unwind
    lea rax, [rip+zyl_rtg_test_state]
    mov rdi, rax
    add rdi, 24
    mov rsi, 1
    call zyl_rt_longjmp
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1551_1:
    call zyl_actor_abandon
    cmp rbx, 0
    jne .L1551_3
    lea rax, [rip+.L1552]
    mov rsi, rax
    jmp .L1551_4
.L1551_3:
    mov rsi, rbx
.L1551_4:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rdi, rax
    mov rax, qword ptr [rdi+0]
    cmp rax, 0
    jne .L1551_5
    lea rax, [rip+.L1553]
    mov rbx, rax
    lea rax, [rip+.L1554]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_cstr_concat
    mov rdi, rax
    mov rsi, rdi
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_err_puts
    jmp .L1551_6
.L1551_5:
    mov rdi, rsi
    call zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Djson
.L1551_6:
    mov rdi, 1
    call zyl_rt_exit
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Djson:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1555_0:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 123
    jne .L1555_1
    lea rax, [rip+.L1556]
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zyl_err_puts
.L1555_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dlen
    mov r12, rax
    cmp r12, 0
    jle .L1555_2
    cmp r12, 128
    jge .L1555_2
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
    mov r13, rax
    lea rsi, [r12+1]
    lea rdi, [rbx+rsi]
    call zy_local_x2Fmain_0__panic__pn_x2Dskip_x2Dsp
    mov rsi, rax
    mov rdi, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag
.L1555_2:
    lea rax, [rip+.L1557]
    mov rsi, rax
    mov rdi, 6
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp
    cmp rax, 0
    je .L1555_3
    lea rdi, [rbx+6]
    call zy_local_x2Fmain_0__panic__pn_x2Dfind_x2Dclose
    mov r12, rax
    cmp r12, 0
    jle .L1555_4
    movzx eax, byte ptr [r12+1]
    cmp rax, 58
    jne .L1555_4
    mov rsi, r12
    sub rsi, rbx
    sub rsi, 6
    cmp rsi, 128
    jge .L1555_4
    lea rdi, [rbx+6]
    mov rsi, r12
    sub rsi, rbx
    sub rsi, 6
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
    mov r13, rax
    lea rdi, [r12+2]
    call zy_local_x2Fmain_0__panic__pn_x2Dskip_x2Dsp
    mov rsi, rax
    mov rdi, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag
.L1555_4:
    lea rax, [rip+.L1558]
    mov rdi, rax
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag
.L1555_3:
    lea rax, [rip+.L1559]
    mov rdi, rax
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag
zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rsi
.L1560_0:
    lea rax, [rip+.L1561]
    mov r12, rax
    call zyl_json_quote
    mov r13, rax
    lea rax, [rip+.L1562]
    mov r14, rax
    mov rdi, rbx
    call zyl_json_quote
    mov rdi, rax
    lea rax, [rip+.L1563]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r14
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r13
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zyl_err_puts
zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dlen:
    push rbx
    mov rbx, rdi
.L1564_0:
    movzx esi, byte ptr [rbx+0]
    cmp rsi, 69
    je .L1564_2
    cmp rsi, 87
    jne .L1564_1
.L1564_2:
    movzx eax, byte ptr [rbx+1]
    cmp rax, 95
    jne .L1564_1
    mov rsi, 2
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dscan
    mov rsi, rax
    lea rdi, [rbx+rsi]
    movzx eax, byte ptr [rdi+0]
    cmp rax, 58
    jne .L1564_3
    mov rax, rsi
    pop rbx
    ret
.L1564_3:
    mov rax, 0
    pop rbx
    ret
.L1564_1:
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dscan:
.L1565_0:
    lea r8, [rdi+rsi]
    movzx r8d, byte ptr [r8+0]
    cmp r8, 65
    jl .L1565_3
    cmp r8, 90
    jle .L1565_2
.L1565_3:
    cmp r8, 48
    jl .L1565_5
    cmp r8, 57
    jle .L1565_4
.L1565_5:
    cmp r8, 95
    jne .L1565_1
.L1565_4:
.L1565_2:
    add rsi, 1
    jmp .L1565_0
.L1565_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dskip_x2Dsp:
.L1566_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 32
    jne .L1566_1
    add rdi, 1
    jmp .L1566_0
.L1566_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__panic__pn_x2Derror_x2Dbracket_x2Dp:
.L1567_0:
    lea rax, [rip+.L1568]
    mov rsi, rax
    mov r8, 6
    mov rdx, r8
    jmp zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp
zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp:
    mov r8, rdx
.L1569_0:
    cmp r8, 0
    jne .L1569_1
.L1569_4:
    mov rax, 1
    ret
.p2align 4
.L1569_1:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    je .L1569_2
    mov rax, 0
    ret
.L1569_2:
    cmp r9, 0
    jne .L1569_3
    mov rax, 1
    ret
.L1569_3:
    add rdi, 1
    add rsi, 1
    sub r8, 1
    cmp r8, 0
    jne .L1569_1
    jmp .L1569_4
zy_local_x2Fmain_0__panic__pn_x2Dfind_x2Dclose:
.L1570_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 93
    jne .L1570_1
    mov rax, rdi
    ret
.L1570_1:
    cmp rsi, 0
    jne .L1570_2
    mov rax, 0
    ret
.L1570_2:
    add rdi, 1
    jmp .L1570_0
.globl zyl_f_error
zyl_f_error:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1571_0:
    cmp rdi, 0
    jne .L1571_1
    lea rax, [rip+.L1572]
    mov rsi, rax
    mov rdi, rsi
    call zyl_err_puts
    jmp .L1571_2
.L1571_1:
    lea rax, [rip+.L1573]
    mov rbx, rax
    lea rax, [rip+.L1574]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_err_puts
.L1571_2:
    mov rdi, 1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_exit
zy_local_x2Fmain_0__panic__pn_x2Ddiag:
.L1575_0:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_diag_json
zyl_diag_json:
.L1576_0:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_diag_json_set
zyl_diag_json_set:
.L1577_0:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov r8, 0
    cmp rdi, 0
    je .L1577_1
    mov r8, 1
.L1577_1:
    mov qword ptr [rsi+0], r8
    mov rax, 0
    ret
zy_local_x2Fmain_0__panic__pn_x2Dwarn:
.L1578_0:
    lea rax, [rip+zyl_rtg_warn]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_warn_capture
zyl_warn_capture:
.L1579_0:
    lea rax, [rip+zyl_rtg_warn]
    mov rsi, rax
    mov r8, 0
    cmp rdi, 0
    je .L1579_1
    mov r8, 1
.L1579_1:
    mov qword ptr [rsi+24], r8
    mov rdi, 0
    mov qword ptr [rsi+8], rdi
    mov rax, 0
    ret
.globl zyl_warn_emit
zyl_warn_emit:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
.L1580_0:
    cmp rdi, 0
    jne .L1580_1
.L1580_5:
    lea rax, [rip+.L1581]
    mov rsi, rax
    jmp .L1580_2
.L1580_1:
    mov rsi, rdi
.L1580_2:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    lea rax, [rip+zyl_rtg_warn]
    mov r13, rax
    mov rax, qword ptr [r13+24]
    cmp rax, 0
    jne .L1580_3
    mov rdi, 2
    mov rsi, rbx
    mov rdx, r12
    call zyl_rt_sys_1
    mov rdi, 2
    lea rax, [rip+.L1582]
    mov rsi, rax
    mov r8, 1
    mov rdx, r8
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1580_3:
    mov r14, qword ptr [r13+8]
    lea rsi, [r14+r12]
    add rsi, 2
    mov rdi, r13
    call zy_local_x2Fmain_0__panic__pn_x2Dwarn_x2Dfit
    cmp rax, 0
    je .L1580_4
    mov r15, qword ptr [r13+0]
    lea rdi, [r15+r14]
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r14+r12]
    add rsi, r15
    mov rdi, 10
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    lea rsi, [r12+1]
    add rsi, r14
    add rsi, r15
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    lea rsi, [r12+1]
    add rsi, r14
    mov qword ptr [r13+8], rsi
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1580_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dwarn_x2Dfit:
    push rbx
    push r12
    mov rbx, rdi
.L1583_0:
    mov rdi, qword ptr [rbx+16]
    cmp rsi, rdi
    jg .L1583_1
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1583_1:
    mov r8, 1024
    cmp rdi, 0
    je .L1583_2
    mov r8, rdi
.L1583_2:
    mov rdi, r8
    call zy_local_x2Fmain_0__panic__pn_x2Ddouble
    mov r12, rax
    mov rdi, qword ptr [rbx+0]
    mov rsi, r12
    call zyl_rt_realloc
    mov rsi, rax
    cmp rsi, 0
    jne .L1583_3
    mov rax, 0
    pop r12
    pop rbx
    ret
.L1583_3:
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+16], r12
    mov rax, 1
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__panic__pn_x2Ddouble:
.L1584_0:
    cmp rsi, rdi
    jle .L1584_1
.L1584_2:
    shl rdi, 1
    cmp rsi, rdi
    jle .L1584_1
    jmp .L1584_2
.L1584_1:
    mov rax, rdi
    ret
.globl zyl_warn_take
zyl_warn_take:
    push rbx
    push r12
    push r13
.L1585_0:
    lea rax, [rip+zyl_rtg_warn]
    mov rbx, rax
    mov r12, qword ptr [rbx+8]
    lea rdi, [r12+1]
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L1585_1
    lea rax, [rip+.L1586]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
.L1585_1:
    cmp r12, 0
    jle .L1585_2
    mov rsi, qword ptr [rbx+0]
    mov rdi, r13
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    jmp .L1585_3
.L1585_2:
.L1585_3:
    lea rsi, [r13+r12]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
.globl zyl_json_quote
zyl_json_quote:
    push rbx
    push r12
    push r13
.L1587_0:
    cmp rdi, 0
    jne .L1587_1
.L1587_4:
    lea rax, [rip+.L1588]
    mov rsi, rax
    jmp .L1587_2
.L1587_1:
    mov rsi, rdi
.L1587_2:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    imul rdi, r12, 6
    add rdi, 3
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L1587_3
    lea rax, [rip+.L1589]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
.L1587_3:
    mov rsi, 34
    mov rcx, rsi
    mov byte ptr [r13+0], cl
    mov rsi, 0
    mov r8, 1
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__panic__pn_x2Dquote_x2Dloop
    mov rsi, rax
    lea rdi, [r13+rsi]
    mov r8, 34
    mov byte ptr [rdi+0], r8b
    add rsi, 1
    add rsi, r13
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__panic__pn_x2Dquote_x2Dloop:
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
    mov rsi, rdx
    mov r13, rcx
    mov qword ptr [rbp-48], r8
.L1590_0:
    cmp rsi, r12
    jl .L1590_1
.L1590_13:
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L1590_1:
    mov rdi, qword ptr [rbp-56]
    add rdi, rsi
    movzx edi, byte ptr [rdi+0]
    lea r14, [rsi+1]
    cmp rdi, 34
    je .L1590_4
    cmp rdi, 92
    jne .L1590_2
.L1590_4:
    mov r9, r13
    add r9, qword ptr [rbp-48]
    mov r10, 92
    mov byte ptr [r9+0], r10b
    mov r9, qword ptr [rbp-48]
    add r9, 1
    add r9, r13
    mov rcx, rdi
    mov byte ptr [r9+0], cl
    mov r9, qword ptr [rbp-48]
    add r9, 2
    jmp .L1590_3
.L1590_2:
    cmp rdi, 10
    jne .L1590_5
    mov r10, 110
    mov r11, r13
    add r11, qword ptr [rbp-48]
    mov r15, 92
    mov byte ptr [r11+0], r15b
    mov r11, qword ptr [rbp-48]
    add r11, 1
    add r11, r13
    mov byte ptr [r11+0], r10b
    mov r10, qword ptr [rbp-48]
    add r10, 2
    jmp .L1590_6
.L1590_5:
    cmp rdi, 9
    jne .L1590_7
    mov r11, 116
    mov r15, r13
    add r15, qword ptr [rbp-48]
    mov r8, 92
    mov byte ptr [r15+0], r8b
    mov r8, qword ptr [rbp-48]
    add r8, 1
    add r8, r13
    mov byte ptr [r8+0], r11b
    mov r8, qword ptr [rbp-48]
    add r8, 2
    jmp .L1590_8
.L1590_7:
    cmp rdi, 13
    jne .L1590_9
    mov r11, 114
    mov r15, r13
    add r15, qword ptr [rbp-48]
    mov rbx, 92
    mov byte ptr [r15+0], bl
    mov rbx, qword ptr [rbp-48]
    add rbx, 1
    add rbx, r13
    mov byte ptr [rbx+0], r11b
    mov r11, qword ptr [rbp-48]
    add r11, 2
    jmp .L1590_10
.L1590_9:
    cmp rdi, 32
    jge .L1590_11
    mov rsi, qword ptr [rbp-48]
    mov rdx, rdi
    mov rdi, r13
    call zy_local_x2Fmain_0__panic__pn_x2Desc_x2Du
    mov rbx, rax
    jmp .L1590_12
.L1590_11:
    mov r15, r13
    add r15, qword ptr [rbp-48]
    mov rcx, rdi
    mov byte ptr [r15+0], cl
    mov rbx, qword ptr [rbp-48]
    add rbx, 1
.L1590_12:
    mov r11, rbx
.L1590_10:
    mov r8, r11
.L1590_8:
    mov r10, r8
.L1590_6:
    mov r9, r10
.L1590_3:
    mov qword ptr [rbp-48], r9
    mov rsi, r14
    cmp rsi, r12
    jl .L1590_1
    jmp .L1590_13
zy_local_x2Fmain_0__panic__pn_x2Desc:
    mov r8, rdx
.L1591_0:
    lea r9, [rdi+rsi]
    mov r10, 92
    mov byte ptr [r9+0], r10b
    lea r9, [rsi+1]
    add rdi, r9
    mov byte ptr [rdi+0], r8b
    lea rax, [rsi+2]
    ret
zy_local_x2Fmain_0__panic__pn_x2Desc_x2Du:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1592_0:
    lea rdi, [rbx+r12]
    lea rax, [rip+.L1593]
    mov rsi, rax
    mov r8, 4
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r12+4]
    lea r14, [rbx+rsi]
    mov rdi, r13
    shr rdi, 4
    call zy_local_x2Fmain_0__panic__pn_x2Dhexd
    mov rsi, rax
    mov rcx, rsi
    mov byte ptr [r14+0], cl
    lea rsi, [r12+5]
    add rbx, rsi
    mov rdi, r13
    and rdi, 15
    call zy_local_x2Fmain_0__panic__pn_x2Dhexd
    mov rsi, rax
    mov rcx, rsi
    mov byte ptr [rbx+0], cl
    lea rax, [r12+6]
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__panic__pn_x2Dhexd:
.L1594_0:
    cmp rdi, 10
    jge .L1594_1
.L1594_2:
    lea rax, [rdi+48]
    ret
.L1594_1:
    lea rax, [rdi+87]
    ret
zy_local_x2Fmain_0__io__io_x2Dput:
.L1595_0:
    jmp zyl_out_puts
zy_local_x2Fmain_0__io__io_x2Dputs_x2Dor_x2Dnull:
.L1596_0:
    cmp rdi, 0
    jne .L1596_1
.L1596_2:
    lea rax, [rip+.L1597]
    mov rsi, rax
    mov rdi, rsi
    jmp zyl_out_puts
.L1596_1:
    jmp zyl_out_puts
zy_local_x2Fmain_0__io__io_x2Dput_x2Dint:
.L1598_0:
    jmp zyl_out_int
.globl zyl_itest_start
zyl_itest_start:
    push rbx
    mov rbx, rdi
.L1599_0:
    lea rax, [rip+.L1600]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, rbx
    call zy_local_x2Fmain_0__io__io_x2Dputs_x2Dor_x2Dnull
    lea rax, [rip+.L1601]
    mov rdi, rax
    call zyl_out_puts
    pop rbx
    jmp zyl_out_flush
.globl zyl_itest_outcome
zyl_itest_outcome:
.L1602_0:
    cmp rdi, 0
    jne .L1602_1
.L1602_3:
    lea rax, [rip+.L1603]
    mov rsi, rax
    jmp .L1602_2
.L1602_1:
    lea rax, [rip+.L1604]
    mov rsi, rax
.L1602_2:
    mov rdi, rsi
    jmp zyl_out_puts
.globl zyl_itest_fail
zyl_itest_fail:
    push rbx
.L1605_0:
    mov rbx, rdi
    lea rax, [rip+.L1606]
    mov rdi, rax
    call zyl_out_puts
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__io__io_x2Dline
    lea rax, [rip+.L1607]
    mov rdi, rax
    pop rbx
    jmp zyl_out_puts
zy_local_x2Fmain_0__io__io_x2Dline:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1608_0:
    lea rsi, [rbx+r12]
    movzx esi, byte ptr [rsi+0]
    cmp rsi, 0
    je .L1608_2
    cmp rsi, 10
    jne .L1608_1
.L1608_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L1608_1:
    lea rdi, [rbx+r12]
    mov rsi, 1
    call zyl_out_write
    add r12, 1
    jmp .L1608_0
.globl zyl_itest_summary
zyl_itest_summary:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1609_0:
    lea rax, [rip+.L1610]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, rbx
    call zyl_out_int
    lea rax, [rip+.L1611]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, r12
    call zyl_out_int
    lea rax, [rip+.L1612]
    mov rdi, rax
    call zyl_out_puts
    lea rdi, [rbx+r12]
    call zyl_out_int
    lea rax, [rip+.L1613]
    mov rdi, rax
    call zyl_out_puts
    cmp r12, 0
    jle .L1609_1
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1609_1:
    mov rax, 0
    pop r12
    pop rbx
    ret
.globl zyl_exit
zyl_exit:
    push rbx
    mov rbx, rdi
.L1614_0:
    call zyl_out_flush
    mov rdi, rbx
    pop rbx
    jmp zyl_rt_exit
.globl zyl_read_line
zyl_read_line:
    push rbx
    push r12
    push r13
.L1615_0:
    call zyl_out_flush
    mov rdi, 128
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rdi, rax
    cmp rdi, 0
    jne .L1615_1
    lea rax, [rip+.L1616]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
.L1615_1:
    mov rsi, 128
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__io__io_x2Dread_x2Dloop
    mov rsi, rax
    mov rbx, qword ptr [rsi+0]
    mov rsi, qword ptr [rsi+8]
    cmp rsi, 0
    jle .L1615_2
    lea rdi, [rsi-1]
    add rdi, rbx
    movzx eax, byte ptr [rdi+0]
    cmp rax, 13
    jne .L1615_2
    lea rdi, [rsi-1]
    jmp .L1615_3
.L1615_2:
    mov rdi, rsi
.L1615_3:
    mov r12, rdi
    lea rdi, [r12+1]
    call zyl_heap_alloc
    mov r13, rax
    cmp r13, 0
    je .L1615_4
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r13+r12]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
.L1615_4:
    mov rdi, rbx
    call zyl_rt_free
    cmp r13, 0
    jne .L1615_5
    lea rax, [rip+.L1617]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    ret
.L1615_5:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__io__io_x2Dread_x2Dloop:
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
.L1618_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_io_rl@tpoff]
    mov r14, rax
    mov rdi, 0
    lea rsi, [r14+16]
    mov r8, 1
    mov rdx, r8
    call zyl_rt_sys_0
    cmp rax, 1
    jne .L1618_1
    movzx eax, byte ptr [r14+16]
    cmp rax, 10
    je .L1618_1
    lea rax, [r13+1]
    cmp rax, r12
    jl .L1618_2
    lea rsi, [r12*2]
    mov rdi, rbx
    call zyl_rt_realloc
    mov rsi, rax
    cmp rsi, 0
    jne .L1618_3
    mov qword ptr [r14+0], rbx
    mov qword ptr [r14+8], r13
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1618_3:
    lea rdi, [rsi+r13]
    movzx r8d, byte ptr [r14+16]
    mov byte ptr [rdi+0], r8b
    mov rbx, rsi
    shl r12, 1
    add r13, 1
    jmp .L1618_0
.L1618_2:
    lea rsi, [rbx+r13]
    movzx edi, byte ptr [r14+16]
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    add r13, 1
    jmp .L1618_0
.L1618_1:
    mov qword ptr [r14+0], rbx
    mov qword ptr [r14+8], r13
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__io__io_x2Dread_x2Ddone:
    mov r8, rdx
.L1619_0:
    mov qword ptr [rdi+0], rsi
    mov qword ptr [rdi+8], r8
    mov rax, rdi
    ret
zy_local_x2Fmain_0__io__io_x2Dcells:
.L1620_0:
    lea rax, [rip+zyl_rtg_cells]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_cell_get
zyl_cell_get:
.L1621_0:
    cmp rdi, 0
    jl .L1621_1
.L1621_2:
    cmp rdi, 16
    jge .L1621_1
    lea rax, [rip+zyl_rtg_cells]
    mov rsi, rax
    shl rdi, 3
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    ret
.L1621_1:
    mov rax, 0
    ret
.globl zyl_cell_set
zyl_cell_set:
.L1622_0:
    cmp rdi, 0
    jl .L1622_1
.L1622_3:
    cmp rdi, 16
    jge .L1622_1
    lea rax, [rip+zyl_rtg_cells]
    mov r8, rax
    shl rdi, 3
    add r8, rdi
    mov qword ptr [r8+0], rsi
    jmp .L1622_2
.L1622_1:
.L1622_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__env__ev_x2Denvp_x2Dcell:
.L1623_0:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_rt_set_env
zyl_rt_set_env:
.L1624_0:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
.globl zyl_rt_envp
zyl_rt_envp:
.L1625_0:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_rt_getenv
zyl_rt_getenv:
.L1626_0:
    cmp rdi, 0
    je .L1626_2
.L1626_4:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 0
    jne .L1626_1
.L1626_2:
    mov rax, 0
    ret
.L1626_1:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L1626_3
    mov rax, 0
    ret
.L1626_3:
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__env__ev_x2Dscan
zy_local_x2Fmain_0__env__ev_x2Dscan:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1627_0:
    mov rdi, qword ptr [rbx+0]
    cmp rdi, 0
    jne .L1627_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L1627_1:
    mov rsi, r12
    call zy_local_x2Fmain_0__env__ev_x2Dmatch
    mov rsi, rax
    cmp rsi, 0
    jne .L1627_2
    add rbx, 8
    jmp .L1627_0
.L1627_2:
    mov rax, rsi
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__env__ev_x2Dmatch:
.L1628_0:
    movzx r8d, byte ptr [rsi+0]
    cmp r8, 0
    jne .L1628_1
    movzx eax, byte ptr [rdi+0]
    cmp rax, 61
    jne .L1628_2
    lea rax, [rdi+1]
    ret
.L1628_2:
    mov rax, 0
    ret
.L1628_1:
    movzx eax, byte ptr [rdi+0]
    cmp rax, r8
    jne .L1628_3
    add rdi, 1
    add rsi, 1
    jmp .L1628_0
.L1628_3:
    mov rax, 0
    ret
zy_local_x2Fmain_0__env__ev_x2Dmax:
.L1629_0:
    mov rax, 32
    ret
zy_local_x2Fmain_0__env__ev_x2Dreg:
.L1630_0:
    lea rax, [rip+zyl_rtg_rt_exit_reg]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__env__ev_x2Dlock:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1631_0:
    mov rsi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L1631_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1631_1:
    call zyl_rt_sys_24
    jmp .L1631_0
zy_local_x2Fmain_0__env__ev_x2Dunlock:
.L1632_0:
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    ret
.globl zyl_rt_atexit
zyl_rt_atexit:
    push rbx
    push r12
    mov rbx, rdi
.L1633_0:
    lea rax, [rip+zyl_rtg_rt_exit_reg]
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__env__ev_x2Dlock
    mov rsi, qword ptr [r12+8]
    cmp rsi, 32
    jl .L1633_1
    mov rdi, 0
    mov rdx, r12
    mov rcx, rdi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1633_1:
    lea rdi, [rsi+2]
    shl rdi, 3
    add rdi, r12
    mov qword ptr [rdi+0], rbx
    add rsi, 1
    mov qword ptr [r12+8], rsi
    mov rsi, 0
    mov rdx, r12
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 0
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__env__ev_x2Dpop:
    push rbx
.L1634_0:
    lea rax, [rip+zyl_rtg_rt_exit_reg]
    mov rbx, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__env__ev_x2Dlock
    mov rsi, qword ptr [rbx+8]
    cmp rsi, 0
    jne .L1634_1
    mov rdi, 0
    mov rdx, rbx
    mov rcx, rdi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 0
    pop rbx
    ret
.L1634_1:
    lea rdi, [rsi+1]
    shl rdi, 3
    add rdi, rbx
    mov rdi, qword ptr [rdi+0]
    sub rsi, 1
    mov qword ptr [rbx+8], rsi
    mov rsi, 0
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, rdi
    pop rbx
    ret
.globl zyl_rt_run_atexit
zyl_rt_run_atexit:
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1635_0:
    call zy_local_x2Fmain_0__env__ev_x2Dpop
    mov rdi, rax
    cmp rdi, 0
    jne .L1635_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1635_1:
    call zyl_rt_call0
    jmp .L1635_0
.globl zyl_rt_exit
zyl_rt_exit:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1636_0:
    call zyl_rt_run_atexit
    call zyl_term_flush
    mov rax, QWORD PTR [rip+exit@GOTPCREL]
    mov rdi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1636_1
    cmp rdi, 0
    jle .L1636_1
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call1
.L1636_1:
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__env__ev_x2Dexit_x2Dgroup
zy_local_x2Fmain_0__env__ev_x2Dexit_x2Dgroup:
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1637_0:
    mov rdi, rbx
    call zyl_rt_sys_231
    mov rdi, rbx
    call zyl_rt_sys_60
    jmp .L1637_0
zy_local_x2Fmain_0__crc__rt_x2Dsse42:
.L1638_0:
    lea rax, [rip+zyl_rtg_cpu_sse42]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    cmp rdi, 0
    jne .L1638_1
    mov r8, 1
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    mov eax, edx
    mov r11, rbx
    cpuid
    mov eax, ecx
    mov rbx, r11
    mov r8, rax
    and r8, 1048576
    cmp r8, 0
    jle .L1638_2
    mov r8, 2
    jmp .L1638_3
.L1638_2:
    mov r8, 1
.L1638_3:
    mov qword ptr [rsi+0], r8
    mov rax, r8
    cmp rax, 2
    sete al
    movzx rax, al
    ret
.L1638_1:
    mov rax, rdi
    cmp rax, 2
    sete al
    movzx rax, al
    ret
zy_local_x2Fmain_0__crc__crc_x2Dtab:
    push rbx
    push r12
.L1639_0:
    lea rax, [rip+zyl_rtg_crc32c_tab]
    mov rbx, rax
    lea rax, [rip+zyl_rtg_crc32c_tab_ok]
    mov r12, rax
    mov rax, qword ptr [r12+0]
    cmp rax, 1
    jne .L1639_1
    mov rax, rbx
    pop r12
    pop rbx
    ret
.L1639_1:
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__crc__crc_x2Dfill
    mov rsi, 1
    mov qword ptr [r12+0], rsi
    mov rax, rbx
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__crc__crc_x2Dfill:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L1640_0:
    cmp r12, 255
    jle .L1640_1
.L1640_3:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L1640_1:
    lea rsi, [r12*8]
    lea r13, [rbx+rsi]
    mov rsi, 8
    mov rdi, r12
    cmp rsi, 0
    je .L1640_2
    mov rdi, r12
    call zy_local_x2Fmain_0__crc__crc_x2Dbits
    mov rdi, rax
.L1640_2:
    mov qword ptr [r13+0], rdi
    add r12, 1
    cmp r12, 255
    jle .L1640_1
    jmp .L1640_3
zy_local_x2Fmain_0__crc__crc_x2Dbits:
.L1641_0:
    cmp rsi, 0
    jne .L1641_1
.L1641_4:
    mov rax, rdi
    ret
.p2align 4
.L1641_1:
    mov rax, rdi
    and rax, 1
    cmp rax, 1
    jne .L1641_2
    mov r8, rdi
    shr r8, 1
    mov r9, 2197175160
    xor r8, r9
    jmp .L1641_3
.L1641_2:
    mov r8, rdi
    shr r8, 1
.L1641_3:
    mov rdi, r8
    sub rsi, 1
    cmp rsi, 0
    jne .L1641_1
    jmp .L1641_4
zy_local_x2Fmain_0__crc__crc_x2Dbyte:
    mov r8, rdx
.L1642_0:
    xor r8, rsi
    and r8, 255
    shl r8, 3
    add rdi, r8
    mov rdi, qword ptr [rdi+0]
    shr rsi, 8
    xor rdi, rsi
    mov rax, rdi
    ret
zy_local_x2Fmain_0__crc__crc_x2Dsoft_x2Dbytes:
    mov r8, rdx
    mov r9, rcx
.L1643_0:
    cmp r9, 0
    jne .L1643_1
.L1643_2:
    mov rax, rsi
    ret
.p2align 4
.L1643_1:
    mov r10, r8
    and r10, 255
    xor r10, rsi
    and r10, 255
    shl r10, 3
    add r10, rdi
    mov r10, qword ptr [r10+0]
    mov r11, rsi
    shr r11, 8
    mov rsi, r10
    xor rsi, r11
    shr r8, 8
    sub r9, 1
    cmp r9, 0
    jne .L1643_1
    jmp .L1643_2
.globl zyl_crc32c_soft
zyl_crc32c_soft:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1644_0:
    call zy_local_x2Fmain_0__crc__crc_x2Dtab
    mov rdi, rax
    mov rsi, 4294967295
    and rsi, rbx
    mov r8, 8
    mov rdx, r12
    mov rcx, r8
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__crc__crc_x2Dsoft_x2Dbytes
.globl zyl_crc32c_u64
zyl_crc32c_u64:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1645_0:
    call zy_local_x2Fmain_0__crc__rt_x2Dsse42
    cmp rax, 0
    je .L1645_1
    mov rdx, rbx
    mov rcx, r12
    mov eax, edx
    crc32 rax, rcx
    pop r12
    pop rbx
    ret
.L1645_1:
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    jmp zyl_crc32c_soft
.globl zyl_crc32c_u8
zyl_crc32c_u8:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1646_0:
    call zy_local_x2Fmain_0__crc__rt_x2Dsse42
    cmp rax, 0
    je .L1646_1
    mov rdx, rbx
    mov rcx, r12
    mov eax, edx
    crc32 eax, cl
    pop r12
    pop rbx
    ret
.L1646_1:
    call zy_local_x2Fmain_0__crc__crc_x2Dtab
    mov rdi, rax
    mov rsi, 4294967295
    and rsi, rbx
    mov r8, r12
    and r8, 255
    mov rdx, r8
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__crc__crc_x2Dbyte
zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Dcmp_x7EInt_x2CInt_x2CInt_x2CInt_x2CInt_x2CInt:
    push rbx
    push r12
    mov r10, r8
    mov r8, rdx
    mov r11, r9
    mov r9, rcx
.L1647_0:
    cmp r8, r9
    jl .L1647_1
.L1647_6:
    cmp r10, r11
    jge .L1647_2
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1647_2:
    cmp r10, r11
    jle .L1647_3
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1647_3:
    mov rax, 0
    pop r12
    pop rbx
    ret
.p2align 4
.L1647_1:
    lea rbx, [r8*8]
    add rbx, rdi
    mov rbx, qword ptr [rbx+0]
    lea r12, [r8*8]
    add r12, rsi
    mov r12, qword ptr [r12+0]
    cmp rbx, r12
    jge .L1647_4
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1647_4:
    cmp rbx, r12
    jle .L1647_5
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1647_5:
    add r8, 1
    cmp r8, r9
    jl .L1647_1
    jmp .L1647_6
.section .rodata
.L12:
    .string "0123456789abcdef"
.L14:
    .string "zyl: "
.L15:
    .string ": invalid string pointer 0x"
.L16:
    .string ""
.L17:
    .string "\n"
.L38:
    .string "cstr-len"
.L40:
    .string "cstr-len"
.L42:
    .string "cstr-eq"
.L43:
    .string "cstr-eq"
.L46:
    .string "cstr-byte-at"
.L48:
    .string "cstr-byte-at"
.L51:
    .string "cstr-concat"
.L52:
    .string "cstr-concat"
.L57:
    .string "cstr-substr"
.L64:
    .string "view"
.L77:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L79:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L80:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L82:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L83:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L84:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L85:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L91:
    .string "cstr-sub"
.L98:
    .string "cstr-to-int"
.L102:
    .string "cstr-to-int-base"
.L106:
    .string "cstr-sanitize"
.L112:
    .string "cstr-decode"
.L115:
    .string "cstr-count-newlines"
.L118:
    .string "cstr-last-newline"
.L133:
    .string "/proc/meminfo"
.L134:
    .string "MemAvailable:"
.L135:
    .string "MemTotal:"
.L138:
    .string "ZYL_MAX_MEMORY"
.L201:
    .string "E_INDEX_OUT_OF_BOUNDS: vector index "
.L202:
    .string " outside length "
.L206:
    .string "E_INDEX_OUT_OF_BOUNDS: pop from an empty vector"
.L232:
    .string "contract violated"
.L233:
    .string "warning: "
.L234:
    .string "\n"
.L243:
    .string "<input>"
.L244:
    .string ""
.L245:
    .string ""
.L248:
    .string "<input>"
.L256:
    .string ""
.L257:
    .string "..."
.L258:
    .string "..."
.L260:
    .string ""
.L263:
    .string ""
.L343:
    .string "0123456789abcdef"
.L345:
    .string "0123456789abcdef"
.L352:
    .string "0123456789ABCDEF"
.L354:
    .string ""
.L356:
    .string ""
.L358:
    .string ""
.L359:
    .string "0123456789ABCDEF"
.L374:
    .string "0"
.L377:
    .string "0"
.L383:
    .string "PANIC: error[E_OUT_OF_MEMORY]: "
.L384:
    .string "\n  = requested "
.L385:
    .string " bytes; "
.L386:
    .string " bytes already allocated; budget "
.L387:
    .string " bytes\n  = help: set ZYL_MAX_MEMORY to a byte count to raise the budget, or ZYL_MAX_MEMORY=0 to remove it\n"
.L392:
    .string "memory budget exhausted"
.L393:
    .string "out of memory allocating an arena block header"
.L394:
    .string "out of memory allocating an arena block"
.L414:
    .string "\n"
.L416:
    .string "zyl_heap_alloc: size too large size="
.L417:
    .string "zyl_heap_alloc: FAILED size="
.L429:
    .string "memory budget exhausted"
.L430:
    .string "mmap failed for a region block"
.L438:
    .string "E_REGION_EXHAUSTED: "
.L439:
    .string "fixed"
.L440:
    .string "arena"
.L441:
    .string " region of "
.L442:
    .string " bytes is full"
.L446:
    .string "zyl_ralloc: size too large size="
.L462:
    .string "zyl: ffi-unpin: pointer not from ffi-pin/Pin arena\n"
.L465:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L466:
    .string ": index "
.L467:
    .string " outside a word array of length "
.L470:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L471:
    .string ": not a word array"
.L473:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L474:
    .string ": not a word array"
.L476:
    .string "E_OUT_OF_MEMORY: word array view"
.L478:
    .string "E_OUT_OF_MEMORY: word array"
.L481:
    .string "E_OUT_OF_MEMORY: word array"
.L484:
    .string "w-len"
.L485:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L486:
    .string ": not a word array"
.L488:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L489:
    .string ": not a word array"
.L491:
    .string "w-get"
.L493:
    .string "w-set"
.L495:
    .string "w-view"
.L496:
    .string "w-view"
.L499:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L500:
    .string ": not an array"
.L502:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L503:
    .string ": not an array"
.L505:
    .string "E_OUT_OF_MEMORY: array"
.L507:
    .string "array-cap"
.L508:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L509:
    .string ": not an array"
.L511:
    .string "array-filled"
.L512:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L513:
    .string ": not an array"
.L515:
    .string "E_OUT_OF_MEMORY: array"
.L518:
    .string "E_OUT_OF_MEMORY: array"
.L520:
    .string "array-get"
.L521:
    .string "array-get"
.L522:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L523:
    .string ": not an array"
.L526:
    .string "array-copy"
.L527:
    .string "array-copy"
.L528:
    .string "array-copy"
.L529:
    .string "array-copy"
.L531:
    .string "array-set"
.L532:
    .string "array-set"
.L537:
    .string "attribute table"
.L546:
    .string "ref cell"
.L551:
    .string ""
.L557:
    .string "0123456789abcdef"
.L559:
    .string "zyl: str-append: invalid string pointer 0x"
.L560:
    .string ""
.L561:
    .string "\n"
.L563:
    .string "codegen buffer limit exceeded"
.L564:
    .string "E_INDEX_OUT_OF_BOUNDS: string buffer full"
.L615:
    .quad 0
.L616:
    .quad 0
.L621:
    .quad -4332466134535158144
.L622:
    .quad 4890905902319617664
.L635:
    .string "eef453d6923bd65a113faa2906a13b3f9558b4661b6565f84ac7ca59a424c507baaee17fa23ebf765d79bcf00d2df649e95a99df8ace6f53f4d82c2c107973dc91d8a02bb6c1059479071b9b8a4be869b64ec836a47146f99748e2826cdee284e3e27a444d8d98b7fd1b1b2308169b258e6d8c6ab0787f72fe30f0f5e50e20f7b208ef855c969f4fbdbd2d335e51a935de8b2b66b3bc4723ad2c788035e613828b16fb203055ac764c3bcb5021afcc31addcb9e83c6b1793df4abe242a1bbf3dd953e8624b85dd78d71d6dad34a2af0d87d4713d6f33aa6b8672648c40e5ad68a9c98d8ccb009506680efdaf511f18c2d43bf0effdc0ba480212bd1b2566def284a57695fe98746d014bb630f7604b57a5ced43b7e3e9188419ea3bd35385e2dcf42894a5dce35ea52064cac828675b9818995ce7aa0e1b27343efebd1940993a1ebfb4219491a1f1014ebe6c5f90bf8ca66fa129f9b60a6d41a26e077774ef6fd00b897478238d08920b098955522b49e20735e8cb1638255b46e5f5d5535b0c5a890362fddbc62eb2189f734aa831df712b443bbd52b7ba5e9ec7501d523e49a6bb0aa55653b2d47b233c92125366ec1069cd4eabe89f8999ec0bb696e840af148440a256e2c76c00670ea43ca250d96cd2a865764dbca380406926a5e5728bc807527ed3e12bcc605083704f5ecf2eba09271e88d976bf7864a44c633682e93445b8731587ea37ab3ee6afbe0211db8157268fdae9e4c5960ea05bad82964e61acf033d1a45df6fb92487298e33bd8fd0c16206306baba5d3b6d479f8e056b3c4f1ba87bc86968f48a4899877186ce0b62e2929aba83c331acdabfe94de878c71dcd9ba0b49259ff0c08b7f1d0b14af8e5410288e1b6f07ecf0ae5ee44dd9db71e91432b1a24ac9e82cd9f69d6150892731ac9faf056ebe311c083a225cd2ab70fe17c79ac6ca6dbd630a48aaf406d64d3d9db981787d092cbbccdad5b10885f0468293f0eb4e25bbf56008c58ea5a76c582338ed2621af2af2b80af6f24ed1476e2c07286faa1af5af660db4aee182cca4db847945ca50d98d9fc890ed4da37fce126597973ce50ff107bab528a0cc5fc196fefd7d0c1e53ed49a96272c8ff77b1fcbebcdc4f25e8e89c13bb0f7a9faacf3df73609b177b191618c54e9acc795830d75038c1dd59df5b9ef6a2417f97ae3d0d2446f254b0573286b44ad1d9becce62836ac5774ee367f9430aec32c2e801fb244576d5229c41f793cda73ff3a20279ed56d48a6b43527578c1110f9845418c345644d6830a13896b78aaa9be5691ef416bd60c23cc986bc656d553edec366b11c6cb8f2cbfbe86b7ec8aa894b3a202eb1c3f397bf7d71432f3d6a9b9e08a83a5e34f07daf5ccd93fb0cc53e858ad248f5c22c9d1b3400f8f9cff6891376c36d99995be23100809b9c21fa1b58547448ffffb2dabd40a0c2832a78ae2e69915b3fff9f916c90c8f323f516c8dd01fad907ffc3bae3da7d97f6792e3b1442798f49ffb4a99cd11cfdf41779cdd95317f31c7fa1d40405643d711d5838a7d3eef7f1cfc52482835ea666b2572ad1c8eab5ee43b66da3243650005eecfd863b256369d4a4090bed43e40076a82873e4f75e2224e685a7744a6e804a291a90de3535aaae202711515d0a205cb36d3515c2831559a830d5a5b44ca873e038412d9991ed58091e858790afe9486c2a5178fff668ae0b6626e974dbe39a872ce5d73ff402d98e3fb0a3d212dc8128f80fa687f881c7f8e7ce66634bc9d0b99a139029f6a239f721c1fffc1ebc44e80c987434744ac874ea327ffb266b56220fbe9141915d7a9224bf1ff9f0062baa89d71ac8fada6c9b56f773fc3603db4a9c4ce17b399107c22cb550fb4384d21d3f6019da07f549b2b7e2a53a146606a4899c102844f94e0fb2eda7444cbfc426dc0314325637a1939fa911155fefb5308f03d93eebc589f88793555ab7eba27ca96267c7535b763b54bc1558b2f3458debbb01b9283253ca29eb1aaedfb016f16ea9c227723ee8bcb465e15a979c1cadc92a1958a7675175f0bfacd89ec191ec9b749faed14125d36cef980ec671f667be51c79a85916f48482b7e12780e7401a8f31cc0937ae58d2d1b2ecb8b0908810b2fe3f0b8599ef07861fa7e6dcb4aa15dfbdcece67006ac967a791e093e1d49a8bd6a141006042bde0c8bb2c5c6d24e0aecc49914078536d58fae9f773886e18da7f5bf590966848af39a475506a899e888f99797a5e012d6d8406c952429603aab37fd7d8f58178c8e5087ba6d33b83d5605fcdcf32e1d6fb1e4a9a90880a64855c3be0a17fcd265cf2eea09a55067fa6b34ad8c9dfc06ff42faa48c0ea481ed0601d8efc57b08bf13b94daf124da26823c12795db6ce5776c53d08d6b70858a2cb1717b52481ed54768c4b0c64ca6ecb7ddcdda26da268a9942f5dcf7dfd09fe5d54150b090b02d3f93b35435d7c4c9efa548d26e5a6e1c47bc5014a1a6dafc6b8e9b0709f109a359ab6419ca1091bf867241c8cc6d4c0c30163d203c94b629b407691d7fc44f879e0de63425dcf1dc21094364dfb5636985915fc12f542e4f294b943e17a2bc43e6f5b7b17b2939d979cf3ca6cec5b5aa705992ceecf9c42bd8430bd0827723150c6ff782a838353ece53cec4a314ebda4f8bf5635246428940f4613ae5ed136871b7795e136be99b913179899f6858428e2557b59846e3fe757dd7ec07426e5331aeada2fe589cf9096ea6f3848984f3ff0d2c85def7621b4bca50b065abe630fed077a756b53a9e1ebce4dc7f16dfbd3e8495912c628948d3360f09cf6e4bd64712dd7abbbd95cb080392cc4349decbd8d794d96aacfb3dca04777f541c567ecf0d7a0fc5583a089e42caaf9491b60f41686c49db57244ac5d37d5b79b6239311c2875c522ced5d77485cb25823ac77d633293366b828b86a8d39ef77164bcae5dff9c02033197a8530886b54dbdebd9f57f830283fdfcd267caa862a12d66d072df63c324fd7b8380dea93da4bc604247cb9e59f71e6da46116538d0deb7852d9be85f074e608cd795be87051665667902e276c921f8b806bd9714632dff600ba1cd8a3db53b6a086cfcd97bf97f380e8a40eccd228a4c8a883c0fdaf7df06122cd128006b2cdfad2a4b13d1b5d6c796b805720085f819cc3a6eec6311a63cbe3303674053bb0c3f490aa77bd60fcbedbfc4411068a9cf4f1b4d515acb93bee92fb5515482d44991711052d8bf3c5751bdd152d4d1c4abf5cd54678eef0b6d262d45a78a0635def340a98172aace486fb897116c87c349580869f0e7aac0ed45d35e6ae3d4da0bae0a846d21957128974836059cca109e998d258869facd72bd1a438703fc94b91ff83775423cc067b6306a34627ddcfb67f6455292cbf081a3bc84c17b1d542e41f3d6a7377eeca20caba5f1d9e4a938e938662882af53e547eb47b7282ee9cb23867fb2a35b28de99e619a4f23aa43dec681f9f4c31f316405fa00e2ec94d48b3c113c38f9f37ede83bc408dd3dd04ae0b158b4738705e9624ab50b148d445d98ddaee19068c763badd624dd9b095787f8a8d4cfa417c9e54ca5d70a80e5d6a9f6d30a038d1dbc5e9fcf4ccd211f4cd47487cc8470652b7647c3200069671f84c8d4dfd2c63f3b29ecd9f40041e073a5fb0a17c777cf09f468107100525890cf79cc9db955c2cc7182148d4066eeb481ac1fe293d599bfc6f14cd848405530a21727db38cb002fb8ada00e5a506a7cca9cf1d206fdc03ba6d90811f0e4851cfd442e4688bd304a908f4a166d1da6639e4a9cec15763e2e9a598e4e043287fec5dd44271ad3cdba40eff1e1853f29fdf7549530e188c128d12bee59e68ef47c9a94dd3e8cf578b982bb74f8301958cec13a148e3032d6e7e36a52363c1faf01f18899b1bc3f8ca1dc44e6c3cb279ac196f5600f15a7b7e529ab103a5ef8c0b9bcb2b812db11a5de7415d448f6b6f0e7ebdf661791d60f56111b495b3464ad21936b9fcebb25c995cab10dd900beec34b84687c269ef3bfb3d5d514f40eea742e65829b3046b0afa0cb4a5a3112a51128ff71a0fe2c2e6dc47f0e785eaba72abb3f4e093db73a09359ed216765690f56e0f218b8d25088b8306869c13ec3532c8c974f73837255731e414218c73a13fbafbd2350644eeacfe5d1929ef90898fadbac6c247d62a583df45f746b74abf39894bc396ce5da7726b8bba8c328eb783ab9eb47c81f5114f066ea92f3f326564d686619ba27255a2c80a537b0efefebd8613fd0145877585bd06742ce95f5f36a798fc4196e952e72c48113823b73704d17f3b51fca3a7a0f75a15862ca504c582ef85133de648c49a984d73dbe722fba3ab66580d5fdaf5c13e60d0d2e0ebbacc963fee10b7d1b3318df905079926a8ffbbcfe994e5c61ffdf17746497f70529fd561f1fd0f9bd3feb6ea8bedefa633c7caba6e7c5382c8fe64a52ee96b8fc0f9bd690a1b68637b3dfdce7aa3c673b09c1661a651213e2d06bea10ca65c084ec31bfa0fe5698db8486e494fcff30a62f3e2f893dec3f1265a89dba3c3efccfa986ddb5c6b3a76b7f89629465a75e01cbe89523386091465f6bbb397f1135823ee2ba6c0678b597f746aa07ded582e2c94db483840b717efa8c2a44eb4571cdcba121a4650e4ddeb92f34d62616ce413e896a0d7e51e156677b020baf9c81d17915e2486ef32cd600ace1474dc1d122eb5b5ada8aaff80b80d819992132456bae3231912d5bf60e610e1fff697ed6c698df5efabc5979c8fca8d3ffa1ef463c1b1736b96b6fd83b3bd308ff8a6b17cb2ddd0467c64bce4a0ac7cb3f6d05ddbde8aa22c0dbef60ee46bcdf07a423aa96bad4ab7112eb3929d86c16c98d2c953c6d89d64d57a607744e871c7bf077ba8b787625f056c7c4a8b11471cd764ad4972a93af6c6c79b5d2dd598e40d3dd89bcfd389b478798234794aff1d108d4ec2c3843610cb4bf160cbcedf722a585139baa54394fe1eedb8fec2974eb4ee658828ce947a3da6a9273e733d226229feea32811ccc668829b8870806357d5a3f525fa163ff802a3426a8ca07c2dcb0cf26f7c9bcff6034c13052fc89b393dd02f0b5fc2c3f3841f17c67bbac2078d443ace29d9ba7832936edc0d54b944b84aa4c0dc5029163f384a9310a9e795e65d4df11f64335bcf065d37d4d4617b5ff4a16d599ea0196163fa42e504bced1bf8e4e45c06481fb9bcf8d39e45ec2862f71e1d6f07da27a82c370885d767327bb4e5a4c964e858c91ba26553a6a07f8d510f86fbbe226efb628afea890489f70a55368beadab0aba3b2dbe52b45ac74ccea842e92c8ae6b464fc96f3b0b8bc90012929db77ada0617e3bbcb09ce6ebb40173744e55990879ddcaabdcc420a6a101d05158f57fa54c2a9eab69fa946824a12232db32df8e9f354656447939822dc96abf9dff9772470297ebd59787e2b93bc56f78bfbea76c619ef3657eb4edb3c55b65aaefae51477a06b03ede622920b6b23f1dab99e59958885c4e95fab368e45eced88b402f7fd75539b11dbcb0218ebb414aae103b5fcd2a881d652bdc29f26a119d59944a37c0752a24be76d3346f0495f857fcae62d8493a56f70a4400c562ddba6dfbd9fb8e5b88ecb4ccd500f6bb952d097ad07a71f26b27e2000a41346a7a7825ecc24c873782f8ed400668c0c28c8a2f67f2dfa90563b728900802f0f32facbb41ef979346bca4f2b40a03ad2ffb9fea126b7d78186bce2f610c84987bfa89f24b832e6b0f4360dd9ca7d2df4d7c9c6ede63fa05d314391503d1c79720dbbf8a95fcf88747d9475a44c6397ce912a9b69dbe1b548ce7cc986afbe3ee11abac24452da229b021bfbe85badce996168f2d56790ab41c2a2fae27299423fb9c397c560ba6b0919a5dccd879fc967d41abdb6b8e905cb600f5400e987bbc1c920ed246723473e3813290123e9aab23b689436c0760c86e30bf9a0b6720aaf6521b94470938fa89bcef808e40e8d5b3e69e7958cb87392c2c2b60b1d1230b20e0490bd77f3483bb9b9b1c6f22b5e6f48c2b4ecd5f01a4aa8281e38aeb6360b1af3e2280b6c20dd523225c6da63c38de1b08d590723948a535f579c487e5a38ad0eb0af48ec79ace8372d835a9df0c6d851dcdb1b2798182244f8e431456cf88e658a08f0f8bf0f156b1b8e9ecb641b58ffac8b2d36eed2dac5e272467e3d222f3fd7adf884aa8791775b0ed81dcc6abb0f86ccbb52ea94baea98e947129fc2b4e9a87fea27a539e9a53f2398d747b36224d29fe4b18e88640e8eec7f0d19a03aad83a3eeeef9153e891953cf68300424aca48ceaaab75a8e2b5fa8c3423c052dd7cdb02555653131b63792f412cb06794d808e17555f3ebf11e2bbd88bbee40bd0a0b19d2ab70e6ed65b6aceaeae9d0ec4c8de047564d20a8bf245825a5a445275fb158592be068d2eeed6e2f0f0d567129ced737bb6c4183d55464dd69685606bc428d05aa4751e4caa97e14c3c26b886f53304714d9265dfd53dd99f4b3066a8993fe2c6d07b7fabe546a8038efe4029bf8fdb78849a5f96de98520472bdd033ef73d256a5c0f77c963e66858f6d444095a8637627989aaddde7001379a44aa8bb127c53b17ec1595560c018580d5d52e9d71b689dde71afaab8f01e6e10b4a69226712162ab070dcab3961304ca70e8b6b00d69bb55c8d13d607b97c5fd0d22e45c10c42a2b3b058cb89a7db77c506a8eb98a7a9a5b04e377f3608e92adb242b267ed1940f1c61c55f038b237591ed3df01e85f912e37a36b6c46dec52f66888b61313bbabce2c62323ac4b3b3da015ae397d8aa96c1b77abec975e0a0d081ad9c7dced53c7225596e7bd358c904a21881cea14545c75757e50d64177da2e54aa242499697392d2dde50bd1d5d0b9e9d4ad2dbfc3d07787955e4ec64b44e86484ec3c97da624ab4bd5af13bef0b113ea6274bbdd0fadd61ecb1ad8aeacdd58ecfb11ead453994ba67de18eda5814af281ceb32c4b43fcf480eacf948770ced7a2425ff75e14fc31a1258379a94d028dcad2f7f5359a3b3e096ee45813a04330fd87b5f28300ca0d8bca9d6e188853fc9e74d1b791e07e48775ea264cf55347ec612062576589dda95364afe032a819ef79687aed3eec5513a83ddbd83f522059abe14cd44753b52c4926a9672793543c16d9a0095928a2775b7053c0f178294f1c90080baf72cb15324c68b12dd6339971da05074da7beed3f6fc16ebca5e04bce5086492111aea88f4bb1ca6bcf585ec1e4a7db69561a52b31e9e3d06c32e69392ee8e921d5d073aff322e62439fd0b877aa3236a4b44909befeb9fad487c3e69594bec44de15b4c2ebe687989a9b4901d7cf73ab0acd90f9d37014bf60a11b424dc35095cd80f538484c19ef38c95e12e13424bb40e132865a5f206b06fba8cbccc096f5088cbf93f87b7442e45d4afebff0bcb24aafef78f69a51539d749dbe6fecebdedd5beb573440e5a884d1c89705f4136b4a59731680a88f8953031abcc77118461cefcfdc20d2b36ba7c3ed6bf94d5e57a42bc3d32907604691b4d8637bd05af6c69b5a63f9a49c2c1b110a7c5ac471b4784230fcf80dc33721d54d1b71758e219652bd3c36113404ea4a983126e978d4fdf3b645a1cac083126eaa3d70a3d70a3d70a3d70a3d70a3d70a4cccccccccccccccccccccccccccccccd80000000000000000000000000000000a0000000000000000000000000000000c8000000000000000000000000000000fa0000000000000000000000000000009c400000000000000000000000000000c3500000000000000000000000000000f424000000000000000000000000000098968000000000000000000000000000bebc2000000000000000000000000000ee6b28000000000000000000000000009502f900000000000000000000000000ba43b740000000000000000000000000e8d4a5100000000000000000000000009184e72a000000000000000000000000b5e620f4800000000000000000000000e35fa931a000000000000000000000008e1bc9bf040000000000000000000000b1a2bc2ec50000000000000000000000de0b6b3a7640000000000000000000008ac7230489e800000000000000000000ad78ebc5ac6200000000000000000000d8d726b7177a80000000000000000000878678326eac90000000000000000000a968163f0a57b4000000000000000000d3c21bcecceda100000000000000000084595161401484a00000000000000000a56fa5b99019a5c80000000000000000cecb8f27f4200f3a0000000000000000813f3978f89409844000000000000000a18f07d736b90be55000000000000000c9f2c9cd04674edea400000000000000fc6f7c40458122964d000000000000009dc5ada82b70b59df020000000000000c5371912364ce3056c28000000000000f684df56c3e01bc6c7320000000000009a130b963a6c115c3c7f400000000000c097ce7bc90715b34b9f100000000000f0bdc21abb48db201e86d4000000000096769950b50d88f41314448000000000bc143fa4e250eb3117d955a000000000eb194f8e1ae525fd5dcfab080000000092efd1b8d0cf37be5aa1cae500000000b7abc627050305adf14a3d9e40000000e596b7b0c643c7196d9ccd05d00000008f7e32ce7bea5c6fe4820023a2000000b35dbf821ae4f38bdda2802c8a800000e0352f62a19e306ed50b2037ad2000008c213d9da502de454526f422cc340000af298d050e4395d69670b12b7f410000daf3f04651d47b4c3c0cdd765f11400088d8762bf324cd0fa5880a69fb6ac800ab0e93b6efee00538eea0d047a457a00d5d238a4abe9806872a4904598d6d88085a36366eb71f04147a6da2b7f864750a70c3c40a64e6c51999090b65f67d924d0cf4b50cfe20765fff4b4e3f741cf6d82818f1281ed449fbff8f10e7a8921a4a321f2d7226895c7aff72d52192b6a0dcbea6f8ceb02bb399bf4f8a69f764490fee50b7025c36a0802f236d04753d5b49f4f2726179a224501d762422c946590c722f0ef9d80aad6424d3ad2b7b97ef5f8ebad2b84e0d58bd2e0898765a7deb29b934c3b330c857763cc55f49f88eb2fc2781f49ffcfa6d53cbf6b71c76b25fbf316271c7fc3908a8bef464e3945ef7a97edd871cfda3a5697758bf0e3cbb5acbde94e8e43d0c8ec3d52eeed1cbea317ed63a231d4c4fb274ca7aaa863ee4bdd945e455f24fb1cf88fe8caa93e74ef6ab975d6b6ee39e436b3e2fd538e122b44e7d34c64a9c85d4460dbbca87196b61690e40fbeea1d3a4abc8955e946fe31cdb51d13aea4a488dd6babab6398bdbe41e264589a4dcdab14c696963c7eed2dd18d7eb76070a08aecfc1e1de5cf543ca2b0de65388cc8ada83b25a55f43294bcbdd15fe86affad91249ef0eb713f39ebe8a2dbf142dfcc7ab6e3569326c784337acb92ed9397bf99649c2c37f07965404d7e77a8f87daf7fbdc33745ec97be90686f0ac99b4e8dafd69a028bb3ded71a3a8acd7c0222311bcc40832ea0d68ce0cd2d80db02aabd62bf50a3fa490c3019083c7088e1aab65db792667c6da79e0faa4b8cab1a1563f52577001b891185938cde6fd5e09abcf26ed4c0226b55e6f8680b05e5ac60b6178544f8158315b05b4a0dc75f1778e39d6696361ae3db1c721c913936dd571c84c03bc3a19cd1e38e9fb5878494ace3a5f04ab48a04065c7239d174b2dcec0e47b62eb0d64283f9c76c45d1df942711d9a3ba5d0bd324f8394f5746577930d6500ca8f44ec7ee364799968bf6abbe85f207e998b13cf4e1ecbbfc2ef456ae276e89e3fedd8c321a67eefb3ab16c59b14a2c5cfe94ef3ea101e95d04aee3b80ece5bba1f1d158724a12bb445da9ca61281f2a8a6e45ae8edc97ea1575143cf97226f52d09d71a3293bd924d692ca61be758593c2626705f9c56b6e0c377cfa2e12e6f8b2fb00c77836ce498f455c38b997a0b6dfb9c0f9564478edf98b59a373fec4724bd4189bd5eacb2977ee300c50fe758edec91ec2cb657df3d5e9bc0f653e12f2967b66737e3ed8b865b215899f46cbd79e0d20082ee74ae67f1e9aec07187ecd8590680a3aa11da01ee641a708de9e80e6f4820cc9495884134fe908658b23109058d147fdcddaa51823e34a7eedebd4b46f0599fd415d4e5e2cdc1d1ea966c9e18ac7007c91a850fadc09923329e03e2cf6bc604ddb0a6539930bf6bff4584db8346b786151ccfe87f7cef46ff16e612641865679a6381f14fae158c5f6e4fcb7e8f3f60c07ea26da3999aef7749e3be5e330f38f09dcb090c8001ab551c5cadf5bfd3072cc5fdcb4fa002162a6373d9732fc7c8f7f69e9f11c4014dda7e2867e7fddcdd9afac646d63501a1511db281e1fd541501b8f7d88bc24209a5651f225a7ca91a42269ae757596946075f3375788de9b06958c1a12d2fc39789370052d6b1641c83aef209787bb47d6b84c0678c5dbd23a49a9745eb4d50ce6332f840b7ba963646e0bd176620a501fbffb650e5a93bc3d898ec5d3fa8ce427affa3e51f138ab4cebe93ba47c980e98cdfc66f336c36b10137b8a8d9bbe123f017b80b0047445d4184e6d3102ad96cec1da60dc059157491e59043ea1ac7e4139287c89837ad68db2fb454e4a179dd187729babe4598c311fbe16a1dc9d8545e94f4296dd6fef3d67a8ce2529e2734bb1d1899e4a65f58660cb01ae745b101e9e45ec05dcff72e7f8fdc21a1171d42645d76707543f4fa1f73899504ae72497eba6a06494a791c53a8abfa45da0edbde690487db9d17636892d6f8d7509292d60345a9d2845d3c42b6865b86925b9bc5c20b8a2392ba45a9b2a7f26836f282b7328e6cac7768d7141ed1ef0244af2364ff3207d795430cd9268335616aed761f1f7f44e6bd49e807b8a402b9c5a8d3a6e75f16206c9c6209a6cd036837130890a136dba887c37a8c0f802221226be55a64c2494954da2c9789a02aa96b06deb0fdf2db9baa10b7bd6cc83553c5c8965d3d6f92829494e5acc7fa42a8b73abbf48ccb772339ba1f17f99c69a97284b578d7ff2a760414536efbc38413cf25e2d70dfef5138519684abaf46518c2ef5b8cd17eb258665fc25d6998bf2f79d5993802ef2f773ffbd97a61beeefb584aff8603aafb550ffacfd8faeeaaba2e5dbf678495ba2a53f983cf38952ab45cfa97a0b2dd945a747bf26183ba756174393d88df94f971119aeef9e4e912b9d1478ceb177a37cd5601aab85d91abb422ccb812eeac62e055c10ab33ab616a12b7fe617aa577b986b314d6009e39c49765fdf9d94ed5a7e85fda0b80b8e41ade9fbebc27d14588f13be847307b1d219647ae6b31c596eb2d8ae258fc8de469fbd99a05fe36fca5f8ed9aef3bb8aec23d680043bee25de7bb9480d5854ada72ccc20054ae9af561aa79a10ae6ad910f7ff28069da41b2ba1518094da0487aa9aff7904228690fb44d2f05d0842a99541bf57452b28353a1607ac744a53d3fa922f2d1675f242889b8997915ce8847c9b5d7c2e09b769956135febada11a59bc234db398c2543fab9837e699095cf02b2c21207ef2e94f967e45e03f4bb8161afb94b44f57d1d1be0eebac278f5a1ba1ba79e1632dc6462d92a69731732ca28a291859bbf937d7b8f7503cfdcfefcb2cb35e702af785cda735244c3d43e9defbf01b061adab3a0888136afa64a7c56baec21c7a1916088aaa1845b8fdd0f6c69a72a3989f5b8aad549e57273d459a3c2087a63f639936ac54e2f678864bc0cb28a98fcf3c7f84576a1bb416a7ddf0fdf2d3f3c30b9f656d44a2a11c51d5969eb7c47859e7439f644ae5a4b1b325bc4665b596706114873d5d9f0dde1feeeb57ff22fc0c7959a90cb506d155a7ea9316ff75dd87cbd809a7f12442d588f2b7dcbf5354e9bece0c11ed6d538aeb2fe5d3ef282a242e818f1668c8a86da5fa8fa475791a569d10f96e017d694487bcb38d92d760ec445537c981dcc395a9ace070f78d3927556a85bbe253f47b14178c469ab843b8956293956d7478ccec8eaf58416654a6babb387ac8d1970027b2db2e51bfe9d0696a06997b05fcc0319e88fcf317f22241e2441fece3bdf81f03ab3c2fddeeaad25ad527e81cad7626c3d60b3bd56a5586f18a71e223d8d3b07485c7056562757456f6872d5667844e49a738c6bebb12d16cb428f8ac016561dbd106f86e69d785c7e13336d701beba5282a45b450226b39cecc0024661173473a34d721642b0608427f002d7f95d0190cc20ce9bd35c78a531ec038df7b441f4ff290242c83396ce7e67047175a152719f79a169bd203e410f0062c6e984d386c75809c42c684dd152c07b78a3e60868f92e0c3537826145a7709a56ccdf8a829bbcc7a142b17ccb88a66076400bb691c2abf989935ddbfe6acff893d00ea435f356f7ebf83552fe0583f6b8c4124d4398165af37b2153dec3727a337a8b704abe1bf1b059e9a8d6744f18c0592e4c5ceda2ee1c7064130c1162def06f79df739485d4d1c63e8be78addcb5645ac2ba8b9a74a0637ce2ee16d953e2bd7173692e8111c87c5c1ba99c8fa8db6ccdd0437910ab1d4db9914a01d9c9892400a22a2b54d5e4a127f59c82503beb6d00cab4be2a0b5dc971f303a2e44ae64840fd61d8da471a9de737e245ceaecfed289e5d2b10d8e1456105dad7425a83e872c5f47dd50f1996b947518d12f124e28f777198a5296ffe33cc92f82bd6b70d99aaa6face73cbfdc0bfb7b636cc64d1001550bd8210befd30efa5a3c47f7e05401aa4e8714a775e3e95c7865acfaec34810a71a8d9d1535ce3b3967f1839a741a14d0dd31045a8341ca07c1ede48111209a05083ea2b892091e44d934aed0aab460432a4e4b66b68b65d60f81da84d5617853fce1de40642e3f4b936251260ab9d668e80d2ae83e9ce78f3c1d72b7c6b426019a1075a24e4421730b24cf65b8612f81fc94930ae1d529cfcdee033f26797b627fb9b7cd9a4a7443c169840ef017da3b19d412e0806e88aa58e1f289560ee864ec491798a08a2ad4ef1a6f2bab92a27e2f5b5d7ec8acb58a2ae10af696774b1db9991a6f3d6bf1765acca6da1e0a8ef29bff610b0cc6edd3f17fd090a58d32af3eff394dcff8a948eddfc4b4cef07f5b095f83d0a1fb69cd94abdaf101564f98ebb764c4ca7a4440f9d6d1ad41abe37f1ea53df5fd18d551384c86189216dc5ed92746b9be2f8552c32fd3cf5b4e49bb4b7118682dbb66a773fbc8c33221dc2a1e4d5e82392a405150fabaf3feaa5334a8f05b1163ba6832d29cb4d87f2a7400eb2c71d5bca9023f8743e20e9ef511012df78e4b2bd342cf6914da9246b2554168bab8eefb6409c1a1ad089b6c2f7548eae9672aba3d0c320a184ac2473b529b1da3c0f568cc4f3e8c9e5d72d90a2741e8865899617fb18717e2fa67c7a658892aa7eebfb9df9de8dddbb901b98feeab7d51ea6fa85785631552a74227f3ea5658533285c936b35ded53a88958f87275fa67ff273b84603568a892abaf368f137d01fef10a657842c2d2b7569b0432d858213f56a67f6b29b9c3b29620e29fc73a298f2c501f45f428349f3ba91b47b8fcb3f2f7642717713241c70a936219a73fe0efb53d30dd4d7ed238cd383aa01109ec95d1463e8a506f4363804324a40aac67bb4597ce2ce48b143c6053edcd0d5f81aa16fdc1b81dadd94b7868e94050a9b10a4e5e9913128ca7cf2b4191c8326c1d4ce1f63f57d72fd1c2f611f63a3f0f24a01a73cf2dccfbc633b39673c8cec976e41088617ca01d5be0503e085d813bd49d14aa79dbc824b2d8644d8a74e18ec9c459d51852ba2ddf8e7d60ed1219e93e1ab8252f33b45cabb90e5c942b503b8da1662e7b00a173d6a751f3b936243e7109bfba19c0c9d0cc512670a783ad4906a617d450187e227fb2b80668b24c5b484f9dc9641e9dab1f9f660802dedf6e1a63853bbd264515e7873f8a03969738d07e33455637eb2db0b487b6423e1e8b049dc016abc5e5f91ce1a9a3d2cda62dc5c5301c56b75f77641a140cc7810fb89b9b3e11b6329baa9e904c87fcb0a9dac2820d9623bf429546345fa9fbdcd44d732290fbacaf133a97c177947ad4095867f59a9d4bed6c049ed8eabcccc485da81f301449ee8c705c68f256bfff5a74d226fc195c6a2f8c73832eec6fff311183585d8fd9c25db7c831fd53c5ff7eaba42e74f3d032f525ba3e7ca8b77f5e55cd3a1230c43fb26f28ce1bd2e55f35eb80444b5e7aa7cf857980d163cf5b81b3a0555e361951c366d7e105bcc332621fc86ab5c39fa634408dd9472bf3fefaa7fa856334878fc150b14f98f6f0feb9519c935e00d4b9d8d26ed1bf9a569f33d3c3b8358109e84f070a862f80ec4700c8f4a642e14c6262c8cd27bb612758c0fa98e7e9cccfbd7dbd8038d51cb897789cbf21e44003acdd2ce0470a63e6bd56c3eeea5d50049814781858ccfce06cac7495527a5202df0ccb0f37801e0c43ebc8baa718e68396cffdd30560258f54e6bae950df20247c83fd47c6b82ef32a206991d28b7416cdd27e4cdc331d57fa5441b6472e511c81471de0133fe4adf8e952e3d8f9e563a198e558180fddd97723a68e679c2f5e44ff8f570f09eaa7ea7648"
.L636:
    .quad 4607182418800017408
.L641:
    .quad 4621819117588971520
.L643:
    .string "eef453d6923bd65a113faa2906a13b3f9558b4661b6565f84ac7ca59a424c507baaee17fa23ebf765d79bcf00d2df649e95a99df8ace6f53f4d82c2c107973dc91d8a02bb6c1059479071b9b8a4be869b64ec836a47146f99748e2826cdee284e3e27a444d8d98b7fd1b1b2308169b258e6d8c6ab0787f72fe30f0f5e50e20f7b208ef855c969f4fbdbd2d335e51a935de8b2b66b3bc4723ad2c788035e613828b16fb203055ac764c3bcb5021afcc31addcb9e83c6b1793df4abe242a1bbf3dd953e8624b85dd78d71d6dad34a2af0d87d4713d6f33aa6b8672648c40e5ad68a9c98d8ccb009506680efdaf511f18c2d43bf0effdc0ba480212bd1b2566def284a57695fe98746d014bb630f7604b57a5ced43b7e3e9188419ea3bd35385e2dcf42894a5dce35ea52064cac828675b9818995ce7aa0e1b27343efebd1940993a1ebfb4219491a1f1014ebe6c5f90bf8ca66fa129f9b60a6d41a26e077774ef6fd00b897478238d08920b098955522b49e20735e8cb1638255b46e5f5d5535b0c5a890362fddbc62eb2189f734aa831df712b443bbd52b7ba5e9ec7501d523e49a6bb0aa55653b2d47b233c92125366ec1069cd4eabe89f8999ec0bb696e840af148440a256e2c76c00670ea43ca250d96cd2a865764dbca380406926a5e5728bc807527ed3e12bcc605083704f5ecf2eba09271e88d976bf7864a44c633682e93445b8731587ea37ab3ee6afbe0211db8157268fdae9e4c5960ea05bad82964e61acf033d1a45df6fb92487298e33bd8fd0c16206306baba5d3b6d479f8e056b3c4f1ba87bc86968f48a4899877186ce0b62e2929aba83c331acdabfe94de878c71dcd9ba0b49259ff0c08b7f1d0b14af8e5410288e1b6f07ecf0ae5ee44dd9db71e91432b1a24ac9e82cd9f69d6150892731ac9faf056ebe311c083a225cd2ab70fe17c79ac6ca6dbd630a48aaf406d64d3d9db981787d092cbbccdad5b10885f0468293f0eb4e25bbf56008c58ea5a76c582338ed2621af2af2b80af6f24ed1476e2c07286faa1af5af660db4aee182cca4db847945ca50d98d9fc890ed4da37fce126597973ce50ff107bab528a0cc5fc196fefd7d0c1e53ed49a96272c8ff77b1fcbebcdc4f25e8e89c13bb0f7a9faacf3df73609b177b191618c54e9acc795830d75038c1dd59df5b9ef6a2417f97ae3d0d2446f254b0573286b44ad1d9becce62836ac5774ee367f9430aec32c2e801fb244576d5229c41f793cda73ff3a20279ed56d48a6b43527578c1110f9845418c345644d6830a13896b78aaa9be5691ef416bd60c23cc986bc656d553edec366b11c6cb8f2cbfbe86b7ec8aa894b3a202eb1c3f397bf7d71432f3d6a9b9e08a83a5e34f07daf5ccd93fb0cc53e858ad248f5c22c9d1b3400f8f9cff6891376c36d99995be23100809b9c21fa1b58547448ffffb2dabd40a0c2832a78ae2e69915b3fff9f916c90c8f323f516c8dd01fad907ffc3bae3da7d97f6792e3b1442798f49ffb4a99cd11cfdf41779cdd95317f31c7fa1d40405643d711d5838a7d3eef7f1cfc52482835ea666b2572ad1c8eab5ee43b66da3243650005eecfd863b256369d4a4090bed43e40076a82873e4f75e2224e685a7744a6e804a291a90de3535aaae202711515d0a205cb36d3515c2831559a830d5a5b44ca873e038412d9991ed58091e858790afe9486c2a5178fff668ae0b6626e974dbe39a872ce5d73ff402d98e3fb0a3d212dc8128f80fa687f881c7f8e7ce66634bc9d0b99a139029f6a239f721c1fffc1ebc44e80c987434744ac874ea327ffb266b56220fbe9141915d7a9224bf1ff9f0062baa89d71ac8fada6c9b56f773fc3603db4a9c4ce17b399107c22cb550fb4384d21d3f6019da07f549b2b7e2a53a146606a4899c102844f94e0fb2eda7444cbfc426dc0314325637a1939fa911155fefb5308f03d93eebc589f88793555ab7eba27ca96267c7535b763b54bc1558b2f3458debbb01b9283253ca29eb1aaedfb016f16ea9c227723ee8bcb465e15a979c1cadc92a1958a7675175f0bfacd89ec191ec9b749faed14125d36cef980ec671f667be51c79a85916f48482b7e12780e7401a8f31cc0937ae58d2d1b2ecb8b0908810b2fe3f0b8599ef07861fa7e6dcb4aa15dfbdcece67006ac967a791e093e1d49a8bd6a141006042bde0c8bb2c5c6d24e0aecc49914078536d58fae9f773886e18da7f5bf590966848af39a475506a899e888f99797a5e012d6d8406c952429603aab37fd7d8f58178c8e5087ba6d33b83d5605fcdcf32e1d6fb1e4a9a90880a64855c3be0a17fcd265cf2eea09a55067fa6b34ad8c9dfc06ff42faa48c0ea481ed0601d8efc57b08bf13b94daf124da26823c12795db6ce5776c53d08d6b70858a2cb1717b52481ed54768c4b0c64ca6ecb7ddcdda26da268a9942f5dcf7dfd09fe5d54150b090b02d3f93b35435d7c4c9efa548d26e5a6e1c47bc5014a1a6dafc6b8e9b0709f109a359ab6419ca1091bf867241c8cc6d4c0c30163d203c94b629b407691d7fc44f879e0de63425dcf1dc21094364dfb5636985915fc12f542e4f294b943e17a2bc43e6f5b7b17b2939d979cf3ca6cec5b5aa705992ceecf9c42bd8430bd0827723150c6ff782a838353ece53cec4a314ebda4f8bf5635246428940f4613ae5ed136871b7795e136be99b913179899f6858428e2557b59846e3fe757dd7ec07426e5331aeada2fe589cf9096ea6f3848984f3ff0d2c85def7621b4bca50b065abe630fed077a756b53a9e1ebce4dc7f16dfbd3e8495912c628948d3360f09cf6e4bd64712dd7abbbd95cb080392cc4349decbd8d794d96aacfb3dca04777f541c567ecf0d7a0fc5583a089e42caaf9491b60f41686c49db57244ac5d37d5b79b6239311c2875c522ced5d77485cb25823ac77d633293366b828b86a8d39ef77164bcae5dff9c02033197a8530886b54dbdebd9f57f830283fdfcd267caa862a12d66d072df63c324fd7b8380dea93da4bc604247cb9e59f71e6da46116538d0deb7852d9be85f074e608cd795be87051665667902e276c921f8b806bd9714632dff600ba1cd8a3db53b6a086cfcd97bf97f380e8a40eccd228a4c8a883c0fdaf7df06122cd128006b2cdfad2a4b13d1b5d6c796b805720085f819cc3a6eec6311a63cbe3303674053bb0c3f490aa77bd60fcbedbfc4411068a9cf4f1b4d515acb93bee92fb5515482d44991711052d8bf3c5751bdd152d4d1c4abf5cd54678eef0b6d262d45a78a0635def340a98172aace486fb897116c87c349580869f0e7aac0ed45d35e6ae3d4da0bae0a846d21957128974836059cca109e998d258869facd72bd1a438703fc94b91ff83775423cc067b6306a34627ddcfb67f6455292cbf081a3bc84c17b1d542e41f3d6a7377eeca20caba5f1d9e4a938e938662882af53e547eb47b7282ee9cb23867fb2a35b28de99e619a4f23aa43dec681f9f4c31f316405fa00e2ec94d48b3c113c38f9f37ede83bc408dd3dd04ae0b158b4738705e9624ab50b148d445d98ddaee19068c763badd624dd9b095787f8a8d4cfa417c9e54ca5d70a80e5d6a9f6d30a038d1dbc5e9fcf4ccd211f4cd47487cc8470652b7647c3200069671f84c8d4dfd2c63f3b29ecd9f40041e073a5fb0a17c777cf09f468107100525890cf79cc9db955c2cc7182148d4066eeb481ac1fe293d599bfc6f14cd848405530a21727db38cb002fb8ada00e5a506a7cca9cf1d206fdc03ba6d90811f0e4851cfd442e4688bd304a908f4a166d1da6639e4a9cec15763e2e9a598e4e043287fec5dd44271ad3cdba40eff1e1853f29fdf7549530e188c128d12bee59e68ef47c9a94dd3e8cf578b982bb74f8301958cec13a148e3032d6e7e36a52363c1faf01f18899b1bc3f8ca1dc44e6c3cb279ac196f5600f15a7b7e529ab103a5ef8c0b9bcb2b812db11a5de7415d448f6b6f0e7ebdf661791d60f56111b495b3464ad21936b9fcebb25c995cab10dd900beec34b84687c269ef3bfb3d5d514f40eea742e65829b3046b0afa0cb4a5a3112a51128ff71a0fe2c2e6dc47f0e785eaba72abb3f4e093db73a09359ed216765690f56e0f218b8d25088b8306869c13ec3532c8c974f73837255731e414218c73a13fbafbd2350644eeacfe5d1929ef90898fadbac6c247d62a583df45f746b74abf39894bc396ce5da7726b8bba8c328eb783ab9eb47c81f5114f066ea92f3f326564d686619ba27255a2c80a537b0efefebd8613fd0145877585bd06742ce95f5f36a798fc4196e952e72c48113823b73704d17f3b51fca3a7a0f75a15862ca504c582ef85133de648c49a984d73dbe722fba3ab66580d5fdaf5c13e60d0d2e0ebbacc963fee10b7d1b3318df905079926a8ffbbcfe994e5c61ffdf17746497f70529fd561f1fd0f9bd3feb6ea8bedefa633c7caba6e7c5382c8fe64a52ee96b8fc0f9bd690a1b68637b3dfdce7aa3c673b09c1661a651213e2d06bea10ca65c084ec31bfa0fe5698db8486e494fcff30a62f3e2f893dec3f1265a89dba3c3efccfa986ddb5c6b3a76b7f89629465a75e01cbe89523386091465f6bbb397f1135823ee2ba6c0678b597f746aa07ded582e2c94db483840b717efa8c2a44eb4571cdcba121a4650e4ddeb92f34d62616ce413e896a0d7e51e156677b020baf9c81d17915e2486ef32cd600ace1474dc1d122eb5b5ada8aaff80b80d819992132456bae3231912d5bf60e610e1fff697ed6c698df5efabc5979c8fca8d3ffa1ef463c1b1736b96b6fd83b3bd308ff8a6b17cb2ddd0467c64bce4a0ac7cb3f6d05ddbde8aa22c0dbef60ee46bcdf07a423aa96bad4ab7112eb3929d86c16c98d2c953c6d89d64d57a607744e871c7bf077ba8b787625f056c7c4a8b11471cd764ad4972a93af6c6c79b5d2dd598e40d3dd89bcfd389b478798234794aff1d108d4ec2c3843610cb4bf160cbcedf722a585139baa54394fe1eedb8fec2974eb4ee658828ce947a3da6a9273e733d226229feea32811ccc668829b8870806357d5a3f525fa163ff802a3426a8ca07c2dcb0cf26f7c9bcff6034c13052fc89b393dd02f0b5fc2c3f3841f17c67bbac2078d443ace29d9ba7832936edc0d54b944b84aa4c0dc5029163f384a9310a9e795e65d4df11f64335bcf065d37d4d4617b5ff4a16d599ea0196163fa42e504bced1bf8e4e45c06481fb9bcf8d39e45ec2862f71e1d6f07da27a82c370885d767327bb4e5a4c964e858c91ba26553a6a07f8d510f86fbbe226efb628afea890489f70a55368beadab0aba3b2dbe52b45ac74ccea842e92c8ae6b464fc96f3b0b8bc90012929db77ada0617e3bbcb09ce6ebb40173744e55990879ddcaabdcc420a6a101d05158f57fa54c2a9eab69fa946824a12232db32df8e9f354656447939822dc96abf9dff9772470297ebd59787e2b93bc56f78bfbea76c619ef3657eb4edb3c55b65aaefae51477a06b03ede622920b6b23f1dab99e59958885c4e95fab368e45eced88b402f7fd75539b11dbcb0218ebb414aae103b5fcd2a881d652bdc29f26a119d59944a37c0752a24be76d3346f0495f857fcae62d8493a56f70a4400c562ddba6dfbd9fb8e5b88ecb4ccd500f6bb952d097ad07a71f26b27e2000a41346a7a7825ecc24c873782f8ed400668c0c28c8a2f67f2dfa90563b728900802f0f32facbb41ef979346bca4f2b40a03ad2ffb9fea126b7d78186bce2f610c84987bfa89f24b832e6b0f4360dd9ca7d2df4d7c9c6ede63fa05d314391503d1c79720dbbf8a95fcf88747d9475a44c6397ce912a9b69dbe1b548ce7cc986afbe3ee11abac24452da229b021bfbe85badce996168f2d56790ab41c2a2fae27299423fb9c397c560ba6b0919a5dccd879fc967d41abdb6b8e905cb600f5400e987bbc1c920ed246723473e3813290123e9aab23b689436c0760c86e30bf9a0b6720aaf6521b94470938fa89bcef808e40e8d5b3e69e7958cb87392c2c2b60b1d1230b20e0490bd77f3483bb9b9b1c6f22b5e6f48c2b4ecd5f01a4aa8281e38aeb6360b1af3e2280b6c20dd523225c6da63c38de1b08d590723948a535f579c487e5a38ad0eb0af48ec79ace8372d835a9df0c6d851dcdb1b2798182244f8e431456cf88e658a08f0f8bf0f156b1b8e9ecb641b58ffac8b2d36eed2dac5e272467e3d222f3fd7adf884aa8791775b0ed81dcc6abb0f86ccbb52ea94baea98e947129fc2b4e9a87fea27a539e9a53f2398d747b36224d29fe4b18e88640e8eec7f0d19a03aad83a3eeeef9153e891953cf68300424aca48ceaaab75a8e2b5fa8c3423c052dd7cdb02555653131b63792f412cb06794d808e17555f3ebf11e2bbd88bbee40bd0a0b19d2ab70e6ed65b6aceaeae9d0ec4c8de047564d20a8bf245825a5a445275fb158592be068d2eeed6e2f0f0d567129ced737bb6c4183d55464dd69685606bc428d05aa4751e4caa97e14c3c26b886f53304714d9265dfd53dd99f4b3066a8993fe2c6d07b7fabe546a8038efe4029bf8fdb78849a5f96de98520472bdd033ef73d256a5c0f77c963e66858f6d444095a8637627989aaddde7001379a44aa8bb127c53b17ec1595560c018580d5d52e9d71b689dde71afaab8f01e6e10b4a69226712162ab070dcab3961304ca70e8b6b00d69bb55c8d13d607b97c5fd0d22e45c10c42a2b3b058cb89a7db77c506a8eb98a7a9a5b04e377f3608e92adb242b267ed1940f1c61c55f038b237591ed3df01e85f912e37a36b6c46dec52f66888b61313bbabce2c62323ac4b3b3da015ae397d8aa96c1b77abec975e0a0d081ad9c7dced53c7225596e7bd358c904a21881cea14545c75757e50d64177da2e54aa242499697392d2dde50bd1d5d0b9e9d4ad2dbfc3d07787955e4ec64b44e86484ec3c97da624ab4bd5af13bef0b113ea6274bbdd0fadd61ecb1ad8aeacdd58ecfb11ead453994ba67de18eda5814af281ceb32c4b43fcf480eacf948770ced7a2425ff75e14fc31a1258379a94d028dcad2f7f5359a3b3e096ee45813a04330fd87b5f28300ca0d8bca9d6e188853fc9e74d1b791e07e48775ea264cf55347ec612062576589dda95364afe032a819ef79687aed3eec5513a83ddbd83f522059abe14cd44753b52c4926a9672793543c16d9a0095928a2775b7053c0f178294f1c90080baf72cb15324c68b12dd6339971da05074da7beed3f6fc16ebca5e04bce5086492111aea88f4bb1ca6bcf585ec1e4a7db69561a52b31e9e3d06c32e69392ee8e921d5d073aff322e62439fd0b877aa3236a4b44909befeb9fad487c3e69594bec44de15b4c2ebe687989a9b4901d7cf73ab0acd90f9d37014bf60a11b424dc35095cd80f538484c19ef38c95e12e13424bb40e132865a5f206b06fba8cbccc096f5088cbf93f87b7442e45d4afebff0bcb24aafef78f69a51539d749dbe6fecebdedd5beb573440e5a884d1c89705f4136b4a59731680a88f8953031abcc77118461cefcfdc20d2b36ba7c3ed6bf94d5e57a42bc3d32907604691b4d8637bd05af6c69b5a63f9a49c2c1b110a7c5ac471b4784230fcf80dc33721d54d1b71758e219652bd3c36113404ea4a983126e978d4fdf3b645a1cac083126eaa3d70a3d70a3d70a3d70a3d70a3d70a4cccccccccccccccccccccccccccccccd80000000000000000000000000000000a0000000000000000000000000000000c8000000000000000000000000000000fa0000000000000000000000000000009c400000000000000000000000000000c3500000000000000000000000000000f424000000000000000000000000000098968000000000000000000000000000bebc2000000000000000000000000000ee6b28000000000000000000000000009502f900000000000000000000000000ba43b740000000000000000000000000e8d4a5100000000000000000000000009184e72a000000000000000000000000b5e620f4800000000000000000000000e35fa931a000000000000000000000008e1bc9bf040000000000000000000000b1a2bc2ec50000000000000000000000de0b6b3a7640000000000000000000008ac7230489e800000000000000000000ad78ebc5ac6200000000000000000000d8d726b7177a80000000000000000000878678326eac90000000000000000000a968163f0a57b4000000000000000000d3c21bcecceda100000000000000000084595161401484a00000000000000000a56fa5b99019a5c80000000000000000cecb8f27f4200f3a0000000000000000813f3978f89409844000000000000000a18f07d736b90be55000000000000000c9f2c9cd04674edea400000000000000fc6f7c40458122964d000000000000009dc5ada82b70b59df020000000000000c5371912364ce3056c28000000000000f684df56c3e01bc6c7320000000000009a130b963a6c115c3c7f400000000000c097ce7bc90715b34b9f100000000000f0bdc21abb48db201e86d4000000000096769950b50d88f41314448000000000bc143fa4e250eb3117d955a000000000eb194f8e1ae525fd5dcfab080000000092efd1b8d0cf37be5aa1cae500000000b7abc627050305adf14a3d9e40000000e596b7b0c643c7196d9ccd05d00000008f7e32ce7bea5c6fe4820023a2000000b35dbf821ae4f38bdda2802c8a800000e0352f62a19e306ed50b2037ad2000008c213d9da502de454526f422cc340000af298d050e4395d69670b12b7f410000daf3f04651d47b4c3c0cdd765f11400088d8762bf324cd0fa5880a69fb6ac800ab0e93b6efee00538eea0d047a457a00d5d238a4abe9806872a4904598d6d88085a36366eb71f04147a6da2b7f864750a70c3c40a64e6c51999090b65f67d924d0cf4b50cfe20765fff4b4e3f741cf6d82818f1281ed449fbff8f10e7a8921a4a321f2d7226895c7aff72d52192b6a0dcbea6f8ceb02bb399bf4f8a69f764490fee50b7025c36a0802f236d04753d5b49f4f2726179a224501d762422c946590c722f0ef9d80aad6424d3ad2b7b97ef5f8ebad2b84e0d58bd2e0898765a7deb29b934c3b330c857763cc55f49f88eb2fc2781f49ffcfa6d53cbf6b71c76b25fbf316271c7fc3908a8bef464e3945ef7a97edd871cfda3a5697758bf0e3cbb5acbde94e8e43d0c8ec3d52eeed1cbea317ed63a231d4c4fb274ca7aaa863ee4bdd945e455f24fb1cf88fe8caa93e74ef6ab975d6b6ee39e436b3e2fd538e122b44e7d34c64a9c85d4460dbbca87196b61690e40fbeea1d3a4abc8955e946fe31cdb51d13aea4a488dd6babab6398bdbe41e264589a4dcdab14c696963c7eed2dd18d7eb76070a08aecfc1e1de5cf543ca2b0de65388cc8ada83b25a55f43294bcbdd15fe86affad91249ef0eb713f39ebe8a2dbf142dfcc7ab6e3569326c784337acb92ed9397bf99649c2c37f07965404d7e77a8f87daf7fbdc33745ec97be90686f0ac99b4e8dafd69a028bb3ded71a3a8acd7c0222311bcc40832ea0d68ce0cd2d80db02aabd62bf50a3fa490c3019083c7088e1aab65db792667c6da79e0faa4b8cab1a1563f52577001b891185938cde6fd5e09abcf26ed4c0226b55e6f8680b05e5ac60b6178544f8158315b05b4a0dc75f1778e39d6696361ae3db1c721c913936dd571c84c03bc3a19cd1e38e9fb5878494ace3a5f04ab48a04065c7239d174b2dcec0e47b62eb0d64283f9c76c45d1df942711d9a3ba5d0bd324f8394f5746577930d6500ca8f44ec7ee364799968bf6abbe85f207e998b13cf4e1ecbbfc2ef456ae276e89e3fedd8c321a67eefb3ab16c59b14a2c5cfe94ef3ea101e95d04aee3b80ece5bba1f1d158724a12bb445da9ca61281f2a8a6e45ae8edc97ea1575143cf97226f52d09d71a3293bd924d692ca61be758593c2626705f9c56b6e0c377cfa2e12e6f8b2fb00c77836ce498f455c38b997a0b6dfb9c0f9564478edf98b59a373fec4724bd4189bd5eacb2977ee300c50fe758edec91ec2cb657df3d5e9bc0f653e12f2967b66737e3ed8b865b215899f46cbd79e0d20082ee74ae67f1e9aec07187ecd8590680a3aa11da01ee641a708de9e80e6f4820cc9495884134fe908658b23109058d147fdcddaa51823e34a7eedebd4b46f0599fd415d4e5e2cdc1d1ea966c9e18ac7007c91a850fadc09923329e03e2cf6bc604ddb0a6539930bf6bff4584db8346b786151ccfe87f7cef46ff16e612641865679a6381f14fae158c5f6e4fcb7e8f3f60c07ea26da3999aef7749e3be5e330f38f09dcb090c8001ab551c5cadf5bfd3072cc5fdcb4fa002162a6373d9732fc7c8f7f69e9f11c4014dda7e2867e7fddcdd9afac646d63501a1511db281e1fd541501b8f7d88bc24209a5651f225a7ca91a42269ae757596946075f3375788de9b06958c1a12d2fc39789370052d6b1641c83aef209787bb47d6b84c0678c5dbd23a49a9745eb4d50ce6332f840b7ba963646e0bd176620a501fbffb650e5a93bc3d898ec5d3fa8ce427affa3e51f138ab4cebe93ba47c980e98cdfc66f336c36b10137b8a8d9bbe123f017b80b0047445d4184e6d3102ad96cec1da60dc059157491e59043ea1ac7e4139287c89837ad68db2fb454e4a179dd187729babe4598c311fbe16a1dc9d8545e94f4296dd6fef3d67a8ce2529e2734bb1d1899e4a65f58660cb01ae745b101e9e45ec05dcff72e7f8fdc21a1171d42645d76707543f4fa1f73899504ae72497eba6a06494a791c53a8abfa45da0edbde690487db9d17636892d6f8d7509292d60345a9d2845d3c42b6865b86925b9bc5c20b8a2392ba45a9b2a7f26836f282b7328e6cac7768d7141ed1ef0244af2364ff3207d795430cd9268335616aed761f1f7f44e6bd49e807b8a402b9c5a8d3a6e75f16206c9c6209a6cd036837130890a136dba887c37a8c0f802221226be55a64c2494954da2c9789a02aa96b06deb0fdf2db9baa10b7bd6cc83553c5c8965d3d6f92829494e5acc7fa42a8b73abbf48ccb772339ba1f17f99c69a97284b578d7ff2a760414536efbc38413cf25e2d70dfef5138519684abaf46518c2ef5b8cd17eb258665fc25d6998bf2f79d5993802ef2f773ffbd97a61beeefb584aff8603aafb550ffacfd8faeeaaba2e5dbf678495ba2a53f983cf38952ab45cfa97a0b2dd945a747bf26183ba756174393d88df94f971119aeef9e4e912b9d1478ceb177a37cd5601aab85d91abb422ccb812eeac62e055c10ab33ab616a12b7fe617aa577b986b314d6009e39c49765fdf9d94ed5a7e85fda0b80b8e41ade9fbebc27d14588f13be847307b1d219647ae6b31c596eb2d8ae258fc8de469fbd99a05fe36fca5f8ed9aef3bb8aec23d680043bee25de7bb9480d5854ada72ccc20054ae9af561aa79a10ae6ad910f7ff28069da41b2ba1518094da0487aa9aff7904228690fb44d2f05d0842a99541bf57452b28353a1607ac744a53d3fa922f2d1675f242889b8997915ce8847c9b5d7c2e09b769956135febada11a59bc234db398c2543fab9837e699095cf02b2c21207ef2e94f967e45e03f4bb8161afb94b44f57d1d1be0eebac278f5a1ba1ba79e1632dc6462d92a69731732ca28a291859bbf937d7b8f7503cfdcfefcb2cb35e702af785cda735244c3d43e9defbf01b061adab3a0888136afa64a7c56baec21c7a1916088aaa1845b8fdd0f6c69a72a3989f5b8aad549e57273d459a3c2087a63f639936ac54e2f678864bc0cb28a98fcf3c7f84576a1bb416a7ddf0fdf2d3f3c30b9f656d44a2a11c51d5969eb7c47859e7439f644ae5a4b1b325bc4665b596706114873d5d9f0dde1feeeb57ff22fc0c7959a90cb506d155a7ea9316ff75dd87cbd809a7f12442d588f2b7dcbf5354e9bece0c11ed6d538aeb2fe5d3ef282a242e818f1668c8a86da5fa8fa475791a569d10f96e017d694487bcb38d92d760ec445537c981dcc395a9ace070f78d3927556a85bbe253f47b14178c469ab843b8956293956d7478ccec8eaf58416654a6babb387ac8d1970027b2db2e51bfe9d0696a06997b05fcc0319e88fcf317f22241e2441fece3bdf81f03ab3c2fddeeaad25ad527e81cad7626c3d60b3bd56a5586f18a71e223d8d3b07485c7056562757456f6872d5667844e49a738c6bebb12d16cb428f8ac016561dbd106f86e69d785c7e13336d701beba5282a45b450226b39cecc0024661173473a34d721642b0608427f002d7f95d0190cc20ce9bd35c78a531ec038df7b441f4ff290242c83396ce7e67047175a152719f79a169bd203e410f0062c6e984d386c75809c42c684dd152c07b78a3e60868f92e0c3537826145a7709a56ccdf8a829bbcc7a142b17ccb88a66076400bb691c2abf989935ddbfe6acff893d00ea435f356f7ebf83552fe0583f6b8c4124d4398165af37b2153dec3727a337a8b704abe1bf1b059e9a8d6744f18c0592e4c5ceda2ee1c7064130c1162def06f79df739485d4d1c63e8be78addcb5645ac2ba8b9a74a0637ce2ee16d953e2bd7173692e8111c87c5c1ba99c8fa8db6ccdd0437910ab1d4db9914a01d9c9892400a22a2b54d5e4a127f59c82503beb6d00cab4be2a0b5dc971f303a2e44ae64840fd61d8da471a9de737e245ceaecfed289e5d2b10d8e1456105dad7425a83e872c5f47dd50f1996b947518d12f124e28f777198a5296ffe33cc92f82bd6b70d99aaa6face73cbfdc0bfb7b636cc64d1001550bd8210befd30efa5a3c47f7e05401aa4e8714a775e3e95c7865acfaec34810a71a8d9d1535ce3b3967f1839a741a14d0dd31045a8341ca07c1ede48111209a05083ea2b892091e44d934aed0aab460432a4e4b66b68b65d60f81da84d5617853fce1de40642e3f4b936251260ab9d668e80d2ae83e9ce78f3c1d72b7c6b426019a1075a24e4421730b24cf65b8612f81fc94930ae1d529cfcdee033f26797b627fb9b7cd9a4a7443c169840ef017da3b19d412e0806e88aa58e1f289560ee864ec491798a08a2ad4ef1a6f2bab92a27e2f5b5d7ec8acb58a2ae10af696774b1db9991a6f3d6bf1765acca6da1e0a8ef29bff610b0cc6edd3f17fd090a58d32af3eff394dcff8a948eddfc4b4cef07f5b095f83d0a1fb69cd94abdaf101564f98ebb764c4ca7a4440f9d6d1ad41abe37f1ea53df5fd18d551384c86189216dc5ed92746b9be2f8552c32fd3cf5b4e49bb4b7118682dbb66a773fbc8c33221dc2a1e4d5e82392a405150fabaf3feaa5334a8f05b1163ba6832d29cb4d87f2a7400eb2c71d5bca9023f8743e20e9ef511012df78e4b2bd342cf6914da9246b2554168bab8eefb6409c1a1ad089b6c2f7548eae9672aba3d0c320a184ac2473b529b1da3c0f568cc4f3e8c9e5d72d90a2741e8865899617fb18717e2fa67c7a658892aa7eebfb9df9de8dddbb901b98feeab7d51ea6fa85785631552a74227f3ea5658533285c936b35ded53a88958f87275fa67ff273b84603568a892abaf368f137d01fef10a657842c2d2b7569b0432d858213f56a67f6b29b9c3b29620e29fc73a298f2c501f45f428349f3ba91b47b8fcb3f2f7642717713241c70a936219a73fe0efb53d30dd4d7ed238cd383aa01109ec95d1463e8a506f4363804324a40aac67bb4597ce2ce48b143c6053edcd0d5f81aa16fdc1b81dadd94b7868e94050a9b10a4e5e9913128ca7cf2b4191c8326c1d4ce1f63f57d72fd1c2f611f63a3f0f24a01a73cf2dccfbc633b39673c8cec976e41088617ca01d5be0503e085d813bd49d14aa79dbc824b2d8644d8a74e18ec9c459d51852ba2ddf8e7d60ed1219e93e1ab8252f33b45cabb90e5c942b503b8da1662e7b00a173d6a751f3b936243e7109bfba19c0c9d0cc512670a783ad4906a617d450187e227fb2b80668b24c5b484f9dc9641e9dab1f9f660802dedf6e1a63853bbd264515e7873f8a03969738d07e33455637eb2db0b487b6423e1e8b049dc016abc5e5f91ce1a9a3d2cda62dc5c5301c56b75f77641a140cc7810fb89b9b3e11b6329baa9e904c87fcb0a9dac2820d9623bf429546345fa9fbdcd44d732290fbacaf133a97c177947ad4095867f59a9d4bed6c049ed8eabcccc485da81f301449ee8c705c68f256bfff5a74d226fc195c6a2f8c73832eec6fff311183585d8fd9c25db7c831fd53c5ff7eaba42e74f3d032f525ba3e7ca8b77f5e55cd3a1230c43fb26f28ce1bd2e55f35eb80444b5e7aa7cf857980d163cf5b81b3a0555e361951c366d7e105bcc332621fc86ab5c39fa634408dd9472bf3fefaa7fa856334878fc150b14f98f6f0feb9519c935e00d4b9d8d26ed1bf9a569f33d3c3b8358109e84f070a862f80ec4700c8f4a642e14c6262c8cd27bb612758c0fa98e7e9cccfbd7dbd8038d51cb897789cbf21e44003acdd2ce0470a63e6bd56c3eeea5d50049814781858ccfce06cac7495527a5202df0ccb0f37801e0c43ebc8baa718e68396cffdd30560258f54e6bae950df20247c83fd47c6b82ef32a206991d28b7416cdd27e4cdc331d57fa5441b6472e511c81471de0133fe4adf8e952e3d8f9e563a198e558180fddd97723a68e679c2f5e44ff8f570f09eaa7ea7648"
.L744:
    .string "-inf"
.L745:
    .string "inf"
.L746:
    .string "-nan"
.L747:
    .string "nan"
.L789:
    .string "(null)"
.L790:
    .string "\n"
.L799:
    .string "file-write"
.L805:
    .string "mkdir-p"
.L814:
    .string ""
.L815:
    .string "/"
.L830:
    .string "/"
.L848:
    .string ""
.L850:
    .string "list-zyl-files"
.L851:
    .string ".zyl"
.L853:
    .string "list-files"
.L854:
    .string "list-files"
.L860:
    .string "[?2004l[0m"
.L869:
    .string "term-write"
.L874:
    .string "union-find table"
.L887:
    .string "zyl: mem-read: null pointer\n"
.L889:
    .string "zyl: mem-write: null pointer\n"
.L891:
    .string "cstr-byte-set"
.L894:
    .string "ZYL_REGIONS"
.L898:
    .string "codegen buffer limit exceeded"
.L905:
    .string "words"
.L907:
    .string "aes block"
.L911:
    .string "aes key"
.L912:
    .string "words"
.L913:
    .string "words"
.L914:
    .string "words"
.L918:
    .string "/dev/urandom"
.L922:
    .string "words"
.L923:
    .string "random-words"
.L925:
    .string "zyl: invalid callee address 0x"
.L926:
    .string ""
.L927:
    .string "\n"
.L980:
    .string "0123456789abcdef"
.L983:
    .string "zyl: ffi call to invalid address 0x"
.L984:
    .string ""
.L985:
    .string "\n"
.L1003:
    .string "zyl: ffi call with "
.L1004:
    .string " arguments (max 6)\n"
.L1006:
    .string "zyl_ffi_pin"
.L1007:
    .string "zyl_ffi_unpin"
.L1008:
    .string "zyl_actor_init"
.L1009:
    .string "zyl_actor_is_alive"
.L1010:
    .string "zyl_actor_spawn"
.L1011:
    .string "zyl_chan_new"
.L1012:
    .string "zyl_chan_recv"
.L1013:
    .string "zyl_chan_rx"
.L1014:
    .string "zyl_chan_send"
.L1015:
    .string "zyl_chan_tx"
.L1016:
    .string "zyl_actor_wait"
.L1017:
    .string "zyl_actor_wait_all"
.L1018:
    .string "zyl_aes_encrypt_block"
.L1019:
    .string "zyl_aesni_available"
.L1020:
    .string "zyl_align_check"
.L1021:
    .string "zyl_arena_alloc"
.L1022:
    .string "zyl_arena_alloc_zeroed"
.L1024:
    .string "zyl_arena_capacity"
.L1025:
    .string "zyl_arena_create"
.L1026:
    .string "zyl_arena_destroy"
.L1027:
    .string "zyl_arena_reset"
.L1028:
    .string "zyl_arena_used"
.L1029:
    .string "zyl_arg_str"
.L1030:
    .string "zyl_argc"
.L1031:
    .string "zyl_atomic_add"
.L1032:
    .string "zyl_atomic_cas"
.L1033:
    .string "zyl_atomic_fetch_add"
.L1034:
    .string "zyl_atomic_load"
.L1035:
    .string "zyl_atomic_max"
.L1036:
    .string "zyl_atomic_min"
.L1037:
    .string "zyl_atomic_store"
.L1038:
    .string "zyl_atomic_sub"
.L1039:
    .string "zyl_blake3_file_hex"
.L1041:
    .string "zyl_blake3_hex"
.L1042:
    .string "zyl_byte_slice"
.L1043:
    .string "zyl_byte_slice_sub"
.L1044:
    .string "zyl_bytebuf_append"
.L1045:
    .string "zyl_bytebuf_atomic_add"
.L1046:
    .string "zyl_bytebuf_atomic_cas"
.L1047:
    .string "zyl_bytebuf_atomic_fetch_add"
.L1048:
    .string "zyl_bytebuf_atomic_load"
.L1049:
    .string "zyl_bytebuf_atomic_max"
.L1050:
    .string "zyl_bytebuf_atomic_min"
.L1051:
    .string "zyl_bytebuf_atomic_store"
.L1052:
    .string "zyl_bytebuf_atomic_sub"
.L1053:
    .string "zyl_bytebuf_cap"
.L1054:
    .string "zyl_bytebuf_len"
.L1055:
    .string "zyl_bytebuf_new"
.L1056:
    .string "zyl_bytebuf_ptr"
.L1058:
    .string "zyl_call0"
.L1059:
    .string "zyl_call1"
.L1060:
    .string "zyl_call2"
.L1061:
    .string "zyl_call3"
.L1062:
    .string "zyl_call4"
.L1063:
    .string "zyl_call5"
.L1064:
    .string "zyl_call6"
.L1065:
    .string "zyl_call_argv"
.L1066:
    .string "zyl_call_on_big_stack"
.L1067:
    .string "zyl_cc_compile"
.L1068:
    .string "zyl_cc_compile_log"
.L1069:
    .string "zyl_chdir"
.L1070:
    .string "zyl_cpuid_features"
.L1071:
    .string "zyl_cstr_byte_at"
.L1072:
    .string "zyl_cstr_byte_set"
.L1073:
    .string "zyl_cstr_concat"
.L1075:
    .string "zyl_cstr_count_newlines"
.L1076:
    .string "zyl_cstr_decode"
.L1077:
    .string "zyl_cstr_cmp"
.L1078:
    .string "zyl_cstr_eq"
.L1079:
    .string "zyl_cstr_from_byte"
.L1080:
    .string "zyl_cstr_from_int"
.L1081:
    .string "zyl_cstr_key_matches"
.L1082:
    .string "zyl_div_magic"
.L1083:
    .string "zyl_div_shift"
.L1084:
    .string "zyl_array_copy"
.L1085:
    .string "zyl_view_ok"
.L1086:
    .string "zyl_view_byte"
.L1087:
    .string "zyl_view_cmp"
.L1088:
    .string "zyl_view_find"
.L1089:
    .string "zyl_view_copy"
.L1090:
    .string "zyl_cstr_last_newline"
.L1092:
    .string "zyl_cstr_len"
.L1093:
    .string "zyl_cstr_of_word"
.L1094:
    .string "zyl_float_bits"
.L1095:
    .string "zyl_float_of_bits"
.L1096:
    .string "zyl_word_load"
.L1097:
    .string "zyl_word_store"
.L1098:
    .string "zyl_ptr_add"
.L1099:
    .string "zyl_ptr_cstr"
.L1100:
    .string "zyl_ffi_addr"
.L1101:
    .string "zyl_cstr_sanitize"
.L1102:
    .string "zyl_cstr_sub"
.L1103:
    .string "zyl_cstr_substr"
.L1104:
    .string "zyl_cstr_to_int"
.L1105:
    .string "zyl_cstr_to_int_base"
.L1106:
    .string "zyl_diag_json"
.L1107:
    .string "zyl_diag_json_set"
.L1109:
    .string "zyl_dirname_cstr"
.L1110:
    .string "zyl_attr_clear"
.L1111:
    .string "zyl_attr_copy"
.L1112:
    .string "zyl_attr_get"
.L1113:
    .string "zyl_attr_set"
.L1114:
    .string "zyl_ensure_arenas"
.L1115:
    .string "zyl_exec_cmd"
.L1116:
    .string "zyl_f_add"
.L1117:
    .string "zyl_f_cmp"
.L1118:
    .string "zyl_f_div"
.L1119:
    .string "zyl_f_error"
.L1120:
    .string "zyl_f_mul"
.L1121:
    .string "zyl_f_of_int"
.L1122:
    .string "zyl_f_parse"
.L1123:
    .string "zyl_f_rem"
.L1124:
    .string "zyl_f_sub"
.L1126:
    .string "zyl_f_text"
.L1127:
    .string "zyl_f_to_int"
.L1128:
    .string "zyl_ffi_lookup"
.L1129:
    .string "zyl_ffi_timed"
.L1130:
    .string "zyl_ffi_timed_argv"
.L1131:
    .string "zyl_file_close_c"
.L1132:
    .string "zyl_exit"
.L1133:
    .string "zyl_read_line"
.L1134:
    .string "zyl_file_open_c"
.L1135:
    .string "zyl_file_read_c"
.L1136:
    .string "zyl_file_write_c"
.L1137:
    .string "zyl_fnmap_get"
.L1138:
    .string "zyl_fnmap_put"
.L1139:
    .string "zyl_fnmap_reset"
.L1140:
    .string "zyl_fresh_id"
.L1141:
    .string "zyl_getcwd"
.L1143:
    .string "zyl_getenv"
.L1144:
    .string "zyl_contract_warn"
.L1145:
    .string "zyl_err_is"
.L1146:
    .string "zyl_list_zyl_files"
.L1147:
    .string "zyl_list_files"
.L1148:
    .string "zyl_load_n"
.L1149:
    .string "zyl_load_n_signed"
.L1150:
    .string "zyl_store_n"
.L1151:
    .string "zyl_global_get"
.L1152:
    .string "zyl_global_put"
.L1153:
    .string "zyl_global_ready"
.L1154:
    .string "zyl_global_clear"
.L1155:
    .string "zyl_iglobal_get"
.L1156:
    .string "zyl_iglobal_put"
.L1157:
    .string "zyl_iglobal_ready"
.L1158:
    .string "zyl_iglobal_clear"
.L1160:
    .string "zyl_repl_global_get"
.L1161:
    .string "zyl_repl_global_set"
.L1162:
    .string "zyl_uf_id"
.L1163:
    .string "zyl_uf_reset"
.L1164:
    .string "zyl_uf_new"
.L1165:
    .string "zyl_uf_find"
.L1166:
    .string "zyl_uf_union"
.L1167:
    .string "zyl_uf_raise"
.L1168:
    .string "zyl_uf_level"
.L1169:
    .string "zyl_regions_enabled"
.L1170:
    .string "zyl_words_new"
.L1171:
    .string "zyl_words_alloc"
.L1172:
    .string "zyl_words_alloc_r"
.L1173:
    .string "zyl_words_len"
.L1174:
    .string "zyl_words_get"
.L1175:
    .string "zyl_words_set"
.L1176:
    .string "zyl_words_view"
.L1177:
    .string "zyl_smap_has"
.L1179:
    .string "zyl_smap_get_or"
.L1180:
    .string "zyl_array_new"
.L1181:
    .string "zyl_vec_alloc"
.L1182:
    .string "zyl_vec_alloc_r"
.L1183:
    .string "zyl_array_cap"
.L1184:
    .string "zyl_array_filled"
.L1185:
    .string "zyl_array_get"
.L1186:
    .string "zyl_array_set"
.L1187:
    .string "zyl_attrh_new"
.L1188:
    .string "zyl_attrh_set"
.L1189:
    .string "zyl_attrh_get_or"
.L1190:
    .string "zyl_attrh_has"
.L1191:
    .string "zyl_attrh_copy"
.L1192:
    .string "zyl_attrh_clear"
.L1193:
    .string "zyl_ref_new"
.L1194:
    .string "zyl_ref_get"
.L1195:
    .string "zyl_ref_set"
.L1196:
    .string "zyl_getenv_str"
.L1198:
    .string "zyl_strbuf_new"
.L1199:
    .string "zyl_strbuf_new_r"
.L1200:
    .string "zyl_strbuf_str"
.L1201:
    .string "zyl_cstr_escapes_ok"
.L1202:
    .string "zyl_heap_alloc"
.L1203:
    .string "zyl_ralloc"
.L1204:
    .string "zyl_region_enter"
.L1205:
    .string "zyl_region_exit"
.L1206:
    .string "zyl_region_free"
.L1207:
    .string "zyl_region_scope_enter"
.L1208:
    .string "zyl_region_live_bytes"
.L1209:
    .string "zyl_heap_block_p"
.L1210:
    .string "zyl_heap_swap"
.L1211:
    .string "zyl_int_text"
.L1212:
    .string "zyl_itest_add"
.L1213:
    .string "zyl_itest_count"
.L1214:
    .string "zyl_itest_fn"
.L1216:
    .string "zyl_itest_name"
.L1217:
    .string "zyl_itest_outcome"
.L1218:
    .string "zyl_itest_fail"
.L1219:
    .string "zyl_itest_reset"
.L1220:
    .string "zyl_itest_start"
.L1221:
    .string "zyl_itest_summary"
.L1222:
    .string "zyl_json_quote"
.L1223:
    .string "zyl_load_byte"
.L1224:
    .string "zyl_load_byte_signed"
.L1225:
    .string "zyl_mangle_key"
.L1226:
    .string "zyl_mem_alloc"
.L1227:
    .string "zyl_mem_free"
.L1228:
    .string "zyl_mem_read"
.L1229:
    .string "zyl_mem_write"
.L1230:
    .string "zyl_mkdir_p"
.L1231:
    .string "zyl_mlock"
.L1232:
    .string "zyl_panic"
.L1234:
    .string "zyl_path_exists"
.L1235:
    .string "zyl_pin_alloc"
.L1236:
    .string "zyl_print_float"
.L1237:
    .string "zyl_print_int"
.L1238:
    .string "zyl_print_str"
.L1239:
    .string "zyl_random_fill"
.L1240:
    .string "zyl_random_words"
.L1241:
    .string "zyl_run_bin"
.L1242:
    .string "zyl_session_arena"
.L1243:
    .string "zyl_smap_clear"
.L1244:
    .string "zyl_smap_get"
.L1245:
    .string "zyl_smap_global"
.L1246:
    .string "zyl_smap_new"
.L1247:
    .string "zyl_smap_put"
.L1248:
    .string "zyl_source_path"
.L1249:
    .string "zyl_source_register"
.L1251:
    .string "zyl_span_col"
.L1252:
    .string "zyl_span_copy"
.L1253:
    .string "zyl_span_file"
.L1254:
    .string "zyl_span_line"
.L1255:
    .string "zyl_span_line_text"
.L1256:
    .string "zyl_span_off"
.L1257:
    .string "zyl_span_snippet"
.L1258:
    .string "zyl_span_snippet_col"
.L1259:
    .string "zyl_span_offset_at"
.L1260:
    .string "zyl_span_set"
.L1261:
    .string "zyl_store_byte"
.L1262:
    .string "zyl_store_byte_signed"
.L1263:
    .string "zyl_str_append"
.L1264:
    .string "zyl_str_append_capped"
.L1265:
    .string "zyl_sym_escape"
.L1266:
    .string "zyl_system_cmd"
.L1268:
    .string "zyl_term_flush"
.L1269:
    .string "zyl_term_height"
.L1270:
    .string "zyl_term_is_tty"
.L1271:
    .string "zyl_term_raw_off"
.L1272:
    .string "zyl_term_raw_on"
.L1273:
    .string "zyl_term_read_byte"
.L1274:
    .string "zyl_term_read_byte_timeout"
.L1275:
    .string "zyl_term_width"
.L1276:
    .string "zyl_term_write"
.L1277:
    .string "zyl_try_frame_msg"
.L1278:
    .string "zyl_try_last_msg"
.L1279:
    .string "zyl_try_pop"
.L1280:
    .string "zyl_try_push"
.L1281:
    .string "zyl_variant_cmp"
.L1282:
    .string "zyl_variant_eq"
.L1283:
    .string "zyl_variant_field"
.L1285:
    .string "zyl_warn_capture"
.L1286:
    .string "zyl_warn_emit"
.L1287:
    .string "zyl_warn_take"
.L1288:
    .string "zyl_word_of_cstr"
.L1289:
    .string "zyl_wvec_get"
.L1290:
    .string "zyl_wvec_global"
.L1291:
    .string "zyl_wvec_len"
.L1292:
    .string "zyl_wvec_new"
.L1293:
    .string "zyl_wvec_pop"
.L1294:
    .string "zyl_wvec_push"
.L1295:
    .string "zyl_wvec_set"
.L1296:
    .string "zyl_wvec_truncate"
.L1297:
    .string "zyl_zeroize"
.L1312:
    .string "PATH"
.L1321:
    .string "/bin:/usr/bin"
.L1326:
    .string "sh"
.L1327:
    .string "-c"
.L1328:
    .string "/bin/sh"
.L1333:
    .string "XXXXXX"
.L1336:
    .string "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
.L1338:
    .string "TMPDIR"
.L1339:
    .string "/tmp"
.L1340:
    .string "/zyl_link_XXXXXX"
.L1341:
    .string "#!/bin/sh\n"
.L1342:
    .string "(null)"
.L1343:
    .string "\n"
.L1344:
    .string "sh"
.L1345:
    .string "/bin/sh"
.L1348:
    .string "cc"
.L1349:
    .string "-no-pie"
.L1350:
    .string "rt.o"
.L1351:
    .string "-o"
.L1352:
    .string "-lpthread"
.L1354:
    .string ".bin"
.L1356:
    .string "cc"
.L1358:
    .string "cc"
.L1374:
    .string "ZYL_SCHED"
.L1375:
    .string "ZYL_SCHED_CHAOS"
.L1376:
    .string "deterministic"
.L1392:
    .string "PANIC: E_DEADLOCK: every live actor is blocked on a channel or a join\n"
.L1401:
    .string "E_CHANNEL_CAPACITY: a channel buffer holds 1 to 16777216 values"
.L1402:
    .string "E_OUT_OF_MEMORY: no memory for a channel"
.L1407:
    .string "E_CHANNEL_NOT_OWNER: this actor does not own the channel endpoint"
.L1410:
    .string "E_CHANNEL_CLOSED: the channel's sender finished and every value was received"
.L1413:
    .string "E_OUT_OF_MEMORY: no memory for a channel"
.L1434:
    .string "E_ACTOR_LIMIT: at most 1024 actors per program"
.L1435:
    .string "E_OUT_OF_MEMORY: no thread for an actor"
.L1438:
    .string "error"
.L1439:
    .string "error"
.L1446:
    .string "PANIC: "
.L1447:
    .string "\n"
.L1481:
    .string "E_OUT_OF_MEMORY: no memory for an FFI worker"
.L1484:
    .string "E_OUT_OF_MEMORY: no memory for an FFI worker"
.L1485:
    .string "E_OUT_OF_MEMORY: no memory for an FFI worker"
.L1487:
    .string "E_FFI_TIMEOUT: could not start the FFI worker thread"
.L1493:
    .string "?"
.L1494:
    .string "E_FFI_SYMBOL_NOT_FOUND: no such FFI symbol: "
.L1495:
    .string "E_ARITY_MISMATCH: ffi-call passes more than 16 arguments"
.L1497:
    .string "E_FFI_TIMEOUT: ffi call `"
.L1498:
    .string "` exceeded its timeout of "
.L1499:
    .string " ms"
.L1522:
    .string "out of memory allocating a try frame"
.L1531:
    .string "FAIL\n"
.L1532:
    .string "FAIL: "
.L1533:
    .string "\n"
.L1542:
    .string "\ntest result: "
.L1543:
    .string " passed, "
.L1544:
    .string " failed, "
.L1545:
    .string " total\n"
.L1546:
    .string "test: "
.L1547:
    .string " ... "
.L1548:
    .string "ok\n"
.L1550:
    .string "error"
.L1552:
    .string "assertion failed"
.L1553:
    .string "PANIC: "
.L1554:
    .string "\n"
.L1556:
    .string "\n"
.L1557:
    .string "error["
.L1558:
    .string ""
.L1559:
    .string ""
.L1561:
    .string "{\"severity\":\"error\",\"code\":"
.L1562:
    .string ",\"message\":"
.L1563:
    .string ",\"file\":\"\",\"line\":0,\"column\":0,\"labels\":[],\"help\":\"\"}\n"
.L1568:
    .string "error["
.L1572:
    .string "error\n"
.L1573:
    .string "error: "
.L1574:
    .string "\n"
.L1581:
    .string ""
.L1582:
    .string "\n"
.L1586:
    .string ""
.L1588:
    .string ""
.L1589:
    .string "\"\""
.L1593:
    .string "\\u00"
.L1597:
    .string "(null)"
.L1600:
    .string "test: "
.L1601:
    .string " ... "
.L1603:
    .string "FAIL\n"
.L1604:
    .string "ok\n"
.L1606:
    .string "FAIL: "
.L1607:
    .string "\n"
.L1610:
    .string "\ntest result: "
.L1611:
    .string " passed, "
.L1612:
    .string " failed, "
.L1613:
    .string " total\n"
.L1616:
    .string ""
.L1617:
    .string ""
.bss
.p2align 6
zyl_rtg_cpu_avx2:
    .zero 8
.p2align 6
zyl_rtg_empty:
    .zero 64
.p2align 6
zyl_rtg_budget:
    .zero 24
.p2align 6
zyl_rtg_heap_cls:
    .zero 384
.p2align 6
zyl_rtg_threads_started:
    .zero 8
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
zyl_rtg_tls_info:
    .zero 32
.p2align 6
zyl_rtg_freestanding:
    .zero 8
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
zyl_rtg_names_lock:
    .zero 8
.p2align 6
zyl_rtg_fresh_id:
    .zero 8
.p2align 6
zyl_rtg_arenas:
    .zero 24
.p2align 6
zyl_rtg_region_live:
    .zero 8
.p2align 6
zyl_rtg_fmt_tab:
    .zero 10608
.p2align 6
zyl_rtg_out_state:
    .zero 32
.p2align 6
zyl_rtg_out_buf:
    .zero 8192
.p2align 6
zyl_rtg_actor_out:
    .zero 24624
.p2align 6
zyl_rtg_actor_err:
    .zero 24624
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
zyl_rtg_ffitab_slots:
    .zero 16384
.p2align 6
zyl_rtg_ffitab_state:
    .zero 8
.p2align 6
zyl_rtg_start_once:
    .zero 8
.p2align 6
zyl_rtg_chan_sched:
    .zero 56
.p2align 6
zyl_rtg_chan_owners:
    .zero 32832
.p2align 6
zyl_rtg_chan_reg:
    .zero 24
.p2align 6
zyl_rtg_actor_sys:
    .zero 24
.p2align 6
zyl_rtg_actor_slots:
    .zero 32768
.p2align 6
zyl_rtg_ffi_any_abandoned:
    .zero 8
.p2align 6
zyl_rtg_test_state:
    .zero 96
.p2align 6
zyl_rtg_tests:
    .zero 34816
.p2align 6
zyl_rtg_test_msg:
    .zero 8
.p2align 6
zyl_rtg_diag_json:
    .zero 8
.p2align 6
zyl_rtg_warn:
    .zero 32
.p2align 6
zyl_rtg_cells:
    .zero 128
.p2align 6
zyl_rtg_rt_envp:
    .zero 8
.p2align 6
zyl_rtg_rt_exit_reg:
    .zero 272
.p2align 6
zyl_rtg_cpu_sse42:
    .zero 8
.p2align 6
zyl_rtg_crc32c_tab:
    .zero 2048
.p2align 6
zyl_rtg_crc32c_tab_ok:
    .zero 8
.section .tbss,"awT",@nobits
.p2align 6
zyl_rtt_sysinfo:
    .zero 128
.p2align 6
zyl_rtt_cond_now:
    .zero 32
.p2align 6
zyl_rtt_rpool:
    .zero 32
.p2align 6
zyl_rtt_timespec:
    .zero 16
.p2align 6
zyl_rtt_fmt_dec:
    .zero 832
.p2align 6
zyl_rtt_fmt_big:
    .zero 384
.p2align 6
zyl_rtt_out_stat:
    .zero 144
.p2align 6
zyl_rtt_out_tios:
    .zero 64
.p2align 6
zyl_rtt_owner_id:
    .zero 8
.p2align 6
zyl_rtt_out_int:
    .zero 32
.p2align 6
zyl_rtt_out_frame:
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
zyl_rtt_aes:
    .zero 288
.p2align 6
zyl_rtt_rand:
    .zero 256
.p2align 6
zyl_rtt_proc_scratch:
    .zero 592
.p2align 6
zyl_rtt_proc_rand:
    .zero 8
.p2align 6
zyl_rtt_proc_stat:
    .zero 144
.p2align 6
zyl_rtt_start_rlimit:
    .zero 16
.p2align 6
zyl_rtt_start_guard:
    .zero 8
.p2align 6
zyl_rtt_chan_ts:
    .zero 16
.p2align 6
zyl_rtt_chan_moves:
    .zero 8
.p2align 6
zyl_rtt_try_top:
    .zero 8
.p2align 6
zyl_rtt_ffi_worker:
    .zero 8
.p2align 6
zyl_rtt_ffi_on_worker:
    .zero 8
.p2align 6
zyl_rtt_ffi_args:
    .zero 128
.p2align 6
zyl_rtt_ffi_tid:
    .zero 8
.p2align 6
zyl_rtt_ffi_ts:
    .zero 16
.p2align 6
zyl_rtt_ffi_in:
    .zero 128
.p2align 6
zyl_rtt_io_rl:
    .zero 24
.globl zyl_cur_region
.p2align 3
zyl_cur_region:
    .zero 8
.globl zyl_region_top
.p2align 3
zyl_region_top:
    .zero 8
.text
zyl_rt_sys_1:
    mov r10, rcx
    mov eax, 1
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
zyl_rt_sys_202:
    mov r10, rcx
    mov eax, 202
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
zyl_rt_sys_228:
    mov r10, rcx
    mov eax, 228
    syscall
    ret
zyl_rt_sys_158:
    mov r10, rcx
    mov eax, 158
    syscall
    ret
zyl_rt_sys_10:
    mov r10, rcx
    mov eax, 10
    syscall
    ret
zyl_rt_sys_60:
    mov r10, rcx
    mov eax, 60
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
zyl_rt_sys_8:
    mov r10, rcx
    mov eax, 8
    syscall
    ret
zyl_rt_sys_87:
    mov r10, rcx
    mov eax, 87
    syscall
    ret
zyl_rt_sys_24:
    mov r10, rcx
    mov eax, 24
    syscall
    ret
zyl_rt_sys_5:
    mov r10, rcx
    mov eax, 5
    syscall
    ret
zyl_rt_sys_16:
    mov r10, rcx
    mov eax, 16
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
zyl_rt_sys_61:
    mov r10, rcx
    mov eax, 61
    syscall
    ret
zyl_rt_sys_56:
    mov r10, rcx
    mov eax, 56
    syscall
    ret
zyl_rt_sys_59:
    mov r10, rcx
    mov eax, 59
    syscall
    ret
zyl_rt_sys_257:
    mov r10, rcx
    mov eax, 257
    syscall
    ret
zyl_rt_sys_33:
    mov r10, rcx
    mov eax, 33
    syscall
    ret
zyl_rt_sys_90:
    mov r10, rcx
    mov eax, 90
    syscall
    ret
zyl_rt_sys_97:
    mov r10, rcx
    mov eax, 97
    syscall
    ret
zyl_rt_sys_160:
    mov r10, rcx
    mov eax, 160
    syscall
    ret
zyl_rt_sys_35:
    mov r10, rcx
    mov eax, 35
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
zyl_rt_call8:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    mov r11, [rsp+24]
    mov [rsp+16], r11
    jmp rax
zyl_rt_call9:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    mov r11, [rsp+24]
    mov [rsp+16], r11
    mov r11, [rsp+32]
    mov [rsp+24], r11
    jmp rax
zyl_rt_call10:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    mov r11, [rsp+24]
    mov [rsp+16], r11
    mov r11, [rsp+32]
    mov [rsp+24], r11
    mov r11, [rsp+40]
    mov [rsp+32], r11
    jmp rax
zyl_rt_call11:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    mov r11, [rsp+24]
    mov [rsp+16], r11
    mov r11, [rsp+32]
    mov [rsp+24], r11
    mov r11, [rsp+40]
    mov [rsp+32], r11
    mov r11, [rsp+48]
    mov [rsp+40], r11
    jmp rax
zyl_rt_call12:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    mov r11, [rsp+24]
    mov [rsp+16], r11
    mov r11, [rsp+32]
    mov [rsp+24], r11
    mov r11, [rsp+40]
    mov [rsp+32], r11
    mov r11, [rsp+48]
    mov [rsp+40], r11
    mov r11, [rsp+56]
    mov [rsp+48], r11
    jmp rax
zyl_rt_call13:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    mov r11, [rsp+24]
    mov [rsp+16], r11
    mov r11, [rsp+32]
    mov [rsp+24], r11
    mov r11, [rsp+40]
    mov [rsp+32], r11
    mov r11, [rsp+48]
    mov [rsp+40], r11
    mov r11, [rsp+56]
    mov [rsp+48], r11
    mov r11, [rsp+64]
    mov [rsp+56], r11
    jmp rax
zyl_rt_call14:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    mov r11, [rsp+24]
    mov [rsp+16], r11
    mov r11, [rsp+32]
    mov [rsp+24], r11
    mov r11, [rsp+40]
    mov [rsp+32], r11
    mov r11, [rsp+48]
    mov [rsp+40], r11
    mov r11, [rsp+56]
    mov [rsp+48], r11
    mov r11, [rsp+64]
    mov [rsp+56], r11
    mov r11, [rsp+72]
    mov [rsp+64], r11
    jmp rax
zyl_rt_call15:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    mov r11, [rsp+24]
    mov [rsp+16], r11
    mov r11, [rsp+32]
    mov [rsp+24], r11
    mov r11, [rsp+40]
    mov [rsp+32], r11
    mov r11, [rsp+48]
    mov [rsp+40], r11
    mov r11, [rsp+56]
    mov [rsp+48], r11
    mov r11, [rsp+64]
    mov [rsp+56], r11
    mov r11, [rsp+72]
    mov [rsp+64], r11
    mov r11, [rsp+80]
    mov [rsp+72], r11
    jmp rax
zyl_rt_call16:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, [rsp+8]
    mov r11, [rsp+16]
    mov [rsp+8], r11
    mov r11, [rsp+24]
    mov [rsp+16], r11
    mov r11, [rsp+32]
    mov [rsp+24], r11
    mov r11, [rsp+40]
    mov [rsp+32], r11
    mov r11, [rsp+48]
    mov [rsp+40], r11
    mov r11, [rsp+56]
    mov [rsp+48], r11
    mov r11, [rsp+64]
    mov [rsp+56], r11
    mov r11, [rsp+72]
    mov [rsp+64], r11
    mov r11, [rsp+80]
    mov [rsp+72], r11
    mov r11, [rsp+88]
    mov [rsp+80], r11
    jmp rax
.globl zyl_rt_setjmp
zyl_rt_setjmp:
    mov [rdi], rbx
    mov rax, rbp
    xor rax, qword ptr [rip+zyl_ptr_guard]
    rol rax, 17
    mov [rdi+8], rax
    mov [rdi+16], r12
    mov [rdi+24], r13
    mov [rdi+32], r14
    mov [rdi+40], r15
    lea rax, [rsp+8]
    xor rax, qword ptr [rip+zyl_ptr_guard]
    rol rax, 17
    mov [rdi+48], rax
    mov rax, [rsp]
    xor rax, qword ptr [rip+zyl_ptr_guard]
    rol rax, 17
    mov [rdi+56], rax
    xor eax, eax
    ret
zyl_rt_longjmp:
    mov rax, rsi
    mov edx, 1
    test rax, rax
    cmove rax, rdx
    mov rbx, [rdi]
    mov rbp, [rdi+8]
    ror rbp, 17
    xor rbp, qword ptr [rip+zyl_ptr_guard]
    mov r12, [rdi+16]
    mov r13, [rdi+24]
    mov r14, [rdi+32]
    mov r15, [rdi+40]
    mov rdx, [rdi+48]
    ror rdx, 17
    xor rdx, qword ptr [rip+zyl_ptr_guard]
    mov rcx, [rdi+56]
    ror rcx, 17
    xor rcx, qword ptr [rip+zyl_ptr_guard]
    mov rsp, rdx
    jmp rcx
zyl_rt_try_call:
    mov [rdi], rbx
    mov rax, rbp
    xor rax, qword ptr [rip+zyl_ptr_guard]
    rol rax, 17
    mov [rdi+8], rax
    mov [rdi+16], r12
    mov [rdi+24], r13
    mov [rdi+32], r14
    mov [rdi+40], r15
    mov rax, rsp
    xor rax, qword ptr [rip+zyl_ptr_guard]
    rol rax, 17
    mov [rdi+48], rax
    lea rax, [rip+.Lzyl_rt_try_land]
    xor rax, qword ptr [rip+zyl_ptr_guard]
    rol rax, 17
    mov [rdi+56], rax
    push rbp
    mov rbp, rsp
    push rdi
    and rsp, -16
    call rsi
    mov rdi, [rbp-8]
    mov [rdi+64], rax
    mov rsp, rbp
    pop rbp
    xor eax, eax
    ret
.Lzyl_rt_try_land:
    mov eax, 1
    ret
.globl zyl_rt_guard_set
zyl_rt_guard_set:
    mov qword ptr [rip+zyl_ptr_guard], rdi
    ret
.bss
.globl zyl_ptr_guard
.p2align 3
zyl_ptr_guard:
    .zero 8
.text
.globl zyl_rt_clone
zyl_rt_clone:
    mov r10, rcx
    mov eax, 56
    syscall
    test rax, rax
    jnz .Lzyl_rt_clone_parent
    xor ebp, ebp
    pop rax
    pop rdi
    call rax
    mov edi, eax
    mov eax, 60
    syscall
    ud2
.Lzyl_rt_clone_parent:
    ret
.weak pthread_attr_init
.weak pthread_attr_setstack
.weak pthread_create
.weak pthread_attr_destroy
.weak pthread_join
.weak pthread_exit
.weak pthread_detach
.weak malloc
.weak free
.weak dlsym
.weak __cxa_atexit
.weak fflush
.weak exit
