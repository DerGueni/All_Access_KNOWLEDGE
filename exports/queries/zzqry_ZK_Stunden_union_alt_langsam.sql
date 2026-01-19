-- Query: zzqry_ZK_Stunden_union_alt_langsam
-- Type: 0
SELECT zzqry_ZK_Stunden_Union.*, [ZUO_ID] & [NV_ID] & [Korr_ID] & [Lohnart_ID] AS Delta_KEY, [ZUO_ID] & [NV_ID] & [Korr_ID] AS Kreuz_KEY
FROM zzqry_ZK_Stunden_Union;

