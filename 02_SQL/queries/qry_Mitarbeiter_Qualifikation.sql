SELECT tbl_MA_Mitarbeiterstamm.*, tbl_MA_Einsatz_Zuo.Quali_ID, tbl_MA_Einsatzart.QualiName
FROM tbl_MA_Einsatzart RIGHT JOIN (tbl_MA_Einsatz_Zuo RIGHT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_Einsatz_Zuo.MA_ID = tbl_MA_Mitarbeiterstamm.ID) ON tbl_MA_Einsatzart.ID = tbl_MA_Einsatz_Zuo.Quali_ID;

