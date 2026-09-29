.MODEL SMALL
.STACK 100H

.DATA

; ------------------------------------------------------------
; Simple command-line shell emulator
; Commands:
;   DIR
;   TYPE <filename>
;   COPY <source> <destination>
;   EXIT
;
; Mock files are stored completely in memory.
; COPY really copies the source contents into the destination.
; ------------------------------------------------------------

prompt      DB 13,10,'SHELL> $'

dirMsg      DB 13,10,'Directory of Mock Files:',13,10
            DB 'FILE1.TXT',13,10
            DB 'FILE2.TXT',13,10
            DB 'TEST.TXT',13,10,'$'

file1Name   DB 'FILE1.TXT',0
file2Name   DB 'FILE2.TXT',0
testName    DB 'TEST.TXT',0

; Each mock file has space for 100 characters.
; The first part contains its initial contents.
file1Data   DB 'This is the content of FILE1.TXT.$'
            DB 70 DUP(0)

file2Data   DB 'This is the content of FILE2.TXT.$'
            DB 70 DUP(0)

testData    DB 'This is a test file.$'
            DB 79 DUP(0)

copyMsg     DB 13,10,'File copied successfully.$'
notFound    DB 13,10,'File not found.$'
syntaxMsg   DB 13,10,'Invalid command.$'
missingMsg  DB 13,10,'Missing source or destination filename.$'
sameMsg     DB 13,10,'Source and destination are the same.$'
crlf        DB 13,10,'$'

; DOS buffered input:
; byte 0 = maximum number of characters
; byte 1 = number actually entered
; bytes 2... = characters
input       DB 100
            DB 0
            DB 100 DUP(0)

; Temporary filename buffers
source      DB 13 DUP(0)
dest        DB 13 DUP(0)

; Pointers/addresses used by COPY
srcPtr      DW 0
dstPtr      DW 0

.CODE

MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

SHELL_LOOP:
    CALL PRINT_PROMPT
    CALL READ_COMMAND
    CALL UPPERCASE_COMMAND
    CALL EXECUTE_COMMAND
    CMP AL,1
    JE EXIT_PROGRAM
    JMP SHELL_LOOP

EXIT_PROGRAM:
    MOV AH,4CH
    MOV AL,00H
    INT 21H
MAIN ENDP


; ------------------------------------------------------------
; PRINT_PROMPT
; ------------------------------------------------------------
PRINT_PROMPT PROC NEAR
    LEA DX,prompt
    MOV AH,09H
    INT 21H
    RET
PRINT_PROMPT ENDP


; ------------------------------------------------------------
; READ_COMMAND
; Reads command using DOS INT 21H, AH=0AH.
; ------------------------------------------------------------
READ_COMMAND PROC NEAR
    MOV BYTE PTR [input+1],0
    LEA DX,input
    MOV AH,0AH
    INT 21H
    RET
READ_COMMAND ENDP


; ------------------------------------------------------------
; UPPERCASE_COMMAND
; Converts all entered alphabetic characters to uppercase.
; This allows:
;   dir
;   Dir
;   dIr
; etc.
; ------------------------------------------------------------
UPPERCASE_COMMAND PROC NEAR
    XOR CX,CX
    MOV CL,[input+1]
    LEA SI,input+2

UC_LOOP:
    CMP CX,0
    JE UC_DONE

    MOV AL,[SI]
    CMP AL,'a'
    JB UC_NEXT
    CMP AL,'z'
    JA UC_NEXT
    SUB AL,20H
    MOV [SI],AL

UC_NEXT:
    INC SI
    DEC CX
    JMP UC_LOOP

UC_DONE:
    RET
UPPERCASE_COMMAND ENDP


; ------------------------------------------------------------
; EXECUTE_COMMAND
;
; Returns:
;   AL = 1 -> EXIT
;   AL = 0 -> continue shell
; ------------------------------------------------------------
EXECUTE_COMMAND PROC NEAR

    ; Empty command
    CMP BYTE PTR [input+1],0
    JE EC_CONTINUE

    ; Check DIR
    CALL CHECK_DIR
    CMP AL,1
    JE EC_DIR

    ; Check TYPE
    CALL CHECK_TYPE
    CMP AL,1
    JE EC_TYPE

    ; Check COPY
    CALL CHECK_COPY
    CMP AL,1
    JE EC_COPY

    ; Check EXIT
    CALL CHECK_EXIT
    CMP AL,1
    JE EC_EXIT

    ; Otherwise invalid
    CALL PRINT_INVALID
    JMP EC_CONTINUE

