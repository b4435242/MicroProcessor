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

main:
	BL GPIO_init
	MOVS R1, #0b00001100
	LDR R0,=leds
	STRB R1, [R0]
	mov r3,#0
	mov r4,#1
Loop:
	//TODO: Write the display pattern into leds variable
	BL DisplayLED
	BL Delay
	B Loop

GPIO_init:
	//TODO: Initial LED GPIO pins as output BX LR
	ldr r0,=RCC_AHB2ENR
	ldr r1,[r0]
	mov r1,#0x2
	str r1,[r0]

	ldr r0,=GPIOB_MODER
	ldr r1,[r0]
	mov r2,#0xFFFFD57F //PB 3 4 5 6
	str r2,[r0]
	ldr r1,[r0]

	ldr r0,=GPIOB_OSPEEDR
	mov r1,#0x00002A80
	str r1,[r0]
	bx lr

DisplayLED:
	//TODO: Display LED by leds BX LR
	ldr r0,=leds
	ldr r1,[r0]
	ldr r9,=GPIOB_ODR
	eor r1,#0xFF
	strh r1,[r9]
	eor r1,#0xFF
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


Delay:
	//TODO: Write a delay 1 sec function
	LDR r5, =#500000
	L1:
		sub r5,#1
		cmp r5,#0
		bne L1
	BX LR
