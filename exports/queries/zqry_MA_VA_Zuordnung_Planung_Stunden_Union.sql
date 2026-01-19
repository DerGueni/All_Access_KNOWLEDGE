-- Query: zqry_MA_VA_Zuordnung_Planung_Stunden_Union
-- Type: 128
SELECT * FROM
qry_MA_VA_Zuordnung_Stunden_Monat
UNION SELECT * FROM
qry_MA_VA_Planung_Stunden_Monat;

