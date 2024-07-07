--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa. 
CREATE DATABASE ispit080922_1
GO
USE ispit080922_1
--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom: 
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Ime, 50 UNICODE karaktera (obavezan unos)
--• Prezime, 50 UNICODE karaktera (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE 
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
--• NazivKategorije, 50 UNICODE (obavezan unos)
CREATE TABLE Proizvodi
(
	ProizvodID INT PRIMARY KEY IDENTITY(1,1),
	Naziv NVARCHAR(50) NOT NULL,
	SifraProizvoda NVARCHAR(25) NOT NULL,
	Boja NVARCHAR(15),
	NazivKategorije NVARCHAR(50) NOT NULL
)

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
CREATE TABLE ZaglavljeNarudzbe
(
	NarudzbaID INT PRIMARY KEY IDENTITY(1,1),
	DatumNarudzbe DATETIME NOT NULL,
	DatumIsporuke DATETIME,
	KreditnaKarticaID INT,
	ImeKupca NVARCHAR(50) NOT NULL,
	PrezimeKupca NVARCHAR(50) NOT NULL,
	NazivGrada NVARCHAR(30) NOT NULL,
	ProdavacID INT CONSTRAINT FK_Prodavac FOREIGN KEY REFERENCES Prodavaci(ProdavacID),
	NacinIsporuke NVARCHAR(50) NOT NULL
)

--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)
CREATE TABLE DetaljiNaruzbe
(
	NarudzbaID INT NOT NULL CONSTRAINT FK_ZaglavljeNarudzbe
	FOREIGN KEY REFERENCES ZaglavljeNarudzbe(NarudzbaID),
	ProizvodID INT NOT NULL CONSTRAINT FK_Proizvodi 
	FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	Cijena MONEY NOT NULL,
	Kolicina SMALLINT NOT NULL,
	Popust MONEY NOT NULL,
	OpisSpecijalnePonude NVARCHAR(255) NOT NULL,
	DetaljiNarudzbeID INT PRIMARY KEY IDENTITY(1,1)
)

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
SET IDENTITY_INSERT Prodavaci ON
INSERT INTO Prodavaci(ProdavacID, Ime, Prezime, OpisPosla, EmailAdresa)
SELECT 
	sp.BusinessEntityID,
	p.FirstName,
	p.LastName,
	e.JobTitle,
	ea.EmailAddress
FROM AdventureWorks2017.Sales.SalesPerson AS sp
INNER JOIN AdventureWorks2017.HumanResources.Employee AS e
ON sp.BusinessEntityID=e.BusinessEntityID
INNER JOIN AdventureWorks2017.Person.Person AS p
ON e.BusinessEntityID=p.BusinessEntityID
INNER JOIN AdventureWorks2017.Person.EmailAddress AS ea
ON p.BusinessEntityID=ea.BusinessEntityID
SET IDENTITY_INSERT Prodavaci OFF

--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--3b) U tabelu Proizvodi dodati sve proizvode
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije
SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID, Naziv, SifraProizvoda, Boja, NazivKategorije)
SELECT
	p.ProductID,
	p.Name,
	p.ProductNumber,
	p.Color,
	pc.Name
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
SET IDENTITY_INSERT Proizvodi OFF

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
SET IDENTITY_INSERT ZaglavljeNarudzbe ON
INSERT INTO ZaglavljeNarudzbe(NarudzbaID, DatumNarudzbe, DatumIsporuke,
KreditnaKarticaID, ImeKupca, PrezimeKupca, NazivGrada, ProdavacID, NacinIsporuke)
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
FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON soh.CustomerID=c.CustomerID
INNER JOIN AdventureWorks2017.Person.Person AS p
ON c.PersonID=p.BusinessEntityID
INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
ON soh.ShipMethodID=sm.ShipMethodID
INNER JOIN AdventureWorks2017.Person.Address AS a
ON soh.ShipToAddressID=a.AddressID
SET IDENTITY_INSERT ZaglavljeNarudzbe OFF

--3d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude
INSERT INTO DetaljiNaruzbe(NarudzbaID, ProizvodID, Cijena, Kolicina, Popust, OpisSpecijalnePonude)
SELECT
	sod.SalesOrderID,
	sod.ProductID,
	sod.UnitPrice,
	sod.OrderQty,
	sod.UnitPriceDiscount,
	so.Description
FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod
INNER JOIN AdventureWorks2017.Sales.SpecialOffer AS so
ON sod.SpecialOfferID=so.SpecialOfferID

