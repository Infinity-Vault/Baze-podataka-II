--1 Kreirati bazu za svojim brojm indeksa
CREATE DATABASE ispitni090922_1
GO
USE ispitni090922_1
--2 U kreiranoj bazi podataka kreirati tabele slijedecom strukturom
--a)	Uposlenici
--•	UposlenikID, 9 karaktera fiksne duzine i primarni kljuc,
--•	Ime 20 karaktera obavezan unos,
--•	Prezime 20 karaktera obavezan unos
--•	DatumZaposlenja polje za unos datuma i vremena obavezan unos
--•	Opis posla 50 karaktera obavezan unos
CREATE TABLE Uposlenik
(
	UposlenikID CHAR(9) PRIMARY KEY,
	Ime VARCHAR(20) NOT NULL,
	Prezime VARCHAR(20) NOT NULL,
	DatumZaposlenja DATETIME NOT NULL,
	OpisPosla VARCHAR(50) NOT NULL
)

--b)	Naslovi
--•	NaslovID 6 karaktera primarni kljuc,
--•	Naslov 80 karaktera obavezan unos,
--•	Tip 12 karaktera fiksne duzine obavezan unos
--•	Cijena novcani tip podatka,
--•	NazivIzdavaca 40 karaktera,
--•	GradIzdavaca 20 karaktera,
--•	DrzavaIzdavaca 30 karaktera
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

--c)	Prodaja
--•	ProdavnicaID 4 karktera fiksne duzine, strani i primarni kljuc
--•	Broj narudzbe 20 karaktera primarni kljuc,
--•	NaslovID 6 karaktera strani i primarni kljuc
--•	DatumNarudzbe polje za unos datuma i vremena obavezan unos
--•	Kolicina skraceni cjelobrojni tip obavezan unos
CREATE TABLE Prodaja
(
	ProdavnicaID CHAR(4) CONSTRAINT FK_Prodavnica FOREIGN KEY 
	REFERENCES Prodavnice(ProdavnicaID),
	BrojNarudzbe VARCHAR(20),
	NaslovID VARCHAR(6) CONSTRAINT FK_Naslov FOREIGN KEY
	REFERENCES Naslovi(NaslovID),
	DatumNarudzbe DATETIME NOT NULL,
	Kolicina SMALLINT NOT NULL,
	CONSTRAINT PK_Prodaja PRIMARY KEY(ProdavnicaID, NaslovID, BrojNarudzbe)
)

--d)	Prodavnice
--•	ProdavnicaID 4 karaktera fiksne duzine primarni kljuc
--•	NazivProdavnice 40 karaktera
--•	Grad 40 karaktera
CREATE TABLE Prodavnice
(
	ProdavnicaID CHAR(4) PRIMARY KEY,
	NazivProdavnice VARCHAR(40),
	Grad VARCHAR(40)
)

--3 Iz baze podataka pubs u svoju bazu prebaciti slijedece podatke
--a)	U tabelu Uposlenici dodati sve uposlenike
--•	emp_id -> UposlenikID
--•	fname -> Ime
--•	lname -> Prezime
--•	hire_date - > DatumZaposlenja
--•	job_desc - > Opis posla
INSERT INTO Uposlenici 
(UposlenikID, Ime, Prezime, DatumZaposlenja, OpisPosla)
SELECT
	e.emp_id,
	e.fname,
	e.lname,
	e.hire_date,
	j.job_desc
FROM pubs.dbo.employee AS e
INNER JOIN pubs.dbo.jobs AS j
ON e.job_id=j.job_id

--b)	U tabelu naslovi dodati sve naslove, na mjestu gdje nema pohranjenih podataka o --nazivima izdavaca zamijeniti vrijednost sa nepoznat izdavac
--•	Title_id -> NaslovID
--•	Title->Naslov
--•	Type->Tip
--•	Price->Cijena
--•	Pub_name->NazivIzdavaca
--•	City->GradIzdavaca
--•	Country-DrzavaIzdavaca
INSERT INTO Naslovi
(NaslovID, Naslov, Tip, Cijena, NazivIzdavaca, GradIzdavaca, DrzavaIzdavaca)
SELECT
	t.title_id,
	t.title,
	t.type,
	t.price,
	p.pub_name,
	p.city,
	p.country
