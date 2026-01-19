SELECT tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, [Objekt] & " " & [Ort] AS ObjOrt, [TVA_Ist] & " / " & [TVA_Soll] AS MA_SPI, tbl_VA_AnzTage.TVA_Offen
FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID;

