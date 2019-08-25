		.orig x3000
BEGIN		ld r6 , SCOPE_STACK		; load initial stack pointer
		ld r5 , DATA_STACK		; load initial frame pointer
		br MAIN_MSG

SCOPE_STACK    	.fill x4000
DATA_STACK	.fill x4100
N_STORE		.blkw 1
M		.fill #4
DATA_STORE 	.blkw #31 ; because push pushes in the next



MSG_ENTER_N	.stringz "\n\nFirst enter N"
MSG_ENTER_NUM	.stringz "\n\nEnter nums"


MAIN_MSG	lea r0 , MSG_ENTER_N
		puts
MAIN		jsr INPUT
		jsr CHECK_N
		st r4 , N_STORE
		br INPUT_N_DONE
NUM_DONE	lea r0 , MSG_NUM_OK
		puts	
		br MENU
		MSG_NUM_OK .stringz "\nNum ok!"
INPUT_N_DONE	lea r0 , MSG_N_OK
		puts
		lea r0, MSG_ENTER_NUM
		puts
		br ENTER_NUM
		MSG_N_OK .stringz "\nN ok!"
MENU		lea r0 , MSG_MENU	;Shows menu and ask for option
		puts
		MSG_MENU .stringz "\n\nMENU\n\n1 N again\n2 Higher value\n3 Descending Sort\n4 Halt\n\nEnter op."
		jsr INPUT	; r4 now has option
		add r1 , r4 , #-4
		brz EXIT
		add r1 , r4 , #-1
		brz MAIN_MSG
		add r1 , r4 , #-2
		brz HIGH_VAL
		add r1 , r4 , #-3
		brz SORT
		; else invalid option
		br MENU	
WHAT		lea r0 , MSG_WHAT
		puts
		MSG_WHAT .stringz "\nWrong Input!"
		br MENU	
EXIT		halt	; end program
HIGH_VAL	halt
SORT		halt
		
ENTER_NUM	;let r3 be the counter
		ld r3 , N_STORE
		lea r5 , DATA_STORE
ENTER_NUM_LOOP	add r3 , r3 , #-1
		brn NUM_DONE
		jsr INPUT
		add r1 , r4 , #0
		jsr PUSH_R1_DATA
		br ENTER_NUM_LOOP				
		
NOT_IN_RANGE	lea r0 , MSG_ERROR_N
		puts
		br MAIN
MSG_ERROR_N     .stringz "\nError: 15 <= N <= 30"
N_LOW		.fill #1 ;15
N_HIGH		.fill #3 ;30
CHECK_N		; check range for N
		; assumes N in r4
		add r1 , r7 , #0
		jsr PUSH_R1_SCOPE
		
		ld r1 , N_LOW
		jsr NEGATE_R1
		add r1 , r4 , r1
		brn NOT_IN_RANGE

		ld r1 , N_HIGH
		jsr NEGATE_R1
		add r1 , r4 , r1
		brp NOT_IN_RANGE
		
		jsr POP_R1_SCOPE
		add r7 , r1 , #0
		; else we are ready to go
		ret

INPUT		; subroutine, leaves stuff in r4
		; push r7 so we dont lose where we came from
		add r1 , r7 , #0 ; since PUSH_R1 pushes R1
		jsr PUSH_R1_SCOPE 


INPUT_NO_PUSH	lea r0 , MSG_ENTER
		
		; we dont need to push r7 so as long we
		; dont go to something that also goes to a subroutine

		MSG_ENTER .stringz "\nEnter it:"

		puts
		
		; R1 will be aux dummy reg
		; R2 will indicate if the number is negative or not
		; R4 will be accumulator, at the end will hold the final number
		
		and r2 , r2 , x0000
		and r4 , r4 , x0000
		
INPUT_I		getc	; gets c in r0
		
		
		add r1 , r0 , #-10	; check if enter was pressed
		brz YES_ENTER
		out	; echo what is in r0 (if not enter)
		
		; check if it is a negative number (-) (45)
		add r1 , r0 , #-15
		add r1 , r1 , #-15
		add r1 , r1 , #-15
		brz NEGATIVE
		

		; check if it is a number indeed
		add r1 , r0 , #0	; copy r0 in r1
		; check it is a number
		; first substract 48, if negative it is lower
		add r1 , r1 , #-16
		add r1 , r1 , #-16
		add r1 , r1 , #-16
		brn INPUT_I
		; we are already sure it is not lower
		; if it was a number we are now within 0 - 9
		; substract 9, if positive it was not a number
		add r1 , r1 , #-9
		brp INPUT_I	

		;convert to number
		and r0 , r0 , xF
			
 		
