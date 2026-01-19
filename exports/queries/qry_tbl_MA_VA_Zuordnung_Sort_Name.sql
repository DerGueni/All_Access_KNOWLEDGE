-- Query: qry_tbl_MA_VA_Zuordnung_Sort_Name
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.*
FROM tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;

