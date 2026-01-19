-- Query: qry_Rch_Report_Anz_Pers
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VAStart_ID, Count(tbl_MA_VA_Zuordnung.VAStart_ID) AS AnzPers
FROM tbl_MA_VA_Zuordnung
GROUP BY tbl_MA_VA_Zuordnung.VAStart_ID;

