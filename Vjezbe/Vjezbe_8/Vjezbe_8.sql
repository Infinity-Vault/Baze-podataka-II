--1.Kreirati upit koji prikazuje kreditne kartice kojima je pla�eno vi�e
--od 20 narud�bi. U listu uklju�iti ime i prezime vlasnika kartice, tip kartice,
--broj kartice, ukupan iznos pla�en karticom. 
--Rezultate sortirati prema ukupnom iznosu u opadaju�em redoslijedu zaokru�ene
--na dvije decimale.
USE AdventureWorks2019
GO
SELECT P.FirstName,P.LastName,CC.CardType,CC.CardNumber,ROUND(SUM(SOH.TotalDue),2) AS UkupanIznos  --TotalDue predstavlja ukupnu vrijednost narudzbe (sa taksama i prevozom)
FROM Person.Person AS P INNER JOIN Sales.PersonCreditCard AS PCC ON --Spojimo osobu i kreditnu karticu osobe
PCC.BusinessEntityID=P.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.CreditCardID=PCC.CreditCardID --Spojimo zaglavlje narudzbe i kreditnu karticu osobe
INNER JOIN Sales.CreditCard AS CC ON CC.CreditCardID=PCC.CreditCardID  --Spojimo kreditnu karticu i k.k osobe
GROUP BY P.FirstName,P.LastName,CC.CardType,CC.CardNumber
HAVING COUNT(*)>20 --Uslov iz texta vise od 20 narudzbi
ORDER BY UkupanIznos DESC


--2.Prikazati ime i prezime te vrijednost narud�be (bez popusta) kupaca koji su 
--napravili narud�bu ve�u od prosje�ne vrijednosti svih narud�bi proizvoda sa id-om 779.

SELECT CONCAT(P.FirstName,' ',P.LastName) AS 'Ime i prezime',(SELECT SUM(SOD.OrderQty*SOD.UnitPrice)
																	FROM Sales.SalesOrderDetail AS SOD
																	INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID
																	WHERE SOH.CustomerID=C.CustomerID) AS Vrijednost --Kako bi dobili sumu vrijednosti narudzbi za svakog kupca
FROM Person.Person AS P INNER JOIN Sales.Customer AS C ON P.BusinessEntityID=C.PersonID
WHERE  --Uslov gdje je ukupna vrijednost svih narudzbi kupca veca od prosjecne vrijednosti svih narudzbi
   (
	SELECT SUM(SOD.OrderQty*SOD.UnitPrice)
	FROM Sales.SalesOrderDetail AS SOD
	INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID
	WHERE SOH.CustomerID=C.CustomerID
)>  (
	SELECT AVG(SOD.OrderQty*SOD.UnitPrice)
	FROM Sales.SalesOrderDetail AS SOD 
	WHERE SOD.ProductID=779  --Isto uslov ID=779
	)
--3.Kreirati upit koji prikazuje kupce koji su u maju mjesecu 2014. godine naru�ili proizvod
--�Front Brakes� u koli�ini ve�oj od 5 komada. 
SELECT CONCAT(P.FirstName,' ',P.LastName) AS 'Ime i prezime',PP.Name
FROM Person.Person AS P INNER JOIN Sales.Customer AS C ON C.PersonID=P.BusinessEntityID --Spojimo osobu i kupca
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.CustomerID=C.CustomerID --Spojimo kupca i zaglavlje narudzbe
INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.SalesOrderID=SOH.SalesOrderID --Spojimo narudzbu detalj i  zaglavlje narudzbe
INNER JOIN Production.Product AS PP ON PP.ProductID=SOD.ProductID --Spojimo proizvod i narudzbu detalj
WHERE PP.Name LIKE 'Front Brakes' AND SOD.OrderQty>5 --Uslov
AND YEAR(SOH.OrderDate)=2014 AND MONTH(SOH.OrderDate)=5 --Uslov

--4.Kreirati upit koji prikazuje kupce koji su u 7. mjesecu utro�ili vi�e od 200.000 KM. 
--U listu uklju�iti ime i prezime kupca te ukupni utro�ak. Izlaz sortirati prema utro�ku
--opadaju�im redoslijedom. 
SELECT P.FirstName,P.LastName, SUM(SOH.TotalDue) AS Utroseno  --TotalDue je ukupna vrijednost troska
FROM Person.Person AS P INNER JOIN Sales.Customer AS C ON C.PersonID=P.BusinessEntityID --Spojimo osobu i kupca
INNER JOIN Sales.SalesOrderHeader AS SOH  ON C.CustomerID=SOH.CustomerID --Spojimo zaglavlje narudzbe i kupca
WHERE MONTH(SOH.OrderDate)=7 --Uslov
GROUP BY P.FirstName,P.LastName  --Radi sum agreg fije
HAVING SUM(SOH.TotalDue) >200000  --Uslov
ORDER BY Utroseno DESC

