-- Query: qry_eMail_Update_Erledigt
-- Type: 48
UPDATE tbl_eMail_Import SET tbl_eMail_Import.IstErledigt = -1
WHERE (((tbl_eMail_Import.IstErledigt)=2));

