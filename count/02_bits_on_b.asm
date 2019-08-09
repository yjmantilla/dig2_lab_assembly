;; Program: Set R0 to the number of bits "on" in R1
;; ------------------------------------------------
;; Assembly this code using lc3as command, 
;; and then load the file 02_bits_on_b.obj into the simulator.

        .ORIG    x3000
START   LEA      R0,MSG1
        PUTS                    ;; Prints the null-terminated string
        GETC                    ;; Asks for a character and stores it in R0
        OUT
        ADD      R1,R0,#0       ;; Moves R0 to R1
        AND      R0,R0,#0       ;; Zero bits so far!
        ADD      R1,R1,#0       ;; Test the msb
        BRzp     SKIPMSB
        ADD      R0,R0,#1       ;; MSB was one
SKIPMSB AND      R2,R2,#0
        ADD      R2,R2,#15      ;; Test remaining 15 bits
LOOP    ADD      R1,R1,R1       
        BRzp     SKIP
        ADD      R0,R0,#1
SKIP    ADD      R2,R2,#-1
        BRp      LOOP
        HALT
MSG1    .STRINGZ "Please provide a character: "        
        .END
