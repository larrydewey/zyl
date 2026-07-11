.intel_syntax noprefix
.align 16
.section .rodata
.align 16
.align 16
.str_hello:
    .string "hello"
.align 16
.str_hello_world:
    .string "hello world"
.align 16
.str_matched_second_arm:
    .string "matched second arm"
.align 16
.str_only_arm:
    .string "only arm"
.align 16
.str_should_not_print:
    .string "should not print"
.align 16
.str_then_branch:
    .string "then-branch"
.align 16
.str_twice:
    .string "twice"
.align 16
.str_unless_works:
    .string "unless works"
.align 16
.str_when_works:
    .string "when works"
.align 16
.str_world:
    .string "world"
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
    .space 33
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
    mov eax, 1
    mov eax, 2
    mov eax, 3
    mov eax, 4
    mov eax, 5
    mov eax, 3
    mov eax, 6
    mov eax, 10
    mov eax, 15
    mov eax, 10
    mov eax, 3
    mov eax, 7
    mov eax, 3
    mov eax, 4
    mov eax, 12
    mov eax, 20
    mov eax, 4
    mov eax, 5
    mov ecx, 10
    mov edx, 5
.align 16
    cmp rcx, rdx
.align 16
    setg al
.align 16
    movzx eax, al
.align 16
    mov ecx, 10
.align 16
    mov edx, 5
.align 16
    cmp ecx, edx
.align 16
    setg al
.align 16
    movzx eax, al
.align 16
    test eax, eax
.align 16
    je  .L0
.align 16
___if_result_23.then:
    mov eax, 1
.align 16
    mov [rbp-184], eax
.align 16
    jmp ___if_result_23.join
.align 16
.L0:
.align 16
___if_result_23.else:
    mov eax, 0
.align 16
    mov [rbp-184], eax
.align 16
___if_result_23.join:
.align 16
    mov eax, [rbp-184]
.align 16
    mov [rbp-184], rax
    mov ecx, 5
    mov edx, 10
.align 16
    cmp rcx, rdx
.align 16
    setl al
.align 16
    movzx eax, al
.align 16
    mov ecx, 5
.align 16
    mov edx, 10
.align 16
    cmp ecx, edx
.align 16
    setl al
.align 16
    movzx eax, al
.align 16
    test eax, eax
.align 16
    je  .L1
.align 16
___if_result_30.then:
    mov eax, 1
.align 16
    mov [rbp-224], eax
.align 16
    jmp ___if_result_30.join
.align 16
.L1:
.align 16
___if_result_30.else:
    mov eax, 0
.align 16
    mov [rbp-224], eax
.align 16
___if_result_30.join:
.align 16
    mov eax, [rbp-224]
.align 16
    mov [rbp-224], rax
    mov ecx, 5
    mov edx, 5
.align 16
    cmp rcx, rdx
.align 16
    setge al
.align 16
    movzx eax, al
.align 16
    mov ecx, 5
.align 16
    mov edx, 5
.align 16
    cmp ecx, edx
.align 16
    setge al
.align 16
    movzx eax, al
.align 16
    test eax, eax
.align 16
    je  .L2
.align 16
___if_result_37.then:
    mov eax, 1
.align 16
    mov [rbp-264], eax
.align 16
    jmp ___if_result_37.join
.align 16
.L2:
.align 16
___if_result_37.else:
    mov eax, 0
.align 16
    mov [rbp-264], eax
.align 16
___if_result_37.join:
.align 16
    mov eax, [rbp-264]
.align 16
    mov [rbp-264], rax
    mov ecx, 5
    mov edx, 5
.align 16
    cmp rcx, rdx
.align 16
    setle al
.align 16
    movzx eax, al
.align 16
    mov ecx, 5
.align 16
    mov edx, 5
.align 16
    cmp ecx, edx
.align 16
    setle al
.align 16
    movzx eax, al
.align 16
    test eax, eax
.align 16
    je  .L3
.align 16
___if_result_44.then:
    mov eax, 1
