DELETE tbl_eMail_Import.*, tbl_VA_AnzTage.VADatum
FROM tbl_eMail_Import INNER JOIN tbl_VA_AnzTage ON tbl_eMail_Import.VADatum_ID = tbl_VA_AnzTage.ID
WHERE (((tbl_VA_AnzTage.VADatum)<Date()-1));

