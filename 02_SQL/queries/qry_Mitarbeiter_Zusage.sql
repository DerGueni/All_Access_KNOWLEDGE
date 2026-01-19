SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.IstFraglich, tbl_MA_Mitarbeiterstamm.Email, tbl_MA_VA_Zuordnung.PosNr, tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname, tbl_MA_VA_Zuordnung.MA_Start AS Beginn, IIf([Nachname]<>'',[Nachname],'ZZZ') AS Sortierfeld, tbl_MA_VA_Zuordnung.[MA_Ende] AS Ende
FROM tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID
ORDER BY tbl_MA_VA_Zuordnung.PosNr;

