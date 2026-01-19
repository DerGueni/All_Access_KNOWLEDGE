-- Query: qry_VA_Akt_Auftragskopf
-- Type: 0
SELECT tbl_VA_Akt_Objekt_Kopf.ID, tbl_VA_Akt_Objekt_Kopf.VADatum_ID, tbl_VA_Akt_Objekt_Kopf.VA_ID, Format([VADatum],"ddd dd/mm/yyyy",2,2) & " - " & [Auftrag] & " " & [Ort] & " " & [Objekt] AS AuftragKopf
FROM tbl_VA_Auftragstamm RIGHT JOIN tbl_VA_Akt_Objekt_Kopf ON tbl_VA_Auftragstamm.ID = tbl_VA_Akt_Objekt_Kopf.VA_ID
ORDER BY tbl_VA_Akt_Objekt_Kopf.VADatum, tbl_VA_Auftragstamm.Auftrag;

