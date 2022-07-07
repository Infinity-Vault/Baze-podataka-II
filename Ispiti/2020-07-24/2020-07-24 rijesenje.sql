/*
Napomena:
A.
Prilikom  bodovanja rješenja prioritet ima rezultat koji upit treba da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, 
jer ni ta rješenja ne mogu vratiti tačan rezultat (broj zapisa, vrijednosti agregatnih funkcija...).
B.
Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i 
sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. 
*/

------------------------------------------------
--1
/*
Kreirati bazu podataka pod vlastitim brojem indeksa.
*/

CREATE DATABASE IB200262
GO
USE IB200262


/*Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
a) Kreirati tabelu radnik koja će imati sljedeću strukturu:
	- radnikID, cjelobrojna varijabla, primarni ključ
	- drzavaID, 15 unicode karaktera
	- loginID, 256 unicode karaktera
	- sati_god_odmora, cjelobrojna varijabla
	- sati_bolovanja, cjelobrojna varijabla
*/

CREATE TABLE Radnik 
(
radnikID INT PRIMARY KEY,
drzavaID NVARCHAR(15),
loginID NVARCHAR(255),
sati_god_odmora INT,
sati_bolovanja INT
)

/*
b) Kreirati tabelu nabavka koja će imati sljedeću strukturu:
	- nabavkaID, cjelobrojna varijabla, primarni ključ
	- status, cjelobrojna varijabla
	- nabavaljacID, cjelobrojna varijabla
	- br_racuna, 15 unicode karaktera
	- naziv_nabavljaca, 50 unicode karaktera
	- kred_rejting, cjelobrojna varijabla
*/

CREATE TABLE Nabavka 
(
nabavkaID INT PRIMARY KEY,
status INT,
nabavljacID INT,
br_racuna NVARCHAR(15),
naziv_dobavljaca NVARCHAR(50),
kred_rejting INT
)

/*
c) Kreirati tabelu prodaja koja će imati sljedeću strukturu:
	- prodavacID, cjelobrojna varijabla, primarni ključ
	- prod_kvota, novčana varijabla
	- bonus, novčana varijabla
	- proslogod_prodaja, novčana varijabla
	- naziv_terit, 50 unicode karaktera
*/
--10 bodova

CREATE TABLE Prodaja 
(
prodavacID INT PRIMARY KEY,
prod_kvota MONEY,
bonus MONEY,
proslogod_prodaja MONEY,
naziv_terit NVARCHAR(50)
)

--------------------------------------------
--2. Import podataka
/*
a) Iz tabele HumanResources.Employee AdventureWorks2017 u tabelu radnik importovati podatke po sljedećem pravilu:
	- BusinessEntityID -> radnikID
	- NationalIDNumber -> drzavaID
	- LoginID -> loginID
	- VacationHours -> sati_god_odmora
	- SickLeaveHours -> sati_bolovanja
*/

INSERT INTO Radnik(radnikID, drzavaID, loginID, sati_god_odmora, sati_bolovanja)
SELECT BusinessEntityID, NationalIDNumber, LoginID, VacationHours, SickLeaveHours 
FROM AdventureWorks2017.HumanResources.Employee

/*
b) Iz tabela Purchasing.PurchaseOrderHeader i Purchasing.Vendor baze AdventureWorks2017 u tabelu nabavka importovati podatke po sljedećem pravilu:
	- PurchaseOrderID -> nabavkaID
	- Status -> status
	- EmployeeID -> radnikID
	- AccountNumber -> br_racuna
	- Name -> naziv_nabavljaca
	- CreditRating -> kred_rejting
*/

ALTER TABLE Nabavka
ADD radnikID INT CONSTRAINT FK_Nabavka_Radnik FOREIGN KEY REFERENCES Radnik(radnikID)

