--1.Kreirati bazu Procedure_ i aktivirati je.
CREATE DATABASE Procedure_
GO 
USE Procedure_
--2.Kreirati tabelu Proizvodi te prilikom kreiranja uraditi insert podataka iz tabele Products baze Northwind.
SELECT*
INTO Proizvodi  --Into ce i da kreira tabelu a i da je ispuni podacima.
FROM Northwind.dbo.Products AS P
--3.Kreirati proceduru sp_Proizvod_Insert kojom æe se u tabeli Proizvodi uraditi insert novog zapisa.

--NOTE:
--SVAKA procedura se moze pozvati i BEZ EXEC kljucne rijeci
--Dobro je "omotati" proceduru u GO ispod i iznad isto kao i pogled, kako bi bilo u jednom batch-u.
GO 
CREATE PROCEDURE sp_Proizvod_Insert
(
@ProductName NVARCHAR(40),
@SupplierID INT=NULL, --Kada zelimo ulazni parametar omoguciti da se moze a i ne mora poslati, stavimo =NUll (kako bi default vrijednost bila NULL)
@CategoryID INT=NULL,
@QuantityPerUnit NVARCHAR(20)=NULL,
@UnitPrice MONEY=NULL,
@UnitsInStock SMALLINT=NULL,
@UnitsInOrder SMALLINT=NULL,
@ReorderLevel SMALLINT=NULL,
@Discontinued BIT
)
AS
BEGIN
INSERT INTO Proizvodi
VALUES(@ProductName,@SupplierID,@CategoryID,@QuantityPerUnit,@UnitPrice,@UnitsInStock,
@UnitsInOrder,@ReorderLevel,@Discontinued) --Ubacimo proslijedjene vrijednosti u tabelu.
END
GO
--4.Kreirati dva testna sluèaja, u prvom poslati podatke u sva polja, u drugom samo u ona koja su obavezna.
EXEC sp_Proizvod_Insert 'Mlijeko',1,1,'20',2,100,200,10,1
EXEC sp_Proizvod_Insert @ProductName='Not named',@Discontinued=1 
--Provjera:
SELECT*
FROM Proizvodi
--5.Kreirati proceduru sp_Proizvod_Update kojom æe se u tabeli Proizvodi uraditi update zapisa.
GO
CREATE PROCEDURE sp_Proizvod_Update
(
--Kod UPDATE-a, sve saljemo kao NULL po defaultu jer ne znamo unaprijed koje parametre korisnik zeli da azurira.
@ProductID INT,
@ProductName NVARCHAR(40)=NULL,
@SupplierID INT=NULL,
@CategoryID INT=NULL,
@QuantityPerUnit NVARCHAR(20)=NULL,
@UnitPrice MONEY=NULL,
@UnitsInStock SMALLINT=NULL,
@UnitsInOrder SMALLINT=NULL,
@ReorderLevel SMALLINT=NULL,
@Discontinued BIT=NULL
)
AS
BEGIN
UPDATE Proizvodi
SET
--Upravo radi toga sto korisnik moze neke parametre da ne azurira, oni ce biti poslani kao null te prepisati ce stare vrijednosti.
--Stoga uradimo check ISNULL i ako jeste ostavimo taj atribut na staroj vrijednosti.
ProductName=ISNULL(@ProductName,ProductName),
SupplierID=ISNULL(@SupplierID,SupplierID),
CategoryID=ISNULL(@CategoryID,CategoryID),
QuantityPerUnit=ISNULL(@QuantityPerUnit,QuantityPerUnit),
UnitPrice=ISNULL(@UnitPrice,UnitPrice),
UnitsInStock=ISNULL(@UnitsInStock,UnitsInStock),
UnitsOnOrder=ISNULL(@UnitsInOrder,@UnitsInOrder),
ReorderLevel=ISNULL(@ReorderLevel,ReorderLevel),
Discontinued=ISNULL(@Discontinued,Discontinued)
WHERE ProductID=@ProductID --Kako ne bi update azurirao sve podatke tabele.
END
GO
--6.Kreirati testni sluèaj za update zapisa kroz proceduru.
EXEC sp_Proizvod_Update @ProductID=79,@ProductName='Not set updated'
SELECT*
FROM Proizvodi
--7.Kreirati proceduru sp_Proizvod_Delete kojom æe se u tabeli Proizvodi uraditi delete odreðenog zapisa.
GO
CREATE PROCEDURE sp_Proizvod_Delete
(
@ProductID INT 
)
AS 
BEGIN 
DELETE Proizvodi
WHERE ProductID=@ProductID  --Kako ne bi delete obrisao sve podatke tabele.
END
GO
--8.Kreirati testni sluèaj za brisanje proizvoda sa id-om 3.
EXEC sp_Proizvod_Delete 3
SELECT*
FROM Proizvodi 
--9.Kreirati tabelu StavkeNarudzbe te prilikom kreiranja uraditi insert podataka iz tabele Order Details baze Northwind.
SELECT*
INTO StavkeNarudzbe
FROM Northwind.dbo.[Order Details]
--10.Kreirati proceduru sp_StavkeNarudzbe_Proizvodi_InsertUpdate kojom æe se u tabeli StavkeNarudzbe dodati
--nova stavka narudžbe a u tabeli Proizvodi umanjiti stanje za zalihama.
GO 
CREATE PROCEDURE sp_StavkeNarudzbe_Proizvodi_InsertUpdate
(
@OrderID INT,
@ProductID INT,
@UnitPrice MONEY,
@Quantity SMALLINT,
@Discount REAL
)
AS 
BEGIN 
INSERT INTO StavkeNarudzbe
VALUES (@OrderID,@ProductID,@UnitPrice,@Quantity,@Discount);--Zavrsimo dio ubacivanja

