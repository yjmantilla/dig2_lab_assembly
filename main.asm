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
		jsr FINISH


INPUT_N		; push r7 so we dont lose where we came from
		add r6, r6, #1
		str r7, r6, #0
		
INPUT_N_NO_PUSH	lea r0 , MSG_ENTER_N
		
		; we dont need to push r7 so as long we
		; dont go to something that also goes to a subroutine

		MSG_ENTER_N .stringz "\nEnter N:"

		puts
		
		; R1 will be aux dummy reg
		; R2 will indicate if the number is negative or not
		; R3 will be aux reg that counts how many stuff have we entered
		; R4 will be accumulator
		
		and r3 , r3 , x0000
		and r2 , r2 , x0000
		and r4 , r4 , x0000
		
INPUT_N_I	getc	; gets c in r0
		out	; echo what is in r0 (if not enter)
		
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
 		
		;accumulate		
		add r1 , r4 , #0 ; r1 <- 1 r4
		add r4 , r4 , r4 ; r4 <- 2 r1
		add r4 , r4 , r4 ; r4 <- 4 r1
		add r4 , r4 , r1 ; r4 <- 5 r1
		add r4 , r4 , r4 ; r4 <- 10 r1		
		add r4 , r4 , r0 ; r4 <= 10 r1 + r0

		; check overflow
		brn OVERFLOW

		add r3 , r3 , #1

		br INPUT_N_I
		
		

OVERFLOW	lea r0 , MSG_OVERFLOW
		MSG_OVERFLOW .stringz "\nOverflow, try with a lower number."

		puts
		br INPUT_N_NO_PUSH

NOT_IN_RANGE	lea r0 , MSG_N
		puts
		br INPUT_N_NO_PUSH
		
INPUT_N_READY	; pop r7 to return (pop stack)
		
		ldr r7 , r6 , #0
		add r6 , r6 , #-1
		add r0 , r4 , #0
		st r4 , N_STORE

		ret	; go home boy

YES_ENTER 	; check if that was the first char
		;add r3 , r3 , #0
		;brz INPUT_N_I
		; not needed anymore, it will just assume thats a 0
		
		; check range
		
		ld r1 , N_LOW
		not r1 , r1
		add r1 , r1 , #1
		add r1 , r4 , r1
		brn NOT_IN_RANGE

		ld r1 , N_HIGH
		not r1 , r1
		add r1 , r1 , #1
		add r1 , r4 , r1
		brp NOT_IN_RANGE
		
		; else we are ready to go
		br INPUT_N_READY

FINISH		lea r0 , MSG_END
		puts					;
		halt	; end program
		MSG_END .stringz "\nImma halting"

;LIFO STACK
;PUSH		;r6 is used as an auxiliar register
;		add r6, r6, #+1
;		str r7, r6, #0
;		ret	

;POP		;r6 used as an auxiliar register
;		ldr r7, r6, #0
;		add r6, r6, #-1 
.end