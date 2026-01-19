INSERT INTO tbltmp_VA_Tag_All ( VA_ID, VADatum_ID, VADatum, Auftrag, Objekt, MA_Plan_Ges, MA_Soll_Ges, MA_Ist_Ges )
SELECT qry_Anz_MA_Tag.VA_ID, qry_Anz_MA_Tag.VADatum_ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, qry_Anz_MA_Tag.MA_Plan_Ges, qry_Anz_MA_Tag.MA_Soll_Ges, qry_Anz_MA_Tag.MA_Ist_Ges
FROM tbl_VA_Auftragstamm INNER JOIN (qry_Anz_MA_Tag INNER JOIN tbl_VA_AnzTage ON qry_Anz_MA_Tag.VADatum_ID = tbl_VA_AnzTage.ID) ON tbl_VA_Auftragstamm.ID = qry_Anz_MA_Tag.VA_ID
WHERE (((tbl_VA_AnzTage.VADatum)=#3/1/2015#));

