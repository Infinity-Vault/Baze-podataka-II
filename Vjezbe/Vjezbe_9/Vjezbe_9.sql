USE pubs
GO 
SELECT E.fname,E.lname,DATEDIFF(YEAR,E.hire_date,GETDATE()) AS BrojGodinaStaza,
J.job_desc,COUNT(T.pub_id) AS BrojNaslova  --Brojimo koliko je naslova ukupno od uposlenika
FROM employee AS  E INNER JOIN jobs AS J ON J.job_id=E.job_id  --Spojimo uposlenika i posao
INNER JOIN titles AS T ON T.pub_id=E.pub_id --Spojimo naslov i uposlenika koji ga je izdao
WHERE DATEDIFF(YEAR,E.hire_date,GETDATE())>30  --Uslov da su godine staza >30
GROUP BY E.fname,E.lname,DATEDIFF(YEAR,E.hire_date,GETDATE()),J.job_desc  --Radi agreg fije
HAVING COUNT(E.pub_id)>(SELECT COUNT(*) AS BrojObjavljenihNaslova
						FROM titles AS T
						WHERE T.pub_id=0736) --Broj objavljenih naslova od izdavaca koji ima id 0736
ORDER BY BrojGodinaStaza ASC,BrojNaslova DESC


SELECT E.fname,E.lname,J.job_desc,(SELECT AVG(S.qty)
									FROM titles as T INNER JOIN sales AS S ON T.title_id=S.title_id
									WHERE T.pub_id=P.pub_id
									)AS 'Prosjecna prodana kolicina'  --Prosjecna prodana kolicina  naslova izdanih od izdavaca/uposlenika
FROM employee AS E INNER JOIN jobs AS J ON J.job_id=E.job_id --Spojimo uposlenika i posao
INNER JOIN publishers AS P ON P.pub_id=E.pub_id --Spojimo uposlenika i izdavace
WHERE J.job_desc LIKE '%designer%' AND  (SELECT AVG(S.qty)
											FROM titles AS T INNER JOIN sales AS S ON T.title_id=S.title_id
											WHERE	T.pub_id=P.pub_id) --Dobijemo prosjecnu kolicinu svih naslova izdanih od uposlenika
											> --Uslov poredjenja
											(SELECT AVG(S.qty)
												FROM titles AS T INNER JOIN sales AS S ON T.title_id=S.title_id
												WHERE T.pub_id=0877) --Dobijemo prosjecnu kolicinu svih naslova koji su izdani od izdavaca sa id 0877

USE AdventureWorks2019
GO

SELECT T1.KalendarskaGodina,SUM(T1.SumaTransakcija) AS UkupnaSumaTransakcija
FROM (SELECT YEAR(TH.TransactionDate) AS KalendarskaGodina,SUM(TH.ActualCost*TH.Quantity) AS SumaTransakcija
		FROM Production.TransactionHistory AS TH
		GROUP BY YEAR(TH.TransactionDate) --Imamo upit sa podacima iz tabele transakcija
UNION --Posto nisu povezane nikako ove dvije tabele, koristimo UNION (imamo iste  tipove podataka,isti redosljed kolona i isti broj kolona pa je moguce)
		SELECT YEAR(THA.TransactionDate) AS KalendarskaGodina,SUM(THA.ActualCost*THA.Quantity) AS SumaTransakcija
		FROM Production.TransactionHistoryArchive AS THA
		GROUP BY YEAR(THA.TransactionDate)) AS T1  --Napravimo novu tabelu  sa podacima  iz arhive transakcija
GROUP BY T1.KalendarskaGodina --Grupisemo po godini
ORDER BY T1.KalendarskaGodina ASC --Sortiramo po godini

-- LineTotal polje ukljucuje i popust
SELECT P.ProductID,SUM(SOD.LineTotal) AS ZaradaSaPopustom, SUM(SOD.UnitPrice*SOD.OrderQty) AS ZaradaBezPopusta
FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID --Spojimo proizvode i detalje narudzbe
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID  --Spojimo detalje narudzbe i zaglavlje narudzbe
WHERE MONTH(SOH.OrderDate)=5 AND YEAR(SOH.OrderDate)=2013 --Uslov
GROUP BY P.ProductID

SELECT P.ProductID, SUM(SOD.LineTotal) AS UkupnaZaradaBezPopusta,SUM(SOD.UnitPrice*SOD.OrderQty) AS UkupnaZaradaBezPopusta
FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID --Spojimo proizvod i detalj narudzbe
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID --Spojimo detalj narudzbe i zaglavlje narudzbe
WHERE YEAR(SOH.OrderDate)=2013 --Uslov
GROUP BY P.ProductID

