-- Query: qry_N_DP_MA_NichtVerfuegbar
-- Type: 0
SELECT nv.MA_ID, nv.vonDat, nv.bisDat, nv.Zeittyp_ID
FROM tbl_MA_NVerfuegZeiten AS nv
WHERE nv.bisDat >= Date();

