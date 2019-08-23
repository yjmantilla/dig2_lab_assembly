		.orig x3000
BEGIN		ld r6 , SCOPE_STACK		; load initial stack pointer
		ld r5 , DATA_STACK	; load initial frame pointer
		BR INPUT_N

SCOPE_STACK    	.FILL x4000
DATA_STACK	.FILL x5000
N_LOW		.FILL #15
N_HIGH		.FILL #30
M		.FILL #4

MAIN					
		jsr INPUT_N
		jsr FINISH


INPUT_N		; routine that will put input in r0
		lea r0 , MSG_ENTER_N
		
		; push r7 so we dont lose where we came from
		add r6, r6, #1
		str r7, r6, #0
		
		; we dont need to push r7 so as long we
		; dont go to something that also goes to a subroutine

		MSG_ENTER_N .stringz "\nEnter N:"

		puts	; displays 
		
		; R1 will be aux dummy reg
		; R2 will indicate if the number is negative or not
		; R3 will be aux reg that counts how many stuff have we entered
		; R4 will be accumulator
		
		and r3 , r3 , x0000
		and r2 , r2 , x0000
		and r4 , r4 , x0000
		
INPUT_N_I	getc	; gets c in r0
		out	; echo what is in r0
		
		add r1 , r0 , #-10	; check if enter was pressed
		brz YES_ENTER

		; check if it is a number indeed
		add r1 , r0 , #0	; copy r0 in r1
		add r1 , r1 , #-16
		add r1 , r1 , #-16
		add r1 , r1 , #-16
		brn INPUT_N_I
		add r1 , r1 , #-9
		brp INPUT_N_I	

		;convert to number
		and r0 , r0 , xF	

		; save r0 given it is valid (push to data stack)
		;add r5, r5, #1
		;str r0, r5, #0
 		
		;accumulate		
		add r1 , r4 , #0 ; r1 <- 1 r4
		add r4 , r4 , r4 ; r4 <- 2 r1
		add r4 , r4 , r4 ; r4 <- 4 r1
		add r4 , r4 , r1 ; r4 <- 5 r1
		add r4 , r4 , r4 ; r4 <- 10 r1		
		add r4 , r4 , r0 ; r4 <= 10 r1 + r0

		; check overflow
		brn OVERFLOW
		
		;	

		add r3 , r3 , #1

		br INPUT_N_I
		
		

OVERFLOW	lea r0 , MSG_OVERFLOW
		MSG_OVERFLOW .stringz "\nOverflow, try with a lower number."

		puts	; displays
		br INPUT_N 
		
INPUT_N_READY	; pop r7 to return (pop stack)
		
		ldr r7 , r6 , #0
		add r6 , r6 , #-1
		add r0 , r4 , #0

		ret	; go home boy

YES_ENTER 	; check if that was the first char
		add r3 , r3 , #0
		brz INPUT_N_I
		
		; else we are ready to go
		br INPUT_N_READY

FINISH		lea r0 , MSG_END
		puts					;
		halt	; end program
		MSG_END .stringz "\nImma halting"

;LIFO STACK
PUSH		;r6 is used as an auxiliar register
		add r6, r6, #+1
		str r7, r6, #0
		ret	

POP		;r6 used as an auxiliar register
		ldr r7, r6, #0
		add r6, r6, #-1 
.end