SELECT YEAR(SOH.OrderDate) AS Godina, SUM(SOD.LineTotal) AS UkupnaZaradaBezPopusta,SUM(SOD.UnitPrice*SOD.OrderQty) AS UkupnaZaradaBezPopusta
FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID --Spojimo detalj narudzbe i proizvod
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID --Spojimo zaglavlje narudzbe i detalj narudzbe
GROUP BY YEAR(SOH.OrderDate) --Samo grupisano po godinama


SELECT  YEAR(SOH.OrderDate) AS Godina, --Uzmemo godinu
							(SELECT SUM(SOD.LineTotal) AS UkupnaZaradaBezPopusta
							FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID --Spojimo detalj narudzbe i proizvod
							INNER JOIN Sales.SalesOrderHeader AS SOH1 ON SOH1.SalesOrderID=SOD.SalesOrderID --Spojimo zaglavlje narudzbe i detalj narudzbe
							INNER JOIN Production.ProductSubcategory AS PSB ON PSB.ProductSubcategoryID=P.ProductSubcategoryID --Spojimo podkategoriju i  podkategoriju proizvoda 
							INNER JOIN Production.ProductCategory AS PC ON PC.ProductCategoryID=PSB.ProductCategoryID --Spojimo kategoriju i podkategoriju
							WHERE  PSB.Name LIKE 'Mountain Bikes' AND YEAR(SOH.OrderDate)=YEAR(SOH1.OrderDate)) AS UkupnaZaradaMountainBikes, --Moramo pratiti i da je godina unutarnjeg upita jednaka godini vanjskog upita kako bi rezultati bili korektni i kako bi se islo po istim godinama i sumiralo.
									(SELECT SUM(SOD.LineTotal) AS UkupnaZaradaBezPopusta
									FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
									INNER JOIN Sales.SalesOrderHeader AS SOH1 ON SOH1.SalesOrderID=SOD.SalesOrderID
									INNER JOIN Production.ProductSubcategory AS PSB ON PSB.ProductSubcategoryID=P.ProductSubcategoryID
									INNER JOIN Production.ProductCategory AS PC ON PC.ProductCategoryID=PSB.ProductCategoryID
									WHERE  PSB.Name LIKE 'Road Bikes' AND YEAR(SOH.OrderDate)=YEAR(SOH1.OrderDate)) AS UkupnaZaradaRoadBikes,
											(SELECT SUM(SOD.LineTotal) AS UkupnaZaradaBezPopusta
											FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
											INNER JOIN Sales.SalesOrderHeader AS SOH1 ON SOH1.SalesOrderID=SOD.SalesOrderID
											INNER JOIN Production.ProductSubcategory AS PSB ON PSB.ProductSubcategoryID=P.ProductSubcategoryID
											INNER JOIN Production.ProductCategory AS PC ON PC.ProductCategoryID=PSB.ProductCategoryID
											WHERE  PSB.Name LIKE 'Touring Bikes' AND YEAR(SOH.OrderDate)=YEAR(SOH1.OrderDate)) AS UkupnaZaradaTouringBikes
FROM Sales.SalesOrderHeader AS SOH
GROUP BY YEAR(SOH.OrderDate)
ORDER BY Godina ASC  


SELECT TOP(1) Tabela.ImePrezime,Tabela.Plata 
--Unutarnju tabelu iskoristimo da sortiramo obrnutim redosljedom (time dobijemo najmanju platu) i uzmemo prvi red (4  najvecu platu)
FROM (SELECT TOP(4) CONCAT(P.FirstName,' ',P.LastName) AS ImePrezime,EPH.Rate AS Plata
		FROM Person.Person AS P INNER JOIN HumanResources.Employee AS E ON E.BusinessEntityID=P.BusinessEntityID --Spojimo uposlenika i osobu
		INNER JOIN HumanResources.EmployeePayHistory AS EPH ON EPH.BusinessEntityID=E.BusinessEntityID --Spojimo historiju plata i uposlenika
		ORDER BY Plata DESC) AS Tabela --Unutarnjom tabelom dobijemo top 4 najvece plate uposlenika
ORDER BY Tabela.Plata ASC

--Ili:
--Isto dobijemo samo sto koristimo u podupitu funkciju ROW_NUMBER  kojoj proslijedimo kolonu (po kojoj ce brojati) i redoslijed sortiranja
SELECT Tabela.ImePrezime,Tabela.Plata
FROM(SELECT TOP(4) CONCAT(P.FirstName,' ',P.LastName) AS ImePrezime,EPH.Rate AS Plata,ROW_NUMBER() OVER (ORDER BY EPH.Rate DESC) AS Redoslijed
FROM Person.Person AS P INNER JOIN HumanResources.Employee AS E ON E.BusinessEntityID=P.BusinessEntityID
INNER JOIN HumanResources.EmployeePayHistory AS EPH ON EPH.BusinessEntityID=E.BusinessEntityID) AS Tabela
WHERE Redoslijed=4 --Uslov iz podupita da uzmemo 4tu platu


