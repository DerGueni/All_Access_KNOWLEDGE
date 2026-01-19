-- Query: qry_Rch_Ges_Akt_KD
-- Type: 128
SELECT qry_Rch_PKW_Alle_Zeitraum_Akt_KD.* FROM qry_Rch_PKW_Alle_Zeitraum_Akt_KD
UNION SELECT qry_Rch_VA_Alle_Zeitraum_Akt_KD.* FROM qry_Rch_VA_Alle_Zeitraum_Akt_KD;

