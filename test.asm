.model tiny
.code
org 100h

locals @@
Start:
jmp Begin

;-----------------------------------------
;Print buf in videoRAM
;-----------------------------------------
;Entry:             AX = offset buffer
;                   DH = X-coordinate
;                   DL = Y-coordinate
;
;Exit:              None
;
;Expects:           None
;
;Destroys:          AX BX SI CX DX ES
;-----------------------------------------
PrintBuf            proc
                    mov bx, 0b800h        ; video mem seg addr
                    mov es, bx
                    mov si, ax
                    
                    xor cx,cx
                    mov cl, [si]  
                    inc si 

                    xor ax, ax           ; transition to coordinates                                          
                    mov al, 80d
                    mul dl
                    shr dx, 8
                    add ax, dx 
                    shl ax, 1
                    
@@Next:             mov bx, si
                    mov dx, ds:[bx]
                    mov bx, ax
                    mov es:[bx], dx
                    add si, 2
                    add ax, 2
                    loop @@Next
                    
@@stop:             ret
                    endp 
;-----------------------------------------
;Print string in buffer
;-----------------------------------------
;Entry:             AX = offset string
;                   BX = offset buffer
;
;Exit:              None
;
;Expects:           None
;
;Destroys:          AX BX CX DX
;-----------------------------------------
fPrintStr           proc
                    mov cx, bx
                    
@@Next:             mov bx, ax
                    mov dl, ds:[bx]
                    cmp dl, 0
                    je @@stop 
                    mov bx, cx
                    mov ds:[bx], dl 
                    mov byte ptr ds:[bx+1], 4eh                                       
                    inc ax
                    add cx, 2
                    jmp @@Next
                    
@@stop:             ret
                    endp 

msg:                db "my_string", 0
Begin:              mov ax, offset msg
                    mov bx, offset Buffer
                    inc bx

                    call fPrintStr

                    mov dx, 2805h

                    mov ax, offset Buffer

                    call PrintBuf


                    mov ax, 4c00h
                    int 21h
Buffer:             db 9
end                 Start

                