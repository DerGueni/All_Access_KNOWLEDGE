SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.MA_Brutto_Std, tbl_MA_VA_Zuordnung.PreisArt_ID, tbl_VA_Auftragstamm.Veranstalter_ID AS kun_ID, tbl_VA_Auftragstamm.Veranst_Status_ID, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende
FROM tbl_VA_Auftragstamm LEFT JOIN tbl_MA_VA_Zuordnung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID
WHERE (((tbl_MA_VA_Zuordnung.MA_Brutto_Std)>0) AND ((tbl_VA_Auftragstamm.Veranst_Status_ID)<3))
ORDER BY tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum;

