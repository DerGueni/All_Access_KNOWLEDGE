-- Query: qry_DP_Alle_Zt_Fill
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.MA_ID, [Nachname] & " " & [Vorname] AS Name, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende, tbl_MA_VA_Zuordnung.IstFraglich, tbl_MA_VA_Zuordnung.VADatum
FROM qry_DP_Alle_Zt INNER JOIN (tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) ON qry_DP_Alle_Zt.ZuordID = tbl_MA_VA_Zuordnung.ID;

