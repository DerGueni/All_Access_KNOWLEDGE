SELECT qry_RchNeu_Tl1_MA.VA_ID, qry_RchNeu_Tl1_MA.kun_ID, qry_RchNeu_Tl1_MA.VADatum, qry_RchNeu_Tl1_MA.VA_Start, qry_RchNeu_Tl1_MA.VA_Ende, 4 AS PreisArt_ID, 0 AS MA_Anz, 0 AS MA_Std, qry_RchNeu_Tl1_MA.Anz_PKW, qry_RchNeu_Tl1_MA.VADatum_ID, qry_RchNeu_Tl1_MA.VAStart_ID
FROM qry_RchNeu_Tl1_MA
WHERE (((qry_RchNeu_Tl1_MA.Anz_PKW)>0));

