-- Query: qry_MA_Abwesenheiten_Krank_Gueni_2023_KT1
-- Type: 16
TRANSFORM Count(qry_MA_Abwesenheiten_Krank_Gueni_2023.Zeittyp_ID) AS AnzahlvonZeittyp_ID
SELECT qry_MA_Abwesenheiten_Krank_Gueni_2023.Name, Count(qry_MA_Abwesenheiten_Krank_Gueni_2023.Zeittyp_ID) AS [Gesamtsumme von Zeittyp_ID]
FROM qry_MA_Abwesenheiten_Krank_Gueni_2023
GROUP BY qry_MA_Abwesenheiten_Krank_Gueni_2023.Name
PIVOT Format([vonDat],"mmm") In ("Jan","Feb","Mrz","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez");

