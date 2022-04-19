--Prikazati tip popusta, naziv prodavnice i njen id. (Pubs) 
USE pubs
GO
SELECT D.discounttype,S.stor_name,S.stor_id
FROM stores AS S INNER JOIN  discounts AS D ON S.stor_id=D.stor_id  --Moramo povezati radnju sa njenim popustom.

--Prikazati ime uposlenika, njegov id, te naziv posla koji obavlja. (Pubs) 
SELECT E.fname,E.emp_id,J.job_desc
FROM  employee AS E INNER JOIN jobs AS J ON E.job_id=J.job_id --Spojimo uposlenika i posao koji radi

--Prikazati spojeno ime i prezime uposlenika, teritoriju i regiju koju pokriva. 
--Uslov je da su zaposlenici mlaði od 60 godina. (Northwind) 
USE Northwind
GO
SELECT E.FirstName+' '+E.LastName AS SpojenoIme,T.TerritoryDescription,R.RegionDescription,DATEDIFF(YEAR,E.BirthDate,GETDATE()) AS Godine
FROM Employees AS E INNER JOIN  EmployeeTerritories AS ET ON E.EmployeeID=ET.EmployeeID  --Spojimo uposlenika sa uposlenik_teritorija
INNER JOIN Territories AS T ON T.TerritoryID=ET.TerritoryID  --Spojimo teritoriju sa uposlenik_teritorija
INNER JOIN Region AS R ON R.RegionID=T.RegionID --Spojimo regiju sa teritorijom 
WHERE DATEDIFF(YEAR,E.BirthDate,GETDATE())<60  --Prikazemo one koji su mladji od 60 godina.

--Prikazati ime uposlenika i ukupnu vrijednost svih narudžbi koju je taj uposlenik napravio u 
--1996. godini. U obzir uzeti samo one uposlenike èija je ukupna napravljena vrijednost 
--veæa od 20000. Podatke sortirati prema ukupnoj vrijednosti (zaokruženoj na dvije decimale) 
--u rastuæem redoslijedu. (Northwind) 

SELECT E.FirstName,SUM(OD.Quantity*OD.UnitPrice) AS UkupnaVrijednost
FROM Employees AS E INNER JOIN Orders AS O ON E.EmployeeID=O.EmployeeID  --Spojimo uposlenika i narudzbu
INNER JOIN [Order Details] AS OD ON OD.OrderID=O.OrderID  --Spojimo narudzbu i stavku_narudzbe
WHERE Year(O.OrderDate)=1996  --Prikazemo samo one koje su narucene 1996
GROUP BY E.FirstName  --Jer imamo agreg. fiju. SUM, grupisemo po imenu uposlenika
HAVING SUM(OD.Quantity*OD.UnitPrice) > 20000  --Uslov ako je vrijednost veca od 20000
ORDER BY 2 ASC  --Poredamo po vrijednosti

--Prikazati naziv dobavljaèa, adresu i državu dobavljaèa i nazive proizvoda koji pripadaju 
--kategoriji piæa i ima ih na stanju više od 30 komada. Rezultate upita sortirati po državama.
--(Northwind) 

SELECT S.ContactName,S.Address,S.Country,P.ProductName
FROM Suppliers AS S INNER JOIN  Products AS P ON S.SupplierID=P.SupplierID  --Spojimo dobavljaca i proizvod 
INNER JOIN Categories AS C ON C.CategoryID=P.CategoryID  --Spojimo kategoriju i prozivod
WHERE C.Description LIKE '%drinks%' AND P.UnitsInStock>30 --Filtriramo samo one koji u opisu sadrze drinks i cija je kolicina na stanju veca od 30
ORDER BY 3 -- Poredamo po drzavi

--Prikazati kontakt ime kupca, njegov id, broj narudžbe, datum kreiranja narudžbe (prikazan na
--naèin npr 24.07.2021) te ukupnu vrijednost narudžbe sa i bez popusta. 
--Prikazati samo one narudžbe koje su kreirane u 1997. godini. 
--Izraèunate vrijednosti zaokružiti na dvije decimale, te podatke sortirati prema ukupnoj 
--vrijednosti narudžbe sa popustom. (Northwind) 

--NOTE: Datum mozemo formatirati putem FORMAT fije prikazane dole:
SELECT C.ContactName,C.CustomerID,O.OrderID,FORMAT(O.OrderDate,'dd.MM.yyyy'),ROUND(SUM(OD.UnitPrice*OD.Quantity),2) 
AS BezPopusta, ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)),2) AS SaPopustom
FROM Customers AS C INNER JOIN  Orders AS O ON C.CustomerID=O.CustomerID  --Spojimo kupca i narudzbu
INNER JOIN [Order Details] AS OD ON OD.OrderID=O.OrderID  --Spojimo narudzbu i stavku_narudzbe
WHERE Year(O.OrderDate)=1997   --Prikazemo one koje su narucene 1997 godine
GROUP BY C.ContactName,C.CustomerID,O.OrderID,O.OrderDate  --Jer imamo agregatne fije, grupisemo po C.ContactName,C.CustomerID,O.OrderID,O.OrderDate 
ORDER BY 5  --Sortiramo po vrijednosti narudzbe NOTE: Default sortiranje je DESC

