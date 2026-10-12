/* Architecture-neutral HX0 program bytes, assembled as data.
 * HX0 opcodes: PUSH=2, EMIT=3, ADD=4, DUP=6, JMP=8,
 * JNZ=9, READ_BIT=11, ECHO_BIT=12. A partial byte hits invalid 255.
 */
.section .rodata
.byte 'H','X','0',1
loop:
.byte 2,0                         /* accumulator = 0 */
/* acc = acc * 2; read and echo the next bit; acc += observed bit. */
.byte 6,4,11,9,1,0,12,4           /* EOF before first bit: HALT */
.rept 7
.byte 6,4,11,9,1,255,12,4         /* EOF mid-byte: invalid opcode */
.endr
.byte 3,8,loop-(.+1)              /* emit byte; repeat */
