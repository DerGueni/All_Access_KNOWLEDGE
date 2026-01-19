-- Query: qry_Excel_Export_Teil3
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VA_ID, Format([VADatum],"dd/mm/yyyy",2,2) AS VA_Datumstr, tbl_MA_VA_Zuordnung.PosNr AS VA_Lfd, Nz([Nachname] & " " & [Vorname]) AS Mitarbeiter, Format([MA_Start],"Short Time") AS Beginnstr, Format([MA_Ende],"Short Time") AS Endestr, tbl_MA_VA_Zuordnung.Bemerkungen AS MA_Info1, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.PosNr, tbl_MA_VA_Zuordnung.Einsatzleitung
FROM tbl_MA_Mitarbeiterstamm RIGHT JOIN tbl_MA_VA_Zuordnung ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_VA_Zuordnung.MA_ID
ORDER BY tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.PosNr;

