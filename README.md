# Arhitektura-Optimizacija
### Algoritam: Izračunavanje ukupne količine prostih brojeva u opsezima iz specificiranog skupa opsega

### Prvi projektni zadatak:
Napisati asemblerski program za obradu podataka. Algoritam odabrati na stranici kursa. Program
treba da, kao argumente komandne linije, prihvata putanju do ulaznog fajla, putanju do izlaznog fajla, kao
i vrijednosti parametara algoritma. Obezbijediti smislene podrazumijevane vrijednosti za sve argumente
komandne linije. Program treba da dinamički alocira stranice potrebne za podatke koji se obrađuju.

Optimizovati program uvođenjem SSE ili AVX paralelizma, te dokumentovati ubrzanje.

Napisati isti program u C ili C++ programskom jeziku i isprobati različite nivoe kompajlerskih
optimizacija. Pri tome, pridržavati se osnovnih principa pisanja efiksanog koda. Uporediti performanse sa
prethodnim implementacijama i dokumentovati rezultate.

### Drugi projektni zadatak:
U proizvoljnom programskom jeziku realizovati paralelizibilan algoritam koji vrši netrivijalnu obradu
podataka.

Program treba da, kao argumente komandne linije, prihvata putanju do ulaznog fajla, putanju do izlaznog
fajla, kao i vrijednosti parametara algoritma. Obezbijediti smislene podrazumijevane vrijednosti za sve
argumente komandne linije. Analizirati, uporediti, dokumentovati i grafički predstaviti mogućnosti
ubrzavanja datog algoritma korištenjem kompajlerskih optimizacija 2 navedena pristupa:

1. (a) SIMD programiranje ili (b) optimizacije za keš memoriju.
- Za (a) je dozvoljeno koristiti SIMD optimizacije urađene u zadatku 1.2 (asemblerski
program za obradu podataka), ako je odabran isti algoritam i za ovaj zadatak.
- Za (b) je potrebno izvršiti mjerenja (npr. upotrebom cachegrind alata) i pokazati da keš
optimizacija stvarno doprinosi keš performansama (procentu keš pogodaka).
- Za (b) je dozvoljeno da se kao inicijalni algoritam iskoristi varijanta algoritma sa lošijim keš
performansama (bez dodavanja nepotrebnog koda).
2. Paralelizacija na višejezgarnom procesoru (npr. OpenMP ili sopstveno rješenje).

Kombinovati dva navedena pristupa u cilju još većeg ubrzanja i dokumentovati rezultate. Pri tome je
potrebno zabilježiti i grafički predstaviti rezultate prije i poslije primjene optimizacija i paralelizacije.
Obezbijediti nekoliko primjera ili jediničnih testova kojima se demonstriraju funkcionalnosti iz stavki u
specifikaciji projektnog zadatka. Na pravilan način pokazati da će optimizovane varijante algoritma
proizvoditi tačan rezultat.
