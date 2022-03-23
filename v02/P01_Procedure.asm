; Procedura koja sabira registre AX, BX i CX i rezultat smešta u registar AX     
                  
code segment
    saberi proc
        add ax, bx
        add ax, cx
        ret
    saberi endp
                    
    start:
        Assume cs: code
        
        mov ax, 3
        mov bx, 5
        mov cx, 7
        call saberi     
    end start
    
code ends 
END

