; Napisati funkciju koja za uneti string zagrada S vraca minimalan broj izmena 
; koji je potreban da bi izraz sa zagradama bio validan.         

data segment
    poruka1 db 'Unesite string: $'  
    poruka2 db 'Minimalan broj izmena je: $' 
    poruka3 db 'String je ispravno unet. $' 
    poruka4 db 'Pritisnite neki taster...$'       
    brojIzmenaStr db ?                      
    brIzmena dw ?
    S db '                           '
ends
; Deficija stek segmenta
stek segment
    dw 128 dup(0
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
    
    ; Odredjuje duzinu unetog stringa
    ; Vrednost registra SI postaje adresa poslednjeg karaktera             
    duzinaStringa proc  
        mov si, offset S     ; inicijalizacija SI na adresu prvog karaktera
        petlja:
            mov al, [si]     ; smestamo karakter koji se nalazi na adresi SI u registar AL
            cmp al, '$'      ; ako je karakter u AL == '$' stigli smo do kraja stringa
            je break         ; potrebno je brojac smanjiti za 1
            inc si
            jmp petlja
            
        break:         
        ret  
    duzinaStringa endp
    
    ; Procedura koja racuma minimalan broj izmena stringa S
    ; Zrocedura je zamisljena tako da postoji brojac koji se inkrementira za svaku otvorenu zagradu koja postoji
    ; u stringu. Ukoliko je brojac > 0 (postoje otvorene zagrade), brojac se dekrementira ako se naidje na zatvorenu 
    ; zagradu. Ako smo detektovali zatvorenu zagradu i pri tome ne postoji ne postoji ni jedna otvorena zagrada koja 
    ; nije zatvorena onda povecavamo drugi brojac. Primer: ((2+i-1) -> minimalan broj promena je = 1. sto predstavlja 
    ; brisanje prve zagrade ili dodavanje zatvorene na kraj a tu vrednost dobijamo iz prvog brojaca cija ce vrednost biti
    ; jednaka sa 1.
    BrojIzmena proc  
        push ax 
        push bx
        push cx
        push si 
        push di
         
        mov bx, offset S    ; Smestamo adresu prvog karaktera stringa 
        mov al, [bx] 
        sub si, offset S    ; Da bi dobili velicinu stringa potrebno je od SI oduzeti ax
        mov cx, si          ; Postavljamo CX na vrednost SI (velicina stringa) zbog broja iteracija u petlji koji diktira vrednost registra CX
        mov si, 0           ; Brojac otvorenih zagrada
        mov di, 0           ; Brojac gresaka ( zatvorena zagrada bez potrebe, npr: 'ovoJeNeki)String' )
        
        petlja1:                    ; U AL smestamo karakter na koji smo naisli
            cmp al, 29h             ; Ako je karakter jednak sa 29h (hex vrednost za zatvorenoj zagradi)
            je zatvorenaZagrada     ; Skoci na labelu zatvorenaZagrada        
            cmp al, 28h             ; Ako je karakter jednak sa 28h (hex vrednost za otvorenu zagradi)
            je otvorenaZagrada      ; Skoci na labelu otvorenaZagrada 
            nastavi:                ; Ako prethodna dva uslova nisu ispunjena kreni sa citanjem sledeceg karaktera
                inc bx
                mov al, [bx]      
            loop petlja1            ; Petlja se izvrsava se sve dok je CX > 0
            
        add si, di  ; Na broj otvorenih zagrada, koje nisu zatvorene, 
                    ; dodati broj zagrada koje su zatvorene bez da je prethodno bila otvorena zagrada
    
        jmp kraj    ; Skoci na kraj
        
        otvorenaZagrada:
            inc si          ; Ako je zagrada otvorena povecaj brojac otvorenih zagrada
            jmp nastavi     ; Skoci na labelu nastavi unutar petlje i citaj sledeci karakter u stringu
            
        zatvorenaZagrada:   
            cmp si, 0       ; Ako je SI = 0, tj. nema "visak" otvorenih zagrada
            je povecajDI    ; Skoci na labelu povecajDI
            dec si          ; U suprotnom brojac otvorenih zagrada za 1.
            jmp nastavi     ; Skoci na labelu nastavi unutar petlje i citaj sledeci karakter u stringu
            
            
        povecajDI:
            inc di          ; Povecaj brojac gresaka (bespotrebno zatvorenih zagrada)
            jmp nastavi     ; Skoci na labelu nastavi unutar petlje i citaj sledeci karakter u stringu
        
        kraj:               
            mov brIzmena, si    ; Smesti broj izmena u promenljivu brIzmena    
            pop di
            pop si   
            pop cx 
            pop bx
            pop ax
            ret 
    BrojIzmena endp
    
    start:    
        ; Postavljanje segmentnih registara  
        ASSUME cs: code, ss:stek
        mov ax, data
        mov ds, ax
          
        ; Unos stringa
        call noviRed
        writeString poruka1
        push 18
        push offset S
        call readString   
        ; Odredjivanje duzine stringa 
        call duzinaStringa
        call brojIzmena
           
        cmp brIzmena, 0
        je korektanString              
        
        ; Pretvaranje vrednosti koja je dobijena procedurom 'brojIzmena' u string 
        push brIzmena
        push offset brojIzmenaStr     
        call intToStr
        
        call noviRed
        writeString poruka2
        writeString brojIzmenaStr
        jmp krajPrograma       
            
        korektanString:
            call noviRed
            writeString poruka3
            
        
        krajPrograma:
            call noviRed 
            writeString poruka4
            keyPress
            krajPrograma
    end start
code ends
