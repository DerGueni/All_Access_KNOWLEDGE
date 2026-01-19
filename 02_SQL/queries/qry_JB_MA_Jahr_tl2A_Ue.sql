SELECT qry_JB_MA_Jahr_tl2A.MA_ID, qry_JB_MA_Jahr_tl2A.AktJahr, qry_JB_MA_Jahr_tl2A.AktMon, [_tblAlleMonate].MonKurz AS Monat, qry_JB_MA_Jahr_tl2A.fahrtko AS Fahrtkosten, qry_JB_MA_Jahr_tl2A.rl_34a AS RL34a, ([RZ_34a]) AS Rückzahlung, qry_JB_MA_Jahr_tl2A.Abschlag, ([NichtDa]) AS Fernbleiben, qry_JB_MA_Jahr_tl2A.Kaution, ([Sonstig]) AS Sonstiges, ([SonstFuer]) AS Grund, ([RV]) AS [RV freiw]
FROM _tblAlleMonate INNER JOIN qry_JB_MA_Jahr_tl2A ON [_tblAlleMonate].MonNr = qry_JB_MA_Jahr_tl2A.AktMon;