--U tabeli Customers baze Northwind ID kupca je primarni kljuè.  
--U tabeli Orders baze Northwind ID kupca je vanjski kljuè. 
--Prikazati: 

--Koliko je kupaca evidentirano u obje tabele 
SELECT C.CustomerID  
FROM Customers AS C 
UNION --Kombinira rezultate dva ili vise SELECT iskaza, pri cemu uklanja duplikatne vrijednosti. Ukoliko zelimo i duplikate koristimo UNION ALL
SELECT O.CustomerID
FROM Orders AS O 

--Da li su svi kupci obavili narudžbu  
SELECT C.CustomerID
FROM Customers AS C 
INTERSECT --Funkcionise slicno INNER JOIN (uzima jednake vrijednosti oba skupa / presjek) pri cemu ova kljucna rijec ne uzima duplikatne vrijednosti
SELECT O.CustomerID
FROM Orders AS O 
--Inner joinom se dobije isto:
SELECT DISTINCT C.CustomerID  --Samo moramo koristiti distinct kako bi eliminisali duplikate
FROM Customers AS C INNER JOIN Orders AS O ON C.CustomerID=O.CustomerID

--Ukoliko postoje neki da nisu prikazati koji su to 
SELECT C.CustomerID
FROM Customers AS C 
EXCEPT  --Vraca zapise koji su pronadjeni u prvom a nisu u pronadjeni u drugom select iskazu / drugoj tabeli
SELECT O.CustomerID
FROM Orders AS O 
--Isto mozemo dobiti sa outer joinom, jer on vraca ne zadovoljene redove:
SELECT C.CustomerID
FROM Customers AS C LEFT OUTER JOIN Orders AS O ON O.CustomerID=C.CustomerID  --Left jer gledamo iz Orders CustomerID
WHERE O.OrderID IS NULL --Uslov je oni kupci koji nisu narucili nista pa je stoga gledamo gdje je OrderID null

--Dati pregled vanrednih prihoda osobe. Pregled treba da sadrži sljedeæe kolone: OsobaID, Ime,
--VanredniPrihodID, IznosPrihoda (Prihodi) 

USE prihodi
GO

SELECT O.OsobaID,O.Ime,VP.VanredniPrihodiID,VP.IznosVanrednogPrihoda  
FROM Osoba AS O LEFT OUTER JOIN VanredniPrihodi AS VP ON VP.OsobaID=O.OsobaID  --Povezemo osobe i vanredni prihodpri cemu povezemo sa outer join jer je moguce da osoba nema vanrednog prihoda.
--NOTE idemo left jer je Osoba LEFT tabela a VanredniPrihodi RIGHT tabela


--Dati pregled redovnih prihoda osobe. Pregled treba da sadrži sljedeæe kolone: OsobaID, Ime, RedovniPrihodID, Neto (Prihodi) 
SELECT O.OsobaID,O.Ime,RP.RedovniPrihodiID,RP.Neto
FROM Osoba AS O LEFT OUTER JOIN RedovniPrihodi AS RP ON RP.OsobaID=O.OsobaID  --Povezemo osobe i redovni prihod, pri cemu povezemo sa outer join jer je moguce da osoba nema redovnog prihoda.
--NOTE idemo left jer je Osoba LEFT tabela a RedovniPrihodi RIGHT tabela

--Prikazati ukupnu vrijednost prihoda osobe (i redovne i vanredne). 
--Rezultat sortirati u rastuæem redoslijedu prema ID osobe. (Prihodi) 
SELECT O.OsobaID,SUM(ISNULL(VP.IznosVanrednogPrihoda,0))+SUM(ISNULL(RP.Neto,0)) AS UkupanPrihod  --Provjerimo ukoliko su prihodi NULL te u tom slucaju zamjenimo samo sa 0. Ovo radimo jer se moze desiti da osoba ima redovni ali nema vanredni prihod i obratno.
FROM Osoba AS O LEFT OUTER JOIN VanredniPrihodi AS VP ON VP.OsobaID=O.OsobaID  --Povezemo osobe i vanredni prihod pri cemu koristimo outer join jer je moguce da osoba nema vanredni prihod
LEFT OUTER JOIN RedovniPrihodi AS RP ON RP.OsobaID=O.OsobaID  --Povezemo osobe i redovni prihod pri cemu koristimo outer join jer je moguce da nema osoba redovni prihod
--NOTE posto je left prvo ide RP.OsobaID i VP.OsobaID pa onda =. Isto tako Osoba je LEFT tabela a VP i RP su RIGHT tabele.
GROUP BY O.OsobaID  --Jer nije ovaj atribut dio agregatne fije, grupisemo po njemu
ORDER BY O.OsobaID ASC  --Sortiramo uzlazno po OsobaID