--4.
--a)(6 bodova) kreirati pogled v_detalji gdje je korisniku potrebno prikazati --identifikacijski broj narudzbe,
--spojeno ime i prezime kupca, grad isporuke, ukupna vrijednost narudzbe sa popustom i- -bez popusta, te u dodatnom polju informacija da li je narudzba placena karticom --("Placeno karticom" ili "Nije placeno karticom").
--Rezultate sortirati prema vrijednosti narudzbe sa popustom u opadajucem redoslijedu.
--OBAVEZNO kreirati testni slucaj.(Novokreirana baza)
--
GO
CREATE OR ALTER VIEW v_detalji
AS 
SELECT 
	zn.NarudzbaID,
	zn.ImeKupca, 
	zn.NazivGrada, 
	SUM(dn.Cijena*(1-dn.Popust)*dn.Kolicina) SaPopustom,
	SUM(dn.Cijena*dn.Kolicina) BezPopusta,
	IIF(zn.KreditnaKarticaID IS NULL, 'Nije placeno karticom', 'Placeno karticom') Kartica
FROM ZaglavljeNarudzbe AS zn
INNER JOIN DetaljiNaruzbe AS dn
ON zn.NarudzbaID=dn.NarudzbaID
GROUP BY zn.NarudzbaID, zn.ImeKupca, zn.NazivGrada,
IIF(zn.KreditnaKarticaID IS NULL, 'Nije placeno karticom', 'Placeno karticom')

SELECT * 
FROM v_detalji
ORDER BY SaPopustom DESC

--b)( 4 bodova) U kreiranoj bazi kreirati wproceduru sp_insert_ZaglavljeNarudzbe kojom- -ce se omoguciti kreiranje nove narudzbe. OBAVEZNO kreirati testni slucaj.--(Novokreirana baza).
--
GO
CREATE OR ALTER PROCEDURE sp_insert_ZaglavljeNarudzbe
(
	@DatumNarudzbe DATETIME,
	@DatumIsporuke DATETIME=NULL,
	@KreditnaKarticaID INT=NULL,
	@ImeKupca NVARCHAR(50),
	@PrezimeKupca NVARCHAR(50),
	@NazivGrada NVARCHAR(30),
	@ProdavacID INT,
	@NacinIsporuke NVARCHAR(50)
)
AS
BEGIN
	INSERT INTO ZaglavljeNarudzbe(DatumNarudzbe, DatumIsporuke, KreditnaKarticaID, ImeKupca, PrezimeKupca, NazivGrada, ProdavacID, NacinIsporuke)
	VALUES(@DatumNarudzbe, @DatumIsporuke, @KreditnaKarticaID, @ImeKupca, @PrezimeKupca, @NazivGrada, @ProdavacID, @NacinIsporuke)
END

SELECT * FROM ZaglavljeNarudzbe

EXEC sp_insert_ZaglavljeNarudzbe
	@DatumNarudzbe='2024-05-31 00:00:00.000',
	@DatumIsporuke=NULL,
	@KreditnaKarticaID=NULL,
	@ImeKupca='Beriz',
	@PrezimeKupca='Kabilovic',
	@NazivGrada='Zvornik',
	@ProdavacID=279,
	@NacinIsporuke='CARGO TRANSPORT 5'

--c)(6 bodova) Kreirati upit kojim ce se prikazati ukupan broj proizvoda po --kategorijama. Uslov je da se prikazu samo one kategorije kojima ne pripada vise od --30 proizvoda, a sadrze broj u bilo kojoj od rijeci i ne nalaze se u prodaji.--(AdventureWorks2017)
--
SELECT 
	pc.Name, 
	COUNT(p.ProductID) BrojProizvoda
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
WHERE p.SellEndDate IS NOT NULL
AND p.Name LIKE '%[0-9]%'
GROUP BY pc.Name
HAVING COUNT(p.ProductID)<=30

--d)(7 bodova) Kreirati upit koji ce prikazati uposlenike koji imaju iskustva( radilli- -su na jednom odjelu) a trenutno rade na marketing ili odjelu za nabavku. Osobama -po- prestanku rada na odjelu se upise podatak datuma prestanka rada.
--Rezultat upita treba prikazati ime i prezime uposlenika, odjel na kojem rade.
--(AdventureWorks2017)
--
SELECT 
	p.FirstName, 
	p.LastName, 
	d.Name Odjel
