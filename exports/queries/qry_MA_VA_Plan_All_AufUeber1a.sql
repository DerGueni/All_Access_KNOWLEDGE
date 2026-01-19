-- Query: qry_MA_VA_Plan_All_AufUeber1a
-- Type: 0
SELECT tbl_MA_VA_Planung.VA_ID, tbl_MA_VA_Planung.MA_ID, tbl_MA_VA_Planung.VADatum_ID, tbl_MA_VA_Planung.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt, tbl_MA_VA_Planung.VA_Start AS Beginn, tbl_MA_VA_Planung.VA_Ende AS Ende, "Plan" AS IstPL, tbl_MA_VA_Planung.ID AS Plan_ID, tbl_VA_Auftragstamm.Treffp_Zeit, tbl_VA_Auftragstamm.Treffpunkt
FROM tbl_VA_Auftragstamm INNER JOIN tbl_MA_VA_Planung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Planung.VA_ID
WHERE (((tbl_MA_VA_Planung.VA_ID)>0) AND ((tbl_MA_VA_Planung.MA_ID)>0) AND ((tbl_MA_VA_Planung.VADatum_ID)>0));

