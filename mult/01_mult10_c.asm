;; Program: Set R0 to 10*R1 and Store R0 in mem
;; --------------------------------------------
;; Assembly this code using lc3as command, 
;; and then load the file 01_mult_c.obj into the simulator.

        .ORIG   x3000
START   LD      R1,VALUE      ; R1 ==  5 loaded from mem.        
MUL10   ADD     R0,R1,R1      ; R0 ==  2*R1
        ADD     R0,R0,R0      ; R0 ==  4*R1
        ADD     R0,R0,R1      ; R0 ==  5*R1
        ADD     R0,R0,R0      ; R0 == 10*R1
        ST      R0,RESULT     ; MEM == R0
        HALT
VALUE   .FILL   xA            ; Hex A.
RESULT  .BLKW   1      
        .END
