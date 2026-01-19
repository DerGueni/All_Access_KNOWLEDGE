SELECT tbl_eMail_Import.Sender, tbl_eMail_Import.Sendername, tbl_eMail_Import.MA_ID, tbl_eMail_Import.Body
FROM tbl_eMail_Import
WHERE (((tbl_eMail_Import.MA_ID)=0) AND ((tbl_eMail_Import.IstErledigt)=0));

