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

                    ;mov dx, 2805h
                    ;call PrintDec
                    ;jmp @@skip

                    cmp al, 169d                    ; code of '~' up
                    je @@skip2
                    cmp al, 41d                     ; code of '~' down
                    jne @@skip                    

                    cmp flag, 0
                    jne @@del08
                    mov flag, 1
                    cli                             ; add new 08 interrupt
                    xor ax, ax
                    mov es, ax
                    mov bx, 4d * 8d                    
                    mov es:[bx], offset New08
                    mov ax, cs
                    mov es:[bx+2], ax
                    sti                    
                    jmp @@skip2

@@del08:            mov flag, 0
                    cli                             ; return old 08 interrupt
                    xor ax, ax
                    mov es, ax
                    mov bx, 4d * 8d  
                    mov ax, old08fun           
                    mov es:[bx], ax
                    mov ax, old08seg
                    mov es:[bx+2], ax
                    sti  
                    jmp @@skip2                
                    
@@skip:             pop ds es dx cx bx ax           ; end with call old 09 interrupt
                    db 0eah
                    old09fun dw 0
                    old09seg dw 0
                    iret
                    

@@skip2:            in al, 61h                      ; end without call old 09 interrupt
                    or al, 80h                      ; talk with PPI and INTC
                    out 61h, al
                    and al, not 80h
                    out 61h, al
                    mov al, 20h
                    out 20h, al
                    pop ds es dx cx bx ax
                    iret
                    endp

flag                db 0

New08               proc
                    push si ds es dx cx bx ax
                    push dx cx bx ax
                    mov bx, cs
                    mov ds, bx
                    mov bl, 02h
                    mov dx, 3a04h
                    mov ax, 0c06h
                    
                    call Ramka
                    pop ax
                    mov dx, 4005h
                    call PrintDec
                    mov dx, 3b05h
                    mov ax, offset StrAx
                    call PrintStr

                    pop ax
                    mov dx, 4006h
                    call PrintDec
                    mov dx, 3b06h
                    mov ax, offset StrBx
                    call PrintStr

                    pop ax
                    mov dx, 4007h
                    call PrintDec
                    mov dx, 3b07h
                    mov ax, offset StrCx
                    call PrintStr

                    pop ax
                    mov dx, 4008h
                    call PrintDec
                    mov dx, 3b08h
                    mov ax, offset StrDx
                    call PrintStr
                                        
                    pop ax bx cx dx es ds si
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

;-----------------------------------------
;Print ramka
;-----------------------------------------
;Entry:             AH = length
;                   AL = hight
;                   DH = X-coordinate
;                   DL = Y-coordinate
;                   BL = code of color
;
;Exit:              None
;
;Expects:           None
;
;Destroys:          AX BX CX DX ES SI
;-----------------------------------------

Ramka               proc
                    mov si, bx
                    mov bx, 0b800h        ; video mem seg addr
                    mov es, bx
                    
                    mov cx, ax            ; transition to coordinates
                    mov al, 80d
                    mul dl
                    shr dx, 8
                    add ax, dx 
                    shl ax, 1
                    mov bx, ax
                    mov ax, cx                    

                    xor dx, dx
                    mov dl, al
                    shr ax, 8

                    mov cx, si
                    mov si, ax
                    mov ax, cx
                    xor cx, cx
                    
                    mov byte ptr es:[bx], 00c9h
                    mov byte ptr es:[bx+1], al
                    mov cx, si
                    add cx, -2

@@Next1:            add bx, 2
                    mov byte ptr es:[bx], 00cdh
                    mov byte ptr es:[bx+1], al
                    loop @@Next1

                    add bx, 2
                    mov byte ptr es:[bx], 00bbh
                    mov byte ptr es:[bx+1], al

                    sub bx, si
                    sub bx, si
                    add bx, 2
                    add bx, 160d

                    mov cl, dl
                    add cl, -2 
@@NewStr:
                    push cx
                    mov byte ptr es:[bx], 00bah
                    mov byte ptr es:[bx+1], al
                    
                    mov cx, si
                    add cx, -1

@@NextIn:           add bx, 2
                    mov byte ptr es:[bx], 0020h
                    mov byte ptr es:[bx+1], al
                    loop @@NextIn

                    mov byte ptr es:[bx], 00bah
                    mov byte ptr es:[bx+1], al
                    sub bx, si
                    sub bx, si
                    add bx, 162d
                    pop cx
                    loop @@NewStr

                    mov byte ptr es:[bx], 00c8h
                    mov byte ptr es:[bx+1], al
                    mov cx, si
                    add cx, -2

@@Next2:            add bx, 2
                    mov byte ptr es:[bx], 00cdh
                    mov byte ptr es:[bx+1], al
                    loop @@Next2

                    add bx, 2
                    mov byte ptr es:[bx], 00bch
                    mov byte ptr es:[bx+1], al

                    ret
                    endp

divider             dw 0ah
StrAx               db 'AX = ', 0
StrBx               db 'BX = ', 0
StrCx               db 'CX = ', 0
StrDx               db 'DX = ', 0
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