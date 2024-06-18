--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
CREATE DATABASE ispit290622_1
GO
USE ispit290622_1

--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)
--• Tezina, decimalna vrijednost sa 2 znaka iza zareza
CREATE TABLE Proizvodi
(
	ProizvodID INT PRIMARY KEY IDENTITY(1,1),
	Naziv NVARCHAR(50) NOT NULL,
	SifraProizvoda NVARCHAR(50) NOT NULL,
	Boja NVARCHAR(15),
	NazivKategorije NVARCHAR(50) NOT NULL,
	Tezina DECIMAL(18, 2)
)

--b) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivTeritorije, 50 UNICODE (obavezan unos)
--• NazivRegije, 50 UNICODE (obavezan unos)
--• NacinIsporuke, 50 UNICODE (obavezan unos)
CREATE TABLE ZaglavljeNarudzbe
(
	NarudzbaID INT PRIMARY KEY IDENTITY(1,1),
	DatumNarudzbe DATETIME NOT NULL,
	DatumIsporuke DATETIME,
	ImeKupca NVARCHAR(50) NOT NULL,
	PrezimeKupca NVARCHAR(50) NOT NULL,
	NazivTeritorije NVARCHAR(50) NOT NULL,
	NazivRegije NVARCHAR(50) NOT NULL,
	NacinIsporuke NVARCHAR(50) NOT NULL
)

--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
CREATE TABLE DetaljiNarudzbe
(
	DetaljiNarudzbeID INT PRIMARY KEY IDENTITY(1,1),
	NarudzbaID INT CONSTRAINT FK_ZaglavljeNarudzbe 
	FOREIGN KEY REFERENCES ZaglavljeNarudzbe(NarudzbaID) NOT NULL,
	ProizvodID INT CONSTRAINT FK_Proizvodi 
	FOREIGN KEY REFERENCES Proizvodi(ProizvodID) NOT NULL,
	Cijena MONEY NOT NULL,
	Kolicina SMALLINT NOT NULL,
	Popust MONEY NOT NULL
)

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
SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID, Naziv, SifraProizvoda, Boja, NazivKategorije,
	Tezina)
SELECT 
	p.ProductID, 
	p.Name, 
	p.ProductNumber, 
	p.Color, 
	pc.Name, 
	ISNULL(p.Weight, 0)
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS ps
ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON ps.ProductCategoryID=pc.ProductCategoryID
SET IDENTITY_INSERT Proizvodi OFF

--b) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• Name (SalesTerritory) -> NazivTeritorije
--• Group (SalesTerritory) -> NazivRegije
--• Name (ShipMethod) -> NacinIsporuke
SET IDENTITY_INSERT ZaglavljeNarudzbe ON
INSERT INTO ZaglavljeNarudzbe(NarudzbaID, DatumNarudzbe, DatumIsporuke, ImeKupca,
	PrezimeKupca, NazivTeritorije, NazivRegije, NacinIsporuke)
SELECT 
	soh.SalesOrderID,
	soh.OrderDate,
	soh.ShipDate,
	p.FirstName,
	p.LastName,
	st.Name,
	st.[Group],
	sm.Name
FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON soh.CustomerID=c.CustomerID
INNER JOIN AdventureWorks2017.Person.Person AS p
ON c.PersonID=p.BusinessEntityID
INNER JOIN AdventureWorks2017.Sales.SalesTerritory AS st
ON soh.TerritoryID=st.TerritoryID
INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
ON soh.ShipMethodID=sm.ShipMethodID
SET IDENTITY_INSERT ZaglavljeNarudzbe OFF

--c) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust
--8 bodova

INSERT INTO DetaljiNarudzbe(NarudzbaID, ProizvodID, Cijena, Kolicina, Popust)
SELECT
	sod.SalesOrderID,
	sod.ProductID,
	sod.UnitPrice,
	sod.OrderQty,
	sod.UnitPriceDiscount
FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod

