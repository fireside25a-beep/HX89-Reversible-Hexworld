/* HX0 Stage-0 for Linux x86-64. No libc.
   File: "HX0\1" followed by opcodes:
   00 HALT, 01 EMIT_IMM b, 02 PUSH b, 03 EMIT_TOP, 04 ADD, 05 XOR,
   06 DUP, 07 DROP, 08 JMP rel8, 09 JNZ rel8,
   0A READ_STDIN (push byte then success flag: 1=byte, 0=EOF),
   0B READ_BIT (same stack contract; reject symbols other than 0 and 1),
   0C ECHO_BIT (store bit and inverse to private memory; verify and return bit).
*/
.global _start
.section .text
_start:
    mov (%rsp), %rax
    cmp $2, %rax
    jb fail
    mov 16(%rsp), %rsi
    mov $-100, %rdi
    xor %rdx, %rdx
    xor %r10, %r10
    mov $257, %rax
    syscall
    test %rax, %rax
    js fail
    mov %rax, %r14
    mov %rax, %rdi
    lea program(%rip), %rsi
    mov $65536, %rdx
    xor %rax, %rax
    syscall
    cmp $5, %rax
    jb fail
    mov %rax, %r15
    mov %r14, %rdi
    mov $3, %rax
    syscall
    cmpb $'H', program(%rip)
    jne fail
    cmpb $'X', program+1(%rip)
    jne fail
    cmpb $'0', program+2(%rip)
    jne fail
    cmpb $1, program+3(%rip)
    jne fail
    lea program+4(%rip), %r12
    lea program(%rip), %rbx
    add %r15, %rbx
    lea stack(%rip), %r13
loop:
    cmp %rbx, %r12
    jae fail
    movzbq (%r12), %rax
    inc %r12
    cmp $0, %al
    je done
    cmp $1, %al
    je emit_imm
    cmp $2, %al
    je push_imm
    cmp $3, %al
    je emit_top
    cmp $4, %al
    je addop
    cmp $5, %al
    je xorop
    cmp $6, %al
    je dupop
    cmp $7, %al
    je dropop
    cmp $8, %al
    je jmpop
    cmp $9, %al
    je jnzop
    cmp $10, %al
    je readop
    cmp $11, %al
    je readbit
    cmp $12, %al
    je echobit
    jmp fail
emit_imm:
    cmp %rbx, %r12
    jae fail
    mov (%r12), %al
    inc %r12
    mov %al, outbyte(%rip)
    mov $1, %rax
    mov $1, %rdi
    lea outbyte(%rip), %rsi
    mov $1, %rdx
    syscall
    jmp loop
push_imm:
    cmp %rbx, %r12
    jae fail
    lea stack+4096(%rip), %rcx
    cmp %rcx, %r13
    jae fail
    mov (%r12), %al
    inc %r12
    mov %al, (%r13)
    inc %r13
    jmp loop
emit_top:
    lea stack(%rip), %rcx
    cmp %rcx, %r13
    jbe fail
    dec %r13
    mov (%r13), %al
    mov %al, outbyte(%rip)
    mov $1, %rax
    mov $1, %rdi
    lea outbyte(%rip), %rsi
    mov $1, %rdx
    syscall
    jmp loop
addop:
    lea stack+2(%rip), %rcx
    cmp %rcx, %r13
    jb fail
    sub $2, %r13
    mov (%r13), %al
    add 1(%r13), %al
    mov %al, (%r13)
    inc %r13
    jmp loop
xorop:
    lea stack+2(%rip), %rcx
    cmp %rcx, %r13
    jb fail
    sub $2, %r13
    mov (%r13), %al
    xor 1(%r13), %al
    mov %al, (%r13)
    inc %r13
    jmp loop
dupop:
    lea stack(%rip), %rcx
    cmp %rcx, %r13
    jbe fail
    lea stack+4096(%rip), %rcx
    cmp %rcx, %r13
    jae fail
    mov -1(%r13), %al
    mov %al, (%r13)
    inc %r13
    jmp loop
dropop:
    lea stack(%rip), %rcx
    cmp %rcx, %r13
    jbe fail
    dec %r13
    jmp loop
jmpop:
    cmp %rbx, %r12
    jae fail
    movsbq (%r12), %rax
    inc %r12
    add %rax, %r12
    cmp %rbx, %r12
    jae fail
    jmp loop
jnzop:
    cmp %rbx, %r12
    jae fail
    lea stack(%rip), %rcx
    cmp %rcx, %r13
    jbe fail
    movsbq (%r12), %rax
    inc %r12
    dec %r13
    cmpb $0, (%r13)
    je loop
    add %rax, %r12
    cmp %rbx, %r12
    jae fail
    jmp loop
readop:
    lea stack+4094(%rip), %rcx
    cmp %rcx, %r13
    ja fail
    xor %rax, %rax
    xor %rdi, %rdi
    lea outbyte(%rip), %rsi
    mov $1, %rdx
    syscall
    test %rax, %rax
    js fail
    cmp $1, %rax
    jne read_eof
    mov outbyte(%rip), %al
    mov %al, (%r13)
    movb $1, 1(%r13)
    add $2, %r13
    jmp loop
readbit:
    lea stack+4094(%rip), %rcx
    cmp %rcx, %r13
    ja fail
    xor %rax, %rax
    xor %rdi, %rdi
    lea outbyte(%rip), %rsi
    mov $1, %rdx
    syscall
    test %rax, %rax
    js fail
    cmp $1, %rax
    jne read_eof
    mov outbyte(%rip), %al
    cmp $1, %al
    ja fail
    mov %al, (%r13)
    movb $1, 1(%r13)
    add $2, %r13
    jmp loop
read_eof:
    movb $0, (%r13)
    movb $0, 1(%r13)
    add $2, %r13
    jmp loop
echobit:
    lea stack(%rip), %rcx
    cmp %rcx, %r13
    jbe fail
    mov -1(%r13), %al
    cmp $1, %al
    ja fail
    mov %al, echo_cell(%rip)
    mov %al, %dl
    xor $255, %dl
    mov %dl, echo_cell+1(%rip)
    mfence
    mov echo_cell(%rip), %r8b
    mov echo_cell+1(%rip), %r9b
    xor $255, %r9b
    cmp %r8b, %r9b
    jne fail
    cmp %r8b, -1(%r13)
    jne fail
    mov %r8b, -1(%r13)
    jmp loop
done:
    xor %rdi, %rdi
    mov $60, %rax
    syscall
fail:
    mov $1, %rdi
    mov $60, %rax
    syscall
.section .bss
.balign 16
program: .skip 65536
stack: .skip 4096
outbyte: .skip 1
echo_cell: .skip 2

.section .note.GNU-stack,"",@progbits
