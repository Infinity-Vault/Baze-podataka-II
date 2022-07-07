/*
Napomena:
A.
Prilikom  bodovanja rješenja prioritet ima rezultat 
koji upit treba da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a rezultat tog upita se koristi
u narednim zadacima, tada se rješenja narednih zadataka, 
bez obzira na tačnost koda, ne boduju punim brojem bodova, 
jer ni ta rješenja ne mogu vratiti tačan rezultat 
(broj zapisa, vrijednosti agregatnih funkcija...).
B.
Tokom pisanja koda obratiti pažnju na tekst zadatka 
i ono što se traži zadatkom. Prilikom pregleda rada pokreće se 
kod koji se nalazi u sql skripti i 
sve ono što nije urađeno prema zahtjevima zadatka 
ili je pogrešno urađeno predstavlja grešku. 
*/

------------------------------------------------
/*
BODOVANJE
	Maksimalni broj bodova:		80
	Prag prolaznosti:			44
RASPON OCJENA
	bodovi			ocjena
	0	-	43		5
	44	-	58		6
	59	-	73		7
	74	-	80		8
*/
------------------------------------------------



------------------------------------------------
--1. 
/*
Kreirati bazu podataka pod vlastitim brojem indeksa
i aktivirati je.
*/


CREATE DATABASE IB200262
GO
USE IB200262

---------------------------------------------------------------------------
--Prilikom kreiranja tabela voditi računa o njihovom međusobnom odnosu.
---------------------------------------------------------------------------
/*
a) 
Kreirati tabelu prodavac koja će imati sljedeću strukturu:
	- prodavac_id, cjelobrojni tip, primarni ključ
	- naziv_posla, 50 unicode karaktera
	- dtm_rodj, datumski tip
	- bracni_status, 1 karakter
	- prod_kvota, novčani tip
	- bonus, novčani tip
*/
CREATE TABLE Prodavac
(
prodavac_id INT PRIMARY KEY,
naziv_posla NVARCHAR(50),
dtm_rodj DATE,
bracni_status CHAR,
prod_kvota MONEY,
bonus MONEY
)
/*
b) 
Kreirati tabelu prodavnica koja će imati sljedeću strukturu:
	- prodavnica_id, cjelobrojni tip, primarni ključ
	- naziv_prodavnice, 50 unicode karaktera
	- prodavac_id, cjelobrojni tip
*/
CREATE TABLE Prodavnica 
(
prodavnica_id INT PRIMARY KEY,
naziv_prodavnice NVARCHAR(50),
prodavac_id INT CONSTRAINT FK_Prodavnica_Prodavac FOREIGN KEY REFERENCES Prodavac(prodavac_id)
)
/*
c) 
Kreirati tabelu kupac_detalji koja će imati sljedeću strukturu:
	- detalj_id, cjelobrojni tip, primarni ključ, automatsko punjenje sa početnom vrijednošću 1 i inkrementom 1
	- kupac_id, cjelobrojni tip, primarni ključ
	- prodavnica_id, cjelobrojni tip
	- br_rac, 10 karaktera
	- dtm_narudz, datumski tip
	- kolicina, skraćeni cjelobrojni tip
	- cijena, novčani tip
	- popust, realni tip
*/
--10 bodova
CREATE TABLE kupac_detalji 
(
detalj_id INT IDENTITY(1,1),
kupac_id INT,
CONSTRAINT PK_kupac_detalji PRIMARY KEY(detalj_id,kupac_id),
prodavnica_id INT CONSTRAINT FK_kupacDetalji_Prodavnica FOREIGN KEY REFERENCES Prodavnica(prodavnica_id),
br_rac CHAR(10),
dtm_narudz DATE,
kolicina SMALLINT,
cijena MONEY,
popust REAL
)

