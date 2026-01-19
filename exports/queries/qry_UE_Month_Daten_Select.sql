-- Query: qry_UE_Month_Daten_Select
-- Type: 0
SELECT qry_UE_Month_Daten.*
FROM qry_UE_Month_Daten
WHERE (((qry_UE_Month_Daten.JahrNr)=Get_Priv_Property("prp_UE_Year")) AND ((qry_UE_Month_Daten.MonatNr)=Get_Priv_Property("prp_UE_Month")))
ORDER BY qry_UE_Month_Daten.TagNr, qry_UE_Month_Daten.Obj;

