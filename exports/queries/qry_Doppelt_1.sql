-- Query: qry_Doppelt_1
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.ID AS ID1, tbl_MA_VA_Zuordnung.MVA_Start, tbl_MA_VA_Zuordnung.MVA_Ende
FROM tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_VA_Zuordnung ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_VA_Zuordnung.MA_ID
WHERE (((((([tbl_MA_Mitarbeiterstamm].[IstSubunternehmer])=True)) Or ((([tbl_MA_Mitarbeiterstamm].[Anstellungsart_ID])=11)))=False));

