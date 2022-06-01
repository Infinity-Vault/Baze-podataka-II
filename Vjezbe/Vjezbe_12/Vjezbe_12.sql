--1.	Kreirati bazu Function_ i aktivirati je.
CREATE DATABASE Function_
GO
USE Function_
--2.Kreirati tabelu Zaposlenici, te prilikom kreiranja uraditi insert podataka iz tabele Employee baze Pubs.
SELECT*
INTO Zaposlenici
FROM pubs.dbo.employee
--3.U tabeli Zaposlenici dodati izraèunatu (stalno pohranjenu) 
--kolonu Godina kojom æe se iz kolone hire_date izdvajati godina uposlenja.
ALTER TABLE Zaposlenici
ADD Godina AS YEAR(hire_date)
--4.Kreirati funkciju f_ocjena sa parametrom brojBodova,
--cjelobrojni tip koja æe vraæati poruke po sljedeæem pravilu:
--	- brojBodova < 55		nedovoljan broj bodova
--	- brojBodova 55 - 65		šest (6)
--	- broj Bodova 65 - 75		sedam (7)
--	- brojBodova 75 - 85		osam (8)
--	- broj Bodova 85 - 95		devet (9)
--	- brojBodova 95-100		deset (10)
--	- brojBodova >100		fatal error
--Kreirati testne sluèajeve.
GO
CREATE FUNCTION f_ocjena
(
@brojBodova INT
)
RETURNS VARCHAR(30)
AS 
BEGIN
	DECLARE @poruka VARCHAR(30) --Kreiramo lokalnu varijablu
	SET @poruka='nedovoljan broj bodova' --Slucaj ukoliko je manje od 55 bodova proslijedjeno (nijedan dole IF se nece pogoditi)
	IF @brojBodova BETWEEN 55 AND 64 SET @poruka='sest (6)' --BETWEEN uzima i granicne vrijednosti stoga idemo u ovim range-ovima
	IF @brojBodova BETWEEN 65 AND 74 SET @poruka='sest (7)'
	IF @brojBodova BETWEEN 75 AND 84 SET @poruka='sest (8)'
	IF @brojBodova BETWEEN 85 AND 94 SET @poruka='sest (9)'
	IF @brojBodova BETWEEN 95 AND 100 SET @poruka='sest (10)'
	IF @brojBodova >100 SET @poruka='fatal error'
	RETURN @poruka
END
GO
SELECT dbo.f_ocjena(58) --Testiranje funkcije
--5.	Kreirati funkciju f_godina koja vraæa podatke u formi tabele sa parametrom godina,
--cjelobrojni tip. Parametar se referira na kolonu godina tabele uposlenici, pri èemu se 
--trebaju vraæati samo oni zapisi u kojima je godina veæa od unijete vrijednosti parametra.
--Potrebno je da se prilikom pokretanja funkcije u rezultatu nalaze sve kolone tabele zaposlenici. 
--Provjeriti funkcioniranje funkcije unošenjem kontrolnih vrijednosti.
--GO koristimo kako bi oznacili jedan BATCH isto kao i kod VIEW sto smo radili
GO
CREATE FUNCTION f_godina
(
@Godina INT
)
RETURNS TABLE
RETURN 
SELECT*
FROM Zaposlenici AS Z
WHERE Z.Godina>=@Godina --Uslov
GO

--Testiranje:
SELECT*
FROM dbo.f_godina(1994)

--6.	Kreirati funkciju f_pub_id koja vraæa podatke u formi tabele sa parametrima:
--	- prva_cifra, kratki cjelobrojni tip
--	- job_id, kratki cjelobrojni tip
--Parametar prva_cifra se referira na prvu cifru kolone pub_id tabele uposlenici, 
--pri èemu je njegova zadana vrijednost 0. Parametar job_id se referira na kolonu 
--job_id tabele uposlenici. Potrebno je da se prilikom pokretanja funkcije 
--u rezultatu nalaze sve kolone tabele uposlenici. Provjeriti funkcioniranje 
--funkcije unošenjem vrijednosti za parametar job_id = 5
GO
CREATE FUNCTION f_pub_id
(
@prva_cifra TINYINT=0, --Napravimo da je default vrijednost 0, na taj nacin ne moramo slati  parametar.
@job_id INT
)
RETURNS TABLE
RETURN
SELECT*
FROM Zaposlenici AS Z
WHERE @prva_cifra=LEFT(Z.pub_id,1) AND @job_id=Z.job_id --Uslov
GO

