-- Query: qry_MA_VA_Zuo_All_MitID
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende, ([MA_Brutto_Std2]) AS Brutto_Std, ([MA_Netto_Std2]) AS Netto_Std, tbl_MA_VA_Zuordnung.PKW, tbl_MA_VA_Zuordnung.RL_34a, tbl_MA_VA_Zuordnung.ID AS Zuord_ID
FROM tbl_VA_Auftragstamm INNER JOIN tbl_MA_VA_Zuordnung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID
WHERE (((tbl_MA_VA_Zuordnung.VA_ID)>0) AND ((tbl_MA_VA_Zuordnung.MA_ID)>0) AND ((tbl_MA_VA_Zuordnung.VADatum_ID)>0));

