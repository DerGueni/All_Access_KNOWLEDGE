INSERT INTO tbl_Rch_Pos_Auftrag ( VorlageNr, kun_ID, VA_ID, VAStart_ID, VADatum, MA_Start, MA_Ende, Menge, EzPreis, Mengenheit, MwSt, Beschreibung, PreisArt_ID, GesPreis, Rch_ID, Anz_MA )
SELECT tbltmp_Pos_Bericht.VorlageNr, tbltmp_Pos_Bericht.kun_ID, tbltmp_Pos_Bericht.VA_ID, tbltmp_Pos_Bericht.VAStart_ID, tbltmp_Pos_Bericht.VADatum, tbltmp_Pos_Bericht.MA_Start, tbltmp_Pos_Bericht.MA_Ende, tbltmp_Pos_Bericht.Menge, tbltmp_Pos_Bericht.EzPreis, tbltmp_Pos_Bericht.Mengenheit, tbltmp_Pos_Bericht.MwSt, tbltmp_Pos_Bericht.Beschreibung, tbltmp_Pos_Bericht.PreisArt_ID, tbltmp_Pos_Bericht.GesPreis, tbltmp_Pos_Bericht.Rch_ID, tbltmp_Pos_Bericht.Anz_MA
FROM tbltmp_Pos_Bericht;

