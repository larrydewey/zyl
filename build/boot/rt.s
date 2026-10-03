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
zy_local_x2Fmain_0__base__rt_x2Dwadd:
    # frame 0
.L1_0:
    lea rax, [rdi+rsi]
    ret
zy_local_x2Fmain_0__base__rt_x2Dwsub:
    # frame 0
.L2_0:
    mov rax, rdi
    sub rax, rsi
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrlen:
    # frame 0
    push rbp
    mov rbp, rsp
.L3_0:
    mov rax, rdi
    and rax, 4095
    cmp rax, 4080
    jg .L3_1
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
    jne .L3_2
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
    jne .L3_3
    mov r9, rdi
    add r9, 16
    jo zyl_rt_trap_ovf_0
    mov rdi, r9
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dv
    mov r9, rax
    add r9, 16
    jo zyl_rt_trap_ovf_0
    mov rax, r9
    pop rbp
    ret
.L3_3:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    shr r8, 3
    mov rax, r8
    add rax, 8
    jo zyl_rt_trap_ovf_0
    pop rbp
    ret
.L3_2:
    mov rdx, rsi
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov rsi, rax
    shr rsi, 3
    mov rax, rsi
    pop rbp
    ret
.L3_1:
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dv
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dv:
    # frame 0
.L4_0:
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
    jne .L4_1
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2Dfrom
.L4_1:
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
.L5_0:
    mov rdx, r12
    movdqu xmm0, [rdx]
    pxor xmm1, xmm1
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov rsi, rax
    cmp rsi, 0
    jne .L5_1
    mov rax, r12
    and rax, 31
    cmp rax, 0
    jne .L5_2
    add r12, 16
    jo zyl_rt_trap_ovf_0
    jmp .L5_0
.L5_2:
    call zy_local_x2Fmain_0__base__rt_x2Davx2
    cmp rax, 0
    je .L5_3
    mov rdi, r12
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    mov rsi, rdi
    mov rdi, rbx
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D32
.L5_3:
    mov rdi, r12
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    mov rsi, rdi
    mov rdi, rbx
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D16
.L5_1:
    mov rdx, rsi
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov rsi, rax
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    sub rsi, rbx
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D16:
    # frame 0
.L6_0:
    mov rdx, rsi
    movdqu xmm0, [rdx]
    pxor xmm1, xmm1
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r8, rax
    cmp r8, 0
    jne .L6_1
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    jmp .L6_0
.L6_1:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrlen_x2D32:
    # frame 0
.L7_0:
    mov rdx, rsi
    vmovdqu ymm0, [rdx]
    vpxor xmm1, xmm1, xmm1
    vpcmpeqb ymm0, ymm0, ymm1
    vpmovmskb eax, ymm0
    vzeroupper
    mov r8, rax
    cmp r8, 0
    jne .L7_1
    add rsi, 32
    jo zyl_rt_trap_ovf_0
    jmp .L7_0
.L7_1:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    ret
zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq:
    # frame 0
    mov r8, rdx
.L8_0:
    cmp r8, 16
    jl .L8_1
.L8_4:
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    cmp rax, 65535
    jne .L8_2
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    sub r8, 16
    jo zyl_rt_trap_ovf_1
    cmp r8, 16
    jl .L8_1
    jmp .L8_4
.L8_2:
    mov rax, 0
    ret
.L8_1:
    cmp r8, 0
    jne .L8_3
    mov rax, 1
    ret
.L8_3:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dbytes_x2Deq
zy_local_x2Fmain_0__base__rt_x2Dbytes_x2Deq:
    # frame 0
    mov r8, rdx
.L9_0:
    cmp r8, 0
    jne .L9_1
.L9_3:
    mov rax, 1
    ret
.p2align 4
.L9_1:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    jne .L9_2
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    cmp r8, 0
    jne .L9_1
    jmp .L9_3
.L9_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrcmp:
    # frame 0
.L10_0:
    mov rax, rdi
    and rax, 4095
    cmp rax, 4080
    jg .L10_2
    mov rax, rsi
    and rax, 4095
    cmp rax, 4080
    jle .L10_1
.L10_2:
    mov r8, 16
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrcmp_x2Dbytes
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
    jne .L10_3
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    jmp .L10_0
.L10_3:
    mov rdx, r8
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r8, rax
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    movzx edi, byte ptr [rdi+0]
    movzx esi, byte ptr [rsi+0]
    cmp rdi, rsi
    jge .L10_4
    mov rax, -1
    ret
.L10_4:
    cmp rdi, rsi
    jle .L10_5
    mov rax, 1
    ret
.L10_5:
    mov rax, 0
    ret
zy_local_x2Fmain_0__base__rt_x2Dstrcmp_x2Dbytes:
    # frame 0
    mov r8, rdx
.L11_0:
    cmp r8, 0
    jne .L11_1
.L11_6:
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrcmp
.p2align 4
.L11_1:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    jne .L11_3
    cmp r9, 0
    jne .L11_2
.L11_3:
    movzx r9d, byte ptr [rdi+0]
    movzx r10d, byte ptr [rsi+0]
    cmp r9, r10
    jge .L11_4
    mov rax, -1
    ret
.L11_4:
    cmp r9, r10
    jle .L11_5
    mov rax, 1
    ret
.L11_5:
    mov rax, 0
    ret
.L11_2:
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    cmp r8, 0
    jne .L11_1
    jmp .L11_6
zy_local_x2Fmain_0__base__rt_x2Dbyte_x2Dorder:
    # frame 0
.L12_0:
    movzx edi, byte ptr [rdi+0]
    movzx esi, byte ptr [rsi+0]
    cmp rdi, rsi
    jge .L12_1
    mov rax, -1
    ret
.L12_1:
    cmp rdi, rsi
    jle .L12_2
    mov rax, 1
    ret
.L12_2:
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
.L13_0:
    lea rax, [rip+.L14]
    mov rdi, rax
    mov rsi, rbx
    and rsi, 15
    mov r8, 1
    mov rdx, r8
    call zyl_cstr_substr
    mov rdi, rax
    cmp rbx, 16
    jge .L13_1
    mov rsi, r12
    call zyl_cstr_concat
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L13_1:
    shr rbx, 4
    mov rsi, r12
    call zyl_cstr_concat
    mov r12, rax
    jmp .L13_0
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
.L15_0:
    lea rax, [rip+.L16]
    mov r12, rax
    lea rax, [rip+.L17]
    mov r13, rax
    lea rax, [rip+.L18]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dhex
    mov rdi, rax
    lea rax, [rip+.L19]
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
.L20_0:
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen
zy_local_x2Fmain_0__base__rt_x2Dcopy:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
    mov rdi, rdx
.L21_0:
    cmp rdi, 16
    jl .L21_1
.L21_4:
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L21_1:
    cmp rdi, 8
    jl .L21_2
    mov r8, qword ptr [rsi+0]
    mov qword ptr [rbx+0], r8
    mov r8, rdi
    sub r8, 8
    jo zyl_rt_trap_ovf_1
    add r8, rbx
    jo zyl_rt_trap_ovf_0
    mov r9, rdi
    sub r9, 8
    jo zyl_rt_trap_ovf_1
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    mov r9, qword ptr [r9+0]
    mov qword ptr [r8+0], r9
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L21_2:
    cmp rdi, 4
    jl .L21_3
    mov r8d, dword ptr [rsi+0]
    mov dword ptr [rbx+0], r8d
    mov r8, rdi
    sub r8, 4
    jo zyl_rt_trap_ovf_1
    add r8, rbx
    jo zyl_rt_trap_ovf_0
    mov r9, rdi
    sub r9, 4
    jo zyl_rt_trap_ovf_1
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    mov r9d, dword ptr [r9+0]
    mov dword ptr [r8+0], r9d
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L21_3:
    mov rdx, rdi
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2Dbytes
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16:
    # frame 0
    mov r8, rdx
.L22_0:
    cmp r8, 256
    jl .L22_1
.L22_2:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D64
.L22_1:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16s
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D64:
    # frame 0
    mov r8, rdx
.L23_0:
    cmp r8, 64
    jl .L23_1
.L23_4:
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    mov r9, rdi
    add r9, 16
    jo zyl_rt_trap_ovf_0
    mov r10, rsi
    add r10, 16
    jo zyl_rt_trap_ovf_0
    mov rdx, r9
    mov rcx, r10
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    mov r9, rdi
    add r9, 32
    jo zyl_rt_trap_ovf_0
    mov r10, rsi
    add r10, 32
    jo zyl_rt_trap_ovf_0
    mov rdx, r9
    mov rcx, r10
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    mov r9, rdi
    add r9, 48
    jo zyl_rt_trap_ovf_0
    mov r10, rsi
    add r10, 48
    jo zyl_rt_trap_ovf_0
    mov rdx, r9
    mov rcx, r10
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    add rdi, 64
    jo zyl_rt_trap_ovf_0
    add rsi, 64
    jo zyl_rt_trap_ovf_0
    sub r8, 64
    jo zyl_rt_trap_ovf_1
    cmp r8, 64
    jl .L23_1
    jmp .L23_4
.L23_1:
    cmp r8, 16
    jle .L23_2
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16s
.L23_2:
    cmp r8, 0
    jle .L23_3
    mov r9, r8
    sub r9, 16
    jo zyl_rt_trap_ovf_1
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    sub r8, 16
    jo zyl_rt_trap_ovf_1
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    mov rdx, r9
    mov rcx, rsi
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    ret
.L23_3:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__base__rt_x2Dcopy_x2D16s:
    # frame 0
    mov r8, rdx
.L24_0:
    cmp r8, 16
    jle .L24_1
.L24_2:
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    sub r8, 16
    jo zyl_rt_trap_ovf_1
    cmp r8, 16
    jle .L24_1
    jmp .L24_2
.L24_1:
    mov r9, r8
    sub r9, 16
    jo zyl_rt_trap_ovf_1
    add rdi, r9
    jo zyl_rt_trap_ovf_0
    sub r8, 16
    jo zyl_rt_trap_ovf_1
    add rsi, r8
    jo zyl_rt_trap_ovf_0
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
.L25_0:
    cmp rdi, 0
    jne .L25_1
.L25_2:
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L25_1:
    movzx r8d, byte ptr [rsi+0]
    mov byte ptr [rbx+0], r8b
    mov r8, rbx
    add r8, 1
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
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
.L26_0:
    cmp r8, 0
    jle .L26_2
.L26_5:
    cmp rdi, rsi
    jne .L26_1
.L26_2:
    mov rax, rdi
    ret
.L26_1:
    cmp rdi, rsi
    jl .L26_4
    mov rax, rsi
    add rax, r8
    jo zyl_rt_trap_ovf_0
    cmp rdi, rax
    jl .L26_3
.L26_4:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__base__rt_x2Dmove_x2Dfwd
.L26_3:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dmove_x2Dback
zy_local_x2Fmain_0__base__rt_x2Dmove_x2Dfwd:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L27_0:
    mov rax, r8
    sub rax, r9
    jo zyl_rt_trap_ovf_1
    cmp rax, 16
    jl .L27_1
    mov r10, rdi
    add r10, r9
    jo zyl_rt_trap_ovf_0
    mov r11, rsi
    add r11, r9
    jo zyl_rt_trap_ovf_0
    mov rdx, r10
    mov rcx, r11
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    add r9, 16
    jo zyl_rt_trap_ovf_0
    jmp .L27_0
.L27_1:
    mov rax, r8
    sub rax, r9
    jo zyl_rt_trap_ovf_1
    cmp rax, 8
    jl .L27_2
    mov r10, rdi
    add r10, r9
    jo zyl_rt_trap_ovf_0
    mov r11, rsi
    add r11, r9
    jo zyl_rt_trap_ovf_0
    mov r11, qword ptr [r11+0]
    mov qword ptr [r10+0], r11
    add r9, 8
    jo zyl_rt_trap_ovf_0
    jmp .L27_0
.L27_2:
    cmp r9, r8
    jl .L27_3
    mov rax, rdi
    ret
.L27_3:
    mov r10, rdi
    add r10, r9
    jo zyl_rt_trap_ovf_0
    mov r11, rsi
    add r11, r9
    jo zyl_rt_trap_ovf_0
    movzx r11d, byte ptr [r11+0]
    mov byte ptr [r10+0], r11b
    add r9, 1
    jo zyl_rt_trap_ovf_0
    jmp .L27_0
zy_local_x2Fmain_0__base__rt_x2Dmove_x2Dback:
    # frame 0
    mov r8, rdx
.L28_0:
    cmp r8, 16
    jl .L28_1
.L28_4:
    mov r9, r8
    sub r9, 16
    jo zyl_rt_trap_ovf_1
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    mov r10, r8
    sub r10, 16
    jo zyl_rt_trap_ovf_1
    add r10, rsi
    jo zyl_rt_trap_ovf_0
    mov rdx, r9
    mov rcx, r10
    movdqu xmm0, [rcx]
    movdqu [rdx], xmm0
    mov rax, rdx
    sub r8, 16
    jo zyl_rt_trap_ovf_1
    cmp r8, 16
    jl .L28_1
    jmp .L28_4
.p2align 4
.L28_1:
    cmp r8, 8
    jl .L28_2
    mov r9, r8
    sub r9, 8
    jo zyl_rt_trap_ovf_1
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    mov r10, r8
    sub r10, 8
    jo zyl_rt_trap_ovf_1
    add r10, rsi
    jo zyl_rt_trap_ovf_0
    mov r10, qword ptr [r10+0]
    mov qword ptr [r9+0], r10
    sub r8, 8
    jo zyl_rt_trap_ovf_1
    cmp r8, 16
    jl .L28_1
    jmp .L28_4
.L28_2:
    cmp r8, 0
    jne .L28_3
    mov rax, rdi
    ret
.L28_3:
    mov r9, r8
    sub r9, 1
    jo zyl_rt_trap_ovf_1
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    mov r10, r8
    sub r10, 1
    jo zyl_rt_trap_ovf_1
    add r10, rsi
    jo zyl_rt_trap_ovf_0
    movzx r10d, byte ptr [r10+0]
    mov byte ptr [r9+0], r10b
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    cmp r8, 16
    jl .L28_1
    jmp .L28_4
zy_local_x2Fmain_0__base__rt_x2Dmem_x2Dcmp:
    # frame 0
    mov r8, rdx
.L29_0:
    cmp r8, 16
    jl .L29_1
.L29_9:
    mov rdx, rdi
    mov rcx, rsi
    movdqu xmm0, [rdx]
    movdqu xmm1, [rcx]
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    mov r9, rax
    xor r9, 65535
    cmp r9, 0
    jne .L29_2
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    sub r8, 16
    jo zyl_rt_trap_ovf_1
    cmp r8, 16
    jl .L29_1
    jmp .L29_9
.L29_2:
    mov rdx, r9
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r10, rax
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    mov rdx, r9
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r9, rax
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    movzx r10d, byte ptr [r10+0]
    movzx r9d, byte ptr [r9+0]
    cmp r10, r9
    jge .L29_3
    mov rax, -1
    ret
.L29_3:
    cmp r10, r9
    jle .L29_4
    mov rax, 1
    ret
.L29_4:
    mov rax, 0
    ret
.p2align 4
.L29_1:
    cmp r8, 0
    jne .L29_5
    mov rax, 0
    ret
.L29_5:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    jne .L29_6
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    cmp r8, 16
    jl .L29_1
    jmp .L29_9
.L29_6:
    movzx edi, byte ptr [rdi+0]
    movzx esi, byte ptr [rsi+0]
    cmp rdi, rsi
    jge .L29_7
    mov rax, -1
    ret
.L29_7:
    cmp rdi, rsi
    jle .L29_8
    mov rax, 1
    ret
.L29_8:
    mov rax, 0
    ret
zy_local_x2Fmain_0__base__rt_x2Dfind_x2Dbyte:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L30_0:
    mov rax, rsi
    sub rax, r9
    jo zyl_rt_trap_ovf_1
    cmp rax, 16
    jl .L30_1
    mov r10, rdi
    add r10, r9
    jo zyl_rt_trap_ovf_0
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
    jne .L30_2
    add r9, 16
    jo zyl_rt_trap_ovf_0
    jmp .L30_0
.L30_2:
    mov rdx, r10
    bsf rax, rdx
    mov ecx, 64
    cmovz rax, rcx
    mov r10, rax
    mov rax, r9
    add rax, r10
    jo zyl_rt_trap_ovf_0
    ret
.L30_1:
    cmp r9, rsi
    jl .L30_3
    mov rax, -1
    ret
.L30_3:
    mov r10, rdi
    add r10, r9
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r10+0]
    cmp rax, r8
    jne .L30_4
    mov rax, r9
    ret
.L30_4:
    add r9, 1
    jo zyl_rt_trap_ovf_0
    jmp .L30_0
zy_local_x2Fmain_0__base__rt_x2Dalloc:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L31_0:
    call zyl_ralloc
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Dcur_x2Dregion:
    # frame 0
.L32_0:
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
.L33_0:
    mov rdi, r12
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    call zyl_ralloc
    mov r13, rax
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r13
    add rsi, r12
    jo zyl_rt_trap_ovf_0
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
.L34_0:
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Davx2:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L35_0:
    lea rax, [rip+zyl_rtg_cpu_avx2]
    mov rbx, rax
    mov rsi, qword ptr [rbx+0]
    cmp rsi, 0
    jne .L35_1
    call zy_local_x2Fmain_0__base__rt_x2Davx2_x2Dprobe
    cmp rax, 0
    je .L35_2
    mov rdi, 2
    jmp .L35_3
.L35_2:
    mov rdi, 1
.L35_3:
    mov qword ptr [rbx+0], rdi
    mov rax, rdi
    cmp rax, 2
    sete al
    movzx rax, al
    pop rbx
    pop rbp
    ret
.L35_1:
    mov rax, rsi
    cmp rax, 2
    sete al
    movzx rax, al
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__base__rt_x2Davx2_x2Dprobe:
    # frame 0
.L36_0:
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
    jge .L36_1
    mov rax, 0
    ret
.L36_1:
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
    jne .L36_2
    xor ecx, ecx
    xgetbv
    mov eax, eax
    mov rsi, rax
    and rsi, 6
    cmp rsi, 6
    jne .L36_3
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
.L36_3:
    mov rax, 0
    ret
.L36_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__numeric__rt_x2Dwmul:
    # frame 0
.L37_0:
    mov rax, rdi
    imul rax, rsi
    ret
.globl zyl_wrap_add
zyl_wrap_add:
    # frame 0
.L38_0:
    lea rax, [rdi+rsi]
    ret
.globl zyl_wrap_sub
zyl_wrap_sub:
    # frame 0
.L39_0:
    mov rax, rdi
    sub rax, rsi
    ret
.globl zyl_wrap_mul
zyl_wrap_mul:
    # frame 0
.L40_0:
    mov rax, rdi
    imul rax, rsi
    ret
zy_local_x2Fmain_0__numeric__rt_x2Dint_x2Dmax:
    # frame 0
.L41_0:
    mov rax, 9223372036854775807
    ret
zy_local_x2Fmain_0__numeric__rt_x2Dint_x2Dmin:
    # frame 0
.L42_0:
    mov rax, -9223372036854775808
    ret
.globl zyl_add_overflows
zyl_add_overflows:
    # frame 0
.L43_0:
    cmp rsi, 0
    jle .L43_1
.L43_3:
    mov r8, 9223372036854775807
    sub r8, rsi
    jo zyl_rt_trap_ovf_1
    mov rax, rdi
    mov rcx, r8
    cmp rax, rcx
    setg al
    movzx rax, al
    ret
.L43_1:
    cmp rsi, 0
    jge .L43_2
    mov r8, -9223372036854775808
    sub r8, rsi
    jo zyl_rt_trap_ovf_1
    mov rax, rdi
    mov rcx, r8
    cmp rax, rcx
    setl al
    movzx rax, al
    ret
.L43_2:
    mov rax, 0
    ret
.globl zyl_sub_overflows
zyl_sub_overflows:
    # frame 0
.L44_0:
    cmp rsi, 0
    jge .L44_1
.L44_3:
    mov r8, 9223372036854775807
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, rdi
    mov rcx, r8
    cmp rax, rcx
    setg al
    movzx rax, al
    ret
.L44_1:
    cmp rsi, 0
    jle .L44_2
    mov r8, -9223372036854775808
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, rdi
    mov rcx, r8
    cmp rax, rcx
    setl al
    movzx rax, al
    ret
.L44_2:
    mov rax, 0
    ret
.globl zyl_mul_overflows
zyl_mul_overflows:
    # frame 0
.L45_0:
    cmp rdi, 0
    je .L45_2
.L45_13:
    cmp rsi, 0
    jne .L45_1
.L45_2:
    mov rax, 0
    ret
.L45_1:
    mov rax, -9223372036854775808
    cmp rdi, rax
    je .L45_4
    mov rax, -9223372036854775808
    cmp rsi, rax
    jne .L45_3
.L45_4:
    cmp rdi, 1
    je .L45_6
    cmp rsi, 1
    jne .L45_5
.L45_6:
    mov rax, 0
    ret
.L45_5:
    mov rax, 1
    ret
.L45_3:
    cmp rdi, 0
    jge .L45_7
    mov r8, 0
    sub r8, rdi
    jo zyl_rt_trap_ovf_1
    jmp .L45_8
.L45_7:
    mov r8, rdi
.L45_8:
    cmp rsi, 0
    jge .L45_9
    mov r9, 0
    sub r9, rsi
    jo zyl_rt_trap_ovf_1
    jmp .L45_10
.L45_9:
    mov r9, rsi
.L45_10:
    mov r10, 9223372036854775807
    mov rax, r10
    mov rcx, r9
    test rcx, rcx
    jz zyl_rt_trap_div0_3
    cmp rcx, -1
    jne .L46
    neg rax
    jo zyl_rt_trap_ovf_3
    jmp .L47
.L46:
    cqo
    idiv rcx
.L47:
    mov r10, rax
    cmp r8, r10
    jg .L45_11
    mov rax, 0
    ret
.L45_11:
    mov rax, rdi
    cmp rax, 0
    setl al
    movzx rax, al
    mov rdi, rax
    mov rax, rsi
    cmp rax, 0
    setl al
    movzx rax, al
    cmp rdi, rax
    je .L45_12
    mov rax, r10
    add rax, 1
    jo zyl_rt_trap_ovf_0
    cmp r8, rax
    jne .L45_12
    mov rsi, 9223372036854775807
    mov rax, rsi
    mov rcx, r9
    test rcx, rcx
    jz zyl_rt_trap_div0_4
    cmp rcx, -1
    jne .L48
    xor eax, eax
    jmp .L49
.L48:
    cqo
    idiv rcx
    mov rax, rdx
.L49:
    mov rsi, rax
    mov rax, r9
    sub rax, 1
    jo zyl_rt_trap_ovf_1
    cmp rsi, rax
    jne .L45_12
    mov rax, 0
    ret
.L45_12:
    mov rax, 1
    ret
.globl zyl_sat_add
zyl_sat_add:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L50_0:
    mov rdi, rbx
    mov rsi, r12
    call zyl_add_overflows
    cmp rax, 0
    je .L50_1
    cmp rbx, 0
    jge .L50_2
    mov rax, -9223372036854775808
    pop r12
    pop rbx
    pop rbp
    ret
.L50_2:
    mov rax, 9223372036854775807
    pop r12
    pop rbx
    pop rbp
    ret
.L50_1:
    mov rax, rbx
    add rax, r12
    jo zyl_rt_trap_ovf_0
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_sat_sub
zyl_sat_sub:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L51_0:
    mov rdi, rbx
    mov rsi, r12
    call zyl_sub_overflows
    cmp rax, 0
    je .L51_1
    cmp rbx, 0
    jge .L51_2
    mov rax, -9223372036854775808
    pop r12
    pop rbx
    pop rbp
    ret
.L51_2:
    mov rax, 9223372036854775807
    pop r12
    pop rbx
    pop rbp
    ret
.L51_1:
    mov rax, rbx
    sub rax, r12
    jo zyl_rt_trap_ovf_1
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_sat_mul
zyl_sat_mul:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L52_0:
    mov rdi, rbx
    mov rsi, r12
    call zyl_mul_overflows
    cmp rax, 0
    je .L52_1
    mov rax, rbx
    cmp rax, 0
    setl al
    movzx rax, al
    mov rsi, rax
    mov rax, r12
    cmp rax, 0
    setl al
    movzx rax, al
    cmp rsi, rax
    jne .L52_2
    mov rax, 9223372036854775807
    pop r12
    pop rbx
    pop rbp
    ret
.L52_2:
    mov rax, -9223372036854775808
    pop r12
    pop rbx
    pop rbp
    ret
.L52_1:
    mov rax, rbx
    imul rax, r12
    jo zyl_rt_trap_ovf_2
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__numeric__rt_x2Dop_x2Dname:
    # frame 0
.L53_0:
    cmp rdi, 0
    jne .L53_1
.L53_5:
    lea rax, [rip+.L54]
    mov rsi, rax
    mov rax, rsi
    ret
.L53_1:
    cmp rdi, 1
    jne .L53_2
    lea rax, [rip+.L55]
    mov rsi, rax
    mov rax, rsi
    ret
.L53_2:
    cmp rdi, 2
    jne .L53_3
    lea rax, [rip+.L56]
    mov rsi, rax
    mov rax, rsi
    ret
.L53_3:
    cmp rdi, 3
    jne .L53_4
    lea rax, [rip+.L57]
    mov rsi, rax
    mov rax, rsi
    ret
.L53_4:
    lea rax, [rip+.L58]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_overflow_text
zyl_overflow_text:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L59_0:
    cmp rdi, 2
    jle .L59_1
.L59_2:
    lea rax, [rip+.L60]
    mov rbx, rax
    call zy_local_x2Fmain_0__numeric__rt_x2Dop_x2Dname
    mov rsi, rax
    lea rax, [rip+.L61]
    mov r8, rax
    mov rdi, rsi
    mov rsi, r8
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_cstr_concat
.L59_1:
    lea rax, [rip+.L62]
    mov rbx, rax
    call zy_local_x2Fmain_0__numeric__rt_x2Dop_x2Dname
    mov rdi, rax
    lea rax, [rip+.L63]
    mov rsi, rax
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_cstr_concat
.globl zyl_div_zero_text
zyl_div_zero_text:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    and rsp, -16
    mov rbx, rdi
.L64_0:
    lea rax, [rip+.L65]
    mov r12, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__numeric__rt_x2Dop_x2Dname
    mov r13, rax
    lea rax, [rip+.L66]
    mov r14, rax
    cmp rbx, 3
    jne .L64_1
    lea rax, [rip+.L67]
    mov rdi, rax
    jmp .L64_2
.L64_1:
    lea rax, [rip+.L68]
    mov rdi, rax
.L64_2:
    lea rax, [rip+.L69]
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
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zyl_cstr_concat
.globl zyl_overflow_panic
zyl_overflow_panic:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L70_0:
    lea rax, [rip+.L71]
    mov rbx, rax
    call zyl_overflow_text
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.globl zyl_div_zero_panic
zyl_div_zero_panic:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L72_0:
    lea rax, [rip+.L73]
    mov rbx, rax
    call zyl_div_zero_text
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.globl zyl_cpuid_features
zyl_cpuid_features:
    # frame 0
.L74_0:
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
    jle .L74_1
    mov rdi, 1
    jmp .L74_2
.L74_1:
    mov rdi, 0
.L74_2:
    mov rax, rsi
    and rax, 2
    cmp rax, 0
    jle .L74_3
    mov r8, 2
    jmp .L74_4
.L74_3:
    mov r8, 0
.L74_4:
    mov rax, rsi
    and rax, 524288
    cmp rax, 0
    jle .L74_5
    mov r9, 4
    jmp .L74_6
.L74_5:
    mov r9, 0
.L74_6:
    mov rax, rsi
    and rax, 268435456
    cmp rax, 0
    jle .L74_7
    mov rsi, 8
    jmp .L74_8
.L74_7:
    mov rsi, 0
.L74_8:
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
.L75_0:
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
.L76_0:
    mov rsi, rdi
    cmp rsi, 4096
    jge .L76_1
    cmp rsi, 0
    jne .L76_2
    mov rax, 0
    pop rbp
    ret
.L76_2:
    lea rax, [rip+.L77]
    mov r8, rax
    mov rdi, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
.L76_1:
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrlen
zy_local_x2Fmain_0__cstr__rt_x2Dbad_x2Dlen:
    # frame 0
    push rbp
    mov rbp, rsp
.L78_0:
    lea rax, [rip+.L79]
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
.L80_0:
    cmp rdi, rsi
    jne .L80_1
    mov rax, 1
    pop rbp
    ret
.L80_1:
    cmp rdi, 4096
    jge .L80_2
    cmp rdi, 0
    jne .L80_3
    mov rax, 0
    pop rbp
    ret
.L80_3:
    lea rax, [rip+.L81]
    mov r8, rax
    mov rsi, r8
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L80_2:
    cmp rsi, 4096
    jge .L80_4
    cmp rsi, 0
    jne .L80_5
    mov rax, 0
    pop rbp
    ret
.L80_5:
    lea rax, [rip+.L82]
    mov r8, rax
    mov rdi, rsi
    mov rsi, r8
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L80_4:
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
.L83_0:
    cmp rdi, rsi
    jne .L83_1
    mov rax, 0
    ret
.L83_1:
    cmp rdi, 0
    jne .L83_2
    mov rax, -1
    ret
.L83_2:
    cmp rsi, 0
    jne .L83_3
    mov rax, 1
    ret
.L83_3:
    jmp zy_local_x2Fmain_0__base__rt_x2Dstrcmp
.globl zyl_cstr_byte_at
zyl_cstr_byte_at:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L84_0:
    mov r12, rdi
    cmp rbx, 0
    jge .L84_1
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L84_1:
    cmp r12, 4096
    jge .L84_2
    cmp r12, 0
    jne .L84_3
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L84_3:
    lea rax, [rip+.L85]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L84_2:
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    cmp rbx, rax
    jl .L84_4
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L84_4:
    mov rsi, r12
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rsi+0]
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__cstr__rt_x2Dbad_x2Dat:
    # frame 0
    push rbp
    mov rbp, rsp
.L86_0:
    lea rax, [rip+.L87]
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
.L88_0:
    mov r12, rdi
    mov r13, rbx
    cmp r12, r13
    jne .L88_1
    mov rax, 1
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L88_1:
    cmp r12, 0
    je .L88_3
    cmp r13, 0
    jne .L88_2
.L88_3:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L88_2:
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    cmp r14, rsi
    jne .L88_4
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
.L88_4:
    mov rax, rsi
    add rax, 2
    jo zyl_rt_trap_ovf_0
    cmp r14, rax
    jge .L88_5
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L88_5:
    mov rdi, r14
    sub rdi, rsi
    jo zyl_rt_trap_ovf_1
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov r8, rdi
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    movzx eax, byte ptr [r8+0]
    cmp rax, 58
    jne .L88_6
    mov r8, rdi
    sub r8, 2
    jo zyl_rt_trap_ovf_1
    movzx eax, byte ptr [r8+0]
    cmp rax, 58
    jne .L88_7
    mov rdx, rsi
    mov rsi, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
.L88_7:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L88_6:
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
.L89_0:
    mov r12, rdi
    mov r13, rsi
    cmp r12, 0
    jle .L89_1
    cmp r12, 4096
    jge .L89_1
    lea rax, [rip+.L90]
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
.L89_1:
    cmp r13, 0
    jle .L89_2
    cmp r13, 4096
    jge .L89_2
    lea rax, [rip+.L91]
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
.L89_2:
    mov rsi, 0
    cmp r12, 0
    je .L89_3
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L89_3:
    mov r14, rsi
    mov rsi, 0
    cmp r13, 0
    je .L89_4
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L89_4:
    mov r15, rsi
    mov rdi, r14
    add rdi, r15
    jo zyl_rt_trap_ovf_0
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    call zyl_ralloc
    mov rbx, rax
    mov rax, r14
    add rax, r15
    jo zyl_rt_trap_ovf_0
    cmp rax, 16
    jge .L89_5
    cmp r14, 0
    je .L89_6
    mov rsi, r12
    and rsi, 4095
    mov rdi, 4080
    cmp r14, 8
    jg .L89_7
    mov rdi, 4088
.L89_7:
    cmp rsi, rdi
    jg .L89_5
.L89_6:
    cmp r15, 0
    je .L89_8
    mov rsi, r13
    and rsi, 4095
    mov rdi, 4080
    cmp r15, 8
    jg .L89_9
    mov rdi, 4088
.L89_9:
    cmp rsi, rdi
    jg .L89_5
.L89_8:
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
.L89_5:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdi, rbx
    add rdi, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, r13
    mov rdx, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r14
    add rsi, r15
    jo zyl_rt_trap_ovf_0
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
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
.L92_0:
    mov r11, 0
    cmp r8, 0
    je .L92_1
    mov rbx, qword ptr [rsi+0]
    mov r12, rbx
    cmp r8, 8
    jge .L92_2
    mov r13, 1
    imul r14, r8, 8
    jo zyl_rt_trap_ovf_2
    mov rax, r13
    mov rcx, r14
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    sub r13, 1
    jo zyl_rt_trap_ovf_1
    mov r12, rbx
    and r12, r13
.L92_2:
    mov r11, r12
.L92_1:
    cmp r8, 8
    jle .L92_3
    mov rsi, qword ptr [rsi+8]
    mov rbx, r8
    sub rbx, 8
    jo zyl_rt_trap_ovf_1
    mov r12, rsi
    cmp rbx, 8
    jge .L92_5
    mov r13, 1
    imul rbx, rbx, 8
    jo zyl_rt_trap_ovf_2
    mov rax, r13
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    sub rbx, 1
    jo zyl_rt_trap_ovf_1
    mov r12, rsi
    and r12, rbx
.L92_5:
    jmp .L92_4
.L92_3:
    mov r12, 0
.L92_4:
    mov rsi, 0
    cmp r10, 0
    je .L92_6
    mov rbx, qword ptr [r9+0]
    mov r13, rbx
    cmp r10, 8
    jge .L92_7
    mov r14, 1
    imul r15, r10, 8
    jo zyl_rt_trap_ovf_2
    mov rax, r14
    mov rcx, r15
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r14, rax
    sub r14, 1
    jo zyl_rt_trap_ovf_1
    mov r13, rbx
    and r13, r14
.L92_7:
    mov rsi, r13
.L92_6:
    cmp r10, 8
    jle .L92_8
    mov r9, qword ptr [r9+8]
    mov rbx, r10
    sub rbx, 8
    jo zyl_rt_trap_ovf_1
    mov r13, r9
    cmp rbx, 8
    jge .L92_10
    mov r14, 1
    imul rbx, rbx, 8
    jo zyl_rt_trap_ovf_2
    mov rax, r14
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    sub rbx, 1
    jo zyl_rt_trap_ovf_1
    mov r13, r9
    and r13, rbx
.L92_10:
    jmp .L92_9
.L92_8:
    mov r13, 0
.L92_9:
    imul r9, r8, 8
    jo zyl_rt_trap_ovf_2
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
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r13
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r13, rax
    sub r9, 64
    jo zyl_rt_trap_ovf_1
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
    mov rax, r8
    add rax, r10
    jo zyl_rt_trap_ovf_0
    cmp rax, 8
    jl .L92_11
    mov qword ptr [rdi+8], rsi
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.L92_11:
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
.L93_0:
    mov r8, 0
    mov rdx, r8
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dconcat
.globl zyl_cstr_concat_r
zyl_cstr_concat_r:
    # frame 0
.L94_0:
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
.L95_0:
    mov r14, rdi
    cmp r14, 0
    jle .L95_1
    cmp r14, 4096
    jge .L95_1
    lea rax, [rip+.L96]
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
.L95_1:
    mov rsi, 0
    cmp r14, 0
    je .L95_2
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L95_2:
    mov rdi, 0
    cmp rbx, 0
    jl .L95_3
    mov r8, rsi
    cmp rbx, rsi
    jg .L95_4
    mov r8, rbx
.L95_4:
    mov rdi, r8
.L95_3:
    mov r8, 0
    cmp r12, 0
    jl .L95_5
    mov rax, rsi
    sub rax, rdi
    jo zyl_rt_trap_ovf_1
    cmp r12, rax
    jle .L95_6
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
    jmp .L95_7
.L95_6:
    mov rsi, r12
.L95_7:
    mov r8, rsi
.L95_5:
    add rdi, r14
    jo zyl_rt_trap_ovf_0
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
.L97_0:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dsubstr
.globl zyl_cstr_substr_r
zyl_cstr_substr_r:
    # frame 0
    mov r8, rdx
.L98_0:
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
.L99_0:
    mov rdi, 2
    call zyl_ralloc
    mov rsi, rax
    cmp rsi, 0
    jne .L99_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L99_1:
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
.L100_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dfrom_x2Dbyte
.globl zyl_cstr_from_byte_r
zyl_cstr_from_byte_r:
    # frame 0
.L101_0:
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
.L102_0:
    cmp rbx, 0
    jl .L102_2
.L102_6:
    cmp r12, 0
    jge .L102_1
.L102_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L102_1:
    cmp rdi, 0
    jle .L102_3
    cmp rdi, 4096
    jge .L102_3
    lea rax, [rip+.L103]
    mov rsi, rax
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
.L102_3:
    mov rsi, 0
    cmp rdi, 0
    je .L102_4
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L102_4:
    cmp rbx, rsi
    jg .L102_5
    sub rsi, rbx
    jo zyl_rt_trap_ovf_1
    mov rax, r12
    mov rcx, rsi
    cmp rax, rcx
    setle al
    movzx rax, al
    pop r12
    pop rbx
    pop rbp
    ret
.L102_5:
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
.L104_0:
    cmp rdi, 0
    je .L104_2
.L104_4:
    cmp r9, 0
    jl .L104_3
    cmp r9, r8
    jl .L104_1
.L104_3:
.L104_2:
    mov rax, -1
    ret
.L104_1:
    add rsi, r9
    jo zyl_rt_trap_ovf_0
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rsi+0]
    ret
zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dbase:
    # frame 0
.L105_0:
    cmp rdi, 0
    jne .L105_1
.L105_2:
    lea rax, [rip+zyl_rtg_empty]
    mov r8, rax
    mov rax, r8
    ret
.L105_1:
    mov rax, rdi
    add rax, rsi
    jo zyl_rt_trap_ovf_0
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
.L106_0:
    mov r8, qword ptr [rbp-48]
    cmp qword ptr [rbp-48], r14
    jl .L106_1
    mov r8, r14
.L106_1:
    mov r15, r8
    cmp r15, 0
    jle .L106_2
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
    jmp .L106_3
.L106_2:
    mov rsi, 0
.L106_3:
    cmp rsi, 0
    je .L106_4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L106_4:
    cmp qword ptr [rbp-48], r14
    jge .L106_5
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L106_5:
    cmp qword ptr [rbp-48], r14
    jle .L106_6
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L106_6:
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
.L107_0:
    cmp rdi, 0
    je .L107_2
.L107_4:
    cmp r9, 0
    jl .L107_3
    cmp r9, r8
    jl .L107_1
.L107_3:
.L107_2:
    mov rax, -1
    ret
.L107_1:
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
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
.L108_0:
    mov rdi, r13
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    call zyl_ralloc
    mov r14, rax
    cmp rbx, 0
    jle .L108_1
    cmp r13, 0
    jle .L108_1
    mov rsi, rbx
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, r14
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    jmp .L108_2
.L108_1:
.L108_2:
    mov rsi, r14
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L109_0:
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dcopy
.globl zyl_view_copy_r
zyl_view_copy_r:
    # frame 0
    mov r8, rdx
.L110_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r9, rax
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__cstr__rt_x2Dview_x2Dcopy
zy_local_x2Fmain_0__cstr__rt_x2Dlast_x2Dslash:
    # frame 0
    mov r8, rdx
.L111_0:
    mov r9, rdi
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    movzx r9d, byte ptr [r9+0]
    cmp r9, 0
    jne .L111_1
    mov rax, r8
    ret
.L111_1:
    mov r10, rsi
    add r10, 1
    jo zyl_rt_trap_ovf_0
    mov r11, rsi
    cmp r9, 47
    je .L111_2
    mov r11, r8
.L111_2:
    mov r8, r11
    mov rsi, r10
    jmp .L111_0
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
.L112_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L112_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L112_1:
    mov rsi, 0
    mov rdi, -1
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__cstr__rt_x2Dlast_x2Dslash
    mov rsi, rax
    cmp rsi, 0
    jge .L112_2
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L112_4
    mov rdi, 0
    jmp .L112_5
.L112_4:
    mov rdi, 1
.L112_5:
    jmp .L112_3
.L112_2:
    mov rdi, rsi
    add rdi, 1
    jo zyl_rt_trap_ovf_0
.L112_3:
    mov r12, rdi
    mov rdi, r12
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    call zyl_heap_alloc
    mov r13, rax
    cmp r13, 0
    jne .L112_6
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L112_6:
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r13
    add rsi, r12
    jo zyl_rt_trap_ovf_0
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
.L113_0:
    cmp rdi, -10000
    jle .L113_1
.L113_9:
    cmp rdi, -100
    jle .L113_2
    cmp rdi, -10
    jle .L113_3
    mov rax, 1
    ret
.L113_3:
    mov rax, 2
    ret
.L113_2:
    cmp rdi, -1000
    jle .L113_4
    mov rax, 3
    ret
.L113_4:
    mov rax, 4
    ret
.L113_1:
    cmp rdi, -100000000
    jle .L113_5
    cmp rdi, -1000000
    jle .L113_6
    cmp rdi, -100000
    jle .L113_7
    mov rax, 5
    ret
.L113_7:
    mov rax, 6
    ret
.L113_6:
    cmp rdi, -10000000
    jle .L113_8
    mov rax, 7
    ret
.L113_8:
    mov rax, 8
    ret
.L113_5:
    mov rsi, -1000000000
    mov r8, 9
    mov rdx, r8
    jmp zy_local_x2Fmain_0__text__rt_x2Dnd
zy_local_x2Fmain_0__text__rt_x2Dnd:
    # frame 0
    mov r8, rdx
.L114_0:
    cmp rdi, rsi
    jle .L114_1
.L114_3:
    mov rax, r8
    ret
.p2align 4
.L114_1:
    cmp r8, 18
    jne .L114_2
    mov rax, 19
    ret
.L114_2:
    imul rsi, rsi, 10
    jo zyl_rt_trap_ovf_2
    add r8, 1
    jo zyl_rt_trap_ovf_0
    cmp rdi, rsi
    jle .L114_1
    jmp .L114_3
zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dpairs:
    # frame 0
.L115_0:
    lea rax, [rip+.L116]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits:
    # frame 16
    push rbx
    mov r8, rdx
.L117_0:
    cmp rsi, -100
    jg .L117_1
.L117_3:
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
    jo zyl_rt_trap_ovf_2
    sub r10, rsi
    jo zyl_rt_trap_ovf_1
    lea rax, [rip+.L118]
    mov r11, rax
    imul r10, r10, 2
    jo zyl_rt_trap_ovf_2
    add r11, r10
    jo zyl_rt_trap_ovf_0
    mov r10, r8
    sub r10, 1
    jo zyl_rt_trap_ovf_1
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    movzx ebx, byte ptr [r11+0]
    mov byte ptr [r10+0], bl
    mov r10, rdi
    add r10, r8
    jo zyl_rt_trap_ovf_0
    movzx r11d, byte ptr [r11+1]
    mov byte ptr [r10+0], r11b
    mov rsi, r9
    sub r8, 2
    jo zyl_rt_trap_ovf_1
    cmp rsi, -100
    jg .L117_1
    jmp .L117_3
.L117_1:
    cmp rsi, -10
    jg .L117_2
    lea rax, [rip+.L119]
    mov r9, rax
    mov r10, 0
    sub r10, rsi
    jo zyl_rt_trap_ovf_1
    imul r10, r10, 2
    jo zyl_rt_trap_ovf_2
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, r8
    sub r10, 1
    jo zyl_rt_trap_ovf_1
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    movzx r11d, byte ptr [r9+0]
    mov byte ptr [r10+0], r11b
    mov r10, rdi
    add r10, r8
    jo zyl_rt_trap_ovf_0
    movzx r9d, byte ptr [r9+1]
    mov byte ptr [r10+0], r9b
    mov rax, r9
    pop rbx
    ret
.L117_2:
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, 48
    sub r8, rsi
    jo zyl_rt_trap_ovf_1
    mov byte ptr [rdi+0], r8b
    mov rsi, r8
    mov rax, rsi
    pop rbx
    ret
zy_local_x2Fmain_0__text__rt_x2Dtext_x2Dword:
    # frame 16
    push rbx
.L120_0:
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
    lea rax, [rip+.L121]
    mov r11, rax
    mov rbx, 0
    sub rbx, r10
    jo zyl_rt_trap_ovf_1
    imul rbx, rbx, 2
    jo zyl_rt_trap_ovf_2
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    movzx r11d, word ptr [r11+0]
    lea rax, [rip+.L122]
    mov rbx, rax
    imul r10, r10, 100
    jo zyl_rt_trap_ovf_2
    sub r10, r9
    jo zyl_rt_trap_ovf_1
    imul r10, r10, 2
    jo zyl_rt_trap_ovf_2
    add rbx, r10
    jo zyl_rt_trap_ovf_0
    movzx r10d, word ptr [rbx+0]
    shl r10, 16
    lea rax, [rip+.L123]
    mov rbx, rax
    imul r9, r9, 100
    jo zyl_rt_trap_ovf_2
    sub r9, r8
    jo zyl_rt_trap_ovf_1
    imul r9, r9, 2
    jo zyl_rt_trap_ovf_2
    add rbx, r9
    jo zyl_rt_trap_ovf_0
    movzx r9d, word ptr [rbx+0]
    shl r9, 32
    lea rax, [rip+.L124]
    mov rbx, rax
    imul r8, r8, 100
    jo zyl_rt_trap_ovf_2
    sub r8, rdi
    jo zyl_rt_trap_ovf_1
    imul rdi, r8, 2
    jo zyl_rt_trap_ovf_2
    add rbx, rdi
    jo zyl_rt_trap_ovf_0
    movzx edi, word ptr [rbx+0]
    shl rdi, 48
    or rdi, r9
    or rdi, r10
    or rdi, r11
    mov r8, 8
    sub r8, rsi
    jo zyl_rt_trap_ovf_1
    imul rsi, r8, 8
    jo zyl_rt_trap_ovf_2
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
.L125_0:
    cmp rdi, 0
    jle .L125_1
.L125_9:
    mov rsi, 0
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
    jmp .L125_2
.L125_1:
    mov rsi, rdi
.L125_2:
    mov r12, rsi
    mov rsi, 1
    cmp rdi, 0
    jl .L125_3
    mov rsi, 0
.L125_3:
    mov r13, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dndigits
    mov r14, rax
    add r14, r13
    jo zyl_rt_trap_ovf_0
    cmp r14, 7
    jg .L125_4
    mov rdi, r14
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    call zyl_ralloc
    mov r15, rax
    mov rsi, r14
    sub rsi, r13
    jo zyl_rt_trap_ovf_1
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dtext_x2Dword
    mov rsi, rax
    cmp r13, 1
    jne .L125_5
    mov rdi, rsi
    shl rdi, 8
    or rdi, 45
    jmp .L125_6
.L125_5:
    mov rdi, rsi
.L125_6:
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
.L125_4:
    mov rdi, r14
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    call zyl_ralloc
    mov rbx, rax
    cmp r13, 1
    jne .L125_7
    mov rsi, 45
    mov rcx, rsi
    mov byte ptr [rbx+0], cl
    jmp .L125_8
.L125_7:
.L125_8:
    mov rsi, r14
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    mov rsi, rbx
    add rsi, r14
    jo zyl_rt_trap_ovf_0
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
.L126_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
.globl zyl_int_text_r
zyl_int_text_r:
    # frame 0
.L127_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
zy_local_x2Fmain_0__text__rt_x2Darena_x2Dstr:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L128_0:
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
.L129_0:
    mov r14, rsi
    cmp r14, 0
    je .L129_2
    cmp r12, 0
    jl .L129_3
    cmp r13, 0
    jge .L129_1
.L129_3:
.L129_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L129_1:
    cmp r14, 4096
    jge .L129_4
    lea rax, [rip+.L130]
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
.L129_4:
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rax, r12
    add rax, r13
    jo zyl_rt_trap_ovf_0
    cmp rax, rsi
    jle .L129_5
    mov rax, rsi
    sub rax, r12
    jo zyl_rt_trap_ovf_1
    cmp rax, 0
    jge .L129_7
    mov rdi, 0
    jmp .L129_8
.L129_7:
    mov rdi, rsi
    sub rdi, r12
    jo zyl_rt_trap_ovf_1
.L129_8:
    jmp .L129_6
.L129_5:
    mov rdi, r13
.L129_6:
    mov r13, rdi
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    mov rsi, r14
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rbx
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L131_0:
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L132_0:
    mov rax, -9223372036854775808
    ret
zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dof:
    # frame 0
.L133_0:
    cmp rdi, 48
    jl .L133_1
.L133_4:
    cmp rdi, 57
    jg .L133_1
    mov rax, rdi
    sub rax, 48
    jo zyl_rt_trap_ovf_1
    ret
.L133_1:
    cmp rdi, 97
    jl .L133_2
    cmp rdi, 102
    jg .L133_2
    mov rax, rdi
    sub rax, 87
    jo zyl_rt_trap_ovf_1
    ret
.L133_2:
    cmp rdi, 65
    jl .L133_3
    cmp rdi, 70
    jg .L133_3
    mov rax, rdi
    sub rax, 55
    jo zyl_rt_trap_ovf_1
    ret
.L133_3:
    mov rax, -1
    ret
zy_local_x2Fmain_0__text__rt_x2Dacc_x2Dok:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L134_0:
    cmp rdi, 0
    je .L134_1
.L134_4:
    mov rdi, -9223372036854775808
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov rax, rdi
    mov rcx, r9
    test rcx, rcx
    jz zyl_rt_trap_div0_3
    cmp rcx, -1
    jne .L135
    neg rax
    jo zyl_rt_trap_ovf_3
    jmp .L136
.L135:
    cqo
    idiv rcx
.L136:
    cmp rsi, rax
    jge .L134_2
    mov rax, 0
    ret
.L134_2:
    mov rax, 1
    ret
.L134_1:
    mov rdi, 9223372036854775807
    sub rdi, r8
    jo zyl_rt_trap_ovf_1
    mov rax, rdi
    mov rcx, r9
    test rcx, rcx
    jz zyl_rt_trap_div0_3
    cmp rcx, -1
    jne .L137
    neg rax
    jo zyl_rt_trap_ovf_3
    jmp .L138
.L137:
    cqo
    idiv rcx
.L138:
    cmp rsi, rax
    jle .L134_3
    mov rax, 0
    ret
.L134_3:
    mov rax, 1
    ret
zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop:
    # frame 16
    push rbx
    push r12
    mov r8, rdx
.L139_0:
    movzx r9d, byte ptr [rdi+0]
    cmp r9, 48
    jl .L139_1
    cmp r9, 57
    jg .L139_1
    mov r10, r9
    sub r10, 48
    jo zyl_rt_trap_ovf_1
    mov r11, 10
    cmp rsi, 0
    je .L139_3
    mov rbx, -9223372036854775808
    add rbx, r10
    jo zyl_rt_trap_ovf_0
    mov rax, rbx
    mov rcx, r11
    test rcx, rcx
    jz zyl_rt_trap_div0_3
    cmp rcx, -1
    jne .L140
    neg rax
    jo zyl_rt_trap_ovf_3
    jmp .L141
.L140:
    cqo
    idiv rcx
.L141:
    cmp r8, rax
    jge .L139_5
    mov rbx, 0
    jmp .L139_6
.L139_5:
    mov rbx, 1
.L139_6:
    jmp .L139_4
.L139_3:
    mov r12, 9223372036854775807
    sub r12, r10
    jo zyl_rt_trap_ovf_1
    mov rax, r12
    mov rcx, r11
    test rcx, rcx
    jz zyl_rt_trap_div0_3
    cmp rcx, -1
    jne .L142
    neg rax
    jo zyl_rt_trap_ovf_3
    jmp .L143
.L142:
    cqo
    idiv rcx
.L143:
    cmp r8, rax
    jle .L139_7
    mov r10, 0
    jmp .L139_8
.L139_7:
    mov r10, 1
.L139_8:
    mov rbx, r10
.L139_4:
    cmp rbx, 0
    je .L139_2
    mov r10, rdi
    add r10, 1
    jo zyl_rt_trap_ovf_0
    sub r9, 48
    jo zyl_rt_trap_ovf_1
    mov r11, 10
    cmp rsi, 0
    je .L139_9
    mov rbx, r8
    imul rbx, r11
    jo zyl_rt_trap_ovf_2
    sub rbx, r9
    jo zyl_rt_trap_ovf_1
    jmp .L139_10
.L139_9:
    mov rbx, r8
    imul rbx, r11
    jo zyl_rt_trap_ovf_2
    add rbx, r9
    jo zyl_rt_trap_ovf_0
.L139_10:
    mov r8, rbx
    mov rdi, r10
    jmp .L139_0
.L139_2:
    mov rax, 0
    pop r12
    pop rbx
    ret
.L139_1:
    mov rax, r8
    pop r12
    pop rbx
    ret
.globl zyl_cstr_to_int
zyl_cstr_to_int:
    # frame 0
    push rbp
    mov rbp, rsp
.L144_0:
    cmp rdi, 0
    jne .L144_1
    mov rax, 0
    pop rbp
    ret
.L144_1:
    cmp rdi, 4096
    jge .L144_2
    lea rax, [rip+.L145]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
.L144_2:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 45
    jne .L144_3
    mov rsi, rdi
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov r8, 1
    mov r9, 0
    mov rdi, rsi
    mov rsi, r8
    mov rdx, r9
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dto_x2Dint_x2Dloop
.L144_3:
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
.L146_0:
    movzx edi, byte ptr [rbx+0]
    call zy_local_x2Fmain_0__text__rt_x2Ddigit_x2Dof
    mov rsi, rax
    cmp rsi, 0
    jl .L146_2
    cmp rsi, r14
    jl .L146_1
.L146_2:
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L146_1:
    cmp r12, 0
    je .L146_4
    mov rdi, -9223372036854775808
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, rdi
    mov rcx, r14
    test rcx, rcx
    jz zyl_rt_trap_div0_3
    cmp rcx, -1
    jne .L147
    neg rax
    jo zyl_rt_trap_ovf_3
    jmp .L148
.L147:
    cqo
    idiv rcx
.L148:
    cmp r13, rax
    jge .L146_6
    mov rdi, 0
    jmp .L146_7
.L146_6:
    mov rdi, 1
.L146_7:
    jmp .L146_5
.L146_4:
    mov r8, 9223372036854775807
    sub r8, rsi
    jo zyl_rt_trap_ovf_1
    mov rax, r8
    mov rcx, r14
    test rcx, rcx
    jz zyl_rt_trap_div0_3
    cmp rcx, -1
    jne .L149
    neg rax
    jo zyl_rt_trap_ovf_3
    jmp .L150
.L149:
    cqo
    idiv rcx
.L150:
    cmp r13, rax
    jle .L146_8
    mov r8, 0
    jmp .L146_9
.L146_8:
    mov r8, 1
.L146_9:
    mov rdi, r8
.L146_5:
    cmp rdi, 0
    je .L146_3
    mov rdi, rbx
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    cmp r12, 0
    je .L146_10
    mov r8, r13
    imul r8, r14
    jo zyl_rt_trap_ovf_2
    sub r8, rsi
    jo zyl_rt_trap_ovf_1
    jmp .L146_11
.L146_10:
    mov r8, r13
    imul r8, r14
    jo zyl_rt_trap_ovf_2
    add r8, rsi
    jo zyl_rt_trap_ovf_0
.L146_11:
    mov r13, r8
    mov rbx, rdi
    jmp .L146_0
.L146_3:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__text__rt_x2Dbase_x2Dof:
    # frame 0
.L151_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 48
    jne .L151_1
    movzx esi, byte ptr [rdi+1]
    cmp rsi, 120
    je .L151_3
    cmp rsi, 88
    jne .L151_2
.L151_3:
    mov rax, 16
    ret
.L151_2:
    cmp rsi, 111
    je .L151_5
    cmp rsi, 79
    jne .L151_4
.L151_5:
    mov rax, 8
    ret
.L151_4:
    cmp rsi, 98
    je .L151_7
    cmp rsi, 66
    jne .L151_6
.L151_7:
    mov rax, 2
    ret
.L151_6:
    mov rax, 10
    ret
.L151_1:
    mov rax, 10
    ret
.globl zyl_cstr_to_int_base
zyl_cstr_to_int_base:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
.L152_0:
    cmp rdi, 0
    jne .L152_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L152_1:
    cmp rdi, 4096
    jge .L152_2
    lea rax, [rip+.L153]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L152_2:
    movzx ebx, byte ptr [rdi+0]
    mov rax, rbx
    cmp rax, 45
    sete al
    movzx rax, al
    mov rbx, rax
    cmp rbx, 0
    je .L152_3
    mov rsi, rdi
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L152_4
.L152_3:
    mov rsi, rdi
.L152_4:
    mov r12, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dbase_x2Dof
    mov rsi, rax
    mov rdi, r12
    cmp rsi, 10
    je .L152_5
    mov rdi, r12
    add rdi, 2
    jo zyl_rt_trap_ovf_0
.L152_5:
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
.L154_0:
    cmp rdi, 65
    jl .L154_3
.L154_8:
    cmp rdi, 90
    jle .L154_2
.L154_3:
    cmp rdi, 97
    jl .L154_5
    cmp rdi, 122
    jle .L154_4
.L154_5:
    cmp rdi, 48
    jl .L154_7
    cmp rdi, 57
    jle .L154_6
.L154_7:
    cmp rdi, 95
    jne .L154_1
.L154_6:
.L154_4:
.L154_2:
    mov rax, rdi
    ret
.L154_1:
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
.L155_0:
    cmp r13, r14
    jl .L155_1
.L155_2:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L155_1:
    mov r15, rbx
    add r15, r13
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    movzx edi, byte ptr [rsi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dident_x2Dbyte
    mov rsi, rax
    mov rcx, rsi
    mov byte ptr [r15+0], cl
    add r13, 1
    jo zyl_rt_trap_ovf_0
    cmp r13, r14
    jl .L155_1
    jmp .L155_2
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
.L156_0:
    mov r12, rsi
    cmp r12, 0
    jne .L156_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L156_1:
    cmp r12, 4096
    jge .L156_2
    lea rax, [rip+.L157]
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
.L156_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L158_0:
    cmp rdi, 48
    jl .L158_1
.L158_4:
    cmp rdi, 57
    jg .L158_1
    mov rax, rdi
    sub rax, 48
    jo zyl_rt_trap_ovf_1
    ret
.L158_1:
    cmp rdi, 97
    jl .L158_2
    cmp rdi, 102
    jg .L158_2
    mov rax, rdi
    sub rax, 87
    jo zyl_rt_trap_ovf_1
    ret
.L158_2:
    cmp rdi, 65
    jl .L158_3
    cmp rdi, 70
    jg .L158_3
    mov rax, rdi
    sub rax, 55
    jo zyl_rt_trap_ovf_1
    ret
.L158_3:
    mov rax, -1
    ret
zy_local_x2Fmain_0__text__rt_x2Descape_x2Dbyte:
    # frame 0
.L159_0:
    cmp rdi, 110
    jne .L159_1
.L159_8:
    mov rax, 10
    ret
.L159_1:
    cmp rdi, 116
    jne .L159_2
    mov rax, 9
    ret
.L159_2:
    cmp rdi, 114
    jne .L159_3
    mov rax, 13
    ret
.L159_3:
    cmp rdi, 48
    jne .L159_4
    mov rax, 0
    ret
.L159_4:
    cmp rdi, 34
    jne .L159_5
    mov rax, 34
    ret
.L159_5:
    cmp rdi, 92
    jne .L159_6
    mov rax, 92
    ret
.L159_6:
    cmp rdi, 101
    jne .L159_7
    mov rax, 27
    ret
.L159_7:
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
.L160_0:
    mov rax, r12
    add rax, 3
    jo zyl_rt_trap_ovf_0
    cmp rax, rsi
    jge .L160_1
    mov rsi, r12
    add rsi, 2
    jo zyl_rt_trap_ovf_0
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    movzx edi, byte ptr [rsi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    cmp rax, 0
    jl .L160_2
    mov rsi, r12
    add rsi, 3
    jo zyl_rt_trap_ovf_0
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
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
.L160_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L160_1:
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
.L161_0:
    cmp r12, r13
    jl .L161_1
.L161_6:
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
.L161_1:
    mov rsi, qword ptr [rbp-56]
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    movzx esi, byte ptr [rsi+0]
    cmp rsi, 92
    jne .L161_2
    mov rax, r12
    add rax, 1
    jo zyl_rt_trap_ovf_0
    cmp rax, r13
    jl .L161_3
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L161_3:
    mov rdi, r12
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    add rdi, qword ptr [rbp-56]
    jo zyl_rt_trap_ovf_0
    movzx r15d, byte ptr [rdi+0]
    mov rdi, r15
    call zy_local_x2Fmain_0__text__rt_x2Descape_x2Dbyte
    mov rdi, rax
    cmp rdi, 0
    jl .L161_4
    mov r8, r14
    add r8, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov rcx, rdi
    mov byte ptr [r8+0], cl
    add r12, 2
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    cmp r12, r13
    jl .L161_1
    jmp .L161_6
.L161_4:
    cmp r15, 120
    jne .L161_5
    mov rdi, qword ptr [rbp-56]
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__text__rt_x2Dhex_x2Descape_x2Dok
    cmp rax, 0
    je .L161_5
    mov r15, r14
    add r15, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov rdi, r12
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    add rdi, qword ptr [rbp-56]
    jo zyl_rt_trap_ovf_0
    movzx edi, byte ptr [rdi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rbx, rax
    imul rbx, rbx, 16
    jo zyl_rt_trap_ovf_2
    mov rdi, r12
    add rdi, 3
    jo zyl_rt_trap_ovf_0
    add rdi, qword ptr [rbp-56]
    jo zyl_rt_trap_ovf_0
    movzx edi, byte ptr [rdi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rdi, rax
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rcx, rdi
    mov byte ptr [r15+0], cl
    add r12, 4
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    cmp r12, r13
    jl .L161_1
    jmp .L161_6
.L161_5:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L161_2:
    mov rdi, r14
    add rdi, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov rcx, rsi
    mov byte ptr [rdi+0], cl
    add r12, 1
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    cmp r12, r13
    jl .L161_1
    jmp .L161_6
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
.L162_0:
    mov r13, rsi
    cmp r13, 0
    jne .L162_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L162_1:
    cmp r13, 4096
    jge .L162_2
    lea rax, [rip+.L163]
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
.L162_2:
    mov rsi, r12
    sub rsi, rbx
    jo zyl_rt_trap_ovf_1
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
    jge .L162_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L162_3:
    add rsi, r14
    jo zyl_rt_trap_ovf_0
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
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L164_0:
    cmp rsi, r8
    jl .L164_1
.L164_5:
    mov rax, r9
    ret
.p2align 4
.L164_1:
    mov r10, rdi
    add r10, rsi
    jo zyl_rt_trap_ovf_0
    movzx r10d, byte ptr [r10+0]
    cmp r10, 0
    jne .L164_2
    mov rax, r9
    ret
.L164_2:
    mov r11, rsi
    add r11, 1
    jo zyl_rt_trap_ovf_0
    cmp r10, 10
    jne .L164_3
    mov r10, r9
    add r10, 1
    jo zyl_rt_trap_ovf_0
    jmp .L164_4
.L164_3:
    mov r10, r9
.L164_4:
    mov r9, r10
    mov rsi, r11
    cmp rsi, r8
    jl .L164_1
    jmp .L164_5
.globl zyl_cstr_count_newlines
zyl_cstr_count_newlines:
    # frame 0
    push rbp
    mov rbp, rsp
.L165_0:
    cmp rdi, 0
    jne .L165_1
    mov rax, 0
    pop rbp
    ret
.L165_1:
    cmp rdi, 4096
    jge .L165_2
    lea rax, [rip+.L166]
    mov r8, rax
    mov rsi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
.L165_2:
    mov r8, 0
    mov r9, 0
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    pop rbp
    jmp zy_local_x2Fmain_0__text__rt_x2Dcount_x2Dnl
zy_local_x2Fmain_0__text__rt_x2Dlast_x2Dnl:
    # frame 0
.L167_0:
    cmp rsi, 0
    jge .L167_1
.L167_3:
    mov rax, -1
    ret
.p2align 4
.L167_1:
    mov r8, rdi
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r8+0]
    cmp rax, 10
    jne .L167_2
    mov rax, rsi
    ret
.L167_2:
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jge .L167_1
    jmp .L167_3
.globl zyl_cstr_last_newline
zyl_cstr_last_newline:
    # frame 0
    push rbp
    mov rbp, rsp
.L168_0:
    cmp rdi, 0
    jne .L168_1
    mov rax, -1
    pop rbp
    ret
.L168_1:
    cmp rdi, 4096
    jge .L168_2
    lea rax, [rip+.L169]
    mov r8, rax
    mov rsi, r8
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, -1
    pop rbp
    ret
.L168_2:
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
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
.L170_0:
    cmp r12, r13
    jl .L170_1
.L170_6:
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L170_1:
    mov rsi, rbx
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rsi+0]
    cmp rax, 92
    jne .L170_2
    mov rax, r12
    add rax, 1
    jo zyl_rt_trap_ovf_0
    cmp rax, r13
    jl .L170_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L170_3:
    mov rsi, r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    movzx edi, byte ptr [rsi+0]
    call zy_local_x2Fmain_0__text__rt_x2Descape_x2Dbyte
    cmp rax, 0
    jl .L170_4
    add r12, 2
    jo zyl_rt_trap_ovf_0
    cmp r12, r13
    jl .L170_1
    jmp .L170_6
.L170_4:
    mov rsi, r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rsi+0]
    cmp rax, 120
    jne .L170_5
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__text__rt_x2Dhex_x2Descape_x2Dok
    cmp rax, 0
    je .L170_5
    add r12, 4
    jo zyl_rt_trap_ovf_0
    cmp r12, r13
    jl .L170_1
    jmp .L170_6
.L170_5:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L170_2:
    add r12, 1
    jo zyl_rt_trap_ovf_0
    cmp r12, r13
    jl .L170_1
    jmp .L170_6
.globl zyl_cstr_escapes_ok
zyl_cstr_escapes_ok:
    # frame 0
    mov r8, rdx
.L171_0:
    cmp rdi, 0
    jne .L171_1
    mov rax, 0
    ret
.L171_1:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__text__rt_x2Descapes_x2Dloop
zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Deq:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L172_0:
    cmp r8, r9
    jl .L172_1
.L172_3:
    mov rax, 1
    ret
.p2align 4
.L172_1:
    imul r10, r8, 8
    jo zyl_rt_trap_ovf_2
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    mov r10, qword ptr [r10+0]
    imul r11, r8, 8
    jo zyl_rt_trap_ovf_2
    add r11, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r11+0]
    cmp r10, rax
    jne .L172_2
    add r8, 1
    jo zyl_rt_trap_ovf_0
    cmp r8, r9
    jl .L172_1
    jmp .L172_3
.L172_2:
    mov rax, 0
    ret
.globl zyl_variant_eq
zyl_variant_eq:
    # frame 0
.L173_0:
    cmp rdi, rsi
    jne .L173_1
.L173_5:
    mov rax, 1
    ret
.L173_1:
    cmp rdi, 0
    je .L173_3
    cmp rsi, 0
    jne .L173_2
.L173_3:
    mov rax, 0
    ret
.L173_2:
    mov r8, rdi
    sub r8, 8
    jo zyl_rt_trap_ovf_1
    mov r8, qword ptr [r8+0]
    mov r9, rsi
    sub r9, 8
    jo zyl_rt_trap_ovf_1
    mov rax, qword ptr [r9+0]
    cmp r8, rax
    jne .L173_4
    mov r9, 0
    mov rdx, r9
    mov rcx, r8
    jmp zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Deq
.L173_4:
    mov rax, 0
    ret
.globl zyl_variant_cmp
zyl_variant_cmp:
    # frame 0
.L174_0:
    cmp rdi, rsi
    jne .L174_1
.L174_6:
    mov rax, 0
    ret
.L174_1:
    cmp rdi, 0
    je .L174_3
    cmp rsi, 0
    jne .L174_2
.L174_3:
    cmp rdi, 0
    jne .L174_4
    mov rax, -1
    ret
.L174_4:
    mov rax, 1
    ret
.L174_2:
    mov r8, rdi
    sub r8, 8
    jo zyl_rt_trap_ovf_1
    mov r8, qword ptr [r8+0]
    mov r9, rsi
    sub r9, 8
    jo zyl_rt_trap_ovf_1
    mov r9, qword ptr [r9+0]
    mov r10, 1
    mov r11, r8
    cmp r8, r9
    jl .L174_5
    mov r11, r9
.L174_5:
    mov rdx, r10
    mov rcx, r11
    jmp zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Dcmp_x7EInt_x2CInt_x2CInt_x2CInt_x2CInt_x2CInt
.globl zyl_variant_field
zyl_variant_field:
    # frame 0
.L175_0:
    cmp rdi, 0
    jne .L175_1
.L175_2:
    mov rax, 0
    ret
.L175_1:
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__heap__rt_x2Dbudget:
    # frame 0
.L176_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__rt_x2Dparse_x2Du:
    # frame 0
.L177_0:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 48
    jl .L177_1
    cmp r8, 57
    jg .L177_1
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    imul rsi, rsi, 10
    jo zyl_rt_trap_ovf_2
    sub r8, 48
    jo zyl_rt_trap_ovf_1
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    jmp .L177_0
.L177_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__rt_x2Dskip_x2Dws:
    # frame 0
.L178_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 32
    je .L178_2
    cmp rsi, 9
    jl .L178_1
    cmp rsi, 13
    jg .L178_1
.L178_2:
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L178_0
.L178_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__heap__rt_x2Dstrtoull:
    # frame 0
    push rbp
    mov rbp, rsp
.L179_0:
    call zy_local_x2Fmain_0__heap__rt_x2Dskip_x2Dws
    mov rsi, rax
    movzx eax, byte ptr [rsi+0]
    cmp rax, 43
    jne .L179_1
    mov rdi, rsi
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L179_2
.L179_1:
    mov rdi, rsi
.L179_2:
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
.L180_0:
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
    jge .L180_1
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L180_1:
    mov rdi, rbx
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
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
.L181_0:
    mov rax, r15
    add rax, r14
    jo zyl_rt_trap_ovf_0
    cmp rax, r12
    jle .L181_1
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L181_1:
    cmp r15, 0
    je .L181_3
    mov rsi, r15
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rsi+0]
    cmp rax, 10
    jne .L181_2
.L181_3:
    mov rdi, rbx
    add rdi, r15
    jo zyl_rt_trap_ovf_0
    mov rsi, r13
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    cmp rax, 0
    je .L181_2
    mov rax, r15
    add rax, r14
    jo zyl_rt_trap_ovf_0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L181_2:
    add r15, 1
    jo zyl_rt_trap_ovf_0
    jmp .L181_0
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
.L182_0:
    cmp r14, r13
    jl .L182_1
.L182_3:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L182_1:
    mov rsi, r12
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    sub rdi, r14
    jo zyl_rt_trap_ovf_1
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L182_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    cmp r14, r13
    jl .L182_1
    jmp .L182_3
.L182_2:
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
.L183_0:
    lea rax, [rip+.L184]
    mov rdi, rax
    mov rsi, 524288
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_2
    mov rbx, rax
    cmp rbx, 0
    jge .L183_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L183_1:
    mov rdi, 16384
    mov rsi, 0
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L183_2
    mov rdi, rbx
    call zyl_rt_sys_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L183_2:
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
    mov rsi, r12
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    lea rax, [rip+.L185]
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Dfield
    mov rbx, rax
    lea rax, [rip+.L186]
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Dfield
    mov r13, rax
    mov rdi, r12
    call zyl_rt_free
    cmp rbx, 0
    jle .L183_3
    imul rax, rbx, 1024
    jo zyl_rt_trap_ovf_2
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L183_3:
    cmp r13, 0
    jle .L183_4
    imul rax, r13, 1024
    jo zyl_rt_trap_ovf_2
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L183_4:
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
.L187_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_sysinfo@tpoff]
    mov rbx, rax
    mov rdi, rbx
    call zyl_rt_sys_99
    cmp rax, 0
    je .L187_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L187_1:
    mov rsi, qword ptr [rbx+32]
    mov edi, dword ptr [rbx+104]
    imul rsi, rdi
    jo zyl_rt_trap_ovf_2
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
.L188_0:
    lea rax, [rip+.L189]
    mov rdi, rax
    call zyl_getenv_str
    mov rdi, rax
    cmp rdi, 0
    jle .L188_1
    movzx eax, byte ptr [rdi+0]
    cmp rax, 0
    jle .L188_1
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__heap__rt_x2Dstrtoull
.L188_1:
    call zy_local_x2Fmain_0__heap__rt_x2Dmeminfo_x2Davailable
    mov rsi, rax
    mov rdi, rsi
    cmp rsi, 0
    jg .L188_2
    call zy_local_x2Fmain_0__heap__rt_x2Dsysinfo_x2Dtotal
    mov rdi, rax
.L188_2:
    cmp rdi, 0
    jle .L188_3
    mov rcx, rdi
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 1
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rsi, rax
    imul rsi, rsi, 4
    jo zyl_rt_trap_ovf_2
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
.L188_3:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Donce:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L190_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rbx, rax
    mov rax, qword ptr [rbx+0]
    cmp rax, 2
    jne .L190_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L190_1:
    mov rsi, 0
    mov rdi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov r11, rdi
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, 0
    jne .L190_2
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
.L190_2:
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Dwait
zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Dwait:
    # frame 0
.L191_0:
    mov rax, qword ptr [rdi+0]
    cmp rax, 2
    jne .L191_1
    mov rax, 0
    ret
.L191_1:
    jmp .L191_0
zy_local_x2Fmain_0__heap__rt_x2Dcharge:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L192_0:
    call zy_local_x2Fmain_0__heap__rt_x2Dbudget_x2Donce
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    mov rdi, rsi
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    mov rdx, rdi
    mov rcx, rbx
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rdi, rax
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jle .L192_1
    mov rax, qword ptr [rsi+8]
    cmp rdi, rax
    jle .L192_1
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    sub rdi, rbx
    jo zyl_rt_trap_ovf_1
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L192_1:
    mov rax, 1
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__heap__rt_x2Drefund:
    # frame 0
.L193_0:
    lea rax, [rip+zyl_rtg_budget]
    mov rsi, rax
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    mov r8, 0
    sub r8, rdi
    jo zyl_rt_trap_ovf_1
    mov rdx, rsi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    ret
zy_local_x2Fmain_0__heap__hp_x2Dmagic:
    # frame 0
.L194_0:
    mov rax, 23130
    ret
zy_local_x2Fmain_0__heap__hp_x2Dbig:
    # frame 0
.L195_0:
    mov rax, 255
    ret
zy_local_x2Fmain_0__heap__hp_x2Dlimit:
    # frame 0
.L196_0:
    mov rax, 281474976710656
    ret
zy_local_x2Fmain_0__heap__hp_x2Dcls:
    # frame 0
.L197_0:
    lea rax, [rip+zyl_rtg_heap_cls]
    mov rsi, rax
    imul rdi, rdi, 32
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__hp_x2Dthreaded:
    # frame 0
.L198_0:
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
.L199_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jle .L199_1
    mov rsi, 0
    mov r8, 1
    mov rdx, rdi
    mov rcx, rsi
    mov r11, r8
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, 0
    jne .L199_2
    mov rax, 0
    ret
.L199_2:
    jmp zy_local_x2Fmain_0__heap__hp_x2Dlock_x2Dslow
.L199_1:
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
.L200_0:
    mov rsi, 2
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L200_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L200_1:
    mov rsi, 128
    mov rdi, 2
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zyl_rt_sys_202
    jmp .L200_0
zy_local_x2Fmain_0__heap__hp_x2Dunlock:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L201_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jle .L201_1
    mov rsi, 0
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 2
    jne .L201_2
    mov rsi, 129
    mov r8, 1
    mov rdx, r8
    call zyl_rt_sys_202
    mov rsp, rbp
    pop rbp
    ret
.L201_2:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L201_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__heap__hp_x2Dmap:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L202_0:
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
    jge .L202_1
    cmp rsi, -4096
    jle .L202_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L202_1:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__heap__hp_x2Dclass_x2Dof:
    # frame 0
.L203_0:
    cmp rdi, 32
    jg .L203_1
.L203_3:
    mov rax, 0
    ret
.L203_1:
    mov rsi, 64
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    mov rdx, rdi
    mov ecx, 127
    bsr rax, rdx
    cmovz rax, rcx
    xor rax, 63
    mov rdi, rax
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
    cmp rsi, 16
    jle .L203_2
    mov rax, 12
    ret
.L203_2:
    mov rax, rsi
    sub rax, 5
    jo zyl_rt_trap_ovf_1
    ret
zy_local_x2Fmain_0__heap__hp_x2Dtag:
    # frame 0
.L204_0:
    cmp rdi, 0
    je .L204_1
.L204_3:
    mov rdi, 256
    jmp .L204_2
.L204_1:
    mov rdi, 0
.L204_2:
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    add rsi, 1515847680
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
zy_local_x2Fmain_0__heap__hp_x2Dhead:
    # frame 0
    mov r8, rdx
.L205_0:
    mov qword ptr [rdi+0], rsi
    mov qword ptr [rdi+8], r8
    mov rax, rdi
    add rax, 16
    jo zyl_rt_trap_ovf_0
    ret
zy_local_x2Fmain_0__heap__hp_x2Dtake:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L206_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dcls
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dlock
    mov r13, qword ptr [r12+8]
    cmp r13, 0
    jle .L206_1
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
.L206_1:
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
    jle .L206_2
    mov rsi, r13
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r12+24]
    cmp rsi, rax
    jg .L206_2
    mov rsi, r13
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r12+16], rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dunlock
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L206_2:
    mov rdi, 1048576
    call zy_local_x2Fmain_0__heap__hp_x2Dmap
    mov r13, rax
    cmp r13, 0
    jne .L206_3
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dunlock
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L206_3:
    mov rsi, r13
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r12+16], rsi
    mov rsi, r13
    add rsi, 1048576
    jo zyl_rt_trap_ovf_0
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
.L207_0:
    cmp rbx, 0
    jl .L207_2
.L207_12:
    mov rax, 281474976710656
    cmp rbx, rax
    jle .L207_1
.L207_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L207_1:
    mov rdi, rbx
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    call zy_local_x2Fmain_0__heap__hp_x2Dclass_x2Dof
    mov r13, rax
    cmp r13, 12
    jl .L207_3
    add rbx, 4111
    jo zyl_rt_trap_ovf_0
    and rbx, -4096
    cmp r12, 0
    je .L207_4
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    jne .L207_4
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L207_4:
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dmap
    mov r14, rax
    cmp r14, 0
    jne .L207_5
    cmp r12, 0
    je .L207_6
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    jmp .L207_7
.L207_6:
.L207_7:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L207_5:
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
.L207_3:
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
    je .L207_8
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    jne .L207_8
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L207_8:
    mov rdi, r13
    call zy_local_x2Fmain_0__heap__hp_x2Dtake
    mov r14, rax
    cmp r14, 0
    jne .L207_9
    cmp r12, 0
    je .L207_10
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    jmp .L207_11
.L207_10:
.L207_11:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L207_9:
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
.L208_0:
    cmp rdi, 4112
    jl .L208_1
.L208_3:
    mov rax, rdi
    and rax, 15
    cmp rax, 0
    jne .L208_2
    mov rsi, rdi
    sub rsi, 8
    jo zyl_rt_trap_ovf_1
    mov rsi, qword ptr [rsi+0]
    shr rsi, 16
    mov rax, rsi
    cmp rax, 23130
    sete al
    movzx rax, al
    ret
.L208_2:
    mov rax, 0
    ret
.L208_1:
    mov rax, 0
    ret
.globl zyl_rt_malloc
zyl_rt_malloc:
    # frame 0
.L209_0:
    mov rsi, 1
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
zy_local_x2Fmain_0__heap__rt_x2Draw_x2Dmalloc:
    # frame 0
.L210_0:
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
.L211_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dvalid
    cmp rax, 0
    jne .L211_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L211_1:
    sub rbx, 16
    jo zyl_rt_trap_ovf_1
    mov r12, qword ptr [rbx+0]
    mov r13, qword ptr [rbx+8]
    mov rdi, r13
    and rdi, 255
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
    cmp rdi, 255
    jne .L211_2
    mov rdi, rbx
    mov rsi, r12
    call zyl_rt_sys_11
    jmp .L211_3
.L211_2:
    call zy_local_x2Fmain_0__heap__hp_x2Dcls
    mov r14, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__heap__hp_x2Dlock
    mov rsi, qword ptr [r14+8]
    mov qword ptr [rbx+0], rsi
    mov qword ptr [r14+8], rbx
    mov rdi, r14
    call zy_local_x2Fmain_0__heap__hp_x2Dunlock
.L211_3:
    mov rax, r13
    and rax, 256
    cmp rax, 256
    jne .L211_4
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    jmp .L211_5
.L211_4:
.L211_5:
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
.L212_0:
    cmp rdi, 0
    jl .L212_2
.L212_7:
    cmp rsi, 0
    jge .L212_1
.L212_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L212_1:
    cmp rdi, 0
    jle .L212_3
    mov r8, 281474976710656
    mov rax, r8
    mov rcx, rdi
    test rcx, rcx
    jz zyl_rt_trap_div0_3
    cmp rcx, -1
    jne .L213
    neg rax
    jo zyl_rt_trap_ovf_3
    jmp .L214
.L213:
    cqo
    idiv rcx
.L214:
    cmp rsi, rax
    jle .L212_3
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L212_3:
    mov rbx, rdi
    imul rbx, rsi
    jo zyl_rt_trap_ovf_2
    mov rsi, 1
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L212_4
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L212_4:
    cmp rbx, 0
    jle .L212_5
    mov rdi, rsi
    sub rdi, 8
    jo zyl_rt_trap_ovf_1
    mov rdi, qword ptr [rdi+0]
    and rdi, 255
    cmp rdi, 255
    je .L212_5
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
    jmp .L212_6
.L212_5:
.L212_6:
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
.L215_0:
    cmp rbx, 0
    jne .L215_1
.L215_8:
    mov rsi, 1
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
.L215_1:
    cmp r12, 0
    jne .L215_2
    mov rdi, rbx
    call zyl_rt_free
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L215_2:
    cmp r12, 0
    jl .L215_4
    mov rax, 281474976710656
    cmp r12, rax
    jg .L215_5
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__hp_x2Dvalid
    cmp rax, 0
    jne .L215_3
.L215_5:
.L215_4:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L215_3:
    mov rsi, rbx
    sub rsi, 16
    jo zyl_rt_trap_ovf_1
    mov r13, qword ptr [rsi+0]
    sub r13, 16
    jo zyl_rt_trap_ovf_1
    cmp r12, r13
    jg .L215_6
    mov rax, rbx
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L215_6:
    mov rsi, 1
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L215_7
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L215_7:
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
.L216_0:
    mov rbx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    mov rdi, r12
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L216_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L216_1:
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r13
    add rsi, r12
    jo zyl_rt_trap_ovf_0
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
.L217_0:
    mov esi, dword ptr [rdi+0]
    cmp rsi, 2147483647
    jle .L217_1
    mov rdi, 4294967296
    mov rax, rsi
    sub rax, rdi
    jo zyl_rt_trap_ovf_1
    ret
.L217_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash:
    # frame 0
.L218_0:
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
.L219_0:
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
.L220_0:
    mov r12, qword ptr [rbx+8]
    cmp r12, 0
    je .L220_1
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
.L220_1:
    mov r13, rsi
    mov rsi, 16
    mov rdi, r13
    call zyl_rt_calloc
    mov r14, rax
    cmp r14, 0
    jne .L220_2
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L220_2:
    mov r15, qword ptr [rbx+0]
    mov rsi, r13
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
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
.L221_0:
    cmp r15, qword ptr [rbp-56]
    jl .L221_1
.L221_3:
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
.L221_1:
    imul rsi, r15, 16
    jo zyl_rt_trap_ovf_2
    mov rbx, qword ptr [rbp-48]
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    mov r12, qword ptr [rbx+0]
    cmp r12, 0
    je .L221_2
    mov rdi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
    mov rsi, rax
    and rsi, r14
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfree_x2Dslot
    mov rsi, rax
    imul rdi, rsi, 16
    jo zyl_rt_trap_ovf_2
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+0], r12
    imul rsi, rsi, 16
    jo zyl_rt_trap_ovf_2
    add rsi, 8
    jo zyl_rt_trap_ovf_0
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rbx+8]
    mov qword ptr [rsi+0], rdi
.L221_2:
    add r15, 1
    jo zyl_rt_trap_ovf_0
    cmp r15, qword ptr [rbp-56]
    jl .L221_1
    jmp .L221_3
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfree_x2Dslot:
    # frame 0
    mov r8, rdx
.L222_0:
    imul r9, r8, 16
    jo zyl_rt_trap_ovf_2
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r9+0]
    cmp rax, 0
    jne .L222_1
    mov rax, r8
    ret
.L222_1:
    add r8, 1
    jo zyl_rt_trap_ovf_0
    and r8, rsi
    jmp .L222_0
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
.L223_0:
    mov rdi, qword ptr [rbx+16]
    imul rdi, rdi, 10
    jo zyl_rt_trap_ovf_2
    mov r8, qword ptr [rbx+8]
    imul r8, r8, 7
    jo zyl_rt_trap_ovf_2
    cmp rdi, r8
    jl .L223_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dgrow
    jmp .L223_2
.L223_1:
.L223_2:
    mov r13, qword ptr [rbx+8]
    cmp r13, 0
    jne .L223_3
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L223_3:
    mov r14, qword ptr [rbx+0]
    mov r15, r13
    sub r15, 1
    jo zyl_rt_trap_ovf_1
    mov rdi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
    mov rsi, rax
    mov rdi, r13
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    and rsi, rdi
    mov rdi, r14
    mov rdx, r12
    mov rcx, rsi
    mov rsi, r15
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L223_4
    mov qword ptr [rsi+0], r12
    mov rdi, qword ptr [rbx+16]
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+16], rdi
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L223_4:
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
.L224_0:
    imul r10, r9, 16
    jo zyl_rt_trap_ovf_2
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    mov r11, qword ptr [r10+0]
    cmp r11, 0
    je .L224_2
    cmp r11, r8
    jne .L224_1
.L224_2:
    mov rax, r10
    ret
.L224_1:
    add r9, 1
    jo zyl_rt_trap_ovf_0
    and r9, rsi
    jmp .L224_0
zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rsi
.L225_0:
    mov r12, qword ptr [rdi+8]
    cmp rbx, 0
    je .L225_2
    cmp r12, 0
    jne .L225_1
.L225_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L225_1:
    mov r13, qword ptr [rdi+0]
    mov r14, r12
    sub r14, 1
    jo zyl_rt_trap_ovf_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
    mov rsi, rax
    mov rdi, r12
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    and rsi, rdi
    mov rdi, r13
    mov rdx, rbx
    mov rcx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dprobe
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L225_3
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L225_3:
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dspans:
    # frame 0
.L226_0:
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
.L227_0:
    cmp rdi, 0
    jne .L227_1
.L227_3:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L227_1:
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
    jne .L227_2
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L227_2:
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
.L228_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L228_1
    mov rax, -1
    pop rbp
    ret
.L228_1:
    mov rdi, rsi
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    pop rbp
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dld32s
.globl zyl_span_file
zyl_span_file:
    # frame 0
    push rbp
    mov rbp, rsp
.L229_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rsi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L229_1
    mov rax, -1
    pop rbp
    ret
.L229_1:
    mov rdi, rsi
    add rdi, 12
    jo zyl_rt_trap_ovf_0
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
.L230_0:
    lea rax, [rip+zyl_rtg_spans]
    mov rdi, rax
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov r12, rax
    cmp r12, 0
    jne .L230_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L230_1:
    mov rdi, r12
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    call zy_local_x2Fmain_0__ctab__rt_x2Dld32s
    mov r13, rax
    mov rdi, r12
    add rdi, 12
    jo zyl_rt_trap_ovf_0
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
.L231_0:
    lea rax, [rip+zyl_rtg_attrs]
    mov rsi, rax
    imul rdi, rdi, 24
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
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
.L232_0:
    cmp rbx, 0
    je .L232_2
.L232_5:
    cmp rdi, 0
    jl .L232_3
    cmp rdi, 6
    jl .L232_1
.L232_3:
.L232_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L232_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rdi, rax
    mov rsi, 4096
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dslot
    mov rsi, rax
    cmp rsi, 0
    jne .L232_4
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L232_4:
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
.L233_0:
    cmp rdi, 0
    jl .L233_2
.L233_4:
    cmp rdi, 6
    jl .L233_1
.L233_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L233_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rdi, rax
    mov rsi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L233_3
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L233_3:
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
.L234_0:
    cmp rdi, 0
    jl .L234_2
.L234_4:
    cmp rdi, 6
    jl .L234_1
.L234_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L234_1:
    call zy_local_x2Fmain_0__ctab__rt_x2Dattr_x2Dtab
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L234_3
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L234_3:
    mov rdi, qword ptr [rbx+0]
    mov rsi, qword ptr [rbx+8]
    imul rsi, rsi, 16
    jo zyl_rt_trap_ovf_2
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dzero:
    # frame 0
.L235_0:
    cmp rsi, 0
    jg .L235_1
.L235_2:
    mov rax, 0
    ret
.p2align 4
.L235_1:
    mov r8, 0
    mov qword ptr [rdi+0], r8
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    sub rsi, 8
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jg .L235_1
    jmp .L235_2
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
.L236_0:
    mov rdi, rbx
    call zyl_attr_get
    mov rsi, rax
    cmp rsi, 0
    jne .L236_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L236_1:
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
.L237_0:
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
.L238_0:
    mov rax, r8
    add rax, 8
    jo zyl_rt_trap_ovf_0
    cmp rax, rsi
    jg .L238_1
    mov r10, r8
    add r10, 8
    jo zyl_rt_trap_ovf_0
    mov r11, rdi
    add r11, r8
    jo zyl_rt_trap_ovf_0
    mov r11, qword ptr [r11+0]
    xor r9, r11
    mov r11, -7046029254386353131
    imul r9, r11
    mov r8, r10
    jmp .L238_0
.L238_1:
    cmp r8, rsi
    jge .L238_2
    mov r10, r8
    add r10, 1
    jo zyl_rt_trap_ovf_0
    mov r11, rdi
    add r11, r8
    jo zyl_rt_trap_ovf_0
    movzx r11d, byte ptr [r11+0]
    xor r9, r11
    mov r11, 1099511628211
    imul r9, r11
    mov r8, r10
    jmp .L238_0
.L238_2:
    mov rdi, r9
    xor rdi, rsi
    jmp zy_local_x2Fmain_0__ctab__rt_x2Daddr_x2Dhash
.globl zyl_smap_new
zyl_smap_new:
    # frame 0
.L239_0:
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
.L240_0:
    mov r12, qword ptr [rbx+8]
    mov rsi, 1024
    cmp r12, 0
    je .L240_1
    imul rsi, r12, 4
    jo zyl_rt_trap_ovf_2
.L240_1:
    mov r13, rsi
    mov rsi, 24
    mov rdi, r13
    call zyl_rt_calloc
    mov r14, rax
    cmp r14, 0
    jne .L240_2
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L240_2:
    mov r15, qword ptr [rbx+0]
    mov rsi, r13
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
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
.L241_0:
    cmp r15, r12
    jl .L241_1
.L241_4:
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
.L241_1:
    imul rsi, r15, 24
    jo zyl_rt_trap_ovf_2
    mov rbx, qword ptr [rbp-48]
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L241_2
    jmp .L241_3
.L241_2:
    mov rsi, qword ptr [rbx+16]
    and rsi, r14
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dempty
    mov rsi, rax
    imul rsi, rsi, 24
    jo zyl_rt_trap_ovf_2
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rbx+0]
    mov qword ptr [rsi+0], rdi
    mov rdi, qword ptr [rbx+8]
    mov qword ptr [rsi+8], rdi
    mov rdi, qword ptr [rbx+16]
    mov qword ptr [rsi+16], rdi
.L241_3:
    add r15, 1
    jo zyl_rt_trap_ovf_0
    cmp r15, r12
    jl .L241_1
    jmp .L241_4
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dempty:
    # frame 0
    mov r8, rdx
.L242_0:
    imul r9, r8, 24
    jo zyl_rt_trap_ovf_2
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r9+0]
    cmp rax, 0
    jne .L242_1
    mov rax, r8
    ret
.L242_1:
    add r8, 1
    jo zyl_rt_trap_ovf_0
    and r8, rsi
    jmp .L242_0
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
.L243_0:
    imul rsi, r15, 24
    jo zyl_rt_trap_ovf_2
    mov rbx, qword ptr [rbp-48]
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rbx+0]
    cmp rdi, 0
    jne .L243_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L243_1:
    mov rax, qword ptr [rbx+16]
    cmp rax, r14
    jne .L243_2
    mov rsi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L243_2
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L243_2:
    add r15, 1
    jo zyl_rt_trap_ovf_0
    and r15, r12
    jmp .L243_0
zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L244_0:
    cmp rbx, 0
    je .L244_2
.L244_5:
    cmp r12, 0
    je .L244_3
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L244_1
.L244_3:
.L244_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L244_1:
    mov r13, qword ptr [rbx+8]
    sub r13, 1
    jo zyl_rt_trap_ovf_1
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
    jne .L244_4
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L244_4:
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
.L245_0:
    mov r14, r12
    cmp rbx, 0
    je .L245_2
    cmp r14, 0
    jne .L245_1
.L245_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L245_1:
    mov rsi, qword ptr [rbx+16]
    imul rsi, rsi, 10
    jo zyl_rt_trap_ovf_2
    mov rdi, qword ptr [rbx+8]
    imul rdi, rdi, 7
    jo zyl_rt_trap_ovf_2
    cmp rsi, rdi
    jl .L245_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dgrow
    jmp .L245_4
.L245_3:
.L245_4:
    mov r15, qword ptr [rbx+8]
    cmp r15, 0
    jne .L245_5
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L245_5:
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
    mov rsi, r15
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    mov r8, r15
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    and r8, r13
    mov rdx, r14
    mov rcx, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dprobe
    mov r14, rax
    mov rax, qword ptr [r14+0]
    cmp rax, 0
    jne .L245_6
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov rsi, rax
    cmp rsi, 0
    jne .L245_7
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L245_7:
    mov qword ptr [r14+0], rsi
    mov qword ptr [r14+16], r13
    mov rsi, qword ptr [rbx+16]
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L245_6:
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
.L246_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L246_1
    mov rax, 0
    pop rbp
    ret
.L246_1:
    mov rax, qword ptr [rsi+8]
    pop rbp
    ret
.globl zyl_smap_has
zyl_smap_has:
    # frame 0
    push rbp
    mov rbp, rsp
.L247_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    cmp rax, 0
    jne .L247_1
    mov rax, 0
    pop rbp
    ret
.L247_1:
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
.L248_0:
    call zy_local_x2Fmain_0__ctab__rt_x2Dsmap_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jne .L248_1
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L248_1:
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
.L249_0:
    cmp r12, r13
    jl .L249_1
.L249_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L249_1:
    imul rsi, r12, 24
    jo zyl_rt_trap_ovf_2
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rsi+0]
    call zyl_rt_free
    add r12, 1
    jo zyl_rt_trap_ovf_0
    cmp r12, r13
    jl .L249_1
    jmp .L249_2
.globl zyl_smap_clear
zyl_smap_clear:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L250_0:
    cmp rbx, 0
    jne .L250_1
.L250_4:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L250_1:
    mov r12, qword ptr [rbx+8]
    mov rdi, qword ptr [rbx+0]
    mov rsi, 0
    mov rdx, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Dfree_x2Dkeys
    cmp r12, 0
    jle .L250_2
    mov rdi, qword ptr [rbx+0]
    imul rsi, r12, 24
    jo zyl_rt_trap_ovf_2
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
    jmp .L250_3
.L250_2:
.L250_3:
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
.L251_0:
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
.L252_0:
    cmp rbx, 0
    jne .L252_1
.L252_8:
    mov rax, -1
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L252_1:
    mov r13, qword ptr [rbx+8]
    mov rax, qword ptr [rbx+16]
    cmp r13, rax
    jl .L252_2
    mov rax, qword ptr [rbx+16]
    cmp rax, 0
    jne .L252_4
    mov rsi, 4096
    jmp .L252_5
.L252_4:
    mov rsi, qword ptr [rbx+16]
    imul rsi, rsi, 2
    jo zyl_rt_trap_ovf_2
.L252_5:
    mov r14, rsi
    mov rdi, qword ptr [rbx+0]
    imul rsi, r14, 8
    jo zyl_rt_trap_ovf_2
    call zyl_rt_realloc
    mov rsi, rax
    mov rdi, 0
    cmp rsi, 0
    je .L252_6
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+16], r14
    mov rdi, 1
.L252_6:
    jmp .L252_3
.L252_2:
    mov rdi, 1
.L252_3:
    mov rax, rdi
    cmp rax, 0
    je .L252_7
    mov rsi, qword ptr [rbx+0]
    imul rdi, r13, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rsi+0], r12
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+8], rsi
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L252_7:
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
.L253_0:
    mov r8, 0
    cmp rdi, 0
    je .L253_1
    mov r8, qword ptr [rdi+8]
.L253_1:
    mov rbx, r8
    cmp rdi, 0
    je .L253_3
    cmp rsi, 0
    jl .L253_4
    cmp rsi, rbx
    jl .L253_2
.L253_4:
.L253_3:
    lea rax, [rip+.L254]
    mov r12, rax
    mov rdi, rsi
    call zyl_int_text
    mov r13, rax
    lea rax, [rip+.L255]
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
.L253_2:
    mov rdi, qword ptr [rdi+0]
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
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
.L256_0:
    cmp rdi, 0
    je .L256_2
.L256_4:
    cmp rsi, 0
    jl .L256_3
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jl .L256_1
.L256_3:
.L256_2:
    mov rax, 0
    ret
.L256_1:
    mov rdi, qword ptr [rdi+0]
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+0], r8
    mov rax, 0
    ret
.globl zyl_wvec_len
zyl_wvec_len:
    # frame 0
.L257_0:
    cmp rdi, 0
    jne .L257_1
.L257_2:
    mov rax, 0
    ret
.L257_1:
    mov rax, qword ptr [rdi+8]
    ret
.globl zyl_wvec_pop
zyl_wvec_pop:
    # frame 0
.L258_0:
    cmp rdi, 0
    je .L258_2
.L258_3:
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jg .L258_1
.L258_2:
    lea rax, [rip+.L259]
    mov rsi, rax
    mov rdi, rsi
    jmp zyl_panic
.L258_1:
    mov rsi, qword ptr [rdi+8]
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    mov qword ptr [rdi+8], rsi
    mov rdi, qword ptr [rdi+0]
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_wvec_truncate
zyl_wvec_truncate:
    # frame 0
.L260_0:
    cmp rdi, 0
    jle .L260_1
.L260_2:
    cmp rsi, 0
    jl .L260_1
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jge .L260_1
    mov qword ptr [rdi+8], rsi
    mov rax, 0
    ret
.L260_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dglobal_x2Dhandle:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov r8, rdx
.L261_0:
    cmp rsi, 0
    jl .L261_2
.L261_6:
    cmp rsi, 8
    jl .L261_1
.L261_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L261_1:
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    mov rbx, rdi
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L261_3
    cmp r8, 0
    je .L261_4
    mov rdi, 1
    mov rsi, 24
    call zyl_rt_calloc
    mov rsi, rax
    jmp .L261_5
.L261_4:
    mov rdi, 1
    mov r8, 24
    mov rsi, r8
    call zyl_rt_calloc
    mov rsi, rax
.L261_5:
    mov qword ptr [rbx+0], rsi
    mov rax, qword ptr [rbx+0]
    pop rbx
    pop rbp
    ret
.L261_3:
    mov rax, qword ptr [rbx+0]
    pop rbx
    pop rbp
    ret
.globl zyl_wvec_global
zyl_wvec_global:
    # frame 0
.L262_0:
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
.L263_0:
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
.L264_0:
    mov rdi, rbx
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jle .L264_1
    mov rax, qword ptr [rsi+8]
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L264_1:
    mov rdi, qword ptr [rbx+0]
    mov rsi, 0
    cmp rdi, 0
    je .L264_2
    mov rsi, r12
    call zyl_smap_get
    mov rsi, rax
.L264_2:
    mov r13, rsi
    cmp r13, 0
    je .L264_3
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dcache_x2Dcell
.L264_3:
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
.L265_0:
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    mov r8, 1024
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Datab_x2Dslot
    mov rsi, rax
    cmp rsi, 0
    jne .L265_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L265_1:
    mov qword ptr [rsi+8], rbx
    mov rsi, rbx
    mov rax, rsi
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell:
    # frame 0
    mov r8, rdx
.L266_0:
    cmp r8, 0
    je .L266_1
.L266_3:
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcached
.L266_1:
    mov rdi, qword ptr [rdi+0]
    cmp rdi, 0
    jne .L266_2
    mov rax, 0
    ret
.L266_2:
    jmp zyl_smap_get
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dget:
    # frame 0
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L267_0:
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell
    mov rsi, rax
    cmp rsi, 0
    jne .L267_1
    mov rax, 0
    pop rbp
    ret
.L267_1:
    mov rax, qword ptr [rsi+0]
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dready:
    # frame 0
    push rbp
    mov rbp, rsp
    mov r8, rdx
.L268_0:
    mov rdx, r8
    call zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dcell
    cmp rax, 0
    jne .L268_1
    mov rax, 0
    pop rbp
    ret
.L268_1:
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
.L269_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L269_1
    mov rdi, 1
    mov rsi, 24
    call zyl_rt_calloc
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    jmp .L269_2
.L269_1:
.L269_2:
    mov rdi, 8
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L269_3
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L269_3:
    mov qword ptr [rsi+0], r13
    mov rdi, qword ptr [rbx+0]
    mov rdx, rsi
    mov rsi, r12
    call zyl_smap_put
    cmp r14, 0
    je .L269_4
    mov rdi, qword ptr [rbx+0]
    mov rsi, r12
    call zyl_smap_get
    mov rsi, rax
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__ctab__rt_x2Dcache_x2Dcell
    jmp .L269_5
.L269_4:
.L269_5:
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
.L270_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L270_1
    jmp .L270_2
.L270_1:
    mov rdi, qword ptr [rbx+0]
    call zyl_smap_clear
.L270_2:
    add rbx, 8
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L270_3
    jmp .L270_4
.L270_3:
    mov rdi, qword ptr [rbx+0]
    mov rsi, qword ptr [rbx+8]
    imul rsi, rsi, 16
    jo zyl_rt_trap_ovf_2
    call zy_local_x2Fmain_0__ctab__rt_x2Dzero
.L270_4:
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Ddefs:
    # frame 0
.L271_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ctab__rt_x2Didefs:
    # frame 0
.L272_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ctab__rt_x2Drepl_x2Ddefs:
    # frame 0
.L273_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_global_clear
zyl_global_clear:
    # frame 0
.L274_0:
    lea rax, [rip+zyl_rtg_def_cells]
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear
.globl zyl_global_ready
zyl_global_ready:
    # frame 0
.L275_0:
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
.L276_0:
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
.L277_0:
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
.L278_0:
    lea rax, [rip+zyl_rtg_idef_cells]
    mov rdi, rax
    jmp zy_local_x2Fmain_0__ctab__rt_x2Dcells_x2Dclear
.globl zyl_iglobal_ready
zyl_iglobal_ready:
    # frame 0
.L279_0:
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
.L280_0:
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
.L281_0:
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
.L282_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov r13, rax
    mov rax, qword ptr [r13+0]
    cmp rax, 0
    jne .L282_1
    mov rdi, 1
    mov rsi, 24
    call zyl_rt_calloc
    mov rsi, rax
    mov qword ptr [r13+0], rsi
    jmp .L282_2
.L282_1:
.L282_2:
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
.L283_0:
    lea rax, [rip+zyl_rtg_repl_globals]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L283_1
    mov rax, 0
    ret
.L283_1:
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
.L284_0:
    cmp rdi, 0
    jne .L284_1
.L284_3:
    lea rax, [rip+.L285]
    mov rsi, rax
    jmp .L284_2
.L284_1:
    mov rsi, rdi
.L284_2:
    lea rax, [rip+.L286]
    mov rbx, rax
    lea rax, [rip+.L287]
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
.L288_0:
    mov rbx, rdi
    mov r12, rsi
    cmp rbx, 0
    je .L288_2
    cmp r12, 0
    jne .L288_1
.L288_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L288_1:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__ctab__rt_x2Dprefix_x2Deq
    cmp rax, 0
    je .L288_3
    mov rsi, rbx
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    movzx esi, byte ptr [rsi+0]
    cmp rsi, 58
    jne .L288_4
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L288_4:
    mov rax, rsi
    cmp rax, 0
    sete al
    movzx rax, al
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L288_3:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__ctab__rt_x2Dprefix_x2Deq:
    # frame 0
    mov r8, rdx
.L289_0:
    cmp r8, 0
    jne .L289_1
.L289_3:
    mov rax, 1
    ret
.p2align 4
.L289_1:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    jne .L289_2
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    cmp r8, 0
    jne .L289_1
    jmp .L289_3
.L289_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrcs:
    # frame 0
.L290_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dcount:
    # frame 0
.L291_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rax, qword ptr [rsi+6144]
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc:
    # frame 0
.L292_0:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    imul rdi, rdi, 24
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
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
.L293_0:
    cmp r12, r13
    jl .L293_1
.L293_3:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L293_1:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    imul rdi, r12, 24
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rsi+0]
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L293_2
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L293_2:
    add r12, 1
    jo zyl_rt_trap_ovf_0
    cmp r12, r13
    jl .L293_1
    jmp .L293_3
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dset_x2Dtext:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L294_0:
    mov rdi, rsi
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov rdi, rax
    mov qword ptr [rbx+8], rdi
    mov rsi, 0
    cmp rdi, 0
    je .L294_1
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
.L294_1:
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
.L295_0:
    cmp rdi, 0
    jne .L295_1
.L295_11:
    lea rax, [rip+.L296]
    mov r8, rax
    jmp .L295_2
.L295_1:
    mov r8, rdi
.L295_2:
    mov rbx, r8
    cmp rsi, 0
    jne .L295_3
    lea rax, [rip+.L297]
    mov rdi, rax
    jmp .L295_4
.L295_3:
    mov rdi, rsi
.L295_4:
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
    jl .L295_5
    lea rax, [rip+zyl_rtg_src_files]
    mov r15, rax
    imul rsi, r14, 24
    jo zyl_rt_trap_ovf_2
    add r15, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r15+8]
    cmp rax, 0
    jne .L295_6
    lea rax, [rip+.L298]
    mov rsi, rax
    jmp .L295_7
.L295_6:
    mov rsi, qword ptr [r15+8]
.L295_7:
    mov rdi, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L295_8
    jmp .L295_9
.L295_8:
    mov rdi, qword ptr [r15+8]
    call zyl_rt_free
    mov rdi, r15
    mov rsi, r12
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dset_x2Dtext
.L295_9:
    mov rax, r14
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L295_5:
    cmp r13, 256
    jl .L295_10
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L295_10:
    lea rax, [rip+zyl_rtg_src_files]
    mov r14, rax
    imul rsi, r13, 24
    jo zyl_rt_trap_ovf_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rdi, r13
    add rdi, 1
    jo zyl_rt_trap_ovf_0
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
.L299_0:
    cmp rdi, 0
    jl .L299_2
.L299_3:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    mov rax, qword ptr [rsi+6144]
    cmp rdi, rax
    jl .L299_1
.L299_2:
    mov rax, 0
    ret
.L299_1:
    lea rax, [rip+zyl_rtg_src_files]
    mov rsi, rax
    imul rdi, rdi, 24
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
.globl zyl_source_path
zyl_source_path:
    # frame 0
    push rbp
    mov rbp, rsp
.L300_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    jne .L300_1
    lea rax, [rip+.L301]
    mov rdi, rax
    mov rax, rdi
    pop rbp
    ret
.L300_1:
    mov rax, qword ptr [rsi+0]
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rsi
.L302_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L302_2
    cmp rbx, 0
    jge .L302_1
.L302_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L302_1:
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    je .L302_4
    mov rax, qword ptr [rsi+16]
    cmp rbx, rax
    jle .L302_3
.L302_4:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L302_3:
    mov rax, rsi
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__source__rt_x2Dcount_x2Dlines:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L303_0:
    cmp rsi, r8
    jl .L303_1
.L303_4:
    mov rax, r9
    ret
.p2align 4
.L303_1:
    mov r10, rsi
    add r10, 1
    jo zyl_rt_trap_ovf_0
    mov r11, rdi
    add r11, rsi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r11+0]
    cmp rax, 10
    jne .L303_2
    mov r11, r9
    add r11, 1
    jo zyl_rt_trap_ovf_0
    jmp .L303_3
.L303_2:
    mov r11, r9
.L303_3:
    mov r9, r11
    mov rsi, r10
    cmp rsi, r8
    jl .L303_1
    jmp .L303_4
.globl zyl_span_line
zyl_span_line:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rsi
.L304_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov rsi, rax
    cmp rsi, 0
    jne .L304_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L304_1:
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
.L305_0:
    cmp rsi, 0
    jle .L305_1
.L305_2:
    mov r8, rsi
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    add r8, rdi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r8+0]
    cmp rax, 10
    je .L305_1
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jle .L305_1
    jmp .L305_2
.L305_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__source__rt_x2Dline_x2Dend:
    # frame 0
    mov r8, rdx
.L306_0:
    cmp rsi, r8
    jge .L306_1
.L306_2:
    mov r9, rdi
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r9+0]
    cmp rax, 10
    je .L306_1
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    cmp rsi, r8
    jge .L306_1
    jmp .L306_2
.L306_1:
    mov rax, rsi
    ret
.globl zyl_span_col
zyl_span_col:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rsi
.L307_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov rsi, rax
    cmp rsi, 0
    jne .L307_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L307_1:
    mov rdi, qword ptr [rsi+8]
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart
    mov rsi, rax
    mov rax, rbx
    mov rcx, rsi
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov rsi, rax
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L308_0:
    mov rdi, r12
    add rdi, 7
    jo zyl_rt_trap_ovf_0
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    jne .L308_1
    lea rax, [rip+.L309]
    mov rsi, rax
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L308_1:
    cmp r13, 0
    je .L308_2
    lea rax, [rip+.L310]
    mov rsi, rax
    mov rdi, 3
    mov rdx, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, 3
    jmp .L308_3
.L308_2:
    mov rsi, 0
.L308_3:
    mov r13, rsi
    mov rdi, r15
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rbx, r13
    add rbx, r12
    jo zyl_rt_trap_ovf_0
    cmp r14, 0
    je .L308_4
    mov rdi, r15
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L311]
    mov rsi, rax
    mov r8, 3
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rbx
    add rsi, 3
    jo zyl_rt_trap_ovf_0
    jmp .L308_5
.L308_4:
    mov rsi, rbx
.L308_5:
    add rsi, r15
    jo zyl_rt_trap_ovf_0
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
.L312_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov r12, rax
    cmp r12, 0
    jne .L312_1
    lea rax, [rip+.L313]
    mov rsi, rax
    mov rax, rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L312_1:
    mov r13, qword ptr [r12+8]
    mov rdi, r13
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dstart
    mov r14, rax
    mov r15, r13
    add r15, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, qword ptr [r12+16]
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dline_x2Dend
    mov rsi, rax
    sub rsi, r14
    jo zyl_rt_trap_ovf_1
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
.L314_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dat
    mov r12, rax
    cmp r12, 0
    jne .L314_1
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
.L314_m3d:
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
.L314_1:
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
    jo zyl_rt_trap_ovf_1
    cmp rax, 120
    jg .L314_2
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
.L314_m15d:
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
.L314_2:
    mov rax, rbx
    sub rax, 60
    jo zyl_rt_trap_ovf_1
    cmp rax, r14
    jge .L314_3
    mov rdi, r14
    jmp .L314_4
.L314_3:
    mov rdi, rbx
    sub rdi, 60
    jo zyl_rt_trap_ovf_1
.L314_4:
    mov rax, rdi
    add rax, 120
    jo zyl_rt_trap_ovf_0
    cmp rax, rsi
    jle .L314_5
    mov r8, rsi
    sub r8, 120
    jo zyl_rt_trap_ovf_1
    jmp .L314_6
.L314_5:
    mov r8, rdi
.L314_6:
    mov rax, rdi
    add rax, 120
    jo zyl_rt_trap_ovf_0
    cmp rax, rsi
    jle .L314_7
    mov r9, rsi
    jmp .L314_8
.L314_7:
    mov r9, rdi
    add r9, 120
    jo zyl_rt_trap_ovf_0
.L314_8:
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
.L314_m49d:
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
.L315_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsnip
    mov rsi, rax
    mov rdi, [rsi+0]
    cmp rdi, 0
    jne .L315_1
    mov r8, [rsi+8]
    mov r9, [rsi+16]
    mov r10, [rsi+24]
    mov rsi, [rsi+32]
    lea rax, [rip+zyl_rtg_src_files]
    mov r11, rax
    imul rbx, rbx, 24
    jo zyl_rt_trap_ovf_2
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    mov r11, qword ptr [r11+8]
    add r11, r8
    jo zyl_rt_trap_ovf_0
    sub r9, r8
    jo zyl_rt_trap_ovf_1
    mov rdi, r11
    mov rdx, r10
    mov rcx, rsi
    mov rsi, r9
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__source__rt_x2Dmcopy
.L315_1:
    cmp rdi, 1
    jne .L315_2
    lea rax, [rip+.L316]
    mov rsi, rax
    mov rax, rsi
    pop rbx
    pop rbp
    ret
.L315_2:
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
.L317_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__source__rt_x2Dsnip
    mov rsi, rax
    mov rdi, [rsi+0]
    cmp rdi, 0
    jne .L317_1
    mov r8, [rsi+8]
    mov rsi, [rsi+24]
    mov rax, rbx
    mov rcx, r8
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov r8, rax
    add r8, 1
    jo zyl_rt_trap_ovf_0
    cmp rsi, 0
    je .L317_2
    mov rsi, 3
    jmp .L317_3
.L317_2:
    mov rsi, 0
.L317_3:
    mov rax, r8
    add rax, rsi
    jo zyl_rt_trap_ovf_0
    pop rbx
    pop rbp
    ret
.L317_1:
    cmp rdi, 1
    jne .L317_4
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L317_4:
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
.L318_0:
    cmp r12, r13
    jl .L318_1
.L318_3:
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L318_1:
    mov rdi, 10
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dfind_x2Dbyte
    mov rdi, rax
    cmp rdi, 0
    jge .L318_2
    mov rax, -1
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L318_2:
    mov rsi, rdi
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add r12, 1
    jo zyl_rt_trap_ovf_0
    cmp r12, r13
    jl .L318_1
    jmp .L318_3
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
.L319_0:
    call zy_local_x2Fmain_0__source__rt_x2Dsrc_x2Dok
    mov rsi, rax
    cmp rsi, 0
    je .L319_2
    cmp rbx, 1
    jl .L319_3
    cmp r12, 1
    jge .L319_1
.L319_3:
.L319_2:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L319_1:
    mov rdi, qword ptr [rsi+8]
    cmp rdi, 0
    jne .L319_4
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L319_4:
    mov r13, qword ptr [rsi+16]
    mov rsi, 0
    mov r8, 1
    mov rdx, r8
    mov rcx, rbx
    mov r8, r13
    call zy_local_x2Fmain_0__source__rt_x2Dskip_x2Dlines
    mov rsi, rax
    cmp rsi, 0
    jge .L319_5
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L319_5:
    mov rdi, r12
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    cmp rsi, r13
    jg .L319_6
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L319_6:
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
.L320_0:
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
.L321_0:
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
.L322_0:
    mov rsi, 0
    mov r8, 1
    mov rdx, rdi
    mov rcx, rsi
    mov r11, r8
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, 0
    jne .L322_1
    mov rax, 0
    ret
.L322_1:
    jmp zy_local_x2Fmain_0__thread__rt_x2Dmutex_x2Dcontend
zy_local_x2Fmain_0__thread__rt_x2Dmutex_x2Dcontend:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L323_0:
    mov rsi, 2
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L323_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L323_1:
    mov rsi, 2
    mov rdi, 0
    mov r8, 128
    mov rdx, rsi
    mov rsi, r8
    mov rcx, rdi
    mov rdi, rbx
    call zyl_rt_sys_202
    jmp .L323_0
.globl zyl_rt_mutex_unlock
zyl_rt_mutex_unlock:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L324_0:
    mov rsi, -1
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    cmp rax, 1
    jne .L324_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L324_1:
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
.L325_0:
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
.L326_0:
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
.L327_0:
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
.L328_0:
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
    jo zyl_rt_trap_ovf_1
    mov rdi, qword ptr [r13+8]
    mov r8, qword ptr [r15+8]
    sub rdi, r8
    jo zyl_rt_trap_ovf_1
    cmp rdi, 0
    jge .L328_1
    mov r8, rsi
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    jmp .L328_2
.L328_1:
    mov r8, rsi
.L328_2:
    cmp rdi, 0
    jge .L328_3
    mov rsi, rdi
    add rsi, 1000000000
    jo zyl_rt_trap_ovf_0
    jmp .L328_4
.L328_3:
    mov rsi, rdi
.L328_4:
    cmp r8, 0
    jge .L328_5
    mov rax, 110
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L328_5:
    mov r13, r15
    add r13, 16
    jo zyl_rt_trap_ovf_0
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
    jne .L328_6
    mov rax, 110
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L328_6:
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
.L329_0:
    lea rax, [rip+zyl_rtg_tls_info]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__thread__rt_x2Dfreestanding:
    # frame 0
.L330_0:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_rt_hosted_p
zyl_rt_hosted_p:
    # frame 0
.L331_0:
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
.L332_0:
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
.L333_0:
    mov r8, rsi
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, 0
    sub r8, rsi
    jo zyl_rt_trap_ovf_1
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
.L334_0:
    lea rax, [rip+zyl_rtg_tls_info]
    mov rbx, rax
    mov rax, qword ptr [rbx+24]
    cmp rax, 64
    jge .L334_1
    mov rsi, 64
    jmp .L334_2
.L334_1:
    mov rsi, qword ptr [rbx+24]
.L334_2:
    mov r12, rsi
    mov rdi, qword ptr [rbx+16]
    mov rsi, r12
    call zy_local_x2Fmain_0__thread__rt_x2Dalign_x2Dup
    mov r13, rax
    mov rdi, r13
    add rdi, 64
    jo zyl_rt_trap_ovf_0
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov rsi, 4096
    call zy_local_x2Fmain_0__thread__rt_x2Dalign_x2Dup
    mov r14, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__thread__rt_x2Dmmap
    mov r15, rax
    cmp r15, 0
    jge .L334_3
    cmp r15, -4096
    jle .L334_3
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L334_3:
    mov rdi, r15
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    call zy_local_x2Fmain_0__thread__rt_x2Dalign_x2Dup
    mov r12, rax
    mov rdi, r12
    sub rdi, r13
    jo zyl_rt_trap_ovf_1
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
.L335_0:
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
.L336_0:
    cmp r8, rsi
    jl .L336_1
.L336_3:
    mov rax, 0
    ret
.p2align 4
.L336_1:
    imul r9, r8, 56
    jo zyl_rt_trap_ovf_2
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    mov eax, dword ptr [r9+0]
    cmp rax, 7
    jne .L336_2
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
.L336_2:
    add r8, 1
    jo zyl_rt_trap_ovf_0
    cmp r8, rsi
    jl .L336_1
    jmp .L336_3
zy_local_x2Fmain_0__thread__rt_x2Dauxv:
    # frame 0
.L337_0:
    mov r8, qword ptr [rdi+0]
    cmp r8, 0
    jne .L337_1
    mov rax, 0
    ret
.L337_1:
    cmp r8, rsi
    jne .L337_2
    mov rax, qword ptr [rdi+8]
    ret
.L337_2:
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    jmp .L337_0
zy_local_x2Fmain_0__thread__rt_x2Dskip_x2Denv:
    # frame 0
.L338_0:
    mov rax, qword ptr [rdi+0]
    cmp rax, 0
    jne .L338_1
    mov rax, rdi
    add rax, 8
    jo zyl_rt_trap_ovf_0
    ret
.L338_1:
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    jmp .L338_0
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
.L339_0:
    mov rbx, qword ptr [rdi+0]
    mov r12, rdi
    add r12, 8
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    mov r13, r12
    add r13, rsi
    jo zyl_rt_trap_ovf_0
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
.L340_0:
    mov rax, 4001536
    ret
zy_local_x2Fmain_0__thread__rt_x2Dstack_x2Dnew:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L341_0:
    call zy_local_x2Fmain_0__thread__rt_x2Dmmap
    mov rbx, rax
    cmp rbx, 0
    jge .L341_1
    cmp rbx, -4096
    jle .L341_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L341_1:
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
.L342_0:
    mov rdi, 4096
    call zy_local_x2Fmain_0__thread__rt_x2Dmmap
    mov rdi, rax
    cmp rdi, 0
    jge .L342_1
    cmp rdi, -4096
    jle .L342_1
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L342_1:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L342_2
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
.L342_2:
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
.L343_0:
    mov rsi, 8388608
    cmp r14, 0
    je .L343_1
    mov rsi, r8
.L343_1:
    mov r15, rsi
    cmp r14, 0
    jne .L343_2
    mov rdi, r15
    call zy_local_x2Fmain_0__thread__rt_x2Dstack_x2Dnew
    mov rsi, rax
    jmp .L343_3
.L343_2:
    mov rsi, r14
.L343_3:
    mov rbx, rsi
    call zy_local_x2Fmain_0__thread__rt_x2Dtls_x2Dnew
    mov qword ptr [rbp-56], rax
    cmp rbx, 0
    je .L343_5
    cmp qword ptr [rbp-56], 0
    jne .L343_4
.L343_5:
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
.L343_4:
    mov rsi, rbx
    add rsi, r15
    jo zyl_rt_trap_ovf_0
    and rsi, -16
    mov rdi, rsi
    sub rdi, 16
    jo zyl_rt_trap_ovf_1
    mov qword ptr [rdi+0], r12
    mov rdi, rsi
    sub rdi, 8
    jo zyl_rt_trap_ovf_1
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
    je .L343_6
    mov rdi, 0
.L343_6:
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+40], rdi
    mov rdi, 4001536
    sub rsi, 16
    jo zyl_rt_trap_ovf_1
    mov rdx, qword ptr [rbp-48]
    mov rcx, qword ptr [rbp-48]
    mov r8, qword ptr [rbp-56]
    call zyl_rt_clone
    cmp rax, 0
    jge .L343_7
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
.L343_7:
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
.L344_0:
    mov rbx, qword ptr [rbp-48]
    add rbx, 64
    jo zyl_rt_trap_ovf_0
    mov rax, QWORD PTR [rip+pthread_attr_init@GOTPCREL]
    mov rdi, rax
    mov rsi, rbx
    call zyl_rt_call1
    cmp r14, 0
    je .L344_1
    mov rax, QWORD PTR [rip+pthread_attr_setstack@GOTPCREL]
    mov rdi, rax
    mov rsi, rbx
    mov rdx, r14
    mov rcx, r15
    call zyl_rt_call3
.L344_1:
    mov rax, QWORD PTR [rip+pthread_create@GOTPCREL]
    mov rdi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, 32
    jo zyl_rt_trap_ovf_0
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
    jne .L344_2
    mov rax, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L344_2:
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
.L345_0:
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
.L346_0:
    mov esi, dword ptr [rbx+0]
    cmp rsi, 0
    jne .L346_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L346_1:
    mov rdi, 0
    mov r8, 0
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, rbx
    mov rcx, r8
    call zyl_rt_sys_202
    jmp .L346_0
.globl zyl_rt_thread_join
zyl_rt_thread_join:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L347_0:
    cmp rbx, 0
    jne .L347_1
.L347_5:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L347_1:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L347_2
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
.L347_2:
    mov rdi, rbx
    call zy_local_x2Fmain_0__thread__rt_x2Djoin_x2Dwait
    mov rax, qword ptr [rbx+40]
    cmp rax, 1
    jne .L347_3
    mov rdi, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+16]
    call zyl_rt_sys_11
    jmp .L347_4
.L347_3:
.L347_4:
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
.L348_0:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L348_1
    mov rax, QWORD PTR [rip+pthread_exit@GOTPCREL]
    mov rdi, rax
    mov rsi, 0
    jmp zyl_rt_call1
.L348_1:
    mov rdi, 0
    jmp zyl_rt_sys_60
.globl zyl_rt_thread_detach
zyl_rt_thread_detach:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L349_0:
    cmp rdi, 0
    jle .L349_1
.L349_2:
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L349_1
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
.L349_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Ditests:
    # frame 0
.L350_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__interp__rt_x2Ditest_x2Dn:
    # frame 0
.L351_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    ret
.globl zyl_itest_add
zyl_itest_add:
    # frame 0
.L352_0:
    lea rax, [rip+zyl_rtg_itests]
    mov r8, rax
    mov r8, qword ptr [r8+65536]
    cmp r8, 4096
    jl .L352_1
    mov rax, -1
    ret
.L352_1:
    lea rax, [rip+zyl_rtg_itests]
    mov r9, rax
    imul r10, r8, 16
    jo zyl_rt_trap_ovf_2
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r9+0], rdi
    mov qword ptr [r9+8], rsi
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rdi, r8
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rsi+65536], rdi
    mov rax, r8
    ret
.globl zyl_itest_count
zyl_itest_count:
    # frame 0
.L353_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    ret
.globl zyl_itest_name
zyl_itest_name:
    # frame 0
.L354_0:
    cmp rdi, 0
    jl .L354_2
.L354_3:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    cmp rdi, rax
    jl .L354_1
.L354_2:
    mov rax, 0
    ret
.L354_1:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    imul rdi, rdi, 16
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_itest_fn
zyl_itest_fn:
    # frame 0
.L355_0:
    cmp rdi, 0
    jl .L355_2
.L355_3:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rax, qword ptr [rsi+65536]
    cmp rdi, rax
    jl .L355_1
.L355_2:
    mov rax, 0
    ret
.L355_1:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    imul rdi, rdi, 16
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rsi+8]
    ret
.globl zyl_itest_reset
zyl_itest_reset:
    # frame 0
.L356_0:
    lea rax, [rip+zyl_rtg_itests]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+65536], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap:
    # frame 0
.L357_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__interp__rt_x2Dfnmap_x2Dused:
    # frame 0
.L358_0:
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, qword ptr [rsi+262144]
    ret
.globl zyl_fnmap_reset
zyl_fnmap_reset:
    # frame 0
    push rbp
    mov rbp, rsp
.L359_0:
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
.L360_0:
    cmp r14, 16384
    jl .L360_1
.L360_4:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L360_1:
    mov rsi, r13
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    and rsi, 16383
    imul rsi, rsi, 16
    jo zyl_rt_trap_ovf_2
    mov r15, rbx
    add r15, rsi
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [r15+0]
    cmp rdi, 0
    je .L360_3
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L360_2
.L360_3:
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L360_2:
    add r14, 1
    jo zyl_rt_trap_ovf_0
    cmp r14, 16384
    jl .L360_1
    jmp .L360_4
.globl zyl_fnmap_put
zyl_fnmap_put:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rsi
.L361_0:
    mov r12, rdi
    cmp r12, 0
    je .L361_2
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, qword ptr [rsi+262144]
    cmp rax, 8192
    jl .L361_1
.L361_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L361_1:
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
    je .L361_4
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    je .L361_3
.L361_4:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L361_3:
    mov qword ptr [rsi+0], r12
    mov qword ptr [rsi+8], rbx
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    lea rax, [rip+zyl_rtg_fnmap]
    mov rdi, rax
    mov rdi, qword ptr [rdi+262144]
    add rdi, 1
    jo zyl_rt_trap_ovf_0
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
.L362_0:
    mov rbx, rdi
    cmp rbx, 0
    je .L362_2
    lea rax, [rip+zyl_rtg_fnmap]
    mov rsi, rax
    mov rax, qword ptr [rsi+262144]
    cmp rax, 0
    jne .L362_1
.L362_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L362_1:
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
    je .L362_4
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L362_3
.L362_4:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L362_3:
    mov rax, qword ptr [rsi+8]
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dmagic:
    # frame 0
.L363_0:
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
.L364_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L364_1
    mov rsi, rdi
.L364_1:
    mov r13, rsi
    cmp r13, 1048576
    jle .L364_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L364_2:
    mov rdi, r13
    add rdi, 3
    jo zyl_rt_trap_ovf_0
    imul rdi, rdi, 8
    jo zyl_rt_trap_ovf_2
    call zyl_heap_alloc
    mov rsi, rax
    cmp rsi, 0
    jne .L364_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L364_3:
    mov qword ptr [rsi+0], r12
    mov rdi, 1514885700
    shl rdi, 32
    mov r8, 4294967295
    and r8, rbx
    or rdi, r8
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], r13
    mov rax, rsi
    add rax, 24
    jo zyl_rt_trap_ovf_0
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
.L365_0:
    cmp rbx, 0
    jne .L365_1
.L365_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L365_1:
    mov rdi, rbx
    sub rdi, 16
    jo zyl_rt_trap_ovf_1
    call zyl_heap_block_p
    cmp rax, 0
    je .L365_2
    mov rsi, rbx
    sub rsi, 16
    jo zyl_rt_trap_ovf_1
    mov rsi, qword ptr [rsi+0]
    mov rax, rsi
    shr rax, 32
    cmp rax, 1514885700
    jne .L365_3
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L365_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L365_2:
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
.L366_0:
    cmp rbx, 0
    jl .L366_2
.L366_4:
    cmp rbx, 31
    jl .L366_1
.L366_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L366_1:
    call zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dword
    mov rsi, rax
    cmp rsi, 0
    jne .L366_3
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L366_3:
    imul rdi, rbx, 2
    jo zyl_rt_trap_ovf_2
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
.L367_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__interp__rt_x2Dkinds_x2Dword
    cmp rax, 0
    jne .L367_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L367_1:
    mov rsi, rbx
    sub rsi, 24
    jo zyl_rt_trap_ovf_1
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
.L368_0:
    cmp rbx, 0
    jne .L368_1
.L368_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L368_1:
    mov rdi, rbx
    sub rdi, 8
    jo zyl_rt_trap_ovf_1
    call zyl_heap_block_p
    cmp rax, 0
    je .L368_2
    mov rsi, rbx
    sub rsi, 8
    jo zyl_rt_trap_ovf_1
    mov rax, qword ptr [rsi+0]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L368_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__interp__rt_x2Dnames:
    # frame 0
.L369_0:
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
.L370_0:
    cmp r14, 4096
    jl .L370_1
.L370_4:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L370_1:
    mov rsi, r13
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    and rsi, 4095
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    mov r15, rbx
    add r15, rsi
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [r15+0]
    cmp rdi, 0
    je .L370_3
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L370_2
.L370_3:
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L370_2:
    add r14, 1
    jo zyl_rt_trap_ovf_0
    cmp r14, 4096
    jl .L370_1
    jmp .L370_4
.globl zyl_intern_name
zyl_intern_name:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L371_0:
    lea rax, [rip+zyl_rtg_names_lock]
    mov r12, rax
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L371_1
    mov rdi, rbx
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__interp__rt_x2Dintern
.L371_1:
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
.L372_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L372_1
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L372_1:
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
    jne .L372_2
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L372_2:
    mov rax, qword ptr [r13+0]
    cmp rax, 0
    je .L372_3
    mov rax, qword ptr [r13+0]
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L372_3:
    mov rax, qword ptr [r12+32768]
    cmp rax, 2048
    jl .L372_4
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L372_4:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    mov rdi, r14
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    jne .L372_5
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L372_5:
    mov rsi, r14
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, r15
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov qword ptr [r13+0], r15
    mov rsi, qword ptr [r12+32768]
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L373_0:
    lea rax, [rip+zyl_rtg_fresh_id]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rsi+0], rdi
    mov rax, rdi
    ret
.globl zyl_cstr_of_word
zyl_cstr_of_word:
    # frame 0
.L374_0:
    mov rax, rdi
    ret
.globl zyl_word_of_cstr
zyl_word_of_cstr:
    # frame 0
.L375_0:
    mov rax, rdi
    ret
.globl zyl_float_bits
zyl_float_bits:
    # frame 0
.L376_0:
    mov rax, rdi
    ret
.globl zyl_float_of_bits
zyl_float_of_bits:
    # frame 0
.L377_0:
    mov rax, rdi
    ret
.globl zyl_word_load
zyl_word_load:
    # frame 0
.L378_0:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_word_store
zyl_word_store:
    # frame 0
.L379_0:
    mov qword ptr [rdi+0], rsi
    mov rax, 0
    ret
.globl zyl_ptr_add
zyl_ptr_add:
    # frame 0
.L380_0:
    mov rax, rdi
    add rax, rsi
    jo zyl_rt_trap_ovf_0
    ret
.globl zyl_ptr_cstr
zyl_ptr_cstr:
    # frame 0
.L381_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dsize:
    # frame 0
.L382_0:
    mov rax, 2208
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dcompress:
    # frame 912
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
    mov qword ptr [rbp-80], r8
    mov r8, rdx
    mov qword ptr [rbp-48], r9
.L383_0:
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
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and rbx, r14
    mov rdx, qword ptr [rbp-64]
    mov r14d, dword ptr [rdx+0]
    add rbx, r14
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and rbx, r14
    xor rdi, rbx
    mov r14, rdi
    shr r14, 16
    shl rdi, 16
    mov r9, 4294967295
    and rdi, r9
    or r14, rdi
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rdi, 4294967295
    and rsi, rdi
    mov rdi, r15
    xor rdi, rsi
    mov r9, rdi
    shr r9, 12
    shl rdi, 20
    mov r15, 4294967295
    and rdi, r15
    or r9, rdi
    mov rdi, rbx
    add rdi, r9
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+4]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, r14
    xor rbx, rdi
    mov r14, rbx
    shr r14, 8
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    or r14, rbx
    mov rax, rsi
    mov rcx, r14
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-144], rax
    mov rbx, 4294967295
    mov rax, qword ptr [rbp-144]
    mov rcx, rbx
    and rax, rcx
    mov qword ptr [rbp-144], rax
    xor r9, qword ptr [rbp-144]
    mov rax, r9
    shr rax, 7
    mov qword ptr [rbp-128], rax
    shl r9, 25
    mov r15, 4294967295
    and r9, r15
    mov rax, qword ptr [rbp-128]
    mov rcx, r9
    or rax, rcx
    mov qword ptr [rbp-128], rax
    mov r9, r12
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and r9, r12
    mov rdx, qword ptr [rbp-64]
    mov r12d, dword ptr [rdx+8]
    add r9, r12
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and r9, r12
    xor r8, r9
    mov r12, r8
    shr r12, 16
    shl r8, 16
    mov r15, 4294967295
    and r8, r15
    or r12, r8
    mov r8, r10
    add r8, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r8, r10
    mov r10, r11
    xor r10, r8
    mov r11, r10
    shr r11, 12
    shl r10, 20
    mov r15, 4294967295
    and r10, r15
    or r11, r10
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+12]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov r10, r12
    xor r10, r9
    mov rax, r10
    shr rax, 8
    mov qword ptr [rbp-160], rax
    shl r10, 24
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-160]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-160], rax
    mov rax, r8
    mov rcx, qword ptr [rbp-160]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-136], rax
    mov r10, 4294967295
    mov rax, qword ptr [rbp-136]
    mov rcx, r10
    and rax, rcx
    mov qword ptr [rbp-136], rax
    mov r10, r11
    xor r10, qword ptr [rbp-136]
    mov r11, r10
    shr r11, 7
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    or r11, r10
    mov r10, r13
    add r10, qword ptr [rbp-104]
    jo zyl_rt_trap_ovf_0
    mov r13, 4294967295
    and r10, r13
    mov rdx, qword ptr [rbp-64]
    mov r13d, dword ptr [rdx+16]
    add r10, r13
    jo zyl_rt_trap_ovf_0
    mov r13, 4294967295
    and r10, r13
    mov r13, qword ptr [rbp-120]
    xor r13, r10
    mov r15, r13
    shr r15, 16
    shl r13, 16
    mov rbx, 4294967295
    and r13, rbx
    or r15, r13
    mov rbx, qword ptr [rbp-112]
    add rbx, r15
    jo zyl_rt_trap_ovf_0
    mov r13, 4294967295
    and rbx, r13
    mov r13, qword ptr [rbp-104]
    xor r13, rbx
    mov r8, r13
    shr r8, 12
    shl r13, 20
    mov rsi, 4294967295
    and r13, rsi
    or r8, r13
    mov rsi, r10
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+20]
    mov rax, rsi
    mov rcx, r10
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-168], rax
    mov r10, 4294967295
    mov rax, qword ptr [rbp-168]
    mov rcx, r10
    and rax, rcx
    mov qword ptr [rbp-168], rax
    mov r10, r15
    xor r10, qword ptr [rbp-168]
    mov rax, r10
    shr rax, 8
    mov qword ptr [rbp-152], rax
    shl r10, 24
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-152]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-152], rax
    mov r10, rbx
    add r10, qword ptr [rbp-152]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    xor r8, r10
    mov rax, r8
    shr rax, 7
    mov qword ptr [rbp-176], rax
    shl r8, 25
    mov r15, 4294967295
    and r8, r15
    mov rax, qword ptr [rbp-176]
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-176], rax
    mov r8, qword ptr [rbp-88]
    add r8, qword ptr [rbp-72]
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r8, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+24]
    add r8, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r8, r15
    mov r15, qword ptr [rbp-80]
    xor r15, r8
    mov r13, r15
    shr r13, 16
    shl r15, 16
    mov r12, 4294967295
    and r15, r12
    or r13, r15
    mov r12, qword ptr [rbp-96]
    add r12, r13
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r12, r15
    mov r15, qword ptr [rbp-72]
    xor r15, r12
    mov rsi, r15
    shr rsi, 12
    shl r15, 20
    mov rbx, 4294967295
    and r15, rbx
    or rsi, r15
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+28]
    add r8, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    mov rbx, r13
    xor rbx, r8
    mov r13, rbx
    shr r13, 8
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    or r13, rbx
    mov rbx, r12
    add rbx, r13
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rbx, r12
    xor rsi, rbx
    mov r12, rsi
    shr r12, 7
    shl rsi, 25
    mov r15, 4294967295
    and rsi, r15
    or r12, rsi
    mov rsi, rdi
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov rdi, 4294967295
    and rsi, rdi
    mov rdx, qword ptr [rbp-64]
    mov edi, dword ptr [rdx+32]
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rdi, 4294967295
    and rsi, rdi
    mov rdi, r13
    xor rdi, rsi
    mov r13, rdi
    shr r13, 16
    shl rdi, 16
    mov r15, 4294967295
    and rdi, r15
    or r13, rdi
    mov rdi, r10
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rdi, r10
    mov r10, r11
    xor r10, rdi
    mov r11, r10
    shr r11, 12
    shl r10, 20
    mov r15, 4294967295
    and r10, r15
    or r11, r10
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+36]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov rax, r10
    shr rax, 8
    mov qword ptr [rbp-184], rax
    shl r10, 24
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-184]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-184], rax
    mov rax, rdi
    mov rcx, qword ptr [rbp-184]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-208], rax
    mov r10, 4294967295
    mov rax, qword ptr [rbp-208]
    mov rcx, r10
    and rax, rcx
    mov qword ptr [rbp-208], rax
    mov r10, r11
    xor r10, qword ptr [rbp-208]
    mov rax, r10
    shr rax, 7
    mov qword ptr [rbp-232], rax
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-232]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-232], rax
    add r9, qword ptr [rbp-176]
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+40]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov r10, r14
    xor r10, r9
    mov r14, r10
    shr r14, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r14, r10
    mov r10, rbx
    add r10, r14
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    mov rbx, qword ptr [rbp-176]
    xor rbx, r10
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r13, 4294967295
    and rbx, r13
    or r15, rbx
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+44]
    add r9, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    mov rbx, r14
    xor rbx, r9
    mov r13, rbx
    shr r13, 8
    shl rbx, 24
    mov r14, 4294967295
    and rbx, r14
    or r13, rbx
    mov rax, r10
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-192], rax
    mov rbx, 4294967295
    mov rax, qword ptr [rbp-192]
    mov rcx, rbx
    and rax, rcx
    mov qword ptr [rbp-192], rax
    mov rbx, r15
    xor rbx, qword ptr [rbp-192]
    mov rax, rbx
    shr rax, 7
    mov qword ptr [rbp-200], rax
    shl rbx, 25
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-200]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-200], rax
    mov rbx, qword ptr [rbp-168]
    add rbx, r12
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and rbx, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+48]
    add rbx, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and rbx, r15
    mov r15, qword ptr [rbp-160]
    xor r15, rbx
    mov r10, r15
    shr r10, 16
    shl r15, 16
    mov r14, 4294967295
    and r15, r14
    or r10, r15
    mov r14, qword ptr [rbp-144]
    add r14, r10
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r14, r15
    xor r12, r14
    mov r15, r12
    shr r15, 12
    shl r12, 20
    mov rdi, 4294967295
    and r12, rdi
    or r15, r12
    mov rdi, rbx
    add rdi, r15
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+52]
    mov rax, rdi
    mov rcx, rbx
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-224], rax
    mov rbx, 4294967295
    mov rax, qword ptr [rbp-224]
    mov rcx, rbx
    and rax, rcx
    mov qword ptr [rbp-224], rax
    xor r10, qword ptr [rbp-224]
    mov rbx, r10
    shr rbx, 8
    shl r10, 24
    mov r12, 4294967295
    and r10, r12
    or rbx, r10
    mov r10, r14
    add r10, rbx
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and r10, r12
    mov r12, r15
    xor r12, r10
    mov rax, r12
    shr rax, 7
    mov qword ptr [rbp-216], rax
    shl r12, 25
    mov r15, 4294967295
    and r12, r15
    mov rax, qword ptr [rbp-216]
    mov rcx, r12
    or rax, rcx
    mov qword ptr [rbp-216], rax
    add r8, qword ptr [rbp-128]
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and r8, r12
    mov rdx, qword ptr [rbp-64]
    mov r12d, dword ptr [rdx+56]
    add r8, r12
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and r8, r12
    mov r12, qword ptr [rbp-152]
    xor r12, r8
    mov r15, r12
    shr r15, 16
    shl r12, 16
    mov r14, 4294967295
    and r12, r14
    or r15, r12
    mov r12, qword ptr [rbp-136]
    add r12, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r12, r14
    mov r14, qword ptr [rbp-128]
    xor r14, r12
    mov rdi, r14
    shr rdi, 12
    shl r14, 20
    mov r11, 4294967295
    and r14, r11
    or rdi, r14
    add r8, rdi
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r8, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+60]
    add r8, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r8, r11
    mov r11, r15
    xor r11, r8
    mov r14, r11
    shr r14, 8
    shl r11, 24
    mov r15, 4294967295
    and r11, r15
    or r14, r11
    mov r11, r12
    add r11, r14
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and r11, r12
    xor rdi, r11
    mov r12, rdi
    shr r12, 7
    shl rdi, 25
    mov r15, 4294967295
    and rdi, r15
    or r12, rdi
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, 4294967295
    and rsi, rdi
    mov rdx, qword ptr [rbp-64]
    mov edi, dword ptr [rdx+8]
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rdi, 4294967295
    and rsi, rdi
    mov rdi, r13
    xor rdi, rsi
    mov r13, rdi
    shr r13, 16
    shl rdi, 16
    mov r15, 4294967295
    and rdi, r15
    or r13, rdi
    mov rdi, r10
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rdi, r10
    mov r10, r12
    xor r10, rdi
    mov r12, r10
    shr r12, 12
    shl r10, 20
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+24]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 8
    shl r10, 24
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    mov rax, rdi
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-256], rax
    mov r10, 4294967295
    mov rax, qword ptr [rbp-256]
    mov rcx, r10
    and rax, rcx
    mov qword ptr [rbp-256], rax
    mov r10, r12
    xor r10, qword ptr [rbp-256]
    mov rax, r10
    shr rax, 7
    mov qword ptr [rbp-240], rax
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-240]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-240], rax
    add r9, qword ptr [rbp-232]
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+12]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov r10, rbx
    xor r10, r9
    mov rbx, r10
    shr rbx, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or rbx, r10
    mov r10, r11
    add r10, rbx
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov r11, qword ptr [rbp-232]
    xor r11, r10
    mov r15, r11
    shr r15, 12
    shl r11, 20
    mov r12, 4294967295
    and r11, r12
    or r15, r11
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+40]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, rbx
    xor r11, r9
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-264], rax
    shl r11, 24
    mov r12, 4294967295
    and r11, r12
    mov rax, qword ptr [rbp-264]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-264], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-264]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-248], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-248]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-248], rax
    mov r11, r15
    xor r11, qword ptr [rbp-248]
    mov r12, r11
    shr r12, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    mov r11, qword ptr [rbp-224]
    add r11, qword ptr [rbp-200]
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+28]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    xor r14, r11
    mov r15, r14
    shr r15, 16
    shl r14, 16
    mov r10, 4294967295
    and r14, r10
    or r15, r14
    mov r10, qword ptr [rbp-208]
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r10, r14
    mov r14, qword ptr [rbp-200]
    xor r14, r10
    mov rdi, r14
    shr rdi, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or rdi, r14
    add r11, rdi
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r11, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+0]
    mov rax, r11
    mov rcx, rbx
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-280], rax
    mov rbx, 4294967295
    mov rax, qword ptr [rbp-280]
    mov rcx, rbx
    and rax, rcx
    mov qword ptr [rbp-280], rax
    mov rbx, r15
    xor rbx, qword ptr [rbp-280]
    mov rax, rbx
    shr rax, 8
    mov qword ptr [rbp-272], rax
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-272]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-272], rax
    add r10, qword ptr [rbp-272]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    xor rdi, r10
    mov rax, rdi
    shr rax, 7
    mov qword ptr [rbp-288], rax
    shl rdi, 25
    mov r15, 4294967295
    and rdi, r15
    mov rax, qword ptr [rbp-288]
    mov rcx, rdi
    or rax, rcx
    mov qword ptr [rbp-288], rax
    mov rdi, r8
    add rdi, qword ptr [rbp-216]
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov rdx, qword ptr [rbp-64]
    mov r8d, dword ptr [rdx+16]
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov r8, qword ptr [rbp-184]
    xor r8, rdi
    mov r15, r8
    shr r15, 16
    shl r8, 16
    mov r14, 4294967295
    and r8, r14
    or r15, r8
    mov r8, qword ptr [rbp-192]
    add r8, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r8, r14
    mov r14, qword ptr [rbp-216]
    xor r14, r8
    mov r11, r14
    shr r11, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r11, r14
    add rdi, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+52]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, r15
    xor rbx, rdi
    mov r14, rbx
    shr r14, 8
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    or r14, rbx
    add r8, r14
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    xor r11, r8
    mov rbx, r11
    shr rbx, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or rbx, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+4]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov r14, r11
    shr r14, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r14, r11
    add r10, r14
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov r11, r12
    xor r11, r10
    mov r12, r11
    shr r12, 12
    shl r11, 20
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+44]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-296], rax
    shl r11, 24
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-296]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-296], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-296]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-320], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-320]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-320], rax
    mov r11, r12
    xor r11, qword ptr [rbp-320]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-344], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-344]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-344], rax
    add r9, qword ptr [rbp-288]
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+48]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r13, r11
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r8, r11
    mov r11, qword ptr [rbp-288]
    xor r11, r8
    mov r15, r11
    shr r15, 12
    shl r11, 20
    mov r14, 4294967295
    and r11, r14
    or r15, r11
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+20]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 8
    shl r11, 24
    mov r14, 4294967295
    and r11, r14
    or r13, r11
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-304], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-304]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-304], rax
    mov r11, r15
    xor r11, qword ptr [rbp-304]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-312], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-312]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-312], rax
    mov r11, qword ptr [rbp-280]
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+36]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov r15, qword ptr [rbp-264]
    xor r15, r11
    mov r8, r15
    shr r8, 16
    shl r15, 16
    mov r14, 4294967295
    and r15, r14
    or r8, r15
    mov r14, qword ptr [rbp-256]
    add r14, r8
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r14, r15
    xor rbx, r14
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r10, 4294967295
    and rbx, r10
    or r15, rbx
    mov r10, r11
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+56]
    mov rax, r10
    mov rcx, r11
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-336], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-336]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-336], rax
    xor r8, qword ptr [rbp-336]
    mov r11, r8
    shr r11, 8
    shl r8, 24
    mov rbx, 4294967295
    and r8, rbx
    or r11, r8
    mov r8, r14
    add r8, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    mov rbx, r15
    xor rbx, r8
    mov rax, rbx
    shr rax, 7
    mov qword ptr [rbp-328], rax
    shl rbx, 25
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-328]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-328], rax
    add rdi, qword ptr [rbp-240]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+60]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, qword ptr [rbp-272]
    xor rbx, rdi
    mov r15, rbx
    shr r15, 16
    shl rbx, 16
    mov r14, 4294967295
    and rbx, r14
    or r15, rbx
    mov rbx, qword ptr [rbp-248]
    add rbx, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and rbx, r14
    mov r14, qword ptr [rbp-240]
    xor r14, rbx
    mov r10, r14
    shr r10, 12
    shl r14, 20
    mov r12, 4294967295
    and r14, r12
    or r10, r14
    add rdi, r10
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov rdx, qword ptr [rbp-64]
    mov r12d, dword ptr [rdx+32]
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov r12, r15
    xor r12, rdi
    mov r14, r12
    shr r14, 8
    shl r12, 24
    mov r15, 4294967295
    and r12, r15
    or r14, r12
    add rbx, r14
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rbx, r12
    xor r10, rbx
    mov r12, r10
    shr r12, 7
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+12]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r8, r10
    mov r10, r12
    xor r10, r8
    mov r12, r10
    shr r12, 12
    shl r10, 20
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+16]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 8
    shl r10, 24
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-368], rax
    mov r10, 4294967295
    mov rax, qword ptr [rbp-368]
    mov rcx, r10
    and rax, rcx
    mov qword ptr [rbp-368], rax
    mov r10, r12
    xor r10, qword ptr [rbp-368]
    mov rax, r10
    shr rax, 7
    mov qword ptr [rbp-352], rax
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-352]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-352], rax
    add r9, qword ptr [rbp-344]
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+40]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov r10, r11
    xor r10, r9
    mov r11, r10
    shr r11, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r11, r10
    mov r10, rbx
    add r10, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    mov rbx, qword ptr [rbp-344]
    xor rbx, r10
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r12, 4294967295
    and rbx, r12
    or r15, rbx
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+48]
    add r9, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    xor r11, r9
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-376], rax
    shl r11, 24
    mov r12, 4294967295
    and r11, r12
    mov rax, qword ptr [rbp-376]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-376], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-376]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-360], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-360]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-360], rax
    mov r11, r15
    xor r11, qword ptr [rbp-360]
    mov r12, r11
    shr r12, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    mov r11, qword ptr [rbp-336]
    add r11, qword ptr [rbp-312]
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+52]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    xor r14, r11
    mov r15, r14
    shr r15, 16
    shl r14, 16
    mov r10, 4294967295
    and r14, r10
    or r15, r14
    mov r10, qword ptr [rbp-320]
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r10, r14
    mov r14, qword ptr [rbp-312]
    xor r14, r10
    mov r8, r14
    shr r8, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r8, r14
    add r11, r8
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r11, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+8]
    mov rax, r11
    mov rcx, rbx
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-392], rax
    mov rbx, 4294967295
    mov rax, qword ptr [rbp-392]
    mov rcx, rbx
    and rax, rcx
    mov qword ptr [rbp-392], rax
    mov rbx, r15
    xor rbx, qword ptr [rbp-392]
    mov rax, rbx
    shr rax, 8
    mov qword ptr [rbp-384], rax
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-384]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-384], rax
    add r10, qword ptr [rbp-384]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    xor r8, r10
    mov rax, r8
    shr rax, 7
    mov qword ptr [rbp-400], rax
    shl r8, 25
    mov r15, 4294967295
    and r8, r15
    mov rax, qword ptr [rbp-400]
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-400], rax
    add rdi, qword ptr [rbp-328]
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov rdx, qword ptr [rbp-64]
    mov r8d, dword ptr [rdx+28]
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov r8, qword ptr [rbp-296]
    xor r8, rdi
    mov r15, r8
    shr r15, 16
    shl r8, 16
    mov r14, 4294967295
    and r8, r14
    or r15, r8
    mov r8, qword ptr [rbp-304]
    add r8, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r8, r14
    mov r14, qword ptr [rbp-328]
    xor r14, r8
    mov r11, r14
    shr r11, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r11, r14
    add rdi, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+56]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, r15
    xor rbx, rdi
    mov r14, rbx
    shr r14, 8
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    or r14, rbx
    add r8, r14
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    xor r11, r8
    mov rbx, r11
    shr rbx, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or rbx, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+24]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov r14, r11
    shr r14, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r14, r11
    add r10, r14
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov r11, r12
    xor r11, r10
    mov r12, r11
    shr r12, 12
    shl r11, 20
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+20]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-408], rax
    shl r11, 24
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-408]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-408], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-408]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-432], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-432]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-432], rax
    mov r11, r12
    xor r11, qword ptr [rbp-432]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-456], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-456]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-456], rax
    add r9, qword ptr [rbp-400]
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+36]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r13, r11
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r8, r11
    mov r11, qword ptr [rbp-400]
    xor r11, r8
    mov r15, r11
    shr r15, 12
    shl r11, 20
    mov r14, 4294967295
    and r11, r14
    or r15, r11
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+0]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 8
    shl r11, 24
    mov r14, 4294967295
    and r11, r14
    or r13, r11
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-416], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-416]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-416], rax
    mov r11, r15
    xor r11, qword ptr [rbp-416]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-424], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-424]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-424], rax
    mov r11, qword ptr [rbp-392]
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+44]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov r15, qword ptr [rbp-376]
    xor r15, r11
    mov r8, r15
    shr r8, 16
    shl r15, 16
    mov r14, 4294967295
    and r15, r14
    or r8, r15
    mov r14, qword ptr [rbp-368]
    add r14, r8
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r14, r15
    xor rbx, r14
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r10, 4294967295
    and rbx, r10
    or r15, rbx
    mov r10, r11
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+60]
    mov rax, r10
    mov rcx, r11
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-448], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-448]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-448], rax
    xor r8, qword ptr [rbp-448]
    mov r11, r8
    shr r11, 8
    shl r8, 24
    mov rbx, 4294967295
    and r8, rbx
    or r11, r8
    mov r8, r14
    add r8, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    mov rbx, r15
    xor rbx, r8
    mov rax, rbx
    shr rax, 7
    mov qword ptr [rbp-440], rax
    shl rbx, 25
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-440]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-440], rax
    add rdi, qword ptr [rbp-352]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+32]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, qword ptr [rbp-384]
    xor rbx, rdi
    mov r15, rbx
    shr r15, 16
    shl rbx, 16
    mov r14, 4294967295
    and rbx, r14
    or r15, rbx
    mov rbx, qword ptr [rbp-360]
    add rbx, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and rbx, r14
    mov r14, qword ptr [rbp-352]
    xor r14, rbx
    mov r10, r14
    shr r10, 12
    shl r14, 20
    mov r12, 4294967295
    and r14, r12
    or r10, r14
    add rdi, r10
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov rdx, qword ptr [rbp-64]
    mov r12d, dword ptr [rdx+4]
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov r12, r15
    xor r12, rdi
    mov r14, r12
    shr r14, 8
    shl r12, 24
    mov r15, 4294967295
    and r12, r15
    or r14, r12
    add rbx, r14
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rbx, r12
    xor r10, rbx
    mov r12, r10
    shr r12, 7
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+40]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r8, r10
    mov r10, r12
    xor r10, r8
    mov r12, r10
    shr r12, 12
    shl r10, 20
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+28]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 8
    shl r10, 24
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-480], rax
    mov r10, 4294967295
    mov rax, qword ptr [rbp-480]
    mov rcx, r10
    and rax, rcx
    mov qword ptr [rbp-480], rax
    mov r10, r12
    xor r10, qword ptr [rbp-480]
    mov rax, r10
    shr rax, 7
    mov qword ptr [rbp-464], rax
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-464]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-464], rax
    add r9, qword ptr [rbp-456]
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+48]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov r10, r11
    xor r10, r9
    mov r11, r10
    shr r11, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r11, r10
    mov r10, rbx
    add r10, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    mov rbx, qword ptr [rbp-456]
    xor rbx, r10
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r12, 4294967295
    and rbx, r12
    or r15, rbx
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+36]
    add r9, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    xor r11, r9
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-488], rax
    shl r11, 24
    mov r12, 4294967295
    and r11, r12
    mov rax, qword ptr [rbp-488]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-488], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-488]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-472], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-472]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-472], rax
    mov r11, r15
    xor r11, qword ptr [rbp-472]
    mov r12, r11
    shr r12, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    mov r11, qword ptr [rbp-448]
    add r11, qword ptr [rbp-424]
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+56]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    xor r14, r11
    mov r15, r14
    shr r15, 16
    shl r14, 16
    mov r10, 4294967295
    and r14, r10
    or r15, r14
    mov r10, qword ptr [rbp-432]
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r10, r14
    mov r14, qword ptr [rbp-424]
    xor r14, r10
    mov r8, r14
    shr r8, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r8, r14
    add r11, r8
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r11, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+12]
    mov rax, r11
    mov rcx, rbx
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-504], rax
    mov rbx, 4294967295
    mov rax, qword ptr [rbp-504]
    mov rcx, rbx
    and rax, rcx
    mov qword ptr [rbp-504], rax
    mov rbx, r15
    xor rbx, qword ptr [rbp-504]
    mov rax, rbx
    shr rax, 8
    mov qword ptr [rbp-496], rax
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-496]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-496], rax
    add r10, qword ptr [rbp-496]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    xor r8, r10
    mov rax, r8
    shr rax, 7
    mov qword ptr [rbp-512], rax
    shl r8, 25
    mov r15, 4294967295
    and r8, r15
    mov rax, qword ptr [rbp-512]
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-512], rax
    add rdi, qword ptr [rbp-440]
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov rdx, qword ptr [rbp-64]
    mov r8d, dword ptr [rdx+52]
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov r8, qword ptr [rbp-408]
    xor r8, rdi
    mov r15, r8
    shr r15, 16
    shl r8, 16
    mov r14, 4294967295
    and r8, r14
    or r15, r8
    mov r8, qword ptr [rbp-416]
    add r8, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r8, r14
    mov r14, qword ptr [rbp-440]
    xor r14, r8
    mov r11, r14
    shr r11, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r11, r14
    add rdi, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+60]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, r15
    xor rbx, rdi
    mov r14, rbx
    shr r14, 8
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    or r14, rbx
    add r8, r14
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    xor r11, r8
    mov rbx, r11
    shr rbx, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or rbx, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+16]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov r14, r11
    shr r14, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r14, r11
    add r10, r14
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov r11, r12
    xor r11, r10
    mov r12, r11
    shr r12, 12
    shl r11, 20
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+0]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-520], rax
    shl r11, 24
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-520]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-520], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-520]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-544], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-544]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-544], rax
    mov r11, r12
    xor r11, qword ptr [rbp-544]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-568], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-568]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-568], rax
    add r9, qword ptr [rbp-512]
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+44]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r13, r11
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r8, r11
    mov r11, qword ptr [rbp-512]
    xor r11, r8
    mov r15, r11
    shr r15, 12
    shl r11, 20
    mov r14, 4294967295
    and r11, r14
    or r15, r11
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+8]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 8
    shl r11, 24
    mov r14, 4294967295
    and r11, r14
    or r13, r11
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-528], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-528]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-528], rax
    mov r11, r15
    xor r11, qword ptr [rbp-528]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-536], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-536]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-536], rax
    mov r11, qword ptr [rbp-504]
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+20]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov r15, qword ptr [rbp-488]
    xor r15, r11
    mov r8, r15
    shr r8, 16
    shl r15, 16
    mov r14, 4294967295
    and r15, r14
    or r8, r15
    mov r14, qword ptr [rbp-480]
    add r14, r8
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r14, r15
    xor rbx, r14
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r10, 4294967295
    and rbx, r10
    or r15, rbx
    mov r10, r11
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+32]
    mov rax, r10
    mov rcx, r11
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-560], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-560]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-560], rax
    xor r8, qword ptr [rbp-560]
    mov r11, r8
    shr r11, 8
    shl r8, 24
    mov rbx, 4294967295
    and r8, rbx
    or r11, r8
    mov r8, r14
    add r8, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    mov rbx, r15
    xor rbx, r8
    mov rax, rbx
    shr rax, 7
    mov qword ptr [rbp-552], rax
    shl rbx, 25
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-552]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-552], rax
    add rdi, qword ptr [rbp-464]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+4]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, qword ptr [rbp-496]
    xor rbx, rdi
    mov r15, rbx
    shr r15, 16
    shl rbx, 16
    mov r14, 4294967295
    and rbx, r14
    or r15, rbx
    mov rbx, qword ptr [rbp-472]
    add rbx, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and rbx, r14
    mov r14, qword ptr [rbp-464]
    xor r14, rbx
    mov r10, r14
    shr r10, 12
    shl r14, 20
    mov r12, 4294967295
    and r14, r12
    or r10, r14
    add rdi, r10
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov rdx, qword ptr [rbp-64]
    mov r12d, dword ptr [rdx+24]
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov r12, r15
    xor r12, rdi
    mov r14, r12
    shr r14, 8
    shl r12, 24
    mov r15, 4294967295
    and r12, r15
    or r14, r12
    add rbx, r14
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rbx, r12
    xor r10, rbx
    mov r12, r10
    shr r12, 7
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+48]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r8, r10
    mov r10, r12
    xor r10, r8
    mov r12, r10
    shr r12, 12
    shl r10, 20
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+52]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 8
    shl r10, 24
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-592], rax
    mov r10, 4294967295
    mov rax, qword ptr [rbp-592]
    mov rcx, r10
    and rax, rcx
    mov qword ptr [rbp-592], rax
    mov r10, r12
    xor r10, qword ptr [rbp-592]
    mov rax, r10
    shr rax, 7
    mov qword ptr [rbp-576], rax
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-576]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-576], rax
    add r9, qword ptr [rbp-568]
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+36]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov r10, r11
    xor r10, r9
    mov r11, r10
    shr r11, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r11, r10
    mov r10, rbx
    add r10, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    mov rbx, qword ptr [rbp-568]
    xor rbx, r10
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r12, 4294967295
    and rbx, r12
    or r15, rbx
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+44]
    add r9, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    xor r11, r9
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-600], rax
    shl r11, 24
    mov r12, 4294967295
    and r11, r12
    mov rax, qword ptr [rbp-600]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-600], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-600]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-584], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-584]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-584], rax
    mov r11, r15
    xor r11, qword ptr [rbp-584]
    mov r12, r11
    shr r12, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    mov r11, qword ptr [rbp-560]
    add r11, qword ptr [rbp-536]
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+60]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    xor r14, r11
    mov r15, r14
    shr r15, 16
    shl r14, 16
    mov r10, 4294967295
    and r14, r10
    or r15, r14
    mov r10, qword ptr [rbp-544]
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r10, r14
    mov r14, qword ptr [rbp-536]
    xor r14, r10
    mov r8, r14
    shr r8, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r8, r14
    add r11, r8
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r11, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+40]
    mov rax, r11
    mov rcx, rbx
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-616], rax
    mov rbx, 4294967295
    mov rax, qword ptr [rbp-616]
    mov rcx, rbx
    and rax, rcx
    mov qword ptr [rbp-616], rax
    mov rbx, r15
    xor rbx, qword ptr [rbp-616]
    mov rax, rbx
    shr rax, 8
    mov qword ptr [rbp-608], rax
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-608]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-608], rax
    add r10, qword ptr [rbp-608]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    xor r8, r10
    mov rax, r8
    shr rax, 7
    mov qword ptr [rbp-624], rax
    shl r8, 25
    mov r15, 4294967295
    and r8, r15
    mov rax, qword ptr [rbp-624]
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-624], rax
    add rdi, qword ptr [rbp-552]
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov rdx, qword ptr [rbp-64]
    mov r8d, dword ptr [rdx+56]
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov r8, qword ptr [rbp-520]
    xor r8, rdi
    mov r15, r8
    shr r15, 16
    shl r8, 16
    mov r14, 4294967295
    and r8, r14
    or r15, r8
    mov r8, qword ptr [rbp-528]
    add r8, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r8, r14
    mov r14, qword ptr [rbp-552]
    xor r14, r8
    mov r11, r14
    shr r11, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r11, r14
    add rdi, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+32]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, r15
    xor rbx, rdi
    mov r14, rbx
    shr r14, 8
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    or r14, rbx
    add r8, r14
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    xor r11, r8
    mov rbx, r11
    shr rbx, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or rbx, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+28]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov r14, r11
    shr r14, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r14, r11
    add r10, r14
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov r11, r12
    xor r11, r10
    mov r12, r11
    shr r12, 12
    shl r11, 20
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+8]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-632], rax
    shl r11, 24
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-632]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-632], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-632]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-656], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-656]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-656], rax
    mov r11, r12
    xor r11, qword ptr [rbp-656]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-680], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-680]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-680], rax
    add r9, qword ptr [rbp-624]
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+20]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r13, r11
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r8, r11
    mov r11, qword ptr [rbp-624]
    xor r11, r8
    mov r15, r11
    shr r15, 12
    shl r11, 20
    mov r14, 4294967295
    and r11, r14
    or r15, r11
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+12]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 8
    shl r11, 24
    mov r14, 4294967295
    and r11, r14
    or r13, r11
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-640], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-640]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-640], rax
    mov r11, r15
    xor r11, qword ptr [rbp-640]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-648], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-648]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-648], rax
    mov r11, qword ptr [rbp-616]
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+0]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov r15, qword ptr [rbp-600]
    xor r15, r11
    mov r8, r15
    shr r8, 16
    shl r15, 16
    mov r14, 4294967295
    and r15, r14
    or r8, r15
    mov r14, qword ptr [rbp-592]
    add r14, r8
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r14, r15
    xor rbx, r14
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r10, 4294967295
    and rbx, r10
    or r15, rbx
    mov r10, r11
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+4]
    mov rax, r10
    mov rcx, r11
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-672], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-672]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-672], rax
    xor r8, qword ptr [rbp-672]
    mov r11, r8
    shr r11, 8
    shl r8, 24
    mov rbx, 4294967295
    and r8, rbx
    or r11, r8
    mov r8, r14
    add r8, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    mov rbx, r15
    xor rbx, r8
    mov rax, rbx
    shr rax, 7
    mov qword ptr [rbp-664], rax
    shl rbx, 25
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-664]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-664], rax
    add rdi, qword ptr [rbp-576]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+24]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, qword ptr [rbp-608]
    xor rbx, rdi
    mov r15, rbx
    shr r15, 16
    shl rbx, 16
    mov r14, 4294967295
    and rbx, r14
    or r15, rbx
    mov rbx, qword ptr [rbp-584]
    add rbx, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and rbx, r14
    mov r14, qword ptr [rbp-576]
    xor r14, rbx
    mov r10, r14
    shr r10, 12
    shl r14, 20
    mov r12, 4294967295
    and r14, r12
    or r10, r14
    add rdi, r10
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov rdx, qword ptr [rbp-64]
    mov r12d, dword ptr [rdx+16]
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov r12, r15
    xor r12, rdi
    mov r14, r12
    shr r14, 8
    shl r12, 24
    mov r15, 4294967295
    and r12, r15
    or r14, r12
    add rbx, r14
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rbx, r12
    xor r10, rbx
    mov r12, r10
    shr r12, 7
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+36]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r8, r10
    mov r10, r12
    xor r10, r8
    mov r12, r10
    shr r12, 12
    shl r10, 20
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+56]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 8
    shl r10, 24
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-704], rax
    mov r10, 4294967295
    mov rax, qword ptr [rbp-704]
    mov rcx, r10
    and rax, rcx
    mov qword ptr [rbp-704], rax
    mov r10, r12
    xor r10, qword ptr [rbp-704]
    mov rax, r10
    shr rax, 7
    mov qword ptr [rbp-688], rax
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-688]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-688], rax
    add r9, qword ptr [rbp-680]
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+44]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov r10, r11
    xor r10, r9
    mov r11, r10
    shr r11, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r11, r10
    mov r10, rbx
    add r10, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    mov rbx, qword ptr [rbp-680]
    xor rbx, r10
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r12, 4294967295
    and rbx, r12
    or r15, rbx
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+20]
    add r9, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    xor r11, r9
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-712], rax
    shl r11, 24
    mov r12, 4294967295
    and r11, r12
    mov rax, qword ptr [rbp-712]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-712], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-712]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-696], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-696]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-696], rax
    mov r11, r15
    xor r11, qword ptr [rbp-696]
    mov r12, r11
    shr r12, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    mov r11, qword ptr [rbp-672]
    add r11, qword ptr [rbp-648]
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+32]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    xor r14, r11
    mov r15, r14
    shr r15, 16
    shl r14, 16
    mov r10, 4294967295
    and r14, r10
    or r15, r14
    mov r10, qword ptr [rbp-656]
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r10, r14
    mov r14, qword ptr [rbp-648]
    xor r14, r10
    mov r8, r14
    shr r8, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r8, r14
    add r11, r8
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r11, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+48]
    mov rax, r11
    mov rcx, rbx
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-728], rax
    mov rbx, 4294967295
    mov rax, qword ptr [rbp-728]
    mov rcx, rbx
    and rax, rcx
    mov qword ptr [rbp-728], rax
    mov rbx, r15
    xor rbx, qword ptr [rbp-728]
    mov rax, rbx
    shr rax, 8
    mov qword ptr [rbp-720], rax
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-720]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-720], rax
    add r10, qword ptr [rbp-720]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    xor r8, r10
    mov rax, r8
    shr rax, 7
    mov qword ptr [rbp-736], rax
    shl r8, 25
    mov r15, 4294967295
    and r8, r15
    mov rax, qword ptr [rbp-736]
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-736], rax
    add rdi, qword ptr [rbp-664]
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov rdx, qword ptr [rbp-64]
    mov r8d, dword ptr [rdx+60]
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov r8, qword ptr [rbp-632]
    xor r8, rdi
    mov r15, r8
    shr r15, 16
    shl r8, 16
    mov r14, 4294967295
    and r8, r14
    or r15, r8
    mov r8, qword ptr [rbp-640]
    add r8, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r8, r14
    mov r14, qword ptr [rbp-664]
    xor r14, r8
    mov r11, r14
    shr r11, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r11, r14
    add rdi, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+4]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, r15
    xor rbx, rdi
    mov r14, rbx
    shr r14, 8
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    or r14, rbx
    add r8, r14
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    xor r11, r8
    mov rbx, r11
    shr rbx, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or rbx, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+52]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov r14, r11
    shr r14, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r14, r11
    add r10, r14
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov r11, r12
    xor r11, r10
    mov r12, r11
    shr r12, 12
    shl r11, 20
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+12]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-744], rax
    shl r11, 24
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-744]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-744], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-744]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-768], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-768]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-768], rax
    mov r11, r12
    xor r11, qword ptr [rbp-768]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-792], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-792]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-792], rax
    add r9, qword ptr [rbp-736]
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+0]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r13, r11
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r8, r11
    mov r11, qword ptr [rbp-736]
    xor r11, r8
    mov r15, r11
    shr r15, 12
    shl r11, 20
    mov r14, 4294967295
    and r11, r14
    or r15, r11
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+40]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 8
    shl r11, 24
    mov r14, 4294967295
    and r11, r14
    or r13, r11
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-752], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-752]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-752], rax
    mov r11, r15
    xor r11, qword ptr [rbp-752]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-760], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-760]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-760], rax
    mov r11, qword ptr [rbp-728]
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+8]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov r15, qword ptr [rbp-712]
    xor r15, r11
    mov r8, r15
    shr r8, 16
    shl r15, 16
    mov r14, 4294967295
    and r15, r14
    or r8, r15
    mov r14, qword ptr [rbp-704]
    add r14, r8
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r14, r15
    xor rbx, r14
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r10, 4294967295
    and rbx, r10
    or r15, rbx
    mov r10, r11
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+24]
    mov rax, r10
    mov rcx, r11
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-784], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-784]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-784], rax
    xor r8, qword ptr [rbp-784]
    mov r11, r8
    shr r11, 8
    shl r8, 24
    mov rbx, 4294967295
    and r8, rbx
    or r11, r8
    mov r8, r14
    add r8, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    mov rbx, r15
    xor rbx, r8
    mov rax, rbx
    shr rax, 7
    mov qword ptr [rbp-776], rax
    shl rbx, 25
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-776]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-776], rax
    add rdi, qword ptr [rbp-688]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+16]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, qword ptr [rbp-720]
    xor rbx, rdi
    mov r15, rbx
    shr r15, 16
    shl rbx, 16
    mov r14, 4294967295
    and rbx, r14
    or r15, rbx
    mov rbx, qword ptr [rbp-696]
    add rbx, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and rbx, r14
    mov r14, qword ptr [rbp-688]
    xor r14, rbx
    mov r10, r14
    shr r10, 12
    shl r14, 20
    mov r12, 4294967295
    and r14, r12
    or r10, r14
    add rdi, r10
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov rdx, qword ptr [rbp-64]
    mov r12d, dword ptr [rdx+28]
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov r12, r15
    xor r12, rdi
    mov r14, r12
    shr r14, 8
    shl r12, 24
    mov r15, 4294967295
    and r12, r15
    or r14, r12
    add rbx, r14
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rbx, r12
    xor r10, rbx
    mov r12, r10
    shr r12, 7
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+44]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r8, r10
    mov r10, r12
    xor r10, r8
    mov r12, r10
    shr r12, 12
    shl r10, 20
    mov r15, 4294967295
    and r10, r15
    or r12, r10
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+60]
    add rsi, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and rsi, r10
    mov r10, r13
    xor r10, rsi
    mov r13, r10
    shr r13, 8
    shl r10, 24
    mov r15, 4294967295
    and r10, r15
    or r13, r10
    mov rax, r8
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-816], rax
    mov r10, 4294967295
    mov rax, qword ptr [rbp-816]
    mov rcx, r10
    and rax, rcx
    mov qword ptr [rbp-816], rax
    mov r10, r12
    xor r10, qword ptr [rbp-816]
    mov rax, r10
    shr rax, 7
    mov qword ptr [rbp-800], rax
    shl r10, 25
    mov r15, 4294967295
    and r10, r15
    mov rax, qword ptr [rbp-800]
    mov rcx, r10
    or rax, rcx
    mov qword ptr [rbp-800], rax
    add r9, qword ptr [rbp-792]
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov rdx, qword ptr [rbp-64]
    mov r10d, dword ptr [rdx+20]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, 4294967295
    and r9, r10
    mov r10, r11
    xor r10, r9
    mov r11, r10
    shr r11, 16
    shl r10, 16
    mov r15, 4294967295
    and r10, r15
    or r11, r10
    mov r10, rbx
    add r10, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    mov rbx, qword ptr [rbp-792]
    xor rbx, r10
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r12, 4294967295
    and rbx, r12
    or r15, rbx
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+0]
    add r9, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r9, rbx
    xor r11, r9
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-824], rax
    shl r11, 24
    mov r12, 4294967295
    and r11, r12
    mov rax, qword ptr [rbp-824]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-824], rax
    mov rax, r10
    mov rcx, qword ptr [rbp-824]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-808], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-808]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-808], rax
    mov r11, r15
    xor r11, qword ptr [rbp-808]
    mov r12, r11
    shr r12, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    mov r11, qword ptr [rbp-784]
    add r11, qword ptr [rbp-760]
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+4]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    xor r14, r11
    mov r15, r14
    shr r15, 16
    shl r14, 16
    mov r10, 4294967295
    and r14, r10
    or r15, r14
    mov r10, qword ptr [rbp-768]
    add r10, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r10, r14
    mov r14, qword ptr [rbp-760]
    xor r14, r10
    mov r8, r14
    shr r8, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r8, r14
    add r11, r8
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r11, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+36]
    mov rax, r11
    mov rcx, rbx
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-840], rax
    mov rbx, 4294967295
    mov rax, qword ptr [rbp-840]
    mov rcx, rbx
    and rax, rcx
    mov qword ptr [rbp-840], rax
    mov rbx, r15
    xor rbx, qword ptr [rbp-840]
    mov rax, rbx
    shr rax, 8
    mov qword ptr [rbp-832], rax
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    mov rax, qword ptr [rbp-832]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-832], rax
    add r10, qword ptr [rbp-832]
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r10, rbx
    xor r8, r10
    mov rax, r8
    shr rax, 7
    mov qword ptr [rbp-848], rax
    shl r8, 25
    mov r15, 4294967295
    and r8, r15
    mov rax, qword ptr [rbp-848]
    mov rcx, r8
    or rax, rcx
    mov qword ptr [rbp-848], rax
    add rdi, qword ptr [rbp-776]
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov rdx, qword ptr [rbp-64]
    mov r8d, dword ptr [rdx+32]
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov r8, qword ptr [rbp-744]
    xor r8, rdi
    mov r15, r8
    shr r15, 16
    shl r8, 16
    mov r14, 4294967295
    and r8, r14
    or r15, r8
    mov r8, qword ptr [rbp-752]
    add r8, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r8, r14
    mov r14, qword ptr [rbp-776]
    xor r14, r8
    mov r11, r14
    shr r11, 12
    shl r14, 20
    mov rbx, 4294967295
    and r14, rbx
    or r11, r14
    add rdi, r11
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+24]
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and rdi, rbx
    mov rbx, r15
    xor rbx, rdi
    mov r14, rbx
    shr r14, 8
    shl rbx, 24
    mov r15, 4294967295
    and rbx, r15
    or r14, rbx
    add r8, r14
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r8, rbx
    xor r11, r8
    mov rbx, r11
    shr rbx, 7
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    or rbx, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+56]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov r14, r11
    shr r14, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r14, r11
    add r10, r14
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov r11, r12
    xor r11, r10
    mov r12, r11
    shr r12, 12
    shl r11, 20
    mov r15, 4294967295
    and r11, r15
    or r12, r11
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+40]
    add rsi, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and rsi, r11
    mov r11, r14
    xor r11, rsi
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-856], rax
    shl r11, 24
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-856]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-856], rax
    add r10, qword ptr [rbp-856]
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r10, r11
    mov r11, r12
    xor r11, r10
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-872], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-872]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-872], rax
    add r9, qword ptr [rbp-848]
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+8]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov r13, r11
    shr r13, 16
    shl r11, 16
    mov r15, 4294967295
    and r11, r15
    or r13, r11
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r8, r11
    mov r11, qword ptr [rbp-848]
    xor r11, r8
    mov r15, r11
    shr r15, 12
    shl r11, 20
    mov r14, 4294967295
    and r11, r14
    or r15, r11
    add r9, r15
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov rdx, qword ptr [rbp-64]
    mov r11d, dword ptr [rdx+48]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r11, 4294967295
    and r9, r11
    mov r11, r13
    xor r11, r9
    mov rax, r11
    shr rax, 8
    mov qword ptr [rbp-880], rax
    shl r11, 24
    mov r14, 4294967295
    and r11, r14
    mov rax, qword ptr [rbp-880]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-880], rax
    mov rax, r8
    mov rcx, qword ptr [rbp-880]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-904], rax
    mov r11, 4294967295
    mov rax, qword ptr [rbp-904]
    mov rcx, r11
    and rax, rcx
    mov qword ptr [rbp-904], rax
    mov r11, r15
    xor r11, qword ptr [rbp-904]
    mov rax, r11
    shr rax, 7
    mov qword ptr [rbp-864], rax
    shl r11, 25
    mov r15, 4294967295
    and r11, r15
    mov rax, qword ptr [rbp-864]
    mov rcx, r11
    or rax, rcx
    mov qword ptr [rbp-864], rax
    mov r11, qword ptr [rbp-840]
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov rdx, qword ptr [rbp-64]
    mov r15d, dword ptr [rdx+12]
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r11, r15
    mov r15, qword ptr [rbp-824]
    xor r15, r11
    mov r14, r15
    shr r14, 16
    shl r15, 16
    mov r12, 4294967295
    and r15, r12
    or r14, r15
    mov r12, qword ptr [rbp-816]
    add r12, r14
    jo zyl_rt_trap_ovf_0
    mov r15, 4294967295
    and r12, r15
    xor rbx, r12
    mov r15, rbx
    shr r15, 12
    shl rbx, 20
    mov r13, 4294967295
    and rbx, r13
    or r15, rbx
    add r11, r15
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r11, rbx
    mov rdx, qword ptr [rbp-64]
    mov ebx, dword ptr [rdx+16]
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    mov rbx, 4294967295
    and r11, rbx
    mov rbx, r14
    xor rbx, r11
    mov rax, rbx
    shr rax, 8
    mov qword ptr [rbp-896], rax
    shl rbx, 24
    mov r14, 4294967295
    and rbx, r14
    mov rax, qword ptr [rbp-896]
    mov rcx, rbx
    or rax, rcx
    mov qword ptr [rbp-896], rax
    mov rbx, r12
    add rbx, qword ptr [rbp-896]
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rbx, r12
    mov r12, r15
    xor r12, rbx
    mov rax, r12
    shr rax, 7
    mov qword ptr [rbp-888], rax
    shl r12, 25
    mov r15, 4294967295
    and r12, r15
    mov rax, qword ptr [rbp-888]
    mov rcx, r12
    or rax, rcx
    mov qword ptr [rbp-888], rax
    add rdi, qword ptr [rbp-800]
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov rdx, qword ptr [rbp-64]
    mov r12d, dword ptr [rdx+28]
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and rdi, r12
    mov r12, qword ptr [rbp-832]
    xor r12, rdi
    mov r15, r12
    shr r15, 16
    shl r12, 16
    mov r14, 4294967295
    and r12, r14
    or r15, r12
    mov r12, qword ptr [rbp-808]
    add r12, r15
    jo zyl_rt_trap_ovf_0
    mov r14, 4294967295
    and r12, r14
    mov r14, qword ptr [rbp-800]
    xor r14, r12
    mov r13, r14
    shr r13, 12
    shl r14, 20
    mov r8, 4294967295
    and r14, r8
    or r13, r14
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov rdx, qword ptr [rbp-64]
    mov r8d, dword ptr [rdx+52]
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, 4294967295
    and rdi, r8
    mov r8, r15
    xor r8, rdi
    mov r14, r8
    shr r14, 8
    shl r8, 24
    mov r15, 4294967295
    and r8, r15
    or r14, r8
    mov r8, r12
    add r8, r14
    jo zyl_rt_trap_ovf_0
    mov r12, 4294967295
    and r8, r12
    mov r12, r13
    xor r12, r8
    mov r13, r12
    shr r13, 7
    shl r12, 25
    mov r15, 4294967295
    and r12, r15
    or r13, r12
    mov rdx, qword ptr [rbp-56]
    mov r12d, dword ptr [rdx+0]
    xor r12, rbx
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+32], r12d
    mov rdx, qword ptr [rbp-56]
    mov r12d, dword ptr [rdx+4]
    xor r12, r8
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+36], r12d
    mov rdx, qword ptr [rbp-56]
    mov r12d, dword ptr [rdx+8]
    xor r12, r10
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+40], r12d
    mov rdx, qword ptr [rbp-56]
    mov r12d, dword ptr [rdx+12]
    xor r12, qword ptr [rbp-904]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+44], r12d
    mov rdx, qword ptr [rbp-56]
    mov r12d, dword ptr [rdx+16]
    xor r12, qword ptr [rbp-880]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+48], r12d
    mov rdx, qword ptr [rbp-56]
    mov r12d, dword ptr [rdx+20]
    xor r12, qword ptr [rbp-896]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+52], r12d
    mov rdx, qword ptr [rbp-56]
    mov r12d, dword ptr [rdx+24]
    xor r12, r14
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+56], r12d
    mov rdx, qword ptr [rbp-56]
    mov r12d, dword ptr [rdx+28]
    xor r12, qword ptr [rbp-856]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+60], r12d
    xor rsi, rbx
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+0], esi
    mov rsi, r9
    xor rsi, r8
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+4], esi
    mov rsi, r11
    xor rsi, r10
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+8], esi
    mov rsi, rdi
    xor rsi, qword ptr [rbp-904]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+12], esi
    mov rsi, r13
    xor rsi, qword ptr [rbp-880]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+16], esi
    mov rsi, qword ptr [rbp-872]
    xor rsi, qword ptr [rbp-896]
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+20], esi
    mov rsi, qword ptr [rbp-864]
    xor rsi, r14
    mov rdx, qword ptr [rbp-48]
    mov dword ptr [rdx+24], esi
    mov rsi, qword ptr [rbp-888]
    xor rsi, qword ptr [rbp-856]
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
.L384_0:
    cmp rsi, 64
    jl .L384_1
.L384_2:
    mov rax, rdi
    ret
.p2align 4
.L384_1:
    mov r8, rdi
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    mov r9, 0
    mov qword ptr [r8+0], r9
    add rsi, 8
    jo zyl_rt_trap_ovf_0
    cmp rsi, 64
    jl .L384_1
    jmp .L384_2
zy_local_x2Fmain_0__blake3__b3_x2Dinit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L385_0:
    mov rsi, 0
    mov qword ptr [rbx+1728], rsi
    mov rsi, 0
    mov qword ptr [rbx+1768], rsi
    mov rsi, 0
    mov qword ptr [rbx+1840], rsi
    mov rsi, 0
    mov qword ptr [rbx+1848], rsi
    mov rdi, rbx
    add rdi, 1776
    jo zyl_rt_trap_ovf_0
    mov rsi, 0
    call zy_local_x2Fmain_0__blake3__b3_x2Dzero64
    mov rsi, rbx
    add rsi, 2016
    jo zyl_rt_trap_ovf_0
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
    mov rdi, rbx
    add rdi, 1736
    jo zyl_rt_trap_ovf_0
    mov r8, 32
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rax, rbx
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag:
    # frame 0
.L386_0:
    mov rax, qword ptr [rdi+1848]
    cmp rax, 0
    jne .L386_1
    mov rax, 1
    ret
.L386_1:
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
.L387_0:
    mov r14, qword ptr [rbx+1728]
    mov rax, r13
    and rax, 1
    cmp rax, 0
    jne .L387_1
    cmp r14, 0
    jle .L387_1
    mov r15, rbx
    add r15, 1920
    jo zyl_rt_trap_ovf_0
    mov rsi, r14
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    imul rsi, rsi, 32
    jo zyl_rt_trap_ovf_2
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    mov rdi, 32
    mov rdx, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdi, r15
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    mov rsi, 32
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r14
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    mov qword ptr [rbx+1728], rsi
    mov rdi, rbx
    add rdi, 2016
    jo zyl_rt_trap_ovf_0
    mov rsi, 0
    mov r8, 64
    mov r9, 4
    mov r10, rbx
    add r10, 1856
    jo zyl_rt_trap_ovf_0
    mov rdx, rsi
    mov rsi, r15
    mov rcx, r8
    mov r8, r9
    mov r9, r10
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov r12, rbx
    add r12, 1856
    jo zyl_rt_trap_ovf_0
    shr r13, 1
    jmp .L387_0
.L387_1:
    imul rsi, r14, 32
    jo zyl_rt_trap_ovf_2
    mov rdi, rbx
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, 32
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r14
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L388_0:
    mov r12, qword ptr [rbx+1768]
    mov rax, qword ptr [rbx+1848]
    cmp rax, 15
    jne .L388_1
    mov r13, rbx
    add r13, 1736
    jo zyl_rt_trap_ovf_0
    mov r14, rbx
    add r14, 1776
    jo zyl_rt_trap_ovf_0
    mov r15, 64
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag
    mov r8, rax
    or r8, 2
    mov r9, rbx
    add r9, 1856
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    mov rsi, r14
    mov rdx, r12
    mov rcx, r15
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov rsi, rbx
    add rsi, 1856
    jo zyl_rt_trap_ovf_0
    mov rdi, r12
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dpush_x2Dcv
    mov rsi, r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+1768], rsi
    mov rdi, rbx
    add rdi, 1736
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    add rsi, 2016
    jo zyl_rt_trap_ovf_0
    mov r8, 32
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, 0
    mov qword ptr [rbx+1848], rsi
    jmp .L388_2
.L388_1:
    mov r13, rbx
    add r13, 1736
    jo zyl_rt_trap_ovf_0
    mov r14, rbx
    add r14, 1776
    jo zyl_rt_trap_ovf_0
    mov r15, 64
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dstart_x2Dflag
    mov r8, rax
    mov r9, rbx
    add r9, 1856
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    mov rsi, r14
    mov rdx, r12
    mov rcx, r15
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov rdi, rbx
    add rdi, 1736
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    add rsi, 1856
    jo zyl_rt_trap_ovf_0
    mov r8, 32
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, qword ptr [rbx+1848]
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+1848], rsi
.L388_2:
    mov rsi, 0
    mov qword ptr [rbx+1840], rsi
    mov rdi, rbx
    add rdi, 1776
    jo zyl_rt_trap_ovf_0
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
.L389_0:
    cmp r13, 0
    jg .L389_1
.L389_6:
    mov rax, rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L389_1:
    mov rax, qword ptr [rbx+1840]
    cmp rax, 64
    jne .L389_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__blake3__b3_x2Dflush
    jmp .L389_3
.L389_2:
.L389_3:
    mov r14, qword ptr [rbx+1840]
    mov rsi, 64
    sub rsi, r14
    jo zyl_rt_trap_ovf_1
    cmp rsi, r13
    jle .L389_4
    mov rsi, r13
    jmp .L389_5
.L389_4:
    mov rsi, 64
    sub rsi, r14
    jo zyl_rt_trap_ovf_1
.L389_5:
    mov r15, rsi
    mov rdi, rbx
    add rdi, 1776
    jo zyl_rt_trap_ovf_0
    add rdi, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    mov rdx, r15
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r14
    add rsi, r15
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+1840], rsi
    add r12, r15
    jo zyl_rt_trap_ovf_0
    sub r13, r15
    jo zyl_rt_trap_ovf_1
    cmp r13, 0
    jg .L389_1
    jmp .L389_6
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
.L390_0:
    cmp r12, 0
    jne .L390_1
.L390_3:
    mov r9, 0
    mov r10, r8
    or r10, 8
    mov r11, 0
    cmp r11, r13
    jl .L390_2
    mov rax, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L390_2:
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
.L390_1:
    mov r14, rbx
    add r14, 2080
    jo zyl_rt_trap_ovf_0
    mov r9, rbx
    add r9, 2048
    jo zyl_rt_trap_ovf_0
    mov r10, rbx
    add r10, 1856
    jo zyl_rt_trap_ovf_0
    mov rdx, rsi
    mov rsi, r14
    mov rcx, rdi
    mov rdi, r9
    mov r9, r10
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov r9, r12
    sub r9, 1
    jo zyl_rt_trap_ovf_1
    imul r9, r9, 32
    jo zyl_rt_trap_ovf_2
    add r9, rbx
    jo zyl_rt_trap_ovf_0
    mov r10, 32
    mov rdi, r14
    mov rsi, r9
    mov rdx, r10
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov r9, r14
    add r9, 32
    jo zyl_rt_trap_ovf_0
    mov r10, rbx
    add r10, 1856
    jo zyl_rt_trap_ovf_0
    mov r11, 32
    mov rdi, r9
    mov rsi, r10
    mov rdx, r11
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov r9, rbx
    add r9, 2048
    jo zyl_rt_trap_ovf_0
    mov r10, rbx
    add r10, 2016
    jo zyl_rt_trap_ovf_0
    mov r11, 32
    mov rdi, r9
    mov rsi, r10
    mov rdx, r11
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    sub r12, 1
    jo zyl_rt_trap_ovf_1
    mov rsi, 0
    mov rdi, 64
    mov r8, 4
    cmp r12, 0
    jne .L390_1
    jmp .L390_3
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
.L391_0:
    cmp r15, rbx
    jl .L391_1
.L391_4:
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
.L391_1:
    mov rdi, qword ptr [rbp-48]
    add rdi, 2048
    jo zyl_rt_trap_ovf_0
    mov rsi, qword ptr [rbp-48]
    add rsi, 2080
    jo zyl_rt_trap_ovf_0
    mov r9, qword ptr [rbp-48]
    add r9, 1856
    jo zyl_rt_trap_ovf_0
    mov rdx, qword ptr [rbp-56]
    mov rcx, r13
    mov r8, r14
    call zy_local_x2Fmain_0__blake3__b3_x2Dcompress
    mov rax, rbx
    sub rax, r15
    jo zyl_rt_trap_ovf_1
    cmp rax, 64
    jle .L391_2
    mov rsi, 64
    jmp .L391_3
.L391_2:
    mov rsi, rbx
    sub rsi, r15
    jo zyl_rt_trap_ovf_1
.L391_3:
    mov r12, rsi
    mov rdi, qword ptr [rbp-48]
    add rdi, 2144
    jo zyl_rt_trap_ovf_0
    add rdi, r15
    jo zyl_rt_trap_ovf_0
    mov rsi, qword ptr [rbp-48]
    add rsi, 1856
    jo zyl_rt_trap_ovf_0
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rax, qword ptr [rbp-56]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-56], rax
    add r15, r12
    jo zyl_rt_trap_ovf_0
    cmp r15, rbx
    jl .L391_1
    jmp .L391_4
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
.L392_0:
    mov rdi, rbx
    add rdi, 2048
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    add rsi, 1736
    jo zyl_rt_trap_ovf_0
    mov r8, 32
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdi, rbx
    add rdi, 2080
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    add rsi, 1776
    jo zyl_rt_trap_ovf_0
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
.L393_0:
    mov rdi, 2208
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rdi, rax
    cmp rdi, 0
    jne .L393_1
    mov rax, 0
    pop rbp
    ret
.L393_1:
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
.L394_0:
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r15, rax
    cmp r15, 0
    jne .L394_1
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L394_1:
    mov rdi, r15
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__blake3__b3_x2Dupdate
    mov rdi, r15
    mov rsi, r14
    call zy_local_x2Fmain_0__blake3__b3_x2Dfinalize
    mov rsi, r15
    add rsi, 2144
    jo zyl_rt_trap_ovf_0
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
.L395_0:
    lea rax, [rip+.L396]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__blake3__rt_x2Dhex_x2Dbytes:
    # frame 16
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L397_0:
    cmp r8, r9
    jl .L397_1
.L397_2:
    mov rax, rdi
    pop r12
    pop rbx
    ret
.p2align 4
.L397_1:
    mov r10, rsi
    add r10, r8
    jo zyl_rt_trap_ovf_0
    movzx r10d, byte ptr [r10+0]
    lea rax, [rip+.L398]
    mov r11, rax
    imul rbx, r8, 2
    jo zyl_rt_trap_ovf_2
    add rbx, rdi
    jo zyl_rt_trap_ovf_0
    mov r12, r10
    shr r12, 4
    add r12, r11
    jo zyl_rt_trap_ovf_0
    movzx r12d, byte ptr [r12+0]
    mov byte ptr [rbx+0], r12b
    imul rbx, r8, 2
    jo zyl_rt_trap_ovf_2
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    add rbx, rdi
    jo zyl_rt_trap_ovf_0
    and r10, 15
    add r10, r11
    jo zyl_rt_trap_ovf_0
    movzx r10d, byte ptr [r10+0]
    mov byte ptr [rbx+0], r10b
    add r8, 1
    jo zyl_rt_trap_ovf_0
    cmp r8, r9
    jl .L397_1
    jmp .L397_2
zy_local_x2Fmain_0__blake3__b3_x2Dclamp:
    # frame 0
.L399_0:
    cmp rdi, 0
    jg .L399_1
.L399_3:
    mov rax, 32
    ret
.L399_1:
    cmp rdi, 64
    jle .L399_2
    mov rax, 64
    ret
.L399_2:
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
.L400_0:
    mov rdi, r12
    mov rsi, r13
    call zy_local_x2Fmain_0__blake3__b3_x2Dfinalize
    imul rsi, r13, 2
    jo zyl_rt_trap_ovf_2
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    cmp rbx, 0
    jne .L400_1
    mov rdi, r12
    call zyl_rt_free
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L400_1:
    mov rsi, r12
    add rsi, 2144
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r13
    call zy_local_x2Fmain_0__blake3__rt_x2Dhex_x2Dbytes
    imul rsi, r13, 2
    jo zyl_rt_trap_ovf_2
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
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
.L401_0:
    cmp rsi, 4096
    jl .L401_3
.L401_12:
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L401_1
.L401_3:
    mov r8, 0
    jmp .L401_2
.L401_1:
    mov r9, qword ptr [rsi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L401_4
    jmp .L401_5
.L401_4:
    mov rsi, 0
.L401_5:
    mov r8, rsi
.L401_2:
    mov r13, r8
    cmp r13, 0
    jne .L401_6
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L401_6:
    mov rsi, qword ptr [r13+24]
    cmp rdi, 0
    jge .L401_7
    mov r8, qword ptr [r13+16]
    jmp .L401_8
.L401_7:
    mov r8, rdi
.L401_8:
    mov r14, r8
    cmp r14, 0
    jl .L401_10
    cmp r14, rsi
    jle .L401_9
.L401_10:
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L401_9:
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r15, rax
    cmp r15, 0
    jne .L401_11
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L401_11:
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
.L402_0:
    mov r13, rsi
    cmp r13, 0
    jne .L402_1
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L402_1:
    cmp rdi, 0
    jge .L402_2
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    jmp .L402_3
.L402_2:
    mov rsi, rdi
.L402_3:
    mov r14, rsi
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r15, rax
    cmp r15, 0
    jne .L402_4
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L402_4:
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
.L403_0:
    mov rsi, 65536
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L403_1
    cmp rsi, 0
    jle .L403_2
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__blake3__b3_x2Dupdate
.L403_2:
    jmp .L403_0
.L403_1:
    cmp rsi, -4
    jne .L403_3
    jmp .L403_0
.L403_3:
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
.L404_0:
    cmp rsi, 0
    jne .L404_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L404_1:
    mov rdi, 0
    mov r8, 0
    mov rdx, r8
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_sys_2
    mov r13, rax
    cmp r13, 0
    jge .L404_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L404_2:
    call zy_local_x2Fmain_0__blake3__b3_x2Dnew
    mov r14, rax
    mov rsi, 0
    cmp r14, 0
    je .L404_3
    mov rdi, 65536
    mov r8, 1
    mov rsi, r8
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
.L404_3:
    mov r15, rsi
    cmp r15, 0
    jne .L404_4
    cmp r14, 0
    je .L404_5
    mov rdi, r14
    call zyl_rt_free
.L404_5:
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
.L404_4:
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
.L405_0:
    lea rax, [rip+.L406]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__mangle__mg_x2Dwidths:
    # frame 0
.L407_0:
    lea rax, [rip+.L408]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__mangle__mg_x2Desc_x2Dlen:
    # frame 16
    push rbx
    mov r8, rdx
    mov r9, rcx
.L409_0:
    cmp rsi, r8
    jl .L409_1
.L409_2:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L409_1:
    mov r10, rsi
    add r10, 1
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L410]
    mov r11, rax
    mov rbx, rdi
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    movzx ebx, byte ptr [rbx+0]
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    movzx r11d, byte ptr [r11+0]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov rsi, r10
    cmp rsi, r8
    jl .L409_1
    jmp .L409_2
zy_local_x2Fmain_0__mangle__mg_x2Desc:
    # frame 32
    push rbx
    push r12
    push r13
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L411_0:
    cmp rsi, r8
    jl .L411_1
.L411_4:
    mov rax, r10
    pop r13
    pop r12
    pop rbx
    ret
.p2align 4
.L411_1:
    mov r11, rdi
    add r11, rsi
    jo zyl_rt_trap_ovf_0
    movzx r11d, byte ptr [r11+0]
    lea rax, [rip+.L412]
    mov rbx, rax
    add rbx, r11
    jo zyl_rt_trap_ovf_0
    movzx ebx, byte ptr [rbx+0]
    cmp rbx, 1
    jne .L411_2
    mov r12, r9
    add r12, r10
    jo zyl_rt_trap_ovf_0
    mov byte ptr [r12+0], r11b
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add r10, 1
    jo zyl_rt_trap_ovf_0
    cmp rsi, r8
    jl .L411_1
    jmp .L411_4
.L411_2:
    cmp rbx, 3
    jne .L411_3
    mov rbx, r9
    add rbx, r10
    jo zyl_rt_trap_ovf_0
    mov r12, 95
    mov byte ptr [rbx+0], r12b
    mov rbx, r10
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    add rbx, r9
    jo zyl_rt_trap_ovf_0
    mov r12, 53
    mov byte ptr [rbx+0], r12b
    mov rbx, r10
    add rbx, 2
    jo zyl_rt_trap_ovf_0
    add rbx, r9
    jo zyl_rt_trap_ovf_0
    mov r12, 70
    mov byte ptr [rbx+0], r12b
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add r10, 3
    jo zyl_rt_trap_ovf_0
    cmp rsi, r8
    jl .L411_1
    jmp .L411_4
.L411_3:
    lea rax, [rip+.L413]
    mov rbx, rax
    mov r12, r9
    add r12, r10
    jo zyl_rt_trap_ovf_0
    mov r13, 95
    mov byte ptr [r12+0], r13b
    mov r12, r10
    add r12, 1
    jo zyl_rt_trap_ovf_0
    add r12, r9
    jo zyl_rt_trap_ovf_0
    mov r13, 120
    mov byte ptr [r12+0], r13b
    mov r12, r10
    add r12, 2
    jo zyl_rt_trap_ovf_0
    add r12, r9
    jo zyl_rt_trap_ovf_0
    mov r13, r11
    shr r13, 4
    add r13, rbx
    jo zyl_rt_trap_ovf_0
    movzx r13d, byte ptr [r13+0]
    mov byte ptr [r12+0], r13b
    mov r12, r10
    add r12, 3
    jo zyl_rt_trap_ovf_0
    add r12, r9
    jo zyl_rt_trap_ovf_0
    and r11, 15
    add r11, rbx
    jo zyl_rt_trap_ovf_0
    movzx r11d, byte ptr [r11+0]
    mov byte ptr [r12+0], r11b
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add r10, 4
    jo zyl_rt_trap_ovf_0
    cmp rsi, r8
    jl .L411_1
    jmp .L411_4
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
.L414_0:
    mov r12, rsi
    cmp r12, 0
    jne .L414_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L414_1:
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
    mov rsi, r14
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    mov rsi, 0
    mov r8, 0
    mov rdi, r12
    mov rdx, r13
    mov rcx, rbx
    call zy_local_x2Fmain_0__mangle__mg_x2Desc
    mov rsi, rbx
    add rsi, r14
    jo zyl_rt_trap_ovf_0
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
.L415_0:
    mov rax, rsi
    add rax, 1
    jo zyl_rt_trap_ovf_0
    cmp rax, r8
    jl .L415_1
    mov rax, -1
    ret
.L415_1:
    mov r9, rdi
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r9+0]
    cmp rax, 58
    jne .L415_2
    mov r9, rsi
    add r9, 1
    jo zyl_rt_trap_ovf_0
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r9+0]
    cmp rax, 58
    jne .L415_2
    mov rax, rsi
    ret
.L415_2:
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L415_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdi, rax
    mov rsi, [rbp-32]
    mov rdx, [rbp-40]
call zy_local_x2Fmain_0__base__rt_x2Dcopy
    add rsp, 32
    mov [rbp-120], rax
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-104]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov [rbp-128], rax
    mov rax, [rbp-8]
    mov rcx, [rbp-128]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    push rax
    mov rax, 1
    mov rcx, [rbp-56]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, 2
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    pop rax
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    pop rax
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov [rbp-96], rax
    mov rax, [rbp-96]
    mov rcx, 200
    cmp rax, rcx
    jg .L416
    sub rsp, 16
    mov rax, [rbp-96]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L417
.L416:
    mov rax, [rbp-96]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jne .L418
    mov rax, 0
    jmp .L419
.L418:
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
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rdi, [rbp-16]
    mov rsi, [rbp-24]
    mov rcx, 8
call zy_local_x2Fmain_0__blake3__rt_x2Dblake3_x2Draw
    add rsp, 32
    test rax, rax
    je .L422
    mov rax, 0
    jmp .L423
.L422:
    mov rax, 1
.L423:
    test rax, rax
    je .L420
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-120]
call zyl_rt_free
    add rsp, 16
    mov [rbp-144], rax
    mov rax, 0
    jmp .L421
.L420:
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
    jo zyl_rt_trap_ovf_0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-120]
    mov rcx, 192
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
.L421:
.L419:
.L417:
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
    jne .L424
    mov rax, 0
    jmp .L425
.L424:
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
    jge .L426
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
    lea rax, [rip+.L428]
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
    jmp .L427
.L426:
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-24]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov [rbp-48], rax
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-32]
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
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
    jge .L429
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
    lea rax, [rip+.L431]
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
    jmp .L430
.L429:
    mov rax, [rbp-64]
    mov rcx, 2
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-48]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov [rbp-72], rax
    mov rax, [rbp-64]
    mov rcx, 2
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-56]
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
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
    jge .L432
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
    jmp .L433
.L432:
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
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-72]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-88]
    mov rcx, 2
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-80]
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
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
.L433:
.L430:
.L427:
.L425:
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
.L434_0:
    call zyl_int_text
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Doom:
    # frame 0
.L435_0:
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
.L436_0:
    lea rax, [rip+zyl_rtg_budget]
    mov r12, rax
    lea rax, [rip+.L437]
    mov qword ptr [rbp-48], rax
    lea rax, [rip+.L438]
    mov qword ptr [rbp-64], rax
    call zyl_int_text
    mov r15, rax
    lea rax, [rip+.L439]
    mov r13, rax
    mov rdi, qword ptr [r12+16]
    call zyl_int_text
    mov rbx, rax
    lea rax, [rip+.L440]
    mov r14, rax
    mov rdi, qword ptr [r12+8]
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L441]
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
.L442_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_threads_started_mark
zyl_threads_started_mark:
    # frame 0
.L443_0:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dalign16:
    # frame 0
.L444_0:
    mov rsi, rdi
    add rsi, 15
    jo zyl_rt_trap_ovf_0
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
.L445_0:
    mov rax, qword ptr [rbx+8]
    cmp rsi, rax
    jge .L445_1
    mov rdi, qword ptr [rbx+8]
    jmp .L445_2
.L445_1:
    mov rdi, rsi
.L445_2:
    mov r12, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    je .L445_3
    jmp .L445_4
.L445_3:
    lea rax, [rip+.L446]
    mov rsi, rax
    mov rdi, r12
    call zyl_arena_oom
.L445_4:
    mov rdi, 32
    mov rsi, 0
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L445_5
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    mov rdi, 32
    lea rax, [rip+.L447]
    mov rsi, rax
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_arena_oom
.L445_5:
    mov rsi, 0
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L445_6
    mov rdi, r13
    call zyl_rt_free
    mov rdi, r12
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    lea rax, [rip+.L448]
    mov rdi, rax
    mov rsi, rdi
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_arena_oom
.L445_6:
    mov qword ptr [r13+0], rsi
    mov qword ptr [r13+8], r12
    mov rsi, 0
    mov qword ptr [r13+16], rsi
    mov rsi, qword ptr [rbx+0]
    mov qword ptr [r13+24], rsi
    mov qword ptr [rbx+0], r13
    mov rsi, qword ptr [rbx+16]
    add rsi, r12
    jo zyl_rt_trap_ovf_0
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
.L449_0:
    mov rsi, 65536
    cmp rdi, 16
    jl .L449_1
    mov rsi, rdi
.L449_1:
    mov rbx, rsi
    mov rdi, 72
    mov rsi, 0
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L449_2
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L449_2:
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
.L450_0:
    cmp rbx, 0
    je .L450_2
.L450_11:
    cmp rsi, 0
    jl .L450_3
    mov rax, 281474976710656
    cmp rsi, rax
    jle .L450_1
.L450_3:
.L450_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L450_1:
    mov r12, rsi
    add r12, 15
    jo zyl_rt_trap_ovf_0
    and r12, -16
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L450_4
    jmp .L450_5
.L450_4:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_lock
.L450_5:
    mov rsi, qword ptr [rbx+0]
    cmp rsi, 0
    je .L450_8
    mov rdi, qword ptr [rsi+8]
    mov r8, qword ptr [rsi+16]
    sub rdi, r8
    jo zyl_rt_trap_ovf_1
    cmp r12, rdi
    jle .L450_6
.L450_8:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dnew_x2Dblock
    mov rdi, rax
    jmp .L450_7
.L450_6:
    mov rdi, rsi
.L450_7:
    mov r13, qword ptr [rdi+0]
    mov rsi, qword ptr [rdi+16]
    add r13, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, qword ptr [rdi+16]
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+16], rsi
    mov rsi, qword ptr [rbx+24]
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+24], rsi
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L450_9
    jmp .L450_10
.L450_9:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_unlock
.L450_10:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_arena_alloc
zyl_arena_alloc:
    # frame 0
.L451_0:
    jmp zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
.globl zyl_arena_alloc_zeroed
zyl_arena_alloc_zeroed:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rsi
.L452_0:
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov r12, rax
    cmp r12, 0
    jne .L452_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L452_1:
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
.L453_0:
    cmp rsi, 0
    jle .L453_1
.L453_2:
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
.L453_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfill_x2Dde:
    # frame 0
.L454_0:
    cmp rsi, 0
    jle .L454_1
.L454_2:
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
.L454_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L455_0:
    cmp rbx, 0
    jne .L455_1
.L455_4:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L455_1:
    mov r12, qword ptr [rbx+24]
    mov rsi, qword ptr [rbx+0]
    mov rdi, qword ptr [rbx+16]
    cmp rdi, 0
    jle .L455_2
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
    jmp .L455_3
.L455_2:
.L455_3:
    mov rsi, qword ptr [rbx+8]
    lea rax, [rip+zyl_rtg_budget]
    mov rdi, rax
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    mov r8, 0
    sub r8, rsi
    jo zyl_rt_trap_ovf_1
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
    jne .L455_1
    jmp .L455_4
.globl zyl_arena_reset
zyl_arena_reset:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L456_0:
    cmp rbx, 0
    jne .L456_1
.L456_6:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L456_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L456_2
    jmp .L456_3
.L456_2:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_lock
.L456_3:
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
    jne .L456_4
    jmp .L456_5
.L456_4:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_unlock
.L456_5:
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
.L457_0:
    cmp rbx, 0
    jne .L457_1
.L457_6:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L457_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L457_2
    jmp .L457_3
.L457_2:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_lock
.L457_3:
    mov rdi, qword ptr [rbx+0]
    call zy_local_x2Fmain_0__alloc__rt_x2Dfree_x2Dblocks
    mov rsi, 0
    mov qword ptr [rbx+0], rsi
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L457_4
    jmp .L457_5
.L457_4:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_unlock
.L457_5:
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
.L458_0:
    cmp rbx, 0
    jne .L458_1
.L458_6:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L458_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L458_2
    jmp .L458_3
.L458_2:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_lock
.L458_3:
    mov r12, qword ptr [rbx+24]
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L458_4
    jmp .L458_5
.L458_4:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_unlock
.L458_5:
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
.L459_0:
    cmp rbx, 0
    jne .L459_1
.L459_6:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L459_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L459_2
    jmp .L459_3
.L459_2:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_lock
.L459_3:
    mov r12, qword ptr [rbx+16]
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L459_4
    jmp .L459_5
.L459_4:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_unlock
.L459_5:
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Din_x2Dblocks:
    # frame 0
.L460_0:
    cmp rdi, 0
    jne .L460_1
.L460_3:
    mov rax, 0
    ret
.p2align 4
.L460_1:
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jl .L460_2
    mov r8, rsi
    add r8, 8
    jo zyl_rt_trap_ovf_0
    mov r9, qword ptr [rdi+0]
    mov r10, qword ptr [rdi+16]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    cmp r8, r9
    jg .L460_2
    mov rax, 1
    ret
.L460_2:
    mov rdi, qword ptr [rdi+24]
    cmp rdi, 0
    jne .L460_1
    jmp .L460_3
zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L461_0:
    cmp rbx, 0
    jne .L461_1
.L461_6:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L461_1:
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L461_2
    jmp .L461_3
.L461_2:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_lock
.L461_3:
    mov rdi, qword ptr [rbx+0]
    mov rsi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Din_x2Dblocks
    mov r12, rax
    lea rax, [rip+zyl_rtg_threads_started]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L461_4
    jmp .L461_5
.L461_4:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    call zyl_rt_mutex_unlock
.L461_5:
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Darenas:
    # frame 0
.L462_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dheap:
    # frame 0
.L463_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dpin:
    # frame 0
.L464_0:
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
.L465_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rbx, rax
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L465_1
    mov rdi, 1048576
    call zyl_arena_create
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    jmp .L465_2
.L465_1:
.L465_2:
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L465_3
    mov rdi, 262144
    call zyl_arena_create
    mov rsi, rax
    mov qword ptr [rbx+8], rsi
    jmp .L465_4
.L465_3:
.L465_4:
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
.L466_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L466_1
    jmp .L466_2
.L466_1:
    mov rdi, qword ptr [rbx+8]
    call zyl_arena_destroy
    mov rsi, 0
    mov qword ptr [rbx+8], rsi
.L466_2:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L466_3
    jmp .L466_4
.L466_3:
    mov rdi, qword ptr [rbx+0]
    call zyl_arena_destroy
    mov rsi, 0
    mov qword ptr [rbx+0], rsi
.L466_4:
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
.L467_0:
    mov rdi, rsi
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L468]
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
.L469_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    cmp rdi, 0
    je .L469_2
    cmp rbx, 0
    jg .L469_1
.L469_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L469_1:
    mov rax, 281474976710656
    cmp rbx, rax
    jle .L469_3
    lea rax, [rip+.L470]
    mov rsi, rax
    mov rdi, rsi
    mov rsi, rbx
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L469_3:
    mov rsi, rbx
    add rsi, 7
    jo zyl_rt_trap_ovf_0
    mov rcx, rsi
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov r12, rax
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    add rsi, 8
    jo zyl_rt_trap_ovf_0
    add rsi, 15
    jo zyl_rt_trap_ovf_0
    and rsi, -16
    mov r8, qword ptr [rdi+0]
    lea rax, [rip+zyl_rtg_threads_started]
    mov r9, rax
    mov rax, qword ptr [r9+0]
    cmp rax, 0
    jne .L469_4
    cmp r8, 0
    jle .L469_4
    mov r9, qword ptr [r8+8]
    mov r10, qword ptr [r8+16]
    sub r9, r10
    jo zyl_rt_trap_ovf_1
    cmp rsi, r9
    jg .L469_4
    mov r9, qword ptr [r8+0]
    mov r10, qword ptr [r8+16]
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov r10, qword ptr [r8+16]
    add r10, rsi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r8+16], r10
    mov r8, qword ptr [rdi+24]
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+24], r8
    mov qword ptr [r9+0], r12
    mov rax, r9
    add rax, 8
    jo zyl_rt_trap_ovf_0
    pop r12
    pop rbx
    pop rbp
    ret
.L469_4:
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    add rsi, 8
    jo zyl_rt_trap_ovf_0
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    cmp rsi, 0
    jne .L469_5
    lea rax, [rip+.L471]
    mov rdi, rax
    mov rsi, rbx
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L469_5:
    mov qword ptr [rsi+0], r12
    mov rax, rsi
    add rax, 8
    jo zyl_rt_trap_ovf_0
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_heap_swap
zyl_heap_swap:
    # frame 0
.L472_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov r8, qword ptr [rsi+0]
    cmp rdi, 0
    je .L472_1
    mov qword ptr [rsi+0], rdi
.L472_1:
    mov rax, r8
    ret
.globl zyl_session_arena
zyl_session_arena:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L473_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rbx, rax
    add rbx, 16
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L473_1
    mov rdi, 1048576
    call zyl_arena_create
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    jmp .L473_2
.L473_1:
.L473_2:
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
.L474_0:
    cmp rbx, 4096
    jl .L474_2
.L474_4:
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    je .L474_1
.L474_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L474_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
    cmp rax, 0
    je .L474_3
    mov rax, 1
    pop rbx
    pop rbp
    ret
.L474_3:
    call zyl_session_arena
    mov rdi, rax
    mov rsi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Daddr_x2Din_x2Darena
.globl zyl_pin_owns
zyl_pin_owns:
    # frame 0
.L475_0:
    cmp rdi, 0
    je .L475_2
.L475_3:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jne .L475_1
.L475_2:
    mov rax, 0
    ret
.L475_1:
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
.L476_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jne .L476_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L476_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+8]
    mov rsi, 8
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov rsi, rax
    cmp rsi, 0
    je .L476_2
    mov qword ptr [rsi+0], rbx
.L476_2:
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
.L477_0:
    cmp rdi, 0
    je .L477_2
.L477_4:
    cmp rsi, 0
    jg .L477_1
.L477_2:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L477_1:
    mov r8, rdi
    and r8, -4096
    sub rdi, r8
    jo zyl_rt_trap_ovf_1
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, rdi
    mov rdi, r8
    call zyl_rt_sys_149
    cmp rax, 0
    jne .L477_3
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L477_3:
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
.L478_0:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    je .L478_2
    cmp rbx, 0
    jg .L478_1
.L478_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L478_1:
    lea rax, [rip+zyl_rtg_arenas]
    mov rsi, rax
    mov rdi, qword ptr [rsi+8]
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Darena_x2Dbump
    mov r12, rax
    cmp r12, 0
    je .L478_3
    mov rdi, r12
    mov rsi, rbx
    call zyl_mlock
.L478_3:
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dclass_x2Dsize:
    # frame 0
.L479_0:
    cmp rdi, 0
    jne .L479_1
.L479_4:
    mov rax, 1024
    ret
.L479_1:
    cmp rdi, 1
    jne .L479_2
    mov rax, 4096
    ret
.L479_2:
    cmp rdi, 2
    jne .L479_3
    mov rax, 16384
    ret
.L479_3:
    mov rax, 65536
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drpool:
    # frame 0
.L480_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dlive:
    # frame 0
.L481_0:
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
.L482_0:
    call zyl_region_poison_level
    cmp rax, 0
    jle .L482_1
    mov rsi, qword ptr [rbx+8]
    mov rdi, rbx
    add rdi, 24
    jo zyl_rt_trap_ovf_0
    sub rsi, 24
    jo zyl_rt_trap_ovf_1
    call zy_local_x2Fmain_0__alloc__rt_x2Dfill_x2Dde
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L482_1:
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
.L483_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dcharge
    cmp rax, 0
    je .L483_1
    jmp .L483_2
.L483_1:
    lea rax, [rip+.L484]
    mov rsi, rax
    mov rdi, rbx
    call zyl_arena_oom
.L483_2:
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
    jge .L483_3
    cmp rsi, -4096
    jle .L483_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Drefund
    lea rax, [rip+.L485]
    mov rdi, rax
    mov rsi, rdi
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_arena_oom
.L483_3:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L486_0:
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
.L487_0:
    mov rax, r14
    add rax, r13
    jo zyl_rt_trap_ovf_0
    cmp rax, 1048576
    jle .L487_1
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L487_1:
    mov rdi, r12
    add rdi, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, 0
    mov rdx, rsi
    mov rsi, r13
    mov rcx, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Drblock_x2Dinit
    mov rsi, rax
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rdi, rax
    imul r8, rbx, 8
    jo zyl_rt_trap_ovf_2
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r8, qword ptr [rdi+0]
    mov qword ptr [rsi+0], r8
    mov qword ptr [rdi+0], rsi
    add r14, r13
    jo zyl_rt_trap_ovf_0
    jmp .L487_0
zy_local_x2Fmain_0__alloc__rt_x2Dpick_x2Dclass:
    # frame 0
.L488_0:
    cmp rsi, 4
    jge .L488_1
.L488_5:
    mov r8, rdi
    add r8, 24
    jo zyl_rt_trap_ovf_0
    mov r9, 1024
    cmp rsi, 0
    je .L488_2
    mov r10, 4096
    cmp rsi, 1
    je .L488_3
    mov r11, 16384
    cmp rsi, 2
    je .L488_4
    mov r11, 65536
.L488_4:
    mov r10, r11
.L488_3:
    mov r9, r10
.L488_2:
    cmp r8, r9
    jle .L488_1
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    cmp rsi, 4
    jge .L488_1
    jmp .L488_5
.L488_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dregion_5Funpooled_x2Dp:
    # frame 0
    push rbp
    mov rbp, rsp
.L489_0:
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
.L490_0:
    mov rdi, rsi
    cmp rsi, 4
    jl .L490_1
    mov rdi, 3
.L490_1:
    mov rsi, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dpick_x2Dclass
    mov r12, rax
    cmp r12, 4
    jl .L490_2
    mov rsi, rbx
    add rsi, 24
    jo zyl_rt_trap_ovf_0
    add rsi, 4095
    jo zyl_rt_trap_ovf_0
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
.L490_2:
    call zyl_region_poison_level
    cmp rax, 2
    jne .L490_3
    mov rsi, rbx
    add rsi, 24
    jo zyl_rt_trap_ovf_0
    add rsi, 4095
    jo zyl_rt_trap_ovf_0
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
.L490_3:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rbx, rax
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L490_4
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
    jmp .L490_5
.L490_4:
.L490_5:
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
.L491_0:
    cmp rdi, 0
    je .L491_2
.L491_3:
    cmp rsi, 4
    jl .L491_1
.L491_2:
    mov rax, rsi
    ret
.L491_1:
    mov rdi, qword ptr [rdi+0]
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    cmp rdi, 0
    je .L491_2
    jmp .L491_3
zy_local_x2Fmain_0__alloc__rt_x2Dpush_x2Dblock:
    # frame 0
.L492_0:
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
    mov r8, rsi
    add r8, 24
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+8], r8
    mov r8, qword ptr [rsi+8]
    add rsi, r8
    jo zyl_rt_trap_ovf_0
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
.L493_0:
    mov rsi, qword ptr [rdi+0]
    lea rax, [rip+.L494]
    mov rbx, rax
    cmp rsi, 2
    jne .L493_1
    lea rax, [rip+.L495]
    mov r12, rax
    jmp .L493_2
.L493_1:
    lea rax, [rip+.L496]
    mov r12, rax
.L493_2:
    lea rax, [rip+.L497]
    mov r13, rax
    cmp rsi, 2
    jne .L493_3
    mov rsi, qword ptr [rdi+8]
    jmp .L493_4
.L493_3:
    mov rsi, qword ptr [rdi+24]
.L493_4:
    mov rdi, rsi
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L498]
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
.L499_0:
    mov rdi, rbx
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    mov rsi, qword ptr [rdi+16]
    mov r8, r12
    add r8, 7
    jo zyl_rt_trap_ovf_0
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov r8, rax
    imul r8, r8, 8
    jo zyl_rt_trap_ovf_2
    mov r9, qword ptr [rbx+8]
    mov r10, r9
    add r10, 8
    jo zyl_rt_trap_ovf_0
    add r10, rsi
    jo zyl_rt_trap_ovf_0
    sub r10, 1
    jo zyl_rt_trap_ovf_1
    mov r11, 0
    sub r11, rsi
    jo zyl_rt_trap_ovf_1
    and r10, r11
    mov r11, r10
    add r11, r8
    jo zyl_rt_trap_ovf_0
    cmp r9, 0
    jle .L499_1
    mov rax, qword ptr [rbx+16]
    cmp r11, rax
    jg .L499_1
    mov r14, qword ptr [rdi+32]
    mov rax, r11
    mov rcx, r9
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov r9, rax
    add r14, r9
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rdi+24]
    cmp rax, 0
    jle .L499_2
    mov rax, qword ptr [rdi+24]
    cmp r14, rax
    jle .L499_2
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dexhausted
.L499_2:
    mov qword ptr [rdi+32], r14
    mov qword ptr [rbx+8], r11
    mov r9, r10
    sub r9, 8
    jo zyl_rt_trap_ovf_1
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
.L499_1:
    cmp r13, 1
    jge .L499_4
    mov rax, qword ptr [rdi+0]
    cmp rax, 2
    jne .L499_3
    mov r9, qword ptr [rbx+24]
    and r9, -2
    cmp r9, 0
    jle .L499_3
.L499_4:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dexhausted
.L499_3:
    add r8, 8
    jo zyl_rt_trap_ovf_0
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    add r8, 24
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rdi+0]
    cmp rax, 2
    jne .L499_5
    mov r9, qword ptr [rdi+8]
    add r9, 8
    jo zyl_rt_trap_ovf_0
    add rsi, r9
    jo zyl_rt_trap_ovf_0
    add rsi, 24
    jo zyl_rt_trap_ovf_0
    jmp .L499_6
.L499_5:
    mov rax, qword ptr [rdi+8]
    cmp rax, r8
    jge .L499_7
    jmp .L499_8
.L499_7:
    mov r8, qword ptr [rdi+8]
.L499_8:
    mov rsi, r8
.L499_6:
    add rsi, 4095
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    jmp .L499_0
.globl zyl_ralloc
zyl_ralloc:
    # frame 0
.L500_0:
    cmp rsi, 0
    jne .L500_1
.L500_5:
    jmp zyl_heap_alloc
.L500_1:
    cmp rdi, 0
    jle .L500_3
    cmp rdi, 65536
    jle .L500_2
.L500_3:
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dralloc_x2Din
.L500_2:
    mov r8, qword ptr [rsi+8]
    mov r9, rdi
    add r9, 7
    jo zyl_rt_trap_ovf_0
    and r9, -8
    add r9, 8
    jo zyl_rt_trap_ovf_0
    cmp r8, 0
    jle .L500_4
    mov r10, qword ptr [rsi+24]
    and r10, 1
    cmp r10, 1
    je .L500_4
    mov r10, r8
    add r10, r9
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rsi+16]
    cmp r10, rax
    jg .L500_4
    add r9, r8
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rsi+8], r9
    mov r9, rdi
    add r9, 7
    jo zyl_rt_trap_ovf_0
    shr r9, 3
    mov qword ptr [r8+0], r9
    mov rax, r8
    add rax, 8
    jo zyl_rt_trap_ovf_0
    ret
.L500_4:
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
.L501_0:
    cmp rbx, 0
    jg .L501_1
.L501_7:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L501_1:
    mov rsi, qword ptr [r12+24]
    and rsi, 1
    cmp rsi, 1
    jne .L501_2
    mov rsi, 0
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dpolicy_x2Dalloc
.L501_2:
    mov rax, 281474976710656
    cmp rbx, rax
    jle .L501_3
    lea rax, [rip+.L502]
    mov rdi, rax
    mov rsi, rbx
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__alloc__rt_x2Dheap_x2Dfail
.L501_3:
    mov rsi, rbx
    add rsi, 7
    jo zyl_rt_trap_ovf_0
    mov rcx, rsi
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov rsi, rax
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    mov r13, rsi
    add r13, 8
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r12+8]
    cmp rax, 0
    je .L501_6
    mov rsi, qword ptr [r12+16]
    mov rdi, qword ptr [r12+8]
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
    cmp rsi, r13
    jge .L501_4
.L501_6:
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
    jmp .L501_5
.L501_4:
.L501_5:
    mov rsi, qword ptr [r12+8]
    mov rdi, rsi
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r12+8], rdi
    mov rdi, rbx
    add rdi, 7
    jo zyl_rt_trap_ovf_0
    mov rcx, rdi
    mov rax, rcx
    sar rax, 63
    shr rax, 61
    add rax, rcx
    sar rax, 3
    mov rdi, rax
    mov qword ptr [rsi+0], rdi
    mov rax, rsi
    add rax, 8
    jo zyl_rt_trap_ovf_0
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
.L503_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov r8, 0
    mov r9, qword ptr [rdi+8]
    sub r8, r9
    jo zyl_rt_trap_ovf_1
    mov rdx, rsi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov eax, dword ptr [rdi+16]
    cmp rax, 1
    jne .L503_1
    mov rbx, qword ptr [rdi+8]
    mov rsi, rbx
    call zyl_rt_sys_11
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__heap__rt_x2Drefund
.L503_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_rpool@tpoff]
    mov rsi, rax
    mov r8d, dword ptr [rdi+20]
    imul r8, r8, 8
    jo zyl_rt_trap_ovf_2
    add rsi, r8
    jo zyl_rt_trap_ovf_0
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
.L504_0:
    cmp rdi, 0
    je .L504_2
.L504_3:
    cmp rdi, rbx
    jne .L504_1
.L504_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L504_1:
    mov r12, qword ptr [rdi+0]
    call zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dblock
    mov rdi, r12
    cmp rdi, 0
    je .L504_2
    jmp .L504_3
zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L505_0:
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
.L506_0:
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
.L507_0:
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
    jl .L507_1
    mov rsi, r9
.L507_1:
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
.L508_0:
    mov rsi, qword ptr [rdi+24]
    and rsi, -2
    cmp rsi, 0
    jle .L508_1
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    jmp .L508_2
.L508_1:
.L508_2:
    mov rax, 0
    pop rbp
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dlast_x2Dblock:
    # frame 0
.L509_0:
    mov rax, qword ptr [rdi+0]
    cmp rax, 0
    jne .L509_1
    mov rax, rdi
    ret
.L509_1:
    mov rdi, qword ptr [rdi+0]
    jmp .L509_0
.globl zyl_region_recycle
zyl_region_recycle:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L510_0:
    mov r12, qword ptr [rbx+24]
    and r12, -2
    cmp r12, 0
    jne .L510_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L510_1:
    mov rax, qword ptr [r12+0]
    cmp rax, 0
    jne .L510_2
    mov eax, dword ptr [r12+16]
    cmp rax, 0
    jne .L510_2
    mov rsi, r12
    add rsi, 24
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+8], rsi
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L510_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dlast_x2Dblock
    mov r13, rax
    mov eax, dword ptr [r13+16]
    cmp rax, 1
    jne .L510_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L510_3:
    mov rdi, r12
    mov rsi, r13
    call zy_local_x2Fmain_0__alloc__rt_x2Drelease_x2Dchain
    mov rsi, qword ptr [rbx+24]
    and rsi, 1
    or rsi, r13
    mov qword ptr [rbx+24], rsi
    mov rsi, r13
    add rsi, 24
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+8], rsi
    mov rsi, qword ptr [r13+8]
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L511_0:
    mov rsi, qword ptr [rbx+24]
    and rsi, -2
    cmp rsi, 0
    jle .L511_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    jmp .L511_2
.L511_1:
.L511_2:
    mov rsi, qword ptr [rbx+0]
    mov rax, rsi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    cmp rsi, rbx
    jne .L511_3
    mov rsi, 0
    mov rax, rsi
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    jmp .L511_4
.L511_3:
.L511_4:
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
.L512_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov r12, rax
    cmp r12, 0
    je .L512_2
    cmp r12, rbx
    jne .L512_1
.L512_2:
    mov rsi, 0
    mov rax, rsi
    mov QWORD PTR fs:zyl_cur_region@tpoff, rax
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L512_1:
    mov rsi, qword ptr [r12+24]
    and rsi, -2
    cmp rsi, 0
    jle .L512_3
    mov rdi, r12
    call zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dfree_x2Dblocks
    jmp .L512_4
.L512_3:
.L512_4:
    mov rsi, qword ptr [r12+0]
    mov rax, rsi
    mov QWORD PTR fs:zyl_region_top@tpoff, rax
    jmp .L512_0
.globl zyl_region_mark
zyl_region_mark:
    # frame 0
.L513_0:
    mov rax, QWORD PTR fs:zyl_region_top@tpoff
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_region_live_bytes
zyl_region_live_bytes:
    # frame 0
.L514_0:
    lea rax, [rip+zyl_rtg_region_live]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__alloc__rt_x2Dregion_x2Dtls:
    # frame 0
.L515_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_cur_region@tpoff]
    mov rsi, rax
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_region_top@tpoff]
    mov rdi, rax
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
.globl zyl_ffi_pin
zyl_ffi_pin:
    # frame 0
.L516_0:
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
.L517_0:
    cmp rbx, 0
    jne .L517_1
.L517_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L517_1:
    mov rdi, rbx
    call zyl_pin_owns
    cmp rax, 0
    je .L517_2
    mov rax, qword ptr [rbx+0]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L517_2:
    lea rax, [rip+.L518]
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
.L519_0:
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
.L520_0:
    lea rax, [rip+.L521]
    mov qword ptr [rbp-48], rax
    lea rax, [rip+.L522]
    mov r14, rax
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r15, rax
    lea rax, [rip+.L523]
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
.L524_0:
    mov rax, 6510318674217419859
    ret
zy_local_x2Fmain_0__tables__tb_x2Dnot_x2Dwords:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L525_0:
    lea rax, [rip+.L526]
    mov rbx, rax
    lea rax, [rip+.L527]
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
.L528_0:
    cmp rbx, 4096
    jl .L528_1
.L528_2:
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    jne .L528_1
    mov rdi, qword ptr [rbx+0]
    mov rax, 6510318674217419859
    cmp rdi, rax
    jne .L528_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L528_1:
    lea rax, [rip+.L529]
    mov r12, rax
    lea rax, [rip+.L530]
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
.L531_0:
    mov rsi, 24
    call zyl_arena_alloc_zeroed
    mov r13, rax
    cmp r13, 0
    jne .L531_1
    lea rax, [rip+.L532]
    mov rdi, rax
    call zyl_panic
    jmp .L531_2
.L531_1:
.L531_2:
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
.L533_0:
    mov rdi, 0
    cmp rsi, 0
    jl .L533_1
    mov rdi, rsi
.L533_1:
    mov r12, rdi
    mov rsi, 24
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov r13, rax
    mov rsi, r12
    cmp r12, 0
    jg .L533_2
    mov rsi, 1
.L533_2:
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov rbx, rax
    cmp r13, 0
    je .L533_5
    cmp rbx, 0
    jne .L533_3
.L533_5:
    lea rax, [rip+.L534]
    mov rdi, rax
    call zyl_panic
    jmp .L533_4
.L533_3:
.L533_4:
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
.L535_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    mov rdi, rbx
    call zyl_ralloc
    mov r12, rax
    cmp r12, 0
    je .L535_1
    mov rdi, r12
    mov rsi, rbx
    call zy_local_x2Fmain_0__alloc__rt_x2Dfill0
.L535_1:
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
.L536_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L536_1
    mov rsi, rdi
.L536_1:
    mov rbx, rsi
    mov rdi, 24
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r12, rax
    mov rsi, rbx
    cmp rbx, 0
    jg .L536_2
    mov rsi, 1
.L536_2:
    imul rdi, rsi, 8
    jo zyl_rt_trap_ovf_2
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r13, rax
    cmp r12, 0
    je .L536_5
    cmp r13, 0
    jne .L536_3
.L536_5:
    lea rax, [rip+.L537]
    mov rdi, rax
    call zyl_panic
    jmp .L536_4
.L536_3:
.L536_4:
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
.L538_0:
    jmp zyl_words_alloc
.globl zyl_words_len
zyl_words_len:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L539_0:
    cmp rdi, 4096
    jl .L539_1
.L539_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L539_1
    mov rsi, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp rsi, rax
    jne .L539_1
    mov rax, qword ptr [rdi+8]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L539_1:
    lea rax, [rip+.L540]
    mov rdi, rax
    lea rax, [rip+.L541]
    mov rbx, rax
    lea rax, [rip+.L542]
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
.L543_0:
    cmp rdi, 4096
    jl .L543_1
.L543_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L543_1
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp r9, rax
    jne .L543_1
    mov rdi, qword ptr [rdi+8]
    mov rdx, rdi
    mov rdi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L543_1:
    lea rax, [rip+.L544]
    mov rbx, rax
    lea rax, [rip+.L545]
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
.L546_0:
    cmp rdi, 4096
    jl .L546_1
.L546_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L546_1
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp r8, rax
    jne .L546_1
    cmp rsi, 0
    jl .L546_1
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jge .L546_1
    mov r8, qword ptr [rdi+16]
    imul r9, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r8, r9
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r8+0]
    ret
.L546_1:
    lea rax, [rip+.L547]
    mov r8, rax
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dfail
.globl zyl_words_set
zyl_words_set:
    # frame 0
    mov r8, rdx
.L548_0:
    cmp rdi, 4096
    jl .L548_1
.L548_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L548_1
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318674217419859
    cmp r9, rax
    jne .L548_1
    cmp rsi, 0
    jl .L548_1
    mov rax, qword ptr [rdi+8]
    cmp rsi, rax
    jge .L548_1
    mov r9, qword ptr [rdi+16]
    imul r10, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r9, r10
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r9+0], r8
    mov rax, r8
    ret
.L548_1:
    lea rax, [rip+.L549]
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
.L550_0:
    mov rdi, 24
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r13, rax
    cmp r13, 0
    jne .L550_1
    lea rax, [rip+.L551]
    mov rdi, rax
    call zyl_panic
    jmp .L550_2
.L550_1:
.L550_2:
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
.L552_0:
    lea rax, [rip+.L553]
    mov rdi, rax
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov r14, rax
    mov rsi, qword ptr [r14+8]
    cmp r12, 0
    jl .L552_3
    cmp r13, 0
    jl .L552_3
    cmp r12, rsi
    jg .L552_4
    mov rax, rsi
    sub rax, r12
    jo zyl_rt_trap_ovf_1
    cmp r13, rax
    jle .L552_1
.L552_4:
.L552_3:
    lea rax, [rip+.L554]
    mov rdi, rax
    mov r8, r12
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov rdx, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L552_2
.L552_1:
.L552_2:
    mov rsi, qword ptr [r14+16]
    imul rdi, r12, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
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
.L555_0:
    lea rax, [rip+.L556]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov r13, rax
    mov rsi, qword ptr [r13+8]
    cmp rbx, 0
    jl .L555_3
    cmp r12, 0
    jl .L555_3
    cmp rbx, rsi
    jg .L555_4
    mov rax, rsi
    sub rax, rbx
    jo zyl_rt_trap_ovf_1
    cmp r12, rax
    jle .L555_1
.L555_4:
.L555_3:
    lea rax, [rip+.L557]
    mov rdi, rax
    mov r8, rbx
    add r8, r12
    jo zyl_rt_trap_ovf_0
    mov rdx, rsi
    mov rsi, r8
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L555_2
.L555_1:
.L555_2:
    mov rsi, qword ptr [r13+16]
    imul rdi, rbx, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dhdr_x2Dr
zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dmagic:
    # frame 0
.L558_0:
    mov rax, 6510318579778470233
    ret
zy_local_x2Fmain_0__tables__tb_x2Dnot_x2Darray:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
.L559_0:
    lea rax, [rip+.L560]
    mov rbx, rax
    lea rax, [rip+.L561]
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
.L562_0:
    cmp rbx, 4096
    jl .L562_1
.L562_2:
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    jne .L562_1
    mov rdi, qword ptr [rbx+0]
    mov rax, 6510318579778470233
    cmp rdi, rax
    jne .L562_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L562_1:
    lea rax, [rip+.L563]
    mov r12, rax
    lea rax, [rip+.L564]
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
.L565_0:
    mov rdi, 0
    cmp rsi, 0
    jl .L565_1
    mov rdi, rsi
.L565_1:
    mov r12, rdi
    mov rsi, 32
    mov rdi, rbx
    call zyl_arena_alloc_zeroed
    mov r13, rax
    mov rsi, r12
    cmp r12, 0
    jg .L565_2
    mov rsi, 1
.L565_2:
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    mov rdi, rbx
    call zyl_arena_alloc
    mov rbx, rax
    cmp r13, 0
    je .L565_5
    cmp rbx, 0
    jne .L565_3
.L565_5:
    lea rax, [rip+.L566]
    mov rdi, rax
    call zyl_panic
    jmp .L565_4
.L565_3:
.L565_4:
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
.L567_0:
    cmp rdi, 4096
    jl .L567_1
.L567_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L567_1
    mov rsi, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp rsi, rax
    jne .L567_1
    mov rax, qword ptr [rdi+8]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L567_1:
    lea rax, [rip+.L568]
    mov rdi, rax
    lea rax, [rip+.L569]
    mov rbx, rax
    lea rax, [rip+.L570]
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
.L571_0:
    cmp rdi, 4096
    jl .L571_1
.L571_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L571_1
    mov rsi, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp rsi, rax
    jne .L571_1
    mov rax, qword ptr [rdi+16]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L571_1:
    lea rax, [rip+.L572]
    mov rdi, rax
    lea rax, [rip+.L573]
    mov rbx, rax
    lea rax, [rip+.L574]
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
.L575_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L575_1
    mov rsi, rdi
.L575_1:
    mov rbx, rsi
    mov rdi, 32
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r12, rax
    mov rsi, rbx
    cmp rbx, 0
    jg .L575_2
    mov rsi, 1
.L575_2:
    imul rdi, rsi, 8
    jo zyl_rt_trap_ovf_2
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    call zyl_ralloc
    mov r13, rax
    cmp r12, 0
    je .L575_5
    cmp r13, 0
    jne .L575_3
.L575_5:
    lea rax, [rip+.L576]
    mov rdi, rax
    call zyl_panic
    jmp .L575_4
.L575_3:
.L575_4:
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
.L577_0:
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
.L578_0:
    mov rsi, 0
    cmp rdi, 0
    jl .L578_1
    mov rsi, rdi
.L578_1:
    mov rbx, rsi
    mov rdi, 32
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov r12, rax
    mov rsi, rbx
    cmp rbx, 0
    jg .L578_2
    mov rsi, 1
.L578_2:
    imul rdi, rsi, 8
    jo zyl_rt_trap_ovf_2
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    call zyl_ralloc
    mov r13, rax
    cmp r12, 0
    je .L578_5
    cmp r13, 0
    jne .L578_3
.L578_5:
    lea rax, [rip+.L579]
    mov rdi, rax
    call zyl_panic
    jmp .L578_4
.L578_3:
.L578_4:
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
.L580_0:
    cmp rdi, 4096
    jl .L580_1
.L580_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L580_1
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp r8, rax
    jne .L580_1
    lea rax, [rip+.L581]
    mov r8, rax
    mov rdi, qword ptr [rdi+16]
    mov rdx, rdi
    mov rdi, r8
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L580_1:
    lea rax, [rip+.L582]
    mov rdi, rax
    lea rax, [rip+.L583]
    mov rbx, rax
    lea rax, [rip+.L584]
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
.L585_0:
    cmp rdi, 4096
    jl .L585_1
.L585_2:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    jne .L585_1
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318579778470233
    cmp r8, rax
    jne .L585_1
    cmp rsi, 0
    jl .L585_1
    mov rax, qword ptr [rdi+16]
    cmp rsi, rax
    jge .L585_1
    mov r8, qword ptr [rdi+24]
    imul r9, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r8, r9
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r8+0]
    ret
.L585_1:
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
.L586_0:
    lea rax, [rip+.L587]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov r13, rax
    lea rax, [rip+.L588]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov rbx, rax
    mov rsi, qword ptr [r13+16]
    cmp r12, 0
    jl .L586_3
    cmp r12, rsi
    jle .L586_1
.L586_3:
    lea rax, [rip+.L589]
    mov rdi, rax
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L586_2
.L586_1:
.L586_2:
    mov rsi, qword ptr [rbx+8]
    mov rax, qword ptr [rbx+16]
    cmp rax, 0
    jne .L586_6
    cmp r12, rsi
    jle .L586_4
.L586_6:
    lea rax, [rip+.L590]
    mov rdi, rax
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L586_5
.L586_4:
.L586_5:
    mov rdi, qword ptr [rbx+24]
    mov rsi, qword ptr [r13+24]
    imul r8, r12, 8
    jo zyl_rt_trap_ovf_2
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
.L591_0:
    lea rax, [rip+.L592]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Darray_x2Dof
    mov r13, rax
    mov r14, qword ptr [r13+16]
    cmp rbx, 0
    jl .L591_3
    cmp rbx, r14
    jg .L591_3
    mov rax, qword ptr [r13+8]
    cmp rbx, rax
    jl .L591_1
.L591_3:
    lea rax, [rip+.L593]
    mov rdi, rax
    mov rsi, rbx
    mov rdx, r14
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L591_2
.L591_1:
.L591_2:
    mov rsi, qword ptr [r13+24]
    imul rdi, rbx, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rsi+0], r12
    cmp rbx, r14
    jne .L591_4
    mov rsi, r14
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r13+16], rsi
    jmp .L591_5
.L591_4:
.L591_5:
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
.L594_0:
    mov rdi, 1
    mov rsi, 24
    jmp zyl_rt_calloc
zy_local_x2Fmain_0__tables__tb_x2Dprobe:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L595_0:
    imul r10, r8, 16
    jo zyl_rt_trap_ovf_2
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    mov r11, qword ptr [r10+0]
    cmp r11, 0
    je .L595_2
    cmp r11, r9
    jne .L595_1
.L595_2:
    mov rax, r10
    ret
.L595_1:
    add r8, 1
    jo zyl_rt_trap_ovf_0
    and r8, rsi
    jmp .L595_0
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
.L596_0:
    cmp qword ptr [rbp-56], r13
    jl .L596_1
.L596_3:
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
.L596_1:
    imul rsi, qword ptr [rbp-56], 16
    jo zyl_rt_trap_ovf_2
    mov rbx, qword ptr [rbp-48]
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    mov r12, qword ptr [rbx+0]
    cmp r12, 0
    je .L596_2
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
.L596_2:
    mov rax, qword ptr [rbp-56]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-56], rax
    cmp qword ptr [rbp-56], r13
    jl .L596_1
    jmp .L596_3
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
.L597_0:
    mov r12, qword ptr [rbx+8]
    cmp r12, 0
    jle .L597_1
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    jmp .L597_2
.L597_1:
    mov rsi, 4096
.L597_2:
    mov r13, rsi
    mov rsi, 16
    mov rdi, r13
    call zyl_rt_calloc
    mov r14, rax
    cmp r14, 0
    jne .L597_3
    imul rdi, r13, 16
    jo zyl_rt_trap_ovf_2
    lea rax, [rip+.L598]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L597_4
.L597_3:
.L597_4:
    mov rdi, qword ptr [rbx+0]
    mov rsi, 0
    mov r8, r13
    sub r8, 1
    jo zyl_rt_trap_ovf_1
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
.L599_0:
    cmp rbx, 0
    je .L599_2
.L599_7:
    cmp r12, 0
    jne .L599_1
.L599_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L599_1:
    mov rsi, qword ptr [rbx+16]
    imul rsi, rsi, 10
    jo zyl_rt_trap_ovf_2
    mov rdi, qword ptr [rbx+8]
    imul rdi, rdi, 7
    jo zyl_rt_trap_ovf_2
    cmp rsi, rdi
    jl .L599_3
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dgrow
    jmp .L599_4
.L599_3:
.L599_4:
    mov rsi, qword ptr [rbx+8]
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
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
    jne .L599_5
    mov qword ptr [rsi+0], r12
    mov rdi, qword ptr [rbx+16]
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+16], rdi
    jmp .L599_6
.L599_5:
.L599_6:
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
.L600_0:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dattr_x2Dset
zy_local_x2Fmain_0__tables__tb_x2Dget_x2Dloop:
    # frame 16
    push rbx
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L601_0:
    imul r11, r8, 16
    jo zyl_rt_trap_ovf_2
    add r11, rdi
    jo zyl_rt_trap_ovf_0
    mov rbx, qword ptr [r11+0]
    cmp rbx, r9
    jne .L601_1
    mov rax, qword ptr [r11+8]
    pop rbx
    ret
.L601_1:
    cmp rbx, 0
    jne .L601_2
    mov rax, r10
    pop rbx
    ret
.L601_2:
    add r8, 1
    jo zyl_rt_trap_ovf_0
    and r8, rsi
    jmp .L601_0
.globl zyl_attrh_get_or
zyl_attrh_get_or:
    # frame 16
    push rbx
    mov r8, rdx
.L602_0:
    cmp rdi, 0
    je .L602_2
.L602_3:
    cmp rsi, 0
    je .L602_2
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jne .L602_1
.L602_2:
    mov rax, r8
    pop rbx
    ret
.L602_1:
    mov r9, qword ptr [rdi+8]
    sub r9, 1
    jo zyl_rt_trap_ovf_1
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
.L603_0:
    cmp rdi, 0
    je .L603_4
.L603_7:
    cmp rsi, 0
    je .L603_4
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jne .L603_2
.L603_4:
    mov r8, 0
    jmp .L603_3
.L603_2:
    mov r9, qword ptr [rdi+8]
    sub r9, 1
    jo zyl_rt_trap_ovf_1
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
    jne .L603_5
    mov rdi, 0
    jmp .L603_6
.L603_5:
    mov rdi, rsi
.L603_6:
    mov r8, rdi
.L603_3:
    cmp r8, 0
    jne .L603_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L603_1:
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
.L604_0:
    cmp rbx, 0
    je .L604_3
.L604_7:
    cmp rsi, 0
    je .L604_3
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L604_1
.L604_3:
    mov rdi, 0
    jmp .L604_2
.L604_1:
    mov r8, qword ptr [rbx+8]
    sub r8, 1
    jo zyl_rt_trap_ovf_1
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
    jne .L604_4
    mov r8, 0
    jmp .L604_5
.L604_4:
    mov r8, rsi
.L604_5:
    mov rdi, r8
.L604_2:
    cmp rdi, 0
    jne .L604_6
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L604_6:
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
.L605_0:
    cmp rdi, 0
    je .L605_2
.L605_3:
    mov rax, qword ptr [rdi+8]
    cmp rax, 0
    jne .L605_1
.L605_2:
    mov rax, 0
    ret
.L605_1:
    mov rsi, qword ptr [rdi+0]
    mov r8, 0
    mov r9, qword ptr [rdi+8]
    imul r9, r9, 16
    jo zyl_rt_trap_ovf_2
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
.L606_0:
    mov rdi, 8
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L606_1
    mov rdi, 8
    lea rax, [rip+.L607]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L606_2
.L606_1:
.L606_2:
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
.L608_0:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_ref_set
zyl_ref_set:
    # frame 0
.L609_0:
    mov qword ptr [rdi+0], rsi
    mov rax, 0
    ret
.globl zyl_uf_id
zyl_uf_id:
    # frame 0
.L610_0:
    mov rax, rdi
    ret
.globl zyl_getenv_str
zyl_getenv_str:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L611_0:
    cmp rdi, 0
    jne .L611_1
.L611_4:
    mov rsi, 0
    jmp .L611_2
.L611_1:
    call zyl_rt_getenv
    mov rsi, rax
.L611_2:
    cmp rsi, 0
    jne .L611_3
    lea rax, [rip+.L612]
    mov rdi, rax
    mov rax, rdi
    mov rsp, rbp
    pop rbp
    ret
.L611_3:
    mov rax, rsi
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dmagic:
    # frame 0
.L613_0:
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
.L614_0:
    mov r8, rsi
    cmp rsi, 0
    jg .L614_1
    mov r8, 1
.L614_1:
    mov rbx, r8
    mov rsi, rbx
    add rsi, 24
    jo zyl_rt_trap_ovf_0
    call zyl_arena_alloc_zeroed
    mov rsi, rax
    cmp rsi, 0
    jne .L614_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L614_2:
    mov rdi, 6510318656819643953
    mov qword ptr [rsi+0], rdi
    mov rdi, 0
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], rbx
    mov rax, rsi
    add rax, 24
    jo zyl_rt_trap_ovf_0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_strbuf_str
zyl_strbuf_str:
    # frame 0
.L615_0:
    cmp rdi, 0
    jne .L615_1
.L615_2:
    lea rax, [rip+.L616]
    mov rsi, rax
    mov rdi, rsi
    jmp zyl_panic
.L615_1:
    mov rax, rdi
    ret
.globl zyl_strbuf_new_r
zyl_strbuf_new_r:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L617_0:
    mov rsi, rdi
    cmp rdi, 0
    jg .L617_1
    mov rsi, 1
.L617_1:
    mov rbx, rsi
    mov rdi, rbx
    add rdi, 24
    jo zyl_rt_trap_ovf_0
    call zy_local_x2Fmain_0__tables__tb_x2Drzalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L617_2
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L617_2:
    mov rdi, 6510318656819643953
    mov qword ptr [rsi+0], rdi
    mov rdi, 0
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], rbx
    mov rax, rsi
    add rax, 24
    jo zyl_rt_trap_ovf_0
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
.L618_0:
    lea rax, [rip+.L619]
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
    jne .L618_1
    mov rsi, r12
    call zyl_cstr_concat
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L618_1:
    mov rbx, rsi
    mov rsi, r12
    call zyl_cstr_concat
    mov r12, rax
    jmp .L618_0
zy_local_x2Fmain_0__tables__tb_x2Dbad:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L620_0:
    cmp rdi, 4096
    jge .L620_1
.L620_2:
    lea rax, [rip+.L621]
    mov rbx, rax
    lea rax, [rip+.L622]
    mov rsi, rax
    call zy_local_x2Fmain_0__tables__tb_x2Duhex
    mov rdi, rax
    lea rax, [rip+.L623]
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
.L620_1:
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
.L624_0:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    mov rsi, rbx
    sub rsi, 16
    jo zyl_rt_trap_ovf_1
    mov r15, qword ptr [rsi+0]
    mov rsi, rbx
    sub rsi, 8
    jo zyl_rt_trap_ovf_1
    mov rsi, qword ptr [rsi+0]
    cmp r13, 0
    jle .L624_1
    cmp r13, rsi
    jge .L624_1
    mov rdi, r13
    jmp .L624_2
.L624_1:
    mov rdi, rsi
.L624_2:
    mov rsi, r15
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    cmp rsi, rdi
    jle .L624_3
    cmp r13, 0
    jle .L624_5
    lea rax, [rip+.L625]
    mov rdi, rax
    jmp .L624_6
.L624_5:
    lea rax, [rip+.L626]
    mov rdi, rax
.L624_6:
    call zyl_panic
    jmp .L624_4
.L624_3:
.L624_4:
    mov rdi, rbx
    add rdi, r15
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r15
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, rbx
    sub rsi, 16
    jo zyl_rt_trap_ovf_1
    mov rdi, r15
    add rdi, r14
    jo zyl_rt_trap_ovf_0
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
.L627_0:
    cmp rbx, 0
    je .L627_2
.L627_7:
    cmp r12, 0
    jne .L627_1
.L627_2:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L627_1:
    cmp rbx, 4096
    jl .L627_3
    cmp r12, 4096
    jl .L627_3
    cmp rbx, 4120
    jl .L627_4
    mov rax, rbx
    and rax, 7
    cmp rax, 0
    jne .L627_4
    mov rdi, rbx
    sub rdi, 24
    jo zyl_rt_trap_ovf_1
    mov rdi, qword ptr [rdi+0]
    mov rax, 6510318656819643953
    cmp rdi, rax
    jne .L627_4
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Dsbuf_x2Dappend
.L627_4:
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zyl_str_append_scan
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L627_3:
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dbad
    cmp rax, 0
    je .L627_5
    jmp .L627_6
.L627_5:
    mov rdi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Dbad
.L627_6:
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_str_append
zyl_str_append:
    # frame 0
.L628_0:
    mov r8, 0
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dappend
.globl zyl_str_append_capped
zyl_str_append_capped:
    # frame 0
    mov r8, rdx
.L629_0:
    mov rdx, r8
    jmp zy_local_x2Fmain_0__tables__tb_x2Dappend
zy_local_x2Fmain_0__bytes__bb_x2Dmagic_x2Dbuf:
    # frame 0
.L630_0:
    mov rax, 6510318584122966017
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dmagic_x2Dslice:
    # frame 0
.L631_0:
    mov rax, 6510318584122966018
    ret
zy_local_x2Fmain_0__bytes__bb_x2Dmax_x2Dcap:
    # frame 0
.L632_0:
    mov rax, 1099511627776
    ret
.globl zyl_load_byte
zyl_load_byte:
    # frame 0
    mov rdi, rdx
.L633_0:
    cmp rdi, 4096
    jl .L633_3
.L633_15:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L633_1
.L633_3:
    mov r8, 0
    jmp .L633_2
.L633_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L633_4
    mov r10, qword ptr [rdi+24]
    jmp .L633_5
.L633_4:
    mov rax, 6510318584122966018
    cmp r9, rax
    jne .L633_6
    mov r9, qword ptr [rdi+16]
    jmp .L633_7
.L633_6:
    mov r9, -1
.L633_7:
    mov r10, r9
.L633_5:
    cmp r10, 0
    jl .L633_8
    cmp rsi, 0
    jl .L633_12
    cmp r10, 0
    jl .L633_13
    mov rax, 1
    cmp rax, r10
    jle .L633_10
.L633_13:
.L633_12:
    mov r9, 0
    jmp .L633_11
.L633_10:
    sub r10, 1
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r9, rax
.L633_11:
    cmp r9, 0
    je .L633_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L633_9
.L633_8:
    mov rdi, 0
.L633_9:
    mov r8, rdi
.L633_2:
    cmp r8, 0
    jne .L633_14
    mov rax, 0
    ret
.L633_14:
    movzx eax, byte ptr [r8+0]
    ret
.globl zyl_load_byte_signed
zyl_load_byte_signed:
    # frame 0
    mov rdi, rdx
.L634_0:
    cmp rdi, 4096
    jl .L634_3
.L634_16:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L634_1
.L634_3:
    mov r8, 0
    jmp .L634_2
.L634_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L634_4
    mov r10, qword ptr [rdi+24]
    jmp .L634_5
.L634_4:
    mov rax, 6510318584122966018
    cmp r9, rax
    jne .L634_6
    mov r9, qword ptr [rdi+16]
    jmp .L634_7
.L634_6:
    mov r9, -1
.L634_7:
    mov r10, r9
.L634_5:
    cmp r10, 0
    jl .L634_8
    cmp rsi, 0
    jl .L634_12
    cmp r10, 0
    jl .L634_13
    mov rax, 1
    cmp rax, r10
    jle .L634_10
.L634_13:
.L634_12:
    mov r9, 0
    jmp .L634_11
.L634_10:
    sub r10, 1
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r9, rax
.L634_11:
    cmp r9, 0
    je .L634_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L634_9
.L634_8:
    mov rdi, 0
.L634_9:
    mov r8, rdi
.L634_2:
    cmp r8, 0
    jne .L634_14
    mov rax, 0
    ret
.L634_14:
    movzx esi, byte ptr [r8+0]
    cmp rsi, 127
    jle .L634_15
    mov rax, rsi
    sub rax, 256
    jo zyl_rt_trap_ovf_1
    ret
.L634_15:
    mov rax, rsi
    ret
.globl zyl_store_byte
zyl_store_byte:
    # frame 0
    mov rdi, rdx
    mov r8, rcx
.L635_0:
    cmp rdi, 4096
    jl .L635_3
.L635_15:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L635_1
.L635_3:
    mov r9, 0
    jmp .L635_2
.L635_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L635_4
    mov r11, qword ptr [rdi+24]
    jmp .L635_5
.L635_4:
    mov rax, 6510318584122966018
    cmp r10, rax
    jne .L635_6
    mov r10, qword ptr [rdi+16]
    jmp .L635_7
.L635_6:
    mov r10, -1
.L635_7:
    mov r11, r10
.L635_5:
    cmp r11, 0
    jl .L635_8
    cmp rsi, 0
    jl .L635_12
    cmp r11, 0
    jl .L635_13
    mov rax, 1
    cmp rax, r11
    jle .L635_10
.L635_13:
.L635_12:
    mov r10, 0
    jmp .L635_11
.L635_10:
    sub r11, 1
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L635_11:
    cmp r10, 0
    je .L635_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L635_9
.L635_8:
    mov rdi, 0
.L635_9:
    mov r9, rdi
.L635_2:
    cmp r9, 0
    jne .L635_14
    mov rax, 0
    ret
.L635_14:
    mov byte ptr [r9+0], r8b
    mov rax, 1
    ret
.globl zyl_store_byte_signed
zyl_store_byte_signed:
    # frame 0
    mov rdi, rdx
    mov r8, rcx
.L636_0:
    cmp rdi, 4096
    jl .L636_3
.L636_15:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L636_1
.L636_3:
    mov r9, 0
    jmp .L636_2
.L636_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L636_4
    mov r11, qword ptr [rdi+24]
    jmp .L636_5
.L636_4:
    mov rax, 6510318584122966018
    cmp r10, rax
    jne .L636_6
    mov r10, qword ptr [rdi+16]
    jmp .L636_7
.L636_6:
    mov r10, -1
.L636_7:
    mov r11, r10
.L636_5:
    cmp r11, 0
    jl .L636_8
    cmp rsi, 0
    jl .L636_12
    cmp r11, 0
    jl .L636_13
    mov rax, 1
    cmp rax, r11
    jle .L636_10
.L636_13:
.L636_12:
    mov r10, 0
    jmp .L636_11
.L636_10:
    sub r11, 1
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L636_11:
    cmp r10, 0
    je .L636_8
    mov rdi, qword ptr [rdi+8]
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L636_9
.L636_8:
    mov rdi, 0
.L636_9:
    mov r9, rdi
.L636_2:
    cmp r9, 0
    jne .L636_14
    mov rax, 0
    ret
.L636_14:
    mov byte ptr [r9+0], r8b
    mov rax, 1
    ret
.globl zyl_load_n
zyl_load_n:
    # frame 16
    push rbx
    mov r8, rdx
    mov r9, rcx
.L637_0:
    cmp rdi, 2
    je .L637_1
.L637_24:
    cmp rdi, 4
    je .L637_1
    cmp rdi, 8
    je .L637_1
    mov rax, 0
    pop rbx
    ret
.L637_1:
    cmp r9, 4096
    jl .L637_4
    mov rax, r9
    and rax, 7
    cmp rax, 0
    je .L637_2
.L637_4:
    mov r10, 0
    jmp .L637_3
.L637_2:
    mov r11, qword ptr [r9+0]
    mov rax, 6510318584122966017
    cmp r11, rax
    jne .L637_5
    mov rbx, qword ptr [r9+24]
    jmp .L637_6
.L637_5:
    mov rax, 6510318584122966018
    cmp r11, rax
    jne .L637_7
    mov r11, qword ptr [r9+16]
    jmp .L637_8
.L637_7:
    mov r11, -1
.L637_8:
    mov rbx, r11
.L637_6:
    cmp rbx, 0
    jl .L637_9
    cmp r8, 0
    jl .L637_13
    cmp rdi, 0
    jl .L637_14
    cmp rbx, 0
    jl .L637_15
    cmp rdi, rbx
    jle .L637_11
.L637_15:
.L637_14:
.L637_13:
    mov r11, 0
    jmp .L637_12
.L637_11:
    sub rbx, rdi
    jo zyl_rt_trap_ovf_1
    mov rax, r8
    mov rcx, rbx
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r11, rax
.L637_12:
    cmp r11, 0
    je .L637_9
    mov r9, qword ptr [r9+8]
    add r9, r8
    jo zyl_rt_trap_ovf_0
    jmp .L637_10
.L637_9:
    mov r9, 0
.L637_10:
    mov r10, r9
.L637_3:
    cmp r10, 0
    jne .L637_16
    mov rax, 0
    pop rbx
    ret
.L637_16:
    cmp rdi, 2
    jne .L637_17
    movzx r8d, word ptr [r10+0]
    jmp .L637_18
.L637_17:
    cmp rdi, 4
    jne .L637_19
    mov r9d, dword ptr [r10+0]
    jmp .L637_20
.L637_19:
    mov r9, qword ptr [r10+0]
.L637_20:
    mov r8, r9
.L637_18:
    cmp rsi, 0
    jne .L637_21
    mov rax, r8
    pop rbx
    ret
.L637_21:
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
    jne .L637_22
    mov rax, rsi
    pop rbx
    ret
.L637_22:
    cmp rdi, 4
    jne .L637_23
    mov rdi, rsi
    shr rdi, 32
    mov r8, 4294967295
    and rdi, r8
    mov rax, rdi
    pop rbx
    ret
.L637_23:
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
.L638_0:
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zyl_load_n
    mov rsi, rax
    cmp rbx, 8
    jge .L638_2
    cmp rbx, 2
    je .L638_1
    cmp rbx, 4
    je .L638_1
    cmp rbx, 8
    je .L638_1
.L638_2:
    mov rax, rsi
    pop rbx
    pop rbp
    ret
.L638_1:
    mov rdi, 1
    imul r8, rbx, 8
    jo zyl_rt_trap_ovf_2
    sub r8, 1
    jo zyl_rt_trap_ovf_1
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
.L639_0:
    cmp rdi, 2
    je .L639_1
.L639_25:
    cmp rdi, 4
    je .L639_1
    cmp rdi, 8
    je .L639_1
    mov rax, 0
    pop r12
    pop rbx
    ret
.L639_1:
    cmp r9, 4096
    jl .L639_4
    mov rax, r9
    and rax, 7
    cmp rax, 0
    je .L639_2
.L639_4:
    mov r11, 0
    jmp .L639_3
.L639_2:
    mov rbx, qword ptr [r9+0]
    mov rax, 6510318584122966017
    cmp rbx, rax
    jne .L639_5
    mov r12, qword ptr [r9+24]
    jmp .L639_6
.L639_5:
    mov rax, 6510318584122966018
    cmp rbx, rax
    jne .L639_7
    mov rbx, qword ptr [r9+16]
    jmp .L639_8
.L639_7:
    mov rbx, -1
.L639_8:
    mov r12, rbx
.L639_6:
    cmp r12, 0
    jl .L639_9
    cmp r8, 0
    jl .L639_13
    cmp rdi, 0
    jl .L639_14
    cmp r12, 0
    jl .L639_15
    cmp rdi, r12
    jle .L639_11
.L639_15:
.L639_14:
.L639_13:
    mov rbx, 0
    jmp .L639_12
.L639_11:
    sub r12, rdi
    jo zyl_rt_trap_ovf_1
    mov rax, r8
    mov rcx, r12
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
.L639_12:
    cmp rbx, 0
    je .L639_9
    mov r9, qword ptr [r9+8]
    add r9, r8
    jo zyl_rt_trap_ovf_0
    jmp .L639_10
.L639_9:
    mov r9, 0
.L639_10:
    mov r11, r9
.L639_3:
    cmp r11, 0
    jne .L639_16
    mov rax, 0
    pop r12
    pop rbx
    ret
.L639_16:
    mov r8, r10
    cmp rsi, 0
    je .L639_17
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
    je .L639_18
    cmp rdi, 4
    jne .L639_19
    mov r10, rsi
    shr r10, 32
    mov rbx, 4294967295
    and r10, rbx
    jmp .L639_20
.L639_19:
    mov r10, rsi
    shr r10, 48
    and r10, 65535
.L639_20:
    mov r9, r10
.L639_18:
    mov r8, r9
.L639_17:
    cmp rdi, 2
    jne .L639_21
    mov word ptr [r11+0], r8w
    jmp .L639_22
.L639_21:
    cmp rdi, 4
    jne .L639_23
    mov dword ptr [r11+0], r8d
    jmp .L639_24
.L639_23:
    mov qword ptr [r11+0], r8
.L639_24:
.L639_22:
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
.L640_0:
    mov rdi, 24
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L640_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L640_1:
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
.L641_0:
    cmp rdi, 4096
    jl .L641_3
.L641_13:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L641_1
.L641_3:
    mov r9, 0
    jmp .L641_2
.L641_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L641_4
    jmp .L641_5
.L641_4:
    mov rdi, 0
.L641_5:
    mov r9, rdi
.L641_2:
    cmp r9, 0
    je .L641_7
    cmp rsi, 0
    jl .L641_10
    cmp r8, 0
    jl .L641_11
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L641_12
    mov rax, qword ptr [r9+24]
    cmp r8, rax
    jle .L641_8
.L641_12:
.L641_11:
.L641_10:
    mov rdi, 0
    jmp .L641_9
.L641_8:
    mov r10, qword ptr [r9+24]
    sub r10, r8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rdi, rax
.L641_9:
    cmp rdi, 0
    jne .L641_6
.L641_7:
    mov rax, 0
    ret
.L641_6:
    mov rdi, qword ptr [r9+8]
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, r8
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice
.globl zyl_byte_slice_sub
zyl_byte_slice_sub:
    # frame 0
    mov r8, rdx
.L642_0:
    cmp rdi, 4096
    jl .L642_3
.L642_13:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L642_1
.L642_3:
    mov r9, 0
    jmp .L642_2
.L642_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966018
    cmp r10, rax
    jne .L642_4
    jmp .L642_5
.L642_4:
    mov rdi, 0
.L642_5:
    mov r9, rdi
.L642_2:
    cmp r9, 0
    je .L642_7
    cmp rsi, 0
    jl .L642_10
    cmp r8, 0
    jl .L642_11
    mov rax, qword ptr [r9+16]
    cmp rax, 0
    jl .L642_12
    mov rax, qword ptr [r9+16]
    cmp r8, rax
    jle .L642_8
.L642_12:
.L642_11:
.L642_10:
    mov rdi, 0
    jmp .L642_9
.L642_8:
    mov r10, qword ptr [r9+16]
    sub r10, r8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rdi, rax
.L642_9:
    cmp rdi, 0
    jne .L642_6
.L642_7:
    mov rax, 0
    ret
.L642_6:
    mov rdi, qword ptr [r9+8]
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, r8
    jmp zy_local_x2Fmain_0__bytes__bb_x2Dnew_x2Dslice
zy_local_x2Fmain_0__bytes__bb_x2Dinit:
    # frame 0
    mov r8, rdx
.L643_0:
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
.L644_0:
    cmp rdi, 0
    jl .L644_1
.L644_2:
    mov rsi, 1099511627776
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setle al
    movzx rax, al
    ret
.L644_1:
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
.L645_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok
    cmp rax, 0
    jne .L645_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L645_1:
    mov rdi, 32
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r12, rax
    cmp r12, 0
    jne .L645_2
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L645_2:
    mov rsi, rbx
    cmp rbx, 0
    jg .L645_3
    mov rsi, 1
.L645_3:
    mov r13, rsi
    mov rsi, 1
    mov rdi, r13
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L645_4
    mov rdi, r12
    call zyl_rt_free
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L645_4:
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
.L646_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__bytes__bb_x2Dcap_x2Dok
    cmp rax, 0
    jne .L646_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L646_1:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov r12, rax
    mov rdi, 32
    mov rsi, r12
    call zyl_ralloc
    mov r13, rax
    cmp r13, 0
    jne .L646_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L646_2:
    mov rsi, rbx
    cmp rbx, 0
    jg .L646_3
    mov rsi, 1
.L646_3:
    mov r14, rsi
    mov rdi, r14
    mov rsi, r12
    call zyl_ralloc
    mov rsi, rax
    cmp rsi, 0
    jne .L646_4
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L646_4:
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
.L647_0:
    cmp rdi, 4096
    jl .L647_3
.L647_19:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L647_1
.L647_3:
    mov r8, 0
    jmp .L647_2
.L647_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L647_4
    jmp .L647_5
.L647_4:
    mov rdi, 0
.L647_5:
    mov r8, rdi
.L647_2:
    mov rbx, r8
    cmp rsi, 4096
    jl .L647_8
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L647_6
.L647_8:
    mov rdi, 0
    jmp .L647_7
.L647_6:
    mov r8, qword ptr [rsi+0]
    mov rax, 6510318584122966018
    cmp r8, rax
    jne .L647_9
    jmp .L647_10
.L647_9:
    mov rsi, 0
.L647_10:
    mov rdi, rsi
.L647_7:
    cmp rbx, 0
    je .L647_12
    cmp rdi, 0
    jne .L647_11
.L647_12:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L647_11:
    mov r12, qword ptr [rbx+16]
    mov r13, qword ptr [rdi+16]
    cmp r12, 0
    jl .L647_16
    cmp r13, 0
    jl .L647_17
    mov rax, qword ptr [rbx+24]
    cmp rax, 0
    jl .L647_18
    mov rax, qword ptr [rbx+24]
    cmp r13, rax
    jle .L647_14
.L647_18:
.L647_17:
.L647_16:
    mov rsi, 0
    jmp .L647_15
.L647_14:
    mov r8, qword ptr [rbx+24]
    sub r8, r13
    jo zyl_rt_trap_ovf_1
    mov rax, r12
    mov rcx, r8
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rsi, rax
.L647_15:
    cmp rsi, 0
    jne .L647_13
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L647_13:
    mov rsi, qword ptr [rbx+8]
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rdi+8]
    mov rdx, r13
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dmove
    mov rsi, r12
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L648_0:
    cmp rdi, 4096
    jl .L648_3
.L648_7:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L648_1
.L648_3:
    mov rsi, 0
    jmp .L648_2
.L648_1:
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L648_4
    jmp .L648_5
.L648_4:
    mov rdi, 0
.L648_5:
    mov rsi, rdi
.L648_2:
    cmp rsi, 0
    jne .L648_6
    mov rax, 0
    ret
.L648_6:
    mov rax, qword ptr [rsi+16]
    ret
.globl zyl_bytebuf_cap
zyl_bytebuf_cap:
    # frame 0
.L649_0:
    cmp rdi, 4096
    jl .L649_3
.L649_7:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L649_1
.L649_3:
    mov rsi, 0
    jmp .L649_2
.L649_1:
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L649_4
    jmp .L649_5
.L649_4:
    mov rdi, 0
.L649_5:
    mov rsi, rdi
.L649_2:
    cmp rsi, 0
    jne .L649_6
    mov rax, 0
    ret
.L649_6:
    mov rax, qword ptr [rsi+24]
    ret
.globl zyl_bytebuf_ptr
zyl_bytebuf_ptr:
    # frame 0
.L650_0:
    cmp rdi, 4096
    jl .L650_3
.L650_7:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L650_1
.L650_3:
    mov rsi, 0
    jmp .L650_2
.L650_1:
    mov r8, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L650_4
    jmp .L650_5
.L650_4:
    mov rdi, 0
.L650_5:
    mov rsi, rdi
.L650_2:
    cmp rsi, 0
    jne .L650_6
    mov rax, 0
    ret
.L650_6:
    mov rax, qword ptr [rsi+8]
    ret
.globl zyl_align_check
zyl_align_check:
    # frame 0
.L651_0:
    cmp rsi, 0
    jg .L651_1
.L651_3:
    mov rax, 0
    ret
.L651_1:
    mov rax, rdi
    mov rcx, rsi
    test rcx, rcx
    jz zyl_rt_trap_div0_4
    cmp rcx, -1
    jne .L652
    xor eax, eax
    jmp .L653
.L652:
    cqo
    idiv rcx
    mov rax, rdx
.L653:
    cmp rax, 0
    jne .L651_2
    mov rax, 1
    ret
.L651_2:
    mov rax, 0
    ret
.globl zyl_atomic_load
zyl_atomic_load:
    # frame 0
.L654_0:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_atomic_store
zyl_atomic_store:
    # frame 0
.L655_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, rsi
    ret
.globl zyl_atomic_fetch_add
zyl_atomic_fetch_add:
    # frame 0
.L656_0:
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    ret
.globl zyl_atomic_add
zyl_atomic_add:
    # frame 0
.L657_0:
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
.L658_0:
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
.L659_0:
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
.L660_0:
    cmp r9, 0
    je .L660_1
.L660_6:
    mov r10, rsi
    cmp rsi, r8
    jg .L660_3
    mov r10, r8
.L660_3:
    jmp .L660_2
.p2align 4
.L660_1:
    mov rbx, rsi
    cmp rsi, r8
    jl .L660_4
    mov rbx, r8
.L660_4:
    mov r10, rbx
.L660_2:
    mov rdx, rdi
    mov rcx, rsi
    mov r11, r10
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    mov rbx, rax
    cmp rbx, rsi
    jne .L660_5
    mov rax, r10
    pop rbx
    ret
.L660_5:
    mov rsi, rbx
    cmp r9, 0
    je .L660_1
    jmp .L660_6
.globl zyl_atomic_max
zyl_atomic_max:
    # frame 0
.L661_0:
    mov r8, qword ptr [rdi+0]
    mov r9, 1
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick
.globl zyl_atomic_min
zyl_atomic_min:
    # frame 0
.L662_0:
    mov r8, qword ptr [rdi+0]
    mov r9, 0
    mov rdx, rsi
    mov rsi, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__bytes__bb_x2Datomic_x2Dpick
.globl zyl_bytebuf_atomic_load
zyl_bytebuf_atomic_load:
    # frame 0
.L663_0:
    cmp rdi, 4096
    jl .L663_3
.L663_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L663_1
.L663_3:
    mov r8, 0
    jmp .L663_2
.L663_1:
    mov r9, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r9, rax
    jne .L663_4
    jmp .L663_5
.L663_4:
    mov rdi, 0
.L663_5:
    mov r8, rdi
.L663_2:
    cmp r8, 0
    je .L663_8
    cmp rsi, 0
    jl .L663_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L663_6
.L663_9:
.L663_8:
    mov rdi, 0
    jmp .L663_7
.L663_6:
    cmp rsi, 0
    jl .L663_14
    mov rax, qword ptr [r8+24]
    cmp rax, 0
    jl .L663_15
    mov r9, 8
    mov rax, qword ptr [r8+24]
    cmp r9, rax
    jle .L663_12
.L663_15:
.L663_14:
    mov r9, 0
    jmp .L663_13
.L663_12:
    mov r10, qword ptr [r8+24]
    sub r10, 8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r10
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r9, rax
.L663_13:
    cmp r9, 0
    je .L663_10
    mov r8, qword ptr [r8+8]
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L663_11
.L663_10:
    mov r8, 0
.L663_11:
    mov rdi, r8
.L663_7:
    cmp rdi, 0
    jne .L663_16
    mov rax, 0
    ret
.L663_16:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_bytebuf_atomic_store
zyl_bytebuf_atomic_store:
    # frame 0
    mov r8, rdx
.L664_0:
    cmp rdi, 4096
    jl .L664_3
.L664_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L664_1
.L664_3:
    mov r9, 0
    jmp .L664_2
.L664_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L664_4
    jmp .L664_5
.L664_4:
    mov rdi, 0
.L664_5:
    mov r9, rdi
.L664_2:
    cmp r9, 0
    je .L664_8
    cmp rsi, 0
    jl .L664_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L664_6
.L664_9:
.L664_8:
    mov rdi, 0
    jmp .L664_7
.L664_6:
    cmp rsi, 0
    jl .L664_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L664_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L664_12
.L664_15:
.L664_14:
    mov r10, 0
    jmp .L664_13
.L664_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L664_13:
    cmp r10, 0
    je .L664_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L664_11
.L664_10:
    mov r9, 0
.L664_11:
    mov rdi, r9
.L664_7:
    cmp rdi, 0
    jne .L664_16
    mov rax, 0
    ret
.L664_16:
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
.L665_0:
    cmp rdi, 4096
    jl .L665_3
.L665_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L665_1
.L665_3:
    mov r9, 0
    jmp .L665_2
.L665_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L665_4
    jmp .L665_5
.L665_4:
    mov rdi, 0
.L665_5:
    mov r9, rdi
.L665_2:
    cmp r9, 0
    je .L665_8
    cmp rsi, 0
    jl .L665_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L665_6
.L665_9:
.L665_8:
    mov rdi, 0
    jmp .L665_7
.L665_6:
    cmp rsi, 0
    jl .L665_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L665_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L665_12
.L665_15:
.L665_14:
    mov r10, 0
    jmp .L665_13
.L665_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L665_13:
    cmp r10, 0
    je .L665_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L665_11
.L665_10:
    mov r9, 0
.L665_11:
    mov rdi, r9
.L665_7:
    cmp rdi, 0
    jne .L665_16
    mov rax, 0
    ret
.L665_16:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
.globl zyl_bytebuf_atomic_sub
zyl_bytebuf_atomic_sub:
    # frame 0
    mov r8, rdx
.L666_0:
    cmp rdi, 4096
    jl .L666_3
.L666_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L666_1
.L666_3:
    mov r9, 0
    jmp .L666_2
.L666_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L666_4
    jmp .L666_5
.L666_4:
    mov rdi, 0
.L666_5:
    mov r9, rdi
.L666_2:
    cmp r9, 0
    je .L666_8
    cmp rsi, 0
    jl .L666_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L666_6
.L666_9:
.L666_8:
    mov rdi, 0
    jmp .L666_7
.L666_6:
    cmp rsi, 0
    jl .L666_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L666_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L666_12
.L666_15:
.L666_14:
    mov r10, 0
    jmp .L666_13
.L666_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L666_13:
    cmp r10, 0
    je .L666_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L666_11
.L666_10:
    mov r9, 0
.L666_11:
    mov rdi, r9
.L666_7:
    cmp rdi, 0
    jne .L666_16
    mov rax, 0
    ret
.L666_16:
    mov rsi, 0
    sub rsi, r8
    jo zyl_rt_trap_ovf_1
    mov rdx, rdi
    mov rcx, rsi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov rsi, rax
    sub rsi, r8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    ret
.globl zyl_bytebuf_atomic_fetch_add
zyl_bytebuf_atomic_fetch_add:
    # frame 0
    mov r8, rdx
.L667_0:
    cmp rdi, 4096
    jl .L667_3
.L667_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L667_1
.L667_3:
    mov r9, 0
    jmp .L667_2
.L667_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L667_4
    jmp .L667_5
.L667_4:
    mov rdi, 0
.L667_5:
    mov r9, rdi
.L667_2:
    cmp r9, 0
    je .L667_8
    cmp rsi, 0
    jl .L667_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L667_6
.L667_9:
.L667_8:
    mov rdi, 0
    jmp .L667_7
.L667_6:
    cmp rsi, 0
    jl .L667_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L667_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L667_12
.L667_15:
.L667_14:
    mov r10, 0
    jmp .L667_13
.L667_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L667_13:
    cmp r10, 0
    je .L667_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L667_11
.L667_10:
    mov r9, 0
.L667_11:
    mov rdi, r9
.L667_7:
    cmp rdi, 0
    jne .L667_16
    mov rax, 0
    ret
.L667_16:
    mov rdx, rdi
    mov rcx, r8
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    ret
.globl zyl_bytebuf_atomic_max
zyl_bytebuf_atomic_max:
    # frame 0
    mov r8, rdx
.L668_0:
    cmp rdi, 4096
    jl .L668_3
.L668_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L668_1
.L668_3:
    mov r9, 0
    jmp .L668_2
.L668_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L668_4
    jmp .L668_5
.L668_4:
    mov rdi, 0
.L668_5:
    mov r9, rdi
.L668_2:
    cmp r9, 0
    je .L668_8
    cmp rsi, 0
    jl .L668_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L668_6
.L668_9:
.L668_8:
    mov rdi, 0
    jmp .L668_7
.L668_6:
    cmp rsi, 0
    jl .L668_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L668_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L668_12
.L668_15:
.L668_14:
    mov r10, 0
    jmp .L668_13
.L668_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L668_13:
    cmp r10, 0
    je .L668_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L668_11
.L668_10:
    mov r9, 0
.L668_11:
    mov rdi, r9
.L668_7:
    cmp rdi, 0
    jne .L668_16
    mov rax, 0
    ret
.L668_16:
    mov rsi, r8
    jmp zyl_atomic_max
.globl zyl_bytebuf_atomic_min
zyl_bytebuf_atomic_min:
    # frame 0
    mov r8, rdx
.L669_0:
    cmp rdi, 4096
    jl .L669_3
.L669_17:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L669_1
.L669_3:
    mov r9, 0
    jmp .L669_2
.L669_1:
    mov r10, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp r10, rax
    jne .L669_4
    jmp .L669_5
.L669_4:
    mov rdi, 0
.L669_5:
    mov r9, rdi
.L669_2:
    cmp r9, 0
    je .L669_8
    cmp rsi, 0
    jl .L669_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L669_6
.L669_9:
.L669_8:
    mov rdi, 0
    jmp .L669_7
.L669_6:
    cmp rsi, 0
    jl .L669_14
    mov rax, qword ptr [r9+24]
    cmp rax, 0
    jl .L669_15
    mov r10, 8
    mov rax, qword ptr [r9+24]
    cmp r10, rax
    jle .L669_12
.L669_15:
.L669_14:
    mov r10, 0
    jmp .L669_13
.L669_12:
    mov r11, qword ptr [r9+24]
    sub r11, 8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r11
    cmp rax, rcx
    setle al
    movzx rax, al
    mov r10, rax
.L669_13:
    cmp r10, 0
    je .L669_10
    mov r9, qword ptr [r9+8]
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L669_11
.L669_10:
    mov r9, 0
.L669_11:
    mov rdi, r9
.L669_7:
    cmp rdi, 0
    jne .L669_16
    mov rax, 0
    ret
.L669_16:
    mov rsi, r8
    jmp zyl_atomic_min
.globl zyl_bytebuf_atomic_cas
zyl_bytebuf_atomic_cas:
    # frame 16
    push rbx
    push r12
    mov r8, rdx
    mov r9, rcx
.L670_0:
    cmp rdi, 4096
    jl .L670_3
.L670_18:
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L670_1
.L670_3:
    mov r10, 0
    jmp .L670_2
.L670_1:
    mov rbx, qword ptr [rdi+0]
    mov rax, 6510318584122966017
    cmp rbx, rax
    jne .L670_4
    jmp .L670_5
.L670_4:
    mov rdi, 0
.L670_5:
    mov r10, rdi
.L670_2:
    cmp r10, 0
    je .L670_8
    cmp rsi, 0
    jl .L670_9
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L670_6
.L670_9:
.L670_8:
    mov rdi, 0
    jmp .L670_7
.L670_6:
    cmp rsi, 0
    jl .L670_14
    mov rax, qword ptr [r10+24]
    cmp rax, 0
    jl .L670_15
    mov rbx, 8
    mov rax, qword ptr [r10+24]
    cmp rbx, rax
    jle .L670_12
.L670_15:
.L670_14:
    mov rbx, 0
    jmp .L670_13
.L670_12:
    mov r12, qword ptr [r10+24]
    sub r12, 8
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rcx, r12
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rbx, rax
.L670_13:
    cmp rbx, 0
    je .L670_10
    mov r10, qword ptr [r10+8]
    add r10, rsi
    jo zyl_rt_trap_ovf_0
    jmp .L670_11
.L670_10:
    mov r10, 0
.L670_11:
    mov rdi, r10
.L670_7:
    cmp rdi, 0
    jne .L670_16
    mov rax, 0
    pop r12
    pop rbx
    ret
.L670_16:
    mov rdx, rdi
    mov rcx, r8
    mov r11, r9
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, r8
    jne .L670_17
    mov rax, 1
    pop r12
    pop rbx
    ret
.L670_17:
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
.L671_0:
    cmp r14, r13
    jl .L671_1
.L671_4:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L671_1:
    mov rsi, r12
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    sub rdi, r14
    jo zyl_rt_trap_ovf_1
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L671_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    cmp r14, r13
    jl .L671_1
    jmp .L671_4
.L671_2:
    cmp rsi, -4
    jne .L671_3
    cmp r14, r13
    jl .L671_1
    jmp .L671_4
.L671_3:
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
.L672_0:
    cmp r14, r13
    jl .L672_1
.L672_4:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L672_1:
    mov rsi, r12
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    sub rdi, r14
    jo zyl_rt_trap_ovf_1
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L672_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    cmp r14, r13
    jl .L672_1
    jmp .L672_4
.L672_2:
    cmp rsi, -4
    jne .L672_3
    cmp r14, r13
    jl .L672_1
    jmp .L672_4
.L672_3:
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
.L673_0:
    cmp rdi, 4096
    jge .L673_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L673_1:
    mov rsi, 0
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_2
    mov rbx, rax
    cmp rbx, 0
    jge .L673_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L673_2:
    mov rsi, 0
    mov rdi, 2
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_8
    mov r12, rax
    cmp r12, 0
    jl .L673_5
    mov rsi, 0
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_8
    cmp rax, 0
    jge .L673_3
.L673_5:
    mov rsi, 0
    jmp .L673_4
.L673_3:
    mov rdi, 0
    mov rsi, r12
    call zyl_bytebuf_new
    mov rsi, rax
.L673_4:
    mov r13, rsi
    mov rsi, -1
    cmp r13, 0
    je .L673_6
    mov rdi, qword ptr [r13+8]
    mov r8, 0
    mov rsi, rdi
    mov rdi, rbx
    mov rdx, r12
    mov rcx, r8
    call zy_local_x2Fmain_0__bytes__bb_x2Dread_x2Dall
    mov rsi, rax
.L673_6:
    mov r14, rsi
    mov rdi, rbx
    call zyl_rt_sys_3
    cmp r14, r12
    jne .L673_7
    mov qword ptr [r13+16], r12
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L673_7:
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
.L674_0:
    mov r12, rdi
    cmp rsi, 4096
    jl .L674_3
    mov rax, rsi
    and rax, 7
    cmp rax, 0
    je .L674_1
.L674_3:
    mov rdi, 0
    jmp .L674_2
.L674_1:
    mov r8, qword ptr [rsi+0]
    mov rax, 6510318584122966017
    cmp r8, rax
    jne .L674_4
    jmp .L674_5
.L674_4:
    mov rsi, 0
.L674_5:
    mov rdi, rsi
.L674_2:
    mov r13, rdi
    cmp r12, 4096
    jl .L674_7
    cmp r13, 0
    je .L674_8
    cmp rbx, 0
    jl .L674_11
    mov rax, qword ptr [r13+24]
    cmp rax, 0
    jl .L674_12
    mov rax, qword ptr [r13+24]
    cmp rbx, rax
    jle .L674_9
.L674_12:
.L674_11:
    mov rsi, 0
    jmp .L674_10
.L674_9:
    mov rdi, 0
    mov r8, qword ptr [r13+24]
    sub r8, rbx
    jo zyl_rt_trap_ovf_1
    mov rax, rdi
    mov rcx, r8
    cmp rax, rcx
    setle al
    movzx rax, al
    mov rsi, rax
.L674_10:
    cmp rsi, 0
    jne .L674_6
.L674_8:
.L674_7:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L674_6:
    mov rdi, r12
    call zyl_rt_sys_87
    mov rsi, 577
    mov rdi, 493
    mov rdx, rdi
    mov rdi, r12
    call zyl_rt_sys_2
    mov r12, rax
    cmp r12, 0
    jge .L674_13
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L674_13:
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
    jne .L674_14
    cmp rsi, 0
    jne .L674_14
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L674_14:
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
.L675_0:
    mov rdx, rdi
    cvtsi2sd xmm0, rdx
    movq rax, xmm0
    ret
.globl zyl_f_to_int
zyl_f_to_int:
    # frame 0
.L676_0:
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
    movsd xmm0, [rip+.L679]
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
    je .L677
    movsd xmm0, [rip+.L680]
    movq rax, xmm0
    jmp .L678
.L677:
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
    movsd xmm0, [rip+.L685]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm0, xmm1
    seta al
    movzx rax, al
    test rax, rax
    je .L683
    mov rax, [rbp-40]
    push rax
    movsd xmm0, [rip+.L686]
    movq rax, xmm0
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    ucomisd xmm1, xmm0
    seta al
    movzx rax, al
    jmp .L684
.L683:
    mov rax, 0
.L684:
    test rax, rax
    je .L681
    mov rax, [rbp-40]
    mov rdx, rax
    movq xmm0, rdx
    cvttsd2si rax, xmm0
    mov rdx, rax
    cvtsi2sd xmm0, rdx
    movq rax, xmm0
    jmp .L682
.L681:
    mov rax, [rbp-40]
.L682:
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
.L678:
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
    je .L687
    mov rax, -1
    jmp .L688
.L687:
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
    je .L689
    mov rax, 1
    jmp .L690
.L689:
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
    je .L691
    mov rax, 0
    jmp .L692
.L691:
    mov rax, 2
.L692:
.L690:
.L688:
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
.L693_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_timespec@tpoff]
    mov rbx, rax
    mov rdi, 1
    mov rsi, rbx
    call zyl_rt_sys_228
    cmp rax, 0
    je .L693_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L693_1:
    mov rsi, qword ptr [rbx+0]
    imul rsi, rsi, 1000
    jo zyl_rt_trap_ovf_2
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
    mov rax, rsi
    add rax, rdi
    jo zyl_rt_trap_ovf_0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dmulhi:
    # frame 0
.L694_0:
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
.L695_0:
    mov rsi, 0
    mov r8, 32
    mov rdx, r8
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo
zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo:
    # frame 0
    mov r8, rdx
.L696_0:
    cmp r8, 0
    jne .L696_1
.L696_3:
    mov rax, rsi
    ret
.p2align 4
.L696_1:
    mov r9, 64
    sub r9, r8
    jo zyl_rt_trap_ovf_1
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
    jo zyl_rt_trap_ovf_1
    and r9, r10
    cmp r9, 0
    jne .L696_2
    mov rax, rdi
    mov rcx, r8
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 63
    add rax, rcx
    sar rax, 1
    mov r8, rax
    cmp r8, 0
    jne .L696_1
    jmp .L696_3
.L696_2:
    mov rcx, r8
    mov rax, rcx
    sar rax, 63
    shr rax, 63
    add rax, rcx
    sar rax, 1
    mov r8, rax
    cmp r8, 0
    jne .L696_1
    jmp .L696_3
zy_local_x2Fmain_0__fmt__fm_x2Disdig:
    # frame 0
.L697_0:
    cmp rdi, 48
    jl .L697_1
.L697_2:
    mov rax, rdi
    cmp rax, 57
    setle al
    movzx rax, al
    ret
.L697_1:
    mov rax, 0
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dtab:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L698_0:
    lea rax, [rip+zyl_rtg_fmt_tab]
    mov rbx, rax
    mov rax, qword ptr [rbx+10600]
    cmp rax, 1
    jne .L698_1
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L698_1:
    lea rax, [rip+.L699]
    mov rsi, rax
    mov rdi, 0
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dtab_x2Dfill
    mov rdi, rbx
    add rdi, 10416
    jo zyl_rt_trap_ovf_0
    mov rsi, 0
    movsd xmm0, [rip+.L700]
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
.L701_0:
    cmp rsi, 16
    jne .L701_1
.L701_2:
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L701_1:
    mov r13, rsi
    add r13, 1
    jo zyl_rt_trap_ovf_0
    shl r12, 4
    mov rdi, rbx
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    movzx edi, byte ptr [rdi+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rdi, rax
    or r12, rdi
    mov rsi, r13
    cmp rsi, 16
    jne .L701_1
    jmp .L701_2
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
.L702_0:
    cmp r13, 1302
    jne .L702_1
.L702_3:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L702_1:
    imul rsi, r13, 8
    jo zyl_rt_trap_ovf_2
    mov r14, rbx
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    imul rsi, r13, 16
    jo zyl_rt_trap_ovf_2
    mov rdi, r12
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, 0
    mov r8, 0
    mov r9, r8
    cmp rsi, 16
    je .L702_2
    mov rdx, r8
    call zy_local_x2Fmain_0__fmt__fm_x2Dhex16
    mov r9, rax
.L702_2:
    mov qword ptr [r14+0], r9
    add r13, 1
    jo zyl_rt_trap_ovf_0
    cmp r13, 1302
    jne .L702_1
    jmp .L702_3
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
    jne .L703
    mov rax, 0
    jmp .L704
.L703:
    mov rax, [rbp-16]
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    push rax
    movsd xmm0, [rip+.L705]
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
.L704:
    mov rbx, [rbp-136]
    mov r12, [rbp-128]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dp5_x2Dhex:
    # frame 0
.L706_0:
    lea rax, [rip+.L707]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dspace:
    # frame 0
.L708_0:
    cmp rdi, 32
    jne .L708_1
.L708_3:
    mov rax, 1
    ret
.L708_1:
    cmp rdi, 9
    jl .L708_2
    mov rax, rdi
    cmp rax, 13
    setle al
    movzx rax, al
    ret
.L708_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dskip_x2Dws:
    # frame 0
.L709_0:
    movzx esi, byte ptr [rdi+0]
    mov r8, 1
    cmp rsi, 32
    je .L709_2
    mov rax, rsi
    cmp rax, 13
    setle al
    movzx rax, al
    mov r9, rax
    cmp rsi, 9
    jge .L709_3
    mov r9, 0
.L709_3:
    mov r8, r9
.L709_2:
    cmp r8, 0
    je .L709_1
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L709_0
.L709_1:
    mov rax, rdi
    ret
.globl zyl_f_parse
zyl_f_parse:
    # frame 0
    push rbp
    mov rbp, rsp
.L710_0:
    cmp rdi, 0
    jne .L710_1
    mov rax, 0
    pop rbp
    ret
.L710_1:
    call zy_local_x2Fmain_0__fmt__fm_x2Dskip_x2Dws
    mov rsi, rax
    movzx edi, byte ptr [rsi+0]
    cmp rdi, 45
    jne .L710_2
    mov r8, rsi
    add r8, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, r8
    call zy_local_x2Fmain_0__fmt__fm_x2Dbody
    mov r8, rax
    mov r9, -9223372036854775808
    mov rdi, r8
    mov rsi, r9
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dsigned
.L710_2:
    cmp rdi, 43
    jne .L710_3
    mov rdi, rsi
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L710_4
.L710_3:
    mov rdi, rsi
.L710_4:
    call zy_local_x2Fmain_0__fmt__fm_x2Dbody
    mov rdi, rax
    mov rsi, 0
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dsigned
zy_local_x2Fmain_0__fmt__fm_x2Dsigned:
    # frame 0
.L711_0:
    cmp rdi, -1
    jne .L711_1
.L711_2:
    mov rax, 0
    ret
.L711_1:
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
    jne .L712
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dinf_x2Dword
    jmp .L713
.L712:
    mov rax, [rbp-16]
    mov rcx, 110
    cmp rax, rcx
    jne .L714
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dword
    jmp .L715
.L714:
    mov rax, [rbp-8]
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov rcx, 48
    cmp rax, rcx
    jne .L718
    mov rax, [rbp-8]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov rcx, 32
    or rax, rcx
    mov rcx, 120
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L719
.L718:
    mov rax, 0
.L719:
    test rax, rax
    je .L716
    sub rsp, 8
    sub rsp, 40
    mov rax, [rbp-8]
    mov rcx, 2
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jne .L720
    mov rax, 0
    jmp .L721
.L720:
    mov rax, [rbp-24]
.L721:
    jmp .L717
.L716:
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
.L717:
.L715:
.L713:
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dinf_x2Dword:
    # frame 0
.L722_0:
    movzx esi, byte ptr [rdi+1]
    or rsi, 32
    cmp rsi, 110
    jne .L722_1
    movzx esi, byte ptr [rdi+2]
    or rsi, 32
    cmp rsi, 102
    jne .L722_1
    mov rax, 9218868437227405312
    ret
.L722_1:
    mov rax, -1
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dword:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L723_0:
    movzx esi, byte ptr [rdi+1]
    or rsi, 32
    cmp rsi, 97
    jne .L723_1
    movzx esi, byte ptr [rdi+2]
    or rsi, 32
    cmp rsi, 110
    jne .L723_1
    movzx eax, byte ptr [rdi+3]
    cmp rax, 40
    jne .L723_2
    mov rbx, rdi
    add rbx, 4
    jo zyl_rt_trap_ovf_0
    add rdi, 4
    jo zyl_rt_trap_ovf_0
    call zy_local_x2Fmain_0__fmt__fm_x2Dseq_x2Dend
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dnan_x2Dseq
.L723_2:
    mov rax, 9221120237041090560
    pop rbx
    pop rbp
    ret
.L723_1:
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
.L724_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Disdig
    cmp rax, 0
    je .L724_1
    mov rax, 1
    pop rbx
    pop rbp
    ret
.L724_1:
    mov rax, rbx
    or rax, 32
    cmp rax, 97
    jl .L724_2
    mov rax, rbx
    or rax, 32
    cmp rax, 122
    jg .L724_2
    mov rax, 1
    pop rbx
    pop rbp
    ret
.L724_2:
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
.L725_0:
    movzx edi, byte ptr [rbx+0]
    call zy_local_x2Fmain_0__fmt__fm_x2Dalnum
    cmp rax, 0
    je .L725_1
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    jmp .L725_0
.L725_1:
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
.L726_0:
    movzx eax, byte ptr [r12+0]
    cmp rax, 41
    je .L726_1
    mov rax, 9221120237041090560
    pop r12
    pop rbx
    pop rbp
    ret
.L726_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dend
    cmp rax, r12
    jne .L726_2
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
.L726_2:
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
.L727_0:
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L727_1
    mov rax, rsi
    mov rcx, rbx
    cmp rax, rcx
    setl al
    movzx rax, al
    pop rbx
    pop rbp
    ret
.L727_1:
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase:
    # frame 0
    push rbp
    mov rbp, rsp
.L728_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 48
    jne .L728_1
    movzx esi, byte ptr [rdi+1]
    or rsi, 32
    cmp rsi, 120
    jne .L728_2
    movzx edi, byte ptr [rdi+2]
    mov rsi, 16
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    je .L728_2
    mov rax, 16
    pop rbp
    ret
.L728_2:
    mov rax, 8
    pop rbp
    ret
.L728_1:
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
.L729_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase
    mov r12, rax
    cmp r12, 16
    jne .L729_1
    mov rsi, rbx
    add rsi, 2
    jo zyl_rt_trap_ovf_0
    jmp .L729_2
.L729_1:
    mov rsi, rbx
.L729_2:
    mov r13, rsi
    movzx edi, byte ptr [r13+0]
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    je .L729_3
    mov rdi, r13
    mov rsi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fm_x2Ddigits_x2Dend
.L729_3:
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
.L730_0:
    movzx edi, byte ptr [rbx+0]
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    je .L730_1
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    jmp .L730_0
.L730_1:
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
.L731_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dull_x2Dbase
    mov rsi, rax
    cmp rsi, 16
    jne .L731_1
    mov rdi, rbx
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    jmp .L731_2
.L731_1:
    mov rdi, rbx
.L731_2:
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
.L732_0:
    mov rdx, qword ptr [rbp-48]
    movzx r15d, byte ptr [rdx+0]
    mov rdi, r15
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__fm_x2Dhexval_x2Dok
    cmp rax, 0
    jne .L732_1
    cmp r14, 0
    je .L732_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L732_2:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L732_1:
    cmp r14, 0
    je .L732_3
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    mov r14, 1
    jmp .L732_0
.L732_3:
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
    jne .L732_5
    mov rsi, -9223372036854775808
    xor rsi, r15
    mov rdi, -9223372036854775808
    mov rax, rbx
    xor rax, rdi
    cmp rsi, rax
    jge .L732_4
.L732_5:
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    mov r14, 1
    jmp .L732_0
.L732_4:
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    mov r13, r15
    mov r14, 0
    jmp .L732_0
zy_local_x2Fmain_0__fmt__fm_x2Dexp:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L733_0:
    movzx esi, byte ptr [rdi+0]
    mov rax, rsi
    cmp rax, 45
    sete al
    movzx rax, al
    mov rbx, rax
    cmp rsi, 45
    je .L733_3
    cmp rsi, 43
    jne .L733_1
.L733_3:
    mov rsi, rdi
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L733_2
.L733_1:
    mov rsi, rdi
.L733_2:
    mov rdi, 0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dgo
    mov rsi, rax
    cmp rbx, 0
    je .L733_4
    mov rdi, 0
    sub rdi, rsi
    jo zyl_rt_trap_ovf_1
    mov rax, rdi
    pop rbx
    pop rbp
    ret
.L733_4:
    mov rax, rsi
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dgo:
    # frame 0
.L734_0:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 48
    jl .L734_1
    cmp r8, 57
    jg .L734_1
    mov r9, rdi
    add r9, 1
    jo zyl_rt_trap_ovf_0
    mov rax, 1000000000000000
    cmp rsi, rax
    jge .L734_2
    imul r10, rsi, 10
    jo zyl_rt_trap_ovf_2
    sub r8, 48
    jo zyl_rt_trap_ovf_1
    add r10, r8
    jo zyl_rt_trap_ovf_0
    jmp .L734_3
.L734_2:
    mov r10, rsi
.L734_3:
    mov rsi, r10
    mov rdi, r9
    jmp .L734_0
.L734_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat:
    # frame 0
.L735_0:
    movzx r8d, byte ptr [rdi+0]
    or r8, 32
    cmp r8, rsi
    jne .L735_1
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dexp
.L735_1:
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
.L736_0:
    movzx r12d, byte ptr [rbx+0]
    mov rdi, r12
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L736_1
    mov rax, qword ptr [rbp-48]
    shr rax, 56
    cmp rax, 0
    jne .L736_2
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbp-48]
    imul rax, 16
    jo zyl_rt_trap_ovf_2
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-48]
    mov rcx, rsi
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    mov r15, 1
    jmp .L736_0
.L736_2:
    mov rdi, rbx
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov r8, r13
    add r8, 4
    jo zyl_rt_trap_ovf_0
    cmp r14, 0
    je .L736_3
    mov r9, 1
    jmp .L736_4
.L736_3:
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov r9, rax
.L736_4:
    mov r14, r9
    mov r15, 1
    mov rbx, rdi
    mov r13, r8
    jmp .L736_0
.L736_1:
    cmp r12, 46
    jne .L736_5
    mov rdi, rbx
    add rdi, 1
    jo zyl_rt_trap_ovf_0
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
.L736_5:
    cmp r15, 0
    je .L736_6
    mov rsi, 112
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat
    mov rsi, rax
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L736_6:
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
.L737_0:
    movzx edi, byte ptr [rbx+0]
    call zy_local_x2Fmain_0__text__rt_x2Dhexval
    mov rsi, rax
    cmp rsi, 0
    jl .L737_1
    mov rax, r12
    shr rax, 56
    cmp rax, 0
    jne .L737_2
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    imul r12, r12, 16
    jo zyl_rt_trap_ovf_2
    add r12, rsi
    jo zyl_rt_trap_ovf_0
    sub r13, 4
    jo zyl_rt_trap_ovf_1
    mov r15, 1
    jmp .L737_0
.L737_2:
    mov rdi, rbx
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    cmp r14, 0
    je .L737_3
    mov r8, 1
    jmp .L737_4
.L737_3:
    mov rax, rsi
    cmp rax, 0
    setg al
    movzx rax, al
    mov r8, rax
.L737_4:
    mov r14, r8
    mov r15, 1
    mov rbx, rdi
    jmp .L737_0
.L737_1:
    cmp r15, 0
    je .L737_5
    mov rsi, 112
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat
    mov rsi, rax
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov rdi, r12
    mov rdx, r14
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fh_x2Dround
.L737_5:
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
.L738_0:
    cmp rbx, 0
    jne .L738_1
.L738_8:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L738_1:
    mov r14, 63
    mov rsi, 0
    mov rdi, 32
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__fm_x2Dclz_x2Dgo
    mov rsi, rax
    sub r14, rsi
    jo zyl_rt_trap_ovf_1
    add r14, r12
    jo zyl_rt_trap_ovf_0
    cmp r14, 1023
    jle .L738_2
    mov rax, 9218868437227405312
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L738_2:
    mov rsi, -1074
    cmp r14, -1022
    jl .L738_3
    mov rsi, r14
    sub rsi, 52
    jo zyl_rt_trap_ovf_1
.L738_3:
    sub rsi, r12
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jg .L738_4
    mov rdi, 0
    sub rdi, rsi
    jo zyl_rt_trap_ovf_1
    mov rax, rbx
    mov rcx, rdi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    jmp .L738_5
.L738_4:
    mov rdi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__fmt__fh_x2Dshift_x2Dround
    mov rdi, rax
.L738_5:
    mov rsi, rdi
    cmp r14, -1022
    jl .L738_6
    mov r8, r14
    add r8, 1022
    jo zyl_rt_trap_ovf_0
    shl r8, 52
    mov rsi, rdi
    add rsi, r8
    jo zyl_rt_trap_ovf_0
.L738_6:
    mov rax, 9218868437227405312
    cmp rsi, rax
    jl .L738_7
    mov rax, 9218868437227405312
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L738_7:
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
.L739_0:
    cmp rsi, 62
    jle .L739_1
.L739_5:
    mov rax, 0
    ret
.L739_1:
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
    jo zyl_rt_trap_ovf_1
    and rdi, r10
    mov r10, 1
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    mov rax, r10
    mov rcx, rsi
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    cmp rdi, rsi
    jg .L739_3
    cmp rdi, rsi
    jne .L739_2
    cmp r8, 0
    jne .L739_4
    mov rax, r9
    and rax, 1
    cmp rax, 1
    jne .L739_2
.L739_4:
.L739_3:
    mov rax, r9
    add rax, 1
    jo zyl_rt_trap_ovf_0
    ret
.L739_2:
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
    jl .L742
    mov rax, [rbp-64]
    mov rcx, 57
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L743
.L742:
    mov rax, 0
.L743:
    test rax, rax
    je .L740
    mov rax, [rbp-56]
    test rax, rax
    je .L744
    mov rax, [rbp-40]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    jmp .L745
.L744:
    mov rax, [rbp-40]
.L745:
    mov [rbp-72], rax
    mov rax, [rbp-32]
    mov rcx, 0
    cmp rax, rcx
    jne .L748
    mov rax, [rbp-64]
    mov rcx, 48
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L749
.L748:
    mov rax, 0
.L749:
    test rax, rax
    je .L746
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L747
.L746:
    mov rax, [rbp-32]
    mov rcx, 19
    cmp rax, rcx
    jge .L750
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 10
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    push rax
    mov rax, [rbp-64]
    mov rcx, 48
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov rcx, rax
    pop rax
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L751
.L750:
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
.L751:
.L747:
    jmp .L741
.L740:
    mov rax, [rbp-64]
    mov rcx, 46
    cmp rax, rcx
    jne .L754
    mov rax, [rbp-56]
    test rax, rax
    je .L756
    mov rax, 0
    jmp .L757
.L756:
    mov rax, 1
.L757:
    jmp .L755
.L754:
    mov rax, 0
.L755:
    test rax, rax
    je .L752
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-16]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L753
.L752:
    mov rax, [rbp-48]
    test rax, rax
    je .L760
    mov rax, 0
    jmp .L761
.L760:
    mov rax, 1
.L761:
    test rax, rax
    je .L758
    mov rax, -1
    jmp .L759
.L758:
    sub rsp, 16
    mov rdi, [rbp-16]
    mov rsi, 101
call zy_local_x2Fmain_0__fmt__fm_x2Dexp_x2Dat
    add rsp, 16
    mov [rbp-80], rax
    mov rax, [rbp-32]
    mov rcx, 0
    cmp rax, rcx
    jne .L762
    mov rax, 0
    jmp .L763
.L762:
    mov rax, [rbp-32]
    mov rcx, 19
    cmp rax, rcx
    jg .L764
    mov rax, [rbp-24]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-80]
    mov rcx, [rbp-40]
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    sub rsp, 8
    mov [rsp], rax
    mov rsi, [rsp+0]
    mov rdi, [rsp+8]
    mov rbx, [rbp-184]
    mov r12, [rbp-176]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__fd_x2Dexact
    jmp .L765
.L764:
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
    jo zyl_rt_trap_ovf_1
    push rax
    mov rax, [rbp-32]
    mov rcx, 19
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov rcx, rax
    pop rax
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
.L765:
.L763:
.L759:
.L753:
.L741:
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
    jl .L770
    mov rax, [rbp-16]
    mov rcx, 22
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L771
.L770:
    mov rax, 0
.L771:
    test rax, rax
    je .L768
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jl .L772
    mov rax, [rbp-8]
    mov rcx, 9007199254740992
    cmp rax, rcx
    setle al
    movzx rax, al
    jmp .L773
.L772:
    mov rax, 0
.L773:
    jmp .L769
.L768:
    mov rax, 0
.L769:
    test rax, rax
    je .L766
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
    jl .L774
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, 10416
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-24]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    mulsd xmm0, xmm1
    movq rax, xmm0
    jmp .L775
.L774:
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rcx, [rbp-16]
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, 10416
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rcx, rax
    mov rax, [rbp-24]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    divsd xmm0, xmm1
    movq rax, xmm0
.L775:
    jmp .L767
.L766:
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
.L767:
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
.L776_0:
    mov rdi, r14
    mov rsi, r13
    call zy_local_x2Fmain_0__fmt__fm_x2Del
    mov r15, rax
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, r14
    call zy_local_x2Fmain_0__fmt__fm_x2Del
    cmp r15, rax
    jne .L776_1
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L776_1:
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
.L777_0:
    cmp rbx, -342
    jge .L777_1
.L777_6:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L777_1:
    cmp rbx, 308
    jle .L777_2
    mov rax, 9218868437227405312
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L777_2:
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
    mov rsi, rbx
    add rsi, 342
    jo zyl_rt_trap_ovf_0
    imul rsi, rsi, 16
    jo zyl_rt_trap_ovf_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
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
    jne .L777_3
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
    jge .L777_4
    mov rdi, 1
    add rdi, qword ptr [rbp-48]
    jmp .L777_5
.L777_4:
    mov rdi, qword ptr [rbp-48]
.L777_5:
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
.L777_3:
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
.L778_0:
    mov r10, r9
    shr r10, 63
    mov r11, r10
    add r11, 9
    jo zyl_rt_trap_ovf_0
    mov rax, r9
    mov rcx, r11
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rbx, rax
    imul r12, rdi, 217706
    jo zyl_rt_trap_ovf_2
    sar r12, 16
    add r12, 63
    jo zyl_rt_trap_ovf_0
    add r12, r10
    jo zyl_rt_trap_ovf_0
    mov rax, r12
    mov rcx, rsi
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov rsi, rax
    add rsi, 1023
    jo zyl_rt_trap_ovf_0
    cmp rsi, 0
    jg .L778_1
    mov r10, 0
    sub r10, rsi
    jo zyl_rt_trap_ovf_1
    mov rax, r10
    add rax, 1
    jo zyl_rt_trap_ovf_0
    cmp rax, 64
    jl .L778_2
    mov rax, 0
    pop r12
    pop rbx
    ret
.L778_2:
    mov r10, 0
    sub r10, rsi
    jo zyl_rt_trap_ovf_1
    add r10, 1
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    shr r10, 1
    mov rax, r10
    pop r12
    pop rbx
    ret
.L778_1:
    mov r10, -9223372036854775808
    xor r8, r10
    mov r10, -9223372036854775808
    xor r10, 2
    cmp r8, r10
    jge .L778_3
    cmp rdi, -4
    jl .L778_3
    cmp rdi, 23
    jg .L778_3
    mov rax, rbx
    and rax, 3
    cmp rax, 1
    jne .L778_3
    mov rax, rbx
    mov rcx, r11
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    cmp rax, r9
    jne .L778_3
    mov rdi, rbx
    and rdi, -2
    jmp .L778_4
.L778_3:
    mov rdi, rbx
.L778_4:
    mov r8, rdi
    and r8, 1
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    shr rdi, 1
    mov rax, 9007199254740992
    cmp rdi, rax
    jl .L778_5
    mov r8, rsi
    add r8, 1
    jo zyl_rt_trap_ovf_0
    jmp .L778_6
.L778_5:
    mov r8, rsi
.L778_6:
    mov rsi, 0
    mov rax, 9007199254740992
    cmp rdi, rax
    jge .L778_7
    mov r9, 4503599627370495
    mov rsi, rdi
    and rsi, r9
.L778_7:
    cmp r8, 2047
    jl .L778_8
    mov rax, 9218868437227405312
    pop r12
    pop rbx
    ret
.L778_8:
    mov rdi, r8
    shl rdi, 52
    mov rax, rsi
    or rax, rdi
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dbuf:
    # frame 0
.L779_0:
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
.L780_0:
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
    jo zyl_rt_trap_ovf_0
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
.L781_0:
    movzx r9d, byte ptr [rsi+0]
    cmp r9, 48
    jl .L781_1
    cmp r9, 57
    jg .L781_1
    mov r10, qword ptr [rdi+0]
    cmp r10, 0
    jne .L781_2
    cmp r9, 48
    jne .L781_2
    cmp r8, 0
    je .L781_3
    mov r11, qword ptr [rdi+8]
    sub r11, 1
    jo zyl_rt_trap_ovf_1
    mov qword ptr [rdi+8], r11
    jmp .L781_4
.L781_3:
.L781_4:
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L781_0
.L781_2:
    cmp r10, 800
    jge .L781_5
    mov r11, rdi
    add r11, 32
    jo zyl_rt_trap_ovf_0
    add r11, r10
    jo zyl_rt_trap_ovf_0
    mov rbx, r9
    sub rbx, 48
    jo zyl_rt_trap_ovf_1
    mov byte ptr [r11+0], bl
    add r10, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+0], r10
    jmp .L781_6
.L781_5:
    cmp r9, 48
    je .L781_7
    mov r10, 1
    mov qword ptr [rdi+16], r10
.L781_7:
.L781_6:
    cmp r8, 0
    je .L781_8
    jmp .L781_9
.L781_8:
    mov r10, qword ptr [rdi+8]
    add r10, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+8], r10
.L781_9:
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L781_0
.L781_1:
    cmp r9, 46
    jne .L781_10
    cmp r8, 0
    jne .L781_10
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov r8, 1
    jmp .L781_0
.L781_10:
    mov rax, 0
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dtrim:
    # frame 0
.L782_0:
    mov rsi, qword ptr [rdi+0]
    cmp rsi, 0
    jle .L782_1
    mov r8, rdi
    add r8, 32
    jo zyl_rt_trap_ovf_0
    mov r9, rsi
    sub r9, 1
    jo zyl_rt_trap_ovf_1
    add r8, r9
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r8+0]
    cmp rax, 0
    jne .L782_1
    mov r8, rsi
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    mov qword ptr [rdi+0], r8
    jmp .L782_0
.L782_1:
    cmp rsi, 0
    jne .L782_2
    mov rsi, 0
    mov qword ptr [rdi+8], rsi
    mov rax, rsi
    ret
.L782_2:
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
.L783_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L783_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L783_1:
    cmp r12, 25
    jle .L783_2
    mov rsi, 25
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dlshift
    sub r12, 25
    jo zyl_rt_trap_ovf_1
    jmp .L783_0
.L783_2:
    cmp r12, 0
    jle .L783_3
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dlshift
.L783_3:
    cmp r12, -59
    jge .L783_4
    mov rsi, 59
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    call zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
    add r12, 59
    jo zyl_rt_trap_ovf_0
    jmp .L783_0
.L783_4:
    cmp r12, 0
    jge .L783_5
    mov rsi, 0
    sub rsi, r12
    jo zyl_rt_trap_ovf_1
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, rbx
    mov rcx, r8
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
.L783_5:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Drshift:
    # frame 0
.L784_0:
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dread:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L785_0:
    mov rax, r9
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    cmp rax, 0
    jne .L785_1
    mov rax, qword ptr [rdi+0]
    cmp r8, rax
    jl .L785_2
    cmp r9, 0
    jne .L785_3
    mov r10, 0
    mov qword ptr [rdi+0], r10
    mov r10, 0
    mov qword ptr [rdi+8], r10
    mov rax, r10
    ret
.L785_3:
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dpad
.L785_2:
    mov r10, r8
    add r10, 1
    jo zyl_rt_trap_ovf_0
    imul r9, r9, 10
    jo zyl_rt_trap_ovf_2
    mov r11, rdi
    add r11, 32
    jo zyl_rt_trap_ovf_0
    add r11, r8
    jo zyl_rt_trap_ovf_0
    movzx r11d, byte ptr [r11+0]
    add r9, r11
    jo zyl_rt_trap_ovf_0
    mov r8, r10
    jmp .L785_0
.L785_1:
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dpad:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L786_0:
    mov rax, r9
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    cmp rax, 0
    jne .L786_1
    add r8, 1
    jo zyl_rt_trap_ovf_0
    imul r9, r9, 10
    jo zyl_rt_trap_ovf_2
    jmp .L786_0
.L786_1:
    mov rdx, r8
    mov rcx, r9
    jmp zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart
zy_local_x2Fmain_0__fmt__sd_x2Drs_x2Dstart:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L787_0:
    mov r10, qword ptr [rdi+8]
    mov r11, r8
    sub r11, 1
    jo zyl_rt_trap_ovf_1
    sub r10, r11
    jo zyl_rt_trap_ovf_1
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
    jo zyl_rt_trap_ovf_1
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
.L788_0:
    mov rax, qword ptr [rdi+0]
    cmp r9, rax
    jge .L788_1
    mov rbx, rdi
    add rbx, 32
    jo zyl_rt_trap_ovf_0
    add rbx, r10
    jo zyl_rt_trap_ovf_0
    mov rax, r11
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r12, rax
    mov byte ptr [rbx+0], r12b
    mov rbx, r9
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    add r10, 1
    jo zyl_rt_trap_ovf_0
    mov r12, r11
    and r12, r8
    imul r12, r12, 10
    jo zyl_rt_trap_ovf_2
    mov r13, rdi
    add r13, 32
    jo zyl_rt_trap_ovf_0
    add r13, r9
    jo zyl_rt_trap_ovf_0
    movzx r13d, byte ptr [r13+0]
    mov r11, r12
    add r11, r13
    jo zyl_rt_trap_ovf_0
    mov r9, rbx
    jmp .L788_0
.L788_1:
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
.L789_0:
    cmp r10, 0
    jle .L789_1
.L789_5:
    mov rax, r10
    mov rcx, rsi
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r11, rax
    cmp r9, 800
    jge .L789_2
    mov rbx, rdi
    add rbx, 32
    jo zyl_rt_trap_ovf_0
    add rbx, r9
    jo zyl_rt_trap_ovf_0
    mov byte ptr [rbx+0], r11b
    add r9, 1
    jo zyl_rt_trap_ovf_0
    and r10, r8
    imul r10, r10, 10
    jo zyl_rt_trap_ovf_2
    cmp r10, 0
    jle .L789_1
    jmp .L789_5
.L789_2:
    cmp r11, 0
    jle .L789_3
    mov r11, 1
    mov qword ptr [rdi+16], r11
    jmp .L789_4
.L789_3:
.L789_4:
    and r10, r8
    imul r10, r10, 10
    jo zyl_rt_trap_ovf_2
    cmp r10, 0
    jle .L789_1
    jmp .L789_5
.L789_1:
    mov qword ptr [rdi+0], r9
    pop rbx
    jmp zy_local_x2Fmain_0__fmt__sd_x2Dtrim
zy_local_x2Fmain_0__fmt__fm_x2Dndig:
    # frame 0
.L790_0:
    cmp rdi, 10
    jge .L790_1
.L790_2:
    mov rax, rsi
    ret
.p2align 4
.L790_1:
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
    jo zyl_rt_trap_ovf_0
    cmp rdi, 10
    jge .L790_1
    jmp .L790_2
zy_local_x2Fmain_0__fmt__fm_x2Dpow5:
    # frame 0
.L791_0:
    cmp rdi, 0
    jne .L791_1
.L791_2:
    mov rax, rsi
    ret
.p2align 4
.L791_1:
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    imul rsi, rsi, 5
    jo zyl_rt_trap_ovf_2
    cmp rdi, 0
    jne .L791_1
    jmp .L791_2
zy_local_x2Fmain_0__fmt__sd_x2Dprefix:
    # frame 16
    push rbx
    mov r8, rdx
    mov r9, rcx
.L792_0:
    cmp rsi, r8
    jne .L792_1
.L792_4:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L792_1:
    mov r10, rsi
    add r10, 1
    jo zyl_rt_trap_ovf_0
    imul r11, r9, 10
    jo zyl_rt_trap_ovf_2
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jge .L792_2
    mov rbx, rdi
    add rbx, 32
    jo zyl_rt_trap_ovf_0
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    movzx ebx, byte ptr [rbx+0]
    jmp .L792_3
.L792_2:
    mov rbx, 0
.L792_3:
    mov r9, r11
    add r9, rbx
    jo zyl_rt_trap_ovf_0
    mov rsi, r10
    cmp rsi, r8
    jne .L792_1
    jmp .L792_4
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
.L793_0:
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
    jge .L793_1
    mov rax, r12
    sub rax, 1
    jo zyl_rt_trap_ovf_1
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L793_1:
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
.L794_0:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__fmt__sd_x2Ddelta
    mov r13, rax
    mov r14, qword ptr [rbx+0]
    mov rsi, r14
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    mov rdi, r14
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    mov r8, 0
    mov rdx, rsi
    mov rsi, r12
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dls_x2Dgo
    mov rsi, r14
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov rdi, 800
    cmp rsi, 800
    jge .L794_1
    mov rdi, rsi
.L794_1:
    mov qword ptr [rbx+0], rdi
    mov rsi, qword ptr [rbx+8]
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L795_0:
    cmp rsi, 800
    jge .L795_1
.L795_3:
    mov r9, rdi
    add r9, 32
    jo zyl_rt_trap_ovf_0
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    mov byte ptr [r9+0], r8b
    mov rsi, r8
    mov rax, rsi
    ret
.L795_1:
    cmp r8, 0
    jne .L795_2
    mov rax, 0
    ret
.L795_2:
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
.L796_0:
    cmp r8, 0
    jl .L796_1
.L796_9:
    mov r11, rdi
    add r11, 32
    jo zyl_rt_trap_ovf_0
    add r11, r8
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    mov rcx, r11
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 2
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rbx, rax
    mov r12, r9
    sub r12, 1
    jo zyl_rt_trap_ovf_1
    imul r13, rbx, 10
    jo zyl_rt_trap_ovf_2
    sub r11, r13
    jo zyl_rt_trap_ovf_1
    cmp r12, 800
    jge .L796_2
    mov r13, rdi
    add r13, 32
    jo zyl_rt_trap_ovf_0
    add r13, r12
    jo zyl_rt_trap_ovf_0
    mov byte ptr [r13+0], r11b
    jmp .L796_3
.L796_2:
    cmp r11, 0
    je .L796_4
    mov r11, 1
    mov qword ptr [rdi+16], r11
.L796_4:
.L796_3:
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    sub r9, 1
    jo zyl_rt_trap_ovf_1
    mov r10, rbx
    cmp r8, 0
    jl .L796_1
    jmp .L796_9
.p2align 4
.L796_1:
    cmp r10, 0
    jle .L796_5
    mov rcx, r10
    movabs rax, 7378697629483820647
    imul rcx
    sar rdx, 2
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov r11, rax
    mov rbx, r9
    sub rbx, 1
    jo zyl_rt_trap_ovf_1
    imul r12, r11, 10
    jo zyl_rt_trap_ovf_2
    mov rax, r10
    mov rcx, r12
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov r12, rax
    cmp rbx, 800
    jge .L796_6
    mov r13, rdi
    add r13, 32
    jo zyl_rt_trap_ovf_0
    add r13, rbx
    jo zyl_rt_trap_ovf_0
    mov byte ptr [r13+0], r12b
    jmp .L796_7
.L796_6:
    cmp r12, 0
    je .L796_8
    mov rbx, 1
    mov qword ptr [rdi+16], rbx
.L796_8:
.L796_7:
    mov r8, -1
    sub r9, 1
    jo zyl_rt_trap_ovf_1
    mov r10, r11
    cmp r8, 0
    jl .L796_1
    jmp .L796_9
.L796_5:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dpowtab:
    # frame 0
.L797_0:
    cmp rdi, 0
    jne .L797_1
.L797_9:
    mov rax, 1
    ret
.L797_1:
    cmp rdi, 1
    jne .L797_2
    mov rax, 3
    ret
.L797_2:
    cmp rdi, 2
    jne .L797_3
    mov rax, 6
    ret
.L797_3:
    cmp rdi, 3
    jne .L797_4
    mov rax, 9
    ret
.L797_4:
    cmp rdi, 4
    jne .L797_5
    mov rax, 13
    ret
.L797_5:
    cmp rdi, 5
    jne .L797_6
    mov rax, 16
    ret
.L797_6:
    cmp rdi, 6
    jne .L797_7
    mov rax, 19
    ret
.L797_7:
    cmp rdi, 7
    jne .L797_8
    mov rax, 23
    ret
.L797_8:
    mov rax, 26
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dstep:
    # frame 0
.L798_0:
    cmp rdi, 9
    jl .L798_1
.L798_2:
    mov rax, 27
    ret
.L798_1:
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
.L799_0:
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jle .L799_1
    mov rdi, qword ptr [rbx+8]
    call zy_local_x2Fmain_0__fmt__sd_x2Dstep
    mov r13, rax
    mov rsi, 0
    sub rsi, r13
    jo zyl_rt_trap_ovf_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    add r12, r13
    jo zyl_rt_trap_ovf_0
    jmp .L799_0
.L799_1:
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
.L800_0:
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jl .L800_2
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L800_1
    mov rsi, rbx
    add rsi, 32
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rsi+0]
    cmp rax, 5
    jge .L800_1
.L800_2:
    mov rdi, 0
    mov rsi, qword ptr [rbx+8]
    sub rdi, rsi
    jo zyl_rt_trap_ovf_1
    call zy_local_x2Fmain_0__fmt__sd_x2Dstep
    mov r13, rax
    mov rdi, rbx
    mov rsi, r13
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    sub r12, r13
    jo zyl_rt_trap_ovf_1
    jmp .L800_0
.L800_1:
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
.L801_0:
    mov rax, qword ptr [rbx+0]
    cmp rax, 0
    jne .L801_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L801_1:
    mov rax, qword ptr [rbx+8]
    cmp rax, 310
    jle .L801_2
    mov rax, 9218868437227405312
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L801_2:
    mov rax, qword ptr [rbx+8]
    cmp rax, -330
    jge .L801_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L801_3:
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Ddown
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dscale_x2Dup
    mov r12, rax
    sub r12, 1
    jo zyl_rt_trap_ovf_1
    cmp r12, -1022
    jge .L801_4
    mov r13, -1022
    sub r13, r12
    jo zyl_rt_trap_ovf_1
    mov rsi, 0
    sub rsi, r13
    jo zyl_rt_trap_ovf_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    mov rsi, r12
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    jmp .L801_5
.L801_4:
    mov rsi, r12
.L801_5:
    mov r12, rsi
    mov rax, r12
    add rax, 1023
    jo zyl_rt_trap_ovf_0
    cmp rax, 2047
    jl .L801_6
    mov rax, 9218868437227405312
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L801_6:
    mov rsi, 53
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Dshift
    mov rdi, rbx
    call zy_local_x2Fmain_0__fmt__sd_x2Drounded
    mov rsi, rax
    mov rax, 9007199254740992
    cmp rsi, rax
    jne .L801_7
    mov rdi, r12
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L801_8
.L801_7:
    mov rdi, r12
.L801_8:
    mov r8, 4503599627370496
    mov rax, 9007199254740992
    cmp rsi, rax
    je .L801_9
    mov r8, rsi
.L801_9:
    mov rax, rdi
    add rax, 1023
    jo zyl_rt_trap_ovf_0
    cmp rax, 2047
    jl .L801_10
    mov rax, 9218868437227405312
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L801_10:
    mov rsi, 4503599627370496
    mov rax, r8
    and rax, rsi
    cmp rax, 0
    jne .L801_11
    mov rsi, -1023
    jmp .L801_12
.L801_11:
    mov rsi, rdi
.L801_12:
    mov rdi, 4503599627370495
    and rdi, r8
    add rsi, 1023
    jo zyl_rt_trap_ovf_0
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
.L802_0:
    cmp rsi, r8
    jl .L802_1
.L802_4:
    mov rax, r9
    pop rbx
    ret
.p2align 4
.L802_1:
    mov r10, rsi
    add r10, 1
    jo zyl_rt_trap_ovf_0
    imul r11, r9, 10
    jo zyl_rt_trap_ovf_2
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jge .L802_2
    mov rbx, rdi
    add rbx, 32
    jo zyl_rt_trap_ovf_0
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    movzx ebx, byte ptr [rbx+0]
    jmp .L802_3
.L802_2:
    mov rbx, 0
.L802_3:
    mov r9, r11
    add r9, rbx
    jo zyl_rt_trap_ovf_0
    mov rsi, r10
    cmp rsi, r8
    jl .L802_1
    jmp .L802_4
zy_local_x2Fmain_0__fmt__sd_x2Drounded:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L803_0:
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
    je .L803_1
    mov rax, r13
    add rax, 1
    jo zyl_rt_trap_ovf_0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L803_1:
    mov rax, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__fmt__sd_x2Dround_x2Dup:
    # frame 0
.L804_0:
    cmp rsi, 0
    jl .L804_2
.L804_6:
    mov rax, qword ptr [rdi+0]
    cmp rsi, rax
    jl .L804_1
.L804_2:
    mov rax, 0
    ret
.L804_1:
    mov r8, rdi
    add r8, 32
    jo zyl_rt_trap_ovf_0
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r8+0]
    cmp rax, 5
    jne .L804_3
    mov r8, rsi
    add r8, 1
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rdi+0]
    cmp r8, rax
    jne .L804_3
    mov rax, qword ptr [rdi+16]
    cmp rax, 1
    jne .L804_4
    mov rax, 1
    ret
.L804_4:
    cmp rsi, 0
    jle .L804_5
    mov r8, rdi
    add r8, 32
    jo zyl_rt_trap_ovf_0
    mov r9, rsi
    sub r9, 1
    jo zyl_rt_trap_ovf_1
    add r8, r9
    jo zyl_rt_trap_ovf_0
    movzx r8d, byte ptr [r8+0]
    and r8, 1
    mov rax, r8
    cmp rax, 1
    sete al
    movzx rax, al
    ret
.L804_5:
    mov rax, 0
    ret
.L804_3:
    add rdi, 32
    jo zyl_rt_trap_ovf_0
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
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
.L805_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext
.globl zyl_f_text_r
zyl_f_text_r:
    # frame 0
.L806_0:
    mov rax, QWORD PTR fs:zyl_cur_region@tpoff
    mov rsi, rax
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext
zy_local_x2Fmain_0__fmt__fm_x2Dtext:
    # frame 0
.L807_0:
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
    jne .L807_1
    cmp rdi, 0
    jne .L807_2
    cmp r8, 0
    je .L807_3
    lea rax, [rip+.L808]
    mov r10, rax
    mov r11, 4
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L807_3:
    lea rax, [rip+.L809]
    mov r10, rax
    mov r11, 3
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L807_2:
    cmp r8, 0
    je .L807_4
    lea rax, [rip+.L810]
    mov r10, rax
    mov r11, 4
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L807_4:
    lea rax, [rip+.L811]
    mov r10, rax
    mov r11, 3
    mov rdi, r10
    mov rdx, rsi
    mov rsi, r11
    jmp zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
.L807_1:
    mov r10, rdi
    cmp r9, 0
    je .L807_5
    mov r11, 4503599627370496
    mov r10, rdi
    or r10, r11
.L807_5:
    mov rdi, -1074
    cmp r9, 0
    je .L807_6
    mov rdi, r9
    sub rdi, 1075
    jo zyl_rt_trap_ovf_1
.L807_6:
    cmp rdi, 10
    jle .L807_7
    mov rdx, rdi
    mov rdi, r8
    mov rcx, rsi
    mov rsi, r10
    jmp zy_local_x2Fmain_0__fmt__fm_x2Dtext_x2Dbig
.L807_7:
    cmp rdi, 0
    jl .L807_8
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
.L807_8:
    mov r9, 0
    sub r9, rdi
    jo zyl_rt_trap_ovf_1
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
.L812_0:
    cmp r12, 76
    jl .L812_1
.L812_8:
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
.L812_1:
    mov rax, rsi
    mov rcx, r12
    mov rdx, rcx
    shr rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rdi, rax
    cmp r12, 64
    jl .L812_2
    mov rdi, 0
.L812_2:
    mov r14, rdi
    cmp r12, 64
    jge .L812_3
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
    jo zyl_rt_trap_ovf_1
    and rdi, rsi
    jmp .L812_4
.L812_3:
    mov rdi, rsi
.L812_4:
    mov rsi, 1000000
    mov r15, rdi
    imul r15, rsi
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
    je .L812_5
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L812_6
.L812_5:
    mov rsi, r13
.L812_6:
    cmp rsi, 1000000
    jne .L812_7
    mov rdi, r14
    add rdi, 1
    jo zyl_rt_trap_ovf_0
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
.L812_7:
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
.L813_0:
    cmp rdi, 64
    jge .L813_1
.L813_2:
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
    jo zyl_rt_trap_ovf_1
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
.L813_1:
    mov rsi, rdi
    sub rsi, 64
    jo zyl_rt_trap_ovf_1
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
.L814_0:
    cmp rdi, 64
    jge .L814_1
.L814_10:
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
    jo zyl_rt_trap_ovf_1
    and r10, rsi
    mov r11, 1
    mov rbx, rdi
    sub rbx, 1
    jo zyl_rt_trap_ovf_1
    mov rax, r11
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r11, rax
    cmp r10, r11
    jle .L814_2
    mov rax, 1
    pop rbx
    ret
.L814_2:
    cmp r10, r11
    jne .L814_3
    mov rax, r9
    pop rbx
    ret
.L814_3:
    mov rax, 0
    pop rbx
    ret
.L814_1:
    sub rdi, 64
    jo zyl_rt_trap_ovf_1
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
    jo zyl_rt_trap_ovf_1
    and r8, r10
    mov r10, 0
    cmp rdi, 0
    je .L814_4
    mov r11, 1
    mov rbx, rdi
    sub rbx, 1
    jo zyl_rt_trap_ovf_1
    mov rax, r11
    mov rcx, rbx
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov r10, rax
.L814_4:
    mov r11, -9223372036854775808
    cmp rdi, 0
    je .L814_5
    mov r11, 0
.L814_5:
    cmp r8, r10
    jle .L814_6
    mov rax, 1
    pop rbx
    ret
.L814_6:
    cmp r8, r10
    jne .L814_7
    mov rdi, -9223372036854775808
    xor rdi, r11
    mov r8, -9223372036854775808
    mov rax, rsi
    xor rax, r8
    cmp rdi, rax
    jge .L814_8
    mov rax, 1
    pop rbx
    ret
.L814_8:
    cmp rsi, r11
    jne .L814_9
    mov rax, r9
    pop rbx
    ret
.L814_9:
    mov rax, 0
    pop rbx
    ret
.L814_7:
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
.L815_0:
    cmp rbx, 0
    je .L815_1
.L815_5:
    mov rsi, 1
    jmp .L815_2
.L815_1:
    mov rsi, 0
.L815_2:
    mov r15, rsi
    mov rdi, 0
    sub rdi, r12
    jo zyl_rt_trap_ovf_1
    call zy_local_x2Fmain_0__text__rt_x2Dndigits
    mov r13, rax
    mov rax, r15
    mov rcx, r13
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-56], rax
    mov rax, qword ptr [rbp-56]
    add rax, 7
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-56], rax
    mov rdi, qword ptr [rbp-56]
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, r14
    call zyl_ralloc
    mov r14, rax
    cmp rbx, 0
    je .L815_3
    mov rsi, 45
    mov rcx, rsi
    mov byte ptr [r14+0], cl
    jmp .L815_4
.L815_3:
.L815_4:
    mov rsi, 0
    sub rsi, r12
    jo zyl_rt_trap_ovf_1
    mov rdi, r15
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    mov rsi, r15
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rdi, 46
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, r15
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, r14
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, 6
    call zy_local_x2Fmain_0__fmt__fm_x2Dzeros
    mov rsi, 0
    sub rsi, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_1
    mov rdi, qword ptr [rbp-56]
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    mov rsi, r14
    add rsi, qword ptr [rbp-56]
    jo zyl_rt_trap_ovf_0
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
.L816_0:
    cmp rsi, 0
    jne .L816_1
.L816_2:
    mov rax, 0
    ret
.p2align 4
.L816_1:
    mov r8, 48
    mov byte ptr [rdi+0], r8b
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jne .L816_1
    jmp .L816_2
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
.L817_0:
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
.L818_0:
    cmp r12, 0
    jne .L818_1
.L818_3:
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L818_1:
    mov rdi, 32
    cmp r12, 32
    jg .L818_2
    mov rdi, r12
.L818_2:
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
    jo zyl_rt_trap_ovf_1
    cmp r12, 0
    jne .L818_1
    jmp .L818_3
zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dmul:
    # frame 32
    push rbx
    push r12
    push r13
    mov r9, rcx
    mov r10, r8
    mov r8, rdx
.L819_0:
    cmp rsi, r8
    jge .L819_1
.L819_3:
    imul r11, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r11, rdi
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    mov rcx, r11
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov rbx, rax
    imul r12, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r12, rdi
    jo zyl_rt_trap_ovf_0
    imul r13, rbx, 1000000000
    jo zyl_rt_trap_ovf_2
    sub r11, r13
    jo zyl_rt_trap_ovf_1
    mov qword ptr [r12+0], r11
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov r10, rbx
    cmp rsi, r8
    jge .L819_1
    jmp .L819_3
.p2align 4
.L819_1:
    cmp r10, 0
    jle .L819_2
    mov rcx, r10
    movabs rax, 1237940039285380275
    imul rcx
    sar rdx, 26
    mov rax, rcx
    sar rax, 63
    sub rdx, rax
    mov rax, rdx
    mov r11, rax
    imul rbx, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rbx, rdi
    jo zyl_rt_trap_ovf_0
    imul r12, r11, 1000000000
    jo zyl_rt_trap_ovf_2
    mov rax, r10
    mov rcx, r12
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov r12, rax
    mov qword ptr [rbx+0], r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add r8, 1
    jo zyl_rt_trap_ovf_0
    mov r10, r11
    cmp rsi, r8
    jge .L819_1
    jmp .L819_3
.L819_2:
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
.L820_0:
    cmp rbx, 0
    je .L820_1
.L820_5:
    mov rsi, 1
    jmp .L820_2
.L820_1:
    mov rsi, 0
.L820_2:
    mov qword ptr [rbp-48], rsi
    mov rsi, r13
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rsi, qword ptr [rbp-56]
    jo zyl_rt_trap_ovf_0
    mov r15, qword ptr [rsi+0]
    mov rdi, 0
    sub rdi, r15
    jo zyl_rt_trap_ovf_1
    call zy_local_x2Fmain_0__text__rt_x2Dndigits
    mov r12, rax
    mov rsi, r13
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    imul rsi, rsi, 9
    jo zyl_rt_trap_ovf_2
    mov rax, r12
    mov rcx, rsi
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-64], rax
    mov rax, qword ptr [rbp-48]
    mov rcx, qword ptr [rbp-64]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-72], rax
    mov rax, qword ptr [rbp-72]
    add rax, 7
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-72], rax
    mov rdi, qword ptr [rbp-72]
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, r14
    call zyl_ralloc
    mov r14, rax
    cmp rbx, 0
    je .L820_3
    mov rsi, 45
    mov rcx, rsi
    mov byte ptr [r14+0], cl
    jmp .L820_4
.L820_3:
.L820_4:
    mov rdi, r14
    add rdi, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov rsi, qword ptr [rbp-64]
    call zy_local_x2Fmain_0__fmt__fm_x2Dzeros
    mov rsi, 0
    sub rsi, r15
    jo zyl_rt_trap_ovf_1
    mov rdi, qword ptr [rbp-48]
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    mov rdx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    mov rsi, r13
    sub rsi, 2
    jo zyl_rt_trap_ovf_1
    mov rdi, qword ptr [rbp-48]
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    mov rdx, rsi
    mov rsi, qword ptr [rbp-56]
    mov rcx, rdi
    mov rdi, r14
    call zy_local_x2Fmain_0__fmt__fm_x2Dbig_x2Dlimbs
    mov rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-64]
    jo zyl_rt_trap_ovf_0
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rdi, 46
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, qword ptr [rbp-48]
    add rsi, qword ptr [rbp-64]
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, r14
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, 6
    call zy_local_x2Fmain_0__fmt__fm_x2Dzeros
    mov rsi, r14
    add rsi, qword ptr [rbp-72]
    jo zyl_rt_trap_ovf_0
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
.L821_0:
    cmp r13, 0
    jge .L821_1
.L821_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L821_1:
    mov rsi, 0
    imul rdi, r13, 8
    jo zyl_rt_trap_ovf_2
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rdi+0]
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
    mov rdi, rbx
    mov rdx, r14
    call zy_local_x2Fmain_0__text__rt_x2Dput_x2Ddigits
    sub r13, 1
    jo zyl_rt_trap_ovf_1
    add r14, 9
    jo zyl_rt_trap_ovf_0
    cmp r13, 0
    jge .L821_1
    jmp .L821_2
zy_local_x2Fmain_0__out__ou_x2Dst:
    # frame 0
.L822_0:
    lea rax, [rip+zyl_rtg_out_state]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Dbuf:
    # frame 0
.L823_0:
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
.L824_0:
    mov rsi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L824_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L824_1:
    call zyl_rt_sys_24
    jmp .L824_0
zy_local_x2Fmain_0__out__ou_x2Dunlock:
    # frame 0
.L825_0:
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
.L826_0:
    mov rax, qword ptr [rbx+16]
    cmp rax, 0
    jle .L826_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L826_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_stat@tpoff]
    mov r12, rax
    mov rdi, 1
    mov rsi, r12
    call zyl_rt_sys_5
    cmp rax, 0
    jne .L826_2
    mov rsi, qword ptr [r12+56]
    jmp .L826_3
.L826_2:
    mov rsi, 0
.L826_3:
    cmp rsi, 0
    jle .L826_4
    cmp rsi, 8192
    jge .L826_4
    jmp .L826_5
.L826_4:
    mov rsi, 8192
.L826_5:
    mov qword ptr [rbx+24], rsi
    mov rdi, 1
    mov rsi, 21505
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_tios@tpoff]
    mov r8, rax
    mov rdx, r8
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L826_6
    mov rsi, 2
    jmp .L826_7
.L826_6:
    mov rsi, 1
.L826_7:
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
.L827_0:
    cmp r13, 0
    jg .L827_1
.L827_4:
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L827_1:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L827_2
    add r12, rsi
    jo zyl_rt_trap_ovf_0
    sub r13, rsi
    jo zyl_rt_trap_ovf_1
    cmp r13, 0
    jg .L827_1
    jmp .L827_4
.L827_2:
    cmp rsi, -4
    jne .L827_3
    cmp r13, 0
    jg .L827_1
    jmp .L827_4
.L827_3:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked:
    # frame 0
.L828_0:
    mov rsi, qword ptr [rdi+8]
    cmp rsi, 0
    jne .L828_1
    mov rax, 1
    ret
.L828_1:
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
.L829_0:
    cmp r13, 0
    jg .L829_1
.L829_5:
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
.L829_1:
    mov rdx, qword ptr [rbp-48]
    mov r14, qword ptr [rdx+8]
    mov rdx, qword ptr [rbp-48]
    mov r15, qword ptr [rdx+24]
    sub r15, r14
    jo zyl_rt_trap_ovf_1
    mov rsi, r13
    cmp r13, r15
    jl .L829_2
    mov rsi, r15
.L829_2:
    mov rbx, rsi
    lea rax, [rip+zyl_rtg_out_buf]
    mov rdi, rax
    add rdi, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    mov rdx, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r14
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+8], rsi
    cmp rbx, r15
    jne .L829_3
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked
    cmp rax, 0
    je .L829_4
    add r12, rbx
    jo zyl_rt_trap_ovf_0
    sub r13, rbx
    jo zyl_rt_trap_ovf_1
    cmp r13, 0
    jg .L829_1
    jmp .L829_5
.L829_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L829_3:
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
.L830_0:
    mov rdx, qword ptr [rbp-48]
    mov r14, qword ptr [rdx+8]
    mov rdx, qword ptr [rbp-48]
    mov r15, qword ptr [rdx+24]
    mov rax, r15
    sub rax, r14
    jo zyl_rt_trap_ovf_1
    cmp r13, rax
    jg .L830_1
    lea rax, [rip+zyl_rtg_out_buf]
    mov rdi, rax
    add rdi, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r14
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L830_1:
    mov rbx, r15
    sub rbx, r14
    jo zyl_rt_trap_ovf_1
    lea rax, [rip+zyl_rtg_out_buf]
    mov rdi, rax
    add rdi, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    mov rdx, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+8], r15
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked
    cmp rax, 0
    jne .L830_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L830_2:
    sub r13, rbx
    jo zyl_rt_trap_ovf_1
    cmp r15, 128
    jl .L830_3
    mov rax, r13
    mov rcx, r15
    test rcx, rcx
    jz zyl_rt_trap_div0_4
    cmp rcx, -1
    jne .L831
    xor eax, eax
    jmp .L832
.L831:
    cqo
    idiv rcx
    mov rax, rdx
.L832:
    mov rsi, rax
    jmp .L830_4
.L830_3:
    mov rsi, 0
.L830_4:
    mov r14, r13
    sub r14, rsi
    jo zyl_rt_trap_ovf_1
    cmp r14, 0
    jle .L830_5
    mov rdi, 1
    mov rsi, r12
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    mov rdx, r14
    call zy_local_x2Fmain_0__out__ou_x2Dsys_x2Dall
    cmp rax, 0
    jne .L830_5
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L830_5:
    mov rsi, rbx
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    sub rdi, r14
    jo zyl_rt_trap_ovf_1
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
.L833_0:
    cmp rsi, 0
    jge .L833_1
.L833_3:
    mov rax, -1
    ret
.p2align 4
.L833_1:
    mov r8, rdi
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r8+0]
    cmp rax, 10
    jne .L833_2
    mov rax, rsi
    ret
.L833_2:
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jge .L833_1
    jmp .L833_3
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
.L834_0:
    mov rsi, r13
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dlast_x2Dnl
    mov r14, rax
    cmp r14, 0
    jge .L834_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dappend
.L834_1:
    mov rsi, r14
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dappend
    cmp rax, 0
    je .L834_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dflush_x2Dlocked
    cmp rax, 0
    je .L834_2
    mov rsi, r14
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, r14
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rax, r13
    mov rcx, rdi
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dappend
.L834_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__out__ou_x2Downer_x2Dcell:
    # frame 0
.L835_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_owner_self
zyl_owner_self:
    # frame 0
.L836_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L836_1
    mov rax, 1
    ret
.L836_1:
    mov rax, rsi
    ret
.globl zyl_owner_set
zyl_owner_set:
    # frame 0
.L837_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__out__ou_x2Dabuf:
    # frame 0
.L838_0:
    lea rax, [rip+zyl_rtg_actor_out]
    mov rsi, rax
    imul rdi, rdi, 24
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
zy_local_x2Fmain_0__out__ou_x2Debuf:
    # frame 0
.L839_0:
    lea rax, [rip+zyl_rtg_actor_err]
    mov rsi, rax
    imul rdi, rdi, 24
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
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
.L840_0:
    mov r14, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+16]
    mov rax, r14
    add rax, r13
    jo zyl_rt_trap_ovf_0
    cmp rax, rsi
    jg .L840_1
    mov rdi, 1
    jmp .L840_2
.L840_1:
    imul r8, rsi, 2
    jo zyl_rt_trap_ovf_2
    mov rax, r14
    add rax, r13
    jo zyl_rt_trap_ovf_0
    cmp r8, rax
    jge .L840_3
    mov r8, r13
    add r8, 256
    jo zyl_rt_trap_ovf_0
    add r8, r14
    jo zyl_rt_trap_ovf_0
    jmp .L840_4
.L840_3:
    imul r8, rsi, 2
    jo zyl_rt_trap_ovf_2
.L840_4:
    mov r15, r8
    mov rsi, qword ptr [rbx+0]
    mov rdi, rsi
    mov rsi, r15
    call zyl_rt_realloc
    mov rsi, rax
    mov r8, 0
    cmp rsi, 0
    je .L840_5
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+16], r15
    mov r8, 1
.L840_5:
    mov rdi, r8
.L840_2:
    mov rax, rdi
    cmp rax, 0
    je .L840_6
    mov rdi, qword ptr [rbx+0]
    add rdi, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r14
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+8], rsi
    mov rax, 1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L840_6:
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
.L841_0:
    cmp rbx, 2
    jl .L841_2
.L841_3:
    cmp rbx, 1025
    jle .L841_1
.L841_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L841_1:
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
.L842_0:
    mov rbx, qword ptr [rdi+0]
    mov r8, qword ptr [rdi+8]
    mov r9, 0
    mov qword ptr [rdi+0], r9
    mov r9, 0
    mov qword ptr [rdi+8], r9
    mov r9, 0
    mov qword ptr [rdi+16], r9
    cmp rbx, 0
    jne .L842_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L842_1:
    cmp rsi, 0
    je .L842_2
    mov rdi, rbx
    mov rsi, r8
    call zyl_err_write
    jmp .L842_3
.L842_2:
    mov rdi, rbx
    mov rsi, r8
    call zyl_out_write
.L842_3:
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
.L843_0:
    call zyl_owner_self
    mov rdi, rax
    cmp rdi, 2
    jl .L843_1
    call zy_local_x2Fmain_0__out__ou_x2Dabuf
    mov rdi, rax
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dabuf_x2Dput
.L843_1:
    mov rax, qword ptr [rbx+16]
    cmp rax, 2
    jne .L843_2
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__out__ou_x2Dput_x2Dline
.L843_2:
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
.L844_0:
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
.L845_0:
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
.L846_0:
    cmp rbx, 0
    jne .L846_1
.L846_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L846_1:
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
.L847_0:
    lea rax, [rip+zyl_rtg_out_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 0
    jne .L847_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L847_1:
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
.L848_0:
    call zyl_owner_self
    mov rdi, rax
    cmp rdi, 2
    jl .L848_1
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
.L848_1:
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
.L849_0:
    cmp rbx, 0
    jne .L849_1
.L849_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L849_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zyl_err_write
zy_local_x2Fmain_0__out__ou_x2Ddigits:
    # frame 0
.L850_0:
    mov r8, rsi
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    mov r9, 10
    mov rdx, rdi
    mov rcx, r9
    mov rax, rdx
    xor edx, edx
    div rcx
    mov rax, rdx
    mov r9, rax
    add r9, 48
    jo zyl_rt_trap_ovf_0
    mov byte ptr [r8+0], r9b
    mov r9, 10
    mov rdx, rdi
    mov rcx, r9
    mov rax, rdx
    xor edx, edx
    div rcx
    mov r9, rax
    cmp r9, 0
    jne .L850_1
    mov rax, r8
    ret
.L850_1:
    mov rdi, r9
    mov rsi, r8
    jmp .L850_0
zy_local_x2Fmain_0__out__ou_x2Dmin:
    # frame 0
.L851_0:
    mov rax, -9223372036854775808
    ret
zy_local_x2Fmain_0__out__ou_x2Dmag:
    # frame 0
.L852_0:
    cmp rdi, 0
    jge .L852_1
.L852_3:
    mov rax, -9223372036854775808
    cmp rdi, rax
    jne .L852_2
    mov rax, -9223372036854775808
    ret
.L852_2:
    mov rsi, 0
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    ret
.L852_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__out__ou_x2Dint:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L853_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dmag
    mov rdi, rax
    mov rsi, r12
    call zy_local_x2Fmain_0__out__ou_x2Ddigits
    mov rsi, rax
    cmp rbx, 0
    jge .L853_1
    mov rdi, rsi
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    mov r8, 45
    mov byte ptr [rdi+0], r8b
    mov rax, rsi
    sub rax, 1
    jo zyl_rt_trap_ovf_1
    pop r12
    pop rbx
    pop rbp
    ret
.L853_1:
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
.globl zyl_out_int
zyl_out_int:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L854_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_int@tpoff]
    mov rbx, rax
    add rbx, 31
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dint
    mov rdi, rax
    mov rsi, rbx
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
    pop rbx
    pop rbp
    jmp zyl_out_write
.globl zyl_print_int
zyl_print_int:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L855_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_out_int@tpoff]
    mov rbx, rax
    add rbx, 31
    jo zyl_rt_trap_ovf_0
    mov rsi, 10
    mov rcx, rsi
    mov byte ptr [rbx+0], cl
    mov rsi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dint
    mov rdi, rax
    mov rsi, rbx
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
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
.L856_0:
    mov rbx, rdi
    lea rax, [rip+zyl_rtg_out_state]
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dlock
    mov rdi, r12
    call zy_local_x2Fmain_0__out__ou_x2Dinit
    cmp rbx, 0
    jne .L856_1
    lea rax, [rip+.L857]
    mov r13, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__out__ou_x2Dput
    jmp .L856_2
.L856_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__out__ou_x2Dput
.L856_2:
    lea rax, [rip+.L858]
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
.L859_0:
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
    mov rdi, rbx
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov r8, 10
    mov byte ptr [rdi+0], r8b
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L860_0:
    cmp rdi, 0
    jge .L860_1
.L860_2:
    mov rax, -1
    ret
.L860_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__os__os_x2Dbad:
    # frame 0
    push rbp
    mov rbp, rsp
.L861_0:
    cmp rdi, 0
    jle .L861_1
.L861_2:
    cmp rdi, 4096
    jge .L861_1
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 1
    pop rbp
    ret
.L861_1:
    mov rax, 0
    pop rbp
    ret
.globl zyl_file_open_c
zyl_file_open_c:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L862_0:
    mov r8, 0
    cmp rsi, 4096
    jl .L862_1
    movzx r8d, byte ptr [rsi+0]
.L862_1:
    mov rsi, 0
    cmp r8, 114
    je .L862_2
    mov r9, 1089
    cmp r8, 97
    je .L862_3
    mov r9, 577
.L862_3:
    mov rsi, r9
.L862_2:
    mov r8, 420
    mov rdx, r8
    call zyl_rt_sys_2
    mov rsi, rax
    cmp rsi, 0
    jge .L862_4
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L862_4:
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
.L863_0:
    mov r8, 0
    cmp rsi, 0
    jl .L863_1
    mov r9, 67108864
    cmp rsi, 67108864
    jg .L863_2
    mov r9, rsi
.L863_2:
    mov r8, r9
.L863_1:
    mov r12, r8
    mov rsi, r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_ralloc
    mov r13, rax
    cmp r13, 0
    jne .L863_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L863_3:
    mov rdi, rbx
    mov rsi, r13
    mov rdx, r12
    call zyl_rt_sys_0
    mov rsi, rax
    mov rdi, 0
    cmp rsi, 0
    jl .L863_4
    mov rdi, rsi
.L863_4:
    mov rsi, r13
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
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
.L864_0:
    cmp rbx, 0
    jne .L864_1
.L864_3:
    call zyl_out_flush
    jmp .L864_2
.L864_1:
.L864_2:
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
.L865_0:
    cmp rbx, 0
    jne .L865_1
.L865_3:
    call zyl_out_flush
    jmp .L865_2
.L865_1:
.L865_2:
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
.L866_0:
    mov r12, rsi
    cmp r12, 0
    jne .L866_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L866_1:
    lea rax, [rip+.L867]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L866_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L866_2:
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    cmp rbx, 1
    jne .L866_3
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
.L866_3:
    cmp rbx, 2
    jne .L866_4
    call zyl_owner_self
    cmp rax, 2
    jl .L866_4
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
.L866_4:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jge .L866_5
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L866_5:
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
.L868_0:
    call zyl_rt_sys_3
    mov rsi, rax
    cmp rsi, 0
    jge .L868_1
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L868_1:
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
.L869_0:
    mov rsi, 0
    call zyl_rt_sys_21
    cmp rax, 0
    jne .L869_1
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L869_1:
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
.L870_0:
    call zyl_rt_sys_80
    mov rsi, rax
    cmp rsi, 0
    jge .L870_1
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L870_1:
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
.L871_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_cwd@tpoff]
    mov rbx, rax
    mov rsi, 4096
    mov rdi, rbx
    call zyl_rt_sys_79
    cmp rax, 0
    jle .L871_2
    movzx eax, byte ptr [rbx+0]
    cmp rax, 47
    je .L871_1
.L871_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L871_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    mov rdi, r12
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    call zyl_heap_alloc
    mov r13, rax
    cmp r13, 0
    jne .L871_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L871_3:
    mov rsi, r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L872_0:
    mov rbx, rdi
    cmp rbx, 0
    je .L872_2
    lea rax, [rip+.L873]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L872_1
.L872_2:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L872_1:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L872_3
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L872_3:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    cmp r12, 4096
    jl .L872_4
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L872_4:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_mkdir@tpoff]
    mov r13, rax
    mov rsi, r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
    je .L872_5
    mov rdi, r13
    call zy_local_x2Fmain_0__os__os_x2Dmkdir_x2Done
    cmp rax, 0
    je .L872_6
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L872_6:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L872_5:
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
.L874_0:
    mov rsi, 493
    call zyl_rt_sys_83
    mov rsi, rax
    cmp rsi, 0
    jne .L874_1
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L874_1:
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
.L875_0:
    cmp r13, r12
    jl .L875_1
.L875_5:
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L875_1:
    mov rsi, rbx
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rsi+0]
    cmp rax, 47
    jne .L875_2
    mov rsi, rbx
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, 493
    mov rdi, rbx
    call zyl_rt_sys_83
    mov rsi, rax
    mov rdi, 1
    cmp rsi, 0
    je .L875_3
    mov rax, rsi
    cmp rax, -17
    sete al
    movzx rax, al
    mov rdi, rax
.L875_3:
    mov rsi, rbx
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov r8, 47
    mov byte ptr [rsi+0], r8b
    cmp rdi, 0
    je .L875_4
    add r13, 1
    jo zyl_rt_trap_ovf_0
    cmp r13, r12
    jl .L875_1
    jmp .L875_5
.L875_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L875_2:
    add r13, 1
    jo zyl_rt_trap_ovf_0
    cmp r13, r12
    jl .L875_1
    jmp .L875_5
.globl zyl_save_args
zyl_save_args:
    # frame 0
.L876_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov r8, rax
    mov r9, 4294967295
    and rdi, r9
    cmp rdi, 2147483647
    jle .L876_1
    mov r9, 4294967296
    mov rax, rdi
    mov rcx, r9
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov r9, rax
    jmp .L876_2
.L876_1:
    mov r9, rdi
.L876_2:
    mov qword ptr [r8+0], r9
    mov qword ptr [r8+8], rsi
    mov rdi, 0
    cmp rsi, 0
    je .L876_3
    mov r8, r9
    add r8, 1
    jo zyl_rt_trap_ovf_0
    imul r8, r8, 8
    jo zyl_rt_trap_ovf_2
    mov rdi, rsi
    add rdi, r8
    jo zyl_rt_trap_ovf_0
.L876_3:
    jmp zyl_rt_set_env
.globl zyl_argc
zyl_argc:
    # frame 0
.L877_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_arg_str
zyl_arg_str:
    # frame 0
.L878_0:
    lea rax, [rip+zyl_rtg_os_args]
    mov rsi, rax
    cmp rdi, 0
    jl .L878_2
    mov rax, qword ptr [rsi+0]
    cmp rdi, rax
    jl .L878_1
.L878_2:
    mov rax, 0
    ret
.L878_1:
    mov rsi, qword ptr [rsi+8]
    imul rdi, rdi, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
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
.L879_0:
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
    jo zyl_rt_trap_ovf_0
    add rsi, r15
    jo zyl_rt_trap_ovf_0
    mov rax, r14
    sub rax, 1
    jo zyl_rt_trap_ovf_1
    cmp rsi, rax
    jle .L879_1
    mov rdi, r14
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    jmp .L879_2
.L879_1:
    mov rdi, rsi
.L879_2:
    mov r14, rdi
    mov rdi, r14
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov qword ptr [rbp-64], rax
    cmp qword ptr [rbp-64], 0
    jne .L879_3
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L879_3:
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
    mov rsi, r15
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rbp-64]
    mov rdx, qword ptr [rbp-48]
    mov rcx, qword ptr [rbp-56]
    mov r8, r14
    call zy_local_x2Fmain_0__os__os_x2Dput
    mov rsi, qword ptr [rbp-64]
    add rsi, r14
    jo zyl_rt_trap_ovf_0
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
.L880_0:
    cmp rsi, r10
    jl .L880_1
.L880_4:
    mov rax, 0
    ret
.L880_1:
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    add rax, r9
    jo zyl_rt_trap_ovf_0
    cmp rax, r10
    jle .L880_2
    mov rax, r10
    mov rcx, rsi
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov rsi, rax
    jmp .L880_3
.L880_2:
    mov rsi, r9
.L880_3:
    mov rdx, rsi
    mov rsi, r8
    jmp zy_local_x2Fmain_0__base__rt_x2Dcopy
zy_local_x2Fmain_0__os__os_x2Dsep:
    # frame 0
.L881_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 0
    jne .L881_1
    lea rax, [rip+.L882]
    mov rsi, rax
    mov rax, rsi
    ret
.L881_1:
    lea rax, [rip+.L883]
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
.L884_0:
    call zy_local_x2Fmain_0__os__os_x2Dskip_x2Dsp
    mov r13, rax
    movzx eax, byte ptr [r13+0]
    cmp rax, 0
    jne .L884_1
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L884_1:
    mov rdi, r13
    call zy_local_x2Fmain_0__os__os_x2Dword_x2Dend
    mov r14, rax
    mov rsi, r14
    sub rsi, r13
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jle .L884_2
    cmp r12, rsi
    jle .L884_2
    mov r8, r12
    sub r8, rsi
    jo zyl_rt_trap_ovf_1
    add r8, rbx
    jo zyl_rt_trap_ovf_0
    mov rdi, r8
    mov rdx, rsi
    mov rsi, r13
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    cmp rax, 0
    je .L884_2
    mov rax, 1
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L884_2:
    mov rdi, r14
    jmp .L884_0
zy_local_x2Fmain_0__os__os_x2Dskip_x2Dsp:
    # frame 0
.L885_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 32
    jne .L885_1
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L885_0
.L885_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__os__os_x2Dword_x2Dend:
    # frame 0
.L886_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 0
    je .L886_2
    cmp rsi, 32
    jne .L886_1
.L886_2:
    mov rax, rdi
    ret
.L886_1:
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L886_0
zy_local_x2Fmain_0__os__os_x2Dpush:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rsi
.L887_0:
    mov rsi, qword ptr [rbx+8]
    mov rdi, qword ptr [rbx+16]
    cmp rsi, rdi
    jne .L887_1
    mov r8, 64
    cmp rdi, 0
    je .L887_2
    imul r8, rdi, 2
    jo zyl_rt_trap_ovf_2
.L887_2:
    mov r13, r8
    mov rdi, qword ptr [rbx+0]
    imul r8, r13, 8
    jo zyl_rt_trap_ovf_2
    mov rsi, r8
    call zyl_rt_realloc
    mov rdi, rax
    cmp rdi, 0
    jne .L887_3
    mov rdi, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_free
.L887_3:
    mov qword ptr [rbx+0], rdi
    mov qword ptr [rbx+16], r13
    jmp .L887_0
.L887_1:
    mov rdi, qword ptr [rbx+0]
    imul r8, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+0], r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L888_0:
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
    jne .L888_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L888_1:
    mov rsi, 591872
    mov rdi, 0
    mov rdx, rdi
    mov rdi, r15
    call zyl_rt_sys_2
    mov qword ptr [rbp-48], rax
    mov rdi, r15
    call zyl_rt_free
    cmp qword ptr [rbp-48], 0
    jge .L888_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L888_2:
    mov rdi, 32768
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    je .L888_3
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    mov r8, qword ptr [rbp-48]
    mov r9, r15
    call zy_local_x2Fmain_0__os__os_x2Dwalk_x2Dfill
.L888_3:
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
    jg .L889
    mov rax, 0
    jmp .L890
.L889:
    mov rax, 0
    mov [rbp-72], rax
    mov rax, [rbp-72]
    mov rcx, [rbp-56]
    cmp rax, rcx
    jl .L891
    mov rax, 0
    jmp .L892
.L891:
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
.L892:
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
.L890:
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
    jl .L893
    mov rax, 0
    jmp .L894
.L893:
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov [rbp-64], rax
    mov rax, [rbp-64]
    mov rcx, 19
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov [rbp-72], rax
    mov rax, [rbp-72]
    mov rdx, rax
    movzx eax, byte ptr [rdx]
    mov rcx, 46
    cmp rax, rcx
    jne .L895
    mov rax, 0
    jmp .L896
.L895:
    sub rsp, 8
    sub rsp, 40
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    mov rdx, [rbp-24]
    mov rcx, [rbp-32]
    mov r8, [rbp-72]
call zy_local_x2Fmain_0__os__os_x2Dwalk_x2Done
    add rsp, 48
.L896:
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
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    movzx eax, word ptr [rdx]
    mov rcx, rax
    mov rax, [rbp-48]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
.L894:
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
.L897_0:
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
    jne .L897_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L897_1:
    lea rax, [rip+.L898]
    mov rsi, rax
    mov rdi, 8200
    mov rdx, qword ptr [rbp-48]
    mov rcx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dcat3
    mov r15, rax
    cmp r15, 0
    jne .L897_2
    mov rdi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_free
.L897_2:
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
    je .L897_3
    mov rdi, qword ptr [rbp-48]
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_free
.L897_3:
    mov esi, dword ptr [r12+24]
    and rsi, 61440
    cmp rsi, 16384
    jne .L897_4
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
.L897_4:
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, qword ptr [rbp-48]
    mov rdx, r13
    call zy_local_x2Fmain_0__os__os_x2Dhas_x2Dsuffix
    cmp rax, 0
    je .L897_5
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
.L897_5:
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
    jo zyl_rt_trap_ovf_1
    mov rcx, 2
    cmp rax, rcx
    jge .L899
    mov rax, 0
    jmp .L900
.L899:
    mov rax, [rbp-32]
    mov rcx, [rbp-24]
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov rcx, 2
    test rcx, rcx
    jz zyl_rt_trap_div0_3
    cmp rcx, -1
    jne .L901
    neg rax
    jo zyl_rt_trap_ovf_3
    jmp .L902
.L901:
    cqo
    idiv rcx
.L902:
    mov rcx, rax
    mov rax, [rbp-24]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, [rbp-16]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    mov rcx, [rbp-24]
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
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
.L900:
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
    jl .L905
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    cmp rax, rcx
    setge al
    movzx rax, al
    jmp .L906
.L905:
    mov rax, 0
.L906:
    test rax, rax
    je .L903
    mov rax, 0
    jmp .L904
.L903:
    mov rax, [rbp-40]
    mov rcx, [rbp-48]
    cmp rax, rcx
    jl .L909
    mov rax, 1
    jmp .L910
.L909:
    mov rax, [rbp-24]
    mov rcx, [rbp-32]
    cmp rax, rcx
    jge .L911
    mov rax, [rbp-24]
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-40]
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L912
.L911:
    mov rax, 0
.L912:
.L910:
    test rax, rax
    je .L907
    mov rax, [rbp-56]
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, [rbp-16]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    push rax
    mov rax, [rbp-24]
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jmp .L908
.L907:
    mov rax, [rbp-56]
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, [rbp-16]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    push rax
    mov rax, [rbp-40]
    mov rcx, 8
    imul rax, rcx
    jo zyl_rt_trap_ovf_2
    mov rcx, rax
    mov rax, [rbp-8]
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-48]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-56]
    mov rcx, 1
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
.L908:
.L904:
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
.L913_0:
    cmp rsi, r12
    jl .L913_1
.L913_2:
    mov rax, r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L913_1:
    mov r14, rsi
    add r14, 1
    jo zyl_rt_trap_ovf_0
    imul rdi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rdi+0]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rdi, rax
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    add r13, rdi
    jo zyl_rt_trap_ovf_0
    mov rsi, r14
    cmp rsi, r12
    jl .L913_1
    jmp .L913_2
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
.L914_0:
    cmp r12, r13
    jl .L914_1
.L914_2:
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
.L914_1:
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    add rsi, qword ptr [rbp-56]
    jo zyl_rt_trap_ovf_0
    mov r15, qword ptr [rsi+0]
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rbx, rax
    mov rdi, r14
    add rdi, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov rsi, r15
    mov rdx, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, qword ptr [rbp-48]
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rdi, 10
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rdi, r15
    call zyl_rt_free
    add r12, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rbp-48]
    mov rcx, rsi
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    cmp r12, r13
    jl .L914_1
    jmp .L914_2
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
.L915_0:
    cmp r12, r13
    jl .L915_1
.L915_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L915_1:
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rsi+0]
    call zyl_rt_free
    add r12, 1
    jo zyl_rt_trap_ovf_0
    cmp r12, r13
    jl .L915_1
    jmp .L915_2
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
.L916_0:
    mov r12, qword ptr [rbx+0]
    mov r13, qword ptr [rbx+8]
    mov rsi, 0
    cmp r13, 2
    jl .L916_1
    imul rdi, r13, 8
    jo zyl_rt_trap_ovf_2
    mov r8, 1
    mov rsi, r8
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
.L916_1:
    mov r14, rsi
    cmp r14, 0
    je .L916_2
    mov rsi, 0
    mov rdi, r12
    mov rdx, rsi
    mov rsi, r14
    mov rcx, r13
    call zy_local_x2Fmain_0__os__os_x2Dsort
    mov rdi, r14
    call zyl_rt_free
.L916_2:
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
    jne .L916_3
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
.L916_3:
    mov rsi, 0
    mov r8, 0
    mov rdi, r12
    mov rdx, r13
    mov rcx, r14
    call zy_local_x2Fmain_0__os__os_x2Demit
    mov rsi, rax
    add rsi, r14
    jo zyl_rt_trap_ovf_0
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
.L917_0:
    mov rdi, 24
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L917_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L917_1:
    mov rsi, 0
    mov qword ptr [r13+0], rsi
    mov rsi, 0
    mov qword ptr [r13+8], rsi
    mov rsi, 0
    mov qword ptr [r13+16], rsi
    cmp rbx, 0
    je .L917_4
    cmp r12, 0
    jne .L917_2
.L917_4:
    jmp .L917_3
.L917_2:
    lea rax, [rip+.L918]
    mov rsi, rax
    mov rdi, rbx
    mov rdx, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__os__os_x2Dwalk
.L917_3:
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
.L919_0:
    mov rbx, rdi
    lea rax, [rip+.L920]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L919_1
    mov rdi, 0
    mov rsi, 0
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.L919_1:
    lea rax, [rip+.L921]
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
.L922_0:
    mov rbx, rdi
    mov r12, rsi
    lea rax, [rip+.L923]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    jne .L922_2
    lea rax, [rip+.L924]
    mov rsi, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L922_1
.L922_2:
    mov rdi, 0
    mov rsi, 0
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
.L922_1:
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__os__os_x2Dlist
zy_local_x2Fmain_0__os__os_x2Dterm_x2Dstate:
    # frame 0
.L925_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__os__os_x2Dterm_x2Dsaved:
    # frame 0
.L926_0:
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
.L927_0:
    mov rsi, 21505
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_tios@tpoff]
    mov r8, rax
    mov rdx, r8
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L927_1
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L927_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__os__os_x2Dtcset:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L928_0:
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
.L929_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 1
    jne .L929_1
    mov rax, qword ptr [rbx+0]
    cmp rax, 1
    jne .L929_1
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
    lea rax, [rip+.L930]
    mov rsi, rax
    mov r8, 12
    mov rdx, r8
    call zyl_rt_sys_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L929_1:
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
.L931_0:
    mov rdi, 0
    call zyl_term_is_tty
    cmp rax, 0
    jne .L931_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L931_1:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 1
    jne .L931_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L931_2:
    mov rax, qword ptr [rbx+0]
    cmp rax, 1
    jne .L931_3
    mov rsi, 1
    jmp .L931_4
.L931_3:
    mov rdi, 0
    mov r8, 21505
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov r9, rax
    mov rsi, r8
    mov rdx, r9
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L931_5
    mov rdi, 1
    mov qword ptr [rbx+0], rdi
    call zyl_term_atexit
    mov rdi, 1
    jmp .L931_6
.L931_5:
    mov rdi, 0
.L931_6:
    mov rsi, rdi
.L931_4:
    mov rax, rsi
    cmp rax, 0
    jne .L931_7
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L931_7:
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
    je .L931_8
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L931_8:
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
.L932_0:
    lea rax, [rip+zyl_rtg_os_term_state]
    mov rbx, rax
    mov rax, qword ptr [rbx+8]
    cmp rax, 1
    jne .L932_2
    mov rax, qword ptr [rbx+0]
    cmp rax, 1
    je .L932_1
.L932_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L932_1:
    lea rax, [rip+zyl_rtg_os_term_saved]
    mov rsi, rax
    mov rdi, 0
    mov r8, 21508
    mov rdx, rsi
    mov rsi, r8
    call zyl_rt_sys_16
    cmp rax, 0
    je .L932_3
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L932_3:
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
.L933_0:
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
    jne .L933_1
    movzx eax, byte ptr [rbx+0]
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L933_1:
    cmp rsi, -4
    jne .L933_2
    mov rax, -2
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L933_2:
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
.L934_0:
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
    jne .L934_1
    mov rax, -3
    mov rsp, rbp
    pop rbp
    ret
.L934_1:
    cmp rsi, 0
    jge .L934_2
    cmp rsi, -4
    jne .L934_3
    mov rax, -2
    mov rsp, rbp
    pop rbp
    ret
.L934_3:
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.L934_2:
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
.L935_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_os_winsz@tpoff]
    mov r13, rax
    mov rdi, 1
    mov rsi, 21523
    mov rdx, r13
    call zyl_rt_sys_16
    cmp rax, 0
    jne .L935_1
    mov rsi, r13
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    movzx esi, word ptr [rsi+0]
    cmp rsi, 0
    jle .L935_2
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L935_2:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L935_1:
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
.L936_0:
    mov rdi, 2
    mov rsi, 80
    jmp zy_local_x2Fmain_0__os__os_x2Dwinsz
.globl zyl_term_height
zyl_term_height:
    # frame 0
.L937_0:
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
.L938_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L938_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L938_1:
    lea rax, [rip+.L939]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__os__os_x2Dbad
    cmp rax, 0
    je .L938_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L938_2:
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
.L940_0:
    cmp r13, r12
    jl .L940_1
.L940_4:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L940_1:
    mov rdi, 1
    mov rsi, rbx
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    mov r8, r12
    sub r8, r13
    jo zyl_rt_trap_ovf_1
    mov rdx, r8
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L940_2
    add r13, rsi
    jo zyl_rt_trap_ovf_0
    cmp r13, r12
    jl .L940_1
    jmp .L940_4
.L940_2:
    cmp rsi, -4
    jne .L940_3
    cmp r13, r12
    jl .L940_1
    jmp .L940_4
.L940_3:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf:
    # frame 0
.L941_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_uf_reset
zyl_uf_reset:
    # frame 0
.L942_0:
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
.L943_0:
    mov rax, qword ptr [rbx+24]
    cmp rax, 0
    jne .L943_1
    mov rsi, 4096
    jmp .L943_2
.L943_1:
    mov rsi, qword ptr [rbx+24]
    imul rsi, rsi, 2
    jo zyl_rt_trap_ovf_2
.L943_2:
    mov r12, rsi
    mov rdi, qword ptr [rbx+0]
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    call zyl_rt_realloc
    mov r13, rax
    mov rdi, qword ptr [rbx+8]
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    call zyl_rt_realloc
    mov r14, rax
    cmp r13, 0
    je .L943_5
    cmp r14, 0
    jne .L943_3
.L943_5:
    imul rdi, r12, 16
    jo zyl_rt_trap_ovf_2
    lea rax, [rip+.L944]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L943_4
.L943_3:
.L943_4:
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
.L945_0:
    lea rax, [rip+zyl_rtg_uf]
    mov r12, rax
    mov rsi, qword ptr [r12+16]
    mov rax, qword ptr [r12+24]
    cmp rsi, rax
    jne .L945_1
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dgrow
    jmp .L945_2
.L945_1:
.L945_2:
    mov rsi, qword ptr [r12+16]
    mov rdi, qword ptr [r12+0]
    imul r8, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+0], rsi
    mov rdi, qword ptr [r12+8]
    imul r8, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+0], rbx
    mov rdi, rsi
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r12+16], rdi
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Droot:
    # frame 0
.L946_0:
    imul r8, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r8, rdi
    jo zyl_rt_trap_ovf_0
    mov r8, qword ptr [r8+0]
    cmp r8, rsi
    jne .L946_1
    mov rax, rsi
    ret
.L946_1:
    mov rsi, r8
    jmp .L946_0
zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dcompress:
    # frame 0
    mov r8, rdx
.L947_0:
    imul r9, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    mov r9, qword ptr [r9+0]
    cmp r9, r8
    jne .L947_1
    mov rax, 0
    ret
.L947_1:
    imul r10, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r10+0], r8
    mov rsi, r9
    jmp .L947_0
.globl zyl_uf_find
zyl_uf_find:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L948_0:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    cmp rbx, 0
    jl .L948_2
    mov rax, qword ptr [rsi+16]
    cmp rbx, rax
    jl .L948_1
.L948_2:
    mov rax, rbx
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L948_1:
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
.L949_0:
    cmp rdi, 0
    jl .L949_1
.L949_2:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rsi, qword ptr [rsi+16]
    mov rax, rdi
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    ret
.L949_1:
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
.L950_0:
    call zyl_uf_find
    mov r12, rax
    mov rdi, rbx
    call zyl_uf_find
    mov rbx, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    je .L950_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    jne .L950_1
.L950_2:
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
.L950_1:
    cmp r12, rbx
    jne .L950_3
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret
.L950_3:
    mov rsi, r12
    cmp r12, rbx
    jl .L950_4
    mov rsi, rbx
.L950_4:
    mov rdi, rbx
    cmp r12, rbx
    jl .L950_5
    mov rdi, r12
.L950_5:
    lea rax, [rip+zyl_rtg_uf]
    mov r8, rax
    mov r8, qword ptr [r8+8]
    imul r9, rdi, 8
    jo zyl_rt_trap_ovf_2
    add r9, r8
    jo zyl_rt_trap_ovf_0
    mov r9, qword ptr [r9+0]
    imul r10, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r10, r8
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r10+0]
    cmp r9, rax
    jle .L950_6
    imul r9, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r9, r8
    jo zyl_rt_trap_ovf_0
    imul r10, rdi, 8
    jo zyl_rt_trap_ovf_2
    add r8, r10
    jo zyl_rt_trap_ovf_0
    mov r8, qword ptr [r8+0]
    mov qword ptr [r9+0], r8
    jmp .L950_7
.L950_6:
.L950_7:
    lea rax, [rip+zyl_rtg_uf]
    mov r8, rax
    mov r8, qword ptr [r8+0]
    imul rdi, rdi, 8
    jo zyl_rt_trap_ovf_2
    add r8, rdi
    jo zyl_rt_trap_ovf_0
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
.L951_0:
    call zyl_uf_find
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    jne .L951_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L951_1:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rsi, qword ptr [rsi+8]
    imul rdi, r12, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rsi+0]
    cmp rbx, rax
    jle .L951_2
    mov qword ptr [rsi+0], rbx
    jmp .L951_3
.L951_2:
.L951_3:
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
.L952_0:
    call zyl_uf_find
    mov rbx, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__uf__rt_x2Duf_x2Dok
    cmp rax, 0
    jne .L952_1
    mov rax, 2
    pop rbx
    pop rbp
    ret
.L952_1:
    lea rax, [rip+zyl_rtg_uf]
    mov rsi, rax
    mov rsi, qword ptr [rsi+8]
    imul rdi, rbx, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
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
.L953_0:
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
.L954_0:
    mov rax, QWORD PTR [rip+malloc@GOTPCREL]
    mov rsi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov r8, rax
    mov rax, qword ptr [r8+0]
    cmp rax, 0
    jne .L954_1
    cmp rsi, 0
    jle .L954_1
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    jmp zyl_rt_call1
.L954_1:
    mov rsi, 1
    jmp zy_local_x2Fmain_0__heap__hp_x2Dalloc
.globl zyl_mem_free
zyl_mem_free:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L955_0:
    mov rax, QWORD PTR [rip+free@GOTPCREL]
    mov rsi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov r8, rax
    mov rax, qword ptr [r8+0]
    cmp rax, 0
    jne .L955_1
    cmp rsi, 0
    jle .L955_1
    mov rax, rsi
    mov rsi, rdi
    mov rdi, rax
    call zyl_rt_call1
    jmp .L955_2
.L955_1:
    call zyl_rt_free
.L955_2:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_mem_read
zyl_mem_read:
    # frame 0
.L956_0:
    cmp rdi, 0
    jne .L956_1
.L956_2:
    lea rax, [rip+.L957]
    mov rsi, rax
    mov rdi, rsi
    jmp zy_local_x2Fmain_0__misc__rt_x2Dnote
.L956_1:
    mov rax, qword ptr [rdi+0]
    ret
.globl zyl_mem_write
zyl_mem_write:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rsi
.L958_0:
    cmp rdi, 0
    jne .L958_1
.L958_2:
    lea rax, [rip+.L959]
    mov rsi, rax
    mov rdi, rsi
    call zy_local_x2Fmain_0__misc__rt_x2Dnote
    mov rax, rbx
    pop rbx
    pop rbp
    ret
.L958_1:
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
.L960_0:
    cmp rdi, 0
    je .L960_2
.L960_4:
    cmp rsi, 0
    jge .L960_1
.L960_2:
    mov rax, 0
    pop rbp
    ret
.L960_1:
    cmp rdi, 4096
    jge .L960_3
    lea rax, [rip+.L961]
    mov r9, rax
    mov rsi, r9
    call zy_local_x2Fmain_0__base__rt_x2Dbad_x2Dstr
    mov rax, 0
    pop rbp
    ret
.L960_3:
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
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
.L962_0:
    jmp zyl_rt_getenv
.globl zyl_regions_enabled
zyl_regions_enabled:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L963_0:
    lea rax, [rip+.L964]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    cmp rsi, 0
    jle .L963_1
    movzx eax, byte ptr [rsi+0]
    cmp rax, 48
    jne .L963_1
    movzx eax, byte ptr [rsi+1]
    cmp rax, 0
    jne .L963_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L963_1:
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_region_poison_enabled
zyl_region_poison_enabled:
    # frame 0
    push rbp
    mov rbp, rsp
.L965_0:
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
.L966_0:
    lea rax, [rip+.L967]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    cmp rsi, 0
    jne .L966_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L966_1:
    movzx eax, byte ptr [rsi+0]
    cmp rax, 49
    jne .L966_2
    movzx eax, byte ptr [rsi+1]
    cmp rax, 0
    jne .L966_2
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L966_2:
    movzx eax, byte ptr [rsi+0]
    cmp rax, 50
    jne .L966_3
    movzx eax, byte ptr [rsi+1]
    cmp rax, 0
    jne .L966_3
    mov rax, 2
    mov rsp, rbp
    pop rbp
    ret
.L966_3:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__misc__rt_x2Dlshr64:
    # frame 0
.L968_0:
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
    jo zyl_rt_trap_ovf_1
    mov rax, r8
    mov rcx, r9
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov rsi, rax
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    and rdi, rsi
    mov rax, rdi
    ret
zy_local_x2Fmain_0__misc__rt_x2Dzsa_x2Dindex:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L969_0:
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
.L970_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_zsa@tpoff]
    mov r14, rax
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__misc__rt_x2Dzsa_x2Dindex
    mov r15, rax
    imul rsi, r15, 8
    jo zyl_rt_trap_ovf_2
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rsi+0]
    cmp rax, qword ptr [rbp-48]
    jne .L970_1
    mov rsi, r14
    add rsi, 512
    jo zyl_rt_trap_ovf_0
    imul rdi, r15, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rsi, qword ptr [rsi+0]
    jmp .L970_2
.L970_1:
    mov rdi, qword ptr [rbp-48]
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rdi, rax
    mov rsi, qword ptr [rbp-48]
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
.L970_2:
    mov rbx, rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov qword ptr [rbp-56], rax
    cmp r13, 0
    jle .L970_3
    mov rsi, rbx
    sub rsi, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_1
    add rsi, qword ptr [rbp-56]
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    add rax, 1
    jo zyl_rt_trap_ovf_0
    cmp rax, r13
    jle .L970_3
    lea rax, [rip+.L971]
    mov rdi, rax
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    jmp zyl_panic
.L970_3:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, rbx
    add rsi, qword ptr [rbp-56]
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    imul rsi, r15, 8
    jo zyl_rt_trap_ovf_2
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rcx, qword ptr [rbp-48]
    mov qword ptr [rsi+0], rcx
    mov rsi, r14
    add rsi, 512
    jo zyl_rt_trap_ovf_0
    imul rdi, r15, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    add rdi, qword ptr [rbp-56]
    jo zyl_rt_trap_ovf_0
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
.L972_0:
    cmp rdi, 0
    je .L972_2
.L972_3:
    cmp rbx, 0
    jg .L972_1
.L972_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L972_1:
    mov rsi, rbx
    call zy_local_x2Fmain_0__crypto__cr_x2Dzero_x2Dbytes
    mov rax, rbx
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Dzero_x2Dbytes:
    # frame 0
.L973_0:
    cmp rsi, 0
    jg .L973_1
.L973_2:
    mov rax, 0
    ret
.p2align 4
.L973_1:
    mov r8, 0
    mov byte ptr [rdi+0], r8b
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jg .L973_1
    jmp .L973_2
zy_local_x2Fmain_0__crypto__cr_x2Dwipe:
    # frame 0
.L974_0:
    cmp rsi, 0
    jg .L974_1
.L974_2:
    mov rax, 0
    ret
.p2align 4
.L974_1:
    mov r8, 0
    mov qword ptr [rdi+0], r8
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    sub rsi, 8
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jg .L974_1
    jmp .L974_2
zy_local_x2Fmain_0__crypto__cr_x2Dpack:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L975_0:
    cmp r9, r8
    jl .L975_1
.L975_2:
    mov rax, 0
    ret
.p2align 4
.L975_1:
    mov r10, rdi
    add r10, r9
    jo zyl_rt_trap_ovf_0
    imul r11, r9, 8
    jo zyl_rt_trap_ovf_2
    add r11, rsi
    jo zyl_rt_trap_ovf_0
    mov r11, qword ptr [r11+0]
    mov byte ptr [r10+0], r11b
    add r9, 1
    jo zyl_rt_trap_ovf_0
    cmp r9, r8
    jl .L975_1
    jmp .L975_2
zy_local_x2Fmain_0__crypto__cr_x2Dunpack:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L976_0:
    cmp r9, r8
    jl .L976_1
.L976_2:
    mov rax, 0
    ret
.p2align 4
.L976_1:
    imul r10, r9, 8
    jo zyl_rt_trap_ovf_2
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    mov r11, rsi
    add r11, r9
    jo zyl_rt_trap_ovf_0
    movzx r11d, byte ptr [r11+0]
    mov qword ptr [r10+0], r11
    add r9, 1
    jo zyl_rt_trap_ovf_0
    cmp r9, r8
    jl .L976_1
    jmp .L976_2
zy_local_x2Fmain_0__crypto__cr_x2Dwords_x2Ddata:
    # frame 0
    push rbp
    mov rbp, rsp
.L977_0:
    lea rax, [rip+.L978]
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
.L979_0:
    call zyl_words_len
    mov rsi, rax
    cmp rsi, 16
    jge .L979_1
    lea rax, [rip+.L980]
    mov rdi, rax
    mov r8, 15
    mov rdx, rsi
    mov rsi, r8
    pop rbp
    jmp zy_local_x2Fmain_0__tables__tb_x2Doob
.L979_1:
    mov rax, 0
    pop rbp
    ret
zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Dscratch:
    # frame 0
.L981_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_aes@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__crypto__cr_x2Daes_x2Drounds:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L982_0:
    cmp r8, r9
    jge .L982_1
.L982_2:
    imul r10, r8, 16
    jo zyl_rt_trap_ovf_2
    add r10, rsi
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    cmp r8, r9
    jge .L982_1
    jmp .L982_2
.L982_1:
    imul r8, r9, 16
    jo zyl_rt_trap_ovf_2
    add rsi, r8
    jo zyl_rt_trap_ovf_0
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
.L983_0:
    call zyl_cpuid_features
    mov rsi, rax
    and rsi, 1
    cmp rsi, 0
    jg .L983_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L983_1:
    cmp qword ptr [rbp-48], 16
    je .L983_2
    cmp qword ptr [rbp-48], 32
    je .L983_2
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L983_2:
    mov rdi, rbx
    call zyl_words_len
    cmp rax, qword ptr [rbp-48]
    jge .L983_3
    lea rax, [rip+.L984]
    mov r15, rax
    mov r12, qword ptr [rbp-48]
    sub r12, 1
    jo zyl_rt_trap_ovf_1
    mov rdi, rbx
    call zyl_words_len
    mov rsi, rax
    mov rdi, r15
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L983_4
.L983_3:
.L983_4:
    lea rax, [rip+.L985]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov rbx, qword ptr [rsi+16]
    mov rdi, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock
    lea rax, [rip+.L986]
    mov rsi, rax
    mov rdi, r13
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov r12, qword ptr [rsi+16]
    mov rdi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dneed_x2Dblock
    lea rax, [rip+.L987]
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
    jo zyl_rt_trap_ovf_0
    mov r14, qword ptr [rbp-56]
    add r14, 272
    jo zyl_rt_trap_ovf_0
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
    je .L983_5
    mov rsi, 14
.L983_5:
    cmp qword ptr [rbp-48], 16
    jne .L983_6
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
    jmp .L983_7
.L983_6:
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
.L983_7:
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
.L988_0:
    cmp r13, r12
    jl .L988_1
.L988_4:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L988_1:
    mov rdi, rbx
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    sub rsi, r13
    jo zyl_rt_trap_ovf_1
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_318
    mov rsi, rax
    cmp rsi, 0
    jge .L988_2
    cmp rsi, -4
    jne .L988_3
    cmp r13, r12
    jl .L988_1
    jmp .L988_4
.L988_3:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L988_2:
    add r13, rsi
    jo zyl_rt_trap_ovf_0
    cmp r13, r12
    jl .L988_1
    jmp .L988_4
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
.L989_0:
    cmp r14, r13
    jl .L989_1
.L989_4:
    mov rax, r14
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L989_1:
    mov rsi, r12
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    sub rdi, r14
    jo zyl_rt_trap_ovf_1
    mov rdx, rdi
    mov rdi, rbx
    call zyl_rt_sys_0
    mov rsi, rax
    cmp rsi, 0
    jle .L989_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    cmp r14, r13
    jl .L989_1
    jmp .L989_4
.L989_2:
    cmp rsi, -4
    jne .L989_3
    cmp r14, r13
    jl .L989_1
    jmp .L989_4
.L989_3:
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
.L990_0:
    lea rax, [rip+.L991]
    mov rdi, rax
    mov rsi, 524288
    mov r8, 0
    mov rdx, r8
    call zyl_rt_sys_2
    mov r14, rax
    cmp r14, 0
    jge .L990_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L990_1:
    mov rdi, r14
    mov rsi, rbx
    mov rdx, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__crypto__cr_x2Dread_x2Dall
    mov rbx, rax
    mov rdi, r14
    call zyl_rt_sys_3
    cmp rbx, r12
    jne .L990_2
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L990_2:
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
.L992_0:
    cmp rbx, 0
    je .L992_2
.L992_4:
    cmp r12, 0
    jg .L992_1
.L992_2:
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L992_1:
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__crypto__cr_x2Dgetrandom
    mov rsi, rax
    cmp rsi, r12
    jne .L992_3
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
.L992_3:
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
.L993_0:
    cmp r13, r12
    jl .L993_1
.L993_6:
    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L993_1:
    mov rax, r12
    sub rax, r13
    jo zyl_rt_trap_ovf_1
    cmp rax, 256
    jle .L993_2
    mov rsi, 256
    jmp .L993_3
.L993_2:
    mov rsi, r12
    sub rsi, r13
    jo zyl_rt_trap_ovf_1
.L993_3:
    mov r15, rsi
    mov rdi, r14
    mov rsi, r15
    call zyl_random_fill
    cmp rax, r15
    je .L993_4
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L993_4:
    imul rsi, r13, 8
    jo zyl_rt_trap_ovf_2
    mov rdi, rbx
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, 0
    cmp rsi, r15
    jge .L993_5
    mov rdx, r15
    mov rcx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__crypto__cr_x2Dunpack
.L993_5:
    add r13, r15
    jo zyl_rt_trap_ovf_0
    cmp r13, r12
    jl .L993_1
    jmp .L993_6
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
.L994_0:
    cmp rbx, 0
    je .L994_2
.L994_5:
    cmp r12, 0
    jg .L994_1
.L994_2:
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L994_1:
    lea rax, [rip+.L995]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__tables__tb_x2Dwords_x2Dof
    mov rsi, rax
    mov r13, qword ptr [rsi+16]
    mov rdi, rbx
    call zyl_words_len
    cmp r12, rax
    jle .L994_3
    lea rax, [rip+.L996]
    mov r14, rax
    mov r15, r12
    sub r15, 1
    jo zyl_rt_trap_ovf_1
    mov rdi, rbx
    call zyl_words_len
    mov rsi, rax
    mov rdi, r14
    mov rdx, rsi
    mov rsi, r15
    call zy_local_x2Fmain_0__tables__tb_x2Doob
    jmp .L994_4
.L994_3:
.L994_4:
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
.L997_0:
    cmp rdi, 4096
    jge .L997_1
.L997_2:
    lea rax, [rip+.L998]
    mov rbx, rax
    lea rax, [rip+.L999]
    mov rsi, rax
    call zy_local_x2Fmain_0__base__rt_x2Dhex
    mov rdi, rax
    lea rax, [rip+.L1000]
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
.L997_1:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dcode_x2Dp:
    # frame 0
.L1001_0:
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
.L1002_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L1002_1
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zyl_rt_call0
.L1002_1:
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
.L1003_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L1003_1
    mov rdi, rbx
    mov rsi, r12
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_call1
.L1003_1:
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
.L1004_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L1004_1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_call2
.L1004_1:
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
.L1005_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L1005_1
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
.L1005_1:
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
.L1006_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__call__rt_x2Dguard
    mov rax, 4294967296
    cmp rbx, rax
    jge .L1006_1
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
.L1006_1:
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
    jge .L1007
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
    jmp .L1008
.L1007:
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
.L1008:
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
    jge .L1009
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
    jmp .L1010
.L1009:
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
.L1010:
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dmin64:
    # frame 0
.L1011_0:
    mov rax, -9223372036854775808
    ret
zy_local_x2Fmain_0__call__rt_x2Dult:
    # frame 0
.L1012_0:
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
    # frame 312
    push rbp
    mov rbp, rsp
    sub rsp, 312
    mov [rbp-312], rbx
    mov [rbp-304], r12
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
    jo zyl_rt_trap_ovf_0
    mov [rbp-80], rax
    mov rax, [rbp-40]
    mov rcx, 1
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov [rbp-88], rax
    mov rax, [rbp-48]
    mov rcx, 1
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
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
    jge .L1013
    mov rax, 0
    jmp .L1014
.L1013:
    mov rax, 1
.L1014:
    mov [rbp-104], rax
    mov rax, [rbp-104]
    test rax, rax
    je .L1015
    mov rax, 1
    mov [rbp-120], rax
    mov rax, [rbp-88]
    mov rcx, [rbp-120]
    add rax, rcx
    jmp .L1016
.L1015:
    mov rax, [rbp-88]
.L1016:
    mov [rbp-112], rax
    mov rax, [rbp-104]
    test rax, rax
    je .L1017
    mov rax, [rbp-96]
    mov rcx, [rbp-24]
    sub rax, rcx
    jmp .L1018
.L1017:
    mov rax, [rbp-96]
.L1018:
    mov [rbp-128], rax
    mov rax, [rbp-56]
    mov rcx, 1
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov [rbp-136], rax
    mov rax, [rbp-64]
    mov rcx, 1
    mov rdx, rcx
    shl rax, cl
    cmp rdx, 64
    sbb rdx, rdx
    and rax, rdx
    mov [rbp-144], rax
    mov rax, [rbp-144]
    mov rcx, -9223372036854775808
    xor rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rcx, -9223372036854775808
    xor rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    jge .L1019
    mov rax, 0
    jmp .L1020
.L1019:
    mov rax, 1
.L1020:
    mov [rbp-152], rax
    mov rax, [rbp-152]
    test rax, rax
    je .L1021
    mov rax, 1
    mov [rbp-168], rax
    mov rax, [rbp-136]
    mov rcx, [rbp-168]
    add rax, rcx
    jmp .L1022
.L1021:
    mov rax, [rbp-136]
.L1022:
    mov [rbp-160], rax
    mov rax, [rbp-152]
    test rax, rax
    je .L1023
    mov rax, [rbp-144]
    mov rcx, [rbp-16]
    sub rax, rcx
    jmp .L1024
.L1023:
    mov rax, [rbp-144]
.L1024:
    mov [rbp-176], rax
    mov rax, [rbp-16]
    mov rcx, [rbp-176]
    sub rax, rcx
    mov [rbp-184], rax
    mov rax, [rbp-112]
    mov rcx, -9223372036854775808
    xor rax, rcx
    push rax
    mov rax, [rbp-184]
    mov rcx, -9223372036854775808
    xor rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    jge .L1027
    mov rax, 1
    jmp .L1028
.L1027:
    mov rax, [rbp-112]
    mov rcx, [rbp-184]
    cmp rax, rcx
    jne .L1029
    mov rax, [rbp-128]
    mov rcx, 0
    cmp rax, rcx
    sete al
    movzx rax, al
    jmp .L1030
.L1029:
    mov rax, 0
.L1030:
.L1028:
    test rax, rax
    je .L1025
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
    mov rax, [rbp-128]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-160]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-176]
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
    mov rbx, [rbp-312]
    mov r12, [rbp-304]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic_x2Dloop
    jmp .L1026
.L1025:
    mov rax, [rbp-72]
    test rax, rax
    je .L1031
    mov rax, [rbp-80]
    mov rcx, 64
    sub rax, rcx
    jo zyl_rt_trap_ovf_1
    jmp .L1032
.L1031:
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jge .L1033
    mov rax, 0
    mov [rbp-192], rax
    mov rax, 1
    mov [rbp-208], rax
    mov rax, [rbp-160]
    mov rcx, [rbp-208]
    add rax, rcx
    mov [rbp-200], rax
    mov rax, [rbp-192]
    mov rcx, [rbp-200]
    sub rax, rcx
    jmp .L1034
.L1033:
    mov rax, 1
    mov [rbp-216], rax
    mov rax, [rbp-160]
    mov rcx, [rbp-216]
    add rax, rcx
.L1034:
.L1032:
.L1026:
    mov rbx, [rbp-312]
    mov r12, [rbp-304]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__call__rt_x2Dmagic:
    # frame 216
    push rbp
    mov rbp, rsp
    sub rsp, 216
    mov [rbp-216], rbx
    mov [rbp-208], r12
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov rcx, 1
    cmp rax, rcx
    jg .L1037
    mov rax, [rbp-8]
    mov rcx, -1
    cmp rax, rcx
    setge al
    movzx rax, al
    jmp .L1038
.L1037:
    mov rax, 0
.L1038:
    test rax, rax
    je .L1035
    mov rax, 0
    jmp .L1036
.L1035:
    mov rax, -9223372036854775808
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov rcx, 0
    cmp rax, rcx
    jge .L1039
    mov rax, 0
    mov [rbp-40], rax
    mov rax, [rbp-40]
    mov rcx, [rbp-8]
    sub rax, rcx
    jmp .L1040
.L1039:
    mov rax, [rbp-8]
.L1040:
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
    mov [rbp-56], rax
    mov rax, [rbp-24]
    mov rcx, [rbp-56]
    add rax, rcx
    mov [rbp-48], rax
    mov rax, 1
    mov [rbp-80], rax
    mov rax, [rbp-48]
    mov rcx, [rbp-80]
    sub rax, rcx
    mov [rbp-72], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rdx
    mov rax, rdx
    xor edx, edx
    div rcx
    mov rax, rdx
    mov [rbp-88], rax
    mov rax, [rbp-72]
    mov rcx, [rbp-88]
    sub rax, rcx
    mov [rbp-64], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-64]
    mov rcx, rax
    pop rdx
    mov rax, rdx
    xor edx, edx
    div rcx
    mov [rbp-96], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rcx, rax
    pop rdx
    mov rax, rdx
    xor edx, edx
    div rcx
    mov [rbp-104], rax
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-32]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-64]
    sub rsp, 8
    mov [rsp], rax
    mov rax, 63
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-96]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-96]
    mov rcx, [rbp-64]
    imul rax, rcx
    mov [rbp-112], rax
    mov rax, [rbp-24]
    mov rcx, [rbp-112]
    sub rax, rcx
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-104]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-104]
    mov rcx, [rbp-32]
    imul rax, rcx
    mov [rbp-120], rax
    mov rax, [rbp-24]
    mov rcx, [rbp-120]
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
.L1036:
    mov rbx, [rbp-216]
    mov r12, [rbp-208]
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_div_magic
zyl_div_magic:
    # frame 0
.L1041_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic
.globl zyl_div_shift
zyl_div_shift:
    # frame 0
.L1042_0:
    mov rsi, 1
    jmp zy_local_x2Fmain_0__call__rt_x2Dmagic
zy_local_x2Fmain_0__ffitab__ft_x2Dslots:
    # frame 0
.L1043_0:
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
.L1044_0:
    imul rsi, r13, 16
    jo zyl_rt_trap_ovf_2
    mov r14, rbx
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [r14+0]
    cmp rdi, 0
    je .L1044_2
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L1044_1
.L1044_2:
    mov rax, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1044_1:
    add r13, 1
    jo zyl_rt_trap_ovf_0
    and r13, 1023
    jmp .L1044_0
zy_local_x2Fmain_0__ffitab__ft_x2Dput:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12, rdx
.L1045_0:
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
    jne .L1045_1
    mov qword ptr [rsi+8], r12
    mov qword ptr [rsi+0], r13
    mov rsi, r13
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1045_1:
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
.L1046_0:
    lea rax, [rip+zyl_rtg_ffitab_state]
    mov rbx, rax
    mov rsi, qword ptr [rbx+0]
    cmp rsi, 2
    jne .L1046_1
    lea rax, [rip+zyl_rtg_ffitab_slots]
    mov rdi, rax
    mov rax, rdi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1046_1:
    cmp rsi, 0
    jne .L1046_2
    mov rsi, 0
    mov rdi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov r11, rdi
    mov rax, rcx
    lock cmpxchg qword ptr [rdx], r11
    cmp rax, 0
    jne .L1046_2
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
.L1046_2:
    call zyl_rt_sys_24
    jmp .L1046_0
zy_local_x2Fmain_0__ffitab__ft_x2Dfind:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L1047_0:
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
    jne .L1047_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L1047_1:
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
.L1048_0:
    cmp rdi, 0
    jne .L1048_1
    mov rax, 0
    pop rbp
    ret
.L1048_1:
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
.L1049_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1049_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1049_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dfind
    mov rsi, rax
    cmp rsi, 0
    jle .L1049_2
    mov rax, qword ptr [rsi+8]
    pop rbx
    pop rbp
    ret
.L1049_2:
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__ffitab__ft_x2Ddlsym
.globl zyl_ffi_addr
zyl_ffi_addr:
    # frame 0
.L1050_0:
    jmp zyl_ffi_lookup
zy_local_x2Fmain_0__ffitab__ft_x2Dnote:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L1051_0:
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
.L1052_0:
    lea rax, [rip+.L1053]
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
    jne .L1052_1
    mov rsi, r12
    call zyl_cstr_concat
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1052_1:
    mov rbx, rsi
    mov rsi, r12
    call zyl_cstr_concat
    mov r12, rax
    jmp .L1052_0
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
    jge .L1054
    lea rax, [rip+.L1056]
    sub rsp, 8
    mov [rsp], rax
    sub rsp, 16
    lea rax, [rip+.L1057]
    mov rsi, rax
    mov rdi, [rbp-8]
call zy_local_x2Fmain_0__ffitab__ft_x2Dhex
    add rsp, 16
    sub rsp, 8
    mov [rsp], rax
    lea rax, [rip+.L1058]
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
    jmp .L1055
.L1054:
    mov rax, [rbp-16]
    mov rcx, 0
    cmp rax, rcx
    jge .L1061
    mov rax, 1
    jmp .L1062
.L1061:
    mov rax, [rbp-16]
    mov rcx, 6
    cmp rax, rcx
    setg al
    movzx rax, al
.L1062:
    test rax, rax
    je .L1059
    mov rax, [rbp-16]
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+0]
    mov rbx, [rbp-168]
    mov r12, [rbp-160]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitab__ft_x2Dargc_x2Dbad
    jmp .L1060
.L1059:
    mov rax, [rbp-16]
    mov rcx, 0
    cmp rax, rcx
    jne .L1063
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-8]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call0
    mov rsp, r12
    add rsp, 16
    jmp .L1064
.L1063:
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov rcx, 1
    cmp rax, rcx
    jne .L1065
    sub rsp, 16
    mov rdi, [rbp-8]
    mov rsi, [rbp-32]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call1
    mov rsp, r12
    add rsp, 16
    jmp .L1066
.L1065:
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-40], rax
    mov rax, [rbp-16]
    mov rcx, 2
    cmp rax, rcx
    jne .L1067
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
    jmp .L1068
.L1067:
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-48], rax
    mov rax, [rbp-16]
    mov rcx, 3
    cmp rax, rcx
    jne .L1069
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
    jmp .L1070
.L1069:
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-56], rax
    mov rax, [rbp-16]
    mov rcx, 4
    cmp rax, rcx
    jne .L1071
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
    jmp .L1072
.L1071:
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    mov [rbp-64], rax
    mov rax, [rbp-16]
    mov rcx, 5
    cmp rax, rcx
    jne .L1073
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
    jmp .L1074
.L1073:
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
    jo zyl_rt_trap_ovf_0
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
.L1074:
.L1072:
.L1070:
.L1068:
.L1066:
.L1064:
.L1060:
.L1055:
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
.L1075_0:
    lea rax, [rip+.L1076]
    mov rbx, rax
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L1077]
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
.L1078_0:
    lea rax, [rip+.L1079]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_pin@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1080]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_unpin@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1081]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_init@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1082]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_is_alive@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1083]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_spawn@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1084]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1085]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_recv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1086]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_rx@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1087]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_send@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1088]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chan_tx@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1089]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_wait@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1090]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_actor_wait_all@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1091]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_aes_encrypt_block@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1092]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_aesni_available@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1093]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_align_check@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1094]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1095]
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
.L1096_0:
    lea rax, [rip+.L1097]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_capacity@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1098]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_create@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1099]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_destroy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1100]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1101]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arena_used@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1102]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_arg_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1103]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_argc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1104]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1105]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_cas@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1106]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_fetch_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1107]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_load@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1108]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_max@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1109]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_min@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1110]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_store@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1111]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_atomic_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1112]
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
.L1113_0:
    lea rax, [rip+.L1114]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_blake3_hex@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1115]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_byte_slice@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1116]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_byte_slice_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1117]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_append@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1118]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1119]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_cas@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1120]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_fetch_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1121]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_load@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1122]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_max@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1123]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_min@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1124]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_store@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1125]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_atomic_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1126]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_cap@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1127]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1128]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_blake3_hex@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1129]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_bytebuf_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1130]
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
.L1131_0:
    lea rax, [rip+.L1132]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call0@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1133]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call1@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1134]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call2@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1135]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call3@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1136]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call4@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1137]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call5@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1138]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call6@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1139]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call_argv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1140]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_call_on_big_stack@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1141]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cc_compile@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1142]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cc_compile_log@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1143]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_chdir@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1144]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cpuid_features@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1145]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_byte_at@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1146]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_byte_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1147]
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
.L1148_0:
    lea rax, [rip+.L1149]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_count_newlines@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1150]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_decode@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1151]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1152]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_eq@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1153]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_from_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1154]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_from_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1155]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_key_matches@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1156]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_div_magic@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1157]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_div_shift@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1158]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1159]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_ok@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1160]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1161]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1162]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_find@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1163]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_view_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1164]
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
.L1165_0:
    lea rax, [rip+.L1166]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1167]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_of_word@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1168]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_float_bits@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1169]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_float_of_bits@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1170]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_word_load@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1171]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_word_store@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1172]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ptr_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1173]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ptr_cstr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1174]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_addr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1175]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_sanitize@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1176]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_sub@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1177]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_substr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1178]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_to_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1179]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_to_int_base@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1180]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_diag_json@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1181]
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
.L1182_0:
    lea rax, [rip+.L1183]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_dirname_cstr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1184]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1185]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1186]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1187]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attr_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1188]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ensure_arenas@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1189]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_exec_cmd@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1190]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1191]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1192]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_div@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1193]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_error@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1194]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_mul@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1195]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_of_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1196]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_parse@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1197]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_rem@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1198]
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
.L1199_0:
    lea rax, [rip+.L1200]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_text@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1201]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_f_to_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1202]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_lookup@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1203]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_timed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1204]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ffi_timed_argv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1205]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_close_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1206]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_exit@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1207]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_read_line@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1208]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_open_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1209]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_read_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1210]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_file_write_c@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1211]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fnmap_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1212]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fnmap_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1213]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fnmap_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1214]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_fresh_id@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1215]
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
.L1216_0:
    lea rax, [rip+.L1217]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_getenv@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1218]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_contract_warn@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1219]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_err_is@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1220]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_list_zyl_files@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1221]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_list_files@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1222]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_n@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1223]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_n_signed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1224]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_store_n@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1225]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1226]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1227]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_ready@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1228]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_global_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1229]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1230]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1231]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_iglobal_ready@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1232]
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
.L1233_0:
    lea rax, [rip+.L1234]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_repl_global_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1235]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_repl_global_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1236]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_id@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1237]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1238]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1239]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_find@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1240]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_union@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1241]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_raise@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1242]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_uf_level@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1243]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_regions_enabled@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1244]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1245]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1246]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_alloc_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1247]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1248]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1249]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1250]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_view@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1251]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_words_view_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1252]
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
.L1253_0:
    lea rax, [rip+.L1254]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_get_or@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1255]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1256]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_vec_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1257]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_vec_alloc_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1258]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_cap@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1259]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_filled@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1260]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1261]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_array_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1262]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1263]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1264]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_get_or@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1265]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_has@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1266]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1267]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_attrh_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1268]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ref_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1269]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ref_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1270]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ref_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1271]
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
.L1272_0:
    lea rax, [rip+.L1273]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_strbuf_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1274]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_strbuf_new_r@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1275]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_strbuf_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1276]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_cstr_escapes_ok@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1277]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_heap_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1278]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_ralloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1279]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_enter@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1280]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_exit@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1281]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_free@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1282]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_scope_enter@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1283]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_region_live_bytes@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1284]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_heap_block_p@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1285]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_heap_swap@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1286]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_int_text@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1287]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_add@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1288]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_count@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1289]
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
.L1290_0:
    lea rax, [rip+.L1291]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_name@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1292]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_outcome@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1293]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_fail@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1294]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_reset@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1295]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_start@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1296]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_itest_summary@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1297]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_json_quote@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1298]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1299]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_load_byte_signed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1300]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mangle_key@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1301]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1302]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_free@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1303]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_read@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1304]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mem_write@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1305]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mkdir_p@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1306]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_mlock@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1307]
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
.L1308_0:
    lea rax, [rip+.L1309]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_path_exists@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1310]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_pin_alloc@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1311]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_print_float@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1312]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_print_int@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1313]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_print_str@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1314]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_random_fill@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1315]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_random_words@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1316]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_run_bin@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1317]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_session_arena@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1318]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_clear@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1319]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1320]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_global@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1321]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1322]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_smap_put@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1323]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_source_path@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1324]
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
.L1325_0:
    lea rax, [rip+.L1326]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_col@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1327]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_copy@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1328]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_file@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1329]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_line@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1330]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_line_text@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1331]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_off@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1332]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_snippet@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1333]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_snippet_col@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1334]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_offset_at@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1335]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_span_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1336]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_store_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1337]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_store_byte_signed@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1338]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_str_append@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1339]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_str_append_capped@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1340]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_sym_escape@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1341]
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
.L1342_0:
    lea rax, [rip+.L1343]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_flush@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1344]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_height@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1345]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_is_tty@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1346]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_raw_off@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1347]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_raw_on@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1348]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_read_byte@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1349]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_read_byte_timeout@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1350]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_width@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1351]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_term_write@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1352]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_frame_msg@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1353]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_last_msg@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1354]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_pop@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1355]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_try_push@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1356]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_variant_cmp@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1357]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_variant_eq@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1358]
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
.L1359_0:
    lea rax, [rip+.L1360]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_warn_capture@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1361]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_warn_emit@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1362]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_warn_take@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1363]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_word_of_cstr@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1364]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_get@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1365]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_global@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1366]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_len@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1367]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_new@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1368]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_pop@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1369]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_push@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1370]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_set@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1371]
    mov rsi, rax
    mov rax, QWORD PTR [rip+zyl_wvec_truncate@GOTPCREL]
    mov rdi, rax
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__ffitab__ft_x2Dput
    lea rax, [rip+.L1372]
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
.L1373_0:
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
.L1374_0:
    mov rax, QWORD PTR [rip+dlsym@GOTPCREL]
    mov rsi, rax
    cmp rsi, 0
    jne .L1374_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1374_1:
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
.L1375_0:
    mov rsi, 4294967295
    and rsi, rdi
    cmp rsi, 2147483647
    jle .L1375_1
    mov rdi, 4294967296
    mov rax, rsi
    sub rax, rdi
    jo zyl_rt_trap_ovf_1
    ret
.L1375_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__proc__pr_x2Denviron:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1376_0:
    call zyl_rt_envp
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dscratch:
    # frame 0
    push rbp
    mov rbp, rsp
.L1377_0:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov rsi, rax
    mov rax, rsi
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dpid:
    # frame 0
.L1378_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__proc__pr_x2Dstatus:
    # frame 0
.L1379_0:
    mov rax, rdi
    add rax, 8
    jo zyl_rt_trap_ovf_0
    ret
zy_local_x2Fmain_0__proc__pr_x2Dargv:
    # frame 0
.L1380_0:
    mov rax, rdi
    add rax, 16
    jo zyl_rt_trap_ovf_0
    ret
zy_local_x2Fmain_0__proc__pr_x2Dout:
    # frame 0
.L1381_0:
    mov rax, rdi
    add rax, 80
    jo zyl_rt_trap_ovf_0
    ret
zy_local_x2Fmain_0__proc__pr_x2Dwait:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1382_0:
    mov rdi, rsi
    call zy_local_x2Fmain_0__proc__pr_x2Dint
    cmp rax, 0
    je .L1382_1
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1382_1:
    mov edi, dword ptr [rbx+0]
    call zy_local_x2Fmain_0__proc__pr_x2Dint
    mov rdi, rax
    mov rsi, rbx
    add rsi, 8
    jo zyl_rt_trap_ovf_0
    mov r8, 0
    mov r9, 0
    mov rdx, r8
    mov rcx, r9
    call zyl_rt_sys_61
    mov rdi, rax
    call zy_local_x2Fmain_0__proc__pr_x2Dint
    cmp rax, 0
    jge .L1382_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1382_2:
    mov esi, dword ptr [rbx+8]
    mov rax, rsi
    and rax, 127
    cmp rax, 0
    jne .L1382_3
    shr rsi, 8
    and rsi, 255
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1382_3:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dmap_x2Dsize:
    # frame 0
.L1383_0:
    mov rax, 65536
    ret
zy_local_x2Fmain_0__proc__pr_x2Dbuf:
    # frame 0
.L1384_0:
    mov rax, rdi
    add rax, 64
    jo zyl_rt_trap_ovf_0
    ret
zy_local_x2Fmain_0__proc__pr_x2Dbuf_x2Dmax:
    # frame 0
.L1385_0:
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
.L1386_0:
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
    jge .L1386_1
    cmp qword ptr [rbp-48], -4096
    jle .L1386_1
    mov rsi, 0
    sub rsi, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_1
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1386_1:
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
    je .L1386_2
    mov rsi, 1
    jmp .L1386_3
.L1386_2:
    mov rsi, 0
.L1386_3:
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+32], rsi
    cmp r15, 0
    je .L1386_4
    lea rax, [rip+.L1387]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    jmp .L1386_5
.L1386_4:
    mov rsi, 0
.L1386_5:
    mov rdx, qword ptr [rbp-48]
    mov qword ptr [rdx+48], rsi
    mov rsi, qword ptr [rbp-48]
    add rsi, 65504
    jo zyl_rt_trap_ovf_0
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
.L1388_0:
    cmp r13, 0
    jge .L1388_1
.L1388_7:
    mov rsi, 0
    sub rsi, r13
    jo zyl_rt_trap_ovf_1
    jmp .L1388_2
.L1388_1:
    mov rsi, qword ptr [r12+40]
.L1388_2:
    mov r14, rsi
    cmp r13, 0
    jle .L1388_3
    cmp r14, 0
    je .L1388_3
    mov rsi, 0
    mov rdi, 0
    mov r8, 0
    mov rdx, rdi
    mov rdi, r13
    mov rcx, r8
    call zyl_rt_sys_61
    jmp .L1388_4
.L1388_3:
.L1388_4:
    cmp r13, 0
    jle .L1388_5
    cmp r14, 0
    jne .L1388_5
    mov dword ptr [rbx+0], r13d
    jmp .L1388_6
.L1388_5:
.L1388_6:
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
.L1389_0:
    mov rbx, qword ptr [rsi+16]
    mov rdi, qword ptr [rbx+24]
    mov rsi, 0
    cmp rdi, 0
    je .L1389_1
    call zy_local_x2Fmain_0__proc__pr_x2Dredirect
    mov rsi, rax
.L1389_1:
    mov rdi, rsi
    cmp rsi, 0
    jl .L1389_2
    mov rax, qword ptr [rbx+32]
    cmp rax, 0
    jne .L1389_3
    mov rsi, qword ptr [rbx+0]
    mov r8, qword ptr [rbx+8]
    mov r9, qword ptr [rbx+16]
    mov rdi, rsi
    mov rsi, r8
    mov rdx, r9
    call zyl_rt_sys_59
    mov rsi, rax
    jmp .L1389_4
.L1389_3:
    mov r8, qword ptr [rbx+0]
    mov rdi, rbx
    mov rsi, r8
    call zy_local_x2Fmain_0__proc__pr_x2Dexecvp
    mov rsi, rax
.L1389_4:
    mov rdi, rsi
.L1389_2:
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
.L1390_0:
    mov rsi, 0
    sub rsi, r12
    jo zyl_rt_trap_ovf_1
    mov qword ptr [rbx+40], rsi
    mov rdi, 127
    call zyl_rt_sys_60
    jmp .L1390_0
zy_local_x2Fmain_0__proc__pr_x2Dredirect:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L1391_0:
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
    jge .L1391_1
    mov rax, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1391_1:
    mov r12, 0
    cmp rbx, 1
    je .L1391_2
    mov rsi, 1
    mov rdi, rbx
    call zyl_rt_sys_33
    mov r12, rax
    mov rdi, rbx
    call zyl_rt_sys_3
.L1391_2:
    cmp r12, 0
    jge .L1391_3
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1391_3:
    mov rdi, 1
    mov rsi, 2
    call zyl_rt_sys_33
    mov rsi, rax
    cmp rsi, 0
    jge .L1391_4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1391_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__proc__pr_x2Dhas_x2Dslash:
    # frame 0
.L1392_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 0
    jne .L1392_1
    mov rax, 0
    ret
.L1392_1:
    cmp rsi, 47
    jne .L1392_2
    mov rax, 1
    ret
.L1392_2:
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1392_0
zy_local_x2Fmain_0__proc__pr_x2Dstrnlen:
    # frame 0
    mov r8, rdx
.L1393_0:
    cmp r8, rsi
    jge .L1393_2
.L1393_3:
    mov r9, rdi
    add r9, r8
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [r9+0]
    cmp rax, 0
    jne .L1393_1
.L1393_2:
    mov rax, r8
    ret
.L1393_1:
    add r8, 1
    jo zyl_rt_trap_ovf_0
    cmp r8, rsi
    jge .L1393_2
    jmp .L1393_3
zy_local_x2Fmain_0__proc__pr_x2Dchrnul:
    # frame 0
.L1394_0:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 0
    je .L1394_2
    cmp r8, rsi
    jne .L1394_1
.L1394_2:
    mov rax, rdi
    ret
.L1394_1:
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1394_0
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
.L1395_0:
    movzx eax, byte ptr [r12+0]
    cmp rax, 0
    jne .L1395_1
    mov rax, -2
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1395_1:
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dhas_x2Dslash
    cmp rax, 0
    je .L1395_2
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
.L1395_2:
    mov rsi, qword ptr [rbx+48]
    cmp rsi, 0
    jne .L1395_3
    lea rax, [rip+.L1396]
    mov rdi, rax
    jmp .L1395_4
.L1395_3:
    mov rdi, rsi
.L1395_4:
    mov r13, rdi
    mov rsi, 255
    mov rdi, 0
    mov rdx, rdi
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dstrnlen
    mov rsi, rax
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    cmp rsi, 255
    jle .L1395_5
    mov rax, -36
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1395_5:
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
.L1397_0:
    cmp rdi, 13
    jne .L1397_1
.L1397_6:
    mov rax, 1
    ret
.L1397_1:
    cmp rdi, 2
    jne .L1397_2
    mov rax, 1
    ret
.L1397_2:
    cmp rdi, 116
    jne .L1397_3
    mov rax, 1
    ret
.L1397_3:
    cmp rdi, 20
    jne .L1397_4
    mov rax, 1
    ret
.L1397_4:
    cmp rdi, 19
    jne .L1397_5
    mov rax, 1
    ret
.L1397_5:
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
.L1398_0:
    mov rsi, 58
    mov rdi, r14
    call zy_local_x2Fmain_0__proc__pr_x2Dchrnul
    mov rbx, rax
    mov rsi, rbx
    sub rsi, r14
    jo zyl_rt_trap_ovf_1
    mov rdi, r13
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    add rax, rdi
    jo zyl_rt_trap_ovf_0
    cmp rax, 4400
    jle .L1398_1
    mov rdi, -36
    jmp .L1398_2
.L1398_1:
    mov rdi, qword ptr [rbp-48]
    mov rdx, rsi
    mov rsi, r14
    mov rcx, qword ptr [rbp-56]
    mov r8, r13
    call zy_local_x2Fmain_0__proc__pr_x2Dexec_x2Dat
    mov rdi, rax
.L1398_2:
    mov r12, rdi
    mov rdi, 0
    sub rdi, r12
    jo zyl_rt_trap_ovf_1
    call zy_local_x2Fmain_0__proc__pr_x2Dpath_x2Dnext_x2Dp
    cmp rax, 0
    jne .L1398_3
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1398_3:
    cmp r15, 0
    je .L1398_4
    mov rsi, 1
    jmp .L1398_5
.L1398_4:
    mov rax, r12
    cmp rax, -13
    sete al
    movzx rax, al
    mov rsi, rax
.L1398_5:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L1398_6
    cmp rsi, 0
    je .L1398_7
    mov rax, -13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1398_7:
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1398_6:
    mov r14, rbx
    add r14, 1
    jo zyl_rt_trap_ovf_0
    mov r15, rsi
    jmp .L1398_0
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
.L1399_0:
    mov r15, rbx
    add r15, 64
    jo zyl_rt_trap_ovf_0
    mov rdi, r15
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r15
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, 47
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, 1
    cmp r12, 0
    jg .L1399_1
    mov rsi, 0
.L1399_1:
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, r15
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
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
.L1400_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1400_1
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1400_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r12, rax
    mov rsi, r12
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L1401]
    mov rdi, rax
    mov qword ptr [rsi+0], rdi
    lea rax, [rip+.L1402]
    mov rdi, rax
    mov qword ptr [rsi+8], rdi
    mov qword ptr [rsi+16], rbx
    mov rdi, 0
    mov qword ptr [rsi+24], rdi
    lea rax, [rip+.L1403]
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
.L1404_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r14, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    mov rax, r13
    sub rax, 1
    jo zyl_rt_trap_ovf_1
    cmp rsi, rax
    jle .L1404_1
    mov rdi, r13
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    jmp .L1404_2
.L1404_1:
    mov rdi, rsi
.L1404_2:
    mov r13, rdi
    mov rdi, r13
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r15, rax
    cmp r15, 0
    jne .L1404_3
    mov rax, 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1404_3:
    mov rsi, r13
    cmp r14, r13
    jg .L1404_4
    mov rsi, r14
.L1404_4:
    mov r14, rsi
    mov rdi, r15
    mov rsi, rbx
    mov rdx, r14
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdi, r15
    add rdi, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, r13
    sub rsi, r14
    jo zyl_rt_trap_ovf_1
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r15
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L1405_0:
    cmp r13, 0
    jg .L1405_1
.L1405_4:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L1405_1:
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r13
    call zyl_rt_sys_1
    mov rsi, rax
    cmp rsi, 0
    jle .L1405_2
    add r12, rsi
    jo zyl_rt_trap_ovf_0
    sub r13, rsi
    jo zyl_rt_trap_ovf_1
    cmp r13, 0
    jg .L1405_1
    jmp .L1405_4
.L1405_2:
    cmp rsi, -4
    jne .L1405_3
    cmp r13, 0
    jg .L1405_1
    jmp .L1405_4
.L1405_3:
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
.L1406_0:
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
.L1407_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    cmp r12, 6
    jl .L1407_2
    mov rsi, r12
    sub rsi, 6
    jo zyl_rt_trap_ovf_1
    mov rdi, rbx
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L1408]
    mov rsi, rax
    mov r8, 6
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dmem_x2Deq
    cmp rax, 0
    jne .L1407_1
.L1407_2:
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1407_1:
    mov rsi, r12
    sub rsi, 6
    jo zyl_rt_trap_ovf_1
    mov rdi, rbx
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
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
.L1409_0:
    cmp r13, 0
    jne .L1409_1
.L1409_6:
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.p2align 4
.L1409_1:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_rand@tpoff]
    mov r14, rax
    mov rsi, 8
    mov rdi, r14
    call zyl_random_fill
    cmp rax, 8
    je .L1409_2
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1409_2:
    mov rsi, qword ptr [r14+0]
    mov rdi, 0
    cmp rdi, 6
    jge .L1409_3
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dfill_x2Dx
.L1409_3:
    mov rdi, -100
    mov rsi, 194
    mov r8, 384
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r8
    call zyl_rt_sys_257
    mov rsi, rax
    cmp rsi, 0
    jl .L1409_4
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1409_4:
    cmp rsi, -17
    jne .L1409_5
    sub r13, 1
    jo zyl_rt_trap_ovf_1
    cmp r13, 0
    jne .L1409_1
    jmp .L1409_6
.L1409_5:
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
.L1410_0:
    cmp r8, 6
    jl .L1410_1
.L1410_2:
    mov rax, 0
    ret
.p2align 4
.L1410_1:
    mov r9, rdi
    add r9, r8
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L1411]
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
    cmp r8, 6
    jl .L1410_1
    jmp .L1410_2
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
.L1412_0:
    mov rbx, rdi
    lea rax, [rip+.L1413]
    mov rdi, rax
    call zyl_rt_getenv
    mov rsi, rax
    cmp rsi, 0
    jne .L1412_1
    lea rax, [rip+.L1414]
    mov rdi, rax
    jmp .L1412_2
.L1412_1:
    mov rdi, rsi
.L1412_2:
    lea rax, [rip+.L1415]
    mov rsi, rax
    mov r8, 512
    mov rdx, r8
    call zy_local_x2Fmain_0__proc__pr_x2Dcat2
    mov r12, rax
    cmp r12, 0
    jne .L1412_3
    mov rax, -1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1412_3:
    mov rdi, r12
    call zy_local_x2Fmain_0__proc__pr_x2Dmkstemp
    mov r13, rax
    cmp r13, 0
    jge .L1412_4
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
.L1412_4:
    lea rax, [rip+.L1416]
    mov r14, rax
    mov rdi, r14
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, r14
    call zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall
    cmp rbx, 0
    jne .L1412_5
    lea rax, [rip+.L1417]
    mov rsi, rax
    jmp .L1412_6
.L1412_5:
    mov rsi, rbx
.L1412_6:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, r13
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dwrite_x2Dall
    lea rax, [rip+.L1418]
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
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L1419]
    mov rsi, rax
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+8], r12
    mov rsi, 0
    mov qword ptr [rbx+16], rsi
    lea rax, [rip+.L1420]
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
.L1421_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_stat@tpoff]
    mov r12, rax
    mov rsi, r12
    call zyl_rt_sys_4
    cmp rax, 0
    je .L1421_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1421_1:
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
.L1422_0:
    lea rax, [rip+.L1423]
    mov r9, rax
    mov qword ptr [rdi+0], r9
    lea rax, [rip+.L1424]
    mov r9, rax
    mov qword ptr [rdi+8], r9
    mov qword ptr [rdi+16], rsi
    lea rax, [rip+.L1425]
    mov rsi, rax
    mov qword ptr [rdi+24], rsi
    mov rsi, 4
    imul r9, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L1426]
    mov r10, rax
    mov qword ptr [r9+0], r10
    mov r9, rsi
    add r9, 1
    jo zyl_rt_trap_ovf_0
    imul r9, r9, 8
    jo zyl_rt_trap_ovf_2
    add r9, rdi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r9+0], r8
    mov r8, rsi
    add r8, 2
    jo zyl_rt_trap_ovf_0
    imul r8, r8, 8
    jo zyl_rt_trap_ovf_2
    add r8, rdi
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L1427]
    mov r9, rax
    mov qword ptr [r8+0], r9
    add rsi, 3
    jo zyl_rt_trap_ovf_0
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
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
.L1428_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r13, rax
    cmp r13, 2
    jl .L1428_1
    mov rsi, r13
    sub rsi, 2
    jo zyl_rt_trap_ovf_1
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rsi+0]
    cmp rax, 46
    jne .L1428_1
    mov rsi, r13
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    add rsi, rbx
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rsi+0]
    cmp rax, 115
    jne .L1428_1
    mov rax, r13
    sub rax, 2
    jo zyl_rt_trap_ovf_1
    cmp rax, 512
    jl .L1428_2
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1428_2:
    mov rsi, r13
    sub rsi, 2
    jo zyl_rt_trap_ovf_1
    mov rdi, r12
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r13
    sub rsi, 2
    jo zyl_rt_trap_ovf_1
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1428_1:
    mov rax, r13
    add rax, 4
    jo zyl_rt_trap_ovf_0
    cmp rax, 512
    jl .L1428_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1428_3:
    mov rdi, r12
    mov rsi, rbx
    mov rdx, r13
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rdi, r12
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L1429]
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
.L1430_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1430_1
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1430_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r12, rax
    mov rsi, r12
    add rsi, 80
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dout_x2Dpath
    cmp rax, 0
    jne .L1430_2
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1430_2:
    mov rdi, r12
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    add rsi, 80
    jo zyl_rt_trap_ovf_0
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dcc_x2Dargv
    lea rax, [rip+.L1431]
    mov rsi, rax
    mov rdi, r12
    add rdi, 16
    jo zyl_rt_trap_ovf_0
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
.L1432_0:
    mov rbx, rdi
    mov r12, rsi
    cmp rbx, 0
    je .L1432_2
    cmp r12, 0
    jne .L1432_1
.L1432_2:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1432_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r13, rax
    mov rsi, r13
    add rsi, 80
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dout_x2Dpath
    cmp rax, 0
    jne .L1432_3
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1432_3:
    mov rdi, r13
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    mov rsi, r13
    add rsi, 80
    jo zyl_rt_trap_ovf_0
    mov rdx, rsi
    mov rsi, rbx
    call zy_local_x2Fmain_0__proc__pr_x2Dcc_x2Dargv
    lea rax, [rip+.L1433]
    mov rsi, rax
    mov rdi, r13
    add rdi, 16
    jo zyl_rt_trap_ovf_0
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
.L1434_0:
    mov rbx, rdi
    cmp rbx, 0
    jne .L1434_1
    mov rax, -1
    pop r12
    pop rbx
    pop rbp
    ret
.L1434_1:
    call zyl_out_flush
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_proc_scratch@tpoff]
    mov r12, rax
    mov rsi, r12
    add rsi, 16
    jo zyl_rt_trap_ovf_0
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
.L1435_0:
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
.L1436_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_start_rlimit@tpoff]
    mov rbx, rax
    mov rdi, 3
    mov rsi, rbx
    call zyl_rt_sys_97
    cmp rax, 0
    jne .L1436_1
    mov rdi, qword ptr [rbx+0]
    mov rsi, qword ptr [rbx+8]
    call zy_local_x2Fmain_0__start__sr_x2Dult
    cmp rax, 0
    je .L1436_1
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
.L1436_1:
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
.L1437_0:
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
    jne .L1437_1
    jmp .L1437_0
.L1437_1:
    cmp rsi, 8
    jne .L1437_2
    mov rdi, qword ptr [rbx+0]
    jmp .L1437_3
.L1437_2:
    mov rdi, 0
.L1437_3:
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
.L1438_0:
    lea rax, [rip+zyl_rtg_start_once]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1438_1
    mov rdi, 1
    mov qword ptr [rsi+0], rdi
    call zy_local_x2Fmain_0__start__sr_x2Dguard_x2Dinit
    call zy_local_x2Fmain_0__start__sr_x2Draise_x2Dstack_x2Dlimit
    call zy_local_x2Fmain_0__start__sr_x2Dlibc_x2Datexit
    mov rax, QWORD PTR [rip+zyl_runtime_cleanup@GOTPCREL]
    mov rdi, rax
    call zyl_rt_atexit
    jmp .L1438_2
.L1438_1:
.L1438_2:
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
.L1439_0:
    call zyl_out_flush
    call zyl_ffi_abandoned
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 0
    jne .L1439_1
    call zyl_arenas_destroy
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1439_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.globl zyl_term_flush
zyl_term_flush:
    # frame 0
.L1440_0:
    jmp zyl_out_flush
.globl zyl_term_atexit
zyl_term_atexit:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1441_0:
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
.L1442_0:
    mov rax, QWORD PTR [rip+__cxa_atexit@GOTPCREL]
    mov rdi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1442_1
    cmp rdi, 0
    jle .L1442_1
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
.L1442_1:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dg:
    # frame 0
.L1443_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Dlock:
    # frame 0
.L1444_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    jmp zyl_rt_mutex_lock
zy_local_x2Fmain_0__chan__ch_x2Dunlock:
    # frame 0
.L1445_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__chan__ch_x2Dwake:
    # frame 0
.L1446_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    jmp zyl_rt_cond_broadcast
zy_local_x2Fmain_0__chan__ch_x2Dmode:
    # frame 0
.L1447_0:
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
.L1448_0:
    lea rax, [rip+.L1449]
    mov rdi, rax
    call zyl_rt_getenv
    mov rbx, rax
    lea rax, [rip+.L1450]
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
    jle .L1448_1
    lea rax, [rip+.L1451]
    mov rsi, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrcmp
    cmp rax, 0
    jne .L1448_1
    mov rsi, 2
    jmp .L1448_2
.L1448_1:
    mov rdi, 3
    cmp r12, 0
    jg .L1448_3
    mov rdi, 1
.L1448_3:
    mov rsi, rdi
.L1448_2:
    mov qword ptr [r13+24], rsi
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Ddigits:
    # frame 0
.L1452_0:
    cmp rdi, 0
    jne .L1452_1
.L1452_3:
    mov rax, 0
    ret
.p2align 4
.L1452_1:
    movzx r8d, byte ptr [rdi+0]
    cmp r8, 48
    jl .L1452_2
    cmp r8, 57
    jg .L1452_2
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    imul rsi, rsi, 10
    jo zyl_rt_trap_ovf_2
    sub r8, 48
    jo zyl_rt_trap_ovf_1
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    cmp rdi, 0
    jne .L1452_1
    jmp .L1452_3
.L1452_2:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Ddet_x2Dp:
    # frame 0
.L1453_0:
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
.L1454_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 3
    je .L1454_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1454_1:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    add rsi, 48
    jo zyl_rt_trap_ovf_0
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
    jge .L1454_2
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1454_2:
    cmp rsi, 6
    jge .L1454_3
    call zyl_rt_sys_24
    mov rsp, rbp
    pop rbp
    ret
.L1454_3:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_ts@tpoff]
    mov rdi, rax
    mov r8, 0
    mov qword ptr [rdi+0], r8
    mov r8, 20000
    cmp rsi, 6
    je .L1454_4
    mov r8, 200000
.L1454_4:
    mov qword ptr [rdi+8], r8
    mov rsi, 0
    call zyl_rt_sys_35
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dmix:
    # frame 0
.L1455_0:
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
.L1456_0:
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
.L1457_0:
    lea rax, [rip+zyl_rtg_chan_owners]
    mov rsi, rax
    imul rdi, rdi, 32
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp:
    # frame 0
    push rbp
    mov rbp, rsp
.L1458_0:
    cmp rdi, 1
    jne .L1458_1
.L1458_5:
    mov r8, qword ptr [rsi+24]
    mov r9, qword ptr [rsi+8]
    mov rax, r8
    mov rcx, r9
    cmp rax, rcx
    setl al
    movzx rax, al
    pop rbp
    ret
.L1458_1:
    cmp rdi, 2
    jne .L1458_2
    mov rax, qword ptr [rsi+24]
    cmp rax, 0
    jle .L1458_3
    mov rax, 1
    pop rbp
    ret
.L1458_3:
    mov r8, qword ptr [rsi+32]
    mov rax, r8
    cmp rax, 1
    sete al
    movzx rax, al
    mov r8, rax
    mov rax, r8
    pop rbp
    ret
.L1458_2:
    cmp rdi, 3
    jne .L1458_4
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
.L1458_4:
    mov rax, 1
    pop rbp
    ret
zy_local_x2Fmain_0__chan__ch_x2Dlive_x2Dp:
    # frame 0
    push rbp
    mov rbp, rsp
.L1459_0:
    cmp rdi, 1
    jne .L1459_1
.L1459_2:
    mov rax, 1
    pop rbp
    ret
.L1459_1:
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
.L1460_0:
    cmp rbx, r12
    jle .L1460_1
.L1460_3:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1460_1:
    lea rax, [rip+zyl_rtg_chan_owners]
    mov r13, rax
    imul rsi, rbx, 32
    jo zyl_rt_trap_ovf_2
    add r13, rsi
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dlive_x2Dp
    cmp rax, 0
    je .L1460_2
    mov rdi, qword ptr [r13+8]
    mov rsi, qword ptr [r13+16]
    call zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp
    cmp rax, 0
    je .L1460_2
    mov rax, 1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1460_2:
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    cmp rbx, r12
    jle .L1460_1
    jmp .L1460_3
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
.L1461_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_owner_id@tpoff]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    mov rdi, 1
    cmp rsi, 0
    je .L1461_1
    mov rdi, rsi
.L1461_1:
    mov r13, rdi
    lea rax, [rip+zyl_rtg_chan_owners]
    mov r14, rax
    imul rsi, r13, 32
    jo zyl_rt_trap_ovf_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp
    cmp rax, 0
    je .L1461_2
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 2
    jne .L1461_3
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+32]
    cmp rax, r13
    jne .L1461_2
.L1461_3:
    mov rsi, 0
    mov qword ptr [r14+8], rsi
    mov rax, rsi
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1461_2:
    mov qword ptr [r14+8], rbx
    mov qword ptr [r14+16], r12
    call zy_local_x2Fmain_0__chan__ch_x2Dcheck
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 2
    jne .L1461_4
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rax, qword ptr [rsi+32]
    cmp rax, r13
    jne .L1461_4
    mov rdi, r13
    call zy_local_x2Fmain_0__chan__ch_x2Dpass
    jmp .L1461_5
.L1461_4:
.L1461_5:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    call zyl_rt_cond_wait
    jmp .L1461_0
zy_local_x2Fmain_0__chan__ch_x2Dcheck:
    # frame 0
    push rbp
    mov rbp, rsp
.L1462_0:
    mov rdi, 1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov rsi, qword ptr [rsi+16]
    call zy_local_x2Fmain_0__chan__ch_x2Dprogress_x2Dp
    cmp rax, 0
    je .L1462_1
    mov rax, 0
    pop rbp
    ret
.L1462_1:
    pop rbp
    jmp zy_local_x2Fmain_0__chan__ch_x2Ddeadlock
zy_local_x2Fmain_0__chan__ch_x2Dpass:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
.L1463_0:
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
    je .L1463_1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    mov qword ptr [rdi+32], rsi
.L1463_1:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_cond_broadcast
zy_local_x2Fmain_0__chan__ch_x2Dsucc:
    # frame 0
.L1464_0:
    cmp rdi, rsi
    jl .L1464_1
.L1464_2:
    mov rax, 1
    ret
.L1464_1:
    mov rax, rdi
    add rax, 1
    jo zyl_rt_trap_ovf_0
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
.L1465_0:
    cmp rbx, r12
    jne .L1465_1
.L1465_4:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1465_1:
    lea rax, [rip+zyl_rtg_chan_owners]
    mov r14, rax
    imul rsi, rbx, 32
    jo zyl_rt_trap_ovf_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dlive_x2Dp
    cmp rax, 0
    je .L1465_2
    mov rdi, qword ptr [r14+8]
    mov rsi, qword ptr [r14+16]
    call zy_local_x2Fmain_0__chan__ch_x2Dready_x2Dp
    cmp rax, 0
    je .L1465_2
    mov rax, rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1465_2:
    mov rsi, 1
    cmp rbx, r13
    jge .L1465_3
    mov rsi, rbx
    add rsi, 1
    jo zyl_rt_trap_ovf_0
.L1465_3:
    mov rbx, rsi
    cmp rbx, r12
    jne .L1465_1
    jmp .L1465_4
zy_local_x2Fmain_0__chan__ch_x2Ddeadlock:
    # frame 0
    push rbp
    mov rbp, rsp
.L1466_0:
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
    lea rax, [rip+.L1467]
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
.L1468_0:
    cmp rbx, r12
    jle .L1468_1
.L1468_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1468_1:
    mov rdi, rbx
    call zyl_out_actor_emit
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    cmp rbx, r12
    jle .L1468_1
    jmp .L1468_2
.globl zyl_chan_exit
zyl_chan_exit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1469_0:
    call zyl_out_flush
    mov rax, QWORD PTR [rip+fflush@GOTPCREL]
    mov rdi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1469_1
    cmp rdi, 0
    jle .L1469_1
    mov rsi, 0
    call zyl_rt_call1
    jmp .L1469_2
.L1469_1:
.L1469_2:
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_sys_231
zy_local_x2Fmain_0__chan__ch_x2Dmagic:
    # frame 0
.L1470_0:
    mov rax, 1514357326
    ret
zy_local_x2Fmain_0__chan__tx_x2Dmagic:
    # frame 0
.L1471_0:
    mov rax, 1514363992
    ret
zy_local_x2Fmain_0__chan__rx_x2Dmagic:
    # frame 0
.L1472_0:
    mov rax, 1514360920
    ret
zy_local_x2Fmain_0__chan__ch_x2Dpanic:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1473_0:
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
.L1474_0:
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
.L1475_0:
    cmp rbx, 1
    jl .L1475_2
.L1475_5:
    cmp rbx, 16777216
    jle .L1475_1
.L1475_2:
    lea rax, [rip+.L1476]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_panic
.L1475_1:
    mov rdi, 64
    call zyl_heap_alloc
    mov r12, rax
    imul rdi, rbx, 8
    jo zyl_rt_trap_ovf_2
    call zyl_heap_alloc
    mov r13, rax
    cmp r12, 0
    je .L1475_4
    cmp r13, 0
    jne .L1475_3
.L1475_4:
    lea rax, [rip+.L1477]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_panic
.L1475_3:
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
.L1478_0:
    mov rax, qword ptr [rdi+40]
    ret
.globl zyl_chan_rx
zyl_chan_rx:
    # frame 0
.L1479_0:
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
.L1480_0:
    mov rdi, rbx
    call zyl_heap_block_p
    cmp rax, 0
    je .L1480_2
    mov rdi, rbx
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    call zyl_heap_block_p
    cmp rax, 0
    jne .L1480_1
.L1480_2:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1480_1:
    mov r12, qword ptr [rbx+0]
    cmp r12, 1514363992
    je .L1480_3
    cmp r12, 1514360920
    je .L1480_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1480_3:
    mov r13, qword ptr [rbx+8]
    mov rdi, r13
    call zyl_heap_block_p
    cmp rax, 0
    je .L1480_5
    mov rdi, r13
    add rdi, 56
    jo zyl_rt_trap_ovf_0
    call zyl_heap_block_p
    cmp rax, 0
    jne .L1480_4
.L1480_5:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1480_4:
    mov rax, qword ptr [r13+0]
    cmp rax, 1514357326
    jne .L1480_6
    mov rsi, 40
    cmp r12, 1514363992
    je .L1480_7
    mov rsi, 48
.L1480_7:
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L1480_6:
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
.L1481_0:
    mov rbx, qword ptr [rdi+16]
    call zyl_owner_self
    cmp rbx, rax
    jne .L1481_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1481_1:
    lea rax, [rip+.L1482]
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
.L1483_0:
    call zy_local_x2Fmain_0__chan__ch_x2Dchaos
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Down_x2Dcheck
    mov rdi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp
    mov r13, rax
    cmp r13, 0
    je .L1483_1
    mov rdi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Down_x2Dcheck
    jmp .L1483_2
.L1483_1:
.L1483_2:
    mov rbx, qword ptr [rbx+8]
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, 1
    mov rsi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dwait
    cmp r13, 0
    je .L1483_3
    mov rsi, 0
    mov qword ptr [r12+16], rsi
    jmp .L1483_4
.L1483_3:
.L1483_4:
    mov rsi, qword ptr [rbx+16]
    mov rdi, qword ptr [rbx+24]
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rbx+8]
    mov rax, rsi
    mov rcx, rdi
    test rcx, rcx
    jz zyl_rt_trap_div0_4
    cmp rcx, -1
    jne .L1484
    xor eax, eax
    jmp .L1485
.L1484:
    cqo
    idiv rcx
    mov rax, rdx
.L1485:
    mov rsi, rax
    mov rdi, qword ptr [rbx+56]
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+0], r12
    mov rsi, qword ptr [rbx+24]
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbx+24], rsi
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    jo zyl_rt_trap_ovf_0
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
.L1486_0:
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
    jne .L1486_1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_unlock
    lea rax, [rip+.L1487]
    mov rdi, rax
    pop r12
    pop rbx
    pop rbp
    jmp zyl_panic
.L1486_1:
    mov rsi, qword ptr [rbx+16]
    mov rdi, qword ptr [rbx+56]
    imul r8, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov r12, qword ptr [rdi+0]
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rbx+8]
    mov rax, rsi
    mov rcx, rdi
    test rcx, rcx
    jz zyl_rt_trap_div0_4
    cmp rcx, -1
    jne .L1488
    xor eax, eax
    jmp .L1489
.L1488:
    cqo
    idiv rcx
    mov rax, rdx
.L1489:
    mov rsi, rax
    mov qword ptr [rbx+16], rsi
    mov rsi, qword ptr [rbx+24]
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    mov qword ptr [rbx+24], rsi
    mov rdi, r12
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp
    cmp rax, 0
    je .L1486_2
    mov rax, qword ptr [r12+16]
    cmp rax, 0
    jne .L1486_2
    call zyl_owner_self
    mov rsi, rax
    mov qword ptr [r12+16], rsi
    jmp .L1486_3
.L1486_2:
.L1486_3:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    jo zyl_rt_trap_ovf_0
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
.L1490_0:
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
.L1491_0:
    lea rax, [rip+zyl_rtg_chan_reg]
    mov r12, rax
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov r13, qword ptr [r12+8]
    mov rax, qword ptr [r12+16]
    cmp r13, rax
    jge .L1491_1
    mov rsi, 1
    jmp .L1491_2
.L1491_1:
    mov rdi, 64
    cmp r13, 0
    je .L1491_3
    imul rdi, r13, 2
    jo zyl_rt_trap_ovf_2
.L1491_3:
    mov r14, rdi
    mov rdi, qword ptr [r12+0]
    imul r8, r14, 8
    jo zyl_rt_trap_ovf_2
    mov rsi, r8
    call zyl_rt_realloc
    mov rdi, rax
    mov r8, 0
    cmp rdi, 0
    je .L1491_4
    mov qword ptr [r12+0], rdi
    mov qword ptr [r12+16], r14
    mov r8, 1
.L1491_4:
    mov rsi, r8
.L1491_2:
    mov rax, rsi
    cmp rax, 0
    je .L1491_5
    mov rsi, qword ptr [r12+0]
    imul rdi, r13, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rsi+0], rbx
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r12+8], rsi
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_rt_mutex_unlock
.L1491_5:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_unlock
    lea rax, [rip+.L1492]
    mov rdi, rax
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    jmp zyl_panic
zy_local_x2Fmain_0__chan__ch_x2Dclose_x2Downed:
    # frame 0
.L1493_0:
    lea rax, [rip+zyl_rtg_chan_reg]
    mov r8, rax
    mov rax, qword ptr [r8+8]
    cmp rsi, rax
    jl .L1493_1
    mov rax, 0
    ret
.L1493_1:
    mov r8, qword ptr [r8+0]
    imul r9, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r8, r9
    jo zyl_rt_trap_ovf_0
    mov r8, qword ptr [r8+0]
    mov r9, qword ptr [r8+40]
    mov rax, qword ptr [r9+16]
    cmp rax, rdi
    jne .L1493_2
    mov r9, 1
    mov qword ptr [r8+32], r9
    jmp .L1493_3
.L1493_2:
.L1493_3:
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1493_0
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
.L1494_0:
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
    jle .L1494_1
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rsi, rax
    mov qword ptr [rsi+16], rbx
    jmp .L1494_2
.L1494_1:
.L1494_2:
    cmp r12, 0
    je .L1494_3
    mov r13, 0
    mov rsi, r12
    sub rsi, 8
    jo zyl_rt_trap_ovf_1
    mov r14, qword ptr [rsi+0]
    call zyl_owner_self
    mov rsi, rax
    mov rdi, r12
    mov rdx, r14
    mov rcx, rsi
    mov rsi, r13
    mov r8, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dmove_x2Dwords
.L1494_3:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov r12, qword ptr [rsi+0]
    cmp r12, 0
    je .L1494_4
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+0], rdi
    mov r13, 0
    mov rsi, r12
    sub rsi, 8
    jo zyl_rt_trap_ovf_1
    mov r14, qword ptr [rsi+0]
    call zyl_owner_self
    mov rsi, rax
    mov rdi, r12
    mov rdx, r14
    mov rcx, rsi
    mov rsi, r13
    mov r8, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dmove_x2Dwords
.L1494_4:
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
.L1495_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_chan_moves@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_chan_spawn_moves
zyl_chan_spawn_moves:
    # frame 0
.L1496_0:
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
.L1497_0:
    cmp r12, r13
    jl .L1497_1
.L1497_4:
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
.L1497_1:
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    add rsi, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov rbx, qword ptr [rsi+0]
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dendpoint_x2Dp
    cmp rax, 0
    je .L1497_2
    mov rax, qword ptr [rbx+16]
    cmp rax, r14
    jne .L1497_2
    mov qword ptr [rbx+16], r15
    jmp .L1497_3
.L1497_2:
.L1497_3:
    add r12, 1
    jo zyl_rt_trap_ovf_0
    cmp r12, r13
    jl .L1497_1
    jmp .L1497_4
.globl zyl_chan_actor_enter
zyl_chan_actor_enter:
    # frame 0
    push rbp
    mov rbp, rsp
.L1498_0:
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
.L1499_0:
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
    jne .L1499_1
    mov rdi, rbx
    call zy_local_x2Fmain_0__chan__ch_x2Dpass
    jmp .L1499_2
.L1499_1:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    call zyl_rt_cond_broadcast
.L1499_2:
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
.L1500_0:
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
.L1501_0:
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    call zyl_rt_mutex_lock
    mov rdi, 1
    mov rsi, 0
    call zy_local_x2Fmain_0__chan__ch_x2Dclose_x2Downed
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    add rdi, 8
    jo zyl_rt_trap_ovf_0
    call zyl_rt_cond_broadcast
    lea rax, [rip+zyl_rtg_chan_sched]
    mov rdi, rax
    pop rbp
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__actor__ac_x2Dmax:
    # frame 0
.L1502_0:
    mov rax, 1024
    ret
zy_local_x2Fmain_0__actor__ac_x2Dsys:
    # frame 0
.L1503_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__actor__ac_x2Dslot:
    # frame 0
.L1504_0:
    lea rax, [rip+zyl_rtg_actor_slots]
    mov rsi, rax
    imul rdi, rdi, 32
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
zy_local_x2Fmain_0__actor__ac_x2Dinited:
    # frame 0
.L1505_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+8]
    cmp rax, 0
    jne .L1505_1
    mov rax, 0
    ret
.L1505_1:
    mov rax, 1
    ret
zy_local_x2Fmain_0__actor__ac_x2Dnext:
    # frame 0
.L1506_0:
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
.L1507_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    je .L1507_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1507_1:
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
.L1508_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rdi, 1
    mov qword ptr [rsi+16], rdi
    mov rax, 0
    ret
zy_local_x2Fmain_0__actor__ac_x2Dptr_x2Dp:
    # frame 0
.L1509_0:
    cmp rdi, 0
    jge .L1509_1
.L1509_2:
    mov rax, 1
    ret
.L1509_1:
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
.L1510_0:
    call zyl_actor_init
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dptr_x2Dp
    cmp rax, 0
    je .L1510_1
    mov rax, qword ptr [rbx+0]
    cmp rax, 2051230803
    jne .L1510_1
    mov rdi, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+16]
    mov r8, qword ptr [rbx+16]
    mov rdx, r8
    pop r12
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__actor__ac_x2Dspawn
.L1510_1:
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
.L1511_0:
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
.L1512_0:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rdi, 1
    mov rdx, rsi
    mov rcx, rdi
    mov rax, rcx
    lock xadd qword ptr [rdx], rax
    mov r14, rax
    cmp r14, 1024
    jl .L1512_1
    lea rax, [rip+.L1513]
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
.L1512_1:
    mov rdi, r14
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov r15, rax
    mov qword ptr [r15+0], rbx
    mov qword ptr [r15+8], r12
    mov rsi, 0
    mov qword ptr [r15+24], rsi
    mov rdi, r14
    add rdi, 2
    jo zyl_rt_trap_ovf_0
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
    jne .L1512_2
    mov rdi, r14
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    mov r8, 0
    mov rsi, r8
    call zyl_chan_actor_done
    lea rax, [rip+.L1514]
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
.L1512_2:
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
.L1515_0:
    call zyl_owner_self
    mov rdi, rax
    sub rdi, 2
    jo zyl_rt_trap_ovf_1
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
.L1516_0:
    mov rsi, 4294967295
    mov rbx, rdi
    and rbx, rsi
    mov rsi, rbx
    add rsi, 2
    jo zyl_rt_trap_ovf_0
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
    jne .L1516_1
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov qword ptr [rsi+0], r13
    mov rdi, r12
    call zyl_rt_free
    mov rdi, rbx
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    mov rsi, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zyl_chan_actor_done
.L1516_1:
    mov rsi, qword ptr [r12+72]
    cmp rsi, 0
    jne .L1516_2
    lea rax, [rip+.L1517]
    mov rdi, rax
    jmp .L1516_3
.L1516_2:
    mov rdi, rsi
.L1516_3:
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov r13, rax
    mov rdi, r12
    call zyl_rt_free
    mov rdi, rbx
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    cmp r13, 0
    jne .L1516_4
    lea rax, [rip+.L1518]
    mov rsi, rax
    jmp .L1516_5
.L1516_4:
    mov rsi, r13
.L1516_5:
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
.L1519_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    je .L1519_1
    cmp rbx, 0
    jl .L1519_2
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 1024
    jle .L1519_3
    mov rsi, 1024
    jmp .L1519_4
.L1519_3:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rdi, rax
    mov rsi, qword ptr [rdi+0]
.L1519_4:
    mov rax, rbx
    mov rcx, rsi
    cmp rax, rcx
    setl al
    movzx rax, al
    pop rbx
    pop rbp
    ret
.L1519_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1519_1:
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
.L1520_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dvalid
    cmp rax, 0
    jne .L1520_1
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1520_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov r12, rax
    mov rax, qword ptr [r12+24]
    cmp rax, 0
    je .L1520_2
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1520_2:
    mov rdi, rbx
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    call zyl_chan_actor_join
    mov r13, rax
    mov rdi, qword ptr [r12+16]
    call zyl_rt_thread_join
    mov rsi, 1
    mov qword ptr [r12+24], rsi
    mov rdi, rbx
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    call zyl_out_actor_emit
    cmp r13, 0
    jne .L1520_3
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1520_3:
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
.L1521_0:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dvalid
    cmp rax, 0
    jne .L1521_1
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1521_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__actor__ac_x2Dslot
    mov rsi, rax
    mov rax, qword ptr [rsi+24]
    cmp rax, 0
    jne .L1521_2
    mov rax, 1
    pop rbx
    pop rbp
    ret
.L1521_2:
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
.L1522_0:
    cmp rbx, r12
    jl .L1522_1
.L1522_4:
    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1522_1:
    lea rax, [rip+zyl_rtg_actor_slots]
    mov r14, rax
    imul rsi, rbx, 32
    jo zyl_rt_trap_ovf_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [r14+24]
    cmp rax, 0
    je .L1522_2
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    cmp rbx, r12
    jl .L1522_1
    jmp .L1522_4
.L1522_2:
    mov rdi, rbx
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    call zyl_chan_actor_join
    mov r15, rax
    mov rdi, qword ptr [r14+16]
    call zyl_rt_thread_join
    mov rsi, 1
    mov qword ptr [r14+24], rsi
    mov rdi, rbx
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    call zyl_out_actor_emit
    mov rsi, rbx
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    cmp r13, 0
    je .L1522_3
    mov r15, r13
.L1522_3:
    mov r13, r15
    mov rbx, rsi
    cmp rbx, r12
    jl .L1522_1
    jmp .L1522_4
.globl zyl_actor_join_unjoined
zyl_actor_join_unjoined:
    # frame 0
    push rbp
    mov rbp, rsp
.L1523_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    jne .L1523_1
    mov rax, 0
    pop rbp
    ret
.L1523_1:
    mov rdi, 0
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 1024
    jle .L1523_2
    mov rsi, 1024
    jmp .L1523_3
.L1523_2:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov r8, rax
    mov rsi, qword ptr [r8+0]
.L1523_3:
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__actor__ac_x2Djoin_x2Drest
    mov rdi, rax
    cmp rdi, 0
    jne .L1523_4
    mov rax, 0
    pop rbp
    ret
.L1523_4:
    pop rbp
    jmp zyl_panic
.globl zyl_actor_wait_all
zyl_actor_wait_all:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1524_0:
    call zy_local_x2Fmain_0__actor__ac_x2Dinited
    cmp rax, 0
    je .L1524_2
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+16]
    cmp rax, 0
    je .L1524_1
.L1524_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1524_1:
    call zyl_chan_main_done
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 1024
    jle .L1524_3
    mov rsi, 1024
    jmp .L1524_4
.L1524_3:
    lea rax, [rip+zyl_rtg_actor_sys]
    mov rdi, rax
    mov rsi, qword ptr [rdi+0]
.L1524_4:
    mov rdi, 0
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__actor__ac_x2Djoin_x2Drest
    mov rbx, rax
    cmp rbx, 0
    jne .L1524_5
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1524_5:
    call zyl_out_flush
    lea rax, [rip+.L1525]
    mov rdi, rax
    call zyl_err_puts
    mov rdi, rbx
    call zyl_err_puts
    lea rax, [rip+.L1526]
    mov rdi, rax
    call zyl_err_puts
    mov rdi, 1
    pop rbx
    pop rbp
    jmp zyl_chan_exit
zy_local_x2Fmain_0__actor__bs_x2Dsize:
    # frame 0
.L1527_0:
    cmp rdi, 0
    jne .L1527_1
.L1527_4:
    mov rax, 68719476736
    ret
.L1527_1:
    cmp rdi, 1
    jne .L1527_2
    mov rax, 17179869184
    ret
.L1527_2:
    cmp rdi, 2
    jne .L1527_3
    mov rax, 4294967296
    ret
.L1527_3:
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
.L1528_0:
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
.L1529_0:
    mov rdi, 24
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rsi, rax
    cmp rsi, 0
    jne .L1529_1
    mov rdi, rbx
    pop rbx
    pop rbp
    jmp zyl_rt_call0
.L1529_1:
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
.L1530_0:
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
.L1531_0:
    cmp r13, 4
    jl .L1531_1
.L1531_7:
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
.L1531_1:
    mov rsi, 68719476736
    cmp r13, 0
    je .L1531_2
    mov rdi, 17179869184
    cmp r13, 1
    je .L1531_3
    mov r8, 4294967296
    cmp r13, 2
    je .L1531_4
    mov r8, 1073741824
.L1531_4:
    mov rdi, r8
.L1531_3:
    mov rsi, rdi
.L1531_2:
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
    jge .L1531_5
    cmp r15, -4096
    jle .L1531_5
    add r13, 1
    jo zyl_rt_trap_ovf_0
    cmp r13, 4
    jl .L1531_1
    jmp .L1531_7
.L1531_5:
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
    jne .L1531_6
    mov rdi, r15
    mov rsi, r14
    call zyl_rt_sys_11
    add r13, 1
    jo zyl_rt_trap_ovf_0
    cmp r13, 4
    jl .L1531_1
    jmp .L1531_7
.L1531_6:
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
.L1532_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_worker@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Don_x2Dworker_x2Dcell:
    # frame 0
.L1533_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_on_worker@tpoff]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dany_x2Dabandoned:
    # frame 0
.L1534_0:
    lea rax, [rip+zyl_rtg_ffi_any_abandoned]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_ffi_abandoned
zyl_ffi_abandoned:
    # frame 0
.L1535_0:
    lea rax, [rip+zyl_rtg_ffi_any_abandoned]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_ffi_on_worker
zyl_ffi_on_worker:
    # frame 0
.L1536_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_on_worker@tpoff]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dlock:
    # frame 0
.L1537_0:
    mov rdi, qword ptr [rdi+0]
    jmp zyl_rt_mutex_lock
zy_local_x2Fmain_0__ffitimed__ff_x2Dunlock:
    # frame 0
.L1538_0:
    mov rdi, qword ptr [rdi+0]
    jmp zyl_rt_mutex_unlock
zy_local_x2Fmain_0__ffitimed__ff_x2Dcond:
    # frame 0
.L1539_0:
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
    jne .L1540
    sub rsp, 8
    sub rsp, 8
    mov rdi, [rbp-8]
    mov r12, rsp
    and rsp, -16
call zyl_rt_call0
    mov rsp, r12
    add rsp, 16
    jmp .L1541
.L1540:
    mov rax, [rbp-16]
    mov rcx, 1
    cmp rax, rcx
    jne .L1542
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
    jmp .L1543
.L1542:
    mov rax, [rbp-16]
    mov rcx, 2
    cmp rax, rcx
    jne .L1544
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
    jo zyl_rt_trap_ovf_0
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
    jmp .L1545
.L1544:
    mov rax, [rbp-16]
    mov rcx, 3
    cmp rax, rcx
    jne .L1546
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
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1547
.L1546:
    mov rax, [rbp-16]
    mov rcx, 4
    cmp rax, rcx
    jne .L1548
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
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1549
.L1548:
    mov rax, [rbp-16]
    mov rcx, 5
    cmp rax, rcx
    jne .L1550
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
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1551
.L1550:
    mov rax, [rbp-16]
    mov rcx, 6
    cmp rax, rcx
    jne .L1552
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
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1553
.L1552:
    mov rax, [rbp-16]
    mov rcx, 7
    cmp rax, rcx
    jne .L1554
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
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1555
.L1554:
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
.L1555:
.L1553:
.L1551:
.L1549:
.L1547:
.L1545:
.L1543:
.L1541:
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
.L1556_0:
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
.L1557_0:
    mov rax, qword ptr [rbx+16]
    cmp rax, 1
    je .L1557_1
    mov rdi, qword ptr [rbx+8]
    mov rsi, qword ptr [rbx+0]
    call zyl_rt_cond_wait
    jmp .L1557_0
.L1557_1:
    mov r12, qword ptr [rbx+40]
    mov r13, qword ptr [rbx+48]
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_args@tpoff]
    mov r14, rax
    mov rsi, rbx
    add rsi, 56
    jo zyl_rt_trap_ovf_0
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
    jne .L1557_2
    jmp .L1557_3
.L1557_2:
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
.L1557_3:
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
    je .L1557_4
    mov rdi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dfinish
.L1557_4:
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
    jmp .L1557_0
zy_local_x2Fmain_0__ffitimed__ff_x2Dfinish:
    # frame 32
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov rbx, rdi
.L1558_0:
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
.L1559_0:
    lea rax, [rip+.L1560]
    mov rdi, rax
    call zyl_panic
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dget:
    # frame 0
.L1561_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_worker@tpoff]
    mov rdi, rax
    mov rsi, qword ptr [rdi+0]
    cmp rsi, 0
    jne .L1561_1
    jmp zy_local_x2Fmain_0__ffitimed__ff_x2Dworker_x2Dnew
.L1561_1:
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
.L1562_0:
    mov rdi, 1
    mov rsi, 192
    call zyl_rt_calloc
    mov r12, rax
    cmp r12, 0
    jne .L1562_1
    lea rax, [rip+.L1563]
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
.L1562_1:
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
    je .L1562_3
    cmp r14, 0
    je .L1562_3
    cmp r15, 0
    je .L1562_4
    cmp qword ptr [rbp-48], 0
    jne .L1562_2
.L1562_4:
.L1562_3:
    lea rax, [rip+.L1564]
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
.L1562_2:
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
.L1565_0:
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
    jne .L1565_1
    lea rax, [rip+.L1566]
    mov rdi, rax
    call zyl_panic
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L1565_1:
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
.L1567_0:
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_2
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    cmp rdi, 1000000000
    jl .L1567_1
    mov r8, rsi
    add r8, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r12+0], r8
    mov r8, rdi
    sub r8, 1000000000
    jo zyl_rt_trap_ovf_1
    mov qword ptr [r12+8], r8
    mov rax, r12
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1567_1:
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
.L1568_0:
    cmp r9, r8
    jl .L1568_1
.L1568_2:
    mov rax, 0
    ret
.p2align 4
.L1568_1:
    imul r10, r9, 8
    jo zyl_rt_trap_ovf_2
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    imul r11, r9, 8
    jo zyl_rt_trap_ovf_2
    add r11, rsi
    jo zyl_rt_trap_ovf_0
    mov r11, qword ptr [r11+0]
    mov qword ptr [r10+0], r11
    add r9, 1
    jo zyl_rt_trap_ovf_0
    cmp r9, r8
    jl .L1568_1
    jmp .L1568_2
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
.L1569_0:
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
.L1570_0:
    mov rax, QWORD PTR [rip+fflush@GOTPCREL]
    mov rdi, rax
    cmp rdi, 0
    jle .L1570_1
    mov rsi, 0
    call zyl_rt_call1
    mov rsp, rbp
    pop rbp
    ret
.L1570_1:
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
.L1571_0:
    cmp rsi, 0
    jne .L1571_1
.L1571_7:
    lea rax, [rip+.L1572]
    mov r8, rax
    jmp .L1571_2
.L1571_1:
    mov r8, rsi
.L1571_2:
    mov r14, r8
    cmp rbx, 4096
    jge .L1571_3
    lea rax, [rip+.L1573]
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
.L1571_3:
    cmp r12, 0
    jl .L1571_5
    cmp r12, 16
    jle .L1571_4
.L1571_5:
    lea rax, [rip+.L1574]
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
.L1571_4:
    mov rsi, 1
    cmp rdi, 1
    jl .L1571_6
    mov rsi, rdi
.L1571_6:
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
.L1575_0:
    mov rdx, qword ptr [rbp-48]
    mov rax, qword ptr [rdx+16]
    cmp rax, 2
    jne .L1575_1
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
    jne .L1575_2
    jmp .L1575_3
.L1575_2:
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
.L1575_3:
    mov rax, r15
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1575_1:
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
    jne .L1575_4
    mov rdx, qword ptr [rbp-48]
    mov rax, qword ptr [rdx+16]
    cmp rax, 2
    je .L1575_4
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
    jne .L1575_5
    jmp .L1575_6
.L1575_5:
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
.L1575_6:
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
    lea rax, [rip+.L1576]
    mov r15, rax
    lea rax, [rip+.L1577]
    mov rbx, rax
    mov rdi, r14
    call zyl_int_text
    mov rdi, rax
    lea rax, [rip+.L1578]
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
.L1575_4:
    jmp .L1575_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
    jo zyl_rt_trap_ovf_0
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
.L1579_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_ffi_in@tpoff]
    mov r15, rax
    mov rsi, 16
    cmp r14, 16
    jg .L1579_1
    mov rsi, r14
.L1579_1:
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
    jne .L1580
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1581
.L1580:
    mov rax, [rbp-16]
    mov rcx, 9
    cmp rax, rcx
    jne .L1582
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1583
.L1582:
    mov rax, [rbp-16]
    mov rcx, 10
    cmp rax, rcx
    jne .L1584
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1585
.L1584:
    mov rax, [rbp-16]
    mov rcx, 11
    cmp rax, rcx
    jne .L1586
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1587
.L1586:
    mov rax, [rbp-16]
    mov rcx, 12
    cmp rax, rcx
    jne .L1588
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1589
.L1588:
    mov rax, [rbp-16]
    mov rcx, 13
    cmp rax, rcx
    jne .L1590
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 96
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1591
.L1590:
    mov rax, [rbp-16]
    mov rcx, 14
    cmp rax, rcx
    jne .L1592
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 96
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 104
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1593
.L1592:
    mov rax, [rbp-16]
    mov rcx, 15
    cmp rax, rcx
    jne .L1594
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 96
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 104
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 112
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
    jmp .L1595
.L1594:
    mov rax, [rbp-8]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 0
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 8
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 16
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 24
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 32
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 40
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 48
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 56
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 64
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 72
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 80
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 88
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 96
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 104
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 112
    add rax, rcx
    jo zyl_rt_trap_ovf_0
    mov rdx, rax
    mov rax, qword ptr [rdx]
    sub rsp, 8
    mov [rsp], rax
    mov rax, [rbp-24]
    mov rcx, 120
    add rax, rcx
    jo zyl_rt_trap_ovf_0
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
.L1595:
.L1593:
.L1591:
.L1589:
.L1587:
.L1585:
.L1583:
.L1581:
    mov rbx, [rbp-120]
    mov r12, [rbp-112]
    mov rsp, rbp
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Derr:
    # frame 0
.L1596_0:
    jmp zyl_err_puts
zy_local_x2Fmain_0__panic__pn_x2Dout:
    # frame 0
.L1597_0:
    jmp zyl_out_puts
zy_local_x2Fmain_0__panic__pn_x2Ds:
    # frame 0
.L1598_0:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtop:
    # frame 0
.L1599_0:
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
.L1600_0:
    mov rdi, 88
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rbx, rax
    cmp rbx, 0
    jne .L1600_1
    mov rdi, 88
    lea rax, [rip+.L1601]
    mov rsi, rax
    call zyl_arena_oom
    jmp .L1600_2
.L1600_1:
.L1600_2:
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
.L1602_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    cmp rdi, 0
    jne .L1602_1
    mov rax, 0
    pop rbp
    ret
.L1602_1:
    mov r8, qword ptr [rdi+64]
    mov qword ptr [rsi+0], r8
    call zyl_rt_free
    mov rax, 0
    pop rbp
    ret
.globl zyl_try_last_msg
zyl_try_last_msg:
    # frame 0
.L1603_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L1603_1
    mov rax, 0
    ret
.L1603_1:
    mov rax, qword ptr [rsi+72]
    ret
.globl zyl_try_frame_msg
zyl_try_frame_msg:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1604_0:
    cmp rdi, 0
    jne .L1604_1
.L1604_2:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1604_1:
    mov rbx, qword ptr [rdi+72]
    call zyl_rt_free
    mov rax, rbx
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtstate:
    # frame 0
.L1605_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtests:
    # frame 0
.L1606_0:
    lea rax, [rip+zyl_rtg_tests]
    mov rsi, rax
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtbuf:
    # frame 0
.L1607_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov rsi, rax
    add rsi, 24
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dtmsg:
    # frame 0
.L1608_0:
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
.L1609_0:
    lea rax, [rip+zyl_rtg_test_msg]
    mov rsi, rax
    mov rbx, qword ptr [rsi+0]
    cmp rbx, 0
    jne .L1609_1
    lea rax, [rip+.L1610]
    mov rsi, rax
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1609_1:
    lea rax, [rip+zyl_rtg_test_msg]
    mov rsi, rax
    mov rdi, 0
    mov qword ptr [rsi+0], rdi
    lea rax, [rip+.L1611]
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
    lea rax, [rip+.L1612]
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
.L1613_0:
    mov r8, rdi
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    movzx r8d, byte ptr [r8+0]
    cmp r8, 0
    je .L1613_2
    cmp r8, 10
    jne .L1613_1
.L1613_2:
    mov rax, rsi
    ret
.L1613_1:
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1613_0
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
.L1614_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov qword ptr [rbp-48], rax
    mov rdx, qword ptr [rbp-48]
    mov r13, qword ptr [rdx+0]
    cmp r13, 256
    jl .L1614_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1614_1:
    lea rax, [rip+zyl_rtg_tests]
    mov r14, rax
    imul rsi, r13, 136
    jo zyl_rt_trap_ovf_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    mov r15, rdi
    mov rdi, r15
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov rsi, rax
    mov rdi, 127
    cmp rsi, 127
    jg .L1614_2
    mov rdi, rsi
.L1614_2:
    mov r12, rdi
    mov rdi, r14
    mov rsi, r15
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r14
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov qword ptr [r14+128], rbx
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L1615_0:
    mov rsi, 0
    jmp zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
.globl zyl_run_tests
zyl_run_tests:
    # frame 0
.L1616_0:
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
.L1617_0:
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
.L1618_0:
    movzx eax, byte ptr [r12+0]
    cmp rax, 0
    jne .L1618_1
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
.L1618_1:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 0
    jne .L1618_2
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L1618_2:
    mov rdi, rbx
    mov rsi, r12
    call zy_local_x2Fmain_0__panic__pn_x2Dprefix
    cmp rax, 0
    je .L1618_3
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
.L1618_3:
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1618_0
zy_local_x2Fmain_0__panic__pn_x2Dprefix:
    # frame 0
.L1619_0:
    movzx eax, byte ptr [rsi+0]
    cmp rax, 0
    jne .L1619_1
    mov rax, 1
    ret
.L1619_1:
    movzx r8d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r8, rax
    jne .L1619_2
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1619_0
.L1619_2:
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
.L1620_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov qword ptr [rbp-80], rax
    mov rdx, qword ptr [rbp-80]
    mov rax, qword ptr [rdx+0]
    cmp qword ptr [rbp-48], rax
    jl .L1620_1
    lea rax, [rip+.L1621]
    mov rbx, rax
    mov rsi, 0
    mov rdi, qword ptr [rbp-56]
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r12, rax
    lea rax, [rip+.L1622]
    mov r13, rax
    mov rsi, 0
    mov rdi, qword ptr [rbp-64]
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov r14, rax
    lea rax, [rip+.L1623]
    mov r15, rax
    mov rdi, qword ptr [rbp-56]
    add rdi, qword ptr [rbp-64]
    jo zyl_rt_trap_ovf_0
    mov rsi, 0
    call zy_local_x2Fmain_0__text__rt_x2Dint_x2Dtext
    mov rdi, rax
    lea rax, [rip+.L1624]
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
    jle .L1620_2
    mov rax, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1620_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1620_1:
    lea rax, [rip+zyl_rtg_tests]
    mov rbx, rax
    imul rsi, qword ptr [rbp-48], 136
    jo zyl_rt_trap_ovf_2
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    cmp qword ptr [rbp-72], 0
    je .L1620_3
    mov rdi, rbx
    mov rsi, qword ptr [rbp-72]
    call zy_local_x2Fmain_0__panic__pn_x2Dcontains
    cmp rax, 0
    jne .L1620_3
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    jmp .L1620_0
.L1620_3:
    lea rax, [rip+.L1625]
    mov r12, rax
    lea rax, [rip+.L1626]
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
    jo zyl_rt_trap_ovf_0
    mov rsi, qword ptr [rbx+128]
    call zyl_rt_try_call
    cmp rax, 0
    jne .L1620_4
    mov rsi, 0
    mov rdx, qword ptr [rbp-80]
    mov qword ptr [rdx+8], rsi
    lea rax, [rip+zyl_rtg_test_state]
    mov rsi, rax
    add rsi, 24
    jo zyl_rt_trap_ovf_0
    mov rsi, qword ptr [rsi+64]
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 0
    jne .L1620_5
    lea rax, [rip+.L1627]
    mov rdi, rax
    call zyl_out_puts
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-56]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-56], rax
    jmp .L1620_0
.L1620_5:
    call zy_local_x2Fmain_0__panic__pn_x2Dfail_x2Dline
    mov rdi, rax
    call zyl_out_puts
    call zyl_out_flush
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-64]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-64], rax
    jmp .L1620_0
.L1620_4:
    call zy_local_x2Fmain_0__panic__pn_x2Dfail_x2Dline
    mov rdi, rax
    call zyl_out_puts
    call zyl_out_flush
    mov rax, qword ptr [rbp-48]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-48], rax
    mov rax, qword ptr [rbp-64]
    add rax, 1
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rbp-64], rax
    jmp .L1620_0
zy_local_x2Fmain_0__panic__pn_x2Dfail:
    # frame 0
    push rbp
    mov rbp, rsp
.L1628_0:
    call zy_local_x2Fmain_0__panic__pn_x2Dfail_x2Dline
    mov rdi, rax
    call zyl_out_puts
    pop rbp
    jmp zyl_out_flush
.globl zyl_panic
zyl_panic:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1629_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_try_top@tpoff]
    mov rsi, rax
    mov rbx, qword ptr [rsi+0]
    cmp rbx, 0
    jne .L1629_1
    pop rbx
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Dtest
.L1629_1:
    mov r8, qword ptr [rbx+64]
    mov qword ptr [rsi+0], r8
    cmp rdi, 0
    jne .L1629_2
    lea rax, [rip+.L1630]
    mov rsi, rax
    jmp .L1629_3
.L1629_2:
    mov rsi, rdi
.L1629_3:
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
.L1631_0:
    lea rax, [rip+zyl_rtg_test_state]
    mov r12, rax
    mov rax, qword ptr [r12+8]
    cmp rax, 0
    je .L1631_1
    call zyl_ffi_on_worker
    mov rsi, rax
    mov rdi, 4294967295
    and rsi, rdi
    cmp rsi, 0
    jne .L1631_1
    mov rsi, 0
    mov qword ptr [r12+8], rsi
    lea rax, [rip+zyl_rtg_test_msg]
    mov r13, rax
    mov rsi, 0
    cmp rbx, 0
    je .L1631_2
    mov rdi, rbx
    call zy_local_x2Fmain_0__heap__rt_x2Dstrdup
    mov rsi, rax
.L1631_2:
    mov qword ptr [r13+0], rsi
    mov rdi, qword ptr [r12+16]
    call zyl_region_unwind
    lea rax, [rip+zyl_rtg_test_state]
    mov rdi, rax
    add rdi, 24
    jo zyl_rt_trap_ovf_0
    mov rsi, 1
    call zyl_rt_longjmp
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1631_1:
    call zyl_actor_abandon
    cmp rbx, 0
    jne .L1631_3
    lea rax, [rip+.L1632]
    mov rsi, rax
    jmp .L1631_4
.L1631_3:
    mov rsi, rbx
.L1631_4:
    mov rbx, rsi
    call zyl_out_flush
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1631_5
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Dtext
    jmp .L1631_6
.L1631_5:
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dpanic_x2Djson
.L1631_6:
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
.L1633_0:
    lea rax, [rip+.L1634]
    mov r12, rax
    lea rax, [rip+.L1635]
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_err_puts
    lea rax, [rip+.L1636]
    mov rsi, rax
    mov rdi, 6
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp
    cmp rax, 0
    je .L1633_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1633_1:
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
.L1637_0:
    mov rax, QWORD PTR [rip+zyl_syms@GOTPCREL]
    mov rbx, rax
    cmp rbx, 0
    je .L1637_2
    lea rax, [rip+zyl_rtg_bt_off]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    je .L1637_1
.L1637_2:
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1637_1:
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
.L1638_0:
    cmp rbx, 0
    je .L1638_2
.L1638_8:
    cmp r13, 32
    jge .L1638_3
    cmp r14, 4096
    jge .L1638_4
    mov rdi, rbx
    and rdi, -4096
    mov rsi, rbx
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    sub rsi, rdi
    jo zyl_rt_trap_ovf_1
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
    jne .L1638_1
.L1638_4:
.L1638_3:
.L1638_2:
    mov rax, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1638_1:
    mov rsi, qword ptr [rbx+8]
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    mov rdi, r12
    call zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Dname
    mov rdi, rax
    mov rsi, r13
    cmp rdi, 0
    je .L1638_5
    lea rax, [rip+.L1639]
    mov r15, rax
    lea rax, [rip+.L1640]
    mov r8, rax
    mov rsi, r8
    call zyl_cstr_concat
    mov rdi, rax
    mov rsi, rdi
    mov rdi, r15
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_err_puts
    mov rsi, r13
    add rsi, 1
    jo zyl_rt_trap_ovf_0
.L1638_5:
    mov rdi, qword ptr [rbx+0]
    cmp rdi, rbx
    jle .L1638_7
    mov rax, rdi
    and rax, 7
    cmp rax, 0
    je .L1638_6
.L1638_7:
    mov rax, rsi
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov r14, qword ptr [rbp-32]
    mov r15, qword ptr [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
.L1638_6:
    mov rbx, rdi
    mov r13, rsi
    add r14, 1
    jo zyl_rt_trap_ovf_0
    cmp rbx, 0
    je .L1638_2
    jmp .L1638_8
zy_local_x2Fmain_0__panic__pn_x2Dmapped:
    # frame 0
    push rbp
    mov rbp, rsp
    and rsp, -16
.L1641_0:
    mov rsi, rdi
    and rsi, -4096
    add rdi, 16
    jo zyl_rt_trap_ovf_0
    sub rdi, rsi
    jo zyl_rt_trap_ovf_1
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
.L1642_0:
    mov r13, qword ptr [rbx+0]
    cmp r13, 0
    je .L1642_2
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Daddr
    cmp r12, rax
    jl .L1642_3
    mov rdi, rbx
    mov rsi, r13
    call zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Daddr
    cmp r12, rax
    jl .L1642_1
.L1642_3:
.L1642_2:
    mov rax, 0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1642_1:
    mov r14, rbx
    add r14, 12
    jo zyl_rt_trap_ovf_0
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    mov rcx, r13
    call zy_local_x2Fmain_0__panic__pn_x2Dsym_x2Dfind
    mov rsi, rax
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    mov esi, dword ptr [r14+0]
    mov rax, rbx
    add rax, rsi
    jo zyl_rt_trap_ovf_0
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
.L1643_0:
    mov rbx, rdi
    add rbx, 8
    jo zyl_rt_trap_ovf_0
    imul rsi, rsi, 8
    jo zyl_rt_trap_ovf_2
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    mov edi, dword ptr [rbx+0]
    call zy_local_x2Fmain_0__panic__pn_x2Ds32
    mov rsi, rax
    mov rax, rbx
    add rax, rsi
    jo zyl_rt_trap_ovf_0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Ds32:
    # frame 0
.L1644_0:
    mov rax, 2147483648
    cmp rdi, rax
    jl .L1644_1
    mov rsi, 4294967296
    mov rax, rdi
    sub rax, rsi
    jo zyl_rt_trap_ovf_1
    ret
.L1644_1:
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
.L1645_0:
    mov rax, r14
    sub rax, r13
    jo zyl_rt_trap_ovf_1
    cmp rax, 1
    jg .L1645_1
    mov rax, r13
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1645_1:
    mov rsi, r13
    add rsi, r14
    jo zyl_rt_trap_ovf_0
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
    jg .L1645_2
    mov r13, r15
    jmp .L1645_0
.L1645_2:
    mov r14, r15
    jmp .L1645_0
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
.L1646_0:
    movzx eax, byte ptr [rbx+0]
    cmp rax, 123
    jne .L1646_1
    lea rax, [rip+.L1647]
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
.L1646_1:
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dlen
    mov r12, rax
    cmp r12, 0
    jle .L1646_2
    cmp r12, 128
    jge .L1646_2
    mov rsi, 0
    mov rdi, rbx
    mov rdx, rsi
    mov rsi, r12
    call zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
    mov r13, rax
    mov rsi, r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    mov rdi, rbx
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    call zy_local_x2Fmain_0__panic__pn_x2Dskip_x2Dsp
    mov rsi, rax
    mov rdi, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag
.L1646_2:
    lea rax, [rip+.L1648]
    mov rsi, rax
    mov rdi, 6
    mov rdx, rdi
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp
    cmp rax, 0
    je .L1646_3
    mov rdi, rbx
    add rdi, 6
    jo zyl_rt_trap_ovf_0
    call zy_local_x2Fmain_0__panic__pn_x2Dfind_x2Dclose
    mov r12, rax
    cmp r12, 0
    jle .L1646_4
    movzx eax, byte ptr [r12+1]
    cmp rax, 58
    jne .L1646_4
    mov rsi, r12
    sub rsi, rbx
    jo zyl_rt_trap_ovf_1
    sub rsi, 6
    jo zyl_rt_trap_ovf_1
    cmp rsi, 128
    jge .L1646_4
    mov rdi, rbx
    add rdi, 6
    jo zyl_rt_trap_ovf_0
    mov rsi, r12
    sub rsi, rbx
    jo zyl_rt_trap_ovf_1
    sub rsi, 6
    jo zyl_rt_trap_ovf_1
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dstr_x2Dof
    mov r13, rax
    mov rdi, r12
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    call zy_local_x2Fmain_0__panic__pn_x2Dskip_x2Dsp
    mov rsi, rax
    mov rdi, r13
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag
.L1646_4:
    lea rax, [rip+.L1649]
    mov rdi, rax
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov r13, qword ptr [rbp-24]
    mov rsp, rbp
    pop rbp
    jmp zy_local_x2Fmain_0__panic__pn_x2Djson_x2Ddiag
.L1646_3:
    lea rax, [rip+.L1650]
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
.L1651_0:
    lea rax, [rip+.L1652]
    mov r12, rax
    call zyl_json_quote
    mov r13, rax
    lea rax, [rip+.L1653]
    mov r14, rax
    mov rdi, rbx
    call zyl_json_quote
    mov rdi, rax
    lea rax, [rip+.L1654]
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
.L1655_0:
    movzx esi, byte ptr [rbx+0]
    cmp rsi, 69
    je .L1655_2
    cmp rsi, 87
    jne .L1655_1
.L1655_2:
    movzx eax, byte ptr [rbx+1]
    cmp rax, 95
    jne .L1655_1
    mov rsi, 2
    mov rdi, rbx
    call zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dscan
    mov rsi, rax
    mov rdi, rbx
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rdi+0]
    cmp rax, 58
    jne .L1655_3
    mov rax, rsi
    pop rbx
    pop rbp
    ret
.L1655_3:
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1655_1:
    mov rax, 0
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dcode_x2Dscan:
    # frame 0
.L1656_0:
    mov r8, rdi
    add r8, rsi
    jo zyl_rt_trap_ovf_0
    movzx r8d, byte ptr [r8+0]
    cmp r8, 65
    jl .L1656_3
    cmp r8, 90
    jle .L1656_2
.L1656_3:
    cmp r8, 48
    jl .L1656_5
    cmp r8, 57
    jle .L1656_4
.L1656_5:
    cmp r8, 95
    jne .L1656_1
.L1656_4:
.L1656_2:
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1656_0
.L1656_1:
    mov rax, rsi
    ret
zy_local_x2Fmain_0__panic__pn_x2Dskip_x2Dsp:
    # frame 0
.L1657_0:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 32
    jne .L1657_1
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1657_0
.L1657_1:
    mov rax, rdi
    ret
zy_local_x2Fmain_0__panic__pn_x2Derror_x2Dbracket_x2Dp:
    # frame 0
.L1658_0:
    lea rax, [rip+.L1659]
    mov rsi, rax
    mov r8, 6
    mov rdx, r8
    jmp zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp
zy_local_x2Fmain_0__panic__pn_x2Dprefix_x2Dp:
    # frame 0
    mov r8, rdx
.L1660_0:
    cmp r8, 0
    jne .L1660_1
.L1660_4:
    mov rax, 1
    ret
.p2align 4
.L1660_1:
    movzx r9d, byte ptr [rdi+0]
    movzx eax, byte ptr [rsi+0]
    cmp r9, rax
    je .L1660_2
    mov rax, 0
    ret
.L1660_2:
    cmp r9, 0
    jne .L1660_3
    mov rax, 1
    ret
.L1660_3:
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    sub r8, 1
    jo zyl_rt_trap_ovf_1
    cmp r8, 0
    jne .L1660_1
    jmp .L1660_4
zy_local_x2Fmain_0__panic__pn_x2Dfind_x2Dclose:
    # frame 0
.L1661_0:
    movzx esi, byte ptr [rdi+0]
    cmp rsi, 93
    jne .L1661_1
    mov rax, rdi
    ret
.L1661_1:
    cmp rsi, 0
    jne .L1661_2
    mov rax, 0
    ret
.L1661_2:
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1661_0
.globl zyl_f_error
zyl_f_error:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    and rsp, -16
.L1662_0:
    mov rbx, rdi
    call zyl_out_flush
    cmp rbx, 0
    jne .L1662_1
    lea rax, [rip+.L1663]
    mov rdi, rax
    call zyl_err_puts
    jmp .L1662_2
.L1662_1:
    lea rax, [rip+.L1664]
    mov r12, rax
    lea rax, [rip+.L1665]
    mov rsi, rax
    mov rdi, rbx
    call zyl_cstr_concat
    mov rsi, rax
    mov rdi, r12
    call zyl_cstr_concat
    mov rdi, rax
    call zyl_err_puts
.L1662_2:
    mov rdi, 1
    mov rbx, qword ptr [rbp-8]
    mov r12, qword ptr [rbp-16]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_exit
zy_local_x2Fmain_0__panic__pn_x2Ddiag:
    # frame 0
.L1666_0:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_diag_json
zyl_diag_json:
    # frame 0
.L1667_0:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_diag_json_set
zyl_diag_json_set:
    # frame 0
.L1668_0:
    lea rax, [rip+zyl_rtg_diag_json]
    mov rsi, rax
    mov r8, 0
    cmp rdi, 0
    je .L1668_1
    mov r8, 1
.L1668_1:
    mov qword ptr [rsi+0], r8
    mov rax, 0
    ret
zy_local_x2Fmain_0__panic__pn_x2Dbt_x2Doff:
    # frame 0
.L1669_0:
    lea rax, [rip+zyl_rtg_bt_off]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_backtrace_set
zyl_backtrace_set:
    # frame 0
.L1670_0:
    lea rax, [rip+zyl_rtg_bt_off]
    mov rsi, rax
    mov r8, 1
    cmp rdi, 0
    je .L1670_1
    mov r8, 0
.L1670_1:
    mov qword ptr [rsi+0], r8
    mov rax, 0
    ret
zy_local_x2Fmain_0__panic__pn_x2Dwarn:
    # frame 0
.L1671_0:
    lea rax, [rip+zyl_rtg_warn]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_warn_capture
zyl_warn_capture:
    # frame 0
.L1672_0:
    lea rax, [rip+zyl_rtg_warn]
    mov rsi, rax
    mov r8, 0
    cmp rdi, 0
    je .L1672_1
    mov r8, 1
.L1672_1:
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
.L1673_0:
    cmp rdi, 0
    jne .L1673_1
.L1673_5:
    lea rax, [rip+.L1674]
    mov rsi, rax
    jmp .L1673_2
.L1673_1:
    mov rsi, rdi
.L1673_2:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    lea rax, [rip+zyl_rtg_warn]
    mov r13, rax
    mov rax, qword ptr [r13+24]
    cmp rax, 0
    jne .L1673_3
    mov rdi, 2
    mov rsi, rbx
    mov rdx, r12
    call zyl_rt_sys_1
    mov rdi, 2
    lea rax, [rip+.L1675]
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
.L1673_3:
    mov r14, qword ptr [r13+8]
    mov rsi, r14
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    add rsi, 2
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    call zy_local_x2Fmain_0__panic__pn_x2Dwarn_x2Dfit
    cmp rax, 0
    je .L1673_4
    mov r15, qword ptr [r13+0]
    mov rdi, r15
    add rdi, r14
    jo zyl_rt_trap_ovf_0
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r14
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    add rsi, r15
    jo zyl_rt_trap_ovf_0
    mov rdi, 10
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, r14
    jo zyl_rt_trap_ovf_0
    add rsi, r15
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    mov rsi, r12
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, r14
    jo zyl_rt_trap_ovf_0
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
.L1673_4:
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
.L1676_0:
    mov rdi, qword ptr [rbx+16]
    cmp rsi, rdi
    jg .L1676_1
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
.L1676_1:
    mov r8, 1024
    cmp rdi, 0
    je .L1676_2
    mov r8, rdi
.L1676_2:
    mov rdi, r8
    call zy_local_x2Fmain_0__panic__pn_x2Ddouble
    mov r12, rax
    mov rdi, qword ptr [rbx+0]
    mov rsi, r12
    call zyl_rt_realloc
    mov rsi, rax
    cmp rsi, 0
    jne .L1676_3
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L1676_3:
    mov qword ptr [rbx+0], rsi
    mov qword ptr [rbx+16], r12
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Ddouble:
    # frame 0
.L1677_0:
    cmp rsi, rdi
    jle .L1677_1
.L1677_2:
    imul rdi, rdi, 2
    jo zyl_rt_trap_ovf_2
    cmp rsi, rdi
    jle .L1677_1
    jmp .L1677_2
.L1677_1:
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
.L1678_0:
    lea rax, [rip+zyl_rtg_warn]
    mov rbx, rax
    mov r12, qword ptr [rbx+8]
    mov rdi, r12
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L1678_1
    lea rax, [rip+.L1679]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1678_1:
    cmp r12, 0
    jle .L1678_2
    mov rsi, qword ptr [rbx+0]
    mov rdi, r13
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    jmp .L1678_3
.L1678_2:
.L1678_3:
    mov rsi, r13
    add rsi, r12
    jo zyl_rt_trap_ovf_0
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
.L1680_0:
    cmp rdi, 0
    jne .L1680_1
.L1680_4:
    lea rax, [rip+.L1681]
    mov rsi, rax
    jmp .L1680_2
.L1680_1:
    mov rsi, rdi
.L1680_2:
    mov rbx, rsi
    mov rdi, rbx
    call zy_local_x2Fmain_0__base__rt_x2Dstrlen
    mov r12, rax
    imul rdi, r12, 6
    jo zyl_rt_trap_ovf_2
    add rdi, 3
    jo zyl_rt_trap_ovf_0
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov r13, rax
    cmp r13, 0
    jne .L1680_3
    lea rax, [rip+.L1682]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1680_3:
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
    mov rdi, r13
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    mov r8, 34
    mov byte ptr [rdi+0], r8b
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, r13
    jo zyl_rt_trap_ovf_0
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
.L1683_0:
    cmp rsi, r12
    jl .L1683_1
.L1683_13:
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
.L1683_1:
    mov rdi, qword ptr [rbp-56]
    add rdi, rsi
    jo zyl_rt_trap_ovf_0
    movzx edi, byte ptr [rdi+0]
    mov r14, rsi
    add r14, 1
    jo zyl_rt_trap_ovf_0
    cmp rdi, 34
    je .L1683_4
    cmp rdi, 92
    jne .L1683_2
.L1683_4:
    mov r9, r13
    add r9, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov r10, 92
    mov byte ptr [r9+0], r10b
    mov r9, qword ptr [rbp-48]
    add r9, 1
    jo zyl_rt_trap_ovf_0
    add r9, r13
    jo zyl_rt_trap_ovf_0
    mov rcx, rdi
    mov byte ptr [r9+0], cl
    mov r9, qword ptr [rbp-48]
    add r9, 2
    jo zyl_rt_trap_ovf_0
    jmp .L1683_3
.L1683_2:
    cmp rdi, 10
    jne .L1683_5
    mov r10, 110
    mov r11, r13
    add r11, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov r15, 92
    mov byte ptr [r11+0], r15b
    mov r11, qword ptr [rbp-48]
    add r11, 1
    jo zyl_rt_trap_ovf_0
    add r11, r13
    jo zyl_rt_trap_ovf_0
    mov byte ptr [r11+0], r10b
    mov r10, qword ptr [rbp-48]
    add r10, 2
    jo zyl_rt_trap_ovf_0
    jmp .L1683_6
.L1683_5:
    cmp rdi, 9
    jne .L1683_7
    mov r11, 116
    mov r15, r13
    add r15, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov r8, 92
    mov byte ptr [r15+0], r8b
    mov r8, qword ptr [rbp-48]
    add r8, 1
    jo zyl_rt_trap_ovf_0
    add r8, r13
    jo zyl_rt_trap_ovf_0
    mov byte ptr [r8+0], r11b
    mov r8, qword ptr [rbp-48]
    add r8, 2
    jo zyl_rt_trap_ovf_0
    jmp .L1683_8
.L1683_7:
    cmp rdi, 13
    jne .L1683_9
    mov r11, 114
    mov r15, r13
    add r15, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov rbx, 92
    mov byte ptr [r15+0], bl
    mov rbx, qword ptr [rbp-48]
    add rbx, 1
    jo zyl_rt_trap_ovf_0
    add rbx, r13
    jo zyl_rt_trap_ovf_0
    mov byte ptr [rbx+0], r11b
    mov r11, qword ptr [rbp-48]
    add r11, 2
    jo zyl_rt_trap_ovf_0
    jmp .L1683_10
.L1683_9:
    cmp rdi, 32
    jge .L1683_11
    mov rsi, qword ptr [rbp-48]
    mov rdx, rdi
    mov rdi, r13
    call zy_local_x2Fmain_0__panic__pn_x2Desc_x2Du
    mov rbx, rax
    jmp .L1683_12
.L1683_11:
    mov r15, r13
    add r15, qword ptr [rbp-48]
    jo zyl_rt_trap_ovf_0
    mov rcx, rdi
    mov byte ptr [r15+0], cl
    mov rbx, qword ptr [rbp-48]
    add rbx, 1
    jo zyl_rt_trap_ovf_0
.L1683_12:
    mov r11, rbx
.L1683_10:
    mov r8, r11
.L1683_8:
    mov r10, r8
.L1683_6:
    mov r9, r10
.L1683_3:
    mov qword ptr [rbp-48], r9
    mov rsi, r14
    cmp rsi, r12
    jl .L1683_1
    jmp .L1683_13
zy_local_x2Fmain_0__panic__pn_x2Desc:
    # frame 0
    mov r8, rdx
.L1684_0:
    mov r9, rdi
    add r9, rsi
    jo zyl_rt_trap_ovf_0
    mov r10, 92
    mov byte ptr [r9+0], r10b
    mov r9, rsi
    add r9, 1
    jo zyl_rt_trap_ovf_0
    add rdi, r9
    jo zyl_rt_trap_ovf_0
    mov byte ptr [rdi+0], r8b
    mov rax, rsi
    add rax, 2
    jo zyl_rt_trap_ovf_0
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
.L1685_0:
    mov rdi, rbx
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    lea rax, [rip+.L1686]
    mov rsi, rax
    mov r8, 4
    mov rdx, r8
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r12
    add rsi, 4
    jo zyl_rt_trap_ovf_0
    mov r14, rbx
    add r14, rsi
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    shr rdi, 4
    call zy_local_x2Fmain_0__panic__pn_x2Dhexd
    mov rsi, rax
    mov rcx, rsi
    mov byte ptr [r14+0], cl
    mov rsi, r12
    add rsi, 5
    jo zyl_rt_trap_ovf_0
    add rbx, rsi
    jo zyl_rt_trap_ovf_0
    mov rdi, r13
    and rdi, 15
    call zy_local_x2Fmain_0__panic__pn_x2Dhexd
    mov rsi, rax
    mov rcx, rsi
    mov byte ptr [rbx+0], cl
    mov rax, r12
    add rax, 6
    jo zyl_rt_trap_ovf_0
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__panic__pn_x2Dhexd:
    # frame 0
.L1687_0:
    cmp rdi, 10
    jge .L1687_1
.L1687_2:
    mov rax, rdi
    add rax, 48
    jo zyl_rt_trap_ovf_0
    ret
.L1687_1:
    mov rax, rdi
    add rax, 87
    jo zyl_rt_trap_ovf_0
    ret
zy_local_x2Fmain_0__io__io_x2Dput:
    # frame 0
.L1688_0:
    jmp zyl_out_puts
zy_local_x2Fmain_0__io__io_x2Dputs_x2Dor_x2Dnull:
    # frame 0
.L1689_0:
    cmp rdi, 0
    jne .L1689_1
.L1689_2:
    lea rax, [rip+.L1690]
    mov rsi, rax
    mov rdi, rsi
    jmp zyl_out_puts
.L1689_1:
    jmp zyl_out_puts
zy_local_x2Fmain_0__io__io_x2Dput_x2Dint:
    # frame 0
.L1691_0:
    jmp zyl_out_int
.globl zyl_itest_start
zyl_itest_start:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rdi
.L1692_0:
    lea rax, [rip+.L1693]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, rbx
    call zy_local_x2Fmain_0__io__io_x2Dputs_x2Dor_x2Dnull
    lea rax, [rip+.L1694]
    mov rdi, rax
    call zyl_out_puts
    pop rbx
    pop rbp
    jmp zyl_out_flush
.globl zyl_itest_outcome
zyl_itest_outcome:
    # frame 0
.L1695_0:
    cmp rdi, 0
    jne .L1695_1
.L1695_3:
    lea rax, [rip+.L1696]
    mov rsi, rax
    jmp .L1695_2
.L1695_1:
    lea rax, [rip+.L1697]
    mov rsi, rax
.L1695_2:
    mov rdi, rsi
    jmp zyl_out_puts
.globl zyl_itest_fail
zyl_itest_fail:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
.L1698_0:
    mov rbx, rdi
    lea rax, [rip+.L1699]
    mov rdi, rax
    call zyl_out_puts
    mov rsi, 0
    mov rdi, rbx
    call zy_local_x2Fmain_0__io__io_x2Dline
    lea rax, [rip+.L1700]
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
.L1701_0:
    mov rsi, rbx
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    movzx esi, byte ptr [rsi+0]
    cmp rsi, 0
    je .L1701_2
    cmp rsi, 10
    jne .L1701_1
.L1701_2:
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L1701_1:
    mov rdi, rbx
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov rsi, 1
    call zyl_out_write
    add r12, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1701_0
.globl zyl_itest_summary
zyl_itest_summary:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1702_0:
    lea rax, [rip+.L1703]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, rbx
    call zyl_out_int
    lea rax, [rip+.L1704]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, r12
    call zyl_out_int
    lea rax, [rip+.L1705]
    mov rdi, rax
    call zyl_out_puts
    mov rdi, rbx
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    call zyl_out_int
    lea rax, [rip+.L1706]
    mov rdi, rax
    call zyl_out_puts
    cmp r12, 0
    jle .L1702_1
    mov rax, 1
    pop r12
    pop rbx
    pop rbp
    ret
.L1702_1:
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
.L1707_0:
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
.L1708_0:
    call zyl_out_flush
    mov rdi, 128
    mov rsi, 1
    call zy_local_x2Fmain_0__heap__hp_x2Dalloc
    mov rdi, rax
    cmp rdi, 0
    jne .L1708_1
    lea rax, [rip+.L1709]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1708_1:
    mov rsi, 128
    mov r8, 0
    mov rdx, r8
    call zy_local_x2Fmain_0__io__io_x2Dread_x2Dloop
    mov rsi, rax
    mov rbx, qword ptr [rsi+0]
    mov rsi, qword ptr [rsi+8]
    cmp rsi, 0
    jle .L1708_2
    mov rdi, rsi
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    movzx eax, byte ptr [rdi+0]
    cmp rax, 13
    jne .L1708_2
    mov rdi, rsi
    sub rdi, 1
    jo zyl_rt_trap_ovf_1
    jmp .L1708_3
.L1708_2:
    mov rdi, rsi
.L1708_3:
    mov r12, rdi
    mov rdi, r12
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    call zyl_heap_alloc
    mov r13, rax
    cmp r13, 0
    je .L1708_4
    mov rdi, r13
    mov rsi, rbx
    mov rdx, r12
    call zy_local_x2Fmain_0__base__rt_x2Dcopy
    mov rsi, r13
    add rsi, r12
    jo zyl_rt_trap_ovf_0
    mov rdi, 0
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
.L1708_4:
    mov rdi, rbx
    call zyl_rt_free
    cmp r13, 0
    jne .L1708_5
    lea rax, [rip+.L1710]
    mov rsi, rax
    mov rax, rsi
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.L1708_5:
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
.L1711_0:
    mov rax, QWORD PTR fs:0
    lea rax, [rax+zyl_rtt_io_rl@tpoff]
    mov r14, rax
    mov rdi, 0
    mov rsi, r14
    add rsi, 16
    jo zyl_rt_trap_ovf_0
    mov r8, 1
    mov rdx, r8
    call zyl_rt_sys_0
    cmp rax, 1
    jne .L1711_1
    movzx eax, byte ptr [r14+16]
    cmp rax, 10
    je .L1711_1
    mov rax, r13
    add rax, 1
    jo zyl_rt_trap_ovf_0
    cmp rax, r12
    jl .L1711_2
    imul rsi, r12, 2
    jo zyl_rt_trap_ovf_2
    mov rdi, rbx
    call zyl_rt_realloc
    mov rsi, rax
    cmp rsi, 0
    jne .L1711_3
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
.L1711_3:
    mov rdi, rsi
    add rdi, r13
    jo zyl_rt_trap_ovf_0
    movzx r8d, byte ptr [r14+16]
    mov byte ptr [rdi+0], r8b
    mov rbx, rsi
    imul r12, r12, 2
    jo zyl_rt_trap_ovf_2
    add r13, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1711_0
.L1711_2:
    mov rsi, rbx
    add rsi, r13
    jo zyl_rt_trap_ovf_0
    movzx edi, byte ptr [r14+16]
    mov rcx, rdi
    mov byte ptr [rsi+0], cl
    add r13, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1711_0
.L1711_1:
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
.L1712_0:
    mov qword ptr [rdi+0], rsi
    mov qword ptr [rdi+8], r8
    mov rax, rdi
    ret
zy_local_x2Fmain_0__io__io_x2Dcells:
    # frame 0
.L1713_0:
    lea rax, [rip+zyl_rtg_cells]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_cell_get
zyl_cell_get:
    # frame 0
.L1714_0:
    cmp rdi, 0
    jl .L1714_1
.L1714_2:
    cmp rdi, 16
    jge .L1714_1
    lea rax, [rip+zyl_rtg_cells]
    mov rsi, rax
    imul rdi, rdi, 8
    jo zyl_rt_trap_ovf_2
    add rsi, rdi
    jo zyl_rt_trap_ovf_0
    mov rax, qword ptr [rsi+0]
    ret
.L1714_1:
    mov rax, 0
    ret
.globl zyl_cell_set
zyl_cell_set:
    # frame 0
.L1715_0:
    cmp rdi, 0
    jl .L1715_1
.L1715_3:
    cmp rdi, 16
    jge .L1715_1
    lea rax, [rip+zyl_rtg_cells]
    mov r8, rax
    imul rdi, rdi, 8
    jo zyl_rt_trap_ovf_2
    add r8, rdi
    jo zyl_rt_trap_ovf_0
    mov qword ptr [r8+0], rsi
    jmp .L1715_2
.L1715_1:
.L1715_2:
    mov rax, 0
    ret
zy_local_x2Fmain_0__env__ev_x2Denvp_x2Dcell:
    # frame 0
.L1716_0:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov rax, rsi
    ret
.globl zyl_rt_set_env
zyl_rt_set_env:
    # frame 0
.L1717_0:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov qword ptr [rsi+0], rdi
    mov rax, 0
    ret
.globl zyl_rt_envp
zyl_rt_envp:
    # frame 0
.L1718_0:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    ret
.globl zyl_rt_getenv
zyl_rt_getenv:
    # frame 0
.L1719_0:
    cmp rdi, 0
    je .L1719_2
.L1719_4:
    movzx eax, byte ptr [rdi+0]
    cmp rax, 0
    jne .L1719_1
.L1719_2:
    mov rax, 0
    ret
.L1719_1:
    lea rax, [rip+zyl_rtg_rt_envp]
    mov rsi, rax
    mov rsi, qword ptr [rsi+0]
    cmp rsi, 0
    jne .L1719_3
    mov rax, 0
    ret
.L1719_3:
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
.L1720_0:
    mov rdi, qword ptr [rbx+0]
    cmp rdi, 0
    jne .L1720_1
    mov rax, 0
    pop r12
    pop rbx
    pop rbp
    ret
.L1720_1:
    mov rsi, r12
    call zy_local_x2Fmain_0__env__ev_x2Dmatch
    mov rsi, rax
    cmp rsi, 0
    jne .L1720_2
    add rbx, 8
    jo zyl_rt_trap_ovf_0
    jmp .L1720_0
.L1720_2:
    mov rax, rsi
    pop r12
    pop rbx
    pop rbp
    ret
zy_local_x2Fmain_0__env__ev_x2Dmatch:
    # frame 0
.L1721_0:
    movzx r8d, byte ptr [rsi+0]
    cmp r8, 0
    jne .L1721_1
    movzx eax, byte ptr [rdi+0]
    cmp rax, 61
    jne .L1721_2
    mov rax, rdi
    add rax, 1
    jo zyl_rt_trap_ovf_0
    ret
.L1721_2:
    mov rax, 0
    ret
.L1721_1:
    movzx eax, byte ptr [rdi+0]
    cmp rax, r8
    jne .L1721_3
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    add rsi, 1
    jo zyl_rt_trap_ovf_0
    jmp .L1721_0
.L1721_3:
    mov rax, 0
    ret
zy_local_x2Fmain_0__env__ev_x2Dmax:
    # frame 0
.L1722_0:
    mov rax, 32
    ret
zy_local_x2Fmain_0__env__ev_x2Dreg:
    # frame 0
.L1723_0:
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
.L1724_0:
    mov rsi, 1
    mov rdx, rbx
    mov rcx, rsi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    cmp rax, 0
    jne .L1724_1
    mov rax, 0
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
.L1724_1:
    call zyl_rt_sys_24
    jmp .L1724_0
zy_local_x2Fmain_0__env__ev_x2Dunlock:
    # frame 0
.L1725_0:
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
.L1726_0:
    lea rax, [rip+zyl_rtg_rt_exit_reg]
    mov r12, rax
    mov rdi, r12
    call zy_local_x2Fmain_0__env__ev_x2Dlock
    mov rsi, qword ptr [r12+8]
    cmp rsi, 32
    jl .L1726_1
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
.L1726_1:
    mov rdi, rsi
    add rdi, 2
    jo zyl_rt_trap_ovf_0
    imul rdi, rdi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, r12
    jo zyl_rt_trap_ovf_0
    mov qword ptr [rdi+0], rbx
    add rsi, 1
    jo zyl_rt_trap_ovf_0
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
.L1727_0:
    lea rax, [rip+zyl_rtg_rt_exit_reg]
    mov rbx, rax
    mov rdi, rbx
    call zy_local_x2Fmain_0__env__ev_x2Dlock
    mov rsi, qword ptr [rbx+8]
    cmp rsi, 0
    jne .L1727_1
    mov rdi, 0
    mov rdx, rbx
    mov rcx, rdi
    mov rax, rcx
    xchg qword ptr [rdx], rax
    mov rax, 0
    pop rbx
    pop rbp
    ret
.L1727_1:
    mov rdi, rsi
    add rdi, 1
    jo zyl_rt_trap_ovf_0
    imul rdi, rdi, 8
    jo zyl_rt_trap_ovf_2
    add rdi, rbx
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rdi+0]
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
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
.L1728_0:
    call zy_local_x2Fmain_0__env__ev_x2Dpop
    mov rdi, rax
    cmp rdi, 0
    jne .L1728_1
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L1728_1:
    call zyl_rt_call0
    jmp .L1728_0
.globl zyl_rt_exit
zyl_rt_exit:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    and rsp, -16
    sub rsp, 16
    mov rbx, rdi
.L1729_0:
    call zyl_rt_run_atexit
    call zyl_term_flush
    mov rax, QWORD PTR [rip+exit@GOTPCREL]
    mov rdi, rax
    lea rax, [rip+zyl_rtg_freestanding]
    mov rsi, rax
    mov rax, qword ptr [rsi+0]
    cmp rax, 0
    jne .L1729_1
    cmp rdi, 0
    jle .L1729_1
    mov rsi, rbx
    mov rbx, qword ptr [rbp-8]
    mov rsp, rbp
    pop rbp
    jmp zyl_rt_call1
.L1729_1:
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
.L1730_0:
    mov rdi, rbx
    call zyl_rt_sys_231
    mov rdi, rbx
    call zyl_rt_sys_60
    jmp .L1730_0
zy_local_x2Fmain_0__crc__rt_x2Dsse42:
    # frame 0
.L1731_0:
    lea rax, [rip+zyl_rtg_cpu_sse42]
    mov rsi, rax
    mov rdi, qword ptr [rsi+0]
    cmp rdi, 0
    jne .L1731_1
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
    jle .L1731_2
    mov r8, 2
    jmp .L1731_3
.L1731_2:
    mov r8, 1
.L1731_3:
    mov qword ptr [rsi+0], r8
    mov rax, r8
    cmp rax, 2
    sete al
    movzx rax, al
    ret
.L1731_1:
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
.L1732_0:
    lea rax, [rip+zyl_rtg_crc32c_tab]
    mov rbx, rax
    lea rax, [rip+zyl_rtg_crc32c_tab_ok]
    mov r12, rax
    mov rax, qword ptr [r12+0]
    cmp rax, 1
    jne .L1732_1
    mov rax, rbx
    pop r12
    pop rbx
    pop rbp
    ret
.L1732_1:
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
.L1733_0:
    cmp r12, 255
    jle .L1733_1
.L1733_3:
    mov rax, 0
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.p2align 4
.L1733_1:
    imul rsi, r12, 8
    jo zyl_rt_trap_ovf_2
    mov r13, rbx
    add r13, rsi
    jo zyl_rt_trap_ovf_0
    mov rsi, 8
    mov rdi, r12
    cmp rsi, 0
    je .L1733_2
    mov rdi, r12
    call zy_local_x2Fmain_0__crc__crc_x2Dbits
    mov rdi, rax
.L1733_2:
    mov qword ptr [r13+0], rdi
    add r12, 1
    jo zyl_rt_trap_ovf_0
    cmp r12, 255
    jle .L1733_1
    jmp .L1733_3
zy_local_x2Fmain_0__crc__crc_x2Dbits:
    # frame 0
.L1734_0:
    cmp rsi, 0
    jne .L1734_1
.L1734_4:
    mov rax, rdi
    ret
.p2align 4
.L1734_1:
    mov rax, rdi
    and rax, 1
    cmp rax, 1
    jne .L1734_2
    mov r8, rdi
    shr r8, 1
    mov r9, 2197175160
    xor r8, r9
    jmp .L1734_3
.L1734_2:
    mov r8, rdi
    shr r8, 1
.L1734_3:
    mov rdi, r8
    sub rsi, 1
    jo zyl_rt_trap_ovf_1
    cmp rsi, 0
    jne .L1734_1
    jmp .L1734_4
zy_local_x2Fmain_0__crc__crc_x2Dbyte:
    # frame 0
    mov r8, rdx
.L1735_0:
    xor r8, rsi
    and r8, 255
    imul r8, r8, 8
    jo zyl_rt_trap_ovf_2
    add rdi, r8
    jo zyl_rt_trap_ovf_0
    mov rdi, qword ptr [rdi+0]
    shr rsi, 8
    xor rdi, rsi
    mov rax, rdi
    ret
zy_local_x2Fmain_0__crc__crc_x2Dsoft_x2Dbytes:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L1736_0:
    cmp r9, 0
    jne .L1736_1
.L1736_2:
    mov rax, rsi
    ret
.p2align 4
.L1736_1:
    mov r10, r8
    and r10, 255
    xor r10, rsi
    and r10, 255
    imul r10, r10, 8
    jo zyl_rt_trap_ovf_2
    add r10, rdi
    jo zyl_rt_trap_ovf_0
    mov r10, qword ptr [r10+0]
    mov r11, rsi
    shr r11, 8
    mov rsi, r10
    xor rsi, r11
    shr r8, 8
    sub r9, 1
    jo zyl_rt_trap_ovf_1
    cmp r9, 0
    jne .L1736_1
    jmp .L1736_2
.globl zyl_crc32c_soft
zyl_crc32c_soft:
    # frame 16
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi
.L1737_0:
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
.L1738_0:
    call zy_local_x2Fmain_0__crc__rt_x2Dsse42
    cmp rax, 0
    je .L1738_1
    mov rdx, rbx
    mov rcx, r12
    mov eax, edx
    crc32 rax, rcx
    pop r12
    pop rbx
    pop rbp
    ret
.L1738_1:
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
.L1739_0:
    call zy_local_x2Fmain_0__crc__rt_x2Dsse42
    cmp rax, 0
    je .L1739_1
    mov rdx, rbx
    mov rcx, r12
    mov eax, edx
    crc32 eax, cl
    pop r12
    pop rbx
    pop rbp
    ret
.L1739_1:
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
zy_local_x2Fmain_0__text__rt_x2Dacc_x2Dstep_x7EBool_x2CInt_x2CInt_x2CInt:
    # frame 0
    mov r8, rdx
    mov r9, rcx
.L1740_0:
    cmp rdi, 0
    je .L1740_1
.L1740_2:
    mov rdi, rsi
    imul rdi, r9
    jo zyl_rt_trap_ovf_2
    sub rdi, r8
    jo zyl_rt_trap_ovf_1
    mov rax, rdi
    ret
.L1740_1:
    imul rsi, r9
    jo zyl_rt_trap_ovf_2
    add rsi, r8
    jo zyl_rt_trap_ovf_0
    mov rax, rsi
    ret
zy_local_x2Fmain_0__variant__rt_x2Dwords_x2Dcmp_x7EInt_x2CInt_x2CInt_x2CInt_x2CInt_x2CInt:
    # frame 16
    push rbx
    push r12
    mov r10, r8
    mov r8, rdx
    mov r11, r9
    mov r9, rcx
.L1741_0:
    cmp r8, r9
    jl .L1741_1
.L1741_6:
    cmp r10, r11
    jge .L1741_2
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1741_2:
    cmp r10, r11
    jle .L1741_3
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1741_3:
    mov rax, 0
    pop r12
    pop rbx
    ret
.p2align 4
.L1741_1:
    imul rbx, r8, 8
    jo zyl_rt_trap_ovf_2
    add rbx, rdi
    jo zyl_rt_trap_ovf_0
    mov rbx, qword ptr [rbx+0]
    imul r12, r8, 8
    jo zyl_rt_trap_ovf_2
    add r12, rsi
    jo zyl_rt_trap_ovf_0
    mov r12, qword ptr [r12+0]
    cmp rbx, r12
    jge .L1741_4
    mov rax, -1
    pop r12
    pop rbx
    ret
.L1741_4:
    cmp rbx, r12
    jle .L1741_5
    mov rax, 1
    pop r12
    pop rbx
    ret
.L1741_5:
    add r8, 1
    jo zyl_rt_trap_ovf_0
    cmp r8, r9
    jl .L1741_1
    jmp .L1741_6
.section .rodata
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
.L54:
    .string "+"
.L55:
    .string "-"
.L56:
    .string "*"
.L57:
    .string "div!"
.L58:
    .string "rem!"
.L60:
    .string "the smallest Int divided by -1 has no Int result, in `"
.L61:
    .string "`\n  = help: `div!` and `rem!` cannot compute this one pair; test for -1 before dividing"
.L62:
    .string "integer overflow in `"
.L63:
    .string "`\n  = help: write `(numeric wrapping)` at the top of the file if wrap-around is intended, or `(numeric saturating)` to clamp"
.L65:
    .string "division by zero in `"
.L66:
    .string "`\n  = help: write `("
.L67:
    .string "div?"
.L68:
    .string "rem?"
.L69:
    .string " a b)` to get None for a zero divisor, or test the divisor first"
.L71:
    .string "error[E_OVERFLOW]: "
.L73:
    .string "error[E_DIVISION_BY_ZERO]: "
.L77:
    .string "cstr-len"
.L79:
    .string "cstr-len"
.L81:
    .string "cstr-eq"
.L82:
    .string "cstr-eq"
.L85:
    .string "cstr-byte-at"
.L87:
    .string "cstr-byte-at"
.L90:
    .string "cstr-concat"
.L91:
    .string "cstr-concat"
.L96:
    .string "cstr-substr"
.L103:
    .string "view"
.L116:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L118:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L119:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L121:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L122:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L123:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L124:
    .string "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"
.L130:
    .string "cstr-sub"
.L145:
    .string "cstr-to-int"
.L153:
    .string "cstr-to-int-base"
.L157:
    .string "cstr-sanitize"
.L163:
    .string "cstr-decode"
.L166:
    .string "cstr-count-newlines"
.L169:
    .string "cstr-last-newline"
.L184:
    .string "/proc/meminfo"
.L185:
    .string "MemAvailable:"
.L186:
    .string "MemTotal:"
.L189:
    .string "ZYL_MAX_MEMORY"
.L254:
    .string "E_INDEX_OUT_OF_BOUNDS: vector index "
.L255:
    .string " outside length "
.L259:
    .string "E_INDEX_OUT_OF_BOUNDS: pop from an empty vector"
.L285:
    .string "contract violated"
.L286:
    .string "warning: "
.L287:
    .string "\n"
.L296:
    .string "<input>"
.L297:
    .string ""
.L298:
    .string ""
.L301:
    .string "<input>"
.L309:
    .string ""
.L310:
    .string "..."
.L311:
    .string "..."
.L313:
    .string ""
.L316:
    .string ""
.L396:
    .string "0123456789abcdef"
.L398:
    .string "0123456789abcdef"
.L406:
    .string "0123456789ABCDEF"
.L408:
    .string ""
.L410:
    .string ""
.L412:
    .string ""
.L413:
    .string "0123456789ABCDEF"
.L428:
    .string "0"
.L431:
    .string "0"
.L437:
    .string "PANIC: error[E_OUT_OF_MEMORY]: "
.L438:
    .string "\n  = requested "
.L439:
    .string " bytes; "
.L440:
    .string " bytes already allocated; budget "
.L441:
    .string " bytes\n  = help: set ZYL_MAX_MEMORY to a byte count to raise the budget, or ZYL_MAX_MEMORY=0 to remove it\n"
.L446:
    .string "memory budget exhausted"
.L447:
    .string "out of memory allocating an arena block header"
.L448:
    .string "out of memory allocating an arena block"
.L468:
    .string "\n"
.L470:
    .string "zyl_heap_alloc: size too large size="
.L471:
    .string "zyl_heap_alloc: FAILED size="
.L484:
    .string "memory budget exhausted"
.L485:
    .string "mmap failed for a region block"
.L494:
    .string "E_REGION_EXHAUSTED: "
.L495:
    .string "fixed"
.L496:
    .string "arena"
.L497:
    .string " region of "
.L498:
    .string " bytes is full"
.L502:
    .string "zyl_ralloc: size too large size="
.L518:
    .string "zyl: ffi-unpin: pointer not from ffi-pin/Pin arena\n"
.L521:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L522:
    .string ": index "
.L523:
    .string " outside a word array of length "
.L526:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L527:
    .string ": not a word array"
.L529:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L530:
    .string ": not a word array"
.L532:
    .string "E_OUT_OF_MEMORY: word array view"
.L534:
    .string "E_OUT_OF_MEMORY: word array"
.L537:
    .string "E_OUT_OF_MEMORY: word array"
.L540:
    .string "w-len"
.L541:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L542:
    .string ": not a word array"
.L544:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L545:
    .string ": not a word array"
.L547:
    .string "w-get"
.L549:
    .string "w-set"
.L551:
    .string "E_OUT_OF_MEMORY: word array view"
.L553:
    .string "w-view"
.L554:
    .string "w-view"
.L556:
    .string "w-view"
.L557:
    .string "w-view"
.L560:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L561:
    .string ": not an array"
.L563:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L564:
    .string ": not an array"
.L566:
    .string "E_OUT_OF_MEMORY: array"
.L568:
    .string "array-cap"
.L569:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L570:
    .string ": not an array"
.L572:
    .string "array-filled"
.L573:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L574:
    .string ": not an array"
.L576:
    .string "E_OUT_OF_MEMORY: array"
.L579:
    .string "E_OUT_OF_MEMORY: array"
.L581:
    .string "array-get"
.L582:
    .string "array-get"
.L583:
    .string "E_INDEX_OUT_OF_BOUNDS: "
.L584:
    .string ": not an array"
.L587:
    .string "array-copy"
.L588:
    .string "array-copy"
.L589:
    .string "array-copy"
.L590:
    .string "array-copy"
.L592:
    .string "array-set"
.L593:
    .string "array-set"
.L598:
    .string "attribute table"
.L607:
    .string "ref cell"
.L612:
    .string ""
.L616:
    .string "E_USE_AFTER_FREE: string buffer used after it was destroyed"
.L619:
    .string "0123456789abcdef"
.L621:
    .string "zyl: str-append: invalid string pointer 0x"
.L622:
    .string ""
.L623:
    .string "\n"
.L625:
    .string "E_CODEGEN_BUFFER_LIMIT: codegen buffer limit exceeded"
.L626:
    .string "E_INDEX_OUT_OF_BOUNDS: string buffer full"
.L679:
    .quad 0
.L680:
    .quad 0
.L685:
    .quad -4332466134535158144
.L686:
    .quad 4890905902319617664
.L699:
    .string "eef453d6923bd65a113faa2906a13b3f9558b4661b6565f84ac7ca59a424c507baaee17fa23ebf765d79bcf00d2df649e95a99df8ace6f53f4d82c2c107973dc91d8a02bb6c1059479071b9b8a4be869b64ec836a47146f99748e2826cdee284e3e27a444d8d98b7fd1b1b2308169b258e6d8c6ab0787f72fe30f0f5e50e20f7b208ef855c969f4fbdbd2d335e51a935de8b2b66b3bc4723ad2c788035e613828b16fb203055ac764c3bcb5021afcc31addcb9e83c6b1793df4abe242a1bbf3dd953e8624b85dd78d71d6dad34a2af0d87d4713d6f33aa6b8672648c40e5ad68a9c98d8ccb009506680efdaf511f18c2d43bf0effdc0ba480212bd1b2566def284a57695fe98746d014bb630f7604b57a5ced43b7e3e9188419ea3bd35385e2dcf42894a5dce35ea52064cac828675b9818995ce7aa0e1b27343efebd1940993a1ebfb4219491a1f1014ebe6c5f90bf8ca66fa129f9b60a6d41a26e077774ef6fd00b897478238d08920b098955522b49e20735e8cb1638255b46e5f5d5535b0c5a890362fddbc62eb2189f734aa831df712b443bbd52b7ba5e9ec7501d523e49a6bb0aa55653b2d47b233c92125366ec1069cd4eabe89f8999ec0bb696e840af148440a256e2c76c00670ea43ca250d96cd2a865764dbca380406926a5e5728bc807527ed3e12bcc605083704f5ecf2eba09271e88d976bf7864a44c633682e93445b8731587ea37ab3ee6afbe0211db8157268fdae9e4c5960ea05bad82964e61acf033d1a45df6fb92487298e33bd8fd0c16206306baba5d3b6d479f8e056b3c4f1ba87bc86968f48a4899877186ce0b62e2929aba83c331acdabfe94de878c71dcd9ba0b49259ff0c08b7f1d0b14af8e5410288e1b6f07ecf0ae5ee44dd9db71e91432b1a24ac9e82cd9f69d6150892731ac9faf056ebe311c083a225cd2ab70fe17c79ac6ca6dbd630a48aaf406d64d3d9db981787d092cbbccdad5b10885f0468293f0eb4e25bbf56008c58ea5a76c582338ed2621af2af2b80af6f24ed1476e2c07286faa1af5af660db4aee182cca4db847945ca50d98d9fc890ed4da37fce126597973ce50ff107bab528a0cc5fc196fefd7d0c1e53ed49a96272c8ff77b1fcbebcdc4f25e8e89c13bb0f7a9faacf3df73609b177b191618c54e9acc795830d75038c1dd59df5b9ef6a2417f97ae3d0d2446f254b0573286b44ad1d9becce62836ac5774ee367f9430aec32c2e801fb244576d5229c41f793cda73ff3a20279ed56d48a6b43527578c1110f9845418c345644d6830a13896b78aaa9be5691ef416bd60c23cc986bc656d553edec366b11c6cb8f2cbfbe86b7ec8aa894b3a202eb1c3f397bf7d71432f3d6a9b9e08a83a5e34f07daf5ccd93fb0cc53e858ad248f5c22c9d1b3400f8f9cff6891376c36d99995be23100809b9c21fa1b58547448ffffb2dabd40a0c2832a78ae2e69915b3fff9f916c90c8f323f516c8dd01fad907ffc3bae3da7d97f6792e3b1442798f49ffb4a99cd11cfdf41779cdd95317f31c7fa1d40405643d711d5838a7d3eef7f1cfc52482835ea666b2572ad1c8eab5ee43b66da3243650005eecfd863b256369d4a4090bed43e40076a82873e4f75e2224e685a7744a6e804a291a90de3535aaae202711515d0a205cb36d3515c2831559a830d5a5b44ca873e038412d9991ed58091e858790afe9486c2a5178fff668ae0b6626e974dbe39a872ce5d73ff402d98e3fb0a3d212dc8128f80fa687f881c7f8e7ce66634bc9d0b99a139029f6a239f721c1fffc1ebc44e80c987434744ac874ea327ffb266b56220fbe9141915d7a9224bf1ff9f0062baa89d71ac8fada6c9b56f773fc3603db4a9c4ce17b399107c22cb550fb4384d21d3f6019da07f549b2b7e2a53a146606a4899c102844f94e0fb2eda7444cbfc426dc0314325637a1939fa911155fefb5308f03d93eebc589f88793555ab7eba27ca96267c7535b763b54bc1558b2f3458debbb01b9283253ca29eb1aaedfb016f16ea9c227723ee8bcb465e15a979c1cadc92a1958a7675175f0bfacd89ec191ec9b749faed14125d36cef980ec671f667be51c79a85916f48482b7e12780e7401a8f31cc0937ae58d2d1b2ecb8b0908810b2fe3f0b8599ef07861fa7e6dcb4aa15dfbdcece67006ac967a791e093e1d49a8bd6a141006042bde0c8bb2c5c6d24e0aecc49914078536d58fae9f773886e18da7f5bf590966848af39a475506a899e888f99797a5e012d6d8406c952429603aab37fd7d8f58178c8e5087ba6d33b83d5605fcdcf32e1d6fb1e4a9a90880a64855c3be0a17fcd265cf2eea09a55067fa6b34ad8c9dfc06ff42faa48c0ea481ed0601d8efc57b08bf13b94daf124da26823c12795db6ce5776c53d08d6b70858a2cb1717b52481ed54768c4b0c64ca6ecb7ddcdda26da268a9942f5dcf7dfd09fe5d54150b090b02d3f93b35435d7c4c9efa548d26e5a6e1c47bc5014a1a6dafc6b8e9b0709f109a359ab6419ca1091bf867241c8cc6d4c0c30163d203c94b629b407691d7fc44f879e0de63425dcf1dc21094364dfb5636985915fc12f542e4f294b943e17a2bc43e6f5b7b17b2939d979cf3ca6cec5b5aa705992ceecf9c42bd8430bd0827723150c6ff782a838353ece53cec4a314ebda4f8bf5635246428940f4613ae5ed136871b7795e136be99b913179899f6858428e2557b59846e3fe757dd7ec07426e5331aeada2fe589cf9096ea6f3848984f3ff0d2c85def7621b4bca50b065abe630fed077a756b53a9e1ebce4dc7f16dfbd3e8495912c628948d3360f09cf6e4bd64712dd7abbbd95cb080392cc4349decbd8d794d96aacfb3dca04777f541c567ecf0d7a0fc5583a089e42caaf9491b60f41686c49db57244ac5d37d5b79b6239311c2875c522ced5d77485cb25823ac77d633293366b828b86a8d39ef77164bcae5dff9c02033197a8530886b54dbdebd9f57f830283fdfcd267caa862a12d66d072df63c324fd7b8380dea93da4bc604247cb9e59f71e6da46116538d0deb7852d9be85f074e608cd795be87051665667902e276c921f8b806bd9714632dff600ba1cd8a3db53b6a086cfcd97bf97f380e8a40eccd228a4c8a883c0fdaf7df06122cd128006b2cdfad2a4b13d1b5d6c796b805720085f819cc3a6eec6311a63cbe3303674053bb0c3f490aa77bd60fcbedbfc4411068a9cf4f1b4d515acb93bee92fb5515482d44991711052d8bf3c5751bdd152d4d1c4abf5cd54678eef0b6d262d45a78a0635def340a98172aace486fb897116c87c349580869f0e7aac0ed45d35e6ae3d4da0bae0a846d21957128974836059cca109e998d258869facd72bd1a438703fc94b91ff83775423cc067b6306a34627ddcfb67f6455292cbf081a3bc84c17b1d542e41f3d6a7377eeca20caba5f1d9e4a938e938662882af53e547eb47b7282ee9cb23867fb2a35b28de99e619a4f23aa43dec681f9f4c31f316405fa00e2ec94d48b3c113c38f9f37ede83bc408dd3dd04ae0b158b4738705e9624ab50b148d445d98ddaee19068c763badd624dd9b095787f8a8d4cfa417c9e54ca5d70a80e5d6a9f6d30a038d1dbc5e9fcf4ccd211f4cd47487cc8470652b7647c3200069671f84c8d4dfd2c63f3b29ecd9f40041e073a5fb0a17c777cf09f468107100525890cf79cc9db955c2cc7182148d4066eeb481ac1fe293d599bfc6f14cd848405530a21727db38cb002fb8ada00e5a506a7cca9cf1d206fdc03ba6d90811f0e4851cfd442e4688bd304a908f4a166d1da6639e4a9cec15763e2e9a598e4e043287fec5dd44271ad3cdba40eff1e1853f29fdf7549530e188c128d12bee59e68ef47c9a94dd3e8cf578b982bb74f8301958cec13a148e3032d6e7e36a52363c1faf01f18899b1bc3f8ca1dc44e6c3cb279ac196f5600f15a7b7e529ab103a5ef8c0b9bcb2b812db11a5de7415d448f6b6f0e7ebdf661791d60f56111b495b3464ad21936b9fcebb25c995cab10dd900beec34b84687c269ef3bfb3d5d514f40eea742e65829b3046b0afa0cb4a5a3112a51128ff71a0fe2c2e6dc47f0e785eaba72abb3f4e093db73a09359ed216765690f56e0f218b8d25088b8306869c13ec3532c8c974f73837255731e414218c73a13fbafbd2350644eeacfe5d1929ef90898fadbac6c247d62a583df45f746b74abf39894bc396ce5da7726b8bba8c328eb783ab9eb47c81f5114f066ea92f3f326564d686619ba27255a2c80a537b0efefebd8613fd0145877585bd06742ce95f5f36a798fc4196e952e72c48113823b73704d17f3b51fca3a7a0f75a15862ca504c582ef85133de648c49a984d73dbe722fba3ab66580d5fdaf5c13e60d0d2e0ebbacc963fee10b7d1b3318df905079926a8ffbbcfe994e5c61ffdf17746497f70529fd561f1fd0f9bd3feb6ea8bedefa633c7caba6e7c5382c8fe64a52ee96b8fc0f9bd690a1b68637b3dfdce7aa3c673b09c1661a651213e2d06bea10ca65c084ec31bfa0fe5698db8486e494fcff30a62f3e2f893dec3f1265a89dba3c3efccfa986ddb5c6b3a76b7f89629465a75e01cbe89523386091465f6bbb397f1135823ee2ba6c0678b597f746aa07ded582e2c94db483840b717efa8c2a44eb4571cdcba121a4650e4ddeb92f34d62616ce413e896a0d7e51e156677b020baf9c81d17915e2486ef32cd600ace1474dc1d122eb5b5ada8aaff80b80d819992132456bae3231912d5bf60e610e1fff697ed6c698df5efabc5979c8fca8d3ffa1ef463c1b1736b96b6fd83b3bd308ff8a6b17cb2ddd0467c64bce4a0ac7cb3f6d05ddbde8aa22c0dbef60ee46bcdf07a423aa96bad4ab7112eb3929d86c16c98d2c953c6d89d64d57a607744e871c7bf077ba8b787625f056c7c4a8b11471cd764ad4972a93af6c6c79b5d2dd598e40d3dd89bcfd389b478798234794aff1d108d4ec2c3843610cb4bf160cbcedf722a585139baa54394fe1eedb8fec2974eb4ee658828ce947a3da6a9273e733d226229feea32811ccc668829b8870806357d5a3f525fa163ff802a3426a8ca07c2dcb0cf26f7c9bcff6034c13052fc89b393dd02f0b5fc2c3f3841f17c67bbac2078d443ace29d9ba7832936edc0d54b944b84aa4c0dc5029163f384a9310a9e795e65d4df11f64335bcf065d37d4d4617b5ff4a16d599ea0196163fa42e504bced1bf8e4e45c06481fb9bcf8d39e45ec2862f71e1d6f07da27a82c370885d767327bb4e5a4c964e858c91ba26553a6a07f8d510f86fbbe226efb628afea890489f70a55368beadab0aba3b2dbe52b45ac74ccea842e92c8ae6b464fc96f3b0b8bc90012929db77ada0617e3bbcb09ce6ebb40173744e55990879ddcaabdcc420a6a101d05158f57fa54c2a9eab69fa946824a12232db32df8e9f354656447939822dc96abf9dff9772470297ebd59787e2b93bc56f78bfbea76c619ef3657eb4edb3c55b65aaefae51477a06b03ede622920b6b23f1dab99e59958885c4e95fab368e45eced88b402f7fd75539b11dbcb0218ebb414aae103b5fcd2a881d652bdc29f26a119d59944a37c0752a24be76d3346f0495f857fcae62d8493a56f70a4400c562ddba6dfbd9fb8e5b88ecb4ccd500f6bb952d097ad07a71f26b27e2000a41346a7a7825ecc24c873782f8ed400668c0c28c8a2f67f2dfa90563b728900802f0f32facbb41ef979346bca4f2b40a03ad2ffb9fea126b7d78186bce2f610c84987bfa89f24b832e6b0f4360dd9ca7d2df4d7c9c6ede63fa05d314391503d1c79720dbbf8a95fcf88747d9475a44c6397ce912a9b69dbe1b548ce7cc986afbe3ee11abac24452da229b021bfbe85badce996168f2d56790ab41c2a2fae27299423fb9c397c560ba6b0919a5dccd879fc967d41abdb6b8e905cb600f5400e987bbc1c920ed246723473e3813290123e9aab23b689436c0760c86e30bf9a0b6720aaf6521b94470938fa89bcef808e40e8d5b3e69e7958cb87392c2c2b60b1d1230b20e0490bd77f3483bb9b9b1c6f22b5e6f48c2b4ecd5f01a4aa8281e38aeb6360b1af3e2280b6c20dd523225c6da63c38de1b08d590723948a535f579c487e5a38ad0eb0af48ec79ace8372d835a9df0c6d851dcdb1b2798182244f8e431456cf88e658a08f0f8bf0f156b1b8e9ecb641b58ffac8b2d36eed2dac5e272467e3d222f3fd7adf884aa8791775b0ed81dcc6abb0f86ccbb52ea94baea98e947129fc2b4e9a87fea27a539e9a53f2398d747b36224d29fe4b18e88640e8eec7f0d19a03aad83a3eeeef9153e891953cf68300424aca48ceaaab75a8e2b5fa8c3423c052dd7cdb02555653131b63792f412cb06794d808e17555f3ebf11e2bbd88bbee40bd0a0b19d2ab70e6ed65b6aceaeae9d0ec4c8de047564d20a8bf245825a5a445275fb158592be068d2eeed6e2f0f0d567129ced737bb6c4183d55464dd69685606bc428d05aa4751e4caa97e14c3c26b886f53304714d9265dfd53dd99f4b3066a8993fe2c6d07b7fabe546a8038efe4029bf8fdb78849a5f96de98520472bdd033ef73d256a5c0f77c963e66858f6d444095a8637627989aaddde7001379a44aa8bb127c53b17ec1595560c018580d5d52e9d71b689dde71afaab8f01e6e10b4a69226712162ab070dcab3961304ca70e8b6b00d69bb55c8d13d607b97c5fd0d22e45c10c42a2b3b058cb89a7db77c506a8eb98a7a9a5b04e377f3608e92adb242b267ed1940f1c61c55f038b237591ed3df01e85f912e37a36b6c46dec52f66888b61313bbabce2c62323ac4b3b3da015ae397d8aa96c1b77abec975e0a0d081ad9c7dced53c7225596e7bd358c904a21881cea14545c75757e50d64177da2e54aa242499697392d2dde50bd1d5d0b9e9d4ad2dbfc3d07787955e4ec64b44e86484ec3c97da624ab4bd5af13bef0b113ea6274bbdd0fadd61ecb1ad8aeacdd58ecfb11ead453994ba67de18eda5814af281ceb32c4b43fcf480eacf948770ced7a2425ff75e14fc31a1258379a94d028dcad2f7f5359a3b3e096ee45813a04330fd87b5f28300ca0d8bca9d6e188853fc9e74d1b791e07e48775ea264cf55347ec612062576589dda95364afe032a819ef79687aed3eec5513a83ddbd83f522059abe14cd44753b52c4926a9672793543c16d9a0095928a2775b7053c0f178294f1c90080baf72cb15324c68b12dd6339971da05074da7beed3f6fc16ebca5e04bce5086492111aea88f4bb1ca6bcf585ec1e4a7db69561a52b31e9e3d06c32e69392ee8e921d5d073aff322e62439fd0b877aa3236a4b44909befeb9fad487c3e69594bec44de15b4c2ebe687989a9b4901d7cf73ab0acd90f9d37014bf60a11b424dc35095cd80f538484c19ef38c95e12e13424bb40e132865a5f206b06fba8cbccc096f5088cbf93f87b7442e45d4afebff0bcb24aafef78f69a51539d749dbe6fecebdedd5beb573440e5a884d1c89705f4136b4a59731680a88f8953031abcc77118461cefcfdc20d2b36ba7c3ed6bf94d5e57a42bc3d32907604691b4d8637bd05af6c69b5a63f9a49c2c1b110a7c5ac471b4784230fcf80dc33721d54d1b71758e219652bd3c36113404ea4a983126e978d4fdf3b645a1cac083126eaa3d70a3d70a3d70a3d70a3d70a3d70a4cccccccccccccccccccccccccccccccd80000000000000000000000000000000a0000000000000000000000000000000c8000000000000000000000000000000fa0000000000000000000000000000009c400000000000000000000000000000c3500000000000000000000000000000f424000000000000000000000000000098968000000000000000000000000000bebc2000000000000000000000000000ee6b28000000000000000000000000009502f900000000000000000000000000ba43b740000000000000000000000000e8d4a5100000000000000000000000009184e72a000000000000000000000000b5e620f4800000000000000000000000e35fa931a000000000000000000000008e1bc9bf040000000000000000000000b1a2bc2ec50000000000000000000000de0b6b3a7640000000000000000000008ac7230489e800000000000000000000ad78ebc5ac6200000000000000000000d8d726b7177a80000000000000000000878678326eac90000000000000000000a968163f0a57b4000000000000000000d3c21bcecceda100000000000000000084595161401484a00000000000000000a56fa5b99019a5c80000000000000000cecb8f27f4200f3a0000000000000000813f3978f89409844000000000000000a18f07d736b90be55000000000000000c9f2c9cd04674edea400000000000000fc6f7c40458122964d000000000000009dc5ada82b70b59df020000000000000c5371912364ce3056c28000000000000f684df56c3e01bc6c7320000000000009a130b963a6c115c3c7f400000000000c097ce7bc90715b34b9f100000000000f0bdc21abb48db201e86d4000000000096769950b50d88f41314448000000000bc143fa4e250eb3117d955a000000000eb194f8e1ae525fd5dcfab080000000092efd1b8d0cf37be5aa1cae500000000b7abc627050305adf14a3d9e40000000e596b7b0c643c7196d9ccd05d00000008f7e32ce7bea5c6fe4820023a2000000b35dbf821ae4f38bdda2802c8a800000e0352f62a19e306ed50b2037ad2000008c213d9da502de454526f422cc340000af298d050e4395d69670b12b7f410000daf3f04651d47b4c3c0cdd765f11400088d8762bf324cd0fa5880a69fb6ac800ab0e93b6efee00538eea0d047a457a00d5d238a4abe9806872a4904598d6d88085a36366eb71f04147a6da2b7f864750a70c3c40a64e6c51999090b65f67d924d0cf4b50cfe20765fff4b4e3f741cf6d82818f1281ed449fbff8f10e7a8921a4a321f2d7226895c7aff72d52192b6a0dcbea6f8ceb02bb399bf4f8a69f764490fee50b7025c36a0802f236d04753d5b49f4f2726179a224501d762422c946590c722f0ef9d80aad6424d3ad2b7b97ef5f8ebad2b84e0d58bd2e0898765a7deb29b934c3b330c857763cc55f49f88eb2fc2781f49ffcfa6d53cbf6b71c76b25fbf316271c7fc3908a8bef464e3945ef7a97edd871cfda3a5697758bf0e3cbb5acbde94e8e43d0c8ec3d52eeed1cbea317ed63a231d4c4fb274ca7aaa863ee4bdd945e455f24fb1cf88fe8caa93e74ef6ab975d6b6ee39e436b3e2fd538e122b44e7d34c64a9c85d4460dbbca87196b61690e40fbeea1d3a4abc8955e946fe31cdb51d13aea4a488dd6babab6398bdbe41e264589a4dcdab14c696963c7eed2dd18d7eb76070a08aecfc1e1de5cf543ca2b0de65388cc8ada83b25a55f43294bcbdd15fe86affad91249ef0eb713f39ebe8a2dbf142dfcc7ab6e3569326c784337acb92ed9397bf99649c2c37f07965404d7e77a8f87daf7fbdc33745ec97be90686f0ac99b4e8dafd69a028bb3ded71a3a8acd7c0222311bcc40832ea0d68ce0cd2d80db02aabd62bf50a3fa490c3019083c7088e1aab65db792667c6da79e0faa4b8cab1a1563f52577001b891185938cde6fd5e09abcf26ed4c0226b55e6f8680b05e5ac60b6178544f8158315b05b4a0dc75f1778e39d6696361ae3db1c721c913936dd571c84c03bc3a19cd1e38e9fb5878494ace3a5f04ab48a04065c7239d174b2dcec0e47b62eb0d64283f9c76c45d1df942711d9a3ba5d0bd324f8394f5746577930d6500ca8f44ec7ee364799968bf6abbe85f207e998b13cf4e1ecbbfc2ef456ae276e89e3fedd8c321a67eefb3ab16c59b14a2c5cfe94ef3ea101e95d04aee3b80ece5bba1f1d158724a12bb445da9ca61281f2a8a6e45ae8edc97ea1575143cf97226f52d09d71a3293bd924d692ca61be758593c2626705f9c56b6e0c377cfa2e12e6f8b2fb00c77836ce498f455c38b997a0b6dfb9c0f9564478edf98b59a373fec4724bd4189bd5eacb2977ee300c50fe758edec91ec2cb657df3d5e9bc0f653e12f2967b66737e3ed8b865b215899f46cbd79e0d20082ee74ae67f1e9aec07187ecd8590680a3aa11da01ee641a708de9e80e6f4820cc9495884134fe908658b23109058d147fdcddaa51823e34a7eedebd4b46f0599fd415d4e5e2cdc1d1ea966c9e18ac7007c91a850fadc09923329e03e2cf6bc604ddb0a6539930bf6bff4584db8346b786151ccfe87f7cef46ff16e612641865679a6381f14fae158c5f6e4fcb7e8f3f60c07ea26da3999aef7749e3be5e330f38f09dcb090c8001ab551c5cadf5bfd3072cc5fdcb4fa002162a6373d9732fc7c8f7f69e9f11c4014dda7e2867e7fddcdd9afac646d63501a1511db281e1fd541501b8f7d88bc24209a5651f225a7ca91a42269ae757596946075f3375788de9b06958c1a12d2fc39789370052d6b1641c83aef209787bb47d6b84c0678c5dbd23a49a9745eb4d50ce6332f840b7ba963646e0bd176620a501fbffb650e5a93bc3d898ec5d3fa8ce427affa3e51f138ab4cebe93ba47c980e98cdfc66f336c36b10137b8a8d9bbe123f017b80b0047445d4184e6d3102ad96cec1da60dc059157491e59043ea1ac7e4139287c89837ad68db2fb454e4a179dd187729babe4598c311fbe16a1dc9d8545e94f4296dd6fef3d67a8ce2529e2734bb1d1899e4a65f58660cb01ae745b101e9e45ec05dcff72e7f8fdc21a1171d42645d76707543f4fa1f73899504ae72497eba6a06494a791c53a8abfa45da0edbde690487db9d17636892d6f8d7509292d60345a9d2845d3c42b6865b86925b9bc5c20b8a2392ba45a9b2a7f26836f282b7328e6cac7768d7141ed1ef0244af2364ff3207d795430cd9268335616aed761f1f7f44e6bd49e807b8a402b9c5a8d3a6e75f16206c9c6209a6cd036837130890a136dba887c37a8c0f802221226be55a64c2494954da2c9789a02aa96b06deb0fdf2db9baa10b7bd6cc83553c5c8965d3d6f92829494e5acc7fa42a8b73abbf48ccb772339ba1f17f99c69a97284b578d7ff2a760414536efbc38413cf25e2d70dfef5138519684abaf46518c2ef5b8cd17eb258665fc25d6998bf2f79d5993802ef2f773ffbd97a61beeefb584aff8603aafb550ffacfd8faeeaaba2e5dbf678495ba2a53f983cf38952ab45cfa97a0b2dd945a747bf26183ba756174393d88df94f971119aeef9e4e912b9d1478ceb177a37cd5601aab85d91abb422ccb812eeac62e055c10ab33ab616a12b7fe617aa577b986b314d6009e39c49765fdf9d94ed5a7e85fda0b80b8e41ade9fbebc27d14588f13be847307b1d219647ae6b31c596eb2d8ae258fc8de469fbd99a05fe36fca5f8ed9aef3bb8aec23d680043bee25de7bb9480d5854ada72ccc20054ae9af561aa79a10ae6ad910f7ff28069da41b2ba1518094da0487aa9aff7904228690fb44d2f05d0842a99541bf57452b28353a1607ac744a53d3fa922f2d1675f242889b8997915ce8847c9b5d7c2e09b769956135febada11a59bc234db398c2543fab9837e699095cf02b2c21207ef2e94f967e45e03f4bb8161afb94b44f57d1d1be0eebac278f5a1ba1ba79e1632dc6462d92a69731732ca28a291859bbf937d7b8f7503cfdcfefcb2cb35e702af785cda735244c3d43e9defbf01b061adab3a0888136afa64a7c56baec21c7a1916088aaa1845b8fdd0f6c69a72a3989f5b8aad549e57273d459a3c2087a63f639936ac54e2f678864bc0cb28a98fcf3c7f84576a1bb416a7ddf0fdf2d3f3c30b9f656d44a2a11c51d5969eb7c47859e7439f644ae5a4b1b325bc4665b596706114873d5d9f0dde1feeeb57ff22fc0c7959a90cb506d155a7ea9316ff75dd87cbd809a7f12442d588f2b7dcbf5354e9bece0c11ed6d538aeb2fe5d3ef282a242e818f1668c8a86da5fa8fa475791a569d10f96e017d694487bcb38d92d760ec445537c981dcc395a9ace070f78d3927556a85bbe253f47b14178c469ab843b8956293956d7478ccec8eaf58416654a6babb387ac8d1970027b2db2e51bfe9d0696a06997b05fcc0319e88fcf317f22241e2441fece3bdf81f03ab3c2fddeeaad25ad527e81cad7626c3d60b3bd56a5586f18a71e223d8d3b07485c7056562757456f6872d5667844e49a738c6bebb12d16cb428f8ac016561dbd106f86e69d785c7e13336d701beba5282a45b450226b39cecc0024661173473a34d721642b0608427f002d7f95d0190cc20ce9bd35c78a531ec038df7b441f4ff290242c83396ce7e67047175a152719f79a169bd203e410f0062c6e984d386c75809c42c684dd152c07b78a3e60868f92e0c3537826145a7709a56ccdf8a829bbcc7a142b17ccb88a66076400bb691c2abf989935ddbfe6acff893d00ea435f356f7ebf83552fe0583f6b8c4124d4398165af37b2153dec3727a337a8b704abe1bf1b059e9a8d6744f18c0592e4c5ceda2ee1c7064130c1162def06f79df739485d4d1c63e8be78addcb5645ac2ba8b9a74a0637ce2ee16d953e2bd7173692e8111c87c5c1ba99c8fa8db6ccdd0437910ab1d4db9914a01d9c9892400a22a2b54d5e4a127f59c82503beb6d00cab4be2a0b5dc971f303a2e44ae64840fd61d8da471a9de737e245ceaecfed289e5d2b10d8e1456105dad7425a83e872c5f47dd50f1996b947518d12f124e28f777198a5296ffe33cc92f82bd6b70d99aaa6face73cbfdc0bfb7b636cc64d1001550bd8210befd30efa5a3c47f7e05401aa4e8714a775e3e95c7865acfaec34810a71a8d9d1535ce3b3967f1839a741a14d0dd31045a8341ca07c1ede48111209a05083ea2b892091e44d934aed0aab460432a4e4b66b68b65d60f81da84d5617853fce1de40642e3f4b936251260ab9d668e80d2ae83e9ce78f3c1d72b7c6b426019a1075a24e4421730b24cf65b8612f81fc94930ae1d529cfcdee033f26797b627fb9b7cd9a4a7443c169840ef017da3b19d412e0806e88aa58e1f289560ee864ec491798a08a2ad4ef1a6f2bab92a27e2f5b5d7ec8acb58a2ae10af696774b1db9991a6f3d6bf1765acca6da1e0a8ef29bff610b0cc6edd3f17fd090a58d32af3eff394dcff8a948eddfc4b4cef07f5b095f83d0a1fb69cd94abdaf101564f98ebb764c4ca7a4440f9d6d1ad41abe37f1ea53df5fd18d551384c86189216dc5ed92746b9be2f8552c32fd3cf5b4e49bb4b7118682dbb66a773fbc8c33221dc2a1e4d5e82392a405150fabaf3feaa5334a8f05b1163ba6832d29cb4d87f2a7400eb2c71d5bca9023f8743e20e9ef511012df78e4b2bd342cf6914da9246b2554168bab8eefb6409c1a1ad089b6c2f7548eae9672aba3d0c320a184ac2473b529b1da3c0f568cc4f3e8c9e5d72d90a2741e8865899617fb18717e2fa67c7a658892aa7eebfb9df9de8dddbb901b98feeab7d51ea6fa85785631552a74227f3ea5658533285c936b35ded53a88958f87275fa67ff273b84603568a892abaf368f137d01fef10a657842c2d2b7569b0432d858213f56a67f6b29b9c3b29620e29fc73a298f2c501f45f428349f3ba91b47b8fcb3f2f7642717713241c70a936219a73fe0efb53d30dd4d7ed238cd383aa01109ec95d1463e8a506f4363804324a40aac67bb4597ce2ce48b143c6053edcd0d5f81aa16fdc1b81dadd94b7868e94050a9b10a4e5e9913128ca7cf2b4191c8326c1d4ce1f63f57d72fd1c2f611f63a3f0f24a01a73cf2dccfbc633b39673c8cec976e41088617ca01d5be0503e085d813bd49d14aa79dbc824b2d8644d8a74e18ec9c459d51852ba2ddf8e7d60ed1219e93e1ab8252f33b45cabb90e5c942b503b8da1662e7b00a173d6a751f3b936243e7109bfba19c0c9d0cc512670a783ad4906a617d450187e227fb2b80668b24c5b484f9dc9641e9dab1f9f660802dedf6e1a63853bbd264515e7873f8a03969738d07e33455637eb2db0b487b6423e1e8b049dc016abc5e5f91ce1a9a3d2cda62dc5c5301c56b75f77641a140cc7810fb89b9b3e11b6329baa9e904c87fcb0a9dac2820d9623bf429546345fa9fbdcd44d732290fbacaf133a97c177947ad4095867f59a9d4bed6c049ed8eabcccc485da81f301449ee8c705c68f256bfff5a74d226fc195c6a2f8c73832eec6fff311183585d8fd9c25db7c831fd53c5ff7eaba42e74f3d032f525ba3e7ca8b77f5e55cd3a1230c43fb26f28ce1bd2e55f35eb80444b5e7aa7cf857980d163cf5b81b3a0555e361951c366d7e105bcc332621fc86ab5c39fa634408dd9472bf3fefaa7fa856334878fc150b14f98f6f0feb9519c935e00d4b9d8d26ed1bf9a569f33d3c3b8358109e84f070a862f80ec4700c8f4a642e14c6262c8cd27bb612758c0fa98e7e9cccfbd7dbd8038d51cb897789cbf21e44003acdd2ce0470a63e6bd56c3eeea5d50049814781858ccfce06cac7495527a5202df0ccb0f37801e0c43ebc8baa718e68396cffdd30560258f54e6bae950df20247c83fd47c6b82ef32a206991d28b7416cdd27e4cdc331d57fa5441b6472e511c81471de0133fe4adf8e952e3d8f9e563a198e558180fddd97723a68e679c2f5e44ff8f570f09eaa7ea7648"
.L700:
    .quad 4607182418800017408
.L705:
    .quad 4621819117588971520
.L707:
    .string "eef453d6923bd65a113faa2906a13b3f9558b4661b6565f84ac7ca59a424c507baaee17fa23ebf765d79bcf00d2df649e95a99df8ace6f53f4d82c2c107973dc91d8a02bb6c1059479071b9b8a4be869b64ec836a47146f99748e2826cdee284e3e27a444d8d98b7fd1b1b2308169b258e6d8c6ab0787f72fe30f0f5e50e20f7b208ef855c969f4fbdbd2d335e51a935de8b2b66b3bc4723ad2c788035e613828b16fb203055ac764c3bcb5021afcc31addcb9e83c6b1793df4abe242a1bbf3dd953e8624b85dd78d71d6dad34a2af0d87d4713d6f33aa6b8672648c40e5ad68a9c98d8ccb009506680efdaf511f18c2d43bf0effdc0ba480212bd1b2566def284a57695fe98746d014bb630f7604b57a5ced43b7e3e9188419ea3bd35385e2dcf42894a5dce35ea52064cac828675b9818995ce7aa0e1b27343efebd1940993a1ebfb4219491a1f1014ebe6c5f90bf8ca66fa129f9b60a6d41a26e077774ef6fd00b897478238d08920b098955522b49e20735e8cb1638255b46e5f5d5535b0c5a890362fddbc62eb2189f734aa831df712b443bbd52b7ba5e9ec7501d523e49a6bb0aa55653b2d47b233c92125366ec1069cd4eabe89f8999ec0bb696e840af148440a256e2c76c00670ea43ca250d96cd2a865764dbca380406926a5e5728bc807527ed3e12bcc605083704f5ecf2eba09271e88d976bf7864a44c633682e93445b8731587ea37ab3ee6afbe0211db8157268fdae9e4c5960ea05bad82964e61acf033d1a45df6fb92487298e33bd8fd0c16206306baba5d3b6d479f8e056b3c4f1ba87bc86968f48a4899877186ce0b62e2929aba83c331acdabfe94de878c71dcd9ba0b49259ff0c08b7f1d0b14af8e5410288e1b6f07ecf0ae5ee44dd9db71e91432b1a24ac9e82cd9f69d6150892731ac9faf056ebe311c083a225cd2ab70fe17c79ac6ca6dbd630a48aaf406d64d3d9db981787d092cbbccdad5b10885f0468293f0eb4e25bbf56008c58ea5a76c582338ed2621af2af2b80af6f24ed1476e2c07286faa1af5af660db4aee182cca4db847945ca50d98d9fc890ed4da37fce126597973ce50ff107bab528a0cc5fc196fefd7d0c1e53ed49a96272c8ff77b1fcbebcdc4f25e8e89c13bb0f7a9faacf3df73609b177b191618c54e9acc795830d75038c1dd59df5b9ef6a2417f97ae3d0d2446f254b0573286b44ad1d9becce62836ac5774ee367f9430aec32c2e801fb244576d5229c41f793cda73ff3a20279ed56d48a6b43527578c1110f9845418c345644d6830a13896b78aaa9be5691ef416bd60c23cc986bc656d553edec366b11c6cb8f2cbfbe86b7ec8aa894b3a202eb1c3f397bf7d71432f3d6a9b9e08a83a5e34f07daf5ccd93fb0cc53e858ad248f5c22c9d1b3400f8f9cff6891376c36d99995be23100809b9c21fa1b58547448ffffb2dabd40a0c2832a78ae2e69915b3fff9f916c90c8f323f516c8dd01fad907ffc3bae3da7d97f6792e3b1442798f49ffb4a99cd11cfdf41779cdd95317f31c7fa1d40405643d711d5838a7d3eef7f1cfc52482835ea666b2572ad1c8eab5ee43b66da3243650005eecfd863b256369d4a4090bed43e40076a82873e4f75e2224e685a7744a6e804a291a90de3535aaae202711515d0a205cb36d3515c2831559a830d5a5b44ca873e038412d9991ed58091e858790afe9486c2a5178fff668ae0b6626e974dbe39a872ce5d73ff402d98e3fb0a3d212dc8128f80fa687f881c7f8e7ce66634bc9d0b99a139029f6a239f721c1fffc1ebc44e80c987434744ac874ea327ffb266b56220fbe9141915d7a9224bf1ff9f0062baa89d71ac8fada6c9b56f773fc3603db4a9c4ce17b399107c22cb550fb4384d21d3f6019da07f549b2b7e2a53a146606a4899c102844f94e0fb2eda7444cbfc426dc0314325637a1939fa911155fefb5308f03d93eebc589f88793555ab7eba27ca96267c7535b763b54bc1558b2f3458debbb01b9283253ca29eb1aaedfb016f16ea9c227723ee8bcb465e15a979c1cadc92a1958a7675175f0bfacd89ec191ec9b749faed14125d36cef980ec671f667be51c79a85916f48482b7e12780e7401a8f31cc0937ae58d2d1b2ecb8b0908810b2fe3f0b8599ef07861fa7e6dcb4aa15dfbdcece67006ac967a791e093e1d49a8bd6a141006042bde0c8bb2c5c6d24e0aecc49914078536d58fae9f773886e18da7f5bf590966848af39a475506a899e888f99797a5e012d6d8406c952429603aab37fd7d8f58178c8e5087ba6d33b83d5605fcdcf32e1d6fb1e4a9a90880a64855c3be0a17fcd265cf2eea09a55067fa6b34ad8c9dfc06ff42faa48c0ea481ed0601d8efc57b08bf13b94daf124da26823c12795db6ce5776c53d08d6b70858a2cb1717b52481ed54768c4b0c64ca6ecb7ddcdda26da268a9942f5dcf7dfd09fe5d54150b090b02d3f93b35435d7c4c9efa548d26e5a6e1c47bc5014a1a6dafc6b8e9b0709f109a359ab6419ca1091bf867241c8cc6d4c0c30163d203c94b629b407691d7fc44f879e0de63425dcf1dc21094364dfb5636985915fc12f542e4f294b943e17a2bc43e6f5b7b17b2939d979cf3ca6cec5b5aa705992ceecf9c42bd8430bd0827723150c6ff782a838353ece53cec4a314ebda4f8bf5635246428940f4613ae5ed136871b7795e136be99b913179899f6858428e2557b59846e3fe757dd7ec07426e5331aeada2fe589cf9096ea6f3848984f3ff0d2c85def7621b4bca50b065abe630fed077a756b53a9e1ebce4dc7f16dfbd3e8495912c628948d3360f09cf6e4bd64712dd7abbbd95cb080392cc4349decbd8d794d96aacfb3dca04777f541c567ecf0d7a0fc5583a089e42caaf9491b60f41686c49db57244ac5d37d5b79b6239311c2875c522ced5d77485cb25823ac77d633293366b828b86a8d39ef77164bcae5dff9c02033197a8530886b54dbdebd9f57f830283fdfcd267caa862a12d66d072df63c324fd7b8380dea93da4bc604247cb9e59f71e6da46116538d0deb7852d9be85f074e608cd795be87051665667902e276c921f8b806bd9714632dff600ba1cd8a3db53b6a086cfcd97bf97f380e8a40eccd228a4c8a883c0fdaf7df06122cd128006b2cdfad2a4b13d1b5d6c796b805720085f819cc3a6eec6311a63cbe3303674053bb0c3f490aa77bd60fcbedbfc4411068a9cf4f1b4d515acb93bee92fb5515482d44991711052d8bf3c5751bdd152d4d1c4abf5cd54678eef0b6d262d45a78a0635def340a98172aace486fb897116c87c349580869f0e7aac0ed45d35e6ae3d4da0bae0a846d21957128974836059cca109e998d258869facd72bd1a438703fc94b91ff83775423cc067b6306a34627ddcfb67f6455292cbf081a3bc84c17b1d542e41f3d6a7377eeca20caba5f1d9e4a938e938662882af53e547eb47b7282ee9cb23867fb2a35b28de99e619a4f23aa43dec681f9f4c31f316405fa00e2ec94d48b3c113c38f9f37ede83bc408dd3dd04ae0b158b4738705e9624ab50b148d445d98ddaee19068c763badd624dd9b095787f8a8d4cfa417c9e54ca5d70a80e5d6a9f6d30a038d1dbc5e9fcf4ccd211f4cd47487cc8470652b7647c3200069671f84c8d4dfd2c63f3b29ecd9f40041e073a5fb0a17c777cf09f468107100525890cf79cc9db955c2cc7182148d4066eeb481ac1fe293d599bfc6f14cd848405530a21727db38cb002fb8ada00e5a506a7cca9cf1d206fdc03ba6d90811f0e4851cfd442e4688bd304a908f4a166d1da6639e4a9cec15763e2e9a598e4e043287fec5dd44271ad3cdba40eff1e1853f29fdf7549530e188c128d12bee59e68ef47c9a94dd3e8cf578b982bb74f8301958cec13a148e3032d6e7e36a52363c1faf01f18899b1bc3f8ca1dc44e6c3cb279ac196f5600f15a7b7e529ab103a5ef8c0b9bcb2b812db11a5de7415d448f6b6f0e7ebdf661791d60f56111b495b3464ad21936b9fcebb25c995cab10dd900beec34b84687c269ef3bfb3d5d514f40eea742e65829b3046b0afa0cb4a5a3112a51128ff71a0fe2c2e6dc47f0e785eaba72abb3f4e093db73a09359ed216765690f56e0f218b8d25088b8306869c13ec3532c8c974f73837255731e414218c73a13fbafbd2350644eeacfe5d1929ef90898fadbac6c247d62a583df45f746b74abf39894bc396ce5da7726b8bba8c328eb783ab9eb47c81f5114f066ea92f3f326564d686619ba27255a2c80a537b0efefebd8613fd0145877585bd06742ce95f5f36a798fc4196e952e72c48113823b73704d17f3b51fca3a7a0f75a15862ca504c582ef85133de648c49a984d73dbe722fba3ab66580d5fdaf5c13e60d0d2e0ebbacc963fee10b7d1b3318df905079926a8ffbbcfe994e5c61ffdf17746497f70529fd561f1fd0f9bd3feb6ea8bedefa633c7caba6e7c5382c8fe64a52ee96b8fc0f9bd690a1b68637b3dfdce7aa3c673b09c1661a651213e2d06bea10ca65c084ec31bfa0fe5698db8486e494fcff30a62f3e2f893dec3f1265a89dba3c3efccfa986ddb5c6b3a76b7f89629465a75e01cbe89523386091465f6bbb397f1135823ee2ba6c0678b597f746aa07ded582e2c94db483840b717efa8c2a44eb4571cdcba121a4650e4ddeb92f34d62616ce413e896a0d7e51e156677b020baf9c81d17915e2486ef32cd600ace1474dc1d122eb5b5ada8aaff80b80d819992132456bae3231912d5bf60e610e1fff697ed6c698df5efabc5979c8fca8d3ffa1ef463c1b1736b96b6fd83b3bd308ff8a6b17cb2ddd0467c64bce4a0ac7cb3f6d05ddbde8aa22c0dbef60ee46bcdf07a423aa96bad4ab7112eb3929d86c16c98d2c953c6d89d64d57a607744e871c7bf077ba8b787625f056c7c4a8b11471cd764ad4972a93af6c6c79b5d2dd598e40d3dd89bcfd389b478798234794aff1d108d4ec2c3843610cb4bf160cbcedf722a585139baa54394fe1eedb8fec2974eb4ee658828ce947a3da6a9273e733d226229feea32811ccc668829b8870806357d5a3f525fa163ff802a3426a8ca07c2dcb0cf26f7c9bcff6034c13052fc89b393dd02f0b5fc2c3f3841f17c67bbac2078d443ace29d9ba7832936edc0d54b944b84aa4c0dc5029163f384a9310a9e795e65d4df11f64335bcf065d37d4d4617b5ff4a16d599ea0196163fa42e504bced1bf8e4e45c06481fb9bcf8d39e45ec2862f71e1d6f07da27a82c370885d767327bb4e5a4c964e858c91ba26553a6a07f8d510f86fbbe226efb628afea890489f70a55368beadab0aba3b2dbe52b45ac74ccea842e92c8ae6b464fc96f3b0b8bc90012929db77ada0617e3bbcb09ce6ebb40173744e55990879ddcaabdcc420a6a101d05158f57fa54c2a9eab69fa946824a12232db32df8e9f354656447939822dc96abf9dff9772470297ebd59787e2b93bc56f78bfbea76c619ef3657eb4edb3c55b65aaefae51477a06b03ede622920b6b23f1dab99e59958885c4e95fab368e45eced88b402f7fd75539b11dbcb0218ebb414aae103b5fcd2a881d652bdc29f26a119d59944a37c0752a24be76d3346f0495f857fcae62d8493a56f70a4400c562ddba6dfbd9fb8e5b88ecb4ccd500f6bb952d097ad07a71f26b27e2000a41346a7a7825ecc24c873782f8ed400668c0c28c8a2f67f2dfa90563b728900802f0f32facbb41ef979346bca4f2b40a03ad2ffb9fea126b7d78186bce2f610c84987bfa89f24b832e6b0f4360dd9ca7d2df4d7c9c6ede63fa05d314391503d1c79720dbbf8a95fcf88747d9475a44c6397ce912a9b69dbe1b548ce7cc986afbe3ee11abac24452da229b021bfbe85badce996168f2d56790ab41c2a2fae27299423fb9c397c560ba6b0919a5dccd879fc967d41abdb6b8e905cb600f5400e987bbc1c920ed246723473e3813290123e9aab23b689436c0760c86e30bf9a0b6720aaf6521b94470938fa89bcef808e40e8d5b3e69e7958cb87392c2c2b60b1d1230b20e0490bd77f3483bb9b9b1c6f22b5e6f48c2b4ecd5f01a4aa8281e38aeb6360b1af3e2280b6c20dd523225c6da63c38de1b08d590723948a535f579c487e5a38ad0eb0af48ec79ace8372d835a9df0c6d851dcdb1b2798182244f8e431456cf88e658a08f0f8bf0f156b1b8e9ecb641b58ffac8b2d36eed2dac5e272467e3d222f3fd7adf884aa8791775b0ed81dcc6abb0f86ccbb52ea94baea98e947129fc2b4e9a87fea27a539e9a53f2398d747b36224d29fe4b18e88640e8eec7f0d19a03aad83a3eeeef9153e891953cf68300424aca48ceaaab75a8e2b5fa8c3423c052dd7cdb02555653131b63792f412cb06794d808e17555f3ebf11e2bbd88bbee40bd0a0b19d2ab70e6ed65b6aceaeae9d0ec4c8de047564d20a8bf245825a5a445275fb158592be068d2eeed6e2f0f0d567129ced737bb6c4183d55464dd69685606bc428d05aa4751e4caa97e14c3c26b886f53304714d9265dfd53dd99f4b3066a8993fe2c6d07b7fabe546a8038efe4029bf8fdb78849a5f96de98520472bdd033ef73d256a5c0f77c963e66858f6d444095a8637627989aaddde7001379a44aa8bb127c53b17ec1595560c018580d5d52e9d71b689dde71afaab8f01e6e10b4a69226712162ab070dcab3961304ca70e8b6b00d69bb55c8d13d607b97c5fd0d22e45c10c42a2b3b058cb89a7db77c506a8eb98a7a9a5b04e377f3608e92adb242b267ed1940f1c61c55f038b237591ed3df01e85f912e37a36b6c46dec52f66888b61313bbabce2c62323ac4b3b3da015ae397d8aa96c1b77abec975e0a0d081ad9c7dced53c7225596e7bd358c904a21881cea14545c75757e50d64177da2e54aa242499697392d2dde50bd1d5d0b9e9d4ad2dbfc3d07787955e4ec64b44e86484ec3c97da624ab4bd5af13bef0b113ea6274bbdd0fadd61ecb1ad8aeacdd58ecfb11ead453994ba67de18eda5814af281ceb32c4b43fcf480eacf948770ced7a2425ff75e14fc31a1258379a94d028dcad2f7f5359a3b3e096ee45813a04330fd87b5f28300ca0d8bca9d6e188853fc9e74d1b791e07e48775ea264cf55347ec612062576589dda95364afe032a819ef79687aed3eec5513a83ddbd83f522059abe14cd44753b52c4926a9672793543c16d9a0095928a2775b7053c0f178294f1c90080baf72cb15324c68b12dd6339971da05074da7beed3f6fc16ebca5e04bce5086492111aea88f4bb1ca6bcf585ec1e4a7db69561a52b31e9e3d06c32e69392ee8e921d5d073aff322e62439fd0b877aa3236a4b44909befeb9fad487c3e69594bec44de15b4c2ebe687989a9b4901d7cf73ab0acd90f9d37014bf60a11b424dc35095cd80f538484c19ef38c95e12e13424bb40e132865a5f206b06fba8cbccc096f5088cbf93f87b7442e45d4afebff0bcb24aafef78f69a51539d749dbe6fecebdedd5beb573440e5a884d1c89705f4136b4a59731680a88f8953031abcc77118461cefcfdc20d2b36ba7c3ed6bf94d5e57a42bc3d32907604691b4d8637bd05af6c69b5a63f9a49c2c1b110a7c5ac471b4784230fcf80dc33721d54d1b71758e219652bd3c36113404ea4a983126e978d4fdf3b645a1cac083126eaa3d70a3d70a3d70a3d70a3d70a3d70a4cccccccccccccccccccccccccccccccd80000000000000000000000000000000a0000000000000000000000000000000c8000000000000000000000000000000fa0000000000000000000000000000009c400000000000000000000000000000c3500000000000000000000000000000f424000000000000000000000000000098968000000000000000000000000000bebc2000000000000000000000000000ee6b28000000000000000000000000009502f900000000000000000000000000ba43b740000000000000000000000000e8d4a5100000000000000000000000009184e72a000000000000000000000000b5e620f4800000000000000000000000e35fa931a000000000000000000000008e1bc9bf040000000000000000000000b1a2bc2ec50000000000000000000000de0b6b3a7640000000000000000000008ac7230489e800000000000000000000ad78ebc5ac6200000000000000000000d8d726b7177a80000000000000000000878678326eac90000000000000000000a968163f0a57b4000000000000000000d3c21bcecceda100000000000000000084595161401484a00000000000000000a56fa5b99019a5c80000000000000000cecb8f27f4200f3a0000000000000000813f3978f89409844000000000000000a18f07d736b90be55000000000000000c9f2c9cd04674edea400000000000000fc6f7c40458122964d000000000000009dc5ada82b70b59df020000000000000c5371912364ce3056c28000000000000f684df56c3e01bc6c7320000000000009a130b963a6c115c3c7f400000000000c097ce7bc90715b34b9f100000000000f0bdc21abb48db201e86d4000000000096769950b50d88f41314448000000000bc143fa4e250eb3117d955a000000000eb194f8e1ae525fd5dcfab080000000092efd1b8d0cf37be5aa1cae500000000b7abc627050305adf14a3d9e40000000e596b7b0c643c7196d9ccd05d00000008f7e32ce7bea5c6fe4820023a2000000b35dbf821ae4f38bdda2802c8a800000e0352f62a19e306ed50b2037ad2000008c213d9da502de454526f422cc340000af298d050e4395d69670b12b7f410000daf3f04651d47b4c3c0cdd765f11400088d8762bf324cd0fa5880a69fb6ac800ab0e93b6efee00538eea0d047a457a00d5d238a4abe9806872a4904598d6d88085a36366eb71f04147a6da2b7f864750a70c3c40a64e6c51999090b65f67d924d0cf4b50cfe20765fff4b4e3f741cf6d82818f1281ed449fbff8f10e7a8921a4a321f2d7226895c7aff72d52192b6a0dcbea6f8ceb02bb399bf4f8a69f764490fee50b7025c36a0802f236d04753d5b49f4f2726179a224501d762422c946590c722f0ef9d80aad6424d3ad2b7b97ef5f8ebad2b84e0d58bd2e0898765a7deb29b934c3b330c857763cc55f49f88eb2fc2781f49ffcfa6d53cbf6b71c76b25fbf316271c7fc3908a8bef464e3945ef7a97edd871cfda3a5697758bf0e3cbb5acbde94e8e43d0c8ec3d52eeed1cbea317ed63a231d4c4fb274ca7aaa863ee4bdd945e455f24fb1cf88fe8caa93e74ef6ab975d6b6ee39e436b3e2fd538e122b44e7d34c64a9c85d4460dbbca87196b61690e40fbeea1d3a4abc8955e946fe31cdb51d13aea4a488dd6babab6398bdbe41e264589a4dcdab14c696963c7eed2dd18d7eb76070a08aecfc1e1de5cf543ca2b0de65388cc8ada83b25a55f43294bcbdd15fe86affad91249ef0eb713f39ebe8a2dbf142dfcc7ab6e3569326c784337acb92ed9397bf99649c2c37f07965404d7e77a8f87daf7fbdc33745ec97be90686f0ac99b4e8dafd69a028bb3ded71a3a8acd7c0222311bcc40832ea0d68ce0cd2d80db02aabd62bf50a3fa490c3019083c7088e1aab65db792667c6da79e0faa4b8cab1a1563f52577001b891185938cde6fd5e09abcf26ed4c0226b55e6f8680b05e5ac60b6178544f8158315b05b4a0dc75f1778e39d6696361ae3db1c721c913936dd571c84c03bc3a19cd1e38e9fb5878494ace3a5f04ab48a04065c7239d174b2dcec0e47b62eb0d64283f9c76c45d1df942711d9a3ba5d0bd324f8394f5746577930d6500ca8f44ec7ee364799968bf6abbe85f207e998b13cf4e1ecbbfc2ef456ae276e89e3fedd8c321a67eefb3ab16c59b14a2c5cfe94ef3ea101e95d04aee3b80ece5bba1f1d158724a12bb445da9ca61281f2a8a6e45ae8edc97ea1575143cf97226f52d09d71a3293bd924d692ca61be758593c2626705f9c56b6e0c377cfa2e12e6f8b2fb00c77836ce498f455c38b997a0b6dfb9c0f9564478edf98b59a373fec4724bd4189bd5eacb2977ee300c50fe758edec91ec2cb657df3d5e9bc0f653e12f2967b66737e3ed8b865b215899f46cbd79e0d20082ee74ae67f1e9aec07187ecd8590680a3aa11da01ee641a708de9e80e6f4820cc9495884134fe908658b23109058d147fdcddaa51823e34a7eedebd4b46f0599fd415d4e5e2cdc1d1ea966c9e18ac7007c91a850fadc09923329e03e2cf6bc604ddb0a6539930bf6bff4584db8346b786151ccfe87f7cef46ff16e612641865679a6381f14fae158c5f6e4fcb7e8f3f60c07ea26da3999aef7749e3be5e330f38f09dcb090c8001ab551c5cadf5bfd3072cc5fdcb4fa002162a6373d9732fc7c8f7f69e9f11c4014dda7e2867e7fddcdd9afac646d63501a1511db281e1fd541501b8f7d88bc24209a5651f225a7ca91a42269ae757596946075f3375788de9b06958c1a12d2fc39789370052d6b1641c83aef209787bb47d6b84c0678c5dbd23a49a9745eb4d50ce6332f840b7ba963646e0bd176620a501fbffb650e5a93bc3d898ec5d3fa8ce427affa3e51f138ab4cebe93ba47c980e98cdfc66f336c36b10137b8a8d9bbe123f017b80b0047445d4184e6d3102ad96cec1da60dc059157491e59043ea1ac7e4139287c89837ad68db2fb454e4a179dd187729babe4598c311fbe16a1dc9d8545e94f4296dd6fef3d67a8ce2529e2734bb1d1899e4a65f58660cb01ae745b101e9e45ec05dcff72e7f8fdc21a1171d42645d76707543f4fa1f73899504ae72497eba6a06494a791c53a8abfa45da0edbde690487db9d17636892d6f8d7509292d60345a9d2845d3c42b6865b86925b9bc5c20b8a2392ba45a9b2a7f26836f282b7328e6cac7768d7141ed1ef0244af2364ff3207d795430cd9268335616aed761f1f7f44e6bd49e807b8a402b9c5a8d3a6e75f16206c9c6209a6cd036837130890a136dba887c37a8c0f802221226be55a64c2494954da2c9789a02aa96b06deb0fdf2db9baa10b7bd6cc83553c5c8965d3d6f92829494e5acc7fa42a8b73abbf48ccb772339ba1f17f99c69a97284b578d7ff2a760414536efbc38413cf25e2d70dfef5138519684abaf46518c2ef5b8cd17eb258665fc25d6998bf2f79d5993802ef2f773ffbd97a61beeefb584aff8603aafb550ffacfd8faeeaaba2e5dbf678495ba2a53f983cf38952ab45cfa97a0b2dd945a747bf26183ba756174393d88df94f971119aeef9e4e912b9d1478ceb177a37cd5601aab85d91abb422ccb812eeac62e055c10ab33ab616a12b7fe617aa577b986b314d6009e39c49765fdf9d94ed5a7e85fda0b80b8e41ade9fbebc27d14588f13be847307b1d219647ae6b31c596eb2d8ae258fc8de469fbd99a05fe36fca5f8ed9aef3bb8aec23d680043bee25de7bb9480d5854ada72ccc20054ae9af561aa79a10ae6ad910f7ff28069da41b2ba1518094da0487aa9aff7904228690fb44d2f05d0842a99541bf57452b28353a1607ac744a53d3fa922f2d1675f242889b8997915ce8847c9b5d7c2e09b769956135febada11a59bc234db398c2543fab9837e699095cf02b2c21207ef2e94f967e45e03f4bb8161afb94b44f57d1d1be0eebac278f5a1ba1ba79e1632dc6462d92a69731732ca28a291859bbf937d7b8f7503cfdcfefcb2cb35e702af785cda735244c3d43e9defbf01b061adab3a0888136afa64a7c56baec21c7a1916088aaa1845b8fdd0f6c69a72a3989f5b8aad549e57273d459a3c2087a63f639936ac54e2f678864bc0cb28a98fcf3c7f84576a1bb416a7ddf0fdf2d3f3c30b9f656d44a2a11c51d5969eb7c47859e7439f644ae5a4b1b325bc4665b596706114873d5d9f0dde1feeeb57ff22fc0c7959a90cb506d155a7ea9316ff75dd87cbd809a7f12442d588f2b7dcbf5354e9bece0c11ed6d538aeb2fe5d3ef282a242e818f1668c8a86da5fa8fa475791a569d10f96e017d694487bcb38d92d760ec445537c981dcc395a9ace070f78d3927556a85bbe253f47b14178c469ab843b8956293956d7478ccec8eaf58416654a6babb387ac8d1970027b2db2e51bfe9d0696a06997b05fcc0319e88fcf317f22241e2441fece3bdf81f03ab3c2fddeeaad25ad527e81cad7626c3d60b3bd56a5586f18a71e223d8d3b07485c7056562757456f6872d5667844e49a738c6bebb12d16cb428f8ac016561dbd106f86e69d785c7e13336d701beba5282a45b450226b39cecc0024661173473a34d721642b0608427f002d7f95d0190cc20ce9bd35c78a531ec038df7b441f4ff290242c83396ce7e67047175a152719f79a169bd203e410f0062c6e984d386c75809c42c684dd152c07b78a3e60868f92e0c3537826145a7709a56ccdf8a829bbcc7a142b17ccb88a66076400bb691c2abf989935ddbfe6acff893d00ea435f356f7ebf83552fe0583f6b8c4124d4398165af37b2153dec3727a337a8b704abe1bf1b059e9a8d6744f18c0592e4c5ceda2ee1c7064130c1162def06f79df739485d4d1c63e8be78addcb5645ac2ba8b9a74a0637ce2ee16d953e2bd7173692e8111c87c5c1ba99c8fa8db6ccdd0437910ab1d4db9914a01d9c9892400a22a2b54d5e4a127f59c82503beb6d00cab4be2a0b5dc971f303a2e44ae64840fd61d8da471a9de737e245ceaecfed289e5d2b10d8e1456105dad7425a83e872c5f47dd50f1996b947518d12f124e28f777198a5296ffe33cc92f82bd6b70d99aaa6face73cbfdc0bfb7b636cc64d1001550bd8210befd30efa5a3c47f7e05401aa4e8714a775e3e95c7865acfaec34810a71a8d9d1535ce3b3967f1839a741a14d0dd31045a8341ca07c1ede48111209a05083ea2b892091e44d934aed0aab460432a4e4b66b68b65d60f81da84d5617853fce1de40642e3f4b936251260ab9d668e80d2ae83e9ce78f3c1d72b7c6b426019a1075a24e4421730b24cf65b8612f81fc94930ae1d529cfcdee033f26797b627fb9b7cd9a4a7443c169840ef017da3b19d412e0806e88aa58e1f289560ee864ec491798a08a2ad4ef1a6f2bab92a27e2f5b5d7ec8acb58a2ae10af696774b1db9991a6f3d6bf1765acca6da1e0a8ef29bff610b0cc6edd3f17fd090a58d32af3eff394dcff8a948eddfc4b4cef07f5b095f83d0a1fb69cd94abdaf101564f98ebb764c4ca7a4440f9d6d1ad41abe37f1ea53df5fd18d551384c86189216dc5ed92746b9be2f8552c32fd3cf5b4e49bb4b7118682dbb66a773fbc8c33221dc2a1e4d5e82392a405150fabaf3feaa5334a8f05b1163ba6832d29cb4d87f2a7400eb2c71d5bca9023f8743e20e9ef511012df78e4b2bd342cf6914da9246b2554168bab8eefb6409c1a1ad089b6c2f7548eae9672aba3d0c320a184ac2473b529b1da3c0f568cc4f3e8c9e5d72d90a2741e8865899617fb18717e2fa67c7a658892aa7eebfb9df9de8dddbb901b98feeab7d51ea6fa85785631552a74227f3ea5658533285c936b35ded53a88958f87275fa67ff273b84603568a892abaf368f137d01fef10a657842c2d2b7569b0432d858213f56a67f6b29b9c3b29620e29fc73a298f2c501f45f428349f3ba91b47b8fcb3f2f7642717713241c70a936219a73fe0efb53d30dd4d7ed238cd383aa01109ec95d1463e8a506f4363804324a40aac67bb4597ce2ce48b143c6053edcd0d5f81aa16fdc1b81dadd94b7868e94050a9b10a4e5e9913128ca7cf2b4191c8326c1d4ce1f63f57d72fd1c2f611f63a3f0f24a01a73cf2dccfbc633b39673c8cec976e41088617ca01d5be0503e085d813bd49d14aa79dbc824b2d8644d8a74e18ec9c459d51852ba2ddf8e7d60ed1219e93e1ab8252f33b45cabb90e5c942b503b8da1662e7b00a173d6a751f3b936243e7109bfba19c0c9d0cc512670a783ad4906a617d450187e227fb2b80668b24c5b484f9dc9641e9dab1f9f660802dedf6e1a63853bbd264515e7873f8a03969738d07e33455637eb2db0b487b6423e1e8b049dc016abc5e5f91ce1a9a3d2cda62dc5c5301c56b75f77641a140cc7810fb89b9b3e11b6329baa9e904c87fcb0a9dac2820d9623bf429546345fa9fbdcd44d732290fbacaf133a97c177947ad4095867f59a9d4bed6c049ed8eabcccc485da81f301449ee8c705c68f256bfff5a74d226fc195c6a2f8c73832eec6fff311183585d8fd9c25db7c831fd53c5ff7eaba42e74f3d032f525ba3e7ca8b77f5e55cd3a1230c43fb26f28ce1bd2e55f35eb80444b5e7aa7cf857980d163cf5b81b3a0555e361951c366d7e105bcc332621fc86ab5c39fa634408dd9472bf3fefaa7fa856334878fc150b14f98f6f0feb9519c935e00d4b9d8d26ed1bf9a569f33d3c3b8358109e84f070a862f80ec4700c8f4a642e14c6262c8cd27bb612758c0fa98e7e9cccfbd7dbd8038d51cb897789cbf21e44003acdd2ce0470a63e6bd56c3eeea5d50049814781858ccfce06cac7495527a5202df0ccb0f37801e0c43ebc8baa718e68396cffdd30560258f54e6bae950df20247c83fd47c6b82ef32a206991d28b7416cdd27e4cdc331d57fa5441b6472e511c81471de0133fe4adf8e952e3d8f9e563a198e558180fddd97723a68e679c2f5e44ff8f570f09eaa7ea7648"
.L808:
    .string "-inf"
.L809:
    .string "inf"
.L810:
    .string "-nan"
.L811:
    .string "nan"
.L857:
    .string "(null)"
.L858:
    .string "\n"
.L867:
    .string "file-write"
.L873:
    .string "mkdir-p"
.L882:
    .string ""
.L883:
    .string "/"
.L898:
    .string "/"
.L918:
    .string ""
.L920:
    .string "list-zyl-files"
.L921:
    .string ".zyl"
.L923:
    .string "list-files"
.L924:
    .string "list-files"
.L930:
    .string "[?2004l[0m"
.L939:
    .string "term-write"
.L944:
    .string "union-find table"
.L957:
    .string "zyl: mem-read: null pointer\n"
.L959:
    .string "zyl: mem-write: null pointer\n"
.L961:
    .string "cstr-byte-set"
.L964:
    .string "ZYL_REGIONS"
.L967:
    .string "ZYL_REGION_POISON"
.L971:
    .string "E_CODEGEN_BUFFER_LIMIT: codegen buffer limit exceeded"
.L978:
    .string "words"
.L980:
    .string "aes block"
.L984:
    .string "aes key"
.L985:
    .string "words"
.L986:
    .string "words"
.L987:
    .string "words"
.L991:
    .string "/dev/urandom"
.L995:
    .string "words"
.L996:
    .string "random-words"
.L998:
    .string "zyl: invalid callee address 0x"
.L999:
    .string ""
.L1000:
    .string "\n"
.L1053:
    .string "0123456789abcdef"
.L1056:
    .string "zyl: ffi call to invalid address 0x"
.L1057:
    .string ""
.L1058:
    .string "\n"
.L1076:
    .string "zyl: ffi call with "
.L1077:
    .string " arguments (max 6)\n"
.L1079:
    .string "zyl_ffi_pin"
.L1080:
    .string "zyl_ffi_unpin"
.L1081:
    .string "zyl_actor_init"
.L1082:
    .string "zyl_actor_is_alive"
.L1083:
    .string "zyl_actor_spawn"
.L1084:
    .string "zyl_chan_new"
.L1085:
    .string "zyl_chan_recv"
.L1086:
    .string "zyl_chan_rx"
.L1087:
    .string "zyl_chan_send"
.L1088:
    .string "zyl_chan_tx"
.L1089:
    .string "zyl_actor_wait"
.L1090:
    .string "zyl_actor_wait_all"
.L1091:
    .string "zyl_aes_encrypt_block"
.L1092:
    .string "zyl_aesni_available"
.L1093:
    .string "zyl_align_check"
.L1094:
    .string "zyl_arena_alloc"
.L1095:
    .string "zyl_arena_alloc_zeroed"
.L1097:
    .string "zyl_arena_capacity"
.L1098:
    .string "zyl_arena_create"
.L1099:
    .string "zyl_arena_destroy"
.L1100:
    .string "zyl_arena_reset"
.L1101:
    .string "zyl_arena_used"
.L1102:
    .string "zyl_arg_str"
.L1103:
    .string "zyl_argc"
.L1104:
    .string "zyl_atomic_add"
.L1105:
    .string "zyl_atomic_cas"
.L1106:
    .string "zyl_atomic_fetch_add"
.L1107:
    .string "zyl_atomic_load"
.L1108:
    .string "zyl_atomic_max"
.L1109:
    .string "zyl_atomic_min"
.L1110:
    .string "zyl_atomic_store"
.L1111:
    .string "zyl_atomic_sub"
.L1112:
    .string "zyl_blake3_file_hex"
.L1114:
    .string "zyl_blake3_hex"
.L1115:
    .string "zyl_byte_slice"
.L1116:
    .string "zyl_byte_slice_sub"
.L1117:
    .string "zyl_bytebuf_append"
.L1118:
    .string "zyl_bytebuf_atomic_add"
.L1119:
    .string "zyl_bytebuf_atomic_cas"
.L1120:
    .string "zyl_bytebuf_atomic_fetch_add"
.L1121:
    .string "zyl_bytebuf_atomic_load"
.L1122:
    .string "zyl_bytebuf_atomic_max"
.L1123:
    .string "zyl_bytebuf_atomic_min"
.L1124:
    .string "zyl_bytebuf_atomic_store"
.L1125:
    .string "zyl_bytebuf_atomic_sub"
.L1126:
    .string "zyl_bytebuf_cap"
.L1127:
    .string "zyl_bytebuf_len"
.L1128:
    .string "zyl_bytebuf_blake3_hex"
.L1129:
    .string "zyl_bytebuf_new"
.L1130:
    .string "zyl_bytebuf_ptr"
.L1132:
    .string "zyl_call0"
.L1133:
    .string "zyl_call1"
.L1134:
    .string "zyl_call2"
.L1135:
    .string "zyl_call3"
.L1136:
    .string "zyl_call4"
.L1137:
    .string "zyl_call5"
.L1138:
    .string "zyl_call6"
.L1139:
    .string "zyl_call_argv"
.L1140:
    .string "zyl_call_on_big_stack"
.L1141:
    .string "zyl_cc_compile"
.L1142:
    .string "zyl_cc_compile_log"
.L1143:
    .string "zyl_chdir"
.L1144:
    .string "zyl_cpuid_features"
.L1145:
    .string "zyl_cstr_byte_at"
.L1146:
    .string "zyl_cstr_byte_set"
.L1147:
    .string "zyl_cstr_concat"
.L1149:
    .string "zyl_cstr_count_newlines"
.L1150:
    .string "zyl_cstr_decode"
.L1151:
    .string "zyl_cstr_cmp"
.L1152:
    .string "zyl_cstr_eq"
.L1153:
    .string "zyl_cstr_from_byte"
.L1154:
    .string "zyl_cstr_from_int"
.L1155:
    .string "zyl_cstr_key_matches"
.L1156:
    .string "zyl_div_magic"
.L1157:
    .string "zyl_div_shift"
.L1158:
    .string "zyl_array_copy"
.L1159:
    .string "zyl_view_ok"
.L1160:
    .string "zyl_view_byte"
.L1161:
    .string "zyl_view_cmp"
.L1162:
    .string "zyl_view_find"
.L1163:
    .string "zyl_view_copy"
.L1164:
    .string "zyl_cstr_last_newline"
.L1166:
    .string "zyl_cstr_len"
.L1167:
    .string "zyl_cstr_of_word"
.L1168:
    .string "zyl_float_bits"
.L1169:
    .string "zyl_float_of_bits"
.L1170:
    .string "zyl_word_load"
.L1171:
    .string "zyl_word_store"
.L1172:
    .string "zyl_ptr_add"
.L1173:
    .string "zyl_ptr_cstr"
.L1174:
    .string "zyl_ffi_addr"
.L1175:
    .string "zyl_cstr_sanitize"
.L1176:
    .string "zyl_cstr_sub"
.L1177:
    .string "zyl_cstr_substr"
.L1178:
    .string "zyl_cstr_to_int"
.L1179:
    .string "zyl_cstr_to_int_base"
.L1180:
    .string "zyl_diag_json"
.L1181:
    .string "zyl_diag_json_set"
.L1183:
    .string "zyl_dirname_cstr"
.L1184:
    .string "zyl_attr_clear"
.L1185:
    .string "zyl_attr_copy"
.L1186:
    .string "zyl_attr_get"
.L1187:
    .string "zyl_attr_set"
.L1188:
    .string "zyl_ensure_arenas"
.L1189:
    .string "zyl_exec_cmd"
.L1190:
    .string "zyl_f_add"
.L1191:
    .string "zyl_f_cmp"
.L1192:
    .string "zyl_f_div"
.L1193:
    .string "zyl_f_error"
.L1194:
    .string "zyl_f_mul"
.L1195:
    .string "zyl_f_of_int"
.L1196:
    .string "zyl_f_parse"
.L1197:
    .string "zyl_f_rem"
.L1198:
    .string "zyl_f_sub"
.L1200:
    .string "zyl_f_text"
.L1201:
    .string "zyl_f_to_int"
.L1202:
    .string "zyl_ffi_lookup"
.L1203:
    .string "zyl_ffi_timed"
.L1204:
    .string "zyl_ffi_timed_argv"
.L1205:
    .string "zyl_file_close_c"
.L1206:
    .string "zyl_exit"
.L1207:
    .string "zyl_read_line"
.L1208:
    .string "zyl_file_open_c"
.L1209:
    .string "zyl_file_read_c"
.L1210:
    .string "zyl_file_write_c"
.L1211:
    .string "zyl_fnmap_get"
.L1212:
    .string "zyl_fnmap_put"
.L1213:
    .string "zyl_fnmap_reset"
.L1214:
    .string "zyl_fresh_id"
.L1215:
    .string "zyl_getcwd"
.L1217:
    .string "zyl_getenv"
.L1218:
    .string "zyl_contract_warn"
.L1219:
    .string "zyl_err_is"
.L1220:
    .string "zyl_list_zyl_files"
.L1221:
    .string "zyl_list_files"
.L1222:
    .string "zyl_load_n"
.L1223:
    .string "zyl_load_n_signed"
.L1224:
    .string "zyl_store_n"
.L1225:
    .string "zyl_global_get"
.L1226:
    .string "zyl_global_put"
.L1227:
    .string "zyl_global_ready"
.L1228:
    .string "zyl_global_clear"
.L1229:
    .string "zyl_iglobal_get"
.L1230:
    .string "zyl_iglobal_put"
.L1231:
    .string "zyl_iglobal_ready"
.L1232:
    .string "zyl_iglobal_clear"
.L1234:
    .string "zyl_repl_global_get"
.L1235:
    .string "zyl_repl_global_set"
.L1236:
    .string "zyl_uf_id"
.L1237:
    .string "zyl_uf_reset"
.L1238:
    .string "zyl_uf_new"
.L1239:
    .string "zyl_uf_find"
.L1240:
    .string "zyl_uf_union"
.L1241:
    .string "zyl_uf_raise"
.L1242:
    .string "zyl_uf_level"
.L1243:
    .string "zyl_regions_enabled"
.L1244:
    .string "zyl_words_new"
.L1245:
    .string "zyl_words_alloc"
.L1246:
    .string "zyl_words_alloc_r"
.L1247:
    .string "zyl_words_len"
.L1248:
    .string "zyl_words_get"
.L1249:
    .string "zyl_words_set"
.L1250:
    .string "zyl_words_view"
.L1251:
    .string "zyl_words_view_r"
.L1252:
    .string "zyl_smap_has"
.L1254:
    .string "zyl_smap_get_or"
.L1255:
    .string "zyl_array_new"
.L1256:
    .string "zyl_vec_alloc"
.L1257:
    .string "zyl_vec_alloc_r"
.L1258:
    .string "zyl_array_cap"
.L1259:
    .string "zyl_array_filled"
.L1260:
    .string "zyl_array_get"
.L1261:
    .string "zyl_array_set"
.L1262:
    .string "zyl_attrh_new"
.L1263:
    .string "zyl_attrh_set"
.L1264:
    .string "zyl_attrh_get_or"
.L1265:
    .string "zyl_attrh_has"
.L1266:
    .string "zyl_attrh_copy"
.L1267:
    .string "zyl_attrh_clear"
.L1268:
    .string "zyl_ref_new"
.L1269:
    .string "zyl_ref_get"
.L1270:
    .string "zyl_ref_set"
.L1271:
    .string "zyl_getenv_str"
.L1273:
    .string "zyl_strbuf_new"
.L1274:
    .string "zyl_strbuf_new_r"
.L1275:
    .string "zyl_strbuf_str"
.L1276:
    .string "zyl_cstr_escapes_ok"
.L1277:
    .string "zyl_heap_alloc"
.L1278:
    .string "zyl_ralloc"
.L1279:
    .string "zyl_region_enter"
.L1280:
    .string "zyl_region_exit"
.L1281:
    .string "zyl_region_free"
.L1282:
    .string "zyl_region_scope_enter"
.L1283:
    .string "zyl_region_live_bytes"
.L1284:
    .string "zyl_heap_block_p"
.L1285:
    .string "zyl_heap_swap"
.L1286:
    .string "zyl_int_text"
.L1287:
    .string "zyl_itest_add"
.L1288:
    .string "zyl_itest_count"
.L1289:
    .string "zyl_itest_fn"
.L1291:
    .string "zyl_itest_name"
.L1292:
    .string "zyl_itest_outcome"
.L1293:
    .string "zyl_itest_fail"
.L1294:
    .string "zyl_itest_reset"
.L1295:
    .string "zyl_itest_start"
.L1296:
    .string "zyl_itest_summary"
.L1297:
    .string "zyl_json_quote"
.L1298:
    .string "zyl_load_byte"
.L1299:
    .string "zyl_load_byte_signed"
.L1300:
    .string "zyl_mangle_key"
.L1301:
    .string "zyl_mem_alloc"
.L1302:
    .string "zyl_mem_free"
.L1303:
    .string "zyl_mem_read"
.L1304:
    .string "zyl_mem_write"
.L1305:
    .string "zyl_mkdir_p"
.L1306:
    .string "zyl_mlock"
.L1307:
    .string "zyl_panic"
.L1309:
    .string "zyl_path_exists"
.L1310:
    .string "zyl_pin_alloc"
.L1311:
    .string "zyl_print_float"
.L1312:
    .string "zyl_print_int"
.L1313:
    .string "zyl_print_str"
.L1314:
    .string "zyl_random_fill"
.L1315:
    .string "zyl_random_words"
.L1316:
    .string "zyl_run_bin"
.L1317:
    .string "zyl_session_arena"
.L1318:
    .string "zyl_smap_clear"
.L1319:
    .string "zyl_smap_get"
.L1320:
    .string "zyl_smap_global"
.L1321:
    .string "zyl_smap_new"
.L1322:
    .string "zyl_smap_put"
.L1323:
    .string "zyl_source_path"
.L1324:
    .string "zyl_source_register"
.L1326:
    .string "zyl_span_col"
.L1327:
    .string "zyl_span_copy"
.L1328:
    .string "zyl_span_file"
.L1329:
    .string "zyl_span_line"
.L1330:
    .string "zyl_span_line_text"
.L1331:
    .string "zyl_span_off"
.L1332:
    .string "zyl_span_snippet"
.L1333:
    .string "zyl_span_snippet_col"
.L1334:
    .string "zyl_span_offset_at"
.L1335:
    .string "zyl_span_set"
.L1336:
    .string "zyl_store_byte"
.L1337:
    .string "zyl_store_byte_signed"
.L1338:
    .string "zyl_str_append"
.L1339:
    .string "zyl_str_append_capped"
.L1340:
    .string "zyl_sym_escape"
.L1341:
    .string "zyl_system_cmd"
.L1343:
    .string "zyl_term_flush"
.L1344:
    .string "zyl_term_height"
.L1345:
    .string "zyl_term_is_tty"
.L1346:
    .string "zyl_term_raw_off"
.L1347:
    .string "zyl_term_raw_on"
.L1348:
    .string "zyl_term_read_byte"
.L1349:
    .string "zyl_term_read_byte_timeout"
.L1350:
    .string "zyl_term_width"
.L1351:
    .string "zyl_term_write"
.L1352:
    .string "zyl_try_frame_msg"
.L1353:
    .string "zyl_try_last_msg"
.L1354:
    .string "zyl_try_pop"
.L1355:
    .string "zyl_try_push"
.L1356:
    .string "zyl_variant_cmp"
.L1357:
    .string "zyl_variant_eq"
.L1358:
    .string "zyl_variant_field"
.L1360:
    .string "zyl_warn_capture"
.L1361:
    .string "zyl_warn_emit"
.L1362:
    .string "zyl_warn_take"
.L1363:
    .string "zyl_word_of_cstr"
.L1364:
    .string "zyl_wvec_get"
.L1365:
    .string "zyl_wvec_global"
.L1366:
    .string "zyl_wvec_len"
.L1367:
    .string "zyl_wvec_new"
.L1368:
    .string "zyl_wvec_pop"
.L1369:
    .string "zyl_wvec_push"
.L1370:
    .string "zyl_wvec_set"
.L1371:
    .string "zyl_wvec_truncate"
.L1372:
    .string "zyl_zeroize"
.L1387:
    .string "PATH"
.L1396:
    .string "/bin:/usr/bin"
.L1401:
    .string "sh"
.L1402:
    .string "-c"
.L1403:
    .string "/bin/sh"
.L1408:
    .string "XXXXXX"
.L1411:
    .string "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
.L1413:
    .string "TMPDIR"
.L1414:
    .string "/tmp"
.L1415:
    .string "/zyl_link_XXXXXX"
.L1416:
    .string "#!/bin/sh\n"
.L1417:
    .string "(null)"
.L1418:
    .string "\n"
.L1419:
    .string "sh"
.L1420:
    .string "/bin/sh"
.L1423:
    .string "cc"
.L1424:
    .string "-no-pie"
.L1425:
    .string "rt.o"
.L1426:
    .string "-o"
.L1427:
    .string "-lpthread"
.L1429:
    .string ".bin"
.L1431:
    .string "cc"
.L1433:
    .string "cc"
.L1449:
    .string "ZYL_SCHED"
.L1450:
    .string "ZYL_SCHED_CHAOS"
.L1451:
    .string "deterministic"
.L1467:
    .string "PANIC: E_DEADLOCK: every live actor is blocked on a channel or a join\n"
.L1476:
    .string "E_CHANNEL_CAPACITY: a channel buffer holds 1 to 16777216 values"
.L1477:
    .string "E_OUT_OF_MEMORY: no memory for a channel"
.L1482:
    .string "E_CHANNEL_NOT_OWNER: this actor does not own the channel endpoint"
.L1487:
    .string "E_CHANNEL_CLOSED: the channel's sender finished and every value was received"
.L1492:
    .string "E_OUT_OF_MEMORY: no memory for a channel"
.L1513:
    .string "E_ACTOR_LIMIT: at most 1024 actors per program"
.L1514:
    .string "E_OUT_OF_MEMORY: no thread for an actor"
.L1517:
    .string "error"
.L1518:
    .string "error"
.L1525:
    .string "PANIC: "
.L1526:
    .string "\n"
.L1560:
    .string "E_OUT_OF_MEMORY: no memory for an FFI worker"
.L1563:
    .string "E_OUT_OF_MEMORY: no memory for an FFI worker"
.L1564:
    .string "E_OUT_OF_MEMORY: no memory for an FFI worker"
.L1566:
    .string "E_FFI_TIMEOUT: could not start the FFI worker thread"
.L1572:
    .string "?"
.L1573:
    .string "E_FFI_SYMBOL_NOT_FOUND: no such FFI symbol: "
.L1574:
    .string "E_ARITY_MISMATCH: ffi-call passes more than 16 arguments"
.L1576:
    .string "E_FFI_TIMEOUT: ffi call `"
.L1577:
    .string "` exceeded its timeout of "
.L1578:
    .string " ms"
.L1601:
    .string "out of memory allocating a try frame"
.L1610:
    .string "FAIL\n"
.L1611:
    .string "FAIL: "
.L1612:
    .string "\n"
.L1621:
    .string "\ntest result: "
.L1622:
    .string " passed, "
.L1623:
    .string " failed, "
.L1624:
    .string " total\n"
.L1625:
    .string "test: "
.L1626:
    .string " ... "
.L1627:
    .string "ok\n"
.L1630:
    .string "error"
.L1632:
    .string "assertion failed"
.L1634:
    .string "PANIC: "
.L1635:
    .string "\n"
.L1636:
    .string "error["
.L1639:
    .string "  in "
.L1640:
    .string "\n"
.L1647:
    .string "\n"
.L1648:
    .string "error["
.L1649:
    .string ""
.L1650:
    .string ""
.L1652:
    .string "{\"severity\":\"error\",\"code\":"
.L1653:
    .string ",\"message\":"
.L1654:
    .string ",\"file\":\"\",\"line\":0,\"column\":0,\"labels\":[],\"help\":\"\"}\n"
.L1659:
    .string "error["
.L1663:
    .string "error\n"
.L1664:
    .string "error: "
.L1665:
    .string "\n"
.L1674:
    .string ""
.L1675:
    .string "\n"
.L1679:
    .string ""
.L1681:
    .string ""
.L1682:
    .string "\"\""
.L1686:
    .string "\\u00"
.L1690:
    .string "(null)"
.L1693:
    .string "test: "
.L1694:
    .string " ... "
.L1696:
    .string "FAIL\n"
.L1697:
    .string "ok\n"
.L1699:
    .string "FAIL: "
.L1700:
    .string "\n"
.L1703:
    .string "\ntest result: "
.L1704:
    .string " passed, "
.L1705:
    .string " failed, "
.L1706:
    .string " total\n"
.L1709:
    .string ""
.L1710:
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
.globl zyl_rt_trap_ovf_0
zyl_rt_trap_ovf_0:
    mov edi, 0
    and rsp, -16
    call zyl_overflow_panic
    ud2
.globl zyl_rt_trap_ovf_1
zyl_rt_trap_ovf_1:
    mov edi, 1
    and rsp, -16
    call zyl_overflow_panic
    ud2
.globl zyl_rt_trap_ovf_2
zyl_rt_trap_ovf_2:
    mov edi, 2
    and rsp, -16
    call zyl_overflow_panic
    ud2
.globl zyl_rt_trap_ovf_3
zyl_rt_trap_ovf_3:
    mov edi, 3
    and rsp, -16
    call zyl_overflow_panic
    ud2
.globl zyl_rt_trap_ovf_4
zyl_rt_trap_ovf_4:
    mov edi, 4
    and rsp, -16
    call zyl_overflow_panic
    ud2
.globl zyl_rt_trap_div0_3
zyl_rt_trap_div0_3:
    mov edi, 3
    and rsp, -16
    call zyl_div_zero_panic
    ud2
.globl zyl_rt_trap_div0_4
zyl_rt_trap_div0_4:
    mov edi, 4
    and rsp, -16
    call zyl_div_zero_panic
    ud2
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
