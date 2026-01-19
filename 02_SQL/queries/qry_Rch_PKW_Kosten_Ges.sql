SELECT qry_Rch_PKW_Einzel.VA_ID, qry_Rch_PKW_Einzel.VADatum, Count(qry_Rch_PKW_Einzel.PKW) AS Menge, 4 AS PreisArt_ID, qry_Rch_PKW_Einzel.kun_ID, qry_Rch_PKW_Einzel.Veranst_Status_ID
FROM qry_Rch_PKW_Einzel
GROUP BY qry_Rch_PKW_Einzel.VA_ID, qry_Rch_PKW_Einzel.VADatum, 4, qry_Rch_PKW_Einzel.kun_ID, qry_Rch_PKW_Einzel.Veranst_Status_ID;