INSERT INTO Nabavka(nabavkaID, status, radnikID, br_racuna, naziv_dobavljaca, kred_rejting)
SELECT PurchaseOrderID, Status, EmployeeID, AccountNumber, Name, CreditRating
FROM AdventureWorks2017.Purchasing.PurchaseOrderHeader AS POH
INNER JOIN AdventureWorks2017.Purchasing.Vendor AS V ON V.BusinessEntityID= POH.VendorID
/*
c) Iz tabela Sales.SalesPerson i Sales.SalesTerritory baze AdventureWorks2017 u tabelu prodaja importovati podatke po sljedećem pravilu:
	- BusinessEntityID -> prodavacID
	- SalesQuota -> prod_kvota
	- Bonus -> bonus
	- SalesLastYear iz Sales.SalesPerson -> proslogod_prodaja
	- Name -> naziv_terit
*/
--10 bodova
INSERT INTO Prodaja(prodavacID, prod_kvota, bonus, proslogod_prodaja, naziv_terit)
SELECT SP.BusinessEntityID, SP.SalesQuota, SP.Bonus, SP.SalesLastYear, ST.Name
FROM AdventureWorks2017.Sales.SalesPerson AS SP
INNER JOIN AdventureWorks2017.Sales.SalesTerritory AS ST ON SP.TerritoryID = ST.TerritoryID

------------------------------------------
/*
3.
a) Iz tabela radnik i nabavka kreirati pogled view_drzavaID koji će imati sljedeću strukturu: 
	- nabavkaID,
	- loginID,
	- status
	- naziv nabavljača,
	- kreditni rejting
Uslov je da u pogledu budu zapisi u kojima je kreditni rejting veći od 1.
b) Koristeći prethodno kreirani pogled prebrojati broj obavljenih nabavki prema kreditnom rejtingu. Npr. kreditni rejting 8 se pojavljuje 20 puta. Pregled treba da sadrži oznaku kreditnog rejtinga i ukupan broj obavljenih nabavki.
*/
--10 bodova
GO
CREATE VIEW view_drzavaID
AS
SELECT N.nabavkaID, R.loginID, N.status, N.naziv_dobavljaca, N.kred_rejting
FROM Radnik AS R 
INNER JOIN Nabavka AS N ON N.radnikID = R.radnikID
WHERE N.kred_rejting > 1
GO

SELECT kred_rejting, COUNT(nabavkaID)
FROM view_drzavaID
GROUP BY kred_rejting
-----------------------------------------------
/*
4.
Kreirati proceduru koja će imati istu strukturu kao pogled kreiran u prethodnom zadatku. Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koji parametar bez unijete vrijednosti), uz uslov da je status veći od 2. Pokrenuti proceduru za kreditni rejting 3 i 5.
*/
--10 bodova
GO
CREATE PROCEDURE zad4	
@NabavkaID INT = NULL,
@LoginID NVARCHAR(255) = NULL,
@Status INT = NULL, 
@NazivDobavljaca NVARCHAR(50) = NULL,
@KredRejting INT = NULL
AS
SELECT N.nabavkaID, R.loginID, N.status, N.naziv_dobavljaca, N.kred_rejting
FROM IB200262.dbo.Nabavka AS N
INNER JOIN IB200262.dbo.Radnik AS R ON R.radnikID = N.radnikID
WHERE IIF(@NabavkaID IS NULL, N.nabavkaID, @NabavkaID) = N.nabavkaID AND
IIF(@LoginID IS NULL, R.LoginID, @LoginID) = R.LoginID AND
IIF(@NabavkaID IS NULL, N.nabavkaID, @NabavkaID) = N.nabavkaID AND
IIF(@Status IS NULL, N.status, IIF(@Status <= 2, N.status, @Status)) = N.status AND
IIF(@NazivDobavljaca IS NULL, N.naziv_dobavljaca, @NazivDobavljaca) = N.naziv_dobavljaca AND
IIF(@KredRejting IS NULL, N.kred_rejting , @KredRejting) = N.kred_rejting
GO
-------------------------------------------
/*
5.
a) Kreirati pogled nabavljaci_radnici koji će se sastojati od kolona naziv dobavljača i prebrojani_broj radnika. prebrojani_broj je podatak kojim se 
prebrojava broj radnika s kojima je dobavljač poslovao. Obavezno napisati kod kojim će se izvršiti pregled sadržaja pogleda sortiran po ukupnom broju.
b) Kreirati proceduru kojom će se iz pogleda kreiranog pod a) preuzeti zapisi u kojima je prebrojani_broj manji od 50. Proceduru kreirati tako da je 
prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koji parametar bez unijete vrijednosti). 
Pokrenuti proceduru za vrijednosti prebrojani_broj = 1 i 2.	
*/
--15 bodova

