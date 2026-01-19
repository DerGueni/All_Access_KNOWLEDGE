UPDATE tbl_eMail_Import SET tbl_eMail_Import.Zu_Absage = -1, tbl_eMail_Import.IstErledigt = 2
WHERE (((tbl_eMail_Import.IstErledigt)=0) AND ((UCase(Left(Trim(Nz([Body])),2)))="JA")) OR (((tbl_eMail_Import.IstErledigt)=0) AND ((UCase(Left(Trim(Nz([Body])),6)))="ZUSAGE"));

