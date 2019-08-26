; Implementing bubble sort algorithm
;   R0  File item
;   R1  File item
;   R2  Work variable
;   R3  File pointer
;   R4  Outer loop counter
;   R5  Inner loop counter
    

            .ORIG   x3000

; Count the number of items to be sorted and store the value in R7

            AND     R2, R2, #0  ; Initialize R2 <- 0 (counter)
            Lea      R3, FILE    ; Put file pointer into R3
COUNT       LDR     R0, R3, #0  ; Put next file item into R0
            BRZ     END_COUNT   ; Loop until file item is 0
            ADD     R3, R3, #1  ; Increment file pointer
            ADD     R2, R2, #1  ; Increment counter
            BRNZP   COUNT       ; Counter loop
END_COUNT   ADD     R4, R2, #0  ; Store total items in R4 (outer loop count)
            BRZ     SORTED      ; Empty file

; Do the bubble sort

OUTERLOOP   ADD     R4, R4, #-1 ; loop n - 1 times
            BRNZ    SORTED      ; Looping complete, exit
            ADD     R5, R4, #0  ; Initialize inner loop counter to outer
            Lea     R3, FILE    ; Set file pointer to beginning of file
INNERLOOP   LDR     R0, R3, #0  ; Get item at file pointer
            LDR     R1, R3, #1  ; Get next item
            NOT     R2, R1      ; Negate ...
            ADD     R2, R2, #1  ;        ... next item
            ADD     R2, R0, R2  ; swap = item - next item
            BRNZ    SWAPPED     ; Don't swap if in order (item <= next item)
            STR     R1, R3, #0  ; Perform ...
            STR     R0, R3, #1  ;         ... swap
SWAPPED     ADD     R3, R3, #1  ; Increment file pointer
            ADD     R5, R5, #-1 ; Decrement inner loop counter
            BRP     INNERLOOP   ; End of inner loop
            BRNZP   OUTERLOOP   ; End of outer loop
SORTED      HALT

FILE        
.FILL #16384
.FILL #-16383
.FILL #-3276
.FILL #3276
.FILL #16
.FILL #-3
.FILL #4
.FILL #-4
.fill #0
.FILL #16383
.FILL #-16383
.FILL #-3276
.FILL #3276
.FILL #16
.FILL #-3
.FILL #4
.FILL #-4
.fill #0
.END