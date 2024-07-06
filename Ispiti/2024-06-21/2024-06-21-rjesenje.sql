--1. Kroz SQL kod kreirati bazu podataka sa imenom vaseg broja indeksa
CREATE DATABASE ispit21062024_1
GO
USE ispit21062024_1
--2. U kreiranoj bazi podataka kreirati tabele sa sljedecom strukturom:
--a)	Uposlenici
--•	UposlenikID, cjelobrojni tip i primarni kljuc, autoinkrement,
--•	Ime 10 UNICODE karaktera obavezan unos,
--•	Prezime 20 UNICODE karaktera obavezan unos
--•	DatumRodjenja polje za unos datuma i vremena obavezan unos
--•	UkupanBrojTeritorija, cjelobrojni tip
CREATE TABLE Uposlenici
(
	UposlenikID INT PRIMARY KEY IDENTITY(1,1),
	Ime NVARCHAR(10) NOT NULL,
	Prezime NVARCHAR(20) NOT NULL,
	DatumRodjenja DATETIME NOT NULL,
	UkupanBrojTeritorija INT
)

--b)	Narudzbe
--•	NarudzbaID, cjelobrojni tip i primarni kljuc, autoinkrement
--•	UposlenikID, cjelobrojni tip, strani kljuc,
--•	DatumNarudzbe, polje za unos datuma i vremena,
--•	ImeKompanijeKupca, 40 UNICODE karaktera,
--•	AdresaKupca, 60 UNICODE karaktera
CREATE TABLE Narudzbe
(
	NarudzbaID INT PRIMARY KEY IDENTITY(1,1),
	UposlenikID INT CONSTRAINT FK_Uposlenici FOREIGN KEY 
	REFERENCES Uposlenici(UposlenikID),
	DatumNarudzbe DATETIME,
	ImeKompanijeKupca NVARCHAR(40),
	AdresaKupca NVARCHAR(60)
)

--c) Proizvodi
--•	ProizvodID, cjelobrojni tip i primarni ključ, auloinkrement
--•	NazivProizvoda, 40 UNICODE karaktera (obavezan unos)
--•	NazivKompanijeDobavljaca, 40 UNICODE karaktcra
--•	NazivKategorije, 15 UNICODE karaktera
CREATE TABLE Proizvodi
(
	ProizvodID INT PRIMARY KEY IDENTITY(1,1),
	NazivProizvoda NVARCHAR(40) NOT NULL,
	NazivKompanijeDobavljaca NVARCHAR(40) NOT NULL,
	NazivKategorije NVARCHAR(15)
)

--d) StavkeNarudzbe
--•	NarudzbalD, cjelobrojni tip strani i primami ključ
--•	ProizvodlD, cjelobrojni tip strani i primami ključ
--•	Cijena, novčani tip (obavezan unos)
--•	Kolicina, kratki cjelobrojni tip (obavezan unos)
--•	Popust, real tip podatka (obavezan unos)
CREATE TABLE StavkeNarudzbe
(
	NarudzbaID INT CONSTRAINT FK_Narudzbe FOREIGN KEY
	REFERENCES Narudzbe(NarudzbaID),
	ProizvodID INT CONSTRAINT FK_Proizvodi FOREIGN KEY
	REFERENCES Proizvodi(ProizvodID),
	Cijena MONEY NOT NULL,
	Kolicina SMALLINT NOT NULL,
	Popust REAL NOT NULL
	CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY(NarudzbaID, ProizvodID)
)

--4 boda

--3. Iz baze podataka Northwind u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Uposlenici dodati sve uposlenike
--•	EmployeelD -> UposlenikID
--•	FirstName -> Ime
--•	LastName -> Prezime
--•	BirthDate -> DatumRodjenja
--•	lzračunata vrijednost za svakog uposlenika na osnovu EmployeeTerritories-:----UkupanBrojTeritorija
SET IDENTITY_INSERT Uposlenici ON
INSERT INTO Uposlenici(UposlenikID, Ime, Prezime, DatumRodjenja, UkupanBrojTeritorija)
SELECT
	e.EmployeeID,
	e.FirstName,
	e.LastName,
	e.BirthDate,
	COUNT(et.TerritoryID)
FROM Northwind.dbo.Employees AS e
INNER JOIN Northwind.dbo.EmployeeTerritories AS et
ON e.EmployeeID=et.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.BirthDate
SET IDENTITY_INSERT Uposlenici OFF

