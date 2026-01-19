-- Query: qry_Mitarbeiter_Geplant
-- Type: 0
SELECT tbl_MA_VA_Planung.ID, tbl_MA_VA_Planung.VA_ID, tbl_MA_VA_Planung.VADatum_ID, tbl_MA_VA_Planung.VAStart_ID, tbl_MA_VA_Planung.MA_ID, tbl_MA_Mitarbeiterstamm.Email, tbl_MA_VA_Planung.PosNr, tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname, tbl_MA_VA_Planung.VA_Start AS Beginn
FROM tbl_MA_VA_Planung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID
WHERE (((tbl_MA_VA_Planung.Status_ID)<3))
ORDER BY tbl_MA_VA_Planung.PosNr;

