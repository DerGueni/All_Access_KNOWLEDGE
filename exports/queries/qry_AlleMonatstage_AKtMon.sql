-- Query: qry_AlleMonatstage_AKtMon
-- Type: 0
SELECT [_tblAlleTage].TagNr, [_tblAlleTage].dtDatum
FROM _tblAlleTage
WHERE (([_tblAlleTage].JahrNr= 2022) AND ([_tblAlleTage].MonatNr= 10));

