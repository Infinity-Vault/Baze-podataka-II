--
--Vje�ba 13 :: Zadaci
--
--1.	Kroz SQL kod kreirati bazu podataka sa imenom va�eg broja indeksa.
  CREATE DATABASE IB1234567
  GO
  USE IB1234567
--2.	U kreiranoj bazi podataka kreirati tabele sa sljede�om strukturom:
--a)	Proizvodi
--�	ProizvodID, cjelobrojna vrijednost i primarni klju�
--�	Naziv, 40 UNICODE karaktera (obavezan unos)
--�	Cijena, nov�ani tip (obavezan unos)
--�	Koli�inaNaSkladistu, smallint 
--�	NazivKompanijeDobavljaca, 40 UNICODE (obavezan unos)
--�	Raspolozivost, bit (obavezan unos)
CREATE TABLE Proizvodi
(
ProizvodID INT CONSTRAINT PK_ProizvodID PRIMARY KEY,
Naziv NVARCHAR(40) NOT NULL,
Cijena MONEY NOT NULL,
KolicinaNaSkladistu SMALLINT,
NazivKompanijeDobavljaca NVARCHAR(40) NOT NULL,
Raspolozivost BIT NOT NULL
)
--b)	Narudzbe
--�	NarudzbaID, cjelobrojna vrijednost i primarni klju�,
--�	DatumNarudzbe, polje za unos datuma
--�	DatumPrijema, polje za unos datuma
--�	DatumIsporuke, polje za unos datuma
--�	Drzava, 15 UNICODE znakova
--�	Regija, 15 UNICODE znakova
--�	Grad, 15 UNICODE znakova
--�	Adresa, 60 UNICODE znakova
CREATE TABLE Narudzbe
(
NarudzbaID INT CONSTRAINT PK_NarudzbaID PRIMARY KEY,
DatumNarudzbe DATE,
DatumPrijema DATE,
DatumIsporuke DATE,
Drzava NVARCHAR(15),
Regija NVARCHAR(15),
Grad NVARCHAR(15),
Adresa NVARCHAR(60)
)
--c)	StavkeNarudzbe
--�	NarudzbaID, cjelobrojna vrijednost, strani klju�
--�	ProizvodID, cjelobrojna vrijednost, strani klju�
--�	Cijena, nov�ani tip (obavezan unos),
--�	Koli�ina, smallint (obavezan unos),
--�	Popust, real vrijednost (obavezan unos)
--**Jedan proizvod se mo�e na�i na vi�e narud�bi, dok jedna narud�ba mo�e imati vi�e proizvoda. U okviru jedne narud�be jedan proizvod se ne mo�e pojaviti vi�e od jedanput.

CREATE TABLE StavkeNarudzbe
(
NarudzbaID INT CONSTRAINT  FK_StavkeNaruzbe_Narudzba_NarudzbaID FOREIGN KEY REFERENCES Narudzbe(NarudzbaID),
ProizvodID INT CONSTRAINT FK_StavkeNaruzbe_Proizvodi_ProizvodID FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
Cijena MONEY NOT NULL,
Kolicina SMALLINT NOT NULL,
Popust REAL NOT NULL,
CONSTRAINT PK_StavkeNarudzbeID PRIMARY KEY (NarudzbaID,ProizvodID)  --Posto imamo kompozitni primarni kljuc, kreiramo constraint na ovaj  nacin.
)
--3.	Iz baze podataka Northwind u svoju bazu podataka prebaciti sljede�e podatke:
--a)	U tabelu Proizvodi dodati sve proizvode 
--�	ProductID -> ProizvodID
--�	ProductName -> Naziv 	
--�	UnitPrice -> Cijena 	
--�	UnitsInStock -> KolicinaNaSkladistu
--�	CompanyName -> NazivKompanijeDobavljaca	
--�	Discontinued -> Raspolozivost 	
INSERT INTO Proizvodi
SELECT P.ProductID,P.ProductName,P.UnitPrice,P.UnitsInStock,S.CompanyName,P.Discontinued
FROM Northwind.dbo.Products AS P INNER JOIN Northwind.dbo.Suppliers AS S ON S.SupplierID=P.SupplierID

--b)	U tabelu Narudzbe dodati sve narud�be, na mjestima gdje nema pohranjenih podataka o regiji zamijeniti vrijednost 
--sa nije naznaceno
--�	OrderID -> NarudzbaID
--�	OrderDate -> DatumNarudzbe
--�	RequiredDate -> DatumPrijema
--�	ShippedDate -> DatumIsporuke
--�	ShipCountry -> Drzava
--�	ShipRegion -> Regija
--�	ShipCity -> Grad
--�	ShipAddress -> Adresa
INSERT INTO Narudzbe
SELECT O.OrderID,O.OrderDate,O.RequiredDate,O.ShippedDate,O.ShipCountry,ISNULL(O.ShipRegion,'nije naznaceno'),O.ShipCity,O.ShipAddress
FROM Northwind.dbo.Orders AS O
--c)	U tabelu StavkeNarudzbe dodati sve stavke narud�be gdje je koli�ina ve�a od 4
--�	OrderID -> NarudzbaID
--�	ProductID -> ProizvodID
--�	UnitPrice -> Cijena
--�	Quantity -> Koli�ina
--�	Discount -> Popust

