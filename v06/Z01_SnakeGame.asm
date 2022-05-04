data segment
     pozX db ?
     pozY db ?
     sirina dw ?
     visina dw ? 
     adresa dw ?
     boja db ?     
     znak db 178         ; popunjen pravougaonik
     glavaX db 4         ; pocetna pozicija "zmije"
     glavaY db 4
     smer db ?
     poruka db 'Pritisnite neki taster...$'
data ends
; Deficijija stek segmenta
stek segment stack
     dw 128 dup(?)
stek ends

code segment
    ; Postavljanje pocetnih vrednosti promenljivih          
    macro initGraph
         push ax
         mov ax, 0B800h
         mov es, ax
         mov pozX, 0
         mov pozY, 0
         mov sirina, 80
         mov visina, 25
         mov adresa, 0
         mov boja, 7
         pop ax
    endm
    ; Postavljanje tekuce pozicije na poziciju (x, y)               
    macro setXY x y
         push ax
         push dx
         mov pozX, x
         mov pozY, y
         
         mov dx, sirina
         shl dx, 1
         mov ax, dx
         mov ah, pozY
         mul ah
         mov dl, pozX  
         shl dl, 1
         add ax, dx
       
         mov adresa, ax
         pop dx
         pop ax
    endm
    ; Postavljanje tekuce boje
    macro setColor b
         mov boja, b
    endm
    ; Ispis stringa na ekran           
    writeString macro str
        LOCAL petlja, kraj
        push ax
        push bx  
        push si
        mov si, 0
        mov ah, boja
        mov bx, adresa
        petlja:
            mov al, str[si]
            cmp al, '$'
            je kraj
            mov es:[bx], al   
            mov es:[bx+1], ah
            add bx, 2
            add si, 1
            jmp petlja  
            
        kraj:           
            mov ax, si
            add al, pozX
            mov ah, pozY
            setXY al ah
            pop si
            pop bx
            pop ax
    endm
    ; Ucitavanje znaka bez prikaza i memorisanja
    keyPress macro
        push ax
        mov ah, 08
        int 21h
        pop ax
    endm  
    ; Ucitavanje znaka bez prikaza
    readkey macro c
        push ax
        mov ah, 08
        int 21h
        mov c, al
        pop ax 
    endm
    ; Ispis znaka na tekucu poziciju
    macro Write c
         push bx        
         push dx
         mov bx, adresa
         mov es:[bx], c
         mov dl, boja
         mov es:[bx+1], dl
         pop dx
         pop bx
    endm
    ; Kraj programa
    krajPrograma macro
        mov ax, 4c02h
        int 21h
    endm        
    ; Brisanje ekrana     
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
    
    
    ; Crtanje okvira
    nacrtajOkvir proc
        push ax
        push bx
        push cx
        push si
        mov bx, 0         ; adresa tekuceg znaka
        mov si, 3840      ; brojac koji se pozicionira na pocetak poslednjeg reda (25*80*2 - 160)
        mov cx, 80        ; 80 je sirina ekrata
        mov al, znak      
        mov ah, boja
        petljaHor:                ; petlja koja crta horizontalne linije, prvi i poslednji red u isto vreme
           mov es:[bx], al
           mov es:[bx+1], ah
           mov es:[bx+si], al
           mov es:[bx+si+1], ah
           add bx, 2             ; znak po znak, za dva mesta
        loop petljaHor
        mov cx, 23               ; 24-ti red je vec iscrtan petljom petljaHor, pa idemo do 23-eg reda
        mov bx, 160              
        mov si, 158              
        petljaVer:               ; petlja koja crta vertikalne linije, prvu i poslednju u isto vreme
           mov es:[bx], al
           mov es:[bx+1], ah
           mov es:[bx+si], al
           mov es:[bx+si+1], ah
           add bx, 160            ; skacemo u sledeci red
        loop petljaVer
        pop si
        pop cx
        pop bx
        pop ax
        ret
    nacrtajOkvir endp  
      
    start:
         ; postavljanje segmentnih registara
         assume cs:code, ss:stek
         mov ax, data
         mov ds, ax
         ; inicijalizacija grafike
         initGraph
         ; Postavljanje okvira koji se iscrtava
         setColor 5
         call nacrtajOkvir
         
         setColor 1        ; "zmija" ce biti druge boje
         mov al, glavaX    ; 
         mov ah, glavaY
         setXY al ah       ; postavi se na tekucu poziciju
         mov al, znak
         write al          ; ispisi prvi znak, odakle i krece "zmija"
         petlja:
           readKey smer
           cmp smer, 's'
           je dole
           cmp smer, 'a'
           je levo
           cmp smer, 'd'
           je desno
           cmp smer, 'w'
           je gore
           jmp kraj     
              
           dole:             ; pomeramo se dole, ispisujemo znak
               add glavaY, 1     ; Y se povecava za jedan
               jmp dalje             
           
           levo:             ; posto idemo levo, smanjujemo X za 1
               sub glavaX, 1
               jmp dalje
           
           desno:            ; x+=1
               add glavaX, 1
               jmp dalje
           
           gore:             ; y-=1
               sub glavaY, 1
               jmp dalje
              
           
           dalje:                ; ovo je provera da li je igrica gotova
               mov al, glavaX    ; postavi tekucu poziciju X i Y
               mov ah, glavaY
               setXY al ah
               mov bx, adresa    ; postavi tekucu adresu tog znaka
               mov al, es:[bx]   ; znak uvek postavljamo u al registar
               cmp al, znak      ; ako je vec iscrtano to polje, onda je igrica gotova...
               je kraj
               mov al, znak      ; inace pomeri znak u al i ispisi ga
               write al
    
         loop petlja       
    
         kraj:
         ; Kraj programa
         setXY 1 23
         setColor 14
         writeString poruka
         keyPress
         krajPrograma
code ends
end start
     
     