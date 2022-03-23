
USE Northwind  --Koristimo bazu 
--Selektujemo godinu mjesec i dan i prikazemo te vrijednosti
SELECT Year(O.ShippedDate) AS Godina,
Month(O.ShippedDate) AS Mjesec,Day(O.ShippedDate) AS Dan
FROM dbo.Orders AS O

--Izracunamo razliku dva datuma, trenutni datum dobijamo sa GETDATE() funkcijom
SELECT DATEDIFF(YEAR,O.OrderDate,GETDATE()) AS Broj_godina
FROM dbo.Orders AS O 

SELECT*
FROM dbo.Employees AS E
WHERE E.FirstName Like 'A%'  

SELECT*
FROM pubs.dbo.employee AS E
--WHERE E.fname LIKE 'A%' OR E.fname LIKE 'M%'  --Prvi nacin
WHERE E.fname LIKE '[AM]%'  --[neki uslov] gledamo kao OR operator npr:  Like '[%ij%]' vraca rijec, rijeka,riva ali ne i roni
 
SELECT*
FROM Customers AS C
WHERE C.ContactTitle LIKE '%manager%' -- Kako bi nasli sa 'nesto manager nesto'

SELECT*
FROM Customers AS C
WHERE C.PostalCode LIKE '[0-9]%' AND C.PostalCode NOT LIKE '%-%' --Ne zelimo da nam vrati vrijednosti koje imaju - izmedju

SELECT*
FROM Customers AS C
WHERE C.PostalCode NOT LIKE '%[^0-9]%' --Znakom ^ negiramo sve sto nije broj i onda to opet negiramo tako da dobijemo onda samo brojeve

SELECT*
FROM Customers AS C
WHERE ISNUMERIC(C.PostalCode)=1  -- <> je nejednako dok je = jednako

CREATE DATABASE Vjezbe_3  --Kreiramo bazu
GO

USE Vjezbe_3  --Koristimo kreiranu bazu

SELECT PP.FirstName,PP.MiddleName,PP.LastName
INTO Osoba  --Kreiramo novu tabelu i kopiramo u nju
FROM AdventureWorks2019.Person.Person AS PP

SELECT O.FirstName+ ' ' + IsNull(O.MiddleName,' ') + ' ' + O.LastName AS ImePrezime  --Spajamo stringove medjutim
--ako je jedan od njih NULL, svi ostali ce biti tako da NULL vrijednost mjenjamo sa ' '
FROM Osoba AS O

UPDATE Osoba
SET MiddleName=' '
WHERE MiddleName IS NULL  --Zamjenimo NULL sa ' '

--Pomocu kljucne rijeci DISTINCT odaberemo samo one koji se ne ponavljaju
SELECT DISTINCT O.FirstName+ ' ' + O.MiddleName + ' ' + O.LastName AS ImePrezime
FROM Osoba AS O

--CONCAT zanemari NULL polja i ne pravi nam problem kao ranije slucaj; Sa ' ' pravimo space (razmak)
SELECT DISTINCT CONCAT(PP.FirstName,' ',PP.MiddleName,' ',PP.LastName) AS ImePrezime
FROM AdventureWorks2019.Person.Person AS PP


SELECT E.EmployeeID,E.FirstName,E.LastName,E.Country,E.Title
FROM Northwind.dbo.Employees AS E
WHERE E.EmployeeID=9 OR E.Country LIKE 'USA' 

SELECT O.OrderID,O.OrderDate,O.CustomerID,O.ShipCity
FROM Northwind.dbo.Orders AS O
WHERE O.OrderDate < '1996-07-19'  --godina-mjesec-dan format kako bi poredili dva datuma, postoje i drugi formati

SELECT*
FROM Northwind.dbo.[Order Details] AS OD
WHERE OD.Quantity>100 AND OD.Discount>0.0 --AND znaci da oba uslova moraju biti true

SELECT C.CompanyName, C.Phone
FROM Northwind.dbo.Customers AS C
WHERE C.CompanyName LIKE '%Restaurant%'  AND C.CompanyName NOT LIKE '%-%'  --Ne zelimo imena kompanija sa - u njima

SELECT*
FROM Northwind.dbo.Products AS P
WHERE P.ProductName LIKE '[CG]_[AO]%' --Prvo slovo moze biti C or G pa trece slovo A or O i onda nas ne zanima dalje
--Jedan karakter oznacimo sa _

SELECT*
FROM Northwind.dbo.Products  AS P
WHERE (P.ProductName LIKE '[LT]%' AND (P.UnitPrice>=10 AND P.UnitPrice<=50)) --Pazimo zagrade radi uslova
OR P.ProductID=46

SELECT P.ProductName, P.UnitPrice,(P.UnitsOnOrder-P.UnitsInStock) AS Razlika --Izracunamo razliku i damo alias;
--Ukoliko je alias jedna rijec ne trebaju navodnici ''  u suprotnom trebaju
FROM Northwind.dbo.Products AS P
WHERE P.UnitsOnOrder<P.UnitsInStock


--Ako je Fax polje NULL zamjenimo ga sa 'nema fax'
SELECT S.SupplierID,S.CompanyName, S.City,S.Region,S.Country,ISNULL(S.Fax,'nema fax') AS Fax,S.HomePage
FROM Northwind.dbo.Suppliers AS S
--WHERE (S.Country LIKE 'Spain' OR S.Country LIKE 'Germany') AND S.Fax IS NULL
WHERE (S.Country IN ('Spain','Germany') AND S.Fax IS NULL)
--Mozemo koristiti i IN koji radi kao OR operator

USE pubs  --Koristimo bazu

SELECT  A.au_id,A.au_fname,A.au_lname,A.city,A.contract
FROM authors AS A
WHERE (A.au_id LIKE '8%'  OR A.city LIKE 'Salt Lake City' ) AND A.contract=1  --Pazimo uslov i zagrade

SELECT DISTINCT T.type
FROM titles AS T
ORDER BY T.type  --Mozemo koristiti ili broj kolone ili alias imena kao u ovom slucaju

SELECT S.stor_id, S.ord_num,S.qty
FROM sales AS S
WHERE S.qty BETWEEN 10 AND 50  --BETWEEN ili S.qty>= 10 AND S.qty<=50
ORDER BY S.qty DESC

SELECT S.stor_id, S.ord_num,S.qty
FROM sales AS S
WHERE S.qty>= 10 AND S.qty<=50
ORDER BY S.qty DESC  --ili ORDER BY 3 (jer je treca kolona qty)


--Izracunamo 20% od cijene i cijenu umanjenu za 20%  i imenujemo ih tako:
SELECT T.title, T.type, T.price,(T.price*0.20) AS '20% od cijene',ROUND((T.price-(T.price*0.20)),2) AS 'Cijena umanjena za 20%'
FROM titles AS T
WHERE T.price IS NOT NULL 
ORDER BY  T.type,T.price DESC  --Sortiramo po 2 kolone

SELECT DISTINCT TOP 10 S.ord_num,S.ord_date,S.qty  --TOP [BROJ] nam omoguci [BROJ] recorda najvece vrijednosti kolone po kojoj sortiramo
FROM sales AS S
ORDER BY S.qty DESC  --Sortiramo opadajuce po qty (kolicini)