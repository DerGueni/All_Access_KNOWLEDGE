-- Query: qry_MonZusB1
-- Type: 0
SELECT tbl_MA_NVerfuegZeiten.*, Month([vonDat]) AS iMonat, Year([vonDat]) AS iJahr, CDate(Fix([vondat])) AS VADatum
FROM tbl_MA_NVerfuegZeiten
WHERE (((tbl_MA_NVerfuegZeiten.ID)=5 Or (tbl_MA_NVerfuegZeiten.ID)=7));

