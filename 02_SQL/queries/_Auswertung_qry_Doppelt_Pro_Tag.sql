SELECT qry_MA_VA_Doppelt1.*, qry_MA_VA_Doppelt2.AnzahlvonMA_ID AS Anzahl
FROM qry_MA_VA_Doppelt2 INNER JOIN qry_MA_VA_Doppelt1 ON (qry_MA_VA_Doppelt2.MA_ID = qry_MA_VA_Doppelt1.MA_ID) AND (qry_MA_VA_Doppelt2.VADatum = qry_MA_VA_Doppelt1.VADatum)
ORDER BY qry_MA_VA_Doppelt1.VADatum, qry_MA_VA_Doppelt1.MA_ID;

