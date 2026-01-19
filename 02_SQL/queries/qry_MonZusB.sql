INSERT INTO tbltmp_Ins_Aktmon_Zuord ( ID, VADatum, VA_ID, MA_ID, Auftrag_Ort, MA_Start, MA_Ende, Brutto_Std, Netto_Std, Fahrtko, RL_34a )
SELECT qry_Ins_Aktmon_Zuord.ID, qry_Ins_Aktmon_Zuord.VADatum, qry_Ins_Aktmon_Zuord.VA_ID, qry_Ins_Aktmon_Zuord.MA_ID, qry_Ins_Aktmon_Zuord.Auftrag_Ort, qry_Ins_Aktmon_Zuord.MA_Start, qry_Ins_Aktmon_Zuord.MA_Ende, qry_Ins_Aktmon_Zuord.Brutto_Std, qry_Ins_Aktmon_Zuord.Netto_Std, qry_Ins_Aktmon_Zuord.Fahrtko, qry_Ins_Aktmon_Zuord.RL_34a
FROM qry_Ins_Aktmon_Zuord
ORDER BY qry_Ins_Aktmon_Zuord.VADatum, qry_Ins_Aktmon_Zuord.VA_ID;

