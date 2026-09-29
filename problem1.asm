.MODEL SMALL
.STACK 100H

.DATA
    ; No specific variables needed as we use absolute memory locations

.CODE
MAIN PROC
    ; Initialize data segment if needed
    MOV AX, @DATA
    MOV DS, AX

    ; Initialize pointers and counter
    MOV SI, 3000H       ; Source offset pointer
    MOV DI, 4000H       ; Destination offset pointer
    MOV CX, 10          ; Loop counter for 10 bytes

TRANSFER_LOOP:
    MOV AL, CS:[SI]        ; Load data byte from source (3000H)
    
    ; Perform operations: (AL * 5) + 10
    MOV BL, 5
    MUL BL              ; AX = AL * 5
    ADD AL, 10          ; Add 10 to the result (assuming result fits in AL)

    MOV CS:[DI], AL        ; Store the modified byte to destination (4000H)

    INC SI              ; Move to next source byte
    INC DI              ; Move to next destination byte
    LOOP TRANSFER_LOOP  ; Decrement CX and repeat until CX = 0

    ; Terminate program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN