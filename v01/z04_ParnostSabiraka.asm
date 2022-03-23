; Napisati asembler program koji proverava da li je rezultat zbira dva brojs paran ili ne. 
; Parnost sacuvati kao informaciju u registru SI (ako je broj paran postaviti ga na 1, u suprotnom na 0). 

data_seg SEGMENT
    broj1 dw 1
    broj2 dw 5   
    rezultat dw ?
data_seg ENDS

code_seg SEGMENT      
    ; Postavljanje vrednosti u segmentne registre
    ASSUME cs:code_seg, ds:data_seg; 
             
    ; Podesavamo DATA segment
    start:
        mov dx, data_seg
        mov ds, dx
     
        ; Sabiramo broj1 i broj2
        mov ax, broj1
        add ax, broj2 
        mov rezultat, ax   

        ; Deljenje rezultata sa brojem 2
        mov bl, 2
        div bl
        
        cmp ah, 0 ; Proveravamo da li je ostatak pri deljenju jednak nuli
        je je_paran ; Ako jeste skoci na labelu je_paran 
        jmp kraj
        
    je_paran:
        mov si, 1 ; Postavi registar SI na vrednost 1.
        jmp kraj    
        
    kraj: 
        jmp kraj        
    
    end start ; 
    
code_seg ENDS     
END
