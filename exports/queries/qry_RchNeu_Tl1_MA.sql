-- Query: qry_RchNeu_Tl1_MA
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_VA_Auftragstamm.Veranstalter_ID AS kun_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, tbl_MA_VA_Zuordnung.PreisArt_ID, Count(tbl_MA_VA_Zuordnung.MA_ID) AS MA_Anz, Sum(tbl_MA_VA_Zuordnung.MA_Brutto_Std) AS MA_Std, Count(tbl_MA_VA_Zuordnung.PKW) AS Anz_PKW, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VAStart_ID
FROM tbl_VA_Start INNER JOIN (tbl_MA_VA_Zuordnung INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID) ON tbl_VA_Start.ID = tbl_MA_VA_Zuordnung.VAStart_ID
WHERE (((tbl_VA_Auftragstamm.Veranst_Status_ID)=3) AND ((tbl_VA_Auftragstamm.Dat_VA_Bis)<Date()))
GROUP BY tbl_MA_VA_Zuordnung.VA_ID, tbl_VA_Auftragstamm.Veranstalter_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, tbl_MA_VA_Zuordnung.PreisArt_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VAStart_ID
HAVING (((Count(tbl_MA_VA_Zuordnung.MA_ID))>0) AND ((Sum(tbl_MA_VA_Zuordnung.MA_Brutto_Std))>0));

