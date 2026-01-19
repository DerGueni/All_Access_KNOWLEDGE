-- Query: qry_Rch_Insert_Pos_Geschrieben
-- Type: 64
INSERT INTO tbl_Rch_Pos_Geschrieben ( VorlageNr, kun_ID, MA_ID, PosNr, Int_ArtNr, Art_Beschreibung, Menge, ME, MwStSatz, EZPreis, GesPreis, Rch_ID )
SELECT tbltmp_Position.VorlageNr, tbltmp_Position.kun_ID, tbltmp_Position.MA_ID, tbltmp_Position.PosNr, tbltmp_Position.Int_ArtNr, tbltmp_Position.Art_Beschreibung, tbltmp_Position.Menge, tbltmp_Position.ME, tbltmp_Position.MwStSatz, tbltmp_Position.EZPreis, tbltmp_Position.GesPreis, tbltmp_Position.Rch_ID
FROM tbltmp_Position;

