-- Query: qry_DP_MA_Neu_1
-- Type: 128
SELECT tbl_MA_VA_Zuordnung.VADatum, [Nachname] & ' ' & [Vorname] AS MAName, CLng(Nz([PosNr],1)) AS Pos_Nr, fObjektOrt3(Nz([Auftrag]),Nz([tbl_VA_Auftragstamm].[Ort]),Nz([Objekt])) AS ObjOrt, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_Mitarbeiterstamm.IstAktiv, tbl_MA_Mitarbeiterstamm.IstSubunternehmer, tbl_MA_Mitarbeiterstamm.Anstellungsart_ID, tbl_MA_VA_Zuordnung.IstFraglich, CLng(Nz([tbl_MA_VA_Zuordnung].[ID],0)) AS ZuordID, tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende, tbl_MA_VA_Zuordnung.MVA_Start, 1 as Hlp
FROM (tbl_MA_VA_Zuordnung RIGHT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID
WHERE (((Abs(Len(Nz([VADatum_ID]))))>0))
UNION SELECT [_tblAlleTage].dtDatum AS VADatum, [Nachname] & ' ' & [Vorname] AS MAName, 1 AS Pos_Nr, tbl_MA_Zeittyp.ZeitTyp AS ObjOrt, tbl_MA_NVerfuegZeiten.MA_ID, tbl_MA_Mitarbeiterstamm.IstAktiv, tbl_MA_Mitarbeiterstamm.IstSubunternehmer, tbl_MA_Mitarbeiterstamm.Anstellungsart_ID, 0 AS IstFraglich, (([tbl_MA_Zeittyp].ID) * -1) AS ZuordID, -1 AS VA_ID, -1 AS VADatum_ID, -1 AS VAStart_ID, tbl_MA_NVerfuegZeiten.vonZeit AS MA_Start, tbl_MA_NVerfuegZeiten.bisZeit AS MA_Ende, tbl_MA_NVerfuegZeiten.vonDat AS MVA_Start, 1 AS Hlp
FROM _tblAlleTage, tbl_MA_Mitarbeiterstamm INNER JOIN (tbl_MA_Zeittyp INNER JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Zeittyp.Kuerzel_Datev = tbl_MA_NVerfuegZeiten.Zeittyp_ID) ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_NVerfuegZeiten.MA_ID
WHERE ((([_tblAlleTage].dtDatum) Between [vonTag] And [bistag]));

