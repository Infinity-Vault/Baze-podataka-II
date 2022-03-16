CREATE DATABASE ZadaciZaVjezbu2
GO

USE ZadaciZaVjezbu2

GO
CREATE SCHEMA Prodaja  --Kreiramo semu Prodaja
GO

CREATE TABLE Prodaja.Proizvodi
(
ProizvodID INT CONSTRAINT PK_ProizvodID PRIMARY KEY IDENTITY (1,1),
Naziv NVARCHAR(40) NOT NULL,
Cijena MONEY,
KolicinaNaSkladistu TINYINT,
Raspolozivost BIT NOT NULL
)

CREATE TABLE Prodaja.Kupci 
(
KupciID NCHAR(5) CONSTRAINT PK_KupciID PRIMARY KEY,
NazivKompanije NVARCHAR(40) NOT NULL,
Ime NVARCHAR(30),
Telefon NVARCHAR(24),
Faks NVARCHAR(24)
)

CREATE TABLE Prodaja.Narudzbe
(
NarudzbaID INT CONSTRAINT PK_NarudzbaID PRIMARY KEY IDENTITY (1,1),
DatumNarudzbe DATETIME,
DatumPrijema DATETIME,
DatumIsporuke DATETIME,
Drzava NVARCHAR(15),
Regija NVARCHAR(15),
Grad NVARCHAR(15),
Adresa NVARCHAR(60)
)

CREATE TABLE Prodaja.StavkeNarudzbe
(
NarudzbaID INT CONSTRAINT FK_StavkeNarudzbe_Narudzba FOREIGN KEY (NarudzbaID) REFERENCES Prodaja.Narudzbe(NarudzbaID),
ProizvodID INT CONSTRAINT FK_StavkeNarudzbe_Proizvod FOREIGN KEY (ProizvodID) REFERENCES Prodaja.Proizvodi(ProizvodID),
Cijena MONEY NOT NULL,
Kolicina TINYINT NOT NULL DEFAULT 1,  --Defaultna vrijednost 1
Popust FLOAT NOT NULL,
VrijednostStavki AS Cijena*Kolicina*(1-Popust) --Kreiramo "calculated" polje pomocu AS
CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY (NarudzbaID,ProizvodID) --Kreiramo kompozitni PK
)

SET IDENTITY_INSERT Prodaja.Proizvodi ON  --Radi autoincrement-a
INSERT INTO Prodaja.Proizvodi(ProizvodID,Naziv,Cijena,KolicinaNaSkladistu,Raspolozivost)
SELECT P.ProductID,P.ProductName,P.UnitPrice,P.UnitsInStock,P.Discontinued
FROM Northwind.dbo.Products AS P
SET IDENTITY_INSERT Prodaja.Proizvodi OFF

--KupciID nema autoincrement stoga nije potreban IDENTITY_INSERT
INSERT INTO Prodaja.Kupci (KupciID,NazivKompanije,Ime,Telefon,Faks)
SELECT K.CustomerID,K.CompanyName,K.ContactName,K.Phone,K.Fax
FROM Northwind.dbo.Customers AS K

SET IDENTITY_INSERT Prodaja.Narudzbe ON  --Radi autoincrement-a
INSERT INTO Prodaja.Narudzbe(NarudzbaID,DatumNarudzbe,DatumPrijema,DatumIsporuke,Drzava,Regija,Grad,Adresa)
SELECT N.OrderID,N.OrderDate,N.RequiredDate,N.ShippedDate,N.ShipCountry,N.ShipRegion,N.ShipCity,N.ShipAddress
FROM Northwind.dbo.Orders AS N
SET IDENTITY_INSERT Prodaja.Narudzbe OFF


INSERT INTO Prodaja.StavkeNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
SELECT SN.OrderID,SN.ProductID,SN.UnitPrice,SN.Quantity,SN.Discount
FROM Northwind.dbo.[Order Details] AS SN
WHERE SN.Quantity>4


SELECT *
FROM Prodaja.Proizvodi AS P
WHERE P.Cijena>100

INSERT INTO Prodaja.Proizvodi
VALUES ('Moj neki novi proizvod',25.00,12,1) --Dodamo proizvod

SELECT *
FROM Prodaja.Proizvodi --Da provjerimo jesmo li dodali novi proizvod

INSERT INTO Prodaja.StavkeNarudzbe  --Dodamo jedan novi record
VALUES (10248,1,250.00,15,10.00)

SELECT *
FROM Prodaja.StavkeNarudzbe  --Provjerimo je li dodan

DELETE
FROM Prodaja.StavkeNarudzbe --Pobrisemo sve stavke sa NarudzbaID 10248
WHERE NarudzbaID=10248

ALTER TABLE Prodaja.Proizvodi
ADD CONSTRAINT CK_Cijena CHECK(Cijena>=0.1)  --Onemogucimo korisniku da pri unosu unese cijenu manju od 0.1

ALTER TABLE Prodaja.Proizvodi
ADD  PotrebnoNaruciti CHAR(2)  --Kreiramo polje

UPDATE Prodaja.Proizvodi
SET PotrebnoNaruciti='DA' WHERE KolicinaNaSkladistu<10  --Updejtujemo

UPDATE Prodaja.Proizvodi
SET PotrebnoNaruciti='NE' WHERE KolicinaNaSkladistu>10 

SELECT *
FROM Prodaja.Proizvodi  --Provjerimo update
