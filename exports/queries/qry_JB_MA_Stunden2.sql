-- Query: qry_JB_MA_Stunden2
-- Type: 0
SELECT qry_JB_Neuberech_1.MA_ID, qry_JB_Neuberech_1.AktJ AS AktJahr, qry_JB_Neuberech_1.AktM1 AS AktMonat, qry_JB_MA_Stunden2a.MA_Brutto_Std1, qry_JB_MA_Stunden2a.MA_Netto_Std1, qry_JB_MA_Stunden2a.Fahrtkost, qry_JB_MA_Stunden2a.RL_34a
FROM qry_JB_Neuberech_1 LEFT JOIN qry_JB_MA_Stunden2a ON (qry_JB_Neuberech_1.MA_ID = qry_JB_MA_Stunden2a.MA_ID) AND (qry_JB_Neuberech_1.AktJ = qry_JB_MA_Stunden2a.AktJahr) AND (qry_JB_Neuberech_1.AktM1 = qry_JB_MA_Stunden2a.AktMonat);

