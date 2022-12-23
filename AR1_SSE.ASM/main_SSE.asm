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
    temp_rcx dq 0
    maska dd 0,0,0,0
SECTION .bss
    array resq 1
    inputFilePath resq 1
    outputFilePath resq 1
    buffer resq 1
    align 16
    iterationPair resd 4
    temp resd 4
    ourNumber resd 4

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
    mov [buffer],rax ; Sada na adresi [buffer] imamo adresu alocirane memorije

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

    mov rsi,0;
petljaInitail:
        xor rax,rax
        xor rbx,rbx
        xor rdx,rdx
        mov rdx,buffer
        mov eax,dword [rdx+rsi*8] ;prvi element opsega
        mov ebx,dword [rdx+rsi*8+4] ;drugi element opsega

        cmp rax,rbx
        jg error_end ; ako opseg nije dobro specificiran

        mov [first_element_of_range],rax
        mov [last_element_of_range],rbx
        sub rbx,[first_element_of_range] ;rbx-first = numIterations
        mov [num_iterations],rbx
        mov rcx,[first_element_of_range] ; u rcx prvi element opsega
    
    findPrime:  
        ;loop elements
        mov r8,rcx
        mov [temp_rcx],rcx ; sacuvamo u privremeno polje vrijednost rcx-a
        call isItPrime
        cmp r10,0
        jne nije_prost
        xor rax,rax
        mov rax,[counter_of_prime]
        inc rax
        mov [counter_of_prime],rax
    nije_prost:
        mov rcx,[temp_rcx] 
        inc rcx
        cmp r8,[last_element_of_range]
        jne findPrime

        inc rsi
        cmp rsi,[num_of_ranges]
        jne petljaInitail

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


isItPrime:
    mov r9,0 ; counter for dividers
    cvtsi2ss xmm0,r8;broj za koji provjeravamo da li je prost konvertujemo FP da bi mogli sa njim raditi operacije
    ;u naznacenu adresu kopiramo 4 puta taj broj
    MOVSS [ourNumber],  xmm0 
    MOVSS [ourNumber+4], xmm0
    MOVSS [ourNumber+8],  xmm0
    MOVSS [ ourNumber+12], xmm0
    movaps xmm0,[ourNumber] ;ucitavamo ta 4 ista broja sa mem.lokacije u xmm0 registar
    xor rdx,rdx
    mov rax,r8
    sub rax,1;smanjujemo broj iteracija sa 1 jer nam ne treba iteracija kad je i = 1
    mov rcx,4
    div rcx ;rax je rez,rdx ostatak, rax predstavlja broj inicijalnih iteracija a rdx su iteracije za ostatak
    mov rcx,2 ;i
    cmp r8,1 ;Ukoliko je broj 1 koji provjeravamo znamo da nije prost
    je not_prime
    ;Stavljamo u masku 0,0,0,0
    mov dword [maska],0
    mov dword [maska+4],0
    mov dword [maska+8],0
    mov dword [maska+12],0
    push rdx ; pushamo ostatak koji ce nam trebati kasnije
    mov rdx,0 
petlja:
	cmp rdx,rax
	je kraj_petlje ; ako smo dosli do poslednjeg elementa zavrsavamo sa iteracijama
	;trebamo na neku lokaciju xmm1 citati podatke staviti 4 iteracije
	MOVDQU xmm1,xmm0 ; xmm1 nam sluzi kao temp u koji smjestamo broj koji provjeravamo da li je prost
	cvtsi2ss xmm2,rcx ; u xmm2 stavljamo  rcx koji je brojac
	MOVSS [iterationPair], xmm2 ;u dato polje na nultoj poziciji postavljamo xmm2 vrijednost
	add rcx,1 ;inkrementujemo brojac
	cvtsi2ss xmm2,rcx ; konvertujemo iz inta u single precision float
	MOVSS [iterationPair+4], xmm2 
	add rcx,1
	cvtsi2ss xmm2,rcx
	MOVSS [iterationPair+8], xmm2
	add rcx,1
	cvtsi2ss xmm2,rcx
	MOVSS [iterationPair+12], xmm2
	add rcx,1
	movaps xmm2,[iterationPair] ; kada smo podesili odgovarajuce elemente u xmm2 prebacujemo [iteration pair]
	divps xmm1,xmm2 ;ovdje smo podjelili i dobili smo rezultate sa zarezom
	MOVUPS [temp],xmm1
	;vrsimo konverziju iz floata u int da bi se rijesili zareza
	cvttss2si ebx,[temp]
	mov [temp],ebx
	cvttss2si ebx,[temp+4]
	mov [temp+4],ebx
	cvttss2si ebx,[temp+8]
	mov [temp+8],ebx
	cvttss2si ebx,[temp+12]
	mov [temp+12],ebx
	
	;vracamo u float da bi mogli paralelno oduzeti one sa zarezom
	;i one bez
	cvtsi2ss xmm3,[temp]
	MOVSS [temp], xmm3
	cvtsi2ss xmm3,[temp+4]
	MOVSS [temp+4], xmm3
	cvtsi2ss xmm3,[temp+8]
	MOVSS [temp+8], xmm3
	cvtsi2ss xmm3,[temp+12]
	MOVSS [temp+12], xmm3
	movaps xmm3, [temp]
	
	;Sada u xmm1 imamo brojeve sa zarezom, a u xmm3 iste brojeve bez zareza
	;oduzimanje
	movups xmm4,[maska] ; u xmm4 maska (0,0,0,0)
	subps xmm1,xmm3 ; oduzimanje
	CMPPS xmm1, xmm4, 0 ; poredimo dobijeni rezultat sa maskom 
    ;ukoliko je jednako nuli u xmm registru ce biti 0 na odgovarajucem mjestu
    ;u suprotnom ce biti ffff...
	MOVDQU [temp],xmm1 ; prebacujemo rezultat u pocmocno polje
	mov r11,0 ;sluzi kao pomjeraj kroz [temp]
	mov r14,0
