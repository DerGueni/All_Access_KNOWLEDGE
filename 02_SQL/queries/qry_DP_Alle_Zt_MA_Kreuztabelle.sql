TRANSFORM First(qry_DP_Alle_MA_Zt.ZuordID) AS ErsterWertvonZuordID
SELECT qry_DP_Alle_MA_Zt.MAName, qry_DP_Alle_MA_Zt.MA_ID
FROM qry_DP_Alle_MA_Zt
GROUP BY qry_DP_Alle_MA_Zt.MAName, qry_DP_Alle_MA_Zt.MA_ID
PIVOT Format([VADatum],"Short Date");

