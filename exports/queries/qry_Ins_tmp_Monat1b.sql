-- Query: qry_Ins_tmp_Monat1b
-- Type: 0
SELECT tbl_MA_Tageszusatzwerte.MA_ID, tbl_MA_Tageszusatzwerte.AktDat AS VADatum
FROM tbl_MA_Tageszusatzwerte
WHERE (((tbl_MA_Tageszusatzwerte.MA_ID)= Get_Priv_Property("prp_Akt_MA_ID")));

