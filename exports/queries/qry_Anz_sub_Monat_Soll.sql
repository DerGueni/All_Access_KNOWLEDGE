-- Query: qry_Anz_sub_Monat_Soll
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VA_ID, Count(tbl_MA_VA_Zuordnung.ID) AS AnzSoll
FROM tbl_MA_VA_Zuordnung
GROUP BY tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VA_ID;

