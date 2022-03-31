; Napisati program koji leksikografski poredi dva stringa. Cim se naidje na razlicite
; karaktere, onaj koji je veci donosi odluku da je i string kojem pripada "veci".
; Stringovi moraju biti iste duzine.          

data segment
  poruka1 db 'Unesite prvi string: $'
  poruka2 db 'Unesite drugi string: $'
  porukaDuzina db 'Duzina unetog stringa je: $'
  strDuzina1 db "        "
  brojDuzina1 dw 0                             
  strDuzina2 db "        "
  brojDuzina2 dw 0
  string1 db '                      '
  string2 db '                      '
  porukaisti db 'Stringovi su isti$'
  porukamanji db 'Prvi string je manji$'
  porukaveci db 'Prvi string je veci$'   
  porukanejednaki db 'Stringovi su razlicite duzine$'
  poruka3 db 'Pritisnite neki taster...$'
data ends
; Deficicija stek segmenta
stek segment stack
    dw 128 dup(0)
stek ends
; Ucitavanje znaka sa tastature bez memorisanja     
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
; String length macro
getLength macro source, destination
    push ax
    push dx 
    push cx              
    LOCAL duzina
    mov dx, offset source 
    mov si, dx
    mov cx, 0
    duzina:            
        mov al, [si] 
        add cx, 1  
        inc si 
        cmp al, '$' 
        jne duzina
    dec cx
    mov destination, cx  
    pop cx
    pop dx
    pop ax   
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
        ; Postavljanje segmentnih registara
        ASSUME cs: code, ss: stek
        mov ax, data
        mov ds, ax
        
        ; Ucitavanje prvog stringa
        call noviRed
        writeString poruka1                
        ;Moramo na stek staviti i maksimalan broj karaktera koji dozvoljavamo
        push 20
        push offset string1
        call readString
        
        ; Dobavljanje i ispis duzina stringa
        getLength string1, brojDuzina1
        call noviRed
        writeString porukaDuzina
        call noviRed
        ; Konvertovanje stringa u broj
        push brojDuzina1
        push offset strDuzina1
        call intToStr
        writeString strDuzina1
        
        ; Ucitavanje drugog stringa
        call noviRed
        writeString poruka2                
        push 20
        push offset string2
        call readString  
 
        ; Dobavljanje i ispis duzina stringa
        getLength string2, brojDuzina2
        call noviRed
        writeString porukaDuzina
        call noviRed
        ; Konvertovanje stringa u broj
        push brojDuzina2
        push offset strDuzina2
        call intToStr
        writeString strDuzina2
        
        call noviRed
        mov ax, brojDuzina1
        cmp ax, brojDuzina2
        jne nejednaki
        ; Anuliranje registra SI
        xor si, si
        ; Poredjenje stringova
        petlja:      
            ; a b
            ; a c
            ; U registre AL i AH se postavljaju karakteri iz stringova koje treba uporediti
            mov al, string1[si]
            mov ah, string2[si]
            cmp al, ah
            ; Ukoliko je karakter uzet iz stringa1 manji,
            ; tada je i string1 manji, ispisuje se odgovarajuca poruka i zavrsava se program.
            jl manji ; jump if lower
            jg veci  ; jump if greater
            ; Ukoliko nije nista od ovoga, tada su karakteri jednaki i postoje dve mogucnosti. 
            ; Ukoliko su oba jednaka znaku '$', tada su stringovi isti, ispisuje se odgovarajuca poruka i program zavrsava sa radom, 
            ; a ukoliko nisu, prelazi se na sledece karaktere i algoritam se ponavlja za sledece karaktere.
            cmp al, '$'
            ; karakter '$' ima redni broj 36 u ASCII tabeli
            je isti
            ; ako os nismo dosli do kraja, povecavamo SI i idemo na sledeca dva karaktera
            inc si
            jmp petlja
            ; Ispis rezultata
        
        manji:
            writeString porukamanji
            jmp Kraj
              
        veci:
            writeString porukaveci     
            jmp kraj
            
        isti:
            writeString porukaisti
            jmp kraj
              
        nejednaki:
            writeString porukanejednaki
 
        kraj:
            call noviRed
            writeString poruka3
            keyPress
            krajPrograma
    end start
ends
