SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, Sum(tbl_VA_Start.MA_Anzahl) AS Soll, tbl_VA_Start.VADatum
FROM tbl_VA_Start
GROUP BY tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, tbl_VA_Start.VADatum;

