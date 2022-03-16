; Napisati program koji demonstrira tri nacina adresiranja. U prvom nacinu prikazati pristup segmentu podataka 
; preko labele sabiranjem brojeva broj1 i broj2. U drugom nacinu demonstrirati bazno relativno adresiranje i 
; pristupiti lokaciji broj 2 broja broj2. U trecem nacinu, demonstrirati direktno indeksno adresiranje sabiranjem 
; elemenata niza niz.                     

data_seg SEGMENT
    broj1 dw 17
    broj2 dw 3
    niz db 1,2,3,4,5,6,7,0 ; definicija niza brojeva tipa bajt
data_seg ENDS 

code_seg SEGMENT
    ; Postavljanje vrednosti u segmentne registre
    ASSUME cs:code_seg, ds:data_seg;     
    
    ; Podesavamo DATA segment
    start: 
        mov dx, offset data_seg
        mov ds, dx         
        
        ; Koriscenje labele za pristup memoriji, sabiramo broj1 i broj2
        mov ax, broj1
        add ax, broj2
        mov broj1, ax   
        
        ; Bazno relativno - zapravo cemo upisati u broj2 jer je BX=2
        mov bx, 2
        mov broj1[BX], 255    
        
        ; Direktno indeksno - pomocu labela[SI]
        ; suma clanova niza dok se ne dodje do 0, rezultat u dx
        mov si, 0 ; pocetni index niza
        mov ax, 0 ; resetujemo ah (tj. ceo ax)
        mov dx, 0 ; pocetni zbir postavljamo na 0    
        
    petlja:
        mov al, niz[si] ; citaj clan niza – jedan bajt (zato je AL)
        cmp ax, 0       ; da li je al=0? (to nam je oznaka kraja niza)
        je kraj         ; ako jeste, idi na kraj
        add dx, ax      ; dodajemo broj na zbir u dx-u
        inc si          ; povecavamo index si
        jmp petlja       
     
    kraj: 
        jmp kraj
                
    end start ; pocinje se od labele start
code_seg ENDS

; Objašnjenje: Procesor i8086 nije dozvoljavao naredbe u kojima postoje dva pristupa memoriji preko labela, kao ni 
; još neke kombinacije registara i labela. Zbog toga, da bi sabrali promenljive broj1 i broj2 prvo se vrednost jedne 
; promenljive stavi u registar, u ovom slucaju AX, zatim na vrednost tog registra dodamo vrednost promenljive broj2
; i nakon toga zbir kopiramo u broj1.
; Kako je svaka od promenljivih broj1 i broj2 velika 2 bajta (tip dw), pristup memoriji 2 bajta udaljenoj od pocetka 
; broja broj1 je ustvari pristup promenljivoj broj2. Na ovaj nacin, umesto da pristupimo promenljivoj broj1 i tamo 
; stavimo vrednost 255, ova vrednost je postavljena u promenljivu broj2.
; Prilikom korišcenja direktnog indeksnog adresiranja, memoriji se pristupa sa labela[si] ili labela[di]. Prilikom 
; sabiranja elemenata niza niz, koristicemo registar SI da pristupimo elementima niza, a zbir cemo stavljati u registar 
; DX. Kako ce registar AX sadržati elemente niza koji su veliki jedan bajt (tip db), a AX je velik dva bajta, registar AL (ili 
; ceo AX) se prethodno mora postaviti na 0. Prilikom obrade niza, uzimaju se elementi niza pocevši od nultog elementa 
; (SI=0), stavljaju u AL (tj. u AX) i dodaju na sumu DX, koja je prethodno postavljena na vrednost 0. Ukoliko se naide 
; na granicnik (element 0) tada se prekida sabiranje i prelazi se na beskonacnu petlju na kraju programa. Ukoliko 
; element nije nula, nastavlja se sabiranje na labeli petlja.