SELECT tbl_VA_Auftragstamm.*, tbl_KD_Kundenstamm.kun_Firma, tbl_VA_Auftragstamm.Dat_VA_Von
FROM tbl_VA_Auftragstamm INNER JOIN tbl_KD_Kundenstamm ON tbl_VA_Auftragstamm.Veranstalter_ID = tbl_KD_Kundenstamm.kun_Id
WHERE (((tbl_VA_Auftragstamm.Dat_VA_Von)>=#4/1/2016#))
ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von;

