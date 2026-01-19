-- Query: qry_eMail_MA_Std2
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, tbl_MA_Mitarbeiterstamm.Anr_eMail, [Nachname] & " " & [Vorname] AS Name, tbl_MA_Mitarbeiterstamm.Email AS [E-Mail], tbl_MA_Mitarbeiterstamm.Anstellungsart_ID
FROM tbl_MA_Mitarbeiterstamm
WHERE ((([Nachname] & " " & [Vorname])>"K*") AND ((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=3 Or (tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=5 Or (tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=11) AND ((Len(Trim(Nz([Email]))))>0))
ORDER BY [Nachname] & " " & [Vorname];

