-- Query: qry_Auftrag_Rechnung_Gueni
-- Type: 0
SELECT DISTINCT First(tbl_MA_VA_Zuordnung.VADatum) AS ErsterWertvonVADatum, tbl_MA_VA_Zuordnung.MA_ID, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, Sum(tbl_MA_VA_Zuordnung.MA_Brutto_Std2) AS SummevonMA_Brutto_Std2, tbl_Rch_Kopf.RchNr_Ext, First(tbl_Rch_Kopf.IstBezahlt) AS ErsterWertvonIstBezahlt, tbl_Rch_Kopf.Aend_von, tbl_Rch_Kopf.Zahlung_am, tbl_MA_VA_Zuordnung.VA_ID, tbl_Rch_Kopf.ID AS Rch_ID, tbl_Rch_Kopf.Rch_Status_ID, tbl_Rch_Kopf.Aend_am, tbl_Rch_Status.Status, tbl_Rch_Kopf.Gesamtsumme1
FROM ((tbl_MA_VA_Zuordnung LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID) LEFT JOIN tbl_Rch_Kopf ON (tbl_MA_VA_Zuordnung.MA_ID = tbl_Rch_Kopf.MA_ID) AND (tbl_MA_VA_Zuordnung.VA_ID = tbl_Rch_Kopf.VA_ID)) LEFT JOIN tbl_Rch_Status ON tbl_Rch_Kopf.Rch_Status_ID = tbl_Rch_Status.ID
GROUP BY tbl_MA_VA_Zuordnung.MA_ID, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, tbl_Rch_Kopf.RchNr_Ext, tbl_Rch_Kopf.Aend_von, tbl_Rch_Kopf.Zahlung_am, tbl_MA_VA_Zuordnung.VA_ID, tbl_Rch_Kopf.ID, tbl_Rch_Kopf.Rch_Status_ID, tbl_Rch_Kopf.Aend_am, tbl_Rch_Status.Status, tbl_Rch_Kopf.Gesamtsumme1
ORDER BY First(tbl_MA_VA_Zuordnung.VADatum);

