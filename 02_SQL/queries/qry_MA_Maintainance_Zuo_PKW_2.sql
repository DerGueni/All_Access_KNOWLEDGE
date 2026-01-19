SELECT tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VA_ID, Count(tbl_MA_VA_Zuordnung.PKW) AS AnzahlvonPKW INTO temp_tbl_MA_Maintainance_PKW_Zuo_T2
FROM tbl_MA_VA_Zuordnung
WHERE (((tbl_MA_VA_Zuordnung.PKW)>0))
GROUP BY tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VA_ID;