provjera:
	cmp r14,4
	je kraj_provjere
	cmp dword [temp+r11],0
	jne povecaj_counter ; ukoliko je 0 povecavamo brojac (djeljiv)
	jmp nema_povecanja ; u suprotnom ne povecavamo (nije djeljiv)
povecaj_counter:
	add r9,1
nema_povecanja: ;ovo se moze izmjenuti petlju drugacije !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	add r14,1
	add r11,4
	jmp provjera
kraj_provjere:
	
	add rdx,1 ; inkrementujemo brojac
	jmp petlja

kraj_petlje:
    pop rdx ; skidamo sa steka ostak koji nam govori koliko elemenata je preostalo za provjeru
    cmp rdx,0
    mov r11,0;pomjeraj u [temp]
    mov r14,0;brojac iteracija brojeva
obrada:
    cmp r14,rdx;provjeravamo iteracije
    je kraj_obrade
    cvtsi2ss xmm1,rcx; pretvaramo u fp
    movss [temp+r11],xmm1 ; dodajemo na odgovarajucu poziciju [temp]
    add rcx,1 ;prelazimo na sljedeci element
    add r11,4;povecavamo pomjeraj
    add r14,1 ; povecavamo brojac
    jmp obrada
kraj_obrade:
    movups xmm1,[temp] ; u xmm1 stavljamo preostale elemente
    divps xmm0,xmm1 ; dijelimo xmm0, u kome je broj koji provjeravamo da li je prost, sa preostalim elementima
    MOVUPS [temp],xmm0 ; rezultat smjestamo u [temp]
    ;vrsimo konverziju iz floata u int da bi se rijesili zareza
    cvttss2si ebx,[temp]
    mov [temp],ebx
    cvttss2si ebx,[temp+4]
    mov [temp+4],ebx
    cvttss2si ebx,[temp+8]
    mov [temp+8],ebx
    cvttss2si ebx,[temp+12]
    mov [temp+12],ebx
    ;U xmm3 stavljamo elemente bez zareza (vrsimo njihovu konverziju iz inta u float)
    cvtsi2ss xmm3,[temp]
    MOVSS [temp], xmm3
    cvtsi2ss xmm3,[temp+4]
    MOVSS [temp+4], xmm3
    cvtsi2ss xmm3,[temp+8]
    MOVSS [temp+8], xmm3
    cvtsi2ss xmm3,[temp+12]
    MOVSS [temp+12], xmm3
    movaps xmm3, [temp] ; U xmm3 elementi bez zareza
    subps xmm0,xmm3 ; Oduzimamo
    CMPPS xmm0, xmm4, 0 ;Opet ista prica ako je 0 onda je 0 u xmm0 inace ffff...
    MOVDQU [temp],xmm0
    mov r11,0 ;pomjeraj
	mov r14,0 ;brojac
provjera2:
	cmp r14,rdx
	je kraj_provjere2
	cmp dword [temp+r11],0
	jne povecaj_counter2 ;ako je nije 0 povecavamo counter
	jmp nema_povecanja2 ; ako jeste ne povecavamo
povecaj_counter2:
	add r9,1
nema_povecanja2:
	add r14,1 ;povecavamo brojac
	add r11,4 ;povecavamo pomjeraj
	jmp provjera2
kraj_provjere2:

    ;Cistimo xmm registre za sljedecu iteraciju
    xorps xmm0,xmm0 
    xorps xmm1,xmm1
    xorps xmm2,xmm2
    xorps xmm3,xmm3
    xorps xmm4,xmm4

    cmp r9,1
    jne not_prime
    mov r10,0
    jmp end
not_prime:
    mov r10,1
end:
    ret

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