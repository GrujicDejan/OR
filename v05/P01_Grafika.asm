;podaci za rad sa grafickom memorijom
data segment
     pozX dw ?
     pozY dw ?          ; pozX i pozY koristicemo za pamcenje (X, Y) pozicije trenutnog znaka, 
     adresa dw ?        ; adresa ce sadrzati ofsetnu adresu tog znaka u ekranskoj memoriji.
     sirina dw ?        ; maksimalna sirina i visina
     visina dw ? 
     boja db ?          ; polje boja sadrzace vrednost tekuce boje sa kojom se radi 
     znak db ?          ; polje znak koristicemo kao pomocnu promenljivu u makrou readString.
data ends

; ovaj makro se koristi za inicijalizaciju ES registra
macro initGraph
     push ax
     mov ax, 0B800h     ; segmentna adresa graficke memorije postavlja se u ES
     mov es, ax
     mov sirina, 80     ; maksimalna sirina je 80
     mov visina, 25     ; maksimalna visina je 25
     mov pozX, 0        
     mov pozY, 0        
     mov adresa, 0      ; ofsetna adresa prve pozicije je 0
     mov boja, 7        ; 7 je siva boja na crnoj podlozi  ->  0 000 0111b
     pop ax
endm  

; Pomera nas na polje definisano parametrima makroa              
macro setXY x y ;  4, 4 -> adresa = 648
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
     mov bx, pozX   
     shl bx, 1      ; opet pomeranje u levo - mnozenje 
     add ax, bx     ; i na kraju sabiranje
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
; setBoja 17
; setXY 4, 4 -> adresa = 648
macro Write c 
     push bx        
     push dx
     
	 mov bx, adresa
     mov es:[bx], c	   ; 0b800h+648 -> 'X'
     mov dl, boja      ; stavljamo boju prvo u pomocni registar dl
     mov es:[bx+1], dl ; 0b800h+649 -> boja se smesta na adresu odmah posle znaka
     
	 pop dx
     pop bx
endm  

; Ispis stringa na ekra
writeString macro str
    LOCAL petlja, kraj    ; definicija dve lokalne petlje - ovo je dobra praksa!
    push ax
    push bx  
    push si               ; index karaktera u stringu
    mov si, 0             ; nulti znak stringa je pocetni
    mov ah, boja          ; trenutno postavljena boja
    mov bx, adresa        ; smestamo trenutnu ofsetnu adresu u bx - ispis se nastavlja tamo gde je adresa!
    petlja:
        mov al, str[si]       ; iz stringa se uzimaju znakovi redom i smestaju se u al
        cmp al, '$'           ; ako se naidje na $ prelazi se na kraj ispisa
        je kraj
        mov es:[bx], al       ; iz registra al se zajedno sa bojom stavljaju na ekran
        mov es:[bx+1], ah
        add bx, 2             ; pomeramo se za 2 mesta u memoriji
        add si, 1             ; indeks SI se povecava za 1 - sledeci znak
        jmp petlja  
        
    kraj:            
        mov ax, pozX          ; pozicija X se pomera za duzinu stringa
        add ax, si
        mov bx, pozY          ; pozicija Y se upisuje u BX
        setXY ax bx
        pop si
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
     mov ax, 0       ; pozX ce biti 0 - pocetak narednog reda ce biti (0,Y)
     setXY ax, bx    ; postavljanje pozicije - setovanje promenljivih
     pop bx
     pop ax
     ret
writeLn endp       

; Ucitavanje jednog znaka - koristili smo ga kod stringova
readkey macro c
    push ax
    mov ah, 08
    int 21h
    mov c, al
    pop ax
endm  

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
         cmp znak, 8          ; 8 = BACKSPACE  - ako nije unet BS idemo na labelu nastavi
         jne nastavi
         cmp si, 0            ; a ako je unet nastavljamo ovde
         je unos              ; ako je broj unetih znakova 0 samo nastavi dalje
         sub cx, 1            ; ako broj unetih znakova != 0 pomeramo se za 1 znak <
         setXY cx dx          ; postavljamo novu poziciju
         write ' '            ; upisujemo space na tekucu poziciju
         dec si               ; smanjimo brojac
         jmp unos
    nastavi:
         mov al, znak         ; u AL stavljam uneti znak
         mov str[si], al      ; smestanje znaka u string
         write al             ; ispis na ekran
         add cx, 1            ; pozX += 1
         setXY cx, dx         ; postavljamo novu poziciju za jedno mesto unapred
         inc si               ; povecavamo index stringa
         jmp unos             ; ucitaj sledeci znak
     
    kraj:
         mov str[si], '$'     ; stavljamo $, sredjujemo stek
         pop si
         pop dx
         pop cx
         pop bx
         pop ax
endm