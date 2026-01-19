-- Query: qry_MonZus8
-- Type: 32
DELETE tbl_MA_Tageszusatzwerte.*, tbl_MA_Tageszusatzwerte.MA_ID, Month([AktDat]) AS Ausdr1, Year([AktDat]) AS Ausdr2
FROM tbl_MA_Tageszusatzwerte
WHERE (((tbl_MA_Tageszusatzwerte.MA_ID)=Get_Priv_Property("prp_Akt_MA_ID")) AND ((Month([AktDat]))=Get_Priv_Property("prp_AktMonUeb_Monat")) AND ((Year([AktDat]))=Get_Priv_Property("prp_AktMonUeb_Jahr")));

