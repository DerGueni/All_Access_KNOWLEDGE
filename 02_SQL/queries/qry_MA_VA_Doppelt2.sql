SELECT qry_MA_VA_Doppelt1.MA_ID, qry_MA_VA_Doppelt1.VADatum, Count(qry_MA_VA_Doppelt1.MA_ID) AS AnzahlvonMA_ID
FROM qry_MA_VA_Doppelt1
GROUP BY qry_MA_VA_Doppelt1.MA_ID, qry_MA_VA_Doppelt1.VADatum
HAVING (((Count(qry_MA_VA_Doppelt1.MA_ID))>1));

