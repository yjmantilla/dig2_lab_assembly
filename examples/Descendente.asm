		.orig x3000

		ldi r4 , N ; r4 <- N
		; FILE is the address of the data array

; Do the bubblesort
; Needs r4 with N
OUTERLOOP	add r4, r4, #-1 ; r4 counter outer loop
		brnz SORTED
		add r5, r4, #0	; r5 counter inner loop
		ld r3, FILE
INNERLOOP	LDR     R1, R3, #0  
      		LDR     R2, R3, #1  
       		NOT     R6, R2       
        	ADD     R6, R6, #1  
         	ADD     R6, R1, R6  ; swap = item - next item
		BRP    SWAPPED     
          	STR     R2, R3, #0  
           	STR     R1, R3, #1  
SWAPPED   	ADD     R3, R3, #1  
           	ADD     R5, R5, #-1 
          	BRP     INNERLOOP   
         	BRNZP   OUTERLOOP   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SORTED		br SHOW_PREP

		
SHOW_PREP	; Needs r3 with address of data array
		; Needs r4 with N
		ldi r4, N
		ld r3, FILE		; r3 <- address of data 

SHOW_LOOP	add r4, r4, #-1		
		brn SHOW_END	
		ldr r0, r3, #0
		jsr DISPD
		add r3, r3, #1
		br SHOW_LOOP

SHOW_END 	halt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAYOR		ld r3, N
		ldr r4, r3,#0 ; r4=N
		add r3,r3,r4
		ldr r1, r3,#0 ; r1 tiene el numero mayor 
		brnzp FIN

;MULTIPLOS
		

FIN		halt
N		.fill x3500	;N location
FILE		.fill x3501	;file location


;
; Takes a 2's complement integer and displays its DECIMAL representation.
;
; THIS FUNCTION IS DIRECTLY DERIVED FROM DISPLAY ABOVE.
; THE ONLY MODIFICATION IS SIMPLIFIED OUTPUT. THE ALGORITHM IS THE SAME.
; BLOCK COMMENTS HAVE BEEN REMOVED FOR REDUNDANCY AND SPACE SAVING.
;
DISPD	ADD R0, R0, #0
	BRnp DISPD_NON_ZERO
	LD R0, DISPD_0
	OUT
	RET
DISPD_NON_ZERO
	ST R0, DISPD_R0
	ST R1, DISPD_R1
	ST R2, DISPD_R2
	ST R3, DISPD_R3
	ST R4, DISPD_R4
	ST R5, DISPD_R5
	ST R7, DISPD_R7
	AND R1, R1, #0	; R1 holds current multiple of ten
	ADD R1, R1, #1
	AND R2, R2, #0	; R2 used by multiply and divide routines
	ADD R2, R2, #1
	AND R3, R3, #0	; R3 holds current power of ten
	AND R4, R4, #0	; R4 holds plurality of current multiple
	AND R5, R5, #0	; R5 holds original number from R0
	ADD R5, R5, R0	; (R0 needed for output)
	BRzp DISPD_LOOP_ASC
	NOT R5, R5
	ADD R5, R5, #1	; Negate to positive
	LD R0, DISPD_NEG	; Input is negative. Display negative sign.
	OUT
DISPD_LOOP_ASC
	AND R1, R1, #0
	ADD R1, R1, R5	; Set R1 to number
	JSR DIV		; How many times does ten*x go into number?
	BRz DISPD_LOOP_DESC	; If zero, then exit loop
	AND R1, R1, #0		; Otherwise, keep multiplying
	ADD R1, R1, #10
	JSR MUL		; Highest multiple of ten up by one
	ADD R3, R3, #1	; One more power of ten
	AND R2, R2, #0
	ADD R2, R2, R1	; Store in R2 for next loop
	BRnzp DISPD_LOOP_ASC
DISPD_LOOP_DESC
	AND R1, R1, #0
	ADD R1, R1, R2	; Here R1 is current multiple of ten we're looking at
	LD R4, DISPD_0
