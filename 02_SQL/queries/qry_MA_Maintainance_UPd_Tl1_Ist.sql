UPDATE tbl_VA_AnzTage INNER JOIN temp_tbl_MA_Maintainance_Zuo_Tl1 ON (tbl_VA_AnzTage.VA_ID = temp_tbl_MA_Maintainance_Zuo_Tl1.VA_ID) AND (tbl_VA_AnzTage.ID = temp_tbl_MA_Maintainance_Zuo_Tl1.VADatum_ID) SET tbl_VA_AnzTage.TVA_Ist = [Anz_MA_Ist];

