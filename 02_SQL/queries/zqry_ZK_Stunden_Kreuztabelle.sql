TRANSFORM Sum(zqry_ZK_Stunden.Anz_Std) AS SummevonAnz_Std
SELECT zqry_ZK_Stunden.Kreuz_KEY
FROM zqry_ZK_Stunden INNER JOIN zqry_ZK_Lohnarten_Zuschlag ON zqry_ZK_Stunden.Lohnart_ID = zqry_ZK_Lohnarten_Zuschlag.ID
WHERE (((zqry_ZK_Lohnarten_Zuschlag.Ist_Zeit)=True))
GROUP BY zqry_ZK_Stunden.Kreuz_KEY, zqry_ZK_Lohnarten_Zuschlag.Ist_Zeit
PIVOT zqry_ZK_Lohnarten_Zuschlag.Bezeichnung_kurz;

