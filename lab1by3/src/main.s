	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
.text
.global main

do_sort:
	//TODO
	ldr r1,=#8
	b outer

	outer:
		sub r1,#1
		ldr r2,=#0
		cmp r1,#1
		bge inner
		bx lr
		inner:
			ldrb r3,[r0,r2]
			add r2,#1
			ldrb r4,[r0,r2]
			cmp r3,r4
			bgt swap
			b inner_check
		swap:
			ldrb r5,[r0,r2]
			strb r3,[r0,r2]
			sub r2,#1
			strb r5,[r0,r2]
			add r2,#1
		b inner_check
		inner_check:
			cmp r2,r1
			blt inner
			b outer

main:
	ldr r0, =arr1
	bl do_sort
	ldr r0, =arr2
	bl do_sort

	mov r10,1

	L: b L
