TRANSFORM Sum(zqry_ZK_Stunden.Anz_Std) AS SummevonAnz_Std
SELECT zqry_ZK_Stunden.Kreuz_KEY
FROM zqry_ZK_Stunden
GROUP BY zqry_ZK_Stunden.Kreuz_KEY
PIVOT zqry_ZK_Stunden.Lohnart_ID;

