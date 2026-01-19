SELECT tbl_VA_Auftragstamm.Veranstalter_ID, Count(tbl_VA_Auftragstamm.ID) AS AnzahlvonID
FROM tbl_VA_Auftragstamm
GROUP BY tbl_VA_Auftragstamm.Veranstalter_ID
ORDER BY Count(tbl_VA_Auftragstamm.ID) DESC;