UPDATE Proizvodi  --Zapocnemo dio azuriranja
SET UnitsInStock=UnitsInStock-@Quantity  --Umanjimo za narucenu kolicinu
WHERE ProductID=@ProductID
END 
GO 
--11.Kreirati testni sluèaj za prethodno kreiranu proceduru.
EXEC sp_StavkeNarudzbe_Proizvodi_InsertUpdate 10248,56,1,10,0.1
SELECT*
FROM StavkeNarudzbe
--12.Kreirati proceduru sp_Proizvodi_SelectByProductNameOrCategoryID kojom æe se u tabeli Proizvodi uraditi select
--proizvoda prema nazivu proizvoda i ID kategorije. Ukoliko korisnik ne unese ništa od navedenog prikazati sve proizvode.
GO 
CREATE PROCEDURE sp_Proizvodi_SelectByProductNameOrCategoryID
(
--Defaultno saljemo NULL jer moze da korisnik ne unese nista (iz teksta)
@ProductName NVARCHAR(40)=NULL,
@CategoryID INT=NULL
)
AS 
BEGIN 
SELECT*
FROM Proizvodi AS P
--Ukoliko se ne proslijedi ime proizvoda i id kategorije vratiti ce se svi zapisi.
--Dok ukoliko ne budu i ime i id tacni nece se prikazati nista.
WHERE (P.ProductName=@ProductName OR @ProductName IS NULL) AND (P.CategoryID=@CategoryID OR @CategoryID IS NULL)
END 
GO 
--13.Prethodno kreiranu proceduru izvršiti sa sljedeæim testnim sluèajevima:
--•	Ime proizvoda'Chai'
--•	Id kategorije 7
EXEC sp_Proizvodi_SelectByProductNameOrCategoryID 'Chai',7
--•	Ime proizvoda'Tofu'i id kategorije=7
EXEC sp_Proizvodi_SelectByProductNameOrCategoryID 'Tofu',7
--•	bez slanja bilo kakvih podataka
EXEC sp_Proizvodi_SelectByProductNameOrCategoryID 

