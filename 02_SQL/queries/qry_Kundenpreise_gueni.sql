TRANSFORM Avg(tbl_KD_Standardpreise.StdPreis) AS MittelwertvonStdPreis
SELECT tbl_KD_Kundenstamm.kun_Firma, tbl_KD_Kundenstamm.kun_Id
FROM tbl_KD_Artikelbeschreibung INNER JOIN (tbl_KD_Kundenstamm INNER JOIN tbl_KD_Standardpreise ON tbl_KD_Kundenstamm.[kun_Id] = tbl_KD_Standardpreise.[kun_ID]) ON tbl_KD_Artikelbeschreibung.ID = tbl_KD_Standardpreise.Preisart_ID
GROUP BY tbl_KD_Kundenstamm.kun_Firma, tbl_KD_Kundenstamm.kun_Id
ORDER BY tbl_KD_Kundenstamm.kun_Firma
PIVOT tbl_KD_Artikelbeschreibung.Beschreibung;

