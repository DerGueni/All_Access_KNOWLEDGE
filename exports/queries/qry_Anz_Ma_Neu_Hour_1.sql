-- Query: qry_Anz_Ma_Neu_Hour_1
-- Type: 0
SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, Format([VA_Start],"Short Time") AS Start, Format([VA_Ende],"Short Time") AS Ende, tbl_VA_Start.MA_Anzahl_Ist, tbl_VA_Start.MA_Anzahl
FROM tbl_VA_Start;