--Odrediti da li je svaki autor napisao bar po jedan naslov. (Pubs) 
USE pubs
GO

SELECT A.au_id
FROM authors AS A
INTERSECT  --Vrati nam zapise koji su jednaki po au_id
SELECT TA.au_id
FROM titleauthor AS TA

--Isto se moze postici sa INNER JOIN ali DISTINCT jer INTERSECT ne vraca duplikatne vrijednosti:
SELECT DISTINCT A.au_id
FROM authors AS A INNER JOIN titleauthor AS TA ON TA.au_id=A.au_id

--a) ako ima autora koji nisu napisali ni jedan naslov navesti njihov ID. 

SELECT A.au_id
FROM authors AS A
EXCEPT  --Vrati nam zapise gdje id iz prve tabele ne postoji u drugoj tabeli.
SELECT TA.au_id
FROM titleauthor AS TA

--Isto se moze postici sa OUTER JOIN jer on predstavlja zapise koji ne zadovoljavaju nesto:
SELECT A.au_id
FROM authors AS A LEFT OUTER JOIN titleauthor AS TA ON TA.au_id=A.au_id --LEFT jer uzimamo au_id iz titleauthor
WHERE TA.au_id IS NULL

--b) dati pregled autora koji su napisali bar po jedan naslov. 

SELECT TA.au_id,COUNT(*) AS BrojNaslovaAutora
FROM authors AS A INNER JOIN titleauthor AS TA ON A.au_id=TA.au_id  --Spojimo autore i autore_naslove
INNER JOIN  titles AS T ON T.title_id=TA.title_id  --Spojimo naslove i autore_naslove
GROUP BY TA.au_id
HAVING COUNT(*)>=1  --Prikazemo one koji su napisali bar po jedan naslov


--Prikazati 10 najskupljih stavki prodaje. Upit treba da sadrži naziv proizvoda, kolièinu, cijenu i vrijednost stavke prodaje. 
--Cijenu i vrijednost stavke prodaje zaokružiti na dvije decimale. Izlaz formatirati na naèin da uz kolièinu stoji 'kom' (npr 50kom) a uz cijenu KM
--(npr 50KM). (AdventureWorks2017) 
USE AdventureWorks2019
GO
--Koristimo TOP(10) za najskupljih 10 jer sortiramo DESC po vrijednosti i DISTINCT kako ne bi prikazivali duplikate.
SELECT DISTINCT TOP(10) P.Name,CAST(SO.OrderQty AS NVARCHAR) + 'kom',CAST(ROUND(SO.UnitPrice,2) AS NVARCHAR)+ 'KM'AS Cijena,  --Kastamo u stringove sa CAST AS NVARCHAR
ROUND((SO.UnitPrice*SO.OrderQty),2) AS Vrijednost
FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SO ON P.ProductID=SO.ProductID  --Spojimo proizvod i stavku_prodaje
INNER JOIN Sales.SalesOrderDetail AS S ON S.SalesOrderID=SO.SalesOrderID --Spojimo prodaju i stavku_prodaje
ORDER BY 4 DESC

--Kreirati upit koji prikazuje ukupan broj kupaca po teritoriji. Lista treba da sadrži sljedeæe kolone: naziv teritorije, ukupan broj kupaca. 
--Uzeti u obzir samo teritorije gdje ima više od 1000 kupaca. (AdventureWorks2017) 
SELECT C.TerritoryID, COUNT(*) AS UkupanBrojKupaca
FROM  Sales.Customer AS C INNER JOIN Sales.SalesTerritory AS T ON C.TerritoryID=T.TerritoryID  --Spojimo kupca i teritoriju
GROUP BY C.TerritoryID  
HAVING COUNT(*)>1000  --Prikazemo samo ukoliko teritorija ima vise od 1000 kupaca

--Kreirati upit koji prikazuje zaradu od prodaje proizvoda. Lista treba da sadrži naziv proizvoda, ukupnu zaradu bez uraèunatog popusta 
--i ukupnu zaradu sa uraèunatim popustom.Iznos zarade zaokružiti na dvije decimale. Uslov je da se prikaže zarada samo za stavke gdje je
--bilo popusta. Listu sortirati po zaradi opadajuæim redoslijedom. (AdventureWorks2017) 
SELECT P.Name,ROUND(SUM(SO.OrderQty*SO.UnitPrice),2)AS ZaradaBezPopusta,ROUND(SUM(SO.OrderQty*SO.UnitPrice*(1-SO.UnitPriceDiscount)),2) AS ZaradaSaPopustom
FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS SO ON P.ProductID=SO.ProductID --Spojimo proizvod i stavku_prodaje
INNER JOIN Sales.SalesOrderDetail AS S ON S.SalesOrderID=SO.SalesOrderID  --Spojimo prodaju i stavku_prodaje
WHERE SO.UnitPriceDiscount >0  --Samo ukoliko je popust veci od 0 (tj. ako ima popusta)
GROUP BY P.Name  --Grupisemo po imenu proizvoda jer P.Name nije dio agregatne fije.
ORDER BY 2 DESC