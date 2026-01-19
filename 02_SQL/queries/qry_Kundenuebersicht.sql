SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Firma, tbl_KD_Standardpreise.StdPreis, tbl_KD_Standardpreise.Preisart_ID
FROM tbl_KD_Kundenstamm INNER JOIN tbl_KD_Standardpreise ON tbl_KD_Kundenstamm.kun_Id = tbl_KD_Standardpreise.kun_ID;

