; Napisati program koji vrši predstavljanje broja -2 u racunaru i vrši njegovo sabiranje sa brojem 2.


code_seg SEGMENT 
    
    ; Postavljanje vrednosti u segmentne registre     
    ASSUME cs:code_seg
    
    ; Ovde stavljamo pozitivan i negativan broj  
    mov ax, 2
    mov bx, -2    
    
    ; Sabiramo ta dva broja
    add ax, bx      
    
    ; Ovde je isti broj kao malopre, ali zapisan drugacije
    mov cx, 2
    mov dx, 0FFFEh 
     
    ; Sabiramo ta dva broja
    add cx, dx   
    
    kraj: jmp kraj
     
    code_seg ENDS             

END
 
; Objašnjenje: registri opšte namene mogu da sadrže samo 16-bitne brojeve koji pripadaju intervalu [0..65535]. 
; Da bi koristili broj -2, umesto broja -2 koristi se njegov drugi (potpuni) komplement. Drugi komplement 
; 16-bitnog broja X je broj koji u zbiru sa brojem X daje broj 216, tj. to je vrednost 216-X. 
; Kako broj 216 nije moguce koristiti, koristi se formula da je drugi komplement broja X jednak 216-1-X+1, tj. 65535-X+1. 
; Vrednost 65535-X naziva se prvi (potpuni) komplement broja X i dobija se tako što se sve vrednosti 1 u binarnoj reprezentaciji
; broja X zamene sa 0, a sve vrednosti 0 zamene sa 1. Nakon racunanja prvog komplementa, ovoj vrednosti dodje se
; broj 1 i tako dobija negativna vrednost broja X.         

; Broj 0FFFEh predstavlja drugi komplement broja -2 zapisan u osnovi 16, tj. broj 65534. U osnovi 16, svaki broj pocinje 
; sa cifrom, pa zato pišemo 0 na pocetku i završava se sa oznakom h. Cifre F i E predstavljaju brojeve 15 i 14.


                 