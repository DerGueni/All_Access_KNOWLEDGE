UPDATE tbl_MA_VA_Planung INNER JOIN tbl_eMail_Import ON (tbl_MA_VA_Planung.MA_ID = tbl_eMail_Import.MA_ID) AND (tbl_MA_VA_Planung.VAStart_ID = tbl_eMail_Import.VAStart_ID) AND (tbl_MA_VA_Planung.VADatum_ID = tbl_eMail_Import.VADatum_ID) AND (tbl_MA_VA_Planung.VA_ID = tbl_eMail_Import.VA_ID) SET tbl_MA_VA_Planung.Status_ID = 4
WHERE (((tbl_eMail_Import.Zu_Absage)=0) AND ((tbl_eMail_Import.IstErledigt)=2));

