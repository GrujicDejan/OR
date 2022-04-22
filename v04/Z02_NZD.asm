; Napisati program koji racuna NZD za brojeve M i N.

data segment
    poruka1 db "Unesite broj M: $"
    strM db "        "
    M dw 0
    poruka2 db "Unesite broj N: $"
    strN db "        "
    N dw 0
    poruka3 db "NZD za unete brojeve je: $"
    strNZD db "        "
    NZD dw 0
    poruka4 db "Pritisnite neki taster...$"
data ends
; Definicija stek segmenta
stek segment stack
    dw 128 dup(0)
stek ends
; Ucitavanje znaka bez prikaza i memorisanja     
keyPress macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm
; Ispis stringa na ekran
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
    ; Konvertovanje stringa u broj
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
    ; Konvertovanje broja u string
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
    ; Procedura NZDRek pronalazi NZD rekurzivnom metodom
    ; Parametri procedure se nalaze na steku
    ; Rezultat procedure se ostavlja na steku
    NZDRek proc
        push ax
        push bx
        push bp
        mov bp, sp
        mov ax, [bp+8]
        mov bx, [bp+10]
    
        cmp ax, bx
        je NZDKraj 
        ; Da li je AX > BX
        jg vece           
        ; Ako je BX vece, onda cemo oduzeti AX od BX
        sub bx, ax
        jmp nastavi
    vece:          
        ; Ako je stanje obratno
        sub ax, bx
        
    nastavi:                   
        ; Ako AX i BX nisu svedeni na isti broj, onda se rekurzija nastavlja
        push ax
        push ax
        push bx
        call NZDRek                                                       
        ; Skidamo AX sa steka - prenos
        pop ax    
        
    NZDKraj: 
        ; Pri svakom povratku upise se poslednje AX na stek - prenosimo ga
        mov [bp+12], ax
        pop bp
        pop bx
        pop ax
        ret 4
    NZDRek endp
    
    start: 
        ; Postavljanje segmentnih registara      
        ASSUME cs: code, ss:stek
        mov ax, data
        mov ds, ax
        ; Ucitavanje prvog broja u string strM
        call noviRed
        writeString poruka1
        push 6                   
        push offset strM
        call readString    
        ; Konvertovanje prvog broja u promenljivu M
        push offset strM
        push offset M
        call strToInt
        ; Ucitavanje drugog broja u string strN
        call noviRed
        writeString poruka2
        push 6                   
        push offset strN
        call readString    
        ; Konvertovanje prvog broja u promenljivu N    
        push offset strN
        push offset N
        call strToInt
        ; Rekurzivni poziv
        push NZD
        push M
        push N       
        call NZDRek
        ; Uzimanje rezultata sa staka   
        pop NZD
        ; Konvertovanje rezultata u string
        push NZD 
        ; Ne moramo raditi pop NZD, pa push NZD, s obzirom da sa te dve linije koda istu vrednost povucemo sa steka,
        ; pa je ponovo vratimo. procedura intToStr ce raditi i ako samo posle poziva rekurzivne procedure NZDRek na stek
        ; push-ujemo samo offsetnu adresu od strNZD
        push offset strNZD
        call intToStr
        ; Ispis rezultata
        call noviRed
        writeString poruka3
        writeString strNZD
        ; Kraj programa
        call noviRed
        writeString poruka4
        keyPress
        krajPrograma
ends
end start
