-- Query: zzqry_ZK_Stunden_Union
-- Type: 128
select * from zqry_ZUO_ZK_Stunden_Normal_FE
union
select * from zqry_ZUO_ZK_Stunden_Nacht_FE
union
select * from zqry_ZUO_ZK_Stunden_Sonntag_FE
union
select * from zqry_ZUO_ZK_Stunden_SonntagNacht_FE
union
select * from zqry_ZUO_ZK_Stunden_Feiertag_FE
union
select * from zqry_ZUO_ZK_Stunden_FeiertagNacht_FE
union
select * from zqry_ZUO_ZK_NV_Urlaub_FE
union
select * from zqry_ZUO_ZK_NV_Krank_FE
union
select * from zqry_ZUO_ZK_Intern_FE
UNION select * from zqry_ZUO_ZK_Korrekturen_FE;

