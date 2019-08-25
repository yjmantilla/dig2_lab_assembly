        .ORIG x3000

        AND R4, R4, #0   ;clears the register we will count with
        LD  R1, hexa
        LEA R2, masks    ;finds the address in memory of the first mask
loop    LDR R3, R2, #0   ;load the mask from the address stored in R2
        ADD R2, R2, #1   ;next mask address
        AND R0, R1, R3
        BRnz else 
        LD  R0, asciif
        BRnzp done
else    LD  R0, asciia
done    OUT
        ADD R4, R4, #1
        ADD R0, R4, #-4  ;sets condition bit zero when R4 = 4
        BRn loop         ;loops if R4 < 4
        HALT

masks   .fill xF000
        .fill x0F00
        .fill x00F0
        .fill x000F
ascii0  .fill #30
ascii1  .fill x31
ascii3  .fill x33
ascii4  .fill x34
ascii5  .fill x35
ascii6  .fill x36
ascii7  .fill x37
ascii8  .fill x38
ascii9  .fill x39
asciia  .fill x41
asciib  .fill x42
asciic  .fill x43
asciid  .fill x44
asciie  .fill x45
asciif  .fill x46
hexa  .fill xABCD
        .END