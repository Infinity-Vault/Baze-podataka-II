--1.Kreirati bazu podataka sa imenom vaseg broja indeksa
CREATE DATABASE ispit12072024_1
GO
USE ispit12072024_1

--2.U kreiranoj bazi tabelu sa strukturom : 
--a) Uposlenici 
-- UposlenikID cjelobrojni tip i primarni kljuc autoinkrement,
-- Ime 10 UNICODE karaktera (obavezan unos)
-- Prezime 20 UNICODE karaktera (obaveznan unos),
-- DatumRodjenja polje za unos datuma i vremena (obavezan unos)
-- UkupanBrojTeritorija cjelobrojni tip
CREATE TABLE Uposlenici
(
	UposlenikID INT PRIMARY KEY IDENTITY(1,1),
	Ime NVARCHAR(10) NOT NULL,
	Prezime NVARCHAR(20) NOT NULL,
	DatumRodjenja DATETIME NOT NULL,
	UkupanBrojTeritorija INT
)

--b) Narudzbe
-- NarudzbaID cjelobrojni tip i primarni kljuc autoinkrement,
-- UposlenikID cjelobrojni tip i strani kljuc,
-- DatumNarudzbe polje za unos datuma i vremena,
-- ImeKompanijeKupca 40 UNICODE karaktera,
-- AdresaKupca 60 UNICODE karaktera,
-- UkupanBrojStavkiNarudzbe cjelobrojni tip
CREATE TABLE Narudzbe
(
	NarudzbaID INT PRIMARY KEY IDENTITY(1,1),
	UposlenikID INT FOREIGN KEY REFERENCES Uposlenici(UposlenikID),
	DatumNarudzbe DATETIME,
	ImeKompanijeKupca NVARCHAR(40),
	AdresaKupca NVARCHAR(60),
	UkupanBrojStavkiNarudzbe INT
)

--c) Proizvodi
-- ProizvodID cjelobrojni tip i primarni kljuc autoinkrement,
-- NazivProizvoda 40 UNICODE karaktera (obaveznan unos),
-- NazivKompanijeDobavljaca 40 UNICODE karaktera,
-- NazivKategorije 15 UNICODE karaktera
CREATE TABLE Proizvodi
(
	ProizvodID INT PRIMARY KEY IDENTITY(1,1),
	NazivProizvoda NVARCHAR(40) NOT NULL,
	NazivKompanijeDobavljaca NVARCHAR(40),
	NazivKategorije NVARCHAR(15)
)

--d) StavkeNarudzbe
-- NarudzbaID cjelobrojni tip strani i primarni kljuc,
-- ProizvodID cjelobrojni tip strani i primarni kljuc,
-- Cijena novcani tip (obavezan unos),
-- Kolicina kratki cjelobrojni tip (obavezan unos),
-- Popust real tip podataka (obavezno)
CREATE TABLE StavkeNarudzbe
(
	NarudzbaID INT FOREIGN KEY REFERENCES Narudzbe(NarudzbaID),
	ProizvodID INT FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	Cijena MONEY NOT NULL,
	Kolicina SMALLINT NOT NULL,
	Popust REAL NOT NULL
	CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY(NarudzbaID, ProizvodID)
)

--(4 boda)


--3.Iz baze Northwind u svoju prebaciti sljedece podatke :
--a) U tabelu uposlenici sve uposlenike , Izracunata vrijednost za svakog uposlenika na osnovnu EmployeeTerritories -> UkupanBrojTeritorija
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

--b) U tabelu narudzbe sve narudzbe, Izracunata vrijensot za svaku narudzbu pojedinacno 
-- ->UkupanBrojStavkiNarudzbe
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

--c) U tabelu proizvodi sve proizvode
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

--d) U tabelu StavkeNrudzbe sve narudzbe
INSERT INTO StavkeNarudzbe(NarudzbaID, ProizvodID, Cijena, Kolicina, Popust)
SELECT
	od.OrderID,
	od.ProductID,
	od.UnitPrice,
	od.Quantity,
	od.Discount
