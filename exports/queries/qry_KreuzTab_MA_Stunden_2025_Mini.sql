TRANSFORM Sum(qry_MA_Stunden_Basis_Mini.Stunden) AS SummeStunden
SELECT qry_MA_Stunden_Basis_Mini.Mitarbeiter, Sum(qry_MA_Stunden_Basis_Mini.Stunden) AS Gesamt
FROM qry_MA_Stunden_Basis_Mini
GROUP BY qry_MA_Stunden_Basis_Mini.Mitarbeiter
ORDER BY qry_MA_Stunden_Basis_Mini.Mitarbeiter
PIVOT qry_MA_Stunden_Basis_Mini.Monat In ('Jan','Feb','Mrz','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez');

