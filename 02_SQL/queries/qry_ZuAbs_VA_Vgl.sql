SELECT 0 as ID1, #1/1/1980# AS ID2 ,"  Alle" as Alle FROM _tblInternalSystemFE UNION SELECT tbl_VA_Auftragstamm.ID, VADatum, [VADatum] & " - " & [Auftrag] & " / " & [Objekt] & " / " & [Ort] AS Einsatz FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID WHERE VADatum >= Date()
ORDER BY ID2;

