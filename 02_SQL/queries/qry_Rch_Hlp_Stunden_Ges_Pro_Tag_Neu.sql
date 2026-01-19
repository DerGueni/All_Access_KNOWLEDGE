SELECT tbl_VA_Auftragstamm.Veranstalter_ID AS kun_ID, Weekday([VADatum],2) AS Wochtg, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.MA_Brutto_Std
FROM tbl_VA_Auftragstamm INNER JOIN tbl_MA_VA_Zuordnung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID;