--2.
/*
a)
Koristeći tabele HumanResources.Employee i Sales.SalesPerson
baze AdventureWorks2017 zvršiti insert podataka u 
tabelu prodavac prema sljedećem pravilu:
	- BusinessEntityID -> prodavac_id
	- JobTitle -> naziv_posla
	- BirthDate -> dtm_rodj
	- MaritalStatus -> bracni_status
	- SalesQuota -> prod_kvota
	- Bonus -> nžbonus
*/
INSERT INTO Prodavac(prodavac_id, naziv_posla, dtm_rodj, bracni_status, prod_kvota, bonus)
SELECT E.BusinessEntityID, E.JobTitle,E.BirthDate, E.MaritalStatus, SP.SalesQuota, Sp.Bonus
FROM AdventureWorks2017.HumanResources.Employee AS E
INNER JOIN AdventureWorks2017.Sales.SalesPerson AS SP ON SP.BusinessEntityID = E.BusinessEntityID
/*
b)
Koristeći tabelu Sales.Store baze AdventureWorks2017 
izvršiti insert podataka u tabelu prodavnica 
prema sljedećem pravilu:
	- BusinessEntityID -> prodavnica_id
	- Name -> naziv_prodavnice
	- SalesPersonID -> prodavac_id
*/*
INSERT INTO Prodavnica(prodavnica_id, naziv_prodavnice, prodavac_id)
SELECT S.BusinessEntityID, S.Name, S.SalesPersonID
FROM AdventureWorks2017.Sales.Store AS S
/*
b)
Koristeći tabele Sales.Customer, Sales.SalesOrderHeader i SalesOrderDetail
baze AdventureWorks2017 izvršiti insert podataka u tabelu kupac_detalji
prema sljedećem pravilu:
	- CustomerID -> kupac_id
	- StoreID -> prodavnica_id
	- AccountNumber -> br_rac
	- OrderDate -> dtm_narudz
	- OrderQty -> kolicina
	- UnitPrice -> cijena
	- UnitPriceDiscount -> popust
Uslov je da se ne dohvataju zapisi u kojima su 
StoreID i PersonID NULL vrijednost
*/
--10 bodova
INSERT INTO kupac_detalji(kupac_id, prodavnica_id, br_rac, dtm_narudz, kolicina, cijena, popust) 
SELECT C.CustomerID, C.StoreID, C.AccountNumber, SOH.OrderDate, SOD.OrderQty, SOD.UnitPrice, SOD.UnitPriceDiscount
FROM AdventureWorks2017.Sales.Customer AS C
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH ON SOH.CustomerID= C.CustomerID
INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE C.StoreID IS NOT NULL AND C.PersonID IS NOT NULL

--3.
/*
a)
U tabeli prodavac dodati izračunatu kolonu god_rodj
u koju će se smještati godina rođenja prodavca.
*/
ALTER TABLE Prodavac
ADD god_rodj AS YEAR(dtm_rodj)

/*
b)
U tabeli kupac_detalji promijeniti tip podatka
kolone cijena iz novčanog u decimalni tip oblika (8,2)
*/
ALTER TABLE kupac_detalji 
ALTER COLUMN cijena DECIMAL(8,2)
/*
c)
U tabeli kupac_detalji dodati standardnu kolonu
lozinka tipa 20 unicode karaktera.
*/
ALTER TABLE kupac_detalji
ADD lozinka NVARCHAR(20)
/*
d) 
Kolonu lozinka popuniti tako da bude spojeno 
10 slučajno generisanih znakova i 
numerički dio (bez vodećih nula) iz kolone br_rac
*/
--10 bodova
UPDATE kupac_detalji
SET lozinka = LEFT(CONVERT(nvarchar(255), NEWID()), 10) + RIGHT(br_rac,5)

SELECT lozinka
FROM kupac_detalji



--4.
/*
Koristeći tabele prodavnica i kupac_detalji
dati pregled sumiranih količina po 
nazivu prodavnice i godini naručivanja.
Sortirati po nazivu prodavnice.
*/
--6 bodova

SELECT P.naziv_prodavnice, YEAR(KD.dtm_narudz) 'Godina narucivanja', SUM(KD.kolicina)
FROM Prodavnica AS P
INNER JOIN kupac_detalji AS KD ON KD.prodavnica_id = p.prodavnica_id
GROUP BY P.naziv_prodavnice, YEAR(KD.dtm_narudz)
ORDER BY 1 ASC


--5.
/*
Kreirati pogled v_prodavac_cijena sljedeće strukture:
	- prodavac_id
	- bracni_status
	- sum_cijena
Uslov je da se u pogled dohvate samo oni zapisi u 
kojima je sumirana vrijednost veća od 1000000.
*/
--8 bodova
GO
CREATE VIEW v_prodavac_cijena AS
SELECT P.prodavac_id, P.bracni_status, SUM(KD.cijena) 'sum_cijena'
FROM Prodavac AS P 
JOIN Prodavnica AS PR ON PR.prodavac_id = P.prodavac_id
JOIN kupac_detalji AS KD ON KD.prodavnica_id = PR.prodavnica_id
GROUP BY P.prodavac_id, P.bracni_status
HAVING SUM(KD.cijena) > 1000000
GO




