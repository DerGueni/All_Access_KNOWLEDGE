-- Query: qry_tbl_MA_VA_Zuordnung_Sum
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.VA_ID, Sum(tbl_MA_VA_Zuordnung.MA_Brutto_Std) AS MA_Brutto_Std, Sum(tbl_MA_VA_Zuordnung.MA_Netto_Std) AS MA_Netto_Std, Sum(tbl_MA_VA_Zuordnung.PKW) AS FahrtKo
FROM tbl_MA_VA_Zuordnung
GROUP BY tbl_MA_VA_Zuordnung.VA_ID;

