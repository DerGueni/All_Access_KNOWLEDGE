-- Query: qry_Ins_MA_NVerfuegZeiten
-- Type: 64
INSERT INTO tbl_MA_NVerfuegZeiten ( MA_ID, Zeittyp_ID, Bemerkung, vonDat, bisDat, Erst_von, Erst_am, Aend_von, Aend_am )
SELECT tbltmp_Fehlzeiten.MA_ID, tbltmp_Fehlzeiten.AbwesenArt, tbltmp_Fehlzeiten.Bemerk, tbltmp_Fehlzeiten.DatVon, tbltmp_Fehlzeiten.DatBis, atcnames(1) AS Ausdr1, Now() AS Ausdr3, atcnames(1) AS Ausdr2, Now() AS Ausdr4
FROM tbltmp_Fehlzeiten;

