-- Query: qry_Rch_Alle_VA_Akt_KD_Auftrag_Ins_tmp
-- Type: 80
SELECT qry_Rch_Ges.VA_ID, qry_Rch_Ges.VADatum, qry_Rch_Ges.Menge, qry_Rch_StandardArtikel.Mengenheit, qry_Rch_StandardArtikel.MwSt_Satz, qry_Rch_StandardArtikel.StdPreis, qry_Rch_StandardArtikel.Beschreibung, qry_Rch_Ges.PreisArt_ID INTO tbltmp_Pos_Bericht
FROM qry_Rch_Ges INNER JOIN qry_Rch_StandardArtikel ON (qry_Rch_Ges.kun_ID = qry_Rch_StandardArtikel.kun_ID) AND (qry_Rch_Ges.PreisArt_ID = qry_Rch_StandardArtikel.ID)
ORDER BY qry_Rch_Ges.VA_ID, qry_Rch_Ges.VADatum, qry_Rch_Ges.PreisArt_ID;

