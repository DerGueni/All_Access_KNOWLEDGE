INSERT INTO tbltmp_Position ( Menge, EzPreis, ME, MwStSatz, Art_Beschreibung, Int_ArtNr, GesPreis, Anz_MA )
SELECT Sum(tbltmp_Pos_Bericht.Menge) AS SummevonMenge, tbltmp_Pos_Bericht.EzPreis, tbltmp_Pos_Bericht.Mengenheit, tbltmp_Pos_Bericht.MwSt, tbltmp_Pos_Bericht.Beschreibung, tbltmp_Pos_Bericht.PreisArt_ID, Sum(tbltmp_Pos_Bericht.GesPreis) AS SummevonGesPreis, Sum(tbltmp_Pos_Bericht.Anz_MA) AS SummevonAnz_MA
FROM tbltmp_Pos_Bericht
GROUP BY tbltmp_Pos_Bericht.EzPreis, tbltmp_Pos_Bericht.Mengenheit, tbltmp_Pos_Bericht.MwSt, tbltmp_Pos_Bericht.Beschreibung, tbltmp_Pos_Bericht.PreisArt_ID
ORDER BY tbltmp_Pos_Bericht.PreisArt_ID;

