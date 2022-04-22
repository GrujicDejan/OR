; Ucitati string od korisnika i sacuvati ga u promenljivoj str1.
; String str1 obrnuti i sacuvati ga kao str2.
; U string str2 prevaciti sva mala slova u velika i sacuvati kao str3.
; Ispisati str2 i str3 na ekran, smisleno sa porukama za korisnika. 

data segment
    str1 db '         '
    str2 db '         '
    str3 db '         '
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
        ; postavljanje segmentnih registara
        ASSUME cs: code, ss:stek
        mov ax, data
        mov ds, ax
        
        push 6
        push offset str1
        call readString
        call noviRed
        
        mov si, 0
        mov ax, 0
        brojSlova:
            mov al, str1[si]
            inc si
            cmp al, '$'
            je dalje
            jmp brojSlova
        dalje:
            dec si
            dec si
            mov di, 0
        obrni:
            mov ax, 0
            cmp si, -1
            je povecaj
            mov al, str1[si]
            mov str2[di], al
            sub al, 20h
            mov str3[di], al
            inc di
            dec si
            jmp obrni
        povecaj:
            mov str2[di], '$' 
            mov str3[di], '$'
            call noviRed
            writeString str2
            call noviRed
            writeString str3
        
        krajPrograma
ends
end start