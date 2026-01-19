TRANSFORM Count([Mitarbeiter]) AS Anzahl
SELECT [Mitarbeiter], Count([Mitarbeiter]) AS Gesamt
FROM qry_Basis_Privat_2024
GROUP BY [Mitarbeiter]
ORDER BY [Mitarbeiter]
PIVOT [Monat] In ('Jan','Feb','Mrz','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez');

