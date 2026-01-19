SELECT qry_AlleMonatstage_AKtMon.dtDatum
FROM qry_AlleMonatstage_AKtMon LEFT JOIN qry_ins_tmp_Monat1b ON qry_AlleMonatstage_AKtMon.dtDatum = qry_ins_tmp_Monat1b.VADatum
WHERE (((qry_ins_tmp_Monat1b.VADatum) Is Null));

