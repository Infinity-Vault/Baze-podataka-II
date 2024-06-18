--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
CREATE DATABASE ispit140722_1
GO
USE ispit140722_1
--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Ime, 50 UNICODE (obavezan unos)
--• Prezime, 50 UNICODE (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE karaktera
CREATE TABLE Prodavaci
(
	ProdavacID INT PRIMARY KEY IDENTITY(1,1),
	Ime NVARCHAR(50) NOT NULL,
	Prezime NVARCHAR(50) NOT NULL,
	OpisPosla NVARCHAR(50) NOT NULL,
	EmailAdresa NVARCHAR(50)
)

--b) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivPodkategorije, 50 UNICODE (obavezan unos)
CREATE TABLE Proizvodi
(
	ProizvodID INT PRIMARY KEY IDENTITY(1,1),
	Naziv NVARCHAR(50) NOT NULL,
	SifraProizvoda NVARCHAR(25) NOT NULL,
	Boja NVARCHAR(15),
	NazivPodKategorije NVARCHAR(50) NOT NULL
)

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
CREATE TABLE ZaglavljeNarudzbe
(
	NarudzbaID INT PRIMARY KEY IDENTITY(1,1),
	DatumNarudzbe DATETIME NOT NULL,
	DatumIsporuke DATETIME,
	KreditnaKarticaID INT,
	ImeKupca NVARCHAR(50) NOT NULL,
	PrezimeKupca NVARCHAR(50) NOT NULL,
	NazivGradaIsporuke NVARCHAR(30) NOT NULL,
	ProdavacID INT CONSTRAINT FK_Prodavaci FOREIGN KEY REFERENCES Prodavaci(ProdavacID),
	NacinIsporuke NVARCHAR(50) NOT NULL
)


--d) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)
--**Jedan proizvod se može više puta naručiti, dok -jednanarudžba'možesadržavati'više''- proizvoda. U okviru jedne
--narudžbe jedan proizvod se može naručiti više puta.
CREATE TABLE DetaljiNarudzbe
(
	NarudzbaID INT NOT NULL CONSTRAINT FK_ZaglavljeNarudzbe 
	FOREIGN KEY REFERENCES ZaglavljeNarudzbe(NarudzbaID),
	ProizvodID INT NOT NULL CONSTRAINT FK_ProizvodD 
	FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	Cijena MONEY NOT NULL,
	Kolicina SMALLINT NOT NULL,
	Popust MONEY NOT NULL,
	OpisSpecijalnePonude NVARCHAR(255) NOT NULL,
	DetaljiNarudzbeID INT PRIMARY KEY IDENTITY(1,1)
)

--9 bodova
--3. Iz baze podataka AdventureWorks u svoju bazu podatakaprebacitisljedeće'podatke:
--a) U tabelu Prodavaci dodati sve prodavače
--• BusinessEntityID (SalesPerson) -> ProdavacID
--• FirstName (Person) -> Ime
--• LastName (Person) -> Prezime
--• JobTitle (Employee) -> OpisPosla
--• EmailAddress (EmailAddress) -> EmailAdresa
SET IDENTITY_INSERT Prodavaci ON
INSERT INTO Prodavaci(ProdavacID, Ime, Prezime, OpisPosla, EmailAdresa)
SELECT sp.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle, ea.EmailAddress
FROM AdventureWorks2017.Sales.SalesPerson AS sp
INNER JOIN AdventureWorks2017.HumanResources.Employee AS e
ON sp.BusinessEntityID=e.BusinessEntityID
INNER JOIN AdventureWorks2017.Person.Person AS p
ON e.BusinessEntityID=p.BusinessEntityID
INNER JOIN AdventureWorks2017.Person.EmailAddress AS ea
ON p.BusinessEntityID=ea.BusinessEntityID
SET IDENTITY_INSERT Prodavaci OFF

