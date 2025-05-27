name "Snake"
data segment
    
    Welcome dw "Welcome to Assembly Snake$"
    ForStart dw "Press any key for start ---> $"
    
    Death dw "Game Over$"
    Points dw "Points : $"
    ForClose dw "Press any key for close ---> $"
    
    Punteggio db 0,0,0
    
    Lato db 16 ;serve ad indicare l'ultima coordinate sia in x che in y in cui andare
    
    Char db ? ;carattere per il serpente
    
    Lunghezza db 3  ;lunghezza del serpente
    
    SnakeX db 225 dup (?)  ;225 e' la lunghezza massima del serpente, lo spazio di gioco e' 15x15 
    SnakeY db 225 dup (?)  ;225 e' la lunghezza massima del serpente, lo spazio di gioco e' 15x15
    Mossa db 'd'  ;mossa che decidera' il player
    PreMossa db 'a' ;se il serpente va su, allora il tasto giu' non puo' essere usato, lo scopo della variabile e' quelllo di ricordarsi la mossa precende
    
    Mela db ?,?  ;la posizione 0 e' per la X,la 1 per la Y
    
ends

;ha lo scopo di stampare la testa del serpente e di far sparire l'ultima parte della coda
Stampa macro CooX,CooY,Char
    
    mov ah,02h
    mov dh,CooY
    mov dl,CooX
    int 10h
    mov dl,Char
    int 21h
        
endm

;con l'avanzamento del serpente e' necessario che che ogni frammento del serpente copi le coordinate di quello successivo
Copia macro param,param2
    mov cl,param
    mov param2,cl
endm

