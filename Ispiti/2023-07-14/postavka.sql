--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Ime, 50 UNICODE (obavezan unos)
--• Prezime, 50 UNICODE (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE karaktera

--b) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivPodkategorije, 50 UNICODE (obavezan unos)

--c) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• KreditnaKarticaID, cjelobrojna vrijednost
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivGradaIsporuke, 30 UNICODE (obavezan unos)
--• ProdavacID, cjelobrojna vrijednost, strani ključ
--• NacinIsporuke, 50 UNICODE (obavezan unos)

--d) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)
--**Jedan proizvod se može više puta naručiti, dok -jednanarudžba'možesadržavati'više''- proizvoda. U okviru jedne
--narudžbe jedan proizvod se može naručiti više puta.

--9 bodova
--3. Iz baze podataka AdventureWorks u svoju bazu podatakaprebacitisljedeće'podatke:
--a) U tabelu Prodavaci dodati sve prodavače
--• BusinessEntityID (SalesPerson) -> ProdavacID
--• FirstName (Person) -> Ime
--• LastName (Person) -> Prezime
--• JobTitle (Employee) -> OpisPosla
--• EmailAddress (EmailAddress) -> EmailAdresa

--b) U tabelu Proizvodi dodati sve proizvode
--• ProductID (Product)-> ProizvodID
--• Name (Product)-> Naziv
--• ProductNumber (Product)-> SifraProizvoda
--• Color (Product)-> Boja
--• Name (ProductSubategory) -> NazivPodkategorije

--c) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID (SalesOrderHeader) -> NarudzbaID
--• OrderDate (SalesOrderHeader)-> DatumNarudzbe
--• ShipDate (SalesOrderHeader)-> DatumIsporuke
--• CreditCardID(SalesOrderID)-> KreditnaKarticaID
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• City (Address) -> NazivGradaIsporuke
--• SalesPersonID (SalesOrderHeader)-> ProdavacID
--• Name (ShipMethod)-> NacinIsporuke

--d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID (SalesOrderDetail)-> NarudzbaID
--• ProductID (SalesOrderDetail)-> ProizvodID
--• UnitPrice (SalesOrderDetail)-> Cijena
--• OrderQty (SalesOrderDetail)-> Kolicina
--• UnitPriceDiscount (SalesOrderDetail)-> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude
--10 bodova

--4.
--a) (6 bodova) Kreirati funkciju f_detalji u formi --tabelegdje''korisnikuslanjem''parametra identifikacijski
--broj narudžbe će biti ispisano spojeno ime i prezime --kupca,grad''isporuke,ukupna''vrijednost narudžbe
--sa popustom, te poruka da li je narudžba plaćena karticom --iline.''Korisnikmože''dobiti 2 poruke „Plaćeno
--karticom“ ili „Nije plaćeno karticom“.
--OBAVEZNO kreirati testni slučaj. (Novokreirana baza)

--b) (4 bodova) U kreiranoj bazi -kreiratiproceduru'sp_insert_DetaljiNarudzbekojom'će''- se omogućiti insert
--nove stavke narudžbe. OBAVEZNO kreirati testni slučaj. (Novokreirana baza)

--c) (6 bodova) Kreirati upit kojim će se prikazati --ukupanbroj''proizvodapo''kategorijama. Korisnicima se
--treba ispisati o kojoj kategoriji se radi. Uslov je da --seprikažu''samoone''kategorije kojima pripada više
--od 30 proizvoda, te da nazivi proizvoda se sastoje od 3 riječi, -asadrže'broju'bilo''- kojoj od riječi i još
--uvijek se nalaze u prodaji. Također, ukupan broj -proizvodapo'kategorijamamora'biti''- veći od 50.
--(AdventureWorks2017)

--d) (7 bodova) Za potrebe menadžmenta kompanije potrebno je -kreiratiupit'kojimće'se''- prikazati proizvodi
--koji trenutno nisu u prodaji i ne pripada kategoriji bicikala, --kakobi''ihponovno''vratili u prodaju.
--Proizvodu se početkom i po prestanku prodaje zabilježi --datum.Osnovni''uslovza''ponovno povlačenje u
--prodaju je to da je ukupna prodana količina za svaki proizvod pojedinačno --bilaveć'''od 200 komada.
--Kao rezultat upita očekuju se podaci u formatu --npr.Laptop''300komitd.''(AdventureWorks2017)

--e) (7 bodova) Kreirati upit kojim će se --prikazatiidentifikacijski''brojnarudžbe,''spojeno ime i prezime kupca,
--te ukupna vrijednost narudžbe koju je kupac platio. Uslov je --daje''oddatuma''narudžbe do datuma
--isporuke proteklo manje dana od prosječnog broja dana koji --jebio''potrebanza''isporuku svih narudžbi.
--(AdventureWorks2017)
--30 bodova

--5.
--a) (9 bodova) Kreirati upit koji će prikazati one naslove --kojihje''ukupnoprodano''više od 30 komada a
--napisani su od strane autora koji su napisali 2 -ilivišedjela/'romana.U'rezultatima''- upita prikazati naslov
--i ukupnu prodanu količinu. (Pubs)

--b) (10 bodova) Kreirati upit koji će u % prikazati koliko --jenarudžbi''(odukupnog''broja kreiranih)
--isporučeno na svaku od teritorija pojedinačno. Npr --Australia20.2%,''Canada12.01%''itd. Vrijednosti
--dobijenih postotaka zaokružiti na dvije decimale --idodati'znak'%.''(AdventureWorks2017)

--c) (12 bodova) Kreirati upit koji će prikazati osobe koje --imajuredovne''prihodea''nemaju vanredne, i one
--koje imaju vanredne a nemaju redovne. Lista treba da sadrži --spojenoime''iprezime''osobe, grad i adresu
--stanovanja i ukupnu vrijednost ostvarenih prihoda -(zaredovne'koristitineto).'Pored''- navedenih podataka
--potrebno je razgraničiti kategorije u novom polju pod --nazivomOpis''nanačin''"ISKLJUČIVO
--VANREDNI" za one koji imaju samo vanredne prihode, ili "ISKLJUČIVO --REDOVNI"za''on''koji
--imaju samo redovne prihode. Konačne rezultate sortirati prema --opisuabecedno''ipo''ukupnoj vrijednosti
--ostvarenih prihoda u opadajućem redoslijedu. (prihodi)
--31 bod

--6. Dokument teorijski_ispit 14JUL23, preimenovati vašim brojem --indeksa,te''utom''dokumentu izraditi pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim --brojemindeksa''nprIB210001.sql,''teorijski dokument imenovan
--Vašim brojem indexa npr IB210001.docx upload-ovati ODVOJEDNO na ftpufolder'Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55