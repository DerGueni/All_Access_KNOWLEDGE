TRANSFORM Sum([Stunden]*0.91) AS SummeStunden
SELECT qry_MA_Stunden_Basis.Mitarbeiter, Sum(qry_MA_Stunden_Basis.Stunden) AS Gesamt
FROM qry_MA_Stunden_Basis
GROUP BY qry_MA_Stunden_Basis.Mitarbeiter
ORDER BY qry_MA_Stunden_Basis.Mitarbeiter
PIVOT qry_MA_Stunden_Basis.Monat In ('Jan','Feb','Mrz','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez');

