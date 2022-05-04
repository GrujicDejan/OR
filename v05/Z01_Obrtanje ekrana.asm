; Napisati prorgam koji obrce sadrzaj ekrana.

data segment
    pozX db ?
    pozY db ?    
    sirina dw ?
    visina dw ?
    adresa dw ?
    boja db ?
    poruka1 db "A mene tu ni minute nema$"
    poruka2 db "Ovaj program treba da obrne sadrzaj ekrana kao u ogledalu$"
    poruka db "Pritisnite neki taster...$"
data ends

; Definicija stek segmenta
stek segment
    dw 128 dup(?)
stek ends

; Postavljanje pocetnih vrednosti promenljivih  
macro initGraph
    push ax
    mov ax, 0B800h  
    mov es, ax
    mov pozX, 0     
    mov pozY, 0     
    mov adresa, 0
    mov sirina, 80
    mov visina, 25  
    mov boja, 7    
    pop ax
endm 

; Pomera nas na polje definisano parametrima makroa
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
              
; Ucitavanje znaka bez prikaza i memorisanja
keyPress macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm         

; Kraj programa
krajPrograma macro
    mov ax, 4c02h
    int 21h
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

code segment             
    
    ; Procedura za obrtanje ekrana

    ; Ova procedura prolazi kroz svih 25 vrsta na ekranu (brojac CX se postavi na 25) 
    ; i obrce sadrzaj svake od njih. Obrtanje sadrzaja jedne vrste vrsi se unutar loop 
    ; petlje  sa labelom petlja2, dok se obrtanje svih vrsta vrsi 
    ; unutar loop naredbe sa labelom petlja1.         
    obrtanje proc
        push ax
        push bx
        push cx
        push si
        push di   
        
        mov bx, 0  ; bazna adresa pocetka trenutnog reda (1. red = 0-ti)
        mov cx, 25 ; brojac koji ide po redovima
        petlja1:   ; Da bi se obrnula jedna vrsta potrebno je izvrsiti 40 zamena. 0-ti znak sa 79-im, itd.
            push cx
            mov cx, 40  ; brojac koji ide po kolonama
            mov si, 0   ; na pocetku si pokazuje na 0-ti znak
            mov di, 158 ; a di na 79 znak, tj 2x79 = 158
           
            petlja2:
                ; zamena dva znaka
                mov al, es:[bx+si]   ; uzimaju se znakovi sa 0 i 79 mesta i smestaju
                mov ah, es:[bx+di]   ; se u registre al i ah
                mov es:[bx+si], ah   ; zatim se u obrnutom redosledu vracaju na ekran
                mov es:[bx+di], al  
                
                ; zamena njihovih boja
                mov al, es:[bx+si+1]    ; boja je ispred znaka, znaci si+1 i di+1
                mov ah, es:[bx+di+1]
                mov es:[bx+si+1], ah    ; isti princip zamene mesta
                mov es:[bx+di+1], al       
                
                add si, 2     ; skacemo u brojacima za 2
                sub di, 2
                loop petlja2 
                add bx, 160   ; povecava se bx za 160 kako bi sadrzao adresu prvog znaka u sledecem redu (0 + 2 x 80)
                pop cx
                loop petlja1  ; idemo u sledeci red
        
        pop di
        pop si
        pop cx
        pop bx
        pop ax
    obrtanje endp
    
    start:
        ; postavljanje segmentnih registara
        assume cs:code, ss:stek
        mov ax, data
        mov ds, ax
        
        ; inicijalizacija grafike
        initGraph
        
        ; postavljanje poruka na ekran
        setColor 15
        setXY 0 0
        writeString poruka1
        setXY 0 10
        writeString poruka2
        setXY 0 20
        writeString poruka
        keyPress
                     
        ; obrtanje ekrana
        call obrtanje   
        
        ; kraj programa
        setXY 0 24
        writeString poruka
        keyPress
        krajPrograma
code ends
end start
