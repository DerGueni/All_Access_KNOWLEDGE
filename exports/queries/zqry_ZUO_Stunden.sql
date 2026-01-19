-- Query: zqry_ZUO_Stunden
-- Type: 0
SELECT ztbl_ZUO_Stunden.*, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VADatum, Year([VADatum]) AS Jahr, Month([VADatum]) AS Monat
FROM tbl_MA_VA_Zuordnung INNER JOIN ztbl_ZUO_Stunden ON tbl_MA_VA_Zuordnung.ID = ztbl_ZUO_Stunden.Zuo_ID;

