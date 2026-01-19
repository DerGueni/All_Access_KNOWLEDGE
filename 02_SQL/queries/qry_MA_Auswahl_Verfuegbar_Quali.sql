SELECT qry_MA_Auswahl_Verfuegbar.*, tbl_MA_Einsatz_Zuo.Quali_ID
FROM tbl_MA_Einsatz_Zuo INNER JOIN qry_MA_Auswahl_Verfuegbar ON tbl_MA_Einsatz_Zuo.MA_ID = qry_MA_Auswahl_Verfuegbar.ID;

