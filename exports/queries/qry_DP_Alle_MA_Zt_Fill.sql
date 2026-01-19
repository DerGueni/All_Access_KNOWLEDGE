-- Query: qry_DP_Alle_MA_Zt_Fill
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.ID, fObjektOrt(Nz([Auftrag]),Nz([tbl_VA_Auftragstamm].[Ort]),Nz([Objekt])) AS ObjOrt, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende, tbl_MA_VA_Zuordnung.IstFraglich, tbl_MA_VA_Zuordnung.VADatum
FROM (qry_DP_Alle_MA_Zt INNER JOIN tbl_MA_VA_Zuordnung ON qry_DP_Alle_MA_Zt.ZuordID = tbl_MA_VA_Zuordnung.ID) INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID;

