-- Query: qry_Rch_Insert_VA_Kopf
-- Type: 64
INSERT INTO tbl_Rch_VA_Kopf ( kun_ID, VA_ID, VorlageNr, Rch_ID, Ges_Netto, rch_Dat )
SELECT tbltmp_Pos_Bericht.kun_ID, tbltmp_Pos_Bericht.VA_ID, tbltmp_Pos_Bericht.VorlageNr, tbltmp_Pos_Bericht.Rch_ID, Sum(tbltmp_Pos_Bericht.GesPreis) AS SummevonGesPreis, Date() AS Ausdr1
FROM tbltmp_Pos_Bericht
GROUP BY tbltmp_Pos_Bericht.kun_ID, tbltmp_Pos_Bericht.VA_ID, tbltmp_Pos_Bericht.VorlageNr, tbltmp_Pos_Bericht.Rch_ID, Date();

