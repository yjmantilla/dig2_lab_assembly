        .ORIG x3000

        AND R4, R4, #0   ;clears the register we will count with
        LD  R1, binary
        LEA R2, masks    ;finds the address in memory of the first mask
loop    LDR R3, R2, #0   ;load the mask from the address stored in R2
        ADD R2, R2, #1   ;next mask address
        AND R0, R1, R3
        BRnz else 
        LD  R0, ascii1
        BRnzp done
else    LD  R0, ascii0
done    OUT
        ADD R4, R4, #1
        ADD R0, R4, #-8  ;sets condition bit zero when R4 = 8
        BRn loop         ;loops if R4 < 8
        HALT

masks   .fill b10000000
        .fill b01000000
        .fill b00100000
        .fill b00010000
        .fill b00001000
        .fill b00000100
        .fill b00000010
        .fill b00000001
ascii0  .fill x30
ascii1  .fill x31
binary  .fill b10000110
        .END