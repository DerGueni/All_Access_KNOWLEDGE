SELECT tbl_VA_Akt_Objekt_Kopf.ID, tbl_VA_Akt_Objekt_Kopf.VADatum_ID, tbl_VA_Akt_Objekt_Kopf.VA_ID, Format(tbl_VA_AnzTage.VADatum,'ddd dd.mm.yyyy',2,2) & ' - ' & [Auftrag] & ' ' & [Ort] & ' ' & [Objekt] AS AuftragKopf
FROM (tbl_VA_Auftragstamm RIGHT JOIN tbl_VA_Akt_Objekt_Kopf ON tbl_VA_Auftragstamm.ID = tbl_VA_Akt_Objekt_Kopf.VA_ID) LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Akt_Objekt_Kopf.VADatum_ID = tbl_VA_AnzTage.ID
ORDER BY tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag;

