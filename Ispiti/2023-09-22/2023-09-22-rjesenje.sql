--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
CREATE DATABASE ispit220923_1
GO
USE ispit220923_1

--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Uposlenici
--• UposlenikID, 9 karaktera fiksne dužine i primarni ključ,
--• Ime, 20 karaktera (obavezan unos),
--• Prezime, 20 karaktera (obavezan unos),
--• DatumZaposlenja, polje za unos datuma i vremena (obavezan unos),
--• OpisPosla, 50 karaktera (obavezan unos)
CREATE TABLE Uposlenici
(
	UposlenikID CHAR(9) PRIMARY KEY,
	Ime VARCHAR(20) NOT NULL,
	Prezime VARCHAR(20) NOT NULL,
	DatumZaposlenja DATETIME NOT NULL,
	OpisPosla VARCHAR(50) NOT NULL
)

--b) Naslovi
--• NaslovID, 6 karaktera i primarni ključ,
--• Naslov, 80 karaktera (obavezan unos),
--• Tip, 12 karaktera fiksne dužine (obavezan unos),
--• Cijena, novčani tip podataka,
--• NazivIzdavaca, 40 karaktera,
--• GradIzadavaca, 20 karaktera,
--• DrzavaIzdavaca, 30 karaktera
CREATE TABLE Naslovi
(
	NaslovID VARCHAR(6) PRIMARY KEY,
	Naslov VARCHAR(80) NOT NULL,
	Tip CHAR(12) NOT NULL,
	Cijena MONEY,
	NazivIzdavaca VARCHAR(40),
	GradIzdavaca VARCHAR(20),
	DrzavaIzdavaca VARCHAR(30)
)

--c) Prodaja
--• ProdavnicaID, 4 karaktera fiksne dužine, strani i primarni ključ,
--• BrojNarudzbe, 20 karaktera, primarni ključ,
--• NaslovID, 6 karaktera, strani i primarni ključ,
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos)
CREATE TABLE Prodaja
(
	ProdavnicaID CHAR(4) CONSTRAINT FK_Prodavnice 
	FOREIGN KEY REFERENCES Prodavnice (ProdavnicaID),
	BrojNarudzbe VARCHAR(20),
	NaslovID VARCHAR(6) CONSTRAINT FK_Naslovi
	FOREIGN KEY REFERENCES Naslovi (NaslovID),
	DatumNarudzbe DATETIME NOT NULL,
	Kolicina SMALLINT NOT NULL,
	CONSTRAINT PK_Prodaja PRIMARY KEY(ProdavnicaID, BrojNarudzbe, NaslovID)
)

--d) Prodavnice
--• ProdavnicaID, 4 karaktera fiksne dužine i primarni ključ,
--• NazivProdavnice, 40 karaktera,
--• Grad, 40 karaktera
--6 bodova
CREATE TABLE Prodavnice
(
	ProdavnicaID CHAR(4) PRIMARY KEY,
	NazivProdavnice VARCHAR(40),
	Grad VARCHAR(40),
)

--3. Iz baze podataka Pubs u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Uposlenici dodati sve uposlenike
--• emp_id -> UposlenikID
--• fname -> Ime
--• lname -> Prezime
--• hire_date -> DatumZaposlenja
--• job_desc -> OpisPosla
INSERT INTO Uposlenici(UposlenikID, Ime, Prezime, DatumZaposlenja, OpisPosla)
SELECT
	e.emp_id,
	e.fname,
	e.lname,
	e.hire_date,
	j.job_desc
FROM pubs.dbo.employee AS e
INNER JOIN pubs.dbo.jobs AS j
on e.job_id=j.job_id

--b) U tabelu Naslovi dodati sve naslove, na mjestima gdje nema pohranjenih podataka -o- nazivima izdavača
--zamijeniti vrijednost sa nepoznat izdavac
--• title_id -> NaslovID
--• title -> Naslov
--• type -> Tip
--• price -> Cijena
--• pub_name -> NazivIzdavaca
--• city -> GradIzdavaca
--• country -> DrzavaIzdavaca
INSERT INTO Naslovi(NaslovID, Naslov, Tip, Cijena, NazivIzdavaca, GradIzdavaca, DrzavaIzdavaca)
SELECT
	t.title_id,
	t.title,
	t.type,
	t.price,
	ISNULL(p.pub_name, 'nepoznat izdavac'),
	p.city,
	p.country
FROM pubs.dbo.titles AS t
INNER JOIN pubs.dbo.publishers AS p
ON t.pub_id=p.pub_id

--c) U tabelu Prodaja dodati sve stavke iz tabele prodaja
--• stor_id -> ProdavnicaID
--• order_num -> BrojNarudzbe
--• title_id -> NaslovID
--• ord_date -> DatumNarudzbe
--• qty -> Kolicina
INSERT INTO Prodaja(ProdavnicaID, BrojNarudzbe, NaslovID, DatumNarudzbe, Kolicina)
SELECT
	s.stor_id,
	s.ord_num,
	s.title_id,
	s.ord_date,
	s.qty
