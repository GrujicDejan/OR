; Napisati proceduru koja obrce sadrzaj unetog niza i cuva novi niz kao promenljivu.
; Novi niz odstampati na ekran

data segment
   ; Definicija podataka
   strMaxNiz db "        "
   MaxNiz dw 0     
   strBroj db "        "
   Broj dw 0        
   poruka0 db "Unesite velicinu niza: $"
   poruka1 db "Unesite element niza: $" 
   poruka2 db "Novi niz: $" 
   poruka3 db "Pritisnite bilo koji taster...$" 
   Niz dw 100 dup(0)  
   ReverseNiz dw 100 dup(0)
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
    ; Obrce sadrzaj u nizu
    reverse proc
        push ax
        push bx
        push cx
        push si
                     
        ; Uzimamo vrednost MaxNiz - 1, mnozimo je sa 2 i smestamo u registar SI
        ; Mnozimo sa 2 zato sto svaki element u nizu zauzima po 2 bajta
        ; Registar SI koristimamo za indeksiranje i iteraciju kroz ReverseNiz
        mov ax, MaxNiz
        dec ax
        mov cx, 2
        mul cx     

        mov si, ax    
        ; Da bi realizovali loop, u registar CX smestamo vrednost iz MaxNiz
        mov cx, MaxNiz  
        ; Registar BX koristimo za idneksiranje i iteraciju kroz pocetni Niz
        mov bx, 0
        
        petlja3:
            mov ax, Niz[bx]
            mov ReverseNiz[si], ax 
            add si, -2 
            add bx, 2
            loop petlja3  
              
        pop si
        pop cx
        pop bx
        pop ax  
        ret
    reverse endp
                   
    start:
        ; postavljanje segmentnih registara       
        ASSUME cs: code, ss:stek
        mov ax, data
        mov ds, ax
        call novired
        writeString poruka0 
        ; Ucitavanje velicine niza
        push 3
        push offset strMaxNiz
        call readString    
        ; Konvertovanje stringa u broj
        push offset strMaxNiz
        push offset MaxNiz
        call strtoint 
        
        mov cx, MaxNiz                                        
        mov si, 0     
        
        unos:         
            ; Ucitavanje broja u string
            call noviRed
            writeString poruka1
            push 6
            push offset strBroj 
            call readString
            ; Konvertovanje stringa u broj
            push offset strBroj
            push offset Broj   
            call strToInt
            ; Smestanje broja u niz
            mov ax, Broj
            mov Niz[si], ax
            ; SI se povecava za 2 kako bi dobili poziciju sledeceg elementa u nizu. 1 element = 2 bajta
            add si, 2
            loop unos

        ; Poziv procedure koja obrce sadrzaj niza 
        call reverse   
    
        mov cx, MaxNiz                                        
        mov si, 0
                     
        ; Ispis novog niza   
        call noviRed  
        writeString poruka2
        petlja:                                             
            call noviRed
            ; Konvertovanje elementa niza (broja) u string
            push ReverseNiz[si]
            push offset strBroj
            call intToStr
            writeString strBroj
            ; SI se povecava za 2 kako bi dobili poziciju sledeceg elementa
            add si, 2
            loop petlja  
            
        call noviRed
        writeString poruka3
        keyPress
        krajPrograma 
ends
end start
