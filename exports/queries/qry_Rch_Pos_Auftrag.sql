-- Query: qry_Rch_Pos_Auftrag
-- Type: 0
SELECT tbl_Rch_Pos_Auftrag.*, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort
FROM tbl_Rch_Pos_Auftrag LEFT JOIN tbl_VA_Auftragstamm ON tbl_Rch_Pos_Auftrag.VA_ID = tbl_VA_Auftragstamm.ID;