--14.Kreirati proceduru u bazi Procedure_ naziva sp_uposlenici_selectAll nad tabelama odgovarajuæim tabelama 
--baze AdventureWorks2017 kojom æe se dati prikaz polja BusinessEntityID, FirstName, LastName i JobTitle.
--Proceduru podesiti da se rezultati sortiraju po BusinessEntityID.
GO 
CREATE  PROCEDURE sp_uposlenici_selectAll
AS 
BEGIN 
SELECT E.BusinessEntityID,P.FirstName,P.LastName,E.JobTitle
FROM AdventureWorks2019.Person.Person AS P INNER JOIN AdventureWorks2019.HumanResources.Employee  AS E --Spojimo osobu i uposlenika
ON P.BusinessEntityID=E.BusinessEntityID
ORDER BY E.BusinessEntityID ASC
END 
GO
--15.Iz baze AdventureWorks2017 u tabelu Vendor kopirati tabelu Purchasing.Vendor.
SELECT* 
INTO Vendor
FROM AdventureWorks2019.Purchasing.Vendor
--16.Kreirati proceduru sp_Vendor_deleteColumn kojom æe se izvršiti brisanje kolone PurchasingWebServiceURL.
GO 
CREATE PROCEDURE sp_Vendor_deleteColumn
AS
BEGIN
ALTER TABLE Vendor
DROP COLUMN PurchasingWebServiceURL --Obrisemo kolonu u citavoj tabeli.
END
GO
--17.Kreirati proceduru sp_Vendor_updateAccountNumber kojom æe se izvršiti update kolone AccountNumber tako da u 
--svakom zapisu posljednji znak (cifra) podatka iskljuèivo bude 1.
GO
CREATE PROCEDURE sp_Vendor_updateAccountNumber
AS 
BEGIN 
UPDATE Vendor
--Ako je zadnja cifra razlicita od jedan, uzmi mi sa lijeva sve do zadnje cifre i spoji to sa 1. Ako je vec 1 samo ostavi AccountNumber onakav kakav  vec jeste.
--Ovime dobijemo namijestanje svim zapisima da je zadnja cifra 1.
SET AccountNumber=IIF(RIGHT(AccountNumber,1)NOT LIKE '1',CONCAT(LEFT(AccountNumber,LEN(AccountNumber)-1),'','1'),AccountNumber)
END
GO

--18.Kreirati proceduru u bazi Procedure_ naziva sp_Zaposlenici_SelectByFirstNameLastNameGender nad odgovarajuæim 
--tabelama baze AdventureWorks2017 kojom æe se definirati sljedeæi ulazni parametri: 
-- EmployeeID, 
-- FirstName,
-- LastName,
-- Gender. 
GO 
CREATE PROCEDURE sp_Zaposlenici_SelectByFirstNameLastNameGender
(
@EmployeeID INT=NULL,
@FirstName NVARCHAR(50)=NULL,
@LastName NVARCHAR(50)=NULL,
@Gender NCHAR(1)=NULL
)
AS
BEGIN 
SELECT E.BusinessEntityID,P.LastName,P.FirstName,E.Gender
FROM AdventureWorks2019.Person.Person AS P INNER JOIN AdventureWorks2019.HumanResources.Employee AS E --Spojimo osobu i uposlenika
ON P.BusinessEntityID=E.BusinessEntityID
WHERE(E.BusinessEntityID=@EmployeeID OR @EmployeeID IS NULL) OR (LastName=@LastName OR @LastName IS NULL)
OR (FirstName=@FirstName OR @FirstName IS NULL) OR (Gender=@Gender OR @Gender IS NULL) 
END
GO
--Proceduru kreirati tako da je prilikom izvršavanja moguæe unijeti bilo koji broj parametara (možemo ostaviti 
--bilo koje polje bez unijete vrijednosti parametra), 
--te da procedura daje rezultat ako je zadovoljena bilo koja od vrijednosti koje su navedene kao vrijednosti parametara.
--Nakon kreiranja pokrenuti proceduru za sljedeæe vrijednosti parametara:
--•	EmployeeID = 20, 
--•	LastName = Miller,
--•	LastName = Abercrombie Gender = M
EXEC sp_Zaposlenici_SelectByFirstNameLastNameGender 20,'Miller','Abercrombie','M'

