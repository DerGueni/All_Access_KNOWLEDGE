-- Query: zqry_MA_Stunden_Differenz_prepare
-- Type: 0
SELECT zqry_MA_Stunden_Abgleich.*, fSumme_Std_Consys([ID],[Jahr],[Monat]) AS Stunden_Consys, fSumme_std_ges([LEXWare_ID],[Jahr],[Monat]) AS Stunden_ZK_ges, fSumme_std_abger([LEXWare_ID],[Jahr],[Monat]) AS Stunden_ZK_abger, -fZKausgezahlt([LEXWare_ID],[Jahr],[Monat]) AS Overload
FROM zqry_MA_Stunden_Abgleich;

