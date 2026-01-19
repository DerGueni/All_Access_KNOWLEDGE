-- Query: qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Netto
-- Type: 0
SELECT tbl_Rch_Kopf.kun_ID, tbl_Rch_Kopf.RchDatum AS VADatum, tbl_Rch_Kopf.Zwi_Sum1 AS NettoBetrag, tbl_Rch_Kopf.IstBezahlt, tbl_Rch_Kopf.M1IstGemahnt1, tbl_Rch_Kopf.M2IstGemahnt1, tbl_Rch_Kopf.M3IstGemahnt1
FROM tbl_Rch_Kopf
WHERE (((tbl_Rch_Kopf.RchTyp)=4 Or (tbl_Rch_Kopf.RchTyp)=12));

