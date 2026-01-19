-- Query: zqry_MA_VA_Stunden_Plan_Ist_aktJahr_Kreuztabelle
-- Type: 16
TRANSFORM Sum(zqry_MA_VA_Stunden_Plan_Ist.Stunden_Netto) AS SummevonStunden_Netto
SELECT zqry_MA_VA_Stunden_Plan_Ist.Name, zqry_MA_VA_Stunden_Plan_Ist.Anstellungsart_ID, Sum(zqry_MA_VA_Stunden_Plan_Ist.Stunden_Netto) AS [Gesamtsumme von Stunden_Netto]
FROM zqry_MA_VA_Stunden_Plan_Ist
GROUP BY zqry_MA_VA_Stunden_Plan_Ist.Name, zqry_MA_VA_Stunden_Plan_Ist.Art, zqry_MA_VA_Stunden_Plan_Ist.Anstellungsart_ID
PIVOT zqry_MA_VA_Stunden_Plan_Ist.Monat;

