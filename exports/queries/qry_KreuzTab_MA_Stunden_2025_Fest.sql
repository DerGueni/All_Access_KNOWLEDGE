TRANSFORM Sum(qry_MA_Stunden_Basis_Fest.Stunden) AS SummeStunden
SELECT qry_MA_Stunden_Basis_Fest.Mitarbeiter, Sum(qry_MA_Stunden_Basis_Fest.Stunden) AS Gesamt
FROM qry_MA_Stunden_Basis_Fest
GROUP BY qry_MA_Stunden_Basis_Fest.Mitarbeiter
ORDER BY qry_MA_Stunden_Basis_Fest.Mitarbeiter
PIVOT qry_MA_Stunden_Basis_Fest.Monat In ('Jan','Feb','Mrz','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez');

