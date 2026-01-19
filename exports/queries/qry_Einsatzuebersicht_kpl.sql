-- Query: qry_Einsatzuebersicht_kpl
-- Type: 0
SELECT tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende, tbl_MA_VA_Zuordnung.MA_Brutto_Std2, tbl_MA_VA_Zuordnung.MA_Netto_Std2, tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname, tbl_MA_VA_Zuordnung.PosNr, tbl_MA_VA_Zuordnung.VADatum
FROM (tbl_VA_Auftragstamm INNER JOIN tbl_MA_VA_Zuordnung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID) INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID;

