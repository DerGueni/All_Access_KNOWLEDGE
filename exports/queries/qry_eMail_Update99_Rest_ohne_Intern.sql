-- Query: qry_eMail_Update99_Rest_ohne_Intern
-- Type: 48
UPDATE tbl_eMail_Import SET tbl_eMail_Import.IstErledigt = 99
WHERE (((tbl_eMail_Import.IstErledigt)=0) AND ((Nz(InStr([Betreff],"Intern:"),0))=0));

