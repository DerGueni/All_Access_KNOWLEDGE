SELECT tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, [Auftrag] & ' ' & [Ort] & ' ' & [Objekt] AS Auftrag_, Nz([TVA_Ist],0) & ' / ' & Nz([TVA_Soll],0) AS I_S, tbl_VA_AnzTage.TVA_Offen
FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID;

