-- Query: qry_MA_NVerfueg_ZeitUpdate
-- Type: 48
UPDATE tbl_MA_NVerfuegZeiten SET tbl_MA_NVerfuegZeiten.vonTag = CDate(Fix([vonDat])), tbl_MA_NVerfuegZeiten.bisTag = CDate(Fix([bisDat])), tbl_MA_NVerfuegZeiten.vonZeit = CDate([vondat]-CDate(Fix([vonDat]))), tbl_MA_NVerfuegZeiten.bisZeit = CDate([bisdat]-CDate(Fix([bisDat]))), tbl_MA_NVerfuegZeiten.vonTagZahl = DateDiff("d",CDate(Fix([vonDat])),CDate(Fix([bisDat])));

