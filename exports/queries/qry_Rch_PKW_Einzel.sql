-- Query: qry_Rch_PKW_Einzel
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.PKW, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende, tbl_VA_Auftragstamm.Veranstalter_ID AS kun_ID, tbl_VA_Auftragstamm.Veranst_Status_ID
FROM tbl_VA_Auftragstamm LEFT JOIN tbl_MA_VA_Zuordnung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID
WHERE (((tbl_MA_VA_Zuordnung.VADatum)<Date()) AND ((tbl_MA_VA_Zuordnung.PKW)>0) AND ((tbl_VA_Auftragstamm.Veranst_Status_ID)=3));