--TotalDue je iznos placen karticom sa svime uracunatim
SELECT CONCAT(P.FirstName,' ',P.LastName) AS ImePrezime,CC.CardType,CC.CardNumber,SUM(SOH.TotalDue) AS UkupnoUtroseno
FROM Person.Person AS P INNER JOIN Sales.Customer AS C ON C.PersonID=P.BusinessEntityID --Spojimo osobu i kupca
INNER JOIN Sales.PersonCreditCard AS PCC ON PCC.BusinessEntityID=P.BusinessEntityID --Spojimo kredit. kart. osobe i osobu
INNER JOIN Sales.CreditCard AS CC ON CC.CreditCardID=PCC.CreditCardID --Spojimo kreditnu karticu i  kredit. kart. osobe
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.CreditCardID=PCC.CreditCardID --Spojimo zaglavlje narudzbe i karticu kako bi dobili narudzbe koje su placene karticom
INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.SalesOrderID=SOH.SalesOrderID --Spojimo detalj narudzbe i  zaglavlje narudzbe
GROUP BY CONCAT(P.FirstName,' ',P.LastName),CC.CardType,CC.CardNumber


SELECT CONCAT(P.FirstName,' ',P.LastName) AS ImePrezime,CC.CardType,CC.CardNumber,SUM(SOH.TotalDue) AS UkupnoUtroseno
FROM Person.Person AS P INNER JOIN Sales.Customer AS C ON C.PersonID=P.BusinessEntityID
INNER JOIN Sales.PersonCreditCard AS PCC ON PCC.BusinessEntityID=P.BusinessEntityID
INNER JOIN Sales.CreditCard AS CC ON CC.CreditCardID=PCC.CreditCardID
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.CreditCardID=PCC.CreditCardID
WHERE(SELECT COUNT(PCC.CreditCardID)
		FROM Sales.PersonCreditCard AS PCC 
		WHERE PCC.BusinessEntityID=P.BusinessEntityID)>1 --Podupitom provjerimo da li ista osoba ima vise od jedne kartice
GROUP BY CONCAT(P.FirstName,' ',P.LastName),CC.CardType,CC.CardNumber


SELECT  CONCAT(P.FirstName,' ',P.LastName) AS ImePrezime,CC.CardType,CC.CardNumber,SUM(SOH.TotalDue) AS UkupnoUtroseno
FROM Person.Person AS P INNER JOIN Sales.Customer AS C ON C.PersonID=P.BusinessEntityID
INNER JOIN Sales.PersonCreditCard AS PCC ON PCC.BusinessEntityID=P.BusinessEntityID
INNER JOIN Sales.CreditCard AS CC ON CC.CreditCardID=PCC.CreditCardID
LEFT  OUTER JOIN Sales.SalesOrderHeader AS SOH ON SOH.CreditCardID=CC.CreditCardID
GROUP BY CONCAT(P.FirstName,' ',P.LastName),CC.CardType,CC.CardNumber

--U donjem upitu isto mozemo izbaciti left outer join i zamjeniti sa podupitom gdje imamo WHERE da je id kreditne kartice jednak SOH.CreditCardID i samo odatle sumiramo  TotalDue i  time dobijemo one narudzbe koje nisu placene karticom
SELECT  CONCAT(P.FirstName,' ',P.LastName) AS ImePrezime,CC.CardType,CC.CardNumber,ISNULL(SUM(SOH.TotalDue),0) AS UkupnoUtroseno
FROM Person.Person AS P INNER JOIN Sales.Customer AS C ON C.PersonID=P.BusinessEntityID
INNER JOIN Sales.PersonCreditCard AS PCC ON PCC.BusinessEntityID=P.BusinessEntityID
INNER JOIN Sales.CreditCard AS CC ON CC.CreditCardID=PCC.CreditCardID
LEFT  OUTER JOIN Sales.SalesOrderHeader AS SOH ON SOH.CreditCardID=CC.CreditCardID  --Left outer joinom dobijemo sve narudzbe koje nisu placene karticom
GROUP BY CONCAT(P.FirstName,' ',P.LastName),CC.CardType,CC.CardNumber


SELECT  CONCAT(P.FirstName,' ',P.LastName) AS ImePrezime,CC.CardType,CC.CardNumber,ISNULL(SUM(SOH.TotalDue),0) AS UkupnoUtroseno --Zamjenimo ako je null sa 0
FROM Person.Person AS P INNER JOIN Sales.Customer AS C ON C.PersonID=P.BusinessEntityID
INNER JOIN Sales.PersonCreditCard AS PCC ON PCC.BusinessEntityID=P.BusinessEntityID
INNER JOIN Sales.CreditCard AS CC ON CC.CreditCardID=PCC.CreditCardID
LEFT  OUTER JOIN Sales.SalesOrderHeader AS SOH ON SOH.CreditCardID=CC.CreditCardID
GROUP BY CONCAT(P.FirstName,' ',P.LastName),CC.CardType,CC.CardNumber
ORDER BY ImePrezime ASC, UkupnoUtroseno DESC --Poredamo po imenima abecedno i ukupno utrosenom obrnuto abecedno


