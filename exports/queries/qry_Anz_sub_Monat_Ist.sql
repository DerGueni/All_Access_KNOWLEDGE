-- Query: qry_Anz_sub_Monat_Ist
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VA_ID, Count(tbl_MA_VA_Zuordnung.MA_ID) AS AnzIst
FROM tbl_MA_VA_Zuordnung
WHERE (((tbl_MA_VA_Zuordnung.MA_ID)>0))
GROUP BY tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VA_ID;

