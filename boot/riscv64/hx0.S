/* HX0 Stage-0 for Linux RV64; same bytecode contract as x86-64. */
.global _start
.section .text
_start:
    ld t0,0(sp); li t1,2; blt t0,t1,fail
    ld a1,16(sp); li a0,-100; li a2,0; li a3,0; li a7,56; ecall
    blt a0,zero,fail; mv s0,a0
    la a1,program; li a2,65536; li a7,63; ecall
    li t0,5; blt a0,t0,fail; mv s1,a0
    mv a0,s0; li a7,57; ecall
    la s2,program
    lbu t0,0(s2); li t1,'H'; bne t0,t1,fail
    lbu t0,1(s2); li t1,'X'; bne t0,t1,fail
    lbu t0,2(s2); li t1,'0'; bne t0,t1,fail
    lbu t0,3(s2); li t1,1; bne t0,t1,fail
    addi s3,s2,4; add s4,s2,s1; la s5,stack; mv s6,s5
loop:
    bgeu s3,s4,fail
    lbu t0,0(s3); addi s3,s3,1
    beq t0,zero,ok
    li t1,1; beq t0,t1,emit_imm
    li t1,2; beq t0,t1,push_imm
    li t1,3; beq t0,t1,emit_top
    li t1,4; beq t0,t1,addop
    li t1,5; beq t0,t1,xorop
    li t1,6; beq t0,t1,dupop
    li t1,7; beq t0,t1,dropop
    li t1,8; beq t0,t1,jmpop
    li t1,9; beq t0,t1,jnzop
    li t1,10; beq t0,t1,readop
    li t1,11; beq t0,t1,readbit
    li t1,12; beq t0,t1,echobit
    j fail
emit_imm:
    bgeu s3,s4,fail; lbu t0,0(s3); addi s3,s3,1; la a1,outbyte; sb t0,0(a1); li a0,1; li a2,1; li a7,64; ecall; j loop
push_imm:
    bgeu s3,s4,fail; sub t2,s6,s5; li t3,4096; bgeu t2,t3,fail; lbu t0,0(s3); addi s3,s3,1; sb t0,0(s6); addi s6,s6,1; j loop
emit_top:
    bleu s6,s5,fail; addi s6,s6,-1; lbu t0,0(s6); la a1,outbyte; sb t0,0(a1); li a0,1; li a2,1; li a7,64; ecall; j loop
addop:
    sub t2,s6,s5; li t3,2; blt t2,t3,fail; addi s6,s6,-2; lbu t0,0(s6); lbu t1,1(s6); add t0,t0,t1; sb t0,0(s6); addi s6,s6,1; j loop
xorop:
    sub t2,s6,s5; li t3,2; blt t2,t3,fail; addi s6,s6,-2; lbu t0,0(s6); lbu t1,1(s6); xor t0,t0,t1; sb t0,0(s6); addi s6,s6,1; j loop
dupop:
    bleu s6,s5,fail; sub t2,s6,s5; li t3,4096; bgeu t2,t3,fail; lbu t0,-1(s6); sb t0,0(s6); addi s6,s6,1; j loop
dropop:
    bleu s6,s5,fail; addi s6,s6,-1; j loop
jmpop:
    bgeu s3,s4,fail; lb t0,0(s3); addi s3,s3,1; add s3,s3,t0; bgeu s3,s4,fail; j loop
jnzop:
    bgeu s3,s4,fail; bleu s6,s5,fail; lb t0,0(s3); addi s3,s3,1; addi s6,s6,-1; lbu t1,0(s6); beq t1,zero,loop; add s3,s3,t0; bgeu s3,s4,fail; j loop
readop:
    sub t2,s6,s5; li t3,4094; bgtu t2,t3,fail
    li a0,0; la a1,outbyte; li a2,1; li a7,63; ecall
    li t0,1; bne a0,t0,1f
    la t1,outbyte; lbu t0,0(t1); sb t0,0(s6); li t0,1; sb t0,1(s6); addi s6,s6,2; j loop
1:  sb zero,0(s6); sb zero,1(s6); addi s6,s6,2; j loop
readbit:
    sub t2,s6,s5; li t3,4094; bgtu t2,t3,fail
    li a0,0; la a1,outbyte; li a2,1; li a7,63; ecall
    blt a0,zero,fail
    li t0,1; bne a0,t0,1f
    la t1,outbyte; lbu t0,0(t1); li t1,1; bgtu t0,t1,fail
    sb t0,0(s6); li t0,1; sb t0,1(s6); addi s6,s6,2; j loop
1:  sb zero,0(s6); sb zero,1(s6); addi s6,s6,2; j loop
echobit:
    bleu s6,s5,fail
    lbu t0,-1(s6); li t1,1; bgtu t0,t1,fail
    la t1,echo_cell; sb t0,0(t1); xori t2,t0,255; sb t2,1(t1)
    fence rw,rw
    lbu t3,0(t1); lbu t4,1(t1); xori t4,t4,255
    bne t3,t4,fail; bne t3,t0,fail
    sb t3,-1(s6); j loop
ok: li a0,0; li a7,93; ecall
fail: li a0,1; li a7,93; ecall
.section .bss
.balign 16
program: .skip 65536
stack: .skip 4096
outbyte: .skip 1
echo_cell: .skip 2

.section .note.GNU-stack,"",@progbits
