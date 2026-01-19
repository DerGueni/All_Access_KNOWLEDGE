TRANSFORM Count(qry_Basis_Privat_2024_Mini.[Mitarbeiter]) AS Anzahl
SELECT qry_Basis_Privat_2024_Mini.[Mitarbeiter], Count(qry_Basis_Privat_2024_Mini.[Mitarbeiter]) AS Gesamt
FROM qry_Basis_Privat_2024_Mini
GROUP BY qry_Basis_Privat_2024_Mini.[Mitarbeiter]
ORDER BY qry_Basis_Privat_2024_Mini.[Mitarbeiter]
PIVOT qry_Basis_Privat_2024_Mini.[Monat] In ('Jan','Feb','Mrz','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez');

