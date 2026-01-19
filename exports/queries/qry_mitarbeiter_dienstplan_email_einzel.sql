-- Query: qry_mitarbeiter_dienstplan_email_einzel
-- Type: 0
SELECT tbltmp_DP_MA_Grund_FI.*, tbl_MA_Mitarbeiterstamm.Email, tbltmp_DP_MA_Grund_FI.MAName, tbltmp_DP_MA_Grund_FI.MA_ID
FROM tbltmp_DP_MA_Grund_FI INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_DP_MA_Grund_FI.MA_ID = tbl_MA_Mitarbeiterstamm.ID;

