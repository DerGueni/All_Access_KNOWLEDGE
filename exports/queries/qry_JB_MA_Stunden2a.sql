-- Query: qry_JB_MA_Stunden2a
-- Type: 0
SELECT qry_JB_MA_Stunden1.MA_ID, qry_JB_MA_Stunden1.AktJahr, qry_JB_MA_Stunden1.AktMonat, Sum(qry_JB_MA_Stunden1.MA_Brutto_Std) AS MA_Brutto_Std1, Sum(qry_JB_MA_Stunden1.MA_Netto_Std) AS MA_Netto_Std1, Sum(qry_JB_MA_Stunden1.PKW) AS Fahrtkost, Sum(qry_JB_MA_Stunden1.RL_34a) AS RL_34a
FROM qry_JB_MA_Stunden1
GROUP BY qry_JB_MA_Stunden1.MA_ID, qry_JB_MA_Stunden1.AktJahr, qry_JB_MA_Stunden1.AktMonat;

