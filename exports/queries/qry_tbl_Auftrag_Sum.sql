-- Query: qry_tbl_Auftrag_Sum
-- Type: 0
SELECT tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_Auftragstamm.Veranstalter_ID, tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis, tbl_VA_Status.Fortschritt, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, qry_tbl_VA_AnzTage_Sum.TVA_Ist, qry_tbl_VA_AnzTage_Sum.TVA_Soll, tbl_VA_Auftragstamm.Rch_Nr, tbl_VA_Auftragstamm.Rch_Dat, fctRound([MA_Brutto_Std]) AS [Brutto Std], fctRound([MA_Netto_Std]) AS [Netto Std], qry_tbl_MA_VA_Zuordnung_Sum.FahrtKo
FROM qry_tbl_MA_VA_Zuordnung_Sum RIGHT JOIN (qry_tbl_VA_AnzTage_Sum RIGHT JOIN (tbl_VA_Auftragstamm LEFT JOIN tbl_VA_Status ON tbl_VA_Auftragstamm.Veranst_Status_ID = tbl_VA_Status.ID) ON qry_tbl_VA_AnzTage_Sum.VA_ID = tbl_VA_Auftragstamm.ID) ON qry_tbl_MA_VA_Zuordnung_Sum.VA_ID = tbl_VA_Auftragstamm.ID
ORDER BY tbl_VA_Auftragstamm.Veranstalter_ID, tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis, tbl_VA_Auftragstamm.Auftrag;

