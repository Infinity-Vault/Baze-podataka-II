--1 Kreirati bazu za svojim brojm indeksa

--2 U kreiranoj bazi podataka kreirati tabele slijedecom strukturom
--a)	Uposlenici
--•	UposlenikID, 9 karaktera fiksne duzine i primarni kljuc,
--•	Ime 20 karaktera obavezan unos,
--•	Prezime 20 karaktera obavezan unos
--•	DatumZaposlenja polje za unos datuma i vremena obavezan unos
--•	Opis posla 50 karaktera obavezan unos

--b)	Naslovi
--•	NaslovID 6 karaktera primarni kljuc,
--•	Naslov 80 karaktera obavezan unos,
--•	Tip 12 karaktera fiksne duzine obavezan unos
--•	Cijena novcani tip podatka,
--•	NazivIzdavaca 40 karaktera,
--•	GradIzdavaca 20 karaktera,
--•	DrzavaIzdavaca 30 karaktera

--c)	Prodaja
--•	ProdavnicaID 4 karktera fiksne duzine, strani i primarni kljuc
--•	Broj narudzbe 20 karaktera primarni kljuc,
--•	NaslovID 6 karaktera strani i primarni kljuc
--•	DatumNarudzbe polje za unos datuma i vremena obavezan unos
--•	Kolicina skraceni cjelobrojni tip obavezan unos

--d)	Prodavnice
--•	ProdavnicaID 4 karaktera fiksne duzine primarni kljuc
--•	NazivProdavnice 40 karaktera
--•	Grad 40 karaktera

--3 Iz baze podataka pubs u svoju bazu prebaciti slijedece podatke
--a)	U tabelu Uposlenici dodati sve uposlenike
--•	emp_id -> UposlenikID
--•	fname -> Ime
--•	lname -> Prezime
--•	hire_date - > DatumZaposlenja
--•	job_desc - > Opis posla

--b)	U tabelu naslovi dodati sve naslove, na mjestu gdje nema pohranjenih podataka o --nazivima izdavaca zamijeniti vrijednost sa nepoznat izdavac
--•	Title_id -> NaslovID
--•	Title->Naslov
--•	Type->Tip
--•	Price->Cijena
--•	Pub_name->NazivIzdavaca
--•	City->GradIzdavaca
--•	Country-DrzavaIzdavaca

--c)	U tabelu prodaja dodati sve stavke iz tabele prodaja
--•	Stor_id->ProdavnicaID
--•	Order_num->BrojNarudzbe
--•	titleID->NaslovID,
--•	ord_date->DatumNarudzbe
--•	qty->Kolicina

--d)	U tabelu prodavnice dodati sve prodavnice
--•	Stor_id->prodavnicaID
--•	Store_name->NazivProdavnice
--•	City->Grad

--4
--a)	Kreirati proceduru sp_delete_uposlenik kojom ce se obrisati odredjeni zapis iz --tabele uposlenici. OBAVEZNO kreirati testni slucaj na kreiranu proceduru

--b)	Kreirati tabelu Uposlenici_log slijedeca struktura
--Uposlenici_log
--•	UposlenikID 9 karaktera fiksne duzine
--•	Ime 20 karaktera
--•	Prezime 20 karakera,
--•	DatumZaposlenja polje za unos datuma i vremena
--•	Opis posla 50 karaktera

--c)	Nad tabelom uposlenici kreirati okidac t_ins_Uposlenici koji ce prilikom --birsanja podataka iz tabele Uposlenici izvristi insert podataka u tabelu --Uposlenici_log. OBAVEZNO kreirati tesni slucaj

--d)	Prikazati sve uposlenike zenskog pola koji imaju vise od 10 godina radnog -staza,- a rade na Production ili Marketing odjelu. Upitom je potrebno pokazati -spojeno -ime i prezime uposlenika, godine radnog staza, te odjel na kojem rade -uposlenici. -Rezultate upita sortirati u rastucem redoslijedu prema nazivu odjela,- te -opadajucem prema godinama radnog staza (AdventureWorks2019)

--e)	Kreirati upit kojim ce se prikazati koliko ukupno je naruceno komada proizvoda --za svaku narudzbu pojedinacno, te ukupnu vrijednost narudzbe sa i bez popusta. --Uzwti u obzir samo one narudzbe kojima je datum narudzbe do datuma isporuke --proteklo manje od 7 dana (ukljuciti granicnu vrijednost), a isporucene su kupcima --koji zive na podrucju Madrida, Minhena,Seatle. Rezultate upita sortirati po broju- -komada u opadajucem redoslijedu, a vrijednost je potrebno zaokruziti na dvije --decimale (Northwind)

--f)	Napisati upit kojim ce se prikazati brojNarudzbe,datumNarudzbe i sifra. --Prikazati samo one zapise iz tabele Prodaja ciji broj narudzbe ISKLJICIVO POCINJE --jednim slovom, ili zavrsava jednim slovom (Novokreirana baza)
--Sifra se sastoji od slijedecih vrijednosti:
--•	Brojevi (samo brojevi) uzeti iz broja narudzbi,
--•	Karakter /
--•	Zadnja dva karaktera godine narudbze /
--•	Karakter /
--•	Id naslova
--•	Karakter /
--•	Id prodavnice
--Za broj narudzbe 772a sifra je 722/19/PS2091/6380
--Za broj narudzbe N914008 sifra je 914008/19/PS2901/6380

--5
--a)	Prikazati nazive odjela gdje radi najmanje odnosno najvise uposlenika --(AdventureWorks2019)

--b)	Prikazati spojeno ime i prezime osobe,spol, ukupnu vrijednost redovnih bruto --prihoda, ukupnu vrijednost vandrednih prihoda, te sumu ukupnih vandrednih prihoda --i ukupnih redovnih prihoda. Uslov je da dolaze iz Latvije, Kine ili Indonezije a --poslodavac kod kojeg rade je registrovan kao javno ustanova (Prihodi)

--c)	Modificirati prethodni upit 5_b na nacin da se prikazu samo oni zapisi kod -kojih- je suma ukupnih bruto i ukupnih vanderednih prihoda (SumaBruto+SumaNeto) -veca od -10000KM Retultate upita sortirati prema ukupnoj vrijednosti prihoda -obrnuto -abecedno(Prihodi)
