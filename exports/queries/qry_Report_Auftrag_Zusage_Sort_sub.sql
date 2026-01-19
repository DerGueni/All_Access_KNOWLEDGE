-- Query: qry_Report_Auftrag_Zusage_Sort_sub
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.PosNr, Left([MA_Start],5) & " Uhr" AS Start, Left([MA_Ende],5) & " Uhr" AS Ende, [Nachname] & " " & [Vorname] AS Gesname, tbl_MA_VA_Zuordnung.MA_Netto_Std, tbl_MA_VA_Zuordnung.MA_Brutto_Std, IIf(Nz(tbl_MA_VA_Zuordnung.PKW,0)>0,"PKW"," ") AS PKW, tbl_MA_VA_Zuordnung.Bemerkungen, tbl_MA_VA_Zuordnung.RL_34a, "" AS Status
FROM tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID;