SELECT*
FROM dbo.f_pub_id(DEFAULT,5) --DEFAULT kljucnom rijecju mozemo pozvati bilo koji parametar koji je postavljen na svoju default vrijednost.

--7.Kreirati tabelu Detalji, te prilikom kreiranja uraditi insert podataka iz 
--tabele Order Details baze Northwind. 
SELECT*
INTO Detalji
FROM Northwind.dbo.[Order Details]

--8.	Kreirati funkciju f_ukupno sa parametrima
--	- UnitPrice	novèani tip,
--	- Quantity	kratki cjelobrojni tip
--	- Discount	realni broj
--Funkcija æe vraæati rezultat tip decimal (10,2) koji æe raèunati po pravilu:
--	UnitPrice * Quantity * (1 - Discount)
GO 
CREATE FUNCTION f_ukupno
(
@UnitPrice MONEY,
@Quantity TINYINT,
@DISCOUNT REAL
)
RETURNS DECIMAL(10,2) --Definisemo povratnu vrijednost
AS
BEGIN 
	 DECLARE @vrati DECIMAL(10,2) --Deklarisemo  lokalnu varijablu
	 SET @vrati=@UnitPrice*@Quantity*(1-@DISCOUNT) --Postavimo joj vrijednost
	 RETURN @vrati  --Vratimo je
END
GO

--9.Koristeæi funkciju f_ukupno u tabeli detalji prikazati ukupnu vrijednost prometa po ID proizvoda.
SELECT D.ProductID,SUM(dbo.f_ukupno(D.UnitPrice,D.Quantity,D.Discount)) AS 'Ukupno sa popustom' --Posaljemo funkciji potrebne parametre.
FROM Detalji AS D
GROUP BY D.ProductID
--10.Koristeæi funkciju f_ukupno u tabeli detalji kreirati pogled v_f_ukupno u kojem æe biti prijazan ukupan promet po ID narudžbe.
GO
CREATE VIEW v_f_ukupno
AS
SELECT D.OrderID,SUM(dbo.f_ukupno(D.UnitPrice,D.Quantity,D.Discount)) AS 'Ukupno sa popustom' --Posaljemo funkciji potrebne parametre.
FROM Detalji AS D
GROUP BY D.OrderID
GO
--11.Iz pogleda v_f_ukupno odrediti najmanju i najveæu vrijednost sume.
SELECT MIN(VFU.[Ukupno sa popustom]) AS 'Najmanja vrijednost',MAX(VFU.[Ukupno sa popustom]) AS 'Najveca vrijednost'
FROM v_f_ukupno AS VFU
--12.Kreirati tabelu Kupovina, te prilikom kreiranja uraditi insert podataka iz tabele PurchaseOrderDetail baze AdventureWorks2017.
--Tabela æe sadržavati kolone:
--	- PurchaseOrderID, 
--	- PurchaseOrderDetailID,
--	- UnitPrice
--	- RejectedQty, 
--	- RazlikaKolicina koja predstavlja razliku izmeðu naruèene i primljene kolièine
SELECT POD.PurchaseOrderID,POD.PurchaseOrderDetailID,POD.UnitPrice,POD.RejectedQty,POD.OrderQty-POD.ReceivedQty AS RazlikaKolicina
INTO Kupovina
FROM AdventureWorks2019.Purchasing.PurchaseOrderDetail AS POD
--13.	Kreirati funkciju f_rejected koja vraæa podatke u formi tabele sa parametrima:
--	- RejectedQty	 DECIMAL (8,2)
--	- RazlikaKolicina  INT
--Parametar RejectedQty se referira na kolonu RejectedQty tabele kupovina, pri èemu je njegova zadana vrijednost 0. 
--Parametar RazlikaKolicina  se odnosi na kolonu RazlikaKolicina.
--Potrebno je da se prilikom pokretanja funkcije u rezultatu nalaze sve kolone tabele Kupovina. 
--Provjeriti funkcioniranje funkcije unošenjem vrijednosti za parametar RazlikaKolicina = 27,
--pri èemu æe upit vraæati sume UnitPrice po PurchaseOrderID.
--Sortirati po sumiranim vrijednostima u opadajuæem redoslijedu.
GO
CREATE FUNCTION f_rejected 
(
@RejectedQty DECIMAL (8,2)=0,
@RazlikaKolicina  INT
)
RETURNS TABLE
RETURN
SELECT*
FROM Kupovina AS K
WHERE K.RejectedQty=@RejectedQty AND K.RazlikaKolicina=@RazlikaKolicina
GO

