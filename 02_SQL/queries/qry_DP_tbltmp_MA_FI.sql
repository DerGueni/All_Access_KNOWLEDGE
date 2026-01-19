SELECT tbltmp_DP_MA_Grund_FI.*
FROM tbltmp_DP_MA_Grund_FI INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_DP_MA_Grund_FI.MA_ID = tbl_MA_Mitarbeiterstamm.ID
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;

