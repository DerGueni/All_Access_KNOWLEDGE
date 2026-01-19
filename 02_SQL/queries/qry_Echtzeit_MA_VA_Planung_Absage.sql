SELECT tbl_MA_VA_Planung.MA_ID, tbl_MA_VA_Planung.MVA_Start, tbl_MA_VA_Planung.MVA_Ende, 'ABSAGE / ' & [Auftrag] & ' ' & [Ort] & ' ' & [Objekt] AS Grund
FROM (tbl_KD_Kundenstamm RIGHT JOIN tbl_VA_Auftragstamm ON tbl_KD_Kundenstamm.kun_Id = tbl_VA_Auftragstamm.Veranstalter_ID) RIGHT JOIN tbl_MA_VA_Planung ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Planung.VA_ID
WHERE (((tbl_MA_VA_Planung.Status_ID)=4) AND ((tbl_MA_VA_Planung.VA_ID)=16));

