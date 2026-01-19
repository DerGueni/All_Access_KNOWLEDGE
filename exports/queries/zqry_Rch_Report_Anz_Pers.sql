-- Query: zqry_Rch_Report_Anz_Pers
-- Type: 0
SELECT tbl_VA_Start.ID, Count(tbl_VA_Start.ID) AS AnzPers, f_get_rch_std([ID],"Sicherheitspersonal") AS StdSich, f_get_rch_std([ID],"Leitungspersonal") AS StdLeit, f_get_rch_std([ID],"Bereichsleitung") AS StdBl, f_get_rch_std([ID],"Nacht") AS StdNacht, f_get_rch_std([ID],"Sonntag") AS StdSonn, f_get_rch_std([ID],"Feiertag") AS StdFeier
FROM tbl_VA_Start
GROUP BY tbl_VA_Start.ID, f_get_rch_std([ID],"Sicherheitspersonal"), f_get_rch_std([ID],"Leitungspersonal"), f_get_rch_std([ID],"Bereichsleitung"), f_get_rch_std([ID],"Nacht"), f_get_rch_std([ID],"Sonntag"), f_get_rch_std([ID],"Feiertag");

