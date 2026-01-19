-- Query: qry_UE_Month_WeekNr
-- Type: 0
SELECT qry_UE_Month_Daten_Select.KW_D
FROM qry_UE_Month_Daten_Select
GROUP BY qry_UE_Month_Daten_Select.KW_D;

