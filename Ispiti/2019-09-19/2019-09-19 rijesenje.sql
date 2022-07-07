--1. Kreiranje baze i tabela
/*
a) Kreirati bazu pod vlastitim brojem indeksa.
*/

CREATE DATABASE IB200262
GO
USE IB200262

--b) Kreiranje tabela.
/*
Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
I. Kreirati tabelu kreditna sljedeće strukture:
	- kreditnaID - cjelobrojna vrijednost, primarni ključ
	- br_kreditne - 25 unicode karatera, obavezan unos
	- dtm_evid - datumska varijabla za unos datuma
*/

CREATE TABLE Kreditna 
(
kreditnaID INT PRIMARY KEY,
br_kreditne NVARCHAR(25) NOT NULL,
dtm_evid DATE
)

/*
II. Kreirati tabelu osoba sljedeće strukture:
	osobaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost, obavezan unos
	mail_lozinka - 128 unicode karaktera
	lozinka - 10 unicode karaktera 
	br_tel - 25 unicode karaktera
*/

CREATE TABLE Osoba 
(
osobaID INT PRIMARY KEY,
kreditnaID INT NOT NULL CONSTRAINT FK_Osoba_Kreditna FOREIGN KEY REFERENCES Kreditna(kreditnaID),
mail_lozinka NVARCHAR(128),
lozinka NVARCHAR(10),
br_tel NVARCHAR(25)
)

/*
III. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost
	br_narudzbe - 25 unicode karaktera
	br_racuna - 15 unicode karaktera
	prodavnicaID - cjelobrojna varijabla
*/

CREATE TABLE Narudzba
(
narudzbaID INT PRIMARY KEY,
kreditnaID INT CONSTRAINT FK_Narudzba_Kreditna FOREIGN KEY REFERENCES Kreditna(kreditnaID),
br_narudzbe NVARCHAR(25),
br_racuna NVARCHAR(15),
prodavnicaID INT
)

--10 bodova





-----------------------------------------------------------------------------------------------------------------------------
--2. Import podataka
/*
a) Iz tabele CreditCard baze AdventureWorks2017 importovati podatke u tabelu kreditna na sljedeći način:
	- CreditCardID -> kreditnaID
	- CardNUmber -> br_kreditne
	- ModifiedDate -> dtm_evid
*/
INSERT INTO Kreditna(kreditnaID,br_kreditne,dtm_evid)
SELECT CreditCardID, CardNumber, ModifiedDate
FROM AdventureWorks2017.Sales.CreditCard

/*
b) Iz tabela Person, Password, PersonCreditCard i PersonPhone baze AdventureWorks2017 koje se nalaze u šemama Sales i Person 
importovati podatke u tabelu osoba na sljedeći način:
	- BussinesEntityID -> osobaID
	- CreditCardID -> kreditnaID
	- PasswordHash -> mail_lozinka
	- PasswordSalt -> lozinka
	- PhoneNumber -> br_tel
*/
INSERT INTO Osoba(osobaID, kreditnaID, mail_lozinka, lozinka, br_tel)
SELECT P.BusinessEntityID, PCC.CreditCardID, PP.PasswordHash, PP.PasswordSalt, PPHONE.PhoneNumber
FROM AdventureWorks2017.Person.Person AS P
JOIN AdventureWorks2017.Person.Password AS PP ON PP.BusinessEntityID = P.BusinessEntityID
JOIN AdventureWorks2017.Sales.PersonCreditCard AS PCC ON PP.BusinessEntityID = PCC.BusinessEntityID
JOIN AdventureWorks2017.Person.PersonPhone AS PPHONE ON PPHONE.BusinessEntityID = PCC.BusinessEntityID

/*
c) Iz tabela Customer i SalesOrderHeader baze AdventureWorks2017 koje se nalaze u šemi Sales importovati podatke u tabelu 
narudzba na sljedeći način:
	- SalesOrderID -> narudzbaID
	- CreditCardID -> kreditnaID
	- PurchaseOrderNumber -> br_narudzbe
	- AccountNumber -> br_racuna
	- StoreID -> prodavnicaID
*/

--10 bodova
INSERT INTO Narudzba(narudzbaID, kreditnaID, br_narudzbe, br_racuna, prodavnicaID)
SELECT SOH.SalesOrderID, SOH.CreditCardID, SOH.PurchaseOrderNumber, SOH.AccountNumber, C.StoreID
FROM AdventureWorks2017.Sales.Customer AS C
JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH ON SOH.CustomerID = C.CustomerID




-----------------------------------------------------------------------------------------------------------------------------
/*
3. Kreirati pogled view_kred_mail koji će se sastojati od kolona: 
	- br_kreditne, 
	- mail_lozinka, 
	- br_tel i 
	- br_cif_br_tel, 
	pri čemu će se kolone puniti na sljedeći način:
	- br_kreditne - odbaciti prve 4 cifre 
 	- mail_lozinka - preuzeti sve znakove od 10. znaka (uključiti i njega) uz odbacivanje znaka jednakosti koji se nalazi na kraju lozinke
	- br_tel - prenijeti cijelu kolonu
	- br_cif_br_tel - broj cifara u koloni br_tel
*/

--10 bodova
GO

CREATE VIEW view_kred_mail AS
SELECT RIGHT(br_kreditne, LEN(br_kreditne) - 4) 'br_kreditne', SUBSTRING(O.mail_lozinka, 10, LEN(O.mail_lozinka -1)) 'mail_lozinka', O.br_tel, LEN(O.br_tel) 'br_cif_br_tel'
FROM Kreditna AS K
JOIN Osoba AS O ON O.kreditnaID = K.kreditnaID

