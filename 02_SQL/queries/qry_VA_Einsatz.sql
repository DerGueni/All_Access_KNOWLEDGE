SELECT tbl_VA_AnzTage.VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, [Auftrag] & " " & [Ort] & " " & [Objekt] AS Einsatz
FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
WHERE (((tbl_VA_Auftragstamm.ID) In (SELECT VA_ID FROM tbl_VA_Start)));

