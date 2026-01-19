SELECT tbl_VA_Auftragstamm.*, tbl_VA_AnzTage.VADatum, [Auftrag] & " - " & [Objekt] & " - " & [Ort] AS AuftragOrt
FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
WHERE (((tbl_VA_Auftragstamm.ID)=Get_Priv_Property("prp_Report1_Auftrag_ID")) AND ((tbl_VA_AnzTage.ID)=Get_Priv_Property("prp_Report1_Auftrag_VADatum_ID")));

