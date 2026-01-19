UPDATE tbl_MA_Mitarbeiterstamm SET tbl_MA_Mitarbeiterstamm.Anr = "Herrn", tbl_MA_Mitarbeiterstamm.Anr_Brief = "Sehr geehrter Herr " & proper([Nachname]) & ",", tbl_MA_Mitarbeiterstamm.Anr_eMail = "Hallo " & [Vorname] & ",", tbl_MA_Mitarbeiterstamm.Briefkopf = "Herrn" & Chr$(13) & Chr$(10) & [Vorname] & " " & proper([Nachname]) & Chr$(13) & Chr$(10) & [Strasse] & " " & [Nr] & Chr$(13) & Chr$(10) & Chr$(13) & Chr$(10) & [PLZ] & " " & [Ort], tbl_MA_Mitarbeiterstamm.IstBrfAuto = False
WHERE (((LCase(Nz(Left([Geschlecht],1))))="m"));

