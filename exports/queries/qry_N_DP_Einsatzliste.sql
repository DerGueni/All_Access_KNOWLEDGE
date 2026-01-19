-- Query: qry_N_DP_Einsatzliste
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.PosNr, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_Mitarbeiterstamm.Nachname & ' ' & tbl_MA_Mitarbeiterstamm.Vorname AS MA_Name, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende, Round(([MA_Ende]-[MA_Start])*24,2) AS Std, tbl_MA_VA_Zuordnung.Bemerkungen, tbl_MA_VA_Zuordnung.PKW, tbl_MA_VA_Zuordnung.Einsatzleitung, tbl_MA_VA_Zuordnung.IstFraglich
FROM tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID
ORDER BY tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.PosNr;

