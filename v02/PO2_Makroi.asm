; Makro koji sabira parametre A, B i C i rezultat smešta u parametar A 

saberi macro a b c
    add a, b
    add a, c
endm

code segment
    start:
        ASSUME cs: code  
        
    mov ax, 3
    mov bx, 5
    mov cx, 7
    saberi ax bx cx
    mov dx, 4
    saberi dx bx cx
    
    end start
code ends

