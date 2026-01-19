SELECT qry_Echtzeit_Vergleich.ID, qry_Echtzeit_MA_VA_Union.MA_ID, qry_Mitarbeiter_Qualifikation.IstSubunternehmer, qry_Mitarbeiter_Qualifikation.IstAktiv, qry_Mitarbeiter_Qualifikation.Quali_ID, qry_Echtzeit_MA_VA_Union.MVA_Start, qry_Echtzeit_MA_VA_Union.MVA_Ende, qry_Echtzeit_MA_VA_Union.Grund
FROM qry_Echtzeit_Vergleich, qry_Echtzeit_MA_VA_Union INNER JOIN qry_Mitarbeiter_Qualifikation ON qry_Echtzeit_MA_VA_Union.MA_ID = qry_Mitarbeiter_Qualifikation.ID
WHERE (((([qry_Echtzeit_MA_VA_Union].[MVA_Start] Between [VGL_Start] And [VGL_Ende]) Or ([qry_Echtzeit_MA_VA_Union].[MVA_Ende] Between [VGL_Start] And [VGL_Ende]) Or (([qry_Echtzeit_MA_VA_Union].[MVA_Start]<[VGL_Start]) And ([qry_Echtzeit_MA_VA_Union].[MVA_Ende]>[VGL_Ende])))=True));

