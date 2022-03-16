; Napisati program koji vrši sabiranje brojeva u dvostrukoj preciznosti. Program kao ulaze koristi 32-bitne brojeve 
; AXBX i CXDX, a izlaz se nalazi u broju AXBX. Ukoliko dode do prekoracenja, vrednost registra SI postaviti na 1, a 
; u suprotnom na 0.

data_seg SEGMENT ; Definicija praznog segmenta podataka
data_seg ENDS              

stack_seg SEGMENT ; Definicija praznog stek segmenta
stack_seg ENDS                                       

code_seg SEGMENT 
    
    ; Postavljanje vrednosti u segmentne registre ASSUME                        
    ASSUME cs:code_seq, ss:stack_seg, ds:data_seg      
    
    ; Vrednosti koje se sabiraj
    mov ax, 123
    mov bx, 456
    
    mov cx, 654
    mov dx, 321        
    
    ; Brisemo SI
    XOR si, si
    
    ; Sabiranje   
    add bx, dx ; bx := bx + dx
    add ax, cx ; ax := ax + cx    
    
    jo prekoracenje ; Ako je doslo do prekoracenja, skoci na labelu prekoracenje
    
    jmp kraj ; Ako nije idi na labelu kraj
    
    prekoracenje: mov si, 1 ; Postavimo SI na 1     
    
    kraj: jmp kraj ; Beskonacna petlja
          
code_seg ENDS ; Zavrsetak kodnog segmenta
END          

; Objasnjenje: registri opšte namene mogu da sadrže samo 16-bitne brojeve koji pripadaju intervalu [0..65535]. 
; Da bi radili sa vecim brojevima koristimo dva 16-bitna broja i njihovim spajanjem dobijamo 32-bitni broj koji pripada 
; intervalu [0..~4*109]. 
; Kada želimo da saberemo dva 32-bitna broja, prvo moramo da saberemo njihove donje 
; polovine (BX i DX), a zatim i njihove gornje polovine (AX i CX). Prilikom sabiranja donjih polovina naredbom ADD, 
; može doci do prenosa (Carry flag) koji se dodaje prilikom sabiranja gornjih polovina broja naredbom ADC. Ukoliko 
; prilikom sabiranja dodje do prekoracenja (Overflow flag), tada naredbom JO (jump if overflow) skacemo na labelu 
; prekoracenje i tamo postavljamo SI na 1. U suprotnom, registar SI zadržava vrdnost 0 i naredbom JMP (jump) 
; skacemo na labelu kraj gde se vrtimo u beskonacnoj petlji