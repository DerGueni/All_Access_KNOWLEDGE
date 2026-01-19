SELECT qry_JB_MA_Jahr_tl2.MA_ID, qry_JB_MA_Jahr_tl2.AktJahr, 13 AS AktMon, Sum(qry_JB_MA_Jahr_tl2.Fahrtko) AS Fahrtko, Sum(qry_JB_MA_Jahr_tl2.RL_34a) AS RL_34a, qry_JB_MA_Jahr_tl2.RZ_34a, Sum(qry_JB_MA_Jahr_tl2.Abschlag) AS Abschlag, Sum(qry_JB_MA_Jahr_tl2.NichtDa) AS NichtDa, Sum(qry_JB_MA_Jahr_tl2.Kaution) AS Kaution, Sum(qry_JB_MA_Jahr_tl2.Sonstig) AS Sonstig, Max(qry_JB_MA_Jahr_tl2.SonstFuer) AS SonstFuer, Sum(qry_JB_MA_Jahr_tl2.RV) AS RV
FROM qry_JB_MA_Jahr_tl2
GROUP BY qry_JB_MA_Jahr_tl2.MA_ID, qry_JB_MA_Jahr_tl2.AktJahr, 13, qry_JB_MA_Jahr_tl2.RZ_34a;

