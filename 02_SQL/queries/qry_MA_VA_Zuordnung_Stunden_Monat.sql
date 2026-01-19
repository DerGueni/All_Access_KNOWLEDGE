SELECT tbl_MA_VA_Zuordnung.MA_ID, Year([MVA_Start]) AS Jahr, Month([Mva_start]) AS Monat, Sum(tbl_MA_VA_Zuordnung.MA_Brutto_Std2) AS SummevonMA_Brutto_Std2, Sum(tbl_MA_VA_Zuordnung.MA_Netto_Std2) AS SummevonMA_Netto_Std2, "IST" AS Art
FROM tbl_MA_VA_Zuordnung
GROUP BY tbl_MA_VA_Zuordnung.MA_ID, Year([MVA_Start]), Month([Mva_start]), "IST"
HAVING (((Year([MVA_Start])) Is Not Null));

