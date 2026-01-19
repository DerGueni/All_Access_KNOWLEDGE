-- Query: qry_Anz_Auftrag_AllTag
-- Type: 0
SELECT tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, tbl_VA_AnzTage.TVA_Offen
FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID;

