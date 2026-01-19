-- Query: qry_MA_ID
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.ID, Trim([Nachname] & " " & [Vorname]) AS NName
FROM tbl_MA_Mitarbeiterstamm;

