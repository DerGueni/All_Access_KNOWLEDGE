-- Query: qry_MA_Monat_VA_Zuordnung
-- Type: 0
SELECT qry_MA_VA_Zuo_All_MitID.*
FROM qry_MA_VA_Zuo_All_MitID
WHERE (((qry_MA_VA_Zuo_All_MitID.MA_ID)=Get_Priv_Property("prp_Akt_MA_ID")) AND ((Month([VADatum]))=Get_Priv_Property("prp_AktMonUeb_Monat")) AND ((Year([VADatum]))=Get_Priv_Property("prp_AktMonUeb_Jahr")));

