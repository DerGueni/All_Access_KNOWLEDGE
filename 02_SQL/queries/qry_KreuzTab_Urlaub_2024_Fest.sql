TRANSFORM Count(qry_Basis_Urlaub_2024_Fest.Mitarbeiter) AS Anzahl
SELECT qry_Basis_Urlaub_2024_Fest.Mitarbeiter, Count(qry_Basis_Urlaub_2024_Fest.Mitarbeiter) AS Gesamt
FROM qry_Basis_Urlaub_2024_Fest
GROUP BY qry_Basis_Urlaub_2024_Fest.Mitarbeiter
ORDER BY qry_Basis_Urlaub_2024_Fest.Mitarbeiter
PIVOT qry_Basis_Urlaub_2024_Fest.Monat In ('Jan','Feb','Mrz','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez');

