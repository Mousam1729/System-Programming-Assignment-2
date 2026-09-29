.MODEL SMALL
.STACK 100H

.DATA

    msgN DB 13,10,'Enter number of elements: $'
    msgElement DB 13,10,'Enter element: $'
    msgBefore DB 13,10,'Array before sorting: $'
    msgAfter DB 13,10,'Array after sorting: $'
    space DB ' $'

    n DW ?
    arr DW 50 DUP(?)

.CODE

MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

; -----------------------
; Read n
; -----------------------

    LEA DX,msgN
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER
    MOV n,AX

; -----------------------
; Read array
; -----------------------

    LEA SI,arr
    MOV CX,n

INPUT_LOOP:

    LEA DX,msgElement
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER
    MOV [SI],AX

    ADD SI,2
    LOOP INPUT_LOOP

; -----------------------
; Display before sorting
; -----------------------

    LEA DX,msgBefore
    MOV AH,09H
    INT 21H

    CALL DISPLAY_ARRAY

; -----------------------
; Bubble sort
; -----------------------

    MOV CX,n
    DEC CX

OUTER:

    PUSH CX

    LEA SI,arr
    MOV CX,n
    DEC CX

INNER:

    MOV AX,[SI]
    MOV BX,[SI+2]

    CMP AX,BX
    JBE NO_SWAP

; Swap
    MOV [SI],BX
    MOV [SI+2],AX

NO_SWAP:

    ADD SI,2
    LOOP INNER

    POP CX
    LOOP OUTER

; -----------------------
; Display after sorting
; -----------------------

    LEA DX,msgAfter
    MOV AH,09H
    INT 21H

    CALL DISPLAY_ARRAY

    MOV AH,4CH
    INT 21H

; =======================
; READ NUMBER
; =======================

READ_NUMBER PROC

    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX,BX

READ:

    MOV AH,01H
    INT 21H

    CMP AL,0DH
    JE DONE_READ

    SUB AL,'0'
    XOR AH,AH

    PUSH AX

    MOV AX,BX
    MOV CX,10
    MUL CX
    MOV BX,AX

    POP AX
    ADD BX,AX

    JMP READ

DONE_READ:

    MOV AX,BX

    POP DX
    POP CX
    POP BX

    RET

READ_NUMBER ENDP

; =======================
; DISPLAY ARRAY
; =======================

DISPLAY_ARRAY PROC

    LEA SI,arr
    MOV CX,n

DISPLAY:

    MOV AX,[SI]
    CALL PRINT_NUMBER

    LEA DX,space
    MOV AH,09H
    INT 21H

    ADD SI,2
    LOOP DISPLAY

    RET

DISPLAY_ARRAY ENDP

; =======================
; PRINT NUMBER
; =======================

PRINT_NUMBER PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX,0
    JNE CONVERT

    MOV DL,'0'
    MOV AH,02H
    INT 21H
    JMP PRINT_DONE

CONVERT:

    XOR CX,CX
    MOV BX,10

DIVIDE:

    XOR DX,DX
    DIV BX

    PUSH DX
    INC CX

    CMP AX,0
    JNE DIVIDE

PRINT:

    POP DX
    ADD DL,'0'

    MOV AH,02H
    INT 21H

    LOOP PRINT

PRINT_DONE:

    POP DX
    POP CX
    POP BX
    POP AX

    RET

PRINT_NUMBER ENDP

MAIN ENDP
END MAIN