CREATE DATABASE Vjezba2  --Kreiramo novu bazu imena Vjezba2 
GO  --Izvrsimo gornju komandu
USE Vjezba2 --Pocnemo koristiti bazu koju smo kreirali
GO 
CREATE SCHEMA Prodaja --Kreiramo novu schemu;Scheme mozemo gledati kao namespace u kojem kreiramo tabele; Ako ga ne imenujemo default je dbo;
GO  --Moramo izvrsiti gornju komandu sa GO

CREATE TABLE Prodaja.Autori --Kreiramo tabelu u namespace (schemi) Prodaja
(
--Atributi:
AutorID VARCHAR(11) CONSTRAINT PK_Autor PRIMARY KEY, --Odmah dodamo PK i imenujemo ga
Prezime VARCHAR(40) NOT NULL,
Ime VARCHAR(20) NOT NULL,
Telefon CHAR(12) DEFAULT 'nepoznato', --Defaultne vrijednosti postavljamo sa kljucnom rijeci DEFAULT; Stringove pisemo samo pod jednim navodnicima ''
Adresa VARCHAR(40), 
Drzava CHAR(2),
PostanskiBroj CHAR(5),
Ugovor BIT NOT NULL  -- BIT polje predstavlja 0/1,Yes/No,True/False
)

CREATE TABLE Prodaja.Knjige  --Kreiramo jos jednu tabelu u istom namespace (schemi)
(
--Atributi:
KnjigaID VARCHAR(6) CONSTRAINT PK_KnjigaID PRIMARY KEY,  --Kreiramo imenovani PK
Naziv VARCHAR(80) NOT NULL,
Vrsta CHAR(12) NOT NULL,  --CHAR za razliku od VARCHAR ce nam kreirati niz karaktera fiksne duzine
IzdavacID CHAR(4), --Poslije postane FK
Cijena  MONEY,
Biljeska VARCHAR(200),
Datum DATETIME
)

SELECT *  --Selektujemo sve  recorde 
INTO Prodaja.Izdavaci  --U tabelu izdavaci
FROM pubs.dbo.publishers  --Iz tabele publishers baze pubs

ALTER TABLE Prodaja.Izdavaci  --Vrsimo izmjenu tabele Izdavaci
ADD CONSTRAINT PK_PubID PRIMARY KEY (pub_id) -- Postavimo pub_id na PK tabele

--Izdavac izdaje  1 ili N knjiga dok knjiga ima 1 i samo 1 izdavaca, stoga PK od izdavaca postaje FK kod knjige:
ALTER TABLE Prodaja.Knjige  
ADD CONSTRAINT FK_Knjiga_Izdavaci  FOREIGN KEY (IzdavacID) REFERENCES Prodaja.Izdavaci(pub_id)

CREATE TABLE Prodaja.AutorNaslovi  --Kreiramo jos jednu tabelu u namespace (schemi) Prodaja
(
--Atributi:
AutorID VARCHAR(11) CONSTRAINT FK_AutorNaslovi_Autori FOREIGN KEY REFERENCES Prodaja.Autori(AutorID),  --Kreiramo FK na tabelu Autori
KnjigaID VARCHAR(6) CONSTRAINT FK_AutorNaslovi_Knjige FOREIGN KEY REFERENCES Prodaja.Knjige(KnjigaID), --Kreiramo FK na tabelu Knjige
AuOrd TINYINT ,  --TINYINT je fizicki manja vrijednost punog INT tipa podatka (prostorno manja u memoriji kada se spremi)
CONSTRAINT PK_AutorNaslov PRIMARY KEY (AutorID,KnjigaID) --Posto je ovo medjutabela imamo kompozitni primarni kljuc koji se kreira samo navodjenjem ,
)

