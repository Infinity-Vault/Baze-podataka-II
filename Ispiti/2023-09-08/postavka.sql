--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa. 

--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom: 
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Ime, 50 UNICODE karaktera (obavezan unos)
--• Prezime, 50 UNICODE karaktera (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE 

--b) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)

--c) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• KreditnaKarticaID, cjelobrojna vrijednost
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivGrada, 30 UNICODE (obavezan unos)
--• ProdavacID, cjelobrojna vrijednost i strani ključ
--• NacinIsporuke, 50 UNICODE (obavezan unos)

--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)

--**Jedan proizvod se može više puta naručiti, dok jedna narudžba može sadržavati više proizvoda. 
--U okviru jedne narudžbe jedan proizvod se može naručiti više puta.
--7 bodova
--3a. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Prodavaci dodati :
--• BusinessEntityID (SalesPerson) -> ProdavacID
--• FirstName -> Ime
--• LastName -> Prezime
--• JobTitle (Employee) -> OpisPosla
--• EmailAddress (EmailAddress) -> EmailAdresa

--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--3b) U tabelu Proizvodi dodati sve proizvode
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije

--3c) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• CreditCardID -> KreditnaKarticaID
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• City (Address) -> NazivGrada
--• SalesPersonID (SalesOrderHeader) -> ProdavacID
--• Name (ShipMethod) -> NacinIsporuke

--3d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude

--4.
--a)(6 bodova) kreirati pogled v_detalji gdje je korisniku potrebno prikazati --identifikacijski broj narudzbe,
--spojeno ime i prezime kupca, grad isporuke, ukupna vrijednost narudzbe sa popustom i- -bez popusta, te u dodatnom polju informacija da li je narudzba placena karticom --("Placeno karticom" ili "Nije placeno karticom").
--Rezultate sortirati prema vrijednosti narudzbe sa popustom u opadajucem redoslijedu.
--OBAVEZNO kreirati testni slucaj.(Novokreirana baza)
--

--b)( 4 bodova) U kreiranoj bazi kreirati wproceduru sp_insert_ZaglavljeNarudzbe kojom- -ce se omoguciti kreiranje nove narudzbe. OBAVEZNO kreirati testni slucaj.--(Novokreirana baza).
--

--c)(6 bodova) Kreirati upit kojim ce se prikazati ukupan broj proizvoda po --kategorijama. Uslov je da se prikazu samo one kategorije kojima ne pripada vise od --30 proizvoda, a sadrze broj u bilo kojoj od rijeci i ne nalaze se u prodaji.--(AdventureWorks2017)
--

--d)(7 bodova) Kreirati upit koji ce prikazati uposlenike koji imaju iskustva( radilli- -su na jednom odjelu) a trenutno rade na marketing ili odjelu za nabavku. Osobama -po- prestanku rada na odjelu se upise podatak datuma prestanka rada.
--Rezultat upita treba prikazati ime i prezime uposlenika, odjel na kojem rade.
--(AdventureWorks2017)
--

--e)(7 bodova) Kreirati upit kojim ce se prikazati proizvod koji je najvise dana bio u- -prodaji( njegova prodaja je prestala) a pripada kategoriji bicikala. Proizvodu se- -pocetkom i po prestanku prodaje biljezi datum.
--Ukoliko postoji vise proizvoda sa istim vremenskim periodom kao i prvi prikazati ih -u- rezultatima upita.
--(AdventureWorks2017)
--

--(30 bodova
--5.)
--
--a) (9 bodova) Prikazati nazive odjela na kojima TRENUTNO radi najmanje , odnosno --najvise uposlenika(AdventureWorks2017)
--

--b)(10 bodova) Kreirati upit kojim ce se prikazati ukupan broj obradjenih narudzbi i --ukupnu vrijednost narudzbi sa popustom za svakog uposlenika pojedinacno, i to od --zadnje 30% kreiranih datumski kreiranih narudzbi. Rezultate sortirati prema -ukupnoj- vrijednosti u opadajucem redoslijedu.
--(AdventureWorks2017)
--

--f)(12 bodova) Upitom prikazati id autora, ime i prezime, napisano djelo i šifra. --Prikazati samo one zapise gdje adresa autora pocinje sa ISKLJUCIVO 2 broja (Pubs)
--Šifra se sastoji od sljedeći vrijednosti: 
--	1.Prezime po pravilu(prezime od 6 karaktera -> uzeti prva 4 karaktera; prezime -od- 10 karaktera-> uzeti prva 6 karaktera, za sve ostale slucajeve uzeti prva dva --karaktera)
--	2.Ime prva 2 karaktera
--	3.Karakter /
--	4.Zip po pravilu( 2 karaktera sa desne strane ukoliko je zadnja cifra u opsegu --0-5; u suprotnom 2 karaktera sa lijeve strane)
--	5.Karakter /
--	6.State(obrnuta vrijednost)
--	7.Phone(brojevi između space i karaktera -)
--	Primjer : za autora sa id-om 486-29-1786 šifra je LoCh/30/AC585
--			  za autora sa id-om 998-72-3567 šifra je RingAl/52/TU826
--(31 bod)
--
