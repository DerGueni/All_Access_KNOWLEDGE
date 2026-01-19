-- Query: qry_Doppelt_MitZusInfo
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VADatum, [Nachname] & " " & [Vorname] AS Name, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende, tbl_MA_VA_Zuordnung.ID, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, qry_Doppelt.MVA_Start, qry_Doppelt.MVA_Ende
FROM tbl_MA_Mitarbeiterstamm INNER JOIN (tbl_VA_Auftragstamm INNER JOIN (qry_Doppelt INNER JOIN tbl_MA_VA_Zuordnung ON qry_Doppelt.ID = tbl_MA_VA_Zuordnung.ID) ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID) ON tbl_MA_Mitarbeiterstamm.ID = qry_Doppelt.MA_ID
WHERE (((tbl_MA_VA_Zuordnung.VADatum)>=Date()))
ORDER BY qry_Doppelt.MVA_Start, qry_Doppelt.MVA_Ende;