SELECT FR.PurchaseOrderID,SUM(FR.UnitPrice) AS 'Suma unitprice'
FROM dbo.f_rejected(DEFAULT,27) AS FR --Koristimo nasu funkciju kao data source
GROUP BY FR.PurchaseOrderID
ORDER BY [Suma unitprice] DESC
--14.	Kreirati bazu Trigger_ i aktivirati je.
CREATE DATABASE Trigger_
GO
USE Trigger_
--15.	Kreirati tabelu Autori, te prilikom kreiranja uraditi insert podataka iz tabele Authors baze Pubs.
SELECT*
INTO Autori
FROM pubs.dbo.authors
--16.	Kreirati tabelu Autori_log strukture:
--	- log_id int IDENTITY (1,1)
--	- au_id VARCHAR (11)
--	- dogadjaj VARCHAR (3)
--	- mod_date DATETIME
CREATE TABLE Autori_log
(
  log_id int IDENTITY (1,1),
  au_id VARCHAR (11),
  dogadjaj VARCHAR (3),
  mod_date DATETIME
)
--17.Nad tabelom Autori kreirati okidaè t_ins_autori kojim æe se prilikom inserta podataka u tabelu autori izvršiti
--insert podataka u tabelu Autori_log.
GO
CREATE TRIGGER t_ins_autori 
ON  Autori
AFTER INSERT
AS
BEGIN
	INSERT INTO Autori_log
	SELECT au_id,'INS',GETDATE() --Ubacimo vrijednosti koje se nalaze iz virtualne inserted tabele,GETDATE() koristimo za mod_date jer je to trenutni datum.
	FROM inserted 
END
GO
--18.	U tabelu autori insertovati zapis 
--'1', 'Ringer', 'Albert', '801 826-0752', '67 Seventh Av.', 'Salt Lake City', 'UT', 84152, 1
INSERT INTO Autori
VALUES('1', 'Ringer', 'Albert', '801 826-0752', '67 Seventh Av.', 'Salt Lake City', 'UT', 84152, 1)
--'2', 'Green', 'Marjorie', '415 986-7020', '309 63rd St. #411', 'Oakland',	'CA', 94618, 1
INSERT INTO Autori
VALUES('2', 'Green', 'Marjorie', '415 986-7020', '309 63rd St. #411', 'Oakland',	'CA', 94618, 1)
--Provjeriti stanje u tabelama autori i autori_log.
SELECT* FROM Autori
SELECT* FROM Autori_log

--19.Nad tabelom Autori kreirati okidaè t_upd_autori kojim æe se prilikom update podataka u tabeli Autori izvršiti 
--insert podataka u tabelu autori_log.
GO
CREATE TRIGGER t_upd_autori
ON Autori
AFTER UPDATE
AS
BEGIN
	INSERT INTO Autori_log 
	SELECT au_id,'UPD',GETDATE() --Mijenjamo samo dogadjaj
	FROM inserted --Za update koristimo opet virtualnu tabelu inserted
END
GO
--20.	U tabeli Autori napraviti update zapisa u kojem je 
--au_id = 998-72-3567 tako što æe se vrijednost kolone au_lname postaviti na prezime. 
UPDATE Autori
SET au_lname='prezime'
WHERE au_id='998-72-3567'
--Provjeriti stanje u tabelama Autori i Autori_log.
SELECT* FROM Autori
SELECT* FROM Autori_log

--21.Nad tabelom Autori kreirati okidaè t_del_autori kojim æe se prilikom brisanja podataka u tabeli Autori izvršiti 
--insert podataka u tabelu Autori_log.
GO
CREATE TRIGGER t_del_autori
ON Autori
AFTER DELETE
AS
BEGIN
	INSERT INTO Autori_log
	SELECT au_id,'DEL',GETDATE()
	FROM deleted --Koristimo drugu virtualnu tabelu deleted
