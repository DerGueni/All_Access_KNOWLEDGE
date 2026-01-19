SELECT qry_Rch_PKW_Einzel.kun_ID, qry_Rch_PKW_Einzel.VA_ID, qry_Rch_PKW_Einzel.VADatum, qry_Rch_PKW_Einzel.VAStart_ID, qry_Rch_PKW_Einzel.MA_Start, qry_Rch_PKW_Einzel.MA_Ende, Count(qry_Rch_PKW_Einzel.PKW) AS Menge, 4 AS PreisArt_ID, Nz([EurPreis],0) AS EzPreis, Nz([MwStSatz],1) AS MwSt, 0 AS Anz_MA
FROM qry_Rch_PKW_Einzel LEFT JOIN qry_Rch_Kosten_PKW ON qry_Rch_PKW_Einzel.VA_ID = qry_Rch_Kosten_PKW.VA_ID
WHERE (((qry_Rch_PKW_Einzel.Veranst_Status_ID)=3))
GROUP BY qry_Rch_PKW_Einzel.kun_ID, qry_Rch_PKW_Einzel.VA_ID, qry_Rch_PKW_Einzel.VADatum, qry_Rch_PKW_Einzel.VAStart_ID, qry_Rch_PKW_Einzel.MA_Start, qry_Rch_PKW_Einzel.MA_Ende, 4, Nz([EurPreis],0), Nz([MwStSatz],1), 0
HAVING (((qry_Rch_PKW_Einzel.kun_ID)=Get_Priv_Property("prp_Rechnung_AktKunde")));

