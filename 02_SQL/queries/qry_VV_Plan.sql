SELECT tbl_MA_VA_Planung.VA_ID, tbl_MA_VA_Planung.VADatum_ID, tbl_MA_VA_Planung.VADatum, tbl_MA_VA_Planung.MVA_Start, tbl_MA_VA_Planung.MVA_Ende, tbl_MA_VA_Planung.MA_ID, [Nachname] & " " & [Vorname] AS MAName, fObjektOrt(Nz([Auftrag]),Nz([tbl_VA_Auftragstamm].[Ort]),Nz([Objekt])) AS ObjektOrt, "verplant" AS Art, 1 AS Sort
FROM (tbl_MA_VA_Planung INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID) LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID
WHERE (((tbl_MA_VA_Planung.MA_ID)>0));