EC_DIR:
    CALL DO_DIR
    JMP EC_CONTINUE

EC_TYPE:
    CALL DO_TYPE
    JMP EC_CONTINUE

EC_COPY:
    CALL DO_COPY
    JMP EC_CONTINUE

EC_EXIT:
    MOV AL,1
    RET

EC_CONTINUE:
    XOR AL,AL
    RET

EXECUTE_COMMAND ENDP


; ------------------------------------------------------------
; CHECK_DIR
; AL = 1 if command begins with "DIR"
; ------------------------------------------------------------
CHECK_DIR PROC NEAR
    CMP BYTE PTR [input+2],'D'
    JNE CD_NO
    CMP BYTE PTR [input+3],'I'
    JNE CD_NO
    CMP BYTE PTR [input+4],'R'
    JNE CD_NO

    ; DIR must end after the command or be followed by space.
    MOV AL,[input+5]
    CMP AL,' '
    JE CD_YES
    CMP AL,0DH
    JE CD_YES
    ; DOS buffer does not contain CR in the entered count,
    ; so zero is also accepted here.
    CMP AL,0
    JE CD_YES

CD_NO:
    XOR AL,AL
    RET

CD_YES:
    MOV AL,1
    RET
CHECK_DIR ENDP


; ------------------------------------------------------------
; CHECK_TYPE
; AL = 1 if command begins with "TYPE"
; ------------------------------------------------------------
CHECK_TYPE PROC NEAR
    CMP BYTE PTR [input+2],'T'
    JNE CT_NO
    CMP BYTE PTR [input+3],'Y'
    JNE CT_NO
    CMP BYTE PTR [input+4],'P'
    JNE CT_NO
    CMP BYTE PTR [input+5],'E'
    JNE CT_NO

    MOV AL,1
    RET

CT_NO:
    XOR AL,AL
    RET
CHECK_TYPE ENDP


; ------------------------------------------------------------
; CHECK_COPY
; AL = 1 if command begins with "COPY"
; ------------------------------------------------------------
CHECK_COPY PROC NEAR
    CMP BYTE PTR [input+2],'C'
    JNE CC_NO
    CMP BYTE PTR [input+3],'O'
    JNE CC_NO
    CMP BYTE PTR [input+4],'P'
    JNE CC_NO
    CMP BYTE PTR [input+5],'Y'
    JNE CC_NO

    MOV AL,1
    RET

CC_NO:
    XOR AL,AL
    RET
CHECK_COPY ENDP


; ------------------------------------------------------------
; CHECK_EXIT
; AL = 1 if command is EXIT
; ------------------------------------------------------------
CHECK_EXIT PROC NEAR
    CMP BYTE PTR [input+2],'E'
    JNE CE_NO
    CMP BYTE PTR [input+3],'X'
    JNE CE_NO
    CMP BYTE PTR [input+4],'I'
    JNE CE_NO
    CMP BYTE PTR [input+5],'T'
    JNE CE_NO

    MOV AL,1
    RET

CE_NO:
    XOR AL,AL
    RET
CHECK_EXIT ENDP


; ------------------------------------------------------------
; DO_DIR
; ------------------------------------------------------------
DO_DIR PROC NEAR
    LEA DX,dirMsg
    MOV AH,09H
    INT 21H
    RET
DO_DIR ENDP


; ------------------------------------------------------------
; DO_TYPE
;
; Expected:
;   TYPE FILE1.TXT
;   TYPE FILE2.TXT
;   TYPE TEST.TXT
; ------------------------------------------------------------
DO_TYPE PROC NEAR

    ; Clear filename buffer
    CALL CLEAR_SOURCE

    ; Parse filename beginning at input+7
    LEA SI,input+7
    LEA DI,source
    CALL GET_FILENAME
    CMP AL,1
    JNE DT_MISSING

    ; Compare with FILE1.TXT
    LEA SI,source
    LEA DI,file1Name
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE DT_FILE1

    ; Compare with FILE2.TXT
    LEA SI,source
    LEA DI,file2Name
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE DT_FILE2

    ; Compare with TEST.TXT
    LEA SI,source
    LEA DI,testName
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE DT_TEST

    CALL PRINT_NOT_FOUND
    RET

