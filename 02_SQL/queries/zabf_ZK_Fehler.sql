SELECT [tbl_MA_Mitarbeiterstamm].[Nachname] & " " & [tbl_MA_Mitarbeiterstamm].[Vorname] AS Name, ztbl_ZK_Fehler.*
FROM ztbl_ZK_Fehler INNER JOIN tbl_MA_Mitarbeiterstamm ON ztbl_ZK_Fehler.MA_ID = tbl_MA_Mitarbeiterstamm.ID;

