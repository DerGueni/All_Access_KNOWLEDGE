-- Query: zqry_ZK_Stunden_Kreuztab_Lohnart_ID
-- Type: 16
TRANSFORM First(zqry_ZK_Stunden.Lohnart_ID) AS ErsterWertvonLohnart_ID
SELECT zqry_ZK_Stunden.Kreuz_KEY
FROM zqry_ZK_Stunden INNER JOIN zqry_ZK_Lohnarten_Zuschlag ON zqry_ZK_Stunden.Lohnart_ID = zqry_ZK_Lohnarten_Zuschlag.ID
GROUP BY zqry_ZK_Stunden.Kreuz_KEY
PIVOT zqry_ZK_Lohnarten_Zuschlag.Bezeichnung_kurz;

