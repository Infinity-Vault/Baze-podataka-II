CREATE DATABASE ZadaciZaVjezbu --Kreiramo bazu podataka imenovanu ZadaciZaVjezbu;
GO --Komanda GO izvrsi  prethodno napisanu komandu (linija iznad) kako ne bi doslo do toga da pristupamo bazi koju prethodno nismo kreirali  prvo;
USE ZadaciZaVjezbu --Kazemo da koristimo bazu koju smo kreirali;

CREATE TABLE Aplikant --Kreiramo tabelu;
(
--Atributi:
Ime NVARCHAR(10),
Prezime NVARCHAR(10),
Mjesto_rodjenja NVARCHAR(20)
)

ALTER TABLE Aplikant 
ADD AplikantID INT NOT NULL PRIMARY KEY IDENTITY(1,1) --Kreiramo primarni kljuc sa autoincrementom (IDENTITY, prvi parametar odakle krecemo drugi za koliko povecavamo);
--Ukoliko ne stavimo CONSTRAINT SQL sam imenuje PK;
CREATE TABLE Projekti --Kreiramo tabelu;
(
--Atributi:
Naziv_projekta NVARCHAR(25),
Akronim_projekta NVARCHAR(15),
Svrha_projekta NVARCHAR(15),
Cilj_projekta NVARCHAR(20)
)
ALTER TABLE Projekti --Kreiramo primarni kljuc sa autoincrementom (IDENTITY, prvi parametar odakle krecemo drugi za koliko povecavamo);
ADD  Sifra_projekta NVARCHAR(10) CONSTRAINT PK_SifraProjekta PRIMARY KEY

ALTER TABLE Aplikant --Kreiramo spoljni kljuc, konvencija je da se imenuje FK_TabelaIzKojeSePrenosi_TabelaUKojuSePrenosi;
ADD projekatID NVARCHAR(10) NOT NULL CONSTRAINT FK_Aplikant_Projekt FOREIGN KEY REFERENCES Projekti(Sifra_projekta)

CREATE TABLE Tmatska_oblast --Kreiramo  tabelu;
(
--Atributi
naziv NVARCHAR(20) NOT NULL,
opseg NVARCHAR(10) NOT NULL
)
ALTER TABLE Tmatska_oblast --Primarni kljuc;
ADD tematskaOblastID INT NOT NULL PRIMARY KEY IDENTITY(1,1)

ALTER TABLE Aplikant --Dodamo atribut;
ADD email NVARCHAR(15)

ALTER TABLE Aplikant
DROP COLUMN Mjesto_rodjenja --Obrisemo kolonu;

ALTER TABLE Aplikant --Dodamo dva nova atributa;
ADD Maticni_broj NVARCHAR(13)NOT NULL ,telefon NVARCHAR(10) NOT NULL

DROP TABLE Aplikant --Obrisemo tabele;
DROP TABLE Projekti

USE baza1 --Da bi obrisali trenutnu bazu, moramo izaci iz nje;

DROP DATABASE ZadaciZaVjezbu --Obrisemo bazu;