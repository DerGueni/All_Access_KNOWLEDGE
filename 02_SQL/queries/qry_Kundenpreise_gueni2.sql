TRANSFORM Avg(tbl_KD_Standardpreise.StdPreis) AS MittelwertvonStdPreis
SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Firma, qry_KD_Kalkulation_Gueni.Kalk
FROM (tbl_KD_Artikelbeschreibung INNER JOIN (tbl_KD_Kundenstamm INNER JOIN tbl_KD_Standardpreise ON tbl_KD_Kundenstamm.[kun_Id] = tbl_KD_Standardpreise.[kun_ID]) ON tbl_KD_Artikelbeschreibung.ID = tbl_KD_Standardpreise.Preisart_ID) INNER JOIN qry_KD_Kalkulation_Gueni ON tbl_KD_Kundenstamm.kun_Id = qry_KD_Kalkulation_Gueni.kun_Id
WHERE (((tbl_KD_Kundenstamm.kun_IstAktiv)=True))
GROUP BY tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Firma, tbl_KD_Kundenstamm.kun_IstAktiv, qry_KD_Kalkulation_Gueni.Kalk
ORDER BY tbl_KD_Kundenstamm.kun_Firma
PIVOT tbl_KD_Artikelbeschreibung.Beschreibung;

