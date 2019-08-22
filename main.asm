.orig x3000


ENTER_N		lea r0 , MSG_ENTER			
		jsr INPUT
		jsr FINISH
		MSG_ENTER .stringz "\nEnter N:"


INPUT		; routine that will put input in r0
			; place ask string address in r0 beforehand
		push
		puts	; displays *r0
		getc	; gets c in r0
		out	; echo what is in r0
		ret	; go home boy

FINISH		lea r0 , MSG_END
		puts					;
		halt	; end program
		MSG_END .stringz "\nImma halting"

PUSH_R7		;r6 is used as an auxiliar register
		add r6, r6, #-1
		str r7, r6, #0 		

POP_R7		;r6 used as an auxiliar register
		ldr r7, r6, #0
		add r6, r6, #1 
.end