--19.Proceduru sp_Zaposlenici_SelectByFirstNameLastNameGender izmijeniti tako da je prilikom izvršavanja moguæe unijeti
--bilo koje vrijednosti za prva tri parametra (možemo ostaviti bilo koje od tih polja bez unijete vrijednosti),
--a da vrijednost èetvrtog parametra bude F. 
GO 
CREATE OR ALTER  PROCEDURE sp_Zaposlenici_SelectByFirstNameLastNameGender
(
@EmployeeID INT=NULL,
@FirstName NVARCHAR(50)=NULL,
@LastName NVARCHAR(50)=NULL,
@Gender NCHAR(1)=NULL
)
AS
BEGIN 
SELECT E.BusinessEntityID,P.LastName,P.FirstName,E.Gender
FROM AdventureWorks2019.Person.Person AS P INNER JOIN AdventureWorks2019.HumanResources.Employee AS E
ON P.BusinessEntityID=E.BusinessEntityID
WHERE ((E.BusinessEntityID=@EmployeeID OR @EmployeeID IS NULL) OR (LastName=@LastName OR @LastName IS NULL)
OR (FirstName=@FirstName OR @FirstName IS NULL)) AND Gender='F' --Povezemo sa AND jer mora biti zensko svaki zapis.
END
GO
--Nakon izmjene pokrenuti proceduru za sljedeæe vrijednosti parametara:
--•	 EmployeeID = 2, 
--•	LastName = Miller
EXEC sp_Zaposlenici_SelectByFirstNameLastNameGender @EmployeeID=2,@LastName='Miller'

--20.Kreirati proceduru u bazi Procedure_ naziva sp_Narudzbe_SelectByCustomerID nad odgovarajuæim tabelama baze Northwind,
--sa parametrom CustomerID kojom æe se dati pregled ukupno naruèenih kolièina svakog od proizvoda za unijeti 
--ID Customera. Proceduru pokrenuti za ID Customera BOLID
GO
CREATE PROCEDURE sp_Narudzbe_SelectByCustomerID
(@CustomerID NCHAR(5)=NULL)
AS
BEGIN
SELECT OD.ProductID,SUM(OD.Quantity) AS 'Ukupno narucena kolicina  proizvoda'
FROM Northwind.dbo.Customers AS C INNER JOIN Northwind.dbo.Orders AS O  --Spojimo kupca i narudzbu
ON O.CustomerID=C.CustomerID
INNER JOIN Northwind.dbo.[Order Details] AS OD ON OD.OrderID=O.OrderID --Spojimo stavku narudzbe i narudzbu
WHERE C.CustomerID=@CustomerID
GROUP BY OD.ProductID
END
GO

EXEC sp_Narudzbe_SelectByCustomerID 'BOLID'

--21.Kreirati pogled v_Narudzbe strukture:
--	- OrderID
--	- ShippedDate
--	- Ukupno (predstavlja sumu vrijednosti stavki po narudžbi).
GO 
CREATE VIEW v_Narudzbe
AS 
SELECT O.OrderID,O.ShippedDate,SUM(OD.Quantity*OD.UnitPrice) AS 'Ukupno'
FROM  Northwind.dbo.[Order Details] AS OD INNER JOIN Northwind.dbo.Orders AS O
ON OD.OrderID=O.OrderID
GROUP BY O.OrderID,O.ShippedDate
GO
--22.Koristeæi pogled v_Narudzbe kreirati proceduru sp_Prodavci_Zemlje sa parametrima:
--	- startDate, datumski tip
--	- endDate, datumski tip
--startDate i endDate su datumi izmeðu kojih se izraèunava suma prometa po narudžbi i obavezno je unijeti oba datuma.
--Procedura ima sljedeæu strukturu, odnosno vraæa sljedeæe podatke:
--	- OrderID
--	- Ukupno
--pri èemu æe kolona ukupno biti tipa money.
--Omoguæiti sortiranje u opadajuæem redoslijedu po Ukupno.
GO
CREATE  PROCEDURE  sp_Prodavci_Zemlje
(
@startDate DATE,
@endDate DATE
)
AS 
BEGIN
SELECT VN.OrderID,SUM(VN.Ukupno) AS Ukupno
FROM v_Narudzbe AS VN
WHERE VN.ShippedDate BETWEEN @startDate AND @endDate
GROUP BY VN.OrderID
ORDER BY Ukupno DESC
END
GO

