-- Query: qry_MA_Maintainance_Zuo_3
-- Type: 80
SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, Sum(tbl_VA_Start.MA_Anzahl) AS MA_Soll INTO temp_tbl_MA_Maintainance_Zuo_Tl3
FROM tbl_VA_Start
GROUP BY tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID;

