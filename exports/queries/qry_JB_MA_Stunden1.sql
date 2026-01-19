-- Query: qry_JB_MA_Stunden1
-- Type: 0
SELECT Year([VADatum]) AS AktJahr, Month([VADatum]) AS AktMonat, tbl_MA_VA_Zuordnung.*
FROM tbl_MA_VA_Zuordnung;

