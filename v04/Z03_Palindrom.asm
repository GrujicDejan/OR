; Napisati rekurzivnu proceduru koja proverava da li je uneti string palindrom. 

data segment             
    poruka1 db 'Unesite string:$' 
    poruka2 db 'Jeste palindrom$'
    poruka3 db 'Nije palindrom$'
    str db '                                    '
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
    ; Rekurzivna procedura za proveravanje da li je string palindrom     
    jePalindrom proc  
        push ax
        push bx         
        push dx
        
        mov ax, [si]        ; u registar AX upisujemo znak koji se nalazi na adresi cija je vrednost == SI
        mov bx, [di]        ; u registar BX upisujemo znak koji se nalazi na adresi cija je vrednost == DI
        
        cmp si, di          ; ako su SI i DI jednaki, string je palindrom
        je kraj
        
        nastavi:
            cmp al, ' '     ; ako AL ili BL imaju vrednost ' ' (white space) onda pomeri brojac za 1
            je smanjiSI     
                  
            cmp bl, ' '
            je povecajDI
             
        cmp si, di          ; proveravamo ponovo da su SI i DI jednaki zbog moguce promene brojaca 
        je kraj             ; zbog praznog mesta (white space)
        
        mov dx, si          ; ako je broj karaktera u stringu paran, brojaci ne mogu biti jednaki
        sub dx, di          ; zato proveravamo da li je razlika brojaca jednaka sa -1             
        cmp dx, -1
        je kraj 
        
        cmp al, bl   
        jne nijePalindrom   ; ako AL i BL nemaju iste vrednosti -> string nije palindrom
        
        inc di              ; azuriranje brojaca, tako da se sa DI krecemo od prvog karaktera 
        dec si              ; stringa prema sredini, dok se sa SI krecemo od poslednjeg karaktera
        call jePalindrom   
         
        jmp kraj 
        
        smanjiSI:
            dec si         
            mov ax, [si]    ; nakon sto smanjimo SI, moramo azurirati vrednost registra AX
            jmp nastavi
        
        povecajDI:
            inc di    
            mov bx, [di]    ; nakon sto smanjimo DI, moramo azurirati vrednost registra BX
            jmp nastavi   
        
        nijePalindrom:      ; ako nije palindrom, postavi vrednost SI na 0 i skoci na kraj
            mov si, 0
            jmp kraj
        
        kraj:      
            pop dx
            pop bx
            pop ax   
            ret
    jePalindrom endp
    
    ; Odredjuje duzinu unetog stringa
    ; Vrednost registra SI postaje adresa poslednjeg karaktera             
    duzinaStringa proc  
        mov si, offset str   ; inicijalizacija SI na adresu prvog karaktera
        petlja:
            mov al, [si]     ; smestamo karakter koji se nalazi na adresi SI u registar AL
            cmp al, '$'      ; ako je karakter u AL == '$' stigli smo do kraja stringa
            je smanji        ; potrebno je brojac smanjiti za 1
            inc si
            jmp petlja   
            
        smanji:
            dec si     
            
        ret  
    duzinaStringa endp
    
    start: 
        ; Postavljanje segmentnih registara      
        ASSUME cs: code, ss:stek
        mov ax, data
        mov ds, ax
        ; Ucitavanje stringa
        call noviRed    
        writeString poruka1
        push 24                   
        push offset str
        call readString   
        ; Pozivom procedure duzinaStringa setujemo registar SI
        ; SI dobija vrednost adrese poslednjeg karaktera u stringu 
        call duzinaStringa   
        ; Pre poziva procedure jePolindrom, setujemo DI na vrednost prvog karaktera u stringu
        mov di, offset str  
        call jePalindrom 
         
        call noviRed
        
        ; Ako je si == 0, to znaci da uneti string jeste palindrom
        cmp si, 0
        jne jestePalindrom   
        
        writeString poruka3
        jmp krajj
        
        jestePalindrom:
            writeString poruka2
            jmp krajj
         
        krajj:
            keyPress
            krajPrograma
ends
end start