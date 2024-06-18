--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Uposlenici
--• UposlenikID, 9 karaktera fiksne dužine i primarni ključ,
--• Ime, 20 karaktera (obavezan unos),
--• Prezime, 20 karaktera (obavezan unos),
--• DatumZaposlenja, polje za unos datuma i vremena (obavezan unos),
--• OpisPosla, 50 karaktera (obavezan unos)

--b) Naslovi
--• NaslovID, 6 karaktera i primarni ključ,
--• Naslov, 80 karaktera (obavezan unos),
--• Tip, 12 karaktera fiksne dužine (obavezan unos),
--• Cijena, novčani tip podataka,
--• NazivIzdavaca, 40 karaktera,
--• GradIzadavaca, 20 karaktera,
--• DrzavaIzdavaca, 30 karaktera

--c) Prodaja
--• ProdavnicaID, 4 karaktera fiksne dužine, strani i primarni ključ,
--• BrojNarudzbe, 20 karaktera, primarni ključ,
--• NaslovID, 6 karaktera, strani i primarni ključ,
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos)

--d) Prodavnice
--• ProdavnicaID, 4 karaktera fiksne dužine i primarni ključ,
--• NazivProdavnice, 40 karaktera,
--• Grad, 40 karaktera
--6 bodova

--3. Iz baze podataka Pubs u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Uposlenici dodati sve uposlenike
--• emp_id -> UposlenikID
--• fname -> Ime
--• lname -> Prezime
--• hire_date -> DatumZaposlenja
--• job_desc -> OpisPosla

--b) U tabelu Naslovi dodati sve naslove, na mjestima gdje nema pohranjenih podataka -o- nazivima izdavača
--zamijeniti vrijednost sa nepoznat izdavac
--• title_id -> NaslovID
--• title -> Naslov
--• type -> Tip
--• price -> Cijena
--• pub_name -> NazivIzdavaca
--• city -> GradIzdavaca
--• country -> DrzavaIzdavaca

--c) U tabelu Prodaja dodati sve stavke iz tabele prodaja
--• stor_id -> ProdavnicaID
--• order_num -> BrojNarudzbe
--• title_id -> NaslovID
--• ord_date -> DatumNarudzbe
--• qty -> Kolicina

--22.09.2023.
--d) U tabelu Prodavnice dodati sve prodavnice
--• stor_id -> ProdavnicaID
--• store_name -> NazivProdavnice
--• city -> Grad
--6 bodova

--4.
--a) (6 bodova) Kreirati proceduru sp_update_naslov kojom će se uraditi update --podataka u tabelu Naslovi.
--Korisnik može da pošalje jedan ili više parametara i pri tome voditi računa da se -ne- desi gubitak/brisanje
--zapisa. OBAVEZNO kreirati testni slučaj za kreiranu proceduru. (Novokreirana baza)

--b) (7 bodova) Kreirati upit kojim će se prikazati ukupna prodana količina i ukupna --zarada bez popusta za
--svaku kategoriju proizvoda pojedinačno. Uslov je da proizvodi ne pripadaju --kategoriji bicikala, da im je
--boja bijela ili crna te da ukupna prodana količina nije veća od 20000. Rezultate --sortirati prema ukupnoj
--zaradi u opadajućem redoslijedu. (AdventureWorks2017)

--c) (8 bodova) Kreirati upit koji prikazuje kupce koji su u maju mjesecu 2013 ili --2014 godine naručili
--proizvod „Front Brakes“ u količini većoj od 5. Upitom prikazati spojeno ime i --prezime kupca, email,
--naručenu količinu i datum narudžbe formatiran na način dan.mjesec.godina --(AdventureWorks2017)

--d) (10 bodova) Kreirati upit koji će prikazati naziv kompanije dobavljača koja je --dobavila proizvode, koji
--se u najvećoj količini prodaju (najprodavaniji). Uslov je da proizvod pripada --kategoriji morske hrane i
--da je dostavljen/isporučen kupcu. Također uzeti u obzir samo one proizvode na -kojima- je popust odobren.
--U rezultatima upita prikazati naziv kompanije dobavljača i ukupnu prodanu količinu --proizvoda.
--(Northwind)

--e) (11 bodova) Kreirati upit kojim će se prikazati narudžbe u kojima je na osnovu --popusta kupac uštedio
--2000KM i više. Upit treba da sadrži identifikacijski broj narudžbe, spojeno ime i --prezime kupca, te
--stvarnu ukupnu vrijednost narudžbe zaokruženu na 2 decimale. Rezultate sortirati po- -ukupnoj vrijednosti
--narudžbe u opadajućem redoslijedu.
-- 43 boda

--5.
--a) (13 bodova) Kreirati upit koji će prikazati kojom kompanijom (ShipMethod(Name)) --je isporučen najveći
--broj narudžbi, a kojom najveća ukupna količina proizvoda. (AdventureWorks2017)

--b) (8 bodova) Modificirati prethodno kreirani upit na način ukoliko je jednom --kompanijom istovremeno
--isporučen najveći broj narudžbi i najveća ukupna količina proizvoda upitom -prikazati- poruku „Jedna
--kompanija“, u suprotnom „Više kompanija“ (AdventureWorks2017)

--c) (4 boda) Kreirati indeks IX_Naslovi_Naslov kojim će se ubrzati pretraga prema --naslovu. OBAVEZNO
--kreirati testni slučaj. (NovokreiranaBaza)

--25 bodova
--6. Dokument teorijski_ispit 22SEP23, preimenovati vašim brojem indeksa, te u tom --dokumentu izraditi pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem indeksa npr IB210001.sql, --teorijski dokument imenovan
--Vašim brojem indexa npr IB210001.docx upload-ovati ODVOJEDNO na ftp u folder -Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55
