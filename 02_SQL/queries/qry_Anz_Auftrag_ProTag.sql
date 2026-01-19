SELECT tbl_VA_AnzTage.VADatum, Count(tbl_VA_AnzTage.VADatum) AS AnzTag
FROM tbl_VA_AnzTage
GROUP BY tbl_VA_AnzTage.VADatum;