FROM pubs.dbo.titles AS t
INNER JOIN pubs.dbo.publishers AS p
ON t.pub_id=p.pub_id

--c)	U tabelu prodaja dodati sve stavke iz tabele prodaja
--•	Stor_id->ProdavnicaID
--•	Order_num->BrojNarudzbe
--•	titleID->NaslovID,
--•	ord_date->DatumNarudzbe
--•	qty->Kolicina
INSERT INTO Prodaja
(ProdavnicaID, BrojNarudzbe, NaslovID, DatumNarudzbe, Kolicina)
SELECT
	s.stor_id,
	s.ord_num,
	s.title_id,
	s.ord_date,
	s.qty
FROM pubs.dbo.sales AS s

--d)	U tabelu prodavnice dodati sve prodavnice
--•	Stor_id->prodavnicaID
--•	Store_name->NazivProdavnice
--•	City->Grad
INSERT INTO Prodavnice
(ProdavnicaID, NazivProdavnice, Grad)
SELECT
	s.stor_id,
	s.stor_name,
	s.city
FROM pubs.dbo.stores AS s

--4
--a)	Kreirati proceduru sp_delete_uposlenik kojom ce se obrisati odredjeni zapis iz --tabele uposlenici. OBAVEZNO kreirati testni slucaj na kreiranu proceduru
GO
CREATE PROCEDURE sp_delete_uposlenik
(
	@UposlenikID CHAR(9)
)
AS
BEGIN
	DELETE FROM Uposlenici
	WHERE UposlenikID=@UposlenikID
END

SELECT * FROM Uposlenici
EXEC sp_delete_uposlenik 'A-C71970F'

--b)	Kreirati tabelu Uposlenici_log slijedeca struktura
--Uposlenici_log
--•	UposlenikID 9 karaktera fiksne duzine
--•	Ime 20 karaktera
--•	Prezime 20 karakera,
--•	DatumZaposlenja polje za unos datuma i vremena
--•	Opis posla 50 karaktera
CREATE TABLE Uposlenici_log
(
	UposlenikID CHAR(9),
	Ime VARCHAR(20) NOT NULL,
	Prezime VARCHAR(20) NOT NULL,
	DatumZaposlenja DATETIME NOT NULL,
	OpisPosla VARCHAR(50) NOT NULL
)
--c)	Nad tabelom uposlenici kreirati okidac t_ins_Uposlenici koji ce prilikom --birsanja podataka iz tabele Uposlenici izvristi insert podataka u tabelu --Uposlenici_log. OBAVEZNO kreirati tesni slucaj
GO
CREATE TRIGGER t_ins_Uposlenici 
ON Uposlenici
AFTER DELETE
AS
BEGIN
	INSERT INTO Uposlenici_log
	SELECT * 
	FROM DELETED
END

SELECT * FROM Uposlenici_log
EXEC sp_delete_uposlenik 'A-R89858F'

--d)	Prikazati sve uposlenike zenskog pola koji imaju vise od 10 godina radnog -staza,- a rade na Production ili Marketing odjelu. Upitom je potrebno pokazati -spojeno -ime i prezime uposlenika, godine radnog staza, te odjel na kojem rade -uposlenici. -Rezultate upita sortirati u rastucem redoslijedu prema nazivu odjela,- te -opadajucem prema godinama radnog staza (AdventureWorks2019)
SELECT CONCAT(p.FirstName, ' ', p.LastName) ImePrezime,
DATEDIFF(YEAR, e.HireDate, GETDATE()) Staz,
d.Name Odjel
FROM AdventureWorks2017.HumanResources.Employee AS e
INNER JOIN AdventureWorks2017.Person.Person AS p
ON e.BusinessEntityID=p.BusinessEntityID
INNER JOIN AdventureWorks2017.HumanResources.EmployeeDepartmentHistory AS edh
ON edh.BusinessEntityID=e.BusinessEntityID
INNER JOIN AdventureWorks2017.HumanResources.Department AS d
ON edh.DepartmentID=d.DepartmentID
WHERE e.Gender='F' AND DATEDIFF(YEAR, e.HireDate, GETDATE())>10
AND d.Name IN ('Production', 'Marketing') 
AND edh.EndDate IS NULL
ORDER BY d.Name, DATEDIFF(YEAR, e.HireDate, GETDATE()) DESC

