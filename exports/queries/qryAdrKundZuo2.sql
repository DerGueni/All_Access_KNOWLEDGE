-- Query: qryAdrKundZuo2
-- Type: 0
SELECT tbl_KD_Ansprechpartner.adr_ID, tbl_KD_Ansprechpartner.adr_Tel, tbl_KD_Ansprechpartner.adr_Handy, tbl_KD_Ansprechpartner.adr_Anschreiben, tbl_KD_Ansprechpartner.adr_eMail, tbl_KD_Ansprechpartner.adr_Name1
FROM tbl_KD_Ansprechpartner
WHERE (((tbl_KD_Ansprechpartner.kun_Id)=get_Priv_Property("prp_Stamm_ID")))
ORDER BY tbl_KD_Ansprechpartner.adr_Nachname, tbl_KD_Ansprechpartner.adr_Vorname;

