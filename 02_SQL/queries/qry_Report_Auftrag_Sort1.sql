SELECT tbl_VA_AnzTage.VADatum, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_Auftragstamm.*
FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
WHERE VADATUM = #2015/03/07#
ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Auftrag;

