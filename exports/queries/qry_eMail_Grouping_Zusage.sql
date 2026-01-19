-- Query: qry_eMail_Grouping_Zusage
-- Type: 0
SELECT tbl_eMail_Import.MA_ID, tbl_eMail_Import.VA_ID, tbl_eMail_Import.VADatum_ID, tbl_eMail_Import.VAStart_ID, tbl_eMail_Import.Zu_Absage
FROM tbl_eMail_Import
GROUP BY tbl_eMail_Import.MA_ID, tbl_eMail_Import.VA_ID, tbl_eMail_Import.VADatum_ID, tbl_eMail_Import.VAStart_ID, tbl_eMail_Import.Zu_Absage;