ACCUM		; accumulate, check overflow in each step	
		add r1 , r4 , #0 ; r1 <- 1 r4
		brn OVERFLOW
		add r4 , r4 , r4 ; r4 <- 2 r1
		brn OVERFLOW
		add r4 , r4 , r4 ; r4 <- 4 r1
		brn OVERFLOW
		add r4 , r4 , r1 ; r4 <- 5 r1
		brn OVERFLOW
		add r4 , r4 , r4 ; r4 <- 10 r1
		brn OVERFLOW		
		add r4 , r4 , r0 ; r4 <= 10 r1 + r0
		brn OVERFLOW
		
		; check overflow for bubblesort-comparisons
		add r1 , r4 , r4 ; 2 times the number have to be representable
		brn OVERFLOW_BUBBLE

		br INPUT_I
		
NEGATIVE	not r2 , r2
		br INPUT_I		

OVERFLOW	lea r0 , MSG_OVERFLOW
		MSG_OVERFLOW .stringz "\nOverflow, try with a lower number."
		puts
		br INPUT_NO_PUSH
OVERFLOW_BUBBLE lea r0 , MSG_B_OVERFLOW
		MSG_B_OVERFLOW .stringz "\nOverflow for comparison, try with a lower number."
		puts
		br INPUT_NO_PUSH
		
INPUT_READY	; pop r7 to return (pop stack)
		
		jsr POP_R1_SCOPE
		add r7 , r1 , #0
		add r0 , r4 , #0
		

		ret	; go home boy

YES_ENTER 	; if enter was first char, it will just assume thats a 0
	
		; check if we need to negate
		add r1 , r4 , #0
		add r2 , r2 , #0
		brz DONT_NEGATE
		not r1 , r1
		add r1 , r1 , #1
		; either way we have the correct stuff in r1
		; move it back to r4
DONT_NEGATE	add r4 , r1 , #0
		br INPUT_READY







NEGATE_R1	; places in r1 the 2complement of r1
		not r1 , r1
		add r1 , r1 , #1
		ret


;LIFO STACK uses r1 as auxiliar register
PUSH_R1_SCOPE	;r6 is used as stack register
		add r6, r6, #1
		str r1, r6, #0
		ret	

POP_R1_SCOPE	;r6 used as an stack register
		ldr r1, r6, #0
		add r6, r6, #-1
		ret
PUSH_R1_DATA	;r5 us used as stack register
		add r5 , r5, #1
		str r1 , r5 ,#0
		ret
POP_R1_DATA	ldr r1 , r5 , #0
		add r5 , r5 ,#-1
; Multiplies two integers.
;
; Preconditions: The number in R1 is multiplied with the number in R2.
; Postconditions: The number in R1 will be the product.
;
MUL	ST R0, MUL_R0
	ST R2, MUL_R2
	ST R3, MUL_R3
	AND R3, R3, #0	; R3 holds flag for negative
	ADD R1, R1, #0
	BRn MUL_NEG_1	; If operand 1 is negative, flip flag
MUL_CHECK_NEG_2
	ADD R2, R2, #0
	BRn MUL_NEG_2	; And if operand 2 is negative
MUL_POST_CHECK_NEG	; Now we know our arguments are positive
	AND R0, R0, #0	; R0 holds original number (absolute value)
	ADD R0, R0, R1
	AND R1, R1, #0	; R1 to 0 so adding R0 R2 times gives correct result
	BRnzp MUL_LOOP
MUL_NEG_1 ; First operand is negative
	NOT R3, R3	; Negative flag is negative when answer is negative
	NOT R1, R1	; Negate operand 1 (both numbers must be positive)
	ADD R1, R1, #1
	BRnzp MUL_CHECK_NEG_2
MUL_NEG_2 ; Second operand is negative
	NOT R3, R3
	NOT R2, R2	; Negate operand 2
	ADD R2, R2, #1
	BRnzp MUL_POST_CHECK_NEG
MUL_LOOP
	ADD R2, R2, #-1
	BRn MUL_POST_LOOP
	ADD R1, R1, R0	; Add R1 to itself (original saved in R0) R2 times
	BRnzp MUL_LOOP
MUL_POST_LOOP
	ADD R3, R3, #0
	BRzp MUL_CLEANUP	; If negative flag not set
	NOT R1, R1		; If it is, negate answer
	ADD R1, R1, #1
MUL_CLEANUP
	LD R0, MUL_R0
	LD R2, MUL_R2
	LD R3, MUL_R3
	RET
MUL_R0	.FILL 0
MUL_R2	.FILL 0
MUL_R3	.FILL 0
.end