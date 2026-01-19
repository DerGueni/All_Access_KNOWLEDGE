-- Query: qry_Ins_MA_JahrMon2
-- Type: 0
SELECT tbl_MA_Tageszusatzwerte.MA_ID, tbl_MA_Tageszusatzwerte.aktdat, Year([aktdat]) AS AktJahr, Month([aktdat]) AS AktMon, tbl_MA_Tageszusatzwerte.[34a_RZ], tbl_MA_Tageszusatzwerte.Abschlag, tbl_MA_Tageszusatzwerte.Nicht_Erscheinen, tbl_MA_Tageszusatzwerte.Kaution, tbl_MA_Tageszusatzwerte.Sonst_Abzuege, tbl_MA_Tageszusatzwerte.Monatslohn, tbl_MA_Tageszusatzwerte.UeberwVon
FROM tbl_MA_Tageszusatzwerte
WHERE (((tbl_MA_Tageszusatzwerte.MA_ID)=Get_Priv_Property("prp_Akt_MA_ID")) AND ((Year([aktdat]))=Get_Priv_Property("prp_AktMonUeb_Jahr")) AND ((Month([aktdat]))=Get_Priv_Property("prp_AktMonUeb_Monat")));