FROM Northwind.dbo.[Order Details] AS od

--(5 bodova)

--4. 
--a) (4 boda) Kreirati indeks kojim ce se ubrzati pretraga po nazivu proizvoda, OBEVAZENO kreirati testni slucaj (Nova baza)
CREATE INDEX ix_pretraga_naziv ON Proizvodi(NazivProizvoda)

SELECT * 
FROM Proizvodi
WHERE NazivProizvoda LIKE 'A%'

--b) (4 boda) Kreirati proceduru sp_update_proizvodi kojom ce se izmjeniti podaci o prpoizvodima u tabeli. Korisnici mogu poslati jedan ili vise parametara te voditi raucna da ne dodje do gubitka podataka.(Nova baza)
GO
CREATE PROCEDURE sp_update_proizvodi
(
	@ProizvodID INT,
	@NazivProizvoda NVARCHAR(40)=NULL,
	@NazivKompanijeDobavljaca NVARCHAR(40)=NULL,
	@NazivKategorije NVARCHAR(15)=NULL
)
AS
BEGIN
UPDATE Proizvodi
SET
	NazivProizvoda=IIF(@NazivProizvoda IS NULL, NazivProizvoda, @NazivProizvoda),
	NazivKompanijeDobavljaca=IIF(@NazivKompanijeDobavljaca IS NULL, NazivKompanijeDobavljaca, @NazivKompanijeDobavljaca),
	NazivKategorije=IIF(@NazivKategorije IS NULL, NazivKategorije, @NazivKategorije)
WHERE ProizvodID=@ProizvodID
END

EXEC sp_update_proizvodi @ProizvodID=1, @NazivProizvoda='Caj'

SELECT * FROM Proizvodi
--c) (5 bodova) Kreirati funckiju f_4c koja ce vratiti podatke u tabelarnom obliku osnovnu prosljedjenog parametra idNarudzbe cjelobrojni tip. Funckija ce vratiti one narudzbe ciji id odgovara poslanom parametru. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalazi id narudzbe,ukupna vrijednost bez popustva. OBAVEZNO testni sluc (Nova baza)
GO
CREATE FUNCTION f_4c
(
	@NarudzbaID INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	sn.NarudzbaID,
	sn.Cijena*sn.Kolicina VrijednostBezPopusta
FROM StavkeNarudzbe AS sn
WHERE NarudzbaID=@NarudzbaID

SELECT * FROM f_4c(10248)

SELECT * FROM StavkeNarudzbe
--d) (6 bodova) Pronaci najmanju narudzbu placenu karticom i isporuceno na porducje Europe, uz id narudzbe prikazati i spojeno ime i prezime kupca te grad u koji je isporucena narudzbe (AdventureWorks)
SELECT TOP 1
	sod.SalesOrderID,
	CONCAT(p.FirstName, ' ', p.LastName) ImePrezime,
	a.City
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON p.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS sod
ON sod.CustomerID=c.CustomerID
INNER JOIN AdventureWorks2017.Sales.SalesTerritory AS st
ON sod.TerritoryID=st.TerritoryID
INNER JOIN AdventureWorks2017.Person.Address AS a
ON sod.ShipToAddressID=a.AddressID
WHERE sod.CreditCardID IS NOT NULL AND st.[Group] = 'Europe'
ORDER BY sod.TotalDue

--e) (6 bodova) Prikazati ukupan broj proizvoda prema specijalnim ponudama. Potrebno je prebrojati samo one proizvode koji pripadaju kategoriji odjece ili imaju zabiljezen model (AdventureWorks)
SELECT 
	sop.SpecialOfferID,
	COUNT(p.ProductID) BrojProizvoda
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Sales.SpecialOfferProduct AS sop
ON p.ProductID=sop.ProductID
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
WHERE pc.Name='Clothing' AND p.ProductModelID IS NOT NULL
GROUP BY sop.SpecialOfferID

