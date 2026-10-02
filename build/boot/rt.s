.file "rt.zyl"
.intel_syntax noprefix
.text
zy_local_x2Fmain_0__base__rt_x2Dwrite_x2Dfd:
    # frame 0
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
    # frame 0
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L1_3:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    shr r8, 3
    lea rax, [r8+8]
    pop rbp
    ret
.L1_2:
    mov rdx, rsi
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov rsi, rax
    shr rsi, 3
    mov rax, rsi
    pop rbp
    ret
.L1_1:
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dv
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dv:
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D32
.L3_3:
    lea rdi, [r12+16]
    mov rsi, rdi
    mov rdi, rbx
    pop r12
    pop rbx
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D16:
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 16
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
    # frame 32
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
    # frame 0
.L18_0:
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen
zy_local_x2Fmain_0__base__rt_x2Dcopy:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
.L19_3:
    mov rdx, rdi
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2Dbytes
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16:
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
    mov rdi, rdx
.L23_0:
    cmp rdi, 0
    jne .L23_1
.L23_2:
    mov rax, rbx
    pop rbx
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dmove:
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L29_0:
    call zyl_ralloc
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dcur_x2Dregion:
    # frame 0
.L30_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof:
    # frame 32
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
    # frame 0
    push rbp
    mov rbp, rsp
.L32_0:
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Davx2:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L33_1:
    mov rax, rsi
    cmp rax, 2
    sete al
    movzx rax, al
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Davx2_x2Dprobe:
    # frame 0
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
    # frame 0
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
    # frame 0
    push rbp
    mov rbp, rsp
.L36_0:
    call zyl_cpuid_features
    mov rsi, rax
    and rsi, 1
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    pop rbp
    ret
.globl zyl_cstr_len
zyl_cstr_len:
    # frame 0
    push rbp
    mov rbp, rsp
.L37_0:
    mov rsi, rdi
    cmp rsi, 4096
    jge .L37_1
    cmp rsi, 0
    jne .L37_2
    mov rax, 0
    pop rbp
    ret
.L37_2:
    lea rax, [rip+.L38]
    mov r8, rax
    mov rdi, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
.L37_1:
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen
zy_local_x2Fmain_0__cstr__rt_x2Dbad_x2Dlen:
    # frame 0
    push rbp
    mov rbp, rsp
.L39_0:
    lea rax, [rip+.L40]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
.globl zyl_cstr_eq
zyl_cstr_eq:
    # frame 0
    push rbp
    mov rbp, rsp
.L41_0:
    cmp rdi, rsi
    jne .L41_1
    mov rax, 1
    pop rbp
    ret
.L41_1:
    cmp rdi, 4096
    jge .L41_2
    cmp rdi, 0
    jne .L41_3
    mov rax, 0
    pop rbp
    ret
.L41_3:
    lea rax, [rip+.L42]
    mov r8, rax
    mov rsi, r8
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L41_2:
    cmp rsi, 4096
    jge .L41_4
    cmp rsi, 0
    jne .L41_5
    mov rax, 0
    pop rbp
    ret
.L41_5:
    lea rax, [rip+.L43]
    mov r8, rax
    mov rdi, rsi
    mov rsi, r8
    pop rbp
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
    pop rbp
    ret
.globl zyl_cstr_cmp
zyl_cstr_cmp:
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L45_1:
    cmp r12, 4096
    jge .L45_2
    cmp r12, 0
    jne .L45_3
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L45_3:
    lea rax, [rip+.L46]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L45_2:
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    cmp rbx, rax
    jl .L45_4
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L45_4:
    lea rsi, [r12+rbx]
    movzx eax, byte ptr [rsi+0]
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__cstr__rt_x2Dbad_x2Dat:
    # frame 0
    push rbp
    mov rbp, rsp
.L47_0:
    lea rax, [rip+.L48]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, -1
    pop rbp
    ret
.globl zyl_cstr_key_matches
zyl_cstr_key_matches:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
.L49_7:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L49_6:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__cstr__rt_x2Dconcat:
    # frame 48
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
    # frame 48
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
    # frame 0
.L54_0:
    mov r8, 0
    mov rdx, r8
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dconcat
.globl zyl_cstr_concat_r
zyl_cstr_concat_r:
    # frame 0
.L55_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r8, rax
    mov rdx, r8
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dconcat
zy_local_x2Fmain_0__cstr__rt_x2Dsubstr:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.globl zyl_cstr_substr
zyl_cstr_substr:
    # frame 0
    mov r8, rdx
.L58_0:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dsubstr
.globl zyl_cstr_substr_r
zyl_cstr_substr_r:
    # frame 0
    mov r8, rdx
.L59_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r9, rax
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dsubstr
zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte:
    # frame 16
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
    # frame 0
.L61_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte
.globl zyl_cstr_from_byte_r
zyl_cstr_from_byte_r:
    # frame 0
.L62_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte
.globl zyl_view_ok
zyl_view_ok:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
.L63_5:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_view_byte
zyl_view_byte:
    # frame 0
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
    # frame 0
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
    # frame 48
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
    # frame 0
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
    # frame 32
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
    # frame 0
    mov r8, rdx
.L70_0:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dcopy
.globl zyl_view_copy_r
zyl_view_copy_r:
    # frame 0
    mov r8, rdx
.L71_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r9, rax
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dcopy
zy_local_x2Fmain_0__cstr__rt_x2Dlast_x2Dslash:
    # frame 0
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
    # frame 32
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
    # frame 0
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
    # frame 0
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
    # frame 0
.L76_0:
    lea rax, [rip+.L77]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits:
    # frame 16
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
    # frame 16
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
    # frame 48
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
    # frame 0
.L87_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
.globl zyl_int_text_r
zyl_int_text_r:
    # frame 0
.L88_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
zy_local_x2Fmain_0__text__rt_x2Darena_x2Dstr:
    # frame 0
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
    # frame 32
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
    # frame 32
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
    # frame 0
.L93_0:
    mov rax, -9223372036854775808
    ret
zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dof:
    # frame 0
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
    # frame 0
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
    # frame 16
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
    # frame 0
    push rbp
    mov rbp, rsp
.L97_0:
    cmp rdi, 0
    jne .L97_1
    mov rax, 0
    pop rbp
    ret
.L97_1:
    cmp rdi, 4096
    jge .L97_2
    lea rax, [rip+.L98]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
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
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop
.L97_3:
    mov rsi, 0
    mov r8, 0
    mov rdx, r8
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop
zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dbase_x2Dloop:
    # frame 32
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
    pop rbp
    ret
.L99_3:
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dbase_x2Dof:
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L101_0:
    cmp rdi, 0
    jne .L101_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
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
    pop rbp
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
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dbase_x2Dloop
zy_local_x2Fmain_0__text__rt_x2Dident_x2Dbyte:
    # frame 0
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
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    # frame 32
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
    # frame 0
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
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L109_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L109_1:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Ddecode_x2Dloop:
    # frame 64
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
    # frame 32
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
    # frame 16
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
    # frame 0
    push rbp
    mov rbp, rsp
.L114_0:
    cmp rdi, 0
    jne .L114_1
    mov rax, 0
    pop rbp
    ret
.L114_1:
    cmp rdi, 4096
    jge .L114_2
    lea rax, [rip+.L115]
    mov r8, rax
    mov rsi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
.L114_2:
    mov r8, 0
    mov r9, 0
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dcount_x2Dnl
zy_local_x2Fmain_0__text__rt_x2Dlast_x2Dnl:
    # frame 0
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
    # frame 0
    push rbp
    mov rbp, rsp
.L117_0:
    cmp rdi, 0
    jne .L117_1
    mov rax, -1
    pop rbp
    ret
.L117_1:
    cmp rdi, 4096
    jge .L117_2
    lea rax, [rip+.L118]
    mov r8, rax
    mov rsi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, -1
    pop rbp
    ret
.L117_2:
    sub rsi, 1
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dlast_x2Dnl
zy_local_x2Fmain_0__text__rt_x2Descapes_x2Dloop:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
.L119_2:
    add r12, 1
    cmp r12, r13
    jl .L119_1
    jmp .L119_6
.globl zyl_cstr_escapes_ok
zyl_cstr_escapes_ok:
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
.L125_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__rt_x2Dparse_x2Du:
    # frame 0
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
    # frame 0
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
    # frame 0
    push rbp
    mov rbp, rsp
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
    pop rbp
    jmp zy_local_x2Fmain_0__heap__rt_x2Dparse_x2Du
zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Dfield:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L129_1:
    lea rdi, [rbx+rsi]
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__heap__rt_x2Dstrtoull
zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Dfind:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L130_2:
    add r15, 1
    jmp .L130_0
zy_local_x2Fmain_0__heap__rt_x2Dread_x2Dall:
    # frame 32
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
    # frame 32
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
    # frame 16
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
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L139_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rbx, rax
    mov rax, qword ptr [rbx+0]
    cmp rax, 2
    jne .L139_1
    mov rax, 0
    pop rbx
    pop rbp
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
    pop rbp
    ret
.L139_2:
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Dwait
zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Dwait:
    # frame 0
.L140_0:
    mov rax, qword ptr [rdi+0]
    cmp rax, 2
    jne .L140_1
    mov rax, 0
    ret
.L140_1:
    jmp .L140_0
zy_local_x2Fmain_0__heap__rt_x2Dcharge:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L141_1:
    mov rax, 1
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__heap__rt_x2Drefund:
    # frame 0
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
    # frame 0
.L143_0:
    mov rax, 23130
    ret
zy_local_x2Fmain_0__heap__hp_x2Dbig:
    # frame 0
.L144_0:
    mov rax, 255
    ret
zy_local_x2Fmain_0__heap__hp_x2Dlimit:
    # frame 0
.L145_0:
    mov rax, 281474976710656
    ret
zy_local_x2Fmain_0__heap__hp_x2Dcls:
    # frame 0
.L146_0:
    lea rax, [rip+zyl_rtg_heap_cls]
    mov rsi, rax
    shl rdi, 5
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__hp_x2Dthreaded:
    # frame 0
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
    # frame 0
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
    # frame 16
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
    mov r8, rdx
.L154_0:
    mov qword ptr [rdi+0], rsi
    mov qword ptr [rdi+8], r8
    lea rax, [rdi+16]
    ret
zy_local_x2Fmain_0__heap__hp_x2Dtake:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__heap__hp_x2Dalloc:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    jmp zy_local_x2Fmain_0__heap__hp_x2Dhead
zy_local_x2Fmain_0__heap__hp_x2Dvalid:
    # frame 0
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
    # frame 0
.L158_0:
    mov rsi, 1
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
zy_local_x2Fmain_0__heap__rt_x2Draw_x2Dmalloc:
    # frame 0
.L159_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
.globl zyl_rt_free
zyl_rt_free:
    # frame 32
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
.globl zyl_rt_realloc
zyl_rt_realloc:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__heap__rt_x2Dstrdup:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dld32s:
    # frame 0
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
    # frame 0
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
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L166_0:
    call zyl_int_text
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dgrow:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Drehash:
    # frame 64
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
    # frame 0
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
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L170_4:
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dprobe:
    # frame 0
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
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L172_3:
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dspans:
    # frame 0
.L173_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_span_set
zyl_span_set:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
.globl zyl_span_off
zyl_span_off:
    # frame 0
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L175_1:
    lea rdi, [rsi+8]
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dld32s
.globl zyl_span_file
zyl_span_file:
    # frame 0
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L176_1:
    lea rdi, [rsi+12]
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dld32s
.globl zyl_span_copy
zyl_span_copy:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    jmp zyl_span_set
zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab:
    # frame 0
.L178_0:
    lea rax, [rip+zyl_rtg_attrs]
    mov rsi, rax
    imul rdi, rdi, 24
    add rsi, rdi
    mov rax, rsi
    ret
.globl zyl_attr_set
zyl_attr_set:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L179_4:
    mov qword ptr [rsi+8], r12
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_attr_get
zyl_attr_get:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L180_3:
    mov rax, qword ptr [rsi+8]
    pop rbx
    pop rbp
    ret
.globl zyl_attr_clear
zyl_attr_clear:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L181_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L181_3
    mov rax, 0
    pop rbx
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dzero:
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L183_1:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_attr_set
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn
zy_local_x2Fmain_0__ctab__rt_x2Dstr_x2Dhash_x2Dn:
    # frame 0
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
    # frame 0
.L186_0:
    mov rdi, 1
    mov rsi, 24
    jmp zyl_rt_calloc
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dgrow:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Drehash:
    # frame 48
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
    # frame 0
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
    # frame 48
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
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L191_4:
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_smap_put
zyl_smap_put:
    # frame 48
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
    # frame 0
    push rbp
    mov rbp, rsp
.L193_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L193_1
    mov rax, 0
    pop rbp
    ret
.L193_1:
    mov rax, qword ptr [rsi+8]
    pop rbp
    ret
.globl zyl_smap_has
zyl_smap_has:
    # frame 0
    push rbp
    mov rbp, rsp
.L194_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    cmp rax, 0
    jne .L194_1
    mov rax, 0
    pop rbp
    ret
.L194_1:
    mov rax, 1
    pop rbp
    ret
.globl zyl_smap_get_or
zyl_smap_get_or:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdx
.L195_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L195_1
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L195_1:
    mov rax, qword ptr [rsi+8]
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dfree_x2Dkeys:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.globl zyl_wvec_new
zyl_wvec_new:
    # frame 0
.L198_0:
    mov rdi, 1
    mov rsi, 24
    jmp zyl_rt_calloc
.globl zyl_wvec_push
zyl_wvec_push:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L199_7:
    mov rax, -1
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_wvec_get
zyl_wvec_get:
    # frame 32
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L208_3:
    mov rax, qword ptr [rbx+0]
    pop rbx
    pop rbp
    ret
.globl zyl_wvec_global
zyl_wvec_global:
    # frame 0
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
    # frame 0
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
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcache_x2Dcell:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L212_1:
    mov qword ptr [rsi+8], rbx
    mov rsi, rbx
    mov rax, rsi
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell:
    # frame 0
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
    # frame 0
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L214_0:
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell
    mov rsi, rax
    cmp rsi, 0
    jne .L214_1
    mov rax, 0
    pop rbp
    ret
.L214_1:
    mov rax, qword ptr [rsi+0]
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dready:
    # frame 0
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L215_0:
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell
    cmp rax, 0
    jne .L215_1
    mov rax, 0
    pop rbp
    ret
.L215_1:
    mov rax, 1
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dput:
    # frame 32
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Ddefs:
    # frame 0
.L218_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ctab__rt_x2Didefs:
    # frame 0
.L219_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ctab__rt_x2Drepl_x2Ddefs:
    # frame 0
.L220_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_global_clear
zyl_global_clear:
    # frame 0
.L221_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear
.globl zyl_global_ready
zyl_global_ready:
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
.L225_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear
.globl zyl_iglobal_ready
zyl_iglobal_ready:
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.globl zyl_repl_global_get
zyl_repl_global_get:
    # frame 0
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
    # frame 16
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
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L235_4:
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L235_3:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dprefix_x2Deq:
    # frame 0
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
    # frame 0
.L237_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dcount:
    # frame 0
.L238_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rax, qword ptr [rsi+6144]
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc:
    # frame 0
.L239_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    imul rdi, rdi, 24
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dfind:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L240_2:
    add r12, 1
    cmp r12, r13
    jl .L240_1
    jmp .L240_3
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dset_x2Dtext:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.globl zyl_source_register
zyl_source_register:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok:
    # frame 0
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
    # frame 0
    push rbp
    mov rbp, rsp
.L247_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    jne .L247_1
    lea rax, [rip+.L248]
    mov rdi, rax
    mov rax, rdi
    pop rbp
    ret
.L247_1:
    mov rax, qword ptr [rsi+0]
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L249_3:
    mov rax, rsi
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dcount_x2Dlines:
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L251_1:
    mov rdi, qword ptr [rsi+8]
    mov rsi, 0
    mov r8, 1
    mov rdx, rbx
    mov rcx, r8
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__source__rt_x2Dcount_x2Dlines
zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart:
    # frame 0
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
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dmcopy:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.globl zyl_span_line_text
zyl_span_line_text:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    jmp zy_local_x2Fmain_0__source__rt_x2Dmcopy
zy_local_x2Fmain_0__source__rt_x2Dsnip:
    # frame 32
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    jmp zy_local_x2Fmain_0__source__rt_x2Dmcopy
.L262_1:
    cmp rdi, 1
    jne .L262_2
    lea rax, [rip+.L263]
    mov rsi, rax
    mov rax, rsi
    pop rbx
    pop rbp
    ret
.L262_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.globl zyl_span_snippet_col
zyl_span_snippet_col:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L264_1:
    cmp rdi, 1
    jne .L264_4
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L264_4:
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dskip_x2Dlines:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L265_2:
    lea rsi, [rdi+1]
    add r12, 1
    cmp r12, r13
    jl .L265_1
    jmp .L265_3
.globl zyl_span_offset_at
zyl_span_offset_at:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L266_1:
    mov rdi, qword ptr [rsi+8]
    cmp rdi, 0
    jne .L266_4
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
.L266_6:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__thread__rt_x2Dfutex_x2Dwait:
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 16
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
    # frame 0
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
    # frame 32
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
    # frame 0
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
    # frame 0
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
    # frame 48
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
    # frame 0
.L276_0:
    lea rax, [rip+zyl_rtg_tls_info]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__thread__rt_x2Dfreestanding:
    # frame 0
.L277_0:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_rt_hosted_p
zyl_rt_hosted_p:
    # frame 0
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
    # frame 0
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
    # frame 0
.L280_0:
    lea r8, [rsi-1]
    add rdi, r8
    mov r8, 0
    sub r8, rsi
    and rdi, r8
    mov rax, rdi
    ret
zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dnew:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dfree:
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 0
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
    # frame 48
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
    # frame 0
.L287_0:
    mov rax, 4001536
    ret
zy_local_x2Fmain_0__thread__rt_x2Dstack_x2Dnew:
    # frame 16
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
    # frame 32
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
    pop rbp
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
    pop rbp
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
    pop rbp
    jmp zy_local_x2Fmain_0__thread__rt_x2Dthread_x2Dclone
zy_local_x2Fmain_0__thread__rt_x2Dthread_x2Dclone:
    # frame 64
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
    # frame 48
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
    # frame 0
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
    # frame 16
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
    # frame 16
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
    # frame 0
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
    # frame 0
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
    # frame 0
.L297_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__interp__rt_x2Ditest_x2Dn:
    # frame 0
.L298_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    ret
.globl zyl_itest_add
zyl_itest_add:
    # frame 0
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
    # frame 0
.L300_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    ret
.globl zyl_itest_name
zyl_itest_name:
    # frame 0
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
    # frame 0
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
    # frame 0
.L303_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+65536], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap:
    # frame 0
.L304_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap_x2Dused:
    # frame 0
.L305_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, qword ptr [rsi+262144]
    ret
.globl zyl_fnmap_reset
zyl_fnmap_reset:
    # frame 0
    push rbp
    mov rbp, rsp
.L306_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rdi, rax
    mov rsi, 262152
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    mov rax, 0
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap_x2Dprobe:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L307_2:
    add r14, 1
    cmp r14, 16384
    jl .L307_1
    jmp .L307_4
.globl zyl_fnmap_put
zyl_fnmap_put:
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
.globl zyl_fnmap_get
zyl_fnmap_get:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L309_3:
    mov rax, qword ptr [rsi+8]
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dmagic:
    # frame 0
.L310_0:
    mov rax, 1514885700
    ret
.globl zyl_val_alloc
zyl_val_alloc:
    # frame 32
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
    # frame 16
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
.L313_1:
    call zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dword
    mov rsi, rax
    cmp rsi, 0
    jne .L313_3
    mov rax, 0
    pop rbx
    pop rbp
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
    pop rbp
    ret
.globl zyl_val_name
zyl_val_name:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L314_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dword
    cmp rax, 0
    jne .L314_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L314_1:
    lea rsi, [rbx-24]
    mov rax, qword ptr [rsi+0]
    pop rbx
    pop rbp
    ret
.globl zyl_val_arity
zyl_val_arity:
    # frame 16
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
    # frame 0
.L316_0:
    lea rax, [rip+zyl_rtg_names]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__interp__rt_x2Dnames_x2Dprobe:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
.L317_2:
    add r14, 1
    cmp r14, 4096
    jl .L317_1
    jmp .L317_4
.globl zyl_intern_name
zyl_intern_name:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dintern:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
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
    pop rbp
    ret
.globl zyl_fresh_id
zyl_fresh_id:
    # frame 0
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
    # frame 0
.L321_0:
    mov rax, rdi
    ret
.globl zyl_word_of_cstr
zyl_word_of_cstr:
    # frame 0
.L322_0:
    mov rax, rdi
    ret
.globl zyl_float_bits
zyl_float_bits:
    # frame 0
.L323_0:
    mov rax, rdi
    ret
.globl zyl_float_of_bits
zyl_float_of_bits:
    # frame 0
.L324_0:
    mov rax, rdi
    ret
.globl zyl_word_load
zyl_word_load:
    # frame 0
.L325_0:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_word_store
zyl_word_store:
    # frame 0
.L326_0:
    mov qword ptr [rdi+0], rsi
    mov rax, 0
    ret
.globl zyl_ptr_add
zyl_ptr_add:
    # frame 0
.L327_0:
    lea rax, [rdi+rsi]
    ret
.globl zyl_ptr_cstr
zyl_ptr_cstr:
    # frame 0
.L328_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dsize:
    # frame 0
.L329_0:
    mov rax, 2208
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dcompress:
    # frame 784
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
    # frame 0
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
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag:
    # frame 0
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
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dflush:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dzero64
zy_local_x2Fmain_0__blake3__b3_x2Dupdate:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    # frame 32
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
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
    # frame 64
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
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dfold
zy_local_x2Fmain_0__blake3__b3_x2Dnew:
    # frame 0
    push rbp
    mov rbp, rsp
.L340_0:
    mov rdi, 2208
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rdi, rax
    cmp rdi, 0
    jne .L340_1
    mov rax, 0
    pop rbp
    ret
.L340_1:
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dinit
zy_local_x2Fmain_0__blake3__rt_x2Dblake3_x2Draw:
    # frame 48
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dhexdigits:
    # frame 0
.L342_0:
    lea rax, [rip+.L343]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__blake3__rt_x2Dhex_x2Dbytes:
    # frame 16
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
    # frame 0
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
    # frame 32
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
    cmp rbx, 0
    jne .L347_1
    mov rdi, r12
    call zyl_rt_free
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L347_1:
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
.globl zyl_bytebuf_blake3_hex
zyl_bytebuf_blake3_hex:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov rdi, rdx
    mov r12, rcx
.L348_0:
    cmp rsi, 4096
    jl .L348_3
.L348_12:
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L348_1
.L348_3:
    mov r8, 0
    jmp .L348_2
.L348_1:
    mov r9, qword ptr [rsi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L348_4
    jmp .L348_5
.L348_4:
    mov rsi, 0
.L348_5:
    mov r8, rsi
.L348_2:
    mov r13, r8
    cmp r13, 0
    jne .L348_6
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L348_6:
    mov rsi, qword ptr [r13+24]
    cmp rdi, 0
    jge .L348_7
    mov r8, qword ptr [r13+16]
    jmp .L348_8
.L348_7:
    mov r8, rdi
.L348_8:
    mov r14, r8
    cmp r14, 0
    jl .L348_10
    cmp r14, rsi
    jle .L348_9
.L348_10:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L348_9:
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r15, rax
    cmp r15, 0
    jne .L348_11
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L348_11:
    mov rsi, qword ptr [r13+8]
    mov rdi, r15
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
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dhex_x2Dout
.globl zyl_blake3_hex
zyl_blake3_hex:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov rdi, rdx
    mov r12, rcx
.L349_0:
    mov r13, rsi
    cmp r13, 0
    jne .L349_1
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L349_1:
    cmp rdi, 0
    jge .L349_2
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    jmp .L349_3
.L349_2:
    mov rsi, rdi
.L349_3:
    mov r14, rsi
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r15, rax
    cmp r15, 0
    jne .L349_4
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L349_4:
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
    pop rbp
    jmp zy_local_x2Fmain_0__blake3__b3_x2Dhex_x2Dout
zy_local_x2Fmain_0__blake3__b3_x2Dread_x2Dall:
    # frame 32
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
.L350_0:
    mov rsi, 65536
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L350_1
    cmp rsi, 0
    jle .L350_2
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__blake3__b3_x2Dupdate
.L350_2:
    jmp .L350_0
.L350_1:
    cmp rsi, -4
    jne .L350_3
    jmp .L350_0
.L350_3:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_blake3_file_hex
zyl_blake3_file_hex:
    # frame 48
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
.L351_0:
    cmp rsi, 0
    jne .L351_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L351_1:
    mov rdi, 0
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_2
    mov r13, rax
    cmp r13, 0
    jge .L351_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L351_2:
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r14, rax
    mov rsi, 0
    cmp r14, 0
    je .L351_3
    mov rdi, 65536
    mov r8, 1
    mov rsi, r8
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
.L351_3:
    mov r15, rsi
    cmp r15, 0
    jne .L351_4
    cmp r14, 0
    je .L351_5
    mov rdi, r14
    call zyl_rt_free
.L351_5:
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
.L351_4:
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
    # frame 0
.L352_0:
    lea rax, [rip+.L353]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__mangle__mg_x2Dwidths:
    # frame 0
.L354_0:
    lea rax, [rip+.L355]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__mangle__mg_x2Desc_x2Dlen:
    # frame 16
    push rbx
    mov r8, rdx
    mov r9, rcx
.L356_0:
    cmp rsi, r8
    jl .L356_1
.L356_2:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L356_1:
    lea r10, [rsi+1]
    lea rax, [rip+.L357]
    mov r11, rax
    lea rbx, [rdi+rsi]
    movzx ebx, byte ptr [rbx+0]
    add r11, rbx
    movzx r11d, byte ptr [r11+0]
    add r9, r11
    mov rsi, r10
    cmp rsi, r8
    jl .L356_1
    jmp .L356_2
zy_local_x2Fmain_0__mangle__mg_x2Desc:
    # frame 32
    push rbx
    push r12
    push r13
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L358_0:
    cmp rsi, r8
    jl .L358_1
.L358_4:
    mov rax, r10
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L358_1:
    lea r11, [rdi+rsi]
    movzx r11d, byte ptr [r11+0]
    lea rax, [rip+.L359]
    mov rbx, rax
    add rbx, r11
    movzx ebx, byte ptr [rbx+0]
    cmp rbx, 1
    jne .L358_2
    lea r12, [r9+r10]
    mov byte ptr [r12+0], r11b
    add rsi, 1
    add r10, 1
    cmp rsi, r8
    jl .L358_1
    jmp .L358_4
.L358_2:
    cmp rbx, 3
    jne .L358_3
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
    jl .L358_1
    jmp .L358_4
.L358_3:
    lea rax, [rip+.L360]
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
    jl .L358_1
    jmp .L358_4
.globl zyl_sym_escape
zyl_sym_escape:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L361_0:
    mov r12, rsi
    cmp r12, 0
    jne .L361_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L361_1:
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
    # frame 0
    mov r8, rdx
.L362_0:
    lea rax, [rsi+1]
    cmp rax, r8
    jl .L362_1
    mov rax, -1
    ret
.L362_1:
    lea r9, [rdi+rsi]
    movzx eax, byte ptr [r9+0]
    cmp rax, 58
    jne .L362_2
    lea r9, [rsi+1]
    add r9, rdi
    movzx eax, byte ptr [r9+0]
    cmp rax, 58
    jne .L362_2
    mov rax, rsi
    ret
.L362_2:
    add rsi, 1
    jmp .L362_0
zy_local_x2Fmain_0__mangle__mg_x2Dwrite:
    # frame 280
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
    # frame 280
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
    jg .L363
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
    jmp .L364
.L363:
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
    jne .L365
    mov rax, 0
    jmp .L366
.L365:
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
    je .L369
    mov rax, 0
    jmp .L370
.L369:
    mov rax, 1
.L370:
    test rax, rax
    je .L367
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-120]
call zyl_rt_free
    add rsp, 16
    mov [rbp-144], rax
    mov rax, 0
    jmp .L368
.L367:
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
.L368:
.L366:
.L364:
    mov rbx, [rbp-280]
    mov r12, [rbp-272]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mangle_key
zyl_mangle_key:
    # frame 184
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
    jne .L371
    mov rax, 0
    jmp .L372
.L371:
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
    jge .L373
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
    lea rax, [rip+.L375]
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
    jmp .L374
.L373:
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
    jge .L376
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
    lea rax, [rip+.L378]
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
    jmp .L377
.L376:
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
    jge .L379
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
    jmp .L380
.L379:
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
.L380:
.L377:
.L374:
.L372:
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dutext:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L381_0:
    call zyl_int_text
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Doom:
    # frame 0
.L382_0:
    jmp zyl_arena_oom
.globl zyl_arena_oom
zyl_arena_oom:
    # frame 64
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
.L383_0:
    lea rax, [rip+zyl_rtg_budget]
    mov r12, rax
    lea rax, [rip+.L384]
    mov qword ptr [rbp-48], rax
    lea rax, [rip+.L385]
    mov qword ptr [rbp-64], rax
    call zyl_int_text
    mov r15, rax
    lea rax, [rip+.L386]
    mov r13, rax
    mov rdi, qword ptr [r12+16]
    call zyl_int_text
    mov rbx, rax
    lea rax, [rip+.L387]
    mov r14, rax
    mov rdi, qword ptr [r12+8]
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L388]
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
    # frame 0
.L389_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_threads_started_mark
zyl_threads_started_mark:
    # frame 0
.L390_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dalign16:
    # frame 0
.L391_0:
    lea rsi, [rdi+15]
    and rsi, -16
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dnew_x2Dblock:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L392_0:
    mov rax, qword ptr [rbx+8]
    cmp rsi, rax
    jge .L392_1
    mov rdi, qword ptr [rbx+8]
    jmp .L392_2
.L392_1:
    mov rdi, rsi
.L392_2:
    mov r12, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    je .L392_3
    jmp .L392_4
.L392_3:
    lea rax, [rip+.L393]
    mov rsi, rax
    mov rdi, r12
    call zyl_arena_oom
.L392_4:
    mov rdi, 32
    mov rsi, 0
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L392_5
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    mov rdi, 32
    lea rax, [rip+.L394]
    mov rsi, rax
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_arena_oom
.L392_5:
    mov rsi, 0
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L392_6
    mov rdi, r13
    call zyl_rt_free
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    lea rax, [rip+.L395]
    mov rdi, rax
    mov rsi, rdi
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_arena_oom
.L392_6:
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
    pop rbp
    ret
.globl zyl_arena_create
zyl_arena_create:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L396_0:
    mov rsi, 65536
    cmp rdi, 16
    jl .L396_1
    mov rsi, rdi
.L396_1:
    mov rbx, rsi
    mov rdi, 72
    mov rsi, 0
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L396_2
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L396_2:
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
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L397_0:
    cmp rbx, 0
    je .L397_2
.L397_11:
    cmp rsi, 0
    jl .L397_3
    mov rax, 281474976710656
    cmp rsi, rax
    jle .L397_1
.L397_3:
.L397_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L397_1:
    lea r12, [rsi+15]
    and r12, -16
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L397_4
    jmp .L397_5
.L397_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_lock
.L397_5:
    mov rsi, qword ptr [rbx+0]
    cmp rsi, 0
    je .L397_8
    mov rdi, qword ptr [rsi+8]
    mov r8, qword ptr [rsi+16]
    sub rdi, r8
    cmp r12, rdi
    jle .L397_6
.L397_8:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dnew_x2Dblock
    mov rdi, rax
    jmp .L397_7
.L397_6:
    mov rdi, rsi
.L397_7:
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
    jne .L397_9
    jmp .L397_10
.L397_9:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L397_10:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_arena_alloc
zyl_arena_alloc:
    # frame 0
.L398_0:
    jmp zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
.globl zyl_arena_alloc_zeroed
zyl_arena_alloc_zeroed:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L399_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov r12, rax
    cmp r12, 0
    jne .L399_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L399_1:
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dfill0
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfill0:
    # frame 0
.L400_0:
    cmp rsi, 0
    jle .L400_1
.L400_2:
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
.L400_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfill_x2Dde:
    # frame 0
.L401_0:
    cmp rsi, 0
    jle .L401_1
.L401_2:
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
.L401_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L402_0:
    cmp rbx, 0
    jne .L402_1
.L402_4:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L402_1:
    mov r12, qword ptr [rbx+24]
    mov rsi, qword ptr [rbx+0]
    mov rdi, qword ptr [rbx+16]
    cmp rdi, 0
    jle .L402_2
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
    jmp .L402_3
.L402_2:
.L402_3:
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
    jne .L402_1
    jmp .L402_4
.globl zyl_arena_reset
zyl_arena_reset:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L403_0:
    cmp rbx, 0
    jne .L403_1
.L403_6:
    mov rax, 0
    pop rbx
    pop rbp
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
    jne .L403_4
    jmp .L403_5
.L403_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L403_5:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.globl zyl_arena_destroy
zyl_arena_destroy:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L404_0:
    cmp rbx, 0
    jne .L404_1
.L404_6:
    mov rax, 0
    pop rbx
    pop rbp
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
    mov rdi, qword ptr [rbx+0]
    call zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks
    mov rsi, 0
    mov qword ptr [rbx+0], rsi
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
    mov rax, 0
    pop rbx
    pop rbp
    ret
.globl zyl_arena_used
zyl_arena_used:
    # frame 16
    push rbp
    mov rbp, rsp
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
    pop rbp
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
    mov r12, qword ptr [rbx+24]
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
    pop rbp
    ret
.globl zyl_arena_capacity
zyl_arena_capacity:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L406_0:
    cmp rbx, 0
    jne .L406_1
.L406_6:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L406_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L406_2
    jmp .L406_3
.L406_2:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_lock
.L406_3:
    mov r12, qword ptr [rbx+16]
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L406_4
    jmp .L406_5
.L406_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L406_5:
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Din_x2Dblocks:
    # frame 0
.L407_0:
    cmp rdi, 0
    jne .L407_1
.L407_3:
    mov rax, 0
    ret
.p2align 4
.L407_1:
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jl .L407_2
    lea r8, [rsi+8]
    mov r9, qword ptr [rdi+0]
    mov r10, qword ptr [rdi+16]
    add r9, r10
    cmp r8, r9
    jg .L407_2
    mov rax, 1
    ret
.L407_2:
    mov rdi, qword ptr [rdi+24]
    cmp rdi, 0
    jne .L407_1
    jmp .L407_3
zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L408_0:
    cmp rbx, 0
    jne .L408_1
.L408_6:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L408_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L408_2
    jmp .L408_3
.L408_2:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_lock
.L408_3:
    mov rdi, qword ptr [rbx+0]
    mov rsi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Din_x2Dblocks
    mov r12, rax
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L408_4
    jmp .L408_5
.L408_4:
    lea rdi, [rbx+32]
    call zyl_rt_mutex_unlock
.L408_5:
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Darenas:
    # frame 0
.L409_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dheap:
    # frame 0
.L410_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dpin:
    # frame 0
.L411_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    ret
.globl zyl_arenas_init
zyl_arenas_init:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L412_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rbx, rax
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L412_1
    mov rdi, 1048576
    call zyl_arena_create
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    jmp .L412_2
.L412_1:
.L412_2:
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L412_3
    mov rdi, 262144
    call zyl_arena_create
    mov rsi, rax
    mov qword ptr [rbx+8], rsi
    jmp .L412_4
.L412_3:
.L412_4:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.globl zyl_arenas_destroy
zyl_arenas_destroy:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L413_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L413_1
    jmp .L413_2
.L413_1:
    mov rdi, qword ptr [rbx+8]
    call zyl_arena_destroy
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
.L413_2:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L413_3
    jmp .L413_4
.L413_3:
    mov rdi, qword ptr [rbx+0]
    call zyl_arena_destroy
    mov rsi, 0
    mov qword ptr [rbx+0], rsi
.L413_4:
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L414_0:
    mov rdi, rsi
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L415]
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L416_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    cmp rdi, 0
    je .L416_2
    cmp rbx, 0
    jg .L416_1
.L416_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L416_1:
    mov rax, 281474976710656
    cmp rbx, rax
    jle .L416_3
    lea rax, [rip+.L417]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L416_3:
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
    jne .L416_4
    cmp r8, 0
    jle .L416_4
    mov r9, qword ptr [r8+8]
    mov r10, qword ptr [r8+16]
    sub r9, r10
    cmp rsi, r9
    jg .L416_4
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
    pop rbp
    ret
.L416_4:
    lea rsi, [r12*8]
    add rsi, 8
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    cmp rsi, 0
    jne .L416_5
    lea rax, [rip+.L418]
    mov rdi, rax
    mov rsi, rbx
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L416_5:
    mov qword ptr [rsi+0], r12
    lea rax, [rsi+8]
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_heap_swap
zyl_heap_swap:
    # frame 0
.L419_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov r8, qword ptr [rsi+0]
    cmp rdi, 0
    je .L419_1
    mov qword ptr [rsi+0], rdi
.L419_1:
    mov rax, r8
    ret
.globl zyl_session_arena
zyl_session_arena:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L420_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rbx, rax
    add rbx, 16
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L420_1
    mov rdi, 1048576
    call zyl_arena_create
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    jmp .L420_2
.L420_1:
.L420_2:
    mov rax, qword ptr [rbx+0]
    pop rbx
    pop rbp
    ret
.globl zyl_heap_block_p
zyl_heap_block_p:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L421_0:
    cmp rbx, 4096
    jl .L421_2
.L421_4:
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    je .L421_1
.L421_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L421_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
    cmp rax, 0
    je .L421_3
    mov rax, 1
    pop rbx
    pop rbp
    ret
.L421_3:
    call zyl_session_arena
    mov rdi, rax
    mov rsi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
.globl zyl_pin_owns
zyl_pin_owns:
    # frame 0
.L422_0:
    cmp rdi, 0
    je .L422_2
.L422_3:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jne .L422_1
.L422_2:
    mov rax, 0
    ret
.L422_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rsi, qword ptr [rsi+8]
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
.globl zyl_pin_word
zyl_pin_word:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L423_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jne .L423_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L423_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+8]
    mov rsi, 8
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    cmp rsi, 0
    je .L423_2
    mov qword ptr [rsi+0], rbx
.L423_2:
    mov rax, rsi
    pop rbx
    pop rbp
    ret
.globl zyl_mlock
zyl_mlock:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L424_0:
    cmp rdi, 0
    je .L424_2
.L424_4:
    cmp rsi, 0
    jg .L424_1
.L424_2:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L424_1:
    mov r8, rdi
    and r8, -4096
    sub rdi, r8
    add rdi, rsi
    mov rsi, rdi
    mov rdi, r8
    call zyl_rt_sys_149
    cmp rax, 0
    jne .L424_3
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L424_3:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_pin_alloc
zyl_pin_alloc:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L425_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    je .L425_2
    cmp rbx, 0
    jg .L425_1
.L425_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L425_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+8]
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov r12, rax
    cmp r12, 0
    je .L425_3
    mov rdi, r12
    mov rsi, rbx
    call zyl_mlock
.L425_3:
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dclass_x2Dsize:
    # frame 0
.L426_0:
    cmp rdi, 0
    jne .L426_1
.L426_4:
    mov rax, 1024
    ret
.L426_1:
    cmp rdi, 1
    jne .L426_2
    mov rax, 4096
    ret
.L426_2:
    cmp rdi, 2
    jne .L426_3
    mov rax, 16384
    ret
.L426_3:
    mov rax, 65536
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drpool:
    # frame 0
.L427_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dlive:
    # frame 0
.L428_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dpoison:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L429_0:
    call zyl_region_poison_level
    cmp rax, 0
    jle .L429_1
    mov rsi, qword ptr [rbx+8]
    lea rdi, [rbx+24]
    sub rsi, 24
    call zy_local_x2Fmain_0__alloc__rt_x2Dfill_x2Dde
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L429_1:
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drmap:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L430_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    je .L430_1
    jmp .L430_2
.L430_1:
    lea rax, [rip+.L431]
    mov rsi, rax
    mov rdi, rbx
    call zyl_arena_oom
.L430_2:
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
    jge .L430_3
    cmp rsi, -4096
    jle .L430_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    lea rax, [rip+.L432]
    mov rdi, rax
    mov rsi, rdi
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_arena_oom
.L430_3:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L433_0:
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
    # frame 32
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
.L434_0:
    lea rax, [r14+r13]
    cmp rax, 1048576
    jle .L434_1
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L434_1:
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
    jmp .L434_0
zy_local_x2Fmain_0__alloc__rt_x2Dpick_x2Dclass:
    # frame 0
.L435_0:
    cmp rsi, 4
    jge .L435_1
.L435_5:
    lea r8, [rdi+24]
    mov r9, 1024
    cmp rsi, 0
    je .L435_2
    mov r10, 4096
    cmp rsi, 1
    je .L435_3
    mov r11, 16384
    cmp rsi, 2
    je .L435_4
    mov r11, 65536
.L435_4:
    mov r10, r11
.L435_3:
    mov r9, r10
.L435_2:
    cmp r8, r9
    jle .L435_1
    add rsi, 1
    cmp rsi, 4
    jge .L435_1
    jmp .L435_5
.L435_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dregion_5Funpooled_x2Dp:
    # frame 0
    push rbp
    mov rbp, rsp
.L436_0:
    call zyl_region_poison_level
    mov rsi, rax
    mov rax, rsi
    cmp rax, 2
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dget:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L437_0:
    mov rdi, rsi
    cmp rsi, 4
    jl .L437_1
    mov rdi, 3
.L437_1:
    mov rsi, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dpick_x2Dclass
    mov r12, rax
    cmp r12, 4
    jl .L437_2
    lea rsi, [rbx+24]
    add rsi, 4095
    mov r13, rsi
    and r13, -4096
    mov rdi, r13
    call zy_local_x2Fmain_0__alloc__rt_x2Drmap
    mov rdi, rax
    mov rsi, 1
    mov r8, -1
    mov rdx, rsi
    mov rsi, r13
    mov rcx, r8
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit
.L437_2:
    call zyl_region_poison_level
    cmp rax, 2
    jne .L437_3
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
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit
.L437_3:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rbx, rax
    lea rsi, [r12*8]
    add rbx, rsi
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L437_4
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
    jmp .L437_5
.L437_4:
.L437_5:
    mov rsi, qword ptr [rbx+0]
    mov rdi, qword ptr [rsi+0]
    mov qword ptr [rbx+0], rdi
    mov rdi, 0
    mov qword ptr [rsi+0], rdi
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dcount_x2Dblocks:
    # frame 0
.L438_0:
    cmp rdi, 0
    je .L438_2
.L438_3:
    cmp rsi, 4
    jl .L438_1
.L438_2:
    mov rax, rsi
    ret
.L438_1:
    mov rdi, qword ptr [rdi+0]
    add rsi, 1
    cmp rdi, 0
    je .L438_2
    jmp .L438_3
zy_local_x2Fmain_0__alloc__rt_x2Dpush_x2Dblock:
    # frame 0
.L439_0:
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L440_0:
    mov rsi, qword ptr [rdi+0]
    lea rax, [rip+.L441]
    mov rbx, rax
    cmp rsi, 2
    jne .L440_1
    lea rax, [rip+.L442]
    mov r12, rax
    jmp .L440_2
.L440_1:
    lea rax, [rip+.L443]
    mov r12, rax
.L440_2:
    lea rax, [rip+.L444]
    mov r13, rax
    cmp rsi, 2
    jne .L440_3
    mov rsi, qword ptr [rdi+8]
    jmp .L440_4
.L440_3:
    mov rsi, qword ptr [rdi+24]
.L440_4:
    mov rdi, rsi
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L445]
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L446_0:
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
    jle .L446_1
    mov rax, qword ptr [rbx+16]
    cmp r11, rax
    jg .L446_1
    mov r14, qword ptr [rdi+32]
    mov rax, r11
    mov rcx, r9
    sub rax, rcx
    mov r9, rax
    add r14, r9
    mov rax, qword ptr [rdi+24]
    cmp rax, 0
    jle .L446_2
    mov rax, qword ptr [rdi+24]
    cmp r14, rax
    jle .L446_2
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dexhausted
.L446_2:
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
    pop rbp
    ret
.L446_1:
    cmp r13, 1
    jge .L446_4
    mov rax, qword ptr [rdi+0]
    cmp rax, 2
    jne .L446_3
    mov r9, qword ptr [rbx+24]
    and r9, -2
    cmp r9, 0
    jle .L446_3
.L446_4:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dexhausted
.L446_3:
    add r8, 8
    add r8, rsi
    add r8, 24
    mov rax, qword ptr [rdi+0]
    cmp rax, 2
    jne .L446_5
    mov r9, qword ptr [rdi+8]
    add r9, 8
    add rsi, r9
    add rsi, 24
    jmp .L446_6
.L446_5:
    mov rax, qword ptr [rdi+8]
    cmp rax, r8
    jge .L446_7
    jmp .L446_8
.L446_7:
    mov r8, qword ptr [rdi+8]
.L446_8:
    mov rsi, r8
.L446_6:
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
    jmp .L446_0
.globl zyl_ralloc
zyl_ralloc:
    # frame 0
.L447_0:
    cmp rsi, 0
    jne .L447_1
.L447_5:
    jmp zyl_heap_alloc
.L447_1:
    cmp rdi, 0
    jle .L447_3
    cmp rdi, 65536
    jle .L447_2
.L447_3:
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dralloc_x2Din
.L447_2:
    mov r8, qword ptr [rsi+8]
    lea r9, [rdi+7]
    and r9, -8
    add r9, 8
    cmp r8, 0
    jle .L447_4
    mov r10, qword ptr [rsi+24]
    and r10, 1
    cmp r10, 1
    je .L447_4
    lea r10, [r8+r9]
    mov rax, qword ptr [rsi+16]
    cmp r10, rax
    jg .L447_4
    add r9, r8
    mov qword ptr [rsi+8], r9
    lea r9, [rdi+7]
    shr r9, 3
    mov qword ptr [r8+0], r9
    lea rax, [r8+8]
    ret
.L447_4:
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dralloc_x2Din
zy_local_x2Fmain_0__alloc__rt_x2Dralloc_x2Din:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L448_0:
    cmp rbx, 0
    jg .L448_1
.L448_7:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L448_1:
    mov rsi, qword ptr [r12+24]
    and rsi, 1
    cmp rsi, 1
    jne .L448_2
    mov rsi, 0
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dpolicy_x2Dalloc
.L448_2:
    mov rax, 281474976710656
    cmp rbx, rax
    jle .L448_3
    lea rax, [rip+.L449]
    mov rdi, rax
    mov rsi, rbx
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L448_3:
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
    je .L448_6
    mov rsi, qword ptr [r12+16]
    mov rdi, qword ptr [r12+8]
    sub rsi, rdi
    cmp rsi, r13
    jge .L448_4
.L448_6:
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
    jmp .L448_5
.L448_4:
.L448_5:
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
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dblock:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L450_0:
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
    jne .L450_1
    mov rbx, qword ptr [rdi+8]
    mov rsi, rbx
    call zyl_rt_sys_11
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__heap__rt_x2Drefund
.L450_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rsi, rax
    mov r8d, dword ptr [rdi+20]
    shl r8, 3
    add rsi, r8
    mov r8, qword ptr [rsi+0]
    mov qword ptr [rdi+0], r8
    mov qword ptr [rsi+0], rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dpoison
zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dchain:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L451_0:
    cmp rdi, 0
    je .L451_2
.L451_3:
    cmp rdi, rbx
    jne .L451_1
.L451_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L451_1:
    mov r12, qword ptr [rdi+0]
    call zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dblock
    mov rdi, r12
    cmp rdi, 0
    je .L451_2
    jmp .L451_3
zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L452_0:
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
    pop rbp
    ret
.globl zyl_region_enter
zyl_region_enter:
    # frame 0
.L453_0:
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
    # frame 0
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L454_0:
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
    jl .L454_1
    mov rsi, r9
.L454_1:
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
    # frame 0
    push rbp
    mov rbp, rsp
.L455_0:
    mov rsi, qword ptr [rdi+24]
    and rsi, -2
    cmp rsi, 0
    jle .L455_1
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    jmp .L455_2
.L455_1:
.L455_2:
    mov rax, 0
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dlast_x2Dblock:
    # frame 0
.L456_0:
    mov rax, qword ptr [rdi+0]
    cmp rax, 0
    jne .L456_1
    mov rax, rdi
    ret
.L456_1:
    mov rdi, qword ptr [rdi+0]
    jmp .L456_0
.globl zyl_region_recycle
zyl_region_recycle:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L457_0:
    mov r12, qword ptr [rbx+24]
    and r12, -2
    cmp r12, 0
    jne .L457_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L457_1:
    mov rax, qword ptr [r12+0]
    cmp rax, 0
    jne .L457_2
    mov eax, dword ptr [r12+16]
    cmp rax, 0
    jne .L457_2
    lea rsi, [r12+24]
    mov qword ptr [rbx+8], rsi
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L457_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dlast_x2Dblock
    mov r13, rax
    mov eax, dword ptr [r13+16]
    cmp rax, 1
    jne .L457_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L457_3:
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
    pop rbp
    ret
.globl zyl_region_exit
zyl_region_exit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L458_0:
    mov rsi, qword ptr [rbx+24]
    and rsi, -2
    cmp rsi, 0
    jle .L458_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    jmp .L458_2
.L458_1:
.L458_2:
    mov rsi, qword ptr [rbx+0]
    mov rax, rsi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    cmp rsi, rbx
    jne .L458_3
    mov rsi, 0
    mov rax, rsi
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    jmp .L458_4
.L458_3:
.L458_4:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.globl zyl_region_unwind
zyl_region_unwind:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L459_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov r12, rax
    cmp r12, 0
    je .L459_2
    cmp r12, rbx
    jne .L459_1
.L459_2:
    mov rsi, 0
    mov rax, rsi
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L459_1:
    mov rsi, qword ptr [r12+24]
    and rsi, -2
    cmp rsi, 0
    jle .L459_3
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    jmp .L459_4
.L459_3:
.L459_4:
    mov rsi, qword ptr [r12+0]
    mov rax, rsi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    jmp .L459_0
.globl zyl_region_mark
zyl_region_mark:
    # frame 0
.L460_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_region_live_bytes
zyl_region_live_bytes:
    # frame 0
.L461_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dtls:
    # frame 0
.L462_0:
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
    # frame 0
.L463_0:
    jmp zyl_pin_word
.globl zyl_ffi_unpin
zyl_ffi_unpin:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L464_0:
    cmp rbx, 0
    jne .L464_1
.L464_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L464_1:
    mov rdi, rbx
    call zyl_pin_owns
    cmp rax, 0
    je .L464_2
    mov rax, qword ptr [rbx+0]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L464_2:
    lea rax, [rip+.L465]
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
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L466_0:
    call zyl_arena_alloc_zeroed
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Doob:
    # frame 48
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
.L467_0:
    lea rax, [rip+.L468]
    mov qword ptr [rbp-48], rax
    lea rax, [rip+.L469]
    mov r14, rax
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r15, rax
    lea rax, [rip+.L470]
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
    # frame 0
.L471_0:
    mov rax, 6510318674217419859
    ret
zy_local_x2Fmain_0__tables__tb_x2Dnot_x2Dwords:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L472_0:
    lea rax, [rip+.L473]
    mov rbx, rax
    lea rax, [rip+.L474]
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L475_0:
    cmp rbx, 4096
    jl .L475_1
.L475_2:
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    jne .L475_1
    mov rdi, qword ptr [rbx+0]
    mov rax, 6510318674217419859
    cmp rdi, rax
    jne .L475_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L475_1:
    lea rax, [rip+.L476]
    mov r12, rax
    lea rax, [rip+.L477]
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rsi
    mov r12, rdx
.L478_0:
    mov rsi, 24
    call zyl_arena_alloc_zeroed
    mov r13, rax
    cmp r13, 0
    jne .L478_1
    lea rax, [rip+.L479]
    mov rdi, rax
    call zyl_panic
    jmp .L478_2
.L478_1:
.L478_2:
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L480_0:
    mov rdi, 0
    cmp rsi, 0
    jl .L480_1
    mov rdi, rsi
.L480_1:
    mov r12, rdi
    mov rsi, 24
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov r13, rax
    mov rsi, r12
    cmp r12, 0
    jg .L480_2
    mov rsi, 1
.L480_2:
    shl rsi, 3
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    cmp r13, 0
    je .L480_5
    cmp rbx, 0
    jne .L480_3
.L480_5:
    lea rax, [rip+.L481]
    mov rdi, rax
    call zyl_panic
    jmp .L480_4
.L480_3:
.L480_4:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L482_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rdi, rbx
    call zyl_ralloc
    mov r12, rax
    cmp r12, 0
    je .L482_1
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dfill0
.L482_1:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_words_alloc
zyl_words_alloc:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L483_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L483_1
    mov rsi, rdi
.L483_1:
    mov rbx, rsi
    mov rdi, 24
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r12, rax
    mov rsi, rbx
    cmp rbx, 0
    jg .L483_2
    mov rsi, 1
.L483_2:
    lea rdi, [rsi*8]
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r13, rax
    cmp r12, 0
    je .L483_5
    cmp r13, 0
    jne .L483_3
.L483_5:
    lea rax, [rip+.L484]
    mov rdi, rax
    call zyl_panic
    jmp .L483_4
.L483_3:
.L483_4:
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
    # frame 0
.L485_0:
    jmp zyl_words_alloc
.globl zyl_words_len
zyl_words_len:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L486_0:
    cmp rdi, 4096
    jl .L486_1
.L486_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L486_1
    mov rsi, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp rsi, rax
    jne .L486_1
    mov rax, qword ptr [rdi+8]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L486_1:
    lea rax, [rip+.L487]
    mov rdi, rax
    lea rax, [rip+.L488]
    mov rbx, rax
    lea rax, [rip+.L489]
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov r8, rdx
.L490_0:
    cmp rdi, 4096
    jl .L490_1
.L490_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L490_1
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp r9, rax
    jne .L490_1
    mov rdi, qword ptr [rdi+8]
    mov rdx, rdi
    mov rdi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L490_1:
    lea rax, [rip+.L491]
    mov rbx, rax
    lea rax, [rip+.L492]
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
    # frame 0
.L493_0:
    cmp rdi, 4096
    jl .L493_1
.L493_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L493_1
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp r8, rax
    jne .L493_1
    cmp rsi, 0
    jl .L493_1
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jge .L493_1
    mov r8, qword ptr [rdi+16]
    lea r9, [rsi*8]
    add r8, r9
    mov rax, qword ptr [r8+0]
    ret
.L493_1:
    lea rax, [rip+.L494]
    mov r8, rax
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dfail
.globl zyl_words_set
zyl_words_set:
    # frame 0
    mov r8, rdx
.L495_0:
    cmp rdi, 4096
    jl .L495_1
.L495_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L495_1
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp r9, rax
    jne .L495_1
    cmp rsi, 0
    jl .L495_1
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jge .L495_1
    mov r9, qword ptr [rdi+16]
    lea r10, [rsi*8]
    add r9, r10
    mov qword ptr [r9+0], r8
    mov rax, r8
    ret
.L495_1:
    lea rax, [rip+.L496]
    mov r8, rax
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dfail
zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dhdr_x2Dr:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L497_0:
    mov rdi, 24
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r13, rax
    cmp r13, 0
    jne .L497_1
    lea rax, [rip+.L498]
    mov rdi, rax
    call zyl_panic
    jmp .L497_2
.L497_1:
.L497_2:
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
.globl zyl_words_view
zyl_words_view:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rdx
    mov r13, rcx
.L499_0:
    lea rax, [rip+.L500]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov r14, rax
    mov rsi, qword ptr [r14+8]
    cmp r12, 0
    jl .L499_3
    cmp r13, 0
    jl .L499_3
    cmp r12, rsi
    jg .L499_4
    mov rax, rsi
    sub rax, r12
    cmp r13, rax
    jle .L499_1
.L499_4:
.L499_3:
    lea rax, [rip+.L501]
    mov rdi, rax
    lea r8, [r12+r13]
    mov rdx, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L499_2
.L499_1:
.L499_2:
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
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dhdr
.globl zyl_words_view_r
zyl_words_view_r:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rsi
    mov r12, rdx
.L502_0:
    lea rax, [rip+.L503]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov r13, rax
    mov rsi, qword ptr [r13+8]
    cmp rbx, 0
    jl .L502_3
    cmp r12, 0
    jl .L502_3
    cmp rbx, rsi
    jg .L502_4
    mov rax, rsi
    sub rax, rbx
    cmp r12, rax
    jle .L502_1
.L502_4:
.L502_3:
    lea rax, [rip+.L504]
    mov rdi, rax
    lea r8, [rbx+r12]
    mov rdx, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L502_2
.L502_1:
.L502_2:
    mov rsi, qword ptr [r13+16]
    lea rdi, [rbx*8]
    add rsi, rdi
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dhdr_x2Dr
zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dmagic:
    # frame 0
.L505_0:
    mov rax, 6510318579778470233
    ret
zy_local_x2Fmain_0__tables__tb_x2Dnot_x2Darray:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L506_0:
    lea rax, [rip+.L507]
    mov rbx, rax
    lea rax, [rip+.L508]
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L509_0:
    cmp rbx, 4096
    jl .L509_1
.L509_2:
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    jne .L509_1
    mov rdi, qword ptr [rbx+0]
    mov rax, 6510318579778470233
    cmp rdi, rax
    jne .L509_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L509_1:
    lea rax, [rip+.L510]
    mov r12, rax
    lea rax, [rip+.L511]
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L512_0:
    mov rdi, 0
    cmp rsi, 0
    jl .L512_1
    mov rdi, rsi
.L512_1:
    mov r12, rdi
    mov rsi, 32
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov r13, rax
    mov rsi, r12
    cmp r12, 0
    jg .L512_2
    mov rsi, 1
.L512_2:
    shl rsi, 3
    mov rdi, rbx
    call zyl_arena_alloc
    mov rbx, rax
    cmp r13, 0
    je .L512_5
    cmp rbx, 0
    jne .L512_3
.L512_5:
    lea rax, [rip+.L513]
    mov rdi, rax
    call zyl_panic
    jmp .L512_4
.L512_3:
.L512_4:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L514_0:
    cmp rdi, 4096
    jl .L514_1
.L514_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L514_1
    mov rsi, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp rsi, rax
    jne .L514_1
    mov rax, qword ptr [rdi+8]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L514_1:
    lea rax, [rip+.L515]
    mov rdi, rax
    lea rax, [rip+.L516]
    mov rbx, rax
    lea rax, [rip+.L517]
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L518_0:
    cmp rdi, 4096
    jl .L518_1
.L518_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L518_1
    mov rsi, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp rsi, rax
    jne .L518_1
    mov rax, qword ptr [rdi+16]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L518_1:
    lea rax, [rip+.L519]
    mov rdi, rax
    lea rax, [rip+.L520]
    mov rbx, rax
    lea rax, [rip+.L521]
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L522_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L522_1
    mov rsi, rdi
.L522_1:
    mov rbx, rsi
    mov rdi, 32
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r12, rax
    mov rsi, rbx
    cmp rbx, 0
    jg .L522_2
    mov rsi, 1
.L522_2:
    lea rdi, [rsi*8]
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    call zyl_ralloc
    mov r13, rax
    cmp r12, 0
    je .L522_5
    cmp r13, 0
    jne .L522_3
.L522_5:
    lea rax, [rip+.L523]
    mov rdi, rax
    call zyl_panic
    jmp .L522_4
.L522_3:
.L522_4:
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
    # frame 0
.L524_0:
    jmp zyl_vec_alloc
.globl zyl_array_new_r
zyl_array_new_r:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L525_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L525_1
    mov rsi, rdi
.L525_1:
    mov rbx, rsi
    mov rdi, 32
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r12, rax
    mov rsi, rbx
    cmp rbx, 0
    jg .L525_2
    mov rsi, 1
.L525_2:
    lea rdi, [rsi*8]
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    call zyl_ralloc
    mov r13, rax
    cmp r12, 0
    je .L525_5
    cmp r13, 0
    jne .L525_3
.L525_5:
    lea rax, [rip+.L526]
    mov rdi, rax
    call zyl_panic
    jmp .L525_4
.L525_3:
.L525_4:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L527_0:
    cmp rdi, 4096
    jl .L527_1
.L527_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L527_1
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp r8, rax
    jne .L527_1
    lea rax, [rip+.L528]
    mov r8, rax
    mov rdi, qword ptr [rdi+16]
    mov rdx, rdi
    mov rdi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L527_1:
    lea rax, [rip+.L529]
    mov rdi, rax
    lea rax, [rip+.L530]
    mov rbx, rax
    lea rax, [rip+.L531]
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
    # frame 0
.L532_0:
    cmp rdi, 4096
    jl .L532_1
.L532_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L532_1
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp r8, rax
    jne .L532_1
    cmp rsi, 0
    jl .L532_1
    mov rax, qword ptr [rdi+16]
    cmp rsi, rax
    jge .L532_1
    mov r8, qword ptr [rdi+24]
    lea r9, [rsi*8]
    add r8, r9
    mov rax, qword ptr [r8+0]
    ret
.L532_1:
    jmp zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dget_x2Dfail
.globl zyl_array_copy
zyl_array_copy:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rsi
    mov r12, rdx
.L533_0:
    lea rax, [rip+.L534]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov r13, rax
    lea rax, [rip+.L535]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov rbx, rax
    mov rsi, qword ptr [r13+16]
    cmp r12, 0
    jl .L533_3
    cmp r12, rsi
    jle .L533_1
.L533_3:
    lea rax, [rip+.L536]
    mov rdi, rax
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L533_2
.L533_1:
.L533_2:
    mov rsi, qword ptr [rbx+8]
    mov rax, qword ptr [rbx+16]
    cmp rax, 0
    jne .L533_6
    cmp r12, rsi
    jle .L533_4
.L533_6:
    lea rax, [rip+.L537]
    mov rdi, rax
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L533_5
.L533_4:
.L533_5:
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
    pop rbp
    ret
.globl zyl_array_set
zyl_array_set:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rsi
    mov r12, rdx
.L538_0:
    lea rax, [rip+.L539]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov r13, rax
    mov r14, qword ptr [r13+16]
    cmp rbx, 0
    jl .L538_3
    cmp rbx, r14
    jg .L538_3
    mov rax, qword ptr [r13+8]
    cmp rbx, rax
    jl .L538_1
.L538_3:
    lea rax, [rip+.L540]
    mov rdi, rax
    mov rsi, rbx
    mov rdx, r14
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L538_2
.L538_1:
.L538_2:
    mov rsi, qword ptr [r13+24]
    lea rdi, [rbx*8]
    add rsi, rdi
    mov qword ptr [rsi+0], r12
    cmp rbx, r14
    jne .L538_4
    lea rsi, [r14+1]
    mov qword ptr [r13+16], rsi
    jmp .L538_5
.L538_4:
.L538_5:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_attrh_new
zyl_attrh_new:
    # frame 0
.L541_0:
    mov rdi, 1
    mov rsi, 24
    jmp zyl_rt_calloc
zy_local_x2Fmain_0__tables__tb_x2Dprobe:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L542_0:
    mov r10, r8
    shl r10, 4
    add r10, rdi
    mov r11, qword ptr [r10+0]
    cmp r11, 0
    je .L542_2
    cmp r11, r9
    jne .L542_1
.L542_2:
    mov rax, r10
    ret
.L542_1:
    add r8, 1
    and r8, rsi
    jmp .L542_0
zy_local_x2Fmain_0__tables__tb_x2Drehash:
    # frame 64
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
.L543_0:
    cmp qword ptr [rbp-56], r13
    jl .L543_1
.L543_3:
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
.L543_1:
    imul rsi, qword ptr [rbp-56], 16
    mov rbx, qword ptr [rbp-48]
    add rbx, rsi
    mov r12, qword ptr [rbx+0]
    cmp r12, 0
    je .L543_2
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
.L543_2:
    mov rax, qword ptr [rbp-56]
    add rax, 1
    mov qword ptr [rbp-56], rax
    cmp qword ptr [rbp-56], r13
    jl .L543_1
    jmp .L543_3
zy_local_x2Fmain_0__tables__tb_x2Dgrow:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L544_0:
    mov r12, qword ptr [rbx+8]
    lea rsi, [r12*8]
    cmp r12, 0
    jg .L544_1
    mov rsi, 4096
.L544_1:
    mov r13, rsi
    mov rsi, 16
    mov rdi, r13
    call zyl_rt_calloc
    mov r14, rax
    cmp r14, 0
    jne .L544_2
    mov rdi, r13
    shl rdi, 4
    lea rax, [rip+.L545]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L544_3
.L544_2:
.L544_3:
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L546_0:
    cmp rbx, 0
    je .L546_2
.L546_7:
    cmp r12, 0
    jne .L546_1
.L546_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L546_1:
    mov rsi, qword ptr [rbx+16]
    imul rsi, rsi, 10
    mov rdi, qword ptr [rbx+8]
    imul rdi, rdi, 7
    cmp rsi, rdi
    jl .L546_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dgrow
    jmp .L546_4
.L546_3:
.L546_4:
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
    jne .L546_5
    mov qword ptr [rsi+0], r12
    mov rdi, qword ptr [rbx+16]
    add rdi, 1
    mov qword ptr [rbx+16], rdi
    jmp .L546_6
.L546_5:
.L546_6:
    mov qword ptr [rsi+8], r13
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_attrh_set
zyl_attrh_set:
    # frame 0
    mov r8, rdx
.L547_0:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dattr_x2Dset
zy_local_x2Fmain_0__tables__tb_x2Dget_x2Dloop:
    # frame 16
    push rbx
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L548_0:
    mov r11, r8
    shl r11, 4
    add r11, rdi
    mov rbx, qword ptr [r11+0]
    cmp rbx, r9
    jne .L548_1
    mov rax, qword ptr [r11+8]
    pop rbx
    ret
.L548_1:
    cmp rbx, 0
    jne .L548_2
    mov rax, r10
    pop rbx
    ret
.L548_2:
    add r8, 1
    and r8, rsi
    jmp .L548_0
.globl zyl_attrh_get_or
zyl_attrh_get_or:
    # frame 16
    push rbx
    mov r8, rdx
.L549_0:
    cmp rdi, 0
    je .L549_2
.L549_3:
    cmp rsi, 0
    je .L549_2
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jne .L549_1
.L549_2:
    mov rax, r8
    pop rbx
    ret
.L549_1:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L550_0:
    cmp rdi, 0
    je .L550_4
.L550_7:
    cmp rsi, 0
    je .L550_4
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jne .L550_2
.L550_4:
    mov r8, 0
    jmp .L550_3
.L550_2:
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
    jne .L550_5
    mov rdi, 0
    jmp .L550_6
.L550_5:
    mov rdi, rsi
.L550_6:
    mov r8, rdi
.L550_3:
    cmp r8, 0
    jne .L550_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L550_1:
    mov rax, 1
    pop rbx
    pop rbp
    ret
.globl zyl_attrh_copy
zyl_attrh_copy:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L551_0:
    cmp rbx, 0
    je .L551_3
.L551_7:
    cmp rsi, 0
    je .L551_3
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L551_1
.L551_3:
    mov rdi, 0
    jmp .L551_2
.L551_1:
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
    jne .L551_4
    mov r8, 0
    jmp .L551_5
.L551_4:
    mov r8, rsi
.L551_5:
    mov rdi, r8
.L551_2:
    cmp rdi, 0
    jne .L551_6
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L551_6:
    mov rsi, qword ptr [rdi+8]
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dattr_x2Dset
.globl zyl_attrh_clear
zyl_attrh_clear:
    # frame 0
.L552_0:
    cmp rdi, 0
    je .L552_2
.L552_3:
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jne .L552_1
.L552_2:
    mov rax, 0
    ret
.L552_1:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L553_0:
    mov rdi, 8
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L553_1
    mov rdi, 8
    lea rax, [rip+.L554]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L553_2
.L553_1:
.L553_2:
    mov qword ptr [r12+0], rbx
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ref_get
zyl_ref_get:
    # frame 0
.L555_0:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_ref_set
zyl_ref_set:
    # frame 0
.L556_0:
    mov qword ptr [rdi+0], rsi
    mov rax, 0
    ret
.globl zyl_uf_id
zyl_uf_id:
    # frame 0
.L557_0:
    mov rax, rdi
    ret
.globl zyl_getenv_str
zyl_getenv_str:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L558_0:
    cmp rdi, 0
    jne .L558_1
.L558_4:
    mov rsi, 0
    jmp .L558_2
.L558_1:
    call zyl_rt_getenv
    mov rsi, rax
.L558_2:
    cmp rsi, 0
    jne .L558_3
    lea rax, [rip+.L559]
    mov rdi, rax
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L558_3:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dmagic:
    # frame 0
.L560_0:
    mov rax, 6510318656819643953
    ret
.globl zyl_strbuf_new
zyl_strbuf_new:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L561_0:
    mov r8, rsi
    cmp rsi, 0
    jg .L561_1
    mov r8, 1
.L561_1:
    mov rbx, r8
    lea rsi, [rbx+24]
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    cmp rsi, 0
    jne .L561_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L561_2:
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
    # frame 0
.L562_0:
    cmp rdi, 0
    jne .L562_1
.L562_2:
    lea rax, [rip+.L563]
    mov rsi, rax
    mov rdi, rsi
    jmp zyl_panic
.L562_1:
    mov rax, rdi
    ret
.globl zyl_strbuf_new_r
zyl_strbuf_new_r:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L564_0:
    mov rsi, rdi
    cmp rdi, 0
    jg .L564_1
    mov rsi, 1
.L564_1:
    mov rbx, rsi
    lea rdi, [rbx+24]
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L564_2
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L564_2:
    mov rdi, 6510318656819643953
    mov qword ptr [rsi+0], rdi
    mov rdi, 0
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], rbx
    lea rax, [rsi+24]
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Duhex:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L565_0:
    lea rax, [rip+.L566]
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
    jne .L565_1
    mov rsi, r12
    call zyl_cstr_concat
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L565_1:
    mov rbx, rsi
    mov rsi, r12
    call zyl_cstr_concat
    mov r12, rax
    jmp .L565_0
zy_local_x2Fmain_0__tables__tb_x2Dbad:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L567_0:
    cmp rdi, 4096
    jge .L567_1
.L567_2:
    lea rax, [rip+.L568]
    mov rbx, rax
    lea rax, [rip+.L569]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Duhex
    mov rdi, rax
    lea rax, [rip+.L570]
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
.L567_1:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dappend:
    # frame 48
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
.L571_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    lea rsi, [rbx-16]
    mov r15, qword ptr [rsi+0]
    lea rsi, [rbx-8]
    mov rsi, qword ptr [rsi+0]
    cmp r13, 0
    jle .L571_1
    cmp r13, rsi
    jge .L571_1
    mov rdi, r13
    jmp .L571_2
.L571_1:
    mov rdi, rsi
.L571_2:
    lea rsi, [r15+r14]
    add rsi, 1
    cmp rsi, rdi
    jle .L571_3
    cmp r13, 0
    jle .L571_5
    lea rax, [rip+.L572]
    mov rdi, rax
    jmp .L571_6
.L571_5:
    lea rax, [rip+.L573]
    mov rdi, rax
.L571_6:
    call zyl_panic
    jmp .L571_4
.L571_3:
.L571_4:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
    mov rsi, rdx
.L574_0:
    cmp rbx, 0
    je .L574_2
.L574_7:
    cmp r12, 0
    jne .L574_1
.L574_2:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L574_1:
    cmp rbx, 4096
    jl .L574_3
    cmp r12, 4096
    jl .L574_3
    cmp rbx, 4120
    jl .L574_4
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    jne .L574_4
    lea rdi, [rbx-24]
    mov rdi, qword ptr [rdi+0]
    mov rax, 6510318656819643953
    cmp rdi, rax
    jne .L574_4
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dappend
.L574_4:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_str_append_scan
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L574_3:
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dbad
    cmp rax, 0
    je .L574_5
    jmp .L574_6
.L574_5:
    mov rdi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Dbad
.L574_6:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_str_append
zyl_str_append:
    # frame 0
.L575_0:
    mov r8, 0
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dappend
.globl zyl_str_append_capped
zyl_str_append_capped:
    # frame 0
    mov r8, rdx
.L576_0:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dappend
zy_local_x2Fmain_0__bytes__bb_x2Dmagic_x2Dbuf:
    # frame 0
.L577_0:
    mov rax, 6510318584122966017
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dmagic_x2Dslice:
    # frame 0
.L578_0:
    mov rax, 6510318584122966018
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dmax_x2Dcap:
    # frame 0
.L579_0:
    mov rax, 1099511627776
    ret
.globl zyl_load_byte
zyl_load_byte:
    # frame 0
    mov rdi, rdx
.L580_0:
    cmp rdi, 4096
    jl .L580_3
.L580_15:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L580_1
.L580_3:
    mov r8, 0
    jmp .L580_2
.L580_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L580_4
    mov r10, qword ptr [rdi+24]
    jmp .L580_5
.L580_4:
    mov rax, 6510318584122966018
    cmp r9, rax
    jne .L580_6
    mov r9, qword ptr [rdi+16]
    jmp .L580_7
.L580_6:
    mov r9, -1
.L580_7:
    mov r10, r9
.L580_5:
    cmp r10, 0
    jl .L580_8
    cmp rsi, 0
    jl .L580_12
    cmp r10, 0
    jl .L580_13
    mov rax, 1
    cmp rax, r10
    jle .L580_10
.L580_13:
.L580_12:
    mov r9, 0
    jmp .L580_11
.L580_10:
    sub r10, 1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r9, rax
.L580_11:
    cmp r9, 0
    je .L580_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jmp .L580_9
.L580_8:
    mov rdi, 0
.L580_9:
    mov r8, rdi
.L580_2:
    cmp r8, 0
    jne .L580_14
    mov rax, 0
    ret
.L580_14:
    movzx eax, byte ptr [r8+0]
    ret
.globl zyl_load_byte_signed
zyl_load_byte_signed:
    # frame 0
    mov rdi, rdx
.L581_0:
    cmp rdi, 4096
    jl .L581_3
.L581_16:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L581_1
.L581_3:
    mov r8, 0
    jmp .L581_2
.L581_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L581_4
    mov r10, qword ptr [rdi+24]
    jmp .L581_5
.L581_4:
    mov rax, 6510318584122966018
    cmp r9, rax
    jne .L581_6
    mov r9, qword ptr [rdi+16]
    jmp .L581_7
.L581_6:
    mov r9, -1
.L581_7:
    mov r10, r9
.L581_5:
    cmp r10, 0
    jl .L581_8
    cmp rsi, 0
    jl .L581_12
    cmp r10, 0
    jl .L581_13
    mov rax, 1
    cmp rax, r10
    jle .L581_10
.L581_13:
.L581_12:
    mov r9, 0
    jmp .L581_11
.L581_10:
    sub r10, 1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r9, rax
.L581_11:
    cmp r9, 0
    je .L581_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jmp .L581_9
.L581_8:
    mov rdi, 0
.L581_9:
    mov r8, rdi
.L581_2:
    cmp r8, 0
    jne .L581_14
    mov rax, 0
    ret
.L581_14:
    movzx esi, byte ptr [r8+0]
    cmp rsi, 127
    jle .L581_15
    lea rax, [rsi-256]
    ret
.L581_15:
    mov rax, rsi
    ret
.globl zyl_store_byte
zyl_store_byte:
    # frame 0
    mov rdi, rdx
    mov r8, rcx
.L582_0:
    cmp rdi, 4096
    jl .L582_3
.L582_15:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L582_1
.L582_3:
    mov r9, 0
    jmp .L582_2
.L582_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L582_4
    mov r11, qword ptr [rdi+24]
    jmp .L582_5
.L582_4:
    mov rax, 6510318584122966018
    cmp r10, rax
    jne .L582_6
    mov r10, qword ptr [rdi+16]
    jmp .L582_7
.L582_6:
    mov r10, -1
.L582_7:
    mov r11, r10
.L582_5:
    cmp r11, 0
    jl .L582_8
    cmp rsi, 0
    jl .L582_12
    cmp r11, 0
    jl .L582_13
    mov rax, 1
    cmp rax, r11
    jle .L582_10
.L582_13:
.L582_12:
    mov r10, 0
    jmp .L582_11
.L582_10:
    sub r11, 1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L582_11:
    cmp r10, 0
    je .L582_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jmp .L582_9
.L582_8:
    mov rdi, 0
.L582_9:
    mov r9, rdi
.L582_2:
    cmp r9, 0
    jne .L582_14
    mov rax, 0
    ret
.L582_14:
    mov byte ptr [r9+0], r8b
    mov rax, 1
    ret
.globl zyl_store_byte_signed
zyl_store_byte_signed:
    # frame 0
    mov rdi, rdx
    mov r8, rcx
.L583_0:
    cmp rdi, 4096
    jl .L583_3
.L583_15:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L583_1
.L583_3:
    mov r9, 0
    jmp .L583_2
.L583_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L583_4
    mov r11, qword ptr [rdi+24]
    jmp .L583_5
.L583_4:
    mov rax, 6510318584122966018
    cmp r10, rax
    jne .L583_6
    mov r10, qword ptr [rdi+16]
    jmp .L583_7
.L583_6:
    mov r10, -1
.L583_7:
    mov r11, r10
.L583_5:
    cmp r11, 0
    jl .L583_8
    cmp rsi, 0
    jl .L583_12
    cmp r11, 0
    jl .L583_13
    mov rax, 1
    cmp rax, r11
    jle .L583_10
.L583_13:
.L583_12:
    mov r10, 0
    jmp .L583_11
.L583_10:
    sub r11, 1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L583_11:
    cmp r10, 0
    je .L583_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jmp .L583_9
.L583_8:
    mov rdi, 0
.L583_9:
    mov r9, rdi
.L583_2:
    cmp r9, 0
    jne .L583_14
    mov rax, 0
    ret
.L583_14:
    mov byte ptr [r9+0], r8b
    mov rax, 1
    ret
.globl zyl_load_n
zyl_load_n:
    # frame 16
    push rbx
    mov r8, rdx
    mov r9, rcx
.L584_0:
    cmp rdi, 2
    je .L584_1
.L584_24:
    cmp rdi, 4
    je .L584_1
    cmp rdi, 8
    je .L584_1
    mov rax, 0
    pop rbx
    ret
.L584_1:
    cmp r9, 4096
    jl .L584_4
    mov rax, r9
    and rax, 7
    cmp rax, 0
    je .L584_2
.L584_4:
    mov r10, 0
    jmp .L584_3
.L584_2:
    mov r11, qword ptr [r9+0]
    mov rax, 6510318584122966017
    cmp r11, rax
    jne .L584_5
    mov rbx, qword ptr [r9+24]
    jmp .L584_6
.L584_5:
    mov rax, 6510318584122966018
    cmp r11, rax
    jne .L584_7
    mov r11, qword ptr [r9+16]
    jmp .L584_8
.L584_7:
    mov r11, -1
.L584_8:
    mov rbx, r11
.L584_6:
    cmp rbx, 0
    jl .L584_9
    cmp r8, 0
    jl .L584_13
    cmp rdi, 0
    jl .L584_14
    cmp rbx, 0
    jl .L584_15
    cmp rdi, rbx
    jle .L584_11
.L584_15:
.L584_14:
.L584_13:
    mov r11, 0
    jmp .L584_12
.L584_11:
    sub rbx, rdi
    mov rax, r8
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r11, rax
.L584_12:
    cmp r11, 0
    je .L584_9
    mov r9, qword ptr [r9+8]
    add r9, r8
    jmp .L584_10
.L584_9:
    mov r9, 0
.L584_10:
    mov r10, r9
.L584_3:
    cmp r10, 0
    jne .L584_16
    mov rax, 0
    pop rbx
    ret
.L584_16:
    cmp rdi, 2
    jne .L584_17
    movzx r8d, word ptr [r10+0]
    jmp .L584_18
.L584_17:
    cmp rdi, 4
    jne .L584_19
    mov r9d, dword ptr [r10+0]
    jmp .L584_20
.L584_19:
    mov r9, qword ptr [r10+0]
.L584_20:
    mov r8, r9
.L584_18:
    cmp rsi, 0
    jne .L584_21
    mov rax, r8
    pop rbx
    ret
.L584_21:
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
    jne .L584_22
    mov rax, rsi
    pop rbx
    ret
.L584_22:
    cmp rdi, 4
    jne .L584_23
    mov rdi, rsi
    shr rdi, 32
    mov r8, 4294967295
    and rdi, r8
    mov rax, rdi
    pop rbx
    ret
.L584_23:
    shr rsi, 48
    and rsi, 65535
    mov rax, rsi
    pop rbx
    ret
.globl zyl_load_n_signed
zyl_load_n_signed:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
    mov rdi, rdx
    mov r8, rcx
.L585_0:
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zyl_load_n
    mov rsi, rax
    cmp rbx, 8
    jge .L585_2
    cmp rbx, 2
    je .L585_1
    cmp rbx, 4
    je .L585_1
    cmp rbx, 8
    je .L585_1
.L585_2:
    mov rax, rsi
    pop rbx
    pop rbp
    ret
.L585_1:
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
    pop rbp
    ret
.globl zyl_store_n
zyl_store_n:
    # frame 16
    push rbx
    push r12
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L586_0:
    cmp rdi, 2
    je .L586_1
.L586_25:
    cmp rdi, 4
    je .L586_1
    cmp rdi, 8
    je .L586_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L586_1:
    cmp r9, 4096
    jl .L586_4
    mov rax, r9
    and rax, 7
    cmp rax, 0
    je .L586_2
.L586_4:
    mov r11, 0
    jmp .L586_3
.L586_2:
    mov rbx, qword ptr [r9+0]
    mov rax, 6510318584122966017
    cmp rbx, rax
    jne .L586_5
    mov r12, qword ptr [r9+24]
    jmp .L586_6
.L586_5:
    mov rax, 6510318584122966018
    cmp rbx, rax
    jne .L586_7
    mov rbx, qword ptr [r9+16]
    jmp .L586_8
.L586_7:
    mov rbx, -1
.L586_8:
    mov r12, rbx
.L586_6:
    cmp r12, 0
    jl .L586_9
    cmp r8, 0
    jl .L586_13
    cmp rdi, 0
    jl .L586_14
    cmp r12, 0
    jl .L586_15
    cmp rdi, r12
    jle .L586_11
.L586_15:
.L586_14:
.L586_13:
    mov rbx, 0
    jmp .L586_12
.L586_11:
    sub r12, rdi
    mov rax, r8
    mov rcx, r12
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
.L586_12:
    cmp rbx, 0
    je .L586_9
    mov r9, qword ptr [r9+8]
    add r9, r8
    jmp .L586_10
.L586_9:
    mov r9, 0
.L586_10:
    mov r11, r9
.L586_3:
    cmp r11, 0
    jne .L586_16
    mov rax, 0
    pop r12
    pop rbx
    ret
.L586_16:
    mov r8, r10
    cmp rsi, 0
    je .L586_17
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
    je .L586_18
    cmp rdi, 4
    jne .L586_19
    mov r10, rsi
    shr r10, 32
    mov rbx, 4294967295
    and r10, rbx
    jmp .L586_20
.L586_19:
    mov r10, rsi
    shr r10, 48
    and r10, 65535
.L586_20:
    mov r9, r10
.L586_18:
    mov r8, r9
.L586_17:
    cmp rdi, 2
    jne .L586_21
    mov word ptr [r11+0], r8w
    jmp .L586_22
.L586_21:
    cmp rdi, 4
    jne .L586_23
    mov dword ptr [r11+0], r8d
    jmp .L586_24
.L586_23:
    mov qword ptr [r11+0], r8
.L586_24:
.L586_22:
    mov rax, 1
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L587_0:
    mov rdi, 24
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L587_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L587_1:
    mov rdi, 6510318584122966018
    mov qword ptr [rsi+0], rdi
    mov qword ptr [rsi+8], rbx
    mov qword ptr [rsi+16], r12
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_byte_slice
zyl_byte_slice:
    # frame 0
    mov r8, rdx
.L588_0:
    cmp rdi, 4096
    jl .L588_3
.L588_13:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L588_1
.L588_3:
    mov r9, 0
    jmp .L588_2
.L588_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L588_4
    jmp .L588_5
.L588_4:
    mov rdi, 0
.L588_5:
    mov r9, rdi
.L588_2:
    cmp r9, 0
    je .L588_7
    cmp rsi, 0
    jl .L588_10
    cmp r8, 0
    jl .L588_11
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L588_12
    mov rax, qword ptr [r9+24]
    cmp r8, rax
    jle .L588_8
.L588_12:
.L588_11:
.L588_10:
    mov rdi, 0
    jmp .L588_9
.L588_8:
    mov r10, qword ptr [r9+24]
    sub r10, r8
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rdi, rax
.L588_9:
    cmp rdi, 0
    jne .L588_6
.L588_7:
    mov rax, 0
    ret
.L588_6:
    mov rdi, qword ptr [r9+8]
    add rdi, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice
.globl zyl_byte_slice_sub
zyl_byte_slice_sub:
    # frame 0
    mov r8, rdx
.L589_0:
    cmp rdi, 4096
    jl .L589_3
.L589_13:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L589_1
.L589_3:
    mov r9, 0
    jmp .L589_2
.L589_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966018
    cmp r10, rax
    jne .L589_4
    jmp .L589_5
.L589_4:
    mov rdi, 0
.L589_5:
    mov r9, rdi
.L589_2:
    cmp r9, 0
    je .L589_7
    cmp rsi, 0
    jl .L589_10
    cmp r8, 0
    jl .L589_11
    mov rax, qword ptr [r9+16]
    cmp rax, 0
    jl .L589_12
    mov rax, qword ptr [r9+16]
    cmp r8, rax
    jle .L589_8
.L589_12:
.L589_11:
.L589_10:
    mov rdi, 0
    jmp .L589_9
.L589_8:
    mov r10, qword ptr [r9+16]
    sub r10, r8
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rdi, rax
.L589_9:
    cmp rdi, 0
    jne .L589_6
.L589_7:
    mov rax, 0
    ret
.L589_6:
    mov rdi, qword ptr [r9+8]
    add rdi, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice
zy_local_x2Fmain_0__bytes__bb_x2Dinit:
    # frame 0
    mov r8, rdx
.L590_0:
    mov r9, 6510318584122966017
    mov qword ptr [rdi+0], r9
    mov qword ptr [rdi+8], rsi
    mov rsi, 0
    mov qword ptr [rdi+16], rsi
    mov qword ptr [rdi+24], r8
    mov rax, rdi
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok:
    # frame 0
.L591_0:
    cmp rdi, 0
    jl .L591_1
.L591_2:
    mov rsi, 1099511627776
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setle al
    movzx rax, al
    ret
.L591_1:
    mov rax, 0
    ret
.globl zyl_bytebuf_new
zyl_bytebuf_new:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rsi
.L592_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok
    cmp rax, 0
    jne .L592_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L592_1:
    mov rdi, 32
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L592_2
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L592_2:
    mov rsi, rbx
    cmp rbx, 0
    jg .L592_3
    mov rsi, 1
.L592_3:
    mov r13, rsi
    mov rsi, 1
    mov rdi, r13
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L592_4
    mov rdi, r12
    call zyl_rt_free
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L592_4:
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
    pop rbp
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dinit
.globl zyl_bytebuf_new_r
zyl_bytebuf_new_r:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rsi
.L593_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok
    cmp rax, 0
    jne .L593_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L593_1:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r12, rax
    mov rdi, 32
    mov rsi, r12
    call zyl_ralloc
    mov r13, rax
    cmp r13, 0
    jne .L593_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L593_2:
    mov rsi, rbx
    cmp rbx, 0
    jg .L593_3
    mov rsi, 1
.L593_3:
    mov r14, rsi
    mov rdi, r14
    mov rsi, r12
    call zyl_ralloc
    mov rsi, rax
    cmp rsi, 0
    jne .L593_4
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L593_4:
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
.L594_0:
    cmp rdi, 4096
    jl .L594_3
.L594_19:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L594_1
.L594_3:
    mov r8, 0
    jmp .L594_2
.L594_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L594_4
    jmp .L594_5
.L594_4:
    mov rdi, 0
.L594_5:
    mov r8, rdi
.L594_2:
    mov rbx, r8
    cmp rsi, 4096
    jl .L594_8
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L594_6
.L594_8:
    mov rdi, 0
    jmp .L594_7
.L594_6:
    mov r8, qword ptr [rsi+0]
    mov rax, 6510318584122966018
    cmp r8, rax
    jne .L594_9
    jmp .L594_10
.L594_9:
    mov rsi, 0
.L594_10:
    mov rdi, rsi
.L594_7:
    cmp rbx, 0
    je .L594_12
    cmp rdi, 0
    jne .L594_11
.L594_12:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L594_11:
    mov r12, qword ptr [rbx+16]
    mov r13, qword ptr [rdi+16]
    cmp r12, 0
    jl .L594_16
    cmp r13, 0
    jl .L594_17
    mov rax, qword ptr [rbx+24]
    cmp rax, 0
    jl .L594_18
    mov rax, qword ptr [rbx+24]
    cmp r13, rax
    jle .L594_14
.L594_18:
.L594_17:
.L594_16:
    mov rsi, 0
    jmp .L594_15
.L594_14:
    mov r8, qword ptr [rbx+24]
    sub r8, r13
    mov rax, r12
    mov rcx, r8
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rsi, rax
.L594_15:
    cmp rsi, 0
    jne .L594_13
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L594_13:
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
    pop rbp
    ret
.globl zyl_bytebuf_len
zyl_bytebuf_len:
    # frame 0
.L595_0:
    cmp rdi, 4096
    jl .L595_3
.L595_7:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L595_1
.L595_3:
    mov rsi, 0
    jmp .L595_2
.L595_1:
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L595_4
    jmp .L595_5
.L595_4:
    mov rdi, 0
.L595_5:
    mov rsi, rdi
.L595_2:
    cmp rsi, 0
    jne .L595_6
    mov rax, 0
    ret
.L595_6:
    mov rax, qword ptr [rsi+16]
    ret
.globl zyl_bytebuf_cap
zyl_bytebuf_cap:
    # frame 0
.L596_0:
    cmp rdi, 4096
    jl .L596_3
.L596_7:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L596_1
.L596_3:
    mov rsi, 0
    jmp .L596_2
.L596_1:
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L596_4
    jmp .L596_5
.L596_4:
    mov rdi, 0
.L596_5:
    mov rsi, rdi
.L596_2:
    cmp rsi, 0
    jne .L596_6
    mov rax, 0
    ret
.L596_6:
    mov rax, qword ptr [rsi+24]
    ret
.globl zyl_bytebuf_ptr
zyl_bytebuf_ptr:
    # frame 0
.L597_0:
    cmp rdi, 4096
    jl .L597_3
.L597_7:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L597_1
.L597_3:
    mov rsi, 0
    jmp .L597_2
.L597_1:
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L597_4
    jmp .L597_5
.L597_4:
    mov rdi, 0
.L597_5:
    mov rsi, rdi
.L597_2:
    cmp rsi, 0
    jne .L597_6
    mov rax, 0
    ret
.L597_6:
    mov rax, qword ptr [rsi+8]
    ret
.globl zyl_align_check
zyl_align_check:
    # frame 0
.L598_0:
    cmp rsi, 0
    jg .L598_1
.L598_3:
    mov rax, 0
    ret
.L598_1:
    mov rax, rdi
    mov rcx, rsi
    cqo
    idiv rcx
    mov rax, rdx
    cmp rax, 0
    jne .L598_2
    mov rax, 1
    ret
.L598_2:
    mov rax, 0
    ret
.globl zyl_atomic_load
zyl_atomic_load:
    # frame 0
.L599_0:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_atomic_store
zyl_atomic_store:
    # frame 0
.L600_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, rsi
    ret
.globl zyl_atomic_fetch_add
zyl_atomic_fetch_add:
    # frame 0
.L601_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    ret
.globl zyl_atomic_add
zyl_atomic_add:
    # frame 0
.L602_0:
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
    # frame 0
.L603_0:
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
    # frame 0
    mov r8, rdx
.L604_0:
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
    # frame 16
    push rbx
    mov r8, rdx
    mov r9, rcx
.L605_0:
    cmp r9, 0
    je .L605_1
.L605_6:
    mov r10, rsi
    cmp rsi, r8
    jg .L605_3
    mov r10, r8
.L605_3:
    jmp .L605_2
.p2align 4
.L605_1:
    mov rbx, rsi
    cmp rsi, r8
    jl .L605_4
    mov rbx, r8
.L605_4:
    mov r10, rbx
.L605_2:
    mov rdx, rdi
    mov rcx, rsi
    mov r11, r10
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    mov rbx, rax
    cmp rbx, rsi
    jne .L605_5
    mov rax, r10
    pop rbx
    ret
.L605_5:
    mov rsi, rbx
    cmp r9, 0
    je .L605_1
    jmp .L605_6
.globl zyl_atomic_max
zyl_atomic_max:
    # frame 0
.L606_0:
    mov r8, qword ptr [rdi+0]
    mov r9, 1
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick
.globl zyl_atomic_min
zyl_atomic_min:
    # frame 0
.L607_0:
    mov r8, qword ptr [rdi+0]
    mov r9, 0
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick
.globl zyl_bytebuf_atomic_load
zyl_bytebuf_atomic_load:
    # frame 0
.L608_0:
    cmp rdi, 4096
    jl .L608_3
.L608_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L608_1
.L608_3:
    mov r8, 0
    jmp .L608_2
.L608_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L608_4
    jmp .L608_5
.L608_4:
    mov rdi, 0
.L608_5:
    mov r8, rdi
.L608_2:
    cmp r8, 0
    je .L608_8
    cmp rsi, 0
    jl .L608_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L608_6
.L608_9:
.L608_8:
    mov rdi, 0
    jmp .L608_7
.L608_6:
    cmp rsi, 0
    jl .L608_14
    mov rax, qword ptr [r8+24]
    cmp rax, 0
    jl .L608_15
    mov r9, 8
    mov rax, qword ptr [r8+24]
    cmp r9, rax
    jle .L608_12
.L608_15:
.L608_14:
    mov r9, 0
    jmp .L608_13
.L608_12:
    mov r10, qword ptr [r8+24]
    sub r10, 8
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r9, rax
.L608_13:
    cmp r9, 0
    je .L608_10
    mov r8, qword ptr [r8+8]
    add r8, rsi
    jmp .L608_11
.L608_10:
    mov r8, 0
.L608_11:
    mov rdi, r8
.L608_7:
    cmp rdi, 0
    jne .L608_16
    mov rax, 0
    ret
.L608_16:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_bytebuf_atomic_store
zyl_bytebuf_atomic_store:
    # frame 0
    mov r8, rdx
.L609_0:
    cmp rdi, 4096
    jl .L609_3
.L609_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L609_1
.L609_3:
    mov r9, 0
    jmp .L609_2
.L609_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L609_4
    jmp .L609_5
.L609_4:
    mov rdi, 0
.L609_5:
    mov r9, rdi
.L609_2:
    cmp r9, 0
    je .L609_8
    cmp rsi, 0
    jl .L609_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L609_6
.L609_9:
.L609_8:
    mov rdi, 0
    jmp .L609_7
.L609_6:
    cmp rsi, 0
    jl .L609_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L609_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L609_12
.L609_15:
.L609_14:
    mov r10, 0
    jmp .L609_13
.L609_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L609_13:
    cmp r10, 0
    je .L609_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L609_11
.L609_10:
    mov r9, 0
.L609_11:
    mov rdi, r9
.L609_7:
    cmp rdi, 0
    jne .L609_16
    mov rax, 0
    ret
.L609_16:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 1
    ret
.globl zyl_bytebuf_atomic_add
zyl_bytebuf_atomic_add:
    # frame 0
    mov r8, rdx
.L610_0:
    cmp rdi, 4096
    jl .L610_3
.L610_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L610_1
.L610_3:
    mov r9, 0
    jmp .L610_2
.L610_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L610_4
    jmp .L610_5
.L610_4:
    mov rdi, 0
.L610_5:
    mov r9, rdi
.L610_2:
    cmp r9, 0
    je .L610_8
    cmp rsi, 0
    jl .L610_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L610_6
.L610_9:
.L610_8:
    mov rdi, 0
    jmp .L610_7
.L610_6:
    cmp rsi, 0
    jl .L610_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L610_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L610_12
.L610_15:
.L610_14:
    mov r10, 0
    jmp .L610_13
.L610_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L610_13:
    cmp r10, 0
    je .L610_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L610_11
.L610_10:
    mov r9, 0
.L610_11:
    mov rdi, r9
.L610_7:
    cmp rdi, 0
    jne .L610_16
    mov rax, 0
    ret
.L610_16:
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
    # frame 0
    mov r8, rdx
.L611_0:
    cmp rdi, 4096
    jl .L611_3
.L611_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L611_1
.L611_3:
    mov r9, 0
    jmp .L611_2
.L611_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L611_4
    jmp .L611_5
.L611_4:
    mov rdi, 0
.L611_5:
    mov r9, rdi
.L611_2:
    cmp r9, 0
    je .L611_8
    cmp rsi, 0
    jl .L611_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L611_6
.L611_9:
.L611_8:
    mov rdi, 0
    jmp .L611_7
.L611_6:
    cmp rsi, 0
    jl .L611_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L611_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L611_12
.L611_15:
.L611_14:
    mov r10, 0
    jmp .L611_13
.L611_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L611_13:
    cmp r10, 0
    je .L611_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L611_11
.L611_10:
    mov r9, 0
.L611_11:
    mov rdi, r9
.L611_7:
    cmp rdi, 0
    jne .L611_16
    mov rax, 0
    ret
.L611_16:
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
    # frame 0
    mov r8, rdx
.L612_0:
    cmp rdi, 4096
    jl .L612_3
.L612_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L612_1
.L612_3:
    mov r9, 0
    jmp .L612_2
.L612_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L612_4
    jmp .L612_5
.L612_4:
    mov rdi, 0
.L612_5:
    mov r9, rdi
.L612_2:
    cmp r9, 0
    je .L612_8
    cmp rsi, 0
    jl .L612_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L612_6
.L612_9:
.L612_8:
    mov rdi, 0
    jmp .L612_7
.L612_6:
    cmp rsi, 0
    jl .L612_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L612_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L612_12
.L612_15:
.L612_14:
    mov r10, 0
    jmp .L612_13
.L612_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L612_13:
    cmp r10, 0
    je .L612_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L612_11
.L612_10:
    mov r9, 0
.L612_11:
    mov rdi, r9
.L612_7:
    cmp rdi, 0
    jne .L612_16
    mov rax, 0
    ret
.L612_16:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    ret
.globl zyl_bytebuf_atomic_max
zyl_bytebuf_atomic_max:
    # frame 0
    mov r8, rdx
.L613_0:
    cmp rdi, 4096
    jl .L613_3
.L613_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L613_1
.L613_3:
    mov r9, 0
    jmp .L613_2
.L613_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L613_4
    jmp .L613_5
.L613_4:
    mov rdi, 0
.L613_5:
    mov r9, rdi
.L613_2:
    cmp r9, 0
    je .L613_8
    cmp rsi, 0
    jl .L613_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L613_6
.L613_9:
.L613_8:
    mov rdi, 0
    jmp .L613_7
.L613_6:
    cmp rsi, 0
    jl .L613_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L613_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L613_12
.L613_15:
.L613_14:
    mov r10, 0
    jmp .L613_13
.L613_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L613_13:
    cmp r10, 0
    je .L613_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L613_11
.L613_10:
    mov r9, 0
.L613_11:
    mov rdi, r9
.L613_7:
    cmp rdi, 0
    jne .L613_16
    mov rax, 0
    ret
.L613_16:
    mov rsi, r8
    jmp zyl_atomic_max
.globl zyl_bytebuf_atomic_min
zyl_bytebuf_atomic_min:
    # frame 0
    mov r8, rdx
.L614_0:
    cmp rdi, 4096
    jl .L614_3
.L614_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L614_1
.L614_3:
    mov r9, 0
    jmp .L614_2
.L614_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L614_4
    jmp .L614_5
.L614_4:
    mov rdi, 0
.L614_5:
    mov r9, rdi
.L614_2:
    cmp r9, 0
    je .L614_8
    cmp rsi, 0
    jl .L614_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L614_6
.L614_9:
.L614_8:
    mov rdi, 0
    jmp .L614_7
.L614_6:
    cmp rsi, 0
    jl .L614_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L614_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L614_12
.L614_15:
.L614_14:
    mov r10, 0
    jmp .L614_13
.L614_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L614_13:
    cmp r10, 0
    je .L614_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jmp .L614_11
.L614_10:
    mov r9, 0
.L614_11:
    mov rdi, r9
.L614_7:
    cmp rdi, 0
    jne .L614_16
    mov rax, 0
    ret
.L614_16:
    mov rsi, r8
    jmp zyl_atomic_min
.globl zyl_bytebuf_atomic_cas
zyl_bytebuf_atomic_cas:
    # frame 16
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L615_0:
    cmp rdi, 4096
    jl .L615_3
.L615_18:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L615_1
.L615_3:
    mov r10, 0
    jmp .L615_2
.L615_1:
    mov rbx, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp rbx, rax
    jne .L615_4
    jmp .L615_5
.L615_4:
    mov rdi, 0
.L615_5:
    mov r10, rdi
.L615_2:
    cmp r10, 0
    je .L615_8
    cmp rsi, 0
    jl .L615_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L615_6
.L615_9:
.L615_8:
    mov rdi, 0
    jmp .L615_7
.L615_6:
    cmp rsi, 0
    jl .L615_14
    mov rax, qword ptr [r10+24]
    cmp rax, 0
    jl .L615_15
    mov rbx, 8
    mov rax, qword ptr [r10+24]
    cmp rbx, rax
    jle .L615_12
.L615_15:
.L615_14:
    mov rbx, 0
    jmp .L615_13
.L615_12:
    mov r12, qword ptr [r10+24]
    sub r12, 8
    mov rax, rsi
    mov rcx, r12
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
.L615_13:
    cmp rbx, 0
    je .L615_10
    mov r10, qword ptr [r10+8]
    add r10, rsi
    jmp .L615_11
.L615_10:
    mov r10, 0
.L615_11:
    mov rdi, r10
.L615_7:
    cmp rdi, 0
    jne .L615_16
    mov rax, 0
    pop r12
    pop rbx
    ret
.L615_16:
    mov rdx, rdi
    mov rcx, r8
    mov r11, r9
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, r8
    jne .L615_17
    mov rax, 1
    pop r12
    pop rbx
    ret
.L615_17:
    mov rax, 0
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dread_x2Dall:
    # frame 32
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
.L616_0:
    cmp r14, r13
    jl .L616_1
.L616_4:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L616_1:
    lea rsi, [r12+r14]
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L616_2
    add r14, rsi
    cmp r14, r13
    jl .L616_1
    jmp .L616_4
.L616_2:
    cmp rsi, -4
    jne .L616_3
    cmp r14, r13
    jl .L616_1
    jmp .L616_4
.L616_3:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dwrite_x2Dall:
    # frame 32
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
.L617_0:
    cmp r14, r13
    jl .L617_1
.L617_4:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L617_1:
    lea rsi, [r12+r14]
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L617_2
    add r14, rsi
    cmp r14, r13
    jl .L617_1
    jmp .L617_4
.L617_2:
    cmp rsi, -4
    jne .L617_3
    cmp r14, r13
    jl .L617_1
    jmp .L617_4
.L617_3:
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
.L618_0:
    cmp rdi, 4096
    jge .L618_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L618_1:
    mov rsi, 0
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_2
    mov rbx, rax
    cmp rbx, 0
    jge .L618_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L618_2:
    mov rsi, 0
    mov rdi, 2
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_8
    mov r12, rax
    cmp r12, 0
    jl .L618_5
    mov rsi, 0
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_8
    cmp rax, 0
    jge .L618_3
.L618_5:
    mov rsi, 0
    jmp .L618_4
.L618_3:
    mov rdi, 0
    mov rsi, r12
    call zyl_bytebuf_new
    mov rsi, rax
.L618_4:
    mov r13, rsi
    mov rsi, -1
    cmp r13, 0
    je .L618_6
    mov rdi, qword ptr [r13+8]
    mov r8, 0
    mov rsi, rdi
    mov rdi, rbx
    mov rdx, r12
    mov rcx, r8
    call zy_local_x2Fmain_0__bytes__bb_x2Dread_x2Dall
    mov rsi, rax
.L618_6:
    mov r14, rsi
    mov rdi, rbx
    call zyl_rt_sys_3
    cmp r14, r12
    jne .L618_7
    mov qword ptr [r13+16], r12
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L618_7:
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdx
.L619_0:
    mov r12, rdi
    cmp rsi, 4096
    jl .L619_3
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L619_1
.L619_3:
    mov rdi, 0
    jmp .L619_2
.L619_1:
    mov r8, qword ptr [rsi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L619_4
    jmp .L619_5
.L619_4:
    mov rsi, 0
.L619_5:
    mov rdi, rsi
.L619_2:
    mov r13, rdi
    cmp r12, 4096
    jl .L619_7
    cmp r13, 0
    je .L619_8
    cmp rbx, 0
    jl .L619_11
    mov rax, qword ptr [r13+24]
    cmp rax, 0
    jl .L619_12
    mov rax, qword ptr [r13+24]
    cmp rbx, rax
    jle .L619_9
.L619_12:
.L619_11:
    mov rsi, 0
    jmp .L619_10
.L619_9:
    mov rdi, 0
    mov r8, qword ptr [r13+24]
    sub r8, rbx
    mov rax, rdi
    mov rcx, r8
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rsi, rax
.L619_10:
    cmp rsi, 0
    jne .L619_6
.L619_8:
.L619_7:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L619_6:
    mov rdi, r12
    call zyl_rt_sys_87
    mov rsi, 577
    mov rdi, 493
    mov rdx, rdi
    mov rdi, r12
    call zyl_rt_sys_2
    mov r12, rax
    cmp r12, 0
    jge .L619_13
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L619_13:
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
    jne .L619_14
    cmp rsi, 0
    jne .L619_14
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L619_14:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_add
zyl_f_add:
    # frame 120
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
    # frame 120
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
    # frame 120
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
    # frame 120
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
    # frame 0
.L620_0:
    mov rdx, rdi
    cvtsi2sd xmm0, rdx
    movq rax, xmm0
    ret
.globl zyl_f_to_int
zyl_f_to_int:
    # frame 0
.L621_0:
    mov rdx, rdi
    movq xmm0, rdx
    cvttsd2si rax, xmm0
    ret
.globl zyl_f_rem
zyl_f_rem:
    # frame 152
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
    movsd xmm0, [rip+.L624]
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
    je .L622
    movsd xmm0, [rip+.L625]
    movq rax, xmm0
    jmp .L623
.L622:
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
    movsd xmm0, [rip+.L630]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm0, xmm1
    seta al
    movzx rax, al
    test rax, rax
    je .L628
    mov rax, [rbp-40]
    push rax
    movsd xmm0, [rip+.L631]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm1, xmm0
    seta al
    movzx rax, al
    jmp .L629
.L628:
    mov rax, 0
.L629:
    test rax, rax
    je .L626
    mov rax, [rbp-40]
    mov rdx, rax
    movq xmm0, rdx
    cvttsd2si rax, xmm0
    mov rdx, rax
    cvtsi2sd xmm0, rdx
    movq rax, xmm0
    jmp .L627
.L626:
    mov rax, [rbp-40]
.L627:
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
.L623:
    mov rbx, [rbp-152]
    mov r12, [rbp-144]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_f_cmp
zyl_f_cmp:
    # frame 136
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
    je .L632
    mov rax, -1
    jmp .L633
.L632:
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
    je .L634
    mov rax, 1
    jmp .L635
.L634:
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
    je .L636
    mov rax, 0
    jmp .L637
.L636:
    mov rax, 2
.L637:
.L635:
.L633:
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_now_ms
zyl_now_ms:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L638_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_timespec@tpoff]
    mov rbx, rax
    mov rdi, 1
    mov rsi, rbx
    call zyl_rt_sys_228
    cmp rax, 0
    je .L638_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L638_1:
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
    # frame 0
.L639_0:
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
    # frame 0
.L640_0:
    mov rsi, 0
    mov r8, 32
    mov rdx, r8
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo
zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo:
    # frame 0
    mov r8, rdx
.L641_0:
    cmp r8, 0
    jne .L641_1
.L641_3:
    mov rax, rsi
    ret
.p2align 4
.L641_1:
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
    jne .L641_2
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
    jne .L641_1
    jmp .L641_3
.L641_2:
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 63
    add rax, rcx
    sar rax, 1
    mov r8, rax
    cmp r8, 0
    jne .L641_1
    jmp .L641_3
zy_local_x2Fmain_0__fmt__fm_x2Disdig:
    # frame 0
.L642_0:
    cmp rdi, 48
    jl .L642_1
.L642_2:
    mov rax, rdi
    cmp rax, 57
    setle al
    movzx rax, al
    ret
.L642_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dtab:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L643_0:
    lea rax, [rip+zyl_rtg_fmt_tab]
    mov rbx, rax
    mov rax, qword ptr [rbx+10600]
    cmp rax, 1
    jne .L643_1
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L643_1:
    lea rax, [rip+.L644]
    mov rsi, rax
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dtab_x2Dfill
    lea rdi, [rbx+10416]
    mov rsi, 0
    movsd xmm0, [rip+.L645]
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
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dhex16:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rdx
.L646_0:
    cmp rsi, 16
    jne .L646_1
.L646_2:
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L646_1:
    lea r13, [rsi+1]
    shl r12, 4
    lea rdi, [rbx+rsi]
    movzx edi, byte ptr [rdi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rdi, rax
    add r12, rdi
    mov rsi, r13
    cmp rsi, 16
    jne .L646_1
    jmp .L646_2
zy_local_x2Fmain_0__fmt__fm_x2Dtab_x2Dfill:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L647_0:
    cmp r13, 1302
    jne .L647_1
.L647_3:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L647_1:
    lea rsi, [r13*8]
    lea r14, [rbx+rsi]
    mov rsi, r13
    shl rsi, 4
    lea rdi, [r12+rsi]
    mov rsi, 0
    mov r8, 0
    mov r9, r8
    cmp rsi, 16
    je .L647_2
    mov rdx, r8
    call zy_local_x2Fmain_0__fmt__fm_x2Dhex16
    mov r9, rax
.L647_2:
    mov qword ptr [r14+0], r9
    add r13, 1
    cmp r13, 1302
    jne .L647_1
    jmp .L647_3
zy_local_x2Fmain_0__fmt__fm_x2Dp10_x2Dfill:
    # frame 136
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
    jne .L648
    mov rax, 0
    jmp .L649
.L648:
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
    movsd xmm0, [rip+.L650]
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
.L649:
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dp5_x2Dhex:
    # frame 0
.L651_0:
    lea rax, [rip+.L652]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dspace:
    # frame 0
.L653_0:
    cmp rdi, 32
    jne .L653_1
.L653_3:
    mov rax, 1
    ret
.L653_1:
    cmp rdi, 9
    jl .L653_2
    mov rax, rdi
    cmp rax, 13
    setle al
    movzx rax, al
    ret
.L653_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dskip_x2Dws:
    # frame 0
.L654_0:
    movzx esi, byte ptr [rdi+0]
    mov r8, 1
    cmp rsi, 32
    je .L654_2
    mov rax, rsi
    cmp rax, 13
    setle al
    movzx rax, al
    mov r9, rax
    cmp rsi, 9
    jge .L654_3
    mov r9, 0
.L654_3:
    mov r8, r9
.L654_2:
    cmp r8, 0
    je .L654_1
    add rdi, 1
    jmp .L654_0
.L654_1:
    mov rax, rdi
    ret
.globl zyl_f_parse
zyl_f_parse:
    # frame 0
    push rbp
    mov rbp, rsp
.L655_0:
    cmp rdi, 0
    jne .L655_1
    mov rax, 0
    pop rbp
    ret
.L655_1:
    call zy_local_x2Fmain_0__fmt__fm_x2Dskip_x2Dws
    mov rsi, rax
    movzx edi, byte ptr [rsi+0]
    cmp rdi, 45
    jne .L655_2
    lea r8, [rsi+1]
    mov rdi, r8
    call zy_local_x2Fmain_0__fmt__fm_x2Dbody
    mov r8, rax
    mov r9, -9223372036854775808
    mov rdi, r8
    mov rsi, r9
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dsigned
.L655_2:
    lea r8, [rsi+1]
    cmp rdi, 43
    je .L655_3
    mov r8, rsi
.L655_3:
    mov rdi, r8
    call zy_local_x2Fmain_0__fmt__fm_x2Dbody
    mov rdi, rax
    mov rsi, 0
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dsigned
zy_local_x2Fmain_0__fmt__fm_x2Dsigned:
    # frame 0
.L656_0:
    cmp rdi, -1
    jne .L656_1
.L656_2:
    mov rax, 0
    ret
.L656_1:
    mov rax, rdi
    or rax, rsi
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dbody:
    # frame 120
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
    jne .L657
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dinf_x2Dword
    jmp .L658
.L657:
    mov rax, [rbp-16]
    mov rcx, 110
    cmp rax, rcx
    jne .L659
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dword
    jmp .L660
.L659:
    mov rax, [rbp-8]
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov rcx, 48
    cmp rax, rcx
    jne .L663
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
    jmp .L664
.L663:
    mov rax, 0
.L664:
    test rax, rax
    je .L661
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
    jne .L665
    mov rax, 0
    jmp .L666
.L665:
    mov rax, [rbp-24]
.L666:
    jmp .L662
.L661:
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
.L662:
.L660:
.L658:
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dinf_x2Dword:
    # frame 0
.L667_0:
    movzx esi, byte ptr [rdi+1]
    or rsi, 32
    cmp rsi, 110
    jne .L667_1
    movzx esi, byte ptr [rdi+2]
    or rsi, 32
    cmp rsi, 102
    jne .L667_1
    mov rax, 9218868437227405312
    ret
.L667_1:
    mov rax, -1
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dword:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L668_0:
    movzx esi, byte ptr [rdi+1]
    or rsi, 32
    cmp rsi, 97
    jne .L668_1
    movzx esi, byte ptr [rdi+2]
    or rsi, 32
    cmp rsi, 110
    jne .L668_1
    movzx eax, byte ptr [rdi+3]
    cmp rax, 40
    jne .L668_2
    lea rbx, [rdi+4]
    add rdi, 4
    call zy_local_x2Fmain_0__fmt__fm_x2Dseq_x2Dend
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dseq
.L668_2:
    mov rax, 9221120237041090560
    pop rbx
    pop rbp
    ret
.L668_1:
    mov rax, -1
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dalnum:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L669_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Disdig
    cmp rax, 0
    je .L669_1
    mov rax, 1
    pop rbx
    pop rbp
    ret
.L669_1:
    mov rax, rbx
    or rax, 32
    cmp rax, 97
    jl .L669_2
    mov rax, rbx
    or rax, 32
    cmp rax, 122
    jg .L669_2
    mov rax, 1
    pop rbx
    pop rbp
    ret
.L669_2:
    mov rax, rbx
    cmp rax, 95
    sete al
    movzx rax, al
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dseq_x2Dend:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L670_0:
    movzx edi, byte ptr [rbx+0]
    call zy_local_x2Fmain_0__fmt__fm_x2Dalnum
    cmp rax, 0
    je .L670_1
    add rbx, 1
    jmp .L670_0
.L670_1:
    mov rax, rbx
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dseq:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L671_0:
    movzx eax, byte ptr [r12+0]
    cmp rax, 41
    je .L671_1
    mov rax, 9221120237041090560
    pop r12
    pop rbx
    pop rbp
    ret
.L671_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dend
    cmp rax, r12
    jne .L671_2
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
    pop rbp
    ret
.L671_2:
    mov rax, 9221120237041090560
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rsi
.L672_0:
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L672_1
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setl al
    movzx rax, al
    pop rbx
    pop rbp
    ret
.L672_1:
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase:
    # frame 0
    push rbp
    mov rbp, rsp
.L673_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 48
    jne .L673_1
    movzx esi, byte ptr [rdi+1]
    or rsi, 32
    cmp rsi, 120
    jne .L673_2
    movzx edi, byte ptr [rdi+2]
    mov rsi, 16
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    je .L673_2
    mov rax, 16
    pop rbp
    ret
.L673_2:
    mov rax, 8
    pop rbp
    ret
.L673_1:
    mov rax, 10
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dend:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L674_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase
    mov r12, rax
    lea rsi, [rbx+2]
    cmp r12, 16
    je .L674_1
    mov rsi, rbx
.L674_1:
    mov r13, rsi
    movzx edi, byte ptr [r13+0]
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    je .L674_2
    mov rdi, r13
    mov rsi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Ddigits_x2Dend
.L674_2:
    mov rax, rbx
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Ddigits_x2Dend:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L675_0:
    movzx edi, byte ptr [rbx+0]
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    je .L675_1
    add rbx, 1
    jmp .L675_0
.L675_1:
    mov rax, rbx
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L676_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase
    mov rsi, rax
    lea rdi, [rbx+2]
    cmp rsi, 16
    je .L676_1
    mov rdi, rbx
.L676_1:
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dgo
zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dgo:
    # frame 48
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
.L677_0:
    mov rdx, qword ptr [rbp-48]
    movzx r15d, byte ptr [rdx+0]
    mov rdi, r15
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    jne .L677_1
    cmp r14, 0
    je .L677_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L677_2:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L677_1:
    cmp r14, 0
    je .L677_3
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov r14, 1
    jmp .L677_0
.L677_3:
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
    jne .L677_5
    mov rsi, -9223372036854775808
    xor rsi, r15
    mov rdi, -9223372036854775808
    mov rax, rbx
    xor rax, rdi
    cmp rsi, rax
    jge .L677_4
.L677_5:
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov r14, 1
    jmp .L677_0
.L677_4:
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov r13, r15
    mov r14, 0
    jmp .L677_0
zy_local_x2Fmain_0__fmt__fm_x2Dexp:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L678_0:
    movzx esi, byte ptr [rdi+0]
    mov rax, rsi
    cmp rax, 45
    sete al
    movzx rax, al
    mov rbx, rax
    cmp rsi, 45
    je .L678_3
    cmp rsi, 43
    jne .L678_1
.L678_3:
    lea rsi, [rdi+1]
    jmp .L678_2
.L678_1:
    mov rsi, rdi
.L678_2:
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dgo
    mov rsi, rax
    cmp rbx, 0
    je .L678_4
    mov rdi, 0
    sub rdi, rsi
    mov rax, rdi
    pop rbx
    pop rbp
    ret
.L678_4:
    mov rax, rsi
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dgo:
    # frame 0
.L679_0:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 48
    jl .L679_1
    cmp r8, 57
    jg .L679_1
    lea r9, [rdi+1]
    mov rax, 1000000000000000
    cmp rsi, rax
    jge .L679_2
    imul r10, rsi, 10
    sub r8, 48
    add r10, r8
    jmp .L679_3
.L679_2:
    mov r10, rsi
.L679_3:
    mov rsi, r10
    mov rdi, r9
    jmp .L679_0
.L679_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat:
    # frame 0
.L680_0:
    movzx r8d, byte ptr [rdi+0]
    or r8, 32
    cmp r8, rsi
    jne .L680_1
    add rdi, 1
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dexp
.L680_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__fmt__fh_x2Dint:
    # frame 48
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
.L681_0:
    movzx r12d, byte ptr [rbx+0]
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L681_1
    mov rax, qword ptr [rbp-48]
    shr rax, 56
    cmp rax, 0
    jne .L681_2
    add rbx, 1
    mov rax, qword ptr [rbp-48]
    imul rax, 16
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-48]
    mov rcx, rsi
    add rax, rcx
    mov qword ptr [rbp-48], rax
    mov r15, 1
    jmp .L681_0
.L681_2:
    lea rdi, [rbx+1]
    lea r8, [r13+4]
    cmp r14, 0
    je .L681_3
    mov r9, 1
    jmp .L681_4
.L681_3:
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov r9, rax
.L681_4:
    mov r14, r9
    mov r15, 1
    mov rbx, rdi
    mov r13, r8
    jmp .L681_0
.L681_1:
    cmp r12, 46
    jne .L681_5
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
.L681_5:
    cmp r15, 0
    je .L681_6
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
.L681_6:
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
    # frame 48
    push rbp
    mov rbp, rsp
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
.L682_0:
    movzx edi, byte ptr [rbx+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L682_1
    mov rax, r12
    shr rax, 56
    cmp rax, 0
    jne .L682_2
    add rbx, 1
    shl r12, 4
    add r12, rsi
    sub r13, 4
    mov r15, 1
    jmp .L682_0
.L682_2:
    lea rdi, [rbx+1]
    cmp r14, 0
    je .L682_3
    mov r8, 1
    jmp .L682_4
.L682_3:
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov r8, rax
.L682_4:
    mov r14, r8
    mov r15, 1
    mov rbx, rdi
    jmp .L682_0
.L682_1:
    cmp r15, 0
    je .L682_5
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
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fh_x2Dround
.L682_5:
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fh_x2Dround:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L683_0:
    cmp rbx, 0
    jne .L683_1
.L683_8:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L683_1:
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
    jle .L683_2
    mov rax, 9218868437227405312
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L683_2:
    mov rsi, -1074
    cmp r14, -1022
    jl .L683_3
    lea rsi, [r14-52]
.L683_3:
    sub rsi, r12
    cmp rsi, 0
    jg .L683_4
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
    jmp .L683_5
.L683_4:
    mov rdi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__fmt__fh_x2Dshift_x2Dround
    mov rdi, rax
.L683_5:
    mov rsi, rdi
    cmp r14, -1022
    jl .L683_6
    lea r8, [r14+1022]
    shl r8, 52
    lea rsi, [rdi+r8]
.L683_6:
    mov rax, 9218868437227405312
    cmp rsi, rax
    jl .L683_7
    mov rax, 9218868437227405312
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L683_7:
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fh_x2Dshift_x2Dround:
    # frame 0
    mov r8, rdx
.L684_0:
    cmp rsi, 62
    jle .L684_1
.L684_5:
    mov rax, 0
    ret
.L684_1:
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
    jg .L684_3
    cmp rdi, rsi
    jne .L684_2
    cmp r8, 0
    jne .L684_4
    mov rax, r9
    and rax, 1
    cmp rax, 1
    jne .L684_2
.L684_4:
.L684_3:
    lea rax, [r9+1]
    ret
.L684_2:
    mov rax, r9
    ret
zy_local_x2Fmain_0__fmt__fd_x2Dscan:
    # frame 184
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
    jl .L687
    mov rax, [rbp-64]
    mov rcx, 57
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L688
.L687:
    mov rax, 0
.L688:
    test rax, rax
    je .L685
    mov rax, [rbp-56]
    test rax, rax
    je .L689
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    jmp .L690
.L689:
    mov rax, [rbp-40]
.L690:
    mov [rbp-72], rax
    mov rax, [rbp-32]
    mov rcx, 0
    cmp rax, rcx
    jne .L693
    mov rax, [rbp-64]
    mov rcx, 48
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L694
.L693:
    mov rax, 0
.L694:
    test rax, rax
    je .L691
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
    jmp .L692
.L691:
    mov rax, [rbp-32]
    mov rcx, 19
    cmp rax, rcx
    jge .L695
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
    jmp .L696
.L695:
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
.L696:
.L692:
    jmp .L686
.L685:
    mov rax, [rbp-64]
    mov rcx, 46
    cmp rax, rcx
    jne .L699
    mov rax, [rbp-56]
    test rax, rax
    je .L701
    mov rax, 0
    jmp .L702
.L701:
    mov rax, 1
.L702:
    jmp .L700
.L699:
    mov rax, 0
.L700:
    test rax, rax
    je .L697
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
    jmp .L698
.L697:
    mov rax, [rbp-48]
    test rax, rax
    je .L705
    mov rax, 0
    jmp .L706
.L705:
    mov rax, 1
.L706:
    test rax, rax
    je .L703
    mov rax, -1
    jmp .L704
.L703:
    sub rsp, 16
    mov rdi, [rbp-16]
    mov rsi, 101
call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat
    add rsp, 16
    mov [rbp-80], rax
    mov rax, [rbp-32]
    mov rcx, 0
    cmp rax, rcx
    jne .L707
    mov rax, 0
    jmp .L708
.L707:
    mov rax, [rbp-32]
    mov rcx, 19
    cmp rax, rcx
    jg .L709
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
    jmp .L710
.L709:
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
.L710:
.L708:
.L704:
.L698:
.L686:
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fd_x2Dexact:
    # frame 136
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
    jl .L715
    mov rax, [rbp-16]
    mov rcx, 22
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L716
.L715:
    mov rax, 0
.L716:
    test rax, rax
    je .L713
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jl .L717
    mov rax, [rbp-8]
    mov rcx, 9007199254740992
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L718
.L717:
    mov rax, 0
.L718:
    jmp .L714
.L713:
    mov rax, 0
.L714:
    test rax, rax
    je .L711
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
    jl .L719
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
    jmp .L720
.L719:
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
.L720:
    jmp .L712
.L711:
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
.L712:
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fd_x2Dinexact:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L721_0:
    mov rdi, r14
    mov rsi, r13
    call zy_local_x2Fmain_0__fmt__fm_x2Del
    mov r15, rax
    lea rsi, [r13+1]
    mov rdi, r14
    call zy_local_x2Fmain_0__fmt__fm_x2Del
    cmp r15, rax
    jne .L721_1
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L721_1:
    mov rdi, rbx
    mov rsi, r12
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dparse
zy_local_x2Fmain_0__fmt__fm_x2Del:
    # frame 48
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
.L722_0:
    cmp rbx, -342
    jge .L722_1
.L722_6:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L722_1:
    cmp rbx, 308
    jle .L722_2
    mov rax, 9218868437227405312
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L722_2:
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
    jne .L722_3
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
    jge .L722_4
    mov rdi, qword ptr [rbp-48]
    add rdi, 1
    jmp .L722_5
.L722_4:
    mov rdi, qword ptr [rbp-48]
.L722_5:
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
.L722_3:
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
    # frame 16
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L723_0:
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
    jg .L723_1
    mov r10, 0
    sub r10, rsi
    lea rax, [r10+1]
    cmp rax, 64
    jl .L723_2
    mov rax, 0
    pop r12
    pop rbx
    ret
.L723_2:
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
.L723_1:
    mov r10, -9223372036854775808
    xor r8, r10
    mov r10, -9223372036854775808
    xor r10, 2
    cmp r8, r10
    jge .L723_3
    cmp rdi, -4
    jl .L723_3
    cmp rdi, 23
    jg .L723_3
    mov rax, rbx
    and rax, 3
    cmp rax, 1
    jne .L723_3
    mov rax, rbx
    mov rcx, r11
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    cmp rax, r9
    jne .L723_3
    mov rdi, rbx
    and rdi, -2
    jmp .L723_4
.L723_3:
    mov rdi, rbx
.L723_4:
    mov r8, rdi
    and r8, 1
    add rdi, r8
    shr rdi, 1
    lea r8, [rsi+1]
    mov rax, 9007199254740992
    cmp rdi, rax
    jge .L723_5
    mov r8, rsi
.L723_5:
    mov rsi, 0
    mov rax, 9007199254740992
    cmp rdi, rax
    jge .L723_6
    mov r9, 4503599627370495
    mov rsi, rdi
    and rsi, r9
.L723_6:
    cmp r8, 2047
    jl .L723_7
    mov rax, 9218868437227405312
    pop r12
    pop rbx
    ret
.L723_7:
    mov rdi, r8
    shl rdi, 52
    mov rax, rsi
    or rax, rdi
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dbuf:
    # frame 0
.L724_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_fmt_dec@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dparse:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L725_0:
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
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dbits
zy_local_x2Fmain_0__fmt__sd_x2Dread:
    # frame 16
    push rbx
    mov r8, rdx
.L726_0:
    movzx r9d, byte ptr [rsi+0]
    cmp r9, 48
    jl .L726_1
    cmp r9, 57
    jg .L726_1
    mov r10, qword ptr [rdi+0]
    cmp r10, 0
    jne .L726_2
    cmp r9, 48
    jne .L726_2
    cmp r8, 0
    je .L726_3
    mov r11, qword ptr [rdi+8]
    sub r11, 1
    mov qword ptr [rdi+8], r11
    jmp .L726_4
.L726_3:
.L726_4:
    add rsi, 1
    jmp .L726_0
.L726_2:
    cmp r10, 800
    jge .L726_5
    lea r11, [rdi+32]
    add r11, r10
    lea rbx, [r9-48]
    mov byte ptr [r11+0], bl
    add r10, 1
    mov qword ptr [rdi+0], r10
    jmp .L726_6
.L726_5:
    cmp r9, 48
    je .L726_7
    mov r10, 1
    mov qword ptr [rdi+16], r10
.L726_7:
.L726_6:
    cmp r8, 0
    je .L726_8
    jmp .L726_9
.L726_8:
    mov r10, qword ptr [rdi+8]
    add r10, 1
    mov qword ptr [rdi+8], r10
.L726_9:
    add rsi, 1
    jmp .L726_0
.L726_1:
    cmp r9, 46
    jne .L726_10
    cmp r8, 0
    jne .L726_10
    add rsi, 1
    mov r8, 1
    jmp .L726_0
.L726_10:
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dtrim:
    # frame 0
.L727_0:
    mov rsi, qword ptr [rdi+0]
    cmp rsi, 0
    jle .L727_1
    lea r8, [rdi+32]
    lea r9, [rsi-1]
    add r8, r9
    movzx eax, byte ptr [r8+0]
    cmp rax, 0
    jne .L727_1
    lea r8, [rsi-1]
    mov qword ptr [rdi+0], r8
    jmp .L727_0
.L727_1:
    cmp rsi, 0
    jne .L727_2
    mov rsi, 0
    mov qword ptr [rdi+8], rsi
    mov rax, rsi
    ret
.L727_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dshift:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L728_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L728_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L728_1:
    cmp r12, 25
    jle .L728_2
    mov rsi, 25
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dlshift
    sub r12, 25
    jmp .L728_0
.L728_2:
    cmp r12, 0
    jle .L728_3
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dlshift
.L728_3:
    cmp r12, -59
    jge .L728_4
    mov rsi, 59
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
    add r12, 59
    jmp .L728_0
.L728_4:
    cmp r12, 0
    jge .L728_5
    mov rsi, 0
    sub rsi, r12
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
.L728_5:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Drshift:
    # frame 0
.L729_0:
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L730_0:
    mov rax, r9
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    cmp rax, 0
    jne .L730_1
    mov rax, qword ptr [rdi+0]
    cmp r8, rax
    jl .L730_2
    cmp r9, 0
    jne .L730_3
    mov r10, 0
    mov qword ptr [rdi+0], r10
    mov r10, 0
    mov qword ptr [rdi+8], r10
    mov rax, r10
    ret
.L730_3:
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dpad
.L730_2:
    lea r10, [r8+1]
    imul r9, r9, 10
    lea r11, [rdi+32]
    add r11, r8
    movzx r11d, byte ptr [r11+0]
    add r9, r11
    mov r8, r10
    jmp .L730_0
.L730_1:
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dpad:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L731_0:
    mov rax, r9
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    cmp rax, 0
    jne .L731_1
    add r8, 1
    imul r9, r9, 10
    jmp .L731_0
.L731_1:
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L732_0:
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
    # frame 32
    push rbx
    push r12
    push r13
    mov r10, r8
    mov r8, rdx
    mov r11, r9
    mov r9, rcx
.L733_0:
    mov rax, qword ptr [rdi+0]
    cmp r9, rax
    jge .L733_1
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
    jmp .L733_0
.L733_1:
    mov rdx, r8
    mov rcx, r10
    mov r8, r11
    pop r13
    pop r12
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dtail
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dtail:
    # frame 16
    push rbx
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L734_0:
    cmp r10, 0
    jle .L734_1
.L734_5:
    mov rax, r10
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r11, rax
    cmp r9, 800
    jge .L734_2
    lea rbx, [rdi+32]
    add rbx, r9
    mov byte ptr [rbx+0], r11b
    add r9, 1
    and r10, r8
    imul r10, r10, 10
    cmp r10, 0
    jle .L734_1
    jmp .L734_5
.L734_2:
    cmp r11, 0
    jle .L734_3
    mov r11, 1
    mov qword ptr [rdi+16], r11
    jmp .L734_4
.L734_3:
.L734_4:
    and r10, r8
    imul r10, r10, 10
    cmp r10, 0
    jle .L734_1
    jmp .L734_5
.L734_1:
    mov qword ptr [rdi+0], r9
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dtrim
zy_local_x2Fmain_0__fmt__fm_x2Dndig:
    # frame 0
.L735_0:
    cmp rdi, 10
    jge .L735_1
.L735_2:
    mov rax, rsi
    ret
.p2align 4
.L735_1:
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
    jge .L735_1
    jmp .L735_2
zy_local_x2Fmain_0__fmt__fm_x2Dpow5:
    # frame 0
.L736_0:
    cmp rdi, 0
    jne .L736_1
.L736_2:
    mov rax, rsi
    ret
.p2align 4
.L736_1:
    sub rdi, 1
    imul rsi, rsi, 5
    cmp rdi, 0
    jne .L736_1
    jmp .L736_2
zy_local_x2Fmain_0__fmt__sd_x2Dprefix:
    # frame 16
    push rbx
    mov r8, rdx
    mov r9, rcx
.L737_0:
    cmp rsi, r8
    jne .L737_1
.L737_4:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L737_1:
    lea r10, [rsi+1]
    imul r11, r9, 10
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jge .L737_2
    lea rbx, [rdi+32]
    add rbx, rsi
    movzx ebx, byte ptr [rbx+0]
    jmp .L737_3
.L737_2:
    mov rbx, 0
.L737_3:
    lea r9, [r11+rbx]
    mov rsi, r10
    cmp rsi, r8
    jne .L737_1
    jmp .L737_4
zy_local_x2Fmain_0__fmt__sd_x2Ddelta:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L738_0:
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
    jge .L738_1
    lea rax, [r12-1]
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L738_1:
    mov rax, r12
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dlshift:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L739_0:
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
    jge .L739_1
    mov rdi, rsi
.L739_1:
    mov qword ptr [rbx+0], rdi
    mov rsi, qword ptr [rbx+8]
    add rsi, r13
    mov qword ptr [rbx+8], rsi
    mov rdi, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dtrim
zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dput:
    # frame 0
    mov r8, rdx
.L740_0:
    cmp rsi, 800
    jge .L740_1
.L740_3:
    lea r9, [rdi+32]
    add r9, rsi
    mov byte ptr [r9+0], r8b
    mov rsi, r8
    mov rax, rsi
    ret
.L740_1:
    cmp r8, 0
    jne .L740_2
    mov rax, 0
    ret
.L740_2:
    mov rsi, 1
    mov qword ptr [rdi+16], rsi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dgo:
    # frame 32
    push rbx
    push r12
    push r13
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L741_0:
    cmp r8, 0
    jl .L741_1
.L741_9:
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
    jge .L741_2
    lea r13, [rdi+32]
    add r13, r12
    mov byte ptr [r13+0], r11b
    jmp .L741_3
.L741_2:
    cmp r11, 0
    je .L741_4
    mov r11, 1
    mov qword ptr [rdi+16], r11
.L741_4:
.L741_3:
    sub r8, 1
    sub r9, 1
    mov r10, rbx
    cmp r8, 0
    jl .L741_1
    jmp .L741_9
.p2align 4
.L741_1:
    cmp r10, 0
    jle .L741_5
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
    jge .L741_6
    lea r13, [rdi+32]
    add r13, rbx
    mov byte ptr [r13+0], r12b
    jmp .L741_7
.L741_6:
    cmp r12, 0
    je .L741_8
    mov rbx, 1
    mov qword ptr [rdi+16], rbx
.L741_8:
.L741_7:
    mov r8, -1
    sub r9, 1
    mov r10, r11
    cmp r8, 0
    jl .L741_1
    jmp .L741_9
.L741_5:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dpowtab:
    # frame 0
.L742_0:
    cmp rdi, 0
    jne .L742_1
.L742_9:
    mov rax, 1
    ret
.L742_1:
    cmp rdi, 1
    jne .L742_2
    mov rax, 3
    ret
.L742_2:
    cmp rdi, 2
    jne .L742_3
    mov rax, 6
    ret
.L742_3:
    cmp rdi, 3
    jne .L742_4
    mov rax, 9
    ret
.L742_4:
    cmp rdi, 4
    jne .L742_5
    mov rax, 13
    ret
.L742_5:
    cmp rdi, 5
    jne .L742_6
    mov rax, 16
    ret
.L742_6:
    cmp rdi, 6
    jne .L742_7
    mov rax, 19
    ret
.L742_7:
    cmp rdi, 7
    jne .L742_8
    mov rax, 23
    ret
.L742_8:
    mov rax, 26
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dstep:
    # frame 0
.L743_0:
    cmp rdi, 9
    jl .L743_1
.L743_2:
    mov rax, 27
    ret
.L743_1:
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dpowtab
zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Ddown:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L744_0:
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jle .L744_1
    mov rdi, qword ptr [rbx+8]
    call zy_local_x2Fmain_0__fmt__sd_x2Dstep
    mov r13, rax
    mov rsi, 0
    sub rsi, r13
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    add r12, r13
    jmp .L744_0
.L744_1:
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Dup:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L745_0:
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jl .L745_2
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L745_1
    lea rsi, [rbx+32]
    movzx eax, byte ptr [rsi+0]
    cmp rax, 5
    jge .L745_1
.L745_2:
    mov rdi, 0
    mov rsi, qword ptr [rbx+8]
    sub rdi, rsi
    call zy_local_x2Fmain_0__fmt__sd_x2Dstep
    mov r13, rax
    mov rdi, rbx
    mov rsi, r13
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    sub r12, r13
    jmp .L745_0
.L745_1:
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dbits:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L746_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L746_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L746_1:
    mov rax, qword ptr [rbx+8]
    cmp rax, 310
    jle .L746_2
    mov rax, 9218868437227405312
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L746_2:
    mov rax, qword ptr [rbx+8]
    cmp rax, -330
    jge .L746_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L746_3:
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Ddown
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Dup
    mov r12, rax
    sub r12, 1
    cmp r12, -1022
    jge .L746_4
    mov r13, -1022
    sub r13, r12
    mov rsi, 0
    sub rsi, r13
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    lea rsi, [r12+r13]
    jmp .L746_5
.L746_4:
    mov rsi, r12
.L746_5:
    mov r12, rsi
    lea rax, [r12+1023]
    cmp rax, 2047
    jl .L746_6
    mov rax, 9218868437227405312
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L746_6:
    mov rsi, 53
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Drounded
    mov rsi, rax
    lea rdi, [r12+1]
    mov rax, 9007199254740992
    cmp rsi, rax
    je .L746_7
    mov rdi, r12
.L746_7:
    mov r8, 4503599627370496
    mov rax, 9007199254740992
    cmp rsi, rax
    je .L746_8
    mov r8, rsi
.L746_8:
    lea rax, [rdi+1023]
    cmp rax, 2047
    jl .L746_9
    mov rax, 9218868437227405312
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L746_9:
    mov rsi, 4503599627370496
    mov rax, r8
    and rax, rsi
    cmp rax, 0
    jne .L746_10
    mov rsi, -1023
    jmp .L746_11
.L746_10:
    mov rsi, rdi
.L746_11:
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
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dint:
    # frame 16
    push rbx
    mov r8, rdx
    mov r9, rcx
.L747_0:
    cmp rsi, r8
    jl .L747_1
.L747_4:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L747_1:
    lea r10, [rsi+1]
    imul r11, r9, 10
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jge .L747_2
    lea rbx, [rdi+32]
    add rbx, rsi
    movzx ebx, byte ptr [rbx+0]
    jmp .L747_3
.L747_2:
    mov rbx, 0
.L747_3:
    lea r9, [r11+rbx]
    mov rsi, r10
    cmp rsi, r8
    jl .L747_1
    jmp .L747_4
zy_local_x2Fmain_0__fmt__sd_x2Drounded:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L748_0:
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
    je .L748_1
    lea rax, [r13+1]
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L748_1:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dround_x2Dup:
    # frame 0
.L749_0:
    cmp rsi, 0
    jl .L749_2
.L749_6:
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jl .L749_1
.L749_2:
    mov rax, 0
    ret
.L749_1:
    lea r8, [rdi+32]
    add r8, rsi
    movzx eax, byte ptr [r8+0]
    cmp rax, 5
    jne .L749_3
    lea r8, [rsi+1]
    mov rax, qword ptr [rdi+0]
    cmp r8, rax
    jne .L749_3
    mov rax, qword ptr [rdi+16]
    cmp rax, 1
    jne .L749_4
    mov rax, 1
    ret
.L749_4:
    cmp rsi, 0
    jle .L749_5
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
.L749_5:
    mov rax, 0
    ret
.L749_3:
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
    # frame 0
.L750_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext
.globl zyl_f_text_r
zyl_f_text_r:
    # frame 0
.L751_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext
zy_local_x2Fmain_0__fmt__fm_x2Dtext:
    # frame 0
.L752_0:
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
    jne .L752_1
    cmp rdi, 0
    jne .L752_2
    cmp r8, 0
    je .L752_3
    lea rax, [rip+.L753]
    mov r10, rax
    mov r11, 4
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L752_3:
    lea rax, [rip+.L754]
    mov r10, rax
    mov r11, 3
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L752_2:
    cmp r8, 0
    je .L752_4
    lea rax, [rip+.L755]
    mov r10, rax
    mov r11, 4
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L752_4:
    lea rax, [rip+.L756]
    mov r10, rax
    mov r11, 3
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L752_1:
    mov r10, rdi
    cmp r9, 0
    je .L752_5
    mov r11, 4503599627370496
    mov r10, rdi
    or r10, r11
.L752_5:
    mov rdi, -1074
    cmp r9, 0
    je .L752_6
    lea rdi, [r9-1075]
.L752_6:
    cmp rdi, 10
    jle .L752_7
    mov rdx, rdi
    mov rdi, r8
    mov rcx, rsi
    mov rsi, r10
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dbig
.L752_7:
    cmp rdi, 0
    jl .L752_8
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
.L752_8:
    mov r9, 0
    sub r9, rdi
    mov rdi, r8
    mov rdx, r9
    mov rcx, rsi
    mov rsi, r10
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dfrac
zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dfrac:
    # frame 64
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
.L757_0:
    cmp r12, 76
    jl .L757_1
.L757_8:
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
.L757_1:
    mov rax, rsi
    mov rcx, r12
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    cmp r12, 64
    jl .L757_2
    mov rdi, 0
.L757_2:
    mov r14, rdi
    cmp r12, 64
    jge .L757_3
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
    jmp .L757_4
.L757_3:
    mov rdi, rsi
.L757_4:
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
    je .L757_5
    lea rsi, [r13+1]
    jmp .L757_6
.L757_5:
    mov rsi, r13
.L757_6:
    cmp rsi, 1000000
    jne .L757_7
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
.L757_7:
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
    # frame 0
    mov r8, rdx
.L758_0:
    cmp rdi, 64
    jge .L758_1
.L758_2:
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
.L758_1:
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
    # frame 16
    push rbx
    mov r8, rdx
    mov r9, rcx
.L759_0:
    cmp rdi, 64
    jge .L759_1
.L759_10:
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
    jle .L759_2
    mov rax, 1
    pop rbx
    ret
.L759_2:
    cmp r10, r11
    jne .L759_3
    mov rax, r9
    pop rbx
    ret
.L759_3:
    mov rax, 0
    pop rbx
    ret
.L759_1:
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
    je .L759_4
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
.L759_4:
    mov r11, -9223372036854775808
    cmp rdi, 0
    je .L759_5
    mov r11, 0
.L759_5:
    cmp r8, r10
    jle .L759_6
    mov rax, 1
    pop rbx
    ret
.L759_6:
    cmp r8, r10
    jne .L759_7
    mov rdi, -9223372036854775808
    xor rdi, r11
    mov r8, -9223372036854775808
    mov rax, rsi
    xor rax, r8
    cmp rdi, rax
    jge .L759_8
    mov rax, 1
    pop rbx
    ret
.L759_8:
    cmp rsi, r11
    jne .L759_9
    mov rax, r9
    pop rbx
    ret
.L759_9:
    mov rax, 0
    pop rbx
    ret
.L759_7:
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dsmall:
    # frame 64
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
.L760_0:
    cmp rbx, 0
    je .L760_1
.L760_5:
    mov rsi, 1
    jmp .L760_2
.L760_1:
    mov rsi, 0
.L760_2:
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
    je .L760_3
    mov rsi, 45
    mov rcx, rsi
    mov byte ptr [r14+0], cl
    jmp .L760_4
.L760_3:
.L760_4:
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
    # frame 0
.L761_0:
    cmp rsi, 0
    jne .L761_1
.L761_2:
    mov rax, 0
    ret
.p2align 4
.L761_1:
    mov r8, 48
    mov byte ptr [rdi+0], r8b
    add rdi, 1
    sub rsi, 1
    cmp rsi, 0
    jne .L761_1
    jmp .L761_2
zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dbig:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov rdi, rdx
    mov r12, rcx
.L762_0:
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
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dout
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dshift:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rdx
.L763_0:
    cmp r12, 0
    jne .L763_1
.L763_3:
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L763_1:
    mov rdi, 32
    cmp r12, 32
    jg .L763_2
    mov rdi, r12
.L763_2:
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
    jne .L763_1
    jmp .L763_3
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dmul:
    # frame 32
    push rbx
    push r12
    push r13
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L764_0:
    cmp rsi, r8
    jge .L764_1
.L764_3:
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
    jge .L764_1
    jmp .L764_3
.p2align 4
.L764_1:
    cmp r10, 0
    jle .L764_2
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
    jge .L764_1
    jmp .L764_3
.L764_2:
    mov rax, r8
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dout:
    # frame 80
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
.L765_0:
    cmp rbx, 0
    je .L765_1
.L765_5:
    mov rsi, 1
    jmp .L765_2
.L765_1:
    mov rsi, 0
.L765_2:
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
    je .L765_3
    mov rsi, 45
    mov rcx, rsi
    mov byte ptr [r14+0], cl
    jmp .L765_4
.L765_3:
.L765_4:
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
    # frame 32
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
.L766_0:
    cmp r13, 0
    jge .L766_1
.L766_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L766_1:
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
    jge .L766_1
    jmp .L766_2
zy_local_x2Fmain_0__out__ou_x2Dst:
    # frame 0
.L767_0:
    lea rax, [rip+zyl_rtg_out_state]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Dbuf:
    # frame 0
.L768_0:
    lea rax, [rip+zyl_rtg_out_buf]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Dlock:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L769_0:
    mov rsi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L769_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L769_1:
    call zyl_rt_sys_24
    jmp .L769_0
zy_local_x2Fmain_0__out__ou_x2Dunlock:
    # frame 0
.L770_0:
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 0
    ret
zy_local_x2Fmain_0__out__ou_x2Dinit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L771_0:
    mov rax, qword ptr [rbx+16]
    cmp rax, 0
    jle .L771_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L771_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_stat@tpoff]
    mov r12, rax
    mov rdi, 1
    mov rsi, r12
    call zyl_rt_sys_5
    cmp rax, 0
    jne .L771_2
    mov rsi, qword ptr [r12+56]
    jmp .L771_3
.L771_2:
    mov rsi, 0
.L771_3:
    cmp rsi, 0
    jle .L771_4
    cmp rsi, 8192
    jge .L771_4
    jmp .L771_5
.L771_4:
    mov rsi, 8192
.L771_5:
    mov qword ptr [rbx+24], rsi
    mov rdi, 1
    mov rsi, 21505
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_tios@tpoff]
    mov r8, rax
    mov rdx, r8
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L771_6
    mov rsi, 2
    jmp .L771_7
.L771_6:
    mov rsi, 1
.L771_7:
    mov qword ptr [rbx+16], rsi
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__out__ou_x2Dsys_x2Dall:
    # frame 32
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
.L772_0:
    cmp r13, 0
    jg .L772_1
.L772_4:
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L772_1:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L772_2
    add r12, rsi
    sub r13, rsi
    cmp r13, 0
    jg .L772_1
    jmp .L772_4
.L772_2:
    cmp rsi, -4
    jne .L772_3
    cmp r13, 0
    jg .L772_1
    jmp .L772_4
.L772_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked:
    # frame 0
.L773_0:
    mov rsi, qword ptr [rdi+8]
    cmp rsi, 0
    jne .L773_1
    mov rax, 1
    ret
.L773_1:
    mov r8, 0
    mov qword ptr [rdi+8], r8
    mov rdi, 1
    lea rax, [rip+zyl_rtg_out_buf]
    mov r8, rax
    mov rdx, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__out__ou_x2Dsys_x2Dall
zy_local_x2Fmain_0__out__ou_x2Dappend:
    # frame 48
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
.L774_0:
    cmp r13, 0
    jg .L774_1
.L774_5:
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
.L774_1:
    mov rdx, qword ptr [rbp-48]
    mov r14, qword ptr [rdx+8]
    mov rdx, qword ptr [rbp-48]
    mov r15, qword ptr [rdx+24]
    sub r15, r14
    mov rsi, r13
    cmp r13, r15
    jl .L774_2
    mov rsi, r15
.L774_2:
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
    jne .L774_3
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked
    cmp rax, 0
    je .L774_4
    add r12, rbx
    sub r13, rbx
    cmp r13, 0
    jg .L774_1
    jmp .L774_5
.L774_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L774_3:
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
    # frame 48
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
.L775_0:
    mov rdx, qword ptr [rbp-48]
    mov r14, qword ptr [rdx+8]
    mov rdx, qword ptr [rbp-48]
    mov r15, qword ptr [rdx+24]
    mov rax, r15
    sub rax, r14
    cmp r13, rax
    jg .L775_1
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
.L775_1:
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
    jne .L775_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L775_2:
    sub r13, rbx
    cmp r15, 128
    jl .L775_3
    mov rax, r13
    mov rcx, r15
    cqo
    idiv rcx
    mov rax, rdx
    mov rsi, rax
    jmp .L775_4
.L775_3:
    mov rsi, 0
.L775_4:
    mov r14, r13
    sub r14, rsi
    cmp r14, 0
    jle .L775_5
    mov rdi, 1
    lea rsi, [r12+rbx]
    mov rdx, r14
    call zy_local_x2Fmain_0__out__ou_x2Dsys_x2Dall
    cmp rax, 0
    jne .L775_5
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L775_5:
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
    # frame 0
.L776_0:
    cmp rsi, 0
    jge .L776_1
.L776_3:
    mov rax, -1
    ret
.p2align 4
.L776_1:
    lea r8, [rdi+rsi]
    movzx eax, byte ptr [r8+0]
    cmp rax, 10
    jne .L776_2
    mov rax, rsi
    ret
.L776_2:
    sub rsi, 1
    cmp rsi, 0
    jge .L776_1
    jmp .L776_3
zy_local_x2Fmain_0__out__ou_x2Dput_x2Dline:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L777_0:
    lea rsi, [r13-1]
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dlast_x2Dnl
    mov r14, rax
    cmp r14, 0
    jge .L777_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dappend
.L777_1:
    lea rsi, [r14+1]
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dappend
    cmp rax, 0
    je .L777_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked
    cmp rax, 0
    je .L777_2
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
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dappend
.L777_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__out__ou_x2Downer_x2Dcell:
    # frame 0
.L778_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_owner_self
zyl_owner_self:
    # frame 0
.L779_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L779_1
    mov rax, 1
    ret
.L779_1:
    mov rax, rsi
    ret
.globl zyl_owner_set
zyl_owner_set:
    # frame 0
.L780_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__out__ou_x2Dabuf:
    # frame 0
.L781_0:
    lea rax, [rip+zyl_rtg_actor_out]
    mov rsi, rax
    imul rdi, rdi, 24
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Debuf:
    # frame 0
.L782_0:
    lea rax, [rip+zyl_rtg_actor_err]
    mov rsi, rax
    imul rdi, rdi, 24
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Dabuf_x2Dput:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L783_0:
    mov r14, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+16]
    lea rax, [r14+r13]
    cmp rax, rsi
    jg .L783_1
    mov rdi, 1
    jmp .L783_2
.L783_1:
    lea r8, [rsi*2]
    lea rax, [r14+r13]
    cmp r8, rax
    jge .L783_3
    lea r8, [r13+256]
    add r8, r14
    jmp .L783_4
.L783_3:
    lea r8, [rsi*2]
.L783_4:
    mov r15, r8
    mov rsi, qword ptr [rbx+0]
    mov rdi, rsi
    mov rsi, r15
    call zyl_rt_realloc
    mov rsi, rax
    mov r8, 0
    cmp rsi, 0
    je .L783_5
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+16], r15
    mov r8, 1
.L783_5:
    mov rdi, r8
.L783_2:
    mov rax, rdi
    cmp rax, 0
    je .L783_6
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
    pop rbp
    ret
.L783_6:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_out_actor_emit
zyl_out_actor_emit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L784_0:
    cmp rbx, 2
    jl .L784_2
.L784_3:
    cmp rbx, 1025
    jle .L784_1
.L784_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L784_1:
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
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Demit
zy_local_x2Fmain_0__out__ou_x2Demit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L785_0:
    mov rbx, qword ptr [rdi+0]
    mov r8, qword ptr [rdi+8]
    mov r9, 0
    mov qword ptr [rdi+0], r9
    mov r9, 0
    mov qword ptr [rdi+8], r9
    mov r9, 0
    mov qword ptr [rdi+16], r9
    cmp rbx, 0
    jne .L785_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L785_1:
    cmp rsi, 0
    je .L785_2
    mov rdi, rbx
    mov rsi, r8
    call zyl_err_write
    jmp .L785_3
.L785_2:
    mov rdi, rbx
    mov rsi, r8
    call zyl_out_write
.L785_3:
    mov rdi, rbx
    call zyl_rt_free
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__out__ou_x2Dput:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L786_0:
    call zyl_owner_self
    mov rdi, rax
    cmp rdi, 2
    jl .L786_1
    call zy_local_x2Fmain_0__out__ou_x2Dabuf
    mov rdi, rax
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dabuf_x2Dput
.L786_1:
    mov rax, qword ptr [rbx+16]
    cmp rax, 2
    jne .L786_2
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dput_x2Dline
.L786_2:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dput_x2Dfull
zy_local_x2Fmain_0__out__ou_x2Dputs:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L787_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dput
.globl zyl_out_write
zyl_out_write:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L788_0:
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
    pop rbp
    ret
.globl zyl_out_puts
zyl_out_puts:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L789_0:
    cmp rbx, 0
    jne .L789_1
.L789_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L789_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zyl_out_write
.globl zyl_out_flush
zyl_out_flush:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L790_0:
    lea rax, [rip+zyl_rtg_out_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L790_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L790_1:
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
    pop rbp
    ret
.globl zyl_err_write
zyl_err_write:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L791_0:
    call zyl_owner_self
    mov rdi, rax
    cmp rdi, 2
    jl .L791_1
    call zy_local_x2Fmain_0__out__ou_x2Debuf
    mov rdi, rax
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__out__ou_x2Dabuf_x2Dput
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L791_1:
    mov rdi, 2
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__out__ou_x2Dsys_x2Dall
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_err_puts
zyl_err_puts:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L792_0:
    cmp rbx, 0
    jne .L792_1
.L792_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L792_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zyl_err_write
zy_local_x2Fmain_0__out__ou_x2Ddigits:
    # frame 0
.L793_0:
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
    jne .L793_1
    mov rax, r8
    ret
.L793_1:
    mov rdi, r9
    mov rsi, r8
    jmp .L793_0
zy_local_x2Fmain_0__out__ou_x2Dint:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L794_0:
    mov rdi, 0
    sub rdi, rbx
    cmp rbx, 0
    jl .L794_1
    mov rdi, rbx
.L794_1:
    call zy_local_x2Fmain_0__out__ou_x2Ddigits
    mov rsi, rax
    cmp rbx, 0
    jge .L794_2
    lea rdi, [rsi-1]
    mov r8, 45
    mov byte ptr [rdi+0], r8b
    lea rax, [rsi-1]
    pop rbx
    pop rbp
    ret
.L794_2:
    mov rax, rsi
    pop rbx
    pop rbp
    ret
.globl zyl_out_int
zyl_out_int:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L795_0:
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
    pop rbp
    jmp zyl_out_write
.globl zyl_print_int
zyl_print_int:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L796_0:
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
    pop rbp
    ret
.globl zyl_print_str
zyl_print_str:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
.L797_0:
    mov rbx, rdi
    lea rax, [rip+zyl_rtg_out_state]
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dlock
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dinit
    cmp rbx, 0
    jne .L797_1
    lea rax, [rip+.L798]
    mov r13, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__out__ou_x2Dput
    jmp .L797_2
.L797_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dput
.L797_2:
    lea rax, [rip+.L799]
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
    pop rbp
    ret
.globl zyl_print_float
zyl_print_float:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L800_0:
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
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dret:
    # frame 0
.L801_0:
    cmp rdi, 0
    jge .L801_1
.L801_2:
    mov rax, -1
    ret
.L801_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__os__os_x2Dbad:
    # frame 0
    push rbp
    mov rbp, rsp
.L802_0:
    cmp rdi, 0
    jle .L802_1
.L802_2:
    cmp rdi, 4096
    jge .L802_1
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 1
    pop rbp
    ret
.L802_1:
    mov rax, 0
    pop rbp
    ret
.globl zyl_file_open_c
zyl_file_open_c:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L803_0:
    mov r8, 0
    cmp rsi, 4096
    jl .L803_1
    movzx r8d, byte ptr [rsi+0]
.L803_1:
    mov rsi, 0
    cmp r8, 114
    je .L803_2
    mov r9, 1089
    cmp r8, 97
    je .L803_3
    mov r9, 577
.L803_3:
    mov rsi, r9
.L803_2:
    mov r8, 420
    mov rdx, r8
    call zyl_rt_sys_2
    mov rsi, rax
    cmp rsi, 0
    jge .L803_4
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L803_4:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dread:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov rdi, rdx
.L804_0:
    mov r8, 0
    cmp rsi, 0
    jl .L804_1
    mov r9, 67108864
    cmp rsi, 67108864
    jg .L804_2
    mov r9, rsi
.L804_2:
    mov r8, r9
.L804_1:
    mov r12, r8
    lea rsi, [r12+1]
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_ralloc
    mov r13, rax
    cmp r13, 0
    jne .L804_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L804_3:
    mov rdi, rbx
    mov rsi, r13
    mov rdx, r12
    call zyl_rt_sys_0
    mov rsi, rax
    mov rdi, 0
    cmp rsi, 0
    jl .L804_4
    mov rdi, rsi
.L804_4:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L805_0:
    cmp rbx, 0
    jne .L805_1
.L805_3:
    call zyl_out_flush
    jmp .L805_2
.L805_1:
.L805_2:
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dread
.globl zyl_file_read_c_r
zyl_file_read_c_r:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L806_0:
    cmp rbx, 0
    jne .L806_1
.L806_3:
    call zyl_out_flush
    jmp .L806_2
.L806_1:
.L806_2:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dread
.globl zyl_file_write_c
zyl_file_write_c:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L807_0:
    mov r12, rsi
    cmp r12, 0
    jne .L807_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L807_1:
    lea rax, [rip+.L808]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L807_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L807_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    cmp rbx, 1
    jne .L807_3
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
.L807_3:
    cmp rbx, 2
    jne .L807_4
    call zyl_owner_self
    cmp rax, 2
    jl .L807_4
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
.L807_4:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jge .L807_5
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L807_5:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_file_close_c
zyl_file_close_c:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L809_0:
    call zyl_rt_sys_3
    mov rsi, rax
    cmp rsi, 0
    jge .L809_1
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L809_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_path_exists
zyl_path_exists:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L810_0:
    mov rsi, 0
    call zyl_rt_sys_21
    cmp rax, 0
    jne .L810_1
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L810_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_chdir
zyl_chdir:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L811_0:
    call zyl_rt_sys_80
    mov rsi, rax
    cmp rsi, 0
    jge .L811_1
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L811_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_getcwd
zyl_getcwd:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L812_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_cwd@tpoff]
    mov rbx, rax
    mov rsi, 4096
    mov rdi, rbx
    call zyl_rt_sys_79
    cmp rax, 0
    jle .L812_2
    movzx eax, byte ptr [rbx+0]
    cmp rax, 47
    je .L812_1
.L812_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L812_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    lea rdi, [r12+1]
    call zyl_heap_alloc
    mov r13, rax
    cmp r13, 0
    jne .L812_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L812_3:
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
.L813_0:
    mov rbx, rdi
    cmp rbx, 0
    je .L813_2
    lea rax, [rip+.L814]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L813_1
.L813_2:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L813_1:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L813_3
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L813_3:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    cmp r12, 4096
    jl .L813_4
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L813_4:
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
    je .L813_5
    mov rdi, r13
    call zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Done
    cmp rax, 0
    je .L813_6
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L813_6:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L813_5:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Done:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L815_0:
    mov rsi, 493
    call zyl_rt_sys_83
    mov rsi, rax
    cmp rsi, 0
    jne .L815_1
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L815_1:
    mov rax, rsi
    cmp rax, -17
    sete al
    movzx rax, al
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Dparents:
    # frame 32
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
.L816_0:
    cmp r13, r12
    jl .L816_1
.L816_5:
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L816_1:
    lea rsi, [rbx+r13]
    movzx eax, byte ptr [rsi+0]
    cmp rax, 47
    jne .L816_2
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
    je .L816_3
    mov rax, rsi
    cmp rax, -17
    sete al
    movzx rax, al
    mov rdi, rax
.L816_3:
    lea rsi, [rbx+r13]
    mov r8, 47
    mov byte ptr [rsi+0], r8b
    cmp rdi, 0
    je .L816_4
    add r13, 1
    cmp r13, r12
    jl .L816_1
    jmp .L816_5
.L816_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L816_2:
    add r13, 1
    cmp r13, r12
    jl .L816_1
    jmp .L816_5
.globl zyl_save_args
zyl_save_args:
    # frame 0
.L817_0:
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
    jg .L817_1
    mov r9, rdi
.L817_1:
    mov qword ptr [r8+0], r9
    mov qword ptr [r8+8], rsi
    mov rdi, 0
    cmp rsi, 0
    je .L817_2
    lea r8, [r9+1]
    shl r8, 3
    lea rdi, [rsi+r8]
.L817_2:
    jmp zyl_rt_set_env
.globl zyl_argc
zyl_argc:
    # frame 0
.L818_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_arg_str
zyl_arg_str:
    # frame 0
.L819_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov rsi, rax
    cmp rdi, 0
    jl .L819_2
    mov rax, qword ptr [rsi+0]
    cmp rdi, rax
    jl .L819_1
.L819_2:
    mov rax, 0
    ret
.L819_1:
    mov rsi, qword ptr [rsi+8]
    shl rdi, 3
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__os__os_x2Dcat3:
    # frame 64
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
.L820_0:
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
    jle .L820_1
    lea rdi, [r14-1]
    jmp .L820_2
.L820_1:
    mov rdi, rsi
.L820_2:
    mov r14, rdi
    lea rdi, [r14+1]
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov qword ptr [rbp-64], rax
    cmp qword ptr [rbp-64], 0
    jne .L820_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L820_3:
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
    # frame 0
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L821_0:
    cmp rsi, r10
    jl .L821_1
.L821_4:
    mov rax, 0
    ret
.L821_1:
    add rdi, rsi
    lea rax, [rsi+r9]
    cmp rax, r10
    jle .L821_2
    mov rax, r10
    mov rcx, rsi
    sub rax, rcx
    mov rsi, rax
    jmp .L821_3
.L821_2:
    mov rsi, r9
.L821_3:
    mov rdx, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy
zy_local_x2Fmain_0__os__os_x2Dsep:
    # frame 0
.L822_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 0
    jne .L822_1
    lea rax, [rip+.L823]
    mov rsi, rax
    mov rax, rsi
    ret
.L822_1:
    lea rax, [rip+.L824]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__os__os_x2Dhas_x2Dsuffix:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov rdi, rdx
.L825_0:
    call zy_local_x2Fmain_0__os__os_x2Dskip_x2Dsp
    mov r13, rax
    movzx eax, byte ptr [r13+0]
    cmp rax, 0
    jne .L825_1
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L825_1:
    mov rdi, r13
    call zy_local_x2Fmain_0__os__os_x2Dword_x2Dend
    mov r14, rax
    mov rsi, r14
    sub rsi, r13
    cmp rsi, 0
    jle .L825_2
    cmp r12, rsi
    jle .L825_2
    mov r8, r12
    sub r8, rsi
    add r8, rbx
    mov rdi, r8
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    cmp rax, 0
    je .L825_2
    mov rax, 1
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L825_2:
    mov rdi, r14
    jmp .L825_0
zy_local_x2Fmain_0__os__os_x2Dskip_x2Dsp:
    # frame 0
.L826_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 32
    jne .L826_1
    add rdi, 1
    jmp .L826_0
.L826_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__os__os_x2Dword_x2Dend:
    # frame 0
.L827_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 0
    je .L827_2
    cmp rsi, 32
    jne .L827_1
.L827_2:
    mov rax, rdi
    ret
.L827_1:
    add rdi, 1
    jmp .L827_0
zy_local_x2Fmain_0__os__os_x2Dpush:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L828_0:
    mov rsi, qword ptr [rbx+8]
    mov rdi, qword ptr [rbx+16]
    cmp rsi, rdi
    jne .L828_1
    mov r8, 64
    cmp rdi, 0
    je .L828_2
    lea r8, [rdi*2]
.L828_2:
    mov r13, r8
    mov rdi, qword ptr [rbx+0]
    lea r8, [r13*8]
    mov rsi, r8
    call zyl_rt_realloc
    mov rdi, rax
    cmp rdi, 0
    jne .L828_3
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_free
.L828_3:
    mov qword ptr [rbx+0], rdi
    mov qword ptr [rbx+16], r13
    jmp .L828_0
.L828_1:
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
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dwalk:
    # frame 48
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
.L829_0:
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
    mov rsi, 591872
    mov rdi, 0
    mov rdx, rdi
    mov rdi, r15
    call zyl_rt_sys_2
    mov qword ptr [rbp-48], rax
    mov rdi, r15
    call zyl_rt_free
    cmp qword ptr [rbp-48], 0
    jge .L829_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L829_2:
    mov rdi, 32768
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    je .L829_3
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    mov r8, qword ptr [rbp-48]
    mov r9, r15
    call zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dfill
.L829_3:
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
    # frame 168
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
    jg .L830
    mov rax, 0
    jmp .L831
.L830:
    mov rax, 0
    mov [rbp-72], rax
    mov rax, [rbp-72]
    mov rcx, [rbp-56]
    cmp rax, rcx
    jl .L832
    mov rax, 0
    jmp .L833
.L832:
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
.L833:
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
.L831:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dents:
    # frame 184
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
    jl .L834
    mov rax, 0
    jmp .L835
.L834:
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
    jne .L836
    mov rax, 0
    jmp .L837
.L836:
    sub rsp, 8
    sub rsp, 40
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    mov rdx, [rbp-24]
    mov rcx, [rbp-32]
    mov r8, [rbp-72]
call zy_local_x2Fmain_0__os__os_x2Dwalk_x2Done
    add rsp, 48
.L837:
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
.L835:
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dwalk_x2Done:
    # frame 64
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
.L838_0:
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
    jne .L838_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L838_1:
    lea rax, [rip+.L839]
    mov rsi, rax
    mov rdi, 8200
    mov rdx, qword ptr [rbp-48]
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dcat3
    mov r15, rax
    cmp r15, 0
    jne .L838_2
    mov rdi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_free
.L838_2:
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
    je .L838_3
    mov rdi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_free
.L838_3:
    mov esi, dword ptr [r12+24]
    and rsi, 61440
    cmp rsi, 16384
    jne .L838_4
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
.L838_4:
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    mov rdx, r13
    call zy_local_x2Fmain_0__os__os_x2Dhas_x2Dsuffix
    cmp rax, 0
    je .L838_5
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
.L838_5:
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
    # frame 168
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
    jge .L840
    mov rax, 0
    jmp .L841
.L840:
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
.L841:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dmerge:
    # frame 168
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
    jl .L844
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    cmp rax, rcx
    setge al
    movzx rax, al
    jmp .L845
.L844:
    mov rax, 0
.L845:
    test rax, rax
    je .L842
    mov rax, 0
    jmp .L843
.L842:
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    cmp rax, rcx
    jl .L848
    mov rax, 1
    jmp .L849
.L848:
    mov rax, [rbp-24]
    mov rcx, [rbp-32]
    cmp rax, rcx
    jge .L850
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
    jmp .L851
.L850:
    mov rax, 0
.L851:
.L849:
    test rax, rax
    je .L846
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
    jmp .L847
.L846:
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
.L847:
.L843:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dtotal:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rdx
    mov r13, rcx
.L852_0:
    cmp rsi, r12
    jl .L852_1
.L852_2:
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L852_1:
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
    jl .L852_1
    jmp .L852_2
zy_local_x2Fmain_0__os__os_x2Demit:
    # frame 64
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
.L853_0:
    cmp r12, r13
    jl .L853_1
.L853_2:
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
.L853_1:
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
    jl .L853_1
    jmp .L853_2
zy_local_x2Fmain_0__os__os_x2Dfree_x2Dall:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L854_0:
    cmp r12, r13
    jl .L854_1
.L854_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L854_1:
    lea rsi, [r12*8]
    add rsi, rbx
    mov rdi, qword ptr [rsi+0]
    call zyl_rt_free
    add r12, 1
    cmp r12, r13
    jl .L854_1
    jmp .L854_2
zy_local_x2Fmain_0__os__os_x2Djoin:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L855_0:
    mov r12, qword ptr [rbx+0]
    mov r13, qword ptr [rbx+8]
    mov rsi, 0
    cmp r13, 2
    jl .L855_1
    lea rdi, [r13*8]
    mov r8, 1
    mov rsi, r8
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
.L855_1:
    mov r14, rsi
    cmp r14, 0
    je .L855_2
    mov rsi, 0
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r14
    mov rcx, r13
    call zy_local_x2Fmain_0__os__os_x2Dsort
    mov rdi, r14
    call zyl_rt_free
.L855_2:
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
    jne .L855_3
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
.L855_3:
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L856_0:
    mov rdi, 24
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L856_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L856_1:
    mov rsi, 0
    mov qword ptr [r13+0], rsi
    mov rsi, 0
    mov qword ptr [r13+8], rsi
    mov rsi, 0
    mov qword ptr [r13+16], rsi
    cmp rbx, 0
    je .L856_4
    cmp r12, 0
    jne .L856_2
.L856_4:
    jmp .L856_3
.L856_2:
    lea rax, [rip+.L857]
    mov rsi, rax
    mov rdi, rbx
    mov rdx, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__os__os_x2Dwalk
.L856_3:
    mov rdi, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Djoin
.globl zyl_list_zyl_files
zyl_list_zyl_files:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L858_0:
    mov rbx, rdi
    lea rax, [rip+.L859]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L858_1
    mov rdi, 0
    mov rsi, 0
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.L858_1:
    lea rax, [rip+.L860]
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.globl zyl_list_files
zyl_list_files:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L861_0:
    mov rbx, rdi
    mov r12, rsi
    lea rax, [rip+.L862]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    jne .L861_2
    lea rax, [rip+.L863]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L861_1
.L861_2:
    mov rdi, 0
    mov rsi, 0
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.L861_1:
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
zy_local_x2Fmain_0__os__os_x2Dterm_x2Dstate:
    # frame 0
.L864_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__os__os_x2Dterm_x2Dsaved:
    # frame 0
.L865_0:
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_term_is_tty
zyl_term_is_tty:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L866_0:
    mov rsi, 21505
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_tios@tpoff]
    mov r8, rax
    mov rdx, r8
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L866_1
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L866_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dtcset:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L867_0:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L868_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 1
    jne .L868_1
    mov rax, qword ptr [rbx+0]
    cmp rax, 1
    jne .L868_1
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
    lea rax, [rip+.L869]
    mov rsi, rax
    mov r8, 12
    mov rdx, r8
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L868_1:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_raw_on
zyl_term_raw_on:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L870_0:
    mov rdi, 0
    call zyl_term_is_tty
    cmp rax, 0
    jne .L870_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L870_1:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 1
    jne .L870_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L870_2:
    mov rax, qword ptr [rbx+0]
    cmp rax, 1
    jne .L870_3
    mov rsi, 1
    jmp .L870_4
.L870_3:
    mov rdi, 0
    mov r8, 21505
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov r9, rax
    mov rsi, r8
    mov rdx, r9
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L870_5
    mov rdi, 1
    mov qword ptr [rbx+0], rdi
    call zyl_term_atexit
    mov rdi, 1
    jmp .L870_6
.L870_5:
    mov rdi, 0
.L870_6:
    mov rsi, rdi
.L870_4:
    mov rax, rsi
    cmp rax, 0
    jne .L870_7
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L870_7:
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
    je .L870_8
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L870_8:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L871_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 1
    jne .L871_2
    mov rax, qword ptr [rbx+0]
    cmp rax, 1
    je .L871_1
.L871_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L871_1:
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rdi, 0
    mov r8, 21508
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_16
    cmp rax, 0
    je .L871_3
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L871_3:
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_read_byte
zyl_term_read_byte:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L872_0:
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
    jne .L872_1
    movzx eax, byte ptr [rbx+0]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L872_1:
    cmp rsi, -4
    jne .L872_2
    mov rax, -2
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L872_2:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_read_byte_timeout
zyl_term_read_byte_timeout:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L873_0:
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
    jne .L873_1
    mov rax, -3
    mov rsp, rbp
    pop rbp
    ret
.L873_1:
    cmp rsi, 0
    jge .L873_2
    cmp rsi, -4
    jne .L873_3
    mov rax, -2
    mov rsp, rbp
    pop rbp
    ret
.L873_3:
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L873_2:
    mov rsp, rbp
    pop rbp
    jmp zyl_term_read_byte
zy_local_x2Fmain_0__os__os_x2Dwinsz:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L874_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_winsz@tpoff]
    mov r13, rax
    mov rdi, 1
    mov rsi, 21523
    mov rdx, r13
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L874_1
    lea rsi, [r13+rbx]
    movzx esi, word ptr [rsi+0]
    cmp rsi, 0
    jle .L874_2
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L874_2:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L874_1:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_width
zyl_term_width:
    # frame 0
.L875_0:
    mov rdi, 2
    mov rsi, 80
    jmp zy_local_x2Fmain_0__os__os_x2Dwinsz
.globl zyl_term_height
zyl_term_height:
    # frame 0
.L876_0:
    mov rdi, 0
    mov rsi, 24
    jmp zy_local_x2Fmain_0__os__os_x2Dwinsz
.globl zyl_term_write
zyl_term_write:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L877_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L877_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L877_1:
    lea rax, [rip+.L878]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L877_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L877_2:
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
    # frame 32
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
.L879_0:
    cmp r13, r12
    jl .L879_1
.L879_4:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L879_1:
    mov rdi, 1
    lea rsi, [rbx+r13]
    mov r8, r12
    sub r8, r13
    mov rdx, r8
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L879_2
    add r13, rsi
    cmp r13, r12
    jl .L879_1
    jmp .L879_4
.L879_2:
    cmp rsi, -4
    jne .L879_3
    cmp r13, r12
    jl .L879_1
    jmp .L879_4
.L879_3:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf:
    # frame 0
.L880_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_uf_reset
zyl_uf_reset:
    # frame 0
.L881_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+16], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dgrow:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L882_0:
    mov rax, qword ptr [rbx+24]
    cmp rax, 0
    jne .L882_1
    mov rsi, 4096
    jmp .L882_2
.L882_1:
    mov rsi, qword ptr [rbx+24]
    shl rsi, 1
.L882_2:
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
    je .L882_5
    cmp r14, 0
    jne .L882_3
.L882_5:
    mov rdi, r12
    shl rdi, 4
    lea rax, [rip+.L883]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L882_4
.L882_3:
.L882_4:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L884_0:
    lea rax, [rip+zyl_rtg_uf]
    mov r12, rax
    mov rsi, qword ptr [r12+16]
    mov rax, qword ptr [r12+24]
    cmp rsi, rax
    jne .L884_1
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dgrow
    jmp .L884_2
.L884_1:
.L884_2:
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
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Droot:
    # frame 0
.L885_0:
    lea r8, [rsi*8]
    add r8, rdi
    mov r8, qword ptr [r8+0]
    cmp r8, rsi
    jne .L885_1
    mov rax, rsi
    ret
.L885_1:
    mov rsi, r8
    jmp .L885_0
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dcompress:
    # frame 0
    mov r8, rdx
.L886_0:
    lea r9, [rsi*8]
    add r9, rdi
    mov r9, qword ptr [r9+0]
    cmp r9, r8
    jne .L886_1
    mov rax, 0
    ret
.L886_1:
    lea r10, [rsi*8]
    add r10, rdi
    mov qword ptr [r10+0], r8
    mov rsi, r9
    jmp .L886_0
.globl zyl_uf_find
zyl_uf_find:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L887_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    cmp rbx, 0
    jl .L887_2
    mov rax, qword ptr [rsi+16]
    cmp rbx, rax
    jl .L887_1
.L887_2:
    mov rax, rbx
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L887_1:
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
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok:
    # frame 0
.L888_0:
    cmp rdi, 0
    jl .L888_1
.L888_2:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rsi, qword ptr [rsi+16]
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    ret
.L888_1:
    mov rax, 0
    ret
.globl zyl_uf_union
zyl_uf_union:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L889_0:
    call zyl_uf_find
    mov r12, rax
    mov rdi, rbx
    call zyl_uf_find
    mov rbx, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    je .L889_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    jne .L889_1
.L889_2:
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
.L889_1:
    cmp r12, rbx
    jne .L889_3
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
.L889_3:
    mov rsi, r12
    cmp r12, rbx
    jl .L889_4
    mov rsi, rbx
.L889_4:
    mov rdi, rbx
    cmp r12, rbx
    jl .L889_5
    mov rdi, r12
.L889_5:
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
    jle .L889_6
    lea r9, [rsi*8]
    add r9, r8
    lea r10, [rdi*8]
    add r8, r10
    mov r8, qword ptr [r8+0]
    mov qword ptr [r9+0], r8
    jmp .L889_7
.L889_6:
.L889_7:
    lea rax, [rip+zyl_rtg_uf]
    mov r8, rax
    mov r8, qword ptr [r8+0]
    shl rdi, 3
    add r8, rdi
    mov qword ptr [r8+0], rsi
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_uf_raise
zyl_uf_raise:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L890_0:
    call zyl_uf_find
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    jne .L890_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L890_1:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rsi, qword ptr [rsi+8]
    lea rdi, [r12*8]
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    cmp rbx, rax
    jle .L890_2
    mov qword ptr [rsi+0], rbx
    jmp .L890_3
.L890_2:
.L890_3:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_uf_level
zyl_uf_level:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L891_0:
    call zyl_uf_find
    mov rbx, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    jne .L891_1
    mov rax, 2
    pop rbx
    pop rbp
    ret
.L891_1:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rsi, qword ptr [rsi+8]
    lea rdi, [rbx*8]
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__misc__rt_x2Dnote:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L892_0:
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
    # frame 0
.L893_0:
    mov rax, QWORD PTR [rip+malloc@GOTPCREL]
    mov rsi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov r8, rax
    mov rax, qword ptr [r8+0]
    cmp rax, 0
    jne .L893_1
    cmp rsi, 0
    jle .L893_1
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zyl_rt_call1
.L893_1:
    mov rsi, 1
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
.globl zyl_mem_free
zyl_mem_free:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L894_0:
    mov rax, QWORD PTR [rip+free@GOTPCREL]
    mov rsi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov r8, rax
    mov rax, qword ptr [r8+0]
    cmp rax, 0
    jne .L894_1
    cmp rsi, 0
    jle .L894_1
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_call1
    jmp .L894_2
.L894_1:
    call zyl_rt_free
.L894_2:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mem_read
zyl_mem_read:
    # frame 0
.L895_0:
    cmp rdi, 0
    jne .L895_1
.L895_2:
    lea rax, [rip+.L896]
    mov rsi, rax
    mov rdi, rsi
    jmp zy_local_x2Fmain_0__misc__rt_x2Dnote
.L895_1:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_mem_write
zyl_mem_write:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rsi
.L897_0:
    cmp rdi, 0
    jne .L897_1
.L897_2:
    lea rax, [rip+.L898]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__misc__rt_x2Dnote
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L897_1:
    mov qword ptr [rdi+0], rbx
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.globl zyl_cstr_byte_set
zyl_cstr_byte_set:
    # frame 0
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L899_0:
    cmp rdi, 0
    je .L899_2
.L899_4:
    cmp rsi, 0
    jge .L899_1
.L899_2:
    mov rax, 0
    pop rbp
    ret
.L899_1:
    cmp rdi, 4096
    jge .L899_3
    lea rax, [rip+.L900]
    mov r9, rax
    mov rsi, r9
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
.L899_3:
    add rsi, rdi
    mov rdi, r8
    and rdi, 255
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, 0
    pop rbp
    ret
.globl zyl_getenv
zyl_getenv:
    # frame 0
.L901_0:
    jmp zyl_rt_getenv
.globl zyl_regions_enabled
zyl_regions_enabled:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L902_0:
    lea rax, [rip+.L903]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    cmp rsi, 0
    jle .L902_1
    movzx eax, byte ptr [rsi+0]
    cmp rax, 48
    jne .L902_1
    movzx eax, byte ptr [rsi+1]
    cmp rax, 0
    jne .L902_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L902_1:
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_region_poison_enabled
zyl_region_poison_enabled:
    # frame 0
    push rbp
    mov rbp, rsp
.L904_0:
    call zyl_region_poison_level
    mov rsi, rax
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    pop rbp
    ret
.globl zyl_region_poison_level
zyl_region_poison_level:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L905_0:
    lea rax, [rip+.L906]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    cmp rsi, 0
    jne .L905_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L905_1:
    movzx eax, byte ptr [rsi+0]
    cmp rax, 49
    jne .L905_2
    movzx eax, byte ptr [rsi+1]
    cmp rax, 0
    jne .L905_2
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L905_2:
    movzx eax, byte ptr [rsi+0]
    cmp rax, 50
    jne .L905_3
    movzx eax, byte ptr [rsi+1]
    cmp rax, 0
    jne .L905_3
    mov rax, 2
    mov rsp, rbp
    pop rbp
    ret
.L905_3:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__misc__rt_x2Dlshr64:
    # frame 0
.L907_0:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L908_0:
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
    pop rbp
    ret
.globl zyl_str_append_scan
zyl_str_append_scan:
    # frame 64
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
.L909_0:
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
    jne .L909_1
    lea rsi, [r14+512]
    lea rdi, [r15*8]
    add rsi, rdi
    mov rsi, qword ptr [rsi+0]
    jmp .L909_2
.L909_1:
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rdi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, rdi
.L909_2:
    mov rbx, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov qword ptr [rbp-56], rax
    cmp r13, 0
    jle .L909_3
    mov rsi, rbx
    sub rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-56]
    lea rax, [rsi+1]
    cmp rax, r13
    jle .L909_3
    lea rax, [rip+.L910]
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.L909_3:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rsi
.L911_0:
    cmp rdi, 0
    je .L911_2
.L911_3:
    cmp rbx, 0
    jg .L911_1
.L911_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L911_1:
    mov rsi, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Dzero_x2Dbytes
    mov rax, rbx
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Dzero_x2Dbytes:
    # frame 0
.L912_0:
    cmp rsi, 0
    jg .L912_1
.L912_2:
    mov rax, 0
    ret
.p2align 4
.L912_1:
    mov r8, 0
    mov byte ptr [rdi+0], r8b
    add rdi, 1
    sub rsi, 1
    cmp rsi, 0
    jg .L912_1
    jmp .L912_2
zy_local_x2Fmain_0__crypto__cr_x2Dwipe:
    # frame 0
.L913_0:
    cmp rsi, 0
    jg .L913_1
.L913_2:
    mov rax, 0
    ret
.p2align 4
.L913_1:
    mov r8, 0
    mov qword ptr [rdi+0], r8
    add rdi, 8
    sub rsi, 8
    cmp rsi, 0
    jg .L913_1
    jmp .L913_2
zy_local_x2Fmain_0__crypto__cr_x2Dpack:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L914_0:
    cmp r9, r8
    jl .L914_1
.L914_2:
    mov rax, 0
    ret
.p2align 4
.L914_1:
    lea r10, [rdi+r9]
    lea r11, [r9*8]
    add r11, rsi
    mov r11, qword ptr [r11+0]
    mov byte ptr [r10+0], r11b
    add r9, 1
    cmp r9, r8
    jl .L914_1
    jmp .L914_2
zy_local_x2Fmain_0__crypto__cr_x2Dunpack:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L915_0:
    cmp r9, r8
    jl .L915_1
.L915_2:
    mov rax, 0
    ret
.p2align 4
.L915_1:
    lea r10, [r9*8]
    add r10, rdi
    lea r11, [rsi+r9]
    movzx r11d, byte ptr [r11+0]
    mov qword ptr [r10+0], r11
    add r9, 1
    cmp r9, r8
    jl .L915_1
    jmp .L915_2
zy_local_x2Fmain_0__crypto__cr_x2Dwords_x2Ddata:
    # frame 0
    push rbp
    mov rbp, rsp
.L916_0:
    lea rax, [rip+.L917]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov rax, qword ptr [rsi+16]
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock:
    # frame 0
    push rbp
    mov rbp, rsp
.L918_0:
    call zyl_words_len
    mov rsi, rax
    cmp rsi, 16
    jge .L918_1
    lea rax, [rip+.L919]
    mov rdi, rax
    mov r8, 15
    mov rdx, rsi
    mov rsi, r8
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L918_1:
    mov rax, 0
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Dscratch:
    # frame 0
.L920_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_aes@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Drounds:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L921_0:
    cmp r8, r9
    jge .L921_1
.L921_2:
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
    jge .L921_1
    jmp .L921_2
.L921_1:
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
    # frame 64
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
.L922_0:
    call zyl_cpuid_features
    mov rsi, rax
    and rsi, 1
    cmp rsi, 0
    jg .L922_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L922_1:
    cmp qword ptr [rbp-48], 16
    je .L922_2
    cmp qword ptr [rbp-48], 32
    je .L922_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L922_2:
    mov rdi, rbx
    call zyl_words_len
    cmp rax, qword ptr [rbp-48]
    jge .L922_3
    lea rax, [rip+.L923]
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
    jmp .L922_4
.L922_3:
.L922_4:
    lea rax, [rip+.L924]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov rbx, qword ptr [rsi+16]
    mov rdi, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock
    lea rax, [rip+.L925]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov r12, qword ptr [rsi+16]
    mov rdi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock
    lea rax, [rip+.L926]
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
    je .L922_5
    mov rsi, 14
.L922_5:
    cmp qword ptr [rbp-48], 16
    jne .L922_6
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
    jmp .L922_7
.L922_6:
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
.L922_7:
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
    # frame 32
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
.L927_0:
    cmp r13, r12
    jl .L927_1
.L927_4:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L927_1:
    lea rdi, [rbx+r13]
    mov rsi, r12
    sub rsi, r13
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_318
    mov rsi, rax
    cmp rsi, 0
    jge .L927_2
    cmp rsi, -4
    jne .L927_3
    cmp r13, r12
    jl .L927_1
    jmp .L927_4
.L927_3:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L927_2:
    add r13, rsi
    cmp r13, r12
    jl .L927_1
    jmp .L927_4
zy_local_x2Fmain_0__crypto__cr_x2Dread_x2Dall:
    # frame 32
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
.L928_0:
    cmp r14, r13
    jl .L928_1
.L928_4:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L928_1:
    lea rsi, [r12+r14]
    mov rdi, r13
    sub rdi, r14
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L928_2
    add r14, rsi
    cmp r14, r13
    jl .L928_1
    jmp .L928_4
.L928_2:
    cmp rsi, -4
    jne .L928_3
    cmp r14, r13
    jl .L928_1
    jmp .L928_4
.L928_3:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Durandom:
    # frame 32
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
.L929_0:
    lea rax, [rip+.L930]
    mov rdi, rax
    mov rsi, 524288
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_2
    mov r14, rax
    cmp r14, 0
    jge .L929_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L929_1:
    mov rdi, r14
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dread_x2Dall
    mov rbx, rax
    mov rdi, r14
    call zyl_rt_sys_3
    cmp rbx, r12
    jne .L929_2
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L929_2:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L931_0:
    cmp rbx, 0
    je .L931_2
.L931_4:
    cmp r12, 0
    jg .L931_1
.L931_2:
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L931_1:
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__crypto__cr_x2Dgetrandom
    mov rsi, rax
    cmp rsi, r12
    jne .L931_3
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
.L931_3:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__crypto__cr_x2Durandom
zy_local_x2Fmain_0__crypto__cr_x2Drand_x2Dchunks:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L932_0:
    cmp r13, r12
    jl .L932_1
.L932_6:
    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L932_1:
    mov rax, r12
    sub rax, r13
    cmp rax, 256
    jle .L932_2
    mov rsi, 256
    jmp .L932_3
.L932_2:
    mov rsi, r12
    sub rsi, r13
.L932_3:
    mov r15, rsi
    mov rdi, r14
    mov rsi, r15
    call zyl_random_fill
    cmp rax, r15
    je .L932_4
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L932_4:
    lea rsi, [r13*8]
    lea rdi, [rbx+rsi]
    mov rsi, 0
    cmp rsi, r15
    jge .L932_5
    mov rdx, r15
    mov rcx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dunpack
.L932_5:
    add r13, r15
    cmp r13, r12
    jl .L932_1
    jmp .L932_6
.globl zyl_random_words
zyl_random_words:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
.L933_0:
    cmp rbx, 0
    je .L933_2
.L933_5:
    cmp r12, 0
    jg .L933_1
.L933_2:
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L933_1:
    lea rax, [rip+.L934]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov r13, qword ptr [rsi+16]
    mov rdi, rbx
    call zyl_words_len
    cmp r12, rax
    jle .L933_3
    lea rax, [rip+.L935]
    mov r14, rax
    lea r15, [r12-1]
    mov rdi, rbx
    call zyl_words_len
    mov rsi, rax
    mov rdi, r14
    mov rdx, rsi
    mov rsi, r15
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L933_4
.L933_3:
.L933_4:
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
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dguard:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L936_0:
    cmp rdi, 4096
    jge .L936_1
.L936_2:
    lea rax, [rip+.L937]
    mov rbx, rax
    lea rax, [rip+.L938]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dhex
    mov rdi, rax
    lea rax, [rip+.L939]
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
.L936_1:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dcode_x2Dp:
    # frame 0
.L940_0:
    mov rsi, 4294967296
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    ret
.globl zyl_call0
zyl_call0:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L941_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L941_1
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zyl_rt_call0
.L941_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, rbx
    pop rbx
    pop rbp
    jmp zyl_rt_call1
.globl zyl_call1
zyl_call1:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L942_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L942_1
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_call1
.L942_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, rbx
    mov rdx, r12
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_call2
.globl zyl_call2
zyl_call2:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L943_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L943_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_call2
.L943_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_call3
.globl zyl_call3
zyl_call3:
    # frame 32
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
.L944_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L944_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_call3
.L944_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    mov r8, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_call4
.globl zyl_call4
zyl_call4:
    # frame 48
    push rbp
    mov rbp, rsp
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
.L945_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L945_1
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
    pop rbp
    jmp zyl_rt_call4
.L945_1:
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
    pop rbp
    jmp zyl_rt_call5
.globl zyl_call5
zyl_call5:
    # frame 152
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
    jge .L946
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
    jmp .L947
.L946:
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
.L947:
    mov rbx, [rbp-152]
    mov r12, [rbp-144]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_call6
zyl_call6:
    # frame 168
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
    jge .L948
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
    jmp .L949
.L948:
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
.L949:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dmin64:
    # frame 0
.L950_0:
    mov rax, -9223372036854775808
    ret
zy_local_x2Fmain_0__call__rt_x2Dult:
    # frame 0
.L951_0:
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
    # frame 264
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
    jge .L952
    mov rax, 0
    jmp .L953
.L952:
    mov rax, 1
.L953:
    mov [rbp-104], rax
    mov rax, [rbp-104]
    test rax, rax
    je .L954
    mov rax, [rbp-88]
    mov rcx, 1
    add rax, rcx
    jmp .L955
.L954:
    mov rax, [rbp-88]
.L955:
    mov [rbp-112], rax
    mov rax, [rbp-104]
    test rax, rax
    je .L956
    mov rax, [rbp-96]
    mov rcx, [rbp-24]
    sub rax, rcx
    jmp .L957
.L956:
    mov rax, [rbp-96]
.L957:
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
    jge .L958
    mov rax, 0
    jmp .L959
.L958:
    mov rax, 1
.L959:
    mov [rbp-144], rax
    mov rax, [rbp-144]
    test rax, rax
    je .L960
    mov rax, [rbp-128]
    mov rcx, 1
    add rax, rcx
    jmp .L961
.L960:
    mov rax, [rbp-128]
.L961:
    mov [rbp-152], rax
    mov rax, [rbp-144]
    test rax, rax
    je .L962
    mov rax, [rbp-136]
    mov rcx, [rbp-16]
    sub rax, rcx
    jmp .L963
.L962:
    mov rax, [rbp-136]
.L963:
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
    jge .L966
    mov rax, 1
    jmp .L967
.L966:
    mov rax, [rbp-112]
    mov rcx, [rbp-168]
    cmp rax, rcx
    jne .L968
    mov rax, [rbp-120]
    mov rcx, 0
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L969
.L968:
    mov rax, 0
.L969:
.L967:
    test rax, rax
    je .L964
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
    jmp .L965
.L964:
    mov rax, [rbp-72]
    test rax, rax
    je .L970
    mov rax, [rbp-80]
    mov rcx, 64
    sub rax, rcx
    jmp .L971
.L970:
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jge .L972
    mov rax, [rbp-152]
    mov rcx, 1
    add rax, rcx
    mov rcx, rax
    mov rax, 0
    sub rax, rcx
    jmp .L973
.L972:
    mov rax, [rbp-152]
    mov rcx, 1
    add rax, rcx
.L973:
.L971:
.L965:
    mov rbx, [rbp-264]
    mov r12, [rbp-256]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dmagic:
    # frame 168
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
    jg .L976
    mov rax, [rbp-8]
    mov rcx, -1
    cmp rax, rcx
    setge al
    movzx rax, al
    jmp .L977
.L976:
    mov rax, 0
.L977:
    test rax, rax
    je .L974
    mov rax, 0
    jmp .L975
.L974:
    mov rax, -9223372036854775808
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jge .L978
    mov rax, 0
    mov rcx, [rbp-8]
    sub rax, rcx
    jmp .L979
.L978:
    mov rax, [rbp-8]
.L979:
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
.L975:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_div_magic
zyl_div_magic:
    # frame 0
.L980_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic
.globl zyl_div_shift
zyl_div_shift:
    # frame 0
.L981_0:
    mov rsi, 1
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic
zy_local_x2Fmain_0__ffitab__ft_x2Dslots:
    # frame 0
.L982_0:
    lea rax, [rip+zyl_rtg_ffitab_slots]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dprobe:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L983_0:
    mov rsi, r13
    shl rsi, 4
    lea r14, [rbx+rsi]
    mov rdi, qword ptr [r14+0]
    cmp rdi, 0
    je .L983_2
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L983_1
.L983_2:
    mov rax, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L983_1:
    add r13, 1
    and r13, 1023
    jmp .L983_0
zy_local_x2Fmain_0__ffitab__ft_x2Dput:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rdx
.L984_0:
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
    jne .L984_1
    mov qword ptr [rsi+8], r12
    mov qword ptr [rsi+0], r13
    mov rsi, r13
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L984_1:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dtable:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L985_0:
    lea rax, [rip+zyl_rtg_ffitab_state]
    mov rbx, rax
    mov rsi, qword ptr [rbx+0]
    cmp rsi, 2
    jne .L985_1
    lea rax, [rip+zyl_rtg_ffitab_slots]
    mov rdi, rax
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L985_1:
    cmp rsi, 0
    jne .L985_2
    mov rsi, 0
    mov rdi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov r11, rdi
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, 0
    jne .L985_2
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
.L985_2:
    call zyl_rt_sys_24
    jmp .L985_0
zy_local_x2Fmain_0__ffitab__ft_x2Dfind:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L986_0:
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
    jne .L986_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L986_1:
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_runtime_export_p
zyl_runtime_export_p:
    # frame 0
    push rbp
    mov rbp, rsp
.L987_0:
    cmp rdi, 0
    jne .L987_1
    mov rax, 0
    pop rbp
    ret
.L987_1:
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfind
    mov rsi, rax
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    pop rbp
    ret
.globl zyl_ffi_lookup
zyl_ffi_lookup:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L988_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L988_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L988_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jle .L988_2
    mov rax, qword ptr [rsi+8]
    pop rbx
    pop rbp
    ret
.L988_2:
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__ffitab__ft_x2Ddlsym
.globl zyl_ffi_addr
zyl_ffi_addr:
    # frame 0
.L989_0:
    jmp zyl_ffi_lookup
zy_local_x2Fmain_0__ffitab__ft_x2Dnote:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L990_0:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L991_0:
    lea rax, [rip+.L992]
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
    jne .L991_1
    mov rsi, r12
    call zyl_cstr_concat
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L991_1:
    mov rbx, rsi
    mov rsi, r12
    call zyl_cstr_concat
    mov r12, rax
    jmp .L991_0
.globl zyl_call_argv
zyl_call_argv:
    # frame 168
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
    jge .L993
    lea rax, [rip+.L995]
    sub rsp, 8
    mov [rsp], rax
    sub rsp, 16
    lea rax, [rip+.L996]
    mov rsi, rax
    mov rdi, [rbp-8]
call zy_local_x2Fmain_0__ffitab__ft_x2Dhex
    add rsp, 16
    sub rsp, 8
    mov [rsp], rax
    lea rax, [rip+.L997]
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
    jmp .L994
.L993:
    mov rax, [rbp-16]
    mov rcx, 0
    cmp rax, rcx
    jge .L1000
    mov rax, 1
    jmp .L1001
.L1000:
    mov rax, [rbp-16]
    mov rcx, 6
    cmp rax, rcx
    setg al
    movzx rax, al
.L1001:
    test rax, rax
    je .L998
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitab__ft_x2Dargc_x2Dbad
    jmp .L999
.L998:
    mov rax, [rbp-16]
    mov rcx, 0
    cmp rax, rcx
    jne .L1002
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-8]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call0
    mov rsp, r12
    add rsp, 16
    jmp .L1003
.L1002:
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov rcx, 1
    cmp rax, rcx
    jne .L1004
    sub rsp, 16
    mov rdi, [rbp-8]
    mov rsi, [rbp-32]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call1
    mov rsp, r12
    add rsp, 16
    jmp .L1005
.L1004:
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-40], rax
    mov rax, [rbp-16]
    mov rcx, 2
    cmp rax, rcx
    jne .L1006
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
    jmp .L1007
.L1006:
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-48], rax
    mov rax, [rbp-16]
    mov rcx, 3
    cmp rax, rcx
    jne .L1008
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
    jmp .L1009
.L1008:
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-56], rax
    mov rax, [rbp-16]
    mov rcx, 4
    cmp rax, rcx
    jne .L1010
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
    jmp .L1011
.L1010:
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-64], rax
    mov rax, [rbp-16]
    mov rcx, 5
    cmp rax, rcx
    jne .L1012
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
    jmp .L1013
.L1012:
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
.L1013:
.L1011:
.L1009:
.L1007:
.L1005:
.L1003:
.L999:
.L994:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dargc_x2Dbad:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1014_0:
    lea rax, [rip+.L1015]
    mov rbx, rax
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L1016]
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1017_0:
    lea rax, [rip+.L1018]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_pin@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1019]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_unpin@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1020]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_init@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1021]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_is_alive@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1022]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_spawn@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1023]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1024]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_recv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1025]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_rx@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1026]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_send@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1027]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_tx@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1028]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_wait@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1029]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_wait_all@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1030]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_aes_encrypt_block@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1031]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_aesni_available@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1032]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_align_check@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1033]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1034]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_alloc_zeroed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D1:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1035_0:
    lea rax, [rip+.L1036]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_capacity@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1037]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_create@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1038]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_destroy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1039]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1040]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_used@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1041]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arg_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1042]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_argc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1043]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1044]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_cas@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1045]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_fetch_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1046]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_load@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1047]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_max@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1048]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_min@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1049]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_store@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1050]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1051]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_blake3_file_hex@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D2:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1052_0:
    lea rax, [rip+.L1053]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_blake3_hex@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1054]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_byte_slice@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1055]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_byte_slice_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1056]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_append@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1057]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1058]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_cas@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1059]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_fetch_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1060]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_load@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1061]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_max@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1062]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_min@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1063]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_store@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1064]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1065]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_cap@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1066]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1067]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_blake3_hex@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1068]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1069]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_ptr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D3:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1070_0:
    lea rax, [rip+.L1071]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call0@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1072]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call1@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1073]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call2@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1074]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call3@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1075]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call4@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1076]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call5@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1077]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call6@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1078]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call_argv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1079]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call_on_big_stack@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1080]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cc_compile@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1081]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cc_compile_log@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1082]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chdir@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1083]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cpuid_features@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1084]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_byte_at@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1085]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_byte_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1086]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_concat@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D4:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1087_0:
    lea rax, [rip+.L1088]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_count_newlines@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1089]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_decode@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1090]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1091]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_eq@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1092]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_from_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1093]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_from_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1094]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_key_matches@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1095]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_div_magic@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1096]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_div_shift@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1097]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1098]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_ok@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1099]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1100]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1101]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_find@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1102]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1103]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_last_newline@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D5:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1104_0:
    lea rax, [rip+.L1105]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1106]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_of_word@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1107]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_float_bits@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1108]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_float_of_bits@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1109]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_word_load@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1110]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_word_store@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1111]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ptr_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1112]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ptr_cstr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1113]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_addr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1114]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_sanitize@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1115]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1116]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_substr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1117]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_to_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1118]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_to_int_base@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1119]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_diag_json@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1120]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_diag_json_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D6:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1121_0:
    lea rax, [rip+.L1122]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_dirname_cstr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1123]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1124]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1125]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1126]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1127]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ensure_arenas@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1128]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_exec_cmd@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1129]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1130]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1131]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_div@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1132]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_error@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1133]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_mul@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1134]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_of_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1135]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_parse@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1136]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_rem@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1137]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D7:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1138_0:
    lea rax, [rip+.L1139]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_text@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1140]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_to_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1141]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_lookup@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1142]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_timed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1143]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_timed_argv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1144]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_close_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1145]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_exit@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1146]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_read_line@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1147]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_open_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1148]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_read_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1149]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_write_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1150]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fnmap_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1151]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fnmap_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1152]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fnmap_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1153]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fresh_id@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1154]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_getcwd@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D8:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1155_0:
    lea rax, [rip+.L1156]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_getenv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1157]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_contract_warn@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1158]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_err_is@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1159]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_list_zyl_files@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1160]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_list_files@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1161]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_n@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1162]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_n_signed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1163]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_store_n@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1164]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1165]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1166]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_ready@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1167]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1168]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1169]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1170]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_ready@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1171]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D9:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1172_0:
    lea rax, [rip+.L1173]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_repl_global_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1174]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_repl_global_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1175]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_id@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1176]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1177]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1178]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_find@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1179]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_union@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1180]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_raise@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1181]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_level@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1182]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_regions_enabled@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1183]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1184]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1185]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_alloc_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1186]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1187]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1188]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1189]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_view@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1190]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_view_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1191]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_has@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D10:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1192_0:
    lea rax, [rip+.L1193]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_get_or@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1194]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1195]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_vec_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1196]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_vec_alloc_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1197]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_cap@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1198]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_filled@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1199]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1200]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1201]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1202]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1203]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_get_or@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1204]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_has@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1205]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1206]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1207]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ref_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1208]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ref_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1209]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ref_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1210]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_getenv_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D11:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1211_0:
    lea rax, [rip+.L1212]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_strbuf_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1213]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_strbuf_new_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1214]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_strbuf_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1215]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_escapes_ok@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1216]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_heap_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1217]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ralloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1218]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_enter@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1219]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_exit@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1220]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_free@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1221]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_scope_enter@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1222]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_live_bytes@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1223]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_heap_block_p@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1224]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_heap_swap@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1225]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_int_text@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1226]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1227]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_count@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1228]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_fn@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D12:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1229_0:
    lea rax, [rip+.L1230]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_name@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1231]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_outcome@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1232]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_fail@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1233]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1234]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_start@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1235]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_summary@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1236]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_json_quote@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1237]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1238]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_byte_signed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1239]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mangle_key@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1240]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1241]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_free@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1242]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_read@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1243]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_write@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1244]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mkdir_p@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1245]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mlock@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1246]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_panic@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D13:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1247_0:
    lea rax, [rip+.L1248]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_path_exists@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1249]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_pin_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1250]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_print_float@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1251]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_print_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1252]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_print_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1253]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_random_fill@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1254]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_random_words@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1255]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_run_bin@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1256]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_session_arena@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1257]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1258]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1259]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_global@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1260]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1261]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1262]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_source_path@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1263]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_source_register@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D14:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1264_0:
    lea rax, [rip+.L1265]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_col@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1266]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1267]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_file@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1268]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_line@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1269]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_line_text@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1270]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_off@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1271]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_snippet@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1272]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_snippet_col@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1273]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_offset_at@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1274]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1275]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_store_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1276]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_store_byte_signed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1277]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_str_append@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1278]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_str_append_capped@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1279]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_sym_escape@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1280]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_system_cmd@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D15:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1281_0:
    lea rax, [rip+.L1282]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_flush@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1283]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_height@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1284]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_is_tty@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1285]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_raw_off@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1286]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_raw_on@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1287]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_read_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1288]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_read_byte_timeout@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1289]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_width@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1290]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_write@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1291]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_frame_msg@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1292]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_last_msg@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1293]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_pop@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1294]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_push@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1295]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_variant_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1296]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_variant_eq@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1297]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_variant_field@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill_x2D16:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1298_0:
    lea rax, [rip+.L1299]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_warn_capture@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1300]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_warn_emit@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1301]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_warn_take@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1302]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_word_of_cstr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1303]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1304]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_global@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1305]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1306]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1307]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_pop@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1308]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_push@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1309]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1310]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_truncate@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1311]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_zeroize@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Dfill:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1312_0:
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
    pop rbp
    ret
zy_local_x2Fmain_0__ffitab__ft_x2Ddlsym:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1313_0:
    mov rax, QWORD PTR [rip+dlsym@GOTPCREL]
    mov rsi, rax
    cmp rsi, 0
    jne .L1313_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1313_1:
    mov r8, 0
    mov rdx, rdi
    mov rdi, rsi
    mov rsi, r8
    call zyl_rt_call2
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dint:
    # frame 0
.L1314_0:
    mov rsi, 4294967295
    and rsi, rdi
    cmp rsi, 2147483647
    jle .L1314_1
    mov rdi, 4294967296
    mov rax, rsi
    sub rax, rdi
    ret
.L1314_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__proc__pr_x2Denviron:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1315_0:
    call zyl_rt_envp
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dscratch:
    # frame 0
    push rbp
    mov rbp, rsp
.L1316_0:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov rsi, rax
    mov rax, rsi
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dpid:
    # frame 0
.L1317_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__proc__pr_x2Dstatus:
    # frame 0
.L1318_0:
    lea rax, [rdi+8]
    ret
zy_local_x2Fmain_0__proc__pr_x2Dargv:
    # frame 0
.L1319_0:
    lea rax, [rdi+16]
    ret
zy_local_x2Fmain_0__proc__pr_x2Dout:
    # frame 0
.L1320_0:
    lea rax, [rdi+80]
    ret
zy_local_x2Fmain_0__proc__pr_x2Dwait:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1321_0:
    mov rdi, rsi
    call zy_local_x2Fmain_0__proc__pr_x2Dint
    cmp rax, 0
    je .L1321_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1321_1:
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
    jge .L1321_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1321_2:
    mov esi, dword ptr [rbx+8]
    mov rax, rsi
    and rax, 127
    cmp rax, 0
    jne .L1321_3
    shr rsi, 8
    and rsi, 255
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1321_3:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dmap_x2Dsize:
    # frame 0
.L1322_0:
    mov rax, 65536
    ret
zy_local_x2Fmain_0__proc__pr_x2Dbuf:
    # frame 0
.L1323_0:
    lea rax, [rdi+64]
    ret
zy_local_x2Fmain_0__proc__pr_x2Dbuf_x2Dmax:
    # frame 0
.L1324_0:
    mov rax, 4400
    ret
zy_local_x2Fmain_0__proc__pr_x2Dspawn:
    # frame 48
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
.L1325_0:
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
    jge .L1325_1
    cmp qword ptr [rbp-48], -4096
    jle .L1325_1
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
.L1325_1:
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
    je .L1325_2
    mov rsi, 1
    jmp .L1325_3
.L1325_2:
    mov rsi, 0
.L1325_3:
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+32], rsi
    cmp r15, 0
    je .L1325_4
    lea rax, [rip+.L1326]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    jmp .L1325_5
.L1325_4:
    mov rsi, 0
.L1325_5:
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
    # frame 32
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
.L1327_0:
    mov rsi, 0
    sub rsi, r13
    cmp r13, 0
    jl .L1327_1
    mov rsi, qword ptr [r12+40]
.L1327_1:
    mov r14, rsi
    cmp r13, 0
    jle .L1327_2
    cmp r14, 0
    je .L1327_2
    mov rsi, 0
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, r13
    mov rcx, r8
    call zyl_rt_sys_61
    jmp .L1327_3
.L1327_2:
.L1327_3:
    cmp r13, 0
    jle .L1327_4
    cmp r14, 0
    jne .L1327_4
    mov dword ptr [rbx+0], r13d
    jmp .L1327_5
.L1327_4:
.L1327_5:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1328_0:
    mov rbx, qword ptr [rsi+16]
    mov rdi, qword ptr [rbx+24]
    mov rsi, 0
    cmp rdi, 0
    je .L1328_1
    call zy_local_x2Fmain_0__proc__pr_x2Dredirect
    mov rsi, rax
.L1328_1:
    mov rdi, rsi
    cmp rsi, 0
    jl .L1328_2
    mov rax, qword ptr [rbx+32]
    cmp rax, 0
    jne .L1328_3
    mov rsi, qword ptr [rbx+0]
    mov r8, qword ptr [rbx+8]
    mov r9, qword ptr [rbx+16]
    mov rdi, rsi
    mov rsi, r8
    mov rdx, r9
    call zyl_rt_sys_59
    mov rsi, rax
    jmp .L1328_4
.L1328_3:
    mov r8, qword ptr [rbx+0]
    mov rdi, rbx
    mov rsi, r8
    call zy_local_x2Fmain_0__proc__pr_x2Dexecvp
    mov rsi, rax
.L1328_4:
    mov rdi, rsi
.L1328_2:
    mov rsi, rdi
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Ddie
zy_local_x2Fmain_0__proc__pr_x2Ddie:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
    mov r12, rsi
.L1329_0:
    mov rsi, 0
    sub rsi, r12
    mov qword ptr [rbx+40], rsi
    mov rdi, 127
    call zyl_rt_sys_60
    jmp .L1329_0
zy_local_x2Fmain_0__proc__pr_x2Dredirect:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L1330_0:
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
    jge .L1330_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1330_1:
    mov r12, 0
    cmp rbx, 1
    je .L1330_2
    mov rsi, 1
    mov rdi, rbx
    call zyl_rt_sys_33
    mov r12, rax
    mov rdi, rbx
    call zyl_rt_sys_3
.L1330_2:
    cmp r12, 0
    jge .L1330_3
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1330_3:
    mov rdi, 1
    mov rsi, 2
    call zyl_rt_sys_33
    mov rsi, rax
    cmp rsi, 0
    jge .L1330_4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1330_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dhas_x2Dslash:
    # frame 0
.L1331_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 0
    jne .L1331_1
    mov rax, 0
    ret
.L1331_1:
    cmp rsi, 47
    jne .L1331_2
    mov rax, 1
    ret
.L1331_2:
    add rdi, 1
    jmp .L1331_0
zy_local_x2Fmain_0__proc__pr_x2Dstrnlen:
    # frame 0
    mov r8, rdx
.L1332_0:
    cmp r8, rsi
    jge .L1332_2
.L1332_3:
    lea r9, [rdi+r8]
    movzx eax, byte ptr [r9+0]
    cmp rax, 0
    jne .L1332_1
.L1332_2:
    mov rax, r8
    ret
.L1332_1:
    add r8, 1
    cmp r8, rsi
    jge .L1332_2
    jmp .L1332_3
zy_local_x2Fmain_0__proc__pr_x2Dchrnul:
    # frame 0
.L1333_0:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 0
    je .L1333_2
    cmp r8, rsi
    jne .L1333_1
.L1333_2:
    mov rax, rdi
    ret
.L1333_1:
    add rdi, 1
    jmp .L1333_0
zy_local_x2Fmain_0__proc__pr_x2Dexecvp:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
    mov r12, rsi
.L1334_0:
    movzx eax, byte ptr [r12+0]
    cmp rax, 0
    jne .L1334_1
    mov rax, -2
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1334_1:
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dhas_x2Dslash
    cmp rax, 0
    je .L1334_2
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
.L1334_2:
    mov rsi, qword ptr [rbx+48]
    cmp rsi, 0
    jne .L1334_3
    lea rax, [rip+.L1335]
    mov rdi, rax
    jmp .L1334_4
.L1334_3:
    mov rdi, rsi
.L1334_4:
    mov r13, rdi
    mov rsi, 255
    mov rdi, 0
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dstrnlen
    mov rsi, rax
    add rsi, 1
    cmp rsi, 255
    jle .L1334_5
    mov rax, -36
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1334_5:
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
    # frame 0
.L1336_0:
    cmp rdi, 13
    jne .L1336_1
.L1336_6:
    mov rax, 1
    ret
.L1336_1:
    cmp rdi, 2
    jne .L1336_2
    mov rax, 1
    ret
.L1336_2:
    cmp rdi, 116
    jne .L1336_3
    mov rax, 1
    ret
.L1336_3:
    cmp rdi, 20
    jne .L1336_4
    mov rax, 1
    ret
.L1336_4:
    cmp rdi, 19
    jne .L1336_5
    mov rax, 1
    ret
.L1336_5:
    mov rax, rdi
    cmp rax, 110
    sete al
    movzx rax, al
    ret
zy_local_x2Fmain_0__proc__pr_x2Dpath_x2Dloop:
    # frame 64
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
.L1337_0:
    mov rsi, 58
    mov rdi, r14
    call zy_local_x2Fmain_0__proc__pr_x2Dchrnul
    mov rbx, rax
    mov rsi, rbx
    sub rsi, r14
    lea rdi, [r13+1]
    lea rax, [rsi+rdi]
    cmp rax, 4400
    jle .L1337_1
    mov rdi, -36
    jmp .L1337_2
.L1337_1:
    mov rdi, qword ptr [rbp-48]
    mov rdx, rsi
    mov rsi, r14
    mov rcx, qword ptr [rbp-56]
    mov r8, r13
    call zy_local_x2Fmain_0__proc__pr_x2Dexec_x2Dat
    mov rdi, rax
.L1337_2:
    mov r12, rdi
    mov rdi, 0
    sub rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dpath_x2Dnext_x2Dp
    cmp rax, 0
    jne .L1337_3
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1337_3:
    cmp r15, 0
    je .L1337_4
    mov rsi, 1
    jmp .L1337_5
.L1337_4:
    mov rax, r12
    cmp rax, -13
    sete al
    movzx rax, al
    mov rsi, rax
.L1337_5:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L1337_6
    cmp rsi, 0
    je .L1337_7
    mov rax, -13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1337_7:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1337_6:
    lea r14, [rbx+1]
    mov r15, rsi
    jmp .L1337_0
zy_local_x2Fmain_0__proc__pr_x2Dexec_x2Dat:
    # frame 48
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
.L1338_0:
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
    jg .L1338_1
    mov rsi, 0
.L1338_1:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L1339_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1339_1
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1339_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r12, rax
    lea rsi, [r12+16]
    lea rax, [rip+.L1340]
    mov rdi, rax
    mov qword ptr [rsi+0], rdi
    lea rax, [rip+.L1341]
    mov rdi, rax
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], rbx
    mov rdi, 0
    mov qword ptr [rsi+24], rdi
    lea rax, [rip+.L1342]
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
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwait
zy_local_x2Fmain_0__proc__pr_x2Dcat2:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1343_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    add rsi, r14
    lea rax, [r13-1]
    cmp rsi, rax
    jle .L1343_1
    lea rdi, [r13-1]
    jmp .L1343_2
.L1343_1:
    mov rdi, rsi
.L1343_2:
    mov r13, rdi
    lea rdi, [r13+1]
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    jne .L1343_3
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1343_3:
    mov rsi, r13
    cmp r14, r13
    jg .L1343_4
    mov rsi, r14
.L1343_4:
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
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall:
    # frame 32
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
.L1344_0:
    cmp r13, 0
    jg .L1344_1
.L1344_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L1344_1:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L1344_2
    add r12, rsi
    sub r13, rsi
    cmp r13, 0
    jg .L1344_1
    jmp .L1344_4
.L1344_2:
    cmp rsi, -4
    jne .L1344_3
    cmp r13, 0
    jg .L1344_1
    jmp .L1344_4
.L1344_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dstr:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1345_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall
zy_local_x2Fmain_0__proc__pr_x2Dmkstemp:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L1346_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    cmp r12, 6
    jl .L1346_2
    lea rsi, [r12-6]
    lea rdi, [rbx+rsi]
    lea rax, [rip+.L1347]
    mov rsi, rax
    mov r8, 6
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    cmp rax, 0
    jne .L1346_1
.L1346_2:
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1346_1:
    lea rsi, [r12-6]
    lea rdi, [rbx+rsi]
    mov rsi, 238328
    mov rdx, rsi
    mov rsi, rbx
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Dmkstemp_x2Dtry
zy_local_x2Fmain_0__proc__pr_x2Dmkstemp_x2Dtry:
    # frame 32
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
.L1348_0:
    cmp r13, 0
    jne .L1348_1
.L1348_6:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L1348_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_rand@tpoff]
    mov r14, rax
    mov rsi, 8
    mov rdi, r14
    call zyl_random_fill
    cmp rax, 8
    je .L1348_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1348_2:
    mov rsi, qword ptr [r14+0]
    mov rdi, 0
    cmp rdi, 6
    jge .L1348_3
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dfill_x2Dx
.L1348_3:
    mov rdi, -100
    mov rsi, 194
    mov r8, 384
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r8
    call zyl_rt_sys_257
    mov rsi, rax
    cmp rsi, 0
    jl .L1348_4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1348_4:
    cmp rsi, -17
    jne .L1348_5
    sub r13, 1
    cmp r13, 0
    jne .L1348_1
    jmp .L1348_6
.L1348_5:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dfill_x2Dx:
    # frame 0
    mov r8, rdx
.L1349_0:
    cmp r8, 6
    jl .L1349_1
.L1349_2:
    mov rax, 0
    ret
.p2align 4
.L1349_1:
    lea r9, [rdi+r8]
    lea rax, [rip+.L1350]
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
    jl .L1349_1
    jmp .L1349_2
.globl zyl_exec_cmd
zyl_exec_cmd:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
.L1351_0:
    mov rbx, rdi
    lea rax, [rip+.L1352]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    cmp rsi, 0
    jne .L1351_1
    lea rax, [rip+.L1353]
    mov rdi, rax
    jmp .L1351_2
.L1351_1:
    mov rdi, rsi
.L1351_2:
    lea rax, [rip+.L1354]
    mov rsi, rax
    mov r8, 512
    mov rdx, r8
    call zy_local_x2Fmain_0__proc__pr_x2Dcat2
    mov r12, rax
    cmp r12, 0
    jne .L1351_3
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1351_3:
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dmkstemp
    mov r13, rax
    cmp r13, 0
    jge .L1351_4
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
.L1351_4:
    lea rax, [rip+.L1355]
    mov r14, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall
    cmp rbx, 0
    jne .L1351_5
    lea rax, [rip+.L1356]
    mov rsi, rax
    jmp .L1351_6
.L1351_5:
    mov rsi, rbx
.L1351_6:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall
    lea rax, [rip+.L1357]
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
    lea rax, [rip+.L1358]
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+8], r12
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    lea rax, [rip+.L1359]
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rsi
.L1360_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_stat@tpoff]
    mov r12, rax
    mov rsi, r12
    call zyl_rt_sys_4
    cmp rax, 0
    je .L1360_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1360_1:
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
    # frame 0
    mov r8, rdx
.L1361_0:
    lea rax, [rip+.L1362]
    mov r9, rax
    mov qword ptr [rdi+0], r9
    lea rax, [rip+.L1363]
    mov r9, rax
    mov qword ptr [rdi+8], r9
    mov qword ptr [rdi+16], rsi
    lea rax, [rip+.L1364]
    mov rsi, rax
    mov qword ptr [rdi+24], rsi
    mov rsi, 4
    lea r9, [rsi*8]
    add r9, rdi
    lea rax, [rip+.L1365]
    mov r10, rax
    mov qword ptr [r9+0], r10
    lea r9, [rsi+1]
    shl r9, 3
    add r9, rdi
    mov qword ptr [r9+0], r8
    lea r8, [rsi+2]
    shl r8, 3
    add r8, rdi
    lea rax, [rip+.L1366]
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
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L1367_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    cmp r13, 2
    jl .L1367_1
    lea rsi, [r13-2]
    add rsi, rbx
    movzx eax, byte ptr [rsi+0]
    cmp rax, 46
    jne .L1367_1
    lea rsi, [r13-1]
    add rsi, rbx
    movzx eax, byte ptr [rsi+0]
    cmp rax, 115
    jne .L1367_1
    lea rax, [r13-2]
    cmp rax, 512
    jl .L1367_2
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1367_2:
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
    pop rbp
    ret
.L1367_1:
    lea rax, [r13+4]
    cmp rax, 512
    jl .L1367_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1367_3:
    mov rdi, r12
    mov rsi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rdi, [r12+r13]
    lea rax, [rip+.L1368]
    mov rsi, rax
    mov r8, 5
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_cc_compile
zyl_cc_compile:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L1369_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1369_1
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1369_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r12, rax
    lea rsi, [r12+80]
    mov rdi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dout_x2Dpath
    cmp rax, 0
    jne .L1369_2
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1369_2:
    lea rdi, [r12+16]
    lea rsi, [r12+80]
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dcc_x2Dargv
    lea rax, [rip+.L1370]
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
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwait
.globl zyl_cc_compile_log
zyl_cc_compile_log:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
.L1371_0:
    mov rbx, rdi
    mov r12, rsi
    cmp rbx, 0
    je .L1371_2
    cmp r12, 0
    jne .L1371_1
.L1371_2:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1371_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r13, rax
    lea rsi, [r13+80]
    mov rdi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dout_x2Dpath
    cmp rax, 0
    jne .L1371_3
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1371_3:
    lea rdi, [r13+16]
    lea rsi, [r13+80]
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dcc_x2Dargv
    lea rax, [rip+.L1372]
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
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwait
.globl zyl_run_bin
zyl_run_bin:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L1373_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1373_1
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1373_1:
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
    pop rbp
    jmp zy_local_x2Fmain_0__proc__pr_x2Dwait
zy_local_x2Fmain_0__start__sr_x2Dult:
    # frame 0
.L1374_0:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1375_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_start_rlimit@tpoff]
    mov rbx, rax
    mov rdi, 3
    mov rsi, rbx
    call zyl_rt_sys_97
    cmp rax, 0
    jne .L1375_1
    mov rdi, qword ptr [rbx+0]
    mov rsi, qword ptr [rbx+8]
    call zy_local_x2Fmain_0__start__sr_x2Dult
    cmp rax, 0
    je .L1375_1
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
.L1375_1:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__start__sr_x2Dguard_x2Dinit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1376_0:
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
    jne .L1376_1
    jmp .L1376_0
.L1376_1:
    cmp rsi, 8
    jne .L1376_2
    mov rdi, qword ptr [rbx+0]
    jmp .L1376_3
.L1376_2:
    mov rdi, 0
.L1376_3:
    call zyl_rt_guard_set
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ensure_arenas
zyl_ensure_arenas:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1377_0:
    lea rax, [rip+zyl_rtg_start_once]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1377_1
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    call zy_local_x2Fmain_0__start__sr_x2Dguard_x2Dinit
    call zy_local_x2Fmain_0__start__sr_x2Draise_x2Dstack_x2Dlimit
    call zy_local_x2Fmain_0__start__sr_x2Dlibc_x2Datexit
    mov rax, QWORD PTR [rip+zyl_runtime_cleanup@GOTPCREL]
    mov rdi, rax
    call zyl_rt_atexit
    jmp .L1377_2
.L1377_1:
.L1377_2:
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
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1378_0:
    call zyl_out_flush
    call zyl_ffi_abandoned
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 0
    jne .L1378_1
    call zyl_arenas_destroy
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1378_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_flush
zyl_term_flush:
    # frame 0
.L1379_0:
    jmp zyl_out_flush
.globl zyl_term_atexit
zyl_term_atexit:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1380_0:
    mov rax, QWORD PTR [rip+zyl_term_restore_atexit@GOTPCREL]
    mov rdi, rax
    call zyl_rt_atexit
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__start__sr_x2Dlibc_x2Datexit:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1381_0:
    mov rax, QWORD PTR [rip+__cxa_atexit@GOTPCREL]
    mov rdi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1381_1
    cmp rdi, 0
    jle .L1381_1
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
.L1381_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dg:
    # frame 0
.L1382_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Dlock:
    # frame 0
.L1383_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    jmp zyl_rt_mutex_lock
zy_local_x2Fmain_0__chan__ch_x2Dunlock:
    # frame 0
.L1384_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__chan__ch_x2Dwake:
    # frame 0
.L1385_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    jmp zyl_rt_cond_broadcast
zy_local_x2Fmain_0__chan__ch_x2Dmode:
    # frame 0
.L1386_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    ret
.globl zyl_chan_init
zyl_chan_init:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
.L1387_0:
    lea rax, [rip+.L1388]
    mov rdi, rax
    call zyl_rt_getenv
    mov rbx, rax
    lea rax, [rip+.L1389]
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
    jle .L1387_1
    lea rax, [rip+.L1390]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L1387_1
    mov rsi, 2
    jmp .L1387_2
.L1387_1:
    mov rdi, 3
    cmp r12, 0
    jg .L1387_3
    mov rdi, 1
.L1387_3:
    mov rsi, rdi
.L1387_2:
    mov qword ptr [r13+24], rsi
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Ddigits:
    # frame 0
.L1391_0:
    cmp rdi, 0
    jne .L1391_1
.L1391_3:
    mov rax, 0
    ret
.p2align 4
.L1391_1:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 48
    jl .L1391_2
    cmp r8, 57
    jg .L1391_2
    add rdi, 1
    imul rsi, rsi, 10
    sub r8, 48
    add rsi, r8
    cmp rdi, 0
    jne .L1391_1
    jmp .L1391_3
.L1391_2:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Ddet_x2Dp:
    # frame 0
.L1392_0:
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
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1393_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 3
    je .L1393_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1393_1:
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
    jge .L1393_2
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1393_2:
    cmp rsi, 6
    jge .L1393_3
    call zyl_rt_sys_24
    mov rsp, rbp
    pop rbp
    ret
.L1393_3:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_ts@tpoff]
    mov rdi, rax
    mov r8, 0
    mov qword ptr [rdi+0], r8
    mov r8, 20000
    cmp rsi, 6
    je .L1393_4
    mov r8, 200000
.L1393_4:
    mov qword ptr [rdi+8], r8
    mov rsi, 0
    call zyl_rt_sys_35
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dmix:
    # frame 0
.L1394_0:
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
    # frame 0
.L1395_0:
    mov rax, rdi
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    ret
zy_local_x2Fmain_0__chan__ch_x2Drec:
    # frame 0
.L1396_0:
    lea rax, [rip+zyl_rtg_chan_owners]
    mov rsi, rax
    shl rdi, 5
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp:
    # frame 0
    push rbp
    mov rbp, rsp
.L1397_0:
    cmp rdi, 1
    jne .L1397_1
.L1397_5:
    mov r8, qword ptr [rsi+24]
    mov r9, qword ptr [rsi+8]
    mov rax, r8
    mov rcx, r9
    cmp rax, rcx
    setl al
    movzx rax, al
    pop rbp
    ret
.L1397_1:
    cmp rdi, 2
    jne .L1397_2
    mov rax, qword ptr [rsi+24]
    cmp rax, 0
    jle .L1397_3
    mov rax, 1
    pop rbp
    ret
.L1397_3:
    mov r8, qword ptr [rsi+32]
    mov rax, r8
    cmp rax, 1
    sete al
    movzx rax, al
    mov r8, rax
    mov rax, r8
    pop rbp
    ret
.L1397_2:
    cmp rdi, 3
    jne .L1397_4
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
    pop rbp
    ret
.L1397_4:
    mov rax, 1
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dlive_x2Dp:
    # frame 0
    push rbp
    mov rbp, rsp
.L1398_0:
    cmp rdi, 1
    jne .L1398_1
.L1398_2:
    mov rax, 1
    pop rbp
    ret
.L1398_1:
    call zy_local_x2Fmain_0__chan__ch_x2Drec
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    mov rax, rsi
    cmp rax, 1
    sete al
    movzx rax, al
    mov rsi, rax
    mov rax, rsi
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dprogress_x2Dp:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L1399_0:
    cmp rbx, r12
    jle .L1399_1
.L1399_3:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1399_1:
    lea rax, [rip+zyl_rtg_chan_owners]
    mov r13, rax
    mov rsi, rbx
    shl rsi, 5
    add r13, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dlive_x2Dp
    cmp rax, 0
    je .L1399_2
    mov rdi, qword ptr [r13+8]
    mov rsi, qword ptr [r13+16]
    call zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp
    cmp rax, 0
    je .L1399_2
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1399_2:
    add rbx, 1
    cmp rbx, r12
    jle .L1399_1
    jmp .L1399_3
zy_local_x2Fmain_0__chan__ch_x2Dwait:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L1400_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    mov rdi, 1
    cmp rsi, 0
    je .L1400_1
    mov rdi, rsi
.L1400_1:
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
    je .L1400_2
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 2
    jne .L1400_3
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+32]
    cmp rax, r13
    jne .L1400_2
.L1400_3:
    mov rsi, 0
    mov qword ptr [r14+8], rsi
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1400_2:
    mov qword ptr [r14+8], rbx
    mov qword ptr [r14+16], r12
    call zy_local_x2Fmain_0__chan__ch_x2Dcheck
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 2
    jne .L1400_4
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+32]
    cmp rax, r13
    jne .L1400_4
    mov rdi, r13
    call zy_local_x2Fmain_0__chan__ch_x2Dpass
    jmp .L1400_5
.L1400_4:
.L1400_5:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    call zyl_rt_cond_wait
    jmp .L1400_0
zy_local_x2Fmain_0__chan__ch_x2Dcheck:
    # frame 0
    push rbp
    mov rbp, rsp
.L1401_0:
    mov rdi, 1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rsi, qword ptr [rsi+16]
    call zy_local_x2Fmain_0__chan__ch_x2Dprogress_x2Dp
    cmp rax, 0
    je .L1401_1
    mov rax, 0
    pop rbp
    ret
.L1401_1:
    pop rbp
    jmp zy_local_x2Fmain_0__chan__ch_x2Ddeadlock
zy_local_x2Fmain_0__chan__ch_x2Dpass:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L1402_0:
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
    je .L1402_1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    mov qword ptr [rdi+32], rsi
.L1402_1:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_cond_broadcast
zy_local_x2Fmain_0__chan__ch_x2Dsucc:
    # frame 0
.L1403_0:
    cmp rdi, rsi
    jl .L1403_1
.L1403_2:
    mov rax, 1
    ret
.L1403_1:
    lea rax, [rdi+1]
    ret
zy_local_x2Fmain_0__chan__ch_x2Dnext_x2Dready:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1404_0:
    cmp rbx, r12
    jne .L1404_1
.L1404_4:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1404_1:
    lea rax, [rip+zyl_rtg_chan_owners]
    mov r14, rax
    mov rsi, rbx
    shl rsi, 5
    add r14, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dlive_x2Dp
    cmp rax, 0
    je .L1404_2
    mov rdi, qword ptr [r14+8]
    mov rsi, qword ptr [r14+16]
    call zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp
    cmp rax, 0
    je .L1404_2
    mov rax, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1404_2:
    mov rsi, 1
    cmp rbx, r13
    jge .L1404_3
    lea rsi, [rbx+1]
.L1404_3:
    mov rbx, rsi
    cmp rbx, r12
    jne .L1404_1
    jmp .L1404_4
zy_local_x2Fmain_0__chan__ch_x2Ddeadlock:
    # frame 0
    push rbp
    mov rbp, rsp
.L1405_0:
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
    lea rax, [rip+.L1406]
    mov rdi, rax
    call zyl_err_puts
    mov rdi, 1
    pop rbp
    jmp zyl_chan_exit
zy_local_x2Fmain_0__chan__ch_x2Demit_x2Dall:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1407_0:
    cmp rbx, r12
    jle .L1407_1
.L1407_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1407_1:
    mov rdi, rbx
    call zyl_out_actor_emit
    add rbx, 1
    cmp rbx, r12
    jle .L1407_1
    jmp .L1407_2
.globl zyl_chan_exit
zyl_chan_exit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1408_0:
    call zyl_out_flush
    mov rax, QWORD PTR [rip+fflush@GOTPCREL]
    mov rdi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1408_1
    cmp rdi, 0
    jle .L1408_1
    mov rsi, 0
    call zyl_rt_call1
    jmp .L1408_2
.L1408_1:
.L1408_2:
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_sys_231
zy_local_x2Fmain_0__chan__ch_x2Dmagic:
    # frame 0
.L1409_0:
    mov rax, 1514357326
    ret
zy_local_x2Fmain_0__chan__tx_x2Dmagic:
    # frame 0
.L1410_0:
    mov rax, 1514363992
    ret
zy_local_x2Fmain_0__chan__rx_x2Dmagic:
    # frame 0
.L1411_0:
    mov rax, 1514360920
    ret
zy_local_x2Fmain_0__chan__ch_x2Dpanic:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1412_0:
    call zyl_panic
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dendpoint:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1413_0:
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
    pop rbp
    ret
.globl zyl_chan_new
zyl_chan_new:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
.L1414_0:
    cmp rbx, 1
    jl .L1414_2
.L1414_5:
    cmp rbx, 16777216
    jle .L1414_1
.L1414_2:
    lea rax, [rip+.L1415]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_panic
.L1414_1:
    mov rdi, 64
    call zyl_heap_alloc
    mov r12, rax
    lea rdi, [rbx*8]
    call zyl_heap_alloc
    mov r13, rax
    cmp r12, 0
    je .L1414_4
    cmp r13, 0
    jne .L1414_3
.L1414_4:
    lea rax, [rip+.L1416]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_panic
.L1414_3:
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
    pop rbp
    ret
.globl zyl_chan_tx
zyl_chan_tx:
    # frame 0
.L1417_0:
    mov rax, qword ptr [rdi+40]
    ret
.globl zyl_chan_rx
zyl_chan_rx:
    # frame 0
.L1418_0:
    mov rax, qword ptr [rdi+48]
    ret
zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L1419_0:
    mov rdi, rbx
    call zyl_heap_block_p
    cmp rax, 0
    je .L1419_2
    lea rdi, [rbx+16]
    call zyl_heap_block_p
    cmp rax, 0
    jne .L1419_1
.L1419_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1419_1:
    mov r12, qword ptr [rbx+0]
    cmp r12, 1514363992
    je .L1419_3
    cmp r12, 1514360920
    je .L1419_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1419_3:
    mov r13, qword ptr [rbx+8]
    mov rdi, r13
    call zyl_heap_block_p
    cmp rax, 0
    je .L1419_5
    lea rdi, [r13+56]
    call zyl_heap_block_p
    cmp rax, 0
    jne .L1419_4
.L1419_5:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1419_4:
    mov rax, qword ptr [r13+0]
    cmp rax, 1514357326
    jne .L1419_6
    mov rsi, 40
    cmp r12, 1514363992
    je .L1419_7
    mov rsi, 48
.L1419_7:
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
    pop rbp
    ret
.L1419_6:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Down_x2Dcheck:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1420_0:
    mov rbx, qword ptr [rdi+16]
    call zyl_owner_self
    cmp rbx, rax
    jne .L1420_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1420_1:
    lea rax, [rip+.L1421]
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_chan_send
zyl_chan_send:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L1422_0:
    call zy_local_x2Fmain_0__chan__ch_x2Dchaos
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Down_x2Dcheck
    mov rdi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp
    mov r13, rax
    cmp r13, 0
    je .L1422_1
    mov rdi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Down_x2Dcheck
    jmp .L1422_2
.L1422_1:
.L1422_2:
    mov rbx, qword ptr [rbx+8]
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, 1
    mov rsi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dwait
    cmp r13, 0
    je .L1422_3
    mov rsi, 0
    mov qword ptr [r12+16], rsi
    jmp .L1422_4
.L1422_3:
.L1422_4:
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
    pop rbp
    ret
.globl zyl_chan_recv
zyl_chan_recv:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L1423_0:
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
    jne .L1423_1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_unlock
    lea rax, [rip+.L1424]
    mov rdi, rax
    pop r12
    pop rbx
    pop rbp
    jmp zyl_panic
.L1423_1:
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
    je .L1423_2
    mov rax, qword ptr [r12+16]
    cmp rax, 0
    jne .L1423_2
    call zyl_owner_self
    mov rsi, rax
    mov qword ptr [r12+16], rsi
    jmp .L1423_3
.L1423_2:
.L1423_3:
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
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dreg:
    # frame 0
.L1425_0:
    lea rax, [rip+zyl_rtg_chan_reg]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_chan_register
zyl_chan_register:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
.L1426_0:
    lea rax, [rip+zyl_rtg_chan_reg]
    mov r12, rax
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov r13, qword ptr [r12+8]
    mov rax, qword ptr [r12+16]
    cmp r13, rax
    jge .L1426_1
    mov rsi, 1
    jmp .L1426_2
.L1426_1:
    mov rdi, 64
    cmp r13, 0
    je .L1426_3
    lea rdi, [r13*2]
.L1426_3:
    mov r14, rdi
    mov rdi, qword ptr [r12+0]
    lea r8, [r14*8]
    mov rsi, r8
    call zyl_rt_realloc
    mov rdi, rax
    mov r8, 0
    cmp rdi, 0
    je .L1426_4
    mov qword ptr [r12+0], rdi
    mov qword ptr [r12+16], r14
    mov r8, 1
.L1426_4:
    mov rsi, r8
.L1426_2:
    mov rax, rsi
    cmp rax, 0
    je .L1426_5
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
    pop rbp
    jmp zyl_rt_mutex_unlock
.L1426_5:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_unlock
    lea rax, [rip+.L1427]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_panic
zy_local_x2Fmain_0__chan__ch_x2Dclose_x2Downed:
    # frame 0
.L1428_0:
    lea rax, [rip+zyl_rtg_chan_reg]
    mov r8, rax
    mov rax, qword ptr [r8+8]
    cmp rsi, rax
    jl .L1428_1
    mov rax, 0
    ret
.L1428_1:
    mov r8, qword ptr [r8+0]
    lea r9, [rsi*8]
    add r8, r9
    mov r8, qword ptr [r8+0]
    mov r9, qword ptr [r8+40]
    mov rax, qword ptr [r9+16]
    cmp rax, rdi
    jne .L1428_2
    mov r9, 1
    mov qword ptr [r8+32], r9
    jmp .L1428_3
.L1428_2:
.L1428_3:
    add rsi, 1
    jmp .L1428_0
.globl zyl_chan_actor_spawn
zyl_chan_actor_spawn:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L1429_0:
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
    jle .L1429_1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov qword ptr [rsi+16], rbx
    jmp .L1429_2
.L1429_1:
.L1429_2:
    cmp r12, 0
    je .L1429_3
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
.L1429_3:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov r12, qword ptr [rsi+0]
    cmp r12, 0
    je .L1429_4
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
.L1429_4:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__chan__ch_x2Dmoves:
    # frame 0
.L1430_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_chan_spawn_moves
zyl_chan_spawn_moves:
    # frame 0
.L1431_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__chan__ch_x2Dmove_x2Dwords:
    # frame 48
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
.L1432_0:
    cmp r12, r13
    jl .L1432_1
.L1432_4:
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
.L1432_1:
    lea rsi, [r12*8]
    add rsi, qword ptr [rbp-48]
    mov rbx, qword ptr [rsi+0]
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp
    cmp rax, 0
    je .L1432_2
    mov rax, qword ptr [rbx+16]
    cmp rax, r14
    jne .L1432_2
    mov qword ptr [rbx+16], r15
    jmp .L1432_3
.L1432_2:
.L1432_3:
    add r12, 1
    cmp r12, r13
    jl .L1432_1
    jmp .L1432_4
.globl zyl_chan_actor_enter
zyl_chan_actor_enter:
    # frame 0
    push rbp
    mov rbp, rsp
.L1433_0:
    call zy_local_x2Fmain_0__chan__ch_x2Dchaos
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, 4
    mov rsi, 0
    call zy_local_x2Fmain_0__chan__ch_x2Dwait
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    pop rbp
    jmp zyl_rt_mutex_unlock
.globl zyl_chan_actor_done
zyl_chan_actor_done:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1434_0:
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
    jne .L1434_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dpass
    jmp .L1434_2
.L1434_1:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    call zyl_rt_cond_broadcast
.L1434_2:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_mutex_unlock
.globl zyl_chan_actor_join
zyl_chan_actor_join:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1435_0:
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
    pop rbp
    ret
.globl zyl_chan_main_done
zyl_chan_main_done:
    # frame 0
    push rbp
    mov rbp, rsp
.L1436_0:
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
    pop rbp
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__actor__ac_x2Dmax:
    # frame 0
.L1437_0:
    mov rax, 1024
    ret
zy_local_x2Fmain_0__actor__ac_x2Dsys:
    # frame 0
.L1438_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__actor__ac_x2Dslot:
    # frame 0
.L1439_0:
    lea rax, [rip+zyl_rtg_actor_slots]
    mov rsi, rax
    shl rdi, 5
    add rsi, rdi
    mov rax, rsi
    ret
zy_local_x2Fmain_0__actor__ac_x2Dinited:
    # frame 0
.L1440_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jne .L1440_1
    mov rax, 0
    ret
.L1440_1:
    mov rax, 1
    ret
zy_local_x2Fmain_0__actor__ac_x2Dnext:
    # frame 0
.L1441_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_actor_init
zyl_actor_init:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1442_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    je .L1442_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1442_1:
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
    # frame 0
.L1443_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+16], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__actor__ac_x2Dptr_x2Dp:
    # frame 0
.L1444_0:
    cmp rdi, 0
    jge .L1444_1
.L1444_2:
    mov rax, 1
    ret
.L1444_1:
    mov rax, rdi
    cmp rax, 4096
    setge al
    movzx rax, al
    ret
.globl zyl_actor_spawn
zyl_actor_spawn:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1445_0:
    call zyl_actor_init
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dptr_x2Dp
    cmp rax, 0
    je .L1445_1
    mov rax, qword ptr [rbx+0]
    cmp rax, 2051230803
    jne .L1445_1
    mov rdi, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+16]
    mov r8, qword ptr [rbx+16]
    mov rdx, r8
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__actor__ac_x2Dspawn
.L1445_1:
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__actor__ac_x2Dspawn
.globl zyl_actor_id
zyl_actor_id:
    # frame 0
.L1446_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__actor__ac_x2Dspawn:
    # frame 48
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
.L1447_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov r14, rax
    cmp r14, 1024
    jl .L1447_1
    lea rax, [rip+.L1448]
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
.L1447_1:
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
    jne .L1447_2
    lea rdi, [r14+2]
    mov r8, 0
    mov rsi, r8
    call zyl_chan_actor_done
    lea rax, [rip+.L1449]
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
.L1447_2:
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
    # frame 0
    push rbp
    mov rbp, rsp
.L1450_0:
    call zyl_owner_self
    mov rdi, rax
    sub rdi, 2
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    mov rsi, qword ptr [rsi+8]
    pop rbp
    jmp zyl_rt_call1
.globl zyl_actor_thread_entry
zyl_actor_thread_entry:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
.L1451_0:
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
    jne .L1451_1
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
.L1451_1:
    mov rsi, qword ptr [r12+72]
    cmp rsi, 0
    jne .L1451_2
    lea rax, [rip+.L1452]
    mov rdi, rax
    jmp .L1451_3
.L1451_2:
    mov rdi, rsi
.L1451_3:
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov r13, rax
    mov rdi, r12
    call zyl_rt_free
    lea rdi, [rbx+2]
    cmp r13, 0
    jne .L1451_4
    lea rax, [rip+.L1453]
    mov rsi, rax
    jmp .L1451_5
.L1451_4:
    mov rsi, r13
.L1451_5:
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zyl_chan_actor_done
zy_local_x2Fmain_0__actor__ac_x2Dvalid:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1454_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    je .L1454_1
    cmp rbx, 0
    jl .L1454_2
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 1024
    jle .L1454_3
    mov rsi, 1024
    jmp .L1454_4
.L1454_3:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rdi, rax
    mov rsi, qword ptr [rdi+0]
.L1454_4:
    mov rax, rbx
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    pop rbx
    pop rbp
    ret
.L1454_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1454_1:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.globl zyl_actor_wait
zyl_actor_wait:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L1455_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dvalid
    cmp rax, 0
    jne .L1455_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1455_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov r12, rax
    mov rax, qword ptr [r12+24]
    cmp rax, 0
    je .L1455_2
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1455_2:
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
    jne .L1455_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1455_3:
    mov rdi, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_panic
.globl zyl_actor_is_alive
zyl_actor_is_alive:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1456_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dvalid
    cmp rax, 0
    jne .L1456_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1456_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 0
    jne .L1456_2
    mov rax, 1
    pop rbx
    pop rbp
    ret
.L1456_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__actor__ac_x2Djoin_x2Drest:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1457_0:
    cmp rbx, r12
    jl .L1457_1
.L1457_4:
    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1457_1:
    lea rax, [rip+zyl_rtg_actor_slots]
    mov r14, rax
    mov rsi, rbx
    shl rsi, 5
    add r14, rsi
    mov rax, qword ptr [r14+24]
    cmp rax, 0
    je .L1457_2
    add rbx, 1
    cmp rbx, r12
    jl .L1457_1
    jmp .L1457_4
.L1457_2:
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
    je .L1457_3
    mov r15, r13
.L1457_3:
    mov r13, r15
    mov rbx, rsi
    cmp rbx, r12
    jl .L1457_1
    jmp .L1457_4
.globl zyl_actor_join_unjoined
zyl_actor_join_unjoined:
    # frame 0
    push rbp
    mov rbp, rsp
.L1458_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    jne .L1458_1
    mov rax, 0
    pop rbp
    ret
.L1458_1:
    mov rdi, 0
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 1024
    jle .L1458_2
    mov rsi, 1024
    jmp .L1458_3
.L1458_2:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov r8, rax
    mov rsi, qword ptr [r8+0]
.L1458_3:
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__actor__ac_x2Djoin_x2Drest
    mov rdi, rax
    cmp rdi, 0
    jne .L1458_4
    mov rax, 0
    pop rbp
    ret
.L1458_4:
    pop rbp
    jmp zyl_panic
.globl zyl_actor_wait_all
zyl_actor_wait_all:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1459_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    je .L1459_2
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+16]
    cmp rax, 0
    je .L1459_1
.L1459_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1459_1:
    call zyl_chan_main_done
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 1024
    jle .L1459_3
    mov rsi, 1024
    jmp .L1459_4
.L1459_3:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rdi, rax
    mov rsi, qword ptr [rdi+0]
.L1459_4:
    mov rdi, 0
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__actor__ac_x2Djoin_x2Drest
    mov rbx, rax
    cmp rbx, 0
    jne .L1459_5
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1459_5:
    call zyl_out_flush
    lea rax, [rip+.L1460]
    mov rdi, rax
    call zyl_err_puts
    mov rdi, rbx
    call zyl_err_puts
    lea rax, [rip+.L1461]
    mov rdi, rax
    call zyl_err_puts
    mov rdi, 1
    pop rbx
    pop rbp
    jmp zyl_chan_exit
zy_local_x2Fmain_0__actor__bs_x2Dsize:
    # frame 0
.L1462_0:
    cmp rdi, 0
    jne .L1462_1
.L1462_4:
    mov rax, 68719476736
    ret
.L1462_1:
    cmp rdi, 1
    jne .L1462_2
    mov rax, 17179869184
    ret
.L1462_2:
    cmp rdi, 2
    jne .L1462_3
    mov rax, 4294967296
    ret
.L1462_3:
    mov rax, 1073741824
    ret
.globl zyl_bigstack_tramp
zyl_bigstack_tramp:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1463_0:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1464_0:
    mov rdi, 24
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L1464_1
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zyl_rt_call0
.L1464_1:
    mov qword ptr [rsi+0], rbx
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__actor__bs_x2Dtry
zy_local_x2Fmain_0__actor__bs_x2Dunmap:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1465_0:
    call zyl_rt_sys_11
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__actor__bs_x2Dtry:
    # frame 48
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
.L1466_0:
    cmp r13, 4
    jl .L1466_1
.L1466_7:
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
.L1466_1:
    mov rsi, 68719476736
    cmp r13, 0
    je .L1466_2
    mov rdi, 17179869184
    cmp r13, 1
    je .L1466_3
    mov r8, 4294967296
    cmp r13, 2
    je .L1466_4
    mov r8, 1073741824
.L1466_4:
    mov rdi, r8
.L1466_3:
    mov rsi, rdi
.L1466_2:
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
    jge .L1466_5
    cmp r15, -4096
    jle .L1466_5
    add r13, 1
    cmp r13, 4
    jl .L1466_1
    jmp .L1466_7
.L1466_5:
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
    jne .L1466_6
    mov rdi, r15
    mov rsi, r14
    call zyl_rt_sys_11
    add r13, 1
    cmp r13, 4
    jl .L1466_1
    jmp .L1466_7
.L1466_6:
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
    # frame 0
.L1467_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_worker@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Don_x2Dworker_x2Dcell:
    # frame 0
.L1468_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_on_worker@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dany_x2Dabandoned:
    # frame 0
.L1469_0:
    lea rax, [rip+zyl_rtg_ffi_any_abandoned]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_ffi_abandoned
zyl_ffi_abandoned:
    # frame 0
.L1470_0:
    lea rax, [rip+zyl_rtg_ffi_any_abandoned]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_ffi_on_worker
zyl_ffi_on_worker:
    # frame 0
.L1471_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_on_worker@tpoff]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dlock:
    # frame 0
.L1472_0:
    mov rdi, qword ptr [rdi+0]
    jmp zyl_rt_mutex_lock
zy_local_x2Fmain_0__ffitimed__ff_x2Dunlock:
    # frame 0
.L1473_0:
    mov rdi, qword ptr [rdi+0]
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__ffitimed__ff_x2Dcond:
    # frame 0
.L1474_0:
    mov rax, qword ptr [rdi+8]
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dinvoke:
    # frame 120
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
    jne .L1475
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-8]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call0
    mov rsp, r12
    add rsp, 16
    jmp .L1476
.L1475:
    mov rax, [rbp-16]
    mov rcx, 1
    cmp rax, rcx
    jne .L1477
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
    jmp .L1478
.L1477:
    mov rax, [rbp-16]
    mov rcx, 2
    cmp rax, rcx
    jne .L1479
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
    jmp .L1480
.L1479:
    mov rax, [rbp-16]
    mov rcx, 3
    cmp rax, rcx
    jne .L1481
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
    jmp .L1482
.L1481:
    mov rax, [rbp-16]
    mov rcx, 4
    cmp rax, rcx
    jne .L1483
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
    jmp .L1484
.L1483:
    mov rax, [rbp-16]
    mov rcx, 5
    cmp rax, rcx
    jne .L1485
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
    jmp .L1486
.L1485:
    mov rax, [rbp-16]
    mov rcx, 6
    cmp rax, rcx
    jne .L1487
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
    jmp .L1488
.L1487:
    mov rax, [rbp-16]
    mov rcx, 7
    cmp rax, rcx
    jne .L1489
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
    jmp .L1490
.L1489:
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
.L1490:
.L1488:
.L1486:
.L1484:
.L1482:
.L1480:
.L1478:
.L1476:
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_ffi_worker_main
zyl_ffi_worker_main:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1491_0:
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
    pop rbp
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dserve
zy_local_x2Fmain_0__ffitimed__ff_x2Dserve:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L1492_0:
    mov rax, qword ptr [rbx+16]
    cmp rax, 1
    je .L1492_1
    mov rdi, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+0]
    call zyl_rt_cond_wait
    jmp .L1492_0
.L1492_1:
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
    jne .L1492_2
    jmp .L1492_3
.L1492_2:
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
.L1492_3:
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
    je .L1492_4
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dfinish
.L1492_4:
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
    jmp .L1492_0
zy_local_x2Fmain_0__ffitimed__ff_x2Dfinish:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L1493_0:
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
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Doom:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1494_0:
    lea rax, [rip+.L1495]
    mov rdi, rax
    call zyl_panic
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dget:
    # frame 0
.L1496_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_worker@tpoff]
    mov rdi, rax
    mov rsi, qword ptr [rdi+0]
    cmp rsi, 0
    jne .L1496_1
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dnew
.L1496_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dnew:
    # frame 48
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
.L1497_0:
    mov rdi, 1
    mov rsi, 192
    call zyl_rt_calloc
    mov r12, rax
    cmp r12, 0
    jne .L1497_1
    lea rax, [rip+.L1498]
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
.L1497_1:
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
    je .L1497_3
    cmp r14, 0
    je .L1497_3
    cmp r15, 0
    je .L1497_4
    cmp qword ptr [rbp-48], 0
    jne .L1497_2
.L1497_4:
.L1497_3:
    lea rax, [rip+.L1499]
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
.L1497_2:
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
    # frame 32
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
.L1500_0:
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
    jne .L1500_1
    lea rax, [rip+.L1501]
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1500_1:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L1502_0:
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
    jl .L1502_1
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
.L1502_1:
    mov qword ptr [r12+0], rsi
    mov qword ptr [r12+8], rdi
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dcopy_x2Dargs:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L1503_0:
    cmp r9, r8
    jl .L1503_1
.L1503_2:
    mov rax, 0
    ret
.p2align 4
.L1503_1:
    lea r10, [r9*8]
    add r10, rdi
    lea r11, [r9*8]
    add r11, rsi
    mov r11, qword ptr [r11+0]
    mov qword ptr [r10+0], r11
    add r9, 1
    cmp r9, r8
    jl .L1503_1
    jmp .L1503_2
zy_local_x2Fmain_0__ffitimed__ff_x2Dcore:
    # frame 48
    push rbp
    mov rbp, rsp
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
.L1504_0:
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
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dlibc_x2Dflush:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1505_0:
    mov rax, QWORD PTR [rip+fflush@GOTPCREL]
    mov rdi, rax
    cmp rdi, 0
    jle .L1505_1
    mov rsi, 0
    call zyl_rt_call1
    mov rsp, rbp
    pop rbp
    ret
.L1505_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dcore_x2Dgo:
    # frame 64
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
.L1506_0:
    cmp rsi, 0
    jne .L1506_1
.L1506_7:
    lea rax, [rip+.L1507]
    mov r8, rax
    jmp .L1506_2
.L1506_1:
    mov r8, rsi
.L1506_2:
    mov r14, r8
    cmp rbx, 4096
    jge .L1506_3
    lea rax, [rip+.L1508]
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
.L1506_3:
    cmp r12, 0
    jl .L1506_5
    cmp r12, 16
    jle .L1506_4
.L1506_5:
    lea rax, [rip+.L1509]
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
.L1506_4:
    mov rsi, 1
    cmp rdi, 1
    jl .L1506_6
    mov rsi, rdi
.L1506_6:
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
    # frame 48
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
.L1510_0:
    mov rdx, qword ptr [rbp-48]
    mov rax, qword ptr [rdx+16]
    cmp rax, 2
    jne .L1510_1
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
    jne .L1510_2
    jmp .L1510_3
.L1510_2:
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
.L1510_3:
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1510_1:
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
    jne .L1510_4
    mov rdx, qword ptr [rbp-48]
    mov rax, qword ptr [rdx+16]
    cmp rax, 2
    je .L1510_4
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
    jne .L1510_5
    jmp .L1510_6
.L1510_5:
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
.L1510_6:
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
    lea rax, [rip+.L1511]
    mov r15, rax
    lea rax, [rip+.L1512]
    mov rbx, rax
    mov rdi, r14
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L1513]
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
.L1510_4:
    jmp .L1510_0
zy_local_x2Fmain_0__ffitimed__ff_x2Din_x2Dargs:
    # frame 360
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
    # frame 264
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
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L1514_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_in@tpoff]
    mov r15, rax
    mov rsi, 16
    cmp r14, 16
    jg .L1514_1
    mov rsi, r14
.L1514_1:
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
    pop rbp
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dcore
.globl zyl_ffi_invoke_wide
zyl_ffi_invoke_wide:
    # frame 120
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
    jmp .L1516
.L1515:
    mov rax, [rbp-16]
    mov rcx, 9
    cmp rax, rcx
    jne .L1517
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
    jmp .L1518
.L1517:
    mov rax, [rbp-16]
    mov rcx, 10
    cmp rax, rcx
    jne .L1519
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
    jmp .L1520
.L1519:
    mov rax, [rbp-16]
    mov rcx, 11
    cmp rax, rcx
    jne .L1521
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
    jmp .L1522
.L1521:
    mov rax, [rbp-16]
    mov rcx, 12
    cmp rax, rcx
    jne .L1523
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
    jmp .L1524
.L1523:
    mov rax, [rbp-16]
    mov rcx, 13
    cmp rax, rcx
    jne .L1525
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
    jmp .L1526
.L1525:
    mov rax, [rbp-16]
    mov rcx, 14
    cmp rax, rcx
    jne .L1527
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
    jmp .L1528
.L1527:
    mov rax, [rbp-16]
    mov rcx, 15
    cmp rax, rcx
    jne .L1529
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
    jmp .L1530
.L1529:
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
.L1530:
.L1528:
.L1526:
.L1524:
.L1522:
.L1520:
.L1518:
.L1516:
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Derr:
    # frame 0
.L1531_0:
    jmp zyl_err_puts
zy_local_x2Fmain_0__panic__pn_x2Dout:
    # frame 0
.L1532_0:
    jmp zyl_out_puts
zy_local_x2Fmain_0__panic__pn_x2Ds:
    # frame 0
.L1533_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtop:
    # frame 0
.L1534_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_try_push
zyl_try_push:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1535_0:
    mov rdi, 88
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rbx, rax
    cmp rbx, 0
    jne .L1535_1
    mov rdi, 88
    lea rax, [rip+.L1536]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L1535_2
.L1535_1:
.L1535_2:
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
    # frame 0
    push rbp
    mov rbp, rsp
.L1537_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    cmp rdi, 0
    jne .L1537_1
    mov rax, 0
    pop rbp
    ret
.L1537_1:
    mov r8, qword ptr [rdi+64]
    mov qword ptr [rsi+0], r8
    call zyl_rt_free
    mov rax, 0
    pop rbp
    ret
.globl zyl_try_last_msg
zyl_try_last_msg:
    # frame 0
.L1538_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L1538_1
    mov rax, 0
    ret
.L1538_1:
    mov rax, qword ptr [rsi+72]
    ret
.globl zyl_try_frame_msg
zyl_try_frame_msg:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1539_0:
    cmp rdi, 0
    jne .L1539_1
.L1539_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1539_1:
    mov rbx, qword ptr [rdi+72]
    call zyl_rt_free
    mov rax, rbx
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtstate:
    # frame 0
.L1540_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtests:
    # frame 0
.L1541_0:
    lea rax, [rip+zyl_rtg_tests]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtbuf:
    # frame 0
.L1542_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov rsi, rax
    add rsi, 24
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtmsg:
    # frame 0
.L1543_0:
    lea rax, [rip+zyl_rtg_test_msg]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dfail_x2Dline:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L1544_0:
    lea rax, [rip+zyl_rtg_test_msg]
    mov rsi, rax
    mov rbx, qword ptr [rsi+0]
    cmp rbx, 0
    jne .L1544_1
    lea rax, [rip+.L1545]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1544_1:
    lea rax, [rip+zyl_rtg_test_msg]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+0], rdi
    lea rax, [rip+.L1546]
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
    lea rax, [rip+.L1547]
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
    # frame 0
.L1548_0:
    lea r8, [rdi+rsi]
    movzx r8d, byte ptr [r8+0]
    cmp r8, 0
    je .L1548_2
    cmp r8, 10
    jne .L1548_1
.L1548_2:
    mov rax, rsi
    ret
.L1548_1:
    add rsi, 1
    jmp .L1548_0
.globl zyl_register_test
zyl_register_test:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rbx, rsi
.L1549_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov qword ptr [rbp-48], rax
    mov rdx, qword ptr [rbp-48]
    mov r13, qword ptr [rdx+0]
    cmp r13, 256
    jl .L1549_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1549_1:
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
    jg .L1549_2
    mov rdi, rsi
.L1549_2:
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
    # frame 0
.L1550_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
.globl zyl_run_tests
zyl_run_tests:
    # frame 0
.L1551_0:
    mov rdi, 0
    mov rsi, 0
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__panic__pn_x2Drun_x2Dtests
.globl zyl_run_tests_matching
zyl_run_tests_matching:
    # frame 0
.L1552_0:
    mov rsi, 0
    mov r8, 0
    mov r9, 0
    mov rdx, r9
    mov rcx, rdi
    mov rdi, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__panic__pn_x2Drun_x2Dtests
zy_local_x2Fmain_0__panic__pn_x2Dcontains:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1553_0:
    movzx eax, byte ptr [r12+0]
    cmp rax, 0
    jne .L1553_1
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
.L1553_1:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L1553_2
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L1553_2:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__panic__pn_x2Dprefix
    cmp rax, 0
    je .L1553_3
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
.L1553_3:
    add rbx, 1
    jmp .L1553_0
zy_local_x2Fmain_0__panic__pn_x2Dprefix:
    # frame 0
.L1554_0:
    movzx eax, byte ptr [rsi+0]
    cmp rax, 0
    jne .L1554_1
    mov rax, 1
    ret
.L1554_1:
    movzx r8d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r8, rax
    jne .L1554_2
    add rdi, 1
    add rsi, 1
    jmp .L1554_0
.L1554_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__panic__pn_x2Drun_x2Dtests:
    # frame 80
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
.L1555_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov qword ptr [rbp-80], rax
    mov rdx, qword ptr [rbp-80]
    mov rax, qword ptr [rdx+0]
    cmp qword ptr [rbp-48], rax
    jl .L1555_1
    lea rax, [rip+.L1556]
    mov rbx, rax
    mov rsi, 0
    mov rdi, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r12, rax
    lea rax, [rip+.L1557]
    mov r13, rax
    mov rsi, 0
    mov rdi, qword ptr [rbp-64]
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r14, rax
    lea rax, [rip+.L1558]
    mov r15, rax
    mov rdi, qword ptr [rbp-56]
    add rdi, qword ptr [rbp-64]
    mov rsi, 0
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov rdi, rax
    lea rax, [rip+.L1559]
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
    jle .L1555_2
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1555_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1555_1:
    lea rax, [rip+zyl_rtg_tests]
    mov rbx, rax
    imul rsi, qword ptr [rbp-48], 136
    add rbx, rsi
    cmp qword ptr [rbp-72], 0
    je .L1555_3
    mov rdi, rbx
    mov rsi, qword ptr [rbp-72]
    call zy_local_x2Fmain_0__panic__pn_x2Dcontains
    cmp rax, 0
    jne .L1555_3
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    jmp .L1555_0
.L1555_3:
    lea rax, [rip+.L1560]
    mov r12, rax
    lea rax, [rip+.L1561]
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
    jne .L1555_4
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
    jne .L1555_5
    lea rax, [rip+.L1562]
    mov rdi, rax
    call zyl_out_puts
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-56]
    add rax, 1
    mov qword ptr [rbp-56], rax
    jmp .L1555_0
.L1555_5:
    call zy_local_x2Fmain_0__panic__pn_x2Dfail_x2Dline
    mov rdi, rax
    call zyl_out_puts
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-64]
    add rax, 1
    mov qword ptr [rbp-64], rax
    jmp .L1555_0
.L1555_4:
    call zy_local_x2Fmain_0__panic__pn_x2Dfail_x2Dline
    mov rdi, rax
    call zyl_out_puts
    mov rax, qword ptr [rbp-48]
    add rax, 1
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-64]
    add rax, 1
    mov qword ptr [rbp-64], rax
    jmp .L1555_0
.globl zyl_panic
zyl_panic:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1563_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rbx, qword ptr [rsi+0]
    cmp rbx, 0
    jne .L1563_1
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Dtest
.L1563_1:
    mov r8, qword ptr [rbx+64]
    mov qword ptr [rsi+0], r8
    cmp rdi, 0
    jne .L1563_2
    lea rax, [rip+.L1564]
    mov rsi, rax
    jmp .L1563_3
.L1563_2:
    mov rsi, rdi
.L1563_3:
    mov qword ptr [rbx+72], rsi
    mov rdi, qword ptr [rbx+80]
    call zyl_region_unwind
    mov rsi, 1
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zyl_rt_longjmp
zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Dtest:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1565_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov r12, rax
    mov rax, qword ptr [r12+8]
    cmp rax, 0
    je .L1565_1
    call zyl_ffi_on_worker
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 0
    jne .L1565_1
    mov rsi, 0
    mov qword ptr [r12+8], rsi
    lea rax, [rip+zyl_rtg_test_msg]
    mov r13, rax
    mov rsi, 0
    cmp rbx, 0
    je .L1565_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov rsi, rax
.L1565_2:
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
.L1565_1:
    call zyl_actor_abandon
    cmp rbx, 0
    jne .L1565_3
    lea rax, [rip+.L1566]
    mov rsi, rax
    jmp .L1565_4
.L1565_3:
    mov rsi, rbx
.L1565_4:
    mov rbx, rsi
    call zyl_out_flush
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1565_5
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Dtext
    jmp .L1565_6
.L1565_5:
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Djson
.L1565_6:
    mov rdi, 1
    call zyl_rt_exit
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Dtext:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
    mov rbx, rdi
.L1567_0:
    lea rax, [rip+.L1568]
    mov r12, rax
    lea rax, [rip+.L1569]
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_err_puts
    lea rax, [rip+.L1570]
    mov rsi, rax
    mov rdi, 6
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp
    cmp rax, 0
    je .L1567_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1567_1:
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Dbacktrace
zy_local_x2Fmain_0__panic__pn_x2Dbacktrace:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1571_0:
    mov rax, QWORD PTR [rip+zyl_syms@GOTPCREL]
    mov rbx, rax
    cmp rbx, 0
    je .L1571_2
    lea rax, [rip+zyl_rtg_bt_off]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    je .L1571_1
.L1571_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1571_1:
    call zyl_rt_frame_addr
    mov rdi, rax
    mov rsi, 0
    mov r8, 0
    mov rdx, rsi
    mov rsi, rbx
    mov rcx, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Dbt_x2Dwalk
zy_local_x2Fmain_0__panic__pn_x2Dbt_x2Dwalk:
    # frame 48
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
.L1572_0:
    cmp rbx, 0
    je .L1572_2
.L1572_8:
    cmp r13, 32
    jge .L1572_3
    cmp r14, 4096
    jge .L1572_4
    mov rdi, rbx
    and rdi, -4096
    lea rsi, [rbx+16]
    sub rsi, rdi
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_bt_vec@tpoff]
    mov r8, rax
    mov rdx, r8
    call zyl_rt_sys_27
    mov rsi, rax
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    mov rsi, rax
    cmp rsi, 0
    jne .L1572_1
.L1572_4:
.L1572_3:
.L1572_2:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1572_1:
    mov rsi, qword ptr [rbx+8]
    sub rsi, 1
    mov rdi, r12
    call zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Dname
    mov rdi, rax
    mov rsi, r13
    cmp rdi, 0
    je .L1572_5
    lea rax, [rip+.L1573]
    mov r15, rax
    lea rax, [rip+.L1574]
    mov r8, rax
    mov rsi, r8
    call zyl_cstr_concat
    mov rdi, rax
    mov rsi, rdi
    mov rdi, r15
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_err_puts
    lea rsi, [r13+1]
.L1572_5:
    mov rdi, qword ptr [rbx+0]
    cmp rdi, rbx
    jle .L1572_7
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L1572_6
.L1572_7:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1572_6:
    mov rbx, rdi
    mov r13, rsi
    add r14, 1
    cmp rbx, 0
    je .L1572_2
    jmp .L1572_8
zy_local_x2Fmain_0__panic__pn_x2Dmapped:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1575_0:
    mov rsi, rdi
    and rsi, -4096
    add rdi, 16
    sub rdi, rsi
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_bt_vec@tpoff]
    mov r8, rax
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_27
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
zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Dname:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
.L1576_0:
    mov r13, qword ptr [rbx+0]
    cmp r13, 0
    je .L1576_2
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Daddr
    cmp r12, rax
    jl .L1576_3
    mov rdi, rbx
    mov rsi, r13
    call zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Daddr
    cmp r12, rax
    jl .L1576_1
.L1576_3:
.L1576_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1576_1:
    lea r14, [rbx+12]
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Dfind
    mov rsi, rax
    shl rsi, 3
    add r14, rsi
    mov esi, dword ptr [r14+0]
    lea rax, [rbx+rsi]
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Daddr:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1577_0:
    lea rbx, [rdi+8]
    shl rsi, 3
    add rbx, rsi
    mov edi, dword ptr [rbx+0]
    call zy_local_x2Fmain_0__panic__pn_x2Ds32
    mov rsi, rax
    lea rax, [rbx+rsi]
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Ds32:
    # frame 0
.L1578_0:
    mov rax, 2147483648
    cmp rdi, rax
    jl .L1578_1
    mov rsi, 4294967296
    mov rax, rdi
    sub rax, rsi
    ret
.L1578_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Dfind:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
.L1579_0:
    mov rax, r14
    sub rax, r13
    cmp rax, 1
    jg .L1579_1
    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1579_1:
    lea rsi, [r13+r14]
    mov rcx, rsi
    mov rax, rcx
    sar rax, 63
    shr rax, 63
    add rax, rcx
    sar rax, 1
    mov r15, rax
    mov rdi, rbx
    mov rsi, r15
    call zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Daddr
    cmp rax, r12
    jg .L1579_2
    mov r13, r15
    jmp .L1579_0
.L1579_2:
    mov r14, r15
    jmp .L1579_0
zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Djson:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1580_0:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 123
    jne .L1580_1
    lea rax, [rip+.L1581]
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
.L1580_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dlen
    mov r12, rax
    cmp r12, 0
    jle .L1580_2
    cmp r12, 128
    jge .L1580_2
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
.L1580_2:
    lea rax, [rip+.L1582]
    mov rsi, rax
    mov rdi, 6
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp
    cmp rax, 0
    je .L1580_3
    lea rdi, [rbx+6]
    call zy_local_x2Fmain_0__panic__pn_x2Dfind_x2Dclose
    mov r12, rax
    cmp r12, 0
    jle .L1580_4
    movzx eax, byte ptr [r12+1]
    cmp rax, 58
    jne .L1580_4
    mov rsi, r12
    sub rsi, rbx
    sub rsi, 6
    cmp rsi, 128
    jge .L1580_4
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
.L1580_4:
    lea rax, [rip+.L1583]
    mov rdi, rax
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag
.L1580_3:
    lea rax, [rip+.L1584]
    mov rdi, rax
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag
zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rsi
.L1585_0:
    lea rax, [rip+.L1586]
    mov r12, rax
    call zyl_json_quote
    mov r13, rax
    lea rax, [rip+.L1587]
    mov r14, rax
    mov rdi, rbx
    call zyl_json_quote
    mov rdi, rax
    lea rax, [rip+.L1588]
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1589_0:
    movzx esi, byte ptr [rbx+0]
    cmp rsi, 69
    je .L1589_2
    cmp rsi, 87
    jne .L1589_1
.L1589_2:
    movzx eax, byte ptr [rbx+1]
    cmp rax, 95
    jne .L1589_1
    mov rsi, 2
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dscan
    mov rsi, rax
    lea rdi, [rbx+rsi]
    movzx eax, byte ptr [rdi+0]
    cmp rax, 58
    jne .L1589_3
    mov rax, rsi
    pop rbx
    pop rbp
    ret
.L1589_3:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1589_1:
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dscan:
    # frame 0
.L1590_0:
    lea r8, [rdi+rsi]
    movzx r8d, byte ptr [r8+0]
    cmp r8, 65
    jl .L1590_3
    cmp r8, 90
    jle .L1590_2
.L1590_3:
    cmp r8, 48
    jl .L1590_5
    cmp r8, 57
    jle .L1590_4
.L1590_5:
    cmp r8, 95
    jne .L1590_1
.L1590_4:
.L1590_2:
    add rsi, 1
    jmp .L1590_0
.L1590_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dskip_x2Dsp:
    # frame 0
.L1591_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 32
    jne .L1591_1
    add rdi, 1
    jmp .L1591_0
.L1591_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__panic__pn_x2Derror_x2Dbracket_x2Dp:
    # frame 0
.L1592_0:
    lea rax, [rip+.L1593]
    mov rsi, rax
    mov r8, 6
    mov rdx, r8
    jmp zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp
zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp:
    # frame 0
    mov r8, rdx
.L1594_0:
    cmp r8, 0
    jne .L1594_1
.L1594_4:
    mov rax, 1
    ret
.p2align 4
.L1594_1:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    je .L1594_2
    mov rax, 0
    ret
.L1594_2:
    cmp r9, 0
    jne .L1594_3
    mov rax, 1
    ret
.L1594_3:
    add rdi, 1
    add rsi, 1
    sub r8, 1
    cmp r8, 0
    jne .L1594_1
    jmp .L1594_4
zy_local_x2Fmain_0__panic__pn_x2Dfind_x2Dclose:
    # frame 0
.L1595_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 93
    jne .L1595_1
    mov rax, rdi
    ret
.L1595_1:
    cmp rsi, 0
    jne .L1595_2
    mov rax, 0
    ret
.L1595_2:
    add rdi, 1
    jmp .L1595_0
.globl zyl_f_error
zyl_f_error:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L1596_0:
    cmp rdi, 0
    jne .L1596_1
    lea rax, [rip+.L1597]
    mov rsi, rax
    mov rdi, rsi
    call zyl_err_puts
    jmp .L1596_2
.L1596_1:
    lea rax, [rip+.L1598]
    mov rbx, rax
    lea rax, [rip+.L1599]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_err_puts
.L1596_2:
    mov rdi, 1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_exit
zy_local_x2Fmain_0__panic__pn_x2Ddiag:
    # frame 0
.L1600_0:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_diag_json
zyl_diag_json:
    # frame 0
.L1601_0:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_diag_json_set
zyl_diag_json_set:
    # frame 0
.L1602_0:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov r8, 0
    cmp rdi, 0
    je .L1602_1
    mov r8, 1
.L1602_1:
    mov qword ptr [rsi+0], r8
    mov rax, 0
    ret
zy_local_x2Fmain_0__panic__pn_x2Dbt_x2Doff:
    # frame 0
.L1603_0:
    lea rax, [rip+zyl_rtg_bt_off]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_backtrace_set
zyl_backtrace_set:
    # frame 0
.L1604_0:
    lea rax, [rip+zyl_rtg_bt_off]
    mov rsi, rax
    mov r8, 1
    cmp rdi, 0
    je .L1604_1
    mov r8, 0
.L1604_1:
    mov qword ptr [rsi+0], r8
    mov rax, 0
    ret
zy_local_x2Fmain_0__panic__pn_x2Dwarn:
    # frame 0
.L1605_0:
    lea rax, [rip+zyl_rtg_warn]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_warn_capture
zyl_warn_capture:
    # frame 0
.L1606_0:
    lea rax, [rip+zyl_rtg_warn]
    mov rsi, rax
    mov r8, 0
    cmp rdi, 0
    je .L1606_1
    mov r8, 1
.L1606_1:
    mov qword ptr [rsi+24], r8
    mov rdi, 0
    mov qword ptr [rsi+8], rdi
    mov rax, 0
    ret
.globl zyl_warn_emit
zyl_warn_emit:
    # frame 48
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    and rsp, -16
    sub rsp, 16
.L1607_0:
    cmp rdi, 0
    jne .L1607_1
.L1607_5:
    lea rax, [rip+.L1608]
    mov rsi, rax
    jmp .L1607_2
.L1607_1:
    mov rsi, rdi
.L1607_2:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    lea rax, [rip+zyl_rtg_warn]
    mov r13, rax
    mov rax, qword ptr [r13+24]
    cmp rax, 0
    jne .L1607_3
    mov rdi, 2
    mov rsi, rbx
    mov rdx, r12
    call zyl_rt_sys_1
    mov rdi, 2
    lea rax, [rip+.L1609]
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
.L1607_3:
    mov r14, qword ptr [r13+8]
    lea rsi, [r14+r12]
    add rsi, 2
    mov rdi, r13
    call zy_local_x2Fmain_0__panic__pn_x2Dwarn_x2Dfit
    cmp rax, 0
    je .L1607_4
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
.L1607_4:
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
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L1610_0:
    mov rdi, qword ptr [rbx+16]
    cmp rsi, rdi
    jg .L1610_1
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
.L1610_1:
    mov r8, 1024
    cmp rdi, 0
    je .L1610_2
    mov r8, rdi
.L1610_2:
    mov rdi, r8
    call zy_local_x2Fmain_0__panic__pn_x2Ddouble
    mov r12, rax
    mov rdi, qword ptr [rbx+0]
    mov rsi, r12
    call zyl_rt_realloc
    mov rsi, rax
    cmp rsi, 0
    jne .L1610_3
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L1610_3:
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+16], r12
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Ddouble:
    # frame 0
.L1611_0:
    cmp rsi, rdi
    jle .L1611_1
.L1611_2:
    shl rdi, 1
    cmp rsi, rdi
    jle .L1611_1
    jmp .L1611_2
.L1611_1:
    mov rax, rdi
    ret
.globl zyl_warn_take
zyl_warn_take:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
.L1612_0:
    lea rax, [rip+zyl_rtg_warn]
    mov rbx, rax
    mov r12, qword ptr [rbx+8]
    lea rdi, [r12+1]
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L1612_1
    lea rax, [rip+.L1613]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1612_1:
    cmp r12, 0
    jle .L1612_2
    mov rsi, qword ptr [rbx+0]
    mov rdi, r13
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    jmp .L1612_3
.L1612_2:
.L1612_3:
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
    pop rbp
    ret
.globl zyl_json_quote
zyl_json_quote:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
.L1614_0:
    cmp rdi, 0
    jne .L1614_1
.L1614_4:
    lea rax, [rip+.L1615]
    mov rsi, rax
    jmp .L1614_2
.L1614_1:
    mov rsi, rdi
.L1614_2:
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
    jne .L1614_3
    lea rax, [rip+.L1616]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1614_3:
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
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dquote_x2Dloop:
    # frame 64
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
.L1617_0:
    cmp rsi, r12
    jl .L1617_1
.L1617_13:
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
.L1617_1:
    mov rdi, qword ptr [rbp-56]
    add rdi, rsi
    movzx edi, byte ptr [rdi+0]
    lea r14, [rsi+1]
    cmp rdi, 34
    je .L1617_4
    cmp rdi, 92
    jne .L1617_2
.L1617_4:
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
    jmp .L1617_3
.L1617_2:
    cmp rdi, 10
    jne .L1617_5
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
    jmp .L1617_6
.L1617_5:
    cmp rdi, 9
    jne .L1617_7
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
    jmp .L1617_8
.L1617_7:
    cmp rdi, 13
    jne .L1617_9
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
    jmp .L1617_10
.L1617_9:
    cmp rdi, 32
    jge .L1617_11
    mov rsi, qword ptr [rbp-48]
    mov rdx, rdi
    mov rdi, r13
    call zy_local_x2Fmain_0__panic__pn_x2Desc_x2Du
    mov rbx, rax
    jmp .L1617_12
.L1617_11:
    mov r15, r13
    add r15, qword ptr [rbp-48]
    mov rcx, rdi
    mov byte ptr [r15+0], cl
    mov rbx, qword ptr [rbp-48]
    add rbx, 1
.L1617_12:
    mov r11, rbx
.L1617_10:
    mov r8, r11
.L1617_8:
    mov r10, r8
.L1617_6:
    mov r9, r10
.L1617_3:
    mov qword ptr [rbp-48], r9
    mov rsi, r14
    cmp rsi, r12
    jl .L1617_1
    jmp .L1617_13
zy_local_x2Fmain_0__panic__pn_x2Desc:
    # frame 0
    mov r8, rdx
.L1618_0:
    lea r9, [rdi+rsi]
    mov r10, 92
    mov byte ptr [r9+0], r10b
    lea r9, [rsi+1]
    add rdi, r9
    mov byte ptr [rdi+0], r8b
    lea rax, [rsi+2]
    ret
zy_local_x2Fmain_0__panic__pn_x2Desc_x2Du:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx
.L1619_0:
    lea rdi, [rbx+r12]
    lea rax, [rip+.L1620]
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
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dhexd:
    # frame 0
.L1621_0:
    cmp rdi, 10
    jge .L1621_1
.L1621_2:
    lea rax, [rdi+48]
    ret
.L1621_1:
    lea rax, [rdi+87]
    ret
zy_local_x2Fmain_0__io__io_x2Dput:
    # frame 0
.L1622_0:
    jmp zyl_out_puts
zy_local_x2Fmain_0__io__io_x2Dputs_x2Dor_x2Dnull:
    # frame 0
.L1623_0:
    cmp rdi, 0
    jne .L1623_1
.L1623_2:
    lea rax, [rip+.L1624]
    mov rsi, rax
    mov rdi, rsi
    jmp zyl_out_puts
.L1623_1:
    jmp zyl_out_puts
zy_local_x2Fmain_0__io__io_x2Dput_x2Dint:
    # frame 0
.L1625_0:
    jmp zyl_out_int
.globl zyl_itest_start
zyl_itest_start:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1626_0:
    lea rax, [rip+.L1627]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, rbx
    call zy_local_x2Fmain_0__io__io_x2Dputs_x2Dor_x2Dnull
    lea rax, [rip+.L1628]
    mov rdi, rax
    call zyl_out_puts
    pop rbx
    pop rbp
    jmp zyl_out_flush
.globl zyl_itest_outcome
zyl_itest_outcome:
    # frame 0
.L1629_0:
    cmp rdi, 0
    jne .L1629_1
.L1629_3:
    lea rax, [rip+.L1630]
    mov rsi, rax
    jmp .L1629_2
.L1629_1:
    lea rax, [rip+.L1631]
    mov rsi, rax
.L1629_2:
    mov rdi, rsi
    jmp zyl_out_puts
.globl zyl_itest_fail
zyl_itest_fail:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1632_0:
    mov rbx, rdi
    lea rax, [rip+.L1633]
    mov rdi, rax
    call zyl_out_puts
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__io__io_x2Dline
    lea rax, [rip+.L1634]
    mov rdi, rax
    pop rbx
    pop rbp
    jmp zyl_out_puts
zy_local_x2Fmain_0__io__io_x2Dline:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1635_0:
    lea rsi, [rbx+r12]
    movzx esi, byte ptr [rsi+0]
    cmp rsi, 0
    je .L1635_2
    cmp rsi, 10
    jne .L1635_1
.L1635_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L1635_1:
    lea rdi, [rbx+r12]
    mov rsi, 1
    call zyl_out_write
    add r12, 1
    jmp .L1635_0
.globl zyl_itest_summary
zyl_itest_summary:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1636_0:
    lea rax, [rip+.L1637]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, rbx
    call zyl_out_int
    lea rax, [rip+.L1638]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, r12
    call zyl_out_int
    lea rax, [rip+.L1639]
    mov rdi, rax
    call zyl_out_puts
    lea rdi, [rbx+r12]
    call zyl_out_int
    lea rax, [rip+.L1640]
    mov rdi, rax
    call zyl_out_puts
    cmp r12, 0
    jle .L1636_1
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
.L1636_1:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_exit
zyl_exit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1641_0:
    call zyl_out_flush
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zyl_rt_exit
.globl zyl_read_line
zyl_read_line:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
.L1642_0:
    call zyl_out_flush
    mov rdi, 128
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rdi, rax
    cmp rdi, 0
    jne .L1642_1
    lea rax, [rip+.L1643]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1642_1:
    mov rsi, 128
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__io__io_x2Dread_x2Dloop
    mov rsi, rax
    mov rbx, qword ptr [rsi+0]
    mov rsi, qword ptr [rsi+8]
    cmp rsi, 0
    jle .L1642_2
    lea rdi, [rsi-1]
    add rdi, rbx
    movzx eax, byte ptr [rdi+0]
    cmp rax, 13
    jne .L1642_2
    lea rdi, [rsi-1]
    jmp .L1642_3
.L1642_2:
    mov rdi, rsi
.L1642_3:
    mov r12, rdi
    lea rdi, [r12+1]
    call zyl_heap_alloc
    mov r13, rax
    cmp r13, 0
    je .L1642_4
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    lea rsi, [r13+r12]
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
.L1642_4:
    mov rdi, rbx
    call zyl_rt_free
    cmp r13, 0
    jne .L1642_5
    lea rax, [rip+.L1644]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1642_5:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__io__io_x2Dread_x2Dloop:
    # frame 32
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
.L1645_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_io_rl@tpoff]
    mov r14, rax
    mov rdi, 0
    lea rsi, [r14+16]
    mov r8, 1
    mov rdx, r8
    call zyl_rt_sys_0
    cmp rax, 1
    jne .L1645_1
    movzx eax, byte ptr [r14+16]
    cmp rax, 10
    je .L1645_1
    lea rax, [r13+1]
    cmp rax, r12
    jl .L1645_2
    lea rsi, [r12*2]
    mov rdi, rbx
    call zyl_rt_realloc
    mov rsi, rax
    cmp rsi, 0
    jne .L1645_3
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
.L1645_3:
    lea rdi, [rsi+r13]
    movzx r8d, byte ptr [r14+16]
    mov byte ptr [rdi+0], r8b
    mov rbx, rsi
    shl r12, 1
    add r13, 1
    jmp .L1645_0
.L1645_2:
    lea rsi, [rbx+r13]
    movzx edi, byte ptr [r14+16]
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    add r13, 1
    jmp .L1645_0
.L1645_1:
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
    # frame 0
    mov r8, rdx
.L1646_0:
    mov qword ptr [rdi+0], rsi
    mov qword ptr [rdi+8], r8
    mov rax, rdi
    ret
zy_local_x2Fmain_0__io__io_x2Dcells:
    # frame 0
.L1647_0:
    lea rax, [rip+zyl_rtg_cells]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_cell_get
zyl_cell_get:
    # frame 0
.L1648_0:
    cmp rdi, 0
    jl .L1648_1
.L1648_2:
    cmp rdi, 16
    jge .L1648_1
    lea rax, [rip+zyl_rtg_cells]
    mov rsi, rax
    shl rdi, 3
    add rsi, rdi
    mov rax, qword ptr [rsi+0]
    ret
.L1648_1:
    mov rax, 0
    ret
.globl zyl_cell_set
zyl_cell_set:
    # frame 0
.L1649_0:
    cmp rdi, 0
    jl .L1649_1
.L1649_3:
    cmp rdi, 16
    jge .L1649_1
    lea rax, [rip+zyl_rtg_cells]
    mov r8, rax
    shl rdi, 3
    add r8, rdi
    mov qword ptr [r8+0], rsi
    jmp .L1649_2
.L1649_1:
.L1649_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__env__ev_x2Denvp_x2Dcell:
    # frame 0
.L1650_0:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_rt_set_env
zyl_rt_set_env:
    # frame 0
.L1651_0:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
.globl zyl_rt_envp
zyl_rt_envp:
    # frame 0
.L1652_0:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_rt_getenv
zyl_rt_getenv:
    # frame 0
.L1653_0:
    cmp rdi, 0
    je .L1653_2
.L1653_4:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 0
    jne .L1653_1
.L1653_2:
    mov rax, 0
    ret
.L1653_1:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L1653_3
    mov rax, 0
    ret
.L1653_3:
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zy_local_x2Fmain_0__env__ev_x2Dscan
zy_local_x2Fmain_0__env__ev_x2Dscan:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1654_0:
    mov rdi, qword ptr [rbx+0]
    cmp rdi, 0
    jne .L1654_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L1654_1:
    mov rsi, r12
    call zy_local_x2Fmain_0__env__ev_x2Dmatch
    mov rsi, rax
    cmp rsi, 0
    jne .L1654_2
    add rbx, 8
    jmp .L1654_0
.L1654_2:
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__env__ev_x2Dmatch:
    # frame 0
.L1655_0:
    movzx r8d, byte ptr [rsi+0]
    cmp r8, 0
    jne .L1655_1
    movzx eax, byte ptr [rdi+0]
    cmp rax, 61
    jne .L1655_2
    lea rax, [rdi+1]
    ret
.L1655_2:
    mov rax, 0
    ret
.L1655_1:
    movzx eax, byte ptr [rdi+0]
    cmp rax, r8
    jne .L1655_3
    add rdi, 1
    add rsi, 1
    jmp .L1655_0
.L1655_3:
    mov rax, 0
    ret
zy_local_x2Fmain_0__env__ev_x2Dmax:
    # frame 0
.L1656_0:
    mov rax, 32
    ret
zy_local_x2Fmain_0__env__ev_x2Dreg:
    # frame 0
.L1657_0:
    lea rax, [rip+zyl_rtg_rt_exit_reg]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__env__ev_x2Dlock:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1658_0:
    mov rsi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L1658_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1658_1:
    call zyl_rt_sys_24
    jmp .L1658_0
zy_local_x2Fmain_0__env__ev_x2Dunlock:
    # frame 0
.L1659_0:
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    ret
.globl zyl_rt_atexit
zyl_rt_atexit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L1660_0:
    lea rax, [rip+zyl_rtg_rt_exit_reg]
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__env__ev_x2Dlock
    mov rsi, qword ptr [r12+8]
    cmp rsi, 32
    jl .L1660_1
    mov rdi, 0
    mov rdx, r12
    mov rcx, rdi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1660_1:
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
    pop rbp
    ret
zy_local_x2Fmain_0__env__ev_x2Dpop:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1661_0:
    lea rax, [rip+zyl_rtg_rt_exit_reg]
    mov rbx, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__env__ev_x2Dlock
    mov rsi, qword ptr [rbx+8]
    cmp rsi, 0
    jne .L1661_1
    mov rdi, 0
    mov rdx, rbx
    mov rcx, rdi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1661_1:
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
    pop rbp
    ret
.globl zyl_rt_run_atexit
zyl_rt_run_atexit:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1662_0:
    call zy_local_x2Fmain_0__env__ev_x2Dpop
    mov rdi, rax
    cmp rdi, 0
    jne .L1662_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1662_1:
    call zyl_rt_call0
    jmp .L1662_0
.globl zyl_rt_exit
zyl_rt_exit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1663_0:
    call zyl_rt_run_atexit
    call zyl_term_flush
    mov rax, QWORD PTR [rip+exit@GOTPCREL]
    mov rdi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1663_1
    cmp rdi, 0
    jle .L1663_1
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call1
.L1663_1:
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__env__ev_x2Dexit_x2Dgroup
zy_local_x2Fmain_0__env__ev_x2Dexit_x2Dgroup:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1664_0:
    mov rdi, rbx
    call zyl_rt_sys_231
    mov rdi, rbx
    call zyl_rt_sys_60
    jmp .L1664_0
zy_local_x2Fmain_0__crc__rt_x2Dsse42:
    # frame 0
.L1665_0:
    lea rax, [rip+zyl_rtg_cpu_sse42]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    cmp rdi, 0
    jne .L1665_1
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
    jle .L1665_2
    mov r8, 2
    jmp .L1665_3
.L1665_2:
    mov r8, 1
.L1665_3:
    mov qword ptr [rsi+0], r8
    mov rax, r8
    cmp rax, 2
    sete al
    movzx rax, al
    ret
.L1665_1:
    mov rax, rdi
    cmp rax, 2
    sete al
    movzx rax, al
    ret
zy_local_x2Fmain_0__crc__crc_x2Dtab:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L1666_0:
    lea rax, [rip+zyl_rtg_crc32c_tab]
    mov rbx, rax
    lea rax, [rip+zyl_rtg_crc32c_tab_ok]
    mov r12, rax
    mov rax, qword ptr [r12+0]
    cmp rax, 1
    jne .L1666_1
    mov rax, rbx
    pop r12
    pop rbx
    pop rbp
    ret
.L1666_1:
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__crc__crc_x2Dfill
    mov rsi, 1
    mov qword ptr [r12+0], rsi
    mov rax, rbx
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__crc__crc_x2Dfill:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L1667_0:
    cmp r12, 255
    jle .L1667_1
.L1667_3:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1667_1:
    lea rsi, [r12*8]
    lea r13, [rbx+rsi]
    mov rsi, 8
    mov rdi, r12
    cmp rsi, 0
    je .L1667_2
    mov rdi, r12
    call zy_local_x2Fmain_0__crc__crc_x2Dbits
    mov rdi, rax
.L1667_2:
    mov qword ptr [r13+0], rdi
    add r12, 1
    cmp r12, 255
    jle .L1667_1
    jmp .L1667_3
zy_local_x2Fmain_0__crc__crc_x2Dbits:
    # frame 0
.L1668_0:
    cmp rsi, 0
    jne .L1668_1
.L1668_4:
    mov rax, rdi
    ret
.p2align 4
.L1668_1:
    mov rax, rdi
    and rax, 1
    cmp rax, 1
    jne .L1668_2
    mov r8, rdi
    shr r8, 1
    mov r9, 2197175160
    xor r8, r9
    jmp .L1668_3
.L1668_2:
    mov r8, rdi
    shr r8, 1
.L1668_3:
    mov rdi, r8
    sub rsi, 1
    cmp rsi, 0
    jne .L1668_1
    jmp .L1668_4
zy_local_x2Fmain_0__crc__crc_x2Dbyte:
    # frame 0
    mov r8, rdx
.L1669_0:
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
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L1670_0:
    cmp r9, 0
    jne .L1670_1
.L1670_2:
    mov rax, rsi
    ret
.p2align 4
.L1670_1:
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
    jne .L1670_1
    jmp .L1670_2
.globl zyl_crc32c_soft
zyl_crc32c_soft:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1671_0:
    call zy_local_x2Fmain_0__crc__crc_x2Dtab
    mov rdi, rax
    mov rsi, 4294967295
    and rsi, rbx
    mov r8, 8
    mov rdx, r12
    mov rcx, r8
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__crc__crc_x2Dsoft_x2Dbytes
.globl zyl_crc32c_u64
zyl_crc32c_u64:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1672_0:
    call zy_local_x2Fmain_0__crc__rt_x2Dsse42
    cmp rax, 0
    je .L1672_1
    mov rdx, rbx
    mov rcx, r12
    mov eax, edx
    crc32 rax, rcx
    pop r12
    pop rbx
    pop rbp
    ret
.L1672_1:
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zyl_crc32c_soft
.globl zyl_crc32c_u8
zyl_crc32c_u8:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1673_0:
    call zy_local_x2Fmain_0__crc__rt_x2Dsse42
    cmp rax, 0
    je .L1673_1
    mov rdx, rbx
    mov rcx, r12
    mov eax, edx
    crc32 eax, cl
    pop r12
    pop rbx
    pop rbp
    ret
.L1673_1:
    call zy_local_x2Fmain_0__crc__crc_x2Dtab
    mov rdi, rax
    mov rsi, 4294967295
    and rsi, rbx
    mov r8, r12
    and r8, 255
    mov rdx, r8
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__crc__crc_x2Dbyte
zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Dcmp_x7EInt_x2CInt_x2CInt_x2CInt_x2CInt_x2CInt:
    # frame 16
    push rbx
    push r12
    mov r10, r8
    mov r8, rdx
    mov r11, r9
    mov r9, rcx
.L1674_0:
    cmp r8, r9
    jl .L1674_1
.L1674_6:
    cmp r10, r11
    jge .L1674_2
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1674_2:
    cmp r10, r11
    jle .L1674_3
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1674_3:
    mov rax, 0
    pop r12
    pop rbx
    ret
.p2align 4
.L1674_1:
    lea rbx, [r8*8]
    add rbx, rdi
    mov rbx, qword ptr [rbx+0]
    lea r12, [r8*8]
    add r12, rsi
    mov r12, qword ptr [r12+0]
    cmp rbx, r12
    jge .L1674_4
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1674_4:
    cmp rbx, r12
    jle .L1674_5
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1674_5:
    add r8, 1
    cmp r8, r9
    jl .L1674_1
    jmp .L1674_6
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
.L353:
    .string "0123456789ABCDEF"
.L355:
    .string ""
.L357:
    .string ""
.L359:
    .string ""
.L360:
    .string "0123456789ABCDEF"
.L375:
    .string "0"
.L378:
    .string "0"
.L384:
    .string "PANIC: error[E_OUT_OF_MEMORY]: "
.L385:
    .string "\n  = requested "
.L386:
    .string " bytes; "
.L387:
    .string " bytes already allocated; budget "
.L388:
    .string " bytes\n  = help: set ZYL_MAX_MEMORY to a byte count to raise the budget, or ZYL_MAX_MEMORY=0 to remove it\n"
.L393:
    .string "memory budget exhausted"
.L394:
    .string "out of memory allocating an arena block header"
.L395:
    .string "out of memory allocating an arena block"
.L415:
    .string "\n"
.L417:
    .string "zyl_heap_alloc: size too large size="
.L418:
    .string "zyl_heap_alloc: FAILED size="
.L431:
    .string "memory budget exhausted"
.L432:
    .string "mmap failed for a region block"
.L441:
    .string "E_REGION_EXHAUSTED: "
.L442:
    .string "fixed"
.L443:
    .string "arena"
.L444:
    .string " region of "
.L445:
    .string " bytes is full"
.L449:
    .string "zyl_ralloc: size too large size="
.L465:
    .string "zyl: ffi-unpin: pointer not from ffi-pin/Pin arena\n"
.L468:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L469:
    .string ": index "
.L470:
    .string " outside a word array of length "
.L473:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L474:
    .string ": not a word array"
.L476:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L477:
    .string ": not a word array"
.L479:
    .string "E_OUT_OF_MEMORY: word array view"
.L481:
    .string "E_OUT_OF_MEMORY: word array"
.L484:
    .string "E_OUT_OF_MEMORY: word array"
.L487:
    .string "w-len"
.L488:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L489:
    .string ": not a word array"
.L491:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L492:
    .string ": not a word array"
.L494:
    .string "w-get"
.L496:
    .string "w-set"
.L498:
    .string "E_OUT_OF_MEMORY: word array view"
.L500:
    .string "w-view"
.L501:
    .string "w-view"
.L503:
    .string "w-view"
.L504:
    .string "w-view"
.L507:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L508:
    .string ": not an array"
.L510:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L511:
    .string ": not an array"
.L513:
    .string "E_OUT_OF_MEMORY: array"
.L515:
    .string "array-cap"
.L516:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L517:
    .string ": not an array"
.L519:
    .string "array-filled"
.L520:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L521:
    .string ": not an array"
.L523:
    .string "E_OUT_OF_MEMORY: array"
.L526:
    .string "E_OUT_OF_MEMORY: array"
.L528:
    .string "array-get"
.L529:
    .string "array-get"
.L530:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L531:
    .string ": not an array"
.L534:
    .string "array-copy"
.L535:
    .string "array-copy"
.L536:
    .string "array-copy"
.L537:
    .string "array-copy"
.L539:
    .string "array-set"
.L540:
    .string "array-set"
.L545:
    .string "attribute table"
.L554:
    .string "ref cell"
.L559:
    .string ""
.L563:
    .string "E_USE_AFTER_FREE: string buffer used after it was destroyed"
.L566:
    .string "0123456789abcdef"
.L568:
    .string "zyl: str-append: invalid string pointer 0x"
.L569:
    .string ""
.L570:
    .string "\n"
.L572:
    .string "codegen buffer limit exceeded"
.L573:
    .string "E_INDEX_OUT_OF_BOUNDS: string buffer full"
.L624:
    .quad 0
.L625:
    .quad 0
.L630:
    .quad -4332466134535158144
.L631:
    .quad 4890905902319617664
.L644:
    .string "eef453d6923bd65a113faa2906a13b3f9558b4661b6565f84ac7ca59a424c507baaee17fa23ebf765d79bcf00d2df649e95a99df8ace6f53f4d82c2c107973dc91d8a02bb6c1059479071b9b8a4be869b64ec836a47146f99748e2826cdee284e3e27a444d8d98b7fd1b1b2308169b258e6d8c6ab0787f72fe30f0f5e50e20f7b208ef855c969f4fbdbd2d335e51a935de8b2b66b3bc4723ad2c788035e613828b16fb203055ac764c3bcb5021afcc31addcb9e83c6b1793df4abe242a1bbf3dd953e8624b85dd78d71d6dad34a2af0d87d4713d6f33aa6b8672648c40e5ad68a9c98d8ccb009506680efdaf511f18c2d43bf0effdc0ba480212bd1b2566def284a57695fe98746d014bb630f7604b57a5ced43b7e3e9188419ea3bd35385e2dcf42894a5dce35ea52064cac828675b9818995ce7aa0e1b27343efebd1940993a1ebfb4219491a1f1014ebe6c5f90bf8ca66fa129f9b60a6d41a26e077774ef6fd00b897478238d08920b098955522b49e20735e8cb1638255b46e5f5d5535b0c5a890362fddbc62eb2189f734aa831df712b443bbd52b7ba5e9ec7501d523e49a6bb0aa55653b2d47b233c92125366ec1069cd4eabe89f8999ec0bb696e840af148440a256e2c76c00670ea43ca250d96cd2a865764dbca380406926a5e5728bc807527ed3e12bcc605083704f5ecf2eba09271e88d976bf7864a44c633682e93445b8731587ea37ab3ee6afbe0211db8157268fdae9e4c5960ea05bad82964e61acf033d1a45df6fb92487298e33bd8fd0c16206306baba5d3b6d479f8e056b3c4f1ba87bc86968f48a4899877186ce0b62e2929aba83c331acdabfe94de878c71dcd9ba0b49259ff0c08b7f1d0b14af8e5410288e1b6f07ecf0ae5ee44dd9db71e91432b1a24ac9e82cd9f69d6150892731ac9faf056ebe311c083a225cd2ab70fe17c79ac6ca6dbd630a48aaf406d64d3d9db981787d092cbbccdad5b10885f0468293f0eb4e25bbf56008c58ea5a76c582338ed2621af2af2b80af6f24ed1476e2c07286faa1af5af660db4aee182cca4db847945ca50d98d9fc890ed4da37fce126597973ce50ff107bab528a0cc5fc196fefd7d0c1e53ed49a96272c8ff77b1fcbebcdc4f25e8e89c13bb0f7a9faacf3df73609b177b191618c54e9acc795830d75038c1dd59df5b9ef6a2417f97ae3d0d2446f254b0573286b44ad1d9becce62836ac5774ee367f9430aec32c2e801fb244576d5229c41f793cda73ff3a20279ed56d48a6b43527578c1110f9845418c345644d6830a13896b78aaa9be5691ef416bd60c23cc986bc656d553edec366b11c6cb8f2cbfbe86b7ec8aa894b3a202eb1c3f397bf7d71432f3d6a9b9e08a83a5e34f07daf5ccd93fb0cc53e858ad248f5c22c9d1b3400f8f9cff6891376c36d99995be23100809b9c21fa1b58547448ffffb2dabd40a0c2832a78ae2e69915b3fff9f916c90c8f323f516c8dd01fad907ffc3bae3da7d97f6792e3b1442798f49ffb4a99cd11cfdf41779cdd95317f31c7fa1d40405643d711d5838a7d3eef7f1cfc52482835ea666b2572ad1c8eab5ee43b66da3243650005eecfd863b256369d4a4090bed43e40076a82873e4f75e2224e685a7744a6e804a291a90de3535aaae202711515d0a205cb36d3515c2831559a830d5a5b44ca873e038412d9991ed58091e858790afe9486c2a5178fff668ae0b6626e974dbe39a872ce5d73ff402d98e3fb0a3d212dc8128f80fa687f881c7f8e7ce66634bc9d0b99a139029f6a239f721c1fffc1ebc44e80c987434744ac874ea327ffb266b56220fbe9141915d7a9224bf1ff9f0062baa89d71ac8fada6c9b56f773fc3603db4a9c4ce17b399107c22cb550fb4384d21d3f6019da07f549b2b7e2a53a146606a4899c102844f94e0fb2eda7444cbfc426dc0314325637a1939fa911155fefb5308f03d93eebc589f88793555ab7eba27ca96267c7535b763b54bc1558b2f3458debbb01b9283253ca29eb1aaedfb016f16ea9c227723ee8bcb465e15a979c1cadc92a1958a7675175f0bfacd89ec191ec9b749faed14125d36cef980ec671f667be51c79a85916f48482b7e12780e7401a8f31cc0937ae58d2d1b2ecb8b0908810b2fe3f0b8599ef07861fa7e6dcb4aa15dfbdcece67006ac967a791e093e1d49a8bd6a141006042bde0c8bb2c5c6d24e0aecc49914078536d58fae9f773886e18da7f5bf590966848af39a475506a899e888f99797a5e012d6d8406c952429603aab37fd7d8f58178c8e5087ba6d33b83d5605fcdcf32e1d6fb1e4a9a90880a64855c3be0a17fcd265cf2eea09a55067fa6b34ad8c9dfc06ff42faa48c0ea481ed0601d8efc57b08bf13b94daf124da26823c12795db6ce5776c53d08d6b70858a2cb1717b52481ed54768c4b0c64ca6ecb7ddcdda26da268a9942f5dcf7dfd09fe5d54150b090b02d3f93b35435d7c4c9efa548d26e5a6e1c47bc5014a1a6dafc6b8e9b0709f109a359ab6419ca1091bf867241c8cc6d4c0c30163d203c94b629b407691d7fc44f879e0de63425dcf1dc21094364dfb5636985915fc12f542e4f294b943e17a2bc43e6f5b7b17b2939d979cf3ca6cec5b5aa705992ceecf9c42bd8430bd0827723150c6ff782a838353ece53cec4a314ebda4f8bf5635246428940f4613ae5ed136871b7795e136be99b913179899f6858428e2557b59846e3fe757dd7ec07426e5331aeada2fe589cf9096ea6f3848984f3ff0d2c85def7621b4bca50b065abe630fed077a756b53a9e1ebce4dc7f16dfbd3e8495912c628948d3360f09cf6e4bd64712dd7abbbd95cb080392cc4349decbd8d794d96aacfb3dca04777f541c567ecf0d7a0fc5583a089e42caaf9491b60f41686c49db57244ac5d37d5b79b6239311c2875c522ced5d77485cb25823ac77d633293366b828b86a8d39ef77164bcae5dff9c02033197a8530886b54dbdebd9f57f830283fdfcd267caa862a12d66d072df63c324fd7b8380dea93da4bc604247cb9e59f71e6da46116538d0deb7852d9be85f074e608cd795be87051665667902e276c921f8b806bd9714632dff600ba1cd8a3db53b6a086cfcd97bf97f380e8a40eccd228a4c8a883c0fdaf7df06122cd128006b2cdfad2a4b13d1b5d6c796b805720085f819cc3a6eec6311a63cbe3303674053bb0c3f490aa77bd60fcbedbfc4411068a9cf4f1b4d515acb93bee92fb5515482d44991711052d8bf3c5751bdd152d4d1c4abf5cd54678eef0b6d262d45a78a0635def340a98172aace486fb897116c87c349580869f0e7aac0ed45d35e6ae3d4da0bae0a846d21957128974836059cca109e998d258869facd72bd1a438703fc94b91ff83775423cc067b6306a34627ddcfb67f6455292cbf081a3bc84c17b1d542e41f3d6a7377eeca20caba5f1d9e4a938e938662882af53e547eb47b7282ee9cb23867fb2a35b28de99e619a4f23aa43dec681f9f4c31f316405fa00e2ec94d48b3c113c38f9f37ede83bc408dd3dd04ae0b158b4738705e9624ab50b148d445d98ddaee19068c763badd624dd9b095787f8a8d4cfa417c9e54ca5d70a80e5d6a9f6d30a038d1dbc5e9fcf4ccd211f4cd47487cc8470652b7647c3200069671f84c8d4dfd2c63f3b29ecd9f40041e073a5fb0a17c777cf09f468107100525890cf79cc9db955c2cc7182148d4066eeb481ac1fe293d599bfc6f14cd848405530a21727db38cb002fb8ada00e5a506a7cca9cf1d206fdc03ba6d90811f0e4851cfd442e4688bd304a908f4a166d1da6639e4a9cec15763e2e9a598e4e043287fec5dd44271ad3cdba40eff1e1853f29fdf7549530e188c128d12bee59e68ef47c9a94dd3e8cf578b982bb74f8301958cec13a148e3032d6e7e36a52363c1faf01f18899b1bc3f8ca1dc44e6c3cb279ac196f5600f15a7b7e529ab103a5ef8c0b9bcb2b812db11a5de7415d448f6b6f0e7ebdf661791d60f56111b495b3464ad21936b9fcebb25c995cab10dd900beec34b84687c269ef3bfb3d5d514f40eea742e65829b3046b0afa0cb4a5a3112a51128ff71a0fe2c2e6dc47f0e785eaba72abb3f4e093db73a09359ed216765690f56e0f218b8d25088b8306869c13ec3532c8c974f73837255731e414218c73a13fbafbd2350644eeacfe5d1929ef90898fadbac6c247d62a583df45f746b74abf39894bc396ce5da7726b8bba8c328eb783ab9eb47c81f5114f066ea92f3f326564d686619ba27255a2c80a537b0efefebd8613fd0145877585bd06742ce95f5f36a798fc4196e952e72c48113823b73704d17f3b51fca3a7a0f75a15862ca504c582ef85133de648c49a984d73dbe722fba3ab66580d5fdaf5c13e60d0d2e0ebbacc963fee10b7d1b3318df905079926a8ffbbcfe994e5c61ffdf17746497f70529fd561f1fd0f9bd3feb6ea8bedefa633c7caba6e7c5382c8fe64a52ee96b8fc0f9bd690a1b68637b3dfdce7aa3c673b09c1661a651213e2d06bea10ca65c084ec31bfa0fe5698db8486e494fcff30a62f3e2f893dec3f1265a89dba3c3efccfa986ddb5c6b3a76b7f89629465a75e01cbe89523386091465f6bbb397f1135823ee2ba6c0678b597f746aa07ded582e2c94db483840b717efa8c2a44eb4571cdcba121a4650e4ddeb92f34d62616ce413e896a0d7e51e156677b020baf9c81d17915e2486ef32cd600ace1474dc1d122eb5b5ada8aaff80b80d819992132456bae3231912d5bf60e610e1fff697ed6c698df5efabc5979c8fca8d3ffa1ef463c1b1736b96b6fd83b3bd308ff8a6b17cb2ddd0467c64bce4a0ac7cb3f6d05ddbde8aa22c0dbef60ee46bcdf07a423aa96bad4ab7112eb3929d86c16c98d2c953c6d89d64d57a607744e871c7bf077ba8b787625f056c7c4a8b11471cd764ad4972a93af6c6c79b5d2dd598e40d3dd89bcfd389b478798234794aff1d108d4ec2c3843610cb4bf160cbcedf722a585139baa54394fe1eedb8fec2974eb4ee658828ce947a3da6a9273e733d226229feea32811ccc668829b8870806357d5a3f525fa163ff802a3426a8ca07c2dcb0cf26f7c9bcff6034c13052fc89b393dd02f0b5fc2c3f3841f17c67bbac2078d443ace29d9ba7832936edc0d54b944b84aa4c0dc5029163f384a9310a9e795e65d4df11f64335bcf065d37d4d4617b5ff4a16d599ea0196163fa42e504bced1bf8e4e45c06481fb9bcf8d39e45ec2862f71e1d6f07da27a82c370885d767327bb4e5a4c964e858c91ba26553a6a07f8d510f86fbbe226efb628afea890489f70a55368beadab0aba3b2dbe52b45ac74ccea842e92c8ae6b464fc96f3b0b8bc90012929db77ada0617e3bbcb09ce6ebb40173744e55990879ddcaabdcc420a6a101d05158f57fa54c2a9eab69fa946824a12232db32df8e9f354656447939822dc96abf9dff9772470297ebd59787e2b93bc56f78bfbea76c619ef3657eb4edb3c55b65aaefae51477a06b03ede622920b6b23f1dab99e59958885c4e95fab368e45eced88b402f7fd75539b11dbcb0218ebb414aae103b5fcd2a881d652bdc29f26a119d59944a37c0752a24be76d3346f0495f857fcae62d8493a56f70a4400c562ddba6dfbd9fb8e5b88ecb4ccd500f6bb952d097ad07a71f26b27e2000a41346a7a7825ecc24c873782f8ed400668c0c28c8a2f67f2dfa90563b728900802f0f32facbb41ef979346bca4f2b40a03ad2ffb9fea126b7d78186bce2f610c84987bfa89f24b832e6b0f4360dd9ca7d2df4d7c9c6ede63fa05d314391503d1c79720dbbf8a95fcf88747d9475a44c6397ce912a9b69dbe1b548ce7cc986afbe3ee11abac24452da229b021bfbe85badce996168f2d56790ab41c2a2fae27299423fb9c397c560ba6b0919a5dccd879fc967d41abdb6b8e905cb600f5400e987bbc1c920ed246723473e3813290123e9aab23b689436c0760c86e30bf9a0b6720aaf6521b94470938fa89bcef808e40e8d5b3e69e7958cb87392c2c2b60b1d1230b20e0490bd77f3483bb9b9b1c6f22b5e6f48c2b4ecd5f01a4aa8281e38aeb6360b1af3e2280b6c20dd523225c6da63c38de1b08d590723948a535f579c487e5a38ad0eb0af48ec79ace8372d835a9df0c6d851dcdb1b2798182244f8e431456cf88e658a08f0f8bf0f156b1b8e9ecb641b58ffac8b2d36eed2dac5e272467e3d222f3fd7adf884aa8791775b0ed81dcc6abb0f86ccbb52ea94baea98e947129fc2b4e9a87fea27a539e9a53f2398d747b36224d29fe4b18e88640e8eec7f0d19a03aad83a3eeeef9153e891953cf68300424aca48ceaaab75a8e2b5fa8c3423c052dd7cdb02555653131b63792f412cb06794d808e17555f3ebf11e2bbd88bbee40bd0a0b19d2ab70e6ed65b6aceaeae9d0ec4c8de047564d20a8bf245825a5a445275fb158592be068d2eeed6e2f0f0d567129ced737bb6c4183d55464dd69685606bc428d05aa4751e4caa97e14c3c26b886f53304714d9265dfd53dd99f4b3066a8993fe2c6d07b7fabe546a8038efe4029bf8fdb78849a5f96de98520472bdd033ef73d256a5c0f77c963e66858f6d444095a8637627989aaddde7001379a44aa8bb127c53b17ec1595560c018580d5d52e9d71b689dde71afaab8f01e6e10b4a69226712162ab070dcab3961304ca70e8b6b00d69bb55c8d13d607b97c5fd0d22e45c10c42a2b3b058cb89a7db77c506a8eb98a7a9a5b04e377f3608e92adb242b267ed1940f1c61c55f038b237591ed3df01e85f912e37a36b6c46dec52f66888b61313bbabce2c62323ac4b3b3da015ae397d8aa96c1b77abec975e0a0d081ad9c7dced53c7225596e7bd358c904a21881cea14545c75757e50d64177da2e54aa242499697392d2dde50bd1d5d0b9e9d4ad2dbfc3d07787955e4ec64b44e86484ec3c97da624ab4bd5af13bef0b113ea6274bbdd0fadd61ecb1ad8aeacdd58ecfb11ead453994ba67de18eda5814af281ceb32c4b43fcf480eacf948770ced7a2425ff75e14fc31a1258379a94d028dcad2f7f5359a3b3e096ee45813a04330fd87b5f28300ca0d8bca9d6e188853fc9e74d1b791e07e48775ea264cf55347ec612062576589dda95364afe032a819ef79687aed3eec5513a83ddbd83f522059abe14cd44753b52c4926a9672793543c16d9a0095928a2775b7053c0f178294f1c90080baf72cb15324c68b12dd6339971da05074da7beed3f6fc16ebca5e04bce5086492111aea88f4bb1ca6bcf585ec1e4a7db69561a52b31e9e3d06c32e69392ee8e921d5d073aff322e62439fd0b877aa3236a4b44909befeb9fad487c3e69594bec44de15b4c2ebe687989a9b4901d7cf73ab0acd90f9d37014bf60a11b424dc35095cd80f538484c19ef38c95e12e13424bb40e132865a5f206b06fba8cbccc096f5088cbf93f87b7442e45d4afebff0bcb24aafef78f69a51539d749dbe6fecebdedd5beb573440e5a884d1c89705f4136b4a59731680a88f8953031abcc77118461cefcfdc20d2b36ba7c3ed6bf94d5e57a42bc3d32907604691b4d8637bd05af6c69b5a63f9a49c2c1b110a7c5ac471b4784230fcf80dc33721d54d1b71758e219652bd3c36113404ea4a983126e978d4fdf3b645a1cac083126eaa3d70a3d70a3d70a3d70a3d70a3d70a4cccccccccccccccccccccccccccccccd80000000000000000000000000000000a0000000000000000000000000000000c8000000000000000000000000000000fa0000000000000000000000000000009c400000000000000000000000000000c3500000000000000000000000000000f424000000000000000000000000000098968000000000000000000000000000bebc2000000000000000000000000000ee6b28000000000000000000000000009502f900000000000000000000000000ba43b740000000000000000000000000e8d4a5100000000000000000000000009184e72a000000000000000000000000b5e620f4800000000000000000000000e35fa931a000000000000000000000008e1bc9bf040000000000000000000000b1a2bc2ec50000000000000000000000de0b6b3a7640000000000000000000008ac7230489e800000000000000000000ad78ebc5ac6200000000000000000000d8d726b7177a80000000000000000000878678326eac90000000000000000000a968163f0a57b4000000000000000000d3c21bcecceda100000000000000000084595161401484a00000000000000000a56fa5b99019a5c80000000000000000cecb8f27f4200f3a0000000000000000813f3978f89409844000000000000000a18f07d736b90be55000000000000000c9f2c9cd04674edea400000000000000fc6f7c40458122964d000000000000009dc5ada82b70b59df020000000000000c5371912364ce3056c28000000000000f684df56c3e01bc6c7320000000000009a130b963a6c115c3c7f400000000000c097ce7bc90715b34b9f100000000000f0bdc21abb48db201e86d4000000000096769950b50d88f41314448000000000bc143fa4e250eb3117d955a000000000eb194f8e1ae525fd5dcfab080000000092efd1b8d0cf37be5aa1cae500000000b7abc627050305adf14a3d9e40000000e596b7b0c643c7196d9ccd05d00000008f7e32ce7bea5c6fe4820023a2000000b35dbf821ae4f38bdda2802c8a800000e0352f62a19e306ed50b2037ad2000008c213d9da502de454526f422cc340000af298d050e4395d69670b12b7f410000daf3f04651d47b4c3c0cdd765f11400088d8762bf324cd0fa5880a69fb6ac800ab0e93b6efee00538eea0d047a457a00d5d238a4abe9806872a4904598d6d88085a36366eb71f04147a6da2b7f864750a70c3c40a64e6c51999090b65f67d924d0cf4b50cfe20765fff4b4e3f741cf6d82818f1281ed449fbff8f10e7a8921a4a321f2d7226895c7aff72d52192b6a0dcbea6f8ceb02bb399bf4f8a69f764490fee50b7025c36a0802f236d04753d5b49f4f2726179a224501d762422c946590c722f0ef9d80aad6424d3ad2b7b97ef5f8ebad2b84e0d58bd2e0898765a7deb29b934c3b330c857763cc55f49f88eb2fc2781f49ffcfa6d53cbf6b71c76b25fbf316271c7fc3908a8bef464e3945ef7a97edd871cfda3a5697758bf0e3cbb5acbde94e8e43d0c8ec3d52eeed1cbea317ed63a231d4c4fb274ca7aaa863ee4bdd945e455f24fb1cf88fe8caa93e74ef6ab975d6b6ee39e436b3e2fd538e122b44e7d34c64a9c85d4460dbbca87196b61690e40fbeea1d3a4abc8955e946fe31cdb51d13aea4a488dd6babab6398bdbe41e264589a4dcdab14c696963c7eed2dd18d7eb76070a08aecfc1e1de5cf543ca2b0de65388cc8ada83b25a55f43294bcbdd15fe86affad91249ef0eb713f39ebe8a2dbf142dfcc7ab6e3569326c784337acb92ed9397bf99649c2c37f07965404d7e77a8f87daf7fbdc33745ec97be90686f0ac99b4e8dafd69a028bb3ded71a3a8acd7c0222311bcc40832ea0d68ce0cd2d80db02aabd62bf50a3fa490c3019083c7088e1aab65db792667c6da79e0faa4b8cab1a1563f52577001b891185938cde6fd5e09abcf26ed4c0226b55e6f8680b05e5ac60b6178544f8158315b05b4a0dc75f1778e39d6696361ae3db1c721c913936dd571c84c03bc3a19cd1e38e9fb5878494ace3a5f04ab48a04065c7239d174b2dcec0e47b62eb0d64283f9c76c45d1df942711d9a3ba5d0bd324f8394f5746577930d6500ca8f44ec7ee364799968bf6abbe85f207e998b13cf4e1ecbbfc2ef456ae276e89e3fedd8c321a67eefb3ab16c59b14a2c5cfe94ef3ea101e95d04aee3b80ece5bba1f1d158724a12bb445da9ca61281f2a8a6e45ae8edc97ea1575143cf97226f52d09d71a3293bd924d692ca61be758593c2626705f9c56b6e0c377cfa2e12e6f8b2fb00c77836ce498f455c38b997a0b6dfb9c0f9564478edf98b59a373fec4724bd4189bd5eacb2977ee300c50fe758edec91ec2cb657df3d5e9bc0f653e12f2967b66737e3ed8b865b215899f46cbd79e0d20082ee74ae67f1e9aec07187ecd8590680a3aa11da01ee641a708de9e80e6f4820cc9495884134fe908658b23109058d147fdcddaa51823e34a7eedebd4b46f0599fd415d4e5e2cdc1d1ea966c9e18ac7007c91a850fadc09923329e03e2cf6bc604ddb0a6539930bf6bff4584db8346b786151ccfe87f7cef46ff16e612641865679a6381f14fae158c5f6e4fcb7e8f3f60c07ea26da3999aef7749e3be5e330f38f09dcb090c8001ab551c5cadf5bfd3072cc5fdcb4fa002162a6373d9732fc7c8f7f69e9f11c4014dda7e2867e7fddcdd9afac646d63501a1511db281e1fd541501b8f7d88bc24209a5651f225a7ca91a42269ae757596946075f3375788de9b06958c1a12d2fc39789370052d6b1641c83aef209787bb47d6b84c0678c5dbd23a49a9745eb4d50ce6332f840b7ba963646e0bd176620a501fbffb650e5a93bc3d898ec5d3fa8ce427affa3e51f138ab4cebe93ba47c980e98cdfc66f336c36b10137b8a8d9bbe123f017b80b0047445d4184e6d3102ad96cec1da60dc059157491e59043ea1ac7e4139287c89837ad68db2fb454e4a179dd187729babe4598c311fbe16a1dc9d8545e94f4296dd6fef3d67a8ce2529e2734bb1d1899e4a65f58660cb01ae745b101e9e45ec05dcff72e7f8fdc21a1171d42645d76707543f4fa1f73899504ae72497eba6a06494a791c53a8abfa45da0edbde690487db9d17636892d6f8d7509292d60345a9d2845d3c42b6865b86925b9bc5c20b8a2392ba45a9b2a7f26836f282b7328e6cac7768d7141ed1ef0244af2364ff3207d795430cd9268335616aed761f1f7f44e6bd49e807b8a402b9c5a8d3a6e75f16206c9c6209a6cd036837130890a136dba887c37a8c0f802221226be55a64c2494954da2c9789a02aa96b06deb0fdf2db9baa10b7bd6cc83553c5c8965d3d6f92829494e5acc7fa42a8b73abbf48ccb772339ba1f17f99c69a97284b578d7ff2a760414536efbc38413cf25e2d70dfef5138519684abaf46518c2ef5b8cd17eb258665fc25d6998bf2f79d5993802ef2f773ffbd97a61beeefb584aff8603aafb550ffacfd8faeeaaba2e5dbf678495ba2a53f983cf38952ab45cfa97a0b2dd945a747bf26183ba756174393d88df94f971119aeef9e4e912b9d1478ceb177a37cd5601aab85d91abb422ccb812eeac62e055c10ab33ab616a12b7fe617aa577b986b314d6009e39c49765fdf9d94ed5a7e85fda0b80b8e41ade9fbebc27d14588f13be847307b1d219647ae6b31c596eb2d8ae258fc8de469fbd99a05fe36fca5f8ed9aef3bb8aec23d680043bee25de7bb9480d5854ada72ccc20054ae9af561aa79a10ae6ad910f7ff28069da41b2ba1518094da0487aa9aff7904228690fb44d2f05d0842a99541bf57452b28353a1607ac744a53d3fa922f2d1675f242889b8997915ce8847c9b5d7c2e09b769956135febada11a59bc234db398c2543fab9837e699095cf02b2c21207ef2e94f967e45e03f4bb8161afb94b44f57d1d1be0eebac278f5a1ba1ba79e1632dc6462d92a69731732ca28a291859bbf937d7b8f7503cfdcfefcb2cb35e702af785cda735244c3d43e9defbf01b061adab3a0888136afa64a7c56baec21c7a1916088aaa1845b8fdd0f6c69a72a3989f5b8aad549e57273d459a3c2087a63f639936ac54e2f678864bc0cb28a98fcf3c7f84576a1bb416a7ddf0fdf2d3f3c30b9f656d44a2a11c51d5969eb7c47859e7439f644ae5a4b1b325bc4665b596706114873d5d9f0dde1feeeb57ff22fc0c7959a90cb506d155a7ea9316ff75dd87cbd809a7f12442d588f2b7dcbf5354e9bece0c11ed6d538aeb2fe5d3ef282a242e818f1668c8a86da5fa8fa475791a569d10f96e017d694487bcb38d92d760ec445537c981dcc395a9ace070f78d3927556a85bbe253f47b14178c469ab843b8956293956d7478ccec8eaf58416654a6babb387ac8d1970027b2db2e51bfe9d0696a06997b05fcc0319e88fcf317f22241e2441fece3bdf81f03ab3c2fddeeaad25ad527e81cad7626c3d60b3bd56a5586f18a71e223d8d3b07485c7056562757456f6872d5667844e49a738c6bebb12d16cb428f8ac016561dbd106f86e69d785c7e13336d701beba5282a45b450226b39cecc0024661173473a34d721642b0608427f002d7f95d0190cc20ce9bd35c78a531ec038df7b441f4ff290242c83396ce7e67047175a152719f79a169bd203e410f0062c6e984d386c75809c42c684dd152c07b78a3e60868f92e0c3537826145a7709a56ccdf8a829bbcc7a142b17ccb88a66076400bb691c2abf989935ddbfe6acff893d00ea435f356f7ebf83552fe0583f6b8c4124d4398165af37b2153dec3727a337a8b704abe1bf1b059e9a8d6744f18c0592e4c5ceda2ee1c7064130c1162def06f79df739485d4d1c63e8be78addcb5645ac2ba8b9a74a0637ce2ee16d953e2bd7173692e8111c87c5c1ba99c8fa8db6ccdd0437910ab1d4db9914a01d9c9892400a22a2b54d5e4a127f59c82503beb6d00cab4be2a0b5dc971f303a2e44ae64840fd61d8da471a9de737e245ceaecfed289e5d2b10d8e1456105dad7425a83e872c5f47dd50f1996b947518d12f124e28f777198a5296ffe33cc92f82bd6b70d99aaa6face73cbfdc0bfb7b636cc64d1001550bd8210befd30efa5a3c47f7e05401aa4e8714a775e3e95c7865acfaec34810a71a8d9d1535ce3b3967f1839a741a14d0dd31045a8341ca07c1ede48111209a05083ea2b892091e44d934aed0aab460432a4e4b66b68b65d60f81da84d5617853fce1de40642e3f4b936251260ab9d668e80d2ae83e9ce78f3c1d72b7c6b426019a1075a24e4421730b24cf65b8612f81fc94930ae1d529cfcdee033f26797b627fb9b7cd9a4a7443c169840ef017da3b19d412e0806e88aa58e1f289560ee864ec491798a08a2ad4ef1a6f2bab92a27e2f5b5d7ec8acb58a2ae10af696774b1db9991a6f3d6bf1765acca6da1e0a8ef29bff610b0cc6edd3f17fd090a58d32af3eff394dcff8a948eddfc4b4cef07f5b095f83d0a1fb69cd94abdaf101564f98ebb764c4ca7a4440f9d6d1ad41abe37f1ea53df5fd18d551384c86189216dc5ed92746b9be2f8552c32fd3cf5b4e49bb4b7118682dbb66a773fbc8c33221dc2a1e4d5e82392a405150fabaf3feaa5334a8f05b1163ba6832d29cb4d87f2a7400eb2c71d5bca9023f8743e20e9ef511012df78e4b2bd342cf6914da9246b2554168bab8eefb6409c1a1ad089b6c2f7548eae9672aba3d0c320a184ac2473b529b1da3c0f568cc4f3e8c9e5d72d90a2741e8865899617fb18717e2fa67c7a658892aa7eebfb9df9de8dddbb901b98feeab7d51ea6fa85785631552a74227f3ea5658533285c936b35ded53a88958f87275fa67ff273b84603568a892abaf368f137d01fef10a657842c2d2b7569b0432d858213f56a67f6b29b9c3b29620e29fc73a298f2c501f45f428349f3ba91b47b8fcb3f2f7642717713241c70a936219a73fe0efb53d30dd4d7ed238cd383aa01109ec95d1463e8a506f4363804324a40aac67bb4597ce2ce48b143c6053edcd0d5f81aa16fdc1b81dadd94b7868e94050a9b10a4e5e9913128ca7cf2b4191c8326c1d4ce1f63f57d72fd1c2f611f63a3f0f24a01a73cf2dccfbc633b39673c8cec976e41088617ca01d5be0503e085d813bd49d14aa79dbc824b2d8644d8a74e18ec9c459d51852ba2ddf8e7d60ed1219e93e1ab8252f33b45cabb90e5c942b503b8da1662e7b00a173d6a751f3b936243e7109bfba19c0c9d0cc512670a783ad4906a617d450187e227fb2b80668b24c5b484f9dc9641e9dab1f9f660802dedf6e1a63853bbd264515e7873f8a03969738d07e33455637eb2db0b487b6423e1e8b049dc016abc5e5f91ce1a9a3d2cda62dc5c5301c56b75f77641a140cc7810fb89b9b3e11b6329baa9e904c87fcb0a9dac2820d9623bf429546345fa9fbdcd44d732290fbacaf133a97c177947ad4095867f59a9d4bed6c049ed8eabcccc485da81f301449ee8c705c68f256bfff5a74d226fc195c6a2f8c73832eec6fff311183585d8fd9c25db7c831fd53c5ff7eaba42e74f3d032f525ba3e7ca8b77f5e55cd3a1230c43fb26f28ce1bd2e55f35eb80444b5e7aa7cf857980d163cf5b81b3a0555e361951c366d7e105bcc332621fc86ab5c39fa634408dd9472bf3fefaa7fa856334878fc150b14f98f6f0feb9519c935e00d4b9d8d26ed1bf9a569f33d3c3b8358109e84f070a862f80ec4700c8f4a642e14c6262c8cd27bb612758c0fa98e7e9cccfbd7dbd8038d51cb897789cbf21e44003acdd2ce0470a63e6bd56c3eeea5d50049814781858ccfce06cac7495527a5202df0ccb0f37801e0c43ebc8baa718e68396cffdd30560258f54e6bae950df20247c83fd47c6b82ef32a206991d28b7416cdd27e4cdc331d57fa5441b6472e511c81471de0133fe4adf8e952e3d8f9e563a198e558180fddd97723a68e679c2f5e44ff8f570f09eaa7ea7648"
.L645:
    .quad 4607182418800017408
.L650:
    .quad 4621819117588971520
.L652:
    .string "eef453d6923bd65a113faa2906a13b3f9558b4661b6565f84ac7ca59a424c507baaee17fa23ebf765d79bcf00d2df649e95a99df8ace6f53f4d82c2c107973dc91d8a02bb6c1059479071b9b8a4be869b64ec836a47146f99748e2826cdee284e3e27a444d8d98b7fd1b1b2308169b258e6d8c6ab0787f72fe30f0f5e50e20f7b208ef855c969f4fbdbd2d335e51a935de8b2b66b3bc4723ad2c788035e613828b16fb203055ac764c3bcb5021afcc31addcb9e83c6b1793df4abe242a1bbf3dd953e8624b85dd78d71d6dad34a2af0d87d4713d6f33aa6b8672648c40e5ad68a9c98d8ccb009506680efdaf511f18c2d43bf0effdc0ba480212bd1b2566def284a57695fe98746d014bb630f7604b57a5ced43b7e3e9188419ea3bd35385e2dcf42894a5dce35ea52064cac828675b9818995ce7aa0e1b27343efebd1940993a1ebfb4219491a1f1014ebe6c5f90bf8ca66fa129f9b60a6d41a26e077774ef6fd00b897478238d08920b098955522b49e20735e8cb1638255b46e5f5d5535b0c5a890362fddbc62eb2189f734aa831df712b443bbd52b7ba5e9ec7501d523e49a6bb0aa55653b2d47b233c92125366ec1069cd4eabe89f8999ec0bb696e840af148440a256e2c76c00670ea43ca250d96cd2a865764dbca380406926a5e5728bc807527ed3e12bcc605083704f5ecf2eba09271e88d976bf7864a44c633682e93445b8731587ea37ab3ee6afbe0211db8157268fdae9e4c5960ea05bad82964e61acf033d1a45df6fb92487298e33bd8fd0c16206306baba5d3b6d479f8e056b3c4f1ba87bc86968f48a4899877186ce0b62e2929aba83c331acdabfe94de878c71dcd9ba0b49259ff0c08b7f1d0b14af8e5410288e1b6f07ecf0ae5ee44dd9db71e91432b1a24ac9e82cd9f69d6150892731ac9faf056ebe311c083a225cd2ab70fe17c79ac6ca6dbd630a48aaf406d64d3d9db981787d092cbbccdad5b10885f0468293f0eb4e25bbf56008c58ea5a76c582338ed2621af2af2b80af6f24ed1476e2c07286faa1af5af660db4aee182cca4db847945ca50d98d9fc890ed4da37fce126597973ce50ff107bab528a0cc5fc196fefd7d0c1e53ed49a96272c8ff77b1fcbebcdc4f25e8e89c13bb0f7a9faacf3df73609b177b191618c54e9acc795830d75038c1dd59df5b9ef6a2417f97ae3d0d2446f254b0573286b44ad1d9becce62836ac5774ee367f9430aec32c2e801fb244576d5229c41f793cda73ff3a20279ed56d48a6b43527578c1110f9845418c345644d6830a13896b78aaa9be5691ef416bd60c23cc986bc656d553edec366b11c6cb8f2cbfbe86b7ec8aa894b3a202eb1c3f397bf7d71432f3d6a9b9e08a83a5e34f07daf5ccd93fb0cc53e858ad248f5c22c9d1b3400f8f9cff6891376c36d99995be23100809b9c21fa1b58547448ffffb2dabd40a0c2832a78ae2e69915b3fff9f916c90c8f323f516c8dd01fad907ffc3bae3da7d97f6792e3b1442798f49ffb4a99cd11cfdf41779cdd95317f31c7fa1d40405643d711d5838a7d3eef7f1cfc52482835ea666b2572ad1c8eab5ee43b66da3243650005eecfd863b256369d4a4090bed43e40076a82873e4f75e2224e685a7744a6e804a291a90de3535aaae202711515d0a205cb36d3515c2831559a830d5a5b44ca873e038412d9991ed58091e858790afe9486c2a5178fff668ae0b6626e974dbe39a872ce5d73ff402d98e3fb0a3d212dc8128f80fa687f881c7f8e7ce66634bc9d0b99a139029f6a239f721c1fffc1ebc44e80c987434744ac874ea327ffb266b56220fbe9141915d7a9224bf1ff9f0062baa89d71ac8fada6c9b56f773fc3603db4a9c4ce17b399107c22cb550fb4384d21d3f6019da07f549b2b7e2a53a146606a4899c102844f94e0fb2eda7444cbfc426dc0314325637a1939fa911155fefb5308f03d93eebc589f88793555ab7eba27ca96267c7535b763b54bc1558b2f3458debbb01b9283253ca29eb1aaedfb016f16ea9c227723ee8bcb465e15a979c1cadc92a1958a7675175f0bfacd89ec191ec9b749faed14125d36cef980ec671f667be51c79a85916f48482b7e12780e7401a8f31cc0937ae58d2d1b2ecb8b0908810b2fe3f0b8599ef07861fa7e6dcb4aa15dfbdcece67006ac967a791e093e1d49a8bd6a141006042bde0c8bb2c5c6d24e0aecc49914078536d58fae9f773886e18da7f5bf590966848af39a475506a899e888f99797a5e012d6d8406c952429603aab37fd7d8f58178c8e5087ba6d33b83d5605fcdcf32e1d6fb1e4a9a90880a64855c3be0a17fcd265cf2eea09a55067fa6b34ad8c9dfc06ff42faa48c0ea481ed0601d8efc57b08bf13b94daf124da26823c12795db6ce5776c53d08d6b70858a2cb1717b52481ed54768c4b0c64ca6ecb7ddcdda26da268a9942f5dcf7dfd09fe5d54150b090b02d3f93b35435d7c4c9efa548d26e5a6e1c47bc5014a1a6dafc6b8e9b0709f109a359ab6419ca1091bf867241c8cc6d4c0c30163d203c94b629b407691d7fc44f879e0de63425dcf1dc21094364dfb5636985915fc12f542e4f294b943e17a2bc43e6f5b7b17b2939d979cf3ca6cec5b5aa705992ceecf9c42bd8430bd0827723150c6ff782a838353ece53cec4a314ebda4f8bf5635246428940f4613ae5ed136871b7795e136be99b913179899f6858428e2557b59846e3fe757dd7ec07426e5331aeada2fe589cf9096ea6f3848984f3ff0d2c85def7621b4bca50b065abe630fed077a756b53a9e1ebce4dc7f16dfbd3e8495912c628948d3360f09cf6e4bd64712dd7abbbd95cb080392cc4349decbd8d794d96aacfb3dca04777f541c567ecf0d7a0fc5583a089e42caaf9491b60f41686c49db57244ac5d37d5b79b6239311c2875c522ced5d77485cb25823ac77d633293366b828b86a8d39ef77164bcae5dff9c02033197a8530886b54dbdebd9f57f830283fdfcd267caa862a12d66d072df63c324fd7b8380dea93da4bc604247cb9e59f71e6da46116538d0deb7852d9be85f074e608cd795be87051665667902e276c921f8b806bd9714632dff600ba1cd8a3db53b6a086cfcd97bf97f380e8a40eccd228a4c8a883c0fdaf7df06122cd128006b2cdfad2a4b13d1b5d6c796b805720085f819cc3a6eec6311a63cbe3303674053bb0c3f490aa77bd60fcbedbfc4411068a9cf4f1b4d515acb93bee92fb5515482d44991711052d8bf3c5751bdd152d4d1c4abf5cd54678eef0b6d262d45a78a0635def340a98172aace486fb897116c87c349580869f0e7aac0ed45d35e6ae3d4da0bae0a846d21957128974836059cca109e998d258869facd72bd1a438703fc94b91ff83775423cc067b6306a34627ddcfb67f6455292cbf081a3bc84c17b1d542e41f3d6a7377eeca20caba5f1d9e4a938e938662882af53e547eb47b7282ee9cb23867fb2a35b28de99e619a4f23aa43dec681f9f4c31f316405fa00e2ec94d48b3c113c38f9f37ede83bc408dd3dd04ae0b158b4738705e9624ab50b148d445d98ddaee19068c763badd624dd9b095787f8a8d4cfa417c9e54ca5d70a80e5d6a9f6d30a038d1dbc5e9fcf4ccd211f4cd47487cc8470652b7647c3200069671f84c8d4dfd2c63f3b29ecd9f40041e073a5fb0a17c777cf09f468107100525890cf79cc9db955c2cc7182148d4066eeb481ac1fe293d599bfc6f14cd848405530a21727db38cb002fb8ada00e5a506a7cca9cf1d206fdc03ba6d90811f0e4851cfd442e4688bd304a908f4a166d1da6639e4a9cec15763e2e9a598e4e043287fec5dd44271ad3cdba40eff1e1853f29fdf7549530e188c128d12bee59e68ef47c9a94dd3e8cf578b982bb74f8301958cec13a148e3032d6e7e36a52363c1faf01f18899b1bc3f8ca1dc44e6c3cb279ac196f5600f15a7b7e529ab103a5ef8c0b9bcb2b812db11a5de7415d448f6b6f0e7ebdf661791d60f56111b495b3464ad21936b9fcebb25c995cab10dd900beec34b84687c269ef3bfb3d5d514f40eea742e65829b3046b0afa0cb4a5a3112a51128ff71a0fe2c2e6dc47f0e785eaba72abb3f4e093db73a09359ed216765690f56e0f218b8d25088b8306869c13ec3532c8c974f73837255731e414218c73a13fbafbd2350644eeacfe5d1929ef90898fadbac6c247d62a583df45f746b74abf39894bc396ce5da7726b8bba8c328eb783ab9eb47c81f5114f066ea92f3f326564d686619ba27255a2c80a537b0efefebd8613fd0145877585bd06742ce95f5f36a798fc4196e952e72c48113823b73704d17f3b51fca3a7a0f75a15862ca504c582ef85133de648c49a984d73dbe722fba3ab66580d5fdaf5c13e60d0d2e0ebbacc963fee10b7d1b3318df905079926a8ffbbcfe994e5c61ffdf17746497f70529fd561f1fd0f9bd3feb6ea8bedefa633c7caba6e7c5382c8fe64a52ee96b8fc0f9bd690a1b68637b3dfdce7aa3c673b09c1661a651213e2d06bea10ca65c084ec31bfa0fe5698db8486e494fcff30a62f3e2f893dec3f1265a89dba3c3efccfa986ddb5c6b3a76b7f89629465a75e01cbe89523386091465f6bbb397f1135823ee2ba6c0678b597f746aa07ded582e2c94db483840b717efa8c2a44eb4571cdcba121a4650e4ddeb92f34d62616ce413e896a0d7e51e156677b020baf9c81d17915e2486ef32cd600ace1474dc1d122eb5b5ada8aaff80b80d819992132456bae3231912d5bf60e610e1fff697ed6c698df5efabc5979c8fca8d3ffa1ef463c1b1736b96b6fd83b3bd308ff8a6b17cb2ddd0467c64bce4a0ac7cb3f6d05ddbde8aa22c0dbef60ee46bcdf07a423aa96bad4ab7112eb3929d86c16c98d2c953c6d89d64d57a607744e871c7bf077ba8b787625f056c7c4a8b11471cd764ad4972a93af6c6c79b5d2dd598e40d3dd89bcfd389b478798234794aff1d108d4ec2c3843610cb4bf160cbcedf722a585139baa54394fe1eedb8fec2974eb4ee658828ce947a3da6a9273e733d226229feea32811ccc668829b8870806357d5a3f525fa163ff802a3426a8ca07c2dcb0cf26f7c9bcff6034c13052fc89b393dd02f0b5fc2c3f3841f17c67bbac2078d443ace29d9ba7832936edc0d54b944b84aa4c0dc5029163f384a9310a9e795e65d4df11f64335bcf065d37d4d4617b5ff4a16d599ea0196163fa42e504bced1bf8e4e45c06481fb9bcf8d39e45ec2862f71e1d6f07da27a82c370885d767327bb4e5a4c964e858c91ba26553a6a07f8d510f86fbbe226efb628afea890489f70a55368beadab0aba3b2dbe52b45ac74ccea842e92c8ae6b464fc96f3b0b8bc90012929db77ada0617e3bbcb09ce6ebb40173744e55990879ddcaabdcc420a6a101d05158f57fa54c2a9eab69fa946824a12232db32df8e9f354656447939822dc96abf9dff9772470297ebd59787e2b93bc56f78bfbea76c619ef3657eb4edb3c55b65aaefae51477a06b03ede622920b6b23f1dab99e59958885c4e95fab368e45eced88b402f7fd75539b11dbcb0218ebb414aae103b5fcd2a881d652bdc29f26a119d59944a37c0752a24be76d3346f0495f857fcae62d8493a56f70a4400c562ddba6dfbd9fb8e5b88ecb4ccd500f6bb952d097ad07a71f26b27e2000a41346a7a7825ecc24c873782f8ed400668c0c28c8a2f67f2dfa90563b728900802f0f32facbb41ef979346bca4f2b40a03ad2ffb9fea126b7d78186bce2f610c84987bfa89f24b832e6b0f4360dd9ca7d2df4d7c9c6ede63fa05d314391503d1c79720dbbf8a95fcf88747d9475a44c6397ce912a9b69dbe1b548ce7cc986afbe3ee11abac24452da229b021bfbe85badce996168f2d56790ab41c2a2fae27299423fb9c397c560ba6b0919a5dccd879fc967d41abdb6b8e905cb600f5400e987bbc1c920ed246723473e3813290123e9aab23b689436c0760c86e30bf9a0b6720aaf6521b94470938fa89bcef808e40e8d5b3e69e7958cb87392c2c2b60b1d1230b20e0490bd77f3483bb9b9b1c6f22b5e6f48c2b4ecd5f01a4aa8281e38aeb6360b1af3e2280b6c20dd523225c6da63c38de1b08d590723948a535f579c487e5a38ad0eb0af48ec79ace8372d835a9df0c6d851dcdb1b2798182244f8e431456cf88e658a08f0f8bf0f156b1b8e9ecb641b58ffac8b2d36eed2dac5e272467e3d222f3fd7adf884aa8791775b0ed81dcc6abb0f86ccbb52ea94baea98e947129fc2b4e9a87fea27a539e9a53f2398d747b36224d29fe4b18e88640e8eec7f0d19a03aad83a3eeeef9153e891953cf68300424aca48ceaaab75a8e2b5fa8c3423c052dd7cdb02555653131b63792f412cb06794d808e17555f3ebf11e2bbd88bbee40bd0a0b19d2ab70e6ed65b6aceaeae9d0ec4c8de047564d20a8bf245825a5a445275fb158592be068d2eeed6e2f0f0d567129ced737bb6c4183d55464dd69685606bc428d05aa4751e4caa97e14c3c26b886f53304714d9265dfd53dd99f4b3066a8993fe2c6d07b7fabe546a8038efe4029bf8fdb78849a5f96de98520472bdd033ef73d256a5c0f77c963e66858f6d444095a8637627989aaddde7001379a44aa8bb127c53b17ec1595560c018580d5d52e9d71b689dde71afaab8f01e6e10b4a69226712162ab070dcab3961304ca70e8b6b00d69bb55c8d13d607b97c5fd0d22e45c10c42a2b3b058cb89a7db77c506a8eb98a7a9a5b04e377f3608e92adb242b267ed1940f1c61c55f038b237591ed3df01e85f912e37a36b6c46dec52f66888b61313bbabce2c62323ac4b3b3da015ae397d8aa96c1b77abec975e0a0d081ad9c7dced53c7225596e7bd358c904a21881cea14545c75757e50d64177da2e54aa242499697392d2dde50bd1d5d0b9e9d4ad2dbfc3d07787955e4ec64b44e86484ec3c97da624ab4bd5af13bef0b113ea6274bbdd0fadd61ecb1ad8aeacdd58ecfb11ead453994ba67de18eda5814af281ceb32c4b43fcf480eacf948770ced7a2425ff75e14fc31a1258379a94d028dcad2f7f5359a3b3e096ee45813a04330fd87b5f28300ca0d8bca9d6e188853fc9e74d1b791e07e48775ea264cf55347ec612062576589dda95364afe032a819ef79687aed3eec5513a83ddbd83f522059abe14cd44753b52c4926a9672793543c16d9a0095928a2775b7053c0f178294f1c90080baf72cb15324c68b12dd6339971da05074da7beed3f6fc16ebca5e04bce5086492111aea88f4bb1ca6bcf585ec1e4a7db69561a52b31e9e3d06c32e69392ee8e921d5d073aff322e62439fd0b877aa3236a4b44909befeb9fad487c3e69594bec44de15b4c2ebe687989a9b4901d7cf73ab0acd90f9d37014bf60a11b424dc35095cd80f538484c19ef38c95e12e13424bb40e132865a5f206b06fba8cbccc096f5088cbf93f87b7442e45d4afebff0bcb24aafef78f69a51539d749dbe6fecebdedd5beb573440e5a884d1c89705f4136b4a59731680a88f8953031abcc77118461cefcfdc20d2b36ba7c3ed6bf94d5e57a42bc3d32907604691b4d8637bd05af6c69b5a63f9a49c2c1b110a7c5ac471b4784230fcf80dc33721d54d1b71758e219652bd3c36113404ea4a983126e978d4fdf3b645a1cac083126eaa3d70a3d70a3d70a3d70a3d70a3d70a4cccccccccccccccccccccccccccccccd80000000000000000000000000000000a0000000000000000000000000000000c8000000000000000000000000000000fa0000000000000000000000000000009c400000000000000000000000000000c3500000000000000000000000000000f424000000000000000000000000000098968000000000000000000000000000bebc2000000000000000000000000000ee6b28000000000000000000000000009502f900000000000000000000000000ba43b740000000000000000000000000e8d4a5100000000000000000000000009184e72a000000000000000000000000b5e620f4800000000000000000000000e35fa931a000000000000000000000008e1bc9bf040000000000000000000000b1a2bc2ec50000000000000000000000de0b6b3a7640000000000000000000008ac7230489e800000000000000000000ad78ebc5ac6200000000000000000000d8d726b7177a80000000000000000000878678326eac90000000000000000000a968163f0a57b4000000000000000000d3c21bcecceda100000000000000000084595161401484a00000000000000000a56fa5b99019a5c80000000000000000cecb8f27f4200f3a0000000000000000813f3978f89409844000000000000000a18f07d736b90be55000000000000000c9f2c9cd04674edea400000000000000fc6f7c40458122964d000000000000009dc5ada82b70b59df020000000000000c5371912364ce3056c28000000000000f684df56c3e01bc6c7320000000000009a130b963a6c115c3c7f400000000000c097ce7bc90715b34b9f100000000000f0bdc21abb48db201e86d4000000000096769950b50d88f41314448000000000bc143fa4e250eb3117d955a000000000eb194f8e1ae525fd5dcfab080000000092efd1b8d0cf37be5aa1cae500000000b7abc627050305adf14a3d9e40000000e596b7b0c643c7196d9ccd05d00000008f7e32ce7bea5c6fe4820023a2000000b35dbf821ae4f38bdda2802c8a800000e0352f62a19e306ed50b2037ad2000008c213d9da502de454526f422cc340000af298d050e4395d69670b12b7f410000daf3f04651d47b4c3c0cdd765f11400088d8762bf324cd0fa5880a69fb6ac800ab0e93b6efee00538eea0d047a457a00d5d238a4abe9806872a4904598d6d88085a36366eb71f04147a6da2b7f864750a70c3c40a64e6c51999090b65f67d924d0cf4b50cfe20765fff4b4e3f741cf6d82818f1281ed449fbff8f10e7a8921a4a321f2d7226895c7aff72d52192b6a0dcbea6f8ceb02bb399bf4f8a69f764490fee50b7025c36a0802f236d04753d5b49f4f2726179a224501d762422c946590c722f0ef9d80aad6424d3ad2b7b97ef5f8ebad2b84e0d58bd2e0898765a7deb29b934c3b330c857763cc55f49f88eb2fc2781f49ffcfa6d53cbf6b71c76b25fbf316271c7fc3908a8bef464e3945ef7a97edd871cfda3a5697758bf0e3cbb5acbde94e8e43d0c8ec3d52eeed1cbea317ed63a231d4c4fb274ca7aaa863ee4bdd945e455f24fb1cf88fe8caa93e74ef6ab975d6b6ee39e436b3e2fd538e122b44e7d34c64a9c85d4460dbbca87196b61690e40fbeea1d3a4abc8955e946fe31cdb51d13aea4a488dd6babab6398bdbe41e264589a4dcdab14c696963c7eed2dd18d7eb76070a08aecfc1e1de5cf543ca2b0de65388cc8ada83b25a55f43294bcbdd15fe86affad91249ef0eb713f39ebe8a2dbf142dfcc7ab6e3569326c784337acb92ed9397bf99649c2c37f07965404d7e77a8f87daf7fbdc33745ec97be90686f0ac99b4e8dafd69a028bb3ded71a3a8acd7c0222311bcc40832ea0d68ce0cd2d80db02aabd62bf50a3fa490c3019083c7088e1aab65db792667c6da79e0faa4b8cab1a1563f52577001b891185938cde6fd5e09abcf26ed4c0226b55e6f8680b05e5ac60b6178544f8158315b05b4a0dc75f1778e39d6696361ae3db1c721c913936dd571c84c03bc3a19cd1e38e9fb5878494ace3a5f04ab48a04065c7239d174b2dcec0e47b62eb0d64283f9c76c45d1df942711d9a3ba5d0bd324f8394f5746577930d6500ca8f44ec7ee364799968bf6abbe85f207e998b13cf4e1ecbbfc2ef456ae276e89e3fedd8c321a67eefb3ab16c59b14a2c5cfe94ef3ea101e95d04aee3b80ece5bba1f1d158724a12bb445da9ca61281f2a8a6e45ae8edc97ea1575143cf97226f52d09d71a3293bd924d692ca61be758593c2626705f9c56b6e0c377cfa2e12e6f8b2fb00c77836ce498f455c38b997a0b6dfb9c0f9564478edf98b59a373fec4724bd4189bd5eacb2977ee300c50fe758edec91ec2cb657df3d5e9bc0f653e12f2967b66737e3ed8b865b215899f46cbd79e0d20082ee74ae67f1e9aec07187ecd8590680a3aa11da01ee641a708de9e80e6f4820cc9495884134fe908658b23109058d147fdcddaa51823e34a7eedebd4b46f0599fd415d4e5e2cdc1d1ea966c9e18ac7007c91a850fadc09923329e03e2cf6bc604ddb0a6539930bf6bff4584db8346b786151ccfe87f7cef46ff16e612641865679a6381f14fae158c5f6e4fcb7e8f3f60c07ea26da3999aef7749e3be5e330f38f09dcb090c8001ab551c5cadf5bfd3072cc5fdcb4fa002162a6373d9732fc7c8f7f69e9f11c4014dda7e2867e7fddcdd9afac646d63501a1511db281e1fd541501b8f7d88bc24209a5651f225a7ca91a42269ae757596946075f3375788de9b06958c1a12d2fc39789370052d6b1641c83aef209787bb47d6b84c0678c5dbd23a49a9745eb4d50ce6332f840b7ba963646e0bd176620a501fbffb650e5a93bc3d898ec5d3fa8ce427affa3e51f138ab4cebe93ba47c980e98cdfc66f336c36b10137b8a8d9bbe123f017b80b0047445d4184e6d3102ad96cec1da60dc059157491e59043ea1ac7e4139287c89837ad68db2fb454e4a179dd187729babe4598c311fbe16a1dc9d8545e94f4296dd6fef3d67a8ce2529e2734bb1d1899e4a65f58660cb01ae745b101e9e45ec05dcff72e7f8fdc21a1171d42645d76707543f4fa1f73899504ae72497eba6a06494a791c53a8abfa45da0edbde690487db9d17636892d6f8d7509292d60345a9d2845d3c42b6865b86925b9bc5c20b8a2392ba45a9b2a7f26836f282b7328e6cac7768d7141ed1ef0244af2364ff3207d795430cd9268335616aed761f1f7f44e6bd49e807b8a402b9c5a8d3a6e75f16206c9c6209a6cd036837130890a136dba887c37a8c0f802221226be55a64c2494954da2c9789a02aa96b06deb0fdf2db9baa10b7bd6cc83553c5c8965d3d6f92829494e5acc7fa42a8b73abbf48ccb772339ba1f17f99c69a97284b578d7ff2a760414536efbc38413cf25e2d70dfef5138519684abaf46518c2ef5b8cd17eb258665fc25d6998bf2f79d5993802ef2f773ffbd97a61beeefb584aff8603aafb550ffacfd8faeeaaba2e5dbf678495ba2a53f983cf38952ab45cfa97a0b2dd945a747bf26183ba756174393d88df94f971119aeef9e4e912b9d1478ceb177a37cd5601aab85d91abb422ccb812eeac62e055c10ab33ab616a12b7fe617aa577b986b314d6009e39c49765fdf9d94ed5a7e85fda0b80b8e41ade9fbebc27d14588f13be847307b1d219647ae6b31c596eb2d8ae258fc8de469fbd99a05fe36fca5f8ed9aef3bb8aec23d680043bee25de7bb9480d5854ada72ccc20054ae9af561aa79a10ae6ad910f7ff28069da41b2ba1518094da0487aa9aff7904228690fb44d2f05d0842a99541bf57452b28353a1607ac744a53d3fa922f2d1675f242889b8997915ce8847c9b5d7c2e09b769956135febada11a59bc234db398c2543fab9837e699095cf02b2c21207ef2e94f967e45e03f4bb8161afb94b44f57d1d1be0eebac278f5a1ba1ba79e1632dc6462d92a69731732ca28a291859bbf937d7b8f7503cfdcfefcb2cb35e702af785cda735244c3d43e9defbf01b061adab3a0888136afa64a7c56baec21c7a1916088aaa1845b8fdd0f6c69a72a3989f5b8aad549e57273d459a3c2087a63f639936ac54e2f678864bc0cb28a98fcf3c7f84576a1bb416a7ddf0fdf2d3f3c30b9f656d44a2a11c51d5969eb7c47859e7439f644ae5a4b1b325bc4665b596706114873d5d9f0dde1feeeb57ff22fc0c7959a90cb506d155a7ea9316ff75dd87cbd809a7f12442d588f2b7dcbf5354e9bece0c11ed6d538aeb2fe5d3ef282a242e818f1668c8a86da5fa8fa475791a569d10f96e017d694487bcb38d92d760ec445537c981dcc395a9ace070f78d3927556a85bbe253f47b14178c469ab843b8956293956d7478ccec8eaf58416654a6babb387ac8d1970027b2db2e51bfe9d0696a06997b05fcc0319e88fcf317f22241e2441fece3bdf81f03ab3c2fddeeaad25ad527e81cad7626c3d60b3bd56a5586f18a71e223d8d3b07485c7056562757456f6872d5667844e49a738c6bebb12d16cb428f8ac016561dbd106f86e69d785c7e13336d701beba5282a45b450226b39cecc0024661173473a34d721642b0608427f002d7f95d0190cc20ce9bd35c78a531ec038df7b441f4ff290242c83396ce7e67047175a152719f79a169bd203e410f0062c6e984d386c75809c42c684dd152c07b78a3e60868f92e0c3537826145a7709a56ccdf8a829bbcc7a142b17ccb88a66076400bb691c2abf989935ddbfe6acff893d00ea435f356f7ebf83552fe0583f6b8c4124d4398165af37b2153dec3727a337a8b704abe1bf1b059e9a8d6744f18c0592e4c5ceda2ee1c7064130c1162def06f79df739485d4d1c63e8be78addcb5645ac2ba8b9a74a0637ce2ee16d953e2bd7173692e8111c87c5c1ba99c8fa8db6ccdd0437910ab1d4db9914a01d9c9892400a22a2b54d5e4a127f59c82503beb6d00cab4be2a0b5dc971f303a2e44ae64840fd61d8da471a9de737e245ceaecfed289e5d2b10d8e1456105dad7425a83e872c5f47dd50f1996b947518d12f124e28f777198a5296ffe33cc92f82bd6b70d99aaa6face73cbfdc0bfb7b636cc64d1001550bd8210befd30efa5a3c47f7e05401aa4e8714a775e3e95c7865acfaec34810a71a8d9d1535ce3b3967f1839a741a14d0dd31045a8341ca07c1ede48111209a05083ea2b892091e44d934aed0aab460432a4e4b66b68b65d60f81da84d5617853fce1de40642e3f4b936251260ab9d668e80d2ae83e9ce78f3c1d72b7c6b426019a1075a24e4421730b24cf65b8612f81fc94930ae1d529cfcdee033f26797b627fb9b7cd9a4a7443c169840ef017da3b19d412e0806e88aa58e1f289560ee864ec491798a08a2ad4ef1a6f2bab92a27e2f5b5d7ec8acb58a2ae10af696774b1db9991a6f3d6bf1765acca6da1e0a8ef29bff610b0cc6edd3f17fd090a58d32af3eff394dcff8a948eddfc4b4cef07f5b095f83d0a1fb69cd94abdaf101564f98ebb764c4ca7a4440f9d6d1ad41abe37f1ea53df5fd18d551384c86189216dc5ed92746b9be2f8552c32fd3cf5b4e49bb4b7118682dbb66a773fbc8c33221dc2a1e4d5e82392a405150fabaf3feaa5334a8f05b1163ba6832d29cb4d87f2a7400eb2c71d5bca9023f8743e20e9ef511012df78e4b2bd342cf6914da9246b2554168bab8eefb6409c1a1ad089b6c2f7548eae9672aba3d0c320a184ac2473b529b1da3c0f568cc4f3e8c9e5d72d90a2741e8865899617fb18717e2fa67c7a658892aa7eebfb9df9de8dddbb901b98feeab7d51ea6fa85785631552a74227f3ea5658533285c936b35ded53a88958f87275fa67ff273b84603568a892abaf368f137d01fef10a657842c2d2b7569b0432d858213f56a67f6b29b9c3b29620e29fc73a298f2c501f45f428349f3ba91b47b8fcb3f2f7642717713241c70a936219a73fe0efb53d30dd4d7ed238cd383aa01109ec95d1463e8a506f4363804324a40aac67bb4597ce2ce48b143c6053edcd0d5f81aa16fdc1b81dadd94b7868e94050a9b10a4e5e9913128ca7cf2b4191c8326c1d4ce1f63f57d72fd1c2f611f63a3f0f24a01a73cf2dccfbc633b39673c8cec976e41088617ca01d5be0503e085d813bd49d14aa79dbc824b2d8644d8a74e18ec9c459d51852ba2ddf8e7d60ed1219e93e1ab8252f33b45cabb90e5c942b503b8da1662e7b00a173d6a751f3b936243e7109bfba19c0c9d0cc512670a783ad4906a617d450187e227fb2b80668b24c5b484f9dc9641e9dab1f9f660802dedf6e1a63853bbd264515e7873f8a03969738d07e33455637eb2db0b487b6423e1e8b049dc016abc5e5f91ce1a9a3d2cda62dc5c5301c56b75f77641a140cc7810fb89b9b3e11b6329baa9e904c87fcb0a9dac2820d9623bf429546345fa9fbdcd44d732290fbacaf133a97c177947ad4095867f59a9d4bed6c049ed8eabcccc485da81f301449ee8c705c68f256bfff5a74d226fc195c6a2f8c73832eec6fff311183585d8fd9c25db7c831fd53c5ff7eaba42e74f3d032f525ba3e7ca8b77f5e55cd3a1230c43fb26f28ce1bd2e55f35eb80444b5e7aa7cf857980d163cf5b81b3a0555e361951c366d7e105bcc332621fc86ab5c39fa634408dd9472bf3fefaa7fa856334878fc150b14f98f6f0feb9519c935e00d4b9d8d26ed1bf9a569f33d3c3b8358109e84f070a862f80ec4700c8f4a642e14c6262c8cd27bb612758c0fa98e7e9cccfbd7dbd8038d51cb897789cbf21e44003acdd2ce0470a63e6bd56c3eeea5d50049814781858ccfce06cac7495527a5202df0ccb0f37801e0c43ebc8baa718e68396cffdd30560258f54e6bae950df20247c83fd47c6b82ef32a206991d28b7416cdd27e4cdc331d57fa5441b6472e511c81471de0133fe4adf8e952e3d8f9e563a198e558180fddd97723a68e679c2f5e44ff8f570f09eaa7ea7648"
.L753:
    .string "-inf"
.L754:
    .string "inf"
.L755:
    .string "-nan"
.L756:
    .string "nan"
.L798:
    .string "(null)"
.L799:
    .string "\n"
.L808:
    .string "file-write"
.L814:
    .string "mkdir-p"
.L823:
    .string ""
.L824:
    .string "/"
.L839:
    .string "/"
.L857:
    .string ""
.L859:
    .string "list-zyl-files"
.L860:
    .string ".zyl"
.L862:
    .string "list-files"
.L863:
    .string "list-files"
.L869:
    .string "[?2004l[0m"
.L878:
    .string "term-write"
.L883:
    .string "union-find table"
.L896:
    .string "zyl: mem-read: null pointer\n"
.L898:
    .string "zyl: mem-write: null pointer\n"
.L900:
    .string "cstr-byte-set"
.L903:
    .string "ZYL_REGIONS"
.L906:
    .string "ZYL_REGION_POISON"
.L910:
    .string "codegen buffer limit exceeded"
.L917:
    .string "words"
.L919:
    .string "aes block"
.L923:
    .string "aes key"
.L924:
    .string "words"
.L925:
    .string "words"
.L926:
    .string "words"
.L930:
    .string "/dev/urandom"
.L934:
    .string "words"
.L935:
    .string "random-words"
.L937:
    .string "zyl: invalid callee address 0x"
.L938:
    .string ""
.L939:
    .string "\n"
.L992:
    .string "0123456789abcdef"
.L995:
    .string "zyl: ffi call to invalid address 0x"
.L996:
    .string ""
.L997:
    .string "\n"
.L1015:
    .string "zyl: ffi call with "
.L1016:
    .string " arguments (max 6)\n"
.L1018:
    .string "zyl_ffi_pin"
.L1019:
    .string "zyl_ffi_unpin"
.L1020:
    .string "zyl_actor_init"
.L1021:
    .string "zyl_actor_is_alive"
.L1022:
    .string "zyl_actor_spawn"
.L1023:
    .string "zyl_chan_new"
.L1024:
    .string "zyl_chan_recv"
.L1025:
    .string "zyl_chan_rx"
.L1026:
    .string "zyl_chan_send"
.L1027:
    .string "zyl_chan_tx"
.L1028:
    .string "zyl_actor_wait"
.L1029:
    .string "zyl_actor_wait_all"
.L1030:
    .string "zyl_aes_encrypt_block"
.L1031:
    .string "zyl_aesni_available"
.L1032:
    .string "zyl_align_check"
.L1033:
    .string "zyl_arena_alloc"
.L1034:
    .string "zyl_arena_alloc_zeroed"
.L1036:
    .string "zyl_arena_capacity"
.L1037:
    .string "zyl_arena_create"
.L1038:
    .string "zyl_arena_destroy"
.L1039:
    .string "zyl_arena_reset"
.L1040:
    .string "zyl_arena_used"
.L1041:
    .string "zyl_arg_str"
.L1042:
    .string "zyl_argc"
.L1043:
    .string "zyl_atomic_add"
.L1044:
    .string "zyl_atomic_cas"
.L1045:
    .string "zyl_atomic_fetch_add"
.L1046:
    .string "zyl_atomic_load"
.L1047:
    .string "zyl_atomic_max"
.L1048:
    .string "zyl_atomic_min"
.L1049:
    .string "zyl_atomic_store"
.L1050:
    .string "zyl_atomic_sub"
.L1051:
    .string "zyl_blake3_file_hex"
.L1053:
    .string "zyl_blake3_hex"
.L1054:
    .string "zyl_byte_slice"
.L1055:
    .string "zyl_byte_slice_sub"
.L1056:
    .string "zyl_bytebuf_append"
.L1057:
    .string "zyl_bytebuf_atomic_add"
.L1058:
    .string "zyl_bytebuf_atomic_cas"
.L1059:
    .string "zyl_bytebuf_atomic_fetch_add"
.L1060:
    .string "zyl_bytebuf_atomic_load"
.L1061:
    .string "zyl_bytebuf_atomic_max"
.L1062:
    .string "zyl_bytebuf_atomic_min"
.L1063:
    .string "zyl_bytebuf_atomic_store"
.L1064:
    .string "zyl_bytebuf_atomic_sub"
.L1065:
    .string "zyl_bytebuf_cap"
.L1066:
    .string "zyl_bytebuf_len"
.L1067:
    .string "zyl_bytebuf_blake3_hex"
.L1068:
    .string "zyl_bytebuf_new"
.L1069:
    .string "zyl_bytebuf_ptr"
.L1071:
    .string "zyl_call0"
.L1072:
    .string "zyl_call1"
.L1073:
    .string "zyl_call2"
.L1074:
    .string "zyl_call3"
.L1075:
    .string "zyl_call4"
.L1076:
    .string "zyl_call5"
.L1077:
    .string "zyl_call6"
.L1078:
    .string "zyl_call_argv"
.L1079:
    .string "zyl_call_on_big_stack"
.L1080:
    .string "zyl_cc_compile"
.L1081:
    .string "zyl_cc_compile_log"
.L1082:
    .string "zyl_chdir"
.L1083:
    .string "zyl_cpuid_features"
.L1084:
    .string "zyl_cstr_byte_at"
.L1085:
    .string "zyl_cstr_byte_set"
.L1086:
    .string "zyl_cstr_concat"
.L1088:
    .string "zyl_cstr_count_newlines"
.L1089:
    .string "zyl_cstr_decode"
.L1090:
    .string "zyl_cstr_cmp"
.L1091:
    .string "zyl_cstr_eq"
.L1092:
    .string "zyl_cstr_from_byte"
.L1093:
    .string "zyl_cstr_from_int"
.L1094:
    .string "zyl_cstr_key_matches"
.L1095:
    .string "zyl_div_magic"
.L1096:
    .string "zyl_div_shift"
.L1097:
    .string "zyl_array_copy"
.L1098:
    .string "zyl_view_ok"
.L1099:
    .string "zyl_view_byte"
.L1100:
    .string "zyl_view_cmp"
.L1101:
    .string "zyl_view_find"
.L1102:
    .string "zyl_view_copy"
.L1103:
    .string "zyl_cstr_last_newline"
.L1105:
    .string "zyl_cstr_len"
.L1106:
    .string "zyl_cstr_of_word"
.L1107:
    .string "zyl_float_bits"
.L1108:
    .string "zyl_float_of_bits"
.L1109:
    .string "zyl_word_load"
.L1110:
    .string "zyl_word_store"
.L1111:
    .string "zyl_ptr_add"
.L1112:
    .string "zyl_ptr_cstr"
.L1113:
    .string "zyl_ffi_addr"
.L1114:
    .string "zyl_cstr_sanitize"
.L1115:
    .string "zyl_cstr_sub"
.L1116:
    .string "zyl_cstr_substr"
.L1117:
    .string "zyl_cstr_to_int"
.L1118:
    .string "zyl_cstr_to_int_base"
.L1119:
    .string "zyl_diag_json"
.L1120:
    .string "zyl_diag_json_set"
.L1122:
    .string "zyl_dirname_cstr"
.L1123:
    .string "zyl_attr_clear"
.L1124:
    .string "zyl_attr_copy"
.L1125:
    .string "zyl_attr_get"
.L1126:
    .string "zyl_attr_set"
.L1127:
    .string "zyl_ensure_arenas"
.L1128:
    .string "zyl_exec_cmd"
.L1129:
    .string "zyl_f_add"
.L1130:
    .string "zyl_f_cmp"
.L1131:
    .string "zyl_f_div"
.L1132:
    .string "zyl_f_error"
.L1133:
    .string "zyl_f_mul"
.L1134:
    .string "zyl_f_of_int"
.L1135:
    .string "zyl_f_parse"
.L1136:
    .string "zyl_f_rem"
.L1137:
    .string "zyl_f_sub"
.L1139:
    .string "zyl_f_text"
.L1140:
    .string "zyl_f_to_int"
.L1141:
    .string "zyl_ffi_lookup"
.L1142:
    .string "zyl_ffi_timed"
.L1143:
    .string "zyl_ffi_timed_argv"
.L1144:
    .string "zyl_file_close_c"
.L1145:
    .string "zyl_exit"
.L1146:
    .string "zyl_read_line"
.L1147:
    .string "zyl_file_open_c"
.L1148:
    .string "zyl_file_read_c"
.L1149:
    .string "zyl_file_write_c"
.L1150:
    .string "zyl_fnmap_get"
.L1151:
    .string "zyl_fnmap_put"
.L1152:
    .string "zyl_fnmap_reset"
.L1153:
    .string "zyl_fresh_id"
.L1154:
    .string "zyl_getcwd"
.L1156:
    .string "zyl_getenv"
.L1157:
    .string "zyl_contract_warn"
.L1158:
    .string "zyl_err_is"
.L1159:
    .string "zyl_list_zyl_files"
.L1160:
    .string "zyl_list_files"
.L1161:
    .string "zyl_load_n"
.L1162:
    .string "zyl_load_n_signed"
.L1163:
    .string "zyl_store_n"
.L1164:
    .string "zyl_global_get"
.L1165:
    .string "zyl_global_put"
.L1166:
    .string "zyl_global_ready"
.L1167:
    .string "zyl_global_clear"
.L1168:
    .string "zyl_iglobal_get"
.L1169:
    .string "zyl_iglobal_put"
.L1170:
    .string "zyl_iglobal_ready"
.L1171:
    .string "zyl_iglobal_clear"
.L1173:
    .string "zyl_repl_global_get"
.L1174:
    .string "zyl_repl_global_set"
.L1175:
    .string "zyl_uf_id"
.L1176:
    .string "zyl_uf_reset"
.L1177:
    .string "zyl_uf_new"
.L1178:
    .string "zyl_uf_find"
.L1179:
    .string "zyl_uf_union"
.L1180:
    .string "zyl_uf_raise"
.L1181:
    .string "zyl_uf_level"
.L1182:
    .string "zyl_regions_enabled"
.L1183:
    .string "zyl_words_new"
.L1184:
    .string "zyl_words_alloc"
.L1185:
    .string "zyl_words_alloc_r"
.L1186:
    .string "zyl_words_len"
.L1187:
    .string "zyl_words_get"
.L1188:
    .string "zyl_words_set"
.L1189:
    .string "zyl_words_view"
.L1190:
    .string "zyl_words_view_r"
.L1191:
    .string "zyl_smap_has"
.L1193:
    .string "zyl_smap_get_or"
.L1194:
    .string "zyl_array_new"
.L1195:
    .string "zyl_vec_alloc"
.L1196:
    .string "zyl_vec_alloc_r"
.L1197:
    .string "zyl_array_cap"
.L1198:
    .string "zyl_array_filled"
.L1199:
    .string "zyl_array_get"
.L1200:
    .string "zyl_array_set"
.L1201:
    .string "zyl_attrh_new"
.L1202:
    .string "zyl_attrh_set"
.L1203:
    .string "zyl_attrh_get_or"
.L1204:
    .string "zyl_attrh_has"
.L1205:
    .string "zyl_attrh_copy"
.L1206:
    .string "zyl_attrh_clear"
.L1207:
    .string "zyl_ref_new"
.L1208:
    .string "zyl_ref_get"
.L1209:
    .string "zyl_ref_set"
.L1210:
    .string "zyl_getenv_str"
.L1212:
    .string "zyl_strbuf_new"
.L1213:
    .string "zyl_strbuf_new_r"
.L1214:
    .string "zyl_strbuf_str"
.L1215:
    .string "zyl_cstr_escapes_ok"
.L1216:
    .string "zyl_heap_alloc"
.L1217:
    .string "zyl_ralloc"
.L1218:
    .string "zyl_region_enter"
.L1219:
    .string "zyl_region_exit"
.L1220:
    .string "zyl_region_free"
.L1221:
    .string "zyl_region_scope_enter"
.L1222:
    .string "zyl_region_live_bytes"
.L1223:
    .string "zyl_heap_block_p"
.L1224:
    .string "zyl_heap_swap"
.L1225:
    .string "zyl_int_text"
.L1226:
    .string "zyl_itest_add"
.L1227:
    .string "zyl_itest_count"
.L1228:
    .string "zyl_itest_fn"
.L1230:
    .string "zyl_itest_name"
.L1231:
    .string "zyl_itest_outcome"
.L1232:
    .string "zyl_itest_fail"
.L1233:
    .string "zyl_itest_reset"
.L1234:
    .string "zyl_itest_start"
.L1235:
    .string "zyl_itest_summary"
.L1236:
    .string "zyl_json_quote"
.L1237:
    .string "zyl_load_byte"
.L1238:
    .string "zyl_load_byte_signed"
.L1239:
    .string "zyl_mangle_key"
.L1240:
    .string "zyl_mem_alloc"
.L1241:
    .string "zyl_mem_free"
.L1242:
    .string "zyl_mem_read"
.L1243:
    .string "zyl_mem_write"
.L1244:
    .string "zyl_mkdir_p"
.L1245:
    .string "zyl_mlock"
.L1246:
    .string "zyl_panic"
.L1248:
    .string "zyl_path_exists"
.L1249:
    .string "zyl_pin_alloc"
.L1250:
    .string "zyl_print_float"
.L1251:
    .string "zyl_print_int"
.L1252:
    .string "zyl_print_str"
.L1253:
    .string "zyl_random_fill"
.L1254:
    .string "zyl_random_words"
.L1255:
    .string "zyl_run_bin"
.L1256:
    .string "zyl_session_arena"
.L1257:
    .string "zyl_smap_clear"
.L1258:
    .string "zyl_smap_get"
.L1259:
    .string "zyl_smap_global"
.L1260:
    .string "zyl_smap_new"
.L1261:
    .string "zyl_smap_put"
.L1262:
    .string "zyl_source_path"
.L1263:
    .string "zyl_source_register"
.L1265:
    .string "zyl_span_col"
.L1266:
    .string "zyl_span_copy"
.L1267:
    .string "zyl_span_file"
.L1268:
    .string "zyl_span_line"
.L1269:
    .string "zyl_span_line_text"
.L1270:
    .string "zyl_span_off"
.L1271:
    .string "zyl_span_snippet"
.L1272:
    .string "zyl_span_snippet_col"
.L1273:
    .string "zyl_span_offset_at"
.L1274:
    .string "zyl_span_set"
.L1275:
    .string "zyl_store_byte"
.L1276:
    .string "zyl_store_byte_signed"
.L1277:
    .string "zyl_str_append"
.L1278:
    .string "zyl_str_append_capped"
.L1279:
    .string "zyl_sym_escape"
.L1280:
    .string "zyl_system_cmd"
.L1282:
    .string "zyl_term_flush"
.L1283:
    .string "zyl_term_height"
.L1284:
    .string "zyl_term_is_tty"
.L1285:
    .string "zyl_term_raw_off"
.L1286:
    .string "zyl_term_raw_on"
.L1287:
    .string "zyl_term_read_byte"
.L1288:
    .string "zyl_term_read_byte_timeout"
.L1289:
    .string "zyl_term_width"
.L1290:
    .string "zyl_term_write"
.L1291:
    .string "zyl_try_frame_msg"
.L1292:
    .string "zyl_try_last_msg"
.L1293:
    .string "zyl_try_pop"
.L1294:
    .string "zyl_try_push"
.L1295:
    .string "zyl_variant_cmp"
.L1296:
    .string "zyl_variant_eq"
.L1297:
    .string "zyl_variant_field"
.L1299:
    .string "zyl_warn_capture"
.L1300:
    .string "zyl_warn_emit"
.L1301:
    .string "zyl_warn_take"
.L1302:
    .string "zyl_word_of_cstr"
.L1303:
    .string "zyl_wvec_get"
.L1304:
    .string "zyl_wvec_global"
.L1305:
    .string "zyl_wvec_len"
.L1306:
    .string "zyl_wvec_new"
.L1307:
    .string "zyl_wvec_pop"
.L1308:
    .string "zyl_wvec_push"
.L1309:
    .string "zyl_wvec_set"
.L1310:
    .string "zyl_wvec_truncate"
.L1311:
    .string "zyl_zeroize"
.L1326:
    .string "PATH"
.L1335:
    .string "/bin:/usr/bin"
.L1340:
    .string "sh"
.L1341:
    .string "-c"
.L1342:
    .string "/bin/sh"
.L1347:
    .string "XXXXXX"
.L1350:
    .string "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
.L1352:
    .string "TMPDIR"
.L1353:
    .string "/tmp"
.L1354:
    .string "/zyl_link_XXXXXX"
.L1355:
    .string "#!/bin/sh\n"
.L1356:
    .string "(null)"
.L1357:
    .string "\n"
.L1358:
    .string "sh"
.L1359:
    .string "/bin/sh"
.L1362:
    .string "cc"
.L1363:
    .string "-no-pie"
.L1364:
    .string "rt.o"
.L1365:
    .string "-o"
.L1366:
    .string "-lpthread"
.L1368:
    .string ".bin"
.L1370:
    .string "cc"
.L1372:
    .string "cc"
.L1388:
    .string "ZYL_SCHED"
.L1389:
    .string "ZYL_SCHED_CHAOS"
.L1390:
    .string "deterministic"
.L1406:
    .string "PANIC: E_DEADLOCK: every live actor is blocked on a channel or a join\n"
.L1415:
    .string "E_CHANNEL_CAPACITY: a channel buffer holds 1 to 16777216 values"
.L1416:
    .string "E_OUT_OF_MEMORY: no memory for a channel"
.L1421:
    .string "E_CHANNEL_NOT_OWNER: this actor does not own the channel endpoint"
.L1424:
    .string "E_CHANNEL_CLOSED: the channel's sender finished and every value was received"
.L1427:
    .string "E_OUT_OF_MEMORY: no memory for a channel"
.L1448:
    .string "E_ACTOR_LIMIT: at most 1024 actors per program"
.L1449:
    .string "E_OUT_OF_MEMORY: no thread for an actor"
.L1452:
    .string "error"
.L1453:
    .string "error"
.L1460:
    .string "PANIC: "
.L1461:
    .string "\n"
.L1495:
    .string "E_OUT_OF_MEMORY: no memory for an FFI worker"
.L1498:
    .string "E_OUT_OF_MEMORY: no memory for an FFI worker"
.L1499:
    .string "E_OUT_OF_MEMORY: no memory for an FFI worker"
.L1501:
    .string "E_FFI_TIMEOUT: could not start the FFI worker thread"
.L1507:
    .string "?"
.L1508:
    .string "E_FFI_SYMBOL_NOT_FOUND: no such FFI symbol: "
.L1509:
    .string "E_ARITY_MISMATCH: ffi-call passes more than 16 arguments"
.L1511:
    .string "E_FFI_TIMEOUT: ffi call `"
.L1512:
    .string "` exceeded its timeout of "
.L1513:
    .string " ms"
.L1536:
    .string "out of memory allocating a try frame"
.L1545:
    .string "FAIL\n"
.L1546:
    .string "FAIL: "
.L1547:
    .string "\n"
.L1556:
    .string "\ntest result: "
.L1557:
    .string " passed, "
.L1558:
    .string " failed, "
.L1559:
    .string " total\n"
.L1560:
    .string "test: "
.L1561:
    .string " ... "
.L1562:
    .string "ok\n"
.L1564:
    .string "error"
.L1566:
    .string "assertion failed"
.L1568:
    .string "PANIC: "
.L1569:
    .string "\n"
.L1570:
    .string "error["
.L1573:
    .string "  in "
.L1574:
    .string "\n"
.L1581:
    .string "\n"
.L1582:
    .string "error["
.L1583:
    .string ""
.L1584:
    .string ""
.L1586:
    .string "{\"severity\":\"error\",\"code\":"
.L1587:
    .string ",\"message\":"
.L1588:
    .string ",\"file\":\"\",\"line\":0,\"column\":0,\"labels\":[],\"help\":\"\"}\n"
.L1593:
    .string "error["
.L1597:
    .string "error\n"
.L1598:
    .string "error: "
.L1599:
    .string "\n"
.L1608:
    .string ""
.L1609:
    .string "\n"
.L1613:
    .string ""
.L1615:
    .string ""
.L1616:
    .string "\"\""
.L1620:
    .string "\\u00"
.L1624:
    .string "(null)"
.L1627:
    .string "test: "
.L1628:
    .string " ... "
.L1630:
    .string "FAIL\n"
.L1631:
    .string "ok\n"
.L1633:
    .string "FAIL: "
.L1634:
    .string "\n"
.L1637:
    .string "\ntest result: "
.L1638:
    .string " passed, "
.L1639:
    .string " failed, "
.L1640:
    .string " total\n"
.L1643:
    .string ""
.L1644:
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
zyl_rtg_bt_off:
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
zyl_rtt_bt_vec:
    .zero 8
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
zyl_rt_sys_27:
    mov r10, rcx
    mov eax, 27
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
zyl_rt_frame_addr:
    mov rax, rbp
    ret
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
.weak zyl_syms
.weak exit
