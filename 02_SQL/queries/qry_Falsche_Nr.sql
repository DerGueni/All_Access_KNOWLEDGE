SELECT tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.ID AS Zuo_ID, tbl_MA_VA_Zuordnung.PosNr, tbl_MA_VA_Zuordnung.MA_ID
FROM tbl_MA_VA_Zuordnung LEFT JOIN tbl_VA_Start ON tbl_MA_VA_Zuordnung.VAStart_ID = tbl_VA_Start.ID
WHERE (((tbl_VA_Start.ID) Is Null));

