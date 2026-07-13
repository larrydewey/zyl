.intel_syntax noprefix
.align 16
.section .rodata
.align 16
.align 16
.align 16
.fmt_int:
    .string "%d\n"
.align 16
.align 16
.fmt_str:
    .string "%s\n"
.align 16
.align 16
.str_minus:
    .string "-"
.align 16
.align 16
.nl:
    .string "\n"
.align 16
.align 16
.zero_str:
    .ascii "0"
.align 16
.align 16
.nl_char:
    .ascii "\n"
.align 16
.align 16
.text
.align 16
.section .bss
.align 16
.align 16
.align 16
.hexbuf:
.align 16
    .space 35
.align 16
.text
.align 16
.globl main
.align 16
main:
.align 16
    push rbp
.align 16
    mov rbp, rsp
    mov eax, 10
    mov eax, 20
.align 16
    mov edi, 16
.align 16
    call malloc@plt
.align 16
    mov r10, rax
.align 16
    mov rax, 10
.align 16
    mov [r10 + 0], rax
.align 16
    mov rax, 20
.align 16
    mov [r10 + 8], rax
.align 16
    mov rax, r10
.align 16
    mov [rbp-32], rax
.align 16
    mov eax, [rbp-32]
.align 16
    mov eax, [rax + 0]
.align 16
    mov ecx, eax
.align 16
    test ecx, ecx
.align 16
    jns .___neg_0
.align 16
    mov al, byte ptr [.str_minus]
.align 16
    lea rdi, [.hexbuf] 
.align 16
    add rdi, 32
.align 16
    mov [rdi], al
.align 16
    neg ecx
.align 16
    dec rdi
.align 16
    mov byte ptr [rdi], 0
.align 16
    dec rdi
.align 16
    jmp .___skip_pos_1
.align 16
.___neg_0:
.align 16
    lea rdi, [.hexbuf] 
.align 16
    add rdi, 32
.align 16
    mov byte ptr [rdi], 0
.align 16
    dec rdi
.align 16
.___skip_pos_1:
.align 16
    test ecx, ecx
.align 16
    jne .___divloop_2
.align 16
    mov byte ptr [rdi], 48
.align 16
    mov rdx, rdi
.align 16
    inc rdi
.align 16
    mov byte ptr [rdi], 0
.align 16
    mov rdi, rdx
.align 16
    jmp .___divdone_3
.align 16
.___divloop_2:
.align 16
    test ecx, ecx
.align 16
    je .___divdone_3
.align 16
    xor edx, edx
.align 16
    mov eax, ecx
.align 16
    mov ebx, 10
.align 16
    idiv ebx
.align 16
    mov ecx, eax
.align 16
    dec rdi
.align 16
    mov [rdi], dl
.align 16
    add byte ptr [rdi], 48
.align 16
    jmp .___divloop_2
.align 16
.___divdone_3:
.align 16
    mov rdx, rdi
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    mov eax, [rbp-32]
.align 16
    mov eax, [rax + 8]
.align 16
    mov ecx, eax
.align 16
    test ecx, ecx
.align 16
    jns .___neg_5
.align 16
    mov al, byte ptr [.str_minus]
.align 16
    lea rdi, [.hexbuf] 
.align 16
    add rdi, 32
.align 16
    mov [rdi], al
.align 16
    neg ecx
.align 16
    dec rdi
.align 16
    mov byte ptr [rdi], 0
.align 16
    dec rdi
.align 16
    jmp .___skip_pos_6
.align 16
.___neg_5:
.align 16
    lea rdi, [.hexbuf] 
.align 16
    add rdi, 32
.align 16
    mov byte ptr [rdi], 0
.align 16
    dec rdi
.align 16
.___skip_pos_6:
.align 16
    test ecx, ecx
.align 16
    jne .___divloop_7
.align 16
    mov byte ptr [rdi], 48
.align 16
    mov rdx, rdi
.align 16
    inc rdi
.align 16
    mov byte ptr [rdi], 0
.align 16
    mov rdi, rdx
.align 16
    jmp .___divdone_8
.align 16
.___divloop_7:
.align 16
    test ecx, ecx
.align 16
    je .___divdone_8
.align 16
    xor edx, edx
.align 16
    mov eax, ecx
.align 16
    mov ebx, 10
.align 16
    idiv ebx
.align 16
    mov ecx, eax
.align 16
    dec rdi
.align 16
    mov [rdi], dl
.align 16
    add byte ptr [rdi], 48
.align 16
    jmp .___divloop_7
.align 16
.___divdone_8:
.align 16
    mov rdx, rdi
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    mov eax, [rbp-32]
.align 16
    mov eax, [rbp-32]
.align 16
    xor edi, edi           # exit code 0
.align 16
    call exit@plt
.align 16
    pop rbp
.align 16
    ret