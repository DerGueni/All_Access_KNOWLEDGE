SELECT tbl_MA_Mitarbeiterstamm.ID, [Nachname] & [Vorname] AS Name, tbl_MA_Mitarbeiterstamm.Email, tbl_MA_Mitarbeiterstamm.Tel_Mobil
FROM tbl_MA_Mitarbeiterstamm
WHERE (((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=3 Or (tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=5))
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname;

