CREATE DATABASE baza1 --Kreiramo bazu sa datim imenom;
GO --Izvrsimo prethodnu komandu jer u suprotnom ne mozemo uci u bazu koja jos nije kreirana;
USE baza1 --Udjemo/krenemo koristiti kreiranu bazu;

CREATE TABLE Studenti --Kreiramo tabelu;
(
--Kreiramo atribute:
brojIndeksa NVARCHAR (10),
ime NVARCHAR (10),
prezime NVARCHAR(20)
)

ALTER TABLE Studenti --Kreiramo primarni kljuc bez autoincrement-a; Po defaultu PRIMARY KEY implementira NOT NULL;
ADD CONSTRAINT PK_Student PRIMARY KEY (brojIndeksa)

ALTER TABLE Studenti
DROP COLUMN brojIndeksa --Obrisemo kolonu;

ALTER TABLE Studenti
ADD brojIndeksa NVARCHAR (10) CONSTRAINT PK_Student PRIMARY KEY (brojIndeksa) --Postavimo da je brojIndeksa primarni kljuc tabele Studenti;

ALTER TABLE Studenti --Kreiramo dva nova atributa, pri cemu email je unikatan UNIQUE;
ADD email NVARCHAR(50) NOT NULL CONSTRAINT  UQ_Student_email UNIQUE,
telefon NVARCHAR(15) 

CREATE TABLE Fakulteti --Kreiramo tabelu;
(
--Kreiramo atribute:
FakultetID INT CONSTRAINT PK_Fakulteti PRIMARY KEY  IDENTITY(1,1),--Primarni kljuc mozemo odmah u tabeli kreirati;IDENTITY kreira osobinu autoincrementa za dati atribut, pri cemu je prvi parametar pocetna (prva) vrijednost a drugi parametar broj povecavanja;
Naziv NVARCHAR(50)
)

ALTER TABLE Studenti --Modifikujemo tabelu;
ADD FakultetID INT NOT NULL CONSTRAINT FK_Student_Fakultet FOREIGN KEY REFERENCES Fakulteti(FakultetID)
--Kreiramo spoljni kljuc u tabelu Studenti, konvencija imenovanja: FK_TabelaIzKojeKljucPrelazi_TabelaUKojuKljucPrelazi;

--NOTE:

--Tip podatka NVARCHAR, ukoliko nema zagrada pored sebe, kreirati ce jedan karakter;Zagradama, tacnije brojem u njima, kreiramo duzinu stringa;
