-- Query: qry_tmp_Anz_MA_VA_AnzTage_2_Ist
-- Type: 80
SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, Count(tbl_MA_VA_Zuordnung.MA_ID) AS AnzahlvonMA_ID INTO tbltmp_MA_VaStart_AnzTag
FROM tbl_MA_VA_Zuordnung
WHERE (((tbl_MA_VA_Zuordnung.MA_ID)>0))
GROUP BY tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID;

