-- Query: zqry_MA_Stunden_Abgleich
-- Type: 0
SELECT zqry_MA_Stunden.Jahr, zqry_MA_Stunden.Monat, zqry_MA_Stunden.ID, zqry_MA_Stunden.LEXWare_ID, zqry_MA_Stunden.Name, Sum(zqry_MA_Stunden.Wert) AS SummevonWert, zqry_MA_Stunden.Anstellungsart_ID, zqry_MA_Stunden.Datum, fSumme_Std_abger([LEXWare_ID],[Jahr],[Monat]) AS Stunden_ZK_abger, fSumme_Std_Consys([ID],[Jahr],[Monat]) AS Stunden_Consys, fSumme_std_ges([LEXWare_ID],[Jahr],[Monat]) AS Stunden_ZK_ges, Round([Stunden_ZK_abger]-[Stunden_ZK_ges],2) AS Differenz, -fZKausgezahlt([LEXWare_ID],[Jahr],[Monat]) AS ausgezahlt
FROM zqry_MA_Stunden
GROUP BY zqry_MA_Stunden.Jahr, zqry_MA_Stunden.Monat, zqry_MA_Stunden.ID, zqry_MA_Stunden.LEXWare_ID, zqry_MA_Stunden.Name, zqry_MA_Stunden.Anstellungsart_ID, zqry_MA_Stunden.Datum
ORDER BY zqry_MA_Stunden.Name;

