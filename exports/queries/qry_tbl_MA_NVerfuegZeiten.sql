-- Query: qry_tbl_MA_NVerfuegZeiten
-- Type: 0
SELECT tbl_MA_NVerfuegZeiten.ID, tbl_MA_NVerfuegZeiten.MA_ID, tbl_MA_NVerfuegZeiten.Zeittyp_ID, tbl_MA_NVerfuegZeiten.vonDat, tbl_MA_NVerfuegZeiten.bisDat, tbl_MA_NVerfuegZeiten.Bemerkung, tbl_MA_NVerfuegZeiten.Erst_von, tbl_MA_NVerfuegZeiten.Erst_am, tbl_MA_NVerfuegZeiten.Aend_von, tbl_MA_NVerfuegZeiten.Aend_am, tbl_MA_NVerfuegZeiten.vonZeit, tbl_MA_NVerfuegZeiten.bisZeit
FROM tbl_MA_NVerfuegZeiten
WHERE MA_ID = 852  AND (((tbl_MA_NVerfuegZeiten.vonDat) >= Date()))
ORDER BY tbl_MA_NVerfuegZeiten.MA_ID, tbl_MA_NVerfuegZeiten.vonDat, tbl_MA_NVerfuegZeiten.bisDat;

