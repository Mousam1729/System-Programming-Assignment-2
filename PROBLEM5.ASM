.MODEL SMALL
.STACK 100H

.DATA
    MENU        DB 10,13,"--- STRING LIBRARY MENU ---"
                DB 10,13,"1. STRLEN (Find Length)"
                DB 10,13,"2. STRCMP (Compare Two Strings)"
                DB 10,13,"3. STRREV (Reverse String in Place)"
                DB 10,13,"4. Exit"
                DB 10,13,"Enter your choice: $"
                
    PROMPT1     DB 10,13,"Enter first string: $"
    PROMPT2     DB 10,13,"Enter second string: $"
    
    LEN_MSG     DB 10,13,"Length of the string is: $"
    REV_MSG     DB 10,13,"Reversed string is: $"
    EQ_MSG      DB 10,13,"Strings are EQUAL.$"
    NEQ_MSG     DB 10,13,"Strings are NOT EQUAL.$"
    
    STR_BUF1    DB 50, 0, 50 DUP('$')
    STR_BUF2    DB 50, 0, 50 DUP('$')

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                  

MENU_LOOP:
    LEA DX, MENU
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, '0'                 
    
    CMP AL, 1
    JNE NOT_1
    JMP DO_STRLEN
NOT_1:
    CMP AL, 2
    JNE NOT_2
    JMP DO_STRCMP
NOT_2:
    CMP AL, 3
    JNE NOT_3
    JMP DO_STRREV
NOT_3:
    CMP AL, 4
    JNE NOT_4
    JMP EXIT_PROG
NOT_4:
    JMP MENU_LOOP               

DO_STRLEN:
    LEA DX, PROMPT1
    MOV AH, 09H
    INT 21H
    LEA DX, STR_BUF1
    CALL READ_STR
    
    LEA SI, STR_BUF1 + 2        
    CALL STRLEN                 
    
    LEA DX, LEN_MSG
    MOV AH, 09H
    INT 21H
    
    MOV AX, CX
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP MENU_LOOP

DO_STRCMP:
    LEA DX, PROMPT1
    MOV AH, 09H
    INT 21H
    LEA DX, STR_BUF1
    CALL READ_STR
    
    LEA DX, PROMPT2
    MOV AH, 09H
    INT 21H
    LEA DX, STR_BUF2
    CALL READ_STR
    
    LEA SI, STR_BUF1 + 2
    LEA DI, STR_BUF2 + 2
    CALL STRCMP
    
    CMP AX, 0
    JE  STRINGS_MATCH
    LEA DX, NEQ_MSG
    JMP PRINT_CMP_RES
STRINGS_MATCH:
    LEA DX, EQ_MSG
PRINT_CMP_RES:
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

DO_STRREV:
    LEA DX, PROMPT1
    MOV AH, 09H
    INT 21H
    LEA DX, STR_BUF1
    CALL READ_STR
    
    LEA SI, STR_BUF1 + 2
    CALL STRREV                 
    
    LEA DX, REV_MSG
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR_BUF1 + 2        
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

EXIT_PROG:
    MOV AH, 4CH                 
    INT 21H
MAIN ENDP

; READ_STR Function

READ_STR PROC NEAR
    PUSH BX                     
    PUSH DX

    MOV AH, 0AH                 
    INT 21H
    
    MOV BX, DX                  
    XOR DX, DX
    MOV DL, [BX + 1]            
    ADD BX, DX                  
    MOV BYTE PTR [BX + 2], '$'  
    
    POP DX
    POP BX
    RET
READ_STR ENDP

; STRLEN FUNCTION

STRLEN PROC NEAR
    PUSH SI
    XOR CX, CX                  
LEN_CON_LOOP:
    CMP BYTE PTR [SI], '$'      
    JE  LEN_DONE
    CMP BYTE PTR [SI], 13       
    JE  LEN_DONE
    INC CX
    INC SI
    JMP LEN_CON_LOOP
LEN_DONE:
    POP SI
    RET
STRLEN ENDP

; STRCMP FUNCTION

STRCMP PROC NEAR
    PUSH SI
    PUSH DI
CMP_LOOP:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL                  
    JNE MISMATCH
    CMP AL, '$'                  
    JE  MATCHED
    INC SI
    INC DI
    JMP CMP_LOOP
MISMATCH:
    MOV AX, 1                   
    JMP CMP_EXIT
MATCHED:
    MOV AX, 0                   
CMP_EXIT:
    POP DI
    POP SI
    RET
STRCMP ENDP

; STRREV FUNCTION

STRREV PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    CALL STRLEN                 
    CMP CX, 1                   
    JLE REV_DONE
    
    MOV DI, SI
    ADD DI, CX
    DEC DI                      

REV_LOOP:
    CMP SI, DI                  
    JGE REV_DONE
    
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL
    MOV [DI], AL
    
    INC SI                      
    DEC DI                      
    JMP REV_LOOP

REV_DONE:
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
STRREV ENDP

END MAIN