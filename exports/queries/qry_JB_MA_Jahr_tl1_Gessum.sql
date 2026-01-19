-- Query: qry_JB_MA_Jahr_tl1_Gessum
-- Type: 0
SELECT qry_JB_MA_Jahr_tl1.MA_ID, qry_JB_MA_Jahr_tl1.AktJahr, 13 AS AktMon, Sum(qry_JB_MA_Jahr_tl1.[Ist]) AS Ist, Avg(qry_JB_MA_Jahr_tl1.RestAusVormonat) AS RestAusVormonat, Sum(qry_JB_MA_Jahr_tl1.IstGes) AS IstGes, Avg(qry_JB_MA_Jahr_tl1.UeberlaufAktMonat) AS UeberlaufAktMonat, Sum(qry_JB_MA_Jahr_tl1.HabVerr) AS HabVerr, Sum(qry_JB_MA_Jahr_tl1.InfBrutto) AS InfBrutto, Sum(qry_JB_MA_Jahr_tl1.Lst) AS Lst, Sum(qry_JB_MA_Jahr_tl1.InfNetto) AS InfNetto, Sum(qry_JB_MA_Jahr_tl1.InfGesamt) AS InfGesamt, Sum(qry_JB_MA_Jahr_tl1.Lohn) AS Lohn, Max(qry_JB_MA_Jahr_tl1.LohnVon) AS LohnVon, Avg(qry_JB_MA_Jahr_tl1.RestGut) AS RestGut
FROM qry_JB_MA_Jahr_tl1
GROUP BY qry_JB_MA_Jahr_tl1.MA_ID, qry_JB_MA_Jahr_tl1.AktJahr, 13;

