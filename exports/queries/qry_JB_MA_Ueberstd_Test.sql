-- Query: qry_JB_MA_Ueberstd_Test
-- Type: 0
SELECT qry_JB_MA_Sum.*, tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname, fctRound([MA_Netto_Std]-[StundenZahlMax]) AS Ueberstd, tbl_MA_Mitarbeiterstamm.StundenZahlMax
FROM tbl_MA_Mitarbeiterstamm INNER JOIN qry_JB_MA_Sum ON tbl_MA_Mitarbeiterstamm.ID = qry_JB_MA_Sum.MA_ID
WHERE (((fctRound([MA_Netto_Std]-[StundenZahlMax]))>0) AND ((tbl_MA_Mitarbeiterstamm.StundenZahlMax)>0));

