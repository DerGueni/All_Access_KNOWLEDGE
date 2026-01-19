SELECT [_tblAlleTage].dtDatum
FROM _tblAlleTage
WHERE ((([_tblAlleTage].JahrNr)=Get_Priv_Property("prp_AktMonUeb_Jahr")) AND (([_tblAlleTage].MonatNr)=Get_Priv_Property("prp_AktMonUeb_Monat")));

