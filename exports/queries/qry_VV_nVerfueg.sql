-- Query: qry_VV_nVerfueg
-- Type: 0
SELECT 0 AS VA_ID, 0 AS VADatum_ID, CDate(Fix([vonDat])) AS VADatum, tbl_MA_NVerfuegZeiten.vonDat AS MVA_Start, tbl_MA_NVerfuegZeiten.bisDat AS MVA_Ende, tbl_MA_NVerfuegZeiten.MA_ID, [Nachname] & " " & [Vorname] AS MAName, tbl_MA_Zeittyp.Zeittyp AS ObjektOrt, "nicht verfügbar" AS Art, 3 AS Sort
FROM tbl_MA_Mitarbeiterstamm INNER JOIN (tbl_MA_Zeittyp INNER JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Zeittyp.Kuerzel_Datev = tbl_MA_NVerfuegZeiten.Zeittyp_ID) ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_NVerfuegZeiten.MA_ID
WHERE (((tbl_MA_NVerfuegZeiten.MA_ID)>0));

