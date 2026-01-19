-- Query: qry_MA_VA_EinzelExcel_Alle_Nverfueg
-- Type: 0
SELECT 0 AS VA_ID, 0 AS VA_Datum_ID, 0 AS VA_Start_ID, tbl_MA_NVerfuegZeiten.MA_ID, [_tblAlleTage].dtDatum AS VADatum, Format([vondat],"Short Time") AS MA_Start, Format([bisdat],"Short Time") AS MA_Ende, 1 AS MA_Anzahl, tbl_MA_Mitarbeiterstamm.IstSubunternehmer, [Nachname] & " " & [Vorname] AS Name, tbl_MA_Zeittyp.Zeittyp AS Auftrag, "" AS Ort, "" AS Objekt, " " AS VA_Treffpunkt, " " AS Treffpunkt, Null AS VA_Zeitpunkt, Null AS Treffp_Zeit, "" AS Dienstkleidung, "" AS Firma, "" AS Ansprechpartner
FROM _tblAlleTage, tbl_MA_Mitarbeiterstamm INNER JOIN (tbl_MA_Zeittyp INNER JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Zeittyp.Kuerzel_Datev = tbl_MA_NVerfuegZeiten.Zeittyp_ID) ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_NVerfuegZeiten.MA_ID
WHERE ((([_tblAlleTage].dtDatum) Between [vonTag] And [bistag]))
ORDER BY [_tblAlleTage].dtDatum;

