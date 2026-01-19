-- Query: qry_Anz_MA_Start_Report
-- Type: 0
SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, tbl_VA_Start.ID AS VAStart_ID, tbl_VA_Start.VADatum, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, 0+Nz([MA_IstAnz],0) AS MA_Ist, tbl_VA_Start.MA_Anzahl AS MA_Soll, tbl_VA_Start.MVA_Start, tbl_VA_Start.MVA_Ende
FROM qry_Anz_MA_Start_sub RIGHT JOIN tbl_VA_Start ON qry_Anz_MA_Start_sub.VAStart_ID = tbl_VA_Start.ID
WHERE (((tbl_VA_Start.VA_ID)=Get_Priv_Property("prp_Report1_Auftrag_ID")) AND ((tbl_VA_Start.VADatum_ID)=Get_Priv_Property("prp_Report1_Auftrag_VADatum_ID")));

