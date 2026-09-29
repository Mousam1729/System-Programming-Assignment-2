.MODEL SMALL
.STACK 100H

.DATA
    password DB '1234'
    passLen  EQU 4

    msgTitle DB 13,10,'=== BIOS PASSWORD VERIFICATION ===',13,10,'$'
    msgPass  DB 13,10,'Enter password: $'
    msgWrong DB 13,10,'Wrong password!',13,10,'$'
    msgCorrect DB 13,10,'Password correct. Access granted!',13,10,'$'
    msgLocked DB 13,10,'3 attempts failed. SYSTEM LOCKED!',13,10,'$'
    msgTry DB 13,10,'Attempts remaining: $'

    input DB 10 DUP(?)
    attempts DB 3

.CODE

MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

    LEA DX,msgTitle
    MOV AH,09H
    INT 21H

TRY_AGAIN:
    LEA DX,msgPass
    MOV AH,09H
    INT 21H

    LEA SI,input
    XOR CX,CX

; Read password using BIOS keyboard interrupt
READ_CHAR:
    MOV AH,00H
    INT 16H

    CMP AL,0DH
    JE CHECK_PASSWORD

    CMP AL,08H
    JE READ_CHAR

    MOV [SI],AL
    INC SI
    INC CX

    CMP CX,10
    JB READ_CHAR

CHECK_PASSWORD:
    CMP CX,passLen
    JNE WRONG

    LEA SI,input
    LEA DI,password
    MOV CX,passLen

COMPARE:
    MOV AL,[SI]
    CMP AL,[DI]
    JNE WRONG

    INC SI
    INC DI
    LOOP COMPARE

; Correct
    LEA DX,msgCorrect
    MOV AH,09H
    INT 21H
    JMP EXIT_PROGRAM

WRONG:
    DEC attempts

    LEA DX,msgWrong
    MOV AH,09H
    INT 21H

    CMP attempts,0
    JE LOCKED

    LEA DX,msgTry
    MOV AH,09H
    INT 21H

    MOV DL,attempts
    ADD DL,'0'
    MOV AH,02H
    INT 21H

    JMP TRY_AGAIN

LOCKED:
    LEA DX,msgLocked
    MOV AH,09H
    INT 21H

EXIT_PROGRAM:
    MOV AH,4CH
    INT 21H

MAIN ENDP
END MAIN