SELECT qry_lst_Row_Auftrag.Datum, Count(qry_lst_Row_Auftrag.Soll) AS AnzahlvonSoll
FROM qry_lst_Row_Auftrag LEFT JOIN tbl_MA_VA_Zuordnung ON qry_lst_Row_Auftrag.[tbl_VA_AnzTage].[ID] = tbl_MA_VA_Zuordnung.[VADatum_ID]
GROUP BY qry_lst_Row_Auftrag.Datum;

