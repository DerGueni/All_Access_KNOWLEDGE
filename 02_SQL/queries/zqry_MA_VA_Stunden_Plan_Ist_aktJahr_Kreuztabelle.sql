TRANSFORM Format(Sum([Stunden_Netto]*0.91),"Fixed") AS Stunden
SELECT qry_MA_VA_Stunden_Plan_Ist.Name AS Ausdr1, qry_MA_VA_Stunden_Plan_Ist.Anstellungsart_ID AS Ausdr2, Format(Sum([Stunden_Netto]*0.91),"Fixed") AS Gesamtsumme
FROM qry_MA_VA_Stunden_Plan_Ist
WHERE ((([qry_MA_VA_Stunden_Plan_Ist].[Anstellungsart_ID]) In (3,5)))
GROUP BY qry_MA_VA_Stunden_Plan_Ist.Name, qry_MA_VA_Stunden_Plan_Ist.Anstellungsart_ID
PIVOT Choose([Monat],"Jan","Feb","Mrz","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez");

