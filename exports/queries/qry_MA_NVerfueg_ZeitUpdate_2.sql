-- Query: qry_MA_NVerfueg_ZeitUpdate_2
-- Type: 48
UPDATE tbl_MA_NVerfuegZeiten SET tbl_MA_NVerfuegZeiten.vonDat = CDate(Fix([vonDat])), tbl_MA_NVerfuegZeiten.bisDat = CDate(Fix([bisDat]))+1-(1/1440)
WHERE (((tbl_MA_NVerfuegZeiten.vonTagZahl)>0));

