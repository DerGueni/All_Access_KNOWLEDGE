-- Query: zqry_zk_Stunden_Nicht_Abgerechnet
-- Type: 0
SELECT zqry_ZUO_Stunden.ID, tbl_VA_Auftragstamm.Auftrag, zqry_ZUO_Stunden.MA_ID, zqry_ZUO_Stunden.jahr, zqry_ZUO_Stunden.monat, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende, zqry_ZUO_Stunden.stunden_brutto AS AnzStd, zqry_ZUO_Stunden.stunden_netto AS AnzStdNetto, zqry_ZUO_Stunden.VADatum
FROM ((zqry_ZUO_Stunden LEFT JOIN tbl_VA_Auftragstamm ON zqry_ZUO_Stunden.VA_ID = tbl_VA_Auftragstamm.ID) LEFT JOIN ztbl_ZK_Stunden ON (zqry_ZUO_Stunden.NV_ID = ztbl_ZK_Stunden.NV_ID) AND (zqry_ZUO_Stunden.Zuo_ID = ztbl_ZK_Stunden.ZUO_ID)) LEFT JOIN tbl_MA_VA_Zuordnung ON zqry_ZUO_Stunden.Zuo_ID = tbl_MA_VA_Zuordnung.ID
WHERE (((ztbl_ZK_Stunden.ID) Is Null))
ORDER BY zqry_ZUO_Stunden.VADatum;