.align 16
    mov [rbp-304], eax
.align 16
    jmp ___if_result_44.join
.align 16
.L3:
.align 16
___if_result_44.else:
    mov eax, 0
.align 16
    mov [rbp-304], eax
.align 16
___if_result_44.join:
.align 16
    mov eax, [rbp-304]
.align 16
    mov [rbp-304], rax
    mov eax, 5
    mov eax, 5
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L4
.align 16
___if_result_51.then:
    mov eax, 1
.align 16
    mov [rbp-344], eax
.align 16
    jmp ___if_result_51.join
.align 16
.L4:
.align 16
___if_result_51.else:
    mov eax, 0
.align 16
    mov [rbp-344], eax
.align 16
___if_result_51.join:
.align 16
    mov eax, [rbp-344]
.align 16
    mov [rbp-344], rax
    mov eax, 5
    mov eax, 3
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L5
.align 16
___if_result_58.then:
    mov eax, 1
.align 16
    mov [rbp-384], eax
.align 16
    jmp ___if_result_58.join
.align 16
.L5:
.align 16
___if_result_58.else:
    mov eax, 0
.align 16
    mov [rbp-384], eax
.align 16
___if_result_58.join:
.align 16
    mov eax, [rbp-384]
.align 16
    mov [rbp-384], rax
    mov eax, 1
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L6
.align 16
___if_result_66.then:
    mov eax, 1
.align 16
    mov [rbp-416], eax
.align 16
    jmp ___if_result_66.join
.align 16
.L6:
.align 16
___if_result_66.else:
    mov eax, 0
.align 16
    mov [rbp-416], eax
.align 16
___if_result_66.join:
.align 16
    mov eax, [rbp-416]
.align 16
    mov [rbp-416], rax
    mov eax, 0
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L7
.align 16
___if_result_74.then:
    mov eax, 1
.align 16
    mov [rbp-448], eax
.align 16
    jmp ___if_result_74.join
.align 16
.L7:
.align 16
___if_result_74.else:
    mov eax, 0
.align 16
    mov [rbp-448], eax
.align 16
___if_result_74.join:
.align 16
    mov eax, [rbp-448]
.align 16
    mov [rbp-448], rax
    mov eax, 0
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L8
.align 16
___if_result_80.then:
    mov eax, 1
.align 16
    mov [rbp-480], eax
.align 16
    jmp ___if_result_80.join
.align 16
.L8:
.align 16
___if_result_80.else:
    mov eax, 0
.align 16
    mov [rbp-480], eax
.align 16
___if_result_80.join:
.align 16
    mov eax, [rbp-480]
.align 16
    mov [rbp-480], rax
    mov eax, 42
.align 16
    mov [rbp-496], rax
.align 16
    mov eax, [rbp-496]
    mov eax, 10
.align 16
    mov [rbp-520], rax
    mov eax, 20
.align 16
    mov [rbp-536], rax
    mov ecx, 0
.align 16
    mov rdx, [rbp-536]
.align 16
    mov eax, ecx
.align 16
    add eax, edx
    mov eax, 5
.align 16
    mov eax, [rbp-168]
.align 16
    mov [rbp-584], rax
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L9
.align 16
___if_result_103.then:
.align 16
    lea rdi, [.str_then_branch] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    mov [rbp-608], eax
.align 16
    jmp ___if_result_103.join
.align 16
.L9:
.align 16
___if_result_103.else:
.align 16
    xor eax, eax
.align 16
    mov [rbp-608], eax
.align 16
___if_result_103.join:
.align 16
    mov eax, [rbp-608]
.align 16
    mov [rbp-608], rax
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L10
.align 16
___if_result_112.then:
.align 16
    xor eax, eax
.align 16
    test eax, eax
.align 16
    je  .L11
.align 16
___if_result_109.then:
    mov eax, 1
.align 16
    jmp ___if_result_109.join
.align 16
.L11:
.align 16
___if_result_109.else:
    mov eax, 2
