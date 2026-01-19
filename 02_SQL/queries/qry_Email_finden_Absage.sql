UPDATE tbl_eMail_Import SET tbl_eMail_Import.Zu_Absage = 0, tbl_eMail_Import.IstErledigt = 2
WHERE (((tbl_eMail_Import.IstErledigt)=0) AND ((UCase(Left(Trim(Nz([Body])),4)))="NEIN")) OR (((tbl_eMail_Import.IstErledigt)=0) AND ((UCase(Left(Trim(Nz([Body])),6)))="ABSAGE"));

