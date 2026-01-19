-- Query: qry_EchtNeu_Priv1
-- Type: 0
SELECT tbl_MA_NVerfuegZeiten.MA_ID, 0 AS VA_ID, 0 AS VADatum_ID, 0 AS VAStart_ID, Fix([vonDat]) AS VADatum, Right("00" & Hour([vonDat]),2) & ":" & Right("00" & Minute([vonDat]),2) AS VA_Start, Right("00" & Hour([bisDat]),2) & ":" & Right("00" & Minute([bisDat]),2) AS VA_Ende, tbl_MA_NVerfuegZeiten.vonDat AS MVA_Start, tbl_MA_NVerfuegZeiten.bisDat AS MVA_Ende, tbl_MA_NVerfuegZeiten.Zeittyp_ID, tbl_MA_NVerfuegZeiten.Bemerkung
FROM tbl_MA_NVerfuegZeiten;

