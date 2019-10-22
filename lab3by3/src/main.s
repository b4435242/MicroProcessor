.syntax unified
.cpu cortex-m4
.thumb

.data
	password: .byte 0b1111

.text
	.global main
	.equ RCC_AHB2ENR ,0x4002104C
	.equ GPIOB_ODR ,0x48000414
	.equ GPIOB_MODER ,0x48000400
	.equ GPIOB_OSPEEDR ,0x48000408

	.equ GPIOC_MODER ,0x48000800
	.equ GPIOC_IDR ,0x48000810
	.equ GPIOC_PUPDR ,0x4800080C

	.equ GPIOA_MODER ,0x48000000
	.equ GPIOA_IDR ,0x48000010
	.equ GPIOA_PUPDR ,0x4800000C

main:
	bl GPIO_init
	mov r1,#0xFFFF
	str r1,[r9]
	b Check


GPIO_init:
	ldr r0,=RCC_AHB2ENR
	mov r1,#0x6
	str r1,[r0]

	ldr r0,=GPIOC_MODER
	ldr r1,=#0xF3FC03FF //PC 13 5678
	mov r2,r1

	str r2,[r0]

	ldr r0,=GPIOC_PUPDR
	ldr r1,=#0xF7FFFFFF //pull-up F7FD57FF
	mov r2,r1
	str r2,[r0]

	ldr r0,=GPIOB_MODER
	mov r2,#0xFFFFD57F //PB 3 4 5 6
	str r2,[r0]

	ldr r8,=GPIOC_IDR
	ldr r9,=GPIOB_ODR
	//ldr r10,=GPIOA_IDR

	ldr r0,=GPIOB_OSPEEDR
	mov r1,#0x00002A80
	str r1,[r0]


	/*ldr r0,=GPIOA_MODER
	ldr r1,=#0xFFC3FF0F //PA 2 3 9 10
	ldr r2,[r0]
	and r2,r1
	str r2,[r0]

	ldr r0,=GPIOA_PUPDR
	ldr r1,=#0x140050 //pull-up
	ldr r2,[r0]
	orr r1,r2
	str r1,[r0]*/


	bx lr

Check:
	mov r6,#0
	Pool:
		ldr r1,[r8]
		mov r0,#1
		lsl r0,#13
		and r1,r0
		cmp r1,#0
		beq BottonPush
		ButtonPull:
			sub r6,#1
			cmp r6,#0
			bgt Reset
			cmp r6,#-100
			bne Pool
			b Check

		BottonPush:
			add r6,#1
			cmp r6,#0
			blt Reset
			cmp r6,#100
			beq End
			b Pool
			End:
				eor r7,#1
				b Verify
		Reset:
				mov r6,#0
				b Pool


Verify:
	ldr r1,[r8]
	mov r2,#0x1E0 //5 6 7 8
	and r1,r2
	ldr r0,=password
	ldrb r2,[r0]

	lsr r1,#5
	eor r1,r2
	cmp r1,#0
	beq AC
	b WA

	/*compare:
		mov r3,r1
		eor r3,r2
		mov r4,0b11
		and r5,r3
		cmp r5,#0
		it ne
		movne r0,#0

	lsr r1,#7
	lsr r2,#2
	b compare

	cmp r0,#0
	beq WA
	b AC*/

WA:
	mov r0,#0b10000111
	str r0,[r9]
	mov r5,#50000
	bl Delay
	mov r0,#0b11111111
	str r0,[r9]
	LDR r5, =#250000
	bl Delay
	b Check

AC:
	mov r3,#0

	blink:
	add r3,#1
	mov r0,#0b10000111
	str r0,[r9]
	mov r5,#50000
	bl Delay
	mov r0,#0b11111111
	str r0,[r9]
	LDR r5, =#250000
	bl Delay
	cmp r3,#3
	blt blink
	b Check


Delay:
	//TODO: Write a delay 1 sec function
	//LDR r5, =#500000
	L1:
		sub r5,#1
		cmp r5,#0
		bne L1
	BX LR
