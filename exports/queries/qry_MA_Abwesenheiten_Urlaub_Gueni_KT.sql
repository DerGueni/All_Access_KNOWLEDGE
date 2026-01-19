-- Query: qry_MA_Abwesenheiten_Urlaub_Gueni_KT
-- Type: 16
TRANSFORM Count(qry_MA_Abwesenheiten_Urlaub_Gueni.Zeittyp_ID) AS AnzahlvonZeittyp_ID
SELECT qry_MA_Abwesenheiten_Urlaub_Gueni.Name, Count(qry_MA_Abwesenheiten_Urlaub_Gueni.Zeittyp_ID) AS [Gesamtsumme von Zeittyp_ID]
FROM qry_MA_Abwesenheiten_Urlaub_Gueni
GROUP BY qry_MA_Abwesenheiten_Urlaub_Gueni.Name
PIVOT Format([vonDat],"mmm") In ("Jan","Feb","Mrz","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez");

