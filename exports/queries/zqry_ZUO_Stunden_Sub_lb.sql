-- Query: zqry_ZUO_Stunden_Sub_lb
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.ID AS ZUO_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.MA_Start AS von, tbl_MA_VA_Zuordnung.MA_Ende AS bis, Stunden([MA_Start],[MA_Ende]) AS Stunden, Stunden_Zuschlag([VADatum],[MA_Start],[MA_Ende],"Nacht") AS Nacht, Stunden_Zuschlag([VADatum],[MA_Start],[MA_Ende],"Sonntag")+Stunden_Zuschlag([VADatum],[MA_Start],[MA_Ende],"SonntagNacht") AS Sonntag, Stunden_Zuschlag([VADatum],[MA_Start],[MA_Ende],"Feiertag")+Stunden_Zuschlag([VADatum],[MA_Start],[MA_Ende],"FeiertagNacht") AS Feiertag, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.Bemerkungen AS Name, tbl_MA_VA_Zuordnung.PKW
FROM tbl_MA_VA_Zuordnung
ORDER BY tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.MA_Start;