--Najveci promet
--Odaberemo prvi zapis
SELECT  TOP(1) P.Name, CAST(ROUND(SUM(SOD.LineTotal),2) AS DECIMAL (18,2)) AS NajveciUkupniPromet --Castamo u decimal (18,2) jer imamo 18 cifri i dva dec. mjesta ostatka (decimalni ostatak ulazi u broj 18) (kako bi nam bilo zaokruzeno na 2 decimale)
FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
GROUP BY P.Name
ORDER BY NajveciUkupniPromet DESC --Desc jer zelimo  najveci

--Najmanji promet 
SELECT  TOP(1) P.Name, CAST(ROUND(SUM(SOD.LineTotal),2) AS DECIMAL (18,2)) AS NajmanjiUkupniPromet
FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
GROUP BY P.Name
ORDER BY NajmanjiUkupniPromet ASC --ASC jer zelimo najmanji

--Prosjecni promet
SELECT AVG(SOD.LineTotal) AS ProsjecniPromet
FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID


--Prvi prikaz:
--Poredamo sve kako zelimo u prikazu
SELECT NajmanjiPromet.Name AS Proizvod,CAST(NajmanjiPromet.NajmanjiUkupniPromet AS DECIMAL (18,2)) AS 'Najmanji promet',
NajveciPromet.Name AS Proizvod,CAST(NajveciPromet.NajveciUkupniPromet AS DECIMAL(18,2)) AS 'Najveci promet',
CAST(ROUND(NajmanjiPromet.NajmanjiUkupniPromet-Prosjek.ProsjecniPromet,2) AS DECIMAL (18,2)) AS 'Razlika min avg',
CAST(ROUND(NajveciPromet.NajveciUkupniPromet-Prosjek.ProsjecniPromet,2) AS DECIMAL (18,2)) AS 'Razlika max avg'
FROM (SELECT AVG(SOD.LineTotal) AS ProsjecniPromet
		FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID) AS Prosjek, --Tabela za prosjecnu vrijednost
			 (SELECT  TOP(1) P.Name, ROUND(SUM(SOD.LineTotal),2) AS NajveciUkupniPromet
			      FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
			      GROUP BY P.Name
			      ORDER BY NajveciUkupniPromet DESC) AS NajveciPromet, --Tabela za najveci promet
			         (SELECT  TOP(1) P.Name, ROUND(SUM(SOD.LineTotal),2) AS NajmanjiUkupniPromet
                      FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
                      GROUP BY P.Name
                      ORDER BY NajmanjiUkupniPromet ASC) AS NajmanjiPromet --Tabela za najmanji promet


--Drugi prikaz
SELECT NajmanjiPromet.Name AS Proizvod,CAST(NajmanjiPromet.NajmanjiUkupniPromet AS DECIMAL (18,2)) AS 'Min-Max promet po proizvodu',
CAST(ROUND(NajmanjiPromet.NajmanjiUkupniPromet-Prosjek.ProsjecniPromet,2) AS DECIMAL (18,2)) AS 'Razlika'
FROM  (SELECT AVG(SOD.LineTotal) AS ProsjecniPromet
		FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID) AS Prosjek,
		(SELECT  TOP(1) P.Name, ROUND(SUM(SOD.LineTotal),2) AS NajmanjiUkupniPromet
                      FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
                      GROUP BY P.Name
                      ORDER BY NajmanjiUkupniPromet ASC) AS NajmanjiPromet

UNION  --Uniju koristimo jer zelimo da kombinujemo prikaz ove dvije tabele po kolonama Proizvod,Promet (min, max) i Razlika
--Ovo je moguce jer imamo kolone istog tipa podatka, istog redosljeda i istog broja

SELECT NajveciPromet.Name AS Proizvod,CAST(NajveciPromet.NajveciUkupniPromet AS DECIMAL(18,2)),
CAST(ROUND(NajveciPromet.NajveciUkupniPromet-Prosjek.ProsjecniPromet,2) AS DECIMAL (18,2)) AS 'Razlika'
FROM (SELECT AVG(SOD.LineTotal) AS ProsjecniPromet
		FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID) AS Prosjek,
			 (SELECT  TOP(1) P.Name, ROUND(SUM(SOD.LineTotal),2) AS NajveciUkupniPromet
			      FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
			      GROUP BY P.Name
			      ORDER BY NajveciUkupniPromet DESC) AS NajveciPromet