--b) U tabelu Narudzbe dodati sve narudzbe
--•	OrderlD -> NarudzbalD
--•	EmployeelD -> UposlenikID
--•	OrderDate -> DatumNarudzbe
--•	CompanyName -> ImeKompanijeKupca
--•	Address -> AdresaKupca
SET IDENTITY_INSERT Narudzbe ON
INSERT INTO Narudzbe(NarudzbaID, UposlenikID, DatumNarudzbe, ImeKompanijeKupca, AdresaKupca)
SELECT
	o.OrderID,
	o.EmployeeID,
	o.OrderDate,
	c.CompanyName,
	c.Address
FROM Northwind.dbo.Orders AS o
INNER JOIN Northwind.dbo.Customers AS c
ON o.CustomerID=c.CustomerID
SET IDENTITY_INSERT Narudzbe OFF

--c) U tabelu Proizvodi dodati sve proizvode
--•	ProductID -> ProizvodlD
--•	ProductName -> NazivProizvoda
--•	CompanyName -> NazivKompanijeDobavljaca
--•	CategoryName -> NazivKategorije
SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID, NazivProizvoda, NazivKompanijeDobavljaca, NazivKategorije)
SELECT
	p.ProductID,
	p.ProductName,
	s.CompanyName,
	c.CategoryName
FROM Northwind.dbo.Products AS p
INNER JOIN Northwind.dbo.Suppliers AS s
ON p.SupplierID=s.SupplierID
INNER JOIN Northwind.dbo.Categories AS c
ON p.CategoryID=c.CategoryID
SET IDENTITY_INSERT Proizvodi OFF

--d) U tabelu StavkeNarudzbe dodati sve stavke narudzbe
--•	OrderlD -> NarudzbalD
--•	ProductID -> ProizvodlD
--•	UnitPrice -> Cijena
--•	Quantity -> Kolicina
--•	Discount -> Popust
INSERT INTO StavkeNarudzbe(NarudzbaID, ProizvodID, Cijena, Kolicina, Popust)
SELECT
	od.OrderID,
	od.ProductID,
	od.UnitPrice,
	od.Quantity,
	od.Discount
FROM Northwind.dbo.[Order Details] AS od

--5 bodova

--4. 
--a) (4 boda) U tabelu StavkeNarudzbe dodati 2 nove izračunate kolone: vrijednostNarudzbeSaPopustom i vrijednostNarudzbeBezPopusta. Izzačunate kolonc već čuvaju podatke na osnovu podataka iz kolona! 
ALTER TABLE StavkeNarudzbe
ADD vrijednostNarudzbeSaPopustom AS Cijena*(1-Popust)*Kolicina

ALTER TABLE StavkeNarudzbe
ADD vrijednostNarudzbeBezPopusta AS Cijena*Kolicina

--b) (5 bodom) Kreirati pogled v_select_orders kojim ćc se prikazati ukupna zarada po uposlenicima od narudzbi kreiranih u zadnjem kvartalu 1996. godine. Pogledom je potrebno prikazati spojeno ime i prezime uposlenika, ukupna zarada sa popustom zaokrzena na dvije decimale i ukupna zarada bez popusta. Za prikaz ukupnih zarada koristiti OBAVEZNO koristiti izračunate kolone iz zadatka 4a. (Novokreirana baza)
GO
CREATE VIEW v_select_orders
AS
SELECT 
	CONCAT(u.Ime, ' ', u.Prezime) ImePrezime,
	ROUND(SUM(sn.vrijednostNarudzbeSaPopustom),2) UkupnaZaradaSaPopustom,
	SUM(sn.vrijednostNarudzbeBezPopusta) UkupnaZaradaBezPopusta
FROM StavkeNarudzbe AS sn
INNER JOIN Narudzbe AS n
ON sn.NarudzbaID=n.NarudzbaID
INNER JOIN Uposlenici AS u
ON n.UposlenikID=u.UposlenikID
WHERE YEAR(n.DatumNarudzbe)=1996 AND MONTH(n.DatumNarudzbe) IN (10, 11, 12)
GROUP BY CONCAT(u.Ime, ' ', u.Prezime)

--c) (5 boda) Kreirati funkciju f_starijiUposleici koja će vraćati podatke u formi tabele na osnovu proslijedjenog parametra godineStarosti, cjelobrojni tip. Funkcija će vraćati one zapise u kojima su godine starosti kod uposlenika veće od unesene vrijednosti parametra. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalaze sve kolone tabele uposlenici, zajedno sa izračunatim godinama starosti. Provjeriti ispravnost funkcije unošenjem kontrolnih vrijednosti. (Novokreirana baza) 
GO
CREATE FUNCTION f_starijiUposlenici
(
	@godineStarosti INT
)
RETURNS TABLE
AS
RETURN
SELECT
	u.UposlenikID, 
	u.Ime, 
	u.Prezime, 
	u.DatumRodjenja, 
	u.UkupanBrojTeritorija,
	DATEDIFF(YEAR, u.DatumRodjenja, GETDATE()) Starost
