-- Query: qry_Anz_MA_Tag_1
-- Type: 0
SELECT DISTINCT qry_Anz_MA_Hour.VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, [Objekt] & " - " & [Ort] AS Objekt_Ort, qry_Anz_MA_Hour.MA_Plan AS MA_Plan_Ges, qry_Anz_MA_Hour.MA_Soll AS MA_Soll_Ges, qry_Anz_MA_Hour.MA_Ist AS MA_Ist_Ges, tbl_VA_AnzTage.TVA_Offen
FROM tbl_VA_AnzTage RIGHT JOIN (qry_Anz_MA_Hour RIGHT JOIN tbl_VA_Auftragstamm ON qry_Anz_MA_Hour.VA_ID = tbl_VA_Auftragstamm.ID) ON tbl_VA_AnzTage.VA_ID = tbl_VA_Auftragstamm.ID;

