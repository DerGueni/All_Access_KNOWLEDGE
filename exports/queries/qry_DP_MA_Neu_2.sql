-- Query: qry_DP_MA_Neu_2
-- Type: 0
SELECT *
FROM qry_DP_MA_Neu_1
WHERE (((qry_DP_MA_Neu_1.VADatum) Between #11/24/2015# And #11/30/2015#) And ((qry_DP_MA_Neu_1.MA_ID)>0));

