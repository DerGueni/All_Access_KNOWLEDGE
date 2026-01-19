-- Query: qry_Ins_Aktmon_Zusatzdat
-- Type: 0
SELECT tbl_MA_Tageszusatzwerte.*
FROM tbl_MA_Tageszusatzwerte
WHERE (((tbl_MA_Tageszusatzwerte.MA_ID)=Get_Priv_Property("prp_Akt_MA_ID")) AND ((Month([AktDat]))=Get_Priv_Property("prp_AktMonUeb_Monat")) AND ((Year([AktDat]))=Get_Priv_Property("prp_AktMonUeb_Jahr")))
ORDER BY tbl_MA_Tageszusatzwerte.AktDat;

