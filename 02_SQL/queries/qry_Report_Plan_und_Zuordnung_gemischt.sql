SELECT tbl_MA_VA_Planung.VA_ID, tbl_MA_VA_Planung.VADatum_ID, tbl_MA_VA_Planung.MA_ID, tbl_MA_VA_Planung.VADatum, tbl_MA_VA_Planung.PosNr, Left([VA_Start],5) & " Uhr" AS Start, Left([VA_Ende],5) & " Uhr" AS Ende, [Nachname] & ", " & [Vorname] AS Gesname, tbl_MA_VA_Planung.MA_Netto_Std, tbl_MA_VA_Planung.MA_Brutto_Std,  iif(Nz([tbl_MA_VA_Planung].[PKW],0) > 0,"PKW"," ") as PKW,  tbl_MA_VA_Planung.Bemerkungen, 
'Geplant' AS Status
FROM tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_VA_Planung ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_VA_Planung.MA_ID
UNION SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.PosNr, Left([MA_Start],5) & " Uhr" AS Start, Left([MA_Ende],5) & " Uhr" AS Ende, [Nachname] & ", " & [Vorname] AS Gesname, tbl_MA_VA_Zuordnung.MA_Netto_Std, tbl_MA_VA_Zuordnung.MA_Brutto_Std, iif(Nz([tbl_MA_VA_Zuordnung].[PKW],0) > 0,"PKW"," ") as PKW, 
tbl_MA_VA_Zuordnung.Bemerkungen, 
'Zugesagt' AS Status
FROM tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_VA_Zuordnung ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_VA_Zuordnung.MA_ID
ORDER BY VA_ID, Status DESC , PosNr;

