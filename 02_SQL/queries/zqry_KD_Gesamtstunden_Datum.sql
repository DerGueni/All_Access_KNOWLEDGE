SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Firma, Sum(tbl_MA_VA_Zuordnung.MA_Brutto_Std2) AS SummevonMA_Brutto_Std2, Year([VADatum]) AS Jahr
FROM tbl_KD_Kundenstamm INNER JOIN (tbl_VA_Auftragstamm INNER JOIN tbl_MA_VA_Zuordnung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID) ON tbl_KD_Kundenstamm.kun_Id = tbl_VA_Auftragstamm.Veranstalter_ID
GROUP BY tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Firma, Year([VADatum]);

