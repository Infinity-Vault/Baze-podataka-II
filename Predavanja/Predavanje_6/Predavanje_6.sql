--Prikazemo sifru i naziv drzave, kao i broj projekata. Spojimo projekte i donatore kao i donatore i drzave
--Filtriramo kako bi prikazali samo one koji imaju vrijednost vecu od milion i ako je broj projekata veci od tri.
SELECT D.sifra,D.naziv,COUNT(*) brojProjekata
FROM dbo.projekti as P INNER JOIN dbo.donatori as DO ON P.id_donator=DO.sifra 
INNER JOIN dbo.Drzave as D ON DO.id_drzava=D.sifra
WHERE P.vrijednost > 1000000
GROUP BY D.sifra,D.naziv
HAVING COUNT(*) >3

--Prikazemo sifru i naziv drzave kao i ukupnu vrijednost projekta. Spojimo projekte i donatore,i drzave i donatore.
--Prikazemo samo one zapise cija je ukupna vrijednost projekta veca od 5 miliona.
SELECT D.sifra,D.naziv,SUM(P.vrijednost) UkupnaVrijednostProjekta
FROM dbo.projekti as P INNER JOIN dbo.donatori as DO ON P.id_donator=DO.sifra 
INNER JOIN dbo.Drzave as D ON DO.id_drzave=D.sifra
HAVING SUM(P.vrijednost)>5000000

--Prikazemo ime profesora i prezime, naziv fakulteta i broj projekata koje su vodili. Povezemo projekte i profesore kao i fakultete i profesore.
--Prikazemo samo one profesore koji su vodili vise od dva projekta.
SELECT PRO.ime,PRO.prezime,F.naziv,COUNT(*) BrojProjekataVodjenih
FROM dbo.projekti as P INNER JOIN dbo.profesori as PRO ON P.id_voditelj=PRO.sifra
INNER JOIN dbo.fakulteti as F ON PRO.id_fakulteta=F.sifra
GROUP BY  PRO.ime,PRO.prezime,F.naziv
HAVING COUNT(*) >2


--Prikazemo sifru fakulteta, naziv  i broj profesora na projektu. Povezemo profesore i fakultete, i takodjer ucesnice projekta i profesore.
SELECT F.sifra,F.naziv,COUNT(*) BrojProfesoraNaProjektu
FROM dbo.profesori as PRO  INNER JOIN dbo.fakulteti as F ON PRO.id_fakultet=F.sifra
INNER JOIN dbo.projeki_ucesnici as PU ON PU.id_profesor=PRO.sifra
GROUP BY  F.sifra,F.naziv