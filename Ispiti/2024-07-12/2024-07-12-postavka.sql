--1.Kreirati bazu podataka sa imenom vaseg broja indeksa

--2.U kreiranoj bazi tabelu sa strukturom : 
--a) Uposlenici 
-- UposlenikID cjelobrojni tip i primarni kljuc autoinkrement,
-- Ime 10 UNICODE karaktera (obavezan unos)
-- Prezime 20 UNICODE karaktera (obaveznan unos),
-- DatumRodjenja polje za unos datuma i vremena (obavezan unos)
-- UkupanBrojTeritorija cjelobrojni tip

--b) Narudzbe
-- NarudzbaID cjelobrojni tip i primarni kljuc autoinkrement,
-- UposlenikID cjelobrojni tip i strani kljuc,
-- DatumNarudzbe polje za unos datuma i vremena,
-- ImeKompanijeKupca 40 UNICODE karaktera,
-- AdresaKupca 60 UNICODE karaktera,
-- UkupanBrojStavkiNarudzbe cjelobrojni tip

--c) Proizvodi
-- ProizvodID cjelobrojni tip i primarni kljuc autoinkrement,
-- NazivProizvoda 40 UNICODE karaktera (obaveznan unos),
-- NazivKompanijeDobavljaca 40 UNICODE karaktera,
-- NazivKategorije 15 UNICODE karaktera

--d) StavkeNarudzbe
-- NarudzbaID cjelobrojni tip strani i primarni kljuc,
-- ProizvodID cjelobrojni tip strani i primarni kljuc,
-- Cijena novcani tip (obavezan unos),
-- Kolicina kratki cjelobrojni tip (obavezan unos),
-- Popust real tip podataka (obavezno)

--(4 boda)


--3.Iz baze Northwind u svoju prebaciti sljedece podatke :
--a) U tabelu uposlenici sve uposlenike , Izracunata vrijednost za svakog uposlenika
-- na osnovnu EmployeeTerritories -> UkupanBrojTeritorija

--b) U tabelu narudzbe sve narudzbe, Izracunata vrijensot za svaku narudzbu pojedinacno 
-- ->UkupanBrojStavkiNarudzbe

--c) U tabelu proizvodi sve proizvode

--d) U tabelu StavkeNrudzbe sve narudzbe

--(5 bodova)


--4. 
--a) (4 boda) Kreirati indeks kojim ce se ubrzati pretraga po nazivu proizvoda, OBEVAZENO kreirati testni slucaj (Nova baza)

--b) (4 boda) Kreirati proceduru sp_update_proizvodi kojom ce se izmjeniti podaci o prpoizvodima u tabeli. Korisnici mogu poslati jedan ili vise parametara te voditi raucna da ne dodje do gubitka podataka.(Nova baza)

--c) (5 bodova) Kreirati funckiju f_4c koja ce vratiti podatke u tabelarnom obliku na osnovnu prosljedjenog parametra idNarudzbe cjelobrojni tip. Funckija ce vratiti one narudzbe ciji id odgovara poslanom parametru. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalazi id narudzbe, ukupna vrijednost bez popusta. OBAVEZNO testni slucaj (Nova baza)

--d) (6 bodova) Pronaci najmanju narudzbu placenu karticom i isporuceno na porducje Europe, uz id narudzbe prikazati i spojeno ime i prezime kupca te grad u koji je isporucena narudzba (AdventureWorks)

--e) (6 bodova) Prikazati ukupan broj porizvoda prema specijalnim ponudama.Potrebno je prebrojati samo one proizvode koji pripadaju kategoriji odjece ili imaju zabiljezen model (AdventureWorks)

--f) (9 bodova) Prikazatu 5 kupaca koji su napravili najveci broj narudzbi u zadnjih 30% narudzbi iz 2011 ili 2012 god. (AdventureWorks)

--g) (10 bodova) Menadzmentu kompanije potrebne su informacije o najmanje prodavanim porizvodima. ...kako bi ih eliminisali iz ponude. Obavezno prikazati naziv o kojem se proizvodu radi i kvartal i godinu i adekvatnu poruku. (AdventureWorks)


--5.
--a) (11 bodova) Prikazati kupce koji su kreirali narudzbe u minimalno 5 razlicitih mjeseci u 2012 godini.

--b) (16 bodova) Prikazati 5 narudzbi sa najvise narucenih razlicitih proizvoda i 5 narudzbi sa najvise porizvoda koji pripadaju razlicitim potkategorijama. Upitom prikazati ime i prezime kupca, id narudzbe te ukupnu vrijednost narudzbe sa popoustom zaokruzenu na 2 decimale (AdventureWorks)