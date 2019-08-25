;; Program: Set R0 to R1*R2 and Store R0 in mem
;; --------------------------------------------
;; Assembly this code using lc3as command, 
;; and then load the file 01_multany.obj into the simulator.

        .ORIG   x3000
START   LD      R1,VALUE1     ; R1 ==  loaded from mem.        
        LD      R2,VALUE2     ; R2 ==  loaded from mem.
        AND     R0,R0,0       ; R0 ==  0        
MULLOOP ADD     R0,R0,R1      ; R0 ==  R0+R1
        ADD     R2,R2,#-1     ; R2 ==  R2-1
        BRp     MULLOOP
        ST      R0,RESULT     ; MEM == R0
        HALT
VALUE1  .FILL   #1            ; Hex 2.
VALUE2  .FILL   #-2            ; Hex 5.
RESULT  .BLKW   1      
        .END
