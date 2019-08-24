		.orig x3000
BEGIN		ld r6 , SCOPE_STACK		; load initial stack pointer
		ld r5 , DATA_STACK		; load initial frame pointer
		br MAIN_MSG

SCOPE_STACK    	.fill x4000
DATA_STACK	.fill x5000
N_STORE		.blkw 1
M		.fill #4

MSG_ENTER_N	.stringz "\nFirst enter N"

MAIN_MSG	lea r0 , MSG_ENTER_N
		puts
MAIN		jsr INPUT
		jsr CHECK_N
		st r4 , N_STORE
		br INPUT_N_DONE

INPUT_N_DONE	lea r0 , MSG_N_DONE
		puts
MENU		lea r0 , MSG_MENU
		puts
		MSG_MENU .stringz "\n1 N again\n2 Higher value\n3 Descending Sort\n4 Halt"					;
		halt	; end program
		MSG_N_DONE .stringz "\nN ok!"

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
N_LOW		.fill #15
N_HIGH		.fill #30

NOT_IN_RANGE	lea r0 , MSG_ERROR_N
		puts
		br MAIN
MSG_ERROR_N     .stringz "\nError: 15 <= N <= 30"

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
.end