-- Query: qry_Ins_MA_JahrMon1_Sum
-- Type: 0
SELECT qry_Ins_MA_JahrMon1.MA_ID, qry_Ins_MA_JahrMon1.AktJahr, qry_Ins_MA_JahrMon1.AktMon, Sum(qry_Ins_MA_JahrMon1.Netto_Std) AS Netto_Std1, Sum(qry_Ins_MA_JahrMon1.RL_34a) AS RL_34a, Sum(qry_Ins_MA_JahrMon1.Brutto_Std) AS Brutto_Std, Sum(qry_Ins_MA_JahrMon1.Fahrtko) AS Fahrtko
FROM qry_Ins_MA_JahrMon1
GROUP BY qry_Ins_MA_JahrMon1.MA_ID, qry_Ins_MA_JahrMon1.AktJahr, qry_Ins_MA_JahrMon1.AktMon;