DT_FILE1:
    LEA DX,file1Data
    MOV AH,09H
    INT 21H
    RET

DT_FILE2:
    LEA DX,file2Data
    MOV AH,09H
    INT 21H
    RET

DT_TEST:
    LEA DX,testData
    MOV AH,09H
    INT 21H
    RET

DT_MISSING:
    CALL PRINT_MISSING
    RET

DO_TYPE ENDP


; ------------------------------------------------------------
; DO_COPY
;
; Expected:
;   COPY FILE1.TXT FILE2.TXT
;   COPY TEST.TXT FILE2.TXT
;
; The source data is copied into the selected destination buffer.
; ------------------------------------------------------------
DO_COPY PROC NEAR

    CALL CLEAR_SOURCE
    CALL CLEAR_DEST

    ; Source starts after "COPY "
    LEA SI,input+7
    LEA DI,source
    CALL GET_FILENAME
    CMP AL,1
    JNE DC_MISSING

    ; Move SI to the character after the first filename.
    ; GET_FILENAME leaves SI at the delimiter/space.
    CALL SKIP_SPACES

    ; Destination filename
    LEA DI,dest
    CALL GET_FILENAME
    CMP AL,1
    JNE DC_MISSING

    ; Find source data address
    CALL FIND_SOURCE
    CMP AL,1
    JNE DC_NOT_FOUND

    ; Find destination data address
    CALL FIND_DEST
    CMP AL,1
    JNE DC_NOT_FOUND

    ; Check source and destination names are not identical.
    LEA SI,source
    LEA DI,dest
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE DC_SAME

    ; Copy source data to destination data.
    MOV SI,srcPtr
    MOV DI,dstPtr
    CALL COPY_STRING

    CALL PRINT_COPY_SUCCESS
    RET

DC_MISSING:
    CALL PRINT_MISSING
    RET

DC_NOT_FOUND:
    CALL PRINT_NOT_FOUND
    RET

DC_SAME:
    CALL PRINT_SAME
    RET

DO_COPY ENDP


; ------------------------------------------------------------
; GET_FILENAME
;
; SI = input position
; DI = destination filename buffer
;
; Copies characters until space or end of input.
; Adds a zero terminator.
;
; Returns AL=1 if at least one character was read.
; Returns AL=0 if no filename was found.
;
; SI ends at the delimiter or end of input.
; ------------------------------------------------------------
GET_FILENAME PROC NEAR
    XOR CX,CX

GF_SKIP:
    MOV AL,[SI]
    CMP AL,' '
    JNE GF_START
    INC SI
    JMP GF_SKIP

GF_START:
    MOV AL,[SI]
    CMP AL,0
    JE GF_EMPTY

    MOV AL,[input+1]
    CMP AL,0
    JE GF_EMPTY

GF_COPY:
    MOV AL,[SI]
    CMP AL,' '
    JE GF_END
    CMP AL,0DH
    JE GF_END
    CMP AL,0
    JE GF_END

    MOV [DI],AL
    INC DI
    INC SI
    INC CX
    CMP CX,12
    JB GF_COPY

GF_END:
    MOV BYTE PTR [DI],0
    MOV AL,1
    RET

GF_EMPTY:
    MOV BYTE PTR [DI],0
    XOR AL,AL
    RET
GET_FILENAME ENDP


; ------------------------------------------------------------
; SKIP_SPACES
; SI moves over spaces.
; ------------------------------------------------------------
SKIP_SPACES PROC NEAR
SS_LOOP:
    CMP BYTE PTR [SI],' '
    JNE SS_DONE
    INC SI
    JMP SS_LOOP

SS_DONE:
    RET
SKIP_SPACES ENDP


; ------------------------------------------------------------
; CLEAR_SOURCE
; ------------------------------------------------------------
CLEAR_SOURCE PROC NEAR
    LEA DI,source
    MOV CX,13
    XOR AL,AL

CS_LOOP:
    MOV [DI],AL
    INC DI
    DEC CX
    JNZ CS_LOOP
    RET
CLEAR_SOURCE ENDP


