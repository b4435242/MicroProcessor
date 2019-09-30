	.syntax unified
	.cpu cortex-m4
	.thumb
.text
.global main
.equ N,10
fib:
	cmp r0, #101
	bge return
	cmp r0, #0
	ble return
	movs r4,#1
	cmp r0, #1
	beq return0
	cmp r0, #2
	beq return0
	movs r5, #2
	movs r1, #1
	movs r2, #1
	loop:
		adds r4,r1,r2
		bvs  ovfreturn
		add r5,r5,#1
		movs r1,r2
		movs r2,r4
		cmp r5,r0
		blt loop
	return0:
		bx lr
	return:
		movs r4,#0
		subs r4,r4,#1
		bx lr
	ovfreturn:
		movs r4,#0
		subs r4,r4,#2
		bx lr
main:

	movs r0, #N

	bl fib
	mov r0,1
L: b L
