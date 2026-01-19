TRANSFORM Sum(qry_N_Abwesenheit_Basis.Tage) AS SummeVonTage
SELECT qry_N_Abwesenheit_Basis.Name, Sum(qry_N_Abwesenheit_Basis.Tage) AS Gesamt
FROM qry_N_Abwesenheit_Basis
WHERE qry_N_Abwesenheit_Basis.Zeittyp_ID = "Krank"
GROUP BY qry_N_Abwesenheit_Basis.Name
PIVOT Format([Monat],"00") & ". " & Choose([Monat],"Jan","Feb","Mrz","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez");

