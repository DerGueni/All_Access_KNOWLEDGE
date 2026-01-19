SELECT qry_EchtNeu_Priv1.MA_ID, qry_EchtNeu_Priv1.VA_ID, qry_EchtNeu_Priv1.VADatum_ID, qry_EchtNeu_Priv1.VAStart_ID, qry_EchtNeu_Priv1.VADatum, qry_EchtNeu_Priv1.VA_Start, qry_EchtNeu_Priv1.VA_Ende, qry_EchtNeu_Priv1.MVA_Start, qry_EchtNeu_Priv1.MVA_Ende, "Privat / " & [Zeittyp_ID] & " - " & [Bemerkung] AS Grund
FROM tbltmp_Vergleichszeiten, qry_EchtNeu_Priv1
WHERE (((([MVA_Start] Between [VGL_Start] And [VGL_Ende]) Or ([MVA_Ende] Between [VGL_Start] And [VGL_Ende]) Or (([MVA_Start]<[VGL_Start]) And ([MVA_Ende]>[VGL_Ende])))=True));

