; Napisati program koji crta pravougaonik proizvoljih dimenzija za unete koordinate
; x1,y1 i x2,y2 i boji ga u boju po izboru.

data segment
     ; Promenljive potrebne za rad sa grafikom
     pozX dw ?      ; trenutna pozicija znaka
     pozY dw ?
     sirina dw ?    ; maksimalna sirina i visina ekrana
     visina dw ? 
     adresa dw ?    ; ofsetna adresa znaka
     boja db ?
     znak db ?      ; pomocna promenljiva za makro readString
     ; Promenljive potrebne za program
     porukaX1 db 'Unesite X1: $'
     porukaY1 db 'Unesite Y1: $'
     porukaX2 db 'Unesite X2: $'
     porukaY2 db 'Unesite Y2: $'
     porukaBoja db 'Unesite boju: $'
     strBroj db '            '
     pozX1 dw ?
     pozY1 dw ?
     pozX2 dw ?
     pozY2 dw ?
     bojaPravougaonika dw ?     ; https://en.wikipedia.org/wiki/BIOS_color_attributes
   
     poruka db 'Pritisnite neki taster...$'
data ends

; Postavljanje stek segmenta
stek segment stack
     dw 128 dup(?)
stek ends

code segment   
    
    ; Inicijalizacija promenljivih potrebnih za rad sa grafikom          
    
    ; ovaj makro se koristi za inicijalizaciju ES registra
    macro initGraph
         push ax
         mov ax, 0B800h
         mov es, ax
         mov sirina, 80
         mov visina, 25
         mov pozX, 0        ; vrednost tekuceg polja je (0,0)
         mov pozY, 0
         mov adresa, 0
         mov boja, 7        ; siva boja na crnoj podlozi
         pop ax
    endm 
    
    ; Pomera nas na polje definisano parametrima makroa              
    macro setXY x y
         push ax
         push bx
         push dx
         ; vrednosti se smestaju u pozX i pozY, a nakon toga se racuna adresa tog znaka 
         ; u ekranskoj memoriji po formuli adresa = pozY*160+pozX*2
         mov pozX, x
         mov pozY, y 
         mov ax, pozY     
         mov bx, sirina
         shl bx, 1      ; pomeranje bitova u levo za 1: mnozenje sa 2
         mul bx         ; mnozi bx sa ax
         mov bx, pozX   ; opet pomeranje u levo
         shl bx, 1      ; i na kraju sabiranje
         add ax, bx
         mov adresa, ax
         
         pop dx
         pop bx
         pop ax
    endm
    
    ; Postavljanje tekuce boje
    macro setColor b
         mov boja, b
    endm  
    
    ; Ucitavanje znaka bez prikaza i memorisanja           
    keyPress macro
        push ax
        mov ah, 08
        int 21h
        pop ax
    endm  
    
    ; Ispis znaka na tekucu poziciju ekrana
    macro Write c
         push bx        
         push dx
         mov bx, adresa
         mov es:[bx], c
         mov dl, boja      ; stavljamo boju prvo u pomocni registar dl
         mov es:[bx+1], dl ; boja se smesta na adresu odmah posle znaka
         pop dx
         pop bx
    endm  
    
    ; Ispis stringa na ekran
    writeString macro str
        LOCAL petlja, kraj    ; dve lokalne petlje
        push ax
        push bx  
        push si               ; kao index u stringu
        mov si, 0             ; nulti znak stringa je pocetni
        mov ah, boja
        mov bx, adresa        ; smestamo ga na adresu
        petlja:
            mov al, str[si]       ; iz stringa se uzimaju znakovi redom i smestaju se u al
            cmp al, '$'           ; ako se naidje na $ prelazi se na kraj ispisa
            je kraj
            mov es:[bx], al       ; iz registra al se zajedno sa bojom stavljaju na ekran
            mov es:[bx+1], ah
            add bx, 2
            add si, 1             ; pomeramo se za 2 mesta u memoriji
            jmp petlja
            
        kraj:           
            mov ax, pozX          ; pozicija X se pomera za duzinu stringa
            add ax, si
            mov bx, pozY
            setXY ax bx
            pop si
            pop bx
            pop ax
    endm 
               
    krajPrograma macro
        mov ax, 4c02h
        int 21h
    endm 
    
    ; Crtanje pravougaonika        

    nacrtajPravougaonik macro x1 y1 x2 y2
        LOCAL petlja1, petlja2
        push ax
        push bx    
        push cx
        push dx    
        push si
        
        mov ax, x1      ; Prvo se pozicioniramo na gornje levo teme (x1,y1)
        mov dx, y1
        setXY ax dx     ; postavimo tekucu poziciju
        mov bx, adresa  ; i ovde sacuvamo adresu tog polja
    
        mov dl, 178     ; redni broj karaktera koji ce se koristiti pri 
        mov dh, boja    ; iscrtavanju pravougaonika (karakter 178)
                        ; boja pravougaonika
       
        mov ax, x2      ; broj znakova u jednoj vrsti koje treba iscrtati
        sub ax, x1
        add ax, 1       ; ax = X2-X1+1
                        
        mov cx, y2      ; broj vrsta koje treba popuniti
        sub cx, y1
        add cx, 1       ; Y2-Y1+1
    
        ;  Iscrtavanje pravougaonika vrsi se koriscenjem dvostruke loop petlje
       
        petlja1:
            push cx  
            mov cx, ax   ; u cx se smesta broj znakova u jednoj vrsti koje treba iscrtati
            mov si, 0
        petlja2:
            mov es:[bx+si], dl      ; znak = popunjen pravougaonik
            mov es:[bx+si+1], dh    ; njegova boja upisuje se odmah posle u memoriju ekrana
            add si, 2               ; pomeramo se za 2
            loop petlja2            ; idemo dalje
            
            pop cx    ; nakon svake unutrasnje petlje pomeramo se u novi red, na prvo mesto
            add bx, 160    ; tako sto se bx povecava za 160
            loop petlja1
        
            pop si
            pop dx
            pop cx
            pop bx
            pop ax
    endm 
    
    ; Ekran se brise postavljanjem znaka space na svih 2000 znakova, sa bojom 7.
    ; U emulatoru radi dooooooooosta sporo...
         
    macro clrScreen
        LOCAL petlja
        push bx
        push cx
        mov bx, 0
        mov cx, 2000
        petlja:
            mov es:[bx], ' '
            mov es:[bx+1], 7  
            add bx, 2
            loop petlja
            pop cx
            pop bx
    endm 
    
    ; Novi red
    writeLn proc  
         push ax
         push bx
         mov bx, pozY
         add bx, 1       ; prvo povecavamo pozY za 1
         mov ax, 0       ; pozX ce biti 0
         setXY ax, bx    ; postavljanje
         pop bx
         pop ax
         ret
    writeLn endp       
    
    
    ; Ucitavanje jednog znaka   
    readkey macro c
        push ax
        mov ah, 08
        int 21h
        mov c, al
        pop ax
    endm  
    
    ; Konvertovanje stringa u broj               
    strtoint proc
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
    strtoint endp     
    
    ; Redefinisan makro ucitavanja stringa sa tastature
    ; tako da i on koristi direktan pristup ekranskoj memoriji 
    ; za prikazivanje ucitanih znakova
    
    readString macro str 
         LOCAL unos, nastavi, kraj
         push ax
         push bx
         push cx
         push dx
         push si 
    
         mov si, 0            ; koristi se kao brojac
         mov bx, adresa       ; adresa tekuceg znaka na ekranu
         mov cx, pozX         ; u cx i dx pamtimo poziciju tekuceg znaka
         mov dx, pozY
    
        unos:
             readKey znak         ; ucitavamo jedan znak
             cmp znak, 13         ; 13 = ENTER --> kraj
             je kraj
             cmp znak, 8          ; 8 = BACKSPACE
             jne nastavi
             cmp si, 0            
             je unos              ; ako je broj unetih znakova 0 samo nastavi dalje
             sub cx, 1            ; ako broj unetih znakova != 0 pomeramo se za 1 znak <
             setXY cx dx          ; postavljamo novu poziciju
             write ' '            ; upisujemo 'prazan znak'
             dec si               ; smanjimo brojac
             jmp unos
        nastavi:
             mov al, znak         
             mov str[si], al      ; smestanje znaka u string
             write al             ; ispis na ekran
             add cx, 1            ; pozX += 1
             setXY cx, dx  
             inc si               ; povecavamo brojac stringa
             jmp unos             ; ucitaj sledeci znak
             
        kraj:
             mov str[si], '$'     ; stavljamo $, sredjujemo stek
             pop si
             pop dx
             pop cx
             pop bx
             pop ax
    endm
      
    start:
         ; Postavljanje segmentnih registara
         assume cs:code, ss:stek
         mov ax, data
         mov ds, ax 
         
         ; inicijalizacija promenljivih potrebnih za rad sa grafikom
         initGraph   
         
         ; Ucitavanje koordinate X1
         writeString porukaX1
         readString strBroj
         push offset strBroj
         push offset pozX1
         call strtoint
         call writeLn  
         
         ; Ucitavanje koordinate Y1            
         writeString porukaY1
         readString strBroj
         push offset strBroj
         push offset pozY1
         call strtoint
         call writeLn 
         
         ; Ucitavanje koordinate X2
         writeString porukaX2
         readString strBroj
         push offset strBroj
         push offset pozX2
         call strtoint
         call writeLn  
         
         ; Ucitavanje koordinate Y2
         writeString porukaY2
         readString strBroj
         push offset strBroj
         push offset pozY2
         call strtoint
         call writeLn  
         
         ; Ucitavanje boje
         writeString porukaBoja
         readString strBroj              ; posto je boja predstavljena kao byte, 
         push offset strBroj             ; a strtoint vraca word 
         push offset bojaPravougaonika   ; boja se prvo mora smestiti u tip word
         call strtoint                   
         mov ax, bojaPravougaonika       ; zatim se smesta u registar ax
        
         clrScreen
         setColor al            ; nakon toga se vrednost al postavlja za tekucu boju       
         nacrtajPravougaonik pozX1 pozY1 pozX2 pozY2
         
         setXY 0 24  
         setColor 7                      ; vraca se vrednost boje na standardnu
         writeString poruka 
         keyPress
         krajPrograma   
       
code ends
end start
     
     
    
    