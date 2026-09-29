.MODEL SMALL
.STACK 100H
 
.DATA
 
.CODE
MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX
 
    ; Use ES = 6000H
    MOV AX, 6000H
    MOV ES, AX
 
    MOV SI, 4000H       ; SI points to first element
    MOV CX, 19          ; 19 adjacent pairs
 
    MOV BL, 0           ; BL = 0 means '<' expected
 
L1:
    MOV AL, ES:[SI]     ; AL = current element
    MOV AH, ES:[SI+1]   ; AH = next element
 
    CMP BL, 0
    JE LESS
 
    ; We need: current > next
    CMP AL, AH
    JA NEXT
 
    ; Swap
    MOV ES:[SI], AH
    MOV ES:[SI+1], AL
    JMP NEXT
 
LESS:
    ; We need: current < next
    CMP AL, AH
    JB NEXT
 
    ; Swap
    MOV ES:[SI], AH
    MOV ES:[SI+1], AL
 
NEXT:
    INC SI
 
    XOR BL, 1 ; Change < to >
 
    LOOP L1
 
    ; Terminate
    MOV AH, 4CH
    INT 21H
 
MAIN ENDP
END MAIN