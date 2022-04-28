--1.
--a) Upotrebom podupita iz tabele Customers baze Northwind dati prikaz 
--svih polja tabele pri èemu je kupac iz Berlina. 
USE Northwind
GO
SELECT*
FROM Customers AS C
WHERE C.City=(SELECT C.City
				FROM Customers AS C
				WHERE C.City LIKE 'Berlin')--Vratimo sve zapise gdje je grad Berlin.

--b) Upotrebom podupita iz tabele Customers baze Northwind dati prikaz svih 
--polja tabele pri èemu je kupac iz Londona ili Berlina. 
SELECT*
FROM Customers AS C
WHERE C.City IN (SELECT C.City  --Sada koristimo IN operator jer imamo vise od jedne moguce vrijednosti
				FROM Customers AS C
				WHERE C.City LIKE 'Berlin' OR C.City LIKE 'London')

--2.	Prikazati srednju vrijednost nabavljene kolièine, u obzir uzeti samo
--one zapise u kojima je vrijednost UnitPrice izmeðu 50 i 100 (ukljuèujuæi 
--graniène vrijednosti). (AdventureWorks2017)
USE AdventureWorks2019
GO
SELECT AVG(PO.OrderQty) AS SrednjaVrijednostNabavljeneKolicine
FROM Purchasing.PurchaseOrderDetail AS PO
WHERE PO.UnitPrice IN (SELECT PO1.UnitPrice
						FROM Purchasing.PurchaseOrderDetail AS PO1
						WHERE PO1.UnitPrice BETWEEN 50 AND 100)  --Vratimo samo one zapise gdje je cijena izmedju 50 i 100

--3.	Prikazati ID narudžbe(i) u kojima je naruèena kolièina jednaka minimalnoj,
--odnosno, maksimalnoj vrijednosti svih naruèenih kolièina. (Northwind)
USE Northwind
GO

SELECT DISTINCT OD.OrderID  --DISTINCT jer  imamo duplikatnih OrderID
FROM [Order Details] AS OD
--U WHERE sa OR poredimo ili =MIN ili =MAX
WHERE OD.Quantity=(SELECT MIN(OD1.Quantity) AS MinNarucenaKolicinaSvih
					FROM [Order Details] AS OD1)  --Vratimo MIN
					OR OD.Quantity=(SELECT MAX(OD1.Quantity) AS MaxNarucenaKolicinaSvih
									FROM [Order Details] AS OD1)  --Vratimo MAX

--4.	Prikazati  ID narudžbe i ID kupca koji je kupio više od 10 komada 
--proizvoda èiji je ID 15. (Northwind)
SELECT OD.OrderID,O.CustomerID
FROM [Order Details] AS OD INNER JOIN Orders AS O ON OD.OrderID=O.OrderID  --Spojimo narudzbu i stavku narudzbe
WHERE OD.Quantity>10 AND OD.ProductID=(SELECT P.ProductID
										FROM Products AS P
										WHERE P.ProductID=15) --Vratimo zapise gdje id=15

--5.	Prikazati sve osobe koje nemaju prihode, vanredni i redovni. (Prihodi) 
USE prihodi
GO
SELECT*
FROM Osoba AS O LEFT OUTER JOIN RedovniPrihodi AS RP ON RP.OsobaID=O.OsobaID  --Spojimo osobu i RP
LEFT OUTER JOIN VanredniPrihodi AS VP ON VP.OsobaID=O.OsobaID  --Spojimo osobu i VP
WHERE RP.OsobaID IS NULL AND  VP.OsobaID IS NULL  --Damo uslov da je NULL FK

--Ili isto mozemo pomocu NOT EXISTS, jer se traze osobe koje nemaju ni RP ni VP:
SELECT*
FROM Osoba AS O 
WHERE  NOT EXISTS (SELECT*
					FROM VanredniPrihodi AS VP
					WHERE O.OsobaID=VP.OsobaID) AND NOT EXISTS (SELECT*
																FROM RedovniPrihodi AS RP
																WHERE RP.OsobaID=O.OsobaID)

