SELECT tbl_MA_Mitarbeiterstamm.ID, tbl_MA_Mitarbeiterstamm.LEXWare_ID, UCase([tbl_MA_Mitarbeiterstamm].[Nachname]) AS Nachname, UCase([tbl_MA_Mitarbeiterstamm].[Vorname]) AS Vorname, UCase([tbl_MA_Mitarbeiterstamm].[Nachname]) & " " & UCase([tbl_MA_Mitarbeiterstamm].[Vorname]) AS Name
FROM tbl_MA_Mitarbeiterstamm;

