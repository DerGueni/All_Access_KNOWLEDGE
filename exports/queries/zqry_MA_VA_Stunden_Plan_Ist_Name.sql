-- Query: zqry_MA_VA_Stunden_Plan_Ist_Name
-- Type: 16
TRANSFORM Format(Sum([Stunden_Netto] * 0.91), "0.00") AS Stunden
SELECT zqry_MA_VA_Stunden_Plan_Ist.Name, zqry_MA_VA_Stunden_Plan_Ist.Anstellungsart_ID, Format(Sum([Stunden_Netto] * 0.91), "0.00") AS Gesamtsumme
FROM zqry_MA_VA_Stunden_Plan_Ist
WHERE zqry_MA_VA_Stunden_Plan_Ist.Anstellungsart_ID IN (3, 5)
GROUP BY zqry_MA_VA_Stunden_Plan_Ist.Name, zqry_MA_VA_Stunden_Plan_Ist.Anstellungsart_ID
PIVOT Choose([Monat], "Jan", "Feb", "Mrz", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez") 
IN 
    ("Jan", "Feb", "Mrz", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez");