--U tabelu Autori izvrsimo ubacivanje podataka, ukoliko ne postujemo redosljed atributa onakav kakav je u tabeli samoj, onda eksplicitno
--u zagradama navodimo redosljed ubacivanja podataka iz izvorisne tabele;
INSERT INTO Prodaja.Autori(AutorID,Prezime,Ime,Telefon,Adresa,Drzava,Ugovor)
SELECT  A.au_id,A.au_lname,A.au_fname,A.phone,A.address,A.state,A.contract  --Odaberemo obiljezja koja zelimo ubaciti
FROM pubs.dbo.authors AS A -- Odaberemo izvorisnu tabelu tj. odakle ubacujemo podatke; AS kljucna rijec nam mogucava da entitet date tabele nazivamo
--nekim drugim imenom (alias)

--Radimo isto ubacivanje kao i na proslom primjeru:
INSERT INTO Prodaja.Knjige
--ISNULL funkcija nam omogucava provjeru da li je dato polje NULL vrijednost te ako jeste da se zamjeni sa necim sto mi specifiziramo; Dva parametra (polje,vrijednost koja mijenja ako je polje NULL);
SELECT T.title_id,T.title,T.type,T.pub_id,T.price,ISNULL(T.notes,'nepoznata vrijednost'),T.pubdate
FROM pubs.dbo.titles AS T

--Takodjer radimo isto ubacivanje kao i prethodna:
INSERT INTO Prodaja.AutorNaslovi(AutorID,KnjigaID,AuOrd)
SELECT AN.au_id, AN.title_id, AN.au_ord
FROM pubs.dbo.titleauthor AS AN


DELETE 
FROM Prodaja.AutorNaslovi --DELETE naredbom brisemo sav sadrzaj navedene tabele

ALTER TABLE Prodaja.Autori
ALTER COlUMN Adresa NVARCHAR(40)  --Na ovaj nacin mozemo mijenjati tipove podatka ukoliko su oni kompatibilni za promjenu ili ukoliko 
-- su polja prazna tada ne moraju biti kompatibilni za promjenu;
--Tipa ukoliko je polje bilo VARCHAR i mi ga  mijenjamo  u NVARCHAR nije potrebno da ono bude prazno, samo ce se izvrsiti konverzija;
--Ali ukoliko mijenjamo iz INT npr u  DATETIME mora polje da bude prazno kako bi se tip podatka zamjenio;

SELECT  A.Ime --Odaberemo sva imena autora
FROM Prodaja.Autori AS A  --Iz tabele Autori, kreiramo alias naziva A
WHERE A.Ime LIKE 'A%' OR A.Ime LIKE 'S%' --Koja pocinju sa A ili sa S; % u SQL jeziku ima ulogu * kod stringova, tj on mijenja sve karaktere;

SELECT *  --Odaberemo sve recorde
FROM Prodaja.Knjige AS K  --Tabele Knjige, kreiramo alias naziva K
WHERE K.Cijena IS NULL  --Gdje je polje Cijena null


--Kreiramo novu schemu:
GO
CREATE SCHEMA Narudzbe
GO

SELECT *  --Odaberemo sve recorde
INTO Narudzbe.Regije  --U tabelu Regije scheme Narudzbe, pri cemu se INTO naredbom kreira tabela i popuni a INSERT INTO samo popuni postojecu tabelu;
FROM  Northwind.dbo.Region  --Iz tabele Region baze Northwind

SELECT *  --Odaberemo sve recorde iz tabele i prikazemo ih
FROM Northwind.dbo.Region

INSERT INTO Narudzbe.Regije
VALUES (5,'SE')  --Pomocu naredbe VALUES mozemo dodavati nove zapise u tabelu; Dodavanje moze biti pojedinacno ili vise zapisa odjednom

INSERT INTO Narudzbe.Regije
VALUES (5,'NE'),(7,'NW')  --Primjer dodavanja vise zapisa odjednom

--Kreiramo tabelu StavkeNarudzbe i popunimo je vrijednostima tabele Order Details
SELECT *
INTO Narudzbe.StavkeNarudzbe
FROM Northwind.dbo.[Order Details]  --Ukoliko se ime tabele sastoji od razmaka SQL to predstavi u [] zagradama

