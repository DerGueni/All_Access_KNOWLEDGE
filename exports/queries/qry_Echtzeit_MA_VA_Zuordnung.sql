-- Query: qry_Echtzeit_MA_VA_Zuordnung
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.MVA_Start, tbl_MA_VA_Zuordnung.MVA_Ende, [Auftrag] & " " & [Ort] & " " & [Objekt] AS Grund
FROM tbl_VA_Auftragstamm RIGHT JOIN tbl_MA_VA_Zuordnung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID;