INSERT INTO StavkeNarudzbe
SELECT OD.OrderID,OD.ProductID,OD.UnitPrice,OD.Quantity,OD.Discount
FROM Northwind.dbo.[Order Details] AS OD 
WHERE OD.Quantity>4
--4.	
--a)Prikazati sve proizvode koji po�inju sa slovom a ili c a trenutno nisu raspolo�ivi.
SELECT*
FROM Proizvodi AS P
WHERE (P.Naziv LIKE 'a%' OR P.Naziv LIKE 'c%') AND P.Raspolozivost=0
--b)Prikazati narud�be koje su kreirane 1996 godine i �ija ukupna vrijednost je ve�a od 500KM.
SELECT SN.NarudzbaID,SUM(SN.Cijena*SN.Kolicina) AS 'Ukupna vrijednost'
FROM Narudzbe AS N INNER JOIN StavkeNarudzbe AS SN ON SN.NarudzbaID=N.NarudzbaID
WHERE YEAR(N.DatumIsporuke)=1996
GROUP BY SN.NarudzbaID
HAVING SUM(SN.Cijena*SN.Kolicina)>500
--c)Prikazati ukupni promet (uzimaju�i u obzir i popust) od narud�bi po teritorijama. (AdventureWorks2017)
SELECT ST.TerritoryID,SUM(SOD.LineTotal) AS 'Ukupni promet'
FROM AdventureWorks2019.Sales.SalesOrderHeader AS SOH INNER JOIN AdventureWorks2019.Sales.SalesTerritory 
AS ST ON ST.TerritoryID=SOH.TerritoryID INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON SOD.SalesOrderID=SOH.SalesOrderID
GROUP BY ST.TerritoryID
--d)Napisati upit koji �e prebrojati stavke narud�be za svaku narud�bu pojedina�no. U rezultatima prikazati ID 
--narud�be i broj stavki, te uzeti u obzir samo one narud�be �iji je broj stavki ve�i od 1, te koje su napravljene 
--izme�u 1.6. i 10.6. bilo koje godine. Rezultate prikazati prema ukupnom broju stavki obrnuto abecedno.
--(AdventureWorks2017)
SELECT SOH.SalesOrderID,COUNT(*)AS BrojStavki
FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD  INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOH.SalesOrderID=SOD.SalesOrderID
WHERE DAY(SOH.OrderDate) BETWEEN 1 AND 10 AND MONTH(SOH.OrderDate)=6
GROUP BY SOH.SalesOrderID
HAVING COUNT(*)>1
ORDER BY 2 DESC
--e)Napisati upit koji �e prikazati sljede�e podatke o proizvodima: ID proizvoda, naziv proizvoda,
--�ifru proizvoda, te novokreiranu �ifru proizvoda. 
--Nova �ifra se sastoji od sljede�ih vrijednosti: 
--(AdventureWorks2017)
--�	Svi karakteri nakon prvog znaka - (crtica)
--�	Karakter /
--�	ID proizvoda
--Npr. Za proizvod sa ID-om 716 i �ifrom LJ-0192-X, nova �ifra �e biti 0192-X/716.

SELECT P.ProductID,P.Name, P.ProductNumber,CONCAT(SUBSTRING(P.ProductNumber,CHARINDEX('-',P.ProductNumber)+1,
LEN(P.ProductNumber)-CHARINDEX('-',P.ProductNumber)+1),'/',P.ProductID)  --SUBSTRING ce nam izdvojiti iz P.ProductNumber dio iza - (+1 kako ne bi uzeli i -) te na to cemo sa CONCAT dodati P.ProductID pri cemu je izmedju /
FROM AdventureWorks2019.Production.Product AS P
--5.	
--a)Kreirati proceduru sp_search_proizvodi kojom �e se u tabeli Proizvodi uraditi pretraga proizvoda 
--prema nazivu prizvoda ili nazivu dobavlja�a. Pretraga treba da radi i prilikom unosa bilo kojeg od slova,
--ne samo potpune rije�i. Ukoliko korisnik ne unese ni�ta od navedenog vratiti sve zapise.
--Proceduru obavezno pokrenuti.

