-- Query: qry_eMail_MA_SMS
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, tbl_MA_Mitarbeiterstamm.Anr_eMail, [Nachname] & ", " & [Vorname] AS Gesname, tbl_MA_Mitarbeiterstamm.Tel_Mobil
FROM tbl_MA_Mitarbeiterstamm
WHERE (((Len(Trim(Nz([Tel_Mobil]))))>0))
ORDER BY [Nachname] & ", " & [Vorname];

