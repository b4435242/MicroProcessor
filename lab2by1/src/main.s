.syntax unified
.cpu cortex-m4
.thumb

.data
	user_stack: .zero 128
	expr_result:.word 0

.text
.global main
	postfix_expr: .asciz "1 -1 + " //"-100 10 20 + - 10 +"//

main:
	LDR R0, =postfix_expr
	//TODO: Setup stack pointer to end of user_stack and calculate the expression using PUSH, POP operators, and store the result into expr_result
	ldr r10,=expr_result
	ldr sp,=user_stack
	add sp,#128
	mov r1,#-1	//index for asciz
	mov r8,#10
	mov r9,#-1
	B function


function:
	add r1,#1
	ldrb r2,[r0,r1] //char of asciz
	cmp r2,#0
	beq function_end
	cmp r2,#32
	beq function
	cmp r2,#43
	beq add_op
	cmp r2,#45
	beq check
	bl atoi
	push {r4}
	b function

function_end:
	pop {r1}
	str r1,[r10]
	b program_end

check:
	add r1,#1
	ldrb r2,[r0,r1] //lookahead

	cmp r2,#32
	beq sub_op
	bl atoi
	mul r4,r4,r9
	push {r4}
	b function

add_op:
	pop {r5,r6}
	add r6,r5
	push {r6}
	b function

sub_op:
	pop {r5,r6}
	sub r6,r5
	push {r6}
	b function

atoi:
	//TODO: implement a �onvert string to integer�� function BX LR
	sub r2,#48
	mov r4,r2
	b endcheck
	parse:
		sub r2,#48
		mul r4,r4,r8
		add r4,r2
		b endcheck
	endcheck:
		add r1,#1
		ldrb r2,[r0,r1]
		cmp r2,#48
		bge parse
		bx lr


program_end:
	B program_end
