-- Query: qry_N_Zeitkonflikte_Anzeige
-- Type: 0
SELECT m.Vorname & ' ' & m.Nachname AS Mitarbeiter, DateValue(z1.MVA_Start) AS Datum, a1.Auftrag AS Auftrag_1, Format(z1.MVA_Start,'Short Time') & '-' & Format(z1.MVA_Ende,'Short Time') AS Zeit_1, a2.Auftrag AS Auftrag_2, Format(z2.MVA_Start,'Short Time') & '-' & Format(z2.MVA_Ende,'Short Time') AS Zeit_2, IIf(z1.VA_ID=z2.VA_ID,'DUPLIKAT','KONFLIKT') AS Typ
FROM (((tbl_MA_VA_Zuordnung AS z1 INNER JOIN tbl_MA_VA_Zuordnung AS z2 ON z1.MA_ID = z2.MA_ID) INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON z1.MA_ID = m.ID) LEFT JOIN tbl_VA_Auftragstamm AS a1 ON z1.VA_ID = a1.ID) LEFT JOIN tbl_VA_Auftragstamm AS a2 ON z2.VA_ID = a2.ID
WHERE (((z1.ID)<[z2].[ID]) AND ((DateValue([z1].[MVA_Start]))=DateValue([z2].[MVA_Start]) And (DateValue([z1].[MVA_Start]))>=Date()) AND ((z1.MVA_Start)<[z2].[MVA_Ende]) AND ((z1.MVA_Ende)>[z2].[MVA_Start]) AND ((m.Anstellungsart_ID) In (3,5)))
ORDER BY DateValue(z1.MVA_Start);

