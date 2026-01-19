-- Query: qry_Rch_Sub_VA_Kopf
-- Type: 0
SELECT tbl_Rch_VA_Kopf.Rch_ID, tbl_Rch_VA_Kopf.VA_ID, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt
FROM tbl_Rch_VA_Kopf LEFT JOIN tbl_VA_Auftragstamm ON tbl_Rch_VA_Kopf.VA_ID = tbl_VA_Auftragstamm.ID;