--4.
--a) (6 bodova) Kreirati upit koji će prikazati ukupan broj uposlenika po odjelima. --Potrebno je prebrojati
--samo one uposlenike koji su trenutno aktivni, odnosno rade na datom odjelu. Također, -samo- uzeti u obzir
--one uposlenike koji imaju više od 10 godina radnog staža (ne uključujući graničnu --vrijednost). Rezultate
--sortirati preba broju uposlenika u opadajućem redoslijedu. (AdventureWorks2017)
SELECT d.Name Odjel, COUNT(e.BusinessEntityID) BrojUposlenikaPoOdjelu
FROM AdventureWorks2017.HumanResources.Department AS d
INNER JOIN AdventureWorks2017.HumanResources.EmployeeDepartmentHistory  AS edh
ON d.DepartmentID=edh.DepartmentID
INNER JOIN AdventureWorks2017.HumanResources.Employee AS e
ON edh.BusinessEntityID=e.BusinessEntityID
WHERE DATEDIFF(YEAR, e.HireDate, GETDATE())>10 AND edh.EndDate IS NULL
GROUP BY d.Name
ORDER BY 2 DESC

--b) (10 bodova) Kreirati upit koji prikazuje po mjesecima ukupnu vrijednost poručene robe- -za skladište, te
--ukupnu količinu primljene robe, isključivo u 2012 godini. Uslov je da su troškovi -prevoza- bili između
--500 i 2500, a da je dostava izvršena CARGO transportom. Također u rezultatima upita je --potrebno
--prebrojati stavke narudžbe na kojima je odbijena količina veća od 100. --(AdventureWorks2017)
SELECT MONTH(poh.OrderDate) Mjesec, SUM(pod.LineTotal) UkupnaVrijednost, 
SUM(pod.OrderQty) PorucenaKolicina,
SUM(pod.ReceivedQty) PrimljenaKolicina,
SUM(IIF(pod.RejectedQty>100,1,0)) OdbijenaKolicinaVecaOdSto
FROM AdventureWorks2017.Purchasing.PurchaseOrderHeader AS poh
INNER JOIN AdventureWorks2017.Purchasing.PurchaseOrderDetail AS pod
ON poh.PurchaseOrderID=pod.PurchaseOrderID
INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
ON poh.ShipMethodID=sm.ShipMethodID
WHERE YEAR(poh.OrderDate)=2012 AND sm.Name LIKE '%CARGO%'
AND poh.Freight BETWEEN 500 AND 2500
GROUP BY MONTH(poh.OrderDate)

--c) (10 bodova) Prikazati ukupan broj narudžbi koje su obradili uposlenici, za svakog --uposlenika
--pojedinačno. Uslov je da su narudžbe kreirane u 2011 ili 2012 godini, te da je u okviru --jedne narudžbe
--odobren popust na dvije ili više stavki. Također uzeti u obzir samo one narudžbe koje su- -isporučene u
--Veliku Britaniju, Kanadu ili Francusku. (AdventureWorks2017)
SELECT e.BusinessEntityID, COUNT(*) BrojNarudzbi
FROM AdventureWorks2017.HumanResources.Employee AS e
INNER JOIN AdventureWorks2017.Sales.SalesPerson AS sp
ON e.BusinessEntityID=sp.BusinessEntityID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON sp.BusinessEntityID=soh.SalesPersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
ON soh.SalesOrderID=sod.SalesOrderID
INNER JOIN AdventureWorks2017.Sales.SalesTerritory AS st
ON soh.TerritoryID=st.TerritoryID
WHERE YEAR(soh.OrderDate) IN (2011, 2012) 
AND st.Name IN ('United Kingdom', 'Canada', 'France')
AND (SELECT COUNT(*) FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod1
	 WHERE sod1.SalesOrderID=soh.SalesOrderID AND sod1.UnitPriceDiscount>0)>=2
GROUP BY e.BusinessEntityID

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
SELECT p.ProductName, s.CompanyName, p.UnitsInStock,
LEFT(p.ProductName, 2) + '/' +  SUBSTRING(s.CompanyName, CHARINDEX(' ', s.CompanyName)+1, 2) + 
IIF(LEN(p.ProductID)=1, CAST(p.ProductID AS NVARCHAR) + 'a', REVERSE(p.ProductID))
SifraProizvoda
FROM Northwind.dbo.Products AS p
INNER JOIN Northwind.dbo.Suppliers AS s
ON p.SupplierID=s.SupplierID
WHERE LEN(s.CompanyName) - LEN(REPLACE(s.CompanyName, ' ', '')) IN (1, 2)
--5.
--a) (3 boda) U kreiranoj bazi kreirati index kojim će se ubrzati pretraga prema šifri i --nazivu proizvoda.
--Napisati upit za potpuno iskorištenje indexa.
CREATE INDEX ix_pretraga_proizvoda ON Proizvodi (SifraProizvoda, Naziv)