--6.	Dati prikaz ID narudžbe, ID proizvoda i jediniène cijene, te razliku 
--cijene u odnosu na srednju vrijednost cijene za sve stavke.
--Rezultat sortirati prema vrijednosti razlike u rastuæem redoslijedu. (Northwind)
USE Northwind
GO
SELECT OD.OrderID, OD.ProductID,OD.UnitPrice,
(OD.UnitPrice-(SELECT AVG(OD1.UnitPrice) FROM[Order Details] AS OD1)) AS  Razlika  --Srednju vrijednost iskalkulisemo upitom
FROM [Order Details] AS OD
ORDER BY 4 ASC

--7.	Za sve proizvode kojih ima na stanju dati prikaz ID proizvoda, 
--naziv proizvoda i stanje zaliha, te razliku stanja zaliha proizvoda u odnosu 
--na srednju vrijednost stanja za sve proizvode u tabeli. 
--Rezultat sortirati prema vrijednosti razlike u opadajuæem redoslijedu.(Northwind)
SELECT P.ProductID,P.ProductName,P.UnitsInStock,(P.UnitsInStock-(
SELECT AVG(P1.UnitsInStock) FROM Products AS P1)) AS Razlika  --Srednju vrijednost iskalkulisemo podupitom
FROM Products AS P
WHERE P.UnitsInStock>0
ORDER BY 3 DESC