--f) (9 bodova) Prikazati 5 kupaca koji su napravili najveci broj narudzbi u zadnjih 30% narudzbi iz 2011 ili 2012 god. (AdventureWorks)
SELECT TOP 5
    sq.CustomerID,
    sq.BrojNarudzbi
FROM
(
    SELECT 
        soh.CustomerID,
        COUNT(soh.SalesOrderID) AS BrojNarudzbi
    FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
    WHERE YEAR(soh.OrderDate) IN (2011, 2012)
    GROUP BY soh.CustomerID
    HAVING soh.CustomerID IN (
		SELECT TOP 30 PERCENT 
			soh.CustomerID
		FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
		WHERE YEAR(soh.OrderDate) IN (2011, 2012)
		ORDER BY soh.OrderDate DESC
        )
) AS sq
ORDER BY sq.BrojNarudzbi DESC

--g) (10 bodova) Menadzmentu kompanije potrebne su informacije o najmanje prodavanim proizvodima. ...kako bi ih eliminisali iz ponude. Obavezno prikazati naziv o kojem se proizvodu radi i kvartal i godinu i adekvatnu poruku. (AdventureWorks)

--5.
--a) (11 bodova) Prikazati kupce koji su kreirali narudzbe u minimalno 5 razlicitih mjeseci u 2012 godini.
SELECT
	sq.CustomerID,
	COUNT(DISTINCT sq.Mjesec) BrojMjeseci
FROM
(
	SELECT 
		soh.CustomerID,
		MONTH(soh.OrderDate) Mjesec
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	WHERE YEAR(soh.OrderDate)=2012
	GROUP BY soh.CustomerID, MONTH(soh.OrderDate)
) AS sq
GROUP BY sq.CustomerID
HAVING COUNT(DISTINCT sq.Mjesec)>=5

--b) (16 bodova) Prikazati 5 narudzbi sa najvise narucenih razlicitih proizvoda i 5 narudzbi sa najvise porizvoda koji pripadaju razlicitim potkategorijama. Upitom prikazati ime i prezime kupca, id narudzbe te ukupnu vrijednost narudzbe sa popoustom zaokruzenu na 2 decimale (AdventureWorks)
SELECT * 
FROM
(
	SELECT TOP 5
		CONCAT(p.FirstName, ' ', p.LastName) ImePrezime,
		sod.SalesOrderID,
		COUNT(DISTINCT sod.ProductID) BrojRazlicitihProizvoda,
		SUM(sod.UnitPrice*(1-sod.UnitPriceDiscount)) CijenaSaPopustom
	FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod
	INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
	ON sod.SalesOrderID=soh.SalesOrderID
	INNER JOIN AdventureWorks2017.Sales.Customer AS c
	ON soh.CustomerID=c.CustomerID
	INNER JOIN AdventureWorks2017.Person.Person AS p
	ON c.PersonID=p.BusinessEntityID
	GROUP BY sod.SalesOrderID, CONCAT(p.FirstName, ' ', p.LastName)
	ORDER BY COUNT(DISTINCT sod.ProductID) DESC
) AS sq1

--kako ih kombinovati? 
--nemam pojma.

SELECT *
FROM
(
	SELECT TOP 5
		CONCAT(pp.FirstName, ' ', pp.LastName) ImePrezime,
		sod.SalesOrderID,
		COUNT(DISTINCT p.ProductSubcategoryID) BrojProizvodaSaRazlicitimPodkategorijama,
		SUM(sod.UnitPrice*(1-sod.UnitPriceDiscount)) CijenaSaPopustom
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID=sod.SalesOrderID
	INNER JOIN AdventureWorks2017.Production.Product AS p
	ON sod.ProductID=p.ProductID
	INNER JOIN AdventureWorks2017.Sales.Customer AS c
	ON soh.CustomerID=c.CustomerID
	INNER JOIN AdventureWorks2017.Person.Person AS pp
	ON c.PersonID=pp.BusinessEntityID
	GROUP BY sod.SalesOrderID, CONCAT(pp.FirstName, ' ', pp.LastName)
	ORDER BY COUNT(DISTINCT sod.ProductID) DESC
) AS sq2
