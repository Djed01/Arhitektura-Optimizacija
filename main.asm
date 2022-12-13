global _start

SECTION .data
    error_msg db 'Pogresan unos ili greska kod rada sa fajlom.',0Ah
    len_error equ $-error_msg
    num_of_ranges dq 0
    num_of_elements dq 0
    buffer_size dq 0
    shift dq 0
SECTION .bss
    array resq 1
    inputFilePath resq 1
    outputFilePath resq 1
    buffer resq 1

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
    mov rsi,0 ; Brojac za indeksiranje
    xor rax,rax
    xor rbx,rbx

    petlja:
        xor rax,rax
        xor rbx,rbx
        xor rdx,rdx
        mov rdx,buffer
        mov eax,dword [rdx+rsi*8]
        mov ebx,dword [rdx+rsi*8+4]
        call findPrime
        inc rsi
        loop petlja


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
        xor rcx,rcx ; Ocisticemo i rxc jer cemo sa njim uzimati cifre
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

findPrime:
        

        ret