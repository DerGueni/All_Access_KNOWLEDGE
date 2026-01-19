-- Query: qry_Anz_MA_Start
-- Type: 0
SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, tbl_VA_Start.ID AS VAStart_ID, tbl_VA_Start.VADatum, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, 0+Nz([MA_IstAnz],0) AS MA_Ist, tbl_VA_Start.MA_Anzahl AS MA_Soll, tbl_VA_Start.MVA_Start, tbl_VA_Start.MVA_Ende
FROM qry_Anz_MA_Start_sub RIGHT JOIN tbl_VA_Start ON qry_Anz_MA_Start_sub.VAStart_ID = tbl_VA_Start.ID;

