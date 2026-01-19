SELECT DISTINCT qry_Doppelt_1.MA_ID, qry_Doppelt_1.ID1 AS ID, -1 AS Doppelt, qry_Doppelt_1.MVA_Start, qry_Doppelt_1.MVA_Ende
FROM qry_Doppelt_2 INNER JOIN qry_Doppelt_1 ON qry_Doppelt_2.MA_ID = qry_Doppelt_1.MA_ID
WHERE (((qry_Doppelt_1.ID1)<>[ID2]) AND ((([MVA_Start] Between [VGL_Start] And [VGL_Ende]) Or ([MVA_Ende] Between [VGL_Start] And [VGL_Ende]) Or (([MVA_Start]<[VGL_Start]) And ([MVA_Ende]>[VGL_Ende])))=True));

