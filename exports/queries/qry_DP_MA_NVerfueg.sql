-- Query: qry_DP_MA_NVerfueg
-- Type: 0
SELECT -1 AS VA_ID, -1 AS ZuordID, 1 AS Anz_MA, tbl_MA_Zeittyp.ZeitTyp AS ObjOrt, CDate(Fix(CDbl([vonDat]))) AS VADatum, 1 AS Pos_Nr, tbl_MA_NVerfuegZeiten.vonDat AS MA_Start, tbl_MA_NVerfuegZeiten.bisDat AS MA_Ende, tbl_MA_NVerfuegZeiten.MA_ID, [Nachname] & " " & [Vorname] AS MAName, 0 AS IstFraglich, 1 AS Hlp
FROM tbl_MA_Zeittyp INNER JOIN (tbl_MA_Mitarbeiterstamm RIGHT JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_NVerfuegZeiten.MA_ID) ON tbl_MA_Zeittyp.Kuerzel_Datev = tbl_MA_NVerfuegZeiten.Zeittyp_ID;

