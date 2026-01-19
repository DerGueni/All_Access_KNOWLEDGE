-- Query: zqry_MA_Stunden_Abgleich_tmp
-- Type: 0
SELECT *
FROM zqry_MA_Stunden_Abgleich
WHERE Anstellungsart_ID = 5 AND Datum BETWEEN #2025-10-01# AND #2025-10-31#;

