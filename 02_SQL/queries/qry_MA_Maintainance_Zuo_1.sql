SELECT tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VA_ID, Count(tbl_MA_VA_Zuordnung.MA_ID) AS Anz_MA_Ist INTO temp_tbl_MA_Maintainance_Zuo_Tl1
FROM tbl_MA_VA_Zuordnung
WHERE (((tbl_MA_VA_Zuordnung.MA_ID)>0))
GROUP BY tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VA_ID;

