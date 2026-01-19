-- Query: qry_Anz_MA_VA_Zuordnung_Tag
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.VADatum_ID, Count(tbl_MA_VA_Zuordnung.ID) AS AnzMA_Z, Max(tbl_MA_VA_Zuordnung.PosNr) AS PosNrMax
FROM tbl_MA_VA_Zuordnung
GROUP BY tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.VADatum_ID;