FROM pubs.dbo.sales AS s

--22.09.2023.
--d) U tabelu Prodavnice dodati sve prodavnice
--• stor_id -> ProdavnicaID
--• store_name -> NazivProdavnice
--• city -> Grad
--6 bodova
INSERT INTO Prodavnice(ProdavnicaID, NazivProdavnice, Grad)
SELECT
	s.stor_id,
	s.stor_name,
	s.city
FROM pubs.dbo.stores AS s

--4.
--a) (6 bodova) Kreirati proceduru sp_update_naslov kojom će se uraditi update --podataka u tabelu Naslovi.
--Korisnik može da pošalje jedan ili više parametara i pri tome voditi računa da se -ne- desi gubitak/brisanje
--zapisa. OBAVEZNO kreirati testni slučaj za kreiranu proceduru. (Novokreirana baza)
GO
CREATE OR ALTER PROCEDURE sp_update_naslov
(
	@NaslovID VARCHAR(6), 
	@Naslov VARCHAR(80)=NULL,
	@Tip CHAR(12)=NULL, 
	@Cijena MONEY=NULL,
	@NazivIzdavaca VARCHAR(40)=NULL,
	@GradIzdavaca VARCHAR(20)=NULL,
	@DrzavaIzdavaca VARCHAR(30)=NULL
)
AS
BEGIN
UPDATE Naslovi
SET
	Naslov=IIF(@Naslov IS NULL,Naslov, @Naslov),
	Tip=IIF(@Tip IS NULL,Tip, @Tip),
	Cijena=IIF(@Cijena IS NULL,Cijena, @Cijena),
	NazivIzdavaca=IIF(@NazivIzdavaca IS NULL,NazivIzdavaca, @NazivIzdavaca),
	GradIzdavaca=IIF(@GradIzdavaca IS NULL,GradIzdavaca, @GradIzdavaca),
	DrzavaIzdavaca=IIF(@DrzavaIzdavaca IS NULL,DrzavaIzdavaca, @DrzavaIzdavaca)
WHERE NaslovID=@NaslovID
END

EXEC sp_update_naslov @NaslovID=TC7777, @Cijena=25

SELECT * FROM Naslovi

--b) (7 bodova) Kreirati upit kojim će se prikazati ukupna prodana količina i ukupna --zarada bez popusta za
--svaku kategoriju proizvoda pojedinačno. Uslov je da proizvodi ne pripadaju --kategoriji bicikala, da im je
--boja bijela ili crna te da ukupna prodana količina nije veća od 20000. Rezultate --sortirati prema ukupnoj
--zaradi u opadajućem redoslijedu. (AdventureWorks2017)
SELECT 
	pc.Name Kategorija, 
	SUM(sod.OrderQty) UkupnaProdanaKolicina, 
	SUM(sod.UnitPrice*sod.OrderQty) UkupnaVrijednost
FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod
INNER JOIN AdventureWorks2017.Production.Product AS p
ON sod.ProductID=p.ProductID
INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS psc
ON p.ProductSubcategoryID=psc.ProductSubcategoryID
INNER JOIN AdventureWorks2017.Production.ProductCategory AS pc
ON psc.ProductCategoryID=pc.ProductCategoryID
WHERE pc.Name NOT LIKE 'Bikes' AND p.Color IN ('White', 'Black')
GROUP BY pc.Name
HAVING SUM(sod.OrderQty)<=20000
ORDER BY SUM(sod.UnitPrice*sod.OrderQty) DESC

--c) (8 bodova) Kreirati upit koji prikazuje kupce koji su u maju mjesecu 2013 ili --2014 godine naručili
--proizvod „Front Brakes“ u količini većoj od 5. Upitom prikazati spojeno ime i --prezime kupca, email,
--naručenu količinu i datum narudžbe formatiran na način dan.mjesec.godina --(AdventureWorks2017)
SELECT 
	pe.FirstName + ' ' + pe.LastName ImePrezime,
	ea.EmailAddress, 
	sod.OrderQty, 
	FORMAT(soh.OrderDate, 'dd.MM.yyyy') DatumNarudzbe
FROM AdventureWorks2017.Production.Product AS p
INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
ON p.ProductID=sod.ProductID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON sod.SalesOrderID=soh.SalesOrderID
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON soh.CustomerID=c.CustomerID
INNER JOIN AdventureWorks2017.Person.Person AS pe
ON c.PersonID=pe.BusinessEntityID
INNER JOIN AdventureWorks2017.Person.EmailAddress AS ea
ON ea.BusinessEntityID=pe.BusinessEntityID
WHERE MONTH(soh.OrderDate)=5 AND YEAR(soh.OrderDate) IN (2013, 2014)
AND p.Name LIKE 'Front Brakes' AND sod.OrderQty>5

