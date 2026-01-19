INSERT INTO tbl_MA_Tageszusatzwerte ( AktDat, MA_ID )
SELECT qry_Ins_tmp_Monat1a.dtDatum, Get_Priv_Property("prp_Akt_MA_ID") AS Ausdr1
FROM qry_Ins_tmp_Monat1a;

