; Napisati program koji ispisuje faktorijel unetog broja (broj definisati u DS).
; Broj unosi korisnik.

data segment
    poruka1 db "Unesite broj: $"
    strM db "        "
    M db 0
    strResenje db "        "
    brojResenje dw 0
    poruka2 db "Resenje je: $"
    poruka3 db "Pritisnite neki taster...$"
data ends
; Definicija stek segmenta
stek segment stack
    dw 128 dup(0)
stek ends                

; Ucitavanje znaka bez cuvanja
keypress macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm              
; Ispis stringa na ekran
writeString macro s         
    push ax
    push dx     
    mov ah, 09
    mov dx, offset s
    int 21h
    pop dx
    pop ax
endm 
; Kraj programa
krajPrograma macro
    mov ax, 4c02h
    int 21h
endm         

code segment
    ; Novi red
    noviRed proc
        push ax
        push bx
        push cx
        push dx  
        
        ; Citanje pozicije kursora
        mov ah, 03
        mov bh, 0
        int 10h
        ; Postavljanje kursora
        inc dh
        mov dl, 0
        mov ah, 02
        int 10h
        
        pop dx
        pop cx
        pop bx
        pop ax    
        ret
    noviRed endp     
    ; Ucitavanje stringa
    ; Adresa stringa je parametar na steku 
    readString proc
        push ax
        push bx
        push cx
        push dx
        push si 
        
        mov bp, sp
        mov dx, [bp+12]
        mov bx, dx
        mov ax, [bp+14]
        mov byte [bx], al
        mov ah, 0Ah
        int 21h
        mov si, dx
        mov cl, [si+1]
        mov ch, 0
        kopiraj:
            mov al, [si+2]
            mov [si], al
            inc si
            loop kopiraj
        mov [si], '$'
        
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret 4
    readString endp    
    ; Konvertovanje stringa u broj
    strToInt proc
        push ax
        push bx
        push cx
        push dx
        push si         
        
        mov bx, sp
        mov bx, [bp+14]
        mov ax, 0
        mov cx, 0
        mov si, 10   
        petlja1:
            mov cl, [bx]
            cmp cl, '$'
            je kraj1
            mul si
            sub cx, 48
            add ax, cx
            inc bx
            jmp petlja1
        kraj1:
            mov bx, [bp+12]
            mov [bx], ax
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret 4
    strToInt endp    
    ; Konvertovanje broja u string
    inttostr proc
       push ax
       push bx
       push cx
       push dx
       push si
       mov bp, sp
       mov ax, [bp+14] 
       mov dl, '$'
       push dx
       mov si, 10
    petlja2:
       mov dx, 0
       div si
       add dx, 48
       push dx
       cmp ax, 0
       jne petlja2
       mov bx, [bp+12]
    petlja2a:      
       pop dx
       mov [bx], dl
       inc bx
       cmp dl, '$'
       jne petlja2a
       pop si  
       pop dx
       pop cx
       pop bx
       pop ax 
       ret 4
    inttostr endp  
    
    start:  
        ; Postavljanje segmentnih registara  
        ASSUME cs: code, ss:stek
        mov ax, data
        mov ds, ax
        
        
        ; Unos broja sa tastature
        call noviRed
        writeString poruka1
        push 6 
        push offset strM
        call readString
        push offset strM
        push offset M
        call strToInt
        call noviRed
        ; Racunanje faktorijela
        XOR AX, AX
        MOV AL, M
        L1:
            DEC M
            MUL M
            MOV CL, M
            CMP CL, 01
            JNE L1   
          
        MOV brojResenje, AX
        ; Ispis rezultata
        writeString poruka2
        ; call noviRed
        push brojResenje
        push offset strResenje
        call intToStr
        writeString strResenje
        call noviRed
        writeString poruka3
        keyPress
        krajPrograma
    end start
code ends