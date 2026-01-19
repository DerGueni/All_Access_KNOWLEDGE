SELECT tbl_MA_Jahresuebersicht.*, ([Nachname]) & " " & ([Vorname]) AS Name
FROM tbl_MA_Jahresuebersicht INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_Jahresuebersicht.MA_ID = tbl_MA_Mitarbeiterstamm.ID;

