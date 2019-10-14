.data
	result: .byte 0
.text
	.global main
	.equ X, 0x1234
	.equ Y, 0x4567

hamm:
	//TODO
	ldr R1,=#1
	and R1,R0
	add R4,R4,R1
	asr R0,#1
	cmp R0,#0
	bne hamm
	bx lr
main:
	ldr R0, =#X
	ldr R1, =#Y
	ldr R2, =result
	eor R0,R0,R1
	movs R4,#0
	bl hamm
	str R4,[R2]
L: b L