--d) (10 bodova) Kreirati upit koji će prikazati naziv kompanije dobavljača koja je --dobavila proizvode, koji
--se u najvećoj količini prodaju (najprodavaniji). Uslov je da proizvod pripada --kategoriji morske hrane i
--da je dostavljen/isporučen kupcu. Također uzeti u obzir samo one proizvode na -kojima- je popust odobren.
--U rezultatima upita prikazati naziv kompanije dobavljača i ukupnu prodanu količinu --proizvoda.
--(Northwind)
SELECT TOP 1 
	s.CompanyName, 
	SUM(od.Quantity) UkupnaKolicina
FROM Northwind.dbo.Suppliers AS s
INNER JOIN Northwind.dbo.Products AS p
on s.SupplierID=p.SupplierID
INNER JOIN Northwind.dbo.[Order Details] AS od
ON p.ProductID=od.ProductID
INNER JOIN Northwind.dbo.Categories AS c
ON p.CategoryID=c.CategoryID
INNER JOIN Northwind.dbo.Orders AS o
on od.OrderID=o.OrderID
WHERE c.CategoryName LIKE '%Sea%' AND o.ShippedDate IS NOT NULL
AND od.Discount>0
GROUP BY s.CompanyName
ORDER BY 2 DESC

--e) (11 bodova) Kreirati upit kojim će se prikazati narudžbe u kojima je na osnovu --popusta kupac uštedio
--2000KM i više. Upit treba da sadrži identifikacijski broj narudžbe, spojeno ime i --prezime kupca, te
--stvarnu ukupnu vrijednost narudžbe zaokruženu na 2 decimale. Rezultate sortirati po- -ukupnoj vrijednosti
--narudžbe u opadajućem redoslijedu.
-- 43 boda
SELECT 
	soh.SalesOrderID, p.FirstName + ' ' + p.LastName ImePrezime,
	ROUND(SUM(sod.UnitPrice*sod.OrderQty), 2) stvarnavrijednost 
FROM AdventureWorks2017.Sales.SalesOrderDetail AS sod
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON sod.SalesOrderID=soh.SalesOrderID
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON soh.CustomerID=c.CustomerID
INNER JOIN AdventureWorks2017.Person.Person AS p
ON c.PersonID=p.BusinessEntityID
GROUP BY soh.SalesOrderID, p.FirstName + ' ' + p.LastName
HAVING SUM(sod.UnitPrice*sod.OrderQty) - SUM(sod.UnitPrice*(1-sod.OrderQty)*sod.OrderQty)>=2000

--5.
--a) (13 bodova) Kreirati upit koji će prikazati kojom kompanijom (ShipMethod(Name)) --je isporučen najveći
--broj narudžbi, a kojom najveća ukupna količina proizvoda. (AdventureWorks2017)
SELECT * FROM
(
	SELECT TOP 1 
		sm.Name, 
		COUNT(*) BrojNarudzbi
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
	ON soh.ShipMethodID=sm.ShipMethodID
	GROUP BY sm.Name
	ORDER BY 2 DESC
)AS sq1
UNION
SELECT * FROM
(
	SELECT TOP 1 
		sm.Name, 
		SUM(sod.OrderQty) UkupnaKolicinaProizvoda
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
	ON soh.ShipMethodID=sm.ShipMethodID
	INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID=sod.SalesOrderID
	GROUP BY sm.Name
	ORDER BY 2 DESC
)AS sq2

--b) (8 bodova) Modificirati prethodno kreirani upit na način ukoliko je jednom --kompanijom istovremeno
--isporučen najveći broj narudžbi i najveća ukupna količina proizvoda upitom -prikazati- poruku „Jedna
--kompanija“, u suprotnom „Više kompanija“ (AdventureWorks2017)
SELECT 
	IIF(COUNT(sq.Name)<2,'jedna', 'vise')
FROM
(
	SELECT * FROM
	(
	SELECT TOP 1 sm.Name, COUNT(*) BrojNarudzbi
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
	ON soh.ShipMethodID=sm.ShipMethodID
	GROUP BY sm.Name
	ORDER BY 2 DESC
	)AS sq1
UNION
	SELECT * FROM
	(
	SELECT TOP 1 sm.Name, SUM(sod.OrderQty) UkupnaKolicinaProizvoda
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
	ON soh.ShipMethodID=sm.ShipMethodID
	INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID=sod.SalesOrderID
	GROUP BY sm.Name
	ORDER BY 2 DESC
	)AS sq2
)AS sq

--c) (4 boda) Kreirati indeks IX_Naslovi_Naslov kojim će se ubrzati pretraga prema --naslovu. OBAVEZNO
--kreirati testni slučaj. (NovokreiranaBaza)
CREATE INDEX IX_Naslovi_Naslov ON Naslovi(Naslov)

SELECT * 
FROM Naslovi
WHERE Naslov LIKE 'B%'
--25 bodova
--6. Dokument teorijski_ispit 22SEP23, preimenovati vašim brojem indeksa, te u tom --dokumentu izraditi pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem indeksa npr IB210001.sql, --teorijski dokument imenovan
--Vašim brojem indexa npr IB210001.docx upload-ovati ODVOJEDNO na ftp u folder -Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55
