SELECT tbl_VA_Akt_Objekt_Kopf.ID, Format([VADatum],"ddd dd/mm/yyyy",2,2) & " - " & [Auftrag] AS AuftragKopf
FROM tbl_VA_Auftragstamm RIGHT JOIN tbl_VA_Akt_Objekt_Kopf ON tbl_VA_Auftragstamm.ID = tbl_VA_Akt_Objekt_Kopf.VA_ID
WHERE (((tbl_VA_Akt_Objekt_Kopf.VADatum)<Date()))
ORDER BY tbl_VA_Akt_Objekt_Kopf.VADatum, tbl_VA_Auftragstamm.Auftrag;

