SELECT tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, tbl_KD_Kundenstamm.kun_Firma
FROM tbl_KD_Kundenstamm INNER JOIN tbl_VA_Auftragstamm ON tbl_KD_Kundenstamm.kun_Id = tbl_VA_Auftragstamm.Veranstalter_ID
WHERE (((tbl_VA_Auftragstamm.Dat_VA_Von)>#4/1/2016#))
ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von;

