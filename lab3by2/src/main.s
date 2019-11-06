.syntax unified
.cpu cortex-m4
.thumb

.data
	leds: .byte 0

.text
	.global main
	.equ RCC_AHB2ENR ,0x4002104C
	.equ GPIOB_ODR ,0x48000414
	.equ GPIOB_MODER ,0x48000400
	.equ GPIOB_OSPEEDR ,0x48000408

	.equ GPIOC_MODER ,0x48000800
	.equ GPIOC_IDR ,0x48000810
	.equ GPIOC_PUPDR ,0x4800080C

main:
	BL GPIO_init
	MOVS R1, #0b00001100
	LDR R0,=leds
	STRB R1, [R0]
	mov r3,#0
	mov r11,#1
	//push {r10}
	mov r7,#1
Loop:
	//TODO: Write the display pattern into leds variable
	bl Check
	BL DisplayLED
	BL Delay
	B Loop

/*Check:
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
			bx lr

		BottonPush:
			add r6,#1
			cmp r6,#0
			blt Reset
			cmp r6,#100
			beq End
			b Pool
			End:
				eor r7,#1
				bx lr
		Reset:
				mov r6,#0
				b Pool*/

Check:
	mov r6,#0
	mov r5,#0
	Pool:
		ldr r1,[r8]
		mov r0,#1
		lsl r0,#13
		and r1,r0
		cmp r1,#0
		it eq
		addeq r6,#1
		cmp r1,#0
		it ne
		subne r6,#1

		add r5,#1
		cmp r5,#100
		blt Pool

		cmp r6,#100
		it eq
		moveq r10,#0
		cmp r6,#-100
		it eq
		moveq r10,#1

		//pop {r0}
		//push {r10}
		sub r0,r11,r10
		cmp r0,#1
		it eq
		eoreq r7,#1
		mov r11,r10

		bx lr

GPIO_init:
	//TODO: Initial LED GPIO pins as output BX LR
	ldr r0,=RCC_AHB2ENR
	ldr r1,[r0]
	mov r1,#0x6
	str r1,[r0]

	ldr r0,=GPIOC_MODER
	mov r1,#0xF3FFFFFF //PC 13
	str r1,[r0]

	ldr r0,=GPIOC_PUPDR
	mov r1,#0xF7FFFFFF //pull-up
	str r1,[r0]

	ldr r0,=GPIOB_MODER
	mov r2,#0xFFFFD57F //PB 3 4 5 6
	str r2,[r0]

	ldr r8,=GPIOC_IDR
	ldr r9,=GPIOB_ODR

	ldr r0,=GPIOB_OSPEEDR
	mov r1,#0x00002A80
	str r1,[r0]
	bx lr

DisplayLED:
	//TODO: Display LED by leds BX LR
	ldr r0,=leds
	ldr r1,[r0]
	eor r1,#0xFF
	strh r1,[r9]
	eor r1,#0xFF
	cmp r7,#0
	beq StopMoving
	mov r4,#1
	cmp r3,#4
	blt shiftleft
	//b shiftright
	shiftright:
		LSR r1,r4
		b end
	shiftleft:
		LSL r1,r4
	end:
		strb r1,[r0]
		add r3,#1
		cmp r3,#8
		beq reset
		bx lr
	reset:
		mov r3,#0
		bx lr
	StopMoving:
		bx lr


Delay:
	//TODO: Write a delay 1 sec function
	LDR r5, =#500000
	L1:
		sub r5,#1
		cmp r5,#0
		bne L1
	BX LR