.align 16
___if_result_109.join:
.align 16
    mov [rbp-16], rax
.align 16
    mov [rbp-632], eax
.align 16
    jmp ___if_result_112.join
.align 16
.L10:
.align 16
___if_result_112.else:
    mov eax, 3
.align 16
    mov [rbp-632], eax
.align 16
___if_result_112.join:
.align 16
    mov eax, [rbp-632]
.align 16
    mov [rbp-632], rax
    mov edi, 3
    mov esi, 4
.align 16
    call _ZYL_add
    mov edi, 10
    mov esi, 3
.align 16
    call _ZYL_sub
    mov edi, 2
    mov esi, 5
.align 16
    call _ZYL_mul
    mov edi, 5
.align 16
    call _ZYL_factorial
    mov eax, 1
.align 16
    mov [rbp-520], rax
    mov eax, 2
.align 16
    mov [rbp-536], rax
    mov eax, 3
.align 16
    mov [rbp-768], rax
    mov ecx, 0
    mov edx, 0
.align 16
    mov eax, ecx
.align 16
    add eax, edx
.align 16
    mov ecx, eax
.align 16
    mov rdx, [rbp-768]
.align 16
    mov eax, ecx
.align 16
    add eax, edx
.align 16
.while_12:
    mov eax, 0
.align 16
    test eax, eax
.align 16
    je  .wend_12
    mov eax, 0
.align 16
    jmp .while_12
.align 16
.wend_12:
    mov eax, 0
.align 16
    mov eax, [rbp-40]
    mov eax, 5
.align 16
    mov eax, [rbp-40]
    mov eax, 10
.align 16
.for_13:
.align 16
    mov rcx, [rbp-40]
    mov edx, 5
.align 16
    cmp rcx, rdx
.align 16
    setle al
.align 16
    movzx eax, al
    mov r10, rax
    test r10, r10
    je .fend_13
.align 16
    mov rcx, [rbp-40]
    mov edx, 10
.align 16
    mov eax, ecx
.align 16
    add eax, edx
    mov eax, 1
.align 16
    jmp .for_13
.align 16
.align 16
.fend_13:
    mov eax, 1
    mov eax, 1
    mov eax, 0
    mov eax, 2
.align 16
    mov [rbp-904], rax
    mov eax, 0
    mov eax, 99
    mov eax, 1
.align 16
    lea rdi, [.str_matched_second_arm] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
    mov eax, 42
.align 16
    mov [rbp-960], rax
    mov eax, 1
    mov eax, 0
.align 16
    test eax, eax
.align 16
    je  .L14
.align 16
___if_result_202.then:
.align 16
    lea rdi, [.str_should_not_print] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    mov [rbp-992], eax
.align 16
    jmp ___if_result_202.join
.align 16
.L14:
.align 16
___if_result_202.else:
.align 16
    xor eax, eax
.align 16
    mov [rbp-992], eax
.align 16
___if_result_202.join:
.align 16
    mov eax, [rbp-992]
.align 16
    mov [rbp-992], rax
    mov eax, 0
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L15
.align 16
___if_result_210.then:
.align 16
    lea rdi, [.str_unless_works] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    mov [rbp-1024], eax
.align 16
    jmp ___if_result_210.join
.align 16
.L15:
.align 16
___if_result_210.else:
.align 16
    xor eax, eax
.align 16
    mov [rbp-1024], eax
.align 16
___if_result_210.join:
.align 16
    mov eax, [rbp-1024]
.align 16
    mov [rbp-1024], rax
    mov eax, 0
    mov eax, 1
    mov eax, 0
.align 16
    test eax, eax
.align 16
    je  .L16
.align 16
___if_result_219.then:
.align 16
    lea rdi, [.str_should_not_print] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    mov [rbp-1064], eax
.align 16
    jmp ___if_result_219.join
.align 16
.L16:
.align 16
___if_result_219.else:
.align 16
    xor eax, eax
.align 16
    mov [rbp-1064], eax
