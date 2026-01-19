-- Query: qry_MA_Abwesenheiten_Krank_Gueni_2022_KT1
-- Type: 16
TRANSFORM Count(qry_MA_Abwesenheiten_Krank_Gueni_2022.[Zeittyp_ID]) AS AnzahlvonZeittyp_ID
SELECT qry_MA_Abwesenheiten_Krank_Gueni_2022.[Name] AS Ausdr1, Count(qry_MA_Abwesenheiten_Krank_Gueni_2022.[Zeittyp_ID]) AS [Gesamtsumme von Zeittyp_ID]
FROM qry_MA_Abwesenheiten_Krank_Gueni_2022
GROUP BY qry_MA_Abwesenheiten_Krank_Gueni_2022.[Name]
PIVOT Format([vonDat],"mmm") In ("Jan","Feb","Mrz","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez");

