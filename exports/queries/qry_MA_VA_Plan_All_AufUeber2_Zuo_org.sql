-- Query: qry_MA_VA_Plan_All_AufUeber2_Zuo_org
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt, ([MA_Start]) AS Beginn, ([MA_Ende]) AS Ende, ([mA_brutto_std2]) AS MA_Brutto_Std, ([ma_Netto_std2]) AS MA_Netto_Std
FROM tbl_MA_VA_Zuordnung INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID
WHERE (((tbl_MA_VA_Zuordnung.VA_ID)>0) AND ((tbl_MA_VA_Zuordnung.MA_ID)>0) AND ((tbl_MA_VA_Zuordnung.VADatum_ID)>0));

