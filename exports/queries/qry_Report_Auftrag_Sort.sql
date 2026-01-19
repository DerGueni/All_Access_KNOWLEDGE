-- Query: qry_Report_Auftrag_Sort
-- Type: 0
SELECT tbl_VA_AnzTage.VADatum, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_Auftragstamm.*, tbl_VA_AnzTage.PKW_Anzahl AS PKW_Anz
FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Auftrag;

