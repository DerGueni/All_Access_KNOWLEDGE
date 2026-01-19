INSERT INTO tbltmp_Ins_Aktmon_Zuord ( ID, VADatum, VA_ID, MA_ID, Auftrag_Ort )
SELECT qry_MonZusB2.ID, qry_MonZusB2.VADatum, qry_MonZusB2.VA_ID, qry_MonZusB2.MA_ID, qry_MonZusB2.Auftrag_Ort
FROM qry_MonZusB2;

