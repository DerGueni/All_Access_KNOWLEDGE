-- Query: qry_Ins_MA_JahrMon1
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VADatum, Year([VADatum]) AS AktJahr, Month([VADatum]) AS AktMon, tbl_MA_VA_Zuordnung.MA_Netto_Std AS Netto_Std, tbl_MA_VA_Zuordnung.RL_34a, tbl_MA_VA_Zuordnung.MA_Brutto_Std AS Brutto_Std, tbl_MA_VA_Zuordnung.PKW AS Fahrtko
FROM tbl_MA_VA_Zuordnung
WHERE (((tbl_MA_VA_Zuordnung.MA_ID)=Get_Priv_Property("prp_Akt_MA_ID")) AND ((Year([VADatum]))=Get_Priv_Property("prp_AktMonUeb_Jahr")) AND ((Month([VADatum]))=Get_Priv_Property("prp_AktMonUeb_Monat")));

