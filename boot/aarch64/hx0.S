/* HX0 Stage-0 for Linux AArch64; same bytecode contract as x86-64. */
.global _start
.section .text
_start:
    ldr x0, [sp]
    cmp x0, #2
    b.lt fail
    ldr x1, [sp,#16]
    mov x0, #-100
    mov x2, #0
    mov x3, #0
    mov x8, #56
    svc #0
    cmp x0, #0
    b.lt fail
    mov x20, x0
    adrp x1, program
    add x1, x1, :lo12:program
    mov x2, #65536
    mov x8, #63
    svc #0
    cmp x0, #5
    b.lt fail
    mov x21, x0
    mov x0, x20
    mov x8, #57
    svc #0
    adrp x19, program
    add x19, x19, :lo12:program
    ldrb w0,[x19]; cmp w0,#'H'; b.ne fail
    ldrb w0,[x19,#1]; cmp w0,#'X'; b.ne fail
    ldrb w0,[x19,#2]; cmp w0,#'0'; b.ne fail
    ldrb w0,[x19,#3]; cmp w0,#1; b.ne fail
    add x22,x19,#4
    add x23,x19,x21
    adrp x24, stack
    add x24,x24,:lo12:stack
    mov x25,x24
loop:
    cmp x22,x23; b.hs fail
    ldrb w0,[x22],#1
    cmp w0,#0; b.eq ok
    cmp w0,#1; b.eq emit_imm
    cmp w0,#2; b.eq push_imm
    cmp w0,#3; b.eq emit_top
    cmp w0,#4; b.eq addop
    cmp w0,#5; b.eq xorop
    cmp w0,#6; b.eq dupop
    cmp w0,#7; b.eq dropop
    cmp w0,#8; b.eq jmpop
    cmp w0,#9; b.eq jnzop
    cmp w0,#10; b.eq readop
    cmp w0,#11; b.eq readbit
    cmp w0,#12; b.eq echobit
    b fail
emit_imm:
    cmp x22,x23; b.hs fail
    ldrb w0,[x22],#1
    adrp x1,outbyte; add x1,x1,:lo12:outbyte; strb w0,[x1]
    mov x0,#1; mov x2,#1; mov x8,#64; svc #0
    b loop
push_imm:
    cmp x22,x23; b.hs fail
    sub x0,x25,x24; cmp x0,#4096; b.hs fail
    ldrb w0,[x22],#1; strb w0,[x25],#1; b loop
emit_top:
    cmp x25,x24; b.ls fail
    ldrb w0,[x25,#-1]!; adrp x1,outbyte; add x1,x1,:lo12:outbyte; strb w0,[x1]
    mov x0,#1; mov x2,#1; mov x8,#64; svc #0; b loop
addop:
    sub x0,x25,x24; cmp x0,#2; b.lt fail
    sub x25,x25,#2; ldrb w0,[x25]; ldrb w1,[x25,#1]; add w0,w0,w1; strb w0,[x25],#1; b loop
xorop:
    sub x0,x25,x24; cmp x0,#2; b.lt fail
    sub x25,x25,#2; ldrb w0,[x25]; ldrb w1,[x25,#1]; eor w0,w0,w1; strb w0,[x25],#1; b loop
dupop:
    cmp x25,x24; b.ls fail
    sub x0,x25,x24; cmp x0,#4096; b.hs fail
    ldrb w0,[x25,#-1]; strb w0,[x25],#1; b loop
dropop:
    cmp x25,x24; b.ls fail
    sub x25,x25,#1; b loop
jmpop:
    cmp x22,x23; b.hs fail
    ldrsb x0,[x22],#1; add x22,x22,x0; cmp x22,x23; b.hs fail; b loop
jnzop:
    cmp x22,x23; b.hs fail
    cmp x25,x24; b.ls fail
    ldrsb x0,[x22],#1; ldrb w1,[x25,#-1]!; cbz w1,loop; add x22,x22,x0; cmp x22,x23; b.hs fail; b loop
readop:
    sub x0,x25,x24; mov x1,#4094; cmp x0,x1; b.hi fail
    mov x0,#0; adrp x1,outbyte; add x1,x1,:lo12:outbyte; mov x2,#1; mov x8,#63; svc #0
    cmp x0,#1; b.ne 1f
    adrp x1,outbyte; add x1,x1,:lo12:outbyte; ldrb w0,[x1]; strb w0,[x25]; mov w0,#1; strb w0,[x25,#1]; add x25,x25,#2; b loop
1:  mov w0,#0; strb w0,[x25]; strb w0,[x25,#1]; add x25,x25,#2; b loop
readbit:
    sub x0,x25,x24; mov x1,#4094; cmp x0,x1; b.hi fail
    mov x0,#0; adrp x1,outbyte; add x1,x1,:lo12:outbyte; mov x2,#1; mov x8,#63; svc #0
    cmp x0,#0; b.lt fail
    cmp x0,#1; b.ne 1f
    adrp x1,outbyte; add x1,x1,:lo12:outbyte; ldrb w0,[x1]
    cmp w0,#1; b.hi fail
    strb w0,[x25]; mov w0,#1; strb w0,[x25,#1]; add x25,x25,#2; b loop
1:  mov w0,#0; strb w0,[x25]; strb w0,[x25,#1]; add x25,x25,#2; b loop
echobit:
    cmp x25,x24; b.ls fail
    ldrb w0,[x25,#-1]; cmp w0,#1; b.hi fail
    adrp x1,echo_cell; add x1,x1,:lo12:echo_cell
    strb w0,[x1]; eor w2,w0,#255; strb w2,[x1,#1]
    dmb ish
    ldrb w3,[x1]; ldrb w4,[x1,#1]; eor w4,w4,#255
    cmp w3,w4; b.ne fail
    cmp w3,w0; b.ne fail
    strb w3,[x25,#-1]; b loop
ok: mov x0,#0; mov x8,#93; svc #0
fail: mov x0,#1; mov x8,#93; svc #0
.section .bss
.balign 16
program: .skip 65536
stack: .skip 4096
outbyte: .skip 1
echo_cell: .skip 2

.section .note.GNU-stack,"",@progbits
