            .ORIG x3000
            LD    R6,INIT_PTR   ; load initial stack pointer
            LD    R5,INIT_PTR   ; load initial frame pointer
            BR    MAIN

INIT_PTR    .FILL x4001
            
MAIN        
;; setup caller portion of activation record
;; push function parameters
            AND   R2,R2,#0      ; initialize R2 to 5
            ADD   R2,R2,#5      ; initialize R2 to 5
 
            ADD   R6,R6,#-1     ; Push step 1: decrement stack pointer
            STR   R2,R6,#0      ; Push step 2: copy param val=5 to stack
            JSR   FACTORIAL     ; call factorial
;; tear down caller portion of activation record
;; push function parameters
            LDR   R0,R6,#0      ; load result of call into a register
            ADD   R6,R6,#1      ; Pop return value
            ADD   R6,R6,#1      ; Pop parameter val
            
            HALT

FACTORIAL   
;; setup callee portion of activation record
;; allocate space for return value, save ret address
;; save frame pointer, allocate space for local variables
            ADD   R6,R6,#-1     ; Allocate space for return value
            ADD   R6,R6,#-1     ; Push step 1: decrement stack pointer
            STR   R7,R6,#0      ; Push step 2: save return address (R7) to stack
            ADD   R6,R6,#-1     ; Push step 1: decrement stack pointer
            STR   R5,R6,#0      ; Push step 2: save frame pointer (R5) to stack
            ADD   R5,R6,#-1     ; Set factorial's frame pointer
            ADD   R6,R6,#-1     ; Allocate space for 1 local variable (result)
            
;; factorial function body *starts* here
            LDR   R1,R5,#4      ; Load parameter val into R1. (frame pointer(R5) + 4)
            ADD   R0,R1,#-1      ; Test val ( set condition codes )
            BRnz  FACT_ELSE

FACT_IF     ADD   R2,R1,#-1     ; Compute val-1
            
;; setup caller portion of activation record
;; push function parameters
            ADD   R6,R6,#-1     ; Push step 1: decrement stack pointer
            STR   R2,R6,#0      ; Push step 2: copy param val=val-1
            JSR   FACTORIAL     ; Call factorial
;; tear down caller portion of activation record
;; push function parameters
            LDR   R0,R6,#0      ; Load result of call into a register
            ADD   R6,R6,#1      ; Pop return value
            ADD   R6,R6,#1      ; Pop parameter val
            
;; resume computation: multiply R0*R1 loop
;; R0=factorial(val-1), R1=val (loop counter), R2=result
            LDR   R1,R5,#4      ; Reset R2 to val (would need to be saved on the stack otherwise)
            AND   R2,R2,#0      ; Initialize result register to 0
FACT_IFLOOP ADD   R2,R2,R0      ; One add of multiply R0*R1
            ADD   R1,R1,#-1     ; Decrement loop counter and test
            BRp   FACT_IFLOOP    
            
            STR   R2,R5,#0      ; Assign to result local variable (frame pointer + 0)
            BR    FACT_FI

FACT_ELSE   AND   R2,R2,#0      ; Initialize R2 to 1
            ADD   R2,R2,#1      ; Initialize R2 to 1
            STR   R2,R5,#0      ; Assign to result local variable (frame pointer + 0)
            
FACT_FI     LDR   R0,R5,#0      ; Load local result into a register
			STR   R0,R5,#3      ; Copy return value to location on stack ( frame pointer + 3 )

;; factorial function body *ends* here
;; tear down callee portion of activation record
            ADD   R6,R6,#1      ; Pop local variables
            LDR   R5,R6,#0      ; Restore caller's frame pointer
            ADD   R6,R6,#1      ; Pop frame pointer
            LDR   R7,R6,#0      ; Restore return address
            ADD   R6,R6,#1      ; Pop return address
            
            RET                 ; Return from factorial
            
            .END
            