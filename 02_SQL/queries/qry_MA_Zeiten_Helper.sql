SELECT k.ID AS Kopf_ID, z.MA_ID, Format(z.MVA_Start,'hh:nn') AS von, Format(z.MVA_Ende,'hh:nn') AS bis
FROM tbl_VA_Akt_Objekt_Kopf AS k INNER JOIN tbl_MA_VA_Zuordnung AS z ON (k.VADatum_ID = z.VADatum_ID) AND (k.VA_ID = z.VA_ID)
WHERE z.MA_ID > 0;