;genera numeri random basandosi sul timer di sistema
Random macro param
    
    ;assegna al registro dx, e cx(la parte piu' alta) il tempo del timer di sistema
    mov ah,00h
    int 1Ah
    
    mov ax,dx
    mov dx,0
    mov cx,16  ;divide il tempo in dx per 16 cosi' che il resto massimo (ovvero il numero da trattare come random) sia massimo 15 visto che l'area per muoversi va da cella 1 a cella 15 compresi
    div cx
    
    mov param,dl
    
endm

code segment
    start:
        
        ;assegnazione del data segment
        mov ax,data
        mov ds,ax
        mov es,ax
        
        mov ax,0
        
        call SchermataStart
        
        ;disegnare la mappa
        call Mappa
        
        ;assegna le posizioni iniziali del serpente
        
        ;Testa
        mov SnakeX[0],8
        mov SnakeY[0],8
        
        mov SnakeX[1],7
        mov SnakeY[1],8
        
        mov SnakeX[2],6
        mov SnakeY[2],8
        
        ;serve per dire che cella cancellare
        mov SnakeX[3],5
        mov SnakeY[3],8
        
        call ChiamaRandom
        
        call InputMossa
        
        ;fine programma
        mov ah,4Ch
        int 21h
        
ends

;schermata di avvio del gioco
SchermataStart proc near
    
    lea dx,Welcome
    mov ah,09h
    int 21h
    
    call a-capo
    
    lea dx,ForStart
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    ;pulisce lo schermo
    mov ax,0x0003
    int 10h
    
    ret
    
endp

;si occupa di convertire il punteggio da esadecimale a decimale
StringaPunteggio proc near
    
    mov Punteggio[2],dl
    
    ;se la terza cifra e' maggiore/uguale a 10 deve sottrarre 10 fino a quando non diventa minore
    cmp Punteggio[2],10
    jge ContinuaDecremento
    jmp concludi
    
    ContinuaDecremento:
    
        sub Punteggio[2],10
        inc Punteggio[1]  ;se sottre allora la cifa alla sua sinistra deve incrementare        
    
    cmp Punteggio[2],10
    jge ContinuaDecremento
    
    ;se la seconda cifra e' maggiore/uguale a 10 deve sottrarre 10 fino a quando non diventa minore
    cmp Punteggio[1],10
    jge ContinuaDecremento1
    jmp concludi
    
    ContinuaDecremento1:
    
        sub Punteggio[1],10
        inc Punteggio[0]  ;se sottre allora la cifa alla sua sinistra deve incrementare        
    
    
    cmp Punteggio[1],10
    jge ContinuaDecremento1
    
    concludi:
    
    ret
    
endp

SchermataDeath proc near
    
    ;ripulisce lo schermo dalla mappa dello snake
    mov ax,0x0003
    int 10h
    
    mov dx,0
    mov ah,02h
    int 10h
    
    lea dx,Death
    mov ah,09h
    int 21h
    
    call a-capo
    
    lea dx,Points
    mov ah,09h
    int 21h
    
    mov dl,Lunghezza
    sub dl,3
    
    ;aumenta i numeri di 30h cosi' che lo 0 (numero di venti '0' (carattere)
    call StringaPunteggio
    add Punteggio[0],30h
    add Punteggio[1],30h
    add Punteggio[2],30h
    
    ;stampa tutto il numero
    mov ah,02h
    mov dl,Punteggio[0]
    int 21h
    mov dl,Punteggio[1]
    int 21h
    mov dl,Punteggio[2]
    int 21h
    
    call a-capo
    
    lea dx,ForClose
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    mov ax,0x4C00
    int 21h
    
    ret
    
endp

a-capo proc near
    
    mov ah,02h
    mov dl,0AH
    int 21h
    mov dl,0Dh
    int 21h
    
    ret
    
endp

;disegna la mappa
Mappa proc near
    
    ;stampa la riga piu' in alto
    mov dx,0
    int 10h
    call Riga
    
    
    ;stampa la riga piu' in basso
    mov dh,Lato
    dec dh
    int 10h
    call Riga
    
    
    ;stampa la colonna piu' a sinistra
    mov dx,0
    mov [0x0100],0  ;visto che in dl vanno sia delle coordinate che i caratteri
                    ;si salva in una cella la colonna in cui si deve stamaper il carattere
    int 10h
    call Colonna
    
    
    ;stampa la colonna piu' a destra
    mov dx,0
    mov ch,Lato
    mov [0x0100],ch  ;visto che in dl vanno sia delle coordinate che i caratteri
                     ;si salva in una cella la colonna in cui si deve stamaper il carattere
    int 10h
    call Colonna
    
    ret
        
endp

;procedura per disegnare le righe
Riga proc near
    
    mov ah,02h
       
    mov cx,0
    mov cl,Lato
    mov si,cx
    SaltoRiga:
        dec si
        mov dl,219
        int 21h
    cmp si,0FFFFh
    jne SaltoRiga
    
    ret
    
endp

;procedura per disegnare le colonne
Colonna proc near
    
    mov ah,02h
       
    mov cx,0
    mov cl,Lato
    dec cl
    mov si,cx
    SaltoColonna:
        dec si
        inc dh
        mov dl,[0x0100]
        int 10h
        mov dl,219
        int 21h
    cmp si,0
    jne SaltoColonna 
    
    ret 
    
endp

InputMossa proc near
    
        call CreazioneSnake1

        mov ah,00h
        int 16h
        jmp SeInizio
    
    ;se la mossa non e' valida si deve ripetere
    ripeti:  ;il prgramma deve essere in loop
            
            call CreazioneSnake
            
            Error:
            
            ;prende in input un tasto e si ricorda e' nota se e' premuto o meno ma non di dimentica
            mov ah,01h
            int 16h      ;prende in input il tasto ma non lo toglie dal buffer
            jz noPremuto 
            
            mov bh,al
            
            ;serve per ripulire il buffer
            xor ah,ah
            int 16h
            
            mov al,bh       
            
            SeInizio:
            
            ;controllo se il tasto e' valido       
            cmp al,'w'
            je esegui
            cmp al,'a'
            je esegui
                cmp al,'s'
                je esegui
                    cmp al,'d'
                    je esegui   
                    
                    ;se non valida richiede l'input 
                    jmp Error
        
        esegui:
        
        cmp al,PreMossa
        je Error
 
        mov Mossa,al
        
        ;se il tasto non e' stato premuto ripete l'ultimo tasto valido premuto
        noPremuto:
        
        call Spostamento  ;si occupa di assegnare le nuove posizioni a tutti i pezzi dello snake tranne la testa  
        call Movimento  ;si occupa della gestione delle coordinate della testa in base al tasto valido premuto 
        
        ;se la testa coincide con il lato il programma termina
        mov bl,Lato
        cmp SnakeX[0],bl  
        je fine
            cmp SnakeX[0],0
            je fine
                cmp SnakeY[0],bl
                je fine
                    cmp SnakeY[0],0
                    je fine             
                    
                    mov si,1
         
        ;si occpua di vedere se la testa sta toccando il corpo           
        ControlloTocco:
                        
           call Tocco
           inc si
           mov cx,0
           mov cl,Lunghezza
                        
        cmp si,cx
        jne ControlloTocco
                    
                    
                    
        call ControlloMela    
                            
        jmp ripeti
          
        fine:   
        
        call SchermataDeath
        
    ret
    
endp

;gestisce lo spostamento della testa
Movimento proc near
    
    cmp Mossa,'w'
    jne Confronta1
        dec SnakeY[0]  ;per andare verso l'alto la Y deve decrementare
        mov PreMossa,'s'  ;se il serpente va verso l'alto non puo' andare in basso
    Confronta1:
    
    cmp Mossa,'s'
    jne Confronta2
        inc SnakeY[0]  ;per andare verso l'alto la Y deve incrementare
        mov PreMossa,'w'  ;se il serpente va verso il basso non puo' andare in alto
    Confronta2:
    
    cmp Mossa,'a'
    jne Confronta3
        dec SnakeX[0]  ;per andare verso sinistra la X deve decrementare
        mov PreMossa,'d'  ;se il serpente va verso sinistra non puo' andare destra
    Confronta3:
    
    cmp Mossa,'d'
    jne Confronta4
        inc SnakeX[0]  ;per andare verso destra la X deve incrementare
        mov PreMossa,'a'  ;se il serpente va verso destra non puo' andare a sinistra
    Confronta4:
    
    ret
        
endp

;si occupa dell'avanzamento del serpente, i pezzi devono copiare quello che li precede
Spostamento proc near
    
    mov cx,0
    mov cl,Lunghezza
    mov si,cx
    
    RiCopia:
    
        Copia SnakeX[si-1],SnakeX[si]
        Copia SnakeY[si-1],SnakeY[si]
        dec si
    
    cmp si,0
    jne RiCopia
    
    ret
    
endp

;Si occupa di stampare lo snake per la prima volta
CreazioneSnake1 proc near
    
    mov si,0FFFFh
    continua:
        inc si
        
        cmp si,0
            je CharO
            mov cx,0
            mov cl,Lunghezza
        cmp si,cx
            je CharSpazio
           
            mov Char,178
            jmp CallStampa
            
            CharSpazio:
                mov Char,' '
                jmp CallStampa    
            
            CharO:
                mov Char,'O'
               jmp CallStampa
            
            
                
                
        CallStampa:       
            Stampa SnakeX[si],SnakeY[si],Char
                
        mov cx,0
        mov cl,Lunghezza
        cmp si,cx
        jne continua
    
    ret
    
endp

;la testa ha un carattere diverso rispetto al corpo, inoltre ha lo scopo di cancellare l'ultima parte dello snake che verrebbe lasciata ad ogni spostamento
CreazioneSnake proc near
    
    Stampa SnakeX[0],SnakeY[0],'O'
    Stampa SnakeX[1],SnakeY[1],178
    mov cx,0
    mov cl,Lunghezza
    mov si,cx
    Stampa SnakeX[si],SnakeY[si],' '
    
    ret
    
endp

;deve controllare se il serpente si sta toccando, se lo fa il programma termina
Tocco proc near
    mov bl,SnakeX[si]
    cmp SnakeX[0],bl
    je ControlloY
        jmp NonTocco
        ControlloY:
            
            mov bl,SnakeY[si]
            cmp SnakeY[0],bl
                je Termine
                jmp NonTocco 
                
        Termine:
        call SchermataDeath        
                
        NonTocco:
        
        ret
            
endp

ControlloMela proc near
    
    ;controlla se la testa del serpente coincide con la mela
    mov bx,0
    mov bl,Mela[0]
                    
        ;se la X del serpente e' uguale alla X della mela deve controlla se lo stesso si ripete anche per la Y
        cmp SnakeX[0],bl
        je ConfrontaY
        jmp ripeti
                    
        ConfrontaY:
            mov bl,Mela[1]
            ;se anche la Y e' uguale allora vuol dire che il serpente a mangiato la mela, e quindi il serpente si allunga
            cmp SnakeY[0],bl
            je IncrementoSnake
            jmp ripeti
                        
            IncrementoSnake:
                inc Lunghezza
                mov bl,Lunghezza
                mov si,bx
                    ;il nuovo pezzo che si crea deve essere la vecchia cella vuota, e la nuova cella vuota deve avere le stesse coordinate della precedente 
                    Copia SnakeX[si-1],SnakeX[si]
                    Copia SnakeY[si-1],SnakeY[si]
                    call ChiamaRandom 
                        
    ret
                          
endp

;si occupa di controllare che la posizione della mela sia valida
ChiamaRandom proc near
    
    mov si,0
        
    rifai:
            
        Random Mela[si]
        
    cmp Mela[si],0  ;la posizione 0 coincide con i bordi, quindi non e' accettata
    je rifai
        
        inc si
        cmp si,2
        jl rifai
    
    mov si,0
    
    mov bx,0
    ControlloParti:
        mov bl,SnakeX[si]     
        cmp Mela[0],bl  ;se la X della mela coincide con la X (elemento 0 dell'array mela) di una parte del serpente deve controllare la Y (elemento 0 dell'array mela)
        je ControllaY
    
    
        ControllaY:
            mov bl,SnakeY[si]
            cmp Mela[1],bl  ;se anche la Y (elemento 1 dell'array mela) concide con la Y della mela allora devo essere riestratti nuovi numeri
            je RiChiamaRandom
            jmp passa
            
            RiChiamaRandom:
                call ChiamaRandom  ;se si usa la ricorsione una volta uscito dalla ricorsione bisogna uscire dalla procedura immediamente senza fare altro  
                jmp esci
                        
            passa:
            mov bx,0
            mov bl,Lunghezza
        
            inc si
         cmp si,bx  ;si deve ripetere fino a quando si non supera l'ultima parte del serpente
         jne ControlloParti
        
         Stampa Mela[0],Mela[1],'H'
         
         esci:
    ret
    
endp

end start