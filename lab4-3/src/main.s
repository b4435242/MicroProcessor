.syntax unified
	.cpu cortex-m4
	.thumb

.data
	arr: .word 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233 , 377,610 ,987 , 1597 ,2584 , 4181 ,6765 , 10946 , 17711 , 28657 , 46368 , 75025 , 121393 , 196418 , 317811 , 514229 , 832040 , 1346269 , 2178309 , 3524578 , 5702887 , 9227465 , 14930352 , 24157817 , 39088169 , 63245986


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

	.equ GPIOC_MODER  , 0x48000800
    .equ GPIOC_OTYPER ,	0x48000804
    .equ GPIOC_OSPEEDR,	0x48000808
    .equ GPIOC_PUPDR  ,	0x4800080c
    .equ GPIOC_IDR    , 0x48000810

    .equ 	DIN,	0b100000 	//PA5
	.equ	CS,		0b1000000	//PA6
	.equ	CLK,	0b10000000	//PA7

	//max7219
	.equ	DECODE,			0x19 //decode control
	.equ	INTENSITY,		0x1A //brightness
	.equ	SCAN_LIMIT,		0x1B //how many digits to display
	.equ	SHUT_DOWN,		0x1C //shut down -- we did't use this
	.equ	DISPLAY_TEST,	0x1F //display test -- we did' use this

	//timer
	.equ	one_sec,		100 //try and error
	.equ	long, 			100000

main:
	BL GPIO_init
	BL max7219_init
	mov r12, #0
	mov r10, #0

Display_fib:
	mov r6, #0

	cmp r12, #39
	it le
	ldrle r1, =0x7

	cmp r12, #35
	it le
	ldrle r1, =0x6

	cmp r12, #30
	it le
	ldrle r1, =0x5

	cmp r12, #25
	it le
	ldrle r1, =0x4

	cmp r12, #20
	it le
	ldrle r1, =0x3

	cmp r12, #16
	it le
	ldrle r1, =0x2

	cmp r12, #11
	it le
	ldrle r1, =0x1

	cmp r12, #6
	it le
	ldrle r1, =0x0

	cmp r12, #40
	it ge
	ldrge r1, =0x1

	ldr r0, =SCAN_LIMIT
	bl MAX7219Send
	cmp r12, #40
	blt display_loop
	b check_end
display_loop:

	ldr r11, =arr
	mov r9,#4
	mul r9 , r12 ,r9
	ldr r11, [r11, r9]
	b check_end
check_end:
	mov r2,r1
	adds r2, r2, #1 //�ѩ�r1�O0-7�]��r2�n+1�ܦ�1-8
	mov r0, #1		//r0=1
	b light
light:
	cmp r12, #40	//�Yr12=40�h����minus_one��loop
	bge minus_one
	mov r3, #10
	cmp r0, r2 		//�Yr0��r2�ۦP�N��Ҧ���Ƴ���ܧ���
	bgt check_button
	udiv r5, r11, r3 	//r5=r11/10 (r11��������ܪ��Ʀr) r5��r11���H10���Ӽ�
	mul r4, r5, r3 		//r4=r5*10
	subs r1, r11, r4 	//r1=r11-r4 (r1��r11���H10���l�ơA�]�N�O�n�L�X���Ʀr)
	udiv r11, r11, r3 	//��r11���H10�A�@���U����ӹB�⪺r11 (�� 123->12)
	bl MAX7219Send		//��r0(�ĴX�Ӧ��)��r1(��X����)�ǤJ����ܾ��B�@
	adds r0, r0, #1 	//r0+1 (�U���i�Ӯ���ܪ��|�O�U�@����ܾ�)(�q�k�ܥ�)
	b light

minus_one:

	mov r0, #2 			//�Y���minus_one�N��w�g���F40���A��X��������-1
	mov r1, 0xA 		//���ڭ̬O��mod���覡�ӳB�z�Ʀr
	bl MAX7219Send		//�]���S��k�L�X�t���A�ҥH�ڭ̧�-1�S�O���X�Ӽg
	mov r0, #1
	mov r1, 0x1
	bl MAX7219Send
	b check_button

check_button:
	ldr r5, [r8]
	lsr r5, r5, #13
	and r5, r5, 0x1
	cmp r5, #0
	it eq
	addseq r10, r10, #1
	cmp r5, #1			//R5�Y�O1�hR10�k�s(R5=0�N��S���άO�٦b��í�w���q)
	it eq
	movseq r10, #0

	ldr r9, =one_sec	//R9=one_sec
	cmp r10, r9 		//�Yr10=one_sec�h�N����s�w�Q���U
	it eq
	movseq r6, #1

	ldr r9, =long		//r9=long
	cmp r10, r9 		//�Yr10=long�h�N����s�Q����
	it ge
	movsge r6, #2 		//r6�]��2
	//beq clear_to_zero

	cmp r6, #1			//�Y���s�Q���U�hr12+1(r12�������s���p�ƾ�)
	itt eq 				//����^�hdisplay_fib���s�˵��U�ӼƦr�ݭn�h�֦��
	addeq r12, r12, #1
	beq Display_fib

	cmp r6, #2			//�Y���s�������h��r12�]��0(�]���|��X0)
	itt eq
	moveq r12, #0
	beq Display_fib

	mov r6,#0
	b check_button

GPIO_init:
	//enable GPIO port A
	ldr r0, =RCC_AHB2ENR
	mov r1, 0b101
	str r1, [r0]

	//enable GPIO PA7,6,5 for output mode=01
	ldr r0, =GPIOA_MODER
	ldr r2, =0xABFF57FF  //0xFFFF 01 01 01 (765) 11 FF
	str r2, [r0]

	//default low speed, set to high speed=10
	ldr r0, =GPIOA_OSPEEDER
	ldr r1, =0x0000A800 //1010 10(765)00 00
	str r1, [r0]

	ldr r0, =GPIOC_MODER
	ldr r1, [r0]
	//clear pc13 to zero
	and r1, r1, 0xf3ffffff
	str r1,	[r0]

	ldr r8, =GPIOC_IDR
	BX LR

MAX7219Send:
	push {r0, r1, r2, r3, r4, r5, r6, r7, LR}
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
	pop {r0, r1, r2, r3, r4, r5, r6, r7, PC}
	bx lr

max7219_init:
	push {lr}
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
	ldr r1, =0x0
	bl MAX7219Send

	ldr r0, =SHUT_DOWN
	ldr r1, =0x1 //normal operation
	bl MAX7219Send

	pop {lr}
	bx lr