--e)	Kreirati upit kojim ce se prikazati koliko ukupno je naruceno komada proizvoda --za svaku narudzbu pojedinacno, te ukupnu vrijednost narudzbe sa i bez popusta. --Uzwti u obzir samo one narudzbe kojima je datum narudzbe do datuma isporuke --proteklo manje od 7 dana (ukljuciti granicnu vrijednost), a isporucene su kupcima --koji zive na podrucju Madrida, Minhena,Seatle. Rezultate upita sortirati po broju- -komada u opadajucem redoslijedu, a vrijednost je potrebno zaokruziti na dvije --decimale (Northwind)
SELECT o.OrderID Narudzba, SUM(od.Quantity) UkupnoKomada,
ROUND(SUM(od.UnitPrice*Quantity), 2) VrijednostBezPopusta,
ROUND(SUM((od.UnitPrice*(1-od.Discount))*od.Quantity), 2) VrijednostSaPopustom
FROM Northwind.dbo.[Order Details] AS od
INNER JOIN Northwind.dbo.Orders AS o
ON od.OrderID=o.OrderID
WHERE DATEDIFF(DAY, o.OrderDate, o.ShippedDate)<=7
AND o.ShipCity IN ('Madrid', 'Seattle', 'München')
GROUP BY o.OrderID
ORDER BY SUM(od.Quantity) DESC

--f)	Napisati upit kojim ce se prikazati brojNarudzbe,datumNarudzbe i sifra. --Prikazati samo one zapise iz tabele Prodaja ciji broj narudzbe ISKLJICIVO POCINJE --jednim slovom, ili zavrsava jednim slovom (Novokreirana baza)
--Sifra se sastoji od slijedecih vrijednosti:
--•	Brojevi (samo brojevi) uzeti iz broja narudzbi,
--•	Karakter /
--•	Zadnja dva karaktera godine narudbze /
--•	Karakter /
--•	Id naslova
--•	Karakter /
--•	Id prodavnice
--Za broj narudzbe 772a sifra je 722/19/PS2091/6380
--Za broj narudzbe N914008 sifra je 914008/19/PS2901/6380
SELECT p.BrojNarudzbe, p.DatumNarudzbe,
REPLACE(
REPLACE(SUBSTRING(REPLACE(p.BrojNarudzbe, PATINDEX('%[0-9]%', p.BrojNarudzbe), LEN(p.BrojNarudzbe)), PATINDEX('%[0-9]%', REPLACE(p.BrojNarudzbe, PATINDEX('%[0-9]%', p.BrojNarudzbe), LEN(p.BrojNarudzbe))), LEN(p.BrojNarudzbe)),'a',' ')
+ '/' 
+ REVERSE(RIGHT(REVERSE(YEAR(p.DatumNarudzbe)), 2))
+ '/'
+ p.NaslovID 
+ '/'
+ p.ProdavnicaID, ' ', '') Sifra
FROM Prodaja AS p
WHERE p.BrojNarudzbe LIKE '[A-Z][0-9]%' OR p.BrojNarudzbe LIKE '%[0-9][A-Z]'

