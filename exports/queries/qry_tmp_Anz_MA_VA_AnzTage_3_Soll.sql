-- Query: qry_tmp_Anz_MA_VA_AnzTage_3_Soll
-- Type: 80
SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, Sum(tbl_VA_Start.MA_Anzahl) AS SummevonMA_Anzahl INTO tbltmp_MA_VaStart_AnzTag_Soll
FROM tbl_VA_Start
GROUP BY tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID;

