-- Query: zqry_MA_Stunden_Differenz
-- Type: 0
SELECT zqry_MA_Stunden_Abgleich.*
FROM zqry_MA_Stunden_Abgleich
WHERE Anstellungsart_ID = 5 AND Datum BETWEEN #2024-10-01# AND #2024-10-31#;