--Nakon kreiranja procedure pokrenuti za vrijednosti
--	- startDate	= 1997-01-01
--	- endDate	= 1997-12-31 
EXEC sp_Prodavci_Zemlje '1997-01-01','1997-12-31' --Datum saljemo kao string.

--23.Iz baze AdventureWorks2017 u bazu Procedure_ kopirati tabelu zaglavlje i tabelu stavke narudžbe za nabavke.
--Novokreirane tabele imenovati kao zaglavlje i detalji. U kreiranim tabelama definirati PK kao u tabelama u 
--Bazi AdventureWorks2017. Definirati realtionships izmeðu tabela zaglavlje i stavke narudzbe.
SELECT* 
INTO Narudzba_zaglavlje
FROM AdventureWorks2019.Sales.SalesOrderHeader

ALTER TABLE Narudzba_zaglavlje
ADD CONSTRAINT PK_SalesOrderID PRIMARY KEY (SalesOrderID)

SELECT* 
INTO  Narudzba_detalji
FROM AdventureWorks2019.Sales.SalesOrderDetail

ALTER TABLE Narudzba_detalji
ADD CONSTRAINT PK_SalesOrderID_Detalji PRIMARY KEY (SalesOrderID,SalesOrderDetailID) --Imamo kompozitni prim kljuc

ALTER TABLE Narudzba_detalji
ADD CONSTRAINT FK_Narudzba_detalji_Narudzba_zaglavlje_SalesOrderID FOREIGN KEY REFERENCES Narudzba_zaglavlje(SalesOrderID)

--24.Kreirati proceduru sp_Narudzbe_Stavke sa paramterima:
-- status, kratki cjelobrojni tip
-- mjesecNarudzbe, cjelobrojni tip
-- kvartalIsporuke, cjelobrojni tip
-- vrijednostStavke, realni tip
--Procedura je sljedeæe strukture:
-- status
-- mjesec datuma narudžbe
-- kvartal datuma isporuke
-- naruèena kolièina
-- cijena
-- vrijednost stavke kao proizvod kolièine i cijene
--Uslov je da procedura dohvata samo one zapise u kojima je vrijednost kolone vrijednost stavki izmeðu 100 i 500, 
--pri èemu æe prilikom pokretanja procedure rezultati biti sortirani u opadajuæem redoslijedu.
--Proceduru kreirati tako da je prilikom izvršavanja moguæe unijeti bilo koji broj parametara 
--(možemo ostaviti bilo koje polje bez unijetog parametra), te da procedura daje rezultat ako je zadovoljena 
--bilo koja od vrijednosti koje su navedene kao vrijednosti parametara.
GO
CREATE  PROCEDURE sp_Narudzbe_Stavke
(
@status SMALLINT=NULL,
@mjesecNarudzbe INT=NULL,
@kvartalIsporuke INT=NULL,
@vrijednostStavke REAL=NULL
)
AS
BEGIN
SELECT DISTINCT NZ.Status,MONTH(NZ.OrderDate) 'Mjesec datuma narudzbe',
DATEPART(QUARTER,NZ.ShipDate) 'Kvartal datuma isporuke',ND.OrderQty,ND.UnitPrice,(ND.UnitPrice*ND.OrderQty) 'Vrijednost stavke'
FROM Narudzba_detalji AS ND INNER JOIN Narudzba_zaglavlje AS NZ ON NZ.SalesOrderID=ND.SalesOrderID  --Spojimo detalje narudzbe i zaglavlje narudzbe
WHERE ((NZ.Status=@status OR @status IS NULL) OR (MONTH(NZ.OrderDate)=@mjesecNarudzbe OR @mjesecNarudzbe IS NULL)
OR (DATEPART(QUARTER,NZ.ShipDate)=@kvartalIsporuke OR @kvartalIsporuke IS NULL)) AND ((ND.UnitPrice*ND.OrderQty) BETWEEN 100 AND 500)
ORDER BY [Vrijednost stavke] DESC
END
GO
--Nakon kreiranja procedure pokrenuti za sljedeæe vrijednosti parametara:
-- status = 3
-- mjesec_narudzbe = 3
-- kvartal_isporuke = 4
EXEC sp_Narudzbe_Stavke 3,3,4

