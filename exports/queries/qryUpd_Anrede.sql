-- Query: qryUpd_Anrede
-- Type: 48
PARAMETERS Adress_ID Long;
UPDATE tbl_KD_Anrede INNER JOIN tbl_KD_Ansprechpartner ON tbl_KD_Anrede.Anr_ID = tbl_KD_Ansprechpartner.adr_AnredeID SET tbl_KD_Ansprechpartner.adr_Name1 = [Anr_Anrede] & " " & [adr_Vorname] & " " & [adr_Nachname], tbl_KD_Ansprechpartner.adr_Anschreiben = [Anr_Anrede_Brf] & " " & [adr_Nachname] & ","
WHERE (((tbl_KD_Ansprechpartner.adr_ID)=[Adress_ID]));

