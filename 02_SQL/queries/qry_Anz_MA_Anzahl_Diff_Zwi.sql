SELECT qry_Anz_MA_Anzahl_Diff.VA_ID, qry_Anz_MA_Anzahl_Diff.VADatum, qry_Anz_MA_Anzahl_Diff.VADatum_ID, Sum(qry_Anz_MA_Anzahl_Diff.Diff_MA) AS SummevonDiff_MA
FROM qry_Anz_MA_Anzahl_Diff
GROUP BY qry_Anz_MA_Anzahl_Diff.VA_ID, qry_Anz_MA_Anzahl_Diff.VADatum, qry_Anz_MA_Anzahl_Diff.VADatum_ID;

