UPDATE tbl_eMail_Import SET tbl_eMail_Import.IstErledigt = 90
WHERE (((tbl_eMail_Import.IstErledigt)=0) AND ((tbl_eMail_Import.Sender)='consec-auftragsplanung@gmx.de'));

