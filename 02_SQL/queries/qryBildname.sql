SELECT tbl_MA_Mitarbeiterstamm.ID, tbl_MA_Mitarbeiterstamm.Nachname, UCase([Nachname] & ".jpg") AS NN, UCase([Nachname] & Left([Vorname],1) & ".jpg") AS NuV1, UCase([Nachname] & [Vorname] & ".jpg") AS NuVA
FROM tbl_MA_Mitarbeiterstamm;