DISPD_LOOP_DESC_AGAIN
	AND R2, R2, #0
	ADD R2, R2, #10	; And R2 is used by DIV, 10 as we're moving down
	JSR DIV		; Divide our multiple of ten by ten
	ADD R3, R3, #-1	; One less power of ten
	AND R2, R2, #0
	ADD R2, R2, R1	; Now we have a multiple of ten in R2 (divisor)
	AND R1, R1, #0
	ADD R1, R1, R5	; So we get our input number in R1 (dividend)
	JSR DIV		; And see how many times the one fits in the other
; Here is where we actually display something
	ADD R0, R1, R4
	OUT
	JSR MUL		; Multiply power of ten by result of integer division
	NOT R1, R1
	ADD R1, R1, #1	; And negate result
	ADD R5, R5, R1	; And subtract it from input number
	ADD R3, R3, #0	; If power of ten is zero
	BRz DISPD_END	; then we've output the last digit
	AND R1, R1, #0
	ADD R1, R1, R2	; Put multiple of ten in R1 for beginning of loop
	BRnzp DISPD_LOOP_DESC_AGAIN
DISPD_END
	LD R0, DISPD_R0
	LD R1, DISPD_R1
	LD R2, DISPD_R2
	LD R3, DISPD_R3
	LD R4, DISPD_R4
	LD R5, DISPD_R5
	LD R7, DISPD_R7
	RET
DISPD_NEG	.FILL #45	; Negative sign
DISPD_0		.FILL #48	; ASCII 0
DISPD_R0	.FILL 0
DISPD_R1	.FILL 0
DISPD_R2	.FILL 0
DISPD_R3	.FILL 0
DISPD_R4	.FILL 0
DISPD_R5	.FILL 0
DISPD_R7	.FILL 0


;
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


;
; Divides two integers.
;
; Preconditions: R1 is the dividen, R2 the divisor.
; Postconditions: R1 holds the quotient.
;
DIV	ST R0, DIV_R0
	ST R2, DIV_R2
	ST R3, DIV_R3
	AND R0, R0, #0	; R0 holds our quotient
	AND R3, R3, #0	; R3 holds negative flag
	ADD R1, R1, #0
	BRn DIV_NEG_1	; If first argument is negative flip flag
DIV_CHECK_NEG_2
	ADD R2, R2, #0
	Brn DIV_NEG_2	; Or the second
DIV_POST_CHECK_NEG
	NOT R2, R2
	ADD R2, R2, #1	; R2 (divisor) negated for repeated subtraction
	BRnzp DIV_LOOP
DIV_NEG_1 ; First operand is negative
	NOT R1, R1	; Negate first argument (both must be positive)
	ADD R1, R1, #1
	NOT R3, R3
	BRnzp DIV_CHECK_NEG_2
DIV_NEG_2 ; Second operand is negative
	NOT R2, R2	; Negate second argument
	ADD R2, R2, #1
	NOT R3, R3
	BRnzp DIV_POST_CHECK_NEG
DIV_LOOP
	ADD R1, R1, R2
	BRn DIV_CLEANUP	; We've subtracted once too many
	ADD R0, R0, #1	; Number of times it fits in goes up
	BRnzp DIV_LOOP
DIV_CLEANUP
	ADD R3, R3, #0
	BRzp DIV_NOT_NEG
	NOT R0, R0	; Here we know the output is negative, so negate it!
	ADD R0, R0, #1
DIV_NOT_NEG
	AND R1, R1, #0
	ADD R1, R1, R0	; Put our result in R1 for return
	LD R0, DIV_R0
	LD R2, DIV_R2
	LD R3, DIV_R3
	ADD R1, R1, #0	; Set condition codes for calling routine
	RET
DIV_R0	.FILL 0
DIV_R2	.FILL 0
DIV_R3	.FILL 0

.end
