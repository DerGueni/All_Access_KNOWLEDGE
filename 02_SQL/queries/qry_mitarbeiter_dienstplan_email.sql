SELECT tbltmp_DP_MA_Grund_FI.*, tbl_MA_Mitarbeiterstamm.Email
FROM tbltmp_DP_MA_Grund_FI INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_DP_MA_Grund_FI.MA_ID = tbl_MA_Mitarbeiterstamm.ID;

