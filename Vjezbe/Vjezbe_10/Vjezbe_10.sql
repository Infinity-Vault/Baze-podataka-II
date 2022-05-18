--1.Kreirati bazu View_ i aktivirati je.
CREATE DATABASE View_  --Kreiramo bazu
GO
USE View_ --Koristimo bazu

--2.U bazi View kreirati pogled v_Employee sljedeæe strukture:
--	- prezime i ime uposlenika kao polje ime i prezime, 
--	- teritoriju i 
--	- regiju koju pokrivaju
--Uslov je da se dohvataju uposlenici koji su stariji od 60 godina. (Northwind)

GO  --GO stavimo iznad i ispod ukoliko nam intellisense izbacuje error da view mora biti u jednom batch-u
CREATE VIEW v_Employee
AS
SELECT CONCAT(E.LastName,' ',E.FirstName) AS ImePrezime,
T.TerritoryID,R.RegionID
FROM Northwind.dbo.Employees AS E INNER JOIN Northwind.dbo.EmployeeTerritories AS ET  --Spojimo uposlenika i uposlenik teritoriju
ON ET.EmployeeID=E.EmployeeID
INNER JOIN Northwind.dbo.Territories AS T ON T.TerritoryID=ET.TerritoryID --Spojimo teritoriju i uposlenik teritoriju
INNER JOIN Northwind.dbo.Region AS R ON R.RegionID=T.RegionID --Spojimo regiju i teritoriju
WHERE DATEDIFF(YEAR,E.BirthDate,GETDATE())>60  --Uslov
GO

--3.Koristeæi pogled v_Employee prebrojati broj teritorija koje uposlenik pokriva
--po jednoj regiji. Rezultate sortirati prema broju teritorija u opadajuæem redoslijedu, 
--te prema imenu i prezimenu u rastuæem redoslijedu. (Northwind)

SELECT VE.RegionID,COUNT(*) AS Brojteritorija,VE.ImePrezime
FROM v_Employee AS VE
GROUP BY VE.RegionID,VE.ImePrezime
ORDER BY Brojteritorija DESC,VE.ImePrezime ASC

--4.Kreirati pogled v_Sales sljedeæe strukture: (Adventureworks2017)
--	- Id kupca
--	- Ime i prezime kupca
--	- Godinu narudžbe
--	- Vrijednost narudžbe bez troškova prevoza i takse

GO
CREATE VIEW v_Sales 
AS 
SELECT C.CustomerID,P.FirstName,P.LastName,YEAR(SOH.OrderDate) AS Godina,
SOH.SubTotal AS VrijednostBezPrevozaITakse  --SubTotal je polje za vrijednost bez uracunate taxe i troskova prevoza
FROM AdventureWorks2019.Sales.Customer AS C INNER JOIN AdventureWorks2019.Person.Person AS P --Spojimo osobu i kupca
ON P.BusinessEntityID=C.PersonID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH ON SOH.CustomerID=C.CustomerID --Spojimo zaglavlje narudzbe i kupca
GO

--5.Koristeæi pogled v_Sales dati pregled sumarno ostvarenih prometa po osobi i godini.

SELECT VS.CustomerID,VS.Godina, SUM(VS.VrijednostBezPrevozaITakse) AS Promet --Ukupni promet
FROM v_Sales AS VS
GROUP BY VS.CustomerID,VS.Godina

--6.Koristeæi pogled v_Sales dati pregled zapisa iz 2013. godine u kojima je vrijednost narudžbe 
--u intervalu 10% u odnosu na srednju vrijednost narudžbe iz 2013 godine. Pregled treba da sadrži
--ime i prezime kupca i vrijednost narudžbe, sortirano prema vrijednosti narudžbe obrnuto abecedno.

SELECT DISTINCT VS.FirstName,VS.LastName,VS.VrijednostBezPrevozaITakse  --Distinct jer ne zelim zapise koji se ponavljaju (jedan kupac vise narudzbi)
FROM v_Sales AS VS
WHERE VS.Godina=2013  --Uslov: pregled zapisa iz 2013 godine
--Provjerimo da li je vrijednost narudzbe u donjih 10% ili gornjih 10% prosjecne vrijednosti u 2013 godini
AND VS.VrijednostBezPrevozaITakse BETWEEN (SELECT AVG(VS.VrijednostBezPrevozaITakse)
											FROM v_Sales AS VS
											WHERE VS.Godina=2013)-0.1*(SELECT AVG(VS.VrijednostBezPrevozaITakse)
																		FROM v_Sales AS VS
																		WHERE VS.Godina=2013) --Donja granica
																		AND 
																		(SELECT AVG(VS.VrijednostBezPrevozaITakse)
																				FROM v_Sales AS VS
																				WHERE VS.Godina=2013)+0.1*(SELECT AVG(VS.VrijednostBezPrevozaITakse)
																											FROM v_Sales AS VS
																											WHERE VS.Godina=2013) --Gornja granica
