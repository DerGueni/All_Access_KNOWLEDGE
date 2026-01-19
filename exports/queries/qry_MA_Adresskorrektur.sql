-- Query: qry_MA_Adresskorrektur
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.ID, tbl_MA_Mitarbeiterstamm.Anr, [Vorname] & " " & [Nachname] AS Name, tbl_MA_Mitarbeiterstamm.Strasse, tbl_MA_Mitarbeiterstamm.Nr, [Plz] & " " & [Ort] AS PLZOrt, tbl_MA_Mitarbeiterstamm.Briefkopf
FROM tbl_MA_Mitarbeiterstamm
WHERE (((tbl_MA_Mitarbeiterstamm.IstBrfAuto)=False));

