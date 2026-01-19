-- Query: qry_XL_XLEinsUeber
-- Type: 0
SELECT 'Glatz Michael' AS Name, qry_MA_VA_Plan_All_AufUeber2_Zuo.VADatum, qry_MA_VA_Plan_All_AufUeber2_Zuo.Auftrag, qry_MA_VA_Plan_All_AufUeber2_Zuo.Ort, qry_MA_VA_Plan_All_AufUeber2_Zuo.Objekt, Format([Beginn],'Short Time') AS beginnt, Format([Ende],'Short Time') AS endet, qry_MA_VA_Plan_All_AufUeber2_Zuo.MA_Brutto_Std, qry_MA_VA_Plan_All_AufUeber2_Zuo.MA_Netto_Std
FROM qry_MA_VA_Plan_All_AufUeber2_Zuo
WHERE (((qry_MA_VA_Plan_All_AufUeber2_Zuo.VADatum) Between #1/1/2015# And #11/30/2015#) And ((qry_MA_VA_Plan_All_AufUeber2_Zuo.MA_ID)=152))
ORDER BY qry_MA_VA_Plan_All_AufUeber2_Zuo.VADatum, qry_MA_VA_Plan_All_AufUeber2_Zuo.Beginn;

