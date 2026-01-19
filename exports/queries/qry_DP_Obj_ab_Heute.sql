-- Query: qry_DP_Obj_ab_Heute
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.*
FROM tbl_MA_VA_Zuordnung INNER JOIN qry_DP_Obj_ab_Heute_ZW ON tbl_MA_VA_Zuordnung.ID = qry_DP_Obj_ab_Heute_ZW.Zuo_ID
ORDER BY tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.PosNr;

