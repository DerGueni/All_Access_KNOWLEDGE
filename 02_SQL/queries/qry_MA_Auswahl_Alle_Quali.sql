SELECT qry_MA_Auswahl_Alle.*, tbl_MA_Einsatz_Zuo.Quali_ID
FROM qry_MA_Auswahl_Alle INNER JOIN tbl_MA_Einsatz_Zuo ON qry_MA_Auswahl_Alle.ID = tbl_MA_Einsatz_Zuo.MA_ID;

