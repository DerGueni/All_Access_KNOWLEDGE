SELECT tbl_VA_AnzTage.VADatum AS Datum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, tbl_VA_AnzTage.TVA_Soll AS Anzahl
FROM (tbl_VA_Auftragstamm LEFT JOIN tbl_Veranst_Status ON tbl_VA_Auftragstamm.Veranst_Status_ID = tbl_Veranst_Status.ID) LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
WHERE (((tbl_VA_AnzTage.VADatum)>=#2/15/2022#) AND ((tbl_VA_AnzTage.TVA_Soll)>10) AND ((1)=1))
ORDER BY tbl_VA_AnzTage.VADatum;

