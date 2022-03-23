; Napisati program koji ucitava brojeve M i N i ispisuje tablicu množenja dimenzije MxN

data segment
    poruka1 db "Unesite broj M: $"
    strM db "        "
    M dw 0
    poruka2 db "Unesite broj N: $"
    strN db "        "
    N dw 0
    poruka3 db "Tablica mnozenja izgleda ovako: $"
    strBroj db "        "
    Broj dw 0
    poruka4 db "Pritisnite neki taster...$"
data ends
; Definicija stek segmenta
stek segment stack
    dw 128 dup(0)
stek ends       
; Ispis znaka na ekran
write macro c
    push ax
    push dx
    mov ah, 02
    mov dl, c
    int 21h
    pop dx
    pop ax
endm
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
 
    unos:
        ; Unos broja M u string strM
        call noviRed
        writeString poruka1
        push 6
        push offset strM
        call readString
        ; Konvertovanje stringa strM u broj M
        push offset strM
        push offset M
        call strToInt
        ; Unos broja N u string strN
        call noviRed
        writeString poruka2
        push 6 
        push offset strN
        call readString
        ; Konvertovanje string strN u broj N
        push offset strN
        push offset N
        call strToInt
        ; Ispis poruke za ispis tablice
        call noviRed
        writeString poruka3
        call noviRed
        ; Ispis tablice
        mov si, 1
        mov cx, N
        petlja3:
            mov di, 1
            push cx
            mov cx, M
        petlja4:    
            mov ax, si
            mul di
            mov Broj, ax  
            push Broj
            push offset strBroj
            call intToStr
            writeString strBroj
            write ' '
            add di, 1
            loop petlja4
            
            pop cx
            call noviRed
            add si, 1
            loop petlja3
        ; Kraj programa
        writeString poruka4
        keyPress
        krajPrograma      
    end start
code ends
 
    
    