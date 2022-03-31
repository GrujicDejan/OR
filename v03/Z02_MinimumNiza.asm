; Uneti niz (korisnik unosi), naci njegov minimum i ispisati ga na ekran.

data segment  
    poruka0 db "Unesite broj elemenata niza: $" 
    strMaxNiz db "        "
    MaxNiz dw 0
    poruka1 db "Unesite broj: $"
    strN db "        "
    N dw 0
    Niz dw 100 dup(0)
    poruka2 db "Minimum unetog niza je: $"
    strMin db "        "
    Min dw 0
    poruka3 db "Pritisnite neki taster...$"
ends
; Deficija stek segmenta
stek segment stack
    dw 128 dup(0)
ends                
; Ucitavanje znaka bez prikaza i cuvanja     
keyPress macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm
; Isis stringa na ekran
writeString macro s
    push ax
    push dx  
    mov dx, offset s
    mov ah, 09
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
        mov ah,03
        mov bh,0
        int 10h
        inc dh
        mov dl,0
        mov ah,02
        int 10h
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    noviRed endp
    ; Ucitavanje stringa sa tastature
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
        mov byte [bx] ,al
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
    ; Konvertuje string u broj
    strToInt proc
        push ax
        push bx
        push cx
        push dx
        push si
        mov bp, sp
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
    ; Konvertuje broj u string
    intToStr proc
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
    intToStr endp  
    
    start:    
        ; Postavlajnje segmentnih registara
        ASSUME cs: code, ss:stek
        mov ax, data
        mov ds, ax
        
        call noviRed
        writeString poruka0
        push 3
        push offset StrMaxNiz
        call readString
        ; Konvertovanje stringa u broj
        push offSet StrMaxNiz
        push offset MaxNiz
        call strToInt
        ; Smestanje broja u niz
        mov cx, MaxNiz
        mov si, 0      
 
    unos:
        ; Ucitavanje broja u string
        call noviRed
        writeString poruka1
        push 6
        push offset strN
        call readString
        ; Konvertovanje stringa u broj
        push offset strN
        push offset N
        call strToInt
        ; Smestanje broja u niz
        mov ax, N 
        mov Niz[si], ax       
        ; SI se poveca za 2 kako bi dobio poziciju sledeceg elementa u nizu, jer su elementi veliki 2 bajta.
        add si, 2
        loop unos
        ; Postavanje prvog broja za minimum
        mov si, 0
        mov ax, Niz[si]
        mov min, ax
        ; Trazenje minimuma
        mov cx, MaxNiz
        sub cx, 1
        petlja:
            add si, 2
            mov ax, Niz[si]
            cmp min, ax
            jl dalje
            mov min, ax
        dalje:
            loop petlja
            ; Konvertovanje minimuma u string
            push Min
            push offset strMin
            call intToStr
            ; Ispis rezultata na ekran
            call noviRed
            writeString poruka2
            writeString strMin
            ; Kraj programa
            call noviRed
            writeString poruka3
            keyPress
            krajPrograma
    end start
ends