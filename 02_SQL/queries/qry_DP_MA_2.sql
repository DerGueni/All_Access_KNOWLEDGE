SELECT qry_DP_Alle_MA_Zt.MA_ID, qry_DP_Alle_MA_Zt.VADatum, Sum(qry_DP_Alle_MA_Zt.Hlp) AS SummevonHlp
FROM qry_DP_Alle_MA_Zt
GROUP BY qry_DP_Alle_MA_Zt.MA_ID, qry_DP_Alle_MA_Zt.VADatum
HAVING (((Sum(qry_DP_Alle_MA_Zt.Hlp))>1));

