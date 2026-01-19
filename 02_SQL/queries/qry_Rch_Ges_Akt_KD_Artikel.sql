SELECT qry_Rch_Ges_Akt_KD.*, qry_Rch_StandardArtikel.Mengenheit, qry_Rch_StandardArtikel.Beschreibung
FROM qry_Rch_Ges_Akt_KD INNER JOIN qry_Rch_StandardArtikel ON qry_Rch_Ges_Akt_KD.PreisArt_ID = qry_Rch_StandardArtikel.ID
ORDER BY qry_Rch_Ges_Akt_KD.kun_ID, qry_Rch_Ges_Akt_KD.VADatum, qry_Rch_Ges_Akt_KD.MA_Start, qry_Rch_Ges_Akt_KD.MA_Ende, qry_Rch_Ges_Akt_KD.PreisArt_ID;

