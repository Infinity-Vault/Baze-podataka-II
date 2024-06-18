--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)
--• Tezina, decimalna vrijednost sa 2 znaka iza zareza

--b) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivTeritorije, 50 UNICODE (obavezan unos)
--• NazivRegije, 50 UNICODE (obavezan unos)
--• NacinIsporuke, 50 UNICODE (obavezan unos)

--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)

--**Jedan proizvod se može više puta naručiti, dok jedna narudžba može sadržavati više --proizvoda. U okviru jedne
--narudžbe jedan proizvod se može naručiti više puta.
--7 bodova
--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Proizvodi dodati sve proizvode, na mjestima gdje nema pohranjenih podataka o- -težini
--zamijeniti vrijednost sa 0
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije
--• Weight -> Tezina

--b) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• Name (SalesTerritory) -> NazivTeritorije
--• Group (SalesTerritory) -> NazivRegije
--• Name (ShipMethod) -> NacinIsporuke

--c) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust
--8 bodova

--4.
--a) (6 bodova) Kreirati upit koji će prikazati ukupan broj uposlenika po odjelima. --Potrebno je prebrojati
--samo one uposlenike koji su trenutno aktivni, odnosno rade na datom odjelu. Također, -samo- uzeti u obzir
--one uposlenike koji imaju više od 10 godina radnog staža (ne uključujući graničnu --vrijednost). Rezultate
--sortirati preba broju uposlenika u opadajućem redoslijedu. (AdventureWorks2017)

--b) (10 bodova) Kreirati upit koji prikazuje po mjesecima ukupnu vrijednost poručene robe- -za skladište, te
--ukupnu količinu primljene robe, isključivo u 2012 godini. Uslov je da su troškovi -prevoza- bili između
--500 i 2500, a da je dostava izvršena CARGO transportom. Također u rezultatima upita je --potrebno
--prebrojati stavke narudžbe na kojima je odbijena količina veća od 100. --(AdventureWorks2017)

--c) (10 bodova) Prikazati ukupan broj narudžbi koje su obradili uposlenici, za svakog --uposlenika
--pojedinačno. Uslov je da su narudžbe kreirane u 2011 ili 2012 godini, te da je u okviru --jedne narudžbe
--odobren popust na dvije ili više stavki. Također uzeti u obzir samo one narudžbe koje su- -isporučene u
--Veliku Britaniju, Kanadu ili Francusku. (AdventureWorks2017)

--d) (11 bodova) Napisati upit koji će prikazati sljedeće podatke o proizvodima: naziv --proizvoda, naziv
--kompanije dobavljača, količinu na skladištu, te kreiranu šifru proizvoda. Šifra se --sastoji od sljedećih
--vrijednosti: (Northwind)
--1) Prva dva slova naziva proizvoda
--2) Karakter /
--3) Prva dva slova druge riječi naziva kompanije dobavljača, uzeti u obzir one kompanije --koje u
--nazivu imaju 2 ili 3 riječi
--4) ID proizvoda, po pravilu ukoliko se radi o jednocifrenom broju na njega dodati slovo --'a', u
--suprotnom uzeti obrnutu vrijednost broja
--Npr. Za proizvod sa nazivom Chai i sa dobavljačem naziva Exotic Liquids, šifra će btiti --Ch/Li1a.
--37 bodova

--5.
--a) (3 boda) U kreiranoj bazi kreirati index kojim će se ubrzati pretraga prema šifri i --nazivu proizvoda.
--Napisati upit za potpuno iskorištenje indexa.

--b) (7 bodova) U kreiranoj bazi kreirati proceduru sp_search_products kojom će se vratiti- -podaci o
--proizvodima na osnovu kategorije kojoj pripadaju ili težini. Korisnici ne moraju unijeti- -niti jedan od
--parametara ali u tom slučaju procedura ne vraća niti jedan od zapisa. Korisnicima unosom- -već prvog
--slova kategorije se trebaju osvježiti zapisi, a vrijednost unesenog parametra težina će --vratiti one
--proizvode čija težina je veća od unesene vrijednosti.

--c) (18 bodova) Zbog proglašenja dobitnika nagradne igre održane u prva dva mjeseca -drugog- kvartala 2013
--godine potrebno je kreirati upit. Upitom će se prikazati treća najveća narudžba --(vrijednost bez popusta)
--za svaki mjesec pojedinačno. Obzirom da je u pravilima nagradne igre potrebno nagraditi -2- osobe
--(muškarca i ženu) za svaki mjesec, potrebno je u rezultatima upita prikazati pored --navedenih stavki i o
--kojem se kupcu radi odnosno ime i prezime, te koju je nagradu osvojio. Nagrade se --dodjeljuju po
--sljedećem pravilu:
--• za žene u prvom mjesecu drugog kvartala je stoni mikser, dok je za muškarce usisivač
--• za žene u drugom mjesecu drugog kvartala je pegla, dok je za muškarc multicooker
--Obzirom da za kupce nije eksplicitno naveden spol, određivat će se po pravilu: Ako je --zadnje slovo imena
--a, smatra se da je osoba ženskog spola u suprotnom radi se o osobi muškog spola. --Rezultate u formiranoj
--tabeli dobitnika sortirati prema vrijednosti narudžbe u opadajućem redoslijedu. --(AdventureWorks2017)
--28 bodova

--6. Dokument teorijski_ispit 29JUN22, preimenovati vašim brojem indeksa, te u tom --dokumentu izraditi
--pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem indeksa npr IB200001.sql, --teorijski dokument imenovan
--Vašim brojem indexa npr IB200001.docx upload-ovati ODVOJEDNO na ftp u folder Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55
