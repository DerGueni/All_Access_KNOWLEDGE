SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, [Nachname] & ' ' & [Vorname] AS MAName, tbl_MA_Mitarbeiterstamm.IstAktiv, tbl_MA_Mitarbeiterstamm.IstSubunternehmer, tbl_MA_Mitarbeiterstamm.Anstellungsart_ID, 0 AS IstFraglich, 0 AS hlp
FROM tbl_MA_Mitarbeiterstamm
WHERE (((tbl_MA_Mitarbeiterstamm.ID) Not In (SELECT MA_ID FROM tbltmp_DP_MA_Neu_1)));

