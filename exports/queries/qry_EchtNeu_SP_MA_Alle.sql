-- Query: qry_EchtNeu_SP_MA_Alle
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.*, qry_EchtNeu_UnionSp.VA_ID, qry_EchtNeu_UnionSp.VADatum_ID, qry_EchtNeu_UnionSp.VAStart_ID, qry_EchtNeu_UnionSp.VADatum, qry_EchtNeu_UnionSp.VA_Start, qry_EchtNeu_UnionSp.VA_Ende, qry_EchtNeu_UnionSp.MVA_Start, qry_EchtNeu_UnionSp.MVA_Ende, qry_EchtNeu_UnionSp.Grund
FROM qry_EchtNeu_UnionSp RIGHT JOIN tbl_MA_Mitarbeiterstamm ON qry_EchtNeu_UnionSp.MA_ID = tbl_MA_Mitarbeiterstamm.ID;

