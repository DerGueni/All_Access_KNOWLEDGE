-- Query: qry_UE_Month_Daten
-- Type: 0
SELECT tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, [Auftrag] & " " & [Ort] & " " & [Objekt] AS Obj, [TVA_Ist] & " / " & [TVA_Soll] AS IstSoll, qryAlleTage_Default.JahrNr, qryAlleTage_Default.MonatNr, qryAlleTage_Default.TagNr, qryAlleTage_Default.WN_KalTag, qryAlleTage_Default.KW_D
FROM tbl_VA_Auftragstamm INNER JOIN (tbl_VA_AnzTage INNER JOIN qryAlleTage_Default ON tbl_VA_AnzTage.VADatum = qryAlleTage_Default.dtDatum) ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
ORDER BY tbl_VA_AnzTage.VADatum, [Auftrag] & " " & [Ort] & " " & [Objekt];

