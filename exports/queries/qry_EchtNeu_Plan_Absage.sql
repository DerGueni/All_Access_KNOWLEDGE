-- Query: qry_EchtNeu_Plan_Absage
-- Type: 0
SELECT tbl_MA_VA_Planung.MA_ID, tbl_MA_VA_Planung.VA_ID, tbl_MA_VA_Planung.VADatum_ID, tbl_MA_VA_Planung.VAStart_ID, tbl_MA_VA_Planung.VADatum, tbl_MA_VA_Planung.VA_Start, tbl_MA_VA_Planung.VA_Ende, tbl_MA_VA_Planung.MVA_Start, tbl_MA_VA_Planung.MVA_Ende, "Absage / " & [Auftrag] & " " & [Ort] & " " & [Objekt] AS Grund
FROM tbltmp_Vergleichszeiten, tbl_VA_Auftragstamm INNER JOIN tbl_MA_VA_Planung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Planung.VA_ID
WHERE (((tbl_MA_VA_Planung.VA_ID)=[VGL_VA_ID]) AND ((tbl_MA_VA_Planung.MVA_Start)=[VGL_Start]) AND ((tbl_MA_VA_Planung.MVA_Ende)=[VGL_Ende]) AND ((([MVA_Start] Between [VGL_Start] And [VGL_Ende]) Or ([MVA_Ende] Between [VGL_Start] And [VGL_Ende]) Or (([MVA_Start]<[VGL_Start]) And ([MVA_Ende]>[VGL_Ende])))=True) AND ((tbl_MA_VA_Planung.Status_ID)=4));

