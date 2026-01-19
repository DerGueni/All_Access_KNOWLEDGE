SELECT tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.MA_Start AS VA_Start, tbl_MA_VA_Zuordnung.MA_Ende AS VA_Ende, tbl_MA_VA_Zuordnung.MVA_Start, tbl_MA_VA_Zuordnung.MVA_Ende, [Auftrag] & " " & [Ort] & " " & [Objekt] AS Grund
FROM tbltmp_Vergleichszeiten, tbl_VA_Auftragstamm INNER JOIN tbl_MA_VA_Zuordnung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID
WHERE (((([MVA_Start] Between [VGL_Start] And [VGL_Ende]) Or ([MVA_Ende] Between [VGL_Start] And [VGL_Ende]) Or (([MVA_Start]<[VGL_Start]) And ([MVA_Ende]>[VGL_Ende])))=True));

