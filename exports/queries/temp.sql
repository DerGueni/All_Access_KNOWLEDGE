-- Query: temp
-- Type: 0
SELECT Jahr, Monat, LEXWare_ID, Lohnartnummer, Wert_korr, Stundensatz, Währung, Name
FROM zqry_MA_Stunden
WHERE Anstellungsart_ID = 5 AND Datum BETWEEN #2024-12-01# AND #2024-12-31#;