.align 16
___if_result_219.join:
.align 16
    mov eax, [rbp-1064]
.align 16
    mov [rbp-1064], rax
    mov eax, 1
    mov eax, 0
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L17
.align 16
___if_result_228.then:
.align 16
    lea rdi, [.str_when_works] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    mov [rbp-1104], eax
.align 16
    jmp ___if_result_228.join
.align 16
.L17:
.align 16
___if_result_228.else:
.align 16
    xor eax, eax
.align 16
    mov [rbp-1104], eax
.align 16
___if_result_228.join:
.align 16
    mov eax, [rbp-1104]
.align 16
    mov [rbp-1104], rax
.align 16
    lea rdi, [.str_twice] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    lea rdi, [.str_twice] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    lea rdi, [.str_hello] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    lea rdi, [.str_world] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
    mov eax, 2
    mov eax, 3
    mov eax, 6
    mov eax, 10
    mov eax, 4
    mov eax, 6
    mov eax, 12
.align 16
    mov [rbp-1232], rax
.align 16
    mov eax, [rbp-1232]
    mov ecx, 10
    mov edx, 5
.align 16
    cmp rcx, rdx
.align 16
    setg al
.align 16
    movzx eax, al
.align 16
    mov ecx, 10
.align 16
    mov edx, 5
.align 16
    cmp ecx, edx
.align 16
    setg al
.align 16
    movzx eax, al
.align 16
    test eax, eax
.align 16
    je  .L18
.align 16
___if_result_263.then:
.align 16
    xor eax, eax
.align 16
    test eax, eax
.align 16
    je  .L19
.align 16
___if_result_260.then:
    mov eax, 1
.align 16
    jmp ___if_result_260.join
.align 16
.L19:
.align 16
___if_result_260.else:
    mov eax, 0
.align 16
___if_result_260.join:
.align 16
    mov [rbp-16], rax
.align 16
    mov [rbp-1280], eax
.align 16
    jmp ___if_result_263.join
.align 16
.L18:
.align 16
___if_result_263.else:
    mov eax, 0
.align 16
    mov [rbp-1280], eax
.align 16
___if_result_263.join:
.align 16
    mov eax, [rbp-1280]
.align 16
    mov [rbp-1280], rax
    mov eax, 2
    mov eax, 3
    mov eax, 6
.align 16
    mov [rbp-536], rax
.align 16
    mov rcx, [rbp-536]
    mov edx, 4
.align 16
    mov eax, ecx
.align 16
    add eax, edx
    mov ecx, 1
.align 16
    mov edx, eax
.align 16
    mov eax, ecx
.align 16
    add eax, edx
.align 16
    mov [rbp-520], rax
.align 16
    mov eax, [rbp-520]
    mov eax, 1
.align 16
    test eax, eax
.align 16
    je  .L20
.align 16
___if_result_281.then:
    mov eax, 1
.align 16
    mov [rbp-1392], eax
.align 16
    jmp ___if_result_281.join
.align 16
.L20:
.align 16
___if_result_281.else:
    mov eax, 0
.align 16
    mov [rbp-1392], eax
.align 16
___if_result_281.join:
.align 16
    mov eax, [rbp-1392]
.align 16
    mov [rbp-1392], rax
    mov eax, 0
.align 16
    test eax, eax
.align 16
    je  .L21
.align 16
___if_result_286.then:
    mov eax, 1
.align 16
    mov [rbp-1416], eax
.align 16
    jmp ___if_result_286.join
.align 16
.L21:
.align 16
___if_result_286.else:
    mov eax, 0
.align 16
    mov [rbp-1416], eax
.align 16
___if_result_286.join:
.align 16
    mov eax, [rbp-1416]
.align 16
    mov [rbp-1416], rax
    mov eax, 1
    mov eax, 0
    mov eax, 0
    mov eax, 1
    mov eax, 1
    mov eax, 0
    mov eax, 0
    mov eax, 1
    mov eax, 5
    mov eax, 5
    mov eax, 0
    mov eax, 1
