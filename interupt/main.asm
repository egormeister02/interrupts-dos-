.model tiny
.code
org 100h

locals @@
Start:
jmp EOP
New09               proc 
                    push ax bx cx dx es ds

                    mov ax, cs
                    mov ds, ax
                    xor ax, ax
                    in al, 60h

                    cmp al, 29d
                    je @@del08
                    cmp al, 41d
                    jne @@skip                    

                    cli
                    xor ax, ax
                    mov es, ax
                    mov bx, 4d * 8d                    
                    mov es:[bx], offset New08
                    mov ax, cs
                    mov es:[bx+2], ax
                    sti                    
                    jmp @@skip2

@@del08:            cli
                    xor ax, ax
                    mov es, ax
                    mov bx, 4d * 8d  
                    mov ax, old08fun           
                    mov es:[bx], ax
                    mov ax, old08seg
                    mov es:[bx+2], ax
                    sti  
                    jmp @@skip2                
                    
@@skip:             pop ds es dx cx bx ax
                    db 0eah
                    old09fun dw 0
                    old09seg dw 0
                    iret
                    

@@skip2:            in al, 61h
                    or al, 80h
                    out 61h, al
                    and al, not 80h
                    out 61h, al
                    mov al, 20h
                    out 20h, al
                    pop ds es dx cx bx ax
                    iret
                    endp

New08               proc
                    push ax bx cx dx es ds
                    
                    mov bx, cs
                    mov ds, bx
                    mov dx, 4005h
                    call PrintDec
                    mov dx, 3B05h
                    mov ax, offset StrAx
                    call PrintStr
                                        
                    pop ds es dx cx bx ax
                    db 0eah
                    old08fun dw 0
                    old08seg dw 0
                    iret
                    endp


;-----------------------------------------
;Print string
;-----------------------------------------
;Entry:             AX = offset string
;                   DH = X-coordinate
;                   DL = Y-coordinate
;
;Exit:              None
;
;Expects:           None
;
;Destroys:          AX BX CX DX ES
;-----------------------------------------
PrintStr            proc

                    mov bx, 0b800h        ; video mem seg addr
                    mov es, bx

                    mov cx, ax            ; transition to coordinates  
                    xor ax, ax                                         
                    mov al, 80d
                    mul dl
                    shr dx, 8
                    add ax, dx 
                    shl ax, 1
                    
@@Next:             mov bx, cx
                    mov dl, ds:[bx]
                    cmp dl, 0
                    je @@stop 
                    mov bx, ax
                    mov es:[bx], dl 
                    inc cx
                    add ax, 2
                    jmp @@Next
                    
@@stop:             ret
                    endp 
;-----------------------------------------
;Print value in dec
;-----------------------------------------
;Entry:             AX = value
;                   DH = X-coordinate
;                   DL = Y-coordinate
;
;Exit:              None
;
;Expects:           None
;
;Destroys:          BX CX DX ES SI
;-----------------------------------------

PrintDec            proc
                    mov bx, 0b800h        ; video mem seg addr
                    mov es, bx

                    mov cx, ax            ; transition to coordinates
                    mov al, 80d
                    mul dl
                    shr dx, 8
                    add ax, dx 
                    add ax, 5
                    shl ax, 1
                    mov bx, ax  
                    mov ax, cx

                    xor dx, dx
                    mov cx, 0005h

@@Next:             
                    add bx, -2
                    
                    div divider
                    add dl, 30h           ; 30h = 48d = '0'   
                    mov es:[bx], dl
                    xor dx, dx
                    loop @@Next

                    ret
                    endp

divider             dw 0ah
StrAx               db 'AX = ', 0
EOP:                
                    cli
                    xor ax, ax
                    mov es, ax
                    mov bx, 4d * 9d
                    mov ax, es:[bx]
                    mov old09fun, ax
                    mov ax, es:[bx+2]
                    mov old09seg, ax

                    mov es:[bx], offset New09
                    mov ax, cs
                    mov es:[bx+2], ax

                    mov bx, 4d * 8d
                    mov ax, es:[bx]
                    mov old08fun, ax
                    mov ax, es:[bx+2]
                    mov old08seg, ax
                    sti

                    mov ax, 3100h
                    mov dx, offset EOP
                    shr dx, 4
                    inc dx
                    int 21h

end                 Start