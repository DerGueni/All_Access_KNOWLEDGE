-- Query: zqry_Rch_Report_Pos_Auftrag
-- Type: 0
SELECT tbl_Rch_Pos_Auftrag.Rch_ID, tbl_Rch_Kopf.RchNr_Ext, qry_Rch_Report_Anz_Pers.AnzPers, tbl_Rch_Pos_Auftrag.kun_ID, fAuftr_RG(1,[Rch_ID]) AS Kun_Auftrag, fAuftr_RG(2,[Rch_ID]) AS Kun_Ort, fAuftr_RG(3,[Rch_ID]) AS Kun_Location, tbl_Rch_Pos_Auftrag.Beschreibung, tbl_Rch_Pos_Auftrag.VADatum, tbl_Rch_Pos_Auftrag.MA_Start, tbl_Rch_Pos_Auftrag.MA_Ende, tbl_Rch_Pos_Auftrag.Menge, tbl_Rch_Pos_Auftrag.Mengenheit, tbl_Rch_Pos_Auftrag.EzPreis, tbl_Rch_Pos_Auftrag.GesPreis, tbl_Rch_Pos_Auftrag.Anz_MA
FROM (tbl_Rch_Kopf RIGHT JOIN (tbl_Rch_Pos_Auftrag LEFT JOIN qry_Rch_Report_Anz_Pers ON tbl_Rch_Pos_Auftrag.VAStart_ID = qry_Rch_Report_Anz_Pers.VAStart_ID) ON tbl_Rch_Kopf.ID = tbl_Rch_Pos_Auftrag.Rch_ID) INNER JOIN zqry_Rch_Report_Anz_Pers ON tbl_Rch_Kopf.ID = zqry_Rch_Report_Anz_Pers.ID
WHERE (((tbl_Rch_Pos_Auftrag.Rch_ID)=Get_Priv_Property("prp_Akt_Rch_ID")));

