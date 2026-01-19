-- Query: qry_VA_AlleTage_Min
-- Type: 0
SELECT Min(tbl_VA_AnzTage.VADatum) AS VADatum
FROM tbl_VA_AnzTage
WHERE (((tbl_VA_AnzTage.TVA_Offen)=True));

