.MODEL SMALL
.STACK 100H

.DATA

    msgN DB 13,10,'Enter number of requests: $'
    msgReq DB 13,10,'Enter request: $'
    msgHead DB 13,10,'Enter initial head position: $'

    msgResult DB 13,10,'Total head movement = $'

    n DW ?
    head DW ?
    total DW 0

    requests DW 50 DUP(?)

.CODE

MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

; -----------------------------
; Read number of requests
; -----------------------------

    LEA DX,msgN
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER
    MOV n,AX

; -----------------------------
; Read requests
; -----------------------------

    LEA SI,requests
    MOV CX,n

READ_REQUESTS:

    LEA DX,msgReq
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER
    MOV [SI],AX

    ADD SI,2
    LOOP READ_REQUESTS

; -----------------------------
; Read initial head
; -----------------------------

    LEA DX,msgHead
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER
    MOV head,AX

; -----------------------------
; FCFS calculation
; -----------------------------

    LEA SI,requests
    MOV CX,n
    MOV BX,head

CALCULATE:

    MOV AX,[SI]

    CMP AX,BX
    JAE POSITIVE

; BX - AX
    MOV DX,BX
    SUB DX,AX
    ADD total,DX
    JMP NEXT

POSITIVE:

; AX - BX
    SUB AX,BX
    ADD total,AX

NEXT:
    MOV BX,[SI]
    ADD SI,2

    LOOP CALCULATE

; -----------------------------
; Display result
; -----------------------------

    LEA DX,msgResult
    MOV AH,09H
    INT 21H

    MOV AX,total
    CALL PRINT_NUMBER

    MOV AH,4CH
    INT 21H

; -----------------------------
; READ NUMBER
; -----------------------------

READ_NUMBER PROC

    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX,BX

READ_LOOP:

    MOV AH,01H
    INT 21H

    CMP AL,0DH
    JE READ_DONE

    SUB AL,'0'

    XOR AH,AH
    PUSH AX

    MOV AX,BX
    MOV CX,10
    MUL CX
    MOV BX,AX

    POP AX
    ADD BX,AX

    JMP READ_LOOP

READ_DONE:

    MOV AX,BX

    POP DX
    POP CX
    POP BX

    RET

READ_NUMBER ENDP

; -----------------------------
; PRINT NUMBER
; -----------------------------

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

PRINT_LOOP:

    POP DX
    ADD DL,'0'

    MOV AH,02H
    INT 21H

    LOOP PRINT_LOOP

PRINT_DONE:

    POP DX
    POP CX
    POP BX
    POP AX

    RET

PRINT_NUMBER ENDP

MAIN ENDP
END MAIN