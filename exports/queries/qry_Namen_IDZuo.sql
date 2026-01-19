-- Query: qry_Namen_IDZuo
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.ID, Proper([Nachname]) & " " & [Vorname] AS Ausdr1
FROM tbl_MA_Mitarbeiterstamm;

