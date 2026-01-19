TRANSFORM Sum([Stunden]) AS SummeStunden
SELECT [Mitarbeiter], Sum([Stunden]) AS Gesamt
FROM qry_MA_Stunden_Basis_2023_Mini
GROUP BY [Mitarbeiter]
ORDER BY [Mitarbeiter]
PIVOT [Monat] In ('Jan','Feb','Mrz','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez');