--b) U tabelu Proizvodi dodati sve proizvode
--• ProductID (Product)-> ProizvodID
--• Name (Product)-> Naziv
--• ProductNumber (Product)-> SifraProizvoda
--• Color (Product)-> Boja
--• Name (ProductSubategory) -> NazivPodkategorije
SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID, Naziv, SifraProizvoda, Boja, NazivPodKategorije)
SELECT
	p.ProductID,
	p.Name,
	p.ProductNumber,
	p.Color,
	ps.Name
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS ps
ON p.ProductSubcategoryID=ps.ProductSubcategoryID
SET IDENTITY_INSERT Proizvodi OFF

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
SET IDENTITY_INSERT ZaglavljeNarudzbe ON
INSERT INTO ZaglavljeNarudzbe(NarudzbaID, DatumNarudzbe, DatumIsporuke, KreditnaKarticaID, ImeKupca, PrezimeKupca, NazivGradaIsporuke, ProdavacID, NacinIsporuke)
SELECT
	soh.SalesOrderID,
	soh.OrderDate,
	soh.ShipDate,
	soh.CreditCardID,
	p.FirstName,
	p.LastName,
	a.City,
	soh.SalesPersonID,
	sm.Name
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
on c.PersonID=p.BusinessEntityID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON soh.CustomerID=c.CustomerID
INNER JOIN AdventureWorks2017.Person.Address AS a
ON a.AddressID=soh.ShipToAddressID
INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
ON sm.ShipMethodID=soh.ShipMethodID
SET IDENTITY_INSERT ZaglavljeNarudzbe OFF

--d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID (SalesOrderDetail)-> NarudzbaID
--• ProductID (SalesOrderDetail)-> ProizvodID
--• UnitPrice (SalesOrderDetail)-> Cijena
--• OrderQty (SalesOrderDetail)-> Kolicina
--• UnitPriceDiscount (SalesOrderDetail)-> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude
--10 bodova
INSERT INTO DetaljiNarudzbe(NarudzbaID, ProizvodID, Cijena, Kolicina, Popust, OpisSpecijalnePonude)
SELECT
	sod.SalesOrderID,
	sod.ProductID,
	sod.UnitPrice,
	sod.OrderQty,
	sod.UnitPriceDiscount,
	so.Description
FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod
INNER JOIN AdventureWorks2017.Sales.SpecialOfferProduct AS sop
ON sod.SpecialOfferID=sop.SpecialOfferID
INNER JOIN AdventureWorks2017.Sales.SpecialOffer AS so
ON sop.SpecialOfferID=so.SpecialOfferID

SELECT * FROM DetaljiNarudzbe

--4.
--a) (6 bodova) Kreirati funkciju f_detalji u formi --tabelegdje''korisnikuslanjem''parametra identifikacijski
--broj narudžbe će biti ispisano spojeno ime i prezime --kupca,grad''isporuke,ukupna''vrijednost narudžbe
--sa popustom, te poruka da li je narudžba plaćena karticom --iline.''Korisnikmože''dobiti 2 poruke „Plaćeno
--karticom“ ili „Nije plaćeno karticom“.
--OBAVEZNO kreirati testni slučaj. (Novokreirana baza)
GO
CREATE FUNCTION f_detalji 
(
	@NarudzbaID INT
)
RETURNS TABLE
AS
RETURN
SELECT
	ZN.ImeKupca + ' ' + ZN.PrezimeKupca ImePrezime,
	ZN.NazivGradaIsporuke,
	SUM(dn.Cijena*(1-dn.Popust)*dn.Kolicina) UkupnaVrijednost,
	IIF(zn.KreditnaKarticaID IS NULL, 'nije kartica', 'kartica') PlacenoKarticom
FROM ZaglavljeNarudzbe AS ZN
INNER JOIN DetaljiNarudzbe AS DN
ON ZN.NarudzbaID=DN.NarudzbaID
WHERE ZN.NarudzbaID=@NarudzbaID
GROUP BY ZN.ImeKupca + ' ' + ZN.PrezimeKupca, ZN.NazivGradaIsporuke,
IIF(zn.KreditnaKarticaID IS NULL, 'nije kartica', 'kartica')

SELECT *
FROM f_detalji(43659)

