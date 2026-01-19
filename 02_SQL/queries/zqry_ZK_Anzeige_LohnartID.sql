SELECT ztbl_ZK_Tage_Zeitraum.ZK_MA_ID, ztbl_ZK_Tage_Zeitraum.ZKDatum, zqry_ZK_Anzeige_prepare.*, zqry_ZK_Stunden_Kreuztab_ID_1.*
FROM (zqry_ZK_Anzeige_prepare RIGHT JOIN ztbl_ZK_Tage_Zeitraum ON (zqry_ZK_Anzeige_prepare.MA_ID = ztbl_ZK_Tage_Zeitraum.[ZK_MA_ID]) AND (zqry_ZK_Anzeige_prepare.VADatum = ztbl_ZK_Tage_Zeitraum.ZKDatum)) LEFT JOIN zqry_ZK_Stunden_Kreuztab_Lohnart_ID AS zqry_ZK_Stunden_Kreuztab_ID_1 ON zqry_ZK_Anzeige_prepare.Kreuz_KEY = zqry_ZK_Stunden_Kreuztab_ID_1.Kreuz_KEY
ORDER BY ztbl_ZK_Tage_Zeitraum.ZKDatum;

