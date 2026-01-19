-- Query: zqry_VA_SUB_sent
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, ztbl_VA_SUB.Datum
FROM tbl_VA_Auftragstamm INNER JOIN (tbl_MA_Mitarbeiterstamm INNER JOIN ztbl_VA_SUB ON tbl_MA_Mitarbeiterstamm.ID = ztbl_VA_SUB.MA_ID) ON tbl_VA_Auftragstamm.ID = ztbl_VA_SUB.VA_ID;

