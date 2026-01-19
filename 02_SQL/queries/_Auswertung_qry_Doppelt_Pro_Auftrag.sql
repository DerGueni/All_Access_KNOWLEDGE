SELECT qry_MA_VA_Doppelt1.VA_ID, qry_MA_VA_Doppelt1.Auftrag, qry_MA_VA_Doppelt1.Objekt, qry_MA_VA_Doppelt1.Ort, qry_MA_VA_Doppelt1.kun_Firma, qry_MA_VA_Doppelt1.VADatum, qry_MA_VA_Doppelt1.MA_ID, qry_MA_VA_Doppelt1.Nachname, qry_MA_VA_Doppelt1.Vorname, Count(qry_MA_VA_Doppelt1.MA_ID) AS Anzahl
FROM qry_MA_VA_Doppelt1
GROUP BY qry_MA_VA_Doppelt1.VA_ID, qry_MA_VA_Doppelt1.Auftrag, qry_MA_VA_Doppelt1.Objekt, qry_MA_VA_Doppelt1.Ort, qry_MA_VA_Doppelt1.kun_Firma, qry_MA_VA_Doppelt1.VADatum, qry_MA_VA_Doppelt1.MA_ID, qry_MA_VA_Doppelt1.Nachname, qry_MA_VA_Doppelt1.Vorname
HAVING (((qry_MA_VA_Doppelt1.VADatum)>Date()) AND ((Count(qry_MA_VA_Doppelt1.MA_ID))>1));

