DELETE tbl_eMail_Import.*, Nz(InStr([Betreff],"Intern:"),0) AS Ausdr2
FROM tbl_eMail_Import
WHERE (((Nz(InStr([Betreff],"Intern:"),0))=0));