END
GO
--22.U tabeli Autori obrisati zapis u kojem je au_id = 267-41-2394.  
DELETE Autori
WHERE au_id='267-41-2394'
--Provjeriti stanje u tabelama Autori i Autori_log.
SELECT* FROM Autori
SELECT* FROM Autori_log
--23.	Kreirati tabelu Autori_instead_log strukture:
--	- log_id INT IDENTITY (1,1),
--	- au_id VARCHAR (11),
--	- dogadjaj VARCHAR (15),
--	- mod_date DATETIME
CREATE TABLE Autori_instead_log
(
  log_id INT IDENTITY (1,1),
  au_id VARCHAR (11),
  dogadjaj VARCHAR (15),
  mod_date DATETIME
)
--24.Nad tabelom Autori kreirati okidaè t_instead_ins_autori kojim æe se onemoguæiti insert podataka u tabelu Autori. 
--Okidaè treba da vraæa poruku da insert nije izvršen.
GO
CREATE  OR ALTER TRIGGER t_instead_ins_autori
ON Autori
INSTEAD OF INSERT
AS
BEGIN
	INSERT INTO Autori_instead_log
	SELECT au_id,'INS',GETDATE()
	FROM inserted 
--PRINT('Insert nije izvrsen')
--Ili
SELECT 'Insert nije izvrsen'
END
GO
--25.U tabelu Autori insertovati zapis 
--'3', 'Ringer', 'Albert', '801 826-0752', '67 Seventh Av.', 'Salt Lake City', 'UT', 84152, 1
INSERT INTO Autori
VALUES('3', 'Ringer', 'Albert', '801 826-0752', '67 Seventh Av.', 'Salt Lake City', 'UT', 84152, 1)
--Provjeriti stanje u tabelama Autori, Autori_log i Autori_instead_log.
SELECT* FROM Autori
SELECT* FROM Autori_log
SELECT* FROM Autori_instead_log --Nigdje nam nije izvrsen insert radi kreiranog triggera

--26.Nad tabelom Autori kreirati okidaè t_instead_upd_autori kojim æe se onemoguæiti update podataka u tabelu Autori.
--Okidaè treba da vraæa poruku da update nije izvršen.
GO
CREATE OR ALTER TRIGGER t_instead_upd_autori
ON Autori
INSTEAD OF UPDATE
AS 
BEGIN
	INSERT INTO Autori_instead_log
	SELECT au_id,'UPD',GETDATE()
	FROM inserted
PRINT('Update nije izvrsen')
END
GO
--27.U tabeli autori pokušati update zapisa u kojem je au_id = 172-32-1176 tako što æe se vrijednost kolone contract postaviti na  0.
UPDATE Autori
SET contract=0
WHERE au_id='172-32-1176'
--Provjeriti stanje u tabelama autori i autori_instead_log.
SELECT* FROM Autori
SELECT* FROM Autori_log
SELECT* FROM Autori_instead_log
--28.Nad tabelom autori kreirati okidaè t_instead_del_autori kojim æe se onemoguæiti delete podataka u tabelu autori.
--Okidaè treba da vraæa poruku da delete nije izvršen.
GO
CREATE OR ALTER TRIGGER t_instead_del_autori
ON Autori
INSTEAD OF DELETE
AS
BEGIN
	INSERT INTO Autori_instead_log
	SELECT  au_id,'DEL',GETDATE()
	FROM deleted
PRINT('Delete nije izvrsen')
END
GO
--29.U tabeli autori pokušati obrisati zapis u kojem je au_id = 172-32-1176. 
DELETE Autori
WHERE au_id='172-32-1176'
--Provjeriti stanje u tabelama autori i autori_instead_log.
SELECT* FROM Autori
SELECT* FROM Autori_log
SELECT* FROM Autori_instead_log
--30.Iskljuæiti okidaè t_instead_ins_autori.
ALTER TABLE Autori --Prvo alterujemo tabelu nad kojom je napravljen trigger
DISABLE  TRIGGER t_instead_ins_autori --Onda onemogucimo trigger
--31.U tabelu autori insertovati zapis 
--'3', 'Ringer', 'Albert', '801 826-0752', '67 Seventh Av.', 'Salt Lake City', 'UT', 84152, 1
INSERT INTO Autori
VALUES('3', 'Ringer', 'Albert', '801 826-0752', '67 Seventh Av.', 'Salt Lake City', 'UT', 84152, 1)
--Provjeriti stanje u tabelama autori, autori_log i autori_instead_log.
SELECT* FROM Autori
SELECT* FROM Autori_log
SELECT* FROM Autori_instead_log

--32.Iskljuèiti sve okidaèe nad tabelom autori.
ALTER TABLE Autori --Alterujemo tabelu
DISABLE TRIGGER ALL --Pa onda onemogucimo sve sa kljucnom rjecju ALL
--33.Ukljuèiti sve okidaèe nad tabelom autori.
ALTER TABLE Autori
ENABLE TRIGGER ALL --Ukljucimo sve triggere nad tabelom Autori
