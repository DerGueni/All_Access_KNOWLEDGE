-- Query: qry_MA_Abwesenheiten_Urlaub_Gueni
-- Type: 0
SELECT [Nachname] & " " & [Vorname] AS Name, tbl_MA_NVerfuegZeiten.vonDat, tbl_MA_NVerfuegZeiten.Zeittyp_ID, tbl_MA_NVerfuegZeiten.vonDat AS Jahr
FROM tbl_MA_Zeittyp INNER JOIN (tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Mitarbeiterstamm.[ID] = tbl_MA_NVerfuegZeiten.[MA_ID]) ON tbl_MA_Zeittyp.Kuerzel_Datev = tbl_MA_NVerfuegZeiten.Zeittyp_ID
WHERE (((tbl_MA_NVerfuegZeiten.Zeittyp_ID)="Urlaub") AND ((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=3))
ORDER BY [Nachname] & " " & [Vorname], tbl_MA_NVerfuegZeiten.vonDat;

