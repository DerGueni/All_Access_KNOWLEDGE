SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Standardpreise.StdPreis, tbl_KD_Kundenstamm.kun_Firma
FROM tbl_KD_Kundenstamm INNER JOIN tbl_KD_Standardpreise ON tbl_KD_Kundenstamm.kun_Id = tbl_KD_Standardpreise.kun_ID
WHERE (((tbl_KD_Standardpreise.Preisart_ID)=1))
ORDER BY tbl_KD_Kundenstamm.kun_Firma;