ALTER TABLE Narudzbe.StavkeNarudzbe
ADD Ukupno DECIMAL(8,2)  --Dodamo i kreiramo polje Ukupno tipa DECIMAL;U zagradama navodimo ukupan broj brojeva prije zareza i broj brojeva iza zareza;
--Znaci ukoliko stavimo (8,2) Mozemo maaksimalno unijeti 123456,78 pri cemu drugi parametar uvijek ulazi (ubrojava) se u prvom parametru;

UPDATE Narudzbe.StavkeNarudzbe --UPDATE nam omogucava da specifiziramo koju tabelu updejtujemo
SET Ukupno=Quantity*UnitPrice --SET nam omogucava da setujemo novu vrijednost nekom polju iz navedene tabele


--Selektujemo sve recorde iz tabele StavkeNarudzbe i prikazemo ih
SELECT *
FROM Narudzbe.StavkeNarudzbe

ALTER TABLE Narudzbe.StavkeNarudzbe  --Modifikujemo tabelu
ADD CijeliDio AS FLOOR(UnitPrice)  --Dodamo i kreiramo polje CijeliDio koji ce biti float tip ali funkcijom FLOOR dobijemo donju vrijednost broja koji proslijedimo
--NPR ako kazemo FLOOR(14.56) vratice nam se 14.00

ALTER TABLE Narudzbe.StavkeNarudzbe
ADD CONSTRAINT  CK_Discount CHECK (Discount>=0)  --Kreiramo provjeru pri unosu takvu da polje Discount ne moze biti negativno
--Konvencija pri kreiranju CHECK-ova je CK_ImePoljaKojeProvjeravamo

CREATE TABLE Narudzbe.Kategorije  --Kreiramo tabelu
(
KategorijaID INT CONSTRAINT PK_Narudzba PRIMARY KEY IDENTITY (1,1),   --Kreiramo autoincrement koji pocinje od 1 i uvecava za 1 
ImeKategorije NVARCHAR(15) NOT NULL,
Opis NTEXT
)

--Zelimo da izvrsimo insert iz jedne tabele u drugu, medjutim u tabeli Kategorije imamo definisan IDENTITY nad PK-em stoga svakim dodavanjem
--se  on inkrementuje te se ne mogu vrijednosti prekopirati iz izvorisne tabele

--PORUKA SA GRESKOM UKOLIKO NE UKLJUCIMO IDENTITY_INSERT:
--Cannot insert explicit value for identity column in table 'Kategorije' when IDENTITY_INSERT is set to OFF.

SET IDENTITY_INSERT Narudzbe.Kategorije ON  --Ovaj problem rijesimo tako sto ukljucimo IDENTITY_INSERT
INSERT INTO Narudzbe.Kategorije (KategorijaID,ImeKategorije,Opis)
SELECT  C.CategoryID, C.CategoryName,C.Description
FROM Northwind.dbo.Categories AS C
SET IDENTITY_INSERT Narudzbe.Kategorije OFF --Te ga nakon insertovanja podataka ponovo iskljucimo jer ne zelimo da daljnje dodavanje ne bude autoincrement

--Ubacimo neki novi zapis u tabelu kako bi testirali autoincrement:
INSERT INTO Narudzbe.Kategorije
VALUES ('Ncategory','Neki opis')  --Polje za ID ne treba navoditi upravo jer je autoincrement


SELECT * FROM Narudzbe.Kategorije  --Provjerimo tabelu

UPDATE Narudzbe.Kategorije
SET Opis='bez opisa' WHERE Opis IS NULL --Gdje god je Opis polje NULL updejtujemo tu vrijednost na 'bez opisa'

--Ukoliko ne zelimo updejtovati sve vrijednosti moramo koristiti WHERE kako bi filtrirali sta zelimo updejtovati

DELETE FROM Narudzbe.Kategorije  --Obrisemo sve zapise tabele Kategorije

--Ukoliko ne zelimo obrisati sve vrijednosti moramo koristiti WHERE kako bi filtrirali sta zelimo obrisati
