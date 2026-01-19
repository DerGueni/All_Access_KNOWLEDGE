-- Query: qry_Zeitabfrage_MA_Fehlzeiten
-- Type: 0
SELECT tbl_MA_FehlZeiten.ID, tbl_MA_FehlZeiten.MA_ID, tbl_MA_FehlZeiten.Zeittyp_ID, tbl_MA_FehlZeiten.vonDat, tbl_MA_FehlZeiten.bisDat, tbl_MA_FehlZeiten.Bemerkung, [Nachname] & ", " & [Vorname] AS MA_Name
FROM tbl_MA_Mitarbeiterstamm RIGHT JOIN (tbl_MA_FehlZeiten LEFT JOIN tbl_MA_Zeittyp ON tbl_MA_FehlZeiten.Zeittyp_ID = tbl_MA_Zeittyp.ID) ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_FehlZeiten.MA_ID;

