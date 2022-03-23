# Makroi, procedure i prekidi

### Z01

- Na početku programa, prvo se unose brojevi M i N. Ova dva broja se prvo učitavaju u stringove strM i strN, a zatim se 
procedurom strtoint prebacuju u brojeve. Nakon toga, računanje tablice množenja i njen ispis vrši se unutar dvostruke 
loop petlje.
- Kako loop petlja uvek koristi isključivo CX registar, javlja se problem dvostrukog korišćenja registra CX, kao brojača u 
spoljnoj petlji (petlja3) i kao brojača u unutrašnjoj petlji (petlja4). Da bi se izbegao konflikt, pre pokretanja unutrašnje 
petlje, brojač CX ćemo staviti na stek, a nakon završetka ove petlje uzeti sa steka njegovu staru vrednost. Inicijalna 
vrednost za brojač CX u spoljnoj je N jer imamo N vrsta, a u unutrašnjoj petlji M jer imamo M kolona. Kako brojač CX 
broji od M ka 1, tj. od N ka 1, a za računanje matrice su potrebne obrnute vrednosti brojača, uvešćemo dodatne brojače 
za ove petlje, i to SI za spoljašnju i DI za unutrašnju petlju. Početne vrednosti za ove brojače su 0.
- Nakon inicijalizacije SI i CX za spoljnu petlju, prelazi se na čuvanje registra CX i inicijalizaciju vrednosti DI i CX za drugu 
petlju. Unutar druge petlje, vrednost brojača SI se stavlja u registar AX, a nakon toga ta vrednost se pomnoži sa registrom 
DI. Posle množenja, u registru se nalazi proizvod dva brojača koji treba ispisati na ekran. Prilikom ispisa, proizvod se 
stavlja u promenljivu Broj, konvertuje u string strBroj i ispisuje na ekran, nakon čega se ispisuje i jedan razmak. Na kraju 
unutrašnje petlje potrebno je povećati vrednost brojača DI, dok se vrednost brojača CX automatski koriguje.
Nakon završetka unutrašnje petlje, vraća se vrednost brojača CX i spoljna petlja nastavlja sa radom. Slično kao i kod 
prethodne petlje, brojač SI mora da se poveća za 1. Nakon toga, štampa se jedan prazan red da bi se na ekranu dobio 
izgled matrice, i prelazi se na sledeću iteraciju spoljne petlje
