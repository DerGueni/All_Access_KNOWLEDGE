SELECT tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.ID AS ID2, DateAdd("n",2,[MVA_Start]) AS VGL_Start, DateAdd("n",-2,[MVA_Ende]) AS VGL_Ende
FROM tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_VA_Zuordnung ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_VA_Zuordnung.MA_ID
WHERE (((((([tbl_MA_Mitarbeiterstamm].[IstSubunternehmer])=True)) Or ((([tbl_MA_Mitarbeiterstamm].[Anstellungsart_ID])=11)))=False));