--b) (4 bodova) U kreiranoj bazi -kreiratiproceduru'sp_insert_DetaljiNarudzbekojom'će''- se omogućiti insert
--nove stavke narudžbe. OBAVEZNO kreirati testni slučaj. (Novokreirana baza)
GO
CREATE PROCEDURE sp_insert_DetaljiNarudzbe
(
	@NarudzbaID INT,
	@ProizvodID INT,
	@Cijena MONEY,
	@Kolicina SMALLINT,
	@Popust MONEY,
	@OpisSpecijalnePonude NVARCHAR(255)
)
AS
BEGIN
INSERT INTO DetaljiNarudzbe
VALUES(@NarudzbaID, @ProizvodID, @Cijena, @Kolicina, @Popust, @OpisSpecijalnePonude)
END

EXEC sp_insert_DetaljiNarudzbe 	@NarudzbaID=45165, @ProizvodID=778, @Cijena=10, @Kolicina=5, @Popust=0.1, @OpisSpecijalnePonude='Neki opis'

--c) (6 bodova) Kreirati upit kojim će se prikazati --ukupanbroj''proizvodapo''kategorijama. Korisnicima se
--treba ispisati o kojoj kategoriji se radi. Uslov je da --seprikažu''samoone''kategorije kojima pripada više
--od 30 proizvoda, te da nazivi proizvoda se sastoje od 3 riječi, -asadrže'broju'bilo''- kojoj od riječi i još
--uvijek se nalaze u prodaji. Također, ukupan broj -proizvodapo'kategorijamamora'biti''- veći od 50.
--(AdventureWorks2017)
SELECT pc.Name Kategorija, COUNT(p.ProductID) UkupanBrojProizvoda
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN  AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
WHERE LEN(p.Name)-LEN(REPLACE(p.Name, ' ', ''))=2
AND p.Name LIKE '%[0-9]%' AND p.SellEndDate IS NOT NULL
GROUP BY pc.Name
HAVING COUNT(p.ProductID)>30