FROM Uposlenici AS u
WHERE DATEDIFF(YEAR, u.DatumRodjenja, GETDATE()) > @godineStarosti

SELECT*
FROM f_starijiUposlenici(72)

--d) (7 bodova) Pronaći najprodavaniji proizvod u 2011 godini. Ulogu najprodavanijeg nosi onaj kojeg je najveći broj komada prodat. (AdventureWorks2017)
SELECT TOP 1 
	sod.ProductID, 
	SUM(sod.OrderQty) ProdanaKolicina
FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON sod.SalesOrderID=soh.SalesOrderID
WHERE YEAR(soh.OrderDate)=2011
GROUP BY sod.ProductID
ORDER BY SUM(sod.OrderQty) DESC

--e) (6 bodova) Prikazati ukupan broj proizvoda prema specijalnim ponudama. Potrebno je prebrojati samo one proizvode koji pripadaju kategoriji odjeće. (AdventureWorks2017) 
SELECT 
	sp.SpecialOfferID, 
	COUNT(p.ProductID) BrojProizvoda
FROM AdventureWorks2017.Sales.SpecialOfferProduct AS sp
INNER JOIN AdventureWorks2017.Production.Product AS p
ON sp.ProductID=p.ProductID
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
WHERE pc.Name LIKE 'Clothing'
GROUP BY sp.SpecialOfferID

--f) (8 bodova) Prikazati najskuplji proizvod (List Price) u svakoj kategoriji. (AdventureWorks2017) 
SELECT 
	pc.Name, 
	MAX(p.ListPrice) NajvecaCijena
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
GROUP BY pc.Name

--g) (8 bodova) Prikazati proizvode čija je maloprodajna cijena (List Price) manja od prosječne maloprodajne cijene kategorije proizvoda kojoj pripada. (AdventureWorks2017) 
SELECT
	p.Name
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
WHERE p.ListPrice < 
(
	SELECT AVG(p1.ListPrice)
	FROM AdventureWorks2017.Production.Product AS p1
	INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc2
	ON p1.ProductSubcategoryID=psc2.ProductSubcategoryID
	WHERE psc2.ProductCategoryID=psc.ProductCategoryID
)

--43 boda

--5. 
--a) (12 bodova) Pronaći najprodavanije proizvode, koji nisu na lisli top 10 najprodavanijih proizvoda u zadnjih 11 godina. (AdventureWorks2017) 
SELECT 
	sod.ProductID,
	COUNT(sod.ProductID) ProdanaKolicina
FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod
WHERE sod.ProductID NOT IN (
SELECT sq.ID
FROM
(
	SELECT TOP 10 
		sod.ProductID ID,
		COUNT(sod.ProductID) Broj
	FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod
	INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
	ON sod.SalesOrderID=soh.SalesOrderID
	WHERE DATEDIFF(YEAR, soh.OrderDate, GETDATE())<=11
	GROUP BY sod.ProductID
	ORDER BY COUNT(sod.ProductID) DESC
) AS sq)
GROUP BY sod.ProductID
ORDER BY COUNT(sod.ProductID) DESC

--b) (16 bodova) Prikazati ime i prezime kupca, id narudzbe, te ukupnu vrijednost narudzbe sa popustom (zaokruzenu na dvije decimale), uz uslov da su na nivou pojedine narudžbe naručeni proizvodi iz svih kategorija. (AdventureWorks2017) 
SELECT 
	pp.FirstName,
	pp.LastName, 
	soh.SalesOrderID,
	round(sum(sod.UnitPrice*sod.OrderQty*(1-sod.UnitPriceDiscount)),2) narudzba_sa_popustom, 
	COUNT(DISTINCT pc.ProductCategoryID) broj_kategorija
FROM AdventureWorks2017.Person.Person AS pp
INNER JOIN AdventureWorks2017.Sales.Customer AS c 
ON pp.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh 
ON c.CustomerID=soh.CustomerID
INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod 
ON soh.SalesOrderID=sod.SalesOrderID
INNER JOIN AdventureWorks2017.Production.Product AS p 
ON sod.ProductID=p.ProductID
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc 
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc 
ON psc.ProductCategoryID=pc.ProductCategoryID
GROUP BY pp.FirstName,pp.LastName,soh.SalesOrderID
HAVING COUNT(DISTINCT pc.ProductCategoryID) =
		(SELECT COUNT(DISTINCT pc1.ProductCategoryID)
		FROM AdventureWorks2017.Production.ProductCategory AS pc1)

--28 bodova 

--6. Dokument teorijski_ispit 21 JUN24, preimcnovati vašim brojem indeksa, te u tom dokumentu izraditi pitanja. 

--20 bodova 

