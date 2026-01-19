UPDATE tbl_MA_Mitarbeiterstamm SET tbl_MA_Mitarbeiterstamm.Briefkopf = [Anr] & Chr$(13) & Chr$(10) & [Vorname] & " " & proper([Nachname]) & Chr$(13) & Chr$(10) & [Strasse] & " " & [Nr] & Chr$(13) & Chr$(10) & Chr$(13) & Chr$(10) & [PLZ] & " " & [Ort]
WHERE (((tbl_MA_Mitarbeiterstamm.IstBrfAuto)=False) AND ((LCase(Nz(Left([Geschlecht],1))))="m" Or (LCase(Nz(Left([Geschlecht],1))))="w") AND ((tbl_MA_Mitarbeiterstamm.ID)=1));