--6.
/*
Koristeći pogled v_prodavac_cijena
kreirati proceduru p_prodavac_cijena sa parametrom
bracni_status čija je zadata (default) vrijednost M.
Uslov je da se procedurom dohvataju zapisi u kojima je 
vrijednost u koloni sum_cijena veća od srednje vrijednosti kolone sum_cijena.
Obavezno napisati kod za pokretanje procedure.
*/
--8 bodova
GO
CREATE PROCEDURE p_prodavac_cijena 
(
@bracni_status CHAR = M 
)
AS
BEGIN

SELECT*
FROM v_prodavac_cijena
WHERE bracni_status = @bracni_status AND sum_cijena > (SELECT AVG(sum_cijena)
					FROM v_prodavac_cijena)

END
GO

exec p_prodavac_cijena





--7.
/*
Iz tabele kupac_detalji prikazati zapise u kojima je 
vrijednost u koloni cijena jednaka 
minimalnoj, odnosno, maksimalnoj vrijednosti u ovoj koloni.
Upit treba da vraća kolone kupac_id, prodavnica_id i cijena.
Sortirati u rastućem redoslijedu prema koloni cijena.
*/
--8 bodova
SELECT KD.kupac_id, KD.prodavnica_id, KD.cijena
FROM kupac_detalji AS KD
WHERE KD.cijena = 
(
SELECT MIN(cijena)
FROM kupac_detalji) 
OR CIJENA = 
(SELECT MAX(cijena)
FROM kupac_detalji)
					
--8.
/*
a)
U tabeli kupac_detalji kreirati kolonu
cijena_sa_popustom tipa decimal (8,2).
*/
ALTER TABLE kupac_detalji
ADD cijena_sa_popustom DECIMAL(8,2)
/*
b) 
Koristeći tabelu kupac_detalji
kreirati proceduru p_popust sa parametrom 
godina koji će odgovarati godini iz datum naručivanja.
Procedura će vršiti update kolone cijena_sa_popustom
ako je vrijednost parametra veća od 2013, 
inače se daje poruka 'transakcija nije izvršena'.
Testirati funkcionisanje procedure za vrijednost 
parametra godina 2014.
Obavezno napisati kod za provjeru sadržaja tabele 
nakon što se pokrene procedura.
*/
GO
CREATE PROCEDURE p_popust 
(
@godina INT
)
AS
BEGIN

SELECT*
FROM kupac_detalji

END
GO
--8 bodova






--9.
/*
a)
U tabeli prodavac kreirati kolonu min_kvota tipa decimal (8,2).
i na njoj postaviti ograničenje da se
ne može unijeti negativna vrijednost.
b)
Kreirati skalarnu funkciju f_kvota sa parametrom prod_kvota.
Funkcija će vraćati rezultat tipa decimal (8,2)
koji će se računati po pravilu:
	10% od prod_kvota
c) 
Koristeći funkciju f_kvota izvršiti update
kolone min_kvota u tabeli prodavac
*/
--8 bodova






--10.
/*
a)
Kreirati tabelu prodavac_log strukture:
	- log_id, primarni ključ, automatsko punjenje sa početnom vrijednošću 1 i inkrementom 1 
	- prodavac_id int
	- min_kvota decimal (8,2)
	- dogadjaj varchar (3)
	- mod_date datetime
b)
Nad tabelom prodavac kreirati okidač t_ins_prod
kojim će se prilikom inserta podataka u 
tabelu prodavac izvršiti insert podataka u 
tabelu prodavac_log sa naznakom aktivnosti 
(insert, update ili delete).
c)
U tabelu autori insertovati zapis
291, Sales Manager, 1985-09-30, M, 250000.00, 985.00, -20000.00
Ako je potrebno izvršiti podešavanja 
koja će omogućiti insrt zapisa. 
d)
Obavezno napisati kod za pregled sadržaja 
tabela prodavac i prodavac_log.
*/
--4 boda