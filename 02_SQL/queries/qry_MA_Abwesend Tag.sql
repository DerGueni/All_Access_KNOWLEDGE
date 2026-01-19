SELECT tbl_MA_NVerfuegZeiten.Zeittyp_ID, CDate(CLng([vonDat])) AS AbwDat, tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname
FROM tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_NVerfuegZeiten.MA_ID
GROUP BY tbl_MA_NVerfuegZeiten.Zeittyp_ID, CDate(CLng([vonDat])), tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname
ORDER BY CDate(CLng([vonDat])), tbl_MA_Mitarbeiterstamm.Nachname;