--5.Kreirati upit koji prikazuje zaposlenike koji su uradili vi�e od 200 narud�bi.
--U listu uklju�iti ime i prezime zaposlenika te ukupan broj ura�enih narud�bi. 
--Izlaz sortirati prema broju narud�bi opadaju�im redoslijedom 
SELECT P.FirstName,P.LastName,COUNT(SOH.SalesOrderID) AS BrojNarudzbi
FROM Person.Person AS P INNER JOIN HumanResources.Employee AS E ON E.BusinessEntityID=
P.BusinessEntityID  --Spojimo osobu i uposlenika
INNER JOIN Sales.SalesPerson AS SP ON SP.BusinessEntityID=E.BusinessEntityID --Spojimo prodavaca i uposlenika 
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesPersonID=SP.BusinessEntityID --Spojimo zaglavlje narudzbe i prodavaca
GROUP BY P.FirstName,P.LastName --Radi agreg fije count
HAVING COUNT(SOH.SalesOrderID)>200  --Uslov 
ORDER BY  BrojNarudzbi DESC

--6.Kreirati upit koji prikazuje proizvode kojih na skladi�tu ima u koli�ini manjoj od 30 komada.
--Lista treba da sadr�i naziv proizvoda, naziv skladi�ta (lokaciju), stanje na skladi�tu i 
--ukupnu prodanu koli�inu. U rezultate upita uklju�iti i one proizvode koji nikad nisu prodavani. 
--Ukoliko je ukupna prodana koli�ina prikazana kao NULL vrijednost, izlaz formatirati brojem 0.
SELECT P.Name,L.Name,PI.Quantity,ISNULL((SELECT SUM(SOD.OrderQty)  --Ako je ukupna prodana kolicina null zamjenimo je sa 0
									FROM Sales.SalesOrderDetail AS SOD
									WHERE SOD.ProductID=P.ProductID
									),0) AS UkupnaProdataKolicina  --Podupit za ukupnu prodatu kolicinu svakog proizvoda
FROM Production.Product AS P INNER JOIN Production.ProductInventory AS PI ON PI.ProductID=P.ProductID --Spojimo proizvod i inventuru
INNER JOIN Production.Location AS L ON L.LocationID=PI.LocationID --Spojimo lokaciju i inventuru
WHERE PI.Quantity<30 OR P.ProductID NOT IN (SELECT DISTINCT SOD.ProductID --DISTINCT radi cinjenice sto u narudzbi moze bit vise proizvoda sa istim ID
												FROM Sales.SalesOrderDetail AS SOD) --Uzmemo u obzir i proizvode koji nisu prodati nikada

--7.Prikazati ukupnu koli�inu prodaje i ukupnu zaradu (uklju�uju�i popust) od prodaje svakog
--pojedinog proizvoda po teritoriji. Uzeti u obzir samo prodaju u sklopu ponude pod nazivom 
--�Volume Discount 11 to 14� i to samo gdje je koli�ina prodaje ve�a od 100 komada. 
--Zaradu zaokru�iti na dvije decimale, te izlaz sortirati po zaradi u opadaju�em redoslijedu. 
SELECT P.Name,ST.Name,SUM(SOD.OrderQty) AS KolicinaProdaje,SUM(SOD.UnitPrice*SOD.OrderQty*(1-SOD.UnitPriceDiscount)) AS UkupnaZarada --ili LineTotal on predstavlja zaradu ukljucujuci popust
FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID  --Spojimo proizvod i detalj narudzbe
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID --Spojimo zaglavlje narudzbe i detalj narudzbe
INNER JOIN Sales.SalesTerritory AS ST ON ST.TerritoryID=SOH.TerritoryID --Spojimo teritoriju i zaglavlje narudzbe
INNER JOIN Sales.SpecialOffer AS SO ON SO.SpecialOfferID=SOD.SpecialOfferID --Spojimo  ponudu i detalj narudzbe
WHERE SO.Description LIKE 'Volume Discount 11 to 14'  --Uslov
GROUP BY  P.Name,ST.Name --Radi agreg fije
HAVING SUM(SOD.OrderQty)>100  --Uslov
ORDER BY UkupnaZarada DESC

--8.Kreirati upit koji prikazuje naziv proizvoda, naziv lokacije, stanje zaliha na lokaciji, ukupno stanje zaliha
--na svim lokacijama i ukupnu prodanu koli�inu. Uzeti u obzir prodaju samo u 2013. godini. 
SELECT P.Name AS ImeProizvoda,L.Name AS ImeLokacije,PI.Quantity AS StanjeZalihaNaLokaciji,
SUM(PI.Quantity) AS 'Ukupno stanje zaliha na svim lokacijama',
SUM(SOD.OrderQty) AS 'Ukupna prodana kolicina'
FROM Production.Product AS P INNER JOIN Production.ProductInventory AS PI ON PI.ProductID=P.ProductID --Spojimo proizvod i inventar
INNER JOIN Production.Location AS L ON L.LocationID=PI.LocationID --Spojimo lokaciju i proizvod
INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID --Spojimo detalj narudzbe i proizvod
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID  --Spojimo zaglavlje narudzbe i detalj narudzbe
WHERE YEAR(SOH.OrderDate)=2013  --Uslov 
GROUP BY P.Name,L.Name,PI.Quantity --Radi agreg fija

