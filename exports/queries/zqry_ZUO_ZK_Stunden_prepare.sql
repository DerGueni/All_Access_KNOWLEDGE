-- Query: zqry_ZUO_ZK_Stunden_prepare
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.ID AS ZUO_ID, Stunden([ma_start],[ma_ende]) AS Stunden, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"NACHT_GESAMT") AS Nacht, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"Sonntag") AS Sonntag, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"SonntagNacht") AS SonntagNacht, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"Feiertag") AS Feiertag, Stunden_Zuschlag([vaDatum],[ma_Start],[ma_Ende],"FeiertagNacht") AS FeiertagNacht
FROM tbl_MA_VA_Zuordnung;

