SELECT [_tblAlleTage].dtDatum
FROM qry_JB_MA_AktMon INNER JOIN _tblAlleTage ON (qry_JB_MA_AktMon.AktMon = [_tblAlleTage].MonatNr) AND (qry_JB_MA_AktMon.AktJahr = [_tblAlleTage].JahrNr);