CREATE VIEW nabavljaci_radnici 
AS
SELECT N.naziv_dobavljaca 'Naziv dobavljaca', COUNT(N.radnikID) 'prebrojani_broj'
FROM Nabavka AS N
GROUP BY N.naziv_dobavljaca

SELECT* 
FROM nabavljaci_radnici
ORDER BY 2 DESC
--------------------------------------------
/*
6.
a) U tabeli radnik dodati kolonu razlika_sati kao cjelobrojnu varijablu sa obaveznom default vrijednošću 0.
b) U koloni razlika_sati ostaviti 0 ako su sati bolovanja veći od godišnjeg odmora, inače u kolonu smjestiti vrijednost razlike između sato_bolovanja i sati_god_odmora.
c) Kreirati pogled view_sati u kojem će biti poruka da li radnik ima više sati godišnjeg odmora ili bolovanja. Ako je više bolovanja daje se poruka "bolovanje", inače "godisnji". Pogled treba da sadrži ID radnika i poruku.
*/
--10 bodova

ALTER TABLE Radnik
ADD razlika_sati INT DEFAULT(0)

UPDATE Radnik
SET razlika_sati = IIF(sati_bolovanja > sati_god_odmora, 0, sati_bolovanja - sati_god_odmora)

SELECT* FROM Radnik

GO
CREATE VIEW view_sati AS
SELECT R.radnikID, IIF(R.sati_bolovanja > R.sati_god_odmora, 'bolovanje', 'godisnji') 'Poruka'
FROM Radnik AS R
GO

SELECT*
from view_sati
-----------------------------------------------
/*
7.
Koristeći tabelu prodaja kreirati pogled view_prodaja sljedeće strukture:
	- prodavacID
	- naziv_terit
	- razlika prošlogodišnje prodaje i srednje vrijednosti prošlogodišnje prodaje.
Uslov je da se dohvate zapisi u kojima je bonus bar za 1000 veći od minimalne vrijednosti bonusa
*/
--10 bodova




------------------------------------------
/*
8.
U koloni drzavaID tabele radnik izvršiti promjenu svih vrijednosti u kojima je broj cifara neparan broj. Promjenu izvršiti tako što će se u umjesto postojećih vrijednosti unijeti slučajno generisani niz znakova.
*/
--10 bodova


---------------------------------------
/*
9.
Iz tabela nabavka i radnik kreirati pogled view_sifra_transakc koja će se sastojati od sljedećih kolona: 
	- naziv dobavljača,
	- sifra_transakc
Podaci u koloni sifra_transakc će se formirati spajanjem karaktera imena iz kolone loginID tabele radnik (ime je npr. ken, NE ken0) i riječi iz kolone br_racuna (npr. u LITWARE0001 riječ je LITWARE) tabele nabavka, između kojih je potrebno umetnuti donju crtu (_). 
Uslov je da se ne dohvataju duplikati (prikaz jedinstvenih vrijednosti) u koloni sifre_transaks.
Obavezno napisati kod za pregled sadržaja pogleda.
*/
--13 bodova



-----------------------------------------------
--10.
/*
Kreirati backup baze na default lokaciju, obrisati bazu, a zatim izvršiti restore baze. 
Uslov prihvatanja koda je da se može izvršiti.
*/
--2 boda
