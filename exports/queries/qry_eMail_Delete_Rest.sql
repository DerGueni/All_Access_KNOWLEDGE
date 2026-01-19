-- Query: qry_eMail_Delete_Rest
-- Type: 32
DELETE tbl_eMail_Import.*, Nz(InStr([Betreff],"Intern:"),0) AS Ausdr2
FROM tbl_eMail_Import
WHERE (((Nz(InStr([Betreff],"Intern:"),0))=0));

