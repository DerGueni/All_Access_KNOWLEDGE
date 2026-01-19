-- Query: qry_VV_Zuo
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.MVA_Start, tbl_MA_VA_Zuordnung.MVA_Ende, tbl_MA_VA_Zuordnung.MA_ID, [Nachname] & " " & [Vorname] AS MAName, fObjektOrt(Nz([Auftrag]),Nz([tbl_VA_Auftragstamm].[Ort]),Nz([Objekt])) AS ObjektOrt, "" AS Art, 2 AS Sort
FROM (tbl_MA_VA_Zuordnung INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID) LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID
WHERE (((tbl_MA_VA_Zuordnung.MA_ID)>0));

