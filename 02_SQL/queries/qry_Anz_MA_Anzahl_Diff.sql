SELECT qry_Anz_MA_VA_Zuordnung.VA_ID, qry_Anz_MA_VA_Zuordnung.VADatum, qry_Anz_MA_VA_Zuordnung.VADatum_ID, tbl_VA_Start.VA_Start, qry_Anz_MA_VA_Zuordnung.VAStart_ID, qry_Anz_MA_VA_Zuordnung.PosNrMax, [AnzMA_Z]-[MA_Anzahl] AS Diff_MA
FROM qry_Anz_MA_VA_Zuordnung INNER JOIN tbl_VA_Start ON (qry_Anz_MA_VA_Zuordnung.VAStart_ID = tbl_VA_Start.ID) AND (qry_Anz_MA_VA_Zuordnung.VADatum_ID = tbl_VA_Start.VADatum_ID) AND (qry_Anz_MA_VA_Zuordnung.VA_ID = tbl_VA_Start.VA_ID)
WHERE ((([AnzMA_Z]-[MA_Anzahl])>0));

