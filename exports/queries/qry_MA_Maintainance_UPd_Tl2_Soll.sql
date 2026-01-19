-- Query: qry_MA_Maintainance_UPd_Tl2_Soll
-- Type: 48
UPDATE tbl_VA_AnzTage INNER JOIN temp_tbl_MA_Maintainance_Zuo_Tl3 ON (temp_tbl_MA_Maintainance_Zuo_Tl3.VA_ID = tbl_VA_AnzTage.VA_ID) AND (tbl_VA_AnzTage.ID = temp_tbl_MA_Maintainance_Zuo_Tl3.VADatum_ID) SET tbl_VA_AnzTage.TVA_Soll = [MA_Soll];

