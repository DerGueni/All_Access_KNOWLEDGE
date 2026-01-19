-- Query: qry_Zeitabfrage_Zuordnung
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.MA_ID, 3 AS Status_ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, [Nachname] & ", " & [Vorname] AS MA_Name, fGetStDat([tbl_VA_AnzTage].[VaDatum],[VA_Start]) AS VA_StartDat, fGetEndDat([tbl_VA_AnzTage].[VaDatum],[VA_Start],[VA_Ende]) AS VA_EndeDat
FROM tbl_VA_Start RIGHT JOIN (tbl_VA_Auftragstamm RIGHT JOIN ((tbl_MA_VA_Zuordnung LEFT JOIN tbl_VA_AnzTage ON tbl_MA_VA_Zuordnung.VADatum_ID = tbl_VA_AnzTage.ID) LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID) ON tbl_VA_Start.ID = tbl_MA_VA_Zuordnung.VAStart_ID
WHERE (((tbl_MA_VA_Zuordnung.MA_ID)>0));

