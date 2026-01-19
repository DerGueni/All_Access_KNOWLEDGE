-- Query: zqry_MA_Verfuegbarkeit_Quali
-- Type: 0
SELECT zqry_MA_Verfuegbarkeit.*, tbl_MA_Einsatz_Zuo.Quali_ID
FROM zqry_MA_Verfuegbarkeit LEFT JOIN tbl_MA_Einsatz_Zuo ON zqry_MA_Verfuegbarkeit.ID = tbl_MA_Einsatz_Zuo.MA_ID
WHERE (((tbl_MA_Einsatz_Zuo.Quali_ID) Is Not Null));

