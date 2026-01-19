-- Query: qry_MA_Akt_ListeDrucken
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.ID, tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname, tbl_MA_Mitarbeiterstamm.Ort
FROM tbl_MA_Mitarbeiterstamm
WHERE (((tbl_MA_Mitarbeiterstamm.[Anstellungsart_ID])=3 Or (tbl_MA_Mitarbeiterstamm.[Anstellungsart_ID])=5))
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;