SELECT * 
FROM Proizvodi
WHERE SifraProizvoda LIKE 'F%' AND Naziv LIKE 'H%'

--b) (7 bodova) U kreiranoj bazi kreirati proceduru sp_search_products kojom će se vratiti- -podaci o
--proizvodima na osnovu kategorije kojoj pripadaju ili težini. Korisnici ne moraju unijeti- -niti jedan od
--parametara ali u tom slučaju procedura ne vraća niti jedan od zapisa. Korisnicima unosom- -već prvog
--slova kategorije se trebaju osvježiti zapisi, a vrijednost unesenog parametra težina će --vratiti one
--proizvode čija težina je veća od unesene vrijednosti.
GO
CREATE PROCEDURE sp_search_products
(
	@Kategorija NVARCHAR(50)=NULL,
	@Tezina DECIMAL(18, 2)=NULL
)
AS
BEGIN
SELECT * 
FROM Proizvodi AS p
WHERE p.NazivKategorije LIKE @Kategorija + '%' OR 
p.Tezina>@Tezina
END

EXEC sp_search_products 'Clo'
EXEC sp_search_products @Tezina=2.2

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
SELECT * FROM
(
SELECT * FROM
(SELECT TOP 1 *
FROM
(SELECT TOP 3 p.FirstName, p.LastName, SUM(soh.TotalDue) Vrijednost,
'stoni mikser' Nagrada
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON p.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON c.CustomerID=soh.CustomerID
WHERE MONTH(soh.OrderDate)=4 AND YEAR(soh.OrderDate)=2013
AND RIGHT(p.FirstName, 1)='a'
GROUP BY p.FirstName, p.LastName
ORDER BY 3 DESC) as zeneApril
ORDER BY zeneApril.Vrijednost) AS sq1
UNION
SELECT * FROM
(SELECT TOP 1 *
FROM
(SELECT TOP 3 p.FirstName, p.LastName, SUM(soh.TotalDue) Vrijednost,
'usisivac' Nagrada
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON p.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON c.CustomerID=soh.CustomerID
WHERE MONTH(soh.OrderDate)=4 AND YEAR(soh.OrderDate)=2013
AND RIGHT(p.FirstName, 1) NOT LIKE 'a'
GROUP BY p.FirstName, p.LastName
ORDER BY 3 DESC) as muskiApril
ORDER BY muskiApril.Vrijednost) AS sq2
UNION
SELECT * FROM
(SELECT TOP 1 *
FROM
(SELECT TOP 3 p.FirstName, p.LastName, SUM(soh.TotalDue) Vrijednost,
'pegla' Nagrada
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON p.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON c.CustomerID=soh.CustomerID
WHERE MONTH(soh.OrderDate)=5 AND YEAR(soh.OrderDate)=2013
AND RIGHT(p.FirstName, 1)='a'
GROUP BY p.FirstName, p.LastName
ORDER BY 3 DESC) as zeneMaj
ORDER BY zeneMaj.Vrijednost) AS sq3
UNION
SELECT * FROM
(SELECT TOP 1 *
FROM
(SELECT TOP 3 p.FirstName, p.LastName, SUM(soh.TotalDue) Vrijednost,
'multicooker' Nagrada
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON p.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON c.CustomerID=soh.CustomerID
WHERE MONTH(soh.OrderDate)=5 AND YEAR(soh.OrderDate)=2013
AND RIGHT(p.FirstName, 1) NOT LIKE 'a'
GROUP BY p.FirstName, p.LastName
ORDER BY 3 DESC) as muskiMaj
ORDER BY muskiMaj.Vrijednost) AS sq4
)
AS finalq
ORDER BY finalq.Vrijednost DESC

--6. Dokument teorijski_ispit 29JUN22, preimenovati vašim brojem indeksa, te u tom --dokumentu izraditi
--pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem indeksa npr IB200001.sql, --teorijski dokument imenovan
--Vašim brojem indexa npr IB200001.docx upload-ovati ODVOJEDNO na ftp u folder Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55
