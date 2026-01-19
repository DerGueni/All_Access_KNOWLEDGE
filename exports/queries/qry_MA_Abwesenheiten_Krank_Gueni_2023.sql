-- Query: qry_MA_Abwesenheiten_Krank_Gueni_2023
-- Type: 0
SELECT [Nachname] & " " & [Vorname] AS Name, tbl_MA_NVerfuegZeiten.vonDat, tbl_MA_NVerfuegZeiten.Zeittyp_ID
FROM tbl_MA_Zeittyp INNER JOIN (tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Mitarbeiterstamm.[ID] = tbl_MA_NVerfuegZeiten.[MA_ID]) ON tbl_MA_Zeittyp.Kuerzel_Datev = tbl_MA_NVerfuegZeiten.Zeittyp_ID
WHERE (((tbl_MA_NVerfuegZeiten.Zeittyp_ID)="krank") AND ((tbl_MA_NVerfuegZeiten.vonDat) Between #1/1/2023# And #12/31/2023#) AND ((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=3))
ORDER BY [Nachname] & " " & [Vorname], tbl_MA_NVerfuegZeiten.vonDat, tbl_MA_NVerfuegZeiten.vonDat;

