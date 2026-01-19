UPDATE tbl_VA_AnzTage INNER JOIN temp_tbl_MA_Maintainance_PKW_Zuo_T2 ON (tbl_VA_AnzTage.ID = temp_tbl_MA_Maintainance_PKW_Zuo_T2.VADatum_ID) AND (tbl_VA_AnzTage.VA_ID = temp_tbl_MA_Maintainance_PKW_Zuo_T2.VA_ID) SET tbl_VA_AnzTage.PKW_Anzahl = [AnzahlvonPKW];

