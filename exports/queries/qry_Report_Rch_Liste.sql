-- Query: qry_Report_Rch_Liste
-- Type: 0
SELECT tbl_KD_Kundenstamm.kun_Firma, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt, tbl_Rch_Pos_Auftrag.VADatum, tbl_Rch_Pos_Auftrag.Anz_MA, tbl_Rch_Pos_Auftrag.Beschreibung, tbl_Rch_Pos_Auftrag.MA_Start, tbl_Rch_Pos_Auftrag.MA_Ende, Nz(CDbl(timeberech_G([VADatum],[MA_Start],[MA_Ende],[Preisart_ID])),0) AS AnzStd, tbl_Rch_Pos_Auftrag.Menge, tbl_Rch_Pos_Auftrag.EzPreis, tbl_Rch_Pos_Auftrag.GesPreis, tbl_Rch_Kopf.Zwi_Sum1 AS Ges_Alles
FROM ((tbl_Rch_Pos_Auftrag INNER JOIN tbl_VA_Auftragstamm ON tbl_Rch_Pos_Auftrag.VA_ID = tbl_VA_Auftragstamm.ID) INNER JOIN tbl_KD_Kundenstamm ON tbl_Rch_Pos_Auftrag.kun_ID = tbl_KD_Kundenstamm.kun_Id) INNER JOIN tbl_Rch_Kopf ON tbl_Rch_Pos_Auftrag.VA_ID = tbl_Rch_Kopf.VA_ID
WHERE (((tbl_Rch_Pos_Auftrag.VA_ID)=Get_Priv_Property("prp_Report1_Auftrag_ID")))
ORDER BY tbl_Rch_Pos_Auftrag.PreisArt_ID, tbl_Rch_Pos_Auftrag.VADatum, tbl_Rch_Pos_Auftrag.MA_Start, tbl_Rch_Pos_Auftrag.MA_Ende;

