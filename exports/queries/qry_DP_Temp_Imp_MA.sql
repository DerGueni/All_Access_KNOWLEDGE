-- Query: qry_DP_Temp_Imp_MA
-- Type: 0
SELECT tbltmp_DP_MA_Grund.*, tbl_MA_Mitarbeiterstamm.IstAktiv, tbl_MA_Mitarbeiterstamm.IstSubunternehmer, tbl_MA_Mitarbeiterstamm.Anstellungsart_ID
FROM tbltmp_DP_MA_Grund INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_DP_MA_Grund.MA_ID = tbl_MA_Mitarbeiterstamm.ID;

