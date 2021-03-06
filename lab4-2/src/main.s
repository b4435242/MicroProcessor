.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr: .byte 0x00, 0x06, 0x01, 0x06, 0x00, 0x09, 0x05

.text
	.global main
	//GPIO
	.equ	RCC_AHB2ENR,	0x4002104C
	.equ	GPIOA_MODER,	0x48000000
	.equ	GPIOA_OTYPER,	0x48000004
	.equ	GPIOA_OSPEEDER,	0x48000008
	.equ	GPIOA_PUPDR,	0x4800000C
	.equ	GPIOA_IDR,		0x48000010
	.equ	GPIOA_ODR,		0x48000014  //PA5 6 7 output mode
	.equ	GPIOA_BSRR,		0x48000018 //set bit -> 1
	.equ	GPIOA_BRR,		0x48000028 //clear bit -> 0
	//Din, CS, CLK offset
	.equ 	DIN,	0b100000 	//PA5
	.equ	CS,		0b1000000	//PA6
	.equ	CLK,	0b10000000	//PA7
	//max7219
	.equ	DECODE,			0x19 //decode control
	.equ	INTENSITY,		0x1A //brightness
	.equ	SCAN_LIMIT,		0x1B //how many digits to display
	.equ	SHUT_DOWN,		0x1C //shut down -- we did't use this
	.equ	DISPLAY_TEST,	0x1F //display test -- we did' use this
	.equ	one_sec, 1000000
main:
	BL GPIO_init
	BL max7219_init

Display0toF:

	ldr r8, =arr //把arr的位址load到r8
	mov r10, #0  //r10為計算現在在學號的第幾個數字
	mov r11, #7	 //r11為要使用7段顯示器的第幾個數

	loop:
		mov r0, r11  //把r11mov到r0 r0為等等傳進max7219send的高8個byte
		ldrb r1, [r8,r10] //r1則設定為arr的位址+counter(r10) 為後8個byte
		bl MAX7219Send
		add r10, r10, #1 //每執行完一次則把r10+1，讓下次做的是下一個學號數字
		sub r11, r11, #1 //R11+1,下個要顯示的數字要在下一個7段顯示器內
		cmp r11, #0 	//若r11=0則代表輸入完畢
		beq Display0toF
		b loop

GPIO_init:
	ldr r0, =RCC_AHB2ENR
	mov r1, 0b1
	str r1, [r0]

	//enable GPIO PA7,6,5 for output mode=01
	ldr r0, =GPIOA_MODER
	ldr r2, =0xABFF57FF  //0xFFFF 01 01 01 (765) 11 FF
	str r2, [r0]

	//default low speed, set to high speed=10
	ldr r0, =GPIOA_OSPEEDER
	ldr r1, =0x0000A800 //1010 10(765)00 00
	str r1, [r0]



	//GPIOA_MODER: PA7 6 5: output
	ldr r0, =0b010101
	lsl r0, 10
	ldr r1, =GPIOA_MODER
	ldr r2, [r1]
	and r2, 0xFFFF03FF //clear 7 6 5
	orrs r2, r2, r0 //7 6 5  --> output
	str r2, [r1]

	BX LR
MAX7219Send:
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =DIN
	ldr r2, =CS
	ldr r3, =CLK
	ldr r4, =GPIOA_BSRR
	ldr r5, =GPIOA_BRR
	ldr r6, =0xF

send_loop:
	mov r7, #1
	lsl r7, r7, r6
	str r3, [r5]
	tst r0, r7
	beq bit_not_set
	str r1, [r4]
	b if_done

bit_not_set:
	str r1, [r5]

if_done:
	str r3, [r4]
	sub r6, r6, #1
	cmp r6, 0
	bge send_loop
	str r2, [r5]
	str r2, [r4]
	bx lr

max7219_init:

	push {LR}
	ldr r0, =DECODE
	ldr r1, =0xFF
	bl MAX7219Send

	ldr r0, =DISPLAY_TEST
	ldr r1, =0x0 //normal operation
	bl MAX7219Send

	ldr r0, =INTENSITY
	ldr r1, =0xA // 21/32 (brightness)
	bl MAX7219Send

	ldr r0, =SCAN_LIMIT
	ldr r1, =0x6
	bl MAX7219Send

	ldr r0, =SHUT_DOWN
	ldr r1, =0x1 //normal operation
	bl MAX7219Send

	pop {lr}
	bx lr