--8.Prikazati po 5 najstarijih zaposlenika muškog, odnosno, ženskog pola 
--uz navoðenje sljedeæih podataka: radno mjesto na kojem se nalazi, 
--datum roðenja, korisnicko ime i godine starosti. 
--Korisnièko ime je dio podatka u LoginID. 
--Rezultate sortirati prema polu rastuæim, a zatim prema godinama starosti 
--opadajuæim redoslijedom. (AdventureWorks2017)
USE AdventureWorks2019
GO
SELECT F.JobTitle,F.Gender,F.BirthDay,F.GodineStarosti,F.KorisnickoIme
FROM
(SELECT TOP(5) E.JobTitle,E.Gender,FORMAT(E.BirthDate,'dd.MM.yyyy') AS BirthDay,
	DATEDIFF(YEAR,E.BirthDate,GETDATE()) AS GodineStarosti, 
	SUBSTRING(E.LoginID,CHARINDEX('\',E.LoginID)+1,(LEN(E.LoginID)-CHARINDEX('\',E.loginID))-1) AS KorisnickoIme --SUBSTRING ce vratiti string gdje je kod pocetnog stringa (parametar 1) na lokaciji (parametar 2) uzeo (parametar 3) broj karaktera
	FROM HumanResources.Employee AS E 
	WHERE E.Gender='F'  --Odaberemo samo zene
	ORDER BY E.Gender ASC, GodineStarosti DESC)AS F  --Sortiramo po spolu rastuce i prema godinama opadajuce, takodje damo alias "novoj" tabeli/data source-u
	--Uvijek prvo stavljati u order by ono sta sortiramo rastucim, pa onda ono sta sortiramo opadajucim.
UNION--Unijom spojimo sve kombinacije jednog i drugog upita koje se podudaraju
SELECT M.JobTitle,M.Gender,M.BirthDay,M.GodineStarosti,M.KorisnickoIme
FROM (SELECT TOP(5) E.JobTitle,E.Gender,FORMAT(E.BirthDate,'dd.MM.yyyy') AS BirthDay,DATEDIFF(YEAR,E.BirthDate,GETDATE()) AS GodineStarosti, SUBSTRING(E.LoginID,CHARINDEX('\',E.LoginID)+1,(LEN(E.LoginID)-CHARINDEX('\',E.loginID))-1)AS KorisnickoIme
		FROM HumanResources.Employee AS E 
		WHERE E.Gender='M'  --Odaberemo samo muskarce
		ORDER BY E.Gender ASC, GodineStarosti DESC) AS M  --Damo alias "novoj" tabeli/data source-u
ORDER BY Gender ASC, GodineStarosti DESC--Sortiramo po spolu rastuce i prema godinama opadajuce, ovdje sortiramo ishod UNION-a

--9.Prikazati po 3 zaposlenika koji obavljaju poslove managera uz navoðenje sljedeæih podataka: radno mjesto na kojem se 
--nalazi, datum zaposlenja, braèni status i staž. Ako osoba nije u braku plaæa dodatni porez (upitom naglasiti to), 
--inaèe ne plaæa. Rezultate sortirati prema braènom statusu rastuæim, a zatim prema stažu opadajuæim redoslijedom. (AdventureWorks2017)
SELECT E.JobTitle,FORMAT(E.HireDate,'dd.MM.yyyy') AS DatumZaposlenja, --Formatiramo datum
E.MaritalStatus,DATEDIFF(YEAR,E.HireDate,GETDATE()) AS Staz,
IIF(E.MaritalStatus='S','Placa dodatni porez','Ne placa dodatni porez') AS DodatniPorez  --Ispitamo atribut i IIF-om damo ishod
FROM HumanResources.Employee AS E
ORDER BY E.MaritalStatus ASC,Staz DESC

--10.Prikazati po 5 osoba koje se nalaze na 1, odnosno, 4.  organizacionom nivou, uposlenici su i žele primati email ponude
--od AdventureWorksa uz navoðenje sljedeæih polja: ime i prezime osobe kao jedinstveno polje, organizacijski nivo na kojem se
--nalazi i da li prima email promocije. Pored ovih uvesti i polje koje æe sadržavati poruke: Ne prima (0), Prima selektirane (1)
--i Prima (2). Sadržaj novog polja ovisi o vrijednosti polja EmailPromotion. Rezultat sortirati prema organizacijskom nivou
--i dodatno uvedenom polju. (AdventureWorks2017)
SELECT TOP(5) (P.FirstName + ' '+ P.LastName) AS 'Ime i prezime', OrganizationLevel,P.EmailPromotion,CASE WHEN P.EmailPromotion=0 THEN 'Ne prima'
																							WHEN P.EmailPromotion=1 THEN 'Prima selektirane'
																							WHEN P.EmailPromotion=2 THEN 'Prima' 
																							END AS 'Prima li mailove'  --CASE je slican switch iskazu u programiranju, ukoliko se odredjeni uslov ispuni izvrsi se odredjeni dio koda
FROM Person.Person AS P INNER JOIN HumanResources.Employee AS E ON E.BusinessEntityID=P.BusinessEntityID
WHERE E.OrganizationLevel=1  --Samo organizacijski level 1
UNION--Napravimo uniju ova dva upita
SELECT TOP(5) (P.FirstName + ' '+ P.LastName) AS 'Ime i prezime', E.OrganizationLevel,P.EmailPromotion, (CASE WHEN P.EmailPromotion=0 THEN 'Ne prima'
																							WHEN P.EmailPromotion=1 THEN 'Prima selektirane'
																							WHEN P.EmailPromotion=2 THEN 'Prima' 
																							END) AS 'Prima li mailove'
FROM Person.Person AS P INNER JOIN HumanResources.Employee AS E ON E.BusinessEntityID=P.BusinessEntityID
WHERE E.OrganizationLevel=4 --Samo organizacijski level 4
ORDER BY OrganizationLevel ASC,[Prima li mailove] ASC

--11.Prikazati broj narudžbe, datum narudžbe i datum isporuke za narudžbe koje su isporuèene u Kanadu u 7. mjesecu 2014.
--godine. Uzeti u obzir samo narudžbe koje nisu plaæene kreditnom karticom. Datume formatirati u sljedeæem obliku: dd.mm.yyyy. 
--(AdventureWorks2017)
SELECT CR.Name,SalesOrderID,FORMAT(SO.OrderDate,'dd.MM.yyyy')AS DatumNarudzbe,
FORMAT(SO.ShipDate,'dd.MM.yyyy')AS DatumIsporuke
FROM Sales.SalesOrderHeader AS SO INNER JOIN Person.Address AS A ON A.AddressID=SO.ShipToAddressID  --Spojimo SalesOrder i Adresu
INNER JOIN Person.StateProvince AS SP ON SP.StateProvinceID=A.StateProvinceID  --Spojimo provincije
INNER JOIN Person.CountryRegion AS CR ON CR.CountryRegionCode=SP.CountryRegionCode  --Spojimo regije
WHERE CR.Name LIKE 'Canada' AND (MONTH(SO.ShipDate)=7 AND YEAR(SO.ShipDate)=2014) AND SO.CreditCardID IS NULL  --NULL jer trebamo one koji nisu platili karticom

--12.Kreirati upit koji prikazuje minimalnu, maksimalnu, prosjeènu te ukupnu zaradu po mjesecima u 2013. godini.(AdventureWorks2017)
SELECT MONTH(SO.ModifiedDate) AS Mjesec,MIN(SO.UnitPrice*SO.OrderQty) AS MinimalnaZarada,
MAX(SO.UnitPrice*SO.OrderQty) AS MaksimalnaZarada,AVG(SO.UnitPrice*SO.OrderQty) AS ProsjecnaZarada
FROM  Sales.SalesOrderDetail AS SO
GROUP BY MONTH(SO.ModifiedDate)--Grupisemo po mjesecima
ORDER BY 1 DESC  
--13.Kreirati upit koji prikazuje ime i prezime, korisnièko ime (sve iza znaka „\“ u koloni LoginID), 
--dužinu korisnièkog imena, titulu, datum zaposlenja (dd.mm.yyyy), starost i staž zaposlenika. 
--Uslov je da se prikaže 10 najstarijih zaposlenika koji obavljaju bilo koju ulogu menadžera. (AdventureWorks2017)

SELECT TOP(10)(P.FirstName+' ' + P.LastName) AS 'Ime i prezime',
SUBSTRING(E.LoginID,CHARINDEX('\',E.LoginID)+1,LEN(E.LoginID)-CHARINDEX('\',E.LoginID)) AS 'Korisnicko ime',--Isto kao i u primjeru gore, samo sada ne uzimamo zadnju cifru, vec je ostavljamo
LEN(SUBSTRING(E.LoginID,CHARINDEX('\',E.LoginID)+1,LEN(E.LoginID)-CHARINDEX('\',E.LoginID))) AS 'Duzina korisnickog imena',
E.JobTitle,FORMAT(E.HireDate,'dd.MM.yyyy') AS DatumZaposlenja,DATEDIFF(YEAR,E.BirthDate,GETDATE())AS Starost,
DATEDIFF(YEAR,E.HireDate,GETDATE())AS StazZaposlenika
FROM HumanResources.Employee AS E INNER JOIN Person.Person AS P ON P.BusinessEntityID=E.BusinessEntityID  --Spojimo Employe i osobu
WHERE E.JobTitle LIKE '%Manager%'
ORDER BY Starost DESC

--14.Kreirati upit koji prikazuje 10 najskupljih stavki prodaje (detalji narudžbe) i to sljedeæe kolone: naziv proizvoda,
--kolièina, cijena, iznos. Cijenu i iznos zaokružiti na dvije decimale. Takoðer, kolièinu prikazati u formatu „10 kom.“,
--a cijenu i iznos u formatu „1000 KM“. (AdventureWorks2017)
SELECT P.Name,STR(POD.OrderQty)+' kom'AS Kolicina,STR(ROUND(POD.UnitPrice,2))+' KM'AS Cijena,
STR(ROUND(POD.UnitPrice*POD.OrderQty,2))+' KM'AS Iznos  --Formatiramo izgled kolona
FROM Purchasing.PurchaseOrderDetail AS POD INNER JOIN Production.Product AS P ON P.ProductID=POD.ProductID  --Spojimo stavku narudzbe  i proizvod

--15.Kreirati upit koji prikazuje naziv modela i opis modela proizvoda. Uslov je da naziv modela sadrži rijeè „Mountain“, 
--dok je opis potrebno prikazati samo na engleskom jeziku. (AdventureWorks2017)
SELECT PM.Name,PD.Description
FROM Production.Product AS P INNER JOIN Production.ProductModel AS PM ON PM.ProductModelID=P.ProductModelID  --Spojimo proizvod i model proizvoda
INNER JOIN Production.ProductModelProductDescriptionCulture AS PDC ON PDC.ProductModelID=P.ProductModelID  --Spojimo medjutabelu i proizvod
INNER JOIN Production.Culture AS C ON C.CultureID=PDC.CultureID  --Spojimo medjutabelu i kulturu
INNER JOIN Production.ProductDescription AS PD ON PD.ProductDescriptionID=PDC.ProductDescriptionID  --Spojimo medjutabelu i opis proizvoda
WHERE P.Name LIKE 'Mountain%' AND C.Name LIKE 'English'
--naziv mora imati Mountain dok kultura (jezik) mora biti  engleska(i)

--16.Kreirati upit koji prikazuje broj, naziv i cijenu proizvoda, te stanje zaliha po lokacijama. 
--Uzeti u obzir samo proizvode koji pripadaju kategoriji „Bikes“. Izlaz sortirati po stanju zaliha u opadajuæem 
--redoslijedu. (AdventureWorks2017)
SELECT  L.Name,P.ProductNumber,P.Name,P.ListPrice,PII.Quantity
FROM Production.Product AS P INNER JOIN Production.ProductInventory AS PII ON PII.ProductID=P.ProductID  --Spojimo proizvod i zalihe
INNER JOIN Production.Location AS L ON L.LocationID=PII.LocationID  --Spojimo lokaciju i zalihe
INNER JOIN Production.ProductSubCategory AS PSC ON PSC.ProductSubcategoryID=P.ProductSubcategoryID  --Spojimo podkategoriju i proizvod
INNER JOIN Production.ProductCategory AS PC ON PC.ProductCategoryID=PSC.ProductCategoryID  --Spojimo kategoriju i podkategoriju
WHERE PC.Name LIKE 'Bikes%'  --Uslov da je ime kategorije Bikes pa bilo sta iza
GROUP BY L.Name,P.ProductNumber,P.Name,P.ListPrice,PII.Quantity  --Grupisemo po svim kolonama select-a jer nemamo nijednu agregatnu fiju
ORDER BY PII.Quantity DESC 

--17.Kreirati upit koji prikazuje ukupno ostvarenu zaradu po zaposleniku, na podruèju Evrope, u januaru mjesecu 2014.
--godine. Lista treba da sadrži ime i prezime zaposlenika, datum zaposlenja (dd.mm.yyyy), mail adresu, 
--te ukupnu ostvarenu zaradu zaokruženu na dvije decimale.
--Izlaz sortirati po zaradi u opadajuæem redoslijedu. (AdventureWorks2017)  
SELECT (P.FirstName+' '+P.LastName) AS 'Ime i prezime',FORMAT(E.HireDate,'dd.MM.yyyy') AS DatumZaposlenja,
EA.EmailAddress,ROUND(SUM(SOD.OrderQty*SOD.UnitPrice),2) AS UkupnoOstvarenaZarada
FROM Person.Person AS P INNER JOIN  HumanResources.Employee AS E ON P.BusinessEntityID=E.BusinessEntityID  --Spojimo osobu i uposlenika
INNER JOIN Sales.SalesPerson AS SP ON SP.BusinessEntityID=E.BusinessEntityID  --Spojimo prodavaca i uposlenika
INNER JOIN Person.EmailAddress AS EA ON EA.BusinessEntityID=SP.BusinessEntityID   --Spojimo mail adresu i prodavaca
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOH.SalesPersonID=SP.BusinessEntityID --Spojimo narudzbu i prodavaca
INNER JOIN Sales.SalesTerritory AS ST ON ST.TerritoryID=SOH.TerritoryID  --Spojimo teritoriju i narudzbu na toj teritoriji
INNER JOIN Sales.SalesOrderDetail AS SOD ON SOD.SalesOrderID=SOH.SalesOrderID  --Spojimo stavku narudzbe i narudzbu
WHERE ST.[Group] LIKE 'Europe' AND (MONTH(SOH.OrderDate)=1 AND YEAR(SOH.OrderDate)=2014) --Uslov da je na podrucje Europe te da je mjesec januar i godina 2014
GROUP BY (P.FirstName+' '+P.LastName),FORMAT(E.HireDate,'dd.MM.yyyy'),EA.EmailAddress
ORDER BY UkupnoOstvarenaZarada DESC