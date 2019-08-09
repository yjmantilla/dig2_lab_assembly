;; Program: Set R0 to 10*R1
;; ------------------------
;; Assembly this code using lc3as command, 
;; and then load the file 01_mult_a.obj into the simulator.

        .ORIG   x3000
START   AND     R1,R1,0       ; R1 ==  0
        ADD     R1,R1,5       ; R1 ==  5        
MUL10   ADD     R0,R1,R1      ; R0 ==  2*R1
        ADD     R0,R0,R0      ; R0 ==  4*R1
        ADD     R0,R0,R1      ; R0 ==  5*R1
        ADD     R0,R0,R0      ; R0 == 10*R1
        HALT
        .END
