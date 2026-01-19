SELECT ztbl_Lohnabrechnungen.*, TLookup("Nachname","tbl_MA_Mitarbeiterstamm","LEXWare_ID= " & [Lex_ID] & " AND IstAktiv = TRUE") & " " & TLookup("Vorname","tbl_MA_Mitarbeiterstamm","LEXWare_ID= " & [Lex_ID] & " AND IstAktiv = TRUE") AS Name, TLookup("Anstellungsart_ID","tbl_MA_Mitarbeiterstamm","LEXWare_ID= " & [Lex_ID] & " AND IstAktiv = TRUE") AS Anstellungsart_ID
FROM ztbl_Lohnabrechnungen
ORDER BY TLookup("Nachname","tbl_MA_Mitarbeiterstamm","LEXWare_ID= " & [Lex_ID] & " AND IstAktiv = TRUE") & " " & TLookup("Vorname","tbl_MA_Mitarbeiterstamm","LEXWare_ID= " & [Lex_ID] & " AND IstAktiv = TRUE");

