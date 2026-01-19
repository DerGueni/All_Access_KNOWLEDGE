SELECT tbl_MA_NVerfuegZeiten.[ID], tbl_MA_NVerfuegZeiten.[MA_ID], tbl_MA_NVerfuegZeiten.[Zeittyp_ID], tbl_MA_NVerfuegZeiten.[vonDat], tbl_MA_NVerfuegZeiten.[bisDat]
FROM tbl_MA_Zeittyp INNER JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Zeittyp.Kuerzel_Datev = tbl_MA_NVerfuegZeiten.Zeittyp_ID;

