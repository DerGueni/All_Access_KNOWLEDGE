-- Query: qry_ListView_Sample
-- Type: 0
SELECT TOP 100 tbl_VA_Auftragstamm.ID, tbl_VA_Auftragstamm.Auftrag, Nz(tbl_KD_Kundenstamm.kun_Firma) AS Auftraggeber, Nz(tbl_VA_Auftragstamm.Objekt) AS [Object], Nz(tbl_VA_Auftragstamm.Ort) AS Ortsname, tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis
FROM tbl_KD_Kundenstamm RIGHT JOIN tbl_VA_Auftragstamm ON tbl_KD_Kundenstamm.kun_Id = tbl_VA_Auftragstamm.Veranstalter_ID
ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von DESC;