.align 16
    lea rax, [.str_only_arm] 
.align 16
    mov [rbp-1528], rax
.align 16
    mov rax, rax
.align 16
    xor edi, edi           # exit code 0
.align 16
    call exit@plt
.align 16
    pop rbp
.align 16
    ret
.align 16
.align 16
_ZYL_add:
.align 16
    push rbp
.align 16
    mov rbp, rsp
.align 16
    sub rsp, 256
.align 16
    mov [rbp-8], edi # x
.align 16
    mov [rbp-16], esi # y
.align 16
    mov rcx, [rbp-8]
.align 16
    mov rdx, [rbp-16]
.align 16
    mov eax, ecx
.align 16
    add eax, edx
.align 16
    add rsp, 256
.align 16
    pop rbp
.align 16
    ret
.align 16
.align 16
_ZYL_sub:
.align 16
    push rbp
.align 16
    mov rbp, rsp
.align 16
    sub rsp, 256
.align 16
    mov [rbp-8], edi # x
.align 16
    mov [rbp-16], esi # y
.align 16
    mov rcx, [rbp-8]
.align 16
    mov rdx, [rbp-16]
.align 16
    mov eax, ecx
.align 16
    sub eax, edx
.align 16
    add rsp, 256
.align 16
    pop rbp
.align 16
    ret
.align 16
.align 16
_ZYL_mul:
.align 16
    push rbp
.align 16
    mov rbp, rsp
.align 16
    sub rsp, 256
.align 16
    mov [rbp-8], edi # x
.align 16
    mov [rbp-16], esi # y
.align 16
    mov rcx, [rbp-8]
.align 16
    mov rdx, [rbp-16]
.align 16
    mov eax, ecx
.align 16
    imul eax, edx
.align 16
    add rsp, 256
.align 16
    pop rbp
.align 16
    ret
.align 16
.align 16
_ZYL_factorial:
.align 16
    push rbp
.align 16
    mov rbp, rsp
.align 16
    sub rsp, 256
.align 16
    mov [rbp-8], edi # n
.align 16
    mov ecx, [rbp-8]
.align 16
    mov edx, 1
.align 16
    cmp ecx, edx
.align 16
    setle al
.align 16
    movzx eax, al
.align 16
    test eax, eax
.align 16
    je  .L22
.align 16
___if_result_140.then:
    mov eax, 1
.align 16
    mov [rbp-56], eax
.align 16
    jmp ___if_result_140.join
.align 16
.L22:
.align 16
___if_result_140.else:
.align 16
    mov rcx, [rbp-8]
    mov edx, 1
.align 16
    mov eax, ecx
.align 16
    sub eax, edx
.align 16
    mov edi, eax
.align 16
    call _ZYL_factorial
.align 16
    mov rcx, [rbp-8]
.align 16
    mov edx, eax
.align 16
    mov eax, ecx
.align 16
    imul eax, edx
.align 16
    mov [rbp-56], eax
.align 16
___if_result_140.join:
.align 16
    mov eax, [rbp-56]
.align 16
    mov [rbp-56], rax
.align 16
    add rsp, 256
.align 16
    pop rbp
.align 16
    ret
.align 16
.align 16
_ZYL_identity:
.align 16
    push rbp
.align 16
    mov rbp, rsp
.align 16
    sub rsp, 256
.align 16
    mov [rbp-8], edi # x
.align 16
    mov eax, [rbp-8]
.align 16
    add rsp, 256
.align 16
    pop rbp
.align 16
    ret
.align 16
.align 16
_ZYL_hello:
.align 16
    push rbp
.align 16
    mov rbp, rsp
.align 16
    sub rsp, 256
.align 16
    lea rdi, [.str_hello_world] 
.align 16
    xor eax, eax           # No xmm args to printf
.align 16
    call printf@plt
.align 16
    add rsp, 256
.align 16
    pop rbp
.align 16
    ret