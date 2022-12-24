global _start

SECTION .data
    error_msg db 'Pogresan unos ili greska kod rada sa fajlom.',0Ah
    len_error equ $-error_msg
    num_of_ranges dq 0
    num_of_elements dq 0
    buffer_size dq 0
    first_element_of_range dq 0
    last_element_of_range dq 0
    half_of_last_element_of_range dq 0
    num_iterations dq 0
    counter dq 0
    counter_of_prime dq 0
    temp_rsi dq 0
    temp_rcx dq 0
    temp_rdx dq 0

SECTION .bss
    buffer resd 1000000
    inputFilePath resq 1
    outputFilePath resq 1
    

SECTION .text

_start:
    pop rax; ; Sa steka skidamo broj argumenata
    cmp rax,4 ; 4 argumenta: poziv programa, broj opsega, ulazni fajl, izlazni fajl
    jne error_end ; ako je br. argumenata nije jednak 4 greska
    pop rax ; niz karaktera komande
    pop rax ; adresa prvog argumenta
    call atoi ; string na adresi u rax-u konvertujemo u int, a rezultat smijestamo u rbx
    mov qword [num_of_ranges],rbx; Iz rbx-a uzimamo broj ospega
    cmp qword [num_of_ranges],0;
    jbe error_end ;ako je br. opsega <= 0 greska

    pop rax ; skidamo putanju ulaznog fajla
    mov [inputFilePath],rax ; smjestamo je u dato polje

    pop rax ; skidamo putanju izlaznog fajla
    mov [outputFilePath],rax ; smjestamo ga u dato polje

    ;Alokacija memorije za niz opsega
    xor rax,rax ; Cistimo rax
    xor rbx,rbx ; Cistimo rbx
    xor rcx,rcx ; Cistimo rcx
    xor rdx,rdx ; Cistimo rdx
    mov qword rax,[num_of_ranges] ; U rax prebacujemo br. opsega
    mov rbx,2 ; Svaki par sadrzi 2 elementa
    mul rbx ; Mnozimo sa 2 -> broj elemenata niza
    mov qword [num_of_elements],rax ; Sacuvacemo broj elemenata u datom polju za kasnije
    mov rbx,4
    mul rbx ; Pomnozimo sa 4, jer toliko bajta ima svaki podatak
    mov [buffer_size],rax ; cuvamo velicinu buffera
    mov rdi,0 ; U rdi stavljamo 0, kernel alocira memorijski prostor bilo gdje pa u rax vraca adresu koja vodi do tog prostora
    mov rsi,rax ; U rsi ide kolicina bajtova koje alociramo
    mov rdx,2 ; Stavljamo prot value, u nasem slucaju 2, zelimo da pisemo po toj memoriji (kao i da citamo)
    mov r10,22h ; Parametar flags ide u r10 registar, stavljamo MAP_ANONYMOUS
    mov r8,-1 ; File descriptor, za MAP_ANON postavljamo vrijednost -1
    mov r9,0 ; Podesimo offset na 0
    mov rax,9 ; Broj sistemskog poziva za mmap
    syscall
    mov qword [buffer],rax ; Sada na adresi [buffer] imamo adresu alocirane memorije

    xor rax,rax
    xor rcx,rcx
    xor rbx,rbx

    ;Otvaranje fajla
    mov rax,2
    mov rdi,[inputFilePath]
    mov rsi,0 ; otvaramo u read modu
    syscall
    mov rdi,rax ; U rdi stavljamo FD 
    cmp rdi,-1
    je error_end ; provjerili smo da li je uspjesno otvaranje, (u rax se vraca FD, ako je greska -1)

    ;Citanje iz fajla
    mov rax,0 ; fd
    mov rsi,buffer ;skladistimo podatke u buffer
    mov rdx,[buffer_size] ; citamo buffer_size bajtova
    syscall

    mov rax,3
    syscall ; zatvranje fajla


    xor rcx,rcx
    mov rcx,[num_of_ranges]; broj iteracija
    sub rcx,1 ; num_of_ranges - 1
    mov rsi,0 ; Brojac za indeksiranje
    xor rax,rax
    xor rbx,rbx
    

    petlja:
        xor rax,rax
        xor rbx,rbx
        xor rdx,rdx
        mov rdx,buffer
        mov eax,dword [rdx+rsi*8] ;prvi element opsega
        mov ebx,dword [rdx+rsi*8+4] ;drugi element opsega

        cmp rax,rbx
        jg error_end ; ako opseg nije dobro specificiran

        mov [temp_rsi],rsi
        mov [temp_rdx],rdx
        mov [temp_rcx],rcx

        findPrime:
        ;loop elements
        mov [first_element_of_range],rax
        mov [last_element_of_range],rbx
        sub rbx,[first_element_of_range] ;rbx-first = numIterations
        mov [num_iterations],rbx;
        mov rsi,[first_element_of_range] ; rsi brojac
        mov rcx,[num_iterations];

        vanjskaPetlja:
            mov rbx,1
            unutrasnjaPetlja:
            inc rbx
            xor rdx,rdx
            mov rax,rsi ; u raxu trenutni element niza
            div qword rbx ; dijelimo pa je ostatak u rdx
            cmp rdx,0 ; ako je ostatak pri dijeljenju 0 inkrementujemo brojac
            jne bottom
            mov rax,[counter]
            inc rax
            mov [counter],rax ; povecavamo brojac
            bottom:
            cmp rbx,rsi
            jne unutrasnjaPetlja

        mov rax,[counter]
        cmp rax,1
        jne skip
        mov rax,[counter_of_prime] ;uvecavamo brojac prostih brojeva
        inc rax
        mov [counter_of_prime],rax
        skip:
        mov rax,0
        mov [counter],rax; restartujemo brojac
        inc rsi ; element niza
        loop vanjskaPetlja

        xor rdx,rdx
        xor rcx,rcx
        xor rsi,rsi
        mov rdx,qword [temp_rdx]
        mov rcx,qword [temp_rcx]
        mov rsi,qword [temp_rsi]
        xor rax,rax
        mov [temp_rsi],rax

        inc rsi ; uvecavamo brojac

        cmp rsi,[num_of_ranges]
        jne petlja

    xor rbx,rbx
    mov rbx,[counter_of_prime]
    xor rax,rax
    xor rdi,rdi
    xor rsi,rsi


    ; Kreiranje fajla
    mov rax,85 ; Broj sistemskog poziva za kreiranje
    mov rdi,[outputFilePath] ; U rdi stavljamo adresu do putanje do fajla
    mov rsi,1ffh ; Dodajemo prava pristupa za fajl koji kreiramo (<=> chmod 777)
    syscall 
    mov rax,2 ; Broj sistemskog poziva za otvaranje
    mov rdi,[outputFilePath] ; U rdi fajl koji otvaramo   
    mov rsi,1 ; Otvaramo u write mode
    syscall
    mov rdi,rax ; U rdi stavljamo FD 
    cmp rdi,-1
    je error_end ; provjerili smo da li je uspjesno otvaranje, (u rax se vraca FD, ako je greska -1)
    mov rax,1 ; Broj sist. poziva za upis
    mov rdx,4 ; Upisuje se 4-bajtni podatak 
    mov rsi,counter_of_prime ; Source u rsi
    syscall ; Upis broja prostih brojeva

    mov rax,60
    mov rdi,0
    syscall


error_end:
    mov rax,1
    mov rdi,1
    mov rsi,error_msg
    mov rdx,len_error
    syscall ; Ispis poruke za pogresan unos
    mov rax,60
    mov rdi,0
    syscall

atoi:
        xor rbx, rbx ; Cistimo rbx, tu cemo ostaviti rezultat
        xor rcx,rcx ; Ocisticemo i rcx jer cemo sa njim uzimati cifre
        .top:
        mov byte cl, [rax] ; Uzimamo jedan karakter
        inc rax ; Inkrementujemo za jedan bajt
        ; Provjere da li je dati karakter broj, ako nije kraj
        cmp cl, '0' 
        jb .done
        cmp cl, '9'
        ja .done
        sub cl, '0' ; Ova linija vrsi u sustini konverziju
        imul rbx, 10 ; Pomnozimo trenutni rezultat sa 10 (dostigli smo novu dekadu)
        add rbx, rcx ; Saberemo trenutnu cifru na rezultat
        jmp .top 
        .done:
        ret