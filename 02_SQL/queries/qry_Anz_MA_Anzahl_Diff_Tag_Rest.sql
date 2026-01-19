SELECT qry_Anz_MA_Anzahl_Diff_Tag.VA_ID, qry_Anz_MA_Anzahl_Diff_Tag.VADatum, qry_Anz_MA_Anzahl_Diff_Tag.VADatum_ID, qry_Anz_MA_Anzahl_Diff_Tag.AnzMA_Z, qry_Anz_MA_Anzahl_Diff_Tag.PosNrMax, [MA_Diff]-Nz([SummevonDiff_MA],0) AS Diff
FROM qry_Anz_MA_Anzahl_Diff_Tag LEFT JOIN qry_Anz_MA_Anzahl_Diff_Zwi ON (qry_Anz_MA_Anzahl_Diff_Tag.VADatum_ID = qry_Anz_MA_Anzahl_Diff_Zwi.VADatum_ID) AND (qry_Anz_MA_Anzahl_Diff_Tag.VA_ID = qry_Anz_MA_Anzahl_Diff_Zwi.VA_ID)
WHERE ((([MA_Diff]-Nz([SummevonDiff_MA],0))>0));

