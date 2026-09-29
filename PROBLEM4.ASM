.model small
.stack 100h

.data
    menu    db 10, 13, "--- MASM CALCULATOR ---"
            db 10, 13, "1. Addition (+)"
            db 10, 13, "2. Subtraction (-)"
            db 10, 13, "3. Multiplication (*)"
            db 10, 13, "4. Division (/)"
            db 10, 13, "Enter choice (1-4): $"
    
    msg1    db 10, 13, "Enter first number: $"
    msg2    db 10, 13, "Enter second number: $"
    msgRes  db 10, 13, "Result: $"
    msgErr  db 10, 13, "Invalid Choice!$"
    msgRem  db " Remainder: $"
    msgNeg  db "-$"
    
    num1    dw ?        
    num2    dw ?
    choice  db ?

.code
main:
    mov ax, @data
    mov ds, ax

display_menu:
    mov ah, 09h
    lea dx, menu
    int 21h

    mov ah, 01h
    int 21h
    mov choice, al

    cmp choice, '1'
    jl handle_invalid
    cmp choice, '4'
    jg handle_invalid
    jmp get_inputs

handle_invalid:
    jmp NEAR ptr invalid_choice

get_inputs:
    mov ah, 09h
    lea dx, msg1
    int 21h
    call ReadNum
    mov num1, ax

    mov ah, 09h
    lea dx, msg2
    int 21h
    call ReadNum
    mov num2, ax

    mov ah, 09h
    lea dx, msgRes
    int 21h

    cmp choice, '1'
    jne check_sub
    jmp NEAR ptr op_add
check_sub:
    cmp choice, '2'
    jne check_mul
    jmp NEAR ptr op_sub
check_mul:
    cmp choice, '3'
    jne check_div
    jmp NEAR ptr op_mul
check_div:
    cmp choice, '4'
    jne handle_invalid
    jmp NEAR ptr op_div

op_add:
    mov ax, num1
    add ax, num2
    call PrintNum
    jmp NEAR ptr exit_prog

op_sub:
    mov ax, num1
    cmp ax, num2
    jge sub_positive
    
    push ax
    mov ah, 09h
    lea dx, msgNeg
    int 21h
    pop ax
    
    mov bx, num2
    sub bx, ax
    mov ax, bx
    jmp print_sub_res
sub_positive:
    sub ax, num2
print_sub_res:
    call PrintNum
    jmp NEAR ptr exit_prog

op_mul:
    mov ax, num1
    mul num2            
    call PrintNum
    jmp NEAR ptr exit_prog

op_div:
    cmp num2, 0
    je div_by_zero
    
    mov ax, num1
    xor dx, dx          
    mov bx, num2
    div bx              
    
    push dx             
    call PrintNum       
    
    mov ah, 09h
    lea dx, msgRem
    int 21h
    pop ax              
    call PrintNum
    jmp NEAR ptr exit_prog

div_by_zero:
    mov ah, 09h
    lea dx, msgErr
    int 21h
    jmp NEAR ptr exit_prog

invalid_choice:
    mov ah, 09h
    lea dx, msgErr
    int 21h

exit_prog:
    mov ah, 4Ch
    int 21h


; PROCEDURE: ReadNum (Fixed Multi-Digit Logic)

ReadNum proc
    push bx
    push cx
    push dx
    
    xor bx, bx          ; BX builds our final value
    xor cx, cx          ; CH = temporary digit, CL = flag for digits entered

read_loop:
    mov ah, 01h         
    int 21h
    
    cmp al, 13          ; Enter key?
    je check_enter
    
    cmp al, '0'         
    jl skip_digit
    cmp al, '9'         
    jg skip_digit
    
    sub al, '0'
    mov ch, al          ; Store current digit safely in CH
    inc cl              ; Increment digit counter
    
    ; Safely multiply running sum by 10: BX = BX * 10
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax          ; BX = BX * 10
    
    ; Add current digit
    xor ax, ax
    mov al, ch          ; AX = current digit
    add bx, ax          ; Accumulate into BX
    jmp read_loop

skip_digit:
    jmp read_loop

check_enter:
    cmp cl, 0           
    jne done_reading
    jmp read_loop       

done_reading:
    mov ax, bx          ; Return result cleanly in AX
    pop dx
    pop cx
    pop bx
    ret
ReadNum endp

; PROCEDURE: PrintNum

PrintNum proc
    push ax
    push bx
    push cx
    push dx
    
    xor cx, cx          
    mov bx, 10          

split_digits:
    xor dx, dx
    div bx              
    push dx             
    inc cx
    cmp ax, 0
    jne split_digits

print_loop:
    pop dx              
    add dl, '0'         
    mov ah, 02h         
    int 21h
    loop print_loop
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintNum endp

end main
 