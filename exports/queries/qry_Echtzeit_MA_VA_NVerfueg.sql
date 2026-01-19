-- Query: qry_Echtzeit_MA_VA_NVerfueg
-- Type: 0
SELECT tbl_MA_NVerfuegZeiten.MA_ID, tbl_MA_NVerfuegZeiten.vonDat AS MVA_Start, tbl_MA_NVerfuegZeiten.bisDat AS MVA_Ende, "Privat / " & [Zeittyp_ID] & " - " & [Bemerkung] AS Grund
FROM tbl_MA_NVerfuegZeiten;