--9.Kreirati upit kojim �e se prikazati narud�be kojima je na osnovu popusta kupac u�tedio 100KM i vi�e.
--Upit treba da sadr�i broj narud�be, naziv kupca i stvarnu ukupnu vrijednost narud�be zaokru�enu na 2 decimale.
--Podatke je potrebno sortirati rastu�im redosljedom od najmanjeg do najve�eg.
SELECT SOD.SalesOrderID,CONCAT(P.FirstName,'',P.LastName) AS 'Naziv kupca',ROUND(SUM(SOD.LineTotal),2) AS 'Stvarna ukupna vrijednost narudzbe' --Sa popustom!
FROM Person.Person AS P INNER JOIN  Sales.Customer AS C ON C.PersonID=P.BusinessEntityID --Spojimo osobu i kupca
INNER JOIN  Sales.SalesOrderHeader AS SOH ON SOH.CustomerID=C.CustomerID --Spojimo kupca i zaglavlje narudzbe
INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.SalesOrderID=SOH.SalesOrderID --Spojimo detalj narudzbe i zaglavlje narudzbe
GROUP BY SOD.SalesOrderID,CONCAT(P.FirstName,'',P.LastName) --Radi agreg fije
HAVING SUM(SOD.UnitPrice*SOD.OrderQty)-SUM(SOD.LineTotal)>=100 --Uslov za ostvareni popust (bez popusta - sa popustom)
ORDER BY [Stvarna ukupna vrijednost narudzbe] ASC

--10.Kreirati upit kojim se prikazuje da li su mu�karci ili �ene napravili ve�i broj narud�bi. 
--Na�in provjere spola jeste da osobe �ije ime zavr�ava slovom �a� predstavljaju �enski spol. 
--U rezultatima upita prikazati spol (samo jedan), ukupan broj narud�bi koje su napravile osobe datog spola i
--ukupnu potro�enu vrijednost zaokru�enu na dvije decimale.
SELECT TOP (1) IIF(RIGHT(P.FirstName,1)='a','F','M') AS Spol,COUNT(*) AS BrojNarudzbi, --Uzmemo top(1) jer zelimo samo jedan red za rezultat (spol koji je imao vise narudzbi)
ROUND(SUM(SOH.TotalDue),2) AS UkupnaPotrosenaVrijednost
FROM Person.Person AS P INNER JOIN Sales.Customer AS C ON  C.PersonID=P.BusinessEntityID --Spojimo osobu i kupca
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.CustomerID=C.CustomerID --Spojimo kupca i zaglavlje zarudzbe
GROUP BY IIF(RIGHT(P.FirstName,1)='a','F','M') --Grupisemo po Spolu
ORDER BY BrojNarudzbi DESC --Poredamo opadajucim redosljedom po broju narudzbi (upravo jer nas zanima koji je spol imao vise narudzbi)

--11.Kreirati upit koji prikazuje ukupan broj proizvoda, ukupnu koli�inu proizvoda na lageru, 
--te ukupnu vrijednost proizvoda na lageru (skladi�tu).
--Rezultate prikazati grupisane po nazivu dobavlja�a te uzeti u obzir samo one zapise gdje je sumarna koli�ina 
--na lageru ve�a od 100 i vrijednost cijene proizvoda ve�a od 0.
SELECT V.Name,COUNT(P.ProductID) AS UkupanBrojProizvoda,SUM(PI.Quantity)AS UkupnaKolicinaNaLageru,
SUM(SOD.UnitPrice*PI.Quantity)AS UkupnaVrijednostProizvodaNaLageru
FROM Production.Product AS P INNER JOIN Production.ProductInventory AS PI ON PI.ProductID=P.ProductID --Spojimo proizvod i inventar
INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID --Spojimo detalj narudzbe i proizvod
INNER JOIN Purchasing.ProductVendor AS PV ON PV.ProductID=P.ProductID --Spojimo dobavljaca proizvoda i  proizvod
INNER JOIN Purchasing.Vendor AS V ON V.BusinessEntityID=PV.BusinessEntityID --Spojimo dobavljaca i dobavljaca proizvoda
WHERE SOD.UnitPrice>0 --Uslov
GROUP BY V.Name --Radi agreg fija i uslova
HAVING SUM(PI.Quantity)>100 --Uslov