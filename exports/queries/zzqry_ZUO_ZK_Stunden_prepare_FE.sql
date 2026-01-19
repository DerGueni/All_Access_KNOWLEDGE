-- Query: zzqry_ZUO_ZK_Stunden_prepare_FE
-- Type: 0
SELECT ztbl_MA_VA_Zuordnung_FE.ID AS ZID, Stunden([ma_start],[ma_ende]) AS Stunden, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"NACHT_GESAMT") AS Nacht, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"Sonntag") AS Sonntag, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"SonntagNacht") AS SonntagNacht, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"Feiertag") AS Feiertag, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"FeiertagNacht") AS FeiertagNacht
FROM ztbl_MA_VA_Zuordnung_FE
WHERE (((ztbl_MA_VA_Zuordnung_FE.MA_ID)<>0));

