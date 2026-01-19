-- Query: qry_Linnert
-- Type: 0
SELECT tbl_VA_Start.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt, Sum(tbl_VA_Start.MA_Anzahl) AS SummevonMA_Anzahl
FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_Start ON tbl_VA_Auftragstamm.[ID] = tbl_VA_Start.[VA_ID]
GROUP BY tbl_VA_Start.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt, tbl_VA_Start.VA_ID, tbl_VA_Auftragstamm.Dat_VA_Von
HAVING (((tbl_VA_Start.VADatum)>Date()))
ORDER BY tbl_VA_Start.VADatum;

