-- Query: qry_lst_Row_Auftrag
-- Type: 0
SELECT tbl_VA_Auftragstamm.ID, tbl_VA_AnzTage.VADatum AS Datum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, tbl_VA_AnzTage.TVA_Soll AS Soll, tbl_VA_AnzTage.TVA_Ist AS Ist, tbl_Veranst_Status.Fortschritt AS Status, tbl_VA_AnzTage.ID, tbl_KD_Kundenstamm.kun_Firma
FROM (tbl_KD_Kundenstamm RIGHT JOIN (tbl_VA_Auftragstamm LEFT JOIN tbl_Veranst_Status ON tbl_VA_Auftragstamm.Veranst_Status_ID = tbl_Veranst_Status.ID) ON tbl_KD_Kundenstamm.kun_Id = tbl_VA_Auftragstamm.Veranstalter_ID) LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
WHERE 1 = 1 AND (((tbl_VA_AnzTage.VADatum) >= #2026-01-16#))
ORDER BY tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt;

