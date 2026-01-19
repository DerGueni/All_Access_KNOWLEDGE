-- Query: qry_Excel_Einsatzuebersicht
-- Type: 0
SELECT 'Sec Concept' AS Name, qry_MA_VA_Plan_All_AufUeber2_Zuo.VADatum, qry_MA_VA_Plan_All_AufUeber2_Zuo.Auftrag, qry_MA_VA_Plan_All_AufUeber2_Zuo.Ort, qry_MA_VA_Plan_All_AufUeber2_Zuo.Objekt, Format([Beginn],'Short Time') AS beginnt, Format([Ende],'Short Time') AS endet, qry_MA_VA_Plan_All_AufUeber2_Zuo.MA_Brutto_Std, qry_MA_VA_Plan_All_AufUeber2_Zuo.MA_Netto_Std
FROM qry_MA_VA_Plan_All_AufUeber2_Zuo
WHERE (((qry_MA_VA_Plan_All_AufUeber2_Zuo.[VADatum]) Between #3/1/2022# And #3/31/2022#) AND ((qry_MA_VA_Plan_All_AufUeber2_Zuo.[MA_ID])=9295))
ORDER BY qry_MA_VA_Plan_All_AufUeber2_Zuo.VADatum, qry_MA_VA_Plan_All_AufUeber2_Zuo.Beginn;

