.MODEL SMALL
.STACK 100H

.DATA

    msgInput DB 13,10,'Enter brackets: $'
    balanced DB 13,10,'Balanced$'
    notBalanced DB 13,10,'Non-Balanced$'

    input DB 100 DUP('$')

    bracketStack DB 100 DUP(?)
    top DW 0

.CODE

MAIN PROC

    MOV AX,@DATA
    MOV DS,AX

; -----------------------
; Input
; -----------------------

    LEA DX,msgInput
    MOV AH,09H
    INT 21H

    LEA DX,input
    MOV BYTE PTR [input],99
    MOV AH,0AH
    INT 21H

; -----------------------
; Initialize stack
; -----------------------

    MOV top,0
    LEA SI,input+2

; =======================
; PROCESS CHARACTER
; =======================

PROCESS:

    MOV AL,[SI]

    CMP AL,0DH
    JNE NOT_END
    JMP END_CHECK

NOT_END:

; -----------------------
; Opening round (
; -----------------------

    CMP AL,'('
    JNE NOT_ROUND_OPEN
    JMP PUSH_BRACKET

NOT_ROUND_OPEN:

; -----------------------
; Opening square [
; -----------------------

    CMP AL,'['
    JNE NOT_SQUARE_OPEN
    JMP PUSH_BRACKET

NOT_SQUARE_OPEN:

; -----------------------
; Opening curly {
; -----------------------

    CMP AL,'{'
    JNE NOT_CURLY_OPEN
    JMP PUSH_BRACKET

NOT_CURLY_OPEN:

; -----------------------
; Closing round )
; -----------------------

    CMP AL,')'
    JNE NOT_ROUND_CLOSE
    JMP CHECK_ROUND

NOT_ROUND_CLOSE:

; -----------------------
; Closing square ]
; -----------------------

    CMP AL,']'
    JNE NOT_SQUARE_CLOSE
    JMP CHECK_SQUARE

NOT_SQUARE_CLOSE:

; -----------------------
; Closing curly }
; -----------------------

    CMP AL,'}'
    JNE NEXT_CHARACTER
    JMP CHECK_CURLY

; =======================
; PUSH OPENING BRACKET
; =======================

PUSH_BRACKET:

    MOV BX,top
    MOV bracketStack[BX],AL
    INC top

    JMP NEXT_CHARACTER

; =======================
; CHECK ROUND )
; =======================

CHECK_ROUND:

    CMP top,0
    JNE ROUND_NOT_EMPTY
    JMP NOT_BALANCED

ROUND_NOT_EMPTY:

    DEC top
    MOV BX,top
    MOV AL,bracketStack[BX]

    CMP AL,'('
    JNE ROUND_WRONG
    JMP NEXT_CHARACTER

ROUND_WRONG:

    JMP NOT_BALANCED

; =======================
; CHECK SQUARE ]
; =======================

CHECK_SQUARE:

    CMP top,0
    JNE SQUARE_NOT_EMPTY
    JMP NOT_BALANCED

SQUARE_NOT_EMPTY:

    DEC top
    MOV BX,top
    MOV AL,bracketStack[BX]

    CMP AL,'['
    JNE SQUARE_WRONG
    JMP NEXT_CHARACTER

SQUARE_WRONG:

    JMP NOT_BALANCED

; =======================
; CHECK CURLY }
; =======================

CHECK_CURLY:

    CMP top,0
    JNE CURLY_NOT_EMPTY
    JMP NOT_BALANCED

CURLY_NOT_EMPTY:

    DEC top
    MOV BX,top
    MOV AL,bracketStack[BX]

    CMP AL,'{'
    JNE CURLY_WRONG
    JMP NEXT_CHARACTER

CURLY_WRONG:

    JMP NOT_BALANCED

; =======================
; NEXT CHARACTER
; =======================

NEXT_CHARACTER:

    INC SI
    JMP PROCESS

; =======================
; END OF INPUT
; =======================

END_CHECK:

    CMP top,0
    JNE STACK_NOT_EMPTY
    JMP BALANCED_RESULT

STACK_NOT_EMPTY:

    JMP NOT_BALANCED

; =======================
; BALANCED
; =======================

BALANCED_RESULT:

    LEA DX,balanced
    MOV AH,09H
    INT 21H

    JMP EXIT_PROGRAM

; =======================
; NON-BALANCED
; =======================

NOT_BALANCED:

    LEA DX,notBalanced
    MOV AH,09H
    INT 21H

; =======================
; EXIT
; =======================

EXIT_PROGRAM:

    MOV AH,4CH
    INT 21H

MAIN ENDP

END MAIN