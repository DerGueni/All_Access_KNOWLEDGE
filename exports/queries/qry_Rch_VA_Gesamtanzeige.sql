-- Query: qry_Rch_VA_Gesamtanzeige
-- Type: 0
SELECT tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, tbl_Rch_VA_Kopf.*
FROM tbl_VA_Auftragstamm RIGHT JOIN tbl_Rch_VA_Kopf ON tbl_VA_Auftragstamm.ID = tbl_Rch_VA_Kopf.VA_ID;