; ------------------------------------------------------------
; CLEAR_DEST
; ------------------------------------------------------------
CLEAR_DEST PROC NEAR
    LEA DI,dest
    MOV CX,13
    XOR AL,AL

CD_LOOP:
    MOV [DI],AL
    INC DI
    DEC CX
    JNZ CD_LOOP
    RET
CLEAR_DEST ENDP


; ------------------------------------------------------------
; COMPARE_NULL_NAMES
;
; SI = zero-terminated name
; DI = zero-terminated name
; AL = 1 if equal, 0 otherwise
; ------------------------------------------------------------
COMPARE_NULL_NAMES PROC NEAR
CN_LOOP:
    MOV AL,[SI]
    MOV BL,[DI]

    CMP AL,BL
    JNE CN_NO

    CMP AL,0
    JE CN_YES

    INC SI
    INC DI
    JMP CN_LOOP

CN_NO:
    XOR AL,AL
    RET

CN_YES:
    MOV AL,1
    RET
COMPARE_NULL_NAMES ENDP


; ------------------------------------------------------------
; FIND_SOURCE
;
; Sets srcPtr to the data address of source filename.
; AL = 1 if found, 0 otherwise.
; ------------------------------------------------------------
FIND_SOURCE PROC NEAR

    LEA SI,source
    LEA DI,file1Name
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE FS_FILE1

    LEA SI,source
    LEA DI,file2Name
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE FS_FILE2

    LEA SI,source
    LEA DI,testName
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE FS_TEST

    XOR AL,AL
    RET

FS_FILE1:
    LEA AX,file1Data
    MOV srcPtr,AX
    MOV AL,1
    RET

FS_FILE2:
    LEA AX,file2Data
    MOV srcPtr,AX
    MOV AL,1
    RET

FS_TEST:
    LEA AX,testData
    MOV srcPtr,AX
    MOV AL,1
    RET

FIND_SOURCE ENDP


; ------------------------------------------------------------
; FIND_DEST
;
; Sets dstPtr to the data address of destination filename.
; AL = 1 if found, 0 otherwise.
; ------------------------------------------------------------
FIND_DEST PROC NEAR

    LEA SI,dest
    LEA DI,file1Name
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE FD_FILE1

    LEA SI,dest
    LEA DI,file2Name
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE FD_FILE2

    LEA SI,dest
    LEA DI,testName
    CALL COMPARE_NULL_NAMES
    CMP AL,1
    JE FD_TEST

    XOR AL,AL
    RET

FD_FILE1:
    LEA AX,file1Data
    MOV dstPtr,AX
    MOV AL,1
    RET

FD_FILE2:
    LEA AX,file2Data
    MOV dstPtr,AX
    MOV AL,1
    RET

FD_TEST:
    LEA AX,testData
    MOV dstPtr,AX
    MOV AL,1
    RET

FIND_DEST ENDP


; ------------------------------------------------------------
; COPY_STRING
;
; SI = source data
; DI = destination data
;
; Copies until '$', then writes '$' to destination.
; ------------------------------------------------------------
COPY_STRING PROC NEAR
COPY_LOOP:
    MOV AL,[SI]
    MOV [DI],AL

    CMP AL,'$'
    JE COPY_DONE

    INC SI
    INC DI
    JMP COPY_LOOP

COPY_DONE:
    RET
COPY_STRING ENDP


; ------------------------------------------------------------
; Message procedures
; ------------------------------------------------------------
PRINT_COPY_SUCCESS PROC NEAR
    LEA DX,copyMsg
    MOV AH,09H
    INT 21H
    RET
PRINT_COPY_SUCCESS ENDP

PRINT_NOT_FOUND PROC NEAR
    LEA DX,notFound
    MOV AH,09H
    INT 21H
    RET
PRINT_NOT_FOUND ENDP

PRINT_INVALID PROC NEAR
    LEA DX,syntaxMsg
    MOV AH,09H
    INT 21H
    RET
PRINT_INVALID ENDP

PRINT_MISSING PROC NEAR
    LEA DX,missingMsg
    MOV AH,09H
    INT 21H
    RET
PRINT_MISSING ENDP

PRINT_SAME PROC NEAR
    LEA DX,sameMsg
    MOV AH,09H
    INT 21H
    RET
PRINT_SAME ENDP

END MAIN
