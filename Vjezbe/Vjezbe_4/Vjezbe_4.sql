-- Funkcija left nam vraca specifizirani broj karaktera od proslijedjenog stringa sa lijeve strane
SELECT LEFT('Softverski inzinjering',2) --So

-- Funkcija right nam vraca specifizirani broj karaktera od proslijedjenog stringa sa desne strane
SELECT RIGHT('Softverski inzinjering',2) --ng

--Charindex funkcija ce nam iz datog stringa vratiti prvu poziciju na kojoj je nadjen proslijedjeni karakter
SELECT CHARINDEX(' ','Softverski inzinjering') --Rez 11,index prve pojave karaktera space

--Substring funkcija ce iz datog stringa, na pocetnoj poziciji uzeti dati broj karaktera. NOTE: pocetna pozicija se ukljucuje u uzete karaktere
SELECT SUBSTRING('Softverski inzinjering',11+1,11) --+1 jer space ne zelimo da racunamo

--Upper funkcija  dati string pretvori u sva velika slova
SELECT UPPER('Softverski inzinjering')

--Lower funkcija dati string pretvori u sva mala slova
SELECT LOWER('Softverski inzinjering')

--Len funkcija vrati broj karaktera u stringu (ukljucujuci space kao jedan char)
SELECT LEN('Softverski inzinjering')

--Replace funkcija u datom stringu pronadje ono sto trazimo (drugim parametrom) i zamjeni ga sa trecim parametrom
SELECT REPLACE('Softverski inzinjering','i','*')

--Stuff funkcija ce da dati string, u datoj poziciji (drugi parametar), odredjeni  broj karaktera (treci parametar) zamjeniti sa datim karakterima  (cetvrti parametar) 
SELECT STUFF('Softverski inzinjering',3,2,'XY')

--Patindex ce traziti dati iskaz u stringu. Npr ovdje trazi bilo koji range brojeva od 0 do 9 u datom stringu, i vrati prvu poziciju gdje je nasao neki broj
SELECT PATINDEX('%[0-9]%','FITCC2022')

--Str ce dati iskaz pretvoriti u string tip
SELECT STR(122) + '.'

--Reverse funkcija ce samo zamjeniti redosljed karaktera  (nimeS)
SELECT REVERSE('Semin')

----------------------------------------------ZADACI-----------------------------------------------------------------------
USE AdventureWorks2019 --Koristimo bazu 

--Uzmemo iz kolone LoginID novi string, pocevsi od pozicije karaktera gdje nadjemo \ do duzine stringa oduzete sa nadjenom pozicijom \ i 1 (1 radi broja na kraju)
SELECT SUBSTRING(E.LoginID,CHARINDEX('\',E.LoginID)+1,LEN(E.LoginID)-CHARINDEX('\',E.LoginID)-1)
FROM HumanResources.Employee AS E  --Iz tabele Employee


--Odaberemo samo ime sa kraja od LoginID kao i gore,i obrnutom dijelu stringa rowguid od pozicije 6 do 8  na poziciju 2 umetnemo umjesto sljedeca 2 karaktera X#
SELECT SUBSTRING(E.LoginID,CHARINDEX('\',E.LoginID)+1,LEN(E.LoginID)-CHARINDEX('\',E.LoginID)) 
AS 'ID uposlenika',STUFF(SUBSTRING(REVERSE(E.rowguid),6,8),2,2,'X#') AS Lozinka
FROM HumanResources.Employee AS E  --Iz tabele Employee

--Uzmemo sa desna sve iz polja AccountNumber sem prva dva slova (zato-2), i to castamo u broj kako bi pocetne nule eliminisali
SELECT CAST(RIGHT(C.AccountNumber,LEN(C.AccountNumber)-2)AS INT)
FROM Sales.Customer AS C  --Iz tabele Customer

SELECT CAST(RIGHT(C.AccountNumber,LEN(C.AccountNumber)-2)AS INT)
FROM Sales.Customer AS C
WHERE C.PersonID IS NOT NULL --Isto kao i gore samo sada selektujemo zapise kod kojih je PersonID neprazan

--Uzmemo sa lijeva string sve do prvog pojavljivanja broja iskljucujuci njega (zato je -1) jer zelimo sve iz AccountNumber bez brojeva zadnjih
SELECT V.AccountNumber,V.Name,LEFT(V.AccountNumber,PATINDEX('%[0-9]%',V.AccountNumber)-1),
--Posto postoji mogucnost imena koji nemaju space,testiramo da li je bez space ime, ako jeste samo ga damo, ako nije uzmemo sa left do prve pojace razmaka
IIF (CHARINDEX(' ',V.Name)=0,V.Name,LEFT(V.Name,CHARINDEX(' ',V.Name)-1))
FROM Purchasing.Vendor AS V
WHERE  LEFT(V.AccountNumber,PATINDEX('%[0-9]%',V.AccountNumber)-1)=
IIF (CHARINDEX(' ',V.Name)=0,V.Name,LEFT(V.Name,CHARINDEX(' ',V.Name)-1))  --Vratimo samo one zapise kojima je prvi dio AccountNumber i Name isti.


USE Northwind --Koristimo bazu

SELECT C.ContactName,LEFT(C.ContactName,CHARINDEX(' ',C.ContactName)-1),--Zelimo prvi dio kontakt imena tako da sa lijeva uzmemo sve do space
RIGHT(C.ContactName,CHARINDEX(' ',REVERSE(C.ContactName))-1),C.Address, --Zelimo da uzmemo prezime, tako da obrnemo string i uzmemo sa desna poslije razmaka sve.
RIGHT(C.Address,CHARINDEX(' ',REVERSE(C.Address))-1) --Zelimo zadnji dio adrese poslije space, tako da idemo opet reverse i uzmemo right sve od space
FROM dbo.Customers AS C  --Iz tabele Customers
WHERE IIF(ISNUMERIC(RIGHT(C.Address,CHARINDEX(' ',REVERSE(C.Address))-1))=1, --=1 znaci vrijednost true
RIGHT(C.Address,CHARINDEX(' ',REVERSE(C.Address))-1),0)>=10 AND  --Zelimo zapise ciji je zadnji broj od dvije ili vise cifri, tako da provjerimo da li je cifra, uzmemo je ako jeste a ako nije stavimo 0 i provjerimo da li je vece = 10 (dvije cifre)
LEN(C.ContactName)-LEN(REPLACE(C.ContactName,' ',''))=1 --Takodjer moramo vidjeti da li se ContactName sastoji od dvije rijeci
--Logika jeste da uzmemo pocetnu duzinu i  oduzmemo sa duzinom stringa gdje smo razmak zamjenili sa spojenim znakom, ako je ta razlika =1 imamo jedan space sto znaci da je ime od dvije rijeci.


--Uzmemo zadnji karakter polja ContactName (dio imena/prve rijeci), ukoliko je on a radi se o Female ukoliko je bilo sta drugo radi se o Male.
SELECT C.ContactName,IIF(RIGHT(LEFT(C.ContactName,CHARINDEX(' ',C.ContactName)-1),1)='a',
'FEMALE','MALE')
FROM dbo.Customers AS C  --Iz tabele Customers

ALTER TABLE dbo.Customers  --Vrsimo izmjene u tabeli
ADD Spol AS (IIF(RIGHT(LEFT(ContactName,CHARINDEX(' ',ContactName)-1),1)='a',  --Dodamo calculated polje kao iskaz gornji
'FEMALE','MALE'))

SELECT *
FROM dbo.Customers  --Vidimo promjene