ORDER BY VS.VrijednostBezPrevozaITakse DESC

--7.Kreirati tabelu Zaposlenici te prilikom kreiranja uraditi insert podataka iz tabele Employees 
--baze Northwind.
SELECT*
INTO Zaposlenici --INTO kreira i ubaci u tabelu
FROM Northwind.dbo.Employees 

--8.Kreirati pogled v_Zaposlenici koji æe dati pregled ID-a, imena, prezimena i države zaposlenika.

GO
CREATE VIEW v_Zaposlenici
AS
SELECT Z.EmployeeID,Z.FirstName,Z.LastName,Z.Country
FROM Zaposlenici AS Z
GO


--9.Modificirati prethodno kreirani pogled te onemoguæiti unos podataka kroz pogled za uposlenike koji 
--ne dolaze iz Amerike ili Velike Britanije. 

GO
CREATE OR ALTER  VIEW v_Zaposlenici  --Koristimo CREATE OR ALTER kako bi smo modifikovali pogled koji je prethodno kreiran
AS
SELECT Z.EmployeeID,Z.FirstName,Z.LastName,Z.Country
FROM Zaposlenici AS Z
WHERE Z.Country  IN ('USA','UK') --Zaposlenik mora biti iz USA ili UK
WITH CHECK OPTION
GO

--10.Testirati prethodno modificiran view unosom ispravnih i neispravnih podataka (napisati 2 testna sluèaja).
INSERT INTO v_Zaposlenici VALUES ('Ime','Prezime','UK')  --Ovaj prodje test jer je country UK dozvoljen
INSERT INTO v_Zaposlenici VALUES ('Ime','Prezime','BIH') --Ovaj ne prodje test jer je country BIH a ne USA ili UK

--Ono sto modificiramo u pogledu (dodamo, obrisemo) mora biti vidljivo i u tabeli iz koje pogled kupi podatke.

--11.Koristeæi tabele Purchasing.Vendor i Purchasing.PurchaseOrderDetail kreirati v_Purchasing pogled sljedeæe strukture:
--	- Name iz tabele Vendor 
--	- PurchaseOrderID iz tabele Purchasing.PurchaseOrderDetail
--	- DueDate iz tabele Purchasing.PurchaseOrderDetail
--	- OrderQty iz tabele Purchasing.PurchaseOrderDetail
--	- UnitPrice iz tabele Purchasing.PurchaseOrderDetail
--	- ukupno kao proizvod OrderQty i UnitPrice
--Uslov je da se dohvate samo oni zapisi kod kojih DueDate pripada 1. ili 3. kvartalu. (AdventureWorks2017)
GO 
CREATE OR ALTER VIEW v_Purchasing
AS 
SELECT V.Name,POD.PurchaseOrderID,POD.DueDate,
POD.OrderQty,POD.UnitPrice,SUM(POD.UnitPrice*POD.OrderQty) AS Ukupno
FROM AdventureWorks2019.Purchasing.Vendor AS V INNER JOIN  --Spojimo dobavljaca i zaglavlje kupovne narudzbe
AdventureWorks2019.Purchasing.PurchaseOrderHeader AS POH ON POH.VendorID=V.BusinessEntityID
INNER JOIN AdventureWorks2019.Purchasing.PurchaseOrderDetail AS POD ON POD.PurchaseOrderID=POH.PurchaseOrderID --Spojimo detalj kupovne narudzbe i zaglavlje kuopvne narudbze
WHERE DATEPART(QUARTER,POD.DueDate)=1 OR DATEPART(QUARTER,POD.DueDate)=3 --Uslov
GROUP BY  V.Name,POD.PurchaseOrderID,POD.DueDate,
POD.OrderQty,POD.UnitPrice
GO

--12.Koristeæi pogled v_Purchasing dati pregled svih dobavljaèa(e) koji je u sklopu narudžbe imao 
--stavke èija je ukupni broj stavki jednak minimumu, odnosno, maksimumu ukupnog broja stavki (proizvoda)
--po narudžbi.
--Pregled treba imati sljedeæu strukturu:
--	- Name
--	- PurchaseOrderID
--	- prebrojani broj

--Napravimo ukupan broj stavki u zasebnom view:
GO
CREATE  VIEW v_BrojStavki
AS
SELECT VP.Name,VP.PurchaseOrderID,COUNT(*) AS BrojStavki
FROM v_Purchasing AS VP
GROUP BY VP.Name,VP.PurchaseOrderID
GO

