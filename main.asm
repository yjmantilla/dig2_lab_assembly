		.orig x3000
BEGIN		ld r6 , SCOPE_STACK		; load initial stack pointer
		ld r5 , DATA_STACK		; load initial frame pointer
		br MAIN

SCOPE_STACK    	.fill x4000
DATA_STACK	.fill x5000
N_STORE		.blkw 1
N_LOW		.fill #15
N_HIGH		.fill #30
M		.fill #4
MSG_N           .stringz "\nError: 15 <= N <= 30"

MAIN					
		jsr INPUT_N
		br FINISH


INPUT_N		; push r7 so we dont lose where we came from
		;jsr PUSH_R7 bad idea
		;add r6, r6 , #1
		;str r7, r6 , #0
		add r1 , r7 , #0
		jsr PUSH_R1_SCOPE 
INPUT_N_NO_PUSH	lea r0 , MSG_ENTER_N
		
		; we dont need to push r7 so as long we
		; dont go to something that also goes to a subroutine

		MSG_ENTER_N .stringz "\nEnter N:"

		puts
		
		; R1 will be aux dummy reg
		; R2 will indicate if the number is negative or not
		; R4 will be accumulator, at the end will hold the final number
		
		and r2 , r2 , x0000
		and r4 , r4 , x0000
		
INPUT_N_I	getc	; gets c in r0
		
		
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
		brn INPUT_N_I
		; we are already sure it is not lower
		; if it was a number we are now within 0 - 9
		; substract 9, if positive it was not a number
		add r1 , r1 , #-9
		brp INPUT_N_I	

		;convert to number
		and r0 , r0 , xF	
 		
		; accumulate, check overflow in each step	
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

		

		br INPUT_N_I
		
NEGATIVE	not r2 , r2
		br INPUT_N_I		

OVERFLOW	lea r0 , MSG_OVERFLOW
		MSG_OVERFLOW .stringz "\nOverflow, try with a lower number."

		puts
		br INPUT_N_NO_PUSH

NOT_IN_RANGE	lea r0 , MSG_N
		puts
		br INPUT_N_NO_PUSH
		
INPUT_N_READY	; pop r7 to return (pop stack)
		
		;jsr POP_R7 bad idea
		;ldr r7, r6, #0
		;add r6, r6, #-1
		jsr POP_R1_SCOPE
		add r7 , r1 , #0
		add r0 , r4 , #0
		st r4 , N_STORE

		ret	; go home boy

YES_ENTER 	; if enter was first char, it will just assume thats a 0
		

		
		; check if we need to negate
		
		; prepare to negate
		add r1 , r4 , #0
		add r2 , r2 , #0
		brz DONT_NEGATE
		not r1 , r1
		add r1 , r1 , #1
		; either way we have the correct stuff in r1
		; move it back to r4
DONT_NEGATE	add r4 , r1 , #0

		; check range
		
		ld r1 , N_LOW
		jsr NEGATE_R1
		add r1 , r4 , r1
		brn NOT_IN_RANGE

		ld r1 , N_HIGH
		jsr NEGATE_R1
		add r1 , r4 , r1
		brp NOT_IN_RANGE

		; else we are ready to go
		br INPUT_N_READY

NEGATE_R1	; places in r1 the 2complement of r1
		not r1 , r1
		add r1 , r1 , #1
		ret
		
FINISH		lea r0 , MSG_END
		puts					;
		halt	; end program
		MSG_END .stringz "\nImma halting"

;LIFO STACK
PUSH_R1_SCOPE	;r6 is used as stack register
		add r6, r6, #1
		str r1, r6, #0
		ret	

POP_R1_SCOPE	;r6 used as an stack register
		ldr r1, r6, #0
		add r6, r6, #-1
		ret
.end