--d) (7 bodova) Za potrebe menadžmenta kompanije potrebno je -kreiratiupit'kojimće'se''- prikazati proizvodi
--koji trenutno nisu u prodaji i ne pripada kategoriji bicikala, --kakobi''ihponovno''vratili u prodaju.
--Proizvodu se početkom i po prestanku prodaje zabilježi --datum.Osnovni''uslovza''ponovno povlačenje u
--prodaju je to da je ukupna prodana količina za svaki proizvod pojedinačno --bilaveć'''od 200 komada.
--Kao rezultat upita očekuju se podaci u formatu --npr.Laptop''300komitd.''(AdventureWorks2017)
SELECT p.Name, CAST(SUM(sod.OrderQty) AS NVARCHAR) + ' kom'
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
ON p.ProductID=sod.ProductID
WHERE p.SellEndDate IS NOT NULL AND p.Name NOT LIKE 'Bikes'
GROUP BY p.Name
HAVING SUM(sod.OrderQty)>200

--e) (7 bodova) Kreirati upit kojim će se --prikazatiidentifikacijski''brojnarudžbe,''spojeno ime i prezime kupca,
--te ukupna vrijednost narudžbe koju je kupac platio. Uslov je --daje''oddatuma''narudžbe do datuma
--isporuke proteklo manje dana od prosječnog broja dana koji --jebio''potrebanza''isporuku svih narudžbi.
--(AdventureWorks2017)
--30 bodova
SELECT soh.SalesOrderID, p.FirstName + ' ' + p.LastName,
SUM(soh.TotalDue) UkupnaVrijednost
FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON soh.CustomerID=c.CustomerID
INNER JOIN AdventureWorks2017.Person.Person AS p
ON c.PersonID=p.BusinessEntityID
WHERE DATEDIFF(DAY, soh.OrderDate, soh.ShipDate)<
(SELECT AVG(DATEDIFF(DAY, soh1.OrderDate, soh1.ShipDate)) FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh1)
GROUP BY soh.SalesOrderID, p.FirstName + ' ' + p.LastName

--5.
--a) (9 bodova) Kreirati upit koji će prikazati one naslove --kojihje''ukupnoprodano''više od 30 komada a
--napisani su od strane autora koji su napisali 2 -ilivišedjela/'romana.U'rezultatima''- upita prikazati naslov
--i ukupnu prodanu količinu. (Pubs)
SELECT t.title, SUM(s.qty)
FROM pubs.dbo.titles AS t
INNER JOIN pubs.dbo.titleauthor AS ta
ON t.title_id=ta.title_id
INNER JOIN pubs.dbo.authors AS a
ON ta.au_id=a.au_id
INNER JOIN pubs.dbo.sales AS s
ON t.title_id=s.title_id
WHERE t.title_id IN 
	(SELECT * 
	 FROM )
GROUP BY t.title
HAVING SUM(s.qty)>30

--b) (10 bodova) Kreirati upit koji će u % prikazati koliko --jenarudžbi''(odukupnog''broja kreiranih)
--isporučeno na svaku od teritorija pojedinačno. Npr --Australia20.2%,''Canada12.01%''itd. Vrijednosti
--dobijenih postotaka zaokružiti na dvije decimale --idodati'znak'%.''(AdventureWorks2017)
SELECT sq1.Name, sq1.UkupanBrojNarudzbi,
ROUND(sq1.UkupanBrojNarudzbi*1.0/(SELECT COUNT(*) FROM AdventureWorks2017.Sales.SalesOrderHeader)*100, 2) Procenat
FROM
(SELECT st.Name, COUNT(*) UkupanBrojNarudzbi
FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
INNER JOIN AdventureWorks2017.Sales.SalesTerritory AS st
ON soh.TerritoryID=st.TerritoryID
GROUP BY st.Name) AS sq1

--c) (12 bodova) Kreirati upit koji će prikazati osobe koje --imajuredovne''prihodea''nemaju vanredne, i one
--koje imaju vanredne a nemaju redovne. Lista treba da sadrži --spojenoime''iprezime''osobe, grad i adresu
--stanovanja i ukupnu vrijednost ostvarenih prihoda -(zaredovne'koristitineto).'Pored''- navedenih podataka
--potrebno je razgraničiti kategorije u novom polju pod --nazivomOpis''nanačin''"ISKLJUČIVO
--VANREDNI" za one koji imaju samo vanredne prihode, ili "ISKLJUČIVO --REDOVNI"za''on''koji
--imaju samo redovne prihode. Konačne rezultate sortirati prema --opisuabecedno''ipo''ukupnoj vrijednosti
--ostvarenih prihoda u opadajućem redoslijedu. (prihodi)
--31 bod
SELECT * FROM
(
SELECT * FROM
(SELECT o.Ime + ' ' + o.PrezIme ImePrezime, g.Grad,
o.Adresa, SUM(rp.Neto) UkupniPrihodi,
'ISKLJUCIVO REDOVNI' Opis
FROM prihodi.dbo.Osoba AS o
INNER JOIN prihodi.dbo.RedovniPrihodi AS rp
ON o.OsobaID=rp.OsobaID
INNER JOIN prihodi.dbo.Grad AS g
ON o.GradID=g.GradID
WHERE o.OsobaID NOT IN 
	(SELECT vp.OsobaID
	FROM prihodi.dbo.VanredniPrihodi AS vp WHERE vp.OsobaID IS NOT NULL)
GROUP BY o.Ime + ' ' + o.PrezIme, g.Grad, o.Adresa) AS r
UNION
SELECT * FROM
(SELECT o.Ime + ' ' + o.PrezIme ImePrezime, g.Grad, 
o.Adresa, SUM(vp.IznosVanrednogPrihoda) UkupniPrihodi,
'ISKLJUCIVO VANREDNI' Opis
FROM prihodi.dbo.Osoba AS o
INNER JOIN prihodi.dbo.VanredniPrihodi AS vp
ON o.OsobaID=vp.OsobaID
INNER JOIN prihodi.dbo.Grad AS g
ON o.GradID=g.GradID
WHERE o.OsobaID NOT IN 
	(SELECT rp.OsobaID
	FROM prihodi.dbo.RedovniPrihodi AS rp WHERE rp.OsobaID IS NOT NULL)
GROUP BY o.Ime + ' ' + o.PrezIme, g.Grad, o.Adresa) AS v
) AS sve
ORDER BY sve.Opis, sve.UkupniPrihodi DESC

--6. Dokument teorijski_ispit 14JUL23, preimenovati vašim brojem --indeksa,te''utom''dokumentu izraditi pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim --brojemindeksa''nprIB210001.sql,''teorijski dokument imenovan
--Vašim brojem indexa npr IB210001.docx upload-ovati ODVOJEDNO na ftpufolder'Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55