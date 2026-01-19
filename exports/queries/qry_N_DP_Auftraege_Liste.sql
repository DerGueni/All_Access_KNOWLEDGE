-- Query: qry_N_DP_Auftraege_Liste
-- Type: 0
SELECT [tbl_VA_Auftragstamm].[ID] AS VA_ID, [tbl_VA_AnzTage].[ID] AS AnzTage_ID, qry_lst_Row_Auftrag.Datum, qry_lst_Row_Auftrag.Auftrag, qry_lst_Row_Auftrag.Objekt, qry_lst_Row_Auftrag.Ort, qry_lst_Row_Auftrag.Soll, qry_lst_Row_Auftrag.Ist
FROM qry_lst_Row_Auftrag
WHERE qry_lst_Row_Auftrag.Datum >= Date()
ORDER BY qry_lst_Row_Auftrag.Datum, qry_lst_Row_Auftrag.Auftrag;

