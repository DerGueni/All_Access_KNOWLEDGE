SELECT [_tblAlleTage].dtDatum AS VADatum, tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VA_ID, tbl_VA_AnzTage.TVA_Soll, tbl_VA_AnzTage.TVA_Ist, tbl_VA_AnzTage.TVA_Offen, tbl_VA_AnzTage.PKW_Anzahl
FROM tbl_VA_AnzTage RIGHT JOIN _tblAlleTage ON tbl_VA_AnzTage.VADatum = [_tblAlleTage].dtDatum
WHERE ((([_tblAlleTage].dtDatum) Between #12/1/2015# And #12/31/2015#));

