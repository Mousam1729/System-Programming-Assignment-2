.MODEL SMALL
.STACK 100H
.DATA
    PROMPT          DB 'Enter a 2-digit hex value (0-9, A-F): $'
    RESULT_MSG      DB 0Dh, 0Ah, 'The corresponding ASCII character is: $'
    HEX_INPUT       DB ?                    
    HIGH_CHAR       DB ?                    
    LOW_CHAR        DB ?                    
    NEWLINE         DB 0Dh, 0Ah, '$'

.CODE
MAIN PROC
    MOV AX, @DATA                       
    MOV DS, AX               

    ; 1. Display Prompt        
    MOV AH, 09h
    LEA DX, PROMPT
    INT 21h         

    ; 2. Read and Validate First Character (High Nibble)    
GET_HIGH_CHAR:
    MOV AH, 07h                      ; DOS function: Read character WITHOUT echo
    INT 21h                          ; Character is now in AL        
    
    ; Validate: Is it between '0' and '9'?
    CMP AL, '0'
    JB  INVALID_HIGH                 ; Less than '0' -> Invalid
    CMP AL, '9'
    JBE VALID_HIGH                   ; Between '0' and '9' -> Valid        
    
    ; Validate: Is it between 'A' and 'F'?
    CMP AL, 'A'
    JB  INVALID_HIGH                 ; Between '9' and 'A' -> Invalid
    CMP AL, 'F'
    JBE VALID_HIGH                   ; Between 'A' and 'F' -> Valid

INVALID_HIGH:
    ; Print a beep sound to alert the user
    MOV AH, 02h
    MOV DL, 07h                      ; ASCII 07h is the system beep (bell)
    INT 21h
    JMP GET_HIGH_CHAR                ; Repeat loop until valid input

VALID_HIGH:
    MOV HIGH_CHAR, AL                ; Save the valid ASCII character
    MOV AH, 02h                      ; Manually echo the valid character to screen
    MOV DL, AL
    INT 21h         

    ; 3. Read and Validate Second Character (Low Nibble)    
GET_LOW_CHAR:
    MOV AH, 07h                      ; Read without echo
    INT 21h        
    
    ; Validate '0'-'9'
    CMP AL, '0'
    JB  INVALID_LOW
    CMP AL, '9'
    JBE VALID_LOW        
    
    ; Validate 'A'-'F'
    CMP AL, 'A'
    JB  INVALID_LOW
    CMP AL, 'F'
    JBE VALID_LOW

INVALID_LOW:
    MOV AH, 02h
    MOV DL, 07h                      ; Beep
    INT 21h
    JMP GET_LOW_CHAR                 ; Repeat loop until valid input

VALID_LOW:
    MOV LOW_CHAR, AL                 ; Save the valid ASCII character
    MOV AH, 02h                      ; Manually echo the valid character
    MOV DL, AL
    INT 21h         

    ; 4. Convert Valid ASCII Characters to a Single Byte    
    ; Process High Character
    MOV AL, HIGH_CHAR
    CMP AL, '9'
    JBE CONVERT_HIGH_INPUT
    SUB AL, 7                        ; Adjust for 'A'-'F'
CONVERT_HIGH_INPUT:
    SUB AL, 30h                      ; Convert to raw value (0-15)
    MOV CL, 4
    SHL AL, CL                       ; Shift to high nibble
    MOV HEX_INPUT, AL                    

    ; Process Low Character
    MOV AL, LOW_CHAR
    CMP AL, '9'
    JBE CONVERT_LOW_INPUT
    SUB AL, 7                        ; Adjust for 'A'-'F'
CONVERT_LOW_INPUT:
    SUB AL, 30h                      ; Convert to raw value (0-15)
    OR HEX_INPUT, AL                 ; Combine into HEX_INPUT         

    ; 5. Display Result Heading    
    MOV AH, 09h
    LEA DX, RESULT_MSG
    INT 21h         

    ; 6. Print the Actual ASCII Character
    MOV AH, 02h                           
    MOV DL, HEX_INPUT                ; Load the combined raw numeric byte into DL
    INT 21h                          ; AH=02h prints whatever character maps to this ASCII value

    ; Print a final newline    
    MOV AH, 09h
    LEA DX, NEWLINE
    INT 21h    

    ; Terminate Program
    MOV AH, 4Ch                         
    INT 21h
MAIN ENDP
END MAIN
