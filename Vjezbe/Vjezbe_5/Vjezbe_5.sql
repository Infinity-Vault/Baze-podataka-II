--1.	Prikazati koli�inski najmanju i najve�u vrijednost stavke narud�be. (Northwind)
 USE Northwind  --Prebacimo se da radimo sa bazom Northwind
 GO

 SELECT MIN(OD.Quantity) AS 'Najmanja vrijednost kolicine', MAX(OD.Quantity) AS 'Najveca vrijednost kolicine'  --Agregatnim funkcijama damo parametre
 FROM [Order Details] AS OD

--2.	Prikazati koli�inski najmanju i najve�u vrijednost stavke narud�be za svaku od narud�bi pojedina�no. (Northwind)
SELECT  OD.OrderID, MIN(OD.Quantity) AS 'Najmanja vrijednost kolicine', MAX(OD.Quantity) AS 'Najveca vrijednost kolicine'  --OrderID jer zelimo pojedinacno min i max za svaku narudzbu
FROM [Order Details] AS OD
GROUP BY OD.OrderID  --Posto selektujemo polje tabele koje se ne nalazi ni u jednoj agregatnoj funkciji, onda moramo grupisati po tom polju

--3.	Prikazati ukupnu zaradu od svih narud�bi. (Northwind)
SELECT SUM(OD.UnitPrice * OD.Quantity) AS 'Ukupna zarada od svih narudzbi'  --Uzimamo u obzir sve recorde tabele, jer ne grupisemo ni po cemu
FROM [Order Details] AS OD

--4.	Prikazati ukupnu vrijednost za svaku narud�bu pojedina�no uzimaju�i u obzir i popust. 
--Rezultate zaokru�iti na dvije decimale i sortirati prema ukupnoj vrijednosti naru�be u opadaju�em redoslijedu. (Northwind)
--Uzmemo u obzir popust i isto tako zaokruzimo sa round:
SELECT OD.OrderID,ROUND(SUM(OD.UnitPrice * OD.Quantity*(1-OD.Discount)),2) AS 'Ukupna vrijednost od svake narudzbe sa popustom'  
FROM [Order Details] AS OD
GROUP BY OD.OrderID
ORDER BY 2 DESC  --Poredamo opadajucim redosljedom

--5.	Prebrojati stavke narud�be gdje su naru�ene koli�ine ve�e od 50 (uklju�uju�i i grani�nu vrijednost). 
--Uzeti u obzir samo one stavke narud�be gdje je odobren popust. (Northwind)

SELECT COUNT(*) AS 'Broj narudzbi cija je kolicina >=50 i popust je > od 0' --COUNT(*) broji i NULL recorde u tabeli dok COUNT(neko_polje) nece brojati proslijedjena polja ako su oni NULL
FROM [Order Details] AS OD
WHERE OD.Quantity>=50 AND OD.Discount>0  --Ukljucimo >=50 i povezemo odobreni popust sa AND (oba uslova moraju biti zadovoljena)

--6.	Prikazati prosje�nu cijenu stavki narud�be za svaku narud�bu pojedina�no. 
--Sortirati po prosje�noj cijeni u opadaju�em redoslijedu. (Northwind)

SELECT OD.OrderID,AVG(OD.UnitPrice) AS 'Prosjecna cijena stavke'
FROM [Order Details] AS OD
GROUP BY OD.OrderID --Kako bi mogli pokrenuti upit moramo grupisati po polju koje nije dio agregatne fije
ORDER BY 2 DESC  --Opadajuci redosljed

--7.	Prikazati broj narud�bi sa odobrenim popustom. (Northwind)
SELECT COUNT(*) AS 'Broj narudzbi sa odobrenim popustom'
FROM [Order Details] AS OD
WHERE OD.Discount>0

--8.	Prikazati broj narud�bi u kojima je unesena regija kupovine. (Northwind)
SELECT COUNT(*)  --Brojati ce i NULL polja jer imamo (*) ukoliko ne stavimo WHERE klauzu
FROM Orders AS O
Where O.ShipRegion IS NOT NULL

SELECT COUNT(O.ShipRegion)  --Nece brojati NULL polja, jer smo specifizirali polje
FROM Orders AS O

--NOTE: U ovom slucaju, razlika je neprimjetna!

--9.	Modificirati prethodni upit tako da se dobije broj narud�bi u kojima nije unesena regija kupovine. (Northwind)
SELECT COUNT(*)
FROM Orders AS O
WHERE O.ShipRegion IS NULL  --Nije unesena

--Drugi nacin:
SELECT COUNT(*) - COUNT(O.ShipRegion)  --Od ukupnog (sa null poljima) oduzmemo onaj broj bez null polja
FROM Orders AS O

--10.	Prikazati ukupne tro�kove prevoza po uposlenicima. 
--Uslov je da ukupni tro�kovi prevoza nisu pre�li 7500 pri �emu se rezultat treba sortirati opadaju�im redoslijedom 
--po visini tro�kova prevoza. (Northwind)
SELECT O.EmployeeID,SUM(O.Freight) AS 'Ukupni trosak prevoza uposlenika'  --Sumiramo (ukupni) troskovi
FROM Orders AS O
GROUP BY O.EmployeeID  --Grupisemo po uposlenicima
HAVING SUM(O.Freight)<=7500  --Agregatne fije nije moguce koristiti u  WHERE klauzama stoga moramo koristiti HAVING
ORDER BY 2 DESC  --Opadajucim redosljedom po drugoj koloni

--11.	Prikazati ukupnu vrijednost tro�kova prevoza po dr�avama ali samo ukoliko je ve�a od 4000 za robu koja se kupila
--u Francuskoj, Njema�koj ili �vicarskoj. (Northwind)

SELECT O.ShipCountry,SUM(O.Freight) AS 'Ukupna vrijednost troskova prevoza'  --Ukupna vrijednost troskova prevoza
FROM Orders AS O
WHERE O.ShipCountry IN ('Germany','France','Switzerland')  --Ako je ili u njem ili u fran ili u svicarskoj roba kupljena
GROUP BY O.ShipCountry  --Po drzavama
HAVING SUM(O.Freight)>4000--Ako je veca od 4000

--12.	Prikazati ukupan broj modela proizvoda. Lista treba da sadr�i ID modela proizvoda i njihov ukupan broj. 
--Uslov je da proizvod pripada nekom modelu i da je ukupan broj proizvoda po modelu ve�i od 3.
--U listu uklju�iti (prebrojati) samo one proizvode �iji naziv po�inje slovom 'S'. (AdventureWorks2017)

USE AdventureWorks2019  --Prebacimo se na drugu bazu
GO

SELECT P.ProductModelID,COUNT(P.ProductModelID) AS 'Ukupan broj modela proizvoda'
FROM Production.Product AS P
WHERE P.ProductModelID IS NOT NULL  AND P.Name LIKE 'S%'  --Proizvod mora pripadati nekom modelu, sto znaci da ProductModelID ne smije biti NULL i naziv proizvoda mora pocinjati sa S
GROUP BY P.ProductModelID  --Grupisemo po modelu jer ga imamo kao sam atribut a ne dio agregatne fije
HAVING COUNT(P.ProductModelID)>3  --Kako bi prikazali samo one ciji je ukupan broj po modelu veci od 3