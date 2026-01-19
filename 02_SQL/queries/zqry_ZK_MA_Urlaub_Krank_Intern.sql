SELECT tbl_MA_NVerfuegZeiten.MA_ID, tbl_MA_NVerfuegZeiten.Zeittyp_ID, tbl_MA_NVerfuegZeiten.vonDat, tbl_MA_NVerfuegZeiten.bisDat, tbl_MA_NVerfuegZeiten.vonTag, tbl_MA_NVerfuegZeiten.bisTag, tbl_MA_NVerfuegZeiten.Bemerkung, tbl_MA_NVerfuegZeiten.vonZeit, tbl_MA_NVerfuegZeiten.bisZeit
FROM tbl_MA_NVerfuegZeiten
WHERE (((tbl_MA_NVerfuegZeiten.Zeittyp_ID)="Urlaub" Or (tbl_MA_NVerfuegZeiten.Zeittyp_ID)="Krank" Or (tbl_MA_NVerfuegZeiten.Zeittyp_ID)="Intern"))
ORDER BY tbl_MA_NVerfuegZeiten.vonDat;

