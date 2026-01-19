SELECT tbl_MA_VA_Planung.MA_ID, tbl_MA_VA_Planung.MVA_Start, tbl_MA_VA_Planung.MVA_Ende, "Plan / " & [Auftrag] & " " & [Ort] & " " & [Objekt] AS Grund
FROM tbl_VA_Auftragstamm RIGHT JOIN tbl_MA_VA_Planung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Planung.VA_ID
WHERE (((tbl_MA_VA_Planung.Status_ID)<3));