GO

SELECT RIGHT(br_kreditne, LEN(br_kreditne) - 4)
FROM Kreditna 


-----------------------------------------------------------------------------------------------------------------------------
/*
4. Koristeći tabelu osoba kreirati proceduru proc_kred_mail u kojoj će biti sve kolone iz tabele. 
Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koji 
parametar bez unijete vrijednosti) uz uslov da se prenesu samo oni zapisi u kojima je unijet predbroj u koloni br_tel. 
Npr. (123) 456 789 je zapis u kojem je unijet predbroj. 
Nakon kreiranja pokrenuti proceduru za sljedeću vrijednost:
br_tel = 1 (11) 500 555-0132
*/

GO
CREATE PROCEDURE proc_kred_mail
(
@osobaID INT = null,
@kreditnaID INT= null,
@mail_lozinka NVARCHAR(128) = null,
@lozinka NVARCHAR(10) = null,
@br_tel NVARCHAR(25) = null
)
AS
BEGIN

SELECT *
FROM Osoba
WHERE @br_tel = br_tel


END
GO

EXEC proc_kred_mail @br_tel = '1 (11) 500 555-0132'

--10 bodova

-----------------------------------------------------------------------------------------------------------------------------
/*
5. 
a) Kopirati tabelu kreditna u kreditna1, 
*/
SELECT* 
INTO Kreditna1
FROM Kreditna
/*
b) U tabeli kreditna1 dodati novu kolonu dtm_izmjene čija je default vrijednost aktivni datum sa vremenom. Kolona je sa obaveznim unosom.
*/
ALTER TABLE Kreditna1
ADD dtm_izmjene DATETIME DEFAULT(GETDATE())

UPDATE Kreditna1
SET dtm_izmjene = GETDATE()
-----------------------------------------------------------------------------------------------------------------------------
/*
6.
a) U zapisima tabele kreditna1 kod kojih broj kreditne kartice počinje ciframa 1 ili 3 vrijednost broja kreditne kartice zamijeniti 
slučajno generisanim nizom znakova.
b) Dati ifnormaciju (prebrojati) broj zapisa u tabeli kreditna1 kod kojih se datum evidencije nalazi u intevalu do najviše 6 godina 
u odnosu na datum izmjene.
c) Napisati naredbu za brisanje tabele kreditna1
*/
UPDATE Kreditna1
SET br_kreditne = LEFT(CONVERT(NVARCHAR(255), NEWID()),25)
WHERE br_kreditne LIKE '1%' OR br_kreditne LIKE '3%' 
-----------------------------------------------------------------------------------------------------------------------------
/*
7.
a) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni br_narudzbe slučajno generisanim nizom znakova.*/
UPDATE Narudzba
SET br_narudzbe = LEFT(CONVERT(NVARCHAR(255), NEWID()),25)
WHERE br_narudzbe IS NULL
/*
b) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni prodavnicaID po sljedećem pravilu.
	- ako narudzbaID počinje ciframa 4 ili 5 u kolonu prodavnicaID preuzeti posljednje 3 cifre iz kolone narudzbaID  
	- ako narudzbaID počinje ciframa 6 ili 7 u kolonu prodavnicaID preuzeti posljednje 4 cifre iz kolone narudzbaID  
*/
--12 bodova
UPDATE narudzba
SET prodavnicaID =  RIGHT(narudzbaID, 3)
WHERE prodavnicaID IS NULL AND narudzbaID LIKE '[45]%'

UPDATE narudzba
SET prodavnicaID = RIGHT(narudzbaID, 4)
WHERE prodavnicaID IS NULL AND narudzbaID LIKE '[67]%' 
GO

-----------------------------------------------------------------------------------------------------------------------------
/*
8.
Kreirati proceduru kojom će se u tabeli narudzba izvršiti izmjena svih vrijednosti u koloni br_narudzbe u kojima se ne nalazi 
slučajno generirani niz znakova tako da se iz podatka izvrši uklanjanje prva dva znaka. 
*/

--8 bodova

CREATE PROCEDURE proc_skracivanje
AS
BEGIN
	UPDATE narudzba
	SET br_narudzbe = SUBSTRING(br_narudzbe, 3, LEN(br_narudzbe) - 3)
	WHERE LEN(br_narudzbe) < 25
END

EXEC proc_skracivanje

SELECT * FROM narudzba


-----------------------------------------------------------------------------------------------------------------------------
/*
9.
a) Iz tabele narudzba kreirati pogled koji će imati sljedeću strukturu:
	- duz_br_nar 
	- prebrojano - prebrojati broj zapisa prema dužini podatka u koloni br_narudzbe 
	  (npr. 1000 zapisa kod kojih je dužina podatka u koloni br_narudzbe 10)
Uslov je da se ne prebrojavaju zapisi u kojima je smješten slučajno generirani niz znakova. 
Provjeriti sadržaj pogleda.
b) Prikazati minimalnu i maksimalnu vrijednost kolone prebrojano
c) Dati pregled zapisa u kreiranom pogledu u kojima su vrijednosti u koloni prebrojano veće od srednje vrijednosti kolone prebrojano 
*/

--13 bodova




-----------------------------------------------------------------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Obrisati bazu.
*/

--2 boda