--5
--a)	Prikazati nazive odjela gdje radi najmanje odnosno najvise uposlenika --(AdventureWorks2019)
SELECT * FROM
(
SELECT TOP 1 d.Name, COUNT(*) BrojRadnika
FROM AdventureWorks2017.HumanResources.Department AS d
INNER JOIN AdventureWorks2017.HumanResources.EmployeeDepartmentHistory AS edh
ON d.DepartmentID=edh.DepartmentID
INNER JOIN AdventureWorks2017.HumanResources.Employee AS e
ON edh.BusinessEntityID=e.BusinessEntityID
GROUP BY d.Name
ORDER BY 2 DESC
) AS sq1
UNION
SELECT * FROM
(
SELECT TOP 1 d.Name, COUNT(*) BrojRadnika
FROM AdventureWorks2017.HumanResources.Department AS d
INNER JOIN AdventureWorks2017.HumanResources.EmployeeDepartmentHistory AS edh
ON d.DepartmentID=edh.DepartmentID
INNER JOIN AdventureWorks2017.HumanResources.Employee AS e
ON edh.BusinessEntityID=e.BusinessEntityID
GROUP BY d.Name
ORDER BY 2
) AS sq2

--b)	Prikazati spojeno ime i prezime osobe,spol, ukupnu vrijednost redovnih bruto --prihoda, ukupnu vrijednost vandrednih prihoda, te sumu ukupnih vandrednih prihoda --i ukupnih redovnih prihoda. Uslov je da dolaze iz Latvije, Kine ili Indonezije a --poslodavac kod kojeg rade je registrovan kao javno ustanova (Prihodi)
SELECT CONCAT(o.Ime, ' ', o.PrezIme) ImePrezime, o.Spol,
SUM(rp.Bruto) RedovniPrihodi,
SUM(vp.IznosVanrednogPrihoda) VanredniPrihodi,
SUM(rp.Bruto+vp.IznosVanrednogPrihoda) UkupniPrihodi
FROM prihodi.dbo.Osoba AS o
INNER JOIN prihodi.dbo.RedovniPrihodi AS rp
ON o.OsobaID=rp.OsobaID
INNER JOIN prihodi.dbo.VanredniPrihodi AS vp
ON o.OsobaID=vp.OsobaID
INNER JOIN prihodi.dbo.Drzava AS d
ON o.DrzavaID=d.DrzavaID
INNER JOIN prihodi.dbo.Poslodavac AS p
ON o.PoslodavacID=p.PoslodavacID
INNER JOIN prihodi.dbo.TipPoslodavca AS tp
ON p.TipPoslodavca=tp.TipPoslodavcaID
WHERE d.Drzava IN ('Latvia', 'China', 'Indonesia')
AND tp.OblikVlasnistva LIKE 'javno ustanova'
GROUP BY CONCAT(o.Ime, ' ', o.PrezIme), o.Spol

--c)	Modificirati prethodni upit 5_b na nacin da se prikazu samo oni zapisi kod -kojih- je suma ukupnih bruto i ukupnih vanderednih prihoda (SumaBruto+SumaNeto) -veca od -10000KM Retultate upita sortirati prema ukupnoj vrijednosti prihoda -obrnuto -abecedno(Prihodi)
SELECT CONCAT(o.Ime, ' ', o.PrezIme) ImePrezime, o.Spol,
SUM(rp.Bruto) RedovniPrihodi,
SUM(vp.IznosVanrednogPrihoda) VanredniPrihodi,
SUM(rp.Bruto+vp.IznosVanrednogPrihoda) UkupniPrihodi
FROM prihodi.dbo.Osoba AS o
INNER JOIN prihodi.dbo.RedovniPrihodi AS rp
ON o.OsobaID=rp.OsobaID
INNER JOIN prihodi.dbo.VanredniPrihodi AS vp
ON o.OsobaID=vp.OsobaID
INNER JOIN prihodi.dbo.Drzava AS d
ON o.DrzavaID=d.DrzavaID
INNER JOIN prihodi.dbo.Poslodavac AS p
ON o.PoslodavacID=p.PoslodavacID
INNER JOIN prihodi.dbo.TipPoslodavca AS tp
ON p.TipPoslodavca=tp.TipPoslodavcaID
WHERE d.Drzava IN ('Latvia', 'China', 'Indonesia')
AND tp.OblikVlasnistva LIKE 'javno ustanova'
GROUP BY CONCAT(o.Ime, ' ', o.PrezIme), o.Spol
HAVING SUM(rp.Bruto+vp.IznosVanrednogPrihoda)>10000
ORDER BY SUM(rp.Bruto+vp.IznosVanrednogPrihoda) DESC