FROM AdventureWorks2017.HumanResources.Employee AS e
INNER JOIN AdventureWorks2017.HumanResources.EmployeeDepartmentHistory AS edh
ON e.BusinessEntityID=edh.BusinessEntityID
INNER JOIN AdventureWorks2017.HumanResources.Department AS d
ON edh.DepartmentID=d.DepartmentID
INNER JOIN AdventureWorks2017.Person.Person AS p
ON e.BusinessEntityID=p.BusinessEntityID
WHERE d.Name IN ('Marketing', 'Purchasing')
AND edh.EndDate IS NULL
GROUP BY p.FirstName, p.LastName, d.Name
HAVING COUNT(d.DepartmentID)>1

--e)(7 bodova) Kreirati upit kojim ce se prikazati proizvod koji je najvise dana bio u- -prodaji( njegova prodaja je prestala) a pripada kategoriji bicikala. Proizvodu se- -pocetkom i po prestanku prodaje biljezi datum.
--Ukoliko postoji vise proizvoda sa istim vremenskim periodom kao i prvi prikazati ih -u- rezultatima upita.
--(AdventureWorks2017)
--
SELECT TOP 1 WITH TIES 
	p.Name, 
	DATEDIFF(DAY, p.SellStartDate, p.SellEndDate) DanaUProdaji
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
WHERE pc.Name LIKE 'Bikes'
ORDER BY 2 DESC

--(30 bodova
--5.)
--
--a) (9 bodova) Prikazati nazive odjela na kojima TRENUTNO radi najmanje , odnosno --najvise uposlenika(AdventureWorks2017)
--
SELECT * FROM
(
	SELECT TOP 1 
		d.Name, 
		COUNT(e.BusinessEntityID) BrojUposlenika
	FROM AdventureWorks2017.HumanResources.Department AS d
	INNER JOIN AdventureWorks2017.HumanResources.EmployeeDepartmentHistory AS edh
	ON d.DepartmentID=edh.DepartmentID
	INNER JOIN AdventureWorks2017.HumanResources.Employee AS e
	ON edh.BusinessEntityID=e.BusinessEntityID
	GROUP BY d.Name
	ORDER BY 2 DESC
	)AS sq1,
(
	SELECT TOP 1 
		d.Name, 
		COUNT(e.BusinessEntityID) BrojUposlenika
	FROM AdventureWorks2017.HumanResources.Department AS d
	INNER JOIN AdventureWorks2017.HumanResources.EmployeeDepartmentHistory AS edh
	ON d.DepartmentID=edh.DepartmentID
	INNER JOIN AdventureWorks2017.HumanResources.Employee AS e
	ON edh.BusinessEntityID=e.BusinessEntityID
	GROUP BY d.Name
	ORDER BY 2 
	)AS sq2

--b)(10 bodova) Kreirati upit kojim ce se prikazati ukupan broj obradjenih narudzbi i --ukupnu vrijednost narudzbi sa popustom za svakog uposlenika pojedinacno, i to od --zadnje 30% kreiranih datumski kreiranih narudzbi. Rezultate sortirati prema -ukupnoj- vrijednosti u opadajucem redoslijedu.
--(AdventureWorks2017)
--
SELECT 
	e.BusinessEntityID, 
	COUNT(*) UkupanBrojNarudzbi, 
	SUM(soh.SubTotal) UkupnaVrijednostNaruzbi
FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
INNER JOIN AdventureWorks2017.Sales.SalesPerson AS sp
ON soh.SalesPersonID=sp.BusinessEntityID
INNER JOIN AdventureWorks2017.HumanResources.Employee AS e
ON sp.BusinessEntityID=e.BusinessEntityID
WHERE soh.OrderDate IN
	(SELECT TOP 30 PERCENT 
		soh1.OrderDate 
	 FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh1
	 ORDER BY soh1.OrderDate DESC)
GROUP BY e.BusinessEntityID
ORDER BY 3 DESC

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
SELECT
	a.au_id,
	a.au_fname + ' ' + a.au_lname ImePrezime,
	t.title,
	IIF(LEN(a.au_lname)=6, LEFT(a.au_lname, 4), 
	IIF(LEN(a.au_lname)=10, LEFT(a.au_lname, 6), LEFT(a.au_lname, 2)))
	+ LEFT(a.au_fname, 2)
	+ '/'
	+ IIF(RIGHT(a.zip, 1) BETWEEN 0 AND 5, RIGHT(a.zip, 2), LEFT(a.zip, 2))
	+ '/'
	+ REVERSE(a.state)
	+ SUBSTRING(a.phone, 5, 3) Sifra
	
FROM pubs.dbo.authors AS a
INNER JOIN pubs.dbo.titleauthor AS ta
ON a.au_id=ta.au_id
INNER JOIN pubs.dbo.titles AS t
ON ta.title_id=t.title_id