SELECT VBS.Name,VBS.PurchaseOrderID,VBS.BrojStavki
FROM v_BrojStavki AS VBS
WHERE VBS.BrojStavki=(SELECT MIN(VBS.BrojStavki) --Poredimo sa min
						FROM v_BrojStavki AS VBS) OR VBS.BrojStavki=(SELECT MAX(VBS.BrojStavki) --Poredimo sa max
																		FROM v_BrojStavki AS VBS)
		

--13.U bazi radna kreirati tabele Osoba i Uposlenik.
--Strukture tabela su sljedeæe:
--
--- Osoba
--	OsobaID			cjelobrojna varijabla, primarni kljuè
--	VrstaOsobe		            2 unicode karaktera, obavezan unos
--	Prezime			50 unicode karaktera, obavezan unos
--	Ime				50 unicode karaktera, obavezan unos

CREATE TABLE Osoba
(
OsobaID INT PRIMARY KEY IDENTITY(1,1), --Primarni kljuc, increment 1 po 1
VrstaOsobe NCHAR(2) NOT NULL,
Prezime NVARCHAR(50) NOT NULL,
Ime NVARCHAR(50) NOT NULL
)
--- Uposlenik
--	UposlenikID		             cjelobrojna varijabla, primarni kljuè
--	NacionalniID	                        15 unicode karaktera, obavezan unos
--	LoginID			 256 unicode karaktera, obavezan unos
--	RadnoMjesto		            50 unicode karaktera, obavezan unos
--	DtmZapos		            datumska varijabla

CREATE TABLE Uposlenik
(
UposlenikID INT PRIMARY KEY IDENTITY(1,1),
NacionalniID NCHAR(15) NOT NULL,
LoginID NVARCHAR(256) NOT NULL,
RadnoMjesto NVARCHAR(50) NOT NULL,
DtmZapos DATE 
)

--Spoj tabela napraviti prema spoju izmeðu tabela
--Person.Person i HumanResources.Employee baze AdventureWorks2017.
ALTER TABLE Uposlenik  --Idemo iz tabele uposlenik u tabelu osoba 
ADD CONSTRAINT FK_Uposlenik_Osoba FOREIGN KEY (UposlenikID) REFERENCES Osoba(OsobaID )
			--^ ime spoljnog kljuca			  ^atribut koji je FK		    ^referenca od FK (na sta pokazuje FK)

--14.Nakon kreiranja tabela u tabelu Osoba kopirati odgovarajuæe podatke iz tabele Person.Person,

SET IDENTITY_INSERT Osoba ON --Kako ne bi imali prebacivanjem okidanje naseg IDENTITY countera
INSERT INTO Osoba (OsobaID,VrstaOsobe,Prezime,Ime) --INSERT INTO samo prekopira u tabelu vrijednosti (tabela u koju se kopira mora postojati)
SELECT   P.BusinessEntityID,P.PersonType,P.LastName,P.FirstName
FROM AdventureWorks2019.Person.Person AS P
SET IDENTITY_INSERT Osoba OFF

--a u tabelu Uposlenik kopirati odgovarajuæe zapise iz tabele HumanResources.Employee.

SET IDENTITY_INSERT Uposlenik ON
INSERT INTO Uposlenik(UposlenikID,NacionalniID,LoginID,RadnoMjesto,DtmZapos)
SELECT E.BusinessEntityID,E.NationalIDNumber,E.LoginID,E.JobTitle,E.HireDate
FROM AdventureWorks2019.HumanResources.Employee AS E
SET IDENTITY_INSERT Uposlenik OFF

--15.Kreirati pogled (view) v_Osoba_Uposlenik nad tabelama Uposlenik i Osoba koji æe sadržavati sva polja obje tabele.

GO
CREATE VIEW v_Osoba_Uposlenik 
AS
SELECT*
FROM Osoba INNER JOIN Uposlenik ON OsobaID=UposlenikID --Spojimo po vezi koju smo kreirali
GO

--16.Koristeæi pogled v_Osoba_Uposlenik prebrojati koliko se osoba zaposlilo po godinama.

SELECT YEAR(VOU.DtmZapos) AS GodinaZaposljenja, COUNT(VOU.UposlenikID) AS BrojZaposlenihPoGodini --Brojimo UposlenikID
FROM v_Osoba_Uposlenik AS VOU 
GROUP BY YEAR(VOU.DtmZapos) --Grupisemo po godinama
ORDER BY GodinaZaposljenja ASC