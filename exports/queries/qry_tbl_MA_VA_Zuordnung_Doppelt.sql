-- Query: qry_tbl_MA_VA_Zuordnung_Doppelt
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.*, qry_Doppelt.Doppelt
FROM qry_Doppelt RIGHT JOIN tbl_MA_VA_Zuordnung ON qry_Doppelt.ID = tbl_MA_VA_Zuordnung.ID;

