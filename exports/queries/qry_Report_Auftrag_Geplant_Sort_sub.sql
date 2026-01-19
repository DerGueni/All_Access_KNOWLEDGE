-- Query: qry_Report_Auftrag_Geplant_Sort_sub
-- Type: 0
SELECT tbl_MA_VA_Planung.VA_ID, tbl_MA_VA_Planung.VADatum_ID, tbl_MA_VA_Planung.MA_ID, tbl_MA_VA_Planung.VADatum, tbl_MA_VA_Planung.PosNr, Left([VA_Start],5) & " Uhr" AS Start, Left([VA_Ende],5) & " Uhr" AS Ende, [Nachname] & ", " & [Vorname] AS Gesname, tbl_MA_VA_Planung.MA_Netto_Std, tbl_MA_VA_Planung.MA_Brutto_Std
FROM tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_VA_Planung ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_VA_Planung.MA_ID
WHERE (((tbl_MA_VA_Planung.Status_ID)<3));

