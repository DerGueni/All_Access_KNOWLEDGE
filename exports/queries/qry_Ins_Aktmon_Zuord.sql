-- Query: qry_Ins_Aktmon_Zuord
-- Type: 0
SELECT qry_MA_Monat_VA_Zuordnung.Zuord_ID AS ID, qry_AlleMonatstage_AKtMon.dtDatum AS VADatum, qry_MA_Monat_VA_Zuordnung.VA_ID, qry_MA_Monat_VA_Zuordnung.MA_ID, [Auftrag] & ' ' & [Ort] & ' ' & [Objekt] AS Auftrag_Ort, qry_MA_Monat_VA_Zuordnung.MA_Start, qry_MA_Monat_VA_Zuordnung.MA_Ende, qry_MA_Monat_VA_Zuordnung.Brutto_Std, qry_MA_Monat_VA_Zuordnung.Netto_Std, qry_MA_Monat_VA_Zuordnung.PKW AS Fahrtko, qry_MA_Monat_VA_Zuordnung.RL_34a
FROM qry_MA_Monat_VA_Zuordnung RIGHT JOIN qry_AlleMonatstage_AKtMon ON qry_MA_Monat_VA_Zuordnung.VADatum = qry_AlleMonatstage_AKtMon.dtDatum
ORDER BY qry_AlleMonatstage_AKtMon.dtDatum;