GO
CREATE  OR ALTER PROCEDURE sp_search_proizvodi
(
@Naziv NVARCHAR(40)=NULL,
@NazivDobavljaca NVARCHAR(40)=NULL
)
AS
BEGIN
SELECT*
FROM Proizvodi AS P
WHERE (P.Naziv LIKE @Naziv+'%' OR @Naziv IS NULL) AND --Povezemo sa AND jer zelimo bilo koji od uslova da bude tacan. Ovo radimo umjesto OR jer imamo OR @parametar IS NULL u zagradama.
(P.NazivKompanijeDobavljaca LIKE @NazivDobavljaca+'%' OR @NazivDobavljaca IS NULL)
-- +'%' koristimo u slucaju da se pri pozivu da samo prvi karakter, % nam mijenja sve iza.
END
GO
EXEC sp_search_proizvodi @Naziv='c'
--b)Kreirati proceduru sp_insert_stavkeNarudzbe koje �e vr�iti insert nove stavke narud�be u tabelu stavkeNarudzbe. 
--Proceduru obavezno pokrenuti.
GO
CREATE PROCEDURE sp_insert_stavkeNarudzbe
(
@NarudzbaID INT,
@ProizvodID INT,
@Cijena MONEY,
@Kolicina SMALLINT,
@Popust REAL
)
AS 
BEGIN
INSERT INTO StavkeNarudzbe
VALUES(@NarudzbaID,@ProizvodID,@Cijena,@Kolicina,@Popust)
END
GO

SELECT*
FROM StavkeNarudzbe
WHERE ProizvodID=0.15
EXEC sp_insert_stavkeNarudzbe 51,10248,25,15,0.15
--c)Kreirati view koji prikazuje sljede�e kolone: ID narud�be, datum narud�be, spojeno ime i prezime kupca 
--i ukupnu vrijednost narud�be. Podatke sortirati prema ukupnoj vrijednosti u opadaju�em redoslijedu. 
--(AdventureWorks2017)
GO
CREATE OR ALTER VIEW v_5C
AS
SELECT SOD.SalesOrderID,SOH.OrderDate,CONCAT(P.FirstName,' ',P.LastName) AS 'Ime i prezime',
SUM(SOD.OrderQty*SOD.UnitPrice) AS 'Ukupna vrijednost narudzbe'
FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD INNER JOIN
AdventureWorks2019.Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID
INNER JOIN 
AdventureWorks2019.Sales.Customer AS C ON C.CustomerID=SOH.CustomerID
INNER JOIN AdventureWorks2019.Person.Person AS P ON P.BusinessEntityID=C.CustomerID
GROUP BY SOD.SalesOrderID,SOH.OrderDate,CONCAT(P.FirstName,' ',P.LastName)
GO
SELECT*
FROM v_5C AS V5C 
ORDER BY V5C.[Ukupna vrijednost narudzbe] DESC --Grupisanje je moguce samo izvan pogleda

--d)Kreirati okida� kojim �e se onemogu�iti brisanje zapisa iz tabele StavkeNarudzbe. 
--Korisnicima je potrebno ispisati poruku Arhivske zapise nije mogu�e izbrisati.
GO
CREATE TRIGGER t_5D --Kada u tekstu nam nije dat naziv, nazovemo ga prema rednom broju zadatka 
ON StavkeNarudzbe
INSTEAD OF DELETE
AS
BEGIN
SELECT('Arhivske zapise nije mogu�e izbrisati')
END
GO

DELETE StavkeNarudzbe 
WHERE ProizvodID=1

--e)Kreirati index kojim �e se ubrzati pretraga po nazivu proizvoda.
CREATE INDEX  Ix_NazivProizvoda --Ime indexa, konvencija imenovanja jeste: Ix_ImeIndexa
ON Proizvodi (Naziv) --U kojoj tabeli i na kojoj koloni kreiramo

SELECT*
FROM Proizvodi
WHERE Naziv LIKE 'A%'  --Index svaki se okine u WHERE uslovu
--f)U tabeli StavkeNarudzbe kreirati polje ModifiedDate u kojem �e se nakon kreiranja okida�a za
--izmjenu podataka spremati datum modifikacije podataka za konkretan red na kojem je izvr�ena modifikacija. 
ALTER TABLE StavkeNarudzbe
ADD ModifiedDate DATE

GO
CREATE TRIGGER t_5F
ON StavkeNarudzbe
AFTER UPDATE
AS
BEGIN
UPDATE StavkeNarudzbe
SET ModifiedDate=GETDATE()
--Posto imamo kompozitni prim kljuc moramo traziti po objema vrjednostima
WHERE NarudzbaID IN (SELECT DISTINCT NarudzbaID
						FROM inserted) AND ProizvodID IN (SELECT DISTINCT ProizvodID
												FROM inserted) 
END 
GO

UPDATE StavkeNarudzbe
SET Cijena=8000
WHERE ProizvodID=51 AND NarudzbaID=10248

--Provjerimo jel update prosao
SELECT*
FROM StavkeNarudzbe
WHERE ProizvodID=51 AND NarudzbaID=10248