--25.Kreirati proceduru sp_Narudzbe_Stavke_sum sa parametrima:
-- status, kratki cjelobrojni tip
-- mjesecNarudzbe, cjelobrojni tip
-- kvartalIsporuke, cjelobrojni tip
--Procedura je sljedeæe strukture:
-- Status
-- mjesec datuma narudžbe
-- kvartal datuma isporuke
-- ukupnu vrijednost narudžbe
--Uslov je da procedura dohvata samo one zapise u kojima je vrijednost kolone ukupno izmeðu 10000 i 5 000 000, 
--pri èemu æe prilikom pokretanja procedure rezultati biti sortirani u opadajuæem redoslijedu.
--Proceduru kreirati tako da je prilikom izvršavanja moguæe unijeti bilo koji broj parametara 
--(možemo ostaviti bilo koje polje bez unijetog parametra), te da procedura daje rezultat ako je zadovoljena 
--bilo koja od vrijednosti koje su navedene kao vrijednosti parametara.
GO
CREATE PROCEDURE sp_Narudzbe_Stavke_sum
(
@status SMALLINT=NULL,
@mjesecDatumaNarudzbe INT=NULL,
@kvartalIsporuke INT=NULL
)
AS
BEGIN
SELECT NZ.Status,MONTH(NZ.OrderDate) 'Mjesec datuma narudzbe',DATEPART(QUARTER,NZ.ShipDate) 'Kvartal datuma isporuke',
SUM(ND.UnitPrice*ND.OrderQty) 'Ukupna vrijednost narudzbe'
FROM Narudzba_detalji AS ND INNER JOIN Narudzba_zaglavlje AS NZ ON NZ.SalesOrderID=ND.SalesOrderID --Spojimmo detalje narudzbe i zaglavlje narudzbe
WHERE (NZ.status=@status OR @status IS NULL) OR (MONTH(NZ.OrderDate)=@mjesecDatumaNarudzbe OR @mjesecDatumaNarudzbe IS NULL)
OR (DATEPART(QUARTER,NZ.ShipDate)=@kvartalIsporuke OR @kvartalIsporuke IS NULL) 
GROUP BY NZ.Status,MONTH(NZ.OrderDate) ,DATEPART(QUARTER,NZ.ShipDate)
HAVING SUM(ND.UnitPrice*ND.OrderQty) BETWEEN 10000 AND 5000000 --Posto ukupnu vrijednost dobijamo agreg. fijom moramo staviti uslov u HAVING a ne u WHERE
ORDER BY [Ukupna vrijednost narudzbe] DESC
END
GO
--Nakon kreiranja procedure pokrenuti za sljedeæe vrijednosti parametara:
-- status = 1
-- mjesec_narudzbe = 3,kvartal_isporuke = 4,
EXEC sp_Narudzbe_Stavke_sum 1,3,4