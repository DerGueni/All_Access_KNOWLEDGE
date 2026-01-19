-- Query: qry_MA_VA_Planung_Stunden_Monat
-- Type: 0
SELECT tbl_MA_VA_Planung.MA_ID, Year([MVA_Start]) AS Jahr, Month([Mva_start]) AS Monat, Sum(tbl_MA_VA_Planung.MA_Brutto_Std2) AS SummevonMA_Brutto_Std2, Sum(tbl_MA_VA_Planung.MA_Netto_Std2) AS SummevonMA_Netto_Std2, "PLAN" AS Art
FROM tbl_MA_VA_Planung
GROUP BY tbl_MA_VA_Planung.MA_ID, Year([MVA_Start]), Month([Mva_start]), "PLAN"
HAVING (((tbl_MA_VA_Planung.MA_ID) Is Not Null) AND ((Year([MVA_Start])) Is